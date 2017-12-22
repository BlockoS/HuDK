; $fffa see Timer register, at $0C00 

_timer:
    timer_ack     ; acknowledge timer interrupt

    bbs2   <irq_m, @user_hook
    rti

@user_hook:
	phy
	phx
	pha

    jsr    [timer_hook]

    pla
    plx
    ply

	rti
	
