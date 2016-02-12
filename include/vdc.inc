; HuC6260 - Video Display Controller (VDC)

; VDC port
videoport = $0000

; VDC register latch
; Writing the lower five bits of video_reg ($0000à select which register will
; be accessed at video_data_l ($0002) and video_data_h ($0003).
; Only registers $00 to $02 and  $05 to $13 are valid; selecting registers 
; $03, $04 or $14 to $1F and trying to access them has no effect.
; Reading video_reg ($0000à returns a set of status flags. 
video_reg   = videoport
video_reg_l = video_reg
video_reg_h = video_reg+1

; VDC data
video_data   = videoport+2
video_data_l = video_data
video_data_h = video_data+1

; Status flags.
; Set when the sprite #0 collision detection interrupt occurs. The collision
; happens if any of the opaque pixel of sprite #0 is overlapping any other
; sprites.
VDC_STATUS_SPR_COLLISION = 1
; Set when the sprite overflow interrupt occurs. More precisely, when there are 
; more than 16 sprites on a scanline.
VDC_STATUS_SPR_OVERFLOW  = 1<<1
; Set when the horizontal blank interrupt occurs. This interrupt is triggered
; when the scanline matches the value stored in VDC register $06.
VDC_STATUS_HBLANK        = 1<<2
; Set when the VRAM to SATB DMA transfer completion interrupt occurs.
VDC_STATUS_SATB_DMA_END  = 1<<3
; Set when the VRAM to VRAM DMA transfer completion interrupt occurs.
VDC_STATUS_VRAM_DMA_END  = 1<<4
; Set when the vertical blank interrupt occurs.
VDC_STATUS_VBLANK        = 1<<5
; Set when the VDC is waiting for a CPU access slot during the active display
; area.
VDC_STATUS_BUSY          = 1<<6

; VDC registers
; Memory Address Write Register
; Set the word offset in VRAM where data will be written.
VDC_MAWR = $00
; Memory Address Read Register
; Set the word offset in VRAM from where data will be read.
VDC_MARR =  $01
; VRAM Data register
; Writing to LSB (video_data_l), the CPU date is stored in the write latch.
; When the MSB is written (video_data_h), the whole 16 bits from the write latch
; and the MSB are transfered to the memory location set with MAWR. MAWR is then
; automatically incremented according to the value set in the control register
; (CR).
VDC_DATA = $02
; Control Register
; Enables or disables VDC interrupts, background or sprite display, and set the
; read and write auto-increment. 
VDC_CR = $05
; Raster Compare Register
; Set the scanline on which the horizontal scanline interrupt should be raised.
; The first scanline of the display area is the number 64. Valid RCR register
; values range from 64 to 326.
VDC_RCR = $06
; Background X Scroll Register
; Horizontal screen position in the virtual background map.
VDC_BXR = $07
; Background Y Scroll Register
; Vertical screen position in the virtual background map.
VDC_BYR = $07
; Memory Width Register (MWR)
; Set virtual background map size.
VDC_MWR = $09
; Horizontal Synchro Register
; Set horizontal synchro width and start position.
VDC_HSR = $0A
; Horizontal Display Register
; Set horizontal display width and end position.
VDC_HDR = $0B
; Vertical Synchro Register
; Set vertical synchro width and start position.
VDC_VSR = $0C
; Vertical Display Register
; Set vertical display width.
VDC_VDR = $0D
; Vertical Display End Position Register
VDC_VCR = $0E
; DMA Control Register
; Enables or disables VRAM to VRAM or VRAM to SATB end of transfer interrupts.
; Set source and destination direction (increment or decrement), and enable or
; disable SATB DMA automatic transfer.
VDC_DMA_CR = $0F
; DMA Source Address Register
VDC_DMA_SRC = $10
; DMA Destination Address Register
VDC_DMA_DST = $11
; DMA Transfer Length Register
VDC_DMA_LEN = $12
; VRAM-SATB Source Address Register
VDC_SATB_SRC = $13

; Control Register flags
; Enables sprite collision interrupt.
VDC_CR_SPR_COLLISION_ENABLE = $0001
; Enables sprite overflow interrupt.
VDC_CR_SPR_OVERFLOW_ENABLE  = $0002
; Enables horizontal blank interrupt.
VDC_CR_HBLANK_ENABLE     = $0004
; Enables vertical blank interrupt.
VDC_CR_VBLANK_ENABLE     = $0008
; Enables sprites layer.
VDC_CR_SPR_ENABLE        = $0040
; Enables background layer.
VDC_CR_BG_ENABLE         = $0080
; Read/write address auto-increment by 1 word.
VDC_CR_RW_INC_1          = $0000
; Read/write address auto-increment by 32 words.
VDC_CR_RW_INC_32         = $0800
; Read/write address auto-increment by 64 words.
VDC_CR_RW_INC_64         = $1000
; Read/write address auto-increment by 128 words.
VDC_CR_RW_INC_128        = $1800

; Background map virtual size.
VDC_BG_32x32  = %0_000_0000
VDC_BG_64x32  = %0_001_0000
VDC_BG_128x32 = %0_010_0000
VDC_BG_128x32 = %0_011_0000
VDC_BG_32x64  = %0_100_0000
VDC_BG_64x64  = %0_101_0000
VDC_BG_128x64 = %0_110_0000
VDC_BG_128x64 = %0_111_0000

; DMA Control register flags.
; Enables VRAM to SATB end of transfer interrupt.
VDC_DMA_SATB_ENABLE = %0000_0001 
; Enables VRAM to VRAM end of transfer interrupt.
VDC_DMA_VRAM_ENABLE = %0000_0010
; Source address direction (increment).
VDC_DMA_SRC_INC     = %0000_0000
; Source address direction (decrement).
VDC_DMA_SRC_DEC     = %0000_0100
; Destination address direction (increment).
VDC_DMA_DST_INC     = %0000_0000
; Destination address direction (decrement).
VDC_DMA_DST_DEC     = %0000_1000
; Enable SATB DMA auto-transfer.
VDC_DMA_SATB_AUTO   = %0001_0000

