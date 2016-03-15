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
;; Return 
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

