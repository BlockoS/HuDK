;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; $fff8 IRQ1 (VDC) handler
; see VDC Status register to define what really happened
; but mainly bit 2 : HSync (see VREG 6)and bit 5 : VSync
; TODO : look for others interrup
; - about sprites related interrupts (collide and limit)
; - related to DMA

_irq_1:
    ; check if irq1 is totally handled by a custom handler
    bbs1   <irq_m, @user_hook

    pha
    phx
    phy

    lda    video_reg        ; get VDC status register (SR)
    sta    <vdc_sr          ; store SR to avoid to call it everytimes
                            ; we wan't to check what occured
@check_hsync:
    bbr2   <vdc_sr, @check_vsync
        bbr6   <irq_m, @default_hsync
            bsr    @user_hsync
            bra    @check_others
@default_hsync:
            bsr    @default_hsync_handler 
            bra    @check_others
@check_vsync:
    bbr5   <vdc_sr, @check_others
        inc    <irq_cnt         ; update irq counter (for wait_vsync)
        
;[todo]       st0   #VDC_CR       ; update display control (bg/sp)
;[todo]        lda   <vdc_crl
;[todo]        sta   video_data_l

        bbr4   <irq_m, @default_vsync
            bsr    @user_vsync 
            bra    @check_others
@default_vsync:
            bsr    @default_vsync_handler
@check_others:
    ; [todo] sprite overflow, dma transfer end, sprite 0 collision
@end:
    ply                     ; restore registers
    plx
    pla
    rti

@user_hook:
    jmp    [irq1_hook]
    
@user_hsync:
    jmp    [hsync_hook]

@user_vsync:
    jmp    [vsync_hook]

@default_vsync_handler:
    jsr    rcr_init
    st0    #VDC_BXR             ; scrolling
	stw    bg_x1, video_data
	st0    #VDC_BYR
	stw    bg_y1, video_data

    ; [todo] clock
    ; [todo] sound
    ; [todo] joypad/mouse

    rts

@default_hsync_handler:
    ldy    display_list_last
    bpl    .r1
    ; --
;[todo]    lda    <vdc_crl
;[todo]    and    #$3F
;[todo]    sta    <vdc_crl
    stz    display_list_last
    ldx    display_list_index
    lda    display_list_top, X
    jmp    rcr5
    ; --
.r1:
    ldx    display_list_index, Y
;    lda    <vdc_crl
;    and    #$3F
;    ora    display_list_flag, X
;    sta    <vdc_crl
    ; --
    jsr    rcr_set
    ; --
    lda    display_list_top, X
    cmp    #$FF
    beq    .out
    ; --
    st0    #VDC_BXR
    lda    display_list_x_lo, X
    ldy    display_list_x_hi, X
    sta    video_data_l
    sty    video_data_h
    st0    #VDC_BYR
    lda    display_list_y_lo, X
    ldy    display_list_x_hi, X
    sec
    sbc    #1
    bcs    .r2
    dey
.r2:
    sta    video_data_l
    sty    video_data_h
.out:
    rts
