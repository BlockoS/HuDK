    .include "hudk.s"
    .include "bram.s"
    .include "bcd.s"

    .zp
cursor_x .ds 1
cursor_y .ds 1

    .bss
bm_namebuf       .ds 14

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
    stw    #bm_info_txt, <_si
    lda    #32              ; [todo]
    sta    <_al
    lda    #32              ; [todo]
    sta    <_ah
    ldx    #1               ; [todo]
    lda    #1               ; [todo]
    jsr    print_string
    
    jsr    bm_full_test     ; [todo] set carry flag on error

    ldx    #2               ; [todo]
    lda    #4
    jsr    set_cursor

    stz    bm_namebuf+13
    stz    bm_namebuf+14
    
    stw    #bm_entry, <_bp
@list:
        lda    #high(bm_namebuf)
        ldx    #low(bm_namebuf)
        jsr    bm_getptr.2
        bcs    @end
        sta    <_bp+1
        stx    <_bp
        
        jsr    next_line
        jsr    print_entry_description
        bra    @list
@end:

    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE)
    
    cli 
.loop:
    nop
    bra    .loop    

set_cursor:
    stx    <cursor_x
    sta    <cursor_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    rts

next_line:
    ldx    <cursor_x
    inc    <cursor_y
    lda    <cursor_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    rts

print_entry_description:
    ; print size
    ldx    <_cl
    lda    <_ch
    jsr    print_dec_u16

    ; spacing
    lda    #' '
    jsr    print_char

    ; print user id
    ldx    bm_namebuf
    lda    bm_namebuf+1
    jsr    print_hex_u16

    ; spacing
    lda    #' '
    jsr    print_char

    ; print name
    stw    #bm_namebuf+2, <_si
    jsr    print_string_raw
    rts

bm_full_test:
    ldx    #11              ; [todo]
    lda    #1
    jsr    set_cursor

    jsr    bm_detect
    ldx    bm_error
    lda    bm_detect_msg.lo, X
    sta    <_si
    lda    bm_detect_msg.hi, X
    sta    <_si+1
    jsr    print_string_raw

    jsr    bm_size
    bcc    @display_size
        stwz    <_cx
@display_size:
    jsr   next_line
    ldx   <_cl
    lda   <_ch
    jsr   print_dec_u16

    jsr    bm_free
    bcc    @display_free
        stwz    <_cx
@display_free:
    jsr   next_line
    ldx   <_cl
    lda   <_ch
    jsr   print_dec_u16
    rts

bm_detect_msg.lo:
    .dwl bm_detect_msg00, bm_detect_msg01, bm_detect_msg02
bm_detect_msg.hi:
    .dwh bm_detect_msg00, bm_detect_msg01, bm_detect_msg02

bm_detect_msg00: .db "ok", 0
bm_detect_msg01: .db "not found", 0
bm_detect_msg02: .db "not formatted", 0

bm_info_txt: .db "   Status:\n"
             .db "     Size:\n"
             .db "Available:", 0

palette:
    .db $00,$00,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    .include "font.inc"

