<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<div align="center">


  <h3 align="center">MIPS based MCU</h3>

  <p align="center">
    Single Cycle MIPS based design with Interrupt Controller, GPIO, divider and timer external modules.
	<br />
	This was a final project in a lab course I took, "Advanced CPU arch. and hardware accelerators"
	- Course # 361.1.4693, at the end of the 3rd year of my B.Sc in Electrical & Computer Engineering
	At Ben Gurion University.
    <br />
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
		<li><a href="#built-with">Project Requirements</a></li>
      </ul>
    </li>
    <li>
      <a href="#diving-in">Diving in</a>
      <ul>
        <li><a href="#cpu-core">CPU Core</a></li>
        <li><a href="#gpio">GPIO</a></li>
		<li><a href="#divider">Divider</a></li>
		<li><a href="#timer">Timer</a></li>
		<li><a href="#interrupt-controller">Interrupt Controller</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>


<!-- ABOUT THE PROJECT -->
## About The Project

This is a project that was given as a final assignment in a course, as detailed above.
<br />
The project was made to be synthesized on top of an Altera Cyclone V FPGA board, and was tested in real time as part of the project's requirements.
The project was done in pairs, and was done by myself (Dolev Eisenberg) and Amir Aboutboul.
<br />
Further information is under <a href="contact">'Contact'</a>.
<br />
The files are catagorized, with VHDL files within 'DUT', TB and Waveform configuration for ModelSim within 'Simulation Files',
and all files relevant for synthesis within 'Quartus'.
<br />


### Built With
The project is written entirely in VHDL (version 2008), using standard IEEE libraries and Numeric_std.
<br />
We used ModelSim and Quartus for simulation and synthesis.
<br />
The project was synthesized for use on an Altera Cyclone V FPGA board, given as part of the course.
<br />
This took about 1.5 weeks of work at the end of the semester's exams, and due to that many things can still be optimized and improved.
<p align="right">(<a href="#readme-top">back to top</a>)</p>



## Project Requirements
As this was a project given as a concluding assignment in a University course, the definition of the project and the material given are detailed below.

<strong>Project Requirements:</strong>
<br /><details>
<ul><li>Add support to a list of 23 instructions, using standard MIPS instruction format. This includes adding and defining the control lines within the CPU to support needed functionality. </li>
<li>Implement GPIO support to the physical keys and displays of the Altera cyclone V FPGA board. Keys and switches to be used as input only, while LEDs and HEX displays as output only. </li>
<li> Implement external Timer and Divider modules, that can be manually configured by the user by using lw/sw instructions to pre-defined memory addresses. 
<ul><li> Implement a PWM signal generator as part of the Timer module, outputting to a pin on the FPGA board. </li>
<li> Both modules can cause an interrupt to the MCU; handler is under user responsibility. </li>
</ul>
<li>Implement an Interrupt Controller, that supports up to 8 different interrupt sources (including a synchronous reset key). </li>
<ul><li> The controller follows a priority queue mechanism. Reset (by keypress) is of highest priority and overrides all other interrupt requests.</li>
<li> Plan an initial service mechanism (save current PC, disable global interrupts, jump to interrupt-associated handler) under time constraint of max. 3 cycles (in this design - took only 2 cycles).</li>
</ul>
<li>Simulate the design using ModelSim, creating a testbench with detailed and easy-to-read Waveform Diagram,
and then using Quartus synthesize the design and run it on the Cyclone V board.</li>
</ul></details>
<br />

