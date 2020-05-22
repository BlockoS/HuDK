;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Title: Memory mapping utility routines.
;;

;;
;; Macro: neg
;; Map address to the bank and page it was declared in
;;
;; Parameter:
;;   addr - Address to be mapped.
;;
  .macro map
    lda    #bank(\1)
    tam    #page(\1)
  .endmacro
