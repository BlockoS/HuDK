; Set current map pointers and infos.
  .macro map_set
    lda    #bank(\1)
    sta    <map_bank
    stw    #\1, <map_address
    stw    #((\2)>>4), <map_tile_base
    lda    #bank(\3)
    sta    <map_pal_bank
    stw    #\3, <map_pal_address
    stw    \4, <map_width
    stw    \5, <map_height
    lda    \6
    sta    <map_wrap
  .endmacro
