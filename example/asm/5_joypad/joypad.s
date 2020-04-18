;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .include "startup.asm"
   
; Joypad types
JOYPAD_2 = 0
JOYPAD_6 = 1

JOYPAD_BOX_WIDTH = 32
JOYPAD_BOX_HEIGHT = 4
JOYPAD_BOX_X = 2
JOYPAD_BOX_Y = 1

    .zp
_x .ds 1
_y .ds 1

    .bss
; type of each joypad (2 or 6 button)
joypad_type .ds 5

    .code
_main:
    ; we consider that we have 5 2 buttons joypads
    lda    #JOYPAD_2
    clx
@reset:
    sta    joypad_type, X
    inx
    cpx    #5
    bne    @reset

    ; load font
    stw    #$2000, <_di 
    lda    #bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load
    ; set font palette index
    lda    #$00
    jsr    font_set_pal
    
    ; load tile palettes
    stb    #bank(palette), <_bl
    stw    #palette, <_si
    jsr    map_data
    cla
    ldy    #$20
    jsr    vce_load_palette
 
    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

    ; display joypad status
    stb    #JOYPAD_BOX_Y, <_y
    stz    <_r0 
@l0:
    stw    #text, <_si
    stb    #JOYPAD_BOX_WIDTH, <_al
    stb    #JOYPAD_BOX_HEIGHT, <_ah
    ldx    #JOYPAD_BOX_X
    lda    <_y    
    jsr    print_string
    

    ldx    #$01
    lda    <_y
    jsr    vdc_calc_addr
    jsr    vdc_set_write
    lda    #'1'
    clc
    adc    <_r0
    jsr    print_char
    
    lda    <_y
    clc
    adc    #JOYPAD_BOX_HEIGHT
    sta    <_y
    
    inc    <_r0
    lda    <_r0
    cmp    #5
    bne    @l0

@loop:
    vdc_wait_vsync

    ; retrieve joypad status and print them
    jsr    joypad_6_read
    jsr    joy_print_status

    bra    @loop    

joy_print_status:
    stb    #JOYPAD_BOX_Y, <_y
    cly
@loop:
    ; Check if joypad type changed
    ldx    #JOYPAD_2
    lda    joypad_6, Y
    and    #$50
    cmp    #$50
    bne    @no_6
        ldx    #JOYPAD_6
@no_6:
    txa
    cmp    joypad_type, Y
    beq    @no_change
        ; It has changed!
        sta    joypad_type, Y
        jsr    print_extra_buttons_line
@no_change:

    stb    #JOYPAD_BOX_X, <_x
    lda    joypad, Y
    ldx    #8
    jsr    print_buttons_status

    ; Display extra buttons status ?
    lda    joypad_type, Y
    cmp    #JOYPAD_6
    bne    @no_display_6
        stb    #JOYPAD_BOX_X, <_x
        lda    joypad_6, Y
        ldx    #4
        inc    <_y
        jsr    print_buttons_status
        dec    <_y
@no_display_6:

    lda   <_y
    clc
    adc   #JOYPAD_BOX_HEIGHT
    sta   <_y
    
    iny
    cpy    #5
    bne    @loop

    rts

print_extra_buttons_line:
    asl    A
    tax
    jmp    [print_tbl, X]

print_tbl:
    .word clear_extra_buttons_line
    .word print_6_buttons_line

clear_extra_buttons_line:
    phy
    stb    #JOYPAD_BOX_WIDTH, <_al
    stb    #1, <_ah
    stb    #' ', <_bl
    ldx    #JOYPAD_BOX_X
    lda    extra_buttons_bat_y, Y
    clc
    adc    #JOYPAD_BOX_Y
    jsr    print_fill
    ply
    rts
    
print_6_buttons_line:
    phy
    stw    #text_6, <_si
    stb    #JOYPAD_BOX_WIDTH, <_al
    stb    #1, <_ah
    ldx    #JOYPAD_BOX_X
    lda    extra_buttons_bat_y, Y
    clc
    adc    #JOYPAD_BOX_Y
    jsr    print_string
    ply
    rts

print_buttons_status:
    stx    <_r1
    sta    <_r0    
    clx
@l0:
    lsr    <_r0
    bcc    @off
@on:
    lda    #$10
    bra    @print
@off:
    lda    #$00
@print:
    sta    <_bl
    
    phx
    phy
    
    lda    button_x, X
    clc
    adc    <_x
    tay
    lda    button_y, X
    clc
    adc    <_y
    sxy
    jsr    vdc_calc_addr
    jsr    vdc_set_write
    jsr    vdc_set_read
    
    ldy    #6
@l1:
    lda    video_data_l
    sta    video_data_l
    lda    video_data_h
    and    #$0f
    ora    <_bl
    sta    video_data_h
    dey
    bne    @l1
    
    ply
    plx
    inx
    cpx    <_r1
    bne    @l0
    rts

extra_buttons_bat_y:
    .db 2, 6, 10, 14 

button_x:
    .db  1 ; JOYPAD_I
    .db  8 ; JOYPAD_II
    .db 15 ; JOYPAD_SEL
    .db 22 ; JOYPAD_RUN
    .db  1 ; JOYPAD_UP
    .db 22 ; JOYPAD_RIGHT
    .db  8 ; JOYPAD_DOWN
    .db 15 ; JOYPAD_LEFT

button_y:
    .db 1 ; JOYPAD_I
    .db 1 ; JOYPAD_II
    .db 1 ; JOYPAD_SEL
    .db 1 ; JOYPAD_RUN
    .db 0 ; JOYPAD_UP
    .db 0 ; JOYPAD_RIGHT
    .db 0 ; JOYPAD_DOWN
    .db 0 ; JOYPAD_LEFT

palette:
    .dw VCE_BLACK, VCE_GREY, VCE_BLACK, $0000, $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

palette_on:
    .dw VCE_BLACK, VCE_WHITE, VCE_GREEN, $0000, $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

; text
text:
    .db "| UP   | DOWN | LEFT | RIGHT|\n"
    .db "| I    | II   | SEL  | RUN  |", 0
text_6:
    .db "| III  | IV   | V    | VI   |", 0
