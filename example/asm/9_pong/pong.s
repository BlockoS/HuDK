;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;
    .include "startup.asm"
    .include "vdc_sprite.inc"       ; [todo] remove

BALL_DIAMETER = 8
BALL_SPRITE_SIZE = 16

SCROLL_Y = -8

BALL_X_MIN = 8 - (BALL_SPRITE_SIZE - BALL_DIAMETER) / 2
BALL_X_MAX = 248 - BALL_SPRITE_SIZE + (BALL_DIAMETER) / 2

BALL_Y_MIN = 16 + (BALL_DIAMETER / 2) - SCROLL_Y
BALL_Y_MAX = 216 - (BALL_DIAMETER / 2) - SCROLL_Y

PAD_SPRITE_WIDTH = 16
PAD_SPRITE_HEIGHT = 32

PAD_WIDTH  = 8
PAD_HEIGHT = 32

PAD_X = 20

PAD_Y_MIN = 16 + (PAD_HEIGHT/2) - SCROLL_Y
PAD_Y_MAX = 216 - (PAD_HEIGHT/2) - SCROLL_Y

VDC_CR_FLAGS = VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE | VDC_CR_HBLANK_ENABLE
VDC_DMA_FLAGS = VDC_DMA_SAT_AUTO | VDC_DMA_SATB_ENABLE

PAD_SPRITE_PATTERN = $1800
BALL_SPRITE_PATTERN = $1840

SPEED_INC_DELAY = 5
SPEED_MAX = 10

    .zp
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

bounce_count .ds 1
speed_inc_delay .ds 1

    .code
_main: 
    ; Set BAT size.
    lda    #VDC_BG_32x32
    jsr    vdc_set_bat_size

    ; Set map bounds.
    ldx    #00
    lda    _vdc_bat_height 
    jsr    map_set_bat_bounds

    ; Load tileset palette.
    stb    #bank(pal_00), <_bl
    stw    #pal_00, <_si
    jsr    map_data
    cla
    ldy    #(pal_00_size/32)
    jsr    vce_load_palette

    ; Load tileset gfx.
    stb    #bank(gfx_00), <_bl
    stw    #pong_map_tile_vram, <_di
    stw    #gfx_00, <_si
    stw    #(gfx_00_size >> 1), <_cx
    jsr    vdc_load_data

    ; Load sprite palette.
    stb    #bank(sprites_pal), <_bl
    stw    #sprites_pal, <_si
    jsr    map_data
    lda    #16
    ldy    #1
    jsr    vce_load_palette

    ; Load sprite data.
    stb    #bank(sprites_data), <_bl
    stw    #PAD_SPRITE_PATTERN, <_di
    stw    #sprites_data, <_si
    stw    #(sprites_data_size >> 1), <_cx
    jsr    vdc_load_data

    ; Set map infos.
    map_set map_00, pong_map_tile_vram, tile_pal_00, #pong_map_width, #pong_map_height, #00

    ; Copy map from (0,0) to (16, map_height) to BAT.
    ; Remember that this is a 16x16 map.
    map_copy_16 #0, #0, #0, #0, #pong_map_width, #pong_map_height

    ; Set scroll window.
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

    ; Set VDC DMA for VRAM/SATB DMA transfer.
    vdc_reg  #VDC_DMA_CR
    vdc_data #VDC_DMA_FLAGS

    ; Set VRAM SATB source address.
    stw    #$7000, <_si
    jsr    vdc_sat_addr

    ; Clear irq config flag.
    stz    <irq_m
    ; Set vsync vec.
    irq_on INT_IRQ1

    ; Reset players score.
    stz    <player_score
    stz    <player_score+1
    
    ; and Print them.
    ldx    #0
    jsr    print_score
    ldx    #1
    jsr    print_score

    ; Initialize random numger generator.
    lda    #$c7
    ldx    #$ea
    jsr    rand8_seed

    ; Setup speed increment delay and bounce countdown.
    lda    #SPEED_INC_DELAY
    sta    <speed_inc_delay
    sta    <bounce_count

    ; Reset game states.
    jsr    game_reset

    ; Here comes the main loop.
@loop:
    vdc_wait_vsync

    ; Move players pad.
    clx
    jsr    player_update
    inx
    jsr    player_update

    ; Update ball position and compute collisions.
    jsr    ball_update
    
    ; Update sprite attribute table.
    jsr    spr_update

    ; Update scrore if needed.
    jsr    game_update

    bra    @loop 
  
; Update sprite table.
spr_update:
    ; Player #0 pad.
    ldy    #$00

    ; The player coordinate is at the center of the pad.
    ; Sprite origin is in the upper left corner.
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

    ; Player #1 pad.
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

    ; Ball.
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

