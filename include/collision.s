;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .zp
collision_quad.xmin .ds 4
collision_quad.ymin .ds 4
collision_quad.xmax .ds 4
collision_quad.ymax .ds 4

    .code
;;
;; function: collision_eval
;; Check if 2 axis aligned quads intersects.
;;
;; Parameters:
;;   collision_quad.xmin - X coordinate of min vertex of the 1st axis aligned aligned quad.
;;   collision_quad.xmin - Y coordinate of min vertex of the 1st axis aligned aligned quad.
;;   collision_quad.xmax - X coordinate of max vertex of the 1st axis aligned aligned quad.
;;   collision_quad.xmax - Y coordinate of max vertex of the 1st axis aligned aligned quad.
;;   collision_quad.xmin+2 - X coordinate of min vertex of the 2nd axis aligned aligned quad.
;;   collision_quad.ymin+2 - Y coordinate of min vertex of the 2nd axis aligned aligned quad.
;;   collision_quad.xmax+2 - X coordinate of max vertex of the 2nd axis aligned aligned quad
;;   collision_quad.ymax+2 - Y coordinate of max vertex of the 2nd axis aligned aligned quad
;;
;; Return:
;;   Carry flag - Set if the 2 axis aligned quads intersect.
;;
collision_eval:
    ; xmax0 < xmin1 => NOK
    lda    <collision_quad.xmax+1
    cmp    <collision_quad.xmin+3
    bcc    @nop
    bne    @l0
    lda    <collision_quad.xmax
    cmp    <collision_quad.xmin+2
    bcc    @nop
@l0:
    ; xmax1 < xmin0 => NOK
    lda    <collision_quad.xmax+3
    cmp    <collision_quad.xmin+1
    bcc    @nop
    bne    @l1
    lda    <collision_quad.xmax+2
    cmp    <collision_quad.xmin
    bcc    @nop
@l1:
    ; ymax0 < ymin1 => NOK
    lda    <collision_quad.ymax+1
    cmp    <collision_quad.ymin+3
    bcc    @nop
    bne    @l2
    lda    <collision_quad.ymax
    cmp    <collision_quad.ymin+2
    bcc    @nop
@l2:
    ; ymax1 < ymin0 => NOK
    lda    <collision_quad.ymax+3
    cmp    <collision_quad.ymin+1
    bcc    @nop
    bne    @l3
    lda    <collision_quad.ymax+2
    cmp    <collision_quad.ymin
    bcc    @nop
@l3:
    rts
@nop:
    rts