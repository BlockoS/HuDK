CC65_PATH:=$(CC65_HOME)
HUDK_PATH:=../..

CC= $(CC65_PATH)/bin/cc65 -t pce 
AS= $(CC65_PATH)/bin/ca65 -t pce 
LD= $(CC65_PATH)/bin/ld65 -C $(HUDK_PATH)/cfg/hucard8K.cfg

CFLAGS  = --create-dep $(<:.c=.d) -O -I $(HUDK_PATH)
LDFLAGS = -m $@.map
ASFLAGS = --include-dir $(HUDK_PATH)/include -DCA65 --feature bracket_as_indirect


SYSTEM_SRC := $(HUDK_PATH)/include/start.s
SYSTEM_OBJ :=$(patsubst %.s,%.o, $(SYSTEM_SRC))

CORE_SRC:=$(HUDK_PATH)/include/mpr.s
CORE_SRC+=$(HUDK_PATH)/include/vdc.s
CORE_SRC+=$(HUDK_PATH)/include/psg.s
CORE_OBJ :=$(patsubst %.s,%.o, $(CORE_SRC))

GAME_SRC :=main.c
GAME_OBJ :=$(patsubst %.c,%.o, $(GAME_SRC))

ASSETS_SRC :=
ASSETS_OBJ :=$(patsubst %.s,%.o, $(ASSETS_SRC))

.PHONY: all

#default
all: pce_runtime.lib hudk_cc65_sample.pce

hudk_cc65_sample.pce: $(ASSETS_OBJ) $(SYSTEM_OBJ) $(CORE_OBJ) $(GAME_OBJ)
	$(LD) $(LDFLAGS) -o $@ $(SYSTEM_OBJ) $(CORE_OBJ) $(GAME_OBJ) $(ASSETS_OBJ) pce_runtime.lib 

pce_runtime.lib:
	$(warning pce_runtime.lib isn't available)
	$(error Please read HuDK/docs/cc65.txt for more info)


#file type compilation
$(OUTPUT)%.o: %.c
	$(CC) $(CFLAGS) -o $@.s $<   
	$(AS) $(ASFLAGS) -o $@ $@.s 

$(OUTPUT)%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

#clean
.PHONY:	clean
clean:
	$(RM) *.o
	$(RM) *.pce
	
#.PRECIOUS: resource.s
