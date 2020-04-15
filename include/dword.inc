;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Group: 32 bits (Double Word) value manipulation macros.
;;

;;
;; Macro: stdwz
;;
;; Set stated memory location to zero.
;;
;; Assembly call:
;;   > stdwz op
;;
;; Parameter:
;;   op - Output memory location
;; 
;; Restrictions:
;;   op - Addressing modes must be either *Zero Page* or *Absolute*.
;;
  .macro stdwz
    stz    \1
    stz    \1+1
    stz    \1+2
    stz    \1+3
  .endmacro

;;
;; Macro: stdw
;;
;; Store 32 bits value at stated memory location.
;;
;; Assembly call:
;;   > stdw p0, p1
;;
;; Parameters:
;;   p0 - Input data.
;;   p1 - Output memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;   p1 - *Zero Page* or *Absolute*.
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

;;
;; Macro: adcdw
;;
;; Add 32 bits value plus carry to value at stated memory location.
;; Depending on the number of arguments, the addition is performed in place or
;; the result is stored in the memory location specified in the third argument.
;;
;; Assembly call:
;;   > adcdw p0, p1
;;   > adcdw p0, p1, p2
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
;; The following bits of code adds $0badcafe to the 32 bits value stored in RAM
;; at $2220 to $2223 and stores the result at the same memory location.
;; > adcw #$0badcafe, $2200
;; This is equivalent in pseudo-code to:
;; > $2200 += #$0badcafe
;; The next example adds 16300 and 200524 and stores the result into a 32 bits
;; value stored in zero page.
;; > adcdw #16300, #200524, <_out
;; The corresponding pseudo-code is:
;; > <_out = #200524 + #16300
;;
  .macro adcdw
    lda    \2
    adc    \1
  .if (\# = 3)
    sta    \3
  .else
    sta    \2
  .endif

    lda    \2+1
    adc    \1+1
  .if (\# = 3)
    sta    \3+1
  .else
    sta    \2+1
  .endif

    lda    \2+2
    adc    \1+2
  .if (\# = 3)
    sta    \3+2
  .else
    sta    \2+2
  .endif

    lda    \2+3
    adc    \1+3
  .if (\# = 3)
    sta    \3+3
  .else
    sta    \2+3
  .endif

  .endmacro

;;
;; Macro: adddw
;;
;; Add 32 bits value to value at stated memory location.
;;
;; Description:
;; This is equivalent to call the clc instruction followed by the <adcdw> macro.
;;
;; See Also:
;;   <adcdw>
;;
  .macro adddw
    clc
  .if (\# = 3)
    adcdw  \1, \2, \3
  .else
    adcdw  \1, \2
  .endif
  .endmacro

;;
;; Macro: sbcdw
;;
;; Substract 32 bits value plus carry from value at stated memory location.
;; Depending on the number of arguments, the substraction is performed in place
;; or the result is stored in the memory location specified in the third
;; argument.
;;
;; Assembly call:
;;   > sbcdw p0, p1
;;   > sbcdw p0, p1, p2
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
;; Substract $0badcafe to the 32 bits value stored in RAM at $2220 to $2223, and
;; stores the result at the same memory location.
;; > sbcdw #$0badcafe, $2200
;; Or to put it in pseudo-code: 
;; > $2200 -= #$0badcafe
;; Substract 16300 from 200524 and stores the result into a 32 bits value stored
;; in zero page.
;; > sbcdw #16300, #200524, <_out
;; Which givec in C pseudo-code:
;; > <_out = #200524 - #16300
;;
  .macro sbcdw
    lda    \2
    sbc    \1
  .if (\# = 3)
    sta    \3
  .else
    sta    \2
  .endif

    lda    \2+1
    sbc    \1+1
  .if (\# = 3)
    sta    \3+1
  .else
    sta    \2+1
  .endif

    lda    \2+2
    sbc    \1+2
  .if (\# = 3)
    sta    \3+2
  .else
    sta    \2+2
  .endif

    lda    \2+3
    sbc    \1+3
  .if (\# = 3)
    sta    \3+3
  .else
    sta    \2+3
  .endif
  .endmacro

;;
;; Macro: subdw
;; Substract 32 bits value plus carry from value at stated memory location.
;; This is equivalent to call the sec instruction followed by the <sbcdw> macro.
;;
;; See Also:
;;   <sbcdw>
;;
  .macro subdw
    sec
  .if (\# = 3)
    sbcdw  \1, \2, \3
  .else
    sbcdw  \1, \2
  .endif
  .endmacro

;;
;; Macro: incdw
;;
;; Increment a 32 bits value at stated memory location.
;;
;; Assembly call:
;;   > incdw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*
;;
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

;;
;; Macro: decdw
;;
;; Decrement a 32 bits value at stated memory location.
;;
;; Assembly call:
;;   > decdw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
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

;;
;; Macro: roldw
;;
;; Left rotate 32 bits value.
;; 
;; Assembly call:
;;   > roldw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro roldw
    rol    \1
    rol    \1+1
    rol    \1+2
    rol    \1+3
  .endmacro

;;
;; Macro: asldw
;;
;; Left shift 32 bits value.
;;
;; Assembly call:
;;   > asldw p0
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
    rol    \1+2
    rol    \1+3
  .endmacro


;;
;; Macro: rordw
;;
;; Right rotate 32 bits value.
;;
;; Assembly call:
;;   > rordw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro rorw
    ror    \1+3
    ror    \1+2
    ror    \1+1
    ror    \1
  .endmacro

;;
;; Macro: lsrdw
;;
;; Right shift 32 bits value.
;;
;; Assembly call:
;;   > lsrdw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro lsrdw
    lsr    \1+3
    ror    \1+2
    ror    \1+1
    ror    \1
  .endmacro

;;
;; Macro: negdw
;;
;; Negate 32 bits value.
;;
;; Assembly call:
;;   > negdw p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
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

;;
;; Macro: phdw
;;
;; Push 32 bits value onto the stack.
;;
;; Assembly call:
;;   > phdw p0
;;
;; Parameter:
;;   p0 - Value.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;
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

;;
;; Macro: pldw
;;
;; Pull 32 bits value from the stack.
;;
;; Assembly call:
;;   > pldw p0
;;
;; Parameter:
;;   p0 - Value.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
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

