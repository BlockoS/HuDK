
; Convert 3bit R, G, B to 9bit palette entry.
  .macro RGB_dw r, g, b
    .word (((g & $03) << 6) | ((r & $03) << 3) | (b & $03))
  .endmacro
