/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */

#include "hudk.h"

#define BALL_DIAMETER 8
#define BALL_SPRITE_SIZE 16

#define SCROLL_Y -8

#define BALL_X_MIN 8 - (BALL_SPRITE_SIZE - BALL_DIAMETER) / 2
#define BALL_X_MAX 248 - BALL_SPRITE_SIZE + (BALL_DIAMETER) / 2

#define BALL_Y_MIN 16 + (BALL_DIAMETER / 2) - SCROLL_Y
#define BALL_Y_MAX 216 - (BALL_DIAMETER / 2) - SCROLL_Y

#define PAD_SPRITE_WIDTH 16
#define PAD_SPRITE_HEIGHT 32

#define PAD_WIDTH 8
#define PAD_HEIGHT 32

#define PAD_X 20

#define PAD_Y_MIN 16 + (PAD_HEIGHT/2) - SCROLL_Y
#define PAD_Y_MAX 216 - (PAD_HEIGHT/2) - SCROLL_Y

#define VDC_CR_FLAGS VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE | VDC_CR_HBLANK_ENABLE
#define VDC_DMA_FLAGS VDC_DMA_SAT_AUTO | VDC_DMA_SATB_ENABLE

#define PAD_SPRITE_PATTERN 0x1800
#define BALL_SPRITE_PATTERN 0x1840

#define SPEED_INC_DELAY 5
#define SPEED_MAX 10

#define pong_map_width 16
#define pong_map_height 16
#define pong_map_tile_width 16
#define pong_map_tile_height 16
#define pong_map_tile_vram 0x2200
#define pong_map_tile_pal 0

#incbin(map_00, "data/pong_map.map")
#incbin(gfx_00, "data/pong_map.bin")
#incbin(tile_pal_00, "data/pong_map.idx")
#incbin(pal_00, "data/pong_map.pal")
#incbin(sprites_data, "data/sprites.bin")
#incbin(sprites_pal, "data/palette.bin")

const char sin[320] = {
    0x00,0x03,0x06,0x09,0x0c,0x0f,0x12,0x15,0x18,0x1b,0x1e,0x21,0x24,0x27,0x2a,0x2d,
    0x30,0x33,0x36,0x39,0x3b,0x3e,0x41,0x43,0x46,0x49,0x4b,0x4e,0x50,0x52,0x55,0x57,
    0x59,0x5b,0x5e,0x60,0x62,0x64,0x66,0x67,0x69,0x6b,0x6c,0x6e,0x70,0x71,0x72,0x74,
    0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7b,0x7c,0x7d,0x7d,0x7e,0x7e,0x7e,0x7e,0x7e,
    0x7f,0x7e,0x7e,0x7e,0x7e,0x7e,0x7d,0x7d,0x7c,0x7b,0x7b,0x7a,0x79,0x78,0x77,0x76,
    0x75,0x74,0x72,0x71,0x70,0x6e,0x6c,0x6b,0x69,0x67,0x66,0x64,0x62,0x60,0x5e,0x5b,
    0x59,0x57,0x55,0x52,0x50,0x4e,0x4b,0x49,0x46,0x43,0x41,0x3e,0x3b,0x39,0x36,0x33,
    0x30,0x2d,0x2a,0x27,0x24,0x21,0x1e,0x1b,0x18,0x15,0x12,0x0f,0x0c,0x09,0x06,0x03,
    0x00,0xfd,0xfa,0xf7,0xf4,0xf1,0xee,0xeb,0xe8,0xe5,0xe2,0xdf,0xdc,0xd9,0xd6,0xd3,
    0xd0,0xcd,0xca,0xc7,0xc5,0xc2,0xbf,0xbd,0xba,0xb7,0xb5,0xb2,0xb0,0xae,0xab,0xa9,
    0xa7,0xa5,0xa2,0xa0,0x9e,0x9c,0x9a,0x99,0x97,0x95,0x94,0x92,0x90,0x8f,0x8e,0x8c,
    0x8b,0x8a,0x89,0x88,0x87,0x86,0x85,0x85,0x84,0x83,0x83,0x82,0x82,0x82,0x82,0x82,
    0x81,0x82,0x82,0x82,0x82,0x82,0x83,0x83,0x84,0x85,0x85,0x86,0x87,0x88,0x89,0x8a,
    0x8b,0x8c,0x8e,0x8f,0x90,0x92,0x94,0x95,0x97,0x99,0x9a,0x9c,0x9e,0xa0,0xa2,0xa5,
    0xa7,0xa9,0xab,0xae,0xb0,0xb2,0xb5,0xb7,0xba,0xbd,0xbf,0xc2,0xc5,0xc7,0xca,0xcd,
    0xd0,0xd3,0xd6,0xd9,0xdc,0xdf,0xe2,0xe5,0xe8,0xeb,0xee,0xf1,0xf4,0xf7,0xfa,0xfd,
    0x00,0x03,0x06,0x09,0x0c,0x0f,0x12,0x15,0x18,0x1b,0x1e,0x21,0x24,0x27,0x2a,0x2d,
    0x30,0x33,0x36,0x39,0x3b,0x3e,0x41,0x43,0x46,0x49,0x4b,0x4e,0x50,0x52,0x55,0x57,
    0x59,0x5b,0x5e,0x60,0x62,0x64,0x66,0x67,0x69,0x6b,0x6c,0x6e,0x70,0x71,0x72,0x74,
    0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7b,0x7c,0x7d,0x7d,0x7e,0x7e,0x7e,0x7e,0x7e
};

