CC      := gcc
ECHO    := echo
RM      := rm
CD      := cd
TAR     := tar

CFLAGS  := -Wall -Wextra -Wshadow -std=gnu11 -I .
DEBUG   ?= 0
ifeq ($(DEBUG), 1)
    OUTDIR := $(OUTDIR)/Debug
    CFLAGS += -g -DDEBUG
else
    OUTDIR := $(OUTDIR)/Release
    CFLAGS += -O2
endif

LIBS   := 

SRC :=
OBJ := $(SRC:.c=.o)

DEPEND = .depend

all: $(OBJ) vgmstrip

vgmstrip: vgmstrip.c $(OBJ)
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

%.o: %.c
	@$(ECHO) "  CC        $@"
	@$(CC) $(CFLAGS) -c -o $@ $<

clean:
	@$(ECHO) "  CLEAN     object files"
	@find . -name "*.o" -exec $(RM) -f {} \;
	@$(RM) -f vgmstrip
