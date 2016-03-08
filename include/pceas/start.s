  .if !(CDROM)
    ; IRQ vectors (HuCard only)
    .code
    .bank 0
    .org  $fff6
    .dw   _irq_2
    .dw   _irq_1
    .dw   _timer
    .dw   _nmi
    .dw   _reset

    .org  $e000
    .include "irq_reset.s"
    .include "irq_nmi.s"
    .include "irq_timer.s"
    .include "irq_1.s"
    .include "irq_2.s"

    .include "utils.s"
	.include "psg.s"
	.include "vdc.s"
    .include "vce.s"
    .include "font.s"
    .include "print.s"
    .include "map.s"
  .else
    ; [todo]
  .endif ; !(CDROM)
