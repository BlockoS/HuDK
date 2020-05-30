# HuDK examples

## Build instructions
The examples can be built using Makefile or CMake. You can use whatever build system you want.
Toolchain files for HuC/PCEas and cc65/ca65 are provided in the [cmake](./cmake/) directory.

### [HuDK Tools](../tools/README.md)

### HuC/PCEas toolchain
⚠️ You must use this [HuC fork](https://github.com/RickUACS/huc) in order to build the examples.

Here's a quick tutorial on how to rebuild HuC/pceas from source.

You can either fork the git repository:
```bash
git clone git@github.com:BlockoS/huc.git
```
Or download a zip file of the master branch:
```bash
wget https://github.com/BlockoS/huc/archive/master.zip
unzip master.zip
```

Now you can build the compilers by runnnig `Make` with
```bash
make
```

Advanced or reckless users can use `CMake`.
```bash
mkdir build
cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=..
cmake --build .
cmake --build . --target install
```

All the generated executables will be located in the `bin` directory.


### Examples

#### Using Makefile
Open your prefered terminal. Go to the `<HUDK_PATH>/example` directory, and simple run:
```bash
make HUDK_TOOLS_PATH=../build/install/bin/ \
     HUDK_INCLUDE_PATH=../include/ \
     HUC_PATH=<path to huc/pceas bin directory>
```

Don't forget to change `DHUDK_TOOLS_PATH` if you installed the **HuDK** tools in another directory.

The roms will be located in the `build/asm` and `build/C` directories.

#### Using CMake
Open your prefered terminal. Go to the `<HUDK_PATH>/example` directory, and create a `build` directory. 
Go to that directory and run `CMake` configuration pass.
```bash
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../cmake/huc-toolchain.cmake \ 
    -DHUDK_TOOLS_PATH=../../build/install/bin/ \ -DHUDK_INCLUDE_PATH=../../include/ \
    -DHUC_PATH=<path to huc/pceas bin directory>
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

## Examples

1. Hello world [asm](asm/1_hello_world/README.md) | [C](C/1_hello_world/README.md)

1. Custom font [asm](asm/2_custom_font/README.md) | [C](C/2_custom_font/README.md)

1. Map of 8 by 8 pixels tiles [asm](asm/3_map_8x8/README.md) | [C](C/3_map_8x8/README.md)

1. Map of 16 by 16 pixels tiles [asm](asm/4_map_16x16/README.md) | [C](C/4_map_16x16/README.md)

1. Joypad [asm](asm/5_joypad/README.md) | [C](C/5_joypad/README.md)

1. Sprites [asm](asm/6_sprites/README.md) | [C](C/6_sprites/README.md)

1. Scroll / Vertical split windows [asm](asm/7_scroll/README.md) | [C](C/7_scroll/README.md)

1. Clock [asm](asm/8_clock/README.md) | [C](C/8_clock/README.md)

1. Pong [asm](asm/9_pong/README.md) | [C](C/9_pong/README.md)
