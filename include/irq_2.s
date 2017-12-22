;; $fff6 IRQ2 (External IRQ, BRK) handler
;; TODO : CD specific handler ?
;; TODO : why not call user_hook EVERy time ?

_irq_2:
    bbs0   <irq_m, @user_hook
    rti
    
@user_hook:
	phy
	phx
	pha

    jsr    [irq2_hook]

    pla
    plx
    ply

	rti