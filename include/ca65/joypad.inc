;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

  .bss
; This array holds the values for 5 2-buttons joypad.
joypad: 	.res 5, 0

; Delta joypad values.
joytrg: 	.res 5, 0

; Previous joypad values.
joyold: 	.res 5, 0

; This array contains the values for buttons III, IV, V and VI of 6 buttons
; joypads.
joypad_6: 	.res 5, 0

; Delta joypad values.
joytrg_6: 	.res 5, 0

; Previous joypad values.
joyold_6: 	.res 5, 0

	.code
