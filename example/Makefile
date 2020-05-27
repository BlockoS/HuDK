SUBDIRS =  asm C

all clean:
	@$(MAKE) $(SUBDIRS) "COMMAND=$@" HUDK_TOOLS_PATH=$(abspath $(HUDK_TOOLS_PATH)) HUC_PATH=$(abspath $(HUC_PATH)) HUDK_INCLUDE_PATH=$(abspath $(HUDK_INCLUDE_PATH))

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) --directory=$@ $(COMMAND)

