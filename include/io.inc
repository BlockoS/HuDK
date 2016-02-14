; IO port.
; It is named joyport for history reasons.
joyport = $1000

; IO port bit mask.
; CD-ROM base unit sense bit.
; This bit is set to 0 if a CD-ROM is attached and 1 otherwise.
IO_CD_MASK      = %1000_0000
; Country detection.
; This bit is set to 1 for Japanses models (PC-Engine, CoreGrafx, ...) and
; is set to 0 for US models (TurboGrafx 16).
IO_COUNTRY_MASK = %0100_0000
; Joypad port pin.
; Only the first two bits are writeable. 
IO_JOYPAD_MASK  = %0000_1111
; Joypad port pin details.
; When select is low (=0) reading joyport gives I,II,SEL,RUN.
IO_JOYPAD_I   = %0000_0001
IO_JOYPAD_II  = %0000_0010
IO_JOYPAD_SEL = %0000_0100
IO_JOYPAD_RUN = %0000_1000
; When select is high (=1) reading joyport gives UP,RIGHT,DOWN,LEFT.
IO_JOYPAD_UP    = %0000_0001
IO_JOYPAD_RIGHT = %0000_0010
IO_JOYPAD_DOWN  = %0000_0100
IO_JOYPAD_LEFT  = %0000_1000
; 6 button joypad bit values.
IO_JOYPAD_III = %0000_0001
IO_JOYPAD_IV  = %0000_0001
IO_JOYPAD_V   = %0000_0001
IO_JOYPAD_VI  = %0000_0001

; Bit values for joypad bytes.
JOY_I     = $01
JOY_II    = $02
JOY_SEL   = $04
JOY_RUN   = $08
JOY_UP    = $10
JOY_RIGHT = $20
JOY_DOWN  = $40
JOY_LEFT  = $80
; Bit values for 6 buttons joypad.
JOY_TYPE6 = $50
JOY_III   = $01
JOY_IV    = $02
JOY_V     = $04
JOY_VI    = $04
