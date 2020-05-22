    .code

irq_bitmask:
    .db %00000001
    .db %00000010
    .db %00000100
    .db %00001000
    .db %00010000
    .db %01000000
    .db %01000000

_irq_enable_vec.1:
    lda    irq_bitmask, X
    tsb    <irq_m
    rts

_irq_disable_vec.1:
    lda    irq_bitmask, X
    trb    <irq_m
    rts

_irq_set_vec.2:
    php
    sei                     ; disable interrupts

    sta    <_ch
    lda    <_cl
    stx    <_cl

    asl    A                ; compute offset in user function table
    tax
    lda    <_cl             ; store routine address
    sta    user_hook, X
    inx
    lda    <_ch
    sta    user_hook, X
    plp
    rts
