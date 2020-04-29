# HuDK examples

## Build instructions
The examples are using CMake. This is not mandatory. You can use whatever build system you want.
Toolchain files for HuC/PCEas and cc65/ca65 are provided in the [cmake](./cmake/) directory.

### HuC/PCEas toolchain
⚠️ You must use this [HuC fork](https://github.com/BlockoS/huc) in order to build the examples.

Open your prefered terminal and create a `build` directory. Go to that directory and type the following command to generate Makefile. 
```bash
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../cmake/huc-toolchain.cmake \ 
    -DHUDK_TOOLS_PATH=../../.build/install/bin/ \ -DHUDK_INCLUDE_PATH=../../include/ \
    -DHUC_PATH=<path to huc/pceas binaries directory>
```

If you plan to build C example, don't forget to set the `PCE_INCLUDE` environment variable.
```bash
export PCE_INCLUDE=../../include
```

You can then build the examples by either typing
```bash
cmake --build .
```
or
```bash
make
```
The roms will be located in the `asm` directory.

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

## C

1. [Hello world](C/1_hello_world/README.md)

1. [Custom font](C/2_custom_font/README.md)

1. [Map of 8 by 8 pixels tiles](C/3_map_8x8/README.md)

1. [Map of 16 by 16 pixels tiles](C/4_map_16x16/README.md)

1. [Joypad](C/5_joypad/README.md)

1. [Sprites](C/6_sprites/README.md)

1. [Scroll / Vertical split windows](C/7_scroll/README.md)

1. [Clock](C/8_clock/README.md)

1. [Pong](C/9_pong/README.md)