CC     := gcc
ECHO   := echo
RM     := rm

CFLAGS := -Wall -Wextra -Wshadow -std=gnu11

.phony: all vgm_play.pce

all: vgm_play.pce

vgm_strip:
	@$(ECHO) "  CC        $@"
	@$(CC) $(CFLAGS) ../../../tools/vgm_strip.c -o $@

song: vgm_strip
	@$(ECHO) "  PREPARING $@"
	@./$< -b 1 -o c000 djs01.vgm song

vgm_play.pce: song
	@$(ECHO) "  PCEAS     $@"
	@$(PCEAS) -I . -I ../../../include -raw vgm_play.s
	
clean:
	@$(ECHO) "  CLEANING... "
	@$(RM) -f song*.* vgm_play.pce vgm_play.sym vgm_strip