unsigned char ball_prev_pos_x;
unsigned char ball_prev_pos_y;

unsigned int ball_pos_x;
unsigned int ball_pos_y;

unsigned char ball_dir;
unsigned char ball_speed;

unsigned char pad_pos_x[2];
unsigned char pad_pos_y[2];
unsigned char pad_speed[2];

unsigned char player_score[2];

unsigned char bounce_count;
unsigned char speed_inc_delay;

void main() {
    // set BAT size.
    vdc_set_bat_size(VDC_BG_32x32);

    // Set map bounds.
    map_set_bat_bounds(0, vdc_bat_height);

    // Load tileset palette.
    vce_load_palette(0, 1, pal_00);

    // Load tileset gfx.
    vdc_load_data(pong_map_tile_vram, gfx_00, 640);

    // Load sprite palette.
    vce_load_palette(16, 1, sprites_pal);

    // Load sprite data.
    vdc_load_data(PAD_SPRITE_PATTERN, sprites_data, 256);

    // Set map infos.
    map_set(map_00, pong_map_tile_vram, tile_pal_00, pong_map_width, pong_map_height);

    // Copy map from (0,0) to (16, map_height) to BAT.
    // Remember that this is a 16x16 map.
    map_load_16(0, 0, 0, 0, pong_map_width, pong_map_height);

    // Set scroll window.
    scroll_set(0, 0, 254, 0, SCROLL_Y, VDC_CR_FLAGS | 0x01);

    // Set VDC DMA for VRAM/SATB DMA transfer.
    vdc_reg(VDC_DMA_CR);
    vdc_write(VDC_DMA_FLAGS);

    // Set VRAM SATB source address.
    vdc_sat_addr(0x7000);

    // enable IRQ 1.
    irq_enable(INT_IRQ1);

    // Reset players score.
    player_score[0] = 0;
    player_score[1] = 0;

    // and Print them.
    print_score(0);
    print_score(1);

    // Initialize random numger generator.
    rand8_seed(0xeac7);

    // Setup speed increment delay and bounce countdown.
    speed_inc_delay = SPEED_INC_DELAY;
    bounce_count = SPEED_INC_DELAY;

    // Reset game states.
    game_reset();

    // Here comes the main loop.
    for(;;) {
        vdc_wait_vsync();
        
        // Move players pad.
        player_update(0);
        player_update(1);

        // Update ball position and compute collisions.
        ball_update();

        // Update sprite attribute table.
        spr_update();

        // Update scrore if needed.
        game_update();
    }
}

