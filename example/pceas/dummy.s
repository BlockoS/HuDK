    .include "hudk.s"
    .include "vgm.s"
main:
    lda    #.bank(hudk.bitmap)
    sta    <_bl
    stw    #$2200, <_di
    stw    #hudk.bitmap, <_si
    stw    #((hudk.bitmap.end - hudk.bitmap) >> 1), <_cx
    jsr    vdc_load_data
   
    stw    #$2e00, <_di 
    lda    #.bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load
    
    lda    #.bank(hudk.bitmap)
    sta    <_bl

    stw    #hudk.palette, <_si
    jsr    map_data
    cla
    ldy    #$02
    jsr    vce_load_palette

    ; setup bat
    stw    #$0220, <_si

    ldx    #0
    lda    #10
    jsr    vdc_calc_addr

    ldy    #$06
.l0:
    jsr    vdc_set_write
    addw   #64, <_di

    ldx    #$20
.l1:
        vdc_data <_si
        incw   <_si
        dex
        bne    .l1
    dey
    bne    .l0

    lda    #$01
    jsr    font_set_pal

	stw    #ascii_string, <_si
    lda    #18
    sta    <_al
    lda    #7
    sta    <_ah
    ldx    #7
    lda    #1
    jsr    print_string

    lda    #18
    sta    <_al
    lda    #5
    sta    <_ah
    lda    #'#'
    sta    <_bl
    ldx    #02
    lda    #17
    jsr    print_fill
 
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE | VDC_CR_VBLANK_ENABLE)
    
;    lda #low(datastorm_base_address)
;    sta <vgm_base
;    sta <vgm_ptr

;    lda #high(datastorm_base_address)
;    sta <vgm_base+1
;    sta <vgm_ptr+1

;    lda #datastorm_bank
;    sta <vgm_bank

;    lda #datastorm_loop_bank
;    sta <vgm_loop_bank

;    stw #datastorm_loop, <vgm_loop_ptr
    
;    lda <vgm_base+1
;    clc
;    adc #$20
;    sta <vgm_end

    smb0 <map_wrap

    lda <font_base
    sta <map_tile_base
    lda <font_base+1
    and #$0f
    sta <map_tile_base+1

    lda #bank(tilemap)
    sta <map_bank
    stw #(tilemap), <map_address

    lda #bank(tile_palettes)
    sta <map_pal_bank
    stw #tile_palettes, <map_pal_address

    stw #05, <map_width
    stw #07, <map_height

    lda #00
    sta <map_bat_top
    lda #32
    sta <map_bat_bottom
    
    clx
    lda <map_bat_top
    jsr vdc_calc_addr
    stw <_di, <map_bat_top_base

    lda #21
    sta <_al
    lda #17
    sta <_ah
    lda #$00
    sta <_cl
    lda #$00
    sta <_ch
    lda #$07
    sta <_dl
    lda #$07
    sta <_dh
    jsr map_load
 
.loop:
    vdc_reg  #VDC_CR
    lda    vdc_data_l
    bit    #VDC_STATUS_VBLANK
    beq    .nop
; [todo]        jsr    vgm_update
.nop
    bra    .loop    

ascii_string:
    .db "Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
    .db "Aenean commodo ligula eget dolor.\nAenean massa.",$00
    
    .bank  $01
    .org   $6000

hudk.palette:
    .incbin "data/hudk.pal"
    .dw $0000, $01ff, $0007, $0000, $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

hudk.bitmap:
    .incbin "data/hudk.dat"
hudk.bitmap.end:

tilemap:
    .db $01, $02, $03, $04, $05
    .db $11, $12, $13, $14, $15
    .db $21, $22, $23, $24, $25
    .db $31, $32, $33, $34, $35
    .db $06, $07, $08, $09, $0A
    .db $16, $17, $18, $19, $1A
    .db $26, $27, $28, $29, $2A

tile_palettes:
    .db $10,$00,$00,$00,$10,$10,$00,$00,$00,$10,$10,$10,$10,$10,$10,$10
    .db $10,$00,$10,$00,$10,$10,$00,$10,$10,$10,$10,$10,$10,$10,$10,$10
    .db $10,$00,$00,$00,$10,$10,$00,$00,$00,$10,$10,$10,$10,$10,$10,$10
    .db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10

    .include "font.inc"

; [todo] vgm data
;    .data
;    .include "data/datastorm.inc"
