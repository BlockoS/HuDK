;;
;; Title: Joypad Functions.
;;
  .include "joypad.inc"

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

  .code
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

    joypad_reset_multitap

    clx
@loop:
    joypad_poll joypad
    
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
    
    joypad_reset_multitap               ; first scan
    clx
@first_scan:
        joypad_poll joypad
        inx
        cpx    #$05
        bne    @first_scan
    
    joypad_reset_multitap               ; second scan
    clx
@second_scan:
        joypad_poll joypad_6
        inx
        cpx    #$05
        bne    @second_scan
    
    ; If there is a 6 button joypad somewhere, the direction bits on one of the
    ; scans are all set to 1. As joypad_6 is supposed to contains the extra
    ; buttons, we may need to swap the values of the joypad and joypad_6 arrays
    ; so that joypad contains the directions and standard buttons and joypad_6
    ; the extra buttons or 0 for a 2-buttons joypad.
    clx
@l0:
        lda    joypad_6, X
        and    #$f0
        cmp    #$f0
        beq    @next
        
        tay
        
        lda    joypad, X
        and    #$f0
        cmp    #$f0
        bne    @reset
            sta    joypad_6, X
            say
            sta    joypad, X
            bra    @next
@reset:
            stz    joypad_6
@next:
        ; Compute "triggers".
        lda    joypad_6, X
        eor    joyold_6, X
        and    joypad_6, X
        sta    joytrg_6, X

        lda    joypad, X
        eor    joyold, X
        and    joypad, X
        sta    joytrg, X

        inx
        cpx    #$05
        bne    @l0
    rts