// Update sprite table.
void spr_update() {
    // Player #0 pad.
    // The player coordinate is at the center of the pad.
    // Sprite origin is in the upper left corner.
    spr_x(0, pad_pos_x[0] - (PAD_SPRITE_WIDTH/2));
    spr_y(0, pad_pos_y[0] - (PAD_SPRITE_HEIGHT/2));
    spr_pattern(0, PAD_SPRITE_PATTERN);
    spr_pal(0, 0);
    spr_pri(0, 1);
    spr_ctrl(0, VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK, VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_32);

    // Player #1 pad.
    spr_x(1, pad_pos_x[1] - (PAD_SPRITE_WIDTH/2));
    spr_y(1, pad_pos_y[1] - (PAD_SPRITE_HEIGHT/2));
    spr_pattern(1, PAD_SPRITE_PATTERN);
    spr_pal(1, 0);
    spr_pri(1, 1);
    spr_ctrl(1, VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK, VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_32);

    // Ball.
    spr_x(2, (ball_pos_x >> 8) - (BALL_SPRITE_SIZE/2));
    spr_y(2, (ball_pos_y >> 8) - (BALL_SPRITE_SIZE/2));
    spr_pattern(2, BALL_SPRITE_PATTERN);
    spr_pal(2, 0);
    spr_pri(2, 1);
    spr_ctrl(2, VDC_SPRITE_WIDTH_MASK | VDC_SPRITE_HEIGHT_MASK, VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16);
    
    spr_update_satb();
}

// Move player pad according to joypad state.
// The pad only moves vertically. We just have to check if eigher UP or DOWN were pressed.
// X gives the player id. 
void player_update(char player_id) {
    if(joypad[player_id] & JOYPAD_UP) {
        // The pad moves up.
        pad_pos_y[player_id] -= pad_speed[player_id];
        // It can't go further than PAD_Y_MIN.
        if(pad_pos_y[player_id] < PAD_Y_MIN) {
            pad_pos_y[player_id] = PAD_Y_MIN;
        }               
    }
    else if(joypad[player_id] & JOYPAD_DOWN) {
        // The pad moves down.
        pad_pos_y[player_id] += pad_speed[player_id];
        // Clamp the Y coordinate to PAD_Y_MAX.
        if(pad_pos_y[player_id] > PAD_Y_MAX) {
            pad_pos_y[player_id] = PAD_Y_MAX;
        }
    }
}

// Compute the ball direction angle when it hits a pad.
void ball_reflect_pad() {
    // We don't compute a real reflexion (PI - angle).
    // The bounce angle is computed w/r the difference between the ball and pad y coordinates.
    // right pad: out_angle = -PI/4 + (ball_pos_y - pad_pos_y + pad_height/2)/pad_height * PI/2
    // left pad : out_angle = 5PI/4 - (ball_pos_y - pad_pos_y + pad_height/2)/pad_height * PI/2
    // with PI=256, pad_height=32
    // right_pad: out_angle = 224 + (ball_pos_y - pad_pos_y + 16) * 2
    // left_pad : out_angle = 160 - (ball_pos_y - pad_pos_y + 16) * 2
    unsigned char x, y;
    x = ball_pos_x >> 8;
    y = ball_pos_y >> 8;
    if(x & 0x80) {
        ball_dir = 160 - (y - pad_pos_y[1] + 16) * 2;
    }
    else {
        ball_dir = 224 + (y - pad_pos_y[0] + 16) * 2;
    }
}

// Move the ball along the direction vector.
void ball_move() {
    unsigned char tmp;
    int dir;    
    // The direction vector is given by (cos(ball_dir), sin(ball_dir)).
    // cos and sin tables are 8 bits signed values. Some special care
    // must be taken here. It can't be simply added because the ball position
    // is a 16 bits. More precisely a 8:8 fixed point math value. The MSB
    // contains the integer part and the LSB the decimal part. So if the 
    // cosine/sine is negative, $ff must be added to the MSB.
    tmp  = sin[(ball_dir+64) & 0xff];
    dir = (tmp & 0x80) ? (0xff00 + tmp) : tmp;
    ball_pos_x += dir;

    tmp = sin[ball_dir];
    dir = (tmp & 0x80) ? (0xff00 + tmp) : tmp;
    ball_pos_y += dir;
}

void ball_update_speed() {
    --bounce_count;
    if(!bounce_count) {
        if(ball_speed < SPEED_MAX) {
            speed_inc_delay *= 2;
            bounce_count = speed_inc_delay;
            ++ball_speed;
        }
    }
}

