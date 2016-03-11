#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

#ifndef PATH_MAX
#define PATH_MAX 1024
#endif // PATH_MAX

#define VGM_HUC6280_CMD 0xb9
#define VGM_FRAME_END 0x62
#define VGM_DATA_END 0x66

#define VGM_HEADER_SIZE 0x100

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

static const uint8_t vgm_id[] = { 0x56, 0x67, 0x6d, 0x20 };

uint16_t read_u16(uint8_t *buffer)
{
    return (buffer[1] << 8) | buffer[0];
}

uint32_t read_u32(uint8_t *buffer)
{
    return   (buffer[3] << 24) | (buffer[2] << 16)
           | (buffer[1] <<  8) | (buffer[0]      );
}

int vgm_read_header(FILE *stream, vgm_header *header)
{
    uint8_t raw_header[VGM_HEADER_SIZE];
    size_t  count;

    memset(header, 0, sizeof(vgm_header));

    count = fread(raw_header, 1, VGM_HEADER_SIZE, stream);
    if(VGM_HEADER_SIZE != count)
    {
        fprintf(stderr, "failed to read vgm header : %s\n", strerror(errno));
        return -1;
    }

    if(memcmp(raw_header, vgm_id, 4))
    {
        fprintf(stderr, "invalid vgm id\n");
        return -1;
    }
    
    header->version_number = read_u32(raw_header+VGM_VERSION_NUMBER);
    if(header->version_number < 0x161)
    {
        fprintf(stderr, "invalid version number : %3x\n", header->version_number);
        return -1;
    }
    
    header->huc6280_clock = raw_header[VGM_HUC6280_CLOCK];
    if(0 == header->huc6280_clock)
    {
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

int process(FILE *stream, vgm_header *header, uint8_t **out, size_t *len)
{
    uint8_t  *src, *dst;
    size_t   count;

    uint32_t i;
    uint32_t loop_offset = (header->loop_offset + 0x1c) - header->data_offset - 0x34;
    uint32_t data_size = header->gd3_offset - header->data_offset;

    fseek(stream, header->data_offset+0x34, SEEK_SET);
	
    *out = (uint8_t*)malloc(data_size);
    if(NULL == *out)
    {
        fprintf(stderr, "alloc error : %s\n", strerror(errno));
        return -1;
    } 

    count = fread(*out, 1, data_size, stream);
    if(count != data_size)
    {
        fprintf(stderr, "failed to read data : %s\n", strerror(errno));
        return -1;
    }

    src = *out;
    dst = *out;
    for(i=0; i<data_size;)
    {
        uint8_t command;
        if(i == loop_offset)
        {
            header->loop_offset = i;
        }

        command  = src[i++];
        if(VGM_HUC6280_CMD == command)
        {
            *dst++ = src[i++]; 
            *dst++ = src[i++]; 
        }
        else if(VGM_FRAME_END == command)
        {
            *dst++ = 0xff; 
        }
        else if(VGM_DATA_END == command)
        {
            break;
        }
    }
    *len = dst - src;
    return 0;
}

int output(vgm_header *header, uint8_t *buffer, size_t len, uint32_t bank, uint32_t org, const char *basename)
{
    FILE *stream;
    char filename[PATH_MAX];

    size_t out_count;
    size_t write_count;
    uint8_t i, j;

    for(out_count=8192, i=0; len>0; buffer+=out_count, len-=out_count, i++)
    {
        snprintf(filename, PATH_MAX, "%s%04x.bin", basename, i++);
        stream = fopen(filename, "wb");
        if(NULL == stream)
        {
            fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
            return -1;
        }
       
        out_count = (len >= 8192) ? 8192 : len; 
        write_count = fwrite(buffer, 1, out_count, stream);
        fclose(stream);
        if(write_count != out_count)
        {
            fprintf(stderr, "write error %s : %s\n", filename, strerror(errno));
            return -1;
        }
	} 

    snprintf(filename, PATH_MAX, "%s.inc", basename);
    stream = fopen(filename, "wb");
    if(NULL == stream)
    {
        fprintf(stderr, "failed to open %s : %s\n", filename, strerror(errno));
        return -1;
    }

    org &= 0x1fff;
    fprintf(stream, "%s_bank=$%02x\n%s_loop=$%04x\n", 
                    basename, bank + (header->loop_offset/8192),
                    basename, org  + header->loop_offset);

    for(j=0; j<i; j++)
    {
        fprintf(stream, "    .bank $%02x\n"
                        "    .org $%04x\n"
                        ".include \"%s%04x.bin\"\n"
                      , bank+j
                      , org
                      , basename, j);
    }
    fclose(stream);

    return 0;
} 

void usage()
{
    fprintf(stdout, "vgmstrip input.vgm out\n");
}

int main(int argc, char **argv)
{
    FILE *stream;
    int err;
    int ret;

    vgm_header header;

    // [todo] getopt for bank and org

    if(argc < 3)
    {
        usage();
        return EXIT_FAILURE;
    }

    stream = fopen(argv[1], "rb");
    if(NULL == stream)
    {
        fprintf(stderr, "Failed to open %s : %s\n", argv[1], strerror(errno));
        return EXIT_FAILURE;
    }

    ret = EXIT_FAILURE;
    err = vgm_read_header(stream, &header);
    if(err >= 0)
    {
        uint8_t *buffer = NULL;
        size_t len = 0;
        err = process(stream, &header, &buffer, &len);
        if(err >= 0)
        {
		    err = output(&header, buffer, len, 0x00, 0x0000, argv[2]);
            if(err >= 0)
            {
                // [todo] some kind of pattern/matching lz77 stuff?
                ret = EXIT_SUCCESS;
            }
        }
        if(NULL != buffer)
        {
            free(buffer);
        }
    }
    fclose(stream);

    return ret;
}
