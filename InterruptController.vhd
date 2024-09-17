----------------------------------------
-- Interrupt Controller external module.
-- holding current interrupt flags (via IFG register) & enabled interrupts (via IE reg)
-- based on IFG and IE contents, manages TYPE register content based on a Priority Queue basis.
-- this TYPE register holds the address within the Dmemory where the associated interrupt handler is at

-- When an interrupt source requests an interrupt (and is enabled to interrupt by the user), sends a request
-- to the Control module of the CPU core, while updating the TYPE register to the highest-priority pending Interrupt
-- upon receieving acknowledge for an interrupt, resets the associated interrupt flag and updates the TYPE register.
-- *implementation of the interrupt service routine is within the CPU Core

-- The reset interrupt logic is seperated (as it is unmasked and with the highest priority), sending reset request 
-- at the rising edge of the next cycle after being issues (by pressing KEY0 on the FPGA board)
-- *The requirement as part of this project was to have a synchronous reset*
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY InterruptController IS
	PORT(	TYPE_out			: OUT STD_LOGIC_VECTOR(7 downto 0); -- content of TYPE register - routed to Dmemory (MCU) 
			GIE					: IN STD_LOGIC;	-- global interrupt enable ($k0[0]) (Decode, MCU)
			int_req_out			: OUT STD_LOGIC; -- Interrupt request sent to the CPU (Control, MIPS)
			int_ack				: IN STD_LOGIC; -- interrupt ack from the CPU (on 1, goes down the following cycle to interrupt being accepted)
			clk,reset_in		: IN STD_LOGIC; -- global clock and raw reset input (KEY0 on FPGA board) 
			interrupt_sources	: IN STD_LOGIC_VECTOR(6 downto 0); -- input sources of all different possible interrupts
			addressBus_relevant	: IN STD_LOGIC_VECTOR(11 downto 0); -- listening to Address Bus for register r/w
			DataBus				: INOUT STD_LOGIC_VECTOR(31 downto 0); -- receiving or sending data to the CPU core
			MemWrite, MemRead	: IN STD_LOGIC; -- from CPU's Control, to determine what should be done (together with the AddressBus)
			reset_to_Control	: OUT STD_LOGIC; -- reset signal sent to control (reset interrupt request)
			global_reset		: IN STD_LOGIC -- reset from CPU's Control - synchronous reset
			);

END 	InterruptController;

ARCHITECTURE ControllerArch OF InterruptController IS

	Component interruptLogic is
		PORT(		SIGNAL clk				: IN 	STD_LOGIC; -- interrupt source - used as clk
					SIGNAL clearInterrupt	: IN	STD_LOGIC; -- clear interrupt
					SIGNAL interruptEnable	: IN	STD_LOGIC; -- from IE register
					SIGNAL IntrFlag_out		: OUT	STD_LOGIC -- towards IFG register
					);
	End Component;
	SIGNAL IE_in				: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL IFG_real_source		: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	SIGNAL IE,IFG,TYPE_within	: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	SIGNAL flag_mask			: STD_LOGIC_VECTOR(6 downto 0); -- for TYPE 
	SIGNAL Priority_q			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL intr_req 			: STD_LOGIC; -- interrupt request - before routing out
	SIGNAL clr_intr				: STD_LOGIC_VECTOR(6 downto 0); -- interrupt clearing after resolving
	SIGNAL ena_IE				: STD_LOGIC; -- serves as 'enable' bits for IE (FOR WRITING)
	SIGNAL clr_reset			: STD_LOGIC;
	SIGNAL DataOut				: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL IFG_in_masked		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL IFG_in_unmasked		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	SIGNAL IE_in_masked			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL IE_in_unmasked		: STD_LOGIC_VECTOR(6 downto 0);
