;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Title: Clock
;;

    .bss
;;
;; ubyte: clock_hh
;; System clock, hours since startup (0-255)
;;
clock_hh .ds 1
;;
;; ubyte: clock_mm
;; System clock, minutes since startup (0-59)
;;
clock_mm .ds 1
;;
;; ubyte: clock_ss
;; system clock, seconds since startup (0-59)
;;
clock_ss .ds 1
;;
;; ubyte: clock_tt
;; System clock, ticks (1/60th sec) since startup (0-59)
;;
clock_tt .ds 1

  .ifdef HUC
_clock_hh = clock_hh
_clock_mm = clock_mm
_clock_ss = clock_ss
_clock_tt = clock_tt
  .endif

    .code
;;
;; Macro: clock_reset
;;
;; Reset system clock.
;;
  .macro clock_reset
    stz    clock_tt
    stz    clock_ss
    stz    clock_mm
    stz    clock_hh
  .endmacro

;; Macro: clock_update
;;
;; Update system clock.
;;
  .macro clock_update
    lda    clock_tt
    inc    A
    cmp    #60
    bne    @ticks
        lda    clock_ss
        inc    A
        cmp    #60
        bne    @seconds
            lda    clock_mm
            inc    A
            cmp    #60
            bne    @minutes
                inc    clock_hh
                cla
@minutes:
            sta    clock_mm
            cla
@seconds:
        sta    clock_ss
        cla
@ticks:
    sta    clock_tt
  .endmacro