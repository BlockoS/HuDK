;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Group: Byte manipulation macros.
;;

;;
;; Macro: stb
;;
;; Store a byte at stated memory location.
;;
;; Assembly call:
;;   > stb p0, p1
;;
;; Parameters:
;;   p0 - Input data.
;;   p1 - Output memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page*, *Absolute* or *Immediate*.
;;   p1 - *Zero Page* or *Absolute*.
  .macro stb
      lda    \1
      sta    \2
  .endmacro

;;
;; Macro: neg
;;
;; Negate value.
;;
;; Assembly call:
;;   > neg p0
;;
;; Parameter:
;;   p0 - Memory location.
;;
;; Restrictions:
;;   p0 - *Zero Page* or *Absolute*.
;;
  .macro neg
      lda    \1
      eor    #$ff
      inc    A
      sta    \1
  .endmacro

;;
;; Macro: add
;;
;; Add a byte to accumulator.
;;
;; Assembly call:
;;   > add p0
;;
;; Parameter:
;;   p0 - Operand.
;;

; [todo] update comments
  .macro add
  .if (\# = 2)
    lda    \2
  .endif
    clc
    adc    \1
  .if (\# = 2)
    sta    \2
  .else
    .if (\# = 3)
    sta    \3
    .endif
  .endif
  .endmacro

;;
;; Macro: sub
;;
;; Substract byte from accumulator.
;;
;; Assembly call:
;;   > sub p0
;;
;; Parameter:
;;   p0 - Operand.
;;

    ; [todo] same as add
  .macro sub
    sec
    sbc    \1
  .endmacro
