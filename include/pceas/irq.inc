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
