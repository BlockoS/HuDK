all: joypad_test.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

joypad_test.s: joypad_test.c
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

joypad_test.pce: joypad_test.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -f *.pce *.lst *.sym *.s
