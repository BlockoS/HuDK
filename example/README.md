# HuDK examples

## Build instructions

 * must have built tools first -> commands to build them

### HuC/PCEas toolchain
 * use pceas fork

```bash
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../cmake/huc-toolchain.cmake \ 
    -DHUDK_TOOLS_PATH=../../.build/install/bin/ \ -DHUDK_INCLUDE_PATH=../../include/ \
    -DHUC_PATH=<path to huc/pceas binaries directory>
```

```bash
cmake --build .
```

### cc64/ca65 toolchain

```bash
cmake .. \ 
    -DCMAKE_TOOLCHAIN_FILE=../cmake/cc65-toolchain.cmake \
    -DHUDK_TOOLS_PATH=../../.build/install/bin/ \
    -DHUDK_INCLUDE_PATH=../../include/ \
    -DCC65_PATH=<path to cc65/ca65 binaries directory> 
```

```bash
cmake --build .
```

## Assembly 

1. [Hello world](asm/1_hello_world/README.md)

1. [Custom font](asm/2_custom_font/README.md)

1. [Map of 8 by 8 pixels tiles](asm/3_map_8x8/README.md)

1. [Map of 16 by 16 pixels tiles](asm/4_map_16x16/README.md)

1. [Joypad](asm/5_joypad/README.md)

1. [Sprites](asm/6_sprites/README.md)

1. [Scroll / Vertical split windows](asm/7_scroll/README.md)

1. [Clock](asm/8_clock/README.md)

1. [Pong](asm/9_pong/README.md)