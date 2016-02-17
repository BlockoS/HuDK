  .include "pceas/macro.inc"
  .include "pceas/word.inc"
  .include "irq.inc"
  .include "io.inc"
  .include "vdc.inc"
  .include "vce.inc"
  .include "pceas/irq.inc"
  
  .if !(CDROM)
    ; IRQ vectors (HuCard only)
    .bank 0
    .org  $fff6
    .dw   _irq_2
    .dw   _irq_1
    .dw   _timer
    .dw   _nmi
    .dw   _reset

    .org  $e000
    .ifndef OVERRIDE_IRQ_RESET
      .include "irq_reset.s"
    .endif
    .ifndef OVERRIDE_IRQ_NMI
      .include "irq_nmi.s"
	.endif
    .ifndef OVERRIDE_IRQ_TIMER
      .include "irq_timer.s"
    .endif
    .ifndef OVERRIDE_IRQ_1
      .include "irq_1.s"
    .endif
    .ifndef OVERRIDE_IRQ_2
      .include "irq_2.s"
    .endif
  .else
    ; [todo]
  .endif ; !(CDROM)
