;
;
;
irq_reset:
    sei                        ; disable interrupts
    csh                        ; switch cpu to high speed mode
    cld                        ; clear decimal flag
    ldx    #$ff                ; initialize the stack pointer
    txs
    lda    #$ff                ; maps the I/O to the first page
    tam    #$00
    lda    #$f8                ; and the RAM bank to the second page
    tam    #$01
    stz    <$00                ; clear RAM
    tii    $2000, $2001, $1fff
    stz    timer_ctrl          ; disable timer
    lda    #$07                ; disable interrupts
    sta    irq_disable

	timer_ack

	
