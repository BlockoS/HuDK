  .ifndef CDROM

    ; IRQ vectors (HuCard only) at $fff6-$ffff 
    .segment "VECTORS" 
    .word   _irq_2	;see irq_2.s 
    .word   _irq_1  ;see irq_1.s
    .word   _timer  ;see irq_timer.s
    .word   _nmi    ;see irq_nmi
    .word   _reset  ;see irq_reset

    ; use a dedicated segment to be sure code start at 0x6000
    ; sice ca65 doesn't handle .org
    .segment "STARTUP"

    ; needed by CC65 :(
    .export         __STARTUP__ : absolute = 1      ; Mark as startup

    .include "irq_reset.s"
    .include "irq_nmi.s"
    .include "irq_timer.s"
    .include "irq_1.s"
    .include "irq_2.s"
  .else
    ; [todo]
  .endif ; !(CDROM)
