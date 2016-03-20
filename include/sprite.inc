;;
;; Title: Sprite descprition and utilities
;;
;; [todo] description of the SATB sprite entry
;; 

;;
;; Group: Sprite entry bitmasks
;;

;;
;; ushort: SPRITE_X_MASK
;; Bitmask for the sprite X coordinate. 
;; 
SPRITE_X_MASK = $3f
;;
;; ushort: SPRITE_Y_MASK
;; Bitmask for the sprite Y coordinate. 
;; 
SPRITE_Y_MASK = $3f
;;
;; ubyte: SPRITE_CG_MODE_MASK
;; Bitmask for CG mode.
;;
SPRITE_CG_MODE_MASK = $01
;;
;; uword: SPRITE_PATTERN_MASK
;; Bitmask for sprite pattern index.
;;
SPRITE_PATTERN_INDEX = $7e
;;
;; ubyte: SPRITE_VERTICAL_FLIP_MASK
;; Bitmask for sprite vertical flip flag.
;;
SPRITE_VERTICAL_FLIP_MASK = $80
;;
;; ubyte: SPRITE_HORIZONTAL_FLIP_MASK
;; Bitmask for sprite horizontal flip flag.
;;
SPRITE_HORIZONTAL_FLIP_MASK = $08
;;
;; ubyte: SPRITE_HEIGHT_MASK
;; Bitmask for sprite height.
;;
SPRITE_HEIGHT_MASK = $30
;;
;; ubyte: SPRITE_WIDTH_MASK
;; Bitmask for sprite width.
;;
SPRITE_WIDTH_MASK = $01
;;
;; ubyte: SPRITE_PRIORITY_MASK
;; Bitmask for sprite priority.
;;
SPRITE_PRIORITY_MASK = $80
;;
;; ubyte: SPRITE_PALETTE_MASK
;; Bitmask for sprite palette index.
;;
SPRITE_PALETTE_MASK = $0f

;;
;; Group: Sprite CG modes.
;;

;;
;; ubyte: SPRITE_CG_MODE_B01
;; Bitplanes 0 and 1 are read, 2 and 3 are treated as zeroes.
;;
;; Note:
;; This is only valid if the VDC MWR register is set to 2 or 3.
;;
SPRITE_CG_MODE_B01 = $00
;;
;; ubyte: SPRITE_CG_MODE_B23
;; Bitplanes 2 and 3 are read, 0 and 1 are treated as zeroes.
;;
;; Note:
;; This is only valid if the VDC MWR register is set to 2 or 3.
;;
SPRITE_CG_MODE_B01 = $01

;;
;; Group: Sprite size.
;; Sprite width can be 16 or 32. Its height can be 16, 32 or 64.
;;

;;
;; ubyte: SPRITE_HEIGHT_16
;; 16 px sprite height.
;;
SPRITE_HEIGHT_16 = $00
;;
;; ubyte: SPRITE_HEIGHT_32
;; 32 px sprite height.
;;
SPRITE_HEIGHT_32 = $10
;;
;; ubyte: SPRITE_HEIGHT_64
;; 64 px sprite height.
;;
SPRITE_HEIGHT_64 = $20
;;
;; ubyte: SPRITE_WIDTH_16
;; 16 px sprite width.
;;
SPRITE_WIDTH_16 = $00
;;
;; ubyte: SPRITE_HEIGHT_32
;; 32 px sprite width.
;;
SPRITE_WIDTH_32 = $01

;; 
;; Group: Sprite control flags
;;

;;
;; ubyte: SPRITE_PRIORITY_LOW
;; The sprite will be displayed in background.
;;
SPRITE_PRIORITY_LOW = $00

;;
;; ubyte: SPRITE_PRIORITY_HIGH
;; The sprite will be displayed in foreground.
;;
SPRITE_PRIORITY_HIGH = $80

;;
;; ubyte: SPRITE_HORIZONTAL_FLIP
;; The sprite will be flipped horizontally.
;;
SPRITE_HORIZONTAL_FLIP = $08

;;
;; ubyte: SPRITE_VERTICAL_FLIP
;; The sprite will be flipped vertically.
;;
SPRITE_VERTICAL_FLIP = $80
