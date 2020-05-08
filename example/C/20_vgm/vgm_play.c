/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "hudk.h"
#include "vgm.h" 


#define song_bank 0x01
#define song_loop_bank 0x01
#define song_loop 0x6fa8

#incbin(song00, "data/song0000.bin")
#incbin(song01, "data/song0001.bin")

void main() {
	vgm_setup(song00, song_loop, song_loop_bank);

    irq_disable(INT_IRQ1);
	irq_enable_vec(VSYNC);
	irq_set_vec(VSYNC, vgm_update);
    irq_enable(INT_IRQ1);

    for(;;) {
        vdc_wait_vsync();
    }
}
