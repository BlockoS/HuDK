all: pong.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

INPUT_DATA_DIR=$(abspath ../../data/9_pong)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/pong.h: $(OUTPUT_DATA_DIR) 
	@echo "convert map"
	@cd $(OUTPUT_DATA_DIR); $(HUDK_TOOLS_PATH)/tiled2bat -l c -p 0 -b 0x2200 $(INPUT_DATA_DIR)/pong_map.json

sprites.data: 
	@echo "convert sprites"
	@$(HUDK_TOOLS_PATH)/encode_gfx $(INPUT_DATA_DIR)/sprite.json $(INPUT_DATA_DIR)/sprite.png -o $(OUTPUT_DATA_DIR)

pong.s: pong.c $(OUTPUT_DATA_DIR)/pong.h sprites.data
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

pong.pce: pong.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym *.s $(OUTPUT_DATA_DIR)
