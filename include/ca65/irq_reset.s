; $fffe Reset interrupt (HuCard only).
; This routine is called when the console is powered up.
    .include "irq.inc"
    .include "memcpy.inc"
    .include "vdc.inc"

    .import psg_init	; from psg.s
    .import vdc_init	; from vdc.s
    .import vce_init	; from vce.s
				
    ; cc65 imports
    .import	zerobss

    ; Linker generated
    .import __RAM_START__, __RAM_SIZE__
    .import __DATA_LOAD__,__DATA_RUN__, __DATA_SIZE__
    ;.import __BSS_SIZE__

    ; TODO see if we don't conflict with HuDK ?! with stack pointer handled differently
    .importzp sp

    ; handle C's void main(void) and ASM's _main:
    .import	_main	

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

    lda    #$f7
    tam2            ; 4000-5FFF = Save RAM
    lda    #1
    tam3            ; 6000-7FFF  Page 2
    lda    #2
    tam4            ; 8000-9FFF  Page 3
    lda    #3
    tam5            ; A000-BFFF  Page 4
    lda    #4
    tam6            ; C000-DFFF  Page 5
    lda    #0
    tam7            ; e000-fFFF  hucard/syscard bank 0
    
    stz    <$00                ; clear RAM
    tii    $2000, $2001, $1fff
    
    timer_disable              ; disable timer
    irq_off INT_ALL            ; disable interrupts
    timer_ack                  ; reset timer

    ; Copy the .data segment to RAM
    tii    __DATA_LOAD__, __DATA_RUN__, __DATA_SIZE__

    ; Set up the stack
    lda    #<(__RAM_START__+__RAM_SIZE__)
    ldx    #>(__RAM_START__+__RAM_SIZE__)
    sta    sp
    stx    sp + 1

; TODO reset irq_hooks to no_hook

	cli							; enable interrup

_init:
    memcpy_init                ; initialize memcpy ramcode
                               ; !! macro, not proc
;todo
    jsr    psg_init            ; initialize sound (mute everything)
    jsr    vdc_init            ; initialize display with default values
                               ; bg, sprites and display interrupts are disable
    jsr    vce_init            ; initialize dot clock, background and border
                               ; color.

    ; [todo] set default/dummy interrupts hooks if needed
    jsr  _main
    
	jmp	_reset
	
