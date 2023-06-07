#!/bin/bash

echo "Tested on ubuntu 22.04. Run this script to build mythtv libraries for Windows"

sudo apt-get --assume-yes install \
    git gcc g++ wget python3 perl bzip2 lzip unzip libssl-dev \
    p7zip make autoconf automake bison flex autopoint gperf \
    libtool libtool-bin ruby intltool p7zip-full \
    pkg-config yasm mmv python-is-python3
    
export BASE=$PWD
export BUILDPATH=$BASE"/build"
export PATH=$BUILDPATH"/mxe/usr/bin":$PATH

#process command
case "$1" in
    "clean")
        echo "Removing build tree"
        rm -rf $BUILDPATH
        exit 0
        ;;
    "")
        ;;
    *)
        echo "unknown command"
        exit 2
        ;;
esac

sudo ln -s -f $BUILDPATH/mxe/usr/bin/i686-w64-mingw32.shared-windres /usr/bin/i686-w64-mingw32.shared-windres
sudo ln -s -f $BUILDPATH/mxe/usr/bin/i686-w64-mingw32.shared-gcc /usr/bin/i686-w64-mingw32.shared-gcc

mkdir -p $BUILDPATH/install/bin/plugins
mkdir -p $BUILDPATH/themes

if test -e "$BUILDPATH/themes/Mythbuntu-classic"; then
    echo "MythTV themes already exist"
else
    echo "Cloning MythTV themes"
    cd $BUILDPATH/themes
    git clone https://github.com/paul-h/MythCenterXMAS-wide.git
    git clone https://github.com/wesnewell/Functionality
    git clone https://github.com/MythTV-Themes/TintedGlass
    git clone https://github.com/MythTV-Themes/Readability
    git clone https://github.com/MythTV-Themes/Steppes
    git clone https://github.com/MythTV-Themes/Retro-wide
    git clone https://github.com/MythTV-Themes/LCARS
    git clone https://github.com/MythTV-Themes/Childish
    git clone https://github.com/MythTV-Themes/Arclight
    git clone https://github.com/MythTV-Themes/Mythbuntu
    git clone https://github.com/MythTV-Themes/blue-abstract-wide
    git clone https://github.com/MythTV-Themes/Mythbuntu-classic
fi

cd $BUILDPATH
if test -d "mxe"; then
    echo "MXE already exists"
else
    echo "Cloning MXE"
    git clone https://github.com/mxe/mxe.git

    echo "Add SQL to QT"
    sed -i 's/-no-sql-mysql /\//g' $BUILDPATH/mxe/src/qt.mk

    #apply qtwebkit gcc13 patch
    cd mxe
    make cc MXE_PLUGIN_DIRS=plugins/gcc13 MXE_TARGETS='i686-w64-mingw32.shared'
    cp ../../Patches/webkit5_gcc13_fix_1.patch src
    cd src
    patch < webkit5_gcc13_fix_1.patch
    cd ../../
fi
cd mxe
make cc MXE_PLUGIN_DIRS=plugins/gcc13 MXE_TARGETS='i686-w64-mingw32.shared' vulkan-loader vulkan-headers qt5 nasm yasm libsamplerate taglib zlib gnutls \
    mman-win32 pthreads libxml2 libdvdcss x264 lame libass qtwebkit qtwebsockets xvidcore libvpx vorbis flac

if test $? != 0; then
    echo "Failed to build mxe."
    exit
fi

#fix paths
cd $BUILDPATH
find . -name \*.dll -exec cp {} \install/bin \;

cp $BUILDPATH/mxe/usr/x86_64-pc-linux-gnu/bin/yasm $BUILDPATH/mxe/usr/bin/yasm
cp $BUILDPATH/mxe/usr/bin/i686-w64-mingw32.shared-pkg-config $BUILDPATH/mxe/usr/bin/pkg-config

echo -e "#define RTLD_LAZY 0 \n#define HAVE_DVDCSS_DVDCSS_H" | tee $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/include/dlfcn.h

cd $BUILDPATH/windows-package-source
if test -e libudfread/.libudfread_installed; then
    echo "libudfread already installed"
else
    echo "Compiling libudfread"
    git clone https://code.videolan.org/videolan/libudfread.git
    cd libudfread
    ./bootstrap
    ./configure --prefix=$BUILDPATH/mxe/usr/i686-w64-mingw32.shared --host=i686-w64-mingw32.shared
    # libtool won't build this as a shared library without this flag.
    sed -i 's/LDFLAGS = /LDFLAGS = -no-undefined/' Makefile
    make -j$(nproc)
    if test $? != 0; then
        echo "Failed to build libudfread."
        exit
    fi
    make install
    touch .libudfread_installed
fi

cd $BUILDPATH
if test -e libbluray/.libbluray_installed; then
    echo "libbluray already installed"
else
    git clone https://code.videolan.org/videolan/libbluray.git
    cd libbluray
    git submodule update --init

    echo "Compiling libbluray"
    ./bootstrap
    ./configure --prefix=$BUILDPATH/mxe/usr/i686-w64-mingw32.shared --disable-examples --with-freetype --with-libxml2 --disable-bdjava-jar --host=i686-w64-mingw32.shared
    make -j$(nproc)
    if test $? != 0; then
        echo "Failed to build libbluray."
        exit
    fi
    make install
    touch .libbluray_installed
fi

cd $BUILDPATH
if test -e libzip/.libzip_installed; then
    echo "libzip already installed"
else
    echo "Compiling libzip"
    git clone https://github.com/nih-at/libzip.git
    cd libzip
    $BUILDPATH/mxe/usr/bin/i686-w64-mingw32.shared-cmake $BUILDPATH/libzip
    make -j$(nproc)
    if test $? != 0; then
        echo "Failed to build libzip."
        exit
    fi
    make install
    touch .libzip_installed
fi

cd $BUILDPATH
if test -e soundtouch/.soundtouch_installed; then
    echo "soundtouch already installed"
else
    echo "Compiling SoundTouch"
    git clone https://codeberg.org/soundtouch/soundtouch.git
    cd soundtouch
    ./bootstrap
    ./configure --prefix=$BUILDPATH/mxe/usr/i686-w64-mingw32.shared --host=i686-w64-mingw32.shared
    make -j$(nproc) LDFLAGS=-no-undefined
    if test $? != 0; then
        echo "Failed to build soundtouch."
        exit
    fi
    make install
    touch .soundtouch_installed
fi

cd $BUILDPATH
if test -f "$BUILDPATH/mxe/usr/i686-w64-mingw32.shared/include/endian.h"; then
    echo "Endian.h already exists"
else
    echo "Install endian.h"
    git clone https://gist.github.com/PkmX/63dd23f28ba885be53a5 portable_endian
    cp $BUILDPATH/portable_endian/portable_endian.h $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/include/endian.h
fi

cd $BUILDPATH
if test -e x265/.x265_installed; then
    echo "x265 already installed"
else
    echo "Compiling x265"
    git clone https://github.com/videolan/x265.git
    cd x265
    $BUILDPATH/mxe/usr/bin/i686-w64-mingw32.shared-cmake source

    make -j$(nproc)
    if test $? != 0; then
        echo "Failed to build x265."
        exit
    fi
    make install
    touch .x265_installed
fi

echo "Done compiling libs"
