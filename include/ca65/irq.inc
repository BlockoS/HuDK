;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

    .bss
user_hook:  .res 14, 0

	.code

;
; Enable one or multiples IRQ interrupts.
  .macro irq_on i
    .if (i <= INT_ALL)
    lda    #(i ^ INT_ALL)
    .else
      .error "invalid IRQ mask"
    .endif
    sta    irq_disable
  .endmacro
;
; Disable one or multiples IRQ interrupts.
;
  .macro irq_off i
    .if (i <= INT_ALL)
    lda    #i
    .else
      .error "invalid IRQ mask"
    .endif
    sta    irq_disable
  .endmacro

;
; Enable IRQ vector.
;
  .macro irq_enable_vec i
    .if (i = 0)
     smb0   <irq_m
    .elseif (i = 1)
     smb1   <irq_m
    .elseif (i = 2)
     smb2   <irq_m
    .elseif (i = 3)
     smb3   <irq_m
    .elseif (i = 4)
     smb3   <irq_m
    .elseif (i = 5)
     smb6   <irq_m
    .elseif (i = 6)
     smb6   <irq_m
    .else
      .error "invalid IRQ vector"
    .endif
  .endmacro

;
; Disable IRQ vector.
;
  .macro irq_disable_vec i
    .if (i = 0)
     rmb0   <irq_m
    .elseif (i = 1)
     rmb1   <irq_m
    .elseif (i = 2)
     rmb2   <irq_m
    .elseif (i = 3)
     rmb3   <irq_m
    .elseif (i = 4)
     rmb3   <irq_m
    .elseif (i = 5)
     rmb6   <irq_m
    .elseif (i = 6)
     rmb6   <irq_m
    .else
      .error "invalid IRQ vector"
    .endif
  .endmacro

;
; Set user interrupt functions.
;
  .macro irq_set_vec i, vec
    sei                     ; disable interrupts

    lda    #i
    asl    A                ; compute offset in user function table
    tax
    __low  lda, vec         ; store routine address
    sta    user_hook, X
    inx
    __high  lda, vec        ; store routine address
    sta    user_hook, X
  .endmacro
