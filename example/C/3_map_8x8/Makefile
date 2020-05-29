all: map_8x8.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

INPUT_DATA_DIR=$(abspath ../../data/3_map_8x8)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/map_8x8.h: $(OUTPUT_DATA_DIR) 
	@echo "convert 8x8 map"
	@cd $(OUTPUT_DATA_DIR); $(HUDK_TOOLS_PATH)/tiled2bat -l c -p 0 -b 0x2200 $(INPUT_DATA_DIR)/map_8x8.tmx

map_8x8.s: map_8x8.c $(OUTPUT_DATA_DIR)/map_8x8.h
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

map_8x8.pce: map_8x8.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym *.s $(OUTPUT_DATA_DIR)
