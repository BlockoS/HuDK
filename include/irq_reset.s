; $fffe Reset interrupt (HuCard only).
; This routine is called when the console is powered up.
;
; void __fastcall__ VDC_setVSyncHandler( void (*handler) (void) );
;			reset with NULL
; void __fastcall__ VDC_setHSyncHandler( void (*handler) (void) );
; 			reset with NULL
; TODO : setXXXIRQHandler(cfunc) with cfunc=NULL mean no_hook	

		.code
		
		; from psg.s
		.import psg_init

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

	; TODO (from cc65)
        ;lda     #$F7
        ;tam     #%00000100      ; 4000-5FFF = Save RAM
        ;lda     #1
        ;tam     #%00001000      ; 6000-7FFF  Page 2
        ;lda     #2
        ;tam     #%00010000      ; 8000-9FFF  Page 3
        ;lda     #3
        ;tam     #%00100000      ; A000-BFFF  Page 4
        ;lda     #4
        ;tam     #%01000000      ; C000-DFFF  Page 5
        ;lda     #0
        ;tam     #%10000000      ; e000-fFFF  hucard/syscard bank 0


    
    stz    <$00                ; clear RAM
    tii    $2000, $2001, $1fff
    
    timer_disable              ; disable timer
    irq_off INT_ALL            ; disable interrupts
    timer_ack                  ; reset timer


.ifdef CA65
;TODO is it really needed since we zeroed RAM ?
        ; Clear the BSS data
        jsr     zerobss

        ; Copy the .data segment to RAM
        tii     __DATA_LOAD__, __DATA_RUN__, __DATA_SIZE__

        ; Set up the stack
        lda     #<(__RAM_START__+__RAM_SIZE__)
        ldx     #>(__RAM_START__+__RAM_SIZE__)
        sta     sp
        stx     sp + 1
.endif

; TODO reset irq_hooks to no_hook




	cli							; enable interrup

_init:
    memcpy_init                ; initialize memcpy ramcode
								; !! macro, not proc


	jsr reset_hooks

;todo
    jsr    psg_init            ; initialize sound (mute everything)
;    jsr    vdc_init            ; initialize display with default values
;                               ; bg, sprites and display interrupts are disable
;    jsr    vce_init            ; initialize dot clock, background and border
;                               ; color.

	; todo : enable interrupt ?
	; todo : enabmle BG/Sprite ?
	; or let user does it ?

    ; [todo] set default/dummy interrupts hooks if needed
    jsr  _main
    
	jmp	_reset
	
; reset all hooks
reset_hooks:
	stz		<irq_m
	
	lda     #<(no_hook)
	ldx     #>(no_hook)
	
	sta     irq2_hook
	stx     irq2_hook+1

	sta     irq1_hook
	stx     irq1_hook+1

	sta     timer_hook
	stx     timer_hook+1

	sta     nmi_hook
	stx     nmi_hook+1

	sta     vsync_hook
	stx     vsync_hook+1

	sta     hsync_hook
	stx     hsync_hook+1

	sta     reset_hook
	stx     reset_hook+1
	
	rts
	
no_hook:
	rts
	
	
	

_VDC_setVSyncHandler:
; TODO : update irq_m
; TODO : check ax=0 (check X only since if X = 0, A is ZP address...no possible)
	lda     #<(no_hook)
	ldx     #>(no_hook)

@set:
	sta     vsync_hook
	stx     vsync_hook+1

	rts
	
_VDC_setHSyncHandler:
; TODO : update irq_m
; TODO : check ax=0 (check X only since if X = 0, A is ZP address...no possible)
	lda     #<(no_hook)
	ldx     #>(no_hook)

@set:
	sta     hsync_hook
	stx     hsync_hook+1

	rts
