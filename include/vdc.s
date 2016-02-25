;;
;; Title: VDC Functions.
;;

;;
;; function: vdc_init
;; Initialize VDC.
;; 
;; Details:
;; Initialize VDC registers, and setup BAT.
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
   
    ; make BAT point to a blank tile
    ; we choose a tile that will not cross bat (even for 128x128)
    st0    #VDC_MAWR
    st1    #$00
    st2    #$00

  .if (VDC_DEFAULT_BG_SIZE = VDC_BG_32x32)
.tile_addr = (32*32*2)
  .else
    .if ((VDC_DEFAULT_BG_SIZE = VDC_BG_64x32) | (VDC_DEFAULT_BG_SIZE = VDC_BG_32x64))
.tile_addr = (64*32*2)
    .else
      .if ((VDC_DEFAULT_BG_SIZE = VDC_BG_64x64) | (VDC_DEFAULT_BG_SIZE = VDC_BG_128x32))
.tile_addr = (64*64*2)
      .else
.tile_addr = (128*128*2)
      .endif
    .endif
  .endif
    st0    #VDC_DATA
    ldy    #high(.tile_addr)
.l1:
    clx
.l2:
        st1    #low(.tile_addr>>4)
        st2    #high(.tile_addr>>4)
        inx
        bne    .l2
    dey
    bne    .l1

    ; clear tile
    st0    #VDC_MAWR
    st1    #low(.tile_addr)
    st2    #high(.tile_addr)

    st0    #VDC_DATA
    st1    #$00
    ldx    #$10
.l3:
        st2    #$00
    dex
    bne    .l3
 
    rts

; Default VDC initialization table.
.vdc_init_table:
    .byte $05, $00, $00             ; CR  control register
    .byte $06, $00, $00             ; RCR scanline interrupt counter
    .byte $07, $00, $00             ; BXR background horizontal scroll offset
    .byte $08, $00, $00             ; BYR      "     vertical     "      " 
    .byte $09, VDC_DEFAULT_BG_SIZE  ; MWR backgroup map virtual size
    .byte $00                       ;
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


