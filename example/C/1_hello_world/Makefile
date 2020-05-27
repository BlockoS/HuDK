all: hello_world.pce

CC=$(HUC_PATH)/huc
CFLAGS?=-fno-recursive -msmall

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

hello_world.s: hello_world.c
	@$(CC) $(CFLAGS) -s $<

hello_world.pce: hello_world.s
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -f *.pce *.lst *.sym *.s
