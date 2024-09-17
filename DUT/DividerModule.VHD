----------------------------------------
-- Hardware divider shift-register based.
-- THIS IS THE ENVELEOPING MODULE. OPERATIVE SUB-MODULE IS "DIVIDER.VHD"
-- listens to the AddressBus and MemWrite/read control lines.
-- upon encountering addresses linked to this module, sends to receieves
-- data to/from DataBus based on the control lines.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  DivideModule IS
	GENERIC (N : INTEGER := 32);
	PORT(	mclk,rst,divclk		: IN STD_LOGIC;
			DIVIFG				: OUT STD_LOGIC;
			Address 			: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			MemWrite,MemRead 	: IN STD_LOGIC;
			DataBus				: INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
			);
END DivideModule;

ARCHITECTURE behavior OF DivideModule IS

SIGNAL Divisor,Dividend		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL Residue,Quotient		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL DataOut				: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL divrst,ena,div_done		: STD_LOGIC := '0';

BEGIN
	---- DATA OUT ----
	-- Dump data output onto bus
	DataBus <= DataOut WHEN MemRead='1' ELSE (others => 'Z');
	
	-- Choose which data to output by address
	WITH Address SELECT
		DataOut <= Quotient WHEN X"834", Residue WHEN X"838", (others => 'Z') WHEN OTHERS;
	
	---- DATA IN ----
	
	-- After we load the divisor from this address we begin
	-- In divider we load the inputs during divrst='1'
	startDiv: PROCESS(mclk, rst)
		BEGIN
			IF (rising_edge(mclk)) THEN
				IF (Address = X"830" and MemWrite='1') THEN
					divrst <= '1';
				ELSE
					divrst <= '0';
				END IF;
			END IF;
		END PROCESS;
	--divrst <= '1' WHEN (Address = X"830" and MemWrite='1') ELSE '0';
	ena <= NOT divrst;
	
	divRegs: PROCESS(mclk, rst)
		BEGIN
			IF (rst='1') THEN
				Dividend <= (others => '0');
				Divisor <= (others => '0');
			ELSIF (rising_edge(mclk) and MemWrite='1') THEN
				IF (Address=X"82C") THEN
					Dividend <= DataBus;
				ELSIF (Address=X"830") THEN
					Divisor <= DataBus;
				END IF;
			END IF;
		END PROCESS;
	

	-- Interrupt flag
	DIVIFG <= div_done;
	
	
	MultiCycleDivider: Divide PORT MAP (
										clk => divclk,
										sysrst => rst,
										divrst => divrst,
										ena => ena,
										done => div_done,
										Dividend => Dividend,
										Divisor => Divisor,
										Residue => Residue,
										Quotient => Quotient);
	
	
END behavior;

