; IRQ ports
irqport = $1400
; Interrupts disable.
irq_disable = irqport+2
; Interrupts status.
irq_status  = irqport+3

; IRQ interrupt bitfield
INT_NONE  = 0
INT_IRQ_2 = 1
INT_IRQ_1 = 1<<1
INT_TIMER = 1<<2
INT_ALL   = (INT_IRQ_2 | INT_IRQ_1 | INT_TIMER)

; Timer port
timerport = $0c00
; Timer counter register.
; Only the first 6 bits are used. A value of $00 counts as 1, $7f as 128.
timer_cnt  = timerport
; Timer control register.
; Only the first bit is used. The timer is enabled if it is set to 0.
timer_ctrl = timerport+1

; Acknowledge timer interrupt
  .macro timer_ack
    stz    irq_status
  .endmacro

; Disable timer
  .macro timer_disable
    lda    #$01
    sta    timer_ctrl
  .endmacro

; Enable timer
  .macro timer_enable
    stz    timer_ctrl
  .endmacro

; [todo] include compiler specific
