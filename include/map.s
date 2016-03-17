;;
;; Title: Tilemap functions.
;;
;; Tilemap format:
;; map width  - (2 bytes) horizontal tile count
;; map height - (2 bytes) vertical tile count
;; wrap mode  - (1 byte) Indicates if the horizontal or vertical coordinates
;;                       should wrap around the origin. 
;; map data   - (N bytes) Tile indices. 
;;
;; [todo] explain tile palette and data
;;

    .zp
map_infos:
map_width       .ds 2
map_height      .ds 2
map_wrap        .ds 1

map_bank        .ds 1
map_address     .ds 2

map_pal_bank    .ds 1
map_pal_address .ds 2

map_tile_base   .ds 2

map_bat_top      .ds 1
map_bat_bottom   .ds 1
map_bat_top_base .ds 2

  .ifdef MAGICKIT
    .include "pceas/map.s"
  .else
    .ifdef CA65
    .include "ca65/map.s"
    .endif
  .endif

    .code
;;
;; Macro: map_set
;; Set current map pointers and infos.
;;
;; Assembly call
;;   > map_set map, tile, colortab, w, h, m
;;
;; Parameters:
;;   map - Map base address
;;   tile - tiles VRAM address
;;   colortab - tiles palette table address
;;   w - Map width
;;   h - Map height
;;   m - Map coordinate wrapping mode
;;

; [todo] 16x16 map_load version

;;
;; function: map_load
;; Load a portion of the tilemap to VRAM.
;;
;; Parameters:
;;   _al - BAT X position.
;;   _ah - BAT Y position.
;;   _cl - Map X position.
;;   _ch - Map Y position.
;;   _dl - Number of column to copy.
;;   _dh - Number of row to copy.
;;
map_load:
    ; save mprs 2, 3 and 4
    tma2
    pha
    tma3
    pha
    tma4
    pha
    
    ; save BAT position
    ; compute vram address
    ldx    <_al
    phx
    lda    <_ah
    pha
    jsr    vdc_calc_addr

    ; save map x position
    lda    <_cl
    sta    <_bh

    ; compute pointer to the tilemap line
    lda    <map_address
    sta    <_si
    lda    <map_address+1
    and    #$1f
    sta    <_si+1
    lda    <map_width+1
    beq    @map_width_std
@map_width_256:
        ; special case for map width of 256
        ; map_ptr = map + (my * 256)
        clc
        lda    <_ch
        sta    <_al
        adc    <_si+1
        sta    <_si+1
        bra    @map_data_bank

@map_width_std:
        ; map_ptr = map + (my * map_width)
        lda    <_ch
        sta    <_al
        lda    <map_width
        sta    <_bl
        jsr    mulu8 
        addw   <_cx, <_si

@map_data_bank:
    ; compute map bank
    rol    A
    rol    A
    rol    A
    rol    A
    and    #$0f
    clc
    adc    <map_bank
    tam3
    inc    A
    tam4

    ; compute tile palette bank
    lda    <map_pal_bank
    tam2

    ; adjust tilemap pointer
    lda    <_si+1
    and    #$1f
    ora    #$60
    sta    <_si+1
    ; adjust tile palette pointer
    lda    <map_pal_address
    sta    <_bp
    lda    <map_pal_address+1 
    and    #$1f
    ora    #$40
    sta    <_bp+1

    ; retrieve bat position
    pla
    and    vdc_bat_vmask
    sta    <_bl
    pla
    and    vdc_bat_vmask
    sta    <_ch

    bra    @line_setup
    ; small recap
    ; _ch - BAT X position
    ; _bl - BAT Y position
    ; _bh - MAP X position
    ; _al - MAP Y position
    ; _dl - Horizontal tile count
    ; _dh - Vertical tile count
    ; _si - MAP pointer
    ; _bp - Tile palette pointer

@loop:
    jsr    map_load_next_line

@line_setup:
    vdc_reg  #VDC_MAWR
    vdc_data <_di
    vdc_reg  #VDC_DATA

    ; MAP X position
    ldy    <_bh
    ; copy horizontal tile count
    lda    <_dl
    sta    <_cl
    ; copy BAT X position
    lda    <_ch
    sta    <_ah

    bra    @copy

@next_bat_x:
        ; increment bat x position
        lda    <_ah
        inc    A
        and    vdc_bat_hmask
        sta    <_ah
        ; reset it to the beginning of the BAT line
        ; if it goes past the BAT width
        bne    @next_tile_x
            vdc_reg  #VDC_MAWR
            lda    vdc_bat_hmask
            eor    #$ff
            sta    <_di
            sta    video_data_l
            lda    <_di+1
            sta    video_data_h
            vdc_reg  #VDC_DATA

@next_tile_x: 
        ; increment tilemap x position
        iny
        cpy    <map_width
        bne    @copy
            ; restart at the beginning of the tilemap line if wrap mode is
            ; activated, otherwise fill the area with the tile at index #0.
            bbs0   <map_wrap, @tile_repeat
            ldy    <map_width
            dey
            cla
            bra    @l0
@tile_repeat:
            cly
@copy:
        ; write bat entry
        lda    [_si], Y
@l0:
        tax
        clc
        adc    <map_tile_base
        sta    video_data_l
        sxy
        lda    [_bp], Y
        adc    <map_tile_base+1
        sta    video_data_h

        ; restore tilemap index
        sxy

        dec    <_cl
        bne    @next_bat_x
    dec    <_dh
    bne    @loop

@end:
    ; restore mprs 2, 3 and 4
    pla
    tam4
    pla
    tam3
    pla
    tam2

    rts

; Update bat and tilemap line pointers.
; For internal use only.
map_load_next_line:
@next_bat_y:
    inc    <_bl
    lda    <_bl
    cmp    <map_bat_bottom
    bcc    @bat_inc_y
        ; reset BAT Y position 
        lda    <map_bat_top
        sta    <_bl
        ; reset map pointer
        lda    <_di
        and    vdc_bat_hmask
        clc
        adc    <map_bat_top_base
        sta    <_di
        cla
        adc    <map_bat_top_base+1 
        sta    <_di+1
        bra    @next_tile_y

@bat_inc_y:
    ; move BAT pointer to the next line
    lda    <_di
    clc
    adc    vdc_bat_width
    sta    <_di
    bcc    @next_tile_y
        inc    <_di+1

@next_tile_y:
    inc    <_al
    beq    @check_tile_y_wrap
    lda    <_al
    cmp    <map_height
    beq    @check_tile_y_wrap
        ; go to next tilemap line
        addw   <map_width, <_si
        ; check if we need to remap the tilemap
        cmp    #$80
        bcc    @end
            sec
            sbc    #$20
            tma4
            tam3
            inc    A
            tam4
@end:
            rts
@check_tile_y_wrap:
    ; wrap tilemap bank
    lda    <map_bank
    tam3
    inc    A
    tam4
    ; reset tilemap pointer
    lda    <map_address
    sta    <_si
    lda    <map_address+1
    and    #$1f
    ora    #$60
    sta    <map_address+1
    ; reset MAP Y position
    stz    <_al 
    rts

