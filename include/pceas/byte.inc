;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Store a byte at stated memory location
  .macro stb
      lda    \1
      sta    \2
  .endmacro

; Negate value.
  .macro neg
      lda    \1
      eor    #$ff
      inc    A
      sta    \1
  .endmacro
