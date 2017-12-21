; $fffa see Timer register, at $0C00 

_timer:
    bbs2   <irq_m, @user_hook
    timer_ack     ; acknowledge timer interrupt
    rti

@user_hook:
; TODO : jmp and not jsr + rti ? problem with C ?
; TODO : no ack ?
    jmp    [timer_hook]
