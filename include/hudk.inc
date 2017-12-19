;; include for any projetct based on HuDK
;;
;;  DO NOT include in a HuDK source file

  .ifdef MAGICKIT
    .include "pceas/macro.inc"
  .endif
    .include "byte.inc"
    .include "word.inc"
    .include "system.inc"
    .include "memcpy.inc"
    .include "irq.inc"
    .include "joypad.inc"
    .include "psg.inc"
    .include "vdc.inc"
    .include "vce.inc"
    