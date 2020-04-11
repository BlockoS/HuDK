;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "start.s"
    .include "vdc_sprite.inc"

BALL_DIAMETER = 8
BALL_SPRITE_SIZE = 16

SCROLL_Y = 0

BALL_X_MIN = 8 - (BALL_SPRITE_SIZE - BALL_DIAMETER) / 2
BALL_X_MAX = 248 - BALL_SPRITE_SIZE + (BALL_DIAMETER) / 2

BALL_Y_MIN = 16 + (BALL_DIAMETER / 2) - SCROLL_Y
BALL_Y_MAX = 224 - (BALL_DIAMETER / 2) - SCROLL_Y

PAD_SPRITE_WIDTH = 16
PAD_SPRITE_HEIGHT = 32

PAD_WIDTH  = 8
PAD_HEIGHT = 32

PAD_X = 20

PAD_Y_MIN = 16 + (PAD_HEIGHT/2) - SCROLL_Y
PAD_Y_MAX = 224 - (PAD_HEIGHT/2) - SCROLL_Y

VDC_CR_FLAGS = VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE | VDC_CR_HBLANK_ENABLE
VDC_DMA_FLAGS = VDC_DMA_SAT_AUTO | VDC_DMA_SATB_ENABLE

PAD_SPRITE_PATTERN = $1800
BALL_SPRITE_PATTERN = $1840

    .zeropage
ball_prev_pos_x .ds 1
ball_prev_pos_y .ds 1

ball_pos_x .ds 2
ball_pos_y .ds 2

ball_dir .ds 1
ball_speed .ds 1

pad_pos_x .ds 2
pad_pos_y .ds 2

pad_speed .ds 2

player_score .ds 2

    .code
_main: 
    ; set BAT size
    lda    #VDC_BG_32x32
    jsr    vdc_set_bat_size

    ; set map bounds
    ldx    #00
    lda    vdc_bat_height 
    jsr    map_set_bat_bounds

    ; load tileset palette
    stb    #bank(pal_00), <_bl
    stw    #pal_00, <_si
    jsr    map_data
    cla
    ldy    #(pal_00_size/32)
    jsr    vce_load_palette

    ; load tileset gfx
    stb    #bank(gfx_00), <_bl
    stw    #pong_map_tile_vram, <_di
    stw    #gfx_00, <_si
    stw    #(gfx_00_size >> 1), <_cx
    jsr    vdc_load_data

    ; load sprite palette
    stb    #bank(sprites_pal), <_bl
    stw    #sprites_pal, <_si
    jsr    map_data
    lda    #16
    ldy    #1
    jsr    vce_load_palette

    ; load sprite data
    stb    #bank(sprites_data), <_bl
    stw    #PAD_SPRITE_PATTERN, <_di
    stw    #sprites_data, <_si
    stw    #(sprites_data_size >> 1), <_cx
    jsr    vdc_load_data

    ; set map infos
    map_set map_00, pong_map_tile_vram, tile_pal_00, #pong_map_width, #pong_map_height, #00

    ; copy map from (0,0) to (16, map_height) to BAT
    ; remember that this is a 16x16 map
    map_copy_16 #0, #0, #0, #0, #pong_map_width, #pong_map_height

    ; set scroll windows
    lda    #$00
    sta    scroll_top
    lda    #254
    sta    scroll_bottom
    stz    scroll_x_lo
    stz    scroll_x_hi
    lda    #SCROLL_Y
    sta    scroll_y_lo
    stz    scroll_y_hi
    lda    #(VDC_CR_FLAGS | $01)
    sta    scroll_flag

    vdc_reg  #VDC_DMA_CR
    vdc_data #VDC_DMA_FLAGS

    stw    #$7000, <_si
    jsr    vdc_sat_addr

    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

    stz    <player_score
    stz    <player_score+1
    
    ldx    #0
    jsr    print_score
    
    ldx    #1
    jsr    print_score

    jsr    game_reset

@loop:
    vdc_wait_vsync

    clx
    jsr    player_update
    inx
    jsr    player_update

    jsr    ball_update
    jsr    spr_update

    jsr    game_update

    bra    @loop 
  
