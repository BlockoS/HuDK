;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Convert 3bit R, G, B to 9bit palette entry.
  .macro RGB 
  (((\2 & $07) << 6) | ((\1 & $07) << 3) | (\3 & $07))
  .endmacro
