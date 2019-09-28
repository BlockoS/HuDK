;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

    .bss
user_hook:  .res 14, 0

	.code

;
; Enable one or multiples IRQ interrupts.
  .macro irq_on i
    lda    #(i ^ INT_ALL)
    sta    irq_disable
  .endmacro
;
; Disable one or multiples IRQ interrupts.
;
  .macro irq_off i
    lda    #i
    sta    irq_disable
  .endmacro
