----------------------------------------
-- Decode module of the MIPS-based single-cycle CPU core.
-- contains the Register File (32 registers, each 32 bits long)
-- and the enveloping logic responsible for outputting and receieving data
-- based on control signals from the Control module.

-- Upon reset, designed the assign the numerical value of each Register
-- to its numbered value (e.g. register #15 will be assigned the value "15").
-- register #0 is always 0, and cannot be over-wrriten with another value.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	PORT(	read_data_1		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- towards main ALU A input
			read_data_2		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- towards main ALU B input
			Instruction		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- From fetch module - entire instruction to be performed 
			ALUop			: IN	STD_LOGIC_VECTOR(3 downto 0); -- ALU operation (used for Zero flag logic)
			RegWrite 		: IN 	STD_LOGIC; -- control line - detailed within Control module
			RegDst 			: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0); -- control line - detailed within Control module
			ALUSrcA			: IN	STD_LOGIC; -- control line - detailed within Control module
			ALUSrcB			: IN	STD_LOGIC; -- control line - detailed within Control module
			Sign_extend 	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- sign extended immediate from the instruction
			clock,reset		: IN 	STD_LOGIC;
			Dmem_write_data	: OUT	STD_LOGIC_VECTOR(31 downto 0); -- RF 2nd port output (data) - routed to Dmemory
			GIE_out			: OUT	STD_LOGIC; -- GIE bit from RF (register #26)
			int_service1	: IN	STD_LOGIC; -- control line - detailed within Control module
			int_service2	: IN	STD_LOGIC; -- control line - detailed within Control module
			write_RF_data	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0) -- data to be written to RF - from Dmemory module
			);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
	TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_data					: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL read_data_1_port				: STD_LOGIC_VECTOR(31 downto 0); 
	SIGNAL read_data_2_port				: STD_LOGIC_VECTOR(31 downto 0); 
	SIGNAL Sign_extend_within			: STD_LOGIC_VECTOR(31 downto 0); 
	SIGNAL write_register_address_31	: STD_LOGIC_VECTOR(4 downto 0):=B"11111"; 
	SIGNAL write_register_data_ctrl		: STD_LOGIC_VECTOR(1 downto 0); 
	SIGNAL PC_Plus_8					: STD_LOGIC_VECTOR(9 downto 0); 
	SIGNAL write_register_address_k0	: STD_LOGIC_VECTOR(4 downto 0):=B"11010"; 
	SIGNAL write_reg_addr_mux			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL detect_reti					: STD_LOGIC; 
	SIGNAL Write_to_RF					: STD_LOGIC;
	SIGNAL GIE_reg						: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL zero_or_sign_extend			: STD_LOGIC;

BEGIN
	read_register_1_address 	<= Instruction(25 DOWNTO 21); -- rs
   	read_register_2_address 	<= Instruction(20 DOWNTO 16); -- rt
   	write_register_address_1	<= Instruction(15 DOWNTO 11); -- rd
   	write_register_address_0 	<= Instruction(20 DOWNTO 16);
	Instruction_immediate_value <= Instruction(15 DOWNTO 0);
	detect_reti					<= '1' when (Instruction(25 downto 21)=B"11011") AND (RegDst="11") else '0'; -- 1 when rs=$k1 & JR instr.
	write_register_address_31	<= B"11111"; --31
	write_register_address_k0	<= B"11010";
	
	with ALUop select
	zero_or_sign_extend <= (not ALUSrcB) when "0011"|"0100"|"0010",
							'1' when others;
	
					-- Read Register 1 Operation
	read_data_1_port <= register_array( CONV_INTEGER(read_register_1_address) );
					-- Read Register 2 Operation		 
	read_data_2_port <= register_array( CONV_INTEGER(read_register_2_address) );
					-- Mux for Register Write Address
	write_register_address <= write_register_address_k0 when (int_service1='1') -- GIE=0 when servicing interrupts
							else B"11011" when (int_service2='1') -- to emulate JAL for interrupt (save to $k1=27)
							else write_register_address_1 when RegDst = "01"
							else write_register_address_0 when RegDst = "00"
							else write_register_address_k0 when RegDst = "11" -- for JR - setup for reti
							else write_register_address_31;
							
					-- Mux to service reti properly
	write_data <= (0 => '1', others => '0') when (RegDst = "11") else write_RF_data; -- when reti - set GIE=1
	
					-- Sign Extend 16-bits to 32-bits
    Sign_extend_within <= X"0000" & Instruction_immediate_value 
			WHEN ((Instruction_immediate_value(15) = '0') or (zero_or_sign_extend='0'))
			ELSE X"FFFF" & Instruction_immediate_value;
					-- Mux for outputs towards Execute unit & Jump mechanics
	read_data_1 	<= read_data_1_port when ALUSrcA='0' else read_data_2_port;
	read_data_2 	<= read_data_2_port when ALUSrcB='0' else Sign_extend_within;
	Sign_extend 	<= Sign_extend_within; -- because of internal use of sign_extend
	Dmem_write_data <= read_data_2_port;
	Write_to_RF		<= (RegWrite OR int_service2 OR detect_reti OR int_service1);
PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR(i, 32);
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF (Write_to_RF='1' AND (write_register_address /= 0)) THEN -- added support for interrupts and reti
		      register_array( CONV_INTEGER(write_register_address)) <= write_data;
		END IF;
	END PROCESS;
	
	GIE_reg	<= (register_array(26)); -- read bit 0 of $k0 only (GIE bit)
	GIE_out <= GIE_reg(0);
END behavior;


