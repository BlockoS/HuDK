;;
;; Title: Font routines.
;;

;;
;; function: font_load_default
;; Load default font to VRAM.
;;
;; Load a 8x8 1bpp font and set font base address for text
;; display routines.
;; The first 96 characters of the font must match the ones
;; of the [$20,$7A] range of the ASCII table. 
;; 
;; Parameters:
;;   _di - VRAM address where the font will be copied.
;;
font_load_default:
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
 
    lda    #bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jmp    vdc_load_1bpp

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
    lda    <font_base+1
    and    #$0f
    sta    <_al
    asl    A
    asl    A
    asl    A
    asl    A
    ora    <_al
    sta    <font_base+1
    rts

