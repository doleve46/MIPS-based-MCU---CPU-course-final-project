--  LED GPO module, connected to the bus
-- decodes the address on the Address Bus to determine
-- which module this address belongs to
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.aux_package.all;

ENTITY  GPIO_Decoder IS
	PORT(	Address		 		: IN 	STD_LOGIC_VECTOR(11 DOWNTO 0);
			CS					: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
END GPIO_Decoder;

ARCHITECTURE behavior OF GPIO_Decoder IS

BEGIN

	WITH Address SELECT CS <=
		"10000000" WHEN X"800", -- LEDR
		"01000000" WHEN X"804",	-- HEX0
		"00100000" WHEN X"805",	-- HEX1
		"00010000" WHEN X"808",	-- HEX2
		"00001000" WHEN X"809",	-- HEX3
		"00000100" WHEN X"80C",	-- HEX4
		"00000010" WHEN X"80D",	-- HEX5
		"00000001" WHEN X"810",	-- SW
		"00000000" WHEN OTHERS;

END behavior;