spr_update:
    ; pad
    ldy    #$00

    lda    <pad_pos_x
    sec
    sbc    #(PAD_SPRITE_WIDTH/2)
    ldx    #0
    jsr    spr_x

    lda    <pad_pos_y
    sec
    sbc    #(PAD_SPRITE_HEIGHT/2)
    ldx    #0
    jsr    spr_y

    lda    #low(PAD_SPRITE_PATTERN)
    ldx    #high(PAD_SPRITE_PATTERN)
    jsr    spr_pattern

    lda    #0
    jsr    spr_pal

    lda    #$01
    jsr    spr_pri

    stb    #(VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK), <_al
    lda    #(VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_32)
    jsr    spr_ctrl

    ldy    #$01

    lda    <pad_pos_x+1
    sec
    sbc    #(PAD_SPRITE_WIDTH/2)
    ldx    #0
    jsr    spr_x

    lda    <pad_pos_y+1
    sec
    sbc    #(PAD_SPRITE_HEIGHT/2)
    ldx    #0
    jsr    spr_y

    lda    #low(PAD_SPRITE_PATTERN)
    ldx    #high(PAD_SPRITE_PATTERN)
    jsr    spr_pattern

    lda    #0
    jsr    spr_pal

    lda    #$01
    jsr    spr_pri

    stb    #(VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK), <_al
    lda    #(VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_32)
    jsr    spr_ctrl

    ; ball
    ldy    #$02

    lda    <ball_pos_x+1
    sec
    sbc    #(BALL_SPRITE_SIZE/2)
    ldx    #00
    jsr    spr_x

    lda    <ball_pos_y+1
    sec
    sbc    #(BALL_SPRITE_SIZE/2)
    ldx    #0
    jsr    spr_y

    lda    #low(BALL_SPRITE_PATTERN)
    ldx    #high(BALL_SPRITE_PATTERN)
    jsr    spr_pattern

    lda    #0
    jsr    spr_pal

    lda    #$01
    jsr    spr_pri

    stb    #(VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK), <_al
    lda    #(VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16)
    jsr    spr_ctrl
    
    jsr    spr_update_satb
    rts

player_update:
    lda    joypad, X
    bit    #JOYPAD_UP
    beq    @down
        lda    <pad_pos_y, X
        sec
        sbc    <pad_speed, X
        cmp    #PAD_Y_MIN
        bcs    @l0
            lda    #PAD_Y_MIN
@l0:
        sta    <pad_pos_y, X
        rts
@down:
    lda    joypad, X
    bit    #JOYPAD_DOWN
    beq    @end
        lda    <pad_pos_y, X
        clc
        adc    <pad_speed, X
        cmp    #PAD_Y_MAX
        bcc    @l1
            lda    #PAD_Y_MAX
@l1:
        sta    <pad_pos_y, X
@end:
    rts

ball_reflect_floor:
    lda    <ball_dir
    eor    #$ff
    inc    A
    sta    <ball_dir
    rts

ball_reflect_pad:
    ; We don't compute a real reflexion (PI - angle).
    ; The bounce angle is computed w/r the difference between the ball and pad y coordinates.
    ; right pad: out_angle = -PI/4 + (ball_y - pad_y + pad_h/2)/pad_h * PI/2
    ; left pad : out_angle = 5PI/4 - (ball_y - pad_y + pad_h/2)/pad_h * PI/2
    ; with PI=256, pad_h=32
    ; right_pad: out_angle = 224 + (ball_y - pad_y + 16) * 2
    ; left_pad : out_angle = 160 - (ball_y - pad_y + 16) * 2
    
    lda    <ball_pos_x+1
    bpl    @right
@left:
        lda    <ball_pos_y+1
        sec
        sbc    <pad_pos_y+1
        adc    #16
        asl    A
        eor    #$ff
        inc    A
        clc
        adc    #160
        sta    <ball_dir
        rts
@right:
    lda    <ball_pos_y+1
    sec
    sbc    <pad_pos_y
    clc
    adc    #16
    asl    A
    clc
    adc    #224
    sta    <ball_dir
    rts

ball_move_x:
    cly
    ldx    <ball_dir
    lda    cos, X
    bpl    @l0
        dey
