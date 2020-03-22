;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

.define videoport a:$0000
.define video_reg a:$0000
.define video_data a:$0002
.define video_data_l a:$0002
.define video_data_h a:$0003

; Compute the value of the HSR register for a given horizontal screen
; resolution.
  .macro VDC_HSR_db xres
    .if (xres < 268)
      ; low resolution (standard)
      .byte $02					    ; Horizontal Display Start (HDS)
      .byte (18 - (xres / 16))      ; Horizontal Sync Width (HWS)
    .elseif (xres < 356)
      ; high resolution
      .byte $03
      .byte (25 - (xres / 16))
    .else
      ; very high resolution
      .byte $05
      .byte (42 - (xres / 16))
    .endif
  .endmacro

; Compute the value of the HDR register for a given horizontal screen
; resolution.
  .macro VDC_HDR_db xres
      .byte ((xres / 8) - 1)                          ; HDW
    .if (xres < 268)
      ; low resolution (standard)
      .byte (38 - ((18 - (xres / 16)) + (xres / 8)))  ; HDE
    .elseif (xres < 356)
      ; high resolution
      .byte (51 - ((25 - (xres / 16)) + (xres / 8)))
    .else
      ; very high resolution
      .byte (82 - ((42 - (xres / 16)) + (xres / 8)))
    .endif
  .endmacro

; Initialize VDC register.
  .macro vdc_reg reg
    lda   reg
    ; [todo] zeropage copy of the vdc register
    .if (.match (.left (1, {reg}), #))
      st0    reg
    .else
      sta    video_reg
    .endif
    sta    <vdc_ri
  .endmacro

; Set VDC register from value in A.
  .macro vdc_setreg
    sta    a:video_reg
    sta    <vdc_ri
  .endmacro

; Set VDC data.
  .macro vdc_data dl, dh
  .if .paramcount = 1
    stw dl, video_data
  .else
    lda dl
    sta video_data_l
    lda dh
    sta video_data_l
  .endif
  .endmacro

; Wait for vsync to occur.
  .macro vdc_wait_vsync
    stz    <irq_cnt
:   lda    <irq_cnt
    beq    :-
  .endmacro

; Set VDC control registers 
  .macro vdc_set_cr flags
    vdc_reg #VDC_CR
    __low  lda, flags
    sta    <vdc_crl
    sta    video_data_l
    __high lda, flags
    sta    <vdc_crl+1
    sta    video_data_h 
  .endmacro