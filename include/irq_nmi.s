    .include "hudk.inc"

_nmi:
    bbs3   <irq_m, @user_hook
    rti
@user_hook:
    jmp    [nmi_hook]

