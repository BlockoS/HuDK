;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
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

;;
;; Macro: subdw
;; Substract 32 bits value plus carry from value at stated memory location.
;; This is equivalent to call the sec instruction followed by the <sbcdw> macro.
;;
;; See Also:
;;   <sbcdw>
;;

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

  .ifdef MAGICKIT
    .include "pceas/dword.inc"
  .else
    .ifdef CA65
    .include "ca65/dword.inc"
    .endif
  .endif
