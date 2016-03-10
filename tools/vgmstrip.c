#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

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

    // uint32_t loop_offset = (header->loop_offset + 0x1c) - header->data_offset - 0x34;
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

    // [todo] recomputed loop offset

    src = *out;
    dst = *out;
    for(i=0; i<data_size;)
    {
        uint8_t command = src[i++];
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

int output(uint32_t bank, uint32_t org, const char *basename)
{
    // [todo]
    return 0;
} 

void usage()
{
    // [todo]
}

int main(int argc, char **argv)
{
    FILE *stream;
    int err;

    vgm_header header;
    uint8_t *buffer;
    size_t len;

    // [todo] command line paring

    stream = fopen(argv[1], "rb");
    if(NULL == stream)
    {
        fprintf(stderr, "Failed to open %s : %s\n", argv[1], strerror(errno));
        return EXIT_FAILURE;
    }

    err = vgm_read_header(stream, &header);
    if(err < 0)
    {
        // [todo]
    }

    buffer = NULL;
    len = 0;
    err = process(stream, &header, &buffer, &len);
    if(err < 0)
    {
        // [todo]
    }

    fclose(stream);

    // [todo] pattern matching?

    if(NULL != buffer)
    {
        free(buffer);
    }

    return EXIT_SUCCESS;
}
