
# Sprite display

sprite sheet

![spritesheet](../../data/6_sprites/balls.png)

configuration file in order to convert it to PC Engine format.
```json
{
	"sprite": [
		{ "name": "ball0.bin", "x":0, "y":0, "w":2, "h":2 },
		{ "name": "ball1.bin", "x":32, "y":0, "w":2, "h":2 },
		{ "name": "ball2.bin", "x":64, "y":0, "w":2, "h":2 },
		{ "name": "ball3.bin", "x":96, "y":0, "w":2, "h":2 },
		{ "name": "ball4.bin", "x":128, "y":0, "w":1, "h":1 },
		{ "name": "ball5.bin", "x":144, "y":0, "w":1, "h":1 },
		{ "name": "ball6.bin", "x":128, "y":16, "w":1, "h":1 },
		{ "name": "ball7.bin", "x":144, "y":16, "w":1, "h":1 }
	],
    "palette": [
        { "name": "palette.bin", "start": 0, "count": 1 }
    ]
}
```

Conversion.

```bash
encode_gfx ../../data/6_sprite/data.json ../../data/6_sprite/balls.png -o ./data
```

<table>
<tr><th>asm</th><th>C</th></tr>
<tr><td>

```asm
SPRITES_DATA_VRAM_ADDR = $1800

sprite_size:
    .db VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .db VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .db VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .db VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32
    .db VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .db VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .db VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
    .db VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16

sprite_addr:
    .dw SPRITES_DATA_VRAM_ADDR
    .dw SPRITES_DATA_VRAM_ADDR+$100
    .dw SPRITES_DATA_VRAM_ADDR+$200
    .dw SPRITES_DATA_VRAM_ADDR+$300
    .dw SPRITES_DATA_VRAM_ADDR+$400
    .dw SPRITES_DATA_VRAM_ADDR+$440
    .dw SPRITES_DATA_VRAM_ADDR+$480
    .dw SPRITES_DATA_VRAM_ADDR+$4c0

; ...

    .data
    .bank 1
    .org $6000

sprites_data:
    .incbin "data/ball0.bin"
    .incbin "data/ball1.bin"
    .incbin "data/ball2.bin"
    .incbin "data/ball3.bin"
    .incbin "data/ball4.bin"
    .incbin "data/ball5.bin"
    .incbin "data/ball6.bin"
    .incbin "data/ball7.bin"
sprites_data_size = * - sprites_data

sprites_pal:
    .incbin "data/palette.bin"
```

</td><td>

```c
#define SPRITES_DATA_VRAM_ADDR 0x1800

#incbin(sprites_pal, "data/palette.bin")

#incbin(ball0, "data/ball0.bin")
#incbin(ball1, "data/ball1.bin")
#incbin(ball2, "data/ball2.bin")
#incbin(ball3, "data/ball3.bin")
#incbin(ball4, "data/ball4.bin")
#incbin(ball5, "data/ball5.bin")
#incbin(ball6, "data/ball6.bin")
#incbin(ball7, "data/ball7.bin")

const char sprite_size[8] = {
    VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32,
    VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32,
    VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32,
    VDC_SPRITE_WIDTH_32 | VDC_SPRITE_HEIGHT_32,
    VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16,
    VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16,
    VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16,
    VDC_SPRITE_WIDTH_16 | VDC_SPRITE_HEIGHT_16
};

const int sprite_addr[8] = {
    SPRITES_DATA_VRAM_ADDR,
    SPRITES_DATA_VRAM_ADDR + 0x100,
    SPRITES_DATA_VRAM_ADDR + 0x200,
    SPRITES_DATA_VRAM_ADDR + 0x300,
    SPRITES_DATA_VRAM_ADDR + 0x400,
    SPRITES_DATA_VRAM_ADDR + 0x440,
    SPRITES_DATA_VRAM_ADDR + 0x480,
    SPRITES_DATA_VRAM_ADDR + 0x4c0
};
```

</td></tr>
</table>


<table>
<tr><th>asm</th><th>C</th></tr>
<tr><td>

```asm
; load sprites palette
stb    #bank(sprites_pal), <_bl
stw    #sprites_pal, <_si
jsr    map_data
lda    #16
ldy    #1
jsr    vce_load_palette

; load sprites gfx
stb    #bank(sprites_data), <_bl
stw    #sprites_data, <_si
stw    #(SPRITES_DATA_VRAM_ADDR), <_di
stw    #(sprites_data_size >> 1), <_cx
jsr    vdc_load_data
```

</td><td>

```c
// load sprites palette
vce_load_palette(16, 1, sprites_pal);

// load sprites gfx
vdc_load_data(SPRITES_DATA_VRAM_ADDR, ball0, 2560);
```

</td></tr>
</table>

![screenshot](screenshot.png)
