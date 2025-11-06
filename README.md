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

## Getting Started with Open Source FPGA Tools

### Why OSS CAD Suite?

This repository uses the **OSS CAD Suite** - a complete, pre-built package of open-source FPGA tools from YosysHQ. Benefits:

- **All-in-one installation**: Single download includes yosys, nextpnr, icestorm, and 100+ other tools
- **No compilation required**: Pre-built binaries for macOS (both Intel and Apple Silicon), Linux, and Windows
- **Regularly updated**: Nightly builds with latest features and bug fixes
- **Consistent versions**: All tools are tested together and guaranteed to work
- **Zero dependencies**: Everything bundled, including Python, libraries, and utilities

Alternative approaches (building from source, using Homebrew taps) often fail due to version mismatches, broken dependencies, or recursive dependency issues. OSS CAD Suite avoids these problems entirely.

### Installation

#### 1. Install openFPGALoader (for programming the FPGA)

```bash
brew install openfpgaloader
```

#### 2. Download and Install OSS CAD Suite

```bash
# Download latest release (for Apple Silicon Macs)
cd ~
curl -L -o oss-cad-suite.tgz https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2025-11-03/oss-cad-suite-darwin-arm64-20251103.tgz

# For Intel Macs, use:
# curl -L -o oss-cad-suite.tgz https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2025-11-03/oss-cad-suite-darwin-x64-20251103.tgz

# Extract
tar -xzf oss-cad-suite.tgz
rm oss-cad-suite.tgz
```

Check for the latest release at: https://github.com/YosysHQ/oss-cad-suite-build/releases/latest

#### 3. Activate the Toolchain

Every time you want to use the FPGA tools, activate the environment:

```bash
source ~/oss-cad-suite/environment
```

**For permanent activation**, add to your `~/.zshrc` or `~/.bashrc`:

```bash
# OSS CAD Suite for FPGA development
source ~/oss-cad-suite/environment
```

#### 4. Verify Installation

```bash
source ~/oss-cad-suite/environment
make check-tools
```

You should see:
- Yosys 0.58+ (synthesis)
- nextpnr-ice40 0.9+ (place and route)
- icepack (bitstream generation)
- openFPGALoader 0.13+ (programming)

## FPGA Development Workflow

### Overview: Verilog → Bitstream → FPGA

The complete workflow has three stages:

1. **Synthesis** (yosys): Verilog → JSON netlist
2. **Place & Route** (nextpnr): JSON → ASCII configuration
3. **Bitstream** (icepack): ASCII → Binary bitstream
4. **Programming** (openFPGALoader): Binary → FPGA hardware

### Quick Start with Makefile

The easiest way to build FPGA bitstreams:

```bash
# Activate tools (if not already in your shell profile)
source ~/oss-cad-suite/environment

# Build the default example (Switches_To_LEDs)
make

# Program your connected FPGA
make program

# Clean build artifacts
make clean

# Build a different module
make TOP=MyModule SRC=path/to/mymodule.v
```

### Manual Workflow (for understanding)

If you want to understand each step or debug issues, run the tools manually:

#### Step 1: Synthesis with Yosys

Converts high-level Verilog to a netlist of iCE40 FPGA primitives.

```bash
yosys -p "synth_ice40 -top Switches_To_LEDs -json switches-to-leds.json" chapter02/Switches_To_LEDs.v
```

**Output**: `switches-to-leds.json` (~332KB) - synthesized netlist in JSON format

**What happens**: Yosys analyses your Verilog, infers logic gates, flip-flops, and RAM blocks, then maps these to iCE40-specific primitives (LUTs, DFFs, etc.).

#### Step 2: Place and Route with nextpnr-ice40

Determines physical placement of logic elements on the FPGA and routes connections between them.

```bash
nextpnr-ice40 --hx1k --package vq100 \
  --json switches-to-leds.json \
  --asc switches-to-leds.asc \
  --pcf Go_Board_Pin_Constraints.pcf
```

**Output**: `switches-to-leds.asc` (~181KB) - ASCII configuration file

**What happens**: nextpnr reads the netlist and pin constraints, assigns each logic element to a physical location on the iCE40HX1K chip, and routes wires between them. It optimises for timing and resource usage.

**Parameters**:
- `--hx1k`: Target device (iCE40HX1K for GO Board)
- `--package vq100`: Physical package type (100-pin VQFP)
- `--pcf`: Pin constraints file mapping signals to physical pins

#### Step 3: Generate Bitstream with icepack

Converts the ASCII configuration to a binary bitstream.

```bash
icepack switches-to-leds.asc switches-to-leds.bin
```

**Output**: `switches-to-leds.bin` (32KB) - binary bitstream

**What happens**: icepack encodes the ASCII configuration into the iCE40's binary bitstream format. The 32KB file contains all the configuration bits for the FPGA's logic, routing, and I/O.

#### Step 4: Program the FPGA

Load the bitstream into your FPGA board.

```bash
# Using openFPGALoader (recommended - supports more boards)
openFPGALoader -b ice40_generic switches-to-leds.bin

# Or using iceprog (included in OSS CAD Suite)
iceprog switches-to-leds.bin
```

**What happens**: The programmer communicates with the FPGA over USB and loads your bitstream into the configuration memory. The FPGA immediately starts running your design.

### Pin Constraints File

The `Go_Board_Pin_Constraints.pcf` file maps Verilog signal names to physical FPGA pins:

```pcf
# Clock
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
```

The PCF file is specific to the GO Board's physical layout. Other FPGA boards require different pin mappings.

### Example: Building the Switches to LEDs Design

```bash
# Activate toolchain
source ~/oss-cad-suite/environment

# Full workflow in one command
make

# Or step-by-step
yosys -p "synth_ice40 -top Switches_To_LEDs -json build.json" chapter02/Switches_To_LEDs.v
nextpnr-ice40 --hx1k --package vq100 --json build.json --asc build.asc --pcf Go_Board_Pin_Constraints.pcf
icepack build.asc build.bin
openFPGALoader -b ice40_generic build.bin
```

### Makefile Configuration

The Makefile is highly configurable:

```bash
# Build different module
make TOP=Blinker SRC=examples/blinker.v

# Use different constraints
make PCF=custom_board.pcf

# Different FPGA device
make DEVICE=hx8k PACKAGE=ct256

# Show current configuration
make info

# Show help
make help
```

### Key Points

- **Completely open source**: No proprietary tools or licenses required
- **GO Board specs**: Lattice iCE40HX1K-VQ100 FPGA
- **Reproducible builds**: Same source always produces identical bitstreams
- **Fast iteration**: Synthesis + place & route typically completes in seconds for small designs
- **Immediate results**: FPGA runs your design as soon as programming completes
- **No FPGA vendor tools needed**: Unlike Xilinx Vivado or Intel Quartus, these tools are vendor-neutral

