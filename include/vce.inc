;;
;; Section: VCE I/O Ports.
;;
;; Group: Ports.
;;

;;
;; ushort: colorport
;; VCE port.
;;
colorport = $0400
;;
;; ushort: color_ctrl
;; VCE Control register.
;;
color_ctrl = colorport

;;
;; ushort: color_reg
;; VCE control table index register.
;;
color_reg = colorport+2
color_reg_lo = color_reg
color_reg_hi = color_reg+1

;;
;; ushort: color_data
;; VCE Color table data register.
;;
color_data = colorport+4
color_data_lo = color_data
color_data_hi = color_data+1

;;
;; Section: Control Register Flags.
;;

;;
;; Group: VCE control register bitmask.
;;

;;
;; bits: VCE_COLOR_MODE_MASK
;; Bit 7 selects the video mode. 2 modes are available : black & white, and 
;; color.
;;
VCE_COLOR_MODE_MASK = %10000000
;;
;; bits: VCE_BLUR_MASK
;; Bit 2 is used to enable or disable sprites and background characters edge
;; blur.
;;
VCE_BLUR_MASK = %00000100
;;
;; bits: VCE_DOT_CLOCK_MASK
;; Bits 0 and 1 selects the dot clock. This determines how many pixels are
;; displayed on each horizontal line.
;;
VCE_DOT_CLOCK_MASK  = %00000011

;;
;; Group: VCE color modes
;;

;;
;; bits: VCE_COLOR_MODE_BW
;; Black and white video.
;;
VCE_COLOR_MODE_BW   = %10000000
;;
;; bits: VCE_COLOR_MODE_RGB
;; Color video.
;;
VCE_COLOR_MODE_RGB  = %00000000

;;
;; Group: VCE blur.
;;

;;
;; bits: VCE_BLUR_ON
;; Blur edges of the sprites and background characters. 
;;
VCE_BLUR_ON  = %00000100
;;
;; bits: VCE_BLUR_OFF
;; Disable edges blur.
;;
VCE_BLUR_OFF = %00000000

;;
;; Group: VCE dot clock.
;;

;;
;; bits: VCE_DOT_CLOCK_10MHZ
;; 10MHz dot clock.
;;
VCE_DOT_CLOCK_10MHZ = %00000010
;;
;; bits: VCE_DOT_CLOCK_7MHZ
;; 7MHz dot clock.
;;
VCE_DOT_CLOCK_7MHZ  = %00000001
;;
;; bits: VCE_DOT_CLOCK_5MHZ
;; 5MHz dot clock.
;;
VCE_DOT_CLOCK_5MHZ  = %00000000

;;
;; Group: VCE Helper Macros.
;;
 
;;
;; macro: RGB
;; Convert 3bit R, G, B to 9bit palette entry.
;;
;; Parameters:
;;   r - Red
;;   g - Green
;;   b - Blue
;;

  .ifdef MAGICKIT
    .include "pceas/vce.inc"
  .else
    .ifdef CA65
    .include "ca65/vce.inc"
    .endif
  .endif
  