#!/bin/bash

BASE=`pwd`
source ~/android/setenv.sh

while : ; do
	case "$1" in
		"")
			break
			;;
		taglib)
			shift
			BUILD_TAGLIB=1
			;;
		freetype)
			shift
			BUILD_FREETYPE=1
			;;
		openssl)
			shift
			BUILD_OPENSSL=1
			;;
		iconv)
			shift
			BUILD_ICONV=1
			;;
		mariadb)
			shift
			BUILD_MARIADB=1
			;;
		lame)
			shift
			BUILD_LAME=1
			;;
		exiv2)
			shift
			BUILD_EXIV2=1
			;;
		qt5extras)
			shift
			BUILD_QT5EXTRAS=1
			;;
		all)
			shift
			BUILD_TAGLIB=1
			BUILD_FREETYPE=1
			BUILD_OPENSSL=1
			BUILD_ICONV=1
			BUILD_MARIADB=1
			BUILD_LAME=1
			BUILD_EXIV2=1
			BUILD_QT5EXTRAS=1
			;;
		*)
			echo "$0 lib [lib...]"
			echo " where lib is one or more of"
			echo "   all"
			echo "   taglib"
			echo "   freetype"
			echo "   openssl"
			echo "   iconv"
			echo "   mariadb"
			echo "   lame"
			echo "   exiv2"
			echo "   qt5extras"
			exit 1
			;;
	esac
done

QTVERSION=5.4.1

CROSSPATH=$ANDROID_NDK/my-android-toolchain/bin
CROSSPATH2=$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-
SYSROOT=$ANDROID_NDK/my-android-toolchain/sysroot
INSTALLROOT=$BASE/mythinstall
# https://github.com/taka-no-me/android-cmake
#armeabi - ARMv5TE based CPU with software floating point operations;
#armeabi-v7a - ARMv7 based devices with hardware FPU instructions (VFPv3_D16);
#armeabi-v7a with NEON - same as armeabi-v7a, but sets NEON as floating-point unit;
#armeabi-v7a with VFPV3 - same as armeabi-v7a, but sets VFPv3_D32 as floating-point unit;

