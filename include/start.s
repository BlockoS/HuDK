;; TODO create a crt0.s with concat content of irq_xx.s
;; CC65's start would only inlcude crt0.s
;; while PCEAS's start.s would also include others .s 

  .ifdef MAGICKIT
    .include "pceas/start.s"
  .else
    .ifdef CA65
      .include "ca65/start.s"
    .endif
  .endif
