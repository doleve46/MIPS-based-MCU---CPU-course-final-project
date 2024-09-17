HEX.vhd - implementation of the encoding for the HEX panels on the FPGA boards, outputs to the board.
mclkPLL.vho - part of the PLL used to power the MCLK (used for quartus).
mclkPLL.vhd - HDL used to define the MCLK for the system.
MCU.vhd - top level module that wraps the whole design of the MCU.
MIPS.vhd - top level module for the MIPS Core, wraps the whole CPU design and interacts with the rest of the MCU.
SevenSegment.vhd - used as part of the HEX implementation (output to HEX screens).
Timer.vhd - HDL file that defines the Timer module in the MCU.
Switches.vhd - used to read the input from the Switches on the board of the FPGA.
InterruptController.vhd - Interrupt Controller module, contains the InterruptLogic module within
InterruptLogic.vhd - D-FF based inputs from each interrupt source, implemented within the Interrupt Controller.
LEDR.vhd - used to output to LEDs on the FPGA board.
GPIOAddrDecoder.vhd - used to decode the relevant addresses for the GPIO units from the Address Bus and pass values onto/from the Data Bus.
IFETCH.vhd - used to implement the ITCM and instruction fetching & PC within the MIPS Core CPU.
IDECODE.vhd - used to implement the RF within the CPU and decipher the required instruction.
DMEMORY.vhd - used to implement the DTCM and interaction with the external modules within the MCU - provides the Address Bus and connects to the Data Bus.
EXECUTE.vhd - used to implement the ALUs for the main operations in the CPU & small Branch ALU as shown in CPU diagram.
CONTROL.vhd - used to implement the main control unit of the MIPS CPU. Provides ctrl. lines to the whole MCU as well.
GPIO.vhd - wrapper module for the GPIO sub-modules.
DividerModule.vhd - divider sub-module that performs the required division operations.
Divider.vhd - wrapper module for the Divider.
aux_package.vhd - component definitions of the whole system.