@l0:
    clc
    adc    <ball_pos_x
    sta    <ball_pos_x
    tya
    adc    <ball_pos_x+1
    sta    <ball_pos_x+1
    rts

ball_move_y:
    cly
    ldx    <ball_dir
    lda    sin, X
    bpl    @l0
        dey
@l0:
    clc
    adc    <ball_pos_y
    sta    <ball_pos_y
    tya
    adc    <ball_pos_y+1
    sta    <ball_pos_y+1
    rts


ball_update:
    lda    <ball_speed
@integrate:
    pha

    stb    <ball_pos_x+1, <ball_prev_pos_x
    stb    <ball_pos_y+1, <ball_prev_pos_y

    jsr    ball_move_x
    jsr    ball_move_y
    
    lda    <ball_pos_x+1
    sec
    sbc    #128
    bcs    @l0
        eor    #$ff
        inc    A
@l0:
    cmp    #(128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)
    bcc    @no_collision
        lda    <ball_prev_pos_x
        sec
        sbc    #128
        bcs    @l1
            eor    #$ff
            inc    A
@l1:
        cmp    #(128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)
        bcs    @no_collision

            clx
            lda    <ball_pos_x+1
            cmp    #128
            bcc    @pad_0
                inx
@pad_0:
            lda    <ball_pos_y+1
            sec
            sbc    <pad_pos_y, X
            bcs    @l2
                eor    #$ff
                inc    A
@l2:
            cmp    #((BALL_DIAMETER + PAD_HEIGHT)/2)
            bcs    @no_collision
                ; reflect
                jsr    ball_reflect_pad
                bra    @end
@no_collision:
    lda    #BALL_Y_MIN
    cmp    <ball_pos_y+1
    bcs    @y1
    lda    #BALL_Y_MAX
    cmp    <ball_pos_y+1
    bcs    @y2
@y1:
        ; reflect 
        asl    A
        sec
        sbc    <ball_pos_y+1
        sta    <ball_pos_y+1

        jsr    ball_reflect_floor
@y2:
@end:
    pla
    dec    A
    bne    @integrate

    rts

game_reset:
    stb    #PAD_X, <pad_pos_x
    stb    #128, <pad_pos_y
    stb    #3, <pad_speed

    stb    #(256-PAD_X), <pad_pos_x+1
    stb    #128, <pad_pos_y+1
    stb    #3, <pad_speed+1


    stz    <ball_pos_x
    stz    <ball_pos_y
    lda    #(128-BALL_DIAMETER/2)
    sta    <ball_pos_x+1
    sta    <ball_pos_y+1

    stb    #3, <ball_speed
    stb    #0, <ball_dir           ; [todo] random
    rts

player_score_pos:
    .byte 16-3-1
    .byte 16+1

update_score:
    inc   <player_score,X

print_score:
    phx
    lda    player_score_pos, X
    tax
    lda    #1
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    
    plx
    lda    <player_score, X
    jsr    print_dec_u8

    rts

game_update: 
    lda    <ball_pos_x+1
    cmp    #BALL_DIAMETER
    bcs    @l0
        ldx   #1
        jsr   update_score
        jsr   game_reset
@l0:

    lda    <ball_pos_x+1
    cmp    #(256-BALL_DIAMETER)
    bcc    @l1
        ldx   #0
        jsr   update_score
        jsr   game_reset
@l1:
    rts

  .include "sin.inc"

  .ifdef MAGICKIT
    .data
    .bank 1
    .org $6000
  .else
    .ifdef CA65
    .segment "BANK01"
    .endif
  .endif

    .include "data/pong_map.inc"

map_00:
    .incbin "data/pong_map.map"
gfx_00:
    .incbin "data/pong_map.bin"
gfx_00_size = * - gfx_00
tile_pal_00:
    .incbin "data/pong_map.idx"
pal_00:
    .incbin "data/pong_map.pal"
pal_00_size = * - pal_00

; [todo] exlpain layout
sprites_data:
    .incbin "data/sprites.bin"
sprites_data_size = * - sprites_data

sprites_pal:
    .incbin "data/palette.bin"
