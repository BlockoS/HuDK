;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

; Set current map pointers and infos.
  .macro map_set map, tile, colortab, w, h, m
    lda    #bank(map)
    sta    <map_bank
    stw    #map, <map_address
    stw    #((tile)>>4), <map_tile_base
    lda    #bank(colortab)
    sta    <map_pal_bank
    stw    #colortab, <map_pal_address
    stw    w, <map_width
    stw    h, <map_height
    lda    m
    sta    <map_wrap
  .endmacro

; Map copy helper macro.
  .macro map_copy bx, by, mx, my, w, h
    lda    bx
    sta    <_al
    lda    by
    sta    <_ah
    lda    mx
    sta    <_cl
    lda    my
    sta    <_ch
    lda    w
    sta    <_dl
    lda    h
    sta    <_dh
    jsr    map_load
  .endmacro

  .macro map_copy_16 bx, by, mx, my, w, h
    lda    bx
    sta    <_al
    lda    by
    sta    <_ah
    lda    mx
    sta    <_cl
    lda    my
    sta    <_ch
    lda    w
    sta    <_dl
    lda    h
    sta    <_dh
    jsr    map_load_16
  .endmacro


