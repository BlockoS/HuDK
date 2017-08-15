;;
;; Title: Memory copy.
;;
;; As tia, tii, tin, etc... only takes immediate values as arguments, the trick
;; is to have the copy instruction in ram and modify the arguments. 
;;

;;
;; Group: Copy Modes.
;;

;;
;; ubyte: SOURCE_ALT_DEST_INC
;; Alternate source address and increment destination address (TAI).
;;
SOURCE_ALT_DEST_INC = $f3 
;;
;; ubyte: SOURCE_DEC_DEST_DEC = $c3 
;; Decrement source and destination addresses (TDD).
;;
SOURCE_DEC_DEST_DEC = $c3 
;;
;; ubyte: SOURCE_INC_DEST_ALT
;; Increment source address and alternate destination address (TIA).
;;
SOURCE_INC_DEST_ALT = $e3 
;;
;; ubyte: SOURCE_INC_DEST_NOP
;; Increment source address and leave destination address unchanged (TIN).
;;
SOURCE_INC_DEST_NOP = $d3 
;;
;; ubyte: SOURCE_INC_DEST_INC
;; Increment source and destination addresses (TII).
;;
SOURCE_INC_DEST_INC = $73 

;;
;; Group: Memory copy helpers.
;;

;;
;; macro: memcpy_init
;; Initialize memcpy routine.
;;
;; Detail:
;; This macro basically set memcpy_rts to the RTS instruction value.
;;
  .macro memcpy_init
    lda    #$60                    ; RTS opcode value
    sta    <memcpy_rts
    lda    #SOURCE_INC_DEST_ALT    ; Default copy mode
    sta    <memcpy
  .endmacro

;;
;; macro: memcpy_mode
;; Set memcpy mode (see <Copy Modes>).
;;
;; Parameters:
;;   mode - memory copy mode.
;;

;;
;; macro: memcpy_args
;; Set memcpy arguments.
;;
;; Parameters:
;;   src - source.
;;   dst - destination.
;;   len - number of bytes to copy.
;;

;;
;; macro: memcpy_ex
;; Copy *len* bytes from the *src* to *dst*.
;; This is equivalent to :
;;   > memcpy_mode mode
;;   > memcpy_args src, dst, len
;;   > jsr    memcpy
;;
;; Assembly call:
;;   > memcpy_ex <_si, #video_data, #$0100, #SOURCE_INC_DEST_ALT
;;
;; Parameters:
;;   src - source.
;;   dst - destination.
;;   len - number of bytes to copy.
;;   mode - memory copy mode (see <Copy Modes>).
;;          *optinal* (default: SOURCE_INC_DEST_ALT). 
;;

  .ifdef MAGICKIT
    .include "pceas/memcpy.inc"
  .else
    .ifdef CA65
    .include "ca65/memcpy.inc"
    .endif
  .endif 
