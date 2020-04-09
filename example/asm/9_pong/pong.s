;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "start.s"
    .include "vdc_sprite.inc"

; [todo] pad 0 & 1

BALL_DIAMETER = 8
BALL_SPRITE_SIZE = 16

BALL_X_MIN = 8 - (BALL_SPRITE_SIZE - BALL_DIAMETER) / 2
BALL_X_MAX = 248 - BALL_SPRITE_SIZE + (BALL_DIAMETER) / 2

BALL_Y_MIN = 16 + (BALL_DIAMETER / 2)
BALL_Y_MAX = 224 - (BALL_DIAMETER / 2)

PAD_SPRITE_WIDTH = 16
PAD_SPRITE_HEIGHT = 32

PAD_WIDTH  = 8
PAD_HEIGHT = 32

PAD_X = 20

PAD_Y_MIN = 16 + (PAD_HEIGHT/2)
PAD_Y_MAX = 224 - (PAD_HEIGHT/2)

VDC_CR_FLAGS = VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_DMA_SAT_AUTO | VDC_DMA_SATB_ENABLE | VDC_CR_VBLANK_ENABLE

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

    vdc_reg  #VDC_DMA_CR
    vdc_data #(VDC_CR_FLAGS)

    stw    #$7000, <_si
    jsr    vdc_sat_addr

    ; clear irq config flag
    stz    <irq_m
    ; set vsync vec
    irq_on INT_IRQ1

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

    stb    #32+64, <ball_dir

@loop:
    vdc_wait_vsync

    jsr    player_update
    jsr    ball_update
    jsr    spr_update
; [todo] check if the ball is past the pad

    bra    @loop 

spr_update:
    ; [todo] loop for pads
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

    ; [todo] param for player id

    lda    joypad
    bit    #JOYPAD_UP
    beq    @down
        lda    <pad_pos_y
        sec
        sbc    <pad_speed
        cmp    #PAD_Y_MIN
        bcs    @l0
            lda    #PAD_Y_MIN
@l0:
        sta    <pad_pos_y
        sta    <pad_pos_y+1
        rts
@down:
    lda    joypad
    bit    #JOYPAD_DOWN
    beq    @end
        lda    <pad_pos_y
        clc
        adc    <pad_speed
        cmp    #PAD_Y_MAX
        bcc    @l1
            lda    #PAD_Y_MAX
@l1:
        sta    <pad_pos_y
        sta    <pad_pos_y+1
@end:
    rts

ball_reflect_floor:
    lda    <ball_dir
    cmp    #64
    bcs    @quad1
@quad0:
        adc    #192
        sta    <ball_dir
        rts
@quad1:
    cmp    #128
    bcs    @quad2
        adc    #64
        sta    <ball_dir
        rts
@quad2:
    cmp    #192
    bcs    @quad3
        adc    #192
        sta    <ball_dir
        rts
@quad3:
        clc
        adc    #64
        sta    <ball_dir
    rts

; [todo add perturbation]
ball_reflect_pad:
    lda    <ball_dir
    cmp    #64
    bcs    @quad1
@quad0:
        adc    #64
        sta    <ball_dir
        rts
@quad1:
    cmp    #128
    bcs    @quad2
        adc    #192
        sta    <ball_dir
        rts
@quad2:
    cmp    #192
    bcs    @quad3
        adc    #64
        sta    <ball_dir
        rts
@quad3:
        clc
        adc    #192
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

; [todo] integrate ball/padd collision
; [todo] for(i=0; i<speed; i++)
ball_update:
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
            cmp    #(PAD_HEIGHT/2)
            bcs    @no_collision
                ; reflect
                jsr    ball_reflect_pad
            rts
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
