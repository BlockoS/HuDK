; Reset interrupt (HuCard only).
; This routine is called when the console is powered up.
_reset:
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
    timer_disable              ; disable timer
    irq_enable #INT_NONE       ; disable interrupts
    timer_ack                  ; reset timer
    
    jmp _init
