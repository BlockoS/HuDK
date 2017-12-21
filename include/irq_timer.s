; $fffa see Timer register, at $0C00 

_timer:
    bbs2   <irq_m, @user_hook
    timer_ack     ; acknowledge timer interrupt
    rti

@user_hook:
; TODO : no ack ?

; TODO : save AXY
    jsr    [timer_hook]
; TODO : restore AXY
	rti
	
