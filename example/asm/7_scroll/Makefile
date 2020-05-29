all: scroll_test.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .
INPUT_DATA_DIR=$(abspath ../../data/7_scroll)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/map_8x8.inc: $(OUTPUT_DATA_DIR) 
	@echo "convert 8x8 map"
	@cd $(OUTPUT_DATA_DIR); $(HUDK_TOOLS_PATH)/tiled2bat -p 0 -b 0x2200 $(INPUT_DATA_DIR)/map_8x8.tmx

scroll_test.pce: scroll_test.s $(OUTPUT_DATA_DIR)/map_8x8.inc
	@echo "=> building $@"
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym $(OUTPUT_DATA_DIR)
