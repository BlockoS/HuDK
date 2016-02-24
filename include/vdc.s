;;
;; Title: VDC Functions.
;;

    .ifndef VDC_DEFAULT_XRES
VDC_DEFAULT_XRES = 256
    .endif
    
    .ifndef VDC_DEFAULT_SATB_ADDR
VDC_DEFAULT_SATB_ADDR = $7F00
    .endif

;;
;; function: vdc_init
;; Initialize VDC.
;; 
;; Details:
;; [todo]
;;
;; Parameters:
;; *none*
;;
vdc_init:
    cly
.l0:
    lda    .vdc_init_table, Y
    sta    video_reg
    iny
    lda    .vdc_init_table, Y
    sta    video_data_l
    iny
    lda    .vdc_init_table, Y
    sta    video_data_h
    iny
    cpy    #36
    bne    .l0

    ; [todo] set x resolution
    ; [todo] set scroll position

    rts

; Default VDC initialization table.
.vdc_init_table:
    .byte $05, $00, $00             ; CR  control register
    .byte $06, $00, $00             ; RCR scanline interrupt counter
    .byte $07, $00, $00             ; BXR background horizontal scroll offset
    .byte $08, $00, $00             ; BYR      "     vertical     "      " 
    .byte $09, VDC_BG_64x64, $00    ; MWR backgroup map virtual size
    .byte $0A                       ; HSR +
     VDC_HSR_db VDC_DEFAULT_XRES    ;     |
    .byte $0B                       ; HDR |
     VDC_HDR_db VDC_DEFAULT_XRES    ;     | display size and synchro
    .byte $0C, $02, $17             ; VPR |
    .byte $0D, $DF, $00             ; VDW |
    .byte $0E, $0C, $00             ; VCR +
    .byte $0F, $10, $00             ; DCR DMA control register
    .byte $13                       ; SATB adddress
    .byte low(VDC_DEFAULT_SATB_ADDR)
    .byte high(VDC_DEFAULT_SATB_ADDR)


