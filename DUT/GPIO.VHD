--  LED GPO module, connected to the bus
-- enveloping module for all GPIO connections
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  GPIO IS
	GENERIC(AddrBusSize : INTEGER := 12;
			DataBusSize : INTEGER := 32
			);
	PORT(	Address		 				: IN 	STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0); -- Relevant address signals
			DataBus						: INOUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
			MemRead,MemWrite			: IN	STD_LOGIC;
			HEX0,HEX1,HEX2				: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX3,HEX4,HEX5				: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
			LEDR						: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			SW							: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			rst,mclk							: IN	STD_LOGIC
			);
END GPIO;

ARCHITECTURE structure OF GPIO IS

TYPE mat IS ARRAY (5 DOWNTO 0) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX_out : mat;
SIGNAL CS : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

HEX0 <= HEX_out(0);
HEX1 <= HEX_out(1);
HEX2 <= HEX_out(2);
HEX3 <= HEX_out(3);
HEX4 <= HEX_out(4);
HEX5 <= HEX_out(5);


AddrDecode: GPIO_Decoder PORT MAP(
						Address => Address,
						CS => CS
						);
	
LEDROut:	LedR_GPO PORT MAP(
						CS => CS(7),
						MemRead => MemRead,
						MemWrite => MemWrite,
						Data => DataBus,
						GPout => LEDR,
						rst => rst,
						clk => mclk
						);
	
Switches:	Switches_GPI PORT MAP(
						CS => CS(0),
						MemRead => MemRead,
						Data => DataBus,
						GPin => SW
						);
						
mapHexGPO:		for i in 1 to 6 generate
			mapHex: HEX_GPO PORT MAP(
						CS => CS(7-i),
						MemRead => MemRead,
						MemWrite => MemWrite,
						Data => DataBus,
						GPout => HEX_out(i-1),
						rst => rst,
						clk => mclk
						);
				end generate;
						
						

END structure;




