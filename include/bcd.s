;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

;;
;; Title: BCD conversion routines.
;;
    .code
;;
;; function: binbcd8
;; Convert an 8 bit binary value to BCD.
;;
;; Description:
;; This function converts an 8 bit binary value into a 16 bit BCD. It works by
;; transferring one bit a time from the source and adding it into a BCD value
;; that is being doubled on each iteration. As all the arithmetic is being done 
;; in BCD the result is a binary to decimal conversion.
;; 
;; All conversions take 311 clock cycles.
;;
;; For example the conversion of a $96 would look like this :
;; > BIN = $96 -> BIN' = $2C C = 1 | BCD $0000 x2 + C -> BCD' $0001
;; > BIN = $2C -> BIN' = $58 C = 0 | BCD $0001 x2 + C -> BCD' $0002
;; > BIN = $58 -> BIN' = $B0 C = 0 | BCD $0002 x2 + C -> BCD' $0004
;; > BIN = $B0 -> BIN' = $60 C = 1 | BCD $0004 x2 + C -> BCD' $0009
;; > BIN = $60 -> BIN' = $C0 C = 0 | BCD $0009 x2 + C -> BCD' $0018
;; > BIN = $C0 -> BIN' = $80 C = 1 | BCD $0018 x2 + C -> BCD' $0037
;; > BIN = $80 -> BIN' = $00 C = 1 | BCD $0037 x2 + C -> BCD' $0075
;; > BIN = $00 -> BIN' = $00 C = 0 | BCD $0075 x2 + C -> BCD' $0150
;;
;; This technique is very similar to Garth Wilsons, but does away with the
;; look up table for powers of two and much simpler than the approach used by
;; Lance Leventhal in his books (e.g. subtracting out 1000s, 100s, 10s and 1s).
;;
;; Andrew Jacobs, 28-Feb-2004
;;
;; Parameters:
;;   A - Number. 
;;
;; Return:
;;   _ax - Contains the bcd encoded number.
;;
binbcd8:
    sta     <_cl
    sed                 ; Switch to decimal mode
    cla                 ; Ensure the result is clear
    stz     <_al
    stz     <_ah
    ldx     #8          ; The number of source bits
@cnvbit8:   
    asl     <_cl        ; Shift out one bit
    lda     <_ax        ; And add into result
    adc     <_ax
    sta     <_ax
    lda     <_ax+1      ; propagating any carry
    adc     <_ax+1
    sta     <_ax+1
    dex                 ; And repeat for next bit
    bne     @cnvbit8

    cld                 ; Back to binary
    
    rts
    
;;
;; function: binbcd16
;; Convert an 16 bit binary value to BCD
;;
;; Description:
;; This function converts a 16 bit binary value into a 24 bit BCD. It
;; works by transferring one bit a time from the source and adding it
;; into a BCD value that is being doubled on each iteration. As all the
;; arithmetic is being done in BCD the result is a binary to decimal
;; conversion. All conversions take 915 clock cycles.
;;
;; See binbcd8 for more details of its operation.
;;
;; Andrew Jacobs, 28-Feb-2004
;;
;; Parameters:
;;   A - Word MSB
;;   X - Word LSB
;;
;; Return:
;;   _ax - Contains the bcd encoded number (3 bytes).
;;
binbcd16:
    stx     <_cl
    sta     <_ch
    sed                     ; Switch to decimal mode
    cla                     ; Clear result
    stz     <_ax
    stz     <_ax+1
    stz     <_ax+2
    ldx     #16             ; The number of source bits
@cnvbit16:
    asl     <_cl            ; Shift out one bit
    rol     <_ch  
    lda     <_ax            ; And add into result
    adc     <_ax
    sta     <_ax
    lda     <_ax+1          ; propagating any carry
    adc     <_ax+1
    sta     <_ax+1
    lda     <_ax+2          ; ... thru whole result
    adc     <_ax+2
    sta     <_ax+2
    dex                     ; And repeat for next bit
    bne     @cnvbit16
        
    cld                     ; Back to binary

    rts
