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
        
        st0   #VDC_CR       ; update display control (bg/sp)
        lda   <vdc_crl
        sta   video_data_l

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
    ldx    <vdc_disp
    bne    @l0
        and    #$3f             ; disable display
        sta    video_data_l
        bra    @l1
@l0:
    jsr    scroll_build_display_list
@l1:
    st0    #VDC_BXR             ; scrolling
	stw    bg_x1, video_data
	st0    #VDC_BYR
	stw    bg_y1, video_data

    clock_update
    
    ; [todo] sound
    ; [todo] joypad/mouse

    rts

@default_hsync_handler          ; [todo]
    jmp scroll_hsync_callback
