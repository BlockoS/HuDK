; Store a byte at stated memory location
  .macro stb
      lda    \1
      sta    \2
  .endmacro

; Negate value.
  .macro neg
      lda    \1
      eor    #$ff
      inc    A
      sta    \1
  .endmacro
