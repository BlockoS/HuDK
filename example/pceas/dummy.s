    .include "hudk.s"
main:
    lda    #.bank(hudson.bitmap)
    sta    <_bl
    stw    #$2200, <_di
    stw    #hudson.bitmap, <_si
    stw    #((hudson.bitmap.end - hudson.bitmap) >> 1), <_cx
    jsr    vdc_load_data
   
    stw    #$2e00, <_di 
    lda    #.bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load
    
    lda    #.bank(hudson.bitmap)
    sta    <_bl

    stw    #hudson.palette, <_si
    jsr    map_data
    cla
    ldy    #$02
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
        vdc_data <_si
        incw   <_si
        dex
        bne    .l1
    dey
    bne    .l0

    lda    #$01
    jsr    font_set_pal

	stw    #ascii_string, <_si
    lda    #18
    sta    <_al
    lda    #7
    sta    <_ah
    ldx    #7
    lda    #1
    jsr    print_string

    lda    #18
    sta    <_al
    lda    #5
    sta    <_ah
    lda    #'#'
    sta    <_bl
    ldx    #02
    lda    #17
    jsr    print_fill
 
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE)

    bra    *

ascii_string:
    .db "Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
    .db "Aenean commodo ligula eget dolor.\nAenean massa.",$00
    
    .bank  $01
    .org   $6000

hudson.palette:
    .incbin "data/hudson.pal"
    .dw $0000, $01ff, $0007, $0000, $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

hudson.bitmap:
    .incbin "data/hudson.dat"
hudson.bitmap.end:

    .include "font.inc"
