;;
;; Title: Sprite routines.
;;
    .zp
sprite_vram_base .ds 2

    .code
;;
;; function: sprite_set_base
;; Set the VRAM address of the sprite table.
;;
;; Parameters:
;;   _si - sprite table VRAM address.
;;
sprite_set_base:
    vdc_reg #VDC_SATB_SRC 

    lda    <_si
    sta    <sprite_vram_base
    sta    video_data_l

    lda    <_si+1
    sta    <sprite_vram_base+1
    sta    video_data_h

    rts
