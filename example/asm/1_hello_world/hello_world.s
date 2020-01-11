;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
    .include "start.s"

    .code
_main:
    ; [todo] comments
    stw    #txt, <_si
    stb    #32, <_al
    stb    #20, <_ah
    ldx    #10
    lda    #8
    jsr    print_string

loop:
    vdc_wait_vsync
    bra    loop

txt:
    .byte "Hello world!", 0