; Move player pad according to joypad state.
; The pad only moves vertically. We just have to check if eigher UP or DOWN were pressed.
; X gives the player id. 
player_update:
    lda    joypad, X
    bit    #JOYPAD_UP
    beq    @down
        lda    <pad_pos_y, X            ; The pad moves up.
        sec
        sbc    <pad_speed, X
        cmp    #PAD_Y_MIN               ; It can't go further than PAD_Y_MIN.
        bcs    @l0
            lda    #PAD_Y_MIN
@l0:
        sta    <pad_pos_y, X
        rts
@down:
    lda    joypad, X
    bit    #JOYPAD_DOWN
    beq    @end
        lda    <pad_pos_y, X            ; The pad moves down.
        clc
        adc    <pad_speed, X
        cmp    #PAD_Y_MAX               ; Clamp the Y coordinate to PAD_Y_MAX.
        bcc    @l1
            lda    #PAD_Y_MAX
@l1:
        sta    <pad_pos_y, X
@end:
    rts

; When the ball hits the upper or lower floor, the direction angle is simply refleced.
; This means that we negates the Y coordinate. As y = sin(dir), y' = -y = -sin(ball_dir).
; As sin(-t) = -t, we just have to negate ball_dir.
ball_reflect_floor:
    lda    <ball_dir
    eor    #$ff
    inc    A
    sta    <ball_dir
    rts

; Compute the ball direction angle when it hits a pad.
ball_reflect_pad:
    ; We don't compute a real reflexion (PI - angle).
    ; The bounce angle is computed w/r the difference between the ball and pad y coordinates.
    ; right pad: out_angle = -PI/4 + (ball_pos_y - pad_pos_y + pad_height/2)/pad_height * PI/2
    ; left pad : out_angle = 5PI/4 - (ball_pos_y - pad_pos_y + pad_height/2)/pad_height * PI/2
    ; with PI=256, pad_height=32
    ; right_pad: out_angle = 224 + (ball_pos_y - pad_pos_y + 16) * 2
    ; left_pad : out_angle = 160 - (ball_pos_y - pad_pos_y + 16) * 2
    
    lda    <ball_pos_x+1
    bpl    @right
@left:
        lda    <ball_pos_y+1    ; Compute a = (ball_pos_y - pad_pos_y + 16) * 2
        sec                     ; Remember that ball_pos_y is a 8:8 fixed point math value.
        sbc    <pad_pos_y+1     ; And this is the left pad.
        adc    #16
        asl    A
        eor    #$ff             ; Negate a.
        inc    A
        clc
        adc    #160             ; Finally add 160 to get the reflected ball angle on the left pad.
        sta    <ball_dir
        rts
@right:
    lda    <ball_pos_y+1        ; Same as above.
    sec
    sbc    <pad_pos_y           ; But for the right player.
    clc
    adc    #16
    asl    A
    clc
    adc    #224                 ; and we are done.
    sta    <ball_dir
    rts


; Move the ball along the direction vector.
ball_move:
    ; The direction vector is given by (cos(ball_dir), sin(ball_dir)).
    ; cos and sin tables are 8 bits signed values. Some special care
    ; must be taken here. It can't be simply added because the ball position
    ; is a 16 bits. More precisely a 8:8 fixed point math value. The MSB
    ; contains the integer part and the LSB the decimal part. So if the 
    ; cosine/sine is negative, $ff must be added to the MSB.
    cly                         ; Direction vector MSB (0).
    ldx    <ball_dir
    lda    cos, X
    bpl    @l0
        dey                     ; The cosine is negative. The MSB is set to $ff.
@l0:
    clc                         ; ball_pos_x += ball_dir
    adc    <ball_pos_x
    sta    <ball_pos_x
    tya
    adc    <ball_pos_x+1
    sta    <ball_pos_x+1

    cly                         ; Do the same for sine.
    ldx    <ball_dir
    lda    sin, X
    bpl    @l1
        dey
@l1:
    clc
    adc    <ball_pos_y
    sta    <ball_pos_y
    tya
    adc    <ball_pos_y+1
    sta    <ball_pos_y+1
    rts

; [todo] comment
ball_update_speed:
    dec    <bounce_count
    bne    @l0
        lda    <ball_speed
        cmp    #SPEED_MAX
        bcs    @l0
            lda    <speed_inc_delay
            asl    A
            sta    <speed_inc_delay
            sta    <bounce_count
            inc    <ball_speed
@l0:
    rts

; Move ball and compute the collision against the field and pads.
ball_update:
    ; Integrate along the direction vector so that we didn't miss any collision.
    lda    <ball_speed
