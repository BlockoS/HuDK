#define VDC_STATUS_SPR_COLLISION 0x01
#define VDC_STATUS_SPR_OVERFLOW 0x02
#define VDC_STATUS_HBLANK 0x04
#define VDC_STATUS_SATB_DMA_END 0x08
#define VDC_STATUS_VRAM_DMA_END 0x10
#define VDC_STATUS_VBLANK 0x20
#define VDC_STATUS_BUSY 0x40
#define VDC_MAWR 0x00
#define VDC_MARR 0x01
#define VDC_DATA 0x02
#define VDC_CR 0x05
#define VDC_RCR 0x06
#define VDC_BXR 0x07
#define VDC_BYR 0x08
#define VDC_MWR 0x09
#define VDC_HSR 0x0A
#define VDC_HDR 0x0B
#define VDC_VSR 0x0C
#define VDC_VDR 0x0D
#define VDC_VCR 0x0E
#define VDC_DMA_CR 0x0F
#define VDC_DMA_SRC 0x10
#define VDC_DMA_DST 0x11
#define VDC_DMA_LEN 0x12
#define VDC_SAT_SRC 0x13
#define VDC_CR_SPR_COLLISION_ENABLE 0x0001
#define VDC_CR_SPR_OVERFLOW_ENABLE 0x0002
#define VDC_CR_HBLANK_ENABLE 0x0004
#define VDC_CR_VBLANK_ENABLE 0x0008
#define VDC_CR_SPR_ENABLE 0x0040
#define VDC_CR_BG_ENABLE 0x0080
#define VDC_CR_RW_INC_1 0x0000
#define VDC_CR_RW_INC_32 0x0800
#define VDC_CR_RW_INC_64 0x1000
#define VDC_CR_RW_INC_128 0x1800
#define VDC_BG_32x32 0x00
#define VDC_BG_64x32 0x10
#define VDC_BG_128x32 0x20
#define VDC_BG_32x64 0x40
#define VDC_BG_64x64 0x50
#define VDC_BG_128x64 0x60
#define VDC_DMA_SATB_ENABLE 0x01 
#define VDC_DMA_VRAM_ENABLE 0x02
#define VDC_DMA_SRC_INC 0x00
#define VDC_DMA_SRC_DEC 0x04
#define VDC_DMA_DST_INC 0x00
#define VDC_DMA_DST_DEC 0x08
#define VDC_DMA_SAT_AUTO 0x10

#define VDC_DEFAULT_BG_SIZE VDC_BG_64x64
#define VDC_DEFAULT_TILE_ADDR (64*64)

#ifndef VDC_DEFAULT_XRES
#define VDC_DEFAULT_XRES 256
#endif

#ifndef VDC_DEFAULT_SAT_ADDR
#define VDC_DEFAULT_SAT_ADDR $7F00
#endif

void __fastcall vdc_set_read(int vaddr<_di>);
void __fastcall vdc_set_write(int vaddr<_di>);
void __fastcall vdc_set_bat_size(char sz<acc>);
int __fastcall vdc_calc_addr(char x<_al>, char y<_ah>);
void __fastcall vdc_load_tiles(int vaddr<_di>, char tile_bank<_bl>, char *tile_addr<_si>, int tile_count<_cx>);
void __fastcall vdc_load_data(int vaddr<_di>, int far *data<_bl:_si>, int word_count<_cx>);
void __fastcall vdc_load_data(int vaddr<_di>, char data_bank<_bl>, int *data_addr<_si>, int word_count<_cx>);
void __fastcall vdc_fill_bat(char bat_x<_cl>, char bat_y<_ch>, char bat_w<_al>, char bat_h<_ah>, char palette_index<_bl>, int tile_offset<_si>);
void __fastcall vdc_clear(int vaddr<_di>, int word_count<_cx>);
void __fastcall vdc_init();
void __fastcall vdc_yres_224();
void __fastcall vdc_yres_240();
void __fastcall vdc_xres_256();
void __fastcall vdc_xres_320();
void __fastcall vdc_xres_512();
void __fastcall vdc_set_xres(int xres<_ax>, char blur_bit<_cl>);
void __fastcall vdc_wait_vsync();

#define VCE_COLOR_MODE_MASK %10000000
#define VCE_BLUR_MASK %00000100
#define VCE_DOT_CLOCK_MASK %00000011

#define VCE_COLOR_MODE_BW  %10000000
#define VCE_COLOR_MODE_RGB %00000000

#define VCE_BLUR_ON  %00000100
#define VCE_BLUR_OFF %00000000

#define VCE_DOT_CLOCK_10MHZ %00000010
#define VCE_DOT_CLOCK_7MHZ  %00000001
#define VCE_DOT_CLOCK_5MHZ  %00000000

#define RGB(r,g,b) ((((g) & $07) << 6) | (((r) & $07) << 3) | ((b) & $07))

#define VCE_BLACK 0x000
#define VCE_WHITE 0x1ff
#define VCE_RED 0x038
#define VCE_GREEN 0x1C0
#define VCE_BLUE 0x007
#define VCE_YELLOW 0x1F8
#define VCE_MAGENTA 0x03F
#define VCE_CYAN 0x1C7
#define VCE_GREY 0x124

void __fastcall vce_init();
void __fastcall vce_load_palette(char pal_index<_al>, char pal_count<_ah>, int far *palettes<_bl:_si>);

#define INT_IRQ2 (1<<0)
#define INT_IRQ1 (1<<1)
#define INT_TIMER (1<<2)
#define INT_NMI (1<<3)
#define INT_ALL (INT_IRQ2 | INT_IRQ1 | INT_TIMER | INT_NMI)

void __fastcall irq_enable(char c<acc>);
void __fastcall irq_disable(char c<acc>);

#ifndef HUDK_USE_CUSTOM_FONT

#define FONT_8x8_COUNT 0x80
#define FONT_ASCII_FIRST 0x00
#define FONT_ASCII_LAST 0x9e
#define FONT_DIGIT_INDEX 0x30
#define FONT_UPPER_CASE_INDEX 0x41
#define FONT_LOWER_CASE_INDEX 0x61

#endif // HUDK_USE_CUSTOM_FONT

void __fastcall font_load(int vaddr<_di>, char far* font<_bl:_si>, int char_count<_cx>);
void __fastcall font_set_addr(int vaddr<acc>);
void __fastcall font_set_pal(char pal<acc>);

void __fastcall print_char(char c<acc>);
void __fastcall print_digit(char d<acc>);
void __fastcall print_hex(char h<acc>);
void __fastcall print_bcd(int n0<_ax>);
void __fastcall print_bcd(int n0<_ax>, int n1<_bx>);
void __fastcall print_dec_u8(char u8<acc>);
void __fastcall print_dec_u16(int u16<acc>);
void __fastcall print_hex_u8(char h8<acc>);
void __fastcall print_hex_u16(int h16<acc>);
void __fastcall print_string(char x<_cl>, char y<_ch>, char width<_al>, char height<_ah>, char *txt<_si>);
void __fastcall print_string_raw(char *txt<_si>);
void __fastcall print_string_n(char *txt<_si>, int count<acc>);
void __fastcall print_fill(char x<_cl>, char y<_ch>, char width<_al>, char height<_ah>, char c<_bl>);
