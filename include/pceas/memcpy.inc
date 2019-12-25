;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
	.code
    
; Set memcpy mode.
  .macro  memcpy_mode
    lda    \1
    sta    <memcpy
  .endmacro

; Set memcpy arguments.
  .macro memcpy_args
    stw    \1, <memcpy_src
    stw    \2, <memcpy_dst
    stw    \3, <memcpy_len
  .endmacro

; All in one macro.
  .macro memcpy_ex
    stw    \1, <memcpy_src
    stw    \2, <memcpy_dst
    stw    \3, <memcpy_len
  .if (\# = 4)
    lda    \4
  .else
    lda    #SOURCE_INC_DEST_ALT
  .endif
    sta    <memcpy
    jsr    memcpy
  .endmacro
