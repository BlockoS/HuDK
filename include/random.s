;;
;; Title: Random number generators.
;; 
;; http://codebase64.org/doku.php?id=base:small_fast_8-bit_prng 
;; 
    .zp
seed    .ds 1

	.code
;;
;; Function: rand8_seed
;; Set pseudo-random number seed.
;;
;; Parameters:
;;    A - Seed.
rand8_seed:
    cmp    #$00
    bne    @store
        lda    #$b8
@store:
    sta    <seed
    rts

;;
;; Function: rand8
;; Generates 8-bit pseudo-random number.
;;
;; Parameters:
;;   seed - Pseudo-random number generator seed.
;;
;; Return:
;;   A - Pseud-random number.
;;
rand8:
    lda    <seed
    beq    @rand8_xor
    asl    A
    beq    @rand8_store
    bcc    @rand8_store
@rand8_xor:
    eor    #$1d
@rand8_store:
    sta    <seed
    rts
