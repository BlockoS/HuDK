/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "hudk.h"

void main() {
    print_string(8,10,32,20,"Hello world!");

    irq_enable(INT_IRQ1);

    for(;;) {
        vdc_wait_vsync();
    }
}
