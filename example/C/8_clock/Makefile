all: clock.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

clock.s: clock.c
	@echo "=> building $@"
	@$(CC) $(CFLAGS) -s $<

clock.pce: clock.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -f *.pce *.lst *.sym *.s
