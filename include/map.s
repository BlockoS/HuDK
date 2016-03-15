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
;; [todo] tile palette
;; [todo] tile data
;;

; [todo] wrap values?
    .zp
; [todo] comments
map_infos:
map_width       .ds 2
map_height      .ds 2
map_wrap        .ds 1

map_bank        .ds 1
map_address     .ds 2

map_pal_bank    .ds 1
map_pal_address .ds 2

map_tile_base   .ds 2
map_top         .ds 1
map_bottom      .ds 1
map_top_base    .ds 2
    .code
;;
;; function: tile_load
;; Load tile data to VRAM.
;;
;; Parameters:
;;   _bl - Tile data bank.
;;   _si - Tile data address.
;;   _cx - Tile count.
;;   _di - VRAM destination.
tile_load:
    stw    <_di, <map_tile_base
    lsr    A
    ror    <map_tile_base
    lsr    A
    ror    <map_tile_base
    lsr    A
    ror    <map_tile_base
    lsr    A
    ror    <map_tile_base
    sta    <map_tile_base+1
   
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

    jmp    vdc_load_data
;;
;; function: map_init
;; Set tilemap infos.
;; 
;; Description:
;;   This routine loads the following informations from the data location given
;; as parameter :
;;
;;   width     - number of horizontal tiles (word)
;;   height    - number of vertical tiles (word)
;;   wrap mode - this flag tells if the map is wrapping horizontally or
;;               verticallly (byte)
;;
;; Remark:
;;   The map address must have been mapped to the appropriate mpr beforehand.
;;
;; Parameters:
;;   _bl - Map bank.
;;   _si - Map address.
;;
map_init:
    lda    <_bl
    sta    <map_bank
    stw    <_si, <map_address
   
    jsr    map_data

    ; copy tilemap infos
    cly
.l0:
    lda    [_si], Y
    sta    map_infos, Y
    iny
    cpy    #05
    bne    .l0

    jsr    unmap_data

    rts

; [todo] 16x16 map_load version

;;
;; function: map_load
;; Load a portion of the tilemap to VRAM.
;;
;; Parameters:
;;   _al - BAT X position.
;;   _ah - BAT Y position.
;;   _si - Map address
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
    beq    .map_width_std
.map_width_256:
        ; special case for map width of 256
        ; map_ptr = map + (my * 256)
        clc
        lda    <_ch
        sta    <_al
        adc    <_si+1
        sta    <_si+1
        bra    .map_data_bank
.map_width_std:
        ; map_ptr = map + (my * map_width)
        lda    <_ch
        sta    <_al
        lda    <map_width
        sta    <_bl
        jsr    mulu8 
        addw   <_cx, <_si

.map_data_bank:
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

.map_pal_bank:
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

    ; small recap
    ; _ch - BAT X position
    ; _bl - BAT Y position
    ; _bh - MAP X position
    ; _al - MAP Y position
    ; _si - MAP pointer
    ; _bp - Tile palette pointer

; [todo] vertical loop
; [todo] horizontal loop

    ; restore mprs 2, 3 and 4
    pla
    tam4
    pla
    tam3
    pla
    tam2

    rts
