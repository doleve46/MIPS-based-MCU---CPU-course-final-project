LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

package aux_package is
--------------------------------------------------------
COMPONENT  GPIO IS
	GENERIC(AddrBusSize : INTEGER := 12;
			DataBusSize : INTEGER := 32
			);
	PORT(	Address		 				: IN 	STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0); -- Address signal
			DataBus						: INOUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
			MemRead,MemWrite			: IN	STD_LOGIC;
			HEX0,HEX1,HEX2				: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX3,HEX4,HEX5				: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
			LEDR						: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			SW							: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			rst,mclk					: IN	STD_LOGIC
			);
END COMPONENT;
---------------------------------------------------------   
COMPONENT  GPIO_Decoder IS
	PORT(	Address		 		: IN 	STD_LOGIC_VECTOR(11 DOWNTO 0);
			CS					: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
END COMPONENT;
---------------------------------------------------------  
COMPONENT  Switches_GPI IS
	PORT(	CS			 	: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			Data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GPin			: IN    STD_LOGIC_VECTOR( 7 DOWNTO 0 )
			);
END COMPONENT;
---------------------------------------------------------	
COMPONENT  LedR_GPO IS
	PORT(	CS			 	: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			MemWrite	    : IN 	STD_LOGIC;
			Data 			: INOUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GPout 			: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			rst,clk				: IN STD_LOGIC
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT  HEX_GPO IS
	PORT(	CS			: IN 	STD_LOGIC;
			MemRead		 	: IN 	STD_LOGIC;
			MemWrite	    : IN 	STD_LOGIC;
			Data 			: INOUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 )
			GPout	: OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			rst,clk				: IN	STD_LOGIC
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT SevenSegDecode IS
	PORT (char		: in STD_LOGIC_VECTOR (3 DOWNTO 0);
		segments   		: out STD_LOGIC_VECTOR (6 downto 0));
END COMPONENT;
---------------------------------------------------------
COMPONENT  DivideModule IS
	GENERIC (N : INTEGER := 32);
	PORT(	mclk,rst,divclk		: IN STD_LOGIC;
			DIVIFG				: OUT STD_LOGIC;
			Address 			: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			MemWrite,MemRead 	: IN STD_LOGIC;
			DataBus				: INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT  Divide IS
	GENERIC (N : INTEGER := 32;
			 K : INTEGER := 5 );-- log2(N)
	PORT(	clk, sysrst, divrst, ena	: IN STD_LOGIC;
			done			: OUT STD_LOGIC;
			Dividend, Divisor : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Residue, Quotient : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT Timer IS
  GENERIC (N : INTEGER := 32
		  );   
	PORT (
		mclk,rst			: IN STD_LOGIC;
		Address 			: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		MemWrite,MemRead 	: IN STD_LOGIC;
		DataBus				: INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		PWMout,Set_BTIFG	: OUT STD_LOGIC
		);
	END COMPONENT;
---------------------------------------------------------
COMPONENT Idecode IS
	PORT(	read_data_1		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			read_data_2		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			Instruction		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUop			: IN	STD_LOGIC_VECTOR(3 downto 0);
			RegWrite 		: IN 	STD_LOGIC;
			RegDst 			: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrcA			: IN	STD_LOGIC;
			ALUSrcB			: IN	STD_LOGIC;
			Sign_extend 	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			clock,reset		: IN 	STD_LOGIC;
			Dmem_write_data	: OUT	STD_LOGIC_VECTOR(31 downto 0); -- 2nd RF output port - routed directly to Dmemory
			GIE_out			: OUT	STD_LOGIC; -- GIE bit from RF (r26)
			int_service1	: IN	STD_LOGIC;
			int_service2	: IN	STD_LOGIC;
			write_RF_data	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0) -- (from dmemory)
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT Ifetch IS
	Generic (Sim : boolean := false;
			 width_ITCM_bol : integer := 10);
	PORT(	Instruction 	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
        	PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
        	Add_result 		: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- result of Branch ALU
        	Branch 			: IN 	STD_LOGIC;
        	Zero			: IN 	STD_LOGIC;
        	clock, reset 	: IN 	STD_LOGIC;
			Jump			: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrcA_Direct	: IN	STD_LOGIC_VECTOR(7 downto 0);
			int_service1	: IN	STD_LOGIC;
			int_service2	: IN	STD_LOGIC;
			intr_next_pc_after : OUT STD_LOGIC_VECTOR(7 downto 0); -- to Dmemory module
			handler_to_PC		: IN 	STD_LOGIC_VECTOR(7 downto 0) -- intrerrupt handler address from Dmemory
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT control IS
   PORT( 	
		Opcode_in		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0); 
		RegDst 			: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0); 
		ALUSrcB			: OUT 	STD_LOGIC; 
		ALUSrcA			: OUT 	STD_LOGIC; 
		MemtoReg 		: OUT 	STD_LOGIC;
		RegWrite 		: OUT 	STD_LOGIC;
		MemRead 		: OUT 	STD_LOGIC;
		MemWrite 		: OUT 	STD_LOGIC;
		Branch 			: OUT 	STD_LOGIC;
		ALUop 			: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0); 
		Jump			: OUT   STD_LOGIC_VECTOR(1 DOWNTO 0); 
		RegData			: OUT   STD_LOGIC; 
		BranchALU		: OUT	STD_LOGIC; 
		FuncCode		: IN	STD_LOGIC_VECTOR(5 DOWNTO 0); -- 6 LSB bits (from fetch)
		clock			: IN 	STD_LOGIC;
		reset_to_Control: IN 	STD_LOGIC;
		global_reset	: OUT	STD_LOGIC; -- main RESET signal - forwarded to the rest of the MCU
		int_service1	: OUT	STD_LOGIC; -- Control signal used to service interrupts
		int_service2	: OUT	STD_LOGIC; -- Control signal used to service interrupts
		int_req			: IN	STD_LOGIC; -- interrupt request - (from Interrupt Controller module)
		int_ack_out		: OUT	STD_LOGIC -- interrupt acknowledge (to interrupt controller)
		);
END COMPONENT;
---------------------------------------------------------
COMPONENT dmemory IS
	Generic (Sim : boolean := false;
			 width_DTCM_bol : integer := 12);
	PORT(	read_data_out		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0); 
        	address_in 			: IN 	STD_LOGIC_VECTOR(11 DOWNTO 0); 
        	write_data_in		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- 2nd RF output port
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			intr_TYPE_reg		: IN	STD_LOGIC_VECTOR(7 downto 0); -- content of TYPE register (Mux'd with address_in)
			addressBus			: OUT	STD_LOGIC_VECTOR(11 downto 0); -- Address bus - all external modules listen to this 
			PC_plus_4			: IN	STD_LOGIC_VECTOR(9 downto 0); 
			ALU_result			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); 
			MemtoReg			: IN 	STD_LOGIC; 
			RegData				: IN	STD_LOGIC; 
			DataBus				: INOUT STD_LOGIC_VECTOR(31 downto 0); 
			PC_after_intr		: IN	STD_LOGIC_VECTOR(7 downto 0); -- from fetch - PC to return to when finished with interrupt
			int_service1		: IN	STD_LOGIC; 
			int_service2		: IN	STD_LOGIC; 
			MemWrite_int_mux	: OUT 	STD_LOGIC; -- goes to all external modules
			handler_to_PC		: OUT	STD_LOGIC_VECTOR(7 downto 0); -- handler address to PC - when interrupt-servicing
            clock,reset			: IN 	STD_LOGIC );
END COMPONENT;
---------------------------------------------------------
COMPONENT  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			Read_data_2 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			Sign_extend 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- routed to the branch ALU
			Branch_Dec_Bit	: IN 	STD_LOGIC; -- Instruction(26) - used to distinguish between BEQ and BNE
			ALUop 			: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0); -- to determine operation of main ALU unit
			BranchALU		: IN	STD_LOGIC; -- to determine operation on Branch ALU
			Zero			: OUT	STD_LOGIC; -- output flag meant for branch-checking 
			ALU_Result 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of Main ALU Unit
			Add_Result 		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0); -- output of Branch ALU Unit
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
			clock, reset	: IN 	STD_LOGIC
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT MIPS IS
	Generic (Sim : boolean := false;
			width_ITCM_bol : integer := 10; -- 8 on ModelSim / 10 on Quartus
			width_DTCM_bol : integer := 12); -- 10 on ModelSim / 12 on Quartus
	PORT( 	reset_to_Control, clock	: IN STD_LOGIC; 
			DataBus					: INOUT STD_LOGIC_VECTOR(31 downto 0);
			addressBus				: OUT STD_LOGIC_VECTOR(11 downto 0);
			MemWrite_out			: OUT STD_LOGIC;
			MemRead_out				: OUT STD_LOGIC;
			GIE						: OUT STD_LOGIC;
			intr_TYPE_reg			: IN STD_LOGIC_VECTOR(7 downto 0);		
			int_req					: IN STD_LOGIC;
			global_reset_to_external: OUT STD_LOGIC;
			int_ack_out				: OUT STD_LOGIC
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT interruptLogic is 
	PORT(	clk				: IN 	STD_LOGIC; -- interrupt source - used as clock
			clearInterrupt	: IN	STD_LOGIC; -- clear interrupt 
			interruptEnable	: IN	STD_LOGIC; -- from IE register
			IntrFlag_out	: OUT	STD_LOGIC -- towards IFG register
			);

end COMPONENT;
---------------------------------------------------------
COMPONENT InterruptController IS
	PORT(	TYPE_out			: OUT STD_LOGIC_VECTOR(7 downto 0); -- to Dmemory (MCU) 
			GIE					: IN STD_LOGIC;	-- global interrupt enable ($k0[0]) (Decode, MCU)
			int_req_out			: OUT STD_LOGIC; -- Interrupt request sent to the CPU (Control, MIPS)
			int_ack				: IN STD_LOGIC; -- interrupt ack from the CPU (on 1, goes down the following cycle to intr being accepted)
			clk,reset_in		: IN STD_LOGIC; -- global clock and KEY0 (reset)
			interrupt_sources	: IN STD_LOGIC_VECTOR(6 downto 0); -- raw interrupt sources - to be directed to the Interrupt Logic sub-modules
			addressBus_relevant	: IN STD_LOGIC_VECTOR(11 downto 0); -- Address bus signal
			DataBus				: INOUT STD_LOGIC_VECTOR(31 downto 0); -- Data Bus between external modules & CPU core - r`eceiving or sending data
			MemWrite, MemRead	: IN STD_LOGIC; -- from CPU's Control, to determine what should be done
			reset_to_Control	: OUT STD_LOGIC; -- "Raw" reset signal sent outwards to CPU Control
			global_reset		: IN STD_LOGIC -- reset from CPU's Control - main reset signal.
			);

END 	COMPONENT;
---------------------------------------------------------

end package aux_package;

