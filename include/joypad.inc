;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

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
;; bits: JOYPAD_I
;; Bit in the joypad for button I.
;;
JOYPAD_I = IO_JOYPAD_I
;;
;; bits: JOYPAD_II
;; Bit in the joypad for button II.
;;
JOYPAD_II = IO_JOYPAD_II
;;
;; bits: JOYPAD_III
;; Bit in the joypad for button III.
;;
JOYPAD_III = IO_JOYPAD_III
;;
;; bits: JOYPAD_IV
;; Bit in the joypad for button IV.
;;
JOYPAD_IV = IO_JOYPAD_IV
;;
;; bits: JOYPAD_VI
;; Bit in the joypad for button VI.
;;
JOYPAD_V = IO_JOYPAD_V
;;
;; bits: JOYPAD_VI
;; Bit in the joypad for button VI.
;;
JOYPAD_VI = IO_JOYPAD_VI
;;
;; bits: JOYPAD_SEL
;; Bit in the joypad for the Select button. 
;;
JOYPAD_SEL = IO_JOYPAD_SEL
;;
;; bits: JOYPAD_RUN
;; Bit in the joypad for the RUN button.
;;
JOYPAD_RUN = IO_JOYPAD_RUN
;;
;; bits: JOYPAD_UP
;; Bit in the joypad for the up direction. 
;;
JOYPAD_UP = (IO_JOYPAD_UP << 4)
;;
;; bits: JOYPAD_RIGHT
;; Bit in the joypad for the right direction. 
;;
JOYPAD_RIGHT = (IO_JOYPAD_RIGHT << 4)
;;
;; bits: JOYPAD_DOWN
;; Bit in the joypad for the down direction.. 
;;
JOYPAD_DOWN = (IO_JOYPAD_DOWN << 4)
;;
;; bits: JOYPAD_LEFT
;; Bit in the joypad for the left direction. 
;;
JOYPAD_LEFT = (IO_JOYPAD_LEFT << 4)

    .bss
;;
;; ubyte: joypad
;; This array holds the values for 5 2-buttons joypads.
;;
joypad .ds 5

;;
;; ubyte: joytrg 
;; Delta joypad values for 5 2-buttons joypads.
;;
joytrg .ds 5

;;
;; ubyte: joyold 
;; Previous 5 joypads values.
;;
joyold .ds 5

;;
;; ubyte: joypad_6
;; This array contains the values for buttons III, IV, V and VI of 5 6-buttons
;; joypads.
;;
joypad_6 .ds 5

;;
;; ubyte: joytrg 
;; Delta joypad values of 5 6-buttons joypads.
;;
joytrg_6 .ds 5

;;
;; ubyte: joyold 
;; Previous 5 6-buttons joypad values.
;;
joyold_6 .ds 5

  .ifdef HUC
_joypad = joypad
_joytrg = joytrg
_joyold = joyold
_joypad_6 = joypad_6
_joytrg_6 = joytrg_6
_joyold_6 = joyold_6
  .endif

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
;; macro: joypad_reset_multitap
;; Reset multitap to the first joypad.
;; 
  .macro joypad_reset_multitap
    lda    #$01         ; reset multitap to joypad #1
    sta    joyport
    lda    #$03
    sta    joyport
    joypad_delay
  .endmacro

;;
;; macro: joypad_poll
;; Read joypad state.
;; 
  .macro joypad_poll
    lda    #$01         ; read directions (SEL=1)
    sta    joyport
    joypad_delay

    lda    \1, X
    sta    \2, X
    lda    joyport
    asl    A
    asl    A
    asl    A
    asl    A
    sta    \1, X

    stz    joyport      ; read buttons (SEL=0)
    joypad_delay

    lda    joyport
    and    #$0f
    ora    \1, X
    eor    #$ff
    sta    \1, X
  .endmacro
