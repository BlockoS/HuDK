;;
;; Title: Analog joypag functions.
;;

; [todo] doc
; [todo] convert to standard button layout

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

