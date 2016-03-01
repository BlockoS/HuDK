    .include "hudk.s"
main:
    lda    #bank(hudson.bitmap)
    sta    <_bl
    stw    #$2200, <_di
    stw    #hudson.bitmap, <_si
    stw    #((hudson.bitmap.end - hudson.bitmap) >> 1), <_cx
    jsr    vdc_load_data
    
    lda    #bank(font_8x8)
    sta    <_bl
    stw    #$2e00, <_di
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    vdc_load_1bpp
    
    
    lda    #bank(hudson.bitmap)
    sta    <_bl
    stw    #hudson.palette, <_si
    jsr    map_data

    cla
    ldy    #$01
    jsr    vce_load_palette

    ; setup bat
    stw    #$0220, <_si

    ldx    #0
    lda    #10
    jsr    vdc_calc_addr

    ldy    #$06
.l0:
    jsr    vdc_set_write
    addw   #64, <_di

    ldx    #$20
.l1:
        stw    <_si, video_data
        incw   <_si
        dex
        bne    .l1
    dey
    bne   .l0

    ; enable background display
    vdc_reg #VDC_CR
    stw    #(VDC_CR_BG_ENABLE), video_data

    bra    *

    .bank  $01
    .org   $6000

hudson.palette:
    .incbin "data/hudson.pal"

hudson.bitmap:
    .incbin "data/hudson.dat"
hudson.bitmap.end:

    .include "font.inc"
