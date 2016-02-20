;;
;; Group: HuC6260 - Video Display Controller (VDC).
;;

;;
;; ushort: videoport
;; VDC port
;; 
videoport = $0000

;;
;; ushort: video_reg
;; VDC register latch
;;
;; Detail:
;; Writing the lower five bits of video_reg ($0000à select which register will
;; be accessed at video_data_l ($0002) and video_data_h ($0003).
;; Only registers $00 to $02 and  $05 to $13 are valid; selecting registers 
;; $03, $04 or $14 to $1F and trying to access them has no effect.
;; Reading video_reg $0000 returns a set of status flags. 
;;
video_reg   = videoport
video_reg_l = video_reg
video_reg_h = video_reg+1

;;
;; ushort: video_data
;; VDC data
;;
video_data   = videoport+2
video_data_l = video_data
video_data_h = video_data+1


;;
;;   Group: VDC status bitfield. 
;;

;;
;; bits: VDC_STATUS_SPR_COLLISION 
;; Set when the sprite #0 collision detection interrupt occurs. The collision
;; happens if any of the opaque pixel of sprite #0 is overlapping any other
;; sprites.
;;
VDC_STATUS_SPR_COLLISION = %00000001
;;
;; bits: VDC_STATUS_SPR_OVERFLOW
;; Set when the sprite overflow interrupt occurs. 
;; More precisely, when there are more than 16 sprites on a scanline.
;;
VDC_STATUS_SPR_OVERFLOW = %00000010
;;
;; bits: VDC_STATUS_HBLANK
;; Set when the horizontal blank interrupt occurs. This interrupt is triggered
;; when the scanline matches the value stored in VDC register $06.
;;
VDC_STATUS_HBLANK = %00000100
;;
;; bits: VDC_STATUS_SATB_DMA_END
;; Set when the VRAM to SATB DMA transfer completion interrupt occurs.
;;
VDC_STATUS_SATB_DMA_END = %00001000
;;
;; bits: VDC_STATUS_VRAM_DMA_END
;; Set when the VRAM to VRAM DMA transfer completion interrupt occurs.
;;
VDC_STATUS_VRAM_DMA_END = %00010000
;;
;; bits: VDC_STATUS_VBLANK
;; Set when the vertical blank interrupt occurs.
;;
VDC_STATUS_VBLANK = %00100000
;;
;; bits: VDC_STATUS_BUSY
;; Set when the VDC is waiting for a CPU access slot during the active display
;; area.
;;
VDC_STATUS_BUSY = %01000000

;; 
;; Group: VDC registers.
;;

;;
;; ubyte: VDC_MAWR
;; Memory Address Write Register
;;
;; Detail:
;; Set the word offset in VRAM where data will be written.
;;
VDC_MAWR = $00
;;
;; ubyte: VDC_MARR
;; Memory Address Read Register
;;
;; Detail:
;; Set the word offset in VRAM from where data will be read.
;;
VDC_MARR =  $01
;;
;; ubyte: VDC_DATA
;; VRAM Data register
;;
;; Detail:
;; Writing to LSB (video_data_l), the CPU date is stored in the write latch.
;; When the MSB is written (video_data_h), the whole 16 bits from the write
;; latch and the MSB are transfered to the memory location set with MAWR.
;; MAWR is then automatically incremented according to the value set in the
;; control register (CR).
;;
VDC_DATA = $02
;;
;; ubyte: VDC_CR
;; Control Register
;;
;; Detail:
;; Enables or disables VDC interrupts, background or sprite display, and set the
;; read and write auto-increment. 
;;
VDC_CR = $05
;;
;; ubyte: VDC_RCR
;; Raster Compare Register
;;
;; Detail:
;; Set the scanline on which the horizontal scanline interrupt should be raised.
;; The first scanline of the display area is the number 64. Valid RCR register
;; values range from 64 to 326.
;;
VDC_RCR = $06
;;
;; ubyte: VDC_BXR
;; Background X Scroll Register
;;
;; Detail:
;; Horizontal screen position in the virtual background map.
;;
VDC_BXR = $07
;;
;; ubyte: VDC_BYR
;; Background Y Scroll Register
;;
;; Detail:
;; Vertical screen position in the virtual background map.
;;
VDC_BYR = $07
;;
;; ubyte: VDC_MWR
;; Memory Width Register (MWR)
;;
;; Detail:
;; Set virtual background map size.
;;
VDC_MWR = $09
;;
;; ubyte: VDC_HSR
;; Horizontal Synchro Register
;;
;; Detail:
;; Set horizontal synchro width and start position.
;;
VDC_HSR = $0A
;;
;; ubyte: VDC_HDR
;; Horizontal Display Register
;;
;; Detail:
;; Set horizontal display width and end position.
;;
VDC_HDR = $0B
;;
;; ubyte: VDC_VSR
;; Vertical Synchro Register
;;
;; Detail:
;; Set vertical synchro width and start position.
;;
VDC_VSR = $0C
;;
;; ubyte: VDC_VDR
;; Vertical Display Register
;; 
;; Detail:
;; Set vertical display width.
;;
VDC_VDR = $0D
;;
;; ubyte: VDC_VCR
;; Vertical Display End Position Register
;;
VDC_VCR = $0E
;;
;; ubyte: VDC_DMA_CR
;; DMA Control Register
;;
;; Detail:
;; Enables or disables VRAM to VRAM or VRAM to SATB end of transfer interrupts.
;; Set source and destination direction (increment or decrement), and enable or
;; disable SATB DMA automatic transfer.
;;
VDC_DMA_CR = $0F
;;
;; ubyte: VDC_DMA_SRC
;; DMA Source Address Register
;;
VDC_DMA_SRC = $10
;;
;; ubyte: VDC_DMA_DST
;; DMA Destination Address Register
;;
VDC_DMA_DST = $11
;;
;; ubyte: VDC_DMA_LEN
;; DMA Transfer Length Register
;;
VDC_DMA_LEN = $12
;;
;; ubyte: VDC_SATB_SRC
;; VRAM-SATB Source Address Register
;;
VDC_SATB_SRC = $13

;;
;; Group: Control Register flags.
;;

;;
;; ushord: VDC_CR_SPR_COLLISION_ENABLE
;; Enables sprite collision interrupt.
;;
VDC_CR_SPR_COLLISION_ENABLE = $0001
;;
;; ushort: VDC_CR_SPR_OVERFLOW_ENABLE
;; Enables sprite overflow interrupt.
;;
VDC_CR_SPR_OVERFLOW_ENABLE  = $0002
;;
;; ushort: VDC_CR_HBLANK_ENABLE
;; Enables horizontal blank interrupt.
;;
VDC_CR_HBLANK_ENABLE     = $0004
;;
;; ushort: VDC_CR_VBLANK_ENABLE
;; Enables vertical blank interrupt.
;;
VDC_CR_VBLANK_ENABLE     = $0008
;;
;; ushort: VDC_CR_SPR_ENABLE
;; Enables sprites layer.
;;
VDC_CR_SPR_ENABLE        = $0040
;;
;; ushort: VDC_CR_BG_ENABLE
;; Enables background layer.
;;
VDC_CR_BG_ENABLE         = $0080
;;
;; ushort: VDC_CR_RW_INC_1
;; Read/write address auto-increment by 1 word.
;;
VDC_CR_RW_INC_1          = $0000
;;
;; ushort: VDC_CR_RW_INC_32
;; Read/write address auto-increment by 32 words.
;;
VDC_CR_RW_INC_32         = $0800
;;
;; ushort: VDC_CR_RW_INC_64
;; Read/write address auto-increment by 64 words.
;;
VDC_CR_RW_INC_64         = $1000
;;
;; ushort: VDC_CR_RW_INC_128
;; Read/write address auto-increment by 128 words.
;;
VDC_CR_RW_INC_128        = $1800

;;
;; Group: Background map virtual size.
;;

;;
;; bits: VDC_BG_32_32
;; 32x32 virtual background map.
;;
VDC_BG_32x32  = %0_000_0000
;;
;; bits: VDC_BG_64_32
;; 64x32 virtual background map.
;;
VDC_BG_64x32  = %0_001_0000
;;
;; bits: VDC_BG_128_32
;; 128x32 virtual background map.
;;
VDC_BG_128x32 = %0_010_0000
;;
;; bits: VDC_BG_32_64
;; 32x64 virtual background map.
;;
VDC_BG_32x64  = %0_100_0000
;;
;; bits: VDC_BG_64_64
;; 64x64 virtual background map.
;;
VDC_BG_64x64  = %0_101_0000
;;
;; bits: VDC_BG_128_64
;; 128x64 virtual background map.
;;
VDC_BG_128x64 = %0_110_0000

;;
;; Group: DMA Control register flags.
;;

;;
;; bits: VDC_DMA_SATB_ENABLE
;; Enables VRAM to SATB end of transfer interrupt.
;;
VDC_DMA_SATB_ENABLE = %0000_0001 
;;
;; bits: VDC_DMA_VRAM_ENABLE
;; Enables VRAM to VRAM end of transfer interrupt.
;;
VDC_DMA_VRAM_ENABLE = %0000_0010
;;
;; bits: VDC_DMA_SRC_INC
;; Source address direction (increment).
;;
VDC_DMA_SRC_INC     = %0000_0000
;;
;; bits: VDC_DMA_SRC_DEC
;; Source address direction (decrement).
;;
VDC_DMA_SRC_DEC     = %0000_0100
;;
;; bits: VDC_DMA_DST_INC
;; Destination address direction (increment).
;;
VDC_DMA_DST_INC     = %0000_0000
;;
;; bits: VDC_DMA_DST_DEC 
;; Destination address direction (decrement).
;;
VDC_DMA_DST_DEC     = %0000_1000
;;
;; bits: VDC_DMA_SATB_AUTO
;; Enable SATB DMA auto-transfer.
;;
VDC_DMA_SATB_AUTO   = %0001_0000

