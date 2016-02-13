; Word-sized value manipulation macros.

; Set stated memory location to zero.
; \syntax stwz p0
; \param  [out] op Output memory location (zp or absolute)
  .macro stwz
    stz    LOW_BYTE \1
    stz    HIGH_BYTE \1
  .endm

; Store word-sized value at stated memory location.
; \syntax stw p0, p1
; \param [in]  p0  Input data (zp, absolute or immediate)
; \param [out] p1 Output memory location (zp or absolute)
  .macro stw
    lda    LOW_BYTE \1
    sta    LOW_BYTE \2
    lda    HIGH_BYTE \1
    sta    HIGH_BYTE \2
  .endm

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
  .endm

; Add word-sized value to value at stated memory location.
; This is equivalent to call the clc instruction followed by the adcw macro.
  .macro addw
    clc
  .if (\# = 3)
    adcw   \1, \2, \3
  .else
    adcw   \1, \2
  .endif
  .endm

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
  .endm

; Substract word-sized value plus carry from value at stated memory location.
; This is equivalent to call the clc instruction followed by the adcw macro.
  .macro subw
    sec
  .if (\# = 3)
    sbcw   \1, \2, \3
  .else
    sbcw   \1, \2
  .endif
  .endm

; Increment a word-sized value at stated memory location.
; \syntax incw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro incw
    inc    \1
    bne    .x_\@
    inc    \1+1
.x_\@:
  .endm

; Decrement a word-sized value at stated memory location.
; \syntax decw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro decw
    sec
    lda    \1
    sbc    #1
    sta    \1
    lda    \1+1
    sbc    #0
    sta    \1+1
  .endm

; Left rotate word-sized value.
; \syntax rolw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro rolw
    rol    \1
    rol    \1+1
  .endm

; Left shift word-sized value.
; \syntax aslw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro aslw
    asl    \1
    rol    \1+1
  .endm

; Right rotate word-sized value.
; \syntax rorw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro rorw
    ror    \1+1
    ror    \1
  .endm

; Right shift word-sized value.
; \syntax lsrw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro lsrw
    lsr    \1+1
    ror    \1
  .endm

; Negate word-sized value.
; \syntax negw p0
; \param [in][out] p0 Memory location (zero page or absolute)
  .macro negw
    cla
    sec
    sbc    \1
    sta    \1
    cla
    sbc    \1+1
    sta    \1+1
  .endm

; Push word-sized value onto the stack.
; \syntax phw p0
; \param [in] p0 Value (zero page, absolute or immediate)
  .macro phw
    lda    HIGH_BYTE \1
    pha
    lda    LOW_BYTE \1
    pha
  .endm

; Pull word-sized value from the stack.
; \syntax plw p0
; \param [in] p0 Value (zero page or absolute)
  .macro plw
    pla
    sta    LOW_BYTE \1
    pla
    sta    HIGH_BYTE \1
  .endm

