;;
;; Section: VDC I/O Ports and Registers.
;;
;; Group: Ports.
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
;;  - Writing the lower five bits of video_reg $0000 selects which register will
;;    be accessed at video_data_l ($0002) and video_data_h ($0003).
;;    Only registers $00 to $02 and  $05 to $13 are valid; selecting registers 
;;    $03, $04 or $14 to $1F and trying to access them has no effect (see <VDC registers>).
;;  - Reading video_reg $0000 returns a set of status flags (see <VDC status flags>). 
;; 
video_reg   = videoport
video_reg_l = video_reg
video_reg_h = video_reg+1

;;
;; ushort: video_data
;; VDC data
;;
;; Data to be read or written to the a VDC register.
;;
video_data   = videoport+2
video_data_l = video_data
video_data_h = video_data+1

;;
;; Group: VDC status flags. 
;; Description of the status flags returned by reading <video_reg>.
;;
;; bit 15-07 - unused
;; bit 6     - busy flag (<VDC_STATUS_BUSY>)
;; bit 5     - vertical blanking flag (<VDC_STATUS_VBLANK>)
;; bit 4     - VRAM to VRAM DMA end of transfer flag (<VDC_STATUS_VRAM_DMA_END>)
;; bit 3     - VRAM to SATB DMA end of transfer flag (<VDC_STATUS_SATB_DMA_END>)
;; bit 2     - scanline interrupt flag (<VDC_STATUS_HBLANK>)
;; bit 1     - sprite overflow flag (<VDC_STATUS_SPR_OVERFLOW>)
;; bit 0     - sprite collision flag (<VDC_STATUS_SPR_COLLISION>)
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
;; Section: VDC registers.
;;

;;
;; Group: Registers.
;;

