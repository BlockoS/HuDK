# makefile for example pce/tg16 project
#==============================================================================#
# pceas setup
PCEAS = pceas

EXAMPLE_PCEAS = ./example/pceas
SOURCE_PCEAS  = $(EXAMPLE_PCEAS)/dummy.s
OUTPUT_PCEAS  = $(EXAMPLE_PCEAS)/dummy.pce
SYMBOLS_PCEAS = $(EXAMPLE_PCEAS)/dummy.sym

PCEAS_FLAGS = -I example -I include --raw

#==============================================================================#
.phony: all clean

all: 
	$(PCEAS) $(PCEAS_FLAGS) $(SOURCE_PCEAS)

clean:
	$(RM) $(OUTPUT_PCEAS) $(SYMBOLS_PCEAS)
