all: hello_world.pce

AS=$(HUC_PATH)/pceas
ASFLAGS=-I $(HUDK_INCLUDE_PATH) -I .

hello_world.pce: hello_world.s
	@echo "=> building $@"	
	@$(AS) $(ASFLAGS) -o $(OUTDIR)/$@ -raw $<

clean:
	@rm -f *.pce *.lst *.sym
