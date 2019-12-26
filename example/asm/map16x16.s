;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
    .include "start.s"

    .zeropage
scroll_x: ds 2
scroll_y: ds 2
sin_idx:  ds 1
map_col:  ds 1

    .code
_main: 
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE | VDC_CR_VBLANK_ENABLE)

    ; set BAT size
    lda    #VDC_BG_64x32
    jsr    vdc_set_bat_size

    ; set map bounds
    ldx    #00
    lda    vdc_bat_height 
    jsr    map_set_bat_bounds

    ; load tileset palette
    stb    #bank(pal00), <_bl
    stw    #pal00, <_si
    jsr    map_data
    cla
    ldy    #(pal00_size/32)
    jsr    vce_load_palette

    ; load tileset gfx
    stb    #bank(gfx00), <_bl
    stw    #map00_tile_vram, <_di
    stw    #gfx00, <_si
    stw    #(gfx00_size >> 1), <_cx
    jsr    vdc_load_data

    ; set map infos
    map_set map00, map00_tile_vram, tile_pal00, #map00_width, #map00_height, #00

    ; copy map from (0,0) to (17, map_height) to BAT
    ; remember that this is a 16x16 map
    map_copy_16 #0, #0, #0, #0, #17, #map00_height
    
    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

    cli

    ; everythins is similar to the 8x8 example
    ; except that we'll use map_copy_16 to load the map column
    lda    #16
    sta    <map_col
    stwz   <scroll_x
    stz    <sin_idx
@loop:
    vdc_wait_vsync

    vdc_reg #VDC_BXR
    vdc_data <scroll_x
    incw   <scroll_x

    ldy    <sin_idx
    lda    sin_table, Y
    cmp    #$80
    ror    A
    clc
    adc    #64
    sta    <scroll_y
    cla
    adc    #$00
    sta    <scroll_y+1

    inc    <sin_idx

    vdc_reg #VDC_BYR
    vdc_data <scroll_y
 
    lda    <scroll_x
    and    #15
    bne    @l1
        inc    <map_col
        lda    <map_col
        cmp    #map00_width
        bcc    @l0
            stz    <map_col
@l0:
    ; copy the next map column to BAT
    map_copy_16 <map_col, #0, <map_col, #0, #1, #map00_height
@l1:
    bra    @loop    

; sine and cosine tables [-128,128[
sin_table:
    .byte $00,$03,$06,$09,$0c,$10,$13,$16,$19,$1c,$1f,$22,$25,$28,$2b,$2e
    .byte $31,$33,$36,$39,$3c,$3f,$41,$44,$47,$49,$4c,$4e,$51,$53,$55,$58
    .byte $5a,$5c,$5e,$60,$62,$64,$66,$68,$6a,$6b,$6d,$6f,$70,$71,$73,$74
    .byte $75,$76,$78,$79,$7a,$7a,$7b,$7c,$7d,$7d,$7e,$7e,$7e,$7f,$7f,$7f
cos_table:
    .byte $7f,$7f,$7f,$7f,$7e,$7e,$7e,$7d,$7d,$7c,$7b,$7a,$7a,$79,$78,$76
    .byte $75,$74,$73,$71,$70,$6f,$6d,$6b,$6a,$68,$66,$64,$62,$60,$5e,$5c
    .byte $5a,$58,$55,$53,$51,$4e,$4c,$49,$47,$44,$41,$3f,$3c,$39,$36,$33
    .byte $31,$2e,$2b,$28,$25,$22,$1f,$1c,$19,$16,$13,$10,$0c,$09,$06,$03
    .byte $00,$fd,$fa,$f7,$f4,$f0,$ed,$ea,$e7,$e4,$e1,$de,$db,$d8,$d5,$d2
    .byte $cf,$cd,$ca,$c7,$c4,$c1,$bf,$bc,$b9,$b7,$b4,$b2,$af,$ad,$ab,$a8
    .byte $a6,$a4,$a2,$a0,$9e,$9c,$9a,$98,$96,$95,$93,$91,$90,$8f,$8d,$8c
    .byte $8b,$8a,$88,$87,$86,$86,$85,$84,$83,$83,$82,$82,$82,$81,$81,$81
    .byte $81,$81,$81,$81,$82,$82,$82,$83,$83,$84,$85,$86,$86,$87,$88,$8a
    .byte $8b,$8c,$8d,$8f,$90,$91,$93,$95,$96,$98,$9a,$9c,$9e,$a0,$a2,$a4
    .byte $a6,$a8,$ab,$ad,$af,$b2,$b4,$b7,$b9,$bc,$bf,$c1,$c4,$c7,$ca,$cd
    .byte $cf,$d2,$d5,$d8,$db,$de,$e1,$e4,$e7,$ea,$ed,$f0,$f4,$f7,$fa,$fd
    .byte $00,$03,$06,$09,$0c,$10,$13,$16,$19,$1c,$1f,$22,$25,$28,$2b,$2e
    .byte $31,$33,$36,$39,$3c,$3f,$41,$44,$47,$49,$4c,$4e,$51,$53,$55,$58
    .byte $5a,$5c,$5e,$60,$62,$64,$66,$68,$6a,$6b,$6d,$6f,$70,$71,$73,$74
    .byte $75,$76,$78,$79,$7a,$7a,$7b,$7c,$7d,$7d,$7e,$7e,$7e,$7f,$7f,$7f


  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif

map00_width = 32
map00_height = 32
map00_tile_width = 16
map00_tile_height = 16
map00_tile_vram = $2200
map00_tile_pal = 0

map00:
    .incbin "../data/map/map16.map"
gfx00:
    .incbin "../data/map/map16x16.bin"
gfx00_size = * - gfx00
tile_pal00:
    .incbin "../data/map/map16x16.idx"
pal00:
    .incbin "../data/map/map16x16.pal"
pal00_size = * - pal00
