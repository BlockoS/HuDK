; Compute the value of the HSR register for a given horizontal screen
; resolution.
  .macro VDC_HSR_db xres
    .if (xres < 268)
      ; low resolution (standard)
      .byte $02					    ; Horizontal Display Start (HDS)
      .byte (18 - (xres / 16))      ; Horizontal Sync Width (HWS)
    .elsif (xres < 356)
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
  .macro VDC_HDR_db
      .byte ((xres / 8) - 1)                          ; HDW
    .if (\1 < 268)
      ; low resolution (standard)
      .byte (38 - ((18 - (xres / 16)) + (xres / 8)))  ; HDE
    .elsif (\1 < 356)
      ; high resolution
      .byte (51 - ((25 - (xres / 16)) + (xres / 8)))
    .else
      ; very high resolution
      .byte (82 - ((42 - (xres / 16)) + (xres / 8)))
    .endif
  .endmacro

