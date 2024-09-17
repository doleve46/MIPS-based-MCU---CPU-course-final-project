----------------------------------------
-- Interurpt Controller sub-module
-- handles a single interrupt logic as required in the project
-- each interrupt source is fed to a D-FF as a clock input, while having '1' as D input.
-- there's an assigned reset line, controlled via the Interrupt Controller parent-module
-- an interrupt flag is sent (to IFG register) when the associated enable bit and 
-- the stored interrupt are both '1'.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--------------------------------------------------------------
entity interruptLogic is
	PORT(	clk				: IN 	STD_LOGIC; -- interrupt source - used as clk
			clearInterrupt	: IN	STD_LOGIC; -- clear interrupt
			interruptEnable	: IN	STD_LOGIC; -- from IE register
			IntrFlag_out	: OUT	STD_LOGIC -- towards IFG register
			);

end interruptLogic;
-------------------------------------------------------------------
architecture intrArch of interruptLogic is
	SIGNAL stored_interrupt	: STD_LOGIC;
	
begin
InterruptMem: Process (clk, clearInterrupt)
	BEGIN
		If clearInterrupt='1' then
			stored_interrupt <= '0';
		Elsif (clk'EVENT and clk='1') then
			stored_interrupt <= '1';
		end if;
	End Process;

	IntrFlag_out <= (interruptEnable and stored_interrupt);
	
end intrArch;
