LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU_tester IS
   PORT( 
      KEY1_IN			: OUT STD_LOGIC;
	  KEY2_IN			: OUT STD_LOGIC;
	  KEY3_IN			: OUT STD_LOGIC;
	  Switches_in		: OUT STD_LOGIC_VECTOR(7 downto 0);
	  LEDR_receieved	: IN STD_LOGIC_VECTOR(7 downto 0);
	  HEX0,HEX1,HEX2	: IN STD_LOGIC_VECTOR(6 downto 0);
	  HEX3,HEX4,HEX5	: IN STD_LOGIC_VECTOR(6 downto 0);
      PWM				: IN STD_LOGIC; -- output from MCU 
      MCLK				: OUT STD_LOGIC;
	  reset				: OUT STD_LOGIC -- KEY0
   );

END MCU_tester ;

ARCHITECTURE struct OF MCU_tester IS



   -- ModuleWare signal declarations(v1.9) for instance 'U_0' of 'clk'
   SIGNAL mw_U_0clk : std_logic;

   -- ModuleWare signal declarations(v1.9) for instance 'U_1' of 'pulse'
   SIGNAL mw_U_1pulse : std_logic :='0';


BEGIN
	-- assigning all inputs to do nothing for now
	KEY1_IN <= '1';
	KEY2_IN <= '1';
	KEY3_IN <= '1';
	Switches_in <= (others => '0');
	
	
   -- ModuleWare code(v1.9) for instance 'U_0' of 'clk'
   u_0MCLK_proc: PROCESS
   BEGIN
      WHILE TRUE LOOP
         mw_U_0clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
   END PROCESS u_0MCLK_proc;
   MCLK <= mw_U_0clk;

   
   -- ModuleWare code(v1.9) for instance 'U_1' of 'pulse'
   reset <= mw_U_1pulse;
   u_1pulse_proc: PROCESS
   BEGIN
		mw_U_1pulse <= 
			'1',
			'0' AFTER 20 ns,
			'1' AFTER 120 ns;
		WAIT;
    END PROCESS u_1pulse_proc;

   -- Instance port mappings.

END struct;
