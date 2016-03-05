; Enable interrupt.
; \syntax irq_enable flag
; \param [in] flag IRQs flag 
  .macro irq_enable flag
    .if (.match (.left (1, {flag}), #)) 
      lda    flag^7
    .else
      lda    flag
      eor    #$07
    .endif
    sta    irq_disable
  .endmacro
