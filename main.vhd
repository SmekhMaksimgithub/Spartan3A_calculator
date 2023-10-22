----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:52:34 05/03/2011 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
generic (
	  freq : std_logic_vector (26 downto 0) := "010111110101111000001111111" 
    );	
    Port ( 		 
	 BTN_WEST : in  STD_LOGIC;
	 BTN_EAST : in  STD_LOGIC;
	  BTN_NORTH : in  STD_LOGIC;
	   BTN_SOUTH : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			   SW : in   STD_LOGIC_VECTOR(3 downto 0);
           LED:out   STD_LOGIC_VECTOR(7 downto 0)
			  );
end main;




architecture Behavioral of main is
signal LED_tmp : std_logic_vector (7 downto 0):= "00000000";

--
-- declaration of KCPSM3
--

component embedded_kcpsm3 is
    Port (      port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
            read_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
end component embedded_kcpsm3;

--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--

signal port_id         : std_logic_vector(7 downto 0);
signal out_port        : std_logic_vector(7 downto 0);
signal in_port         : std_logic_vector(7 downto 0);
signal write_strobe    : std_logic;
signal read_strobe     : std_logic;
signal interrupt       : std_logic := '0';
signal interrupt_ack   : std_logic;


signal e_t1, e_t2 ,n_t1, n_t2 ,s_t1, s_t2,w_t1, w_t2 : std_logic; -- to detect push


begin

  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------

 processor: embedded_kcpsm3
    port map(      port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => '0',
                       clk => clk);

  ----------------------------------------------------------------------------------------------------------------------------------
  -- The inputs connect via a pipelined multiplexer
  ----------------------------------------------------------------------------------------------------------------------------------

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

     if port_id="0000000" then
        -- read data at address 01 hex
        in_port <= "0000000" & BTN_WEST;
    end if;
	 if port_id="00000001" then
        -- read data at address 01 hex
        in_port <= "0000000" &  BTN_EAST;
    end if;
	 if port_id="00000010" then
        -- read data at address 01 hex
        in_port <= "0000000" & BTN_NORTH;
    end if;
	 if port_id="00000011" then
        -- read data at address 01 hex
        in_port <= "0000000" & BTN_SOUTH;
    end if;
	 
	 if port_id="00000100" then
        -- read data at address 01 hex
        in_port <="0000"& SW;
    end if;


    end if;

  end process input_ports;


  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------

  -- adding the output registers to the clock processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then

        -- Output at address 04 hex with data bit0 

        if port_id = "00000101" then
          LED_tmp <= out_port;
        end if;

      end if;

    end if; 

  end process output_ports;

 --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is a generated for WORK change from 0 to 1
  -- Interrupt is automatically cleared by interrupt acknowledgment from KCPSM3.
  --

 Timer: process(clk)
  begin

    if clk'event and clk='1' then
      e_t1<= BTN_EAST;
		e_t2<= e_t1;
		w_t1<= BTN_WEST;
		w_t2<= w_t1;
		s_t1<= BTN_SOUTH;
		s_t2<= s_t1;
		n_t1<= BTN_NORTH;
		n_t2<= n_t1;
		
      if interrupt_ack = '1' then
         interrupt <= '0';
       elsif e_t1 = '1' and  e_t2 = '0' then 
         interrupt <= '1';
			elsif w_t1 = '1' and  w_t2 = '0' then 
         interrupt <= '1';
			elsif s_t1 = '1' and  s_t2 = '0' then 
         interrupt <= '1';
			elsif n_t1 = '1' and  n_t2 = '0' then 
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;
    end if;
  end process Timer;
  
 
  
  
--process (clk)
--begin 
  --if (rising_edge(clk)) then
  --  
  --end if;
--end process;


LED <= LED_tmp;




end Behavioral;

