; $fffc NMI handler
; TODO : is NMI really used on PCE (Hucard) ? several docs state for no.
; 			perhaps on SGX ou PCECD ?


;; TODO : why not call user_hook EVERy time ?
_nmi:
    bbs3   <irq_m, @user_hook
    rti

@user_hook:
	phy
	phx
	pha

    jsr    [nmi_hook]

    pla
    plx
    ply

	rti
