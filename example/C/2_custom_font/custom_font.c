/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#define HUDK_USE_CUSTOM_FONT 1

#define FONT_8x8_COUNT 0x1ff
#define FONT_ASCII_FIRST 0x00
#define FONT_ASCII_LAST 0x9e
#define FONT_DIGIT_INDEX 0x30
#define FONT_UPPER_CASE_INDEX 0x41
#define FONT_LOWER_CASE_INDEX 0x61

#include "hudk.h"

#incbin(palette, "data/palette.bin")
#incbin(font_bin, "./data/font.bin")

void main() {
    // load font palette
    vce_load_palette(0, 1, palette);

    // load font gfx
    vdc_load_data(VDC_DEFAULT_TILE_ADDR, font_bin, 4096);

    // set font VRAM address
    font_set_addr(VDC_DEFAULT_TILE_ADDR);

    // set font palette
    font_set_pal(0);

    // Display "Hello world!" on screen.
    // The string will be placed at BAT coordinate [10,8] using the custom font
    print_string(8,10,32,20,"Hello world!");

    // enable IRQ 1.
    irq_enable(INT_IRQ1);

    for(;;) {
        // wait for screen refresh
        vdc_wait_vsync();
    } // and we'll loop indefinitely
}
