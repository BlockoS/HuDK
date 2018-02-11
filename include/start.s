  .ifdef MAGICKIT
    .include "pceas/start.s"
  .else
    .ifdef CA65
      .include "ca65/start.s"
    .endif
  .endif
