.ifndef CDROM

    ; IRQ vectors (HuCard only) at $fff6-$ffff 
    .segment "VECTORS" 
  .word 	_irq_2	;see irq_2.s 
  .word		_irq_1  ;see irq_1.s
  .word		_timer  ;see irq_timer.s
  .word		_nmi    ;see irq_nmi
  .word		_reset  ;see irq_reset
  
	; use a dedicated segment to be sure code start at 0x6000
	; sice ca65 doesn't handle .org
    .segment "STARTUP"

	; needed by CC65 :(
     .export         __STARTUP__ : absolute = 1      ; Mark as startup

	
	; cc65 imports
    .import	zerobss
    ; Linker generated
	.import         __RAM_START__, __RAM_SIZE__
	.import         __DATA_LOAD__,__DATA_RUN__, __DATA_SIZE__
	;.import         __BSS_SIZE__

    ; TODO see if we don't conflict with HuDK ?! with stack pointer handled differently
    .importzp       sp
 
	; handle C's void main(void) and ASM's _main:
	.import	_main
       
    ; imports needed by irq_reset
;    .import vce_init
;    .import vdc_init
;    .import psg_init
	
	
  .include "irq_reset.s"

;; TODO
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
