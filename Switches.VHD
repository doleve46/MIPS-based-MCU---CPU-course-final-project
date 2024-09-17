-- Switches GPO module, connected to the bus
-- contains the interface with the Switches, used as input only to the MCU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  Switches_GPI IS
	PORT(	CS			 	: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			Data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GPin			: IN    STD_LOGIC_VECTOR( 7 DOWNTO 0 )
			);
END Switches_GPI;

ARCHITECTURE behavior OF Switches_GPI IS

SIGNAL en_read		: STD_LOGIC;

BEGIN
	-- Only enable if the relevant control line signal is activated,
	-- and the relevant Chip Select is used.
	en_read <= MemRead and CS;
	-- Read write capability to bus
	Data <= X"000000" & GPin when en_read = '1' else (others => 'Z');
	
END behavior;

