;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; [todo] vdc_disp_on
; [todo] vdc_disp_off
; [todo] clear bat

    .bss
vdc_bat_width  .ds 2
vdc_bat_height .ds 1
vdc_bat_hmask  .ds 1
vdc_bat_vmask  .ds 1
vdc_scr_height .ds 1

  .ifdef HUC
_vdc_bat_width = vdc_bat_width
_vdc_bat_height = vdc_bat_height
_vdc_bat_hmask = vdc_bat_hmask
_vdc_bat_vmask = vdc_bat_vmask
_vdc_scr_height = vdc_scr_height
  .endif

;;
;; Title: VDC Functions.
  .code
;;
;; function: vdc_set_read
;; Set VDC VRAM read pointer.
;;
;; Parameters:
;;   _di - VRAM location.
;;
  .ifdef HUC
_vdc_set_read.1:
  .endif
vdc_set_read:
    vdc_reg  #VDC_MARR
    vdc_data <_di
    vdc_reg  #VDC_DATA
    rts

;;
;; function: vdc_set_write
;; Set VDC VRAM write pointer.
;;
;; Parameters:
;;   _di - VRAM location.
;;
  .ifdef HUC
_vdc_set_write.1:
  .endif
vdc_set_write:
    vdc_reg  #VDC_MAWR
    vdc_data <_di
    vdc_reg  #VDC_DATA
    rts

;;
;; function: vdc_set_bat_size
;; Set background map virtual size.
;;
;; Parameters:
;;   A - BAT size (see <Background Map Virtual Size>) 
;;
  .ifdef HUC
_vdc_set_bat_size.1:
    txa
  .endif
vdc_set_bat_size:
    and    #%01110000
    pha
    vdc_reg #VDC_MWR
    pla
    sta    video_data_l
    st2    #$00
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
bat_width_array:  .db $20,$40,$80,$80,$20,$40,$80,$80
; BAT height
bat_height_array: .db $20,$20,$20,$20,$40,$40,$40,$40

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
  .ifdef HUC
_vdc_calc_addr.2:
    ldx    <_al
    lda    <_ah
    jsr    vdc_calc_addr
  __ldw    <_di
    rts
  .endif
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
;; function: vdc_load_tiles
;; Load 8x8 tiles data to VRAM.
;;
;; Parameters:
;;   _bl - Tile data bank.
;;   _si - Tile data address.
;;   _cx - Tile count.
;;   _di - VRAM destination.
  .ifdef HUC
_vdc_load_tiles.3:

_vdc_load_tiles.4:
  .endif
vdc_load_tiles:
    ; word count = tile count * 16
    lda    <_ch
    asl    <_cl
    rol    A 
    asl    <_cl
    rol    A 
    asl    <_cl
    rol    A 
    asl    <_cl
    rol    A 
    sta    <_cx
; Warning! Do not put anything between vdc_load_tiles and vdc_load_data.
; If for any reason you will have to do it, uncomment the following line and
; remove this comment.
;    jmp    vdc_load_data

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
  .ifdef HUC
_vdc_load_data.3:

_vdc_load_data.4:
  .endif
vdc_load_data:
    jsr    map_data
    jsr    vdc_set_write
    
    cly

    ldx    <_cl
    beq    @l2
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
;; function: vdc_fill_bat
;; Set an area in BAT to a given tile and palette.
;;
;; Parameters:
;;   X - BAT x position.
;;   A - BAT y position.
;;   _al - BAT area width. 
;;   _ah - BAT area height.
;;   _si - Tile offset
;;   _bl - Palette index
;;
  .ifdef HUC
_vdc_fill_bat.6:
    ldx    <_cl
    lda    <_ch
  .endif
vdc_fill_bat:
    jsr   vdc_calc_addr

    lda    <_si
    ; bat_data = (_bl<<12) | (_si>>4)
    lsr    <_bl
    ror    <_si+1
    ror    A

    lsr    <_bl
    ror    <_si+1
    ror    A

    lsr    <_bl
    ror    <_si+1
    ror    A
    
    lsr    <_bl
    ror    <_si+1
    ror    A
    sta    <_si
    
vdc_fill_bat_ex:    
    ldy    <_ah
@l0:
    jsr    vdc_set_write
    addw   vdc_bat_width, <_di

    lda    <_si
    sta    video_data_l

    ldx    <_al    
@l1:
        lda    <_si+1
        sta    video_data_h

        dex
        bne    @l1
    dey
    bne    @l0
    rts

