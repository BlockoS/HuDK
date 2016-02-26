
; Convert 3bit R, G, B to 9bit palette entry.
  .macro RGB_dw
    .dw (((\2 & $03) << 6) | ((\1 & $03) << 3) | (\3 & $03))
  .endmacro
