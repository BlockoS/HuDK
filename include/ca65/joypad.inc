;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

  .bss
; This array holds the values for 5 2-buttons joypad.
joypad: 	.res 5, 0

; Delta joypad values.
joytrg: 	.res 5, 0

; Previous joypad values.
joyold: 	.res 5, 0

; This array contains the values for buttons III, IV, V and VI of 6 buttons
; joypads.
joypad_6: 	.res 5, 0

; Delta joypad values.
joytrg_6: 	.res 5, 0

; Previous joypad values.
joyold_6: 	.res 5, 0

.macro joypad_reset_multitap
    lda    #$01         ; reset multitap to joypad #1
    sta    joyport
    lda    #$03
    sta    joyport
    joypad_delay
.endmacro

.macro joypad_poll current, previous
    lda    #$01         ; read directions (SEL=1)
    sta    joyport
    joypad_delay

    lda    current, X
    sta    previous, X
    lda    joyport
    asl    A
    asl    A
    asl    A
    asl    A
    sta    current, X

    stz    joyport      ; read buttons (SEL=0)
    joypad_delay

    lda    joyport
    and    #$0f
    ora    current, X
    eor    #$ff
    sta    current, X
.endmacro
