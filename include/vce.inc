; VCE (Video Color Encoder) port
colorport = $0400

; VCE Control register
color_ctrl = colorport

; VCE control register bitmask
VCE_COLOR_MODE_MASK = %1_0000000
VCE_BLUR_MASK       = %00000_1_00
VCE_DOT_CLOCK_MASK  = %000000_11

; VCE color modes
VCE_COLOR_MODE_BW   = %1_0000000
VCE_COLOR_MODE_RGB  = %0_0000000

; VCE blur
VCE_BLUR_ON  = %00000_1_00
VCE_BLUR_OFF = %00000_0_00

; VCE dot clock
VCE_DOT_CLOCK_10MHZ = %000000_10
VCE_DOT_CLOCK_7MHZ  = %000000_00
VCE_DOT_CLOCK_5MHZ  = %000000_01

; VCE control table index register
color_reg = colorport+2
color_reg.lo = color_reg
color_reg.hi = color_reg+1

; VCE Color table data register
color_data = colorport+4
color_data.lo = color_data
color_data.hi = color_data+1
