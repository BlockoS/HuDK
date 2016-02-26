.zeropage

memcpy:     .res 1
memcpy_src: .res 2
memcpy_dst: .res 2
memcpy_len: .res 2
memcpy_rts: .res 1
    
; Set memcpy mode.
  .macro  memcpy_mode mode
    lda    mode
    sta    <memcpy
  .endmacro

; Set memcpy arguments.
  .macro memcpy_args src, dst, len
    stw    src, <memcpy_src
    stw    dst, <memcpy_dst
    stw    len, <memcpy_len
  .endmacro
