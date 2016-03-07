; [todo]
_timer:
    stz irq_status ; acknowledge timer interrupt
    rti
