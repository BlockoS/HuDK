;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

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

; Map copy helper macro.
  .macro map_copy
    lda    \1
    sta    <_al
    lda    \2
    sta    <_ah
    lda    \3
    sta    <_cl
    lda    \4
    sta    <_ch
    lda    \5
    sta    <_dl
    lda    \6
    sta    <_dh
    jsr    map_load
  .endmacro

  .macro map_copy_16
    lda    \1
    sta    <_al
    lda    \2
    sta    <_ah
    lda    \3
    sta    <_cl
    lda    \4
    sta    <_ch
    lda    \5
    sta    <_dl
    lda    \6
    sta    <_dh
    jsr    map_load_16
  .endmacro

