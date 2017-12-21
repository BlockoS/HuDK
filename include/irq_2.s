;; $fff6 IRQ2 (External IRQ, BRK) handler
;; TODO : CD specific handler ?

_irq_2:
    bbs0   <irq_m, @user_hook
    rti
@user_hook:

; TODO : jmp and no jsr + rti ?
    jmp    [irq2_hook]
