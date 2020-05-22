;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Group: Word-sized value manipulation macros.
;;

;;
;; Macro: stwz
;;
;; Set stated memory location to zero.
;;
;; Assembly call:
;;   > stwz op
;;
;; Parameter:
;;   op - Output memory location
;; 
;; Restrictions:
;;   op - Addressing modes must be either *Zero Page* or *Absolute*.
;;
  .macro stwz
    stz    LOW_BYTE \1
    stz    HIGH_BYTE \1
  .endmacro

;;
;; Macro: stw
;;
;; Store word-sized value at stated memory location.
;;
;; Assembly call:
;;   > stw p0, p1
;;
;; Parameters:
;;   p0 - Input data.
;;   p1 - Output memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;   p1 - *Zero Page* or *Absolute*.
  .macro stw
    lda    LOW_BYTE \1
    sta    LOW_BYTE \2
    lda    HIGH_BYTE \1
    sta    HIGH_BYTE \2
  .endmacro

;;
;; Macro: adcw
;;
;; Add word-sized value plus carry to value at stated memory location.
;; Depending on the number of arguments, the addition is performed in place or
;; the result is stored in the memory location specified in the third argument.
;;
;; Assembly call:
;;   > adcw p0, p1
;;   > adcw p0, p1, p2
;;
;; Parameters:
;;   p0 - First operand.
;;   p1 - Second operand.
;;   p2 - (Optional) Output memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;   p1 - *Zero Page*, *Absolute* or *Immediate* if the 3rd argument is set.
;;   p2 - *Zero Page* or *Absolute*
;;
;; Examples:
;; The following bits of code adds $cafe to the word-sized value stored in RAM
;; at $2220 and $2221, and stores the result at the same memory location.
;; > adcw #$cafe, $2200
;; This is equivalent in pseudo-code to:
;; > $2200 += #$cafe
;; The next example adds 1234 and 5678 and stores the result into a word-sized
;; value stored in zero page.
;; > adcw #1234, #5678, <_out
;; The corresponding pseudo-code is:
;; > <_out = #5678 + #1234
;;
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

;;
;; Macro: addw
;;
;; Add word-sized value to value at stated memory location.
;;
;; Description:
;; This is equivalent to call the clc instruction followed by the <adcw> macro.
;;
;; See Also:
;;   <adcw>
;;
  .macro addw
    clc
  .if (\# = 3)
    adcw   \1, \2, \3
  .else
    adcw   \1, \2
  .endif
  .endmacro

;;
;; Macro: sbcw
;;
;; Substract word-sized value plus carry from value at stated memory location.
;; Depending on the number of arguments, the substraction is performed in place
;; or the result is stored in the memory location specified in the third
;; argument.
;;
;; Assembly call:
;;   > sbcw p0, p1
;;   > sbcw p0, p1, p2
;;
;; Parameters:
;;   p0 - First operand.
;;   p1 - Second operand.
;;   p2 - (Optional) Output memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;   p1 - *Zero Page*, *Absolute* or *Immediate* if the 3rd argument is set.
;;   p2 - *Zero Page* or *Absolute*.
;;
;; Examples:
;; Substract $cafe to the word-sized value stored in RAM at $2220 and $2221, and
;; stores the result at the same memory location.
;; > sbcw #$cafe, $2200
;; Or to put it in pseudo-code: 
;; > $2200 -= #$cafe
;; Substract 1234 from 5678 and stores the result into a word-sized value stored
;; in zero page.
;; > sbcw #1234, #5678, <_out
;; Which givec in C pseudo-code:
;; > <_out = #5678 - #1234
;;
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

;;
;; Macro: subw
;; Substract word-sized value plus carry from value at stated memory location.
;; This is equivalent to call the sec instruction followed by the <sbcw> macro.
;;
;; See Also:
;;   <sbcw>
;;
  .macro subw
    sec
  .if (\# = 3)
    sbcw   \1, \2, \3
  .else
    sbcw   \1, \2
  .endif
  .endmacro

;;
;; Macro: incw
;;
;; Increment a word-sized value at stated memory location.
;;
;; Assembly call:
;;   > incw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*
;;
  .macro incw
    inc    \1
    bne    @x_\@
    inc    \1+1
@x_\@:
  .endmacro

;;
;; Macro: decw
;;
;; Decrement a word-sized value at stated memory location.
;;
;; Assembly call:
;;   > decw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro decw
    sec
    lda    \1
    sbc    #1
    sta    \1
    bne    @decw_\@
        dec    \1+1
@decw_\@:
  .endmacro

;;
;; Macro: rolw
;;
;; Left rotate word-sized value.
;; 
;; Assembly call:
;;   > rolw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro rolw
    rol    \1
    rol    \1+1
  .endmacro

;;
;; Macro: aslw
;;
;; Left shift word-sized value.
;;
;; Assembly call:
;;   > aslw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro aslw
    asl    \1
    rol    \1+1
  .endmacro

;;
;; Macro: rorw
;;
;; Right rotate word-sized value.
;;
;; Assembly call:
;;   > rorw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro rorw
    ror    \1+1
    ror    \1
  .endmacro

;;
;; Macro: lsrw
;;
;; Right shift word-sized value.
;;
;; Assembly call:
;;   > lsrw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro lsrw
    lsr    \1+1
    ror    \1
  .endmacro

;;
;; Macro: negw
;;
;; Negate word-sized value.
;;
;; Assembly call:
;;   > negw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro negw
    cla
    sec
    sbc    \1
    sta    \1
    cla
    sbc    \1+1
    sta    \1+1
  .endmacro

;;
;; Macro: phw
;;
;; Push word-sized value onto the stack.
;;
;; Assembly call:
;;   > phw p0
;;
;; Parameter:
;;   p0 - Value.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;
  .macro phw
    lda    HIGH_BYTE \1
    pha
    lda    LOW_BYTE \1
    pha
  .endmacro

;;
;; Macro: plw
;;
;; Pull word-sized value from the stack.
;;
;; Assembly call:
;;   > plw p0
;;
;; Parameter:
;;   p0 - Value.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro plw
    pla
    sta    LOW_BYTE \1
    pla
    sta    HIGH_BYTE \1
  .endmacro
