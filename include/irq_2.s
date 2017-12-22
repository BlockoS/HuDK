;; $fff6 IRQ2 (External IRQ, BRK) handler
;; TODO : CD specific handler ?

_irq_2:
	phy
	phx
	pha


	; TODO : any HuDK dedicated stuff goes here

    bbr0   <irq_m, @no_hook ;6 + 2	
	
	;vs
	;lda	<irq_m		;4
	;bit #0			;2
	;be  @no_hook	;2+2


	; since jsr [xxx] doesn't exist, let's do the trick !
    jsr    @user_irq2

@no_hook:
    pla
    plx
    ply

	rti
	
@user_irq2:
	jmp [irq2_hook]