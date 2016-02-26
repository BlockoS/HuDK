  .include "pceas/macro.inc"
  .include "pceas/word.inc"
  .include "pceas/memcpy.inc"
  .include "system.inc"
  .include "memcpy.inc"
  .include "irq.inc"
  .include "io.inc"
  .include "psg.inc"
  .include "vdc.inc"
  .include "vce.inc"
  .include "pceas/irq.inc"
  .include "pceas/vdc.inc"
 
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

	.include "psg.s"
	.include "vdc.s"
    .include "vce.s"

  .else
    ; [todo]
  .endif ; !(CDROM)
