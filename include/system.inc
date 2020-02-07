;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Title: System variables
;;

;;
;; ushort: sp
;; 
    declare_zp sp, $20e4
;;
;; ushort: sreg
;; 
    declare_zp sreg, $20e6
;;
;; ushort: _r0
;; 
    declare_zp _r0, $20e8
;;
;; ushort: _r1
;; 
    declare_zp _r1, $20ea
;;
;; ushort: _bp
;; Base pointer.
    declare_zp _bp, $20ec
;;
;; ushort: _si
;; Source address.
    declare_zp _si, $20ee
;;
;; ushort: _di
;; Destination address.
    declare_zp _di, $20f0
;;
;; ushort: _ax
;; 
    declare_zp _ax, $20f8
;;
;; ushort: _al
;; _ax LSB
    declare_zp _al, _ax
;;
;; ushort: _ah
;; _ax MSB
    declare_zp _ah, _ax+1
;;
;; ushort: _bx
;; 
    declare_zp _bx, $20fa
;;
;; ushort: _bl
;; _bx LSB
    declare_zp _bl, _bx
;;
;; ushort: _bh
;; _bx MSB
    declare_zp _bh, _bx+1
;;
;; ushort: _cx
;; 
    declare_zp _cx, $20fc
;;
;; ushort: _cl
;; _cx LSB
    declare_zp _cl, _cx
;;
;; ushort: _ch
;; _cx MSB
    declare_zp _ch, _cx+1
;;
;; ushort: _dx
;;
    declare_zp _dx, $20fe
;;
;; ushort: _dl
;; _dx LSB
    declare_zp _dl, _dx
;;
;; ushort: _dh
;; _dx MSB
    declare_zp _dh, _dx+1
