    .zp
memcpy     .ds 1
memcpy_src .ds 2
memcpy_dst .ds 2
memcpy_len .ds 2
memcpy_rts .ds 1
    
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
