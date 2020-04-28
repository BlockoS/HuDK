;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Title: Text output routines.
;;
;; Example:
;; >    ; setup VDC write offset and register
;; >    ldx    #$08  ; BAT x = 8
;; >    lda    #$0A  ; BAT y = 10
;; >    jsr    vdc_calc_addr
;; >    jsr    vdc_set_write
;; >    ; output the string "Yo"
;; >    lda    #'Y'
;; >    jsr    print_char
;; >    lda    #'o'
;; >    jsr    print_char
;;
;; Note:
;; The font must be 8x8 pixels wide and stored in VRAM as tiles.
;; This means that the font routines modifies the BAT.
;; Only standard ASCII (0-127 included) is supported at the moment.
;;
  .code
;;
;; function: print_char
;; Output an ASCII character at the current BAT location.
;;
;; Remarks:
;;   * The VDC write register must point to a valid BAT location.
;;   * Only a subset of the ASCII character set is supported
;;     (see <8x8 monochrome 1bpp font>).
;;
;; Parameters:
;;   A - ASCII character
;;
  .ifdef HUC
_print_char.1:
    txa
  .endif
print_char:
    clc
    adc    <font_base
    sta    video_data_l
    cla
    adc    <font_base+1
    sta    video_data_h
    rts

;;
;; function: print_digit
;; Output a decimal digit at the current BAT location.
;;
;; Remark:
;; The VDC write register must point to a valid BAT location.
;;
;; Parameters:
;;   A - Digit value between 0 and 9.
;;
  .ifdef HUC
_print_digit.1:
    txa
  .endif
print_digit:
    cmp    #10
    bcc    @l0
        ; The digit is out of bound.
        lda    #$0f     ; '?'
@l0:
    clc
    adc    #FONT_DIGIT_INDEX
    clc
    adc    <font_base
    sta    video_data_l
    cla
    adc    <font_base+1
    sta    video_data_h
    rts

;;
;; function: print_hex
;; Output a hexadecimal digit at the current BAT location.
;;
;; Remark:
;; The VDC write register must point to a valid BAT location.
;;
;; Parameters:
;;   A - Digit value between 0 and 15.
;;
  .ifdef HUC
_print_hex.1:
    txa
  .endif
print_hex:
    cmp    #$10
    bcc    @l0
        ; The digit is out of bound.
        lda    #$3f     ; '?'
        bra    @print
@l0:
    cmp    #$0a
    bcc    @l1
        ; Remember that the carry flag is set. 1 will be added to 
        ; adc operand.
        adc    #(FONT_UPPER_CASE_INDEX - FONT_DIGIT_INDEX - 10 - 1)
@l1:
    clc
    adc    #FONT_DIGIT_INDEX
@print:
    clc
    adc    <font_base
    sta    video_data_l
    cla
    adc    <font_base+1
    sta    video_data_h
    rts

;;
;; function: print_bcd
;; Output a bcd number at the current BAT location.
;;
;; Parameters:
;;   _ax - BCD encoded number (max 4 bytes).
;;   X - BCD array top element index
;;
  .ifdef HUC
_print_bcd.2:
    ldx    #3
    bra    print_bcd
_print_bcd:
    ldx    #1
  .endif
print_bcd:
print_bcd_hi:
    lda    <_ax, X
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    jsr    print_digit
print_bcd_lo:
    lda    <_ax, X
    and    #$0f
    jsr    print_digit
    
    dex
    bpl    print_bcd
    rts

;;
;; function: print_dec_u8
;; Output an unsigned decimal number at the current BAT location.
;;
;; Parameters:
;;   A - Unsigned byte.
;;
  .ifdef HUC
_print_dec_u8:
    txa
  .endif
print_dec_u8:
    jsr    binbcd8
    ldx    #$01
    jmp    print_bcd_lo

;;
;; function: print_dec_u16
;; Output an unsigned decimal number at the current BAT location.
;;
;; Parameters:
;;   A - Word MSB.
;;   X - Word LSB.
;;
  .ifdef HUC
_print_dec_u16:
    sax
  .endif
print_dec_u16:
    jsr    binbcd16
    ldx    #$02
    jmp    print_bcd_lo

;;
;; function: print_hex_u8
;; Output a hexadecimal number at the current BAT location.
;;
;; Parameters:
;;   A - Unsigned byte.
;;
  .ifdef HUC
_print_hex_u8:
    txa
  .endif
print_hex_u8:
    pha
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    jsr    print_hex
    pla
    and    #$0f
    jmp    print_hex

;;
;; function: print_hex_u16
;; Output a hexadecimal number at the current BAT location.
;;
;; Parameters:
;;   A - Word MSB.
;;   X - Word LSB.
;;
  .ifdef HUC
_print_hex_u16:
    sax
  .endif
print_hex_u16:
    jsr    print_hex_u8     ; print MSB
    sax                     ; print LSB
    jmp    print_hex_u8

;;
;; function: print_string
;; Display a null (0) terminated string in a textarea.
;;              
;; The characters must have been previously converted to fit to current font. 
;;
;; Parameters:
;;   _si - string address.
;;     X - textarea x tile position.
;;     A - textarea y tile position.
;;   _al - textarea width.
;;   _ah - textarea height.
;;
;; Returns:
;;   _si - pointer to the last displayed character or '\0'.
;;
  .ifdef HUC
_print_string.5:
    ldx    <_cl
    lda    <_ch
  .endif
print_string:
    jsr    vdc_calc_addr 

    ldx    <_ah
@print_loop:
    jsr    vdc_set_write
    addw   vdc_bat_width, <_di    

    cly
@print_line:
        lda    [_si], Y
        beq    @end             ; end of line
        iny
        cmp    #$0a             ; newline
        beq    @next_line
        jsr    print_char
       
        cpy    <_al
        bne    @print_line
@next_line:
    dex
    beq    @end

    tya
    clc
    adc    <_si
    sta    <_si
    bcc    @l0
        inc    <_si+1
@l0:
    bra    @print_loop
@end:
    tya
    clc
    adc    <_si
    sta    <_si
    rts

;;
;; function: print_string_raw
;; Display a null (0) terminated string.
;;
;; Remark:
;; The VDC write register must point to a valid BAT location.
;; The string must be less than 256 characters long ('\0' included).
;;
;; Parameters:
;;   _si - string address.
;;
  .ifdef HUC
_print_string_raw:
  .endif
print_string_raw:
    cly
@loop:
    lda    [_si], Y
    beq    @end
    jsr    print_char
    iny
    bne    @loop
@end:
    rts

;;
;; function: print_string_n
;; Display the n first characters of a string.
;;
;; Remark:
;; The VDC write register must point to a valid BAT location.
;; The string must be less than 256 characters long.
;;
;; Parameters:
;;   _si - string address.
;;     X - number of characters to print.
;;
  .ifdef HUC
_print_string_n.2:
  .endif
print_string_n:
    cly
@loop:
    lda    [_si], Y
    jsr    print_char
    iny
    dex
    bpl    @loop
@end:
    rts

;;
;; function: print_fill
;; Fill an area with a given character.
;;
;; Parameters:
;;   X - BAT x position.
;;   A - BAT y position.
;;   _al - BAT area width. 
;;   _ah - BAT area height.
;;   _bl - ASCII code.
;;
  .ifdef HUC
_print_fill.5:
    lda    <_ch
    ldx    <_cl
  .endif
print_fill:
    jsr    vdc_calc_addr

    lda    <_bl
    clc
    adc    <font_base
    sta    <_si
    cla
    adc    <font_base+1
    sta    <_si+1

    lda    <_si
    jmp    vdc_fill_bat_ex
