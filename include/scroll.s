;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
SCROLL_MAX_COUNT = 4

    .bss
scroll_top:    ds SCROLL_MAX_COUNT
scroll_bottom: ds SCROLL_MAX_COUNT
scroll_x_lo:   ds SCROLL_MAX_COUNT
scroll_x_hi:   ds SCROLL_MAX_COUNT
scroll_y_lo:   ds SCROLL_MAX_COUNT
scroll_y_hi:   ds SCROLL_MAX_COUNT
scroll_flag:   ds SCROLL_MAX_COUNT

display_list_last:   ds 1
display_list_top:    ds SCROLL_MAX_COUNT+1
display_list_bottom: ds SCROLL_MAX_COUNT+1
display_list_x_lo:   ds SCROLL_MAX_COUNT
display_list_x_hi:   ds SCROLL_MAX_COUNT
display_list_y_lo:   ds SCROLL_MAX_COUNT
display_list_y_hi:   ds SCROLL_MAX_COUNT
display_list_flag:   ds SCROLL_MAX_COUNT
display_list_index:  ds SCROLL_MAX_COUNT+1
display_list_tmp:    ds 3
    
bg_x1: ds 2
bg_y1: ds 2

    .code

;;
;; Macro: scroll_set
;;
;; Initialize a scroll area.
;;
;; Assembly call:
;;   > scroll_set id, top, bottom, x, y, flag
;;
;; Parameters:
;;   id - scroll area id (between 0 and 3).
;;   top - coordinate of the first raster line.
;;   bottom - coordinate of the last raster line.
;;   x - X scroll coordinate.
;;   y - Y scroll coordinate.
;;   flag - VDC flags.
;;
  .macro scroll_set
    lda    \2
    sta    scroll_top+\1
    lda    \3
    sta    scroll_bottom+\1
    lda    LOW_BYTE \4
    sta    scroll_x_lo+\1
    lda    HIGH_BYTE \4
    sta    scroll_x_hi+\1
    lda    LOW_BYTE \5
    sta    scroll_y_lo+\1
    lda    HIGH_BYTE \5
    sta    scroll_y_hi+\1
    lda    \6
    sta    scroll_flag+\1
  .endmacro

  .ifdef HUC
_scroll_set.6:
    ldy    <_dl
    txa
    sta    scroll_flag, Y
    lda    <_al
    sta    scroll_top, Y
    lda    <_ah
    sta    scroll_bottom, Y
    lda    <_bl
    sta    scroll_x_lo, Y
    lda    <_bh
    sta    scroll_x_hi, Y
    lda    <_cl
    sta    scroll_y_lo, Y
    lda    <_ch
    sta    scroll_y_hi, Y
    rts

_scroll_set_rcr.3
    ldy    <_dl
    lda    <_al
    sta    scroll_top, Y
    lda    <_ah
    sta    scroll_bottom, Y
    rts

_scroll_set_coord.3:
    ldy    <_dl
    lda    <_al
    sta    scroll_x_lo, Y
    lda    <_ah
    sta    scroll_x_hi, Y
    lda    <_cl
    sta    scroll_y_lo, Y
    lda    <_ch
    sta    scroll_y_hi, Y
    rts

_scroll_set_flag.2:
    ldy    <_dl
    lda    <_al
    sta    scroll_flag, Y
    rts

  .endif
  
;;
;; function:
;; Computes the hsync scroll display list.
;; The scroll areas will be sorted by ascending raster coordinate.
scroll_build_display_list:
    lda    scroll_flag                      ; quit if all flags are zero
    ora    scroll_flag+1
    ora    scroll_flag+2
    ora    scroll_flag+3
    and    #$01
    bne    @go
        rts
@go:
    clx                                     ; output index
    cly                                     ; input index
@loop:
    lda    scroll_flag, Y                   ; skip if the current scroll area is active
    and    #$01
    beq    @skip

    lda    scroll_top, Y                    ; check if the scroll area is visible
    cmp    vdc_scr_height
    bcs    @skip

    dec    A
    jsr    @check_list ; [todo] bsr? 
    bcs    @skip

    sta    display_list_top, X              ; copy scroll data to display list
    lda    scroll_bottom, Y
    sta    display_list_bottom, X

    lda    scroll_x_lo, Y
    sta    display_list_x_lo, X
    lda    scroll_x_hi, Y
    sta    display_list_x_hi, X

    lda    scroll_y_lo, Y
    sta    display_list_y_lo, X
    lda    scroll_y_hi, Y
    sta    display_list_y_hi, X

    lda    scroll_flag, Y
    and    #$C0
    sta    display_list_flag, Y

    inx
@skip:
    iny
    cpy    #SCROLL_MAX_COUNT
    bcc    @loop

    lda    vdc_scr_height                  ; setup display list
    sta    display_list_top, X
    sta    display_list_bottom, X
    inx
    stx    display_list_last

    cly
