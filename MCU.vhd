----------------------------------------
-- Top level MCU module
-- connects all the different modules together:
-- the CPU core, Timer, Divider, Interrupt Controller & GPIO interface.
-- ** TO DIFFERENTIATE SIMULATION AND SYNTHESIS WHILE USING THE SAME CODE, THE GENERICS ARE USED TO CHANGE
-- ** THE ADJUST THE CHANGES BETWEEN THE SIMULATION ENVIR. AND SYNTHESIS FOR FPGA BOARD.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.all;

ENTITY MCU IS
	Generic (Sim : boolean := false;
			width_ITCM_bol : integer := 10; -- 8 on ModelSim / 10 on Quartus
			width_DTCM_bol : integer := 10); -- 8 on ModelSim / 10 on Quartus
	PORT(
		KEY0,KEY1,KEY2,KEY3			: IN 	STD_LOGIC;	-- Physical keys on the FPGA board
		Switches					: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- Physical switches on the FPGA board
		LEDR						: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- Physical LEDs on the FPGA board
		HEX0,HEX1,HEX2				: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0); -- Physical HEX screens on the FPGA board
		HEX3,HEX4,HEX5				: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		PWM							: OUT	STD_LOGIC; -- Output PWM signal - routed to a specific pin on the FPGA board
		clk							: IN  	STD_LOGIC
		);
END 	MCU;

ARCHITECTURE structure OF MCU IS

	SIGNAL DataBus					: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => 'Z');
	SIGNAL AddressBus				: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL MemWrite 				: STD_LOGIC;
	SIGNAL MemRead 					: STD_LOGIC;
	SIGNAL DIVIFG,BTIFG				: STD_LOGIC;
	SIGNAL GIE,int_req,int_ack		: STD_LOGIC;
	SIGNAL INT_TYPE					: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL interrupt_sources		: STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL KEY0_not					: STD_LOGIC;
	SIGNAL global_reset_to_external	: STD_LOGIC;
	SIGNAL reset_to_Control 		: STD_LOGIC;
	SIGNAL divclk,mclk 		: STD_LOGIC := '0';
	
	component mclkPLL is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		outclk_1 : out std_logic;        -- outclk1.clk
		locked   : out std_logic         --  locked.export
	);
	end component;
	
	
	
BEGIN

	PLLMap: mclkPLL PORT MAP(
					refclk => clk,
					outclk_0 => divclk,
					outclk_1 => mclk
					);


	CPUMap: MIPS GENERIC MAP(Sim, width_ITCM_bol, width_DTCM_bol)
				 PORT MAP(
					reset_to_Control => reset_to_Control,
					clock => mclk,
					DataBus => DataBus,
					addressBus => AddressBus,
					MemWrite_out => MemWrite,
					MemRead_out => MemRead,
					GIE => GIE,
					intr_TYPE_reg => INT_TYPE,
					int_req => int_req,
					global_reset_to_external => global_reset_to_external,
					int_ack_out => int_ack
					);
	
	
	GPIOMap: GPIO PORT MAP(
					Address => AddressBus,
					DataBus => DataBus,
					MemRead => MemRead,
					MemWrite => MemWrite,
					HEX0 => HEX0,
					HEX1 => HEX1,
					HEX2 => HEX2,
					HEX3 => HEX3,
					HEX4 => HEX4,
					HEX5 => HEX5,
					LEDR => LEDR,
					SW => Switches,
					rst => global_reset_to_external,
					mclk => mclk
					);
	
	DividerMap: DivideModule PORT MAP(
					mclk => mclk,
					rst => global_reset_to_external,
					divclk => divclk,
					DIVIFG => DIVIFG,
					Address => AddressBus,
					MemWrite => MemWrite,
					MemRead => MemRead,
					DataBus => DataBus
					);
	
	TimerMap: Timer PORT MAP(
					mclk => mclk,
					rst => global_reset_to_external,
					Address => AddressBus,
					MemWrite => MemWrite,
					MemRead => MemRead,
					DataBus => DataBus,
					PWMout => PWM,
					Set_BTIFG => BTIFG
					);
	
	KEY0_not <= NOT KEY0; -- keys are 'on' when not pressed at this specific FPGA board - logic was designed with the alternative in mind.
	interrupt_sources <= DIVIFG & (NOT KEY3) & (NOT KEY2) & (NOT KEY1) & BTIFG & '0' & '0';
	IntContMap: InterruptController PORT MAP(
					TYPE_out => INT_TYPE,
					GIE => GIE,
					int_req_out => int_req,
					int_ack => int_ack,
					clk => mclk,
					reset_in => KEY0_not,
					interrupt_sources => interrupt_sources,
					addressBus_relevant => AddressBus,
					DataBus => DataBus,
					MemWrite => MemWrite,
					MemRead => MemRead,
					reset_to_Control => reset_to_Control,
					global_reset => global_reset_to_external
					);
	
END structure;

