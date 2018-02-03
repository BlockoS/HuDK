;;
;; Title: Joypad port.
;;

;;
;; ushort: joyport
;; I/O port.
;;
;; The joypad port uses a 8-pin connector. 
;;
;;   pin 1 - Vcc
;;   pin 2 - D0
;;   pin 3 - D1
;;   pin 4 - D2
;;   pin 5 - D3
;;   pin 6 - SEL
;;   pin 7 - CLR
;;   pin 8 - GND
;;
;; Reading <joyport> returns the states of states of pins 2,3,4 and 5 as long
;; as the following informations :
;;
;;   bit 7 - CD-ROM base unit presence (<IO_CD_MASK>)
;;   bit 6 - Country detection (<IO_COUNTRY_MASK>)
;;   bit 5 - Unused (always 1)
;;   bit 4 - Unused (always 1)
;;   bit 3 - Joypad port 5 (D3)
;;   bit 2 - Joypad port 4 (D2)
;;   bit 1 - Joypad port 3 (D1)
;;   bit 0 - Joypad port 2 (D0)
;;
;; Writing bit 0 and 1 of the <joyport> will update pin 6 and 7 states.
;;
;;   bit 1 - Joypad port 7 (CLR)
;;   bit 0 - Joypad port 6 (SEL)
;;
joyport = $1000

;;
;; Group: I/O port bit mask.
;;

;;
;; bits: IO_CD_MASK
;; CD-ROM base unit sense bit.
;;
;; This bit is set to 0 if a CD-ROM is attached and 1 otherwise.
;;
IO_CD_MASK      = %10000000
;;
;; bits: IO_COUNTRY_MASK
;; Country detection.
;;
;; This bit is set to 1 for Japanses models (PC-Engine, CoreGrafx, ...) and
;; is set to 0 for US models (TurboGrafx 16).
;;
IO_COUNTRY_MASK = %01000000
;;
;; bits: IO_JOYPAD_MASK
;; Joypad port pin.
;;
;; The first 4 bits of the <joyport> returns the states of the joypad port pins
;; 2,3,4 and 5. 
;; Nevertheless the standard 2-button controller has a 4-way directional pad and
;; and 4 buttons (Select, Run, I and II). The SEL line of the I/O port selects
;; whether the directions of the buttons state are returned when D3-D0 are read.
;; When SEL is high, the directions are returned, and buttons are returned when
;; it is low. Note that the state of D3-DO is inverted. 0 means that a button is
;; pressed and 1 otherwise.
;;
;; >      SEL = 0      SEL = 1
;; > D3 | Run        | Left      |
;; > D2 | Select     | Right     |
;; > D1 | I          | Down      |
;; > D0 | II         | Up        |
;;
;; Unconnected controllers always return $0f in D3-DO.  
;;
;; 
;; Multitap/Turbo tap:
;; This device lets you connect 5 controllers to the joypad port. Each joypad is
;; read sequentially. A transition from zero-to-one on the SEL while holding CLR
;; to zero will switch to the next controller. The sequence is reset by holding
;; SEL to 1 while doing a zero-to one transition on CLR.
;; Note that once all 5 controllers have been read, the multitap will return 
;; $00 for D3-D0 until the sequence is reset again.
;;
IO_JOYPAD_MASK  = %00001111

;;
;; Group: 2-buttons Joypad Bitfield. 
;;

;;
;; bits: IO_JOYPAD_I
;; Bit in the <joyport> for button I (SEL=0). 
;;
IO_JOYPAD_I   = %00000001
;;
;; bits: IO_JOYPAD_II
;; Bit in the <joyport> for button II (SEL=0).  
;;
IO_JOYPAD_II  = %00000010
;;
;; bits: IO_JOYPAD_SEL
;; Bit in the <joyport> for the Select button (SEL=0). 
;;
IO_JOYPAD_SEL = %00000100
;;
;; bits: IO_JOYPAD_RUN
;; Bit in the <joyport> for the RUN button (SEL=0). 
;;
IO_JOYPAD_RUN = %00001000
;;
;; bits: IO_JOYPAD_UP
;; Bit in the <joyport> for the up direction on the D-PAD (SEL=1). 
;;
IO_JOYPAD_UP    = %00000001
;;
;; bits: IO_JOYPAD_RIGHT
;; Bit in the <joyport> for the right direction on the D-PAD (SEL=1). 
;;
IO_JOYPAD_RIGHT = %00000010
;;
;; bits: IO_JOYPAD_DOWN
;; Bit in the <joyport> for the down direction on the D-PAD (SEL=1). 
;;
IO_JOYPAD_DOWN  = %00000100
;;
;; bits: IO_JOYPAD_LEFT
;; Bit in the <joyport> for the left direction on the D-PAD (SEL=1). 
;;
IO_JOYPAD_LEFT  = %00001000

;;
;; Group: 6-buttons Joypad Bitfield. 
;;

;;
;; bits: IO_JOYPAD_III
;; Bit in the <joyport> for button III on a 6-button joypad. 
;;
IO_JOYPAD_III = %00000001
;;
;; bits: IO_JOYPAD_IV
;; Bit in the <joyport> for button IV on a 6-button joypad. 
;;
IO_JOYPAD_IV  = %00000010
;;
;; bits: IO_JOYPAD_V
;; Bit in the <joyport> for button V on a 6-button joypad. 
;;
IO_JOYPAD_V   = %00000100
;;
;; bits: IO_JOYPAD_VI
;; Bit in the <joyport> for button VI on a 6-button joypad. 
;;
IO_JOYPAD_VI  = %00001000

;;
;; macro: joypad_delay
;; 9 cycles delay before reading data after SEL line update.
;;
;; This delay is performed after changing the SEL line before reading data.
;; This ensures the multiplexer is ready and returns the right data.
;; 
  .macro joypad_delay
    pha
    pla
    nop
    nop
  .endmacro

;;
;; ubyte: joypad
;; This array holds the values for 5 2-buttons joypads.
;;

;;
;; ubyte: joytrg 
;; Delta joypad values for 5 2-buttons joypads.
;;

;;
;; ubyte: joyold 
;; Previous 5 joypads values.
;;


;;
;; ubyte: joypad_6
;; This array contains the values for buttons III, IV, V and VI of 5 6-buttons
;; joypads.
;;

;;
;; ubyte: joytrg 
;; Delta joypad values of 5 6-buttons joypads.
;;

;;
;; ubyte: joyold 
;; Previous 5 6-buttons joypad values.
;;

  .ifdef MAGICKIT
    .include "pceas/joypad.inc"
  .else
    .ifdef CA65
    .include "ca65/joypad.inc"
    .endif
  .endif