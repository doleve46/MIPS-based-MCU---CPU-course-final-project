--  LED GPO module, connected to the bus
-- LEDs handler module, responsible for controlling the FPGA board LEDs.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  LedR_GPO IS
	PORT(	CS			 	: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			MemWrite	    : IN 	STD_LOGIC;
			Data 			: INOUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GPout 			: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			rst,clk				: IN STD_LOGIC
			);
END LedR_GPO;

ARCHITECTURE behavior OF LedR_GPO IS

SIGNAL en_write, en_read		: STD_LOGIC;
SIGNAL LatchOut 				: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
	-- Only enable if the relevant control line signal is activated,
	-- and the relevant Chip Select is used.
	en_write <= MemWrite and CS;
	en_read <= MemRead and CS;
	-- Read write capability to bus
	Data <= X"000000" & LatchOut when (en_read = '1') else (others => 'Z');
	GPout <= LatchOut;
	-- Latch to capture the data from bus when CS and MemWrite
	dlatch: PROCESS (clk, rst) 
	BEGIN
		IF (rst='1') THEN
			LatchOut <= (others => '0');
		ELSIF (rising_edge(clk) and en_write='1') then
			LatchOut <= Data(7 DOWNTO 0);
		END IF;
	END PROCESS;
END behavior;

