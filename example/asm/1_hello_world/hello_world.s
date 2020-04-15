;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "start.s"

    .code
_main:
    ; Display "Hello world!" on screen.
    ; The string will be placed at BAT coordinate [10,8] using the default font
    stw    #txt, <_si       ; string address
    stb    #32, <_al        ; text area width
    stb    #20, <_ah        ; text area height
    ldx    #10              ; BAT X coordinate
    lda    #8               ; BAT Y coordinate
    jsr    print_string

    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

loop:
    vdc_wait_vsync          ; wait for screen refresh
    bra    loop             ; and we'll loop indefinitely

txt:                        ; the string we'll print on screen
    .db "Hello world!", 0
