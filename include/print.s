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
print_char:
    clc
    adc     <font_base
    vdc_data_l
    cla
    adc     <font_base+1
    vdc_data_h
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
print_digit:
    cmp    #10
    bcc    @l0
        ; The digit is out of bound.
        lda    #$0f     ; '?'
@l0:
    clc
    adc    #FONT_DIGIT_INDEX
    clc
    adc     <font_base
    vdc_data_l
    cla
    adc     <font_base+1
    vdc_data_h
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
    adc     <font_base
    vdc_data_l
    cla
    adc     <font_base+1
    vdc_data_h
    rts

;;
;; function: print_bcd
;; Output a bcd number at the current BAT location.
;;
;; Parameters:
;;   _ax - BCD encoded number (max 4 bytes).
;;   X - BCD array top element index
;;
print_bcd:
print_bcd.hi:
    lda    <_ax, X
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    jsr    print_digit
print_bcd.lo:
    lda    <_ax, X
    and    #$0f
    jsr    print_digit
    
    dex
    bpl     print_bcd
    rts

;;
;; function: print_dec_u8
;; Output an unsigned decimal number at the current BAT location.
;;
;; Parameters:
;;   A - Unsigned byte.
;;
print_dec_u8:
    jsr    binbcd8
    ldx    #$01
    jmp    print_bcd.lo

;;
;; function: print_dec_u16
;; Output an unsigned decimal number at the current BAT location.
;;
;; Parameters:
;;   A - Word MSB.
;;   X - Word LSB.
;;
print_dec_u16:
    jsr    binbcd16
    ldx    #$02
    jmp    print_bcd.lo

;;
;; function: print_hex_u8
;; Output a hexadecimal number at the current BAT location.
;;
;; Parameters:
;;   A - Unsigned byte.
;;
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
