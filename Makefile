# makefile for example pce/tg16 project
# includes targets for pceas and ca65/ld65
#==============================================================================#
# pceas setup
PCEAS = pceas

EXAMPLE_PCEAS = ./example/pceas
SOURCE_PCEAS  = $(EXAMPLE_PCEAS)/dummy.s
OUTPUT_PCEAS  = $(EXAMPLE_PCEAS)/dummy.pce
SYMBOLS_PCEAS = $(EXAMPLE_PCEAS)/dummy.sym

PCEAS_FLAGS = -I example -I include --raw
#==============================================================================#
# ca65/ld65 setup
CA65 = ca65
LD65 = ld65

EXAMPLE_CA65 = ./example/ca65
SOURCE_CA65  = $(EXAMPLE_CA65)/dummy.s
OBJECT_CA65  = $(EXAMPLE_CA65)/dummy.o
LINK_CA65    = $(EXAMPLE_CA65)/dummy.cfg
OUTPUT_CA65  = $(EXAMPLE_CA65)/dummy.pce

CA65_FLAGS  = -DCA65 -I example -I include -t pce -v
LD65_FLAGS  = -o $(OUTPUT_CA65) -C $(LINK_CA65)
#==============================================================================#
.phony: all ca65 pceas clean

all: pceas ca65

pceas:
	$(PCEAS) $(PCEAS_FLAGS) $(SOURCE_PCEAS)

ca65:
	@echo ca65 example still not finished yet
#	$(CA65) $(CA65_FLAGS) $(SOURCE_CA65)
#	$(LD65) $(LD65_FLAGS) $(OBJECT_CA65)

clean:
	$(RM) $(OUTPUT_PCEAS) $(SYMBOLS_PCEAS)
	$(RM) $(OBJECT_CA65) $(OUTPUT_CA65)
