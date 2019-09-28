;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

;;
;; Title: Random number generators.
;; 
;; http://codebase64.org/doku.php?id=base:small_fast_8-bit_prng 
;; 
    .zp
seed    .ds 2
	.code
;;
;; Function: rand8_seed
;; Set pseudo-random number seed.
;;
;; Parameters:
;;    X - Seed LSB
;;    A - Seed MSB.
rand8_seed:
    cpx    #$00
    bne    @store
        ldx    #$b8
@store:
    stx    <seed
    
    and    #$0f
    tax
    lda    @magic_eor, X
    sta    <seed+1
    rts
@magic_eor:
    .db $1d,$2b,$2d,$4d,$5f,$63,$65,$69
    .db $71,$87,$8d,$a9,$c3,$cf,$e7,$f5

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
    eor    <seed+1
@rand8_store:
    sta    <seed
    rts
