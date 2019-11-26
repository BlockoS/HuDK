;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

    .zp
_sprite.tmp .ds 2

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

intersect_q0q1:
    ; x_min1
    lda    sprite.shape, Y
    and    #$7f
    clc
    adc    sprite.x, Y
    sta    <_sprite.tmp
    cla
    adc    sprite.x+64, Y
    sta    <_sprite.tmp+1

    ; x_max0
    lda    sprite.shape+64, X
    clc
    adc    sprite.x, X
    pha
    cla
    adc    sprite.x+64, X
    ; xmax0 < xmin1 => NOK
    cmp    <_sprite.tmp+1
    bcc    @nop
    bne    @l0
    pla
    cmp    <_sprite.tmp
    bcc    @nop
@l0:
    ; x_min0
    lda    sprite.shape, X
    and    #$7f
    clc
    adc    sprite.x, X
    sta    <_sprite.tmp
    cla
    adc    sprite.x+64, X
    sta    <_sprite.tmp+1

    ; x_max1
    lda    sprite.shape+64, Y
    clc
    adc    sprite.x, Y
    pha
    cla
    adc    sprite.x+64, Y
    ; xmax1 < xmin0 => NOK
    cmp    <_sprite.tmp+1
    bcc    @nop
    bne    @l1
    pla
    cmp    <_sprite.tmp
    bcc    @nop
@l1:
    ; y_min1
    lda    sprite.shape+192, Y
    clc
    adc    sprite.y, Y
    sta    <_sprite.tmp
    cla
    adc    sprite.y+64, Y
    sta    <_sprite.tmp+1

    ; y_max0
    lda    sprite.shape+192, X
    clc
    adc    sprite.y, X
    pha
    cla
    adc    sprite.y+64, X
    ; ymax0 < ymin1 => NOK
    cmp    <_sprite.tmp+1
    bcc    @nop
    bne    @l2
    pla
    cmp    <_sprite.tmp
    bcc    @nop
@l2:
    ; y_min0
    lda    sprite.shape+128, X
    clc
    adc    sprite.y, X
    sta    <_sprite.tmp
    cla
    adc    sprite.y+64, X
    sta    <_sprite.tmp+1

    ; ymax1
    lda    sprite.shape+192, Y
    clc
    adc    sprite.y, Y
    pha
    cla
    adc    sprite.y+64, Y
    ; ymax1 < ymin0 => NOK
    cmp    <_sprite.tmp+1
    bcc    @nop
    bne    @l3
    pla
    cmp    <_sprite.tmp
    bcc    @nop
@l3:
    rts
@nop:
    rts