; $fffc NMI handler
; TODO : is NMI really used on PCE (Hucard) ? several docs state for no.
; 			perhaps on SGX ou PCECD ?

_nmi:
    bbs3   <irq_m, @user_hook
    rti
@user_hook:

; TODO : jmp and no jsr + rti ?
    jmp    [nmi_hook]

