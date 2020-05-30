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

## tiled2bat

## vgm_strip