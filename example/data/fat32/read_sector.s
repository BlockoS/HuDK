    .code
;
; function: read_sector
; Copies 512 bytes from the specified sector to the destination
; buffer.
;
; Parameters:
;   _ax : sector id
;   _di : output buffer
;
; Return 
;
read_sector:
    clx
@loop:    
    ; look if this sector is not empty
    txa
    asl   A
    tay
    lda   sectors, Y
    cmp   <_al
    bne   @next
    iny
    lda   sectors, Y
    cmp   <_ah
    beq   @found
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