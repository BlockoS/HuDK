all: sprites.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .
INPUT_DATA_DIR=$(abspath ../../data/6_sprites)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

sprites.data: $(OUTPUT_DATA_DIR)
	@echo "convert sprites"
	@$(HUDK_TOOLS_PATH)/encode_gfx $(INPUT_DATA_DIR)/data.json $(INPUT_DATA_DIR)/balls.png -o $(OUTPUT_DATA_DIR)

sprites.pce: sprites.s sprites.data
	@echo "=> building $@"
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym $(OUTPUT_DATA_DIR)
