;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

;;
;; Title: Math routines.
;;
    .code
;;
;; function: mulu8
;; Multiply 2 unsigned bytes.
;;
;; Parameters:
;;   _al - first operand.
;;   _bl - second operand.
;;
;; Return:
;;   _cx - 16 bits unsigned result.
;;
mulu8:
    lda    <_bl
    sta    <_ch

    cla
    ldy    #$08
@loop:
    asl    A
    rol    <_ch
    bcc    @next
        clc
        adc    <_al
        bcc    @next
            inc    <_ch
@next:
    dey
    bne    @loop

    sta    <_cl
    rts

;;
;; function: divu8
;; Divide 2 unsigned bytes.
;;
;; Parameters:
;;   _al - Dividend.
;;   _bl - Divisor.
;;
;; Return:
;;   _cl - Result (_al / _bl).
;;   _dl - Remainder (_al mod _bl).
;;
divu8:
    lda    <_al
    asl    A
    sta    <_cl
    cla
    ldy    #$08
@loop:
    rol    A
    cmp    <_bl
    bcc    @next
        sbc    <_bl
@next:
    rol    <_cl
    dey
    bne    @loop

    sta   <_dl
    rts

;;
;; function: mulu16
;; Multiply 2 unsigned words.
;;
;; Parameters:
;;   _al - first operand LSB.
;;   _ah - first operand MSB.
;;   _bl - second operand LSB.
;;   _bh - second operand MSB.
;;
;; Return 
;;   _cx - result bytes 0 and 1.
;;   _dx - result bytes 2 and 3.
;;
mulu16:
    stz    <_dx
    stz    <_dx+1

    ldx    #16
@loop:
    lsr    <_ah
    ror    <_al
    bcc    @next 
        lda    <_dx
        clc
        adc    <_bl
        sta    <_dx
        lda    <_dx+1 
        adc    <_bh
@next:
    ror    A 
    sta    <_dx+1 
    ror    <_dx
    ror    <_cx+1 
    ror    <_cx
    dex
    bne    @loop

    rts

;;
;; function: mulu32
;; Multiply 2 unsigned double words.
;;
;; Parameters:
;;   _ax - 
;;   _bx -
;;   _cx - 
;;   _dx -
;;
;; Return 
;;
mulu32:
    ; [todo]
    rts
