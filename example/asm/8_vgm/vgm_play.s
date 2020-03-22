 ;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .include "start.s"
    .include "vgm.s"
    
    .code
_main:
	; we will use a 32x32 tileset
	lda    #VDC_BG_32x32
	jsr    vdc_set_bat_size
 
	; clear irq config flag
	stz    <irq_m
	
	; set vsync vec
	irq_on #INT_IRQ1
	irq_enable_vec #VSYNC
	irq_set_vec #VSYNC, #vsync_proc
	
	; enable background and sprite display
	vdc_reg  #VDC_CR
	vdc_data #VDC_CR_VBLANK_ENABLE
	lda    #VDC_CR_VBLANK_ENABLE
	sta    <vdc_crl

	stb    #song_bank, <_bl
	stw    #song_loop, <_si
	stb    #song_loop_bank, <_bh
	lda    #.hibyte(song_base_address)
	ldx    #.lobyte(song_base_address)
	jsr    vgm_setup

	cli    
.loop:
	vdc_wait_vsync
	bra    .loop

vsync_proc:
	jsr    vgm_update
	rts

song_bank=$01
song_base_address=$6000
song_loop_bank=$01
song_loop=$6fa8

  .ifdef MAGICKIT
    .data
    .bank $01
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif
    .incbin "data/song0000.bin"

  .ifdef MAGICKIT
    .data
    .bank $02
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK02"
    .endif
  .endif
    .incbin "data/song0001.bin"
