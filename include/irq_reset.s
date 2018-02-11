; $fffe Reset interrupt (HuCard only).
; This routine is called when the console is powered up.
  .ifdef MAGICKIT
    .include "pceas/irq_reset.s"
  .else
    .ifdef CA65
    .include "ca65/irq_reset.s"
    .endif
  .endif
