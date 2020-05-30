# HuDK tools

## Build instructions

Create a `build` directory and launch CMake configuration.
```bash
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=./install
```

You can build the tools.
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