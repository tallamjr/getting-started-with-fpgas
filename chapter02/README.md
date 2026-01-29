# Chapter 02: Switches to LEDs

## Overview

This chapter introduces the most basic FPGA design: directly connecting physical switches to LEDs using combinational logic. The `Switches_To_LEDs` module uses `assign` statements to wire each of the four switches to its corresponding LED -- no clock, no flip-flops, pure combinational pass-through.

```verilog
assign o_LED_1 = i_Switch_1;
assign o_LED_2 = i_Switch_2;
// ...
```

When you press a switch, the corresponding LED lights up immediately.

## Prerequisites

1. **OSS CAD Suite** installed and activated:
   ```bash
   source ~/oss-cad-suite/environment
   ```

2. **openFPGALoader** installed:
   ```bash
   brew install openfpgaloader
   ```

3. **GO Board** (Lattice iCE40HX1K-VQ100) connected via USB.

4. Verify tools are available:
   ```bash
   make check-tools
   ```

## Building and Flashing

From the **repository root**:

```bash
# Activate the toolchain
source ~/oss-cad-suite/environment

# Build the bitstream
make TOP=Switches_To_LEDs SRC=chapter02/Switches_To_LEDs.v

# Program the FPGA
make program TOP=Switches_To_LEDs SRC=chapter02/Switches_To_LEDs.v
```

## What Happens During the Build

1. **Synthesis** (Yosys): Parses `Switches_To_LEDs.v` and maps the four `assign` statements to iCE40 primitives. Since there is no sequential logic, no flip-flops are inferred -- only direct I/O connections.

2. **Place and Route** (nextpnr-ice40): Assigns signals to physical pins using `Go_Board_Pin_Constraints.pcf`:
   ```
   set_io i_Switch_1 53    set_io o_LED_1 56
   set_io i_Switch_2 51    set_io o_LED_2 57
   set_io i_Switch_3 54    set_io o_LED_3 59
   set_io i_Switch_4 52    set_io o_LED_4 60
   ```

3. **Bitstream** (icepack): Generates a 32KB binary for the iCE40HX1K.

4. **Programming** (openFPGALoader): Writes the bitstream to the board's flash memory. The FPGA configures itself and the design runs immediately.

## Manual Build (Step by Step)

If you prefer to run each tool individually:

```bash
# 1. Synthesis
yosys -p "synth_ice40 -top Switches_To_LEDs -json switches-to-leds.json" chapter02/Switches_To_LEDs.v

# 2. Place and Route
nextpnr-ice40 --hx1k --package vq100 \
  --json switches-to-leds.json \
  --asc switches-to-leds.asc \
  --pcf Go_Board_Pin_Constraints.pcf

# 3. Bitstream Generation
icepack switches-to-leds.asc switches-to-leds.bin

# 4. Program the FPGA
openFPGALoader -b ice40_generic switches-to-leds.bin
```

> [!TIP]
> This design uses **zero flip-flops** -- it is purely combinational. Each `assign` statement creates a direct wire from an input pin to an output pin, meaning the FPGA acts as little more than a passive routing fabric here.
>
> The contrast with Chapter 04's `LED_Toggle_Project` is instructive: that design needs a clock and flip-flops for edge detection and state storage, while this one demonstrates that not all FPGA designs require sequential logic.

## Testing on Hardware

Once programmed:

- Press **Switch 1** -- **LED 1** lights up
- Press **Switch 2** -- **LED 2** lights up
- Press **Switch 3** -- **LED 3** lights up
- Press **Switch 4** -- **LED 4** lights up
- Release any switch -- the corresponding LED turns off

The response is effectively instantaneous since this is pure combinational logic with no clock involvement.