;;
;; function: vdc_clear
;; Set N words of VRAM to 0.
;;
;; Parameters:
;;   _cl - word count.
;;   _di - VRAM location.
;;
  .ifdef HUC
_vdc_clear.2:
  .endif
vdc_clear:
    lda    <_cl
    ora    <_ch
    beq    @end
    jsr    vdc_set_write
@l1:
        st1    #$00
        st2    #$00
        sec
        lda    <_cl
        sbc    #$01
        sta    <_cl
        lda    <_ch
        sbc    #$00
        sta    <_ch
        ora    <_cl
        bne    @l1
@end:
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
  .ifdef HUC
_vdc_init:
  .endif
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

    lda    #VDC_DEFAULT_YRES
    sta    vdc_scr_height

    jsr    reset_hooks
   
    ; set BAT size
    lda    #VDC_DEFAULT_BG_SIZE
    jsr    vdc_set_bat_size

    ; make BAT point to a blank tile
    ; we choose a tile that will not cross bat (even for 128x128)
    st0    #VDC_MAWR
    st1    #$00
    st2    #$00

    st0    #VDC_DATA
    ldy    #high(VDC_DEFAULT_TILE_ADDR)
@l1:
    clx
@l2:
        st1    #low(VDC_DEFAULT_TILE_ADDR>>4)
        st2    #high(VDC_DEFAULT_TILE_ADDR>>4)
        inx
        bne    @l2
    dey
    bne    @l1

    ; clear tile
    st0    #VDC_MAWR
    st1    #low(VDC_DEFAULT_TILE_ADDR)
    st2    #high(VDC_DEFAULT_TILE_ADDR)

    st0    #VDC_DATA
    st1    #$00
    ldx    #$10
@l3:
        st2    #$00
    dex
    bne    @l3

    ; disable interrupts and display
    vdc_reg  #VDC_CR
    vdc_data $0000
     
    rts

; Default VDC initialization table.
@vdc_init_table:
    .db $05, $00, $00             ; CR  control register
    .db $06, $00, $00             ; RCR scanline interrupt counter
    .db $07, $00, $00             ; BXR background horizontal scroll offset
    .db $08, $00, $00             ; BYR      "     vertical     "      " 
    .db $09, VDC_DEFAULT_BG_SIZE  ; MWR backgroup map virtual size
    .db $00                       ;
    .db $0A                       ; HSR +
     VDC_HSR_db VDC_DEFAULT_XRES  ;     |
    .db $0B                       ; HDR |
     VDC_HDR_db VDC_DEFAULT_XRES  ;     | display size and synchro
    .db $0C, $02, $0F             ; VPR |
    .db $0D, $EF, $00             ; VDW |
    .db $0E, $0C, $00             ; VCR +
    .db $0F, $10, $00             ; DCR DMA control register
    .db $13                       ; SAT adddress
    .db low(VDC_DEFAULT_SAT_ADDR)
    .db high(VDC_DEFAULT_SAT_ADDR)

; reset all hooks
reset_hooks:
	stz		<irq_m
	
	stw #no_hook, irq2_hook
	tai irq2_hook, irq1_hook, 12
	rts
	
no_hook:
	rts

;;
;; function: vdc_yres_224
;; Set vertical (y) resolution to 224 pixels.
;;
;; Parameters:
;; *none*
;;
  .ifdef HUC
_vdc_yres_224:
  .endif
vdc_yres_224:
    st0    #VDC_VSR
    ; vertical synchro width
    st1    #$02
    ; vertical display start
    st2    #$17

    st0    #VDC_VDR
    ; vertical display width
    st1    #$df
    st2    #$00

    lda    #224
    sta    vdc_scr_height
    rts

;;
;; function: vdc_yres_240
;; Set vertical (y) resolution to 240 pixels.
;;
;; Parameters:
;; *none*
;;
  .ifdef HUC
_vdc_yres_240:
  .endif
vdc_yres_240:
    st0    #VDC_VSR
    ; vertical synchro width
    st1    #$02   
    ; vertical display start
    st2    #$0f

    st0    #VDC_VDR
    ; vertical display width
    st1    #$ef
    st2    #$00

    lda    #240
    sta    vdc_scr_height
    rts

;;
;; function: vdc_xres_256
;; Set horizontal (x) resolution to 256 pixels.
;;
;; Parameters:
;; *none*
;;
  .ifdef HUC
