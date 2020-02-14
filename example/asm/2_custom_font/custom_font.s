;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
HUDK_USE_CUSTOM_FONT = 1

FONT_8x8_COUNT=$1ff
FONT_ASCII_FIRST=$00
FONT_ASCII_LAST =$9e
FONT_DIGIT_INDEX=$30
FONT_UPPER_CASE_INDEX=$41
FONT_LOWER_CASE_INDEX=$61

    .include "start.s"

    .code
_main:
    ; load font palette
    stb    #bank(palette_bin), <_bl
    stw    #palette_bin, <_si
    jsr    map_data
    cla
    ldy    #1
    jsr    vce_load_palette

    ; load font gfx
    stb    #bank(font_bin), <_bl
    stw    #font_bin, <_si
    stw    #(VDC_DEFAULT_TILE_ADDR), <_di
    stw    #4096, <_cx
    jsr    vdc_load_data

    ; set font VRAM address
    ldx    #<VDC_DEFAULT_TILE_ADDR
    lda    #>VDC_DEFAULT_TILE_ADDR
    jsr    font_set_addr

    ; set font palette
    lda    #$00
    jsr    font_set_pal

    ; Display "Hello world!" on screen.
    ; The string will be placed at BAT coordinate [10,8] using the custom font
    stw    #txt, <_si       ; string address
    stb    #32, <_al        ; text area width
    stb    #20, <_ah        ; text area height
    ldx    #10              ; BAT X coordinate
    lda    #8               ; BAT Y coordinate
    jsr    print_string

loop:
    vdc_wait_vsync          ; wait for screen refresh
    bra    loop             ; and we'll loop indefinitely

txt:                        ; the string we'll print on screen
    .byte "Hello world!", 0

palette_bin:
    .incbin "data/palette.bin"

  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif
font_bin:
    .incbin "data/font.bin"
