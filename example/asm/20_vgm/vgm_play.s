 ;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .include "startup.asm"
    .include "vgm.s"
    
    .code
_main:
	; we will use a 32x32 tileset
	lda    #VDC_BG_32x32
	jsr    vdc_set_bat_size
 
	; clear irq config flag
	stz    <irq_m
	
	; set vsync vec
	irq_on INT_IRQ1
	irq_enable_vec VSYNC
	irq_set_vec #VSYNC, #vsync_proc

	stb    #song_bank, <_bl
    stw    #song_base_address, <_si
	stw    #song_loop, <_cx
	ldx    #song_loop_bank
	jsr    vgm_setup

	cli    
@loop:
	vdc_wait_vsync
	bra    @loop

vsync_proc:
	jsr    vgm_update
	rts

song_bank=$01
song_base_address=$6000
song_loop_bank=$01
song_loop=$6fa8

  .data
  .bank $01
  .org $6000
  
  .incbin "data/song0000.bin"

  .data
  .bank $02
  .org $6000

  .incbin "data/song0001.bin"
