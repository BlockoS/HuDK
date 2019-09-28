;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

;;
;; Title: Sprite descprition and utilities
;;
;; [todo] description of the SAT sprite entry
;; Sprite Y coordinate 0 1023 
;; Sprite X coordinate 0 1023
;; Pattern index + CG mode bit 
;; Parameters (Horizontal or vertical flip, width, height, priority, palette index)
;; 

;;
;; Group: Sprite entry bitmasks
;;

;;
;; ubyte: VDC_SPRITE_CG_MODE_MASK
;; Bitmask for CG mode.
;;
VDC_SPRITE_CG_MODE_MASK = $0001
;;
;; uword: VDC_SPRITE_PATTERN_MASK
;; Bitmask for sprite pattern index.
;;
VDC_SPRITE_PATTERN_MASK = $03fe

;;
;; ubyte: VDC_SPRITE_VERTICAL_FLIP_MASK
;; Bitmask for sprite vertical flip flag.
;;
VDC_SPRITE_VERTICAL_FLIP_MASK = $8000
;;
;; ubyte: VDC_SPRITE_HORIZONTAL_FLIP_MASK
;; Bitmask for sprite horizontal flip flag.
;;
VDC_SPRITE_HORIZONTAL_FLIP_MASK = $0800
;;
;; ubyte: VDC_SPRITE_HEIGHT_MASK
;; Bitmask for sprite height.
;;
VDC_SPRITE_HEIGHT_MASK = $3000
;;
;; ubyte: VDC_SPRITE_WIDTH_MASK
;; Bitmask for sprite width.
;;
VDC_SPRITE_WIDTH_MASK = $0100
;;
;; ubyte: VDC_SPRITE_PRIORITY_MASK
;; Bitmask for sprite priority.
;;
VDC_SPRITE_PRIORITY_MASK = $0080
;;
;; ubyte: VDC_SPRITE_PALETTE_MASK
;; Bitmask for sprite palette index.
;;
VDC_SPRITE_PALETTE_MASK = $000f

;;
;; Group: Sprite CG modes.
;;

;;
;; ubyte: VDC_SPRITE_CG_MODE_B01
;; Bitplanes 0 and 1 are read, 2 and 3 are treated as zeroes.
;;
;; Note:
;; This is only valid if the VDC MWR register is set to 2 or 3.
;;
VDC_SPRITE_CG_MODE_B01 = $00
;;
;; ubyte: VDC_SPRITE_CG_MODE_B23
;; Bitplanes 2 and 3 are read, 0 and 1 are treated as zeroes.
;;
;; Note:
;; This is only valid if the VDC MWR register is set to 2 or 3.
;;
VDC_SPRITE_CG_MODE_B23 = $01

;;
;; Group: Sprite size.
;; Sprite width can be 16 or 32. Its height can be 16, 32 or 64.
;;

;;
;; ubyte: VDC_SPRITE_HEIGHT_16
;; 16 px sprite height.
;;
VDC_SPRITE_HEIGHT_16 = $0000
;;
;; ubyte: VDC_SPRITE_HEIGHT_32
;; 32 px sprite height.
;;
VDC_SPRITE_HEIGHT_32 = $1000
;;
;; ubyte: VDC_SPRITE_HEIGHT_64
;; 64 px sprite height.
;;
VDC_SPRITE_HEIGHT_64 = $2000
;;
;; ubyte: VDC_SPRITE_WIDTH_16
;; 16 px sprite width.
;;
VDC_SPRITE_WIDTH_16 = $0000
;;
;; ubyte: VDC_SPRITE_HEIGHT_32
;; 32 px sprite width.
;;
VDC_SPRITE_WIDTH_32 = $0100

;; 
;; Group: Sprite control flags
;;

;;
;; ubyte: VDC_SPRITE_PRIORITY_LOW
;; The sprite will be displayed in background.
;;
VDC_SPRITE_PRIORITY_LOW = $0000

;;
;; ubyte: VDC_SPRITE_PRIORITY_HIGH
;; The sprite will be displayed in foreground.
;;
VDC_SPRITE_PRIORITY_HIGH = $0080

;;
;; ubyte: VDC_SPRITE_HORIZONTAL_FLIP
;; The sprite will be flipped horizontally.
;;
VDC_SPRITE_HORIZONTAL_FLIP = $0800

;;
;; ubyte: VDC_SPRITE_VERTICAL_FLIP
;; The sprite will be flipped vertically.
;;
VDC_SPRITE_VERTICAL_FLIP = $8000
