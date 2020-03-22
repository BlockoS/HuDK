;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "start.s"
    .include "vdc_sprite.inc"

SPRITES_DATA_VRAM_ADDR = $1800

    .zp
_t .ds 1

    .code
_main: 
    ; set BAT size
    lda    #VDC_BG_32x32
    jsr    vdc_set_bat_size

    ; load sprites palette
    stb    #bank(sprites_pal), <_bl
    stw    #sprites_pal, <_si
    jsr    map_data
    lda    #16
    ldy    #1
    jsr    vce_load_palette

    ; load sprites gfx
    stb    #bank(sprites_data), <_bl
    stw    #sprites_data, <_si
    stw    #(SPRITES_DATA_VRAM_ADDR), <_di
    stw    #(sprites_data_size >> 1), <_cx
    jsr    vdc_load_data

    vdc_reg  #VDC_DMA_CR
    vdc_data #(VDC_DMA_SAT_AUTO | VDC_DMA_SATB_ENABLE)

    stw    #$7000, <_si
    jsr    vdc_sat_addr

    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1
@loop:

    cly
@sprite_loop:

    tya
    asl    A
    asl    A
    asl    A
    asl    A
    asl    A
    ldx    #00
    jsr    spr_x

    tya
    and    #$07
    tax
    phx
    lda    sprite_phase, X
    clc
    adc    <_t
    tax
    lda    sin_table, X
    clc
    plx
    adc    sprite_dy, X
    ldx    #0
    jsr    spr_y

    inc    <_t

    tya
    and    #$07
    asl    A
    tax
    lda    sprite_addr+1,X
    sta    <_al
    lda    sprite_addr, X
    ldx    <_al
    jsr    spr_pattern

    lda    #0
    jsr    spr_pal

    lda    #$01
    jsr    spr_pri

    lda    #(VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK)
    sta    <_al
    
    tya
    and    #$07
    tax
    lda    sprite_size, X
    jsr    spr_ctrl

    iny
    cpy    #08
    bne    @sprite_loop

    ; wait for vsync
    vdc_wait_vsync
    jsr    spr_update_satb

    bra    @loop

; sine and cosine tables [0,16[
sin_table:
    .db $00,$01,$02,$02,$03,$04,$05,$05,$06,$07,$08,$09,$09,$0a,$0b,$0c
    .db $0c,$0d,$0e,$0e,$0f,$10,$10,$11,$12,$12,$13,$14,$14,$15,$15,$16
    .db $17,$17,$18,$18,$19,$19,$1a,$1a,$1b,$1b,$1b,$1c,$1c,$1d,$1d,$1d
    .db $1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
cos_table:
    .db $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1e,$1e,$1e
    .db $1e,$1d,$1d,$1d,$1c,$1c,$1b,$1b,$1b,$1a,$1a,$19,$19,$18,$18,$17
    .db $17,$16,$15,$15,$14,$14,$13,$12,$12,$11,$10,$10,$0f,$0e,$0e,$0d
    .db $0c,$0c,$0b,$0a,$09,$09,$08,$07,$06,$05,$05,$04,$03,$02,$02,$01
    .db $00,$ff,$fe,$fe,$fd,$fc,$fb,$fb,$fa,$f9,$f8,$f7,$f7,$f6,$f5,$f4
    .db $f4,$f3,$f2,$f2,$f1,$f0,$f0,$ef,$ee,$ee,$ed,$ec,$ec,$eb,$eb,$ea
    .db $e9,$e9,$e8,$e8,$e7,$e7,$e6,$e6,$e5,$e5,$e5,$e4,$e4,$e3,$e3,$e3
    .db $e2,$e2,$e2,$e2,$e1,$e1,$e1,$e1,$e1,$e0,$e0,$e0,$e0,$e0,$e0,$e0
    .db $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e1,$e1,$e1,$e1,$e1,$e2,$e2,$e2
    .db $e2,$e3,$e3,$e3,$e4,$e4,$e5,$e5,$e5,$e6,$e6,$e7,$e7,$e8,$e8,$e9
    .db $e9,$ea,$eb,$eb,$ec,$ec,$ed,$ee,$ee,$ef,$f0,$f0,$f1,$f2,$f2,$f3
    .db $f4,$f4,$f5,$f6,$f7,$f7,$f8,$f9,$fa,$fb,$fb,$fc,$fd,$fe,$fe,$ff
    .db $00,$01,$02,$02,$03,$04,$05,$05,$06,$07,$08,$09,$09,$0a,$0b,$0c
    .db $0c,$0d,$0e,$0e,$0f,$10,$10,$11,$12,$12,$13,$14,$14,$15,$15,$16
    .db $17,$17,$18,$18,$19,$19,$1a,$1a,$1b,$1b,$1b,$1c,$1c,$1d,$1d,$1d
    .db $1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f

sprite_size:
    .byte VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .byte VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .byte VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .byte VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .byte VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .byte VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .byte VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .byte VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16

sprite_addr:
    .word SPRITES_DATA_VRAM_ADDR
    .word SPRITES_DATA_VRAM_ADDR+$100
    .word SPRITES_DATA_VRAM_ADDR+$200
    .word SPRITES_DATA_VRAM_ADDR+$300
    .word SPRITES_DATA_VRAM_ADDR+$400
    .word SPRITES_DATA_VRAM_ADDR+$440
    .word SPRITES_DATA_VRAM_ADDR+$480
    .word SPRITES_DATA_VRAM_ADDR+$4c0

sprite_dy:
    .byte $40,$40,$40,$40
    .byte $48,$48,$48,$48

sprite_phase:
    .byte 0,20,40,60,80,100,120,140

  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif

sprites_data:
    .incbin "data/ball0.bin"
    .incbin "data/ball1.bin"
    .incbin "data/ball2.bin"
    .incbin "data/ball3.bin"
    .incbin "data/ball4.bin"
    .incbin "data/ball5.bin"
    .incbin "data/ball6.bin"
    .incbin "data/ball7.bin"
sprites_data_size = * - sprites_data

sprites_pal:
    .incbin "data/palette.bin"
