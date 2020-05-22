;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "startup.asm"

    .zeropage
offset: ds 2
addr:   ds 2

    .code
_main:
    ; load tile palettes
    stb    #bank(palette), <_bl
    stw    #palette, <_si
    jsr    map_data
    cla
    ldy    #$02
    jsr    vce_load_palette
    ; load font
    stw    #$2000, <_di 
    stb    #bank(font_8x8), <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load
    ; set font palette index
    lda    #$00
    jsr    font_set_pal

    ; clear display with space character
    stb    vdc_bat_width, <_al
    stb    vdc_bat_height, <_ah
    stb    #' ', <_bl
    ldx    #$00
    lda    #$00
    jsr    print_fill

    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE | VDC_CR_VBLANK_ENABLE)

    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

    cli

    stwz   <offset
    
loop:
    ; print offset at the bottom of the screen
    ldx    #00
    lda    #24
    jsr    vdc_calc_addr
    jsr    vdc_set_write
    lda    <offset+1
    ldx    <offset
    jsr    print_hex_u16

    ; print text in a 32x20 box
    stb    #bank(txt), <_bl
    addw   #txt, <offset, <_si
    jsr    map_data
    stw    <_si, <addr

    stb    #32, <_al
    stb    #20, <_ah
    ldx    #$00
    lda    #$00
    jsr    print_string

@wait:
        vdc_wait_vsync
        jsr    joypad_read
        lda    joytrg
        bit    #JOYPAD_I
        beq    @wait

    lda    [_si]
    bne    @skip
        ; Reset text offset
        stwz   <offset
        bra    @next
@skip:
    ; Advance text offset
    lda    <_si
    sec
    sbc    <addr
    tax
    lda    <_si+1
    sbc    <addr+1
    sax
    clc
    adc    <offset
    sta    <offset
    sax
    adc    <offset+1
    sta    <offset+1
@next:

    ; clear the 32x20 box
    stb    #32, <_al
    stb    #20, <_ah
    stb    #' ', <_bl
    ldx    #$00
    lda    #$00
    jsr    print_fill

    bra    loop

palette:
    .word VCE_GREEN, VCE_WHITE, VCE_BLACK, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif

txt:
    .byte "Copyright (c) 2016-2020, XXXX\n"
    .byte "All rights reserved.\n"
    .byte "Redistribution and use in source and binary forms, with or without "
    .byte "modification, are permitted provided that the following conditions "
    .byte "are met:\n"
    .byte "1. Redistributions of source code must retain the above copyright "
    .byte "notice, this list of conditions and the following disclaimer.\n"
    .byte "\n"
    .byte "2. Redistributions in binary form must reproduce the above copyright"
    .byte " notice, this list of conditions and the following disclaimer in the"
    .byte " documentation and/or other materials provided with the distribution.\n"
    .byte "\n"
    .byte "3. Neither the name of the copyright holder nor the names of its"
    .byte " contributors may be used to endorse or promote products derived"
    .byte " from this software without specific prior written permission.\n"
    .byte "\n"
    .byte "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS"
    .byte " \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT"
    .byte " LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A"
    .byte " PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT"
    .byte " HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,"
    .byte " SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED"
    .byte " TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR"
    .byte " PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF"
    .byte " LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT(INCLUDING"
    .byte " NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS"
    .byte " SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
    .byte $00