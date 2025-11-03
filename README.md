## About

This repository contains supporting code for the book Getting Started with FPGAs by Russell Merrick. All Verilog and VHDL code used in the book can be found in this repository.

Within this repository, the code is broken down by Chapters. These chapters match the organization in the book. See below for details of each chapter.

If you find any typos, errors, or suggested improvements, please open an issue within this GitHub repository.

## More References

- Purchase "Getting Started with FPGAs" book at [nandland.com](https://nandland.com) or directly from the [publisher](https://nostarch.com/gettingstartedwithfpgas)

- More examples and tutorials at [nandland.com](https://nandland.com)

- My [YouTube](https://youtube.com/c/nandland) channel

- Free Verilog and VHDL simulator: [EDA Playground](https://edaplayground.com)

- Download Lattice [iCEcube2](https://www.latticesemi.com/iCEcube2)

- Buy a [Go Board](https://nandland.com/the-go-board) to run your Verilog or VHDL on a real device

## Book Table of Contents

### Chapter 1: Meet the FPGA

Introduces FPGAs and talks about their strengths and weaknesses. Being an engineer is about knowing which tool to use in which scenario. Understanding when to use an FPGA—and when not to—is crucial.

### Chapter 2: Setting Up Your Hardware and Tools

Gets you set up with the Lattice iCE40 series of FPGAs. You’ll download and install the FPGA tools and learn how to run them to program your FPGA.

### Chapter 3: Boolean Algebra and the Look-Up Table

Explores one of the two most fundamental FPGA components: the look-up table (LUT). You’ll learn how LUTs perform Boolean algebra and take the place of dedicated logic gates.

### Chapter 4: Storing State with the Flip-Flop

Introduces the second fundamental FPGA component: the flip-flop. You’ll see how flip-flops store state within an FPGA, giving the device memory of what happened previously.

### Chapter 5: Testing Your Code with Simulation

Discusses how to write testbenches to simulate your FPGA designs and make sure they work correctly. It’s hard to see what’s going on inside a real physical FPGA, but simulations let you investigate how your code is behaving, find bugs, and understand strange behaviors.

### Chapter 6: Common FPGA Modules

Shows how to create some basic building blocks common to most FPGA designs, including multiplexers, demultiplexers, shift registers, and first in, first out (FIFO) and other memory structures. You’ll learn how they work and how to combine them to solve complex problems.

### Chapter 7: Synthesis, Place and Route, and Crossing Clock Domains

Expands on the FPGA build process, with details about synthesis and the place and route stage. You’ll learn about timing errors and how to avoid them, and how to safely cross between clock domains within your FPGA design.

### Chapter 8: The State Machine

Introduces the state machine, a common model for keeping track of the logical flow through a sequence of events in an FPGA. You’ll use a state machine to implement an interactive memory game.

### Chapter 9: Useful FPGA Primitives

Discusses other important FPGA components besides the LUT and the flip-flop, including the block RAM, the DSP block, and the phase-locked loop (PLL). You’ll learn different strategies for harnessing these components and see how they solve common problems.

### Chapter 10: Numbers and Math

Outlines simple rules for working with numbers and implementing math operations in an FPGA. You’ll learn the difference between signed and unsigned numbers, fixedpoint and floating-point operations, and more.

### Chapter 11: Getting Data In and Out with I/O and SerDes

Examines the input/output (I/O) capabilities of an FPGA. You’ll learn the pros and cons of different types of interfaces and be introduced to SerDes, a powerful FPGA feature for high-speed data transmission.

### Appendix A: FPGA Development Boards

Suggests some FPGA development boards that you can use for this book’s projects.

### Appendix B: Tips for a Career in FPGA Engineering

Outlines strategies for finding an FPGA-related job, in case you want to pursue FPGA design professionally. I’ll make suggestions on how to build a good resume, prepare for interviews, and negotiate for the best-possible job offer.

## Getting Started

1. Install the core tools via Homebrew (as documented in external/README.md:22):
brew install yosys libftdi graphviz libftdi0
brew install cmake python boost eigen

2. Install the iCE40 toolchain:
# Install icestorm tools (includes iceprog for programming)
git clone https://github.com/ddm/icetools.git
cd icetools && ./icetools.sh

# Install nextpnr for place-and-route
git clone https://github.com/YosysHQ/nextpnr.git
cd nextpnr && git submodule update --init --recursive
mkdir build && cd build
cmake .. -DARCH=ice40
make -j$(nproc)
sudo make install

The Complete Workflow

The workflow follows these stages: Verilog → Synthesis → Place & Route → Bitstream → Programming

Here's how each tool fits into the process:

1. Write Your Verilog Code

Create your design file (e.g., my_design.v). For example, let's use the simple LED control from chapter02/Switches_To_LEDs.v:85:

module my_design (
    input  i_Switch_1,
    input  i_Switch_2,
    input  i_Switch_3,
    input  i_Switch_4,
    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4
);

    assign o_LED_1 = i_Switch_1;
    assign o_LED_2 = i_Switch_2;
    assign o_LED_3 = i_Switch_3;
    assign o_LED_4 = i_Switch_4;

endmodule

2. Create Pin Constraints File

Copy the provided Go_Board_Pin_Constraints.pcf:1 or create your own .pcf file mapping your Verilog signals to physical FPGA pins:

# Clock and basic I/O constraints for GO Board (iCE40HX1K VQ100)
set_io i_Clk 15

# LED outputs
set_io o_LED_1 56
set_io o_LED_2 57
set_io o_LED_3 59
set_io o_LED_4 60

# Switch inputs
set_io i_Switch_1 53
set_io i_Switch_2 51
set_io i_Switch_3 54
set_io i_Switch_4 52

3. Synthesis with Yosys

Convert your Verilog to a JSON netlist (external/Makefile:9):

yosys -p "synth_ice40 -top my_design -json my_design.json" my_design.v

What this does: Yosys reads your Verilog, performs synthesis (converts high-level constructs to basic logic elements), and outputs a JSON representation targeting iCE40 primitives.

4. Place and Route with nextpnr-ice40

Convert the netlist to an ASCII configuration file (external/Makefile:12):

nextpnr-ice40 --hx1k --package vq100 --json my_design.json --asc my_design.asc --pcf Go_Board_Pin_Constraints.pcf

What this does: nextpnr takes the synthesised netlist and your pin constraints, then decides exactly where each logic element goes on the physical FPGA and how they're connected (place and route).

5. Generate Bitstream with icepack

Convert ASCII config to binary bitstream (external/Makefile:15):

icepack my_design.asc my_design.bin

What this does: icepack converts the ASCII configuration into a binary bitstream that can be loaded into the FPGA's configuration memory.

6. Program the FPGA with iceprog

Flash the bitstream to your connected FPGA (external/Makefile:18):

iceprog my_design.bin

What this does: iceprog communicates with the FPGA over USB and loads your bitstream into the device's configuration memory, making your design active immediately.

Complete Example Using the Provided Makefile

The external/Makefile:1 provides a complete workflow template. To use it:

1. Set up your project structure:
cp external/Makefile ./
cp Go_Board_Pin_Constraints.pcf ./board.pcf

2. Create your Verilog file as top.v (or modify the Makefile TOP variable)
3. Build and program:
# Build everything (synthesis → place&route → bitstream)
make

# Program the FPGA
make program

# Clean build files
make clean

Example: Simple LED Blinker

Here's a complete working example that blinks an LED:

blinker.v:
module blinker (
    input i_Clk,
    output o_LED_1
);

    reg [23:0] counter = 0;
    reg led_state = 0;

    always @(posedge i_Clk) begin
        counter <= counter + 1;
        if (counter == 0) begin
            led_state <= ~led_state;
        end
    end

    assign o_LED_1 = led_state;

endmodule

Build and program:
# Synthesis
yosys -p "synth_ice40 -top blinker -json blinker.json" blinker.v

# Place and route
nextpnr-ice40 --hx1k --package vq100 --json blinker.json --asc blinker.asc --pcf Go_Board_Pin_Constraints.pcf

# Generate bitstream
icepack blinker.asc blinker.bin

# Program FPGA
iceprog blinker.bin

Key Points:

- No proprietary tools needed - this is a completely open source workflow
- The GO Board uses a Lattice iCE40HX1K FPGA in VQ100 package
- Pin constraints are crucial - they tell the tools which Verilog signals connect to which physical pins
- The workflow is linear - each step depends on the previous one's output
- Programming is immediate - once iceprog completes, your design is running on the hardware

This workflow lets you go from Verilog code to a running FPGA design using entirely open source tools!

