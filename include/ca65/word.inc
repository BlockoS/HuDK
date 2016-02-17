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
      opcode 1+(arg)
    .endif
  .endmacro

; Set stated memory location to zero.
; \syntax stwz p0
; \param  [out] op Output memory location (zp or absolute)
  .macro stwz p0
    __low  stz, p0
    __high stz, p0
  .endmacro

; Store word-sized value at stated memory location.
; \syntax stw p0, p1
; \param [in]  p0  Input data (zp, absolute or immediate)
; \param [out] p1 Output memory location (zp or absolute)
  .macro stw p0, p1
    __low  lda, p0
    __low  sta, p1
    __high lda, p0
    __high sta, p1
  .endmacro

; Add word-sized value plus carry to value at stated memory location.
; Depending on the number of arguments, the addition is performed in place or
; the result is stored in the memory location specified in the third argument.
; The following bits of code adds $cafe to the word-sized value stored in RAM
; at $2220 and $2221, and stores the result at the same memory location.
; Or to put it in pseudo-code : $2200 += #$cafe
; \code
; adcw #$cafe, $2200
; \endcode
; Adds 1234 and 5678 and stores the result into a word-sized value stored in
; zero page.
; Or to put it in pseudo-code : <_out = #5678 + #1234
; \code
; adcw #1234, #5678, <_out
; \endcode
;
; \syntax adcw p0, out
;         adcw p0, p1, out
; \param [in]      p0  First operand (zp, absolute or immediate)
; \param [in][out] p1  Second operand (zp or absolute, or immediate if the 3rd 
;                                      argument is set)
; \param [out]     out (Optional) Output memory location (zp or absolute)
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
; This is equivalent to call the clc instruction followed by the adcw macro.
  .macro addw p0, p1, p2
    clc
  .if .paramcount = 3
    adcw   p0, p1, p2
  .else
    adcw   p0, p1
  .endif
  .endmacro

; Substract word-sized value plus carry from value at stated memory location.
; Depending on the number of arguments, the substraction is performed in place
; or the result is stored in the memory location specified in the third
; argument.
; @code
; Substract $cafe to the word-sized value stored in RAM at $2220 and $2221, and
; stores the result at the same memory location.
; Or to put it in pseudo-code : $2200 -= #$cafe
; \code
; sbcw #$cafe, $2200
; \endcode
; Substract 1234 from 5678 and stores the result into a word-sized value stored
; in zero page.
; Or to put it in pseudo-code : <_out = #5678 - #1234
; \code
; sbcw #1234, #5678, <_out
; \endcode
;
; \syntax adcw p0, out
;         adcw p0, p1, out
; \param [in]      p0  First operand (zp, absolute or immediate)
; \param [in][out] p1  Second operand (zp or absolute, or immediate if the 3rd 
;                                      argument is set)
; \param [out]     out (Optional) Output memory location (zp or absolute)
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
; This is equivalent to call the clc instruction followed by the adcw macro.
  .macro subw p0, p1, p2
    sec
  .if .paramcount = 3
    sbcw   p0, p1, p2
  .else
    sbcw   p0, p1
  .endif
  .endmacro

; Increment a word-sized value at stated memory location.
; \syntax incw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro incw p0
    inc    p0
    bne    @l
    inc    1+(p0)
@l:
  .endmacro

; Decrement a word-sized value at stated memory location.
; \syntax decw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro decw p0
    sec
    lda    p0
    sbc    #1
    sta    p0
    lda    1+(p0)
    sbc    #0
    sta    1+(p0)
  .endmacro

; Left rotate word-sized value.
; \syntax rolw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro rolw p0
    rol    p0
    rol    1+(p0)
  .endmacro

; Left shift word-sized value.
; \syntax aslw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro aslw p0
    asl    p0
    rol    1+(p0)
  .endmacro

; Right rotate word-sized value.
; \syntax rorw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro rorw p0
    ror    1+(p0)
    ror    p0
  .endmacro

; Right shift word-sized value.
; \syntax lsrw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro lsrw p0
    lsr    1+(p0)
    ror    p0
  .endmacro

; Negate word-sized value.
; \syntax negw p0
; \param [in][out] p0 Memory location (zero page or absolute)
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
; \syntax phw p0
; \param [in] p0 Value (zero page, absolute or immediate)
  .macro phw p0
    __high lda, p0
    pha
    __low  lda, p0
    pha
  .endmacro

; Pull word-sized value from the stack.
; \syntax plw p0
; \param [in] p0 Value (zero page or absolute)
  .macro plw p0
    pla
    __low  sta, p0
    pla
    __high sta, p0
  .endmacro

