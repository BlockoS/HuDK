;;
;; Title: System variables
;;

;;
;; ushort: irq_m
;; Interrupt control register.
;;
irq_m = $20f5
;;
;; ushort: _bp
;; Base pointer.
_bp = $20ec
;;
;; ushort: _si
;; Source address.
_si = $20ee
;;
;; ushort: _di
;; Destination address.
_di = $20f0
;;
;; ushort: _ax
;; 
_ax = $20f8
;;
;; ushort: _al
;; _ax LSB
_al = _ax
;;
;; ushort: _ah
;; _ax MSB
_ah = _ax+1
;;
;; ushort: _bx
;; 
_bx = $20fa
;;
;; ushort: _bl
;; _bx LSB
_bl = _bx
;;
;; ushort: _bh
;; _bx MSB
_bh = _bx+1
;;
;; ushort: _cx
;; 
_cx = $20fc
;;
;; ushort: _cl
;; _cx LSB
_cl = _cx
;;
;; ushort: _ch
;; _cx MSB
_ch = _cx+1
;;
;; ushort: _dx
;;
_dx = $20fe
;;
;; ushort: _dl
;; _dx LSB
_dl = _dx
;;
;; ushort: _dh
;; _dx MSB
_dh = _dx+1

