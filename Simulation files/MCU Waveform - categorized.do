onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -itemcolor Gold /mcu_tb/U_0/mclk
add wave -noupdate -itemcolor Orchid /mcu_tb/U_0/divclk
add wave -noupdate -itemcolor Green /mcu_tb/U_0/CPUMap/CTL/global_reset
add wave -noupdate -group {Simulated Signals} -label {KEY0 - RESET} /mcu_tb/U_0/KEY0
add wave -noupdate -group {Simulated Signals} /mcu_tb/U_0/KEY1
add wave -noupdate -group {Simulated Signals} /mcu_tb/U_0/KEY2
add wave -noupdate -group {Simulated Signals} /mcu_tb/U_0/KEY3
add wave -noupdate -group {Simulated Signals} /mcu_tb/U_0/Switches
add wave -noupdate -group {Simulated Signals} -divider Outputs
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/LEDR
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX0
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX1
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX2
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX3
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX4
add wave -noupdate -group {Simulated Signals} -radix binary /mcu_tb/U_0/HEX5
add wave -noupdate -group {MCU - top} -radix hexadecimal /mcu_tb/U_0/DataBus
add wave -noupdate -group {MCU - top} -radix hexadecimal /mcu_tb/U_0/AddressBus
add wave -noupdate -group {Fetch Signals} -radix unsigned /mcu_tb/U_0/CPUMap/IFE/PC
add wave -noupdate -group {Fetch Signals} -label {Mem_Addr - ITCM} /mcu_tb/U_0/CPUMap/IFE/Mem_Addr
add wave -noupdate -group {Decode Signals} /mcu_tb/U_0/CPUMap/ID/register_array
add wave -noupdate -group {Decode Signals} /mcu_tb/U_0/CPUMap/ID/GIE_out
add wave -noupdate -group {Decode Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/ID/Instruction
add wave -noupdate -group {Decode Signals} /mcu_tb/U_0/CPUMap/ID/detect_reti
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix unsigned /mcu_tb/U_0/CPUMap/ID/read_register_1_address
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix hexadecimal /mcu_tb/U_0/CPUMap/ID/read_data_1_port
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix unsigned /mcu_tb/U_0/CPUMap/ID/read_register_2_address
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix hexadecimal /mcu_tb/U_0/CPUMap/ID/read_data_2_port
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix unsigned /mcu_tb/U_0/CPUMap/ID/write_register_address
add wave -noupdate -group {Decode Signals} -group {Ports entrances} -radix hexadecimal /mcu_tb/U_0/CPUMap/ID/write_data
add wave -noupdate -group {Execute Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/EXE/Ainput
add wave -noupdate -group {Execute Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/EXE/Binput
add wave -noupdate -group {Execute Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/EXE/ALU_Result
add wave -noupdate -group {Execute Signals} -divider {Zero Flag & BNE/BEQ Distinguisher}
add wave -noupdate -group {Execute Signals} /mcu_tb/U_0/CPUMap/EXE/Zero
add wave -noupdate -group {Execute Signals} /mcu_tb/U_0/CPUMap/EXE/Branch_Dec_Bit
add wave -noupdate -group {Execute Signals} -divider {Branch's ALU Signals}
add wave -noupdate -group {Execute Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/EXE/Sign_extend
add wave -noupdate -group {Execute Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/EXE/Add_Result
add wave -noupdate -group {DTCM Signals} -label {address in - FROM EXECUTE} -radix hexadecimal /mcu_tb/U_0/CPUMap/MEM/address_in
add wave -noupdate -group {DTCM Signals} -label {address - TO DTCM} -radix hexadecimal /mcu_tb/U_0/CPUMap/MEM/address
add wave -noupdate -group {DTCM Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/MEM/addressBus
add wave -noupdate -group {DTCM Signals} -radix hexadecimal /mcu_tb/U_0/CPUMap/MEM/DataBus
add wave -noupdate -group {DTCM Signals} -label {MemWrite - TO EXTERNAL MODULES} /mcu_tb/U_0/CPUMap/MEM/MemWrite_int_mux
add wave -noupdate -group {DTCM Signals} -label {MemWrite - TO REAL DTCM} /mcu_tb/U_0/CPUMap/MEM/MemWrite_memUnit
add wave -noupdate -expand -group {Control Unit Signals} -divider {Instruction Decoding - Inner Signals}
add wave -noupdate -expand -group {Control Unit Signals} -radix binary -childformat {{/mcu_tb/U_0/CPUMap/CTL/Opcode_in(5) -radix binary} {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(4) -radix binary} {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(3) -radix binary} {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(2) -radix binary} {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(1) -radix binary} {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(0) -radix binary}} -subitemconfig {/mcu_tb/U_0/CPUMap/CTL/Opcode_in(5) {-height 15 -radix binary} /mcu_tb/U_0/CPUMap/CTL/Opcode_in(4) {-height 15 -radix binary} /mcu_tb/U_0/CPUMap/CTL/Opcode_in(3) {-height 15 -radix binary} /mcu_tb/U_0/CPUMap/CTL/Opcode_in(2) {-height 15 -radix binary} /mcu_tb/U_0/CPUMap/CTL/Opcode_in(1) {-height 15 -radix binary} /mcu_tb/U_0/CPUMap/CTL/Opcode_in(0) {-height 15 -radix binary}} /mcu_tb/U_0/CPUMap/CTL/Opcode_in
add wave -noupdate -expand -group {Control Unit Signals} -color Gold -label {Current Operation} /mcu_tb/U_0/CPUMap/CTL/Current_operation
add wave -noupdate -expand -group {Control Unit Signals} -color Gold -label {Cur R-Type op (when Cur op. is R Type!)} /mcu_tb/U_0/CPUMap/CTL/Current_R_Type_op
add wave -noupdate -expand -group {Control Unit Signals} -radix binary /mcu_tb/U_0/CPUMap/CTL/FuncCode
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/RegDst
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/ALUSrcB
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/ALUSrcA
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/MemtoReg
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/RegWrite
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/MemRead
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/MemWrite
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/Branch
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/ALUop
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} -radix binary /mcu_tb/U_0/CPUMap/CTL/Jump
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/RegData
add wave -noupdate -expand -group {Control Unit Signals} -group {Normal controls} /mcu_tb/U_0/CPUMap/CTL/BranchALU
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/global_reset
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/reset_to_Control
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/int_service1
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/int_service2
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/int_req
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} /mcu_tb/U_0/CPUMap/CTL/int_ack_out
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} -radix unsigned /mcu_tb/U_0/CPUMap/CTL/int_cur_state
add wave -noupdate -expand -group {Control Unit Signals} -group {Interrupt controls} -radix unsigned /mcu_tb/U_0/CPUMap/CTL/int_next_state
add wave -noupdate -group {Divider module} /mcu_tb/U_0/DividerMap/DIVIFG
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/quotient_reg
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/divisor_reg
add wave -noupdate -group {Divider module} /mcu_tb/U_0/DividerMap/MultiCycleDivider/rst
add wave -noupdate -group {Divider module} /mcu_tb/U_0/DividerMap/MultiCycleDivider/ena
add wave -noupdate -group {Divider module} -divider IN
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/Dividend
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/Divisor
add wave -noupdate -group {Divider module} -divider OUT
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/Residue
add wave -noupdate -group {Divider module} -radix hexadecimal /mcu_tb/U_0/DividerMap/MultiCycleDivider/Quotient
add wave -noupdate -group {Timer module} /mcu_tb/U_0/TimerMap/PWMout
add wave -noupdate -group {Timer module} /mcu_tb/U_0/TimerMap/Set_BTIFG
add wave -noupdate -group {Timer module} -label {clk (chosen by mux)} /mcu_tb/U_0/TimerMap/clk
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCNT
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCTL
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCL1
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCL0
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCCR1
add wave -noupdate -group {Timer module} -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCCR0
add wave -noupdate -group {Interrupt Controller} -group {InterruptController Registers} -radix binary /mcu_tb/U_0/IntContMap/IE
add wave -noupdate -group {Interrupt Controller} -group {InterruptController Registers} -radix binary /mcu_tb/U_0/IntContMap/IFG
add wave -noupdate -group {Interrupt Controller} -group {InterruptController Registers} -label TYPE -radix binary /mcu_tb/U_0/IntContMap/TYPE_within
add wave -noupdate -group {Interrupt Controller} -group {Interrupt signals to/from CPU} /mcu_tb/U_0/IntContMap/reset_to_Control
add wave -noupdate -group {Interrupt Controller} -group {Interrupt signals to/from CPU} -label {int_req - interrupt request} /mcu_tb/U_0/IntContMap/int_req_out
add wave -noupdate -group {Interrupt Controller} -group {Interrupt signals to/from CPU} -label {int_ack - interrupt acknowledge} /mcu_tb/U_0/IntContMap/int_ack
add wave -noupdate -group {Interrupt Controller} -group {Data from CPU} -label AddressBus -radix hexadecimal /mcu_tb/U_0/IntContMap/addressBus_relevant
add wave -noupdate -group {Interrupt Controller} -group {Data from CPU} /mcu_tb/U_0/IntContMap/MemRead
add wave -noupdate -group {Interrupt Controller} -group {Data from CPU} -radix hexadecimal /mcu_tb/U_0/IntContMap/DataBus
add wave -noupdate -group {Interrupt Controller} -group {Data from CPU} /mcu_tb/U_0/IntContMap/MemWrite
add wave -noupdate -group {Interrupt Controller} -group {Data from CPU} /mcu_tb/U_0/IntContMap/GIE
add wave -noupdate -group {Interrupt Controller} -group {Interrupt logic units} -radix binary /mcu_tb/U_0/IntContMap/interrupt_sources
add wave -noupdate -group {Interrupt Controller} -group {Interrupt logic units} -radix binary /mcu_tb/U_0/IntContMap/clr_intr
add wave -noupdate -group {Interrupt Controller} -group {Interrupt logic units} -label {IFG source - logic units} /mcu_tb/U_0/IntContMap/IFG_real_source
add wave -noupdate -group {Interrupt Controller} -group {Reset interrupt logic unit} -label {reset_in (KEY0)} /mcu_tb/U_0/IntContMap/reset_in
add wave -noupdate -group {Interrupt Controller} -group {Reset interrupt logic unit} /mcu_tb/U_0/IntContMap/clr_reset
add wave -noupdate -itemcolor Gold /mcu_tb/U_0/mclk
add wave -noupdate -itemcolor Orchid /mcu_tb/U_0/divclk
add wave -noupdate -itemcolor Green /mcu_tb/U_0/CPUMap/CTL/global_reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6325637 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
configure wave -valuecolwidth 116
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {5978956 ps} {7053740 ps}
