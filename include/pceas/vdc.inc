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

