; $fff8 IRQ1 (VDC) handler
; see VDC Status register to define what really happened
; but mainly bit 2 : HSync (see VREG 6)and bit 5 : VSync
; TODO : look for others interrup
; - about sprites related interrupts (collide and limit)
; - related to DMA
; TODO : registers seems to not be restored when using hooks

_irq_1:
    bbs1   <irq_m, @user_hook

    pha                     ; save registers
    phx
    phy

    lda    video_reg        ; get VDC status register (SR)
    sta    <vdc_sr			; store SR to avoid to call it everytimes
							; we wan't to check what occured

@check_vsync:                     ; vsync interrupt
    bbr5   <vdc_sr, @check_hsync	; check SR's bit 5 : VSync

	; bit5 = 1
    inc    <irq_cnt         ; update irq counter (for wait_vsync)

; [todo]
;    st0    #$05             ; update display control (bg/sp)
;    lda    <vdc_crl         ; vdc control register
;    sta    video_data_l
;    lda    <vdc_crh
;    sta    video_data_h

; TODO why bother with a default vsync handler ?

    bbs5   <irq_m, @l3
	jsr  default_vsync_handler




@l3:
    bbr4   <irq_m, @l4
    jsr  @user_vsync

@l4:

@check_hsync:
    bbr2   <vdc_sr, @exit		
    
    bbs7   <irq_m,  @l5
    jsr  default_hsync_handler

@l5:
    bbr6 <irq_m, @exit
    jsr  @user_hsync

@exit:
; TODO : check spriteoverflow ?


 ; See what BlockOS was trying to do (vdc_reg is a macro!)
 ; vdc_ri ?
 ;   lda    <vdc_reg         ; restore VDC register index
 ;   sta    video_reg

    ply                     ; restore registers
    plx
    pla
    
    rti

; note : jump's rts will jump back to jsr call to @user_xxx
;		so see what AFTER jsr call to know what occurs after this jmp
    
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
