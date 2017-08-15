
; Convert 3bit R, G, B to 9bit palette entry.
  .macro RGB 
  (((\2 & $07) << 6) | ((\1 & $07) << 3) | (\3 & $07))
  .endmacro
