----------------------------------------
-- Top level module of the CPU core (MIPS based single-cycle CPU)
-- connects the different modules: Fetch, Decode, Execute, Dmemory & Control.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.all;

ENTITY MIPS IS
	Generic (Sim : boolean := false;
			width_ITCM_bol : integer := 10; -- 8 on ModelSim / 10 on Quartus
			width_DTCM_bol : integer := 12); -- 10 on ModelSim / 12 on Quartus
	PORT( 
		reset_to_Control, clock	: IN STD_LOGIC; -- reset line from Interrupt Controller - "Raw" reset
		DataBus					: INOUT STD_LOGIC_VECTOR(31 downto 0); -- Data bus used to connect with all external modules
		addressBus				: OUT STD_LOGIC_VECTOR(11 downto 0); -- Address Bus. all external modules listen to this
		MemWrite_out			: OUT STD_LOGIC; -- Memory Write external control line (to all external modules)
		MemRead_out				: OUT STD_LOGIC; -- Memory read external control line (to all external modules)
		GIE						: OUT STD_LOGIC; -- General Interrupt Enable bit (from RF to Interrupt Controller)
		intr_TYPE_reg			: IN STD_LOGIC_VECTOR(7 downto 0); -- TYPE register from InterruptControlelr (usage detailed there)
		int_req					: IN STD_LOGIC; -- interrupt request from Interrupt Controller
		global_reset_to_external: OUT STD_LOGIC; -- Main, synchoronous reset signal
		int_ack_out				: OUT STD_LOGIC ); -- Interrupt acknowledge - sent to Interrupt Controller during the final servicing cycle
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
					
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Add_result 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUSrcB 			: STD_LOGIC;
	SIGNAL ALUSrcA			: STD_LOGIC;
	SIGNAL Jump				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL RegData			: STD_LOGIC;
	SIGNAL BranchALU		: STD_LOGIC;
	SIGNAL FuncCode			: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL Branch 			: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(3 DOWNTO 0); 
	SIGNAL Instruction		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL intr_PC_plus4	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL global_reset		: STD_LOGIC;
	SIGNAL write_data_in	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_from_memory : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL int_service1		: STD_LOGIC;
	SIGNAL int_service2		: STD_LOGIC;
	SIGNAL MemWrite_int_mux : STD_LOGIC;
	SIGNAL PC_after_intr	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL handler_to_PC	: STD_LOGIC_VECTOR(7 downto 0);

BEGIN
	global_reset_to_external <= global_reset;
	MemRead_out <= MemRead;				
	MemWrite_out <= MemWrite_int_mux;		
	
	-- connect the 5 MIPS components   
  IFE : Ifetch
	GENERIC MAP (Sim, width_ITCM_bol)
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				clock 			=> clock,  
				reset 			=> global_reset, 
				Jump			=> Jump,
				ALUSrcA_Direct	=> read_data_1(9 DOWNTO 2), -- for JR - routing PC bits (w/o 2 LSB 0s)
				int_service1	=> int_service1, -- #control
				intr_next_pc_after => PC_after_intr, -- #fetch
				handler_to_PC 	=> handler_to_PC,
				int_service2	=> int_service2 ); -- #control, int_ack (out through mips too)

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
				ALUop			=> ALUop,
				RegWrite		=> RegWrite,
				RegDst			=> RegDst,
				ALUSrcA			=> ALUSrcA,
				ALUSrcB			=> ALUSrcB,
				Sign_extend		=> Sign_extend,
				clock			=> clock,
				reset			=> global_reset,
				Dmem_write_data => write_data_in, -- #dmemory
				int_service1	=> int_service1, -- #control
				int_service2	=> int_service2, -- #control
				GIE_out			=> GIE, --#InterruptController (through MCU)
				write_RF_data	=> read_data_from_memory ); -- #Dmemory, read_data_out

   CTL: control
	PORT MAP ( 	Opcode_in 		=> Instruction(31 DOWNTO 26),
				RegDst 			=> RegDst, 
				ALUSrcB 		=> ALUSrcB,
				ALUSrcA			=> ALUSrcA,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				ALUop 			=> ALUop, 
				Jump			=> Jump, 
				RegData			=> RegData, 
				BranchALU		=> BranchALU, 
				FuncCode		=> Instruction(5 DOWNTO 0), 
                clock 			=> clock,
				reset_to_Control=> reset_to_Control,
				global_reset	=> global_reset,
				int_service1	=> int_service1, -- #Dmemory, decode (to)
				int_service2	=> int_service2, -- #fetch
				int_req			=> int_req, -- #intruuptController (coming from)
				int_ack_out		=> int_ack_out); -- to interrupt controller, fetch & decode

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
				Branch_Dec_Bit	=> Instruction(26), 
				ALUOp 			=> ALUop, 
				BranchALU		=> BranchALU, 
				Zero			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> global_reset );

   MEM:  dmemory
    GENERIC MAP (Sim, width_DTCM_bol)
	PORT MAP (	read_data_out	=> read_data_from_memory, -- data read from memory unit (real or fake), after mux
				address_in		=> ALU_result(11 downto 0),
				write_data_in	=> write_data_in, -- #Decode
				MemRead			=> MemRead, -- #control
				MemWrite		=> MemWrite, -- #control
				MemWrite_int_mux => MemWrite_int_mux, -- #all external modules
				intr_TYPE_reg	=> intr_TYPE_reg, -- #interruptController
				int_service1	=> int_service1, -- #control
				addressBus		=> addressBus, -- #all external modules listen to this
				PC_plus_4		=> PC_plus_4, -- #fetch
				ALU_result		=> ALU_result, -- #execute
				MemtoReg		=> MemtoReg, -- #control
				RegData			=> RegData, -- #control
				DataBus			=> DataBus, -- #MCU - implemented there
				int_service2	=> int_service2, -- #control
				PC_after_intr	=> PC_after_intr,
				handler_to_PC	=> handler_to_PC,
                clock 			=> clock,  
				reset 			=> global_reset );
END structure;

