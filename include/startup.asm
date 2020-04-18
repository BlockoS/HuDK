;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; [todo] CDROM

    .code
    .bank 0
    .org $fff6
    
    ; IRQ vectors (HuCard only) at $fff6-$ffff 
    .dw _irq_2  ;see irq_2.s 
    .dw _irq_1  ;see irq_1.s
    .dw _timer  ;see irq_timer.s
    .dw _nmi    ;see irq_nmi
    .dw _reset  ;see irq_reset

    .code
    .bank 0
    .org $e000

    .include "macro.inc"
    .include "mpr.inc"
    .include "byte.inc"
    .include "word.inc"
    .include "system.inc"
    .include "memcpy.inc"
    .include "vdc.inc"
    .include "vce.inc"
    .include "psg.inc"
    .include "irq.inc"
    .include "clock.inc"

  .ifdef HUC
    .include "huc.inc"
  .endif

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
    .include "sprite.s"
    .include "vce.s"
    .include "font.s"
    .include "print.s"
    .include "map.s"
    .include "math.s"
    .include "bcd.s"
    .include "random.s"
    .include "scroll.s"

  .ifdef HUC
    .include "huc.s"
  .endif