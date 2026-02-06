# Makefile for iCE40 FPGA Development with SystemVerilog
# Compiles SystemVerilog to bitstream using yosys with slang plugin (OSS CAD Suite)
#
# This Makefile uses the slang plugin for yosys as the SystemVerilog frontend
# instead of the standard Yosys Verilog parser. The slang library provides full
# SystemVerilog 2017/2023 support.
#
# Prerequisites:
#   - OSS CAD Suite (includes yosys with slang plugin, nextpnr-ice40, icepack)
#     Download from: https://github.com/YosysHQ/oss-cad-suite-build/releases
#   - openFPGALoader for programming
#
# IMPORTANT: The OSS CAD Suite must be sourced BEFORE running make:
#   source ~/oss-cad-suite/environment
#
# Usage:
#   make -f Makefile.sv TOP=Module SRC=path/to/file.sv  # Build bitstream
#   make -f Makefile.sv program TOP=Module SRC=...      # Program FPGA
#   make -f Makefile.sv clean                           # Remove build artifacts
#   make -f Makefile.sv info TOP=Module SRC=...         # Show configuration
#   make -f Makefile.sv check-tools                     # Verify toolchain
#   make -f Makefile.sv check-slang                     # Verify slang plugin

# Configuration variables - MUST be specified on command line
# Example: make -f Makefile.sv TOP=Module_Name SRC=path/to/file.sv
TOP ?=
SRC ?=

# Board-specific defaults (GO Board)
PCF ?= Go_Board_Pin_Constraints.pcf
DEVICE ?= hx1k
PACKAGE ?= vq100

# Validation - ensure required variables are set (only for targets that need them)
# Targets that don't need TOP/SRC: clean, help, check-tools, check-slang
# If MAKECMDGOALS is empty, default target (all) needs validation
ifeq ($(MAKECMDGOALS),)
  NEEDS_VALIDATION := true
else
  NEEDS_VALIDATION := $(filter-out clean help check-tools check-slang,$(MAKECMDGOALS))
endif

ifneq ($(NEEDS_VALIDATION),)
  ifeq ($(TOP),)
    $(error TOP module not specified. Usage: make -f Makefile.sv TOP=Module_Name SRC=path/to/file.sv)
  endif
  ifeq ($(SRC),)
    $(error SRC file not specified. Usage: make -f Makefile.sv TOP=Module_Name SRC=path/to/file.sv)
  endif
endif

# Derived filenames and paths
PROJECT := $(shell echo $(TOP) | tr '[:upper:]' '[:lower:]' | tr '_' '-')
BUILD_DIR := $(dir $(SRC))
JSON := $(BUILD_DIR)$(PROJECT).json
ASC := $(BUILD_DIR)$(PROJECT).asc
BIN := $(BUILD_DIR)$(PROJECT).bin

# Tool configuration
# OSS CAD Suite includes yosys with the slang plugin pre-installed.
# The slang plugin is loaded with: yosys -m slang
#
# Auto-detect OSS CAD Suite location (default: ~/oss-cad-suite)
OSS_CAD_SUITE ?= $(HOME)/oss-cad-suite

# Use OSS CAD Suite tools explicitly to avoid conflicts with Homebrew tools
# which may not have the slang plugin or correct versions
YOSYS := $(OSS_CAD_SUITE)/bin/yosys
YOSYS_SLANG := $(YOSYS) -m slang
NEXTPNR := $(OSS_CAD_SUITE)/bin/nextpnr-ice40
ICEPACK := $(OSS_CAD_SUITE)/bin/icepack
# openFPGALoader may be installed separately via Homebrew
PROGRAMMER := openFPGALoader

# Synthesis flags for yosys with slang plugin
# read_slang reads SystemVerilog files using the slang frontend
# synth_ice40 synthesises for iCE40 FPGAs and outputs JSON netlist
SYNTH_FLAGS := -p "read_slang -top $(TOP) $(SRC); synth_ice40 -top $(TOP) -json $(JSON)"

# Place and route flags
PNR_FLAGS := --$(DEVICE) --package $(PACKAGE) --json $(JSON) --asc $(ASC) --pcf $(PCF)

# OpenFPGALoader flags
PROG_FLAGS := -b ice40_generic

# Default target builds the bitstream
.PHONY: all
all: $(BIN)

# Synthesis: SystemVerilog -> JSON netlist
# yosys with slang plugin converts SystemVerilog to a netlist of iCE40 primitives
# using the slang library for full SV2017/SV2023 parsing support
$(JSON): $(SRC) $(PCF)
	@echo "==> Synthesis: Converting SystemVerilog to JSON netlist"
	@echo "    Top module: $(TOP)"
	@echo "    Source: $(SRC)"
	@echo "    Using yosys with slang plugin for SystemVerilog frontend"
	$(YOSYS_SLANG) $(SYNTH_FLAGS)
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
	@echo "Build complete! Ready to program FPGA with: make -f Makefile.sv program"

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
	@echo "SystemVerilog FPGA Build Configuration:"
	@echo "  Top Module:      $(TOP)"
	@echo "  Source File:     $(SRC)"
	@echo "  Build Dir:       $(BUILD_DIR)"
	@echo "  Constraints:     $(PCF)"
	@echo "  Device:          $(DEVICE)"
	@echo "  Package:         $(PACKAGE)"
	@echo "  Project Name:    $(PROJECT)"
	@echo "  Output Files:    $(JSON), $(ASC), $(BIN)"
	@echo ""
	@echo "Tools:"
	@echo "  OSS CAD Suite:   $(OSS_CAD_SUITE)"
	@echo "  Yosys:           $(YOSYS)"
	@echo "  Synthesis:       $(YOSYS_SLANG) (SystemVerilog frontend)"
	@echo "  Place & Route:   $(NEXTPNR)"
	@echo "  Bitstream:       $(ICEPACK)"
	@echo "  Programmer:      $(PROGRAMMER)"

