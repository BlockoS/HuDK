;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .include "startup.asm"
    .include "crc.s"

    .code
_main:
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
    ldy    #$10
    jsr    vce_load_palette
 
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #VDC_CR_BG_ENABLE

    ; compute crc-32
    jsr    crc32_begin

    stb    #bank(data), <_bl
    stw    #data, <_si
    jsr    map_data
    stw    #data_size, <_ax
@crc32_loop:
        lda    [_si]
        jsr    crc32

        incw   <_si
        decw   <_ax
        lda    <_al
        ora    <_ah
        bne    @crc32_loop
    jsr    crc32_end

    ; display it
    ldx    #$02
    lda    #$08
    jsr    vdc_calc_addr
    jsr    vdc_set_write

    stw    #computed_txt, <_si
    jsr    print_string_raw

    lda    <_crc+3
    jsr    print_hex_u8
    lda    <_crc+2
    jsr    print_hex_u8
    lda    <_crc+1
    jsr    print_hex_u8
    lda    <_crc
    jsr    print_hex_u8

    ; display expected crc
    ldx    #$02
    lda    #$09
    jsr    vdc_calc_addr
    jsr    vdc_set_write
    
    stw    #expected_txt, <_si
    jsr    print_string_raw

    lda    expected+3
    jsr    print_hex_u8
    lda    expected+2
    jsr    print_hex_u8
    lda    expected+1
    jsr    print_hex_u8
    lda    expected
    jsr    print_hex_u8
    
    ; check result
    ldx    #$02
    lda    #$0a
    jsr    vdc_calc_addr
    jsr    vdc_set_write

    stw    #check_txt, <_si
    jsr    print_string_raw

    ; check if the computed CRC-32 is correct 
    clx
@test:
    lda    expected,X
    cmp    <_crc,X
    bne    @end
    inx
    cpx    #4
    bne    @test
@end:

    stw    #success_txt, <_si
    cpx    #4
    beq    @ok
    stw    #failure_txt, <_si
@ok:
    jsr    print_string_raw

@loop:
    bra    @loop

palette:
    .word VCE_BLACK, VCE_WHITE, VCE_BLACK, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

computed_txt:
    .byte "computed: ", 0
expected_txt:
    .byte "expected: ", 0
check_txt:
    .byte "check: ", 0
success_txt:
    .byte "success", 0
failure_txt:
    .byte "failure", 0

expected:
    .byte $01, $26, $17, $5c

  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif
data:
    .incbin "../data/hudson.dat"
data_size = * - data
