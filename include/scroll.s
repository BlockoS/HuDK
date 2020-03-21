;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
SCROLL_MAX_COUNT = 4

    .bss
scroll_top    .ds SCROLL_MAX_COUNT
scroll_bottom .ds SCROLL_MAX_COUNT
scroll_x_lo   .ds SCROLL_MAX_COUNT
scroll_x_hi   .ds SCROLL_MAX_COUNT
scroll_y_lo   .ds SCROLL_MAX_COUNT
scroll_y_hi   .ds SCROLL_MAX_COUNT
scroll_flag   .ds SCROLL_MAX_COUNT


display_list_last   .ds 1
display_list_top    .ds SCROLL_MAX_COUNT+1
display_list_bottom .ds SCROLL_MAX_COUNT+1
display_list_x_lo   .ds SCROLL_MAX_COUNT
display_list_x_hi   .ds SCROLL_MAX_COUNT
display_list_y_lo   .ds SCROLL_MAX_COUNT
display_list_y_hi   .ds SCROLL_MAX_COUNT
display_list_flag   .ds SCROLL_MAX_COUNT
display_list_index  .ds SCROLL_MAX_COUNT+1
display_list_tmp    .ds 3
    
bg_x1 .ds 2
bg_y1 .ds 2

    .code
scroll_build_display_list:
    lda    scroll_flag                      ; quit if all flags are zero
    ora    scroll_flag+1
    ora    scroll_flag+2
    ora    scroll_flag+3
    and    #$01
    bne    @go
        clc
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

    lda    vdc_scr_height                   ; setup display list
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
@l2:                                    ; sort display_list (bubble sort)
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
    rts

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


rcr_init:
    jsr    scroll_build_display_list
    bcs    @r3
        rts
@r3:
    smb    #7, <vdc_crl
    lda    #$FF
    sta    display_list_last
    ldx    display_list_index
    ldy    display_list_top,X
    cpy    #$FF
    bne    rcr5
        ldy   display_list_x_lo,X
        sty   bg_x1
        ldy   display_list_x_hi,X
        sty   bg_x1+1
        ldy   display_list_y_lo,X
        sty   bg_y1
        ldy   display_list_y_hi,X
        sty   bg_y1+1
        stz   display_list_last
        bra   rcr5

; ----
; program scanline interrupt
;
rcr_set:
    iny
    sty    display_list_last
    lda    display_list_index, Y
    tay
    lda    display_list_top, Y
    cmp    vdc_scr_height
    bcs    rcr6
    cmp    display_list_bottom,X
    bcc    rcr5

    lda    display_list_bottom, X
rcr4:
    dec    A
    pha
    lda    #$F0
    sta    display_list_bottom, X
    stz    display_list_flag, X
    dec    display_list_last
    pla
    ; --

rcr5:
    st0    #VDC_RCR          ; set scanline counter
    clc
    adc    #64
    sta    video_data_l
    cla
    adc    #0
    sta    video_data_h
    bra   __rcr_on

rcr6:
    lda    display_list_bottom, X
    cmp    vdc_scr_height
    bcc    rcr4
        bra    __rcr_off

_rcr_on:
    lda    #VDC_CR
    sta    <vdc_ri
__rcr_on:
; [todo]    st0    #VDC_CR
; [todo]    lda    <vdc_crl
; [todo]    ora    #$04
; [todo]    sta    <vdc_crl
; [todo]    sta    video_data_l
    rts

_rcr_off:
    lda    #VDC_CR
    sta    <vdc_ri
__rcr_off:
    rts
; [todo]    st0    #VDC_CR  
; [todo]    lda    <vdc_crl
; [todo]    and    #$FB
; [todo]    sta    <vdc_crl
; [todo]    sta    video_data_l
; [todo]    rts
