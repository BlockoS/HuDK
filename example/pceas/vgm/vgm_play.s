    .code

    .include "start.s"
    .include "bcd.s"
    .include "vgm.s"
    
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

    jsr    vgm_setup

    cli    
.loop:
    vdc_wait_vsync
    bra    .loop

vgm_setup:
	lda    #low(song_base_address)
	sta    <vgm_base
	sta    <vgm_ptr
	
	lda    #high(song_base_address)
	sta    <vgm_base+1
	sta    <vgm_ptr+1
	
	lda    #song_bank
	sta    <vgm_bank
	
	lda    <vgm_base+1
	clc
	adc    #$20
	sta    <vgm_end
	
	lda    #song_loop_bank
	sta    <vgm_loop_bank
	stw    #song_loop, <vgm_loop_ptr
	
	stz    <vgm_wait
	rts

vsync_proc:
	jsr    vgm_update
    rts
    
    .include "font.inc"
    
    .data
    .include "song.inc"
