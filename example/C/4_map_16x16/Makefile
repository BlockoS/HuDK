all: map_16x16.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

INPUT_DATA_DIR=$(abspath ../../data/4_map_16x16)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/map_16x16.h: $(OUTPUT_DATA_DIR) 
	@echo "convert 16x16 map"
	@cd $(OUTPUT_DATA_DIR); $(HUDK_TOOLS_PATH)/tiled2bat -l c -p 0 -b 0x2200 $(INPUT_DATA_DIR)/map_16x16.tmx

map_16x16.s: map_16x16.c $(OUTPUT_DATA_DIR)/map_16x16.h
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

map_16x16.pce: map_16x16.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym *.s $(OUTPUT_DATA_DIR)