;;
;; ubyte: VDC_MAWR
;; Memory Address Write Register
;;
;; Detail:
;; Set the word offset in VRAM where data written to <VDC_DATA> will be stored.
;; The value of this register is automatically incremented after a write to the 
;; MSB of <VDC_DATA>. The increment value is set via bits 11 and 12 of <VDC_CR>.
;;
VDC_MAWR = $00
;;
;; ubyte: VDC_MARR
;; Memory Address Read Register
;;
;; Detail:
;; Set the word offset in VRAM from where data will be read. Just like 
;; <VDC_MAWR>, this register is automatically incremented after a read to the 
;; high byte of <VDC_DATA> and the increment is set via bits 11 and 12 of 
;; <VDC_CR>.
;;
VDC_MARR =  $01
;;
;; ubyte: VDC_DATA
;; VRAM Data register
;;
;; Detail:
;; - Writing to LSB (video_data_l), the CPU data is stored in the write latch.
;;   When the MSB is written (video_data_h), the whole 16 bits from the write
;;   latch and the MSB are transfered to the memory location set with 
;;   <VDC_MAWR>.
;;   <VDC_MAWR> is then automatically incremented according to the value set in
;;   the control register <VDC_CR>.
;; - Reading the LSB (video_data_l) will store the LSB of the read buffer, and
;;   reading the MSG (video_data_h) will store the MSB of the read buffer.
;;   <VDC_MARR> is then incremented by the factor set in <VDC_CR>, and a word is
;;   read of VRAM at the location set by <VDC_MARR> is read and stored in the
;;   read buffer. 
VDC_DATA = $02
;;
;; ubyte: VDC_CR
;; Control Register
;;
;; Detail:
;; Enables or disables VDC interrupts, background or sprite display, and set the
;; read and write auto-increment. See <Control Register Flags> for a complete
;; description.
;;
;; Value:
;;   bit 15-13 - Unused
;;   bit 12-11 - Read/Write auto-increment value <VDC_CR_RW_INC_1>, <VDC_CR_RW_INC_32>, <VDC_CR_RW_INC_64>, <VDC_CR_RW_INC_128> 
;;   bit 10    - DRAM refresh enable (unused)
;;   bit 9-8   - DISP terminal output mode (unused)
;;   bit 7     - Background enable <VDC_CR_BG_ENABLE>
;;   bit 6     - Sprite enable <VDC_CR_SPR_ENABLE> 
;;   bit 5-4   - External sync (unused)
;;   bit 3     - Enable interrupt for vertical blanking <VDC_CR_VBLANK_ENABLE>
;;   bit 2     - Enable interrupt for raster compare <VDC_CR_HBLANK_ENABLE>
;;   bit 1     - Enable interrupt for sprite overflow <VDC_CR_SPR_OVERFLOW_ENABLE>
;;   bit 0     - Enable interrupt for sprite #0 collision <VDC_CR_SPR_COLLISION_ENABLE>
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
;; Value:
;;   bit 15-10 - Unused
;;   bit 9-0   - Scanline number.
;;
VDC_RCR = $06
;;
;; ubyte: VDC_BXR
;; Background X Scroll Register
;;
;; Detail:
;; Horizontal screen position in the virtual background map.
;;
;; Value:
;;   bit 15-10 - Unused
;;   bit 9-0   - Horizontal scroll position.
;;
VDC_BXR = $07
;;
;; ubyte: VDC_BYR
;; Background Y Scroll Register
;;
;; Detail:
;; Vertical screen position in the virtual background map.
;;
;; Value:
;;   bit 15-9 - Unused
;;   bit 8-0  - Vertical scroll position.
;;
VDC_BYR = $07
;;
;; ubyte: VDC_MWR
;; Memory Width Register (MWR)
;;
;; Detail:
;; Set virtual background map size.
;;
;; Value:
;;   bit 15-8 - Unused
;;   bit 7    - CG Mode
;;   bit 4-6  - <Background Map Virtual Size>
;;   bit 3-2  - Sprite Dot Period
;;   bit 0-1  - VRAM Dot Width
;;
VDC_MWR = $09
;;
;; ubyte: VDC_HSR
;; Horizontal Synchro Register
;;
;; Detail:
;; Set horizontal synchro width and start position.
;;
;; Value:
;;   bit 15   - Unused
;;   bit 14-8 - Horizontal Display Start (HDS)
;;   bit 7-5  - Unused
;;   bit 4-0  - Horizontal Sync Width (HSW) 
;;
VDC_HSR = $0A
;;
;; ubyte: VDC_HDR
;; Horizontal Display Register
;;
;; Detail:
;; Set horizontal display width and end position.
;;
;; Value:
;;   bit 15   - Unused
;;   bit 14-8 - Horizontal Display End (HDE)
;;   bit 7    - Unused
;;   bit 6-0  - Horizontal Display Width (HDW)
;; 
VDC_HDR = $0B
;;
;; ubyte: VDC_VSR
;; Vertical Synchro Register
;;
;; Detail:
;; Set vertical synchro width and start position.
;;
;; Value:
;;   bit 15-8 - Vertical Display Start (VDS)
;;   bit 7-5  - Unused
;;   bit 4-0  - Vertical Synchro Width (VSW)
;;
VDC_VSR = $0C
;;
;; ubyte: VDC_VDR
;; Vertical Display Register
;; 
;; Detail:
;; Set vertical display width.
;;
;; Value:
;;   bit 15-9 - Unused
;;   bit 8-0  - Vertical Display Width (VDR)
;; 
VDC_VDR = $0D
;;
;; ubyte: VDC_VCR
;; Vertical Display End Position Register
;;
;; Value:
;;   bit 15-9 - Unused
;;   bit 8-0  - Vertical Display End Position (VCR)
VDC_VCR = $0E
;;
;; ubyte: VDC_DMA_CR
;; DMA Control Register
;;
;; Detail:
;; Enables or disables VRAM to VRAM or VRAM to SATB end of transfer interrupts.
;; Set source and destination direction (increment or decrement), and enable or
;; disable SATB DMA automatic transfer (see <DMA Control Register Flags>).
;;
;; Value:
;;   bit 15-5 - Unused
;;   bit 4    - SATB DMA auto-transfer enable flag <VDC_DMA_SATB_AUTO>
;;   bit 3    - Destination address increment direction <VDC_DMA_DST_INC>, <VDC_DMA_DST_DEC>
;;   bit 3    - Source address increment direction <VDC_DMA_SRC_INC>, <VDC_DMA_SRC_DEC>
;;   bit 1    - VRAM to VRAM end of transfer interrupt enable flag <VDC_DMA_VRAM_ENABLE>
;;   bit 0    - VRAM to SATB end of transfer interrupt enable flag <VDC_DMA_SATB_ENABLE>
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
;; Group: Control Register Flags.
;;

;;
;; ushort: VDC_CR_SPR_COLLISION_ENABLE
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
;; Group: Background Map Virtual Size.
;;

