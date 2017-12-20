.ifndef CDROM

    ; IRQ vectors (HuCard only)
    .segment "VECTORS"
  .word 	_irq_2
  .word		_irq_1
  .word		_timer
  .word		_nmi
  .word		_reset 
  
  
    .segment "STARTUP"

	; needed by CC65 :(
     .export         __STARTUP__ : absolute = 1      ; Mark as startup


	.import	_main
       
;    .import vce_init
;    .import vdc_init
;    .import psg_init
	
	
  .include "irq_reset.s"
;  .include "irq_nmi.s"
_nmi:
;  .include "irq_timer.s"
_timer:
;  .include "irq_1.s"
_irq_1:
;  .include "irq_2.s"
_irq_2:
	rti
	
	
.else
    ; [todo]
.endif ; !(CDROM)
