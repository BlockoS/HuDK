/* vgmstrip.c -- Strips PC Engine VGM and outputs ASM files
 * suitable for replay.
 *
 * Copyright (C) 2016-2018 MooZ
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

#include <argparse/argparse.h>

#ifdef _MSC_VER
#    define strcasecmp _stricmp
#endif // _MSC_VER

#ifndef PATH_MAX
#define PATH_MAX 1024
#endif // PATH_MAX

#define VGM_HEADER_SIZE 0x100
#define SAMPLES_PER_FRAME 0x2df

enum OUTPUT_LANG {
    OUTPUT_ASM = 0,
    OUTPUT_C
};

/* Supported VGM commands */
enum VGM_COMMAND
{
    VGM_HUC6280_CMD = 0xb9,
    VGM_WAIT_CMD    = 0x61,
    VGM_FRAME_END   = 0x62,
    VGM_DATA_END    = 0x66
};

/* Offsets (in bytes) of various infos in the VGM header. */
enum VGM_OFFSET
{
    VGM_ID                 = 0x00,
    VGM_EOF_OFFSET         = 0x04,
    VGM_VERSION_NUMBER     = 0x08,
    VGM_GD3_OFFSET         = 0x14,
    VGM_TOTAL_SAMPLE_COUNT = 0x18,
    VGM_LOOP_OFFSET        = 0x1c,
    VGM_LOOP_SAMPLE_COUNT  = 0x20,
    VGM_DATA_OFFSET        = 0x34,
    VGM_VOLUME_MODIFIER    = 0x7c,
    VGM_LOOP_BASE          = 0x7e,
    VGM_LOOP_MODIFIER      = 0x7f,
    VGM_HUC6280_CLOCK      = 0xa4
};

/* VGM header. */
typedef struct
{
    uint32_t eof_offset;
    uint32_t version_number;
    /* */
    uint32_t gd3_offset;
    uint32_t total_sample_count;
    uint32_t loop_offset;
    uint32_t loop_sample_count;
    /* */
    uint32_t data_offset;
    /* */
    uint8_t volume_modifier;
    /* */
    uint8_t loop_base;
    uint8_t loop_modifier;
    /* */
    uint32_t huc6280_clock;
} vgm_header;

/* VGM magic id */
static const uint8_t vgm_id[] = { 0x56, 0x67, 0x6d, 0x20 };

uint16_t read_u16(uint8_t *buffer) {
    return (buffer[1] << 8) | buffer[0];
}

uint32_t read_u32(uint8_t *buffer) {
    return   (buffer[3] << 24) | (buffer[2] << 16)
           | (buffer[1] <<  8) | (buffer[0]      );
}

/* Read vgm header and check it's a valid PC Engine tune. */
int vgm_read_header(FILE *stream, vgm_header *header) {
    uint8_t raw_header[VGM_HEADER_SIZE];
    size_t  count;

    memset(header, 0, sizeof(vgm_header));

    count = fread(raw_header, 1, VGM_HEADER_SIZE, stream);
    if(VGM_HEADER_SIZE != count) {
        fprintf(stderr, "failed to read vgm header : %s\n", strerror(errno));
        return -1;
    }

    if(memcmp(raw_header, vgm_id, 4)) {
        fprintf(stderr, "invalid vgm id\n");
        return -1;
    }
    
    header->version_number = read_u32(raw_header+VGM_VERSION_NUMBER);
    if(header->version_number < 0x161) {
        fprintf(stderr, "invalid version number : %3x\n", header->version_number);
        return -1;
    }
    
    header->huc6280_clock = raw_header[VGM_HUC6280_CLOCK];
    if(0 == header->huc6280_clock) {
        fprintf(stderr, "not a PC Engine vgm!\n");
        return -1;
    }
 
    header->eof_offset = read_u32(raw_header+VGM_EOF_OFFSET);
    header->gd3_offset = read_u32(raw_header+VGM_GD3_OFFSET);
    header->total_sample_count = read_u32(raw_header+VGM_TOTAL_SAMPLE_COUNT);
    header->loop_offset = read_u32(raw_header+VGM_LOOP_OFFSET);
    header->loop_sample_count = read_u32(raw_header+VGM_LOOP_SAMPLE_COUNT);
    header->data_offset = read_u32(raw_header+VGM_DATA_OFFSET);
    header->volume_modifier = raw_header[VGM_VOLUME_MODIFIER];
    header->loop_base = raw_header[VGM_LOOP_BASE];
    header->loop_modifier = raw_header[VGM_LOOP_MODIFIER];

    return 0;
}

