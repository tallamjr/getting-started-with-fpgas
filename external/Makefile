# Makefile
TOP = top
SRC = top.v
PCF = board.pcf

all: $(TOP).bin

$(TOP).json: $(SRC)
	yosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(SRC)

$(TOP).asc: $(TOP).json $(PCF)
	nextpnr-ice40 --hx1k --package vq100 --json $(TOP).json --asc $(TOP).asc --pcf $(PCF)

$(TOP).bin: $(TOP).asc
	icepack $(TOP).asc $(TOP).bin

program: $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f $(TOP).json $(TOP).asc $(TOP).bin

