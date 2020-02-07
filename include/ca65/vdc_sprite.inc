;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Set current SAT entry in VRAM.
  .macro vdc_sat_set sx, sy, addr, pal, size, flag
    vdc_data sx
    vdc_data sy
    vdc_data addr
    lda    pal
    ora    LOW_BYTE size
    sta    video_data_l
    lda    HIGH_BYTE flag
    sta    video_data_h
  .endmacro
