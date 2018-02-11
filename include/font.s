;;
;; Title: Font routines.
;;
    .code
;;
;; function: font_load
;; Load 1bpp font to VRAM.
;;
;; Load a 8x8 1bpp font and set font base address for text
;; display routines.
;; The first 96 characters of the font must match the ones
;; of the [$20,$7A] range of the ASCII table. 
;;
;; Note:
;; Background color for the font is the palette entry #2.
;; Whereas foreground color is at index #1.
;;
;; Parameters:
;;   _di - VRAM address where the font will be copied.
;;   _bl - font bank
;;   _si - font address
;;   _cx - number of characters to load
;;
font_load:
    ; font_base = _di >> 4
    lda    <_di+1
    sta    <font_base+1
    lda    <_di
    lsr    <font_base+1
    ror    A
    lsr    <font_base+1
    ror    A
    lsr    <font_base+1
    ror    A
    lsr    <font_base+1
    ror    A
    sta    <font_base
 
    jsr    map_data
    jsr    vdc_set_write
    
    ldx    <_cl
    beq    @l3
    cly
@l0:
        lda    [_si], Y
        vdc_data_l              ; bitplane #0
        eor    #$ff
        vdc_data_h              ; bitplane #1
        iny
        cpy    #$08
        bne    @l2
            cly
            ; unroll loop for the last 2 bitplanes
            st1    #$00         ; bitplane #2
            st2    #$00         ; bitplane #3
            st2    #$00         ; bitplane #2+3
            st2    #$00
            st2    #$00
            st2    #$00
            st2    #$00
            st2    #$00
            st2    #$00

            lda    <_si         ; increment source pointer
            clc
            adc    #$08
            sta    <_si
            bcc    @l2
                inc    <_si+1
@l2:
    dex
    bne    @l0
    jsr    remap_data 
@l3:
    dec    <_ch
    bpl    @l0

    jsr    unmap_data

    rts

;;
;; function: font_set_addr
;; Set font address.
;; 
;; Parameters:
;;   X - VRAM address LSB.
;;   A - VRAM address MSB.
;;
font_set_addr:
    ; compute VRAM base address.
    stx    <font_base
    lsr    <font_base
    ror    A
    lsr    <font_base
    ror    A
    lsr    <font_base
    ror    A
    lsr    <font_base
    ror    A
    sta    <_al
    ; restore palette index
    lda    <font_base+1
    ora    <_al
    sta    <font_base+1
    rts

;;
;; function: font_set_pal
;; Set font palette.
;; 
;; Parameters:
;;   A - Palette index.
;;
font_set_pal:
    sax
    lda    <font_base+1
    and    #$0f
    sta    <_al
    sax
    asl    A
    asl    A
    asl    A
    asl    A
    ora    <_al
    sta    <font_base+1
    rts

