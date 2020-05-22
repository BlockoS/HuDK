#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

void output_16_sin(FILE *out, int i) {
    fprintf(out, "\n    .byte");
    char c = ' ';
    for(int j=0; j<16; j++, i++) {
        float v = 127 * sin(i*2.f*M_PI/256.f);
        fprintf(out, "%c$%02x", c, (uint8_t)v);
        c = ',';
    }
}

int main() {
    int i;
    FILE *out = fopen("sin.inc", "wb");
    fprintf(out, "sin:");
    for(i=0; i<64; i+=16) {
        output_16_sin(out, i);
    }
    fprintf(out, "\ncos:");
    for(; i<320; i+=16) {
        output_16_sin(out, i);
    }
    fclose(out);
    return EXIT_SUCCESS;
}