;;
;; bits: VDC_BG_32x32
;; 32x32 virtual background map.
;;
VDC_BG_32x32  = %00000000
;;
;; bits: VDC_BG_64x32
;; 64x32 virtual background map.
;;
VDC_BG_64x32  = %00010000
;;
;; bits: VDC_BG_128x32
;; 128x32 virtual background map.
;;
VDC_BG_128x32 = %00100000
;;
;; bits: VDC_BG_32x64
;; 32x64 virtual background map.
;;
VDC_BG_32x64  = %01000000
;;
;; bits: VDC_BG_64x64
;; 64x64 virtual background map.
;;
VDC_BG_64x64  = %01010000
;;
;; bits: VDC_BG_128x64
;; 128x64 virtual background map.
;;
VDC_BG_128x64 = %01100000

;;
;; Group: DMA Control Register Flags.
;;

;;
;; bits: VDC_DMA_SATB_ENABLE
;; Enables VRAM to SATB end of transfer interrupt.
;;
VDC_DMA_SATB_ENABLE = %00000001 
;;
;; bits: VDC_DMA_VRAM_ENABLE
;; Enables VRAM to VRAM end of transfer interrupt.
;;
VDC_DMA_VRAM_ENABLE = %00000010
;;
;; bits: VDC_DMA_SRC_INC
;; Source address direction (increment).
;;
VDC_DMA_SRC_INC     = %00000000
;;
;; bits: VDC_DMA_SRC_DEC
;; Source address direction (decrement).
;;
VDC_DMA_SRC_DEC     = %00000100
;;
;; bits: VDC_DMA_DST_INC
;; Destination address direction (increment).
;;
VDC_DMA_DST_INC     = %00000000
;;
;; bits: VDC_DMA_DST_DEC 
;; Destination address direction (decrement).
;;
VDC_DMA_DST_DEC     = %00001000
;;
;; bits: VDC_DMA_SATB_AUTO
;; Enable SATB DMA auto-transfer.
;;
VDC_DMA_SATB_AUTO   = %00010000

;;
;; Group: VDC Helper Macros.
;;

;; 
;; macro: VDC_HSR_db
;;
;; Compute the value of the <VDC_HSR> register for a given horizontal screen
;; resolution. This macro outputs the result as 2 .db directives. 
;;
;; Assembly call:
;;   > VDC_HSR_db xres
;;
;; Parameters:
;;   xres - Horizontal screen resolution.
;;

;; 
;; macro: VDC_HDR_db
;;
;; Compute the value of the <VDC_HDR> register for a given horizontal screen
;; resolution. This macro outputs the result as 2 .db directives. 
;;
;; Assembly call:
;;   > VDC_HDR_db xres
;;
;; Parameters:
;;   xres - Horizontal screen resolution.
;;

;;
;; macro: vdc_reg
;; Initialize VDC register.
;; 
;; Assembly call:
;;   > vdc_reg   #VDC_MAWR
;;
;; Parameters:
;;   reg - VDC register.
;;

;
;; macro: vdc_data
;; Set VDC data.
;;
;; Assembly call:
;;   > vdc_data    <_si
;;   > vdc_data    $2210, $3200
;;

;;
;; macro: vdc_data_l
;; Set VDC data LSB.
;;
;; Assembly call:
;;   > lda    something
;;   > vdc_data_l
;;

;;
;; macro: vdc_data_h
;; Set VDC data MSB.
;;
;; Assembly call:
;;   > lda    some_data
;;   > vdc_data_h
;;

;;
;; Group: Default VDC values.
;;
  .ifndef VDC_DEFAULT_BG_SIZE
;; ushort: VDC_DEFAULT_BG_SIZE
;; Default virtual background map size.
VDC_DEFAULT_BG_SIZE = VDC_BG_64x64
  .endif

  .ifndef VDC_DEFAULT_XRES
;;
;; ushort: VDC_DEFAULT_XRES
;; Default horizonale resolution.
;;
VDC_DEFAULT_XRES = 256
  .endif

  .ifndef VDC_DEFAULT_SATB_ADDR
;;
;; ushort: VDC_DEFAULT_SATB_ADDR
;; Default SATB VRAM offset.
;;
VDC_DEFAULT_SATB_ADDR = $7F00
  .endif

  .ifdef MAGICKIT
    .include "pceas/vdc.inc"
  .else
    .ifdef CA65
    .include "ca65/vdc.inc"
    .endif
  .endif
