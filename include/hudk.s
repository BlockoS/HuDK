  .ifdef PCEAS
    .include "pceas/macro.inc"
  .endif
    .include "word.inc"
    .include "system.inc"
    .include "memcpy.inc"
    .include "irq.inc"
    .include "io.inc"
    .include "psg.inc"
    .include "vdc.inc"
    .include "vce.inc"

  .ifdef PCEAS
    .include "pceas/start.s"
  .else
    .ifdef CA65
    .include "ca65/start.s"
    .endif
  .endif
