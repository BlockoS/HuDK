/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */

#include "hudk.h"


const char *labels[4] = {
    "hours",
    "minutes",
    "seconds",
    "ticks"
};

char index;
char txt_x;
char txt_y;

void main() {
    // Display the current system clock on screen.

    // enable IRQ 1.
    irq_enable(INT_IRQ1);

    for(;;) {
        char *clock;
        clock = &clock_hh;

        // wait for screen refresh
        vdc_wait_vsync();

        print_string(2, 2, 32, 32, "elapsed");

        txt_x = 2;
        txt_y = 4;
        for(index = 0; index < 4; index++) {
            int addr;
            // compute BAT address
            addr = vdc_calc_addr(txt_x, txt_y);
            vdc_set_write(addr);

            // print value
            print_dec_u8(clock[index]);
            // add a space
            print_char(' ');

            // display_unit
            print_string_raw(labels[index]);

            // jump two line below
            txt_y += 2;
        }
    }
}
