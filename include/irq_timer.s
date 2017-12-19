_timer:
    bbs2   <irq_m, @user_hook
    timer_ack     ; acknowledge timer interrupt
    rti
@user_hook:
    jmp    [timer_hook]
