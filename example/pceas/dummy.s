    .include "pceas/start.s"
main:
    lda    #bank(hudson.bitmap)
    sta    <_bl
    stw    #$3000, <_di
    stw    #hudson.bitmap, <_si
    stw    #(hudson.bitmap.end-hudson.bitmap), <_cx
    jsr    vdc_load_data
    
    lda    #bank(hudson.bitmap)
    sta    <_bl
    stw    #hudson.palette, <_si
    jsr    map_data

    cla
    ldy    #$01
    jsr    vce_load_palette

    ; setup bat
    stw    #$0300, <_si

    ldx    #0
    lda    #1
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
