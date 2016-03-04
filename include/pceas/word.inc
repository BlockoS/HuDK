; Word-sized value manipulation macros.

; Set stated memory location to zero.
  .macro stwz
    stz    LOW_BYTE \1
    stz    HIGH_BYTE \1
  .endmacro

; Store word-sized value at stated memory location.
  .macro stw
    lda    LOW_BYTE \1
    sta    LOW_BYTE \2
    lda    HIGH_BYTE \1
    sta    HIGH_BYTE \2
  .endmacro

; Add word-sized value plus carry to value at stated memory location.
  .macro adcw
    lda    LOW_BYTE \2
    adc    LOW_BYTE \1
  .if (\# = 3)
    sta    LOW_BYTE \3
  .else
    sta    LOW_BYTE \2
  .endif
    lda    HIGH_BYTE \2
    adc    HIGH_BYTE \1
  .if (\# = 3)
    sta    HIGH_BYTE \3
  .else
    sta    HIGH_BYTE \2
  .endif
  .endmacro

; Add word-sized value to value at stated memory location.
  .macro addw
    clc
  .if (\# = 3)
    adcw   \1, \2, \3
  .else
    adcw   \1, \2
  .endif
  .endmacro

; Substract word-sized value plus carry from value at stated memory location.
  .macro sbcw
    lda    LOW_BYTE \2
    sbc    LOW_BYTE \1
  .if (\# = 3)
    sta    LOW_BYTE \3
  .else
    sta    LOW_BYTE \2
  .endif
    lda    HIGH_BYTE \2
    sbc    HIGH_BYTE \1
  .if (\# = 3)
    sta    HIGH_BYTE \3
  .else
    sta HIGH_BYTE \2
  .endif
  .endmacro

; Substract word-sized value plus carry from value at stated memory location.
  .macro subw
    sec
  .if (\# = 3)
    sbcw   \1, \2, \3
  .else
    sbcw   \1, \2
  .endif
  .endmacro

; Increment a word-sized value at stated memory location.
  .macro incw
    inc    \1
    bne    @x_\@
    inc    \1+1
@x_\@:
  .endmacro

; Decrement a word-sized value at stated memory location.
  .macro decw
    sec
    lda    \1
    sbc    #1
    sta    \1
    lda    \1+1
    sbc    #0
    sta    \1+1
  .endmacro

; Left rotate word-sized value.
  .macro rolw
    rol    \1
    rol    \1+1
  .endmacro

; Left shift word-sized value.
  .macro aslw
    asl    \1
    rol    \1+1
  .endmacro

; Right rotate word-sized value.
  .macro rorw
    ror    \1+1
    ror    \1
  .endmacro

; Right shift word-sized value.
  .macro lsrw
    lsr    \1+1
    ror    \1
  .endmacro

; Negate word-sized value.
  .macro negw
    cla
    sec
    sbc    \1
    sta    \1
    cla
    sbc    \1+1
    sta    \1+1
  .endmacro

; Push word-sized value onto the stack.
  .macro phw
    lda    HIGH_BYTE \1
    pha
    lda    LOW_BYTE \1
    pha
  .endmacro

; Pull word-sized value from the stack.
  .macro plw
    pla
    sta    LOW_BYTE \1
    pla
    sta    HIGH_BYTE \1
  .endmacro

