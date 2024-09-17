----------------------------------------
-- Dmemory module, part of the MIPS based single-cycle CPU core.
-- Handles all memory access to&from the CPU core, to external
-- modules as well (via DataBus & AddressBus).
-- receives signals from Execute module (main & branch ALUs), Fetch & 
-- Decode (Register File), combined with control lines from the Control module.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	Generic (Sim : boolean := false;
			 width_DTCM_bol : integer := 10); -- Modelsim=10 / Quartus=10&"00"
	PORT(	read_data_out		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- data routed to RF input (within Decode module)
        	address_in 			: IN 	STD_LOGIC_VECTOR(11 DOWNTO 0); -- main ALU output - within Execute module (12 LSBs)
        	write_data_in		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- 2nd output port of Register File
	   		MemRead, Memwrite 	: IN 	STD_LOGIC; -- control lines handling Reading & Writing to memory (incl. external modules)
			intr_TYPE_reg		: IN	STD_LOGIC_VECTOR(7 downto 0); -- content of TYPE reg (to Dmemory)
			addressBus			: OUT	STD_LOGIC_VECTOR(11 downto 0); -- External modules listen to this line for their operation
			PC_plus_4			: IN	STD_LOGIC_VECTOR(9 downto 0); -- from Fetch module
			ALU_result			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- entire main ALU output (32 bits)
			MemtoReg			: IN 	STD_LOGIC; -- control line - detailed within Control.vhd
			RegData				: IN	STD_LOGIC; -- control line - same as above
			DataBus				: INOUT STD_LOGIC_VECTOR(31 downto 0); -- Data Bus used to connect all external modules with the CPU core
			PC_after_intr		: IN	STD_LOGIC_VECTOR(7 downto 0); -- from fetch - PC to return to when finished with interrupt
			int_service1		: IN	STD_LOGIC; -- 1st cycle of interrupt servicing control line
			int_service2		: IN	STD_LOGIC; -- 2nd cycle of interrupt servicing control line
			MemWrite_int_mux	: OUT 	STD_LOGIC; -- output towards external modules - the MemWrite they receive
			handler_to_PC		: OUT	STD_LOGIC_VECTOR(7 downto 0); -- handler address to PC - when interrupt servicing
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
	SIGNAL write_clock 			: STD_LOGIC;
	SIGNAL read_data			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL address				: STD_LOGIC_VECTOR(width_DTCM_bol-1 downto 0); -- 7 on ModelSim / 11 on Quartus
	SIGNAL write_data			: STD_LOGIC_VECTOR(31 downto 0); -- this is input the real Data Memory
	SIGNAL data_to_RF_mux		: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL PC_Plus_8			: STD_LOGIC_VECTOR(9 downto 0); 
	SIGNAL MemWrite_memUnit		: STD_LOGIC; -- don't write into real memory when sw to external modules

BEGIN
	addressBus <= address_in(11 downto 0); -- for external modules to listen to the address bus
	------ **Sim/Synth behaviour** ------
	SimOrSynth: if Sim generate
		address <= "0000"&intr_TYPE_reg(7 downto 2) when (int_service2='1') else address_in(11 downto 2);
	else generate
		address <= "00"&intr_TYPE_reg when (int_service2='1') else address_in(9 downto 2)&"00"; -- changed address space to 10 bits in ram
	end generate;
	---------------------------------
	-- Data Bus & enveloping hardware
	PC_Plus_8 <= PC_plus_4 + 4; -- for JAL implementation
	
	-- Output Mux (toward's RF write_data input)
	handler_to_PC <= read_data(9 downto 2); -- send handler address to PC when interrupt servicing
	
	data_to_RF_mux <= RegData&MemtoReg&address_in(11);
	

	read_data_out <= (others => '0') when int_service1='1' 								-- interrupt service phase 1/2 ($k0 (R26,GIE register) <= X"00000000")
					else (X"00000"&B"00"&PC_after_intr&"00") when (int_service2='1') 	-- interrupt service phase 2/2 - ($k1,(R27)<= PC to return to after interrupt)
					else ALU_result(31 downto 0) when data_to_RF_mux(2 downto 1)="00" 	-- bypass memory, routing ALU_result back to RF
					else read_data when (data_to_RF_mux="010") 							-- route from real Data Memory unit
					else DataBus when (address_in(11)='1') 								-- route external modules result back to RF
					else (X"00000"&B"00"&PC_Plus_8(9 downto 0)) when RegData='1' 		-- 22 zeros concatenated to PC+8 (10 bit)
					else (others => 'Z');

	MemWrite_int_mux <= MemWrite when (int_service1='0' and int_service2='0') else '0'; -- disable writing to ALL memory when interrupt servicing
	
	-- Seperate between real DMEM and external modules' addresses
	-- * if addressing the real Data Memory - high Z on Databus, route data_in & MemWrite to Dmemory
	-- * if addressing external modules' addresses - route data_in to Databus, disable- 
	-- * -writing to Dmemory & 0's as input data (power consumption regard)
	write_data_encoder: Process(address_in(11), write_data_in, MemWrite_int_mux, MemRead)
		Begin
			Case (address_in(11)) IS
				when '1' =>
					if MemWrite_int_mux='1' then
						MemWrite_memUnit <= '0'; -- accessing external modules - dont write into Dmemory
						write_data <= (others => '0');
						DataBus <= write_data_in; -- writing - load to Databus
					elsif MemRead='1' then -- if trying to read - dont load the Databus
						MemWrite_memUnit <= '0';
						write_data <= (others => '0');
						DataBus <= (others => 'Z');
					else
						MemWrite_memUnit <= '0';
						write_data <= (others => '0');
						DataBus <= (others => 'Z');
					end if;
				when others =>
					MemWrite_memUnit <= MemWrite_int_mux; -- accessing (real) Dmemory - route real control lines
					write_data <= write_data_in;
					DataBus <= (others => 'Z');
			End case;
		End Process;
	---------------------------------

	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => width_DTCM_bol,
		numwords_a => 1024,
		lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = DTCM",
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\ronny\OneDrive\Documents\VHDL Lab\Final Proj\SW QA - ASM codes\Interrupt based IO\test1\DTCM.hex", -- loaded in Quartus using ISMCE
		intended_device_family => "Cyclone V"
	)
	PORT MAP (
		wren_a => MemWrite_memUnit,
		clock0 => write_clock,
		address_a => address,
		data_a => write_data,
		q_a => read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
		
	
				
	
	
END behavior;

