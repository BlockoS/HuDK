    .include "hudk.s"
    .include "bram.s"
    .include "bcd.s"

MAIN_MENU   = 0
FILE_MENU   = 1
EDITOR_MENU = 2

    .zp
cursor_x .ds 1
cursor_y .ds 1

entry_count .ds 1

menu_id   .ds 1
joybtn    .ds 1
joybtn_id .ds 1

menu_callbacks .ds 2
callback       .ds 2

    .bss
bm_namebuf       .ds 14
current_menu     .ds 1

    .code
main:
    ; switch resolution to 512x224
    jsr    vdc_xres_512
    jsr    vdc_yres_224
    
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

    lda    #MAIN_MENU
    sta    <menu_id
    
    asl    A
    tay
    lda    joypad_callbacks, Y
    sta    <menu_callbacks
    iny
    lda    joypad_callbacks, Y
    sta    <menu_callbacks+1

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

    ldx    #6               ; [todo]
    lda    #8
    jsr    set_cursor

    stz    bm_namebuf+13
    stz    bm_namebuf+14
    
    stz    <entry_count
    stw    #bm_entry, <_bp
@list:
        lda    #high(bm_namebuf)
        ldx    #low(bm_namebuf)
        jsr    bm_getptr.2
        bcs    @end
        sta    <_bp+1
        stx    <_bp
        
        jsr    print_entry_description
        inc    <entry_count

        bbr0   <entry_count, @newline
@next_column:
        ldx    #34              ; [todo]
        bra    @set_cursor
@newline:
        ldx    #6               ; [todo]
        inc    <cursor_y
@set_cursor:
        lda    <cursor_y
        jsr    set_cursor
        bra    @list
@end:

    jsr    draw_main_menu

    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE)
    
    cli 
.loop:
    nop
    bra    .loop    

joypad_callback:
    stz    <joybtn_id
    lda    joypad
    sta    <joybtn
@loop:
    lsr    <joybtn
    bcs    @run
    beq    @end
@run:
        lda    <joybtn_id
        asl    A
        tay
        lda    [menu_callbacks], Y
        sta    <callback
        iny
        lda    [menu_callbacks], Y
        sta    <callback+1
        jsr    run_callback
        inc    <joybtn_id
        bra    @loop
@end:
    rts
run_callback:
    jmp     [callback]
    
; I, II, SEL, RUN, up, right, down, left

joypad_callbacks:
    .dw    main_menu_callbacks
    .dw    file_menu_callbacks
    .dw    editor_menu_callbacks

main_menu_callbacks:
    .dw main_menu_I, do_nothing,      do_nothing, do_nothing
    .dw do_nothing,  main_menu_right, do_nothing, main_menu_left

file_menu_callbacks:
    .dw file_menu_I,  file_menu_II,    file_menu_SEL,  file_menu_RUN
    .dw file_menu_up, file_menu_right, file_menu_down, file_menu_left

editor_menu_callbacks:
    .dw editor_menu_I,  editor_menu_II,    editor_menu_SEL,  editor_menu_RUN
    .dw editor_menu_up, editor_menu_right, editor_menu_down, editor_menu_left

do_nothing:
    rts

main_menu_I:
main_menu_right:
main_menu_left:
    rts

file_menu_I:
file_menu_II:
file_menu_SEL:
file_menu_RUN:
file_menu_up:
file_menu_right:
file_menu_down:
file_menu_left:
    rts

editor_menu_I:
editor_menu_II:
editor_menu_SEL:
editor_menu_RUN:
editor_menu_up:
editor_menu_right:
editor_menu_down:
editor_menu_left:
    rts

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
    ; entry number
    lda    <entry_count
    jsr    print_hex_u8
    
    ; spacing
    lda    #' '
    jsr    print_char

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

draw_main_menu:
    ldx    #02             ; [todo]
    lda    #26             ; [todo]
    jsr    set_cursor

    stw    #bm_main_menu, <_si
    jsr    print_string_raw
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

bm_main_menu:
    .db "    EDIT    ",$a9,"     BACKUP    ",$a9
    .db "     RESTORE    ",$a9,"     DELETE    ",$00

palette:
    .db $00,$00,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    .include "font.inc"

