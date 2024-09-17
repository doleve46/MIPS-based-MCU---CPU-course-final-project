----------------------------------------
-- control module of the MIPS based CPU core of the design, Single-Cycle design
-- receives the relevant bits from the instruction (6 MSBs & LSBs)
-- based on them, toggles the control lines that enable the required operation
-- in order to deal with Interrupts - receieves request lines from
-- Interrupt Controller (reset & regular request), and sends back an ACK signal
-- while also adding 2 inner control lines to support the interrupt servicing.
-- Interrupt service mechanism - detailed below (line 93)
-- the Interrupt service is designed as a 4 states FSM.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode_in		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0); -- Opcode input - MSBs of Instruction
	RegDst 			: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0); -- control signal to choose Register to write to
	ALUSrcB			: OUT 	STD_LOGIC; -- Mux control line for B input to main ALU unit
	ALUSrcA			: OUT 	STD_LOGIC; -- Mux control line for A input to main ALU unit
	MemtoReg 		: OUT 	STD_LOGIC; -- control line for MUX at the output of the Dmemory unit - choose Dmem or bypass ALU result to RF
	RegWrite 		: OUT 	STD_LOGIC; -- write to RF control line
	MemRead 		: OUT 	STD_LOGIC; -- read from memory control line
	MemWrite 		: OUT 	STD_LOGIC; -- write to memory control line (shared signal for external & Dmemory, split within Dmemory module)
	Branch 			: OUT 	STD_LOGIC; -- Branch control line - for relevant instructions
	ALUop 			: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0); -- main ALU operation control lines (within Execute sub-module)
	Jump			: OUT   STD_LOGIC_VECTOR(1 DOWNTO 0); -- Jump control line - for relevant instructions
	RegData			: OUT   STD_LOGIC; -- control line to choose input to be written to RF
	BranchALU		: OUT	STD_LOGIC; -- Branch ALU unit control line - Pass through or <<4
	FuncCode		: IN	STD_LOGIC_VECTOR(5 DOWNTO 0); -- 6 LSB bits (from fetch), part of MIPS instr. decoding
	clock			: IN 	STD_LOGIC;
	reset_to_Control: IN 	STD_LOGIC; -- From Interrupt Controller module - reset pending from KEY press
	global_reset	: OUT	STD_LOGIC; -- Main reset line (synchornous) - routed to the rest of the MCU
	int_service1	: OUT	STD_LOGIC; -- Control to service interrupts (1/2 cycle service)
	int_service2	: OUT	STD_LOGIC; -- Control to service interrupts (2/2 cycle service)
	int_req			: IN	STD_LOGIC; -- interrupt request - from Interrupt Controller module
	int_ack_out		: OUT	STD_LOGIC -- interrupt acknowledge (to interrupt controller)
	);
	
END control;

ARCHITECTURE behavior OF control IS
	type Operation is
	(R_type, jmp, jal, slti, bne, beq, lui, lw, sw, xori, ori, andi, mul, addi);
	type R_Operation is
	(addd, subb, andd, xorr, slll, srll, adduu, sltt, jrr, orr);
	-- some saved words - hence double ending letter
	signal Current_operation : operation ;
	signal Current_R_Type_op : R_Operation;
	signal Opcode : STD_LOGIC_VECTOR(5 downto 0);
	signal int_ack		: STD_LOGIC;
	
	SIGNAL int_cur_state : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL int_next_state : STD_LOGIC_VECTOR(1 downto 0);
