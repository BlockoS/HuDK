all: vgm_play.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

INPUT_DATA_DIR=$(abspath ../../data/20_vgm)
OUTPUT_DATA_DIR=./data

$(OUTPUT_DATA_DIR):
	@mkdir -p $@

vgm.data: $(OUTPUT_DATA_DIR)
	@${HUDK_TOOLS_PATH}/vgm_strip -l c -o 0x6000 -b 1 song $(INPUT_DATA_DIR)/magician_domain.vgm ${OUTPUT_DATA_DIR}

vgm_play.s: vgm_play.c vgm.data
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

vgm_play.pce: vgm_play.s
	@echo "=> building $@"
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym *.s $(OUTPUT_DATA_DIR)
