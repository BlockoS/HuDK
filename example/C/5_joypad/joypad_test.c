/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */

#include "hudk.h"

// Joypad types
#define JOYPAD_2 0
#define JOYPAD_6 1

#define JOYPAD_BOX_WIDTH 32
#define JOYPAD_BOX_HEIGHT 4
#define JOYPAD_BOX_X 2
#define JOYPAD_BOX_Y 1

int x;
int y;

// type of each joypad (2 or 6 button)
char joypad_type[5];

const char extra_buttons_bat_y[4] = {
    2, 6, 10, 14 
};

const char button_x[8] = {
     1, // JOYPAD_I
     8, // JOYPAD_II
    15, // JOYPAD_SEL
    22, // JOYPAD_RUN
     1, // JOYPAD_UP
    22, // JOYPAD_RIGHT
     8, // JOYPAD_DOWN
    15  // JOYPAD_LEFT
};

const char button_y[8] = {
    1, // JOYPAD_I
    1, // JOYPAD_II
    1, // JOYPAD_SEL
    1, // JOYPAD_RUN
    0, // JOYPAD_UP
    0, // JOYPAD_RIGHT
    0, // JOYPAD_DOWN
    0  // JOYPAD_LEFT
};

const int palette[32] = {
    VCE_BLACK,  VCE_GREY, VCE_BLACK, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
       0x0000,    0x0000,    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    VCE_BLACK, VCE_WHITE, VCE_GREEN, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
       0x0000,    0x0000,    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};

// text
const char *text = "| UP   | DOWN | LEFT | RIGHT|\n| I    | II   | SEL  | RUN  |";
const char *text_6 =  "| III  | IV   | V    | VI   |";

void joy_print_status() {
    char i;
    char type;

    y = JOYPAD_BOX_Y;
    for(i=0; i<5; i++) {
        // Check if joypad type changed
        type = JOYPAD_2;
        if((joypad_6[i] & 0x50) == 0x50) {
            type = JOYPAD_6;
        }

        if(type != joypad_type[i]) {
            // It has changed!
            joypad_type[i] = type;
            print_extra_buttons_line(i, type);
        }

        x = JOYPAD_BOX_X;
        print_buttons_status(joypad[i], 8);

        // Display extra buttons status ?
        if(joypad_type[i] == JOYPAD_6) {
            x = JOYPAD_BOX_X;
            ++y;
            print_buttons_status(joypad_6[i], 4);
            --y;
        }
        y += JOYPAD_BOX_HEIGHT;
    }
}

void print_buttons_status(char button, char bit_count) {
    int vram_addr;
    int pal;
    char i, j;
    for(i=0; i<bit_count ; i++) {
        if(button & (1 << i)) {
            pal = 0x1000;
        }
        else {
            pal = 0x0000;
        }

        vram_addr = vdc_calc_addr(x + button_x[i], y + button_y[i]);
        vdc_set_write(vram_addr);
        vdc_set_read(vram_addr);

        for(j=0; j<6; j++) {    
            int data;
            data = vdc_read();
            vdc_write((data & 0x0fff) | pal);
        }
    }
}

void clear_extra_buttons_line(char id)  {
    print_fill(JOYPAD_BOX_X, extra_buttons_bat_y[id] + JOYPAD_BOX_Y, JOYPAD_BOX_WIDTH, 1, ' ');
}

void print_6_buttons_line(char id) {
    print_string(JOYPAD_BOX_X, extra_buttons_bat_y[id] + JOYPAD_BOX_Y, JOYPAD_BOX_WIDTH, 1, text_6);
}

void print_extra_buttons_line(char id, char type) {
    if(type) {
        print_6_buttons_line(id);
    }
    else {
        clear_extra_buttons_line(id);
    }
}

void main() {
    char i;

    // we consider that we have 5 2 buttons joypads
    for(i=0; i<5; i++) {
        joypad_type[i] = JOYPAD_2;
    }

    // load tile palettes
    vce_load_palette(0, 2, palette);

    // display joypad status
    y = JOYPAD_BOX_Y;
    for(i=0; i<5; i++) {
        print_string(JOYPAD_BOX_X, y, JOYPAD_BOX_WIDTH, JOYPAD_BOX_HEIGHT, text);

        vdc_set_write(vdc_calc_addr(1, y));
        print_char('1'+i);

        y += JOYPAD_BOX_HEIGHT;
    }

    // enable IRQ 1.
    irq_enable(INT_IRQ1);

    for(;;) {
        vdc_wait_vsync();

        // retrieve joypad status and print them
        joypad_6_read();
        joy_print_status();
    }
}
