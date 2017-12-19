;;
;; Title: Analog joypag functions.
;;

	.include "hudk.inc"

;;
;; ubyte: JOY_ANALOG_BYTTONS_0
;; Holds the state of A, B, SELECT, START and other unknown buttons...
;;
JOY_ANALOG_BUTTONS_O = 0 
;;
;; ubyte: JOY_ANALOG_BUTTONS_1
;; May hold the states for other unknown buttons.
;;
JOY_ANALOG_BUTTONS_1 = 4 ; [todo] unconfirmed
;;
;; ubyte: JOY_ANALOG_X
;; Value of the analog stick horizontal axis.
;;
JOY_ANALOG_X         = 1
;;
;; ubyte: JOY_ANALOG_Y
;; Value of the analog stick vertical axis.
;;
JOY_ANALOG_Y         = 2
;;
;; ubyte: JOY_ANALOG_SLIDER
;; Value of the slider stick.
;;
JOY_ANALOG_SLIDER    = 3 ; [todo] unconfirmed

;;
;; function: analog_joypad_read
;; Read values from an analog joypad. 
;; 
;; Return:
;;   Carry flag - set if an analog joypad was succesfully detected.
;;   joypad
    sec
    rts
analog_joypad_read:
    ; this is an evil hack in order to avoir long branch
@detect_failed = analog_joypad_read - 2

    ; analog joypad detection
    stz    joyport
    joypad_delay

    cly    
@loop:
    ; first nibble
    lda    #$02
    sta    joyport
    joypad_delay

    clx
@detect_step_1:
        inx
        beq    @detect_failed
        lda    joyport
        and    #$03
        bne    @detect_step_1
    
    lda    #$03
    sta    joyport
    joypad_delay

    lda    joyport
    and    #$0f
    tax
    lda    analog_lut, X
    sta    joypad, Y
    iny

    ; second nibble
    lda    #$02
    sta    joyport
    joypad_delay
    
    clx
@detect_step_2:
        inx
        beq    @detect_failed
        lda    joyport
        and    #$03
        cmp    #$01
        bne    @detect_step_2

    lda    #$03
    sta    joyport
    joypad_delay

    lda    joyport
    and    #$0f
    tax
    lda    analog_lut, X
    sta    joypad, Y
    iny

    cpy    #10
    bne    @loop

    ; reassemble nibbles
    lda    joypad
    asl    A
    asl    A
    asl    A
    asl    A
    ora    joypad+1
    sta    joypad

    lda    joypad+2
    asl    A 
    asl    A 
    asl    A 
    asl    A 
    ora    joypad+6
    sta    joypad+1

    lda    joypad+3
    asl    A 
    asl    A 
    asl    A 
    asl    A 
    ora    joypad+7
    sta    joypad+2

    lda    joypad+4
    asl    A 
    asl    A 
    asl    A 
    asl    A 
    ora    joypad+8
    sta    joypad+3

    lda    joypad+5
    asl    A 
    asl    A 
    asl    A 
    asl    A 
    ora    joypad+9
    sta    joypad+4

    clc
    rts

analog_lut:
    .db $00,$01,$08,$09,$02,$03,$0a,$0b
    .db $04,$05,$0c,$0d,$06,$07,$0e,$0f

;;
;; function: analog_convert
;; Convert button to the standard joypad layout.
;; 
;; Return:
;;   joypad - The first 4 bits will contains the state of the A, B, SELECT and
;;            START buttons just like a standard joypad.
analog_convert:
    lda    joypad
    asl    A
    rol    A
    bcc    @l0
        ora    #$02
@l0:
    sta    joypad
    rts
