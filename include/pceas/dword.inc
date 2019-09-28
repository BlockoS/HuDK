;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

; 32 bits value manipulation macros.

; Set stated memory location to zero.
  .macro stdwz
    stz    \1
    stz    \1+1
    stz    \1+2
    stz    \1+3
  .endmacro

; Store 32 bits value at stated memory location.
  .macro stdw
    lda    \1
    sta    \2
    lda    \1+1
    sta    \2+1
    lda    \1+2
    sta    \2+2    
    lda    \1+3
    sta    \2+3
  .endmacro

; Add 32 bits value plus carry to value at stated memory location.
  .macro adcdw
    lda    \2
    adc    \1
  .if (\# = 3)
    sta    \3
  .else
    sta    \2
  .endif

  .macro adcdw
    lda    \2+1
    adc    \1+1
  .if (\# = 3)
    sta    \3+1
  .else
    sta    \2+1
  .endif

  .macro adcdw
    lda    \2+2
    adc    \1+2
  .if (\# = 3)
    sta    \3+2
  .else
    sta    \2+2
  .endif

  .macro adcdw
    lda    \2+3
    adc    \1+3
  .if (\# = 3)
    sta    \3+3
  .else
    sta    \2+3
  .endif

  .endmacro

; Add 32 bits value to value at stated memory location.
  .macro adddw
    clc
  .if (\# = 3)
    adcdw  \1, \2, \3
  .else
    adcdw  \1, \2
  .endif
  .endmacro

; Substract 32 bits value plus carry from value at stated memory location.
  .macro sbcdw
    lda    LOW_BYTE \2
    sbc    LOW_BYTE \1
  .if (\# = 3)
    sta    LOW_BYTE \3
  .else
    sta    LOW_BYTE \2
  .endif

    lda    LOW_BYTE \2+1
    sbc    LOW_BYTE \1+1
  .if (\# = 3)
    sta    LOW_BYTE \3+1
  .else
    sta    LOW_BYTE \2+1
  .endif

    lda    LOW_BYTE \2+2
    sbc    LOW_BYTE \1+2
  .if (\# = 3)
    sta    LOW_BYTE \3+2
  .else
    sta    LOW_BYTE \2+2
  .endif

    lda    LOW_BYTE \2+3
    sbc    LOW_BYTE \1+3
  .if (\# = 3)
    sta    LOW_BYTE \3+3
  .else
    sta    LOW_BYTE \2+3
  .endif
  .endmacro

; Substract 32 bits value plus carry from value at stated memory location.
  .macro subdw
    sec
  .if (\# = 3)
    sbcdw  \1, \2, \3
  .else
    sbcdw  \1, \2
  .endif
  .endmacro

; Increment a 32 bits value at stated memory location.
  .macro incdw
    inc    \1
    bne    @x_\@
    inc    \1+1
    bne    @x_\@
    inc    \1+2
    bne    @x_\@
    inc    \1+3
@x_\@:
  .endmacro

; Decrement a 32 bits value at stated memory location.
  .macro decdw
    sec
    lda    \1
    sbc    #1
    sta    \1
    lda    \1+1
    sbc    #0
    sta    \1+1
    lda    \1+2
    sbc    #0
    sta    \1+2
    lda    \1+3
    sbc    #0
    sta    \1+3
  .endmacro

; Left rotate 32 bits value.
  .macro roldw
    rol    \1
    rol    \1+1
    rol    \1+2
    rol    \1+3
  .endmacro

; Left shift 32 bits value.
  .macro aslw
    asl    \1
    rol    \1+1
    rol    \1+2
    rol    \1+3
  .endmacro

; Right rotate 32 bits value.
  .macro rorw
    ror    \1+3
    ror    \1+2
    ror    \1+1
    ror    \1
  .endmacro

; Right shift 32 bits value.
  .macro lsrdw
    lsr    \1+3
    ror    \1+2
    ror    \1+1
    ror    \1
  .endmacro

; Negate 32 bits value.
  .macro negdw
    cla
    sec
    sbc    \1
    sta    \1
    cla
    sbc    \1+1
    sta    \1+1
    cla
    sbc    \1+2
    sta    \1+2
    cla
    sbc    \1+3
    sta    \1+3
  .endmacro

; Push 32 bits value onto the stack.
  .macro phdw
    lda    \1+3
    pha
    lda    \1+2
    pha
    lda    \1+1
    pha
    lda    \1
    pha
  .endmacro

; Pull 32 bits value from the stack.
  .macro plw
    pla
    sta    \1
    pla
    sta    \1+1
    pla
    sta    \1+2
    pla
    sta    \1+3
  .endmacro

