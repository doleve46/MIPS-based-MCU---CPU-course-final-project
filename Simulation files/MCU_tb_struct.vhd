LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

LIBRARY work;
USE work.aux_package.all;

ENTITY MCU_tb IS
   Generic (Sim : boolean := true;
			width_ITCM_bol : integer := 8; -- 8 on ModelSim / 10 on Quartus
			width_DTCM_bol : integer := 10); -- 10 on ModelSim / 12(10?) on Quartus
-- Declarations

END MCU_tb ;

ARCHITECTURE struct OF MCU_tb IS

   -- Architecture declarations

   -- Internal signal declarations
SIGNAL KEY0,KEY1,KEY2,KEY3 	: STD_LOGIC;
SIGNAL Switches				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL LEDR 				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL HEX0,HEX1,HEX2 		: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX3,HEX4,HEX5 		: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL PWM 					: STD_LOGIC;
SIGNAL mclk,divclk 			: STD_LOGIC;

   -- Component Declarations
Component MCU IS
	Generic (Sim : boolean := false;
			width_ITCM_bol : integer := 10; -- 8 on ModelSim / 10 on Quartus
			width_DTCM_bol : integer := 10); -- 8 on ModelSim / 10 on Quartus
	PORT(
		KEY0,KEY1,KEY2,KEY3			: IN 	STD_LOGIC;
		Switches					: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		LEDR						: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0,HEX1,HEX2				: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3,HEX4,HEX5				: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		PWM							: OUT	STD_LOGIC;
		clk					: IN  	STD_LOGIC -- divclk
		);
END Component;
----
Component MCU_tester IS
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
END Component ;
----
BEGIN

   -- Instance port mappings.
U_0 : MCU
	GENERIC MAP (Sim, width_ITCM_bol,width_DTCM_bol)
	PORT MAP (
		KEY0 => KEY0,
		KEY1 => KEY1,
		KEY2 => KEY2,
		KEY3 => KEY3,
		Switches => Switches,
		LEDR => LEDR,
		HEX0 => HEX0, 
		HEX1 => HEX1,
		HEX2 => HEX2,
		HEX3 => HEX3, 
		HEX4 => HEX4,
		HEX5 => HEX5,
		PWM => PWM,
		clk => MCLK--,
		--divclk => DIVCLK
		);
		
U_1 : MCU_tester
	PORT MAP (
		KEY1_IN => KEY1,
		KEY2_IN => KEY2,
		KEY3_IN => KEY3,
		Switches_in => Switches,
		LEDR_receieved => LEDR,
		HEX0 => HEX0,
		HEX1 => HEX1,
		HEX2 => HEX2,
		HEX3 => HEX3,
		HEX4 => HEX4,
		HEX5 => HEX5,
		PWM => PWM,
		mclk => MCLK,
		reset => KEY0
		);
END struct;
