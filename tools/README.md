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

## tiled2bat

## vgm_strip