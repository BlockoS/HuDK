;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;
.setcpu "huc6280"

.define ds .res
.define bank <.bank
.macro declare_zp var, address
    .exportzp var = <address
.endmacro