@l0:
    tya
    sta    display_list_index, Y
    iny
    dex
    bne    @l0
    
    lda    display_list_last
    sta    display_list_tmp
    bra    @l4
@l1:
    stz    display_list_tmp+1
    ldy    #1
@l2:                                        ; sort display_list (bubble sort)
    ldx    display_list_index-1, Y
    lda    display_list_top, X
    inc    A
    sta    display_list_tmp+2
    ldx    display_list_index, Y
    lda    display_list_top, X
    inc    A
    cmp    display_list_tmp+2
    bcs    @l3
        lda    display_list_index-1, Y
        sta    display_list_index, Y
        txa
        sta    display_list_index-1, Y
        inc    display_list_tmp+1
@l3:
    iny
    cpy    display_list_tmp
    bcc    @l2
    
    lda    display_list_tmp+1
    beq    @end
    dec    display_list_tmp
    lda    display_list_tmp
@l4:
    cmp    #2
    bcs    @l1
@end:
    lda    display_list_last
    clc
    adc    #$fe
    ; The display list now contains the list of raster area and scroll coordinates sorted by the top raster coordinate<
@r3:
    smb7   <vdc_crl                     ; enable background (tiles) display
    lda    #$FF                             
    sta    display_list_last
    ldx    display_list_index
    ldy    display_list_top,X
    cpy    #$FF
    bne    __rcr5
        ldy   display_list_x_lo,X
        sty   bg_x1
        ldy   display_list_x_hi,X
        sty   bg_x1+1
        ldy   display_list_y_lo,X
        sty   bg_y1
        ldy   display_list_y_hi,X
        sty   bg_y1+1
        stz   display_list_last
        bra   __rcr5
@check_list:                                ; check if there is already a scroll area starting at the scanline
    phx
@check_loop:
    dex
    bmi    @ok
    cmp    scroll_top, X
    bne    @check_loop
@collide:
    plx
    sec
    rts
@ok:
    plx
    clc
    rts
__rcr_set:                                  ; set scanline counter
    iny
    sty    display_list_last                ; process next scroll area
    lda    display_list_index, Y
    tay
    lda    display_list_top, Y              ; 
    cmp    vdc_scr_height
    bcs    __rcr6
    cmp    display_list_bottom,X            ; 
    bcc    __rcr5

    lda    display_list_bottom, X
__rcr4:
    dec    A
    pha                                     ; save current raster bottom coordinate
    lda    #$F0                             ; disable display list entry
    sta    display_list_bottom, X
    stz    display_list_flag, X
    dec    display_list_last
    pla
    ; --
__rcr5:
    st0    #VDC_RCR                         ; set the next rcr to the next top coordinate
    clc
    adc    #64
    sta    video_data_l
    cla
    adc    #0
    sta    video_data_h
    st0    #VDC_CR
    lda    <vdc_crl
    ora    #(VDC_CR_HBLANK_ENABLE & $00ff) ; enable hsync
    sta    <vdc_crl
    sta    video_data_l
    rts
__rcr6:
    lda    display_list_bottom, X
    cmp    vdc_scr_height
    bcc    __rcr4
    st0    #VDC_CR                              ; the bottom of the scroll area is not out of the screen height
    lda    <vdc_crl
    and    #((~VDC_CR_HBLANK_ENABLE) & $00ff)  ; disable hsync
    sta    <vdc_crl
    sta    video_data_l
    rts

;; 
;; function: scroll_hsync_callback
;; Set scroll coordinates with the current scroll display list entry, and program the next hsync callback.
;; 
scroll_hsync_callback:
    ldy    display_list_last
    bpl    @r1
    
    lda    <vdc_crl
    and    #$3F                                 ; disable background and sprite display
    sta    <vdc_crl
    stz    display_list_last
    ldx    display_list_index
    lda    display_list_top, X
    bra    __rcr5
    
@r1:
    ldx    display_list_index, Y
    lda    <vdc_crl
    and    #$3F
    ora    display_list_flag, X                 ; use the bg/sp enable flags from the scroll area flag
    sta    <vdc_crl
    
    jsr    __rcr_set                            ; program next hsync
    
    lda    display_list_top, X
    cmp    #$FF
    beq    @out
        st0    #VDC_BXR                         ; set scroll coordinates
        lda    display_list_x_lo, X
        ldy    display_list_x_hi, X
        sta    video_data_l
        sty    video_data_h
        st0    #VDC_BYR
        lda    display_list_y_lo, X
        ldy    display_list_y_hi, X
        sec
        sbc    #1
        bcs    @r2
            dey
@r2:
        sta    video_data_l
        sty    video_data_h
@out:
    rts
