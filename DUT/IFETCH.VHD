----------------------------------------
-- Fetch module of the MIPS-based single-cycle CPU core.
-- contains the PC register and its relevant logic.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	Generic (Sim : boolean := false;
			 width_ITCM_bol : integer := 10); -- Modelsim=8 / Quartus=10
	PORT(	Instruction 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
        	PC_plus_4_out 		: OUT	STD_LOGIC_VECTOR(9 DOWNTO 0); -- PC+4 to other modules
        	Add_result 			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- result of Branch ALU
        	Branch 				: IN 	STD_LOGIC; -- control line - detailed in Control module
        	Zero				: IN 	STD_LOGIC; -- Zero flag, from Execute module
        	clock, reset 		: IN 	STD_LOGIC;
			Jump				: IN	STD_LOGIC_VECTOR(1 DOWNTO 0); -- control line - detailed in Control module
			ALUSrcA_Direct		: IN	STD_LOGIC_VECTOR(7 downto 0); -- used for Jump Instructions - address to jump to
			int_service1		: IN	STD_LOGIC; -- control line - detailed in Control module
			int_service2		: IN	STD_LOGIC; -- control line - detailed in Control module
			intr_next_pc_after 	: OUT STD_LOGIC_VECTOR(7 downto 0); -- PC to return to after interrupt service completion - saved into RF (R27)
			handler_to_PC		: IN 	STD_LOGIC_VECTOR(7 downto 0) -- interrupt handler address from Dmemory - based on TYPE register content
			);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4		 	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Mem_Addr					: STD_LOGIC_VECTOR(width_ITCM_bol-1 DOWNTO 0); -- 9 downto 0 for Quartus
	SIGNAL next_PC, Almost_Next_PC	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Instruction_within		: STD_LOGIC_VECTOR(31 DOWNTO 0); 
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram -- imports pre-made Altera sync. RAM module
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => width_ITCM_bol, -- 8 on modelSim / 10 on Quartus
		numwords_a => 1024,
		lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = ITCM",
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\ronny\OneDrive\Documents\VHDL Lab\Final Proj\SW QA - ASM codes\Interrupt based IO\test1\ITCM.hex",
		intended_device_family => "Cyclone V")
	PORT MAP (
		clock0     	=> clock,
		address_a 	=> Mem_Addr, 
		q_a 		=> Instruction_within );
		
		Instruction <= Instruction_within; -- linking the pulled instruction outside
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		
		-- Simulation vs Synthesis change --		
		SimOrSynthPragma: if sim generate
			Mem_Addr <= next_PC;
		else generate
			Mem_Addr <=  next_PC&"00";
		end generate;
				
						-- Adder to increment PC by 4        
      	PC_plus_4(9 DOWNTO 2)  <= PC(9 DOWNTO 2) + 1;
       	PC_plus_4(1 DOWNTO 0)  <= "00";

		--- NEW mux logic  to select next PC (Branch Add. , PC+4 or direct Jump)
		
		Almost_Next_PC <= Instruction_within(7 downto 0) when (Jump = "01")
						else ALUSrcA_Direct(7 downto 0) when (Jump = "10")
						else Add_result when ((Branch = '1') and (Zero = '1'))
						else PC_plus_4(9 downto 2);
		
		Next_PC <= X"00" when (reset = '1')
					else handler_to_PC when (int_service2 = '1') -- to support interrupts
					else Almost_Next_PC;
		
		
	PC_reg: PROCESS
		BEGIN
			WAIT UNTIL (clock'EVENT) AND (clock = '1');
			if reset = '1' then
				PC(9 downto 2) <= X"00";
			elsif (clock'EVENT and clock='1') then
				PC(9 downto 2) <= next_PC;
			end if;

	END PROCESS;
	
	holding_handler_addr: Process (clock,reset,int_service1)
	Begin
		If (reset= '1') then
			intr_next_pc_after <= X"00";
		elsif (rising_edge(clock)) then
			if (int_service1='1') then -- serves as enable to save PC+4 when interrupt servicing
				intr_next_pc_after <= Almost_Next_PC; -- PC_plus_4(9 downto 2)
			end if;
		end if;
	End Process;
	
END behavior;