/* Read vgm data and strip unecessary data. */
int process(FILE *stream, vgm_header *header, uint8_t **out, size_t *len) {
    uint8_t  *src, *dst;
    size_t   count;

    uint32_t i;
    uint32_t loop_offset = (header->loop_offset + 0x1c) - header->data_offset - 0x34;
    uint32_t data_size = header->gd3_offset - header->data_offset;

    fseek(stream, header->data_offset+0x34, SEEK_SET);
	
    *out = (uint8_t*)malloc(data_size);
    if(*out == NULL) {
        fprintf(stderr, "alloc error : %s\n", strerror(errno));
        return -1;
    } 

    count = fread(*out, 1, data_size, stream);
    if(count != data_size) {
        fprintf(stderr, "failed to read data : %s\n", strerror(errno));
        return -1;
    }

    src = *out;
    dst = *out;
    for(i=0; i<data_size;) {
        uint8_t command;
        if(i == loop_offset) {
            header->loop_offset = i;
        }

        command = src[i++];
        if(command == VGM_HUC6280_CMD) {
            *dst++ = src[i++]; 
            *dst++ = src[i++]; 
        }
        else if(command == VGM_WAIT_CMD) {
            /* determine the number of frames to wait */
            uint16_t samples = (src[i+1] << 8) | src[i];
            uint16_t frames = samples / SAMPLES_PER_FRAME;
            for(; frames >= 0x11; frames-=0x11) {
                *dst++ = 0xef;
            }
            if(frames == 1) {
                *dst++ = 0xf0;
            }
            else if(frames) {
                *dst++ = 0xe0 + (uint8_t)(frames - 2);
           }
           i += 2;
        }
        else if(command == VGM_FRAME_END) {
            *dst++ = 0xf0; 
        }
        else if(command == VGM_DATA_END) {
            *dst++ = 0xff;
            break;
        }
        else {
            fprintf(stderr, "unsupported command %x\n", command);
            return -1;
        }
    }
    *len = dst - src;
    return 0;
}

/* Cut the vgm in slices of 8kB and writes assembly files containing data and bank infos. */
int output_asm(vgm_header *header, uint8_t *buffer, size_t len, uint32_t bank, uint32_t org, const char *song_name, const char *output_directory) {
    FILE *stream;
    char filename[PATH_MAX];

    size_t out_count;
    size_t write_count;
    uint8_t i, j;

    uint32_t loop_org;
    uint32_t loop_bank;

    for(out_count=8192, i=0; len>0; buffer+=out_count, len-=out_count, i++) {
        snprintf(filename, PATH_MAX, "%s/%s%04x.bin", output_directory, song_name, i);
        stream = fopen(filename, "wb");
        if(stream == NULL) {
            fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
            return -1;
        }
       
        out_count = (len >= 8192) ? 8192 : len; 
        write_count = fwrite(buffer, 1, out_count, stream);
        fclose(stream);
        if(write_count != out_count) {
            fprintf(stderr, "write error %s : %s\n", filename, strerror(errno));
            return -1;
        }
	} 

    snprintf(filename, PATH_MAX, "%s/%s.inc", output_directory, song_name);
    stream = fopen(filename, "wb");
    if(stream == NULL) {
        fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
        return -1;
    }

    loop_bank = bank + (header->loop_offset >> 13); 
    loop_org  = org + (header->loop_offset & 0x1fff);

    fprintf(stream, "%s_bank=$%02x\n"
                    "%s_base_address=$%04x\n" 
                    "%s_loop_bank=$%02x\n"
                    "%s_loop=$%04x\n",
                    song_name, bank,
                    song_name, org,
                    song_name, loop_bank,
                    song_name, loop_org);

    for(j=0; j<i; j++) {
        fprintf(stream, "    .bank $%02x\n"
                        "    .org $%04x\n"
                        "    .incbin \"%s%04x.bin\"\n"
                      , bank + j
                      , org
                      , song_name, j);
    }
    fclose(stream);
    return 0;
} 

