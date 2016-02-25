;;
;; Title: VCE Functions.
;;

;;
;; function: vce_init
;; Set VCE dot clock, edge blur and background color.
;;
;; Parameters:
;; *none*
;;
vce_init:
	; set VCE dot clock based on the default resolution.
	; enable edge blur in the same time.
  .if (VDC_DEFAULT_XRES < 268)
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_5MHZ)
  .else
    .if (VDC_DEFAULT_XRES < 356)
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_7MHZ)
    .else
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_10MHZ)
    .endif
  .endif
    sta    color_ctrl

	; set background color to black
	stwz   color_reg
    stwz   color_data
    stw    #256, color_reg
    stwz   color_data
   
    rts
