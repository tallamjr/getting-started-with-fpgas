# Makefile for iCE40 FPGA Development
# Compiles Verilog to bitstream using the OSS CAD Suite open-source toolchain
#
# Usage:
#   make TOP=Module SRC=path/to/file.v  # Build bitstream (TOP and SRC required)
#   make program TOP=Module SRC=...     # Program FPGA (must specify same TOP/SRC)
#   make clean                          # Remove all build artifacts
#   make info TOP=Module SRC=...        # Show build configuration
#   make check-tools                    # Verify toolchain installation

# Configuration variables - MUST be specified on command line
# Example: make TOP=Module_Name SRC=path/to/file.v
TOP ?=
SRC ?=

# Board-specific defaults (GO Board)
PCF ?= Go_Board_Pin_Constraints.pcf
DEVICE ?= hx1k
PACKAGE ?= vq100

# Validation - ensure required variables are set (only for targets that need them)
# Targets that don't need TOP/SRC: clean, help, check-tools
# If MAKECMDGOALS is empty, default target (all) needs validation
ifeq ($(MAKECMDGOALS),)
  NEEDS_VALIDATION := true
else
  NEEDS_VALIDATION := $(filter-out clean help check-tools,$(MAKECMDGOALS))
endif

ifneq ($(NEEDS_VALIDATION),)
  ifeq ($(TOP),)
    $(error TOP module not specified. Usage: make TOP=Module_Name SRC=path/to/file.v)
  endif
  ifeq ($(SRC),)
    $(error SRC file not specified. Usage: make TOP=Module_Name SRC=path/to/file.v)
  endif
endif

# Derived filenames and paths
PROJECT := $(shell echo $(TOP) | tr '[:upper:]' '[:lower:]' | tr '_' '-')
BUILD_DIR := $(dir $(SRC))
JSON := $(BUILD_DIR)$(PROJECT).json
ASC := $(BUILD_DIR)$(PROJECT).asc
BIN := $(BUILD_DIR)$(PROJECT).bin

# Tool configuration
YOSYS := yosys
NEXTPNR := nextpnr-ice40
ICEPACK := icepack
PROGRAMMER := openFPGALoader

# Synthesis flags
SYNTH_FLAGS := -p "synth_ice40 -top $(TOP) -json $(JSON)"

# Place and route flags
PNR_FLAGS := --$(DEVICE) --package $(PACKAGE) --json $(JSON) --asc $(ASC) --pcf $(PCF)

# OpenFPGALoader flags
PROG_FLAGS := -b ice40_generic

# Default target builds the bitstream
.PHONY: all
all: $(BIN)

# Synthesis: Verilog -> JSON netlist
# Yosys converts high-level Verilog to a netlist of iCE40 primitives
$(JSON): $(SRC) $(PCF)
	@echo "==> Synthesis: Converting Verilog to JSON netlist"
	@echo "    Top module: $(TOP)"
	@echo "    Source: $(SRC)"
	$(YOSYS) $(SYNTH_FLAGS) $(SRC)
	@echo "    Output: $(JSON)"

# Place and Route: JSON -> ASCII configuration
# nextpnr determines physical placement and routing on the FPGA
$(ASC): $(JSON) $(PCF)
	@echo "==> Place and Route: Mapping netlist to physical FPGA resources"
	@echo "    Device: $(DEVICE), Package: $(PACKAGE)"
	@echo "    Constraints: $(PCF)"
	$(NEXTPNR) $(PNR_FLAGS)
	@echo "    Output: $(ASC)"

# Bitstream Generation: ASCII -> Binary
# icepack converts the ASCII configuration to binary bitstream
$(BIN): $(ASC)
	@echo "==> Bitstream Generation: Creating binary bitstream"
	$(ICEPACK) $(ASC) $(BIN)
	@echo "    Output: $(BIN) ($(shell ls -lh $(BIN) | awk '{print $$5}'))"
	@echo ""
	@echo "Build complete! Ready to program FPGA with: make program"

