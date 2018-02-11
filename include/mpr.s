;;
;; Title: Memory mapping utility routines.
;;
  .ifdef CA65
    .include "ca65/mpr.s"
  .endif 

  .code
;;
;; function: map_data
;;   Map data to mpr 3 and 4.
;;
;; Parameters:
;;   _bl - data bank. 
;;   _si - data address.
;;
;; Return:
;;   _bx - previous values of mpr 3 and 4.
;;   _si - remapped data address.
map_data:
    ldx    <_bl
    ; save mpr 3 and 4.
    tma3
    sta    <_bl
    tma4
    sta    <_bh

    ; map bank
    txa
    tam3
    inc    A
    tam4

    ; remap data address
    lda    <_si+1
    and    #$1f
    ora    #$60
    sta    <_si+1
    rts

;;
;; function: remap_data
;; Update value of mpr 3 and 4 if needed.
;;
;; Parameters:
;;   _si - data address.
;;
;; Return:
;;   _si - 
remap_data:
    ; check if data needs to be remapped
    lda    <_si+1
    bpl    @l0
        sec
        sbc    #$20
        sta    <_si+1
        tma4
        tam3
        inc    A
        tam4
@l0:
    rts

;;
;; function: unmap_data
;; Restore values of mpr 3 and 4.
;;
;; Parameters:
;;   _bx - mpr 3 and 4 values.
;;
unmap_data:
    lda    <_bl
    tam3
    lda    <_bh
    tam4
    rts
