;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

; Convert 3bit R, G, B to 9bit palette entry.
  .macro RGB_dw r, g, b
    .word (((g & $07) << 6) | ((r & $07) << 3) | (b & $07))
  .endmacro
