all: custom_font.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .
INPUT_DATA_DIR=../../data/2_custom_font
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/font.bin: $(OUTPUT_DATA_DIR)
	@$(HUDK_TOOLS_PATH)/encode_gfx $(INPUT_DATA_DIR)/data.json $(INPUT_DATA_DIR)/font.png -o $(OUTPUT_DATA_DIR)

custom_font.pce: custom_font.s $(OUTPUT_DATA_DIR)/font.bin
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -f *.pce *.lst *.sym $(DATA_DIR)
