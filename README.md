# MIPS-based MCU - Final project of a Lab course in CPU & hardware accelerators design.
MIPS based single-cycle Microcontroller unit - including Interrupt Controller &amp; external modules (Divider, Timer, GPIO..)

This is a final project in a CPU course as part of my B.Sc in Electrical & Computer Engineering at Ben Gurion University, at the end of the 3rd year of studies.
Part of an Lab course - Advanced CPU arch. and hardware accelerators - Course # 361.1.4693

This project contains all DUT files (written in VHDL), as well as Synthesis related files & simulation files (Wave diagram, Testbench files etc.).

The project was made to be synthesis for an Altera Cyclone V FPGA board, and runs at MCLK of 28Mhz (with a different clock used for the Divider external module @ 100Mhz).

We were given a bare-bones, basic MIPS-based, single-cycle VHDL design, and were required the following:
1. Add support to a list of 23 instructions defined in a normal MIPS arch. , following the instruction decoding of a MIPS processor (this includes adding and defining the control lines for the proccessor to function properly and effeciently).
2. Impelement GPIO support to the physical keys and screens of the Altera Cyclone V FPGA board, using the keys and switches as inputs, and LEDs and HEX screens as outputs
3. Implement Divider & TImer external modules, each able to create an interrupt flag, with the latter also generating a PWM signal routed to a pin on the FPGA board.
4. Implement a simple Interrupt Controller, that supports up to 8 different interrupt sources (incl. a synchronous reset key), and works on a priority basis as defined in the project requirements. This includes adding an interrupt initial service mechanism under the constraint of max. 3 cycles (in this design - took only 2 cycles).
5. Simulate the design using ModelSim, creating a detailed and easy-to-read Wave diagram, and then using Quartus synthesize the design and run it on the Cyclone V board.

This project took about 1.5 weeks of work at the end of the semester's exams, and was written entirely in VHDL (as this was the language taught in the course).

This is a simplified diagram of the design:
![image](https://github.com/user-attachments/assets/c7975a71-462c-464c-a053-2a09059e2752)