@integrate:
    pha

    stb    <ball_pos_x+1, <ball_prev_pos_x      ; Save the current position (only the integer part).
    stb    <ball_pos_y+1, <ball_prev_pos_y

    jsr    ball_move                            ; Move the ball one step along the direction vector.
    
    lda    <ball_pos_x+1                        ; Check if the ball X position is close to the pad.
    sec                                         ; We perform a coordinate change so that the pad is located on the left. 
    sbc    #128                                 ; The pad X coordinate is fixed, but the ball needs to be
    bcs    @l0                                  ;    x' = abs(screen_width/2 - ball_pos_x)
        eor    #$ff
        inc    A
@l0:                                            ; There might be a collision if (x'+ ball_radius) >= (128-pad_x-pad_width/2)
    cmp    #(128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)
    bcc    @no_collision
        lda    <ball_prev_pos_x                 ; Check if this is the first time. 
        sec
        sbc    #128
        bcs    @l1
            eor    #$ff
            inc    A
@l1:
        cmp    #(128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)
        bcs    @no_collision

            clx                                 ; We will now test the Y axis.
            lda    <ball_pos_x+1                ; First, we need determine which pad is closest to the ball.
            cmp    #128                         ; The pad index will be stored in X.
            bcc    @pad_0
                inx
@pad_0:
            lda    <ball_pos_y+1                ; The ball intersects the pad if the distance between the ball and pad position
            sec                                 ; is less or equal to sum of the ball radius and half the pad height.
            sbc    <pad_pos_y, X
            bcs    @l2                          ; We are taking the absolute value here.
                eor    #$ff
                inc    A
@l2:
            cmp    #((BALL_DIAMETER + PAD_HEIGHT)/2)
            bcs    @no_collision
                jsr    ball_reflect_pad         ; The ball hit a pad, so we compute the new ball direction.
                jsr    ball_update_speed        ; We update the ball speed after a given number of bounces.
                bra    @end
@no_collision:
    lda    #BALL_Y_MIN                          ; We check here if the ball hits the floor.
    cmp    <ball_pos_y+1
    bcs    @y1
    lda    #BALL_Y_MAX
    cmp    <ball_pos_y+1
    bcs    @y2
@y1:
        asl    A                                ; The ball position is reflected : ball_pos_y = 2*floor_position - ball_pos_y
        sec
        sbc    <ball_pos_y+1
        sta    <ball_pos_y+1

        jsr    ball_reflect_floor               ; Compute new ball direction.
@y2:
@end:
    pla
    dec    A
    bne    @integrate

    rts

; Reset game states.
game_reset:
    ; Reset pads position and speed.
    stb    #PAD_X, <pad_pos_x
    stb    #128, <pad_pos_y
    stb    #3, <pad_speed

    stb    #(256-PAD_X), <pad_pos_x+1
    stb    #128, <pad_pos_y+1
    stb    #3, <pad_speed+1

    ; Move the ball to the center of the screen.
    stz    <ball_pos_x
    stz    <ball_pos_y
    lda    #(128-BALL_DIAMETER/2)
    sta    <ball_pos_x+1
    sta    <ball_pos_y+1

    ; Reset ball speed.
    stb    #3, <ball_speed

    ; The ball is randomly thrown between [-PI/4,PI/4] or [3PI/4,5PI/4].
    ; We use the clock_tt as our random variable. It's not the best one, but it'll do the trick.
    jsr    rand8
    and    #63          ; We clamp A so that it's between 0 and 63 eg [0,PI/2[
    clc
    adc    #224         ; It's not between [-PI/4,PI/4[
    sta    ball_dir
    ; Flip a coin to mirror the direction.
    jsr    rand8
    bit    #1
    beq    @no_flip
        lda    #128     ; angle = PI - angle
        sec
        sbc    <ball_dir
        sta    <ball_dir
@no_flip:
    rts

; This array contains the BAT X position for players score.
player_score_pos:
    .byte 16-3-1
    .byte 16+1

; Increment and print player score.
; X contains the player id.
update_score:
    inc   <player_score,X

; Print player score.
print_score:
    phx
    lda    player_score_pos, X      ; Set VRAM Write address
    tax
    lda    #1
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    
    plx
    lda    <player_score, X         ; Print player score
    jsr    print_dec_u8

    rts

; This routine is a little bit misnamed.
; It checks if the ball went past one of the pads. If that's the case,
; the score of the other player is incremented, and the ball/pad position reseted.
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

; the sine and cosine tables generated by table.c
  .include "sin.inc"

; bank 1 contains the sprites, the tiles, the palettes and the map.
  .data
  .bank 1
  .org $6000

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
