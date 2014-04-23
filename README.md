# Automatic building of Minetest for OS X from GitHub repo

[Binaries made with this are available here](https://github.com/mdoege/minetest/releases)

Usage:

    bash make_mac.sh

This will create a ZIP file in releases/ with an app bundle.

The script

* updates Minetest OS X executable and shared files
* does not change libraries (so an old minetest.app is needed)

## Dependencies

Install with [Homebrew](http://brew.sh/) ("brew install"): cmake, irrlicht, jpeg, libogg, libvorbis

(Maybe you need XQuartz too to compile this?)

## Playing the game

* Use two finger tap for right click

* Use "e" for sneak/climb down (activate in Settings)

## How to update dynamic libraries

This will create the libs directory and change library path names:

    dylibbundler -x minetest.app/Contents/Resources/bin/minetest -b -d ./minetest.app/Contents/libs/ \
    -p @executable_path/../../libs/ -cd

Check if all no libraries point to Homebrew Cellar direcory any more:

    $ for x in *.dylib ; do otool -L $x|grep Cell; done

Update a library reference that was not updated by dylibbundler with:

    $ install_name_tool -change /usr/local/Cellar/libvorbis/1.3.4/lib/libvorbis.0.dylib \
    @executable_path/../../libs/libvorbis.0.dylib libvorbisfile.3.dylib
