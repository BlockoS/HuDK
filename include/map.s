;;
;; Title: Tilemap functions.
;;

    .zp
map_infos:
map_width      .ds 2
map_height     .ds 2
map_wrap       .ds 1
map_bank       .ds 1
map_address    .ds 2
map_tile_base  .ds 2
map_tile_count .ds 2

    .code
;;
;; function: map_init
;; Set tilemap infos.
;; 
;; Description:
;;   This routine loads the following informations from the data location given
;; as parameter :
;;   width - number of horizontal tiles (word)
;;   height - number of vertical tiles (word)
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
    stw    <_cx, <map_tile_count
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
;; function: map_load
;; Load a portion of the tilemap to VRAM.
;;
;; Parameters:
;;   _di - BAT address
;;   _ah - BAT X position.
;;   _al - BAT Y position.
;;   _si - Map address
;;   _ch - Map X position.
;;   _cl - Map Y position.
;;   _dl - Number of column to copy.
;;   _dh - Number of row to copy.
;;
map_load:
    ; [todo]
    rts
