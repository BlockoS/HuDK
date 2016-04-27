_irq_1:
    bbs1   <irq_m, @user_hook

    pha                     ; save registers
    phx
    phy

    lda    video_reg        ; get VDC status register
    sta    <vdc_sr

@vsync:                     ; vsync interrupt
    bbr5   <vdc_sr, @hsync

    inc    <irq_cnt         ; update irq counter (for wait_vsync)

; [todo]
;    st0    #$05             ; update display control (bg/sp)
;    lda    <vdc_crl         ; vdc control register
;    sta    video_data_l
;    lda    <vdc_crh
;    sta    video_data_h

    bbs5   <irq_m, @l3
        jsr  default_vsync_handler
@l3:
    bbr4   <irq_m, @l4
        jsr  @user_vsync
@l4:

@hsync:
    bbr2   <vdc_sr, @exit
    bbs7   <irq_m,  @l5
        jsr  default_hsync_handler

@l5:
    bbr6 <irq_m, @exit
        jsr  @user_hsync

@exit:
    lda    <vdc_reg         ; restore VDC register index
    sta    video_reg

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

default_vsync_handler:
    ; [todo]
    rts
    
default_hsync_handler:
    ; [todo]
    rts
