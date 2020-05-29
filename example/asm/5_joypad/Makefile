all: joypad_test.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I . -I $(HUDK_INCLUDE_PATH)

joypad_test.pce: joypad_test.s
	@echo "=> building $@"
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -rf *.pce *.lst *.sym
