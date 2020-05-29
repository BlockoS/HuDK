all: pong.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .
INPUT_DATA_DIR=$(abspath ../../data/9_pong)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/pong.inc: $(OUTPUT_DATA_DIR) 
	@echo "convert map"
	@cd $(OUTPUT_DATA_DIR); $(HUDK_TOOLS_PATH)/tiled2bat -p 0 -b 0x2200 $(INPUT_DATA_DIR)/pong_map.json

sprites.data: 
	@echo "convert sprites"
	@$(HUDK_TOOLS_PATH)/encode_gfx $(INPUT_DATA_DIR)/sprite.json $(INPUT_DATA_DIR)/sprite.png -o $(OUTPUT_DATA_DIR)

pong.pce: pong.s $(OUTPUT_DATA_DIR)/pong.inc sprites.data
	@echo "=> building $@"
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym $(OUTPUT_DATA_DIR)
