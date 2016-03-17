;;
;; Title: Sprite routines.
;;
    .zp
sprite_vram_ptr  .ds 1
sprite_vram_base .ds 1

    .code
;;
;; function: sprite_set_base
;; Set the VRAM address of the sprite table.
;;
;; Parameters:
;;   X - MSB of the VRAM address of the sprite table.
;;
sprite_set_base:
    vdc_reg #VDC_SATB_SRC 

    st1    #$00
    stx    <sprite_vram_base
    stx    video_data_h

    rts

;;
;; function: sprite_select
;; Compute the VRAM address of a given sprite.
;;
;; Parameters:
;;   X - Sprite number
;;
sprite_select:
    vdc_reg #VDC_MAWR
 
    txa
    asl    A
    asl    A
    sta    <sprite_vram_ptr
    sta    video_data_l
    
    lda    <sprite_vram_base 
    sta    video_data_h
 
    rts

;;
;; function: sprite_x
;; Set current sprite X coordinate.
;;
;; Parameters:
;;   A - LSB of the sprite X coordinate
;;   X - MSB of the sprite X coordinate
;;
sprite_x:
    tay

    vdc_reg #VDC_MAWR

    lda    <sprite_vram_ptr
    inc    A
    sta    video_data_l
    lda    <sprite_vram_base
    sta    video_data_h

    vdc_reg #VDC_DATA
    sty    video_data_l
    stx    video_data_h
 
    rts

;;
;; function: sprite_y
;; Set current sprite Y coordinate.
;;
;; Parameters:
;;   A - LSB of the sprite Y coordinate
;;   X - MSB of the sprite Y coordinate
;;
sprite_y:
    tay

    vdc_reg #VDC_MAWR

    lda    <sprite_vram_ptr
    sta    video_data_l
    lda    <sprite_vram_base
    sta    video_data_h

    vdc_reg #VDC_DATA
    sty    video_data_l
    stx    video_data_h
 
    rts

; [todo]
sprite_show:
    rts

; [todo]
sprite_hide:
    rts

; [todo]
sprite_pattern:
    rts

; [todo]
sprite_palette:
    rts

; [todo]
sprite_ctrl:
    rts

; [todo]
sprite_set:
    rts

