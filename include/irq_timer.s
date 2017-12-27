; $fffa see Timer register, at $0C00 

_timer:
    timer_ack     ; acknowledge timer interrupt

	phy
	phx
	pha

    bbr2   <irq_m, @no_hook
    jsr    @user_timer

@no_hook:

    pla
    plx
    ply

	rti
	
@user_timer:
	jmp [timer_hook]