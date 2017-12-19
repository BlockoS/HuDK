.phony: all ca65 pceas clean

all: pceas ca65

pceas:
	$(MAKE) -C example/pceas

ca65:
	@echo ca65 example still not finished yet
#	$(MAKE) -C example/ca65
		

clean:
	$(MAKE) -C example/pceas clean
	$(MAKE) -C example/ca65 clean
