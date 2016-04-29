;;
;; Title: Joypad Functions.
;;

;;
;; function: joypad_read
;; Poll joypads state.
;;
;; This routine assumes that a multitap with 5 2-button joypads are plugged to
;; the joypad port. 
;;
;; Parameters:
;;   *none*
;;
;; Return:
;;   joypad - States of the 5 joypads.
;;
;; Consumed:
;;   A, X
;;
joypad_read:
    tii    joypad, joyold, 5

    lda    #$01         ; reset multitap to joypad #1
    sta    joyport
    lda    #$03
    sta    joyport
    joypad_delay

    clx
@loop:
    lda    #$01         ; read directions (SEL=1)
    sta    joyport
    joypad_delay
   
    lda    joyport
    asl    A
    asl    A
    asl    A
    asl    A
    sta    joypad, X

    stz    joyport      ; read buttons (SEL=0)
    joypad_delay

    lda    joyport
    and    #$0f
    ora    joypad, X
    eor    #$ff
    sta    joypad, X

    eor    joyold, X
    and    joypad, X
    sta    joytrg, X

    inx
    cpx    #$05
    bcc    @loop

    rts

;;
;; function: joypad_6_read
;; Poll 6-buttons joypads state.
;;
;; This routines assumes that 6-button controllers may be connected to a
;; multitap.
;;
;; Parameters:
;;   *none*
;;
;; Return:
;;   joypad   - directions and buttons for all 5 controllers.
;;   joypad_6 - states of buttons III, IV, V and VI or 0 for 2-button joypads.
;;
joypad_6_read:
    tii    joypad_6, joyold_6, 5

    jsr    joypad_read      ; first scan

    lda    joypad           ; unrolled copy loop
    sta    joypad_6
    lda    joypad+1
    sta    joypad_6+1
    lda    joypad+2
    sta    joypad_6+2
    lda    joypad+3
    sta    joypad_6+3
    lda    joypad+4
    sta    joypad_6+4

    jsr    joypad_read      ; second scan

    ; If there is a 6 button joypad somewhere, the direction bits on one of the
    ; scans are all set to 1. As joypad_6 is supposed to contains the extra
    ; buttons, we may need to swap the values of the joypad and joypad_6 arrays
    ; so that joypad contains the directions and standard buttons and joypad_6
    ; the extra buttons or 0 for a 2-buttons joypad.
    clx
@l0:
    lda    joypad_6, X
    tay
    and    #$f0
    cmp    #$f0
    beq    @no_swap
       lda    joypad, X
       sta    joypad_6, X
       say
       sta    joypad, X
@no_swap:
    ; now set joypad_6 entry to zero for 2-buttons joypads.
    tya
    and    #$f0
    cmp    #$f0
    bne    @no_reset
        stz    joypad_6, X
@no_reset: 

    lda    joypad_6, X
    eor    joyold_6, X
    and    joypad_6, X
    sta    joypad_6, X

    inx
    cpx    #$05
    bne    @l0

    rts

;;
;; function: joypad_read.1
;; Poll the first joypad state.
;;
;; Parameters:
;;   *none*
;;
;; Return:
;;   joypad - States of the first joypads.
;;
;; Consumed:
;;   A, X, Y
;;
joypad_read.1:
    lda    joypad
    sta    joyold

    lda    #$01         ; reset multitap to joypad #1
    sta    joyport
    lda    #$03
    sta    joyport
    joypad_delay

    lda    #$01         ; read directions (SEL=1)
    sta    joyport
    joypad_delay
   
    lda    joyport
    asl    A
    asl    A
    asl    A
    asl    A
    sta    joypad

    stz    joyport      ; read buttons (SEL=0)
    joypad_delay

    lda    joyport
    and    #$0f
    ora    joypad
    eor    #$ff
    sta    joypad

    eor    joyold
    and    joypad
    sta    joytrg

    rts

;;
;; function: joypad_6_read.1
;; Poll the first 6-buttons joypad state.
;;
;; Parameters:
;;   *none*
;;
;; Return:
;;   joypad   - directions and buttons for the first controller.
;;   joypad_6 - states of buttons III, IV, V and VI or 0 for 2-button joypad.
;;
joypad_6_read.1:
    jsr    joypad_read.1    ; first scan

    lda    joypad
    sta    joypad_6

    jsr    joypad_read.1    ; second scan

    lda    joypad_6
    tay
    and    #$f0
    cmp    #$f0
    beq    @no_swap
       lda    joypad
       sta    joypad_6
       say
       sta    joypad
@no_swap:
    ; now set joypad_6 entry to zero for 2-buttons joypads.
    tya
    and    #$f0
    cmp    #$f0
    bne    @no_reset
        stz    joypad_6
@no_reset: 

    rts
