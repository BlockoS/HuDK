#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>

int slice_sectors(uint8_t *buffer, size_t size, const char *prefix) {
    int ret = EXIT_SUCCESS;
    char filename[256];
    
    snprintf(filename, sizeof(filename), "%s.inc", prefix);
    FILE *info = fopen(filename, "wb");

    uint8_t bank[8192];
    size_t count = 0;
    size_t k = 0;
    
    size_t used = 0;
    size_t sectors = 0;
    
    size_t i, j;
    fprintf(info, "sectors:");
    for(i=0; i<size; i+=512, sectors++) {
        uint8_t *ptr = buffer + i;
        size_t sector_size = ((i+512) <= size) ? 512 : (size-i);
        for(j=0; (j<sector_size) && (ptr[j]==0); j++) {
        }

        if(j < sector_size) {
            fprintf(info, "%s$%04zx", (used%8) ? "," : "\n    .dw ", i/512);
            
            memcpy(bank+k, buffer+i, sector_size);
            k += sector_size;
            if(k >= 8192) {
                snprintf(filename, 256, "bank_%04zx", count);
                
                FILE *out = fopen(filename, "wb");
                fwrite(bank, 1, 8192, out);
                fclose(out);

                count++;                
                k = 0;
            }            
            used++;
        }
    }
    fprintf(info, "\n\n");
    
    if(k) {
        snprintf(filename, 256, "bank_%04zx", count);
        FILE *out = fopen(filename, "wb");
        fwrite(bank, 1, k, out);
        fclose(out);
        count++;
    }    
    
    j = 2;
    for(i=0; i<count; i++) {
        snprintf(filename, 256, "bank_%04zx", i);    
        fprintf(info,
                "    .bank $%02zx\n"
                "    .org  $4000\n"
                "%s:\n    .incbin \"data/fat32/%s\"\n\n"
                , i+j
                , filename
                , filename);
    }
    fprintf(info, "sector_count = %zd\n", sectors);
    fprintf(info, "sector_used = %zd\n", used);
    fclose(info);
    
    return ret;
}

int main(int argc, char **argv) {
    if(argc != 2) {
        fprintf(stderr, "Usage: img_slice input\n");
        return EXIT_FAILURE;
    }
    
    size_t size;
    uint8_t *buffer;
    FILE *in;
    
    in = fopen(argv[1], "rb");
    if(in == NULL) {
        fprintf(stderr, "Failed to open %s : %s \n", argv[1], strerror(errno));
        return EXIT_FAILURE;
    }
    
    fseek(in, 0, SEEK_END);
    size = ftell(in);
    fseek(in, 0, SEEK_SET);
    size -= ftell(in);
    
    int ret = EXIT_SUCCESS;
    
    buffer = (uint8_t*)malloc(size);
    if(fread(buffer, 1, size, in) != size) {
        fprintf(stderr, "Failed to read %zd bytes from %s : %s \n", size, argv[1], strerror(errno));
        ret = EXIT_FAILURE;
    }
    fclose(in);
    
    if(ret == EXIT_SUCCESS) {
        ret = slice_sectors(buffer, size, argv[1]);
    }
    
    free(buffer);
    return ret;
}
