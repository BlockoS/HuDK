;;
;; Title: VDC Functions.
;;

;;
;; function: vdc_set_read
;; Set VDC VRAM read pointer.
;;
;; Parameters:
;;   _di - VRAM location.
;;
vdc_set_read:
    vdc_reg #VDC_MARR
    stw    <_di, video_data
    vdc_reg #VDC_DATA
    rts

;;
;; function: vdc_set_write
;; Set VDC VRAM write pointer.
;;
;; Parameters:
;;   _di - VRAM location.
;;
vdc_set_write:
    vdc_reg #VDC_MAWR
    stw    <_di, video_data
    vdc_reg #VDC_DATA
    rts

;;
;; function: vdc_set_bat_size
;; Set background map virtual size.
;;
;; Parameters:
;;   A - BAT size (see <Background Map Virtual Size>) 
;;
vdc_set_bat_size:
    and    #%01110000
    pha
    vdc_reg #VDC_MWR
    pla
    sta    video_data_l
    ; compute BAT dimensions
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    tax
    ; -- width
    lda    bat_width_array, X
    sta    vdc_bat_width
    stz    vdc_bat_width+1
    dec    A
    sta    vdc_bat_hmask
    ; -- height
    lda    bat_height_array, X
    sta    vdc_bat_height
    dec    A
    sta    vdc_bat_vmask
    rts

; BAT width
bat_width_array:  .byte $20,$40,$80,$80,$20,$40,$80,$80
; BAT height
bat_height_array: .byte $20,$20,$20,$20,$40,$40,$40,$40

;;
;; function: vdc_calc_addr
;; Compute VRAM address for a given tile in BAT.
;;
;; Parameters:
;;   X - BAT x coordinate.
;;   A - BAT y coordinate.
;;
;; Return:
;;   _di - VRAM location
;;
vdc_calc_addr:
    ; BAT address formula :
    ;   addr = (bat_y * bat_width) + bat_x
    ; the multiplication can be safely replaced by bit shifts as bat_width
    ; is either 32, 64 or 128.
    phx
    and   vdc_bat_vmask
    stz   <_di
    ldx   vdc_bat_width
    cpx   #64
    beq   @w_64
    cpx   #128
    beq   @w_128
@w_32:
    lsr   A
    ror   <_di
@w_64:
    lsr   A
    ror   <_di
@w_128:
    lsr   A
    ror   <_di
    sta   <_di+1
    ; bat_x can be added with a simple bit OR.
    pla
    and   vdc_bat_hmask
    ora   <_di
    sta   <_di
    rts

;;
;; function: vdc_load_data
;; Copy data to VRAM.
;;
;; Parameters:
;;   _di - VRAM address where the data will be copied.
;;   _bl - first bank of the source data.
;;   _si - data address.
;;   _cx - number of words to copy.
;;
vdc_load_data:
    jsr    map_data
    jsr    vdc_set_write
    
    ldx    <_cl
    beq    @l2
    cly
@l0:
        lda    [_si], Y
        sta    video_data_l
        iny
        lda    [_si], Y
        sta    video_data_h
        iny
        bne    @l1
            inc    <_si+1
@l1:
    dex
    bne    @l0
    jsr    remap_data 
@l2:
    dec    <_ch
    bpl    @l0

    jsr    unmap_data

    rts

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
@l0:
    lda    @vdc_init_table, Y
    sta    video_reg
    iny
    lda    @vdc_init_table, Y
    sta    video_data_l
    iny
    lda    @vdc_init_table, Y
    sta    video_data_h
    iny
    cpy    #36
    bne    @l0
   
    ; set BAT size
    lda    #VDC_DEFAULT_BG_SIZE
    jsr    vdc_set_bat_size

    ; make BAT point to a blank tile
    ; we choose a tile that will not cross bat (even for 128x128)
    st0    #VDC_MAWR
    st1    #$00
    st2    #$00

  .if (VDC_DEFAULT_BG_SIZE = VDC_BG_32x32)
@tile_addr = (32*32*2)
  .else
    .if ((VDC_DEFAULT_BG_SIZE = VDC_BG_64x32) | (VDC_DEFAULT_BG_SIZE = VDC_BG_32x64))
@tile_addr = (64*32*2)
    .else
      .if ((VDC_DEFAULT_BG_SIZE = VDC_BG_64x64) | (VDC_DEFAULT_BG_SIZE = VDC_BG_128x32))
@tile_addr = (64*64*2)
      .else
@tile_addr = (128*128*2)
      .endif
    .endif
  .endif
    st0    #VDC_DATA
    ldy    #high(@tile_addr)
@l1:
    clx
@l2:
        st1    #low(@tile_addr>>4)
        st2    #high(@tile_addr>>4)
        inx
        bne    @l2
    dey
    bne    @l1

    ; clear tile
    st0    #VDC_MAWR
    st1    #low(@tile_addr)
    st2    #high(@tile_addr)

    st0    #VDC_DATA
    st1    #$00
    ldx    #$10
@l3:
        st2    #$00
    dex
    bne    @l3
 
    rts

; Default VDC initialization table.
@vdc_init_table:
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