// Move ball and compute the collision against the field and pads.
void ball_update() {
    char i;
    unsigned char x;
    unsigned char y;
    unsigned char x_old, y_old;
    char player_id;
    char hit;
    // Integrate along the direction vector so that we didn't miss any collision.
    for(i=0; i<ball_speed; i++) {
        // Save the current position (only the integer part).
        ball_prev_pos_x = ball_pos_x >> 8;
        ball_prev_pos_y = ball_pos_y >> 8;

        // Move the ball one step along the direction vector.
        ball_move();

        // Check if the ball X position is close to the pad.
        // We perform a coordinate change so that the pad is located on the left. 
        // The pad X coordinate is fixed, but the ball needs to be
        //    x' = abs(screen_width/2 - ball_pos_x)
        x = (ball_pos_x >> 8) - 128;
        if(x & 0x80) {
            x = -x;
        }

        // There might be a collision if (x'+ ball_radius) >= (128-pad_x-pad_width/2)
        if(x >= (128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)) {
            // Check if this is the first time.
            x_old = ball_prev_pos_x - 128;
            if(x_old & 0x80) {
                x_old = -x_old;
            }
            if(x_old < (128 - PAD_X - PAD_WIDTH/2 - BALL_DIAMETER/2)) {
                // We will now test the Y axis.
                // First, we need determine which pad is closest to the ball.
                player_id = 0;
                if(ball_pos_x > (128<<8)) {
                    player_id = 1;
                }

                // The ball intersects the pad if the distance between the ball and pad position
                // is less or equal to sum of the ball radius and half the pad height.
                y = (ball_pos_y >> 8) - pad_pos_y[player_id];
                if(y & 0x80) {
                    y = -y;
                }
                if(y < ((BALL_DIAMETER + PAD_HEIGHT)/2)) {
                    // The ball hit a pad, so we compute the new ball direction.
                    ball_reflect_pad();
                    // We update the ball speed after a given number of bounces.
                    ball_update_speed();
                    continue;
                }
            }
        }
        
        // We check here if the ball hits the floor.
        hit = 0;
        if(ball_pos_y < (BALL_Y_MIN << 8)) {
            hit = 1;
            y = BALL_Y_MIN;
        }
        if(ball_pos_y > (BALL_Y_MAX << 8)) {
            hit = 1;
            y = BALL_Y_MAX;
        }
        if(hit) {
            // The ball position is reflected.
            ball_pos_y = ((2*y) << 8) - ball_pos_y;

            // Compute new ball direction.
            // When the ball hits the upper or lower floor, the direction angle is simply refleced.
            // This means that we negates the Y coordinate. As y = sin(dir), y' = -y = -sin(ball_dir).
            // As sin(-t) = -t, we just have to negate ball_dir.
            ball_dir = -ball_dir;
        }
    }
}

// Reset game states.
void game_reset() {
    // Reset pads position and speed.
    pad_pos_x[0] = PAD_X;
    pad_pos_y[0] = 128;
    pad_speed[0] = 3;

    pad_pos_x[1] = 256-PAD_X;
    pad_pos_y[1] = 128;
    pad_speed[1] = 3;

    // Move the ball to the center of the screen.
    ball_pos_x = (128-BALL_DIAMETER/2) << 8;
    ball_pos_y = (128-BALL_DIAMETER/2) << 8;

    // Reset ball speed.
    ball_speed = 3;

    // The ball is randomly thrown between [-PI/4,PI/4] or [3PI/4,5PI/4].
    // We use the clock_tt as our random variable. It's not the best one, but it'll do the trick.
    ball_dir = 224 + (rand8() & 63);
    // Flip a coin to mirror the direction.
    if(rand8() & 1) {
        // angle = PI - angle
        ball_dir = 128 - ball_dir;
    }
}

// This array contains the BAT X position for players score.
const char player_score_pos[2] = {
    16-3-1,
    16+1
};

// Increment and print player score.
void update_score(char player_id) {
    ++player_score[player_id];
    print_score(player_id);
}

// Print player score.
void print_score(char player_id) {
    int vram_addr;
    // Set VRAM Write address
    vram_addr = vdc_calc_addr(player_score_pos[player_id], 1); 
    vdc_set_write(vram_addr);

    // Print player score    
    print_dec_u8(player_score[player_id]);
}

// This routine is a little bit misnamed.
// It checks if the ball went past one of the pads. If that's the case,
// the score of the other player is incremented, and the ball/pad position reseted.
void game_update() { 
    unsigned char pos;
    pos = ball_pos_x >> 8;
    if(pos < BALL_DIAMETER) {
        update_score(1);
        game_reset();
    }
    else if(pos > (256-BALL_DIAMETER)) {
        update_score(0);
        game_reset();
    }
}