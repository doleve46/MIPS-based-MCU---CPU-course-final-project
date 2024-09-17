----------------------------------------
-- Execute module of the MIPS based single cycle CPU core.
-- Holds the main ALU of the CPU, as well as a smaller ALU for Branching
-- Branch ALU supports pass-through and <<4 (1 control bit)
-- Main ALU supports 10 different operations (as detailed below),
-- controlled via 4 control bits.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- Main ALU "A input"
			Read_data_2 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- Main ALU "B input"
			Sign_extend 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- Branch ALU input
			Branch_Dec_Bit	: IN 	STD_LOGIC; -- Instruction(26) (effeciently distinguish between BEQ and BNE)
			ALUop 			: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0); -- Main ALU operation mode
			BranchALU		: IN	STD_LOGIC; -- Branch ALU operation mode
			Zero			: OUT	STD_LOGIC; -- flag meant for branch-checking
			ALU_Result 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of Main ALU Unit
			Add_Result 		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0); -- output of Branch ALU Unit
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS

	SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Branch_Add 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ALU_ctl				: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL temp1				: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL Mult_in_A,Mult_in_B	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL Zero_within			: STD_LOGIC; 
BEGIN
	
						-- Assign inner signals for Main ALU use
	Binput <= Read_data_2;
	Ainput <= Read_data_1;
						-- Branch ALU Unit --
	Branch_Add	<= (PC_plus_4(9 downto 2) + Sign_extend(7 downto 0)) when BranchALU='1'
				else Sign_extend(7 downto 0); -- changed to obey by BranchALU control line
		Add_result 	<= Branch_Add(7 downto 0);

						-- Generate Zero flag --
	Zero_within <= '1' When (ALU_output_mux(31 downto 0) = X"00000000") else '0';
	Zero <= (Not Zero_within) When Branch_Dec_Bit='1' else Zero_within; -- for BNE/BEQ
	
						-- Main ALU mainframe --
	ALU_Result <= ALU_output_mux;
Process (ALUop, Ainput, Binput)
	variable slt_intermed : STD_LOGIC_VECTOR(31 downto 0); 
	Begin

	Case ALUop is
		When "0001"|"1011" => -- Sub operation - signed
			ALU_output_mux <= Ainput - Binput;
		When "0010" => -- And operation
			ALU_output_mux <= Ainput AND Binput;
		When "0011" => -- Or operation
			ALU_output_mux <= Ainput OR Binput;
		When "0100" => -- Xor operation
			ALU_output_mux <= Ainput XOR Binput;
		When "0101" => -- Shift left logical
			ALU_output_mux <= std_logic_vector(shift_left(unsigned(Ainput), to_integer(unsigned(Binput(10 downto 6)))));
		When "0110" => -- shift right logical
			ALU_output_mux <= std_logic_vector(shift_right(unsigned(Ainput), to_integer(unsigned(Binput(10 downto 6)))));
		When "0111" => -- slt/slti checks
			slt_intermed := Ainput - Binput;
			ALU_output_mux <= X"0000000"&"000"&slt_intermed(31);
		When "1000" => -- multiply
			ALU_output_mux <= (Ainput(15 downto 0) * Binput(15 downto 0));
		When "1010" => -- Out=B & shift left 16 bit
			ALU_output_mux <= Binput(15 downto 0)&X"0000";
		When "0000"|"1001" =>
			ALU_output_mux <= Ainput + Binput;
		When others =>
			ALU_output_mux <= X"00000000";
	End Case;
End Process;


END behavior;

