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
    .include "pceas/macro.inc"
    .include "byte.inc"
    .include "word.inc"
    .include "system.inc"
    .include "memcpy.inc"
    .include "vdc.inc"
    .include "vce.inc"
    .include "psg.inc"
    .include "irq.inc"

    .include "irq_reset.s"
    .include "irq_nmi.s"
    .include "irq_timer.s"
    .include "irq_1.s"
    .include "irq_2.s"

    .include "mpr.s"
    .include "joypad.s"
    .include "psg.s"
    .include "vdc.s"
    .include "vce.s"
    .include "font.s"
    .include "print.s"
    .include "map.s"
    .include "sprite.s"
    .include "math.s"
  .else
    ; [todo]
  .endif ; !(CDROM)