BEGIN
	TYPE_out <= TYPE_within;
	flag_mask <= (IE(6 downto 0) and IFG(6 downto 0)); -- mask to be used for priority queue (TYPE)

	---- DATA OUT ----
	-- Dump data output onto bus
	DataBus <= DataOut WHEN MemRead='1' ELSE (others => 'Z');
	
	-- Choose which data to output by address
	WITH addressBus_relevant SELECT DataOut <=
			X"000000"&IE WHEN X"83C",
			X"000000"&IFG WHEN X"83D",
			X"000000"&TYPE_within WHEN X"83E",
			(others => 'Z') WHEN OTHERS;

	WriteToRegs: Process (clk, global_reset)
	-- initializes IE,IFG registers w/ logic writing to them
	BEGIN
		if (global_reset='1') then
			IE <= (others => '0');
			IFG <= (others => '0');
		elsif (rising_edge(clk)) then
			IE <= IE_in_masked;
			IFG <= IFG_in_masked; -- overwrite current content (sw)
		end if;
	end process;
	---
	IE_in_masked <= DataBus(7 downto 0) when (addressBus_relevant=X"83C" and MemWrite='1') 
					 else IE;
	IFG_in_masked <= DataBus(7 downto 0) when (addressBus_relevant=X"83D" and MemWrite='1')
					 else IFG_in_unmasked;
	
	---
	WriteToIFG_inner_sources: process (int_ack, TYPE_within, IFG_real_source)
	BEGIN
		if int_ack='1' then -- an interrupt was serviced - manual flag reset
			if TYPE_within=X"10" then -- basic timer was interrupting
				IFG_in_unmasked <= (IFG and "11111011"); -- reset BTIFG
			elsif TYPE_within=X"20" then -- divisor was interrupting
				IFG_in_unmasked <= (IFG and "10111111"); -- reset DIVIFG
			else
				IFG_in_unmasked <= '0'&IFG_real_source; -- normal inner IFG input
			end if;
		else -- no interrupt was serviced
			IFG_in_unmasked <= '0'&IFG_real_source; -- normal inner IFG input
		end if;
	end process;
		
	----------------------------------------------------------------
	---	 priority queue for TYPE register ---
	Priority_queue_type: Process (flag_mask,global_reset)
	BEGIN
		if global_reset='1' then
			priority_q <= X"00";
		elsif flag_mask(0)='1' then
			Priority_q <= X"08";
		elsif flag_mask(1)='1' then
			Priority_q <= X"0C";
		elsif flag_mask(2)='1' then
			Priority_q <= X"10";
		elsif flag_mask(3)='1' then
			Priority_q <= X"14";
		elsif flag_mask(4)='1' then
			Priority_q <= X"18";
		elsif flag_mask(5)='1' then
			Priority_q <= X"1C";
		elsif flag_mask(6)='1' then
			Priority_q <= X"20";
		else
			Priority_q <= X"00";
		end if;
	End process;
	
	TYPE_reg: PROCESS (clk,Priority_q,global_reset)
	BEGIN
		if global_reset = '1' then
			TYPE_within <= (others => '0');
		--elsif intr_req = '1' then -- unsure about this mechanism for updating TYPE register - only after pouring content to data-bus?
		elsif (falling_edge(clk)) then --clk'EVENT and clk='1' (old)
				TYPE_within <= Priority_q;
			--end if;
		end if;
	END PROCESS;
	----------------------------------------------------------------
	--- MAPPING ALL THE DIFFERENT INTERRUPT LOGICS TO THEIR RELEVANT PORTS ---
   map_intr_logic : for i in 0 to 6 generate
		intr_logic: interruptLogic PORT MAP(
				clk 			=> interrupt_sources(i),
				clearInterrupt	=> clr_intr(i),
				interruptEnable => IE_in_masked(i),
				IntrFlag_out 	=> IFG_real_source(i));
				end generate;
		-- 0=UART_RX, 1=UART_TX, 2=Basic Timer, 3=Key1, 4=Key2, 5=Key3, 6=Div
	----------------------------------------------------------------
	--- Interrupt Service Request ---
	intr_req <= (GIE and (not int_ack)) when (flag_mask /="0000000") else '0'; -- if there's a pending interrupt request & GIE=1
	int_req_out <= intr_req;
	----------------------------------------------------------------
	--- Reset Button Logic ---
	rst_intr_envelope: interruptLogic PORT MAP(
				clk	=> reset_in, -- KEY0
				clearInterrupt => clr_reset,
				interruptEnable => '1', -- always enabled
				IntrFlag_out => reset_to_Control); -- stable reset signal (through D-FF)
				
	----------------------------------------------------------------
	
	-- clearing D-FFs for each interrupt upon receiving interrupt ack
	WhosCryingLoudest: Process (int_ack, TYPE_within)
	BEGIN
		if int_ack='1' then
			case TYPE_within IS
				when X"00" =>
					clr_reset <= '1';
					clr_intr <= (others => '1'); -- dont reset any others
				when X"08" =>
					clr_reset <= '0';
					clr_intr <= (0 => '1', others => '0');
				when X"0C" =>
					clr_reset <= '0';
					clr_intr <= (1 => '1', others => '0');
				when X"10" =>
					clr_reset <= '0';
					clr_intr <= (2 => '1', others => '0');
				when X"14" =>
					clr_reset <= '0';
					clr_intr <= (3 => '1', others => '0');
				when X"18" =>
					clr_reset <= '0';
					clr_intr <= (4 => '1', others => '0');
				when X"1C" =>
					clr_reset <= '0';
					clr_intr <= (5 => '1', others => '0');
				when X"20" =>
					clr_reset <= '0';
					clr_intr <= (6 => '1', others => '0');
				when others =>
					clr_reset <= '0';
					clr_intr <= (others => '0');
			end case;
		else -- no interrupt ack
			clr_reset <= '0';
			clr_intr <= (others => '0');
		end if;
	end process;

end ControllerArch;