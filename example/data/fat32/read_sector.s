    .code
;
; function: read_sector
; Copies 512 bytes from the specified sector to the destination
; buffer.
;
; Parameters:
;   _ax : sector id bytes 0 and 1
;   _bx : sector id bytes 2 and 3
;   _di : output buffer
;
; Return:
;
read_sector:
    clx
@loop:    
    ; look if this sector is not empty
    txa
    stz    <_si+1
    asl    A
    rol    <_si+1
    asl    A
    rol    <_si+1
    sta    <_si
    
    addw   #sectors, <_si

    cly
@check:
    lda    [_si], Y
    cmp    _al, Y
    bne    @next
    iny
    cpy    #$04
    bne    @check    
    bra    @found
@next:
    inx
    cpx    #sector_used
    bne    @loop
    ; this is an empty sector
@not_found:
    ; clear sector    
    jsr    @clear
    inc    <_di+1
    jsr    @clear    
    rts
@clear:
    cly
    cla
@l0:
    sta    [_di], Y
    iny
    bne    @l0
    rts
    ; it's not empty, copy data
@found:
    ; map bank
    txa
    and    #$70
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    adc    #bank(bank_0000)
    tam    #page(bank_0000)    
    
    ; remap address
    txa
    asl    A
    and    #$1f
    ora    #$40
    sta    <_si+1
    stz    <_si
    
    ; copy data
    memcpy_ex <_si, <_di, #$0200, #SOURCE_INC_DEST_INC
    
    rts