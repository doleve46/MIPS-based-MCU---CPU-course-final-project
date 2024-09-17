--  LED GPO module, connected to the bus
-- HEX handler module - handles the interruction with the FPGA board HEX units
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  HEX_GPO IS
	PORT(	CS			: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			MemWrite	    : IN 	STD_LOGIC;
			Data 			: INOUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GPout			: OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			rst,clk				: IN	STD_LOGIC
			);
END HEX_GPO;

ARCHITECTURE behavior OF HEX_GPO IS

SIGNAL en_write,en_read		: STD_LOGIC;
SIGNAL LatchOut				: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	-- Only enable if the relevant control line signal is activated,
	-- and the relevant Chip Select is used.
	en_write <= MemWrite and CS;
	en_read  <= MemRead and CS;
	-- Read write capability to bus
	Data <= X"0000000" & LatchOut when (en_read='1') else (others => 'Z');
	-- Latch to capture the data from bus when CS and MemWrite
	dlatch_lower: PROCESS (clk, rst) 
	BEGIN
		IF (rst='1') THEN
			LatchOut <= (others => '0');
		ELSIF (en_write='1' and rising_edge(clk)) then
			LatchOut <= Data(3 DOWNTO 0);
		END IF;
	END PROCESS;
	
	SevSegLower: SevenSegDecode PORT MAP (LatchOut, GPout);
	
	
END behavior;