BEGIN
	-- for better readability - using enumerate to distinguish operations
	-- **** FOR BETTER SYNTHESIS - REMOVE BOTH SELECTS BELOW (AND TYPE DEFINITIONS ABOVE)
	-- **** IN THE CTRL. LINES PROCESS, SWAP THE NAMES WITH THE NUMBERS IN THE COMMENTS
	With Opcode_in Select
		Current_operation <= R_type when "000000",
							jmp when "000010",
							jal when "000011",
							slti when "001010",
							bne when "000101",
							beq when "000100",
							lui when "001111",
							lw when "100011",
							sw when "101011",
							xori when "001110",
							ori when "001101",
							andi when "001100",
							mul when "011100",
							addi when others; -- used as default - addi is 001000
	with FuncCode Select
		Current_R_Type_op <= addd when "100000",
							subb when "100010",
							andd when "100100",
							xorr when "100110",
							slll when "000000",
							srll when "000010",
							adduu when "100001",
							sltt when "101010",
							jrr when "001000",
							orr when others; -- used as default - or is 100101
							
	--------------------INTERRUPT SERVICING - FSM & CTRL LINES-------------------------
	-- On rising edge - check if there's an interrupt pending. (else no intr pending -> int_ack=0)
	-- 1. if its RESET:
	--		a. forward reset line to all units under MIPS Core (full CPU reset)
	--		b. send int_ack back to InterruptController (will reset the D-FF holding reset)
	-- 2. if any other Interrupt:
	--		a. placeholder_reg <= PC+4
	--		b. $k0 (R26,GIE register) <= X"00000000"
	-- NEXT CYCLE:
	-- 1. if its (was) RESET: return back to normal
	-- 2. if any other Interrupt:
	--		a. Dmemory_address_in <= TYPE_reg (extended to fit length)
	--		b. MemWrite <= '0' (in case we stopped at SW instr.)
	--		c. PC_reg <= handler_address@TYPE address(DTCM) (from Dmemory output)
	--		^^ this fetches the handler instruction to be ready in the next CYCLE
	--		d. $k1 (R27) <= placeholder register (stores PC'+4 to return to)
	--		e. int_ack <= '1' (sent back to InterruptController)
	--	NEXT CYCLE: BACK TO NORMAL (total time to service interrupt = 2 cycles)

Intr_service_FSM: Process (clock, int_next_state)
BEGIN
	if (rising_edge(clock)) then
		int_cur_state <= int_next_state;
	end if;
end process;

Intr_service_ctrl_lines: Process (int_cur_state, reset_to_Control, int_req) -- this reset is stable & synchoronous
BEGIN
	if int_cur_state="11" then -- already servicing a reset interrupt
		int_next_state <= "00"; -- return to normal
		int_ack <= '1';
		int_service1 <= '0';
		int_service2 <= '0';
		global_reset <= '1'; -- sent reset signal to the whole system
	elsif (reset_to_Control='1') then
		int_next_state <= "11"; -- return to normal after RESET is serviced
		int_ack <= '0';
		int_service1 <= '0';
		int_service2 <= '0';
		global_reset <= '0';
	elsif (int_cur_state="01") then -- state 1 = interrupt service part 1
		int_next_state <= "10";
		int_ack <= '0';
		int_service1 <= '1';
		int_service2 <= '0';
		global_reset <= '0';
	elsif (int_cur_state="10") then -- state 2 == interrupt service part 2
		int_next_state <= "00"; -- return to normal next cycle
		int_ack <= '1';
		int_service1 <= '0';
		int_service2 <= '1';
		global_reset <= '0';
	else -- state 0 = normal operation
		int_ack <= '0';
		int_service1 <= '0';
		int_service2 <= '0';
		global_reset <= '0';
		if (int_req='1') then -- interrupt request pending, not reset
			int_next_state <= "01"; -- begin servicing interrupt
		else -- no interrupt pending
			int_next_state <= "00"; -- normal operation
		end if;
	end if;
end process;
	int_ack_out <= int_ack;
	---------------------------------------------------------------------------------


Process (Current_operation, Current_R_Type_op)
Begin
	CASE(Current_operation) IS
		WHEN R_type => -- R types "000000"
			Case (Current_R_Type_op) is
				When addd => -- add "100000"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0000";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When subb => -- sub "100010"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0001";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When andd => -- and "100100"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0010";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When xorr => -- xor "100110"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0100";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When slll => -- sll "000000"
					RegDst <= "01";
					ALUsrcB <= '1';
					ALUsrcA <= '1';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0101";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When srll => -- srl "000010"
					RegDst <= "01";
					ALUsrcB <= '1';
					ALUsrcA <= '1';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0110";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When adduu => -- addu "100001"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "1001";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When sltt => -- slt "101010"
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0111";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
				When jrr => -- jr "001000"
					RegDst <= "11"; -- to support reti
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '0';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0000";
					Jump <= "10";
					RegData <= '0';
					BranchALU <= '0';
				When others => -- used for OR (100101) instruction & default
					RegDst <= "01";
					ALUsrcB <= '0';
					ALUsrcA <= '0';
					MemtoReg <= '0';
					RegWrite <= '1';
					MemRead <= '0';
					MemWrite <= '0';
					Branch <= '0';
					ALUop <= "0011";
					Jump <= "00";
					RegData <= '0';
					BranchALU <= '0';
			end Case;
		WHEN jmp => -- jump "000010"
			RegDst <= "00";
			ALUsrcB <= '0';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '0';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0000";
			Jump <= "01";
			RegData <= '0';
			BranchALU <= '0';
		WHEN jal => -- jal "000011"
			RegDst <= "10";
			ALUsrcB <= '0';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0000";
			Jump <= "01";
			RegData <= '1';
			BranchALU <= '0';
		WHEN slti => -- slti "001010"
			RegDst <= "01";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0111";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN bne => -- bne "000101"
			RegDst <= "00";
			ALUsrcB <= '0';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '0';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '1';
			ALUop <= "1011";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '1'; -- add operation
		WHEN beq => -- beq "000100"
			RegDst <= "00";
			ALUsrcB <= '0';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '0';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '1';
			ALUop <= "0001";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '1'; -- add operation
		WHEN lui => -- lui "001111"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "1010";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN lw => -- Lw "100011"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '1';
			RegWrite <= '1';
			MemRead <= '1';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0000";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN sw => -- sw "101011"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '0';
			MemRead <= '0';
			MemWrite <= '1';
			Branch <= '0';
			ALUop <= "0000";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN xori => -- xori "001110"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0100";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN ori => -- ori "001101"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0011";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN andi => -- andi "001100"
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0010";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN mul => -- mul "011100"
			RegDst <= "01";
			ALUsrcB <= '0';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "1000";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
		WHEN OTHERS => -- used for addi (001000) instruction & default
			RegDst <= "00";
			ALUsrcB <= '1';
			ALUsrcA <= '0';
			MemtoReg <= '0';
			RegWrite <= '1';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			ALUop <= "0000";
			Jump <= "00";
			RegData <= '0';
			BranchALU <= '0';
	END CASE;
End Process;

   END behavior;
