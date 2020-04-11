;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

  .bss
sprite_attribute: ds 128
sprite_pattern: ds 128
sprite_x: ds 128
sprite_y: ds 128

    .code
;;
;; function: spr_show
;; Show sprite.  
;;
;; Parameters:
;;  Y - sprite index
;;
spr_show:
    ; move sprite to the visible area.
    lda    sprite_x+64, Y
    and    #$01
    sta    sprite_x+64, Y
    rts

;;
;; function: spr_hide
;; Hide sprite.
;;
;; Parameters:
;;  Y - sprite index
;;
spr_hide:
    ; move sprite out of the visible area.
    lda    sprite_x+64, Y
    ora    #$02
    sta    sprite_x+64, Y
    rts

;;
;; function: spr_x
;; Update sprite X coordinate.
;;
;; Parameters:
;;  Y - sprite index
;;  A - X coordinate
;;
spr_x:
    clc
    adc    #32
    sta    sprite_x, Y
    sax
    adc    #$00
    sta    sprite_x+64, Y
    rts

;;
;; function: spr_y
;; Update sprite Y coordinate.
;;
;; Parameters:
;;  Y - sprite index
;;  A - Y coordinate
;;
spr_y:
    clc
    adc    #64
    sta    sprite_y, Y
    sax
    adc    #$00
    sta    sprite_y+64, Y
    rts

;;
;; function: spr_pattern
;; Set sprite pattern address in VRAM.
;;
;; Parameters:
;;  Y - sprite index
;;  X - MSB of the sprite pattern address in VRAM
;;  A - LSB of the sprite pattern address in VRAM
spr_pattern:
    stx    <_ah
    asl    A
    rol    <_ah
    rol    A
    rol    <_ah
    rol    A
    rol    <_ah
    rol    A
    and    #$07
    sta    sprite_pattern+64,Y
    lda    <_ah
    sta    sprite_pattern, Y
    rts

;;
;; function: spr_pal
;; Set sprite palette index.
;;
;; Parameters:
;;  Y - sprite index
;;  A - palette index
;;
spr_pal:
    and    #$0f
    sta    sprite_attribute, Y
    rts

;;
;; function: spr_pri
;; Set sprite priority.
;;   - 1 foreground
;;   - 0 background
;;
;; Parameters:
;;  Y - sprite index
;;  A - sprite priority
;;
spr_pri:
    tax
    lda    sprite_attribute, Y
    and    #$7f
    cpx    #$00
    beq    @l0
        ora    #$80
@l0:
    sta    sprite_attribute, Y
    rts

;;
;; function: spr_ctrl
;; Set sprite control flag.
;; 
;; Parameters:
;;    Y - sprite index
;;  _al - Mask of the bits to change (eg VDC_SPRITE_VERTICAL_FLIP_MASK, VDC_SPRITE_HORIZONTAL_FLIP_MASK, VDC_SPRITE_WIDTH_MASK, VDC_SPRITE_HEIGHT_MASK, VDC_SPRITE_PRIORITY_MASK, VDC_SPRITE_PALETTE_MASK)
;;    A - New bits values. 
spr_ctrl:
    and    <_al
	sta    <_ah
	lda    <_al
	eor    #$FF
    and    sprite_attribute+64, Y
	ora    <_ah
    sta    sprite_attribute+64, Y
	rts

;;
;; function: spr_update_satb
;; Copy the local sprite attribute table to VRAM.
;;
spr_update_satb:
    vdc_reg #VDC_MAWR
    vdc_data <sprite_vram_base
    vdc_reg #VDC_DATA
    cly
@loop:
        lda    sprite_y, Y
        sta    video_data_l
        lda    sprite_y+64, Y
        sta    video_data_h

        lda    sprite_x, Y
        sta    video_data_l
        lda    sprite_x+64, Y
        sta    video_data_h

        lda    sprite_pattern, Y
        sta    video_data_l
        lda    sprite_pattern+64, Y
        sta    video_data_h

        lda    sprite_attribute, Y
        sta    video_data_l
        lda    sprite_attribute+64, Y
        sta    video_data_h

        iny
        cpy    #64
        bne    @loop
