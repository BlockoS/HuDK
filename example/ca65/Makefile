# makefile for example pce/tg16 project
#==============================================================================#
# ca65/ld65 setup
ifeq ($(strip $(CC65_HOME)),)
CC65_HOME := d:/pce/tools/GeanyPortablePCE/sdk
endif

CA65 = $(CC65_HOME)/bin/ca65
LD65 = $(CC65_HOME)/bin/ld65

OUTPUT := obj/example/ca65
EXAMPLE_CA65 = ./example/ca65

SOURCE_CA65 := ./include/start.s
SOURCE_CA65 += $(EXAMPLE_CA65)/dummy.s
SOURCE_CA65 += ./include/vgm.s
SOURCE_CA65 += ./include/analog.s

OBJECT_CA65 := $(subst $(EXAMPLE_CA65)/, $(OUTPUT)/,$(SOURCE_CA65:.s=.o))
OBJECT_CA65 := $(subst ./include/, $(OUTPUT)/,$(OBJECT_CA65:.s=.o))

LINK_CA65    = ./cfg/hucard8K.cfg
OUTPUT_CA65  = $(EXAMPLE_CA65)/hudk_ca65_sample.pce

CA65_FEATURES = --feature bracket_as_indirect
CA65_INCLUDES = -I ./example -I ./include

CA65_FLAGS  = -DCA65 $(CA65_FEATURES) $(CA65_INCLUDES) -t pce -v
LD65_FLAGS  = -o $(OUTPUT_CA65) -C $(LINK_CA65)

#==============================================================================#
.phony: all clean

all: $(OBJECT_CA65)
	@echo ca65 example still not finished yet
	$(LD65) $(LD65_FLAGS) $(OBJECT_CA65)


$(OUTPUT)/%.o:./include/%.s
	$(CA65) $(CA65_FLAGS) -o $@ $< 

$(OUTPUT)/%.o:$(EXAMPLE_CA65)/%.s
	$(CA65) $(CA65_FLAGS) -o $@ $< 
	
clean:
	$(RM) $(OBJECT_CA65) $(OUTPUT_CA65)
