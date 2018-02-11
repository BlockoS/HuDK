; $fffe Reset interrupt (HuCard only).
; This routine is called when the console is powered up.

_reset:
    sei                        ; disable interrupts
    csh                        ; switch cpu to high speed mode
    cld                        ; clear decimal flag
    
    ldx    #$ff                ; initialize the stack pointer ($21ff)
    txs
    
    lda    #$ff                ; maps the I/O to the first page
    tam0					   ; 0000-1FFF
    
    lda    #$f8                ; and the RAM bank to the second page
    tam1					   ; 2000-3FFF = Work RAM

    stz    <$00                ; clear RAM
    tii    $2000, $2001, $1fff
    
    timer_disable              ; disable timer
    irq_off INT_ALL            ; disable interrupts
    timer_ack                  ; reset timer

    cli							; enable interrup

_init:
    memcpy_init                ; initialize memcpy ramcode

    jsr    psg_init            ; initialize sound (mute everything)
    jsr    vdc_init            ; initialize display with default values
                               ; bg, sprites and display interrupts are disable
    jsr    vce_init            ; initialize dot clock, background and border
                               ; color.

    ; [todo] set default/dummy interrupts hooks if needed
    jsr  _main
    
	jmp	_reset
	