# Program FPGA with openFPGALoader
.PHONY: program
program: $(BIN)
	@echo "==> Programming FPGA with openFPGALoader"
	$(PROGRAMMER) $(PROG_FLAGS) $(BIN)

# Alternative: Program FPGA with iceprog (requires icetools)
.PHONY: program-iceprog
program-iceprog: $(BIN)
	@echo "==> Programming FPGA with iceprog"
	iceprog $(BIN)

# Show current configuration
.PHONY: info
info:
	@echo "FPGA Build Configuration:"
	@echo "  Top Module:    $(TOP)"
	@echo "  Source File:   $(SRC)"
	@echo "  Build Dir:     $(BUILD_DIR)"
	@echo "  Constraints:   $(PCF)"
	@echo "  Device:        $(DEVICE)"
	@echo "  Package:       $(PACKAGE)"
	@echo "  Project Name:  $(PROJECT)"
	@echo "  Output Files:  $(JSON), $(ASC), $(BIN)"
	@echo ""
	@echo "Tools:"
	@echo "  Synthesis:     $(YOSYS)"
	@echo "  Place & Route: $(NEXTPNR)"
	@echo "  Bitstream:     $(ICEPACK)"
	@echo "  Programmer:    $(PROGRAMMER)"

# Check if OSS CAD Suite tools are available
.PHONY: check-tools
check-tools:
	@echo "Checking for required tools..."
	@command -v $(YOSYS) >/dev/null 2>&1 || { echo "Error: yosys not found. Source OSS CAD Suite environment."; exit 1; }
	@command -v $(NEXTPNR) >/dev/null 2>&1 || { echo "Error: nextpnr-ice40 not found. Source OSS CAD Suite environment."; exit 1; }
	@command -v $(ICEPACK) >/dev/null 2>&1 || { echo "Error: icepack not found. Source OSS CAD Suite environment."; exit 1; }
	@command -v $(PROGRAMMER) >/dev/null 2>&1 || { echo "Warning: openFPGALoader not found. Programming will not work."; }
	@echo "All required tools found!"
	@$(YOSYS) -V | head -1
	@$(NEXTPNR) --version 2>&1 | head -1
	@echo "icepack: OK"
	@command -v $(PROGRAMMER) >/dev/null 2>&1 && $(PROGRAMMER) --version 2>&1 | head -1 || true

# Clean all generated files
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -f *.json *.asc *.bin
	find chapter* -type f \( -name "*.json" -o -name "*.asc" -o -name "*.bin" \) -delete 2>/dev/null || true
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "iCE40 FPGA Makefile - Open Source Toolchain"
	@echo ""
	@echo "Targets:"
	@echo "  make TOP=... SRC=...  Build bitstream (TOP and SRC required)"
	@echo "  make program TOP=...  Program FPGA with openFPGALoader"
	@echo "  make clean            Remove all build artifacts"
	@echo "  make info TOP=...     Show current build configuration"
	@echo "  make check-tools      Verify all required tools are installed"
	@echo "  make help             Show this help message"
	@echo ""
	@echo "Required Configuration:"
	@echo "  TOP=module_name   Top-level module name (REQUIRED)"
	@echo "  SRC=file.v        Verilog source file path (REQUIRED)"
	@echo ""
	@echo "Optional Configuration:"
	@echo "  PCF=file.pcf      Pin constraints file (default: $(PCF))"
	@echo "  DEVICE=device     FPGA device (default: $(DEVICE))"
	@echo "  PACKAGE=pkg       Package type (default: $(PACKAGE))"
	@echo ""
	@echo "Examples:"
	@echo "  make TOP=Switches_To_LEDs SRC=chapter02/Switches_To_LEDs.v"
	@echo "  make TOP=LED_Toggle_Project SRC=chapter04/LED_Toggle_Project.v"
	@echo "  make program TOP=Switches_To_LEDs SRC=chapter02/Switches_To_LEDs.v"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - OSS CAD Suite installed in ~/oss-cad-suite/"
	@echo "  - Run: source ~/oss-cad-suite/environment"
	@echo "  - openFPGALoader installed (brew install openfpgaloader)"
