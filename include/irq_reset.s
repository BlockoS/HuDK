;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; $fffe Reset interrupt (HuCard only).
; This routine is called when the console is powered up.

_reset:
    sei                             ; disable interrupts
    csh                             ; switch cpu to high speed mode
    cld                             ; clear decimal flag
    
    ldx    #$ff                     ; initialize the stack pointer ($21ff)
    txs
    
    lda    #$ff                     ; maps the I/O to the first page
    tam0                            ; 0000-1FFF
    
    lda    #$f8                     ; and the RAM bank to the second page
    tam1                            ; 2000-3FFF = Work RAM

    stz    <$00                     ; clear RAM
    tii    $2000, $2001, $1fff
    
    timer_disable                   ; disable timer
    irq_off INT_ALL                 ; disable interrupts
    timer_ack                       ; reset timer

    clock_reset                     ; reset system clock

_init:
    memcpy_init                     ; initialize memcpy ramcode

    jsr    psg_init                 ; initialize sound (mute everything)
    jsr    vdc_init                 ; initialize display with default values
                                    ; bg, sprites and display interrupts are disable
    jsr    vce_init                 ; initialize dot clock, background and border
                                    ; color.

  .ifndef HUDK_USE_CUSTOM_FONT      ; load the default 1bpp 8x8 font
    stw    #(VDC_DEFAULT_TILE_ADDR), <_di
    cla
    jsr    font_8x8_load 
  .endif

    vdc_set_cr #(VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE)
    vdc_enable_display

  .ifdef HUC
    stw    #$3fff, __sp

    lda    #CONST_BANK;+_bank_base    ; map string constants bank
    tam    #2                        ; (ie. $4000-$5FFF)
    ;lda   #_call_bank               ; map call bank
    ;tam   #4                        ; (ie. $8000-$9FFF)
  .endif

    cli

    map  _main
    jsr  _main
    
	jmp	_reset
	
