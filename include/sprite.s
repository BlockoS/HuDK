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

;;
;; function: sprite_set
;; Compute start address of a given sprite entry.
;;
;; Parameters:
;;   X - sprite number
;;
;; Returns:
;;   _si - sprite VRAM address
;;
sprite_set:
    ; current sprite address = sprite_vram_base + (#entry * 8)
    stz    <_si+1
    
    txa
    asl    A
    asl    A
    asl    A
    rol    <_si+1
    
    clc
    adc    <sprite_vram_base
    sta    <_si
    
    lda    <sprite_vram_base
    adc    <_si+1
    sta    <_si+1

    rts

;;
;; function: sprite_y
;; Set sprite Y coordinate. 
;;
;; Parameters:
;;   A - Y coordinate MSB
;;   X - Y coordinate LSB
;;
sprite_y:
    pha
    vdc_reg  #VDC_MAWR
    vdc_data <_si
    
    stx    video_data_l
    pla
    sta    video_data_h
    
    rts

;;
;; function: sprite_x
;; Set sprite X coordinate. 
;;
;; Parameters:
;;   A - X coordinate MSB
;;   X - X coordinate LSB
;;
sprite_x:
    pha
    vdc_reg #VDC_MAWR
    addw    #$01, <_si, video_data
    
    stx    video_data_l
    pla
    sta    video_data_h
    
    rts

;;
;; function: sprite_hide
;; Hide current sprite. 
;;
sprite_hide:
    vdc_reg #VDC_MARR 
    vdc_data <_si

    vdc_reg  #VDC_MAWR
    vdc_data <_si
    
    lda    video_data_l
    sta    video_data_l
    
    lda    video_data_h
    ora    #$02 
    sta    video_data_h
    
    rts

;;
;; function: sprite_show
;; Show current sprite. 
;;
sprite_show:
    vdc_reg #VDC_MARR 
    vdc_data <_si

    vdc_reg  #VDC_MAWR
    vdc_data <_si
    
    lda    video_data_l
    sta    video_data_l
    
    lda    video_data_h
    and    #$01
    sta    video_data_h
    
    rts
