;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

;;
;; Title: Joypad Functions.
;;
  .include "joypad.inc"

  .code
;;
;; function: joypad_read
;; Poll joypads state.
;;
;; This routine assumes that a multitap with 5 2-button joypads is plugged to
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
    joypad_reset_multitap

    clx
@loop:
    joypad_poll joypad, joyold
    
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
        joypad_poll joypad, joyold
        inx
        cpx    #$05
        bne    @first_scan
    
    joypad_reset_multitap               ; second scan
    clx
@second_scan:
        joypad_poll joypad_6, joyold_6
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
        ldy    joypad_6, X
        tya
        and    #$50
        cmp    #$50
        beq    @next
        
        ldy    joypad, X
        tya
        and    #$50
        cmp    #$50
        bne    @reset
            lda    joypad_6, X
            sta    joypad, X
            bra    @next
@reset:
        cly
@next:
        tya
        and     #$5f
        sta    joypad_6, X
        ; Compute "triggers".
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

