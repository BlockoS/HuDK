    .bss
user_hook  .ds 14

	.code

;
; Enable one or multiples IRQ interrupts.
  .macro irq_on
    .if (\1 <= INT_ALL)
    lda    #(\1 ^ INT_ALL)
    .else
      .fail "invalid IRQ mask"
    .endif
    sta    irq_disable
  .endmacro
;
; Disable one or multiples IRQ interrupts.
;
  .macro irq_off
    .if (\1 <= INT_ALL)
    lda    #\1
    .else
      .fail "invalid IRQ mask"
    .endif
    sta    irq_disable
  .endmacro

;
; Enable IRQ vector.
;
  .macro irq_enable_vec
    .if (\1 = 5)
     smb    #6, <irq_m
    .else
     smb    \1, <irq_m
    .endif
  .endmacro

;
; Disable IRQ vector.
;
  .macro irq_disable_vec
    .if (\1 = 5)
     rmb    #6, <irq_m
    .else
     rmb    \1, <irq_m
    .endif
  .endmacro

;
; Set user interrupt functions.
;
  .macro irq_set_vec
    sei                     ; disable interrupts

    lda    \1
    asl    A                ; compute offset in user function table
    tax
    lda    LOW_BYTE \2      ; store routine address
    sta    user_hook, X
    inx
    lda    HIGH_BYTE \2
    sta    user_hook, X
  .endmacro
