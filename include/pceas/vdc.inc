
  .bss
vdc_bat_width  .ds 2
vdc_bat_height .ds 1
vdc_bat_hmask  .ds 1
vdc_bat_vmask  .ds 1

  .code

; Compute the value of the HSR register for a given horizontal screen
; resolution.
  .macro VDC_HSR_db
    .if (\1 < 268)
      ; low resolution (standard)
      .db $02                   ; Horizontal Display Start (HDS)
      .db (18 - (\1 / 16))      ; Horizontal Sync Width (HWS)
    .else
      .if (\1 < 356)
        ; high resolution
        .db $03
        .db (25 - (\1 / 16))
      .else
        ; very high resolution
        .db $05
        .db (42 - (\1 / 16))
      .endif
    .endif
  .endmacro

; Compute the value of the HDR register for a given horizontal screen
; resolution.
  .macro VDC_HDR_db
      .db ((\1 / 8) - 1)                        ; Horizontal Display Width (HDW)
    .if (\1 < 268)
      ; low resolution (standard)
      .db (38 - ((18 - (\1 / 16)) + (\1 / 8)))  ; Horizontal Display End (HDE)
    .else
      .if (\1 < 356)
        ; high resolution
        .db (51 - ((25 - (\1 / 16)) + (\1 / 8)))
      .else
        ; very high resolution
        .db (82 - ((42 - (\1 / 16)) + (\1 / 8)))
      .endif
    .endif
  .endmacro

; Initialize VDC register.
  .macro vdc_reg
    lda    \1
    ; [todo] zeropage copy of the vdc register
    .if (\?1 = ARG_IMMEDIATE)
      st0    \1
    .else
      sta    video_reg
    .endif
    sta    <vdc_ri
  .endmacro

; Set VDC register from value in A.
  .macro vdc_setreg
    sta    video_reg
    sta    <vdc_ri
  .endmacro

; Set VDC data.
  .macro vdc_data
  .if (\# = 1)
    lda    LOW_BYTE \1
    sta    video_data_l
    lda    HIGH_BYTE \1
    sta    video_data_h
  .else
    lda    \1
    sta    video_data_l
    lda    \2
    sta    video_data_h
  .endif
  .endmacro

; Set VDC data LSB.
  .macro vdc_data_l
    sta    video_data_l
  .endm

; Set VDC data MSB.
  .macro vdc_data_h
    sta    video_data_h
  .endm

; Wait for vsync to occur.
  .macro vdc_wait_vsync
    stz    <irq_cnt
@wait_vsync\@:
    lda    <irq_cnt
    beq    @wait_vsync\@
  .endm