----------------------------------------
-- Timer external module
-- Functions as a user-controller timer, able to provide a PWM signal as well as
-- interrupts on a user-defined timer overflow value.
----------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
--------------------------------------------
ENTITY Timer IS
  GENERIC (N : INTEGER := 32
		  );   
	PORT (
		mclk,rst			: IN STD_LOGIC;
		Address 			: IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- AddressBus from CPU core
		MemWrite,MemRead 	: IN STD_LOGIC; -- control lines from CPU core (to external modules after manipulation)
		DataBus				: INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		PWMout,Set_BTIFG	: OUT STD_LOGIC -- PWM output signal (to FPGA board) & Timer flag (to interrupt controller)
		);
	END Timer;
-------- Define the logic block architecture -----
ARCHITECTURE behavioral OF Timer IS
	SIGNAL DataOut			: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	
	SIGNAL clk 				: STD_LOGIC := '0';
	SIGNAL clk_divider 		: STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
	SIGNAL pwm_legal_input	: STD_LOGIC;
	
	
	-- Registers
	SIGNAL BTCNT 			: STD_LOGIC_VECTOR (N-1 DOWNTO 0) := (others => '0');
	SIGNAL BTCTL			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BTCL0,BTCL1   	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL BTCCR0,BTCCR1   	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	
	SIGNAL BTCNT_pending_write_data		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL BTCNT_write		: STD_LOGIC;
	SIGNAL BTCNT_pending_write_request 	: STD_LOGIC;
	SIGNAL BTCNT_write_ack 	: STD_LOGIC;

	
	
	-- Aliases for BTCTL
	ALIAS BTSSEL IS BTCTL(4 DOWNTO 3);
	ALIAS BTHOLD IS BTCTL(5);
	ALIAS BTOUTEN IS BTCTL(6);
	ALIAS BTOUTMD IS BTCTL(7);
	ALIAS BTIPx IS BTCTL(2 DOWNTO 0);
	
BEGIN
	---- DATA OUT ----
	-- Dump data output onto bus
	DataBus <= DataOut WHEN MemRead='1' ELSE (others => 'Z');
	
	-- Choose which data to output by address
	WITH Address SELECT DataOut <=
			X"000000" & BTCTL WHEN X"81C",
			BTCNT WHEN X"820",
			BTCCR0 WHEN X"824",
			BTCCR1 WHEN X"828",
			(others => 'Z') WHEN OTHERS;

	---- DATA IN ----
	writeToRegisters: PROCESS(mclk, rst)
		BEGIN
			IF (rst='1') THEN
				BTCCR0 <= (others => '0');
				BTCCR1 <= (others => '0');
				BTCTL <= "00100000"; -- BTHOLD on 1 by default
			ELSIF (rising_edge(mclk) and MemWrite='1') THEN
				IF (Address=X"824") THEN
					BTCCR0 <= DataBus;
				ELSIF (Address=X"828") THEN
					BTCCR1 <= DataBus;
				ELSIF (Address=X"81C") THEN
					BTCTL <= DataBus(7 DOWNTO 0);
				END IF;
			END IF;
		END PROCESS;
	
	
	---- Timer ----
	-- Create mclk divisions for the counter input clk
	clkdivide: PROCESS (mclk,rst)
	BEGIN
		IF (rst='1') THEN
			clk_divider <= (others => '0');
		ELSIF (rising_edge(mclk)) THEN
			clk_divider <= clk_divider + 1;
		END IF;
	END PROCESS;

	-- Select the correct clock for the counter
	WITH BTSSEL SELECT clk <=
				clk_divider(0) WHEN "01", -- MCLK : 2
				clk_divider(1) WHEN "10", -- MCLK : 4
				clk_divider(2) WHEN "11", -- MCLK : 8
				mclk WHEN OTHERS;


	BTCNT_write <= '1' WHEN (MemWrite='1' and Address=X"820") ELSE '0';
	
	counterWriting: PROCESS (mclk, rst)
		BEGIN
			IF (rst='1') THEN
				BTCNT_pending_write_data <= (others => '0');
				BTCNT_pending_write_request <= '0';
			ELSIF (rising_edge(mclk)) THEN
				IF (BTCNT_write='1') THEN
					BTCNT_pending_write_data <= DataBus;
					BTCNT_pending_write_request <= '1';
				ELSIF (BTCNT_write_ack='1') THEN
					BTCNT_pending_write_request <= '0';
				END IF;
			END IF;
		END PROCESS;
	
	counter: PROCESS (clk, rst) 
	BEGIN
		IF (rst='1') then
			BTCNT <= (others => '0');
			BTCNT_write_ack <= '0';
		ELSIF (rising_edge(clk)) THEN -- Counting BTCNT handled by chosen clk
			IF (BTCNT_pending_write_request='1') THEN
				BTCNT <= BTCNT_pending_write_data;
				BTCNT_write_ack <= '1';
			ELSIF (BTHOLD='0') THEN
				BTCNT <= BTCNT + 1;
				BTCNT_write_ack <= '0';
			ELSE
				BTCNT_write_ack <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	-- IFG Select
	WITH BTIPx SELECT
		Set_BTIFG <= BTCNT(0)  WHEN "000",
					 BTCNT(3)  WHEN "001",
					 BTCNT(7)  WHEN "010",
					 BTCNT(11) WHEN "011",
					 BTCNT(15) WHEN "100",
					 BTCNT(19) WHEN "101",
					 BTCNT(23) WHEN "110",
					 BTCNT(25) WHEN "111",
					 '0' WHEN OTHERS;

	---- Output Unit ----
	compareLatch: PROCESS (mclk,rst)
		BEGIN
			IF (rising_edge(mclk)) THEN -- clk or mclk?
				BTCL0 <= BTCCR0;
				BTCL1 <= BTCCR1;
			END IF;
		END PROCESS;
	
	
	pwm_legal_input <= '1' WHEN BTCL0 > BTCL1 ELSE '0';
	outputCompare: PROCESS(clk,rst)
		BEGIN
			IF (rst='1' or BTOUTEN = '0') THEN
				PWMout <= '0';
			ELSIF (rising_edge(clk) and pwm_legal_input='1') THEN
				IF (BTCNT < BTCL1) THEN -- Under BTCL1
					PWMout <= BTOUTMD;
				ELSIF (BTCNT < BTCL0) THEN -- Over BTCL1 Under BTCL0
					PWMout <= not BTOUTMD;
				ELSE PWMout <= BTOUTMD; -- Over both
				END IF;
			END IF;

		END PROCESS;

END behavioral;