int output_c(vgm_header *header, uint8_t *buffer, size_t len, uint32_t bank, uint32_t org, const char *song_name, const char *output_directory) {
    FILE *stream;
    char filename[PATH_MAX];

    size_t write_count;

    uint32_t loop_org;
    uint32_t loop_bank;

    snprintf(filename, PATH_MAX, "%s/%s.bin", output_directory, song_name);
    stream = fopen(filename, "wb");
    if(stream == NULL) {
        fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
        return -1;
    }
    
    write_count = fwrite(buffer, 1, len, stream);
    fclose(stream);
    if(write_count != len) {
        fprintf(stderr, "write error %s : %s\n", filename, strerror(errno));
        return -1;
    }

    snprintf(filename, PATH_MAX, "%s/%s.h", output_directory, song_name);
    stream = fopen(filename, "wb");
    if(stream == NULL) {
        fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
        return -1;
    }

    loop_bank = bank + (header->loop_offset >> 13); 
    loop_org  = org + (header->loop_offset & 0x1fff);

    fprintf(stream, "#define %s_bank 0x%02x\n"
                    "#define %s_loop_bank 0x%02x\n"
                    "#define %s_loop 0x%04x\n",
                    song_name, bank,
                    song_name, loop_bank,
                    song_name, loop_org);
    fclose(stream);
    return 0;
} 

/* display program arguments on the command line. */
void usage()
{
    fprintf(stdout, "usage: vgmstrip -b bank -o org song_name input.vgm output_directory\n"
                    "-b or --bank : Start ROM bank (in hexadecimal)\n"
                    "-o or --org  : Start bank offset (in hexadecimal)\n"
                    "-l or --lang : Output language (c or asm)\n");
}

/* main entry point. */
int main(int argc, const char **argv) {
    FILE *stream;
    int err;
    int ret;

    vgm_header header;
    uint32_t bank;
    uint32_t org;
    const char *lang = NULL;
    int output_lang = OUTPUT_ASM;

    const char *filename;
    const char *song_name;
    const char *output_directory;
	
	static const char* const usages[] = {
		"vgmstrip [options] song_name input.vgm output_directory",
		NULL
	};

	struct argparse_option options[5] = {
		OPT_HELP(),
		OPT_INTEGER('b', "bank", &bank, "First ROM bank", NULL, 0, 0),
		OPT_INTEGER('o', "org", &org, "Logical address", NULL, 0, 0),
		OPT_STRING('l', "lang", &lang, "Output language", NULL, 0, 0),
		OPT_END(),
	};
	struct argparse argparse;
	
	argparse_init(&argparse, options, usages, 0);
	argparse_describe(&argparse, "\nvgm_strip : Strip/convert VGM", "  ");
	argc = argparse_parse(&argparse, argc, argv);
	if (argc != 3) {
		argparse_usage(&argparse);
		return EXIT_FAILURE;
	}

    if(lang != NULL) {
        if(strcasecmp(lang, "c") == 0) {
            output_lang = OUTPUT_C;
        }
        else if(strcasecmp(lang, "asm") == 0) {
            output_lang = OUTPUT_ASM;
        }
        else {
            fprintf(stderr, "unknown output language: %s\n", lang);
     		argparse_usage(&argparse);
            return EXIT_FAILURE;
        }
    }

    song_name = argv[0]; 
    filename = argv[1];
    output_directory = argv[2];
    
    stream = fopen(filename, "rb");
    if(stream == NULL) {
        fprintf(stderr, "Failed to open %s : %s\n", filename, strerror(errno));
        return EXIT_FAILURE;
    }
    
    ret = EXIT_FAILURE;
    err = vgm_read_header(stream, &header);
    if(err >= 0) {
        uint8_t *buffer = NULL;
        size_t len = 0;
        err = process(stream, &header, &buffer, &len);
        if(err >= 0) {
            if(output_lang == OUTPUT_ASM) {
    		    err = output_asm(&header, buffer, len, bank, org, song_name, output_directory);
            }
            else {
    		    err = output_c(&header, buffer, len, bank, org, song_name, output_directory);
            }
            if(err >= 0) {
                ret = EXIT_SUCCESS;
            }
        }
        if(buffer != NULL) {
            free(buffer);
        }
    }
    fclose(stream);

    return ret;
}
