#!/bin/bash

export MYMYTHPATH="`readlink -f ../../../mythtv`"

if [ ! -f "$MYMYTHPATH/authors.map" ]; then
    echo "Cannot find MythTV source code."
    exit
fi

export BASE=$PWD
export BUILDPATH=$BASE"/build"
export PATH=$BUILDPATH"/mxe/usr/bin":$PATH
export QTMAKE=$BUILDPATH"/mxe/usr/bin"/i686-w64-mingw32.shared-qmake-qt5
export IN1=$BUILDPATH"/mxe/usr/i686-w64-mingw32.shared"
export CROSSPREFIX=$BUILDPATH"/mxe/usr/bin/"i686-w64-mingw32.shared

function makeclean() {
    echo "Cleaning MythTV build directory" rm - rf $BUILDPATH/windows-package-source

    #setup new build source
    rm -r -f $BUILDPATH/windows-package-source
    mkdir -p $BUILDPATH/windows-package-source
    cd $BASE
    cp -r $MYMYTHPATH/. $BUILDPATH/windows-package-source
    make clean
}

#process command
case "$1" in
    "clean")
        makeclean
        exit 0
        ;;
    "")
        ;;
    *)
        echo "unknown command"
        exit 2
        ;;
esac

if [ ! -d "$BUILDPATH/windows-package-source" ]; then
    echo "Creating MythTV build directory"
    makeclean;
fi

#fix mythtv music metadata scripts
sudo mkdir -p /metadata/Music
sudo chmod -R 777 /metadata/Music

cd $BUILDPATH/windows-package-source
export BUILDNAME=$(git describe --abbrev=4 HEAD)
if test -e .exif_patched; then
    echo "libexif source already patched"
else
    echo "Patching libexif source"
    patch -p1 < platform/win32/w64-mingw32/Patches/libexiv2.patch
    touch .exif_patched
fi

echo "Compiling mythtv"

cd $BUILDPATH/windows-package-source/mythtv
./configure --prefix="$BUILDPATH/install" --enable-cross-compile --cross-prefix=$CROSSPREFIX- --target_os=mingw32 --arch=x86 --cpu=pentium3 --qmake=$QTMAKE --extra-cflags=-I$IN1/include-I/home/ubuntu/Desktop/build/mxe/usr/lib/gcc/i686-w64-mingw32.shared/8.4.0/include/c++/i686-w64-mingw32.shared --extra-ldflags=-L$IN1/lib --disable-lirc --disable-hdhomerun --disable-firewire --disable-vdpau  --disable-nvdec --disable-dxva2 --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libxvid --enable-libvpx --disable-w32threads --enable-silent_cc
if test $? != 0; then
    echo "Configure failed."
    exit
fi

make -j$(nproc)
if test $? != 0; then
    echo "Make failed."
    exit
fi

cp $BUILDPATH/windows-package-source/mythtv/external/FFmpeg/ffmpeg_g.exe $BUILDPATH/windows-package-source/mythtv/external/FFmpeg/mythffmpeg.exe
cp $BUILDPATH/windows-package-source/mythtv/external/FFmpeg/ffprobe_g.exe $BUILDPATH/windows-package-source/mythtv/external/FFmpeg/mythffprobe.exe
make install
if test $? != 0; then
    echo "Make install failed."
    exit
fi

#The libxxx.dll.a files get installed as liblibxxx.dll.a.
cd $BUILDPATH/windows-package-source/install/lib
mmv -d 'liblib*' 'lib#1'

cd $BUILDPATH/windows-package-source/mythplugins
./configure --prefix="$BUILDPATH/install" --disable-mytharchive --disable-mythnetvision
make -j$(nproc) install
if test $? != 0; then
    echo "Make plugins failed."
    exit
fi

cp -R $BASE/Installer/*.* $BUILDPATH/install/
cp $BUILDPATH/windows-package-source/LICENSE $BUILDPATH/install/LICENSE
rsync -a --exclude=".git" $BUILDPATH/themes $BUILDPATH/install/share/mythtv/

cd $BUILDPATH"/install/bin"
mkdir -p platforms
mkdir -p sqldrivers
mkdir -p plugins

cp -R $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/qt5/bin/*.dll .
cp -R $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/bin/*.dll .
cp $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/qt5/plugins/sqldrivers/qsqlmysql.dll $BUILDPATH"/install/bin/sqldrivers/qsqlmysql.dll"
cp $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/qt5/qml/QtQuick/Window.2/windowplugin.dll $BUILDPATH"/install/bin/platforms/windowplugin.dll"
cp $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/qt5/plugins/styles/qwindowsvistastyle.dll $BUILDPATH"/install/bin/platforms/qwindowsvistastyle.dll"

mv opengl32.dll SOFTWARE_opengl32.dll
mv $BUILDPATH/install/lib/mythtv/plugins/* plugins
mv $BUILDPATH/install/lib/*.dll .

#remove version numbers from plugin file names
cd $BUILDPATH/install/bin/plugins/
for f in *.dll
do
    mv "$f" $(sed -e "s/[0-9]//g" <(echo $f))
done

cd $BUILDPATH/mxe/usr/i686-w64-mingw32.shared/qt5/plugins/
find . -name \*.dll -exec cp {} $BUILDPATH"/install/bin/platforms/" \;

cd $BUILDPATH"/install"
find . -name \*.a -exec cp {} \lib \;
find . -name \*.lib -exec cp {} \lib \;
cd bin
find . -name \*.a -exec cp {} \lib \;
find . -name \*.lib -exec cp {} \lib \;
cd ..

NOW=`date +"%d_%m_%Y"`
zip -rq MythTV-Windows-$BUILDNAME-$NOW.zip *

echo "Done building mythtv"