build_taglib() {
pushd taglib-1.9.1
rm -rf build
mkdir build
pushd taglib
patch -p0 -t <<END
--- CMakeLists.txt.first	2015-02-21 19:55:08.634450005 +1100
+++ CMakeLists.txt	2015-02-21 20:03:49.189005782 +1100
@@ -314,8 +314,8 @@
 endif()
 
 set_target_properties(tag PROPERTIES
-  VERSION ${TAGLIB_SOVERSION_MAJOR}.${TAGLIB_SOVERSION_MINOR}.${TAGLIB_SOVERSION_PATCH}
-  SOVERSION ${TAGLIB_SOVERSION_MAJOR}
+  VVERSION ${TAGLIB_SOVERSION_MAJOR}.${TAGLIB_SOVERSION_MINOR}.${TAGLIB_SOVERSION_PATCH}
+  SSOVERSION ${TAGLIB_SOVERSION_MAJOR}
   INSTALL_NAME_DIR ${LIB_INSTALL_DIR}
   DEFINE_SYMBOL MAKE_TAGLIB_LIB
   LINK_INTERFACE_LIBRARIES ""
END
popd
pushd build
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_ROOT/android-cmake/android.toolchain.cmake \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DANDROID_NDK=$ANDROID_NDK                     \
      -DCMAKE_BUILD_TYPE=Release                     \
      -DANDROID_ABI="armeabi-v7a with NEON"          \
      -DSOVERSION="" \
      .. && \
      cmake --build . && \
      cmake --build . --target install

popd
popd
}

build_freetype() {
rm -rf build
pushd freetype-2.5.5
OPATH=$PATH
PATH=$CROSSPATH:$PATH
./configure --host=arm-linux-androideabi \
	--prefix=$INSTALLROOT \
	--with-sysroot=$SYSROOT \
	--with-png=no \
	--with-harfbuzz=no
make -j4
make install
PATH=$OPATH
unset OPATH
popd
}

build_openssl() {
rm -rf build
pushd openssl-1.0.2
OPATH=$PATH
PATH=$CROSSPATH:$PATH
RANLIB=${CROSSPATH2}ranlib CC=${CROSSPATH2}gcc ./Configure android-armv7 --prefix=$INSTALLROOT
ANDROID_DEV=$SYSROOT make -j4
make install
PATH=$OPATH
unset OPATH
popd
}

build_iconv() {
rm -rf build
pushd libiconv-1.14
OPATH=$PATH
PATH=$CROSSPATH:$PATH
STRIP=${CROSSPATH2}strip \
	RANLIB=${CROSSPATH2}ranlib \
	OBJDUMP=${CROSSPATH2}objdump \
	AR=${CROSSPATH2}ar \
	CC=${CROSSPATH2}gcc \
	CFLAGS=--sysroot=$SYSROOT \
	CPP=${CROSSPATH2}cpp \
	CPPFLAGS=$CFLAGS \
	./configure --build=x86_64 --host=arm --prefix=$INSTALLROOT --with-sysroot=$SYSROOT &&
       make install	
PATH=$OPATH
unset OPATH
popd
}

build_mariadb() {
pushd mariadb-connector-c-2.1.0-src
pushd libmariadb
patch -p0 -t <<END
--- CMakeLists.txt.first	2015-02-21 14:48:19.730589947 +1100
+++ CMakeLists.txt	2015-02-22 08:27:33.029951254 +1100
@@ -362,12 +362,16 @@
 SET(LIBMARIADB_SOURCES ${LIBMARIADB_SOURCES} ${ZLIB_SOURCES})
   INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/zlib)
 ENDIF()
+INCLUDE_DIRECTORIES(${ICONV_INCLUDE_DIR})
+LINK_LIBRARIES(${ICONV_LIBRARY})
 
 # CREATE OBJECT LIBRARY 
 ADD_LIBRARY(mariadb_obj OBJECT ${LIBMARIADB_SOURCES})
 IF(UNIX)
   SET_TARGET_PROPERTIES(mariadb_obj PROPERTIES COMPILE_FLAGS "${CMAKE_SHARED_LIBRARY_C_FLAGS}")
 ENDIF()
+INCLUDE_DIRECTORIES()
+LINK_LIBRARIES()
 
 ADD_LIBRARY(mariadbclient STATIC $<TARGET_OBJECTS:mariadb_obj> ${EXPORT_LINK})
 TARGET_LINK_LIBRARIES(mariadbclient ${SYSTEM_LIBS})
@@ -377,6 +381,8 @@
 IF(UNIX)
   SET_TARGET_PROPERTIES(libmariadb PROPERTIES COMPILE_FLAGS "${CMAKE_SHARED_LIBRARY_C_FLAGS}")
 ENDIF()
+INCLUDE_DIRECTORIES()
+LINK_LIBRARIES()
 
 IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
   TARGET_LINK_LIBRARIES (libmariadb "-Wl,--no-undefined")
@@ -387,9 +393,9 @@
 
 SET_TARGET_PROPERTIES(libmariadb PROPERTIES PREFIX "")
 
-SET_TARGET_PROPERTIES(libmariadb PROPERTIES VERSION 
+SET_TARGET_PROPERTIES(libmariadb PROPERTIES VVERSION 
    ${CPACK_PACKAGE_VERSION_MAJOR}
-   SOVERSION ${CPACK_PACKAGE_VERSION_MAJOR})
+   SSOVERSION ${CPACK_PACKAGE_VERSION_MAJOR})
 
 #
 # Installation
END
popd
rm -rf build
mkdir build
pushd build
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_ROOT/android-cmake/android.toolchain.cmake \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DANDROID_NDK=$ANDROID_NDK                     \
      -DCMAKE_BUILD_TYPE=Release                     \
      -DANDROID_ABI="armeabi-v7a with NEON"          \
      -DWITH_EXTERNAL_ZLIB:BOOL=ON \
      -DWITH_OPENSSL:BOOL=OFF \
      -DCMAKE_CXX_FLAGS="-Dushort=uint16_t" \
      -DCMAKE_C_FLAGS="-Dushort=uint16_t" \
      -DCMAKE_PREFIX_PATH="$INSTALLROOT" \
      -DICONV_LIBRARY=$INSTALLROOT/lib/libiconv.a \
      .. && \
      make VERBOSE=1 && \
      cmake --build . --target install

popd
popd
}

build_lame() {
rm -rf build
pushd lame-3.99.5
OPATH=$PATH
#PATH=$CROSSPATH:$PATH
#CPPFLAGS="-isysroot $SYSROOT"
patch -p0 -t <<END
--- config.sub.orig	2015-02-15 14:50:50.199338461 +1100
+++ config.sub	2015-02-15 15:06:56.202841075 +1100
@@ -1252,6 +1252,9 @@
 	-aros*)
 		os=-aros
 		;;
+	-android*)
+		os=-android
+		;;
 	-kaos*)
 		os=-kaos
 		;;
END
./configure \
	CFLAGS="-isysroot $SYSROOT -march=armv7-a" \
	CC="$CROSSPATH/arm-linux-androideabi-gcc" \
	CPP="$CROSSPATH/arm-linux-androideabi-cpp" \
	--host=arm-linux-androideabi \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static \
	--disable-frontend
make clean
make -j4
make install
PATH=$OPATH
unset OPATH
popd
}

