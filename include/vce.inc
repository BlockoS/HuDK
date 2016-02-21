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
color_reg.lo = color_reg
color_reg.hi = color_reg+1

;;
;; ushort: color_data
;; VCE Color table data register.
;;
color_data = colorport+4
color_data.lo = color_data
color_data.hi = color_data+1

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
VCE_COLOR_MODE_MASK = %1_0000000
;;
;; bits: VCE_BLUR_MASK
;; Bit 2 is used to enable or disable sprites and background characters edge
;; blur.
;;
VCE_BLUR_MASK = %00000_1_00
;;
;; bits: VCE_DOT_CLOCK_MASK
;; Bits 0 and 1 selects the dot clock. This determines how many pixels are
;; displayed on each horizontal line.
;;
VCE_DOT_CLOCK_MASK  = %000000_11

;;
;; Group: VCE color modes
;;

;;
;; bits: VCE_COLOR_MODE_BW
;; Black and white video.
;;
VCE_COLOR_MODE_BW   = %1_0000000
;;
;; bits: VCE_COLOR_MODE_RGB
;; Color video.
;;
VCE_COLOR_MODE_RGB  = %0_0000000

;;
;; Group: VCE blur.
;;

;;
;; bits: VCE_BLUR_ON
;; Blur edges of the sprites and background characters. 
;;
VCE_BLUR_ON  = %00000_1_00
;;
;; bits: VCE_BLUR_OFF
;; Disable edges blur.
;;
VCE_BLUR_OFF = %00000_0_00

;;
;; Group: VCE dot clock.
;;

;;
;; bits: VCE_DOT_CLOCK_10MHZ
;; 10MHz dot clock.
;;
VCE_DOT_CLOCK_10MHZ = %000000_10
;;
;; bits: VCE_DOT_CLOCK_7MHZ
;; 7MHz dot clock.
;;
VCE_DOT_CLOCK_7MHZ  = %000000_00
;;
;; bits: VCE_DOT_CLOCK_5MHZ
;; 5MHz dot clock.
;;
VCE_DOT_CLOCK_5MHZ  = %000000_01

