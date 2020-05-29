all: custom_font.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

INPUT_DATA_DIR=$(abspath ../../data/2_custom_font)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

$(OUTPUT_DATA_DIR)/font.bin: $(OUTPUT_DATA_DIR)
	@$(HUDK_TOOLS_PATH)/encode_gfx $(INPUT_DATA_DIR)/data.json $(INPUT_DATA_DIR)/font.png -o $(OUTPUT_DATA_DIR)

custom_font.s: custom_font.c $(OUTPUT_DATA_DIR)/font.bin
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

custom_font.pce: custom_font.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym *.s $(OUTPUT_DATA_DIR)