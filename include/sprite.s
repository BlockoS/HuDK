;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

    .zp
_xmin .ds 4
_ymin .ds 4
_xmax .ds 4
_ymax .ds 4

    .bss
sprite.attribute .ds 128
sprite.pattern   .ds 128
sprite.x         .ds 128
sprite.y         .ds 128
sprite.shape     .ds 256

    .code

; [todo] set sprite pattern
; [todo] set sprite attribute (width/height/flip x/ flip y/ pal)
; [todo] set sprite position
; [todo] set sprite collision shape
; [todo] disc/quad intersection test
;       xc = max(xa,min(xb,xa+w0))
;       yc = max(ya,min(yb,ya+w0))
;       sqr(xb-xc) + sqr(yb-yc) <= sqr(r1)
; [todo] disc/disc intersection test
;       sqr(x0-x1) + sqr(y0-y1) <= sqr(r0+r1)

init_q0:
    lda    sprite.x, X
    sta    <_xmin

    lda    sprite.x+64, X
    sta    <_xmin+1

    lda    sprite.y, X
    sta    <_ymin

    lda    sprite.y+64, X
    sta    <_ymin+1

    ; x_max[0]
    lda    sprite.shape+64, X
    clc
    adc    <_xmin
    sta    <_xmax
    cla
    adc    <_xmin+1
    sta    <_xmax+1

    ; x_min[0]
    lda    sprite.shape, X
    and    #$7f
    clc
    adc    <_xmin
    sta    <_xmin
    cla
    adc    <_xmin+1
    sta    <_xmin+1

    ; y_max[0]
    lda    sprite.shape+192, X
    clc
    adc    <_ymin
    sta    <_ymax
    cla
    adc    <_ymin+1
    sta    <_ymax+1

    ; y_min[0]
    lda    sprite.shape+128, X
    clc
    adc    <_ymin
    sta    <_ymin
    cla
    adc    <_ymin+1
    sta    <_ymin+1

    rts

init_q1:
    lda    sprite.x, Y
    sta    <_xmin+2

    lda    sprite.x+64, Y
    sta    <_xmin+3

    lda    sprite.y, Y
    sta    <_ymin+2

    lda    sprite.y+64, Y
    sta    <_ymin+3

    ; x_max[1]
    lda    sprite.shape+64, Y
    clc
    adc    <_xmin+2
    sta    <_xmax+2
    cla
    adc    <_xmin+3
    sta    <_xmax+3

    ; x_min[1]
    lda    sprite.shape, Y
    and    #$7f
    clc
    adc    <_xmin+2
    sta    <_xmin+2
    cla
    adc    <_xmin+3
    sta    <_xmin+3

    ; y_max[1]
    lda    sprite.shape+192, Y
    clc
    adc    <_ymin+2
    sta    <_ymax+2
    cla
    adc    <_ymin+3
    sta    <_ymax+3

    ; y_min[1]
    lda    sprite.shape+128, Y
    clc
    adc    <_ymin+2
    sta    <_ymin+2
    cla
    adc    <_ymin+3
    sta    <_ymin+3

    rts

intersect_q0q1:
    ; xmax0 < xmin1 => NOK
    lda    <_xmax+1
    cmp    <_xmin+3
    bcc    @nop
    bne    @l0
    lda    <_xmax
    cmp    <_xmin+2
    bcc    @nop
@l0:
    ; xmax1 < xmin0 => NOK
    lda    <_xmax+3
    cmp    <_xmin+1
    bcc    @nop
    bne    @l1
    lda    <_xmax+2
    cmp    <_xmin
    bcc    @nop
@l1:    
    ; ymax0 < ymin1 => NOK
    lda    <_ymax+1
    cmp    <_ymin+3
    bcc    @nop
    bne    @l2
    lda    <_ymax
    cmp    <_ymin+2
    bcc    @nop
@l2:
    ; ymax1 < ymin0 => NOK
    lda    <_ymax+3
    cmp    <_ymin+1
    bcc    @nop
    bne    @l3
    lda    <_ymax+2
    cmp    <_ymin
    bcc    @nop
@l3:
    rts
@nop:
    rts