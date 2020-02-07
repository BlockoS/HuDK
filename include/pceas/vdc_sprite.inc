;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; Set current SAT entry in VRAM.
  .macro vdc_sat_set
    vdc_data \1
    vdc_data \2
    vdc_data \3
    lda    \4
    ora    LOW_BYTE \5
    sta    video_data_l
    lda    HIGH_BYTE \5
    sta    video_data_h
  .endmacro
