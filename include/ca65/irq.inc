    .bss
user_hook:  .res 14, 0



;
; Enable one or multiples IRQ interrupts.
  .macro irq_on i
    lda    #(i ^ INT_ALL)
    sta    irq_disable
  .endmacro
;
; Disable one or multiples IRQ interrupts.
;
  .macro irq_off i
    lda    #i
    sta    irq_disable
  .endmacro