# Check if yosys with slang plugin is available
.PHONY: check-slang
check-slang:
	@echo "Checking for yosys with slang plugin..."
	@echo "  OSS CAD Suite path: $(OSS_CAD_SUITE)"
	@echo "  Yosys binary: $(YOSYS)"
	@if [ -x "$(YOSYS)" ]; then \
		echo ""; \
		echo "OSS CAD Suite yosys found!"; \
		$(YOSYS) -V 2>&1 | head -1; \
		echo ""; \
		echo "Testing slang plugin..."; \
		if $(YOSYS_SLANG) -p "help read_slang" >/dev/null 2>&1; then \
			echo "slang plugin loaded successfully!"; \
			$(YOSYS_SLANG) -p "help read_slang" 2>&1 | head -5; \
		else \
			echo "Error: slang plugin failed to load."; \
			echo "Check that OSS CAD Suite is properly installed."; \
			exit 1; \
		fi; \
	else \
		echo ""; \
		echo "Error: OSS CAD Suite yosys not found at $(YOSYS)"; \
		echo ""; \
		echo "Please install OSS CAD Suite:"; \
		echo "  1. Download from: https://github.com/YosysHQ/oss-cad-suite-build/releases"; \
		echo "  2. Extract to ~/oss-cad-suite/"; \
		echo "  3. Source environment: source ~/oss-cad-suite/environment"; \
		echo ""; \
		echo "Or specify custom location: make -f Makefile.sv OSS_CAD_SUITE=/path/to/oss-cad-suite ..."; \
		exit 1; \
	fi

# Check if OSS CAD Suite tools are available
.PHONY: check-tools
check-tools: check-slang
	@echo ""
	@echo "Checking for other required tools..."
	@if [ -x "$(NEXTPNR)" ]; then \
		echo "nextpnr-ice40: OK"; \
		$(NEXTPNR) --version 2>&1 | head -1; \
	else \
		echo "Error: nextpnr-ice40 not found at $(NEXTPNR)"; \
		exit 1; \
	fi
	@if [ -x "$(ICEPACK)" ]; then \
		echo "icepack: OK"; \
	else \
		echo "Error: icepack not found at $(ICEPACK)"; \
		exit 1; \
	fi
	@if command -v $(PROGRAMMER) >/dev/null 2>&1; then \
		echo "openFPGALoader: OK"; \
		$(PROGRAMMER) -V 2>&1 | head -1 || true; \
	else \
		echo "Warning: openFPGALoader not found. Programming will not work."; \
		echo "  Install via: brew install openfpgaloader"; \
	fi
	@echo ""
	@echo "All required tools found!"

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
	@echo "iCE40 FPGA Makefile - SystemVerilog with yosys slang plugin"
	@echo ""
	@echo "This Makefile uses yosys with the slang plugin for SystemVerilog 2017/2023 support."
	@echo "For standard Verilog files, use the regular Makefile instead."
	@echo ""
	@echo "Targets:"
	@echo "  make -f Makefile.sv TOP=... SRC=...  Build bitstream (TOP and SRC required)"
	@echo "  make -f Makefile.sv program TOP=...  Program FPGA with openFPGALoader"
	@echo "  make -f Makefile.sv clean            Remove all build artifacts"
	@echo "  make -f Makefile.sv info TOP=...     Show current build configuration"
	@echo "  make -f Makefile.sv check-tools      Verify all required tools are installed"
	@echo "  make -f Makefile.sv check-slang      Verify slang plugin is available"
	@echo "  make -f Makefile.sv help             Show this help message"
	@echo ""
	@echo "Required Configuration:"
	@echo "  TOP=module_name   Top-level module name (REQUIRED)"
	@echo "  SRC=file.sv       SystemVerilog source file path (REQUIRED)"
	@echo ""
	@echo "Optional Configuration:"
	@echo "  PCF=file.pcf          Pin constraints file (default: $(PCF))"
	@echo "  DEVICE=device         FPGA device (default: $(DEVICE))"
	@echo "  PACKAGE=pkg           Package type (default: $(PACKAGE))"
	@echo "  OSS_CAD_SUITE=path    OSS CAD Suite location (default: ~/oss-cad-suite)"
	@echo ""
	@echo "Examples:"
	@echo "  make -f Makefile.sv TOP=Switches_To_LEDs SRC=chapter02/systemverilog/Switches_To_LEDs.sv"
	@echo "  make -f Makefile.sv program TOP=Switches_To_LEDs SRC=chapter02/systemverilog/Switches_To_LEDs.sv"
	@echo ""
	@echo "Prerequisites:"
	@echo "  1. OSS CAD Suite (includes yosys with slang, nextpnr-ice40, icepack)"
	@echo "     Download: https://github.com/YosysHQ/oss-cad-suite-build/releases"
	@echo "     Extract to ~/oss-cad-suite/ (or set OSS_CAD_SUITE variable)"
	@echo "  2. Source environment BEFORE running make:"
	@echo "     source ~/oss-cad-suite/environment"
	@echo "  3. openFPGALoader for programming (brew install openfpgaloader)"
