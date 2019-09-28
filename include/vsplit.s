;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
VSPLIT_MAX_COUNT = 4

    .bss
vsplit_count   .ds 1
vsplit_raster .ds VSPLIT_MAX_COUNT
vsplit_sx.lo  .ds VSPLIT_MAX_COUNT
vsplit_sx.hi  .ds VSPLIT_MAX_COUNT
vsplit_sy.lo  .ds VSPLIT_MAX_COUNT
vsplit_sy.hi  .ds VSPLIT_MAX_COUNT
vsplit_cr     .ds VSPLIT_MAX_COUNT

; set vertical split

; disable vertical split

; build raster/scroll list

