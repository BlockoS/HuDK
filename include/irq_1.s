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
    pha                     ; save registers
    phx
    phy
	
	; check if irq1 is totally handled by a custom handler
    bbr1   <irq_m, @no_hook
	jsr @user_hook
	jmp @end

@no_hook:
    lda    video_reg        ; get VDC status register (SR)
    sta    <vdc_sr			; store SR to avoid to call it everytimes
							; we wan't to check what occured

;;;;;;;;;;;;;;;;
;; HSync
;; first, because time sensitive

@check_hsync:
    bbr2   <vdc_sr, @no_hsync
    
    ; BIT 2 = Hsync
    ; HSync occured
    
    ; TODO : stuff
    ; vsplit ;)
    
    
    ; call user hsync handler
    ; we don't care about vsync, since it can't happen at the same time
    ; TODO : do we also do'nt care about others ?
    bbr6 <irq_m, @no_vsync
    jsr  @user_hsync
    
    jmp @no_vsync


@no_hsync:

	; call user irq1_w/o_hsync handler (!) 
    bbr7   <irq_m,  @check_vsync
    jsr  @no_hsync_handler

	; continue to @check_vsync

;;;;;;;;;;;;;;;;
;; VSYNC

@check_vsync:
    bbr5   <vdc_sr, @no_vsync

	; bit5 = VSync
	; vsync occured
	
	;default vsync HuDK handler
    inc    <irq_cnt         ; update irq counter (for wait_vsync)
    ;todo : reset vsplit

; [todo] default vsync HuDK handler
; TODO 	see	HuC' clock ?

;    st0    #$05             ; update display control (bg/sp)
;    lda    <vdc_crl         ; vdc control register
;    sta    video_data_l
;    lda    <vdc_crh
;    sta    video_data_h


    bbr4   <irq_m, @check_others
    jsr  @user_vsync 
	jmp @check_others

@no_vsync:
	; call user irq1_wo_vsync handler
	bbr5   <irq_m, @check_others
	jsr  @no_vsync_handler
	
	; continue to @check_others
		

@check_others:
; TODO : check spriteoverflow ?
; TODO : check collide ?
; TODO : check dma ?


 ; See what BlockOS was trying to do (vdc_reg is a macro!)
 ; vdc_ri ?
 ;   lda    <vdc_reg         ; restore VDC register index
 ;   sta    video_reg


@end:
    ply                     ; restore registers
    plx
    pla
    
    rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; note : jump's rts will jump back to jsr call to @user_xxx
;		so see what AFTER jsr call to know what occurs after this jmp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; all the IRQ1
@user_hook:
    jmp    [irq1_hook]
    
; only hsync
@user_hsync:
    jmp    [hsync_hook]

; only vsync
@user_vsync:
    jmp    [vsync_hook]

; irq1, no vsync, and perhaps hsync
@no_vsync_handler:
    ; [todo]
    rts

; irq1, no hsync and perhaps vsync
@no_hsync_handler:
    ; [todo]
    rts
