_irq_enable.1:
    txa
    eor    #$ff
    sei
    and    irq_disable
    sta    irq_disable
    cli
    rts

_irq_disable.1:
    txa
    sei
    ora    irq_disable
    sta    irq_disable
    cli
    rts

_vdc_wait_vsync:
    vdc_wait_vsync
    rts

_print_char:
    txa
    jmp    print_char

_print_digit:
    txa
    jmp    print_digit

_print_hex:
    txa
    jmp    print_hex

_print_bcd.2:
    ldx    #3
    jmp    print_bcd

_print_bcd:
    ldx    #1
    jmp    print_bcd

_print_dec_u8:
    txa
    jmp    print_dec_u8

_print_dec_u16:
    sax
    jmp    print_dec_u16

_print_hex_u8:
    txa
    jmp    print_hex_u8

_print_hex_u16:
    sax
    jmp    print_hex_u16

_print_string.5:
    ldx    <_cl
    lda    <_ch
    jmp    print_string

_print_string_raw:
    jmp    print_string_raw

_print_string_n.2:
    jmp    print_string_n

_print_fill.5:
    lda    <_ch
    ldx    <_cl
    jmp    print_fill