_vdc_xres_256:
  .endif
vdc_xres_256:
    st0    #VDC_HSR
    ; horizontal sync width
    st1    #$02
    ; horizontal display start
    st2    #$02

    st0    #VDC_HDR
    ; horizontal display width
    st1    #$1f
    ; horizontal display end
    st2    #$04

    ; enable edge blur and set dot clock to 5MHz
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_5MHZ)
    sta    color_ctrl
    rts

;;
;; function: vdc_xres_320
;; Set horizontal (x) resolution to 320 pixels.
;;
;; Parameters:
;; *none*
;;
  .ifdef HUC
_vdc_xres_320:
  .endif
vdc_xres_320:
    st0    #VDC_HSR
    ; horizontal sync width
    st1    #$02
    ; horizontal display start
    st2    #$04
    
    st0    #VDC_HDR
    ; horizontal display width
    st1    #$29
    ; horizontal display end
    st2    #$04
    
    ; enable edge blur and set dot clock to 7MHz
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_7MHZ)
    sta    color_ctrl
    rts

;;
;; function: vdc_xres_512
;; Set horizontal (x) resolution to 512 pixels.
;;
;; Parameters:
;; *none*
;;
  .ifdef HUC
_vdc_xres_512:
  .endif
vdc_xres_512:
    st0    #VDC_HSR
    ; horizontal sync width
    st1    #$02
    ; horizontal display start
    st2    #$0b
    
    st0    #VDC_HDR
    ; horizontal display width
    st1    #$3f
    ; horizontal display end
    st2    #$04
    
    ; enable edge blur and set dot clock to 10MHz
    lda    #(VCE_BLUR_ON | VCE_DOT_CLOCK_10MHZ)
    sta    color_ctrl
    rts

    .bss
_hsw:    ds 1
_hds:    ds 1
_hdw:    ds 1
_hde:    ds 1

    .code
;;
;; function: vdc_set_xres
;; Set horizontal display resolution.
;; The new resolution will be ajusted/clamped to 256, 268, 356 or 512. 
;;
;; Parameters:
;;   _ax - New horizontal display resolution. 
;;   _cl - 'blur bit' for control register.
;;
  .ifdef HUC
_vdc_set_xres.2:
  .endif
vdc_set_xres:
    lda    #$20
    tsb    <irq_m               ; disable vsync processing

    cly

    ldx    <_al
    beq    @calc                ; < 256

    lda    <_ah
    cmp    #$02
    bcs    @l1                  ; >= 512

    cpx    #$0C
    bcc    @calc                ; < 268

    iny

    cpx    #$64
    bcc    @calc                ; < 356
@l1:
    ldy    #$2                  ; 356 <= x < 512
@calc:
    ; A:X / 8
    lsr    A
    sax
    ror    A
    sax
    lsr    A
    sax
    ror    A
    lsr    A
    sta    <_bl

    lda    @vce_clock, Y
    ora    <_cl
    sta    color_ctrl           ; dot-clock (x-resolution)

    lda    @hsw, Y
    sta    _hsw
    lda    <_bl
    sta    _hds                 ; hds = (x/8)
    dec    A
    sta    _hdw                 ; hdw = (x/8)-1
    lsr    _hds                 ; hds = (x/16)

    lda    @hds, Y
    clc
    sbc    _hds
    sta    _hds                 ; hds = 18 - (x/16)

    lda    @hde, Y
    sec
    sbc    _hds
    sec
    sbc    <_bl                 ; hde = (38 - ( (18-(x/16)) + (x/8) ))
    sta    _hde

    vdc_reg #VDC_HSR
    lda    _hsw
    sta    video_data_l
    lda    _hds
    sta    video_data_h

    vdc_reg #VDC_HDR
    lda    _hdw
    sta    video_data_l
    lda    _hde
    sta    video_data_h

@end:
    lda    #$20
    trb    <irq_m               ; re-enable VSYNC processing
    rts

@vce_clock: .byte 0, 1, 2
@hsw: .byte 2, 3, 5
@hds: .byte 18,25,42
@hde: .byte 38,51,82

  .ifdef HUC
_vdc_write.1:
    stx    video_data_l
    sta    video_data_h
    rts

_vdc_read:
    ldx    video_data_l
    lda    video_data_h
    rts

_vdc_reg.1:
    stx    video_reg
    stx    <vdc_ri
    rts

  .endif
