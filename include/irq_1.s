_irq_1:
    bbs1   <irq_m, @user_hook
    ; [todo]
    rti
@user_hook:
    jmp    [irq1_hook]
