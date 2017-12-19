    .include "hudk.inc"

_irq_2:
    bbs0   <irq_m, @user_hook
    rti
@user_hook
    jmp    [irq2_hook]
