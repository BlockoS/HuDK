;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
  .ifdef MAGICKIT
    .include "pceas/compat.inc"
  .else
    .ifdef CA65
    .include "ca65/compat.inc"
    .endif
  .endif

; [todo] CDROM

  .ifdef MAGICKIT
    .code
    .bank 0
    .org $fff6
  .else
    .ifdef CA65
    .segment "VECTORS" 
    .endif
  .endif
    
    ; IRQ vectors (HuCard only) at $fff6-$ffff 
    .word _irq_2  ;see irq_2.s 
    .word _irq_1  ;see irq_1.s
    .word _timer  ;see irq_timer.s
    .word _nmi    ;see irq_nmi
    .word _reset  ;see irq_reset

    .code
  .ifdef MAGICKIT
    .bank 0
    .org $e000
  .endif

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
    .include "vdc_sprite.s"
    .include "vce.s"
    .include "font.s"    
    .include "font.inc"
    .include "print.s"
    .include "map.s"
    .include "math.s"
    .include "bcd.s"
