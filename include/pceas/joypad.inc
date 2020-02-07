;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

  .bss
; This array holds the values for 5 2-buttons joypad.
joypad .ds 5

; Delta joypad values.
joytrg .ds 5

; Previous joypad values.
joyold .ds 5

; This array contains the values for buttons III, IV, V and VI of 6 buttons
; joypads.
joypad_6 .ds 5

; Delta joypad values.
joytrg_6 .ds 5

; Previous joypad values.
joyold_6 .ds 5

  .code
  .macro joypad_reset_multitap
    lda    #$01         ; reset multitap to joypad #1
    sta    joyport
    lda    #$03
    sta    joyport
    joypad_delay
  .endmacro

  .macro joypad_poll
    lda    #$01         ; read directions (SEL=1)
    sta    joyport
    joypad_delay

    lda    \1, X
    sta    \2, X
    lda    joyport
    asl    A
    asl    A
    asl    A
    asl    A
    sta    \1, X

    stz    joyport      ; read buttons (SEL=0)
    joypad_delay

    lda    joyport
    and    #$0f
    ora    \1, X
    eor    #$ff
    sta    \1, X
  .endmacro
