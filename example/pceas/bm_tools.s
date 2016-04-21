    .include "hudk.s"
    .include "bram.s"
    .include "bcd.s"
    
    .code
main:
    ; load default font
    stw    #$2000, <_di 
    lda    #.bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load

    lda    #$00
    jsr    font_set_pal

    ; load palette
    stw    #palette, <_si
    jsr    map_data
    cla
    ldy    #$02
    jsr    vce_load_palette
    
    ; fill BAT with space character
    lda    #' '
    sta    <_bl
    lda    vdc_bat_width
    sta    <_al
    lda    vdc_bat_height
    sta    <_ah
    ldx    #$00
    lda    #$00
    jsr    print_fill

    ; detect BRAM
    jsr    bm_detect
    ldx    bm_error
    lda    bm_detect_msg.lo, X
    sta    <_si
    lda    bm_detect_msg.hi, X
    sta    <_si+1
    lda    #32              ; [todo]
    sta    <_al
    lda    #32              ; [todo]
    sta    <_ah
    ldx    #7               ; [todo]
    lda    #1               ; [todo]
    jsr    print_string
    
    jsr    bm_size
    bcs    @size_error
        ldx    #7               ; [todo]
        lda    #2               ; [todo]            
        jsr    vdc_calc_addr 
        jsr    vdc_set_write

        lda   <_cl
        ldx   <_ch
        jsr   print_hex_u16
@size_error:
        
    jsr    bm_free
    bcs    @free_error
        ldx    #7               ; [todo]
        lda    #3               ; [todo]            
        jsr    vdc_calc_addr 
        jsr    vdc_set_write

        lda   <_cl
        ldx   <_ch
        jsr   print_hex_u16
@free_error:
   
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE)
    
    cli 
.loop:
    nop
    bra    .loop    

bm_detect_msg.lo:
    .dwl bm_detect_msg00, bm_detect_msg01, bm_detect_msg02
bm_detect_msg.hi:
    .dwh bm_detect_msg00, bm_detect_msg01, bm_detect_msg02

bm_detect_msg00: .db "detected", 0
bm_detect_msg01: .db "not found", 0
bm_detect_msg02: .db "not formatted", 0

palette:
    .db $00,$00,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    .include "font.inc"

