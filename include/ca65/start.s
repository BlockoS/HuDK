  .ifndef CDROM
    ; IRQ vectors (HuCard only)
    .segment "VECTORS"
    .word _irq_2
    .word _irq_1
    .word _timer
    .word _nmi
    .word _reset

    .code
    .include "irq_reset.s"
    .include "irq_nmi.s"
    .include "irq_timer.s"
    .include "irq_1.s"
    .include "irq_2.s"

    .include "mpr.s"
    .include "psg.s"
    .include "vdc.s"
    .include "vce.s"
    .include "font.s"
    .include "print.s"
  .else
    ; [todo]
  .endif ; !(CDROM)
