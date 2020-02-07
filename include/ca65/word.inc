;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Word-sized value manipulation macros.

; cc65 specific macros
  .macro __low opcode, arg
    .if (.match (.left (1, {arg}), #))
      opcode #<(.right (.tcount ({arg})-1, {arg}))
    .else
      opcode arg
    .endif 
  .endmacro 

  .macro __high opcode, arg
    .if (.match (.left (1, {arg}), #))
      opcode #>(.right (.tcount ({arg})-1, {arg}))
    .else
      opcode arg + 1
    .endif
  .endmacro

; Set stated memory location to zero.
  .macro stwz p0
    __low  stz, p0
    __high stz, p0
  .endmacro

; Store word-sized value at stated memory location.
  .macro stw p0, p1
    __low  lda, p0
    __low  sta, p1
    __high lda, p0
    __high sta, p1
  .endmacro

; Add word-sized value plus carry to value at stated memory location.
  .macro adcw p0, p1, p2
    __low  lda, p1
    __low  adc, p0
  .if .paramcount = 3
    __low  sta, p2
  .else
    __low  sta, p1
  .endif
    __high lda, p1
    __high adc, p0
  .if .paramcount = 3
    __high sta, p2
  .else
    __high sta, p1
  .endif
  .endmacro

; Add word-sized value to value at stated memory location.
  .macro addw p0, p1, p2
    clc
  .if .paramcount = 3
    adcw   p0, p1, p2
  .else
    adcw   p0, p1
  .endif
  .endmacro

; Substract word-sized value plus carry from value at stated memory location.
  .macro sbcw p0, p1, p2
    __low  lda, p1
    __low  sbc, p0
  .if .paramcount = 3
    __low  sta, p2
  .else
    __low  sta, p1
  .endif
    __high lda, p1
    __high sbc, p0
  .if .paramcount = 3
    __high sta, p2
  .else
    __high sta, p1
  .endif
  .endmacro

; Substract word-sized value plus carry from value at stated memory location.
  .macro subw p0, p1, p2
    sec
  .if .paramcount = 3
    sbcw   p0, p1, p2
  .else
    sbcw   p0, p1
  .endif
  .endmacro

; Increment a word-sized value at stated memory location.
  .macro incw p0
    inc    p0
    bne    :+
    inc    1+(p0)
:
  .endmacro

; Decrement a word-sized value at stated memory location.
  .macro decw p0
    sec
    lda    p0
    sbc    #1
    sta    p0
    bcs    :+
        dec    1+(p0)
:
  .endmacro

; Left rotate word-sized value.
  .macro rolw p0
    rol    p0
    rol    1+(p0)
  .endmacro

; Left shift word-sized value.
  .macro aslw p0
    asl    p0
    rol    1+(p0)
  .endmacro

; Right rotate word-sized value.
  .macro rorw p0
    ror    1+(p0)
    ror    p0
  .endmacro

; Right shift word-sized value.
  .macro lsrw p0
    lsr    1+(p0)
    ror    p0
  .endmacro

; Negate word-sized value.
  .macro negw p0
    cla
    sec
    sbc    p0
    sta    p0
    cla
    sbc    1+(p0)
    sta    1+(p0)
  .endmacro

; Push word-sized value onto the stack.
  .macro phw p0
    __high lda, p0
    pha
    __low  lda, p0
    pha
  .endmacro

; Pull word-sized value from the stack.
  .macro plw p0
    pla
    __low  sta, p0
    pla
    __high sta, p0
  .endmacro

