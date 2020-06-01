# HuDK tools

## Build instructions

### Dependencies
The HuDK tools depend on the following libraries:
 * [jansson](https://github.com/akheron/jansson/archive/v2.12.zip)
 * [zlib](https://github.com/madler/zlib/archive/v1.2.11.zip)
 * [libpng](https://download.sourceforge.net/libpng/lpng1637.zip)
 * [mxml](https://github.com/BlockoS/mxml/archive/master.zip)
 * [argparse](https://github.com/cofyc/argparse.git)
 * [cwalk](https://github.com/likle/cwalk) 

First fetch git submodules.
```bash
cd ..
git submodule update --init --recursive
```

On some OSes `jansson`, `zib`, `libpng` and `mxml` are available as packages. If that is not the case, here are the instructions on how to build them.

#### Jansson
We will assume that you have `wget` and `unzip`. If not, you will have to download and extract the archives by yourself.
```bash
cd tools
mkdir deps
cd deps
wget https://github.com/akheron/jansson/archive/v2.12.zip
unzip v2.12.zip -d jansson
cd jansson
mkdir build
cd build
cmake -DJANSSON_BUILD_DOCS=OFF -DJANSSON_WITHOUT_TESTS=ON -G ${CMAKE_GENERATOR} -DCMAKE_INSTALL_PREFIX=../../deps/ ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd ../..
```

`CMAKE_GENERATOR` being the generator to use. It can be "GNU Makefiles", "MSYS Makefiles", "Visual Studio 15 2017", etc...

#### zlib
```bash
cd deps
wget https://github.com/madler/zlib/archive/v1.2.11.zip
unzip v1.2.11.zip -d zlib
cd zlib
mkdir build
cd build
cmake -G ${CMAKE_GENERATOR} -DCMAKE_INSTALL_PREFIX=../../deps/ ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd ../..
```
### libpng
```bash
wget https://download.sourceforge.net/libpng/lpng1637.zip
unzip lpng1637.zip -d libpng
cd libpng
mkdir build
cd build
cmake -G ${CMAKE_GENERATOR} -DCMAKE_INSTALL_PREFIX=../../deps/ -DZLIB_LIBRARY=../../deps/lib/zlib.lib -DZLIB_INCLUDE_DIR=../../deps/include ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd ../..
```
`ZLIB_LIBRARY` must point to library generated for zlib. Here we assume that we built zlib for Windows using Visual studio.

### mxml
```bash
wget https://github.com/BlockoS/mxml/archive/master.zip
unzip master.zip -d mxml
cd mxml
mkdir build
cd build
cmake -G ${CMAKE_GENERATOR} -DCMAKE_INSTALL_PREFIX=../../deps/ ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd ../..
```

### Tools

Create a `build` directory and launch CMake configuration.
```bash
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=./install
```

If you built the dependencies as shown above, you should launch CMake with:
```bash
  - cmake -G ${CMAKE_GENERATOR}
    -DCMAKE_INSTALL_PREFIX=../package
    -DBUILD_EXAMPLES=OFF
    -DZLIB_LIBRARY=./deps/lib/zlib.lib
    -DZLIB_INCLUDE_DIR=./deps/include
    -DPNG_PNG_INCLUDE_DIR=./deps/include
    -DPNG_LIBRARY=./deps/lib/libpng16.lib
    -DJANSSON_INCLUDE_DIR=./deps/include
    -DJANSSON_LIBRARY=./deps/lib/jansson.lib
    -DMXML_LIBRARIES=./deps/lib/mxml.lib
    -DMXML_INCLUDE_DIRS=./deps/include
```

You can now build the tools.
```bash
cmake --build .
cmake --build . --target install
```

If you are using the Makefile generators, you can just type the following to build and install the tools.
```bash
make && make install
```

You can change the value of `CMAKE_INSTALL_PREFIX` to install the tools in another directory.
In this example, they will be installed in `<HuDK_PATH>/build/install`.

## encode_gfx

### Usage
```
encode_gfx -o/--output-directory <out> <config.json> <image>
```

It will extract tiles, sprites and palettes as specified in the `config.json` file and writes them in the `out` directory encoded in the corresponging PC Engine format.

### Configuration file

Here is an example of configuration file:
```json
{
    "tile": [
        { "name": "tiles.bin", "x":0, "y":0, "w":1, "h":16 }
    ],
    "sprite": [
        { "name": "spr0.bin", "x":0, "y":8, "w":2, "h":2 },
        { "name": "spr1.bin", "x":32, "y":8, "w":2, "h":2 },
        { "name": "spr2.bin", "x":5, "y":40, "w":1, "h":1 }
    ],
    "palette": [
        { "name": "tiles.pal", "start": 0, "count": 1 },
        { "name": "sprites.pal", "start": 1, "count": 1 }
    ]
}
```

It contains at most 3 arrays `tile`, `sprite` and `palette`, each one containing objects.
* `tile` 
  * `name` _(string)_ : filename of the extracted tiles.
  * `x` _(integer)_ : X position in pixels in the source image of the first tile.
  * `y` _(integer)_ : Y position in pixels in the source image of the first tile.
  * `w` _(integer)_ : Tile column count.
  * `h` _(integer)_ : Tile row count.
* `sprite` 
  * `name` _(string)_ : filename of the extracted sprite.
  * `x` _(integer)_ : X position in pixels in the source image of the sprite.
  * `y` _(integer)_ : Y position in pixels in the source image of the sprite.
  * `w` _(integer)_ : Sprite width (by count of 16 pixels, max: 2).
  * `h` _(integer)_ : Sprite height (by count of 16 pixels, max: 4).
* `palette` 
  * `name` _(string)_ : filename of the extracted palettes.
  * `start` _(integer)_ : index of the first subpalette color (by count of 16 colors).
  * `y` _(integer)_ : Subpalette count.

## tiled2bat

## vgm_strip