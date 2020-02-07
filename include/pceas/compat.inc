;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

; PCEas macro argument type
ARG_NONE        .equ 0
ARG_REG         .equ 1
ARG_IMMEDIATE   .equ 2
ARG_ABS         .equ 3
ARG_ABSOLUTE    .equ 3
ARG_INDIRECT    .equ 4
ARG_STRING      .equ 5
ARG_LABEL       .equ 6

  .macro declare_zp
\1 = \2
  .endmacro
