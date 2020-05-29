SUBDIRS =  1_hello_world 2_custom_font 3_map_8x8 4_map_16x16 5_joypad 6_sprites 7_scroll 8_clock 9_pong 20_vgm
OUTDIR=$(abspath ../build/asm)

all clean:
	@$(MAKE) $(SUBDIRS) "COMMAND=$@"

.PHONY: $(SUBDIRS)

$(OUTDIR):
	@mkdir -p $@

$(SUBDIRS): $(OUTDIR)
	@$(MAKE) --directory=$@ $(COMMAND) OUTDIR=$(OUTDIR)

