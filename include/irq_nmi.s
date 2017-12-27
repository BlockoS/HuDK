; $fffc NMI handler
; TODO : is NMI really used on PCE (Hucard) ? several docs state for no.
; 			perhaps on SGX ou PCECD ?

_nmi:
	phy
	phx
	pha
		
	; TODO : any HuDK dedicated stuff goes here

    bbr3   <irq_m, @no_hook
    jsr	@user_nmi

@no_hook:
    pla
    plx
    ply

	rti

@user_nmi:
	jmp [nmi_hook]