build_exiv2() {
rm -rf build
pushd exiv2-0.24
OPATH=$PATH
patch -p0 -t <<END
--- configure.first	2015-02-22 07:43:24.151529203 +1100
+++ configure	2015-02-22 07:43:53.764366303 +1100
@@ -15104,8 +15104,8 @@
   version_type=linux
   need_lib_prefix=no
   need_version=no
-  library_names_spec='${libname}${release}${shared_ext}$versuffix ${libname}${release}${shared_ext}$major $libname${shared_ext}'
-  soname_spec='${libname}${release}${shared_ext}$major'
+  library_names_spec='${libname}${release}${shared_ext}$versuffix ${libname}${release}${major}${shared_ext} $libname${shared_ext}'
+  soname_spec='${libname}${release}${major}${shared_ext}'
   finish_cmds='PATH="\$PATH:/sbin" ldconfig -n $libdir'
   shlibpath_var=LD_LIBRARY_PATH
   shlibpath_overrides_runpath=no
END
./configure \
	CFLAGS="-isysroot $SYSROOT -march=armv7-a" \
	CXXFLAGS="-isysroot $SYSROOT -march=armv7-a" \
	CC="$CROSSPATH/arm-linux-androideabi-gcc" \
	CXX="$CROSSPATH/arm-linux-androideabi-g++" \
	CPP="$CROSSPATH/arm-linux-androideabi-cpp" \
	--host=arm-linux-androideabi \
	--prefix=$INSTALLROOT \
	--disable-xmp \
	--enable-shared \
	--enable-static 2>&1 | tee xxx
make clean
make -j4
make install
PATH=$OPATH
unset OPATH
popd
}

build_android_external_liblzo() {
rm -rf build
pushd android-external-liblzo
OPATH=$PATH
patch -p0 -t <<END
--- autoconf/config.sub.orig	2015-02-15 16:07:07.005411976 +1100
+++ autoconf/config.sub	2015-02-15 16:07:35.378208159 +1100
@@ -1399,6 +1399,9 @@
 	-dicos*)
 		os=-dicos
 		;;
+	-android*)
+		os=-android
+		;;
 	-none)
 		;;
 	*)
END
./configure \
	CFLAGS="-isysroot $SYSROOT -march=armv7-a" \
	CXXFLAGS="-isysroot $SYSROOT -march=armv7-a" \
	CC="$CROSSPATH/arm-linux-androideabi-gcc" \
	CXX="$CROSSPATH/arm-linux-androideabi-g++" \
	CPP="$CROSSPATH/arm-linux-androideabi-cpp" \
	--host=arm-linux-androideabi \
	--prefix=$INSTALLROOT \
	--disable-xmp \
	--enable-shared \
	--enable-static
make clean
make -j4
make install
cp minilzo/minilzo.h $INSTALLROOT/include
PATH=$OPATH
unset OPATH
popd
}

configure_qt5() {
rm -rf build
pushd qt-everywhere-opensource-src-$QTVERSION
OPATH=$PATH

export ANDROID_NDK_PLATFORM=android-17
export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
./configure -xplatform android-g++ \
	-opensource -confirm-license \
	-prefix $INSTALLROOT \
	-extprefix $INSTALLROOT \
	-sysroot $SYSROOT \
	-nomake tests -nomake examples \
	-android-arch armeabi-v7a \
	-android-toolchain-version 4.9 \
	-qt-sql-mysql -continue \
	-skip qttranslations \
	-skip qtserialport \
	-skip qtwebkit-examples \
	-no-warnings-are-errors

	#-android-ndk-host $ANDROID_NDK_TOOLS_PREFIX \
	#-skip qtwebkit \
	#--with-png=no \
	#--with-harfbuzz=no

PATH=$OPATH
unset OPATH
popd
}

build_webkit() {
rm -rf build
#pushd qtwebkit-opensource-src-5.4.0
pushd qt-everywhere-opensource-src-5.4.0/qtwebkit
OPATH=$PATH

#../qt-everywhere-opensource-src-5.4.0/qtbase/src/3rdparty/sqlite
export ANDROID_NDK_PLATFORM=android-17
export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
export CPPFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\""
export LDFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\""
export CXXPPFLAGS="--sysroot=\"$sysroot\""
#export INSTALL_ROOT="$INSTALLROOT"
$QTBASE/bin/qmake
make -j4
cd Source
make -f Makefile.widgetsapi install
make -f Makefile.api install

PATH=$OPATH
unset OPATH
popd
}

build_mysqlplugin() {
rm -rf build
pushd qt-everywhere-opensource-src-$QTVERSION/qtbase/src/plugins/sqldrivers/mysql
OPATH=$PATH

export ANDROID_NDK_PLATFORM=android-17
export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
export CPPFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\" -I$INSTALLROOT/include/mariadb"
export LDFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\" -L$INSTALLROOT/lib/mariadb"
export CXXPPFLAGS="--sysroot=\"$sysroot\" -I$INSTALLROOT/include"
#export INSTALL_ROOT="$INSTALLROOT"
$QTBASE/bin/qmake \
	"INCLUDEPATH+=$INSTALLROOT/include/mariadb" \
	"LIBPATH+=$INSTALLROOT/lib/mariadb"
make -j4
make install

PATH=$OPATH
unset OPATH
popd
}

pushd libs

[ -n "$BUILD_TAGLIB" ] && build_taglib
[ -n "$BUILD_FREETYPE" ] && build_freetype
[ -n "$BUILD_OPENSSL" ] && build_openssl
[ -n "$BUILD_ICONV" ] && build_iconv
[ -n "$BUILD_MARIADB" ] && build_mariadb
[ -n "$BUILD_LAME" ] && build_lame
[ -n "$BUILD_EXIV2" ] && build_exiv2
if [ -n "$BUILD_QT5EXTRAS" ]; then
	configure_qt5
	build_webkit
	build_mysqlplugin
fi

popd
