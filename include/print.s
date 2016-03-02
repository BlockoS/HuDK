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
    sec
    sbc    #FONT_ASCII_FIRST
    bcc    .unknown 
    cmp    #FONT_8x8_COUNT
    bcc    .go 
.unknown:
      lda    #$1f        ; '?'
.go:
    clc
    adc     <font_base
    sta     video_data_l
    cla
    adc     <font_base+1
    sta     video_data_h
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
    bcc    .l0
        ; The digit is out of bound.
        lda    #$0f     ; '?'
.l0:
    clc
    adc    #FONT_DIGIT_INDEX
    clc
    adc     <font_base
    sta     video_data_l
    cla
    adc     <font_base+1
    sta     video_data_h
    rts