<strong>Material Given:</strong>
<br /><details>
We were given a bare-bones template for a single-cycle MIPS CPU core, usually used as a base to create a pipelined version of MIPS (that was excluded off this year's syllabus), hence
it was split into 5 different files - Fetch, Decode, Execute, Dmemory & Control.
<br />
We were also given a basic TB template, to ease the work needed.</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- DIVING IN -->
## Diving In
In this section we'll detail in full the design of each module within the MCU, and provide some future additions and changes that can be made to improve upon the work.

This is a simplified diagram of the entire design:
![Total system diagram](https://github.com/user-attachments/assets/fb7f44e7-5fd5-4be2-90db-180936ebbec9)

### CPU Core
The "heart" of the project was the single-cycle, MIPS-based CPU with Harvard architecture design, that needed to support a total of 23 different instructions, as followed:
<ul><details>
	<li>Arithmatic instructions</li>
		<ul>
			<li>add </li>
			<li>subtract </li>
			<li> add immediate </li>
			<li> multiply (without overflow, 16bit LSBs into 32 bit result)</li>
		</ul>
	<li>Logical instructions </li>
		<ul>
			<li> and </li>
			<li> or </li>
			<li> xor </li>
			<li> and immediate </li>
			<li> or immediate </li>
			<li> xor immediate </li>
			<li> shift left logical </li>
			<li> shift right logical </li>
		</ul>
	<li>Data Transfer instructions</li>
		<ul>
			<li> move (emulated using add unsinged instruction)</li>
			<li> load word </li>
			<li> store word </li>
			<li> load upper immediate </li>
		</ul>
	<li>Conditional Branch instructions </li>
		<ul>
			<li>BEQ (branch-on-equal)</li>
			<li>BNE (branch-on-not-equal)</li>
		</ul>
	<li> Unconditional Jump instructions </li>
		<ul>
			<li>Jump</li>
			<li>Jump register</li>
			<li>Jump and link</li>
		</ul>
</ul>
</details>
As we were given a bare-bones template for the CPU, we started off by planning all neccessary hardware and control lines needed to obtain the needed functionality:

![Updated MIPS Arch](https://github.com/user-attachments/assets/bfe5ebea-6ded-4454-b8bf-c7f32352f87a)

<br />
Followed by assigning a value for the control lines of each instruction.

![Instruction decoding](https://github.com/user-attachments/assets/328072ba-2287-41ad-88df-a8575405fb67)

<br />
To support interrupt servicing, the control unit of the CPU contains a simple FSM to distinguish the different stages of servicing an interrupt.
<br />
Further details regarding interrupt servicing is found under the <a href="interrupt_controller">'Interrupt Controller'</a> section.

<strong>Regarding memory</strong>, the system has a seperate Instruction memory and Data memory (Harvard architecture).
<br />
Data memory addresses up to 0xFFF direct to RAM memory, while specific, pre-defined addresses 'higher' than that are directed to registers of external modules, being 
accessed using load-word and store-word instructions by the user (in order to read data stored there, or configure/load values onto said registers).
<br />

The architecture contains a Register File of 32 registers, each 32 bits long.
<br />
Multiple registers can be read simultaniously (2 within an instruction, as required), and one can be written at every clock cycle.
<br />
Some of the registers have pre-defined usage (as instructed in the project definition by the instructor), such as r0, whose default value is 0 and cannot be changed, and r27, used to store the PC address to return to when interrupt-servicing.
<br />

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### GPIO
As defined by the course's instructor, we were tasked to use the 4 physical keys (numbered 0 to 3) and 8 switches on-board the Cyclone V board as input only, with Key 0 as a synchronous reset key,
and the rest 3 keys causing normal interrupts with handlers defined by the user (as assembly code stored within the instruction memory).
<br />
For output, the 4 Hex displays and LEDs are used.
<br />
<strong>Interating with the GPIO &amp; other external units </strong> are done via load word and store word instruction with pre-defined 'virtual' data memory addresses. 
All external modules actively listen to the signal line holding potential addresses (regarded as Address Bus); once an adress connected to a specific module is spotted, 
and the control bits for either reading or writing are on, the relevant unit loads/stores the information that is on the Data Bus - 32 bit bus that connects all external 
modules with the Data memory within the CPU, as shown in the system diagram at the start of the section.
<br />
To properly display the hexadecimal values onto the Hex display, we decoded the real value into the appropriate values used by the display onboard.
<br />

### Divider
The divider module serves as an external hardware accelerator for the division operation. <br />
Given a Divisor and Dividend, loaded to their respective registers (as described within the <a href="GPIO">'GPIO'</a> section).
<br />
a standard shift-register based division is performed. To speed the process up, a different clock is used for this part of the MCU. Upon synthesis, we used a clock
 x4 times faster than the MCLK. <br />
Upon completion, the divider flags an interrupt to the Interrupt Controller module, and the results (quotient and residue) are stored within designated registers.
<br />

### Timer
A timer module was also required, being used to generate interrupt flags on configurable intervals, by choosing frequency division options and counter overflow settings 
configured within a designated control register. <br />
The timer also contains a PWM unit, able to generate a PWM signal onto a pin on the Cyclone V board, with 2 operation modes; The PWM is determined by 2 configurable values used as low-high or the opposite. <br />
Similar to other external modules, the timer also flags an interrupt upon overflowing the counter as decided by the user.


### Interrupt Controller

The interrupt controller is comprised of logic units, one for each interrupt, designed as shown in the diagram below (as requested by the course insturctor), 
as well as user-configurable registers, IE (interrupt enable register), IFG (interrupt flag register) and Type register, each 8 bits.
<br />

![interrupt logic](https://github.com/user-attachments/assets/5e2791cb-101e-4c7c-9a6e-7978f973b005)

The interrupt controller works as followed - whenever at least 1 interrupt source is on and the corresponding enable bit within the IE register is on '1', an interrupt request is sent to the
CPU's Control unit, while simultaniously the Type register changes its value to a pre-defined value, corresponding to a Data Memory address holding the address for the interrupt handler within the 
Instruction Memory.
<br /> The Type registers functions similarly to a priority queue, so when more than 1 interrupt is pending, the source with the highest priority is serviced first by having its handler's address 
in the Type register when requesting service from the Control unit.
<br />
Once an interrupt request is sent to the CPU, upon the next rising edge the CPU does the following:
<ol><li><strong>On the first cycle:</strong></li>
<ul><li>placeholder_register &lt;= Next_PC </li>
<li>r26(0) &lt;= 0 (This resets GIE - General Interrupt Enable bit, and prevent further interrupts)</li></ul>
<li><strong>On the second cycle</strong></li>
<ul><li>PC &lt;= ITCM[ DTCM[Type] ]</li>
<li>MemWrite = 0 (prevents writing to memory in case we overrode a store word instruction)</li>
<li>r27 &lt;= placeholder_register (saves PC to return to to pre-defined register in RF)</li>
<li> Interrupt_acknowledge = 1 (sent to Interrupt Controller)</li></ul></ol>
<br />
Following these 2 cycles, the CPU now executes the handler for the interrupt request with the highest priority.
<br />
<br />
<em>NOTE:</em> The reset interrupt over-rides every other interrupt, including mid-service, and resets the PC back to 0 without saving the next PC to the RF. The Control unit is responsible 
for distributing the reset line to the whole MCU, which happens on the next rising edge of the MCLK.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.
TO BE CHANGED TO SOMETHING ELSE (HARDWARE?)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Dolev Eisenberg - [![LinkedIn][linkedin-shield]][linkedin-url1]
Amir Aboutboul - [![LinkedIn][linkedin-shield]][linkedin-url2]

Project Link: [https://github.com/doleve46/MIPS-based-MCU---CPU-course-final-project](https://github.com/doleve46/MIPS-based-MCU---CPU-course-final-project)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url1]: https://www.linkedin.com/in/dolev-eisenberg/
[linkedin-url2]: https://www.linkedin.com/in/amir-aboutboul-29038b23b/
