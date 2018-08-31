;;
;; Title: CRC routines.
;;
    .zp
_crc .ds 4

    .code
;;
;; function: crc16
;; Computes CRC-16 (CCITT).	
;;
;; Description:
;; This function updates the current CRC-16 with the value of the A register.
;; The current implementation is based on Greg Cook CRC-16.
;;
;; For more informations:
;;  - https://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks
;;  - http://www.6502.org/source/integers/crc-more.html
;;
;; Assembly call:
;;   > ; reset CRC-16 value
;;   > stwz   <_crc
;;   >
;;   > ; _si contains the address of the input buffer
;;   > ; X contains its size 
;;   > cly
;;   > loop:
;;   >     phy
;;   >     phx
;;   >
;;   >     lda    [_si], Y
;;   >     jsr    crc16
;;   >
;;   >     plx
;;   >     ply
;;   >     iny
;;   >     dex
;;   >     bne    loop
;;   > ; at the end of the loop _crc contains the 16 bit CRC of the input buffer
;;
;; Parameters:
;;   A - Input byte
;;   _crc - Current CRC-16 value
;;
;; Return:
;;   _crc - Updated CRC-16 value
;;
crc16:
    ; According to https://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks
    ; CRC-16-CCITT (0x1021 (MSBF/normal)) can be computed as follows:
    ; uint8_t  d, s, t;
    ; uint16_t c, r;
    ; …
    ; s = d ^ (c >> 8);
    ; t = s ^ (s >> 4);
    ; r = (c << 8) ^
    ;      t       ^ 
    ;     (t << 5) ^
    ;     (t << 12);
    ; …
    ; so we have :
    ; c = %dddd_cccc_bbbb_aaaa
    ; d = %ffff_eeee
    ; s       = %ffff_eeee ^ %dddd_cccc
    ;         = %hhhh_gggg
    ; s >> 4  = %0000_hhhh
    ; t       = %hhhh_gggg ^ %0000_hhhh
    ;         = %hhhh_iiii
    ; c << 8  = %bbbb_aaaa_0000_0000
    ; t       = %0000_0000_hhhh_iiii
    ; t << 5  = %000h_hhhi_iii0_0000
    ; t << 12 = %iiii_0000_0000_0000
    ;

    ; A contains the input byte.
    ; s = A ^ crc[1] = %hhhh_gggg
    eor    <_crc+1
    sta    <_crc+1
    ; compute A = s >> 4
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    ; save it for latter
    tax
    ; compute %000h_hhh0 = high(t << 5) & %0000_0001
    asl    A
    ; A = %000h_hhh0 ^ %bbbb_aaaa
    eor    <_crc
    sta    <_crc
    ; restore %0000_hhhh
    txa
    ; compute t = %hhhh_gggg ^ %0000_hhhh
    eor    <_crc+1
    sta    <_crc+1
    ; so a = %hhhh_iiii
    ; we still need to xor crc with %iiii_0000_0000_0000 ((t & %0000_1111) << 12)
    ;                           and %0000_000i_iii0_0000 ((t & %0000_1111) << 5 )
    asl    A
    asl    A
    asl    A
    tax
    asl    A
    asl    A
    ; A now contains the low byte of (t << 5)
    eor    <_crc+1
    tay
    ; Y now contains %hhhh_iiii ^ %iii0_0000
    ; so we are done for the low byte of the crc
    txa
    ; A now contains %hiii_i000
    ; and the carry flags contains the 3th bit of t
    ; if we rotate A 1 bit to the left, we will get %iiii_000i
    ; which is exactly what's is missing
    rol    A
    eor    <_crc
    ; swap byte and we are done!
    sta    <_crc+1
    sty    <_crc
    ; and this is Greg Cook's CRC-16 code
    ; For a more "formal" explanation see http://www.6502.org/source/integers/crc-more.html
    rts

;;
;; function: crc32_begin
;; Resets CRC-32 value.
;;
;; Return:
;;   _crc - Updated CRC-32 value
;;
crc32_begin:
    lda    #$ff
    sta    <_crc
    sta    <_crc+1
    sta    <_crc+2
    sta    <_crc+3
    rts

;;
;; function: crc32
;; Computes CRC-32.	
;;
;; Description:
;; This function updates the current CRC-32 with the value of the A register.
;; The following implementation is based on Kevin Horton CRC32 checksum code.
;;
;; For more informations:
;;  - https://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks
;;  - https://wiki.nesdev.com/w/index.php/Calculate_CRC32
;;
;; Assembly call:
;;   > ; reset CRC-32 value
;;   > jsr    crc32_begin 
;;   >
;;   > ; _si contains the address of the input buffer
;;   > ; X contains its size 
;;   > cly
;;   > loop:
;;   >     phy
;;   >     phx
;;   >
;;   >     lda    [_si], Y
;;   >     jsr    crc32
;;   >
;;   >     plx
;;   >     ply
;;   >     iny
;;   >     dex
;;   >     bne    loop
;;   >
;;   > ; finalize CRC-32 computation
;;   > jsr    crc32_end
;;
;; Parameters:
;;   A - Input byte
;;   _crc - Current CRC-32 value
;;
;; Return:
;;   _crc - Updated CRC-32 value
;;
crc32:
    ldx    #$08
    eor    <_crc
    sta    <_crc
@loop:
    lsr    <_crc+3
    ror    <_crc+2
    ror    <_crc+1
    ror    <_crc
    bcc    @next
        lda    #$ed
        eor    <_crc+3
        sta    <_crc+3
        lda    #$b8
        eor    <_crc+2
        sta    <_crc+2
        lda    #$83
        eor    <_crc+1
        sta    <_crc+1
        lda    #$20
        eor    <_crc
        sta    <_crc    
@next:
    dex
    bne   @loop
    rts

;;
;; function: crc32_end
;; Finalizes CRC-32 value.
;;
;; Return:
;;   _crc - Updated CRC-32 value
;;
crc32_end:
    lda    #$ff
    eor    <_crc
    sta    <_crc
    lda    #$ff
    eor    <_crc+1
    sta    <_crc+1    
    lda    #$ff
    eor    <_crc+2
    sta    <_crc+2
    lda    #$ff
    eor    <_crc+3
    sta    <_crc+3
    rts