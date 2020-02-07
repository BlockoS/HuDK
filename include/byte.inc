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

  .ifdef MAGICKIT
    .include "pceas/byte.inc"
  .else
    .ifdef CA65
    .include "ca65/byte.inc"
    .endif
  .endif
