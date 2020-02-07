;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Store a byte at stated memory location
  .macro stb p0, p1
      lda    p0
      sta    p1
  .endmacro

; Negate value.
  .macro neg
      lda    p0
      eor    #$ff
      inc    A
      sta    p0
  .endmacro
