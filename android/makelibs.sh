#!/bin/bash

set -e

BASE=`pwd`
ARM64=0
source android-utilities/setenv.sh
CLEAN=1
PRISTINE=0
export NCPUS=$(nproc)

[ -e make.inc ] && source make.inc

while : ; do
	case "$1" in
		"")
			break
			;;
		missingheaders)
			shift
			BUILD_MISSING_HEADERS=1
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
		fribidi)
			shift
			BUILD_FRIBIDI=1
			;;
		fontconfig)
			shift
			BUILD_FONTCONFIG=1
			;;
		harfbuzz)
			shift
			BUILD_HARFBUZZ=1
			;;
		ass)
			shift
			BUILD_FONTCONFIG=1
			BUILD_FRIBIDI=1
			BUILD_ASS=1
			;;
		flac)
			shift
			BUILD_FLAC=1
			;;
		ogg)
			shift
			BUILD_OGG=1
			;;
		vorbis)
			shift
			BUILD_VORBIS=1
			;;
		libxml2)
			shift
			BUILD_LIBXML2=1
			;;
		libxslt)
			shift
			BUILD_LIBXSLT=1
			;;
		glib)
			shift
			BUILD_GLIB=1
			;;
		ffi)
			shift
			BUILD_FFI=1
			;;
		gettext)
			shift
			BUILD_GETTEXT=1
			;;
		icu)
			shift
			BUILD_ICU=1
			;;
		liblzo)
			shift
			BUILD_LZO=1
			;;
		libzip)
			shift
			BUILD_LIBZIP=1
			;;
		libsamplerate)
			shift
			BUILD_LIBSAMPLERATE=1
			;;
		libsoundtouch)
			shift
			BUILD_LIBSOUNDTOUCH=1
			;;
		libbluray)
			shift
			BUILD_LIBBLURAY=1
			;;
		qt5extras)
			shift
			BUILD_QT5EXTRAS=1
			;;
		qtwebkit)
			shift
			BUILD_QTWEBKITONLY=1
			;;
		newqtwebkit)
			shift
			BUILD_NEWQTWEBKITONLY=1
			;;
		mysqlplugin)
			shift
			BUILD_QTMYSQLPLUGIN=1
			;;
		fftw)
			shift
			BUILD_FFTW=1
			;;
		all)
			shift
			#BUILD_MISSING_HEADERS=1
			BUILD_TAGLIB=1
			BUILD_FREETYPE=1
			BUILD_OPENSSL=1
			BUILD_ICONV=1
			BUILD_MARIADB=1
			BUILD_LAME=1
			BUILD_EXIV2=1
			BUILD_ICU=1
			BUILD_LZO=1
			BUILD_LIBZIP=1
			BUILD_LIBSAMPLERATE=1
			BUILD_LIBSOUNDTOUCH=1
			BUILD_LIBBLURAY=1
			BUILD_FLAC=1
			BUILD_VORBIS=1
			BUILD_OGG=1
			BUILD_HARFBUZZ=1
			BUILD_FRIBIDI=1
			BUILD_FONTCONFIG=1
			BUILD_ASS=1
			BUILD_LIBXML2=1
			#BUILD_LIBXSLT=1
			#BUILD_GLIB=1
			BUILD_QT5EXTRAS=1
			BUILD_FFTW=1
			;;
		--no-clean)
			shift
			CLEAN=0
			;;
		--pristine)
			shift
			PRISTINE=1
			;;
		--cpus)
			shift
			export NCPUS=$1
			shift
			;;
		--arm)
			shift
			ARM64=0
			;;
		--oldarm)
			shift
			ARM64=0
			ANDROID_NATIVE_API_LEVEL=17
			;;
		--arm64)
			shift
			ARM64=1
			;;
		--sdk)
			shift
			export ANDROID_NATIVE_API_LEVEL=$1
			shift
			;;
		--min-sdk)
			shift
			export ANDROID_MIN_SDK_VERSION=$1
			shift
			;;
		--target-sdk)
			shift
			export TARGET_SDK_VERSION=$1
			shift
			;;
		--list-configs)
			shift
			ls -1 android-utilities/config
			exit 0
			;;
		--config)
			shift
			source android-utilities/config/$1
			shift
			;;
			*)
			echo "$0 lib [lib...]"
			echo " where lib is one or more of"
			echo "   all"
			echo "   missingheaders"
			echo "   taglib"
			echo "   freetype"
			echo "   openssl"
			echo "   iconv"
			echo "   mariadb"
			echo "   lame"
			echo "   ogg"
			echo "   vorbis"
			echo "   flac"
			echo "   exiv2"
			echo "   icu"
			echo "   fribidi"
			echo "   fontconfig"
			echo "   ass"
			echo "   liblzo"
			echo "   libzip"
			echo "   libsamplerate"
			echo "   libsoundtouch"
			echo "   libblueray"
			echo "   qtwebkit"
			echo "   qt5extras"
			echo "   --no-clean"
			echo "   --pristine"
			echo "   --cpus"
			echo "   --arm"
			echo "   --arm64"
			echo "   --sdk <level>"
			exit 1
			;;
	esac
done

#QTMAJORVERSION=5.14
#QTVERSION=$QTMAJORVERSION.1
QTMAJORVERSION=5.15
QTVERSION=$QTMAJORVERSION.6
BUILD_WEBKIT=0
export ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL:-29}
export ANDROID_SDK_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL
export ANDROID_NDK_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL
export ANDROID_API_VERSION=${ANDROID_API_VERSION:-$ANDROID_SDK_PLATFORM}
# for cmake projects
export ANDROID_API_DEF="-D__ANDROID_API__=$ANDROID_NATIVE_API_LEVEL"

if [ $ARM64 == 1 ]; then
	TOOLCHAIN_SUFFIX=64
	MY_ANDROID_NDK_TOOLS_PREFIX=aarch64-linux-android
	MY_ANDROID_NDK_TOOLS_CC_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm64
	ARMEABI="arm64-v8a"
	CPU="cortex-a53"
	CPU_TUNE="cortex-a53"
	CPU_ARCH="armv8-a"
else
	if [ $ANDROID_NATIVE_API_LEVEL -gt 19 ]; then
		TOOLCHAIN_SUFFIX=
		EXTRA_QT_CONFIGURE_ARGS="-feature-neon"
		#EXTRA_QT_CONFIGURE_ARGS="-no-feature-neon \"-after QMAKE_CFLAGS_NEON+=-mfloat-abi=softfp\""
	else
		TOOLCHAIN_SUFFIX=old
		EXTRA_QT_CONFIGURE_ARGS=-no-feature-futimens
	fi
	MY_ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
	MY_ANDROID_NDK_TOOLS_CC_PREFIX=armv7a-linux-androideabi
	SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm
	ARMEABI="armeabi-v7a"
	CPU="armv7-a"
	CPU_TUNE="armv7-a"
	CPU_ARCH="armv7-a"
fi

ANDROID_NDK_TOOLCHAIN_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
SYSROOT=$ANDROID_NDK_TOOLCHAIN_PATH/sysroot
CROSSPATH=$ANDROID_NDK_TOOLCHAIN_PATH/bin
CROSSPATH2=$CROSSPATH/$MY_ANDROID_NDK_TOOLS_PREFIX-
CROSSPATH3=$CROSSPATH/${MY_ANDROID_NDK_TOOLS_CC_PREFIX}${ANDROID_NATIVE_API_LEVEL}-
CROSSCC=${MY_ANDROID_NDK_TOOLS_CC_PREFIX}${ANDROID_NATIVE_API_LEVEL}-clang
INSTALLROOT=$BASE/libsinstall$TOOLCHAIN_SUFFIX
QTINSTALLROOT=$BASE/libsinstall$TOOLCHAIN_SUFFIX/qt
QTBUILDROOT=build$TOOLCHAIN_SUFFIX
LIBSDIR=libs$TOOLCHAIN_SUFFIX
CROSSPATH_LLVM="$CROSSPATH2"
if [ ! -e "${CROSSPATH_LLVM}ar" ]; then
	CROSSPATH_LLVM="$CROSSPATH/llvm-"
fi
CROSSPATH_LD="$CROSSPATH2"
if [ ! -e "${CROSSPATH2}ld" ]; then
	CROSSPATH_LD="$CROSSPATH/"
fi
#EXTRA_QT_CONFIGURE_ARGS="$EXTRA_QT_CONFIGURE_ARGS -after 'QMAKE_LFLAGS_SHLIB*=-rdynamic -frtti' -after 'QMAKE_LFLAGS_APP*=-rdynamic -frtti'"
#EXTRA_QT_CONFIGURE_ARGS="$EXTRA_QT_CONFIGURE_ARGS -late 'QMAKE_LFLAGS_SHLIB*=-frtti -fexceptions' -late 'QMAKE_LFLAGS_APP*=-rdynamic -frtti -fexceptions'"
EXTRA_QT_CONFIGURE_ARGS="$EXTRA_QT_CONFIGURE_ARGS \"-late QMAKE_RANLIB=${CROSSPATH_LLVM}ranlib\""
CPUOPT="-march=$CPU_ARCH"
CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake

#armeabi - ARMv5TE based CPU with software floating point operations;
#armeabi-v7a - ARMv7 based devices with hardware FPU instructions (VFPv3_D16);
#armeabi-v7a with NEON - same as armeabi-v7a, but sets NEON as floating-point unit;
#armeabi-v7a with VFPV3 - same as armeabi-v7a, but sets VFPv3_D32 as floating-point unit;
export PKG_CONFIG_LIBDIR=$INSTALLROOT/lib

build_log=build_summary.log
date | tee -a $build_log
echo makelibs.sh | tee -a $build_log
echo ANDROID_NATIVE_API_LEVEL [SDK]: $ANDROID_NATIVE_API_LEVEL | tee -a $build_log
echo ARM64: $ARM64 | tee -a $build_log

# some headers are missing in post 19 ndks so copy them from 19 into
# our output tree
MISSINGHEADERS="
		_errdefs.h
		_sigdefs.h
		_system_properties.h
		_types.h
		_wchar_limits.h
		atomics.h
		dirent.h
		exec_elf.h
		linux-syscalls.h
		timeb.h
		"

copy_missing_sys_headers() {
	mkdir -p $INSTALLROOT/include/arpa
	cat <<-END > $INSTALLROOT/include/arpa/inet.h
	#include_next <arpa/inet.h>
	#include <linux/in6.h>
	END
	if [ "$TOOLCHAIN_SUFFIX" != "old" ]; then
		mkdir -p $INSTALLROOT/include/sys || true
		for header in $MISSINGHEADERS ; do
			echo "copying $SYSROOTEXTRA/usr/include/sys/$header"
			cp $SYSROOTEXTRA/usr/include/sys/$header $INSTALLROOT/include/sys
		done
		mkdir -p $INSTALLROOT/include/linux || true
		cat <<-END > $INSTALLROOT/include/linux/sockio.h
		#include_next <linux/sockio.h>
		#undef SIOCGIFHWADDR
		END
		mkdir -p $INSTALLROOT/include/bits || true
		cat <<-END > $INSTALLROOT/include/bits/posix_limits.h
		#include_next <bits/posix_limits.h>
		#undef _POSIX_THREAD_PRIORITY_SCHEDULING
		END
	fi
}

fetch_file() {
	[ -d ../tarballs ] || mkdir -p ../tarballs
	if [ ! -e "../tarballs/$1" ]; then
		pushd ../tarballs
		wget --no-check-certificate "$2"
		popd
	fi
}

# param 1 = URL for fetching source
# param 2 = directory name inside that tar file
#           defaults to basename of URL without .tar.*
setup_lib() {
	# fetch and extract if necessary a lib
	# prepare for patching
	# apply patch
	local URL="$1"
	local F=`basename $URL`
	local D="${F%%.tar.*}"
	[ -n "$2" ] && D="$2"
	if [ $PRISTINE == 1 ]; then
		rm -rf "$D"
	fi
	if [ ! -d "$D" ]; then
		[ -d ../tarballs ] || mkdir -p ../tarballs
		if [ ! -e "../tarballs/$F" ]; then
			pushd ../tarballs
			wget --no-check-certificate "$URL"
			popd
		fi
		tar xf "../tarballs/$F"
		pushd "$D"
		git init
		git add --all -f
		git commit -m"initial"
		popd
	fi
}

get_android_cmake() {
	if [ ! -d android-cmake ]; then
		git clone https://github.com/bingmann/android-cmake.git
	fi
}

build_taglib() {
TAGLIB=taglib-1.11.1
echo -e "\n**** $TAGLIB ****"
setup_lib http://taglib.org/releases/$TAGLIB.tar.gz
pushd $TAGLIB
rm -rf build
mkdir build
pushd taglib
{ patch -p0 -Nt -r - || true; } <<'END'
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
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DANDROID_NDK=$ANDROID_NDK		\
      -DANDROID_TOOLCHAIN="clang"	\
      -DCMAKE_BUILD_TYPE=Release                \
      -DBUILD_SHARED_LIBS=ON                    \
      -DANDROID_ABI="$ARMEABI"                  \
      -DANDROID_NATIVE_API_LEVEL="$ANDROID_NATIVE_API_LEVEL"  \
      -DCMAKE_MAKE_PROGRAM=make \
      -DCMAKE_PREFIX_PATH="$INSTALLROOT" \
      -DSOVERSION="" \
      .. && \
      cmake --build . -j$NCPUS && \
      cmake --build . --target install
      ERR=$?

      #-DANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK_TOOLCHAIN_PATH \
      #-DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=1 \

popd
popd
return $ERR
}

build_freetype() {
FREETYPE=freetype-2.12.1
echo -e "\n**** $FREETYPE ****"
setup_lib http://download.savannah.gnu.org/releases/freetype/$FREETYPE.tar.xz $FREETYPE
pushd $FREETYPE
if [ $CLEAN == 1 ]; then
	make distclean || true
fi
OPATH=$PATH
PATH=$CROSSPATH:$PATH
CC=$CROSSCC \
./configure --host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-sysroot=$SYSROOT \
	--with-png=no \
	--with-harfbuzz=no && \
make -j$NCPUS && \
make install
ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_openssl() {
rm -rf build
#OPENSSL=openssl-1.0.2u
OPENSSL=openssl-1.1.1s
#OPENSSL=openssl-3.0.7
if [ $ARM64 == 1 ]; then
	#OPENSSL_FLAVOUR=android-armv8
	#OPENSSL_FLAVOUR=android64-aarch64
	OPENSSL_FLAVOUR=android-arm64
else
	#OPENSSL_FLAVOUR=android-armv7
	OPENSSL_FLAVOUR=android-arm
fi
echo -e "\n**** $OPENSSL ****"
setup_lib https://www.openssl.org/source/$OPENSSL.tar.gz $OPENSSL
pushd $OPENSSL
OPATH=$PATH
export PATH=$CROSSPATH:$PATH
if [ -e "$BASE"/patches/${OPENSSL}.patch ]; then
	patch -p1 -Nt --no-backup-if-mismatch -r - < "$BASE"/patches/${OPENSSL}.patch || true
elif [ 0 -ne 0 ]; then
{ patch -p1 -Nt -r - || true; } <<'END'
diff --git a/Configure b/Configure
index 494e0b3..5283852 100755
--- a/Configure
+++ b/Configure
@@ -471,11 +471,11 @@ my %table=(
 "linux-alpha+bwx-ccc","ccc:-fast -readonly_strings -DL_ENDIAN::-D_REENTRANT:::SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_PTR DES_RISC1 DES_UNROLL:${alpha_asm}",
 
 # Android: linux-* but without pointers to headers and libs.
-"android","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
-"android-x86","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
-"android-armv7","gcc:-march=armv7-a -mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
-"android-mips","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
-"android64-aarch64","gcc:-mandroid -fPIC -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-pie%-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${aarch64_asm}:linux64:dlfcn:linux-shared:::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android","gcc:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-x86","gcc:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-armv7","gcc:-march=armv7 -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-mips","gcc:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android64-aarch64","gcc:-fPIC -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-pie%-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${aarch64_asm}:linux64:dlfcn:linux-shared:::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
 
 #### *BSD [do see comment about ${BSDthreads} above!]
 "BSD-generic32","gcc:-O3 -fomit-frame-pointer -Wall::${BSDthreads}:::BN_LLONG RC2_CHAR RC4_INDEX DES_INT DES_UNROLL:${no_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
@@ -733,6 +733,7 @@ my $openssldir="";
 my $exe_ext="";
 my $install_prefix= "$ENV{'INSTALL_PREFIX'}";
 my $cross_compile_prefix="";
+my $cross_compile_prefix_cc="";
 my $fipsdir="/usr/local/ssl/fips-2.0";
 my $fipslibdir="";
 my $baseaddr="0xFB00000";
@@ -987,6 +988,10 @@ PROCESS_ARGS:
 				{
 				$baseaddr="$1";
 				}
+			elsif (/^--cross-compile-prefix-cc=(.*)$/)
+				{
+				$cross_compile_prefix_cc=$1;
+				}
 			elsif (/^--cross-compile-prefix=(.*)$/)
 				{
 				$cross_compile_prefix=$1;
@@ -1205,6 +1210,7 @@ $perl=$ENV{'PERL'} or $perl=&which("perl5") or $perl=&which("perl")
 my $make = $ENV{'MAKE'} || "make";
 
 $cross_compile_prefix=$ENV{'CROSS_COMPILE'} if $cross_compile_prefix eq "";
+$cross_compile_prefix_cc=$ENV{'CROSS_COMPILE'} if $cross_compile_prefix_cc eq "";
 
 chop $openssldir if $openssldir =~ /\/$/;
 chop $prefix if $prefix =~ /.\/$/;
@@ -1271,7 +1277,7 @@ my ($prelflags,$postlflags)=split('%',$lflags);
 if (defined($postlflags))	{ $lflags=$postlflags;	}
 else				{ $lflags=$prelflags; undef $prelflags;	}
 
-if ($target =~ /^mingw/ && `$cross_compile_prefix$cc --target-help 2>&1` !~ m/\-mno\-cygwin/m)
+if ($target =~ /^mingw/ && `$cross_compile_prefix_cc$cc --target-help 2>&1` !~ m/\-mno\-cygwin/m)
 	{
 	$cflags =~ s/\-mno\-cygwin\s*//;
 	$shared_ldflag =~ s/\-mno\-cygwin\s*//;
@@ -1666,7 +1672,7 @@ if ($shlib_version_number =~ /(^[0-9]*)\.([0-9\.]*)/)
 my %predefined;
 
 # collect compiler pre-defines from gcc or gcc-alike...
-open(PIPE, "$cross_compile_prefix$cc -dM -E -x c /dev/null 2>&1 |");
+open(PIPE, "$cross_compile_prefix_cc$cc -dM -E -x c /dev/null 2>&1 |");
 while (<PIPE>) {
   m/^#define\s+(\w+(?:\(\w+\))?)(?:\s+(.+))?/ or last;
   $predefined{$1} = defined($2) ? $2 : "";
@@ -1734,7 +1740,7 @@ while (<IN>)
 	s/^CONFIGURE_ARGS=.*$/CONFIGURE_ARGS=$argvstring/;
 	if ($cross_compile_prefix)
 		{
-		s/^CC=.*$/CROSS_COMPILE= $cross_compile_prefix\nCC= \$\(CROSS_COMPILE\)$cc/;
+		s/^CC=.*$/CROSS_COMPILE_CC= $cross_compile_prefix_cc\nCC= \$\(CROSS_COMPILE_CC\)$cc/;
 		s/^AR=\s*/AR= \$\(CROSS_COMPILE\)/;
 		s/^NM=\s*/NM= \$\(CROSS_COMPILE\)/;
 		s/^RANLIB=\s*/RANLIB= \$\(CROSS_COMPILE\)/;
END
	fi
# Make sure that configure file time is past
SSL_EXT="SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so"
OPENSSL_CONFIGS="shared"
#if [ $CLEAN == 1 ]; then
	make distclean || true
#fi
rm Makefile || true
CC=clang \
PATH="${CROSSPATH3}:$PATH" \
./Configure \
	--prefix=$INSTALLROOT \
	$OPENSSL_CONFIGS \
	$ANDROID_API_DEF \
	$OPENSSL_FLAVOUR \
	&& \
make -j$NCPUS $SSL_EXT build_libs && \
make $SSL_EXT install_dev && \
make $SSL_EXT install_runtime_libs

# the .la files are missing so we will create some here for easier linking
# due to the .so name difference
cat <<END >>$INSTALLROOT/lib/libssl.la
dlname='libssl_1_1.so'
END
cat <<END >>$INSTALLROOT/lib/libcrypto.la
dlname='libcrypto_1_1.so'
END


ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_iconv() {
LIBICONV=libiconv-1.16
echo -e "\n**** $LIBICONV ****"
setup_lib https://ftp.gnu.org/pub/gnu/libiconv/$LIBICONV.tar.gz $LIBICONV
rm -rf build
pushd $LIBICONV
BUILD_HOST=$MY_ANDROID_NDK_TOOLS_PREFIX
#if [ $ARM64 == 1 ]; then
#	BUILD_HOST=aarch64-linux-android
#else
#	BUILD_HOST=arm-linux-androideabi
#fi
OPATH=$PATH
PATH=$CROSSPATH:$PATH
local MAKEDEFS
#local MAKEDEFS+=" WARN_ON_USE_H=0"
#MAKEDEFS+=" GNULIBS_GETS"
if [ $CLEAN == 1 ]; then
	make distclean || true
fi
STRIP=${CROSSPATH2}strip \
	CC=${CROSSPATH3}clang \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH2}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CFLAGS="--sysroot=$SYSROOT $ANDROID_API_DEF" \
	CPPFLAGS=$CFLAGS \
	./configure --build=x86_64 --host=$BUILD_HOST --prefix=$INSTALLROOT --with-sysroot=$SYSROOT --enable-shared=yes --enable-static=yes &&
	make -j$NCPUS $MAKEDEFS install-lib
	ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_mariadb() {
MARIADB_CONNECTOR_C_VERSION=3.3.3
#MARIADB_CONNECTOR_C_VERSION=3.3.0
#MARIADB_CONNECTOR_C_VERSION=3.2.6
#MARIADB_CONNECTOR_C_VERSION=3.1.6
#MARIADB_CONNECTOR_C_VERSION=2.3.7
#MARIADB_CONNECTOR_C_VERSION=2.2.3
#MARIADB_CONNECTOR_C_VERSION=2.1.0
MARIADB_CONNECTOR_C=mariadb-connector-c-$MARIADB_CONNECTOR_C_VERSION-src
MARIADB_CONNECTOR_C_TARBALL="../tarballs/mariadb-connector-c-$MARIADB_CONNECTOR_C_VERSION-src.tar.gz"
echo -e "\n**** $MARIADB_CONNECTOR_C ****"
setup_lib https://downloads.mariadb.com/Connectors/c/connector-c-$MARIADB_CONNECTOR_C_VERSION/mariadb-connector-c-$MARIADB_CONNECTOR_C_VERSION-src.tar.gz $MARIADB_CONNECTOR_C
if [ ! -e "$MARIADB_CONNECTOR_C_TARBALL" ]; then
	setup_lib https://downloads.mariadb.org/Connectors/c/connector-c-$MARIADB_CONNECTOR_C_VERSION/mariadb-connector-c-$MARIADB_CONNECTOR_C_VERSION-src.tar.gz/from/http%3A//ftp.hosteurope.de/mirror/archive.mariadb.org/ $MARIADB_CONNECTOR_C
	mv "$MARIADB_CONNECTOR_C_TARBALL*" "$MARIADB_CONNECTOR_C_TARBALL"
fi
pushd $MARIADB_CONNECTOR_C
if [ -e "$BASE"/patches/mariadb-${MARIADB_CONNECTOR_C_VERSION}.patch ]; then
	patch -p1 -Nt --no-backup-if-mismatch -r - < "$BASE"/patches/mariadb-${MARIADB_CONNECTOR_C_VERSION}.patch || true
elif [ $MARIADB_CONNECTOR_C_VERSION == 2.1.0 ]; then
pushd libmariadb
{ patch -p0 -Nt || true; } <<'END'
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
index 68be4aa..cef0af8 100644
--- mf_pack.c
+++ mf_pack.c
@@ -314,7 +314,7 @@ static my_string NEAR_F expand_tilde(my_string *path)
 {
   if (path[0][0] == FN_LIBCHAR)
     return home_dir;			/* ~/ expanded to home */
-#ifdef HAVE_GETPWNAM
+#if defined(HAVE_GETPWNAM) && defined(HAVE_GETPWENT)
   {
     char *str,save;
     struct passwd *user_entry;
END
popd
elif [ 1 == 1 ]; then
{ patch -p1 -Nt || true; } <<'END'
diff --git a/cmake/CheckIncludeFiles.cmake b/cmake/CheckIncludeFiles.cmake
index ffb0e01..11b24af 100644
--- a/cmake/CheckIncludeFiles.cmake
+++ b/cmake/CheckIncludeFiles.cmake
@@ -46,4 +46,4 @@ CHECK_INCLUDE_FILES (sys/types.h HAVE_SYS_TYPES_H)
 CHECK_INCLUDE_FILES (sys/un.h HAVE_SYS_UN_H)
 CHECK_INCLUDE_FILES (unistd.h HAVE_UNISTD_H)
 CHECK_INCLUDE_FILES (utime.h HAVE_UTIME_H)
-CHECK_INCLUDE_FILES (ucontext.h HAVE_UCONTEXT_H)
+#CHECK_INCLUDE_FILES (ucontext.h HAVE_UCONTEXT_H)
END
fi
rm -rf build
mkdir build
pushd build
if [ $CLEAN == 1 ]; then
	make distclean || true
fi
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR \
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DCMAKE_PREFIX_PATH=$INSTALLROOT		\
      -DXCMAKE_LIBRARY_PATH=$INSTALLROOT/lib	\
      -DXCMAKE_INCLUDE_PATH=$INSTALLROOT/include	\
      -DANDROID_NDK=$ANDROID_NDK		\
      -DANDROID_TOOLCHAIN="clang"		\
      -DCMAKE_BUILD_TYPE=Release                \
      -DBUILD_SHARED_LIBS=ON                    \
      -DANDROID_ABI="$ARMEABI"                  \
      -DANDROID_NATIVE_API_LEVEL="$ANDROID_NATIVE_API_LEVEL"  \
      -DWITH_EXTERNAL_ZLIB:BOOL=ON              \
      -DWITH_SSL:BOOL=OFF			\
      -DOPENSSL_INCLUDE_DIR=$INSTALLROOT/include	\
      -DOPENSSL_LIB_DIR=$INSTALLROOT/lib	\
      -DSSL_LIBRARIES:=$INSTALLROOT/lib/libssl.a	\
      -DCMAKE_CXX_FLAGS="-Dushort=uint16_t -isystem $INSTALLROOT/include" \
      -DCMAKE_C_FLAGS="-Dushort=uint16_t -isystem $INSTALLROOT/include" \
      -DCMAKE_PREFIX_PATH="$INSTALLROOT" \
      -DCMAKE_MAKE_PROGRAM=make \
      -DICONV_EXTERNAL:BOOL=ON \
      -DICONV_LIBRARIES:PATH=$INSTALLROOT/lib/libiconv.a \
      -DICONV_INCLUDE_DIR:PATH=$INSTALLROOT/include \
      -DWITH_OPENSSL:BOOL=OFF                   \
      -DICONV_LIBRARY=$INSTALLROOT/lib/libiconv.a \
      .. && \
      make VERBOSE=1 libmariadb && \
      cmake --build ./libmariadb -j$NCPUS --target install && \
      cmake --build ./include -j$NCPUS --target install
      ERR=$?

      #cp "$INSTALLROOT"/lib/mariadb/lib{mariadb,mysql}client.a

popd
popd
return $ERR
}

build_lame() {
rm -rf build
LAME=lame-3.99.5
echo -e "\n**** $LAME ****"
setup_lib https://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz $LAME
pushd $LAME
OPATH=$PATH
#PATH=$CROSSPATH:$PATH
#CPPFLAGS="-isysroot $SYSROOT"
{ patch -p1 -Nt -r - || true; } <<'END'
diff --git a/config.sub b/config.sub
index 9d7f733..55bee46 100755
--- a/config.sub
+++ b/config.sub
@@ -228,7 +228,7 @@ case $basic_machine in
 	| a29k \
 	| alpha | alphaev[4-8] | alphaev56 | alphaev6[78] | alphapca5[67] \
 	| alpha64 | alpha64ev[4-8] | alpha64ev56 | alpha64ev6[78] | alpha64pca5[67] \
-	| arc | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr \
+	| arc | aarch | aarch64 | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr \
 	| c4x | clipper \
 	| d10v | d30v | dlx | dsp16xx \
 	| fr30 | frv \
@@ -293,7 +293,7 @@ case $basic_machine in
 	| alpha-* | alphaev[4-8]-* | alphaev56-* | alphaev6[78]-* \
 	| alpha64-* | alpha64ev[4-8]-* | alpha64ev56-* | alpha64ev6[78]-* \
 	| alphapca5[67]-* | alpha64pca5[67]-* | amd64-* | arc-* \
-	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* \
+	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* | aarch64-* \
 	| avr-* \
 	| bs2000-* \
 	| c[123]* | c30-* | [cjt]90-* | c4x-* | c54x-* | c55x-* | c6x-* \
@@ -1252,6 +1252,9 @@ case $os in
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
if [ $CLEAN == 1 ]; then
	make distclean || true
fi
	#--host=arm-linux-androideabi
local CPUOPT=
if [ $ARM64 == 1 ]; then
	CPUOPT="-mcpu=$CPU"
fi
./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT" \
	CC="${CROSSPATH3}clang" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static \
	--disable-frontend &&
make -j$NCPUS &&
make install
ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_exiv2() {
rm -rf build
#EXIV2=exiv2-0.27.1
EXIV2=exiv2-0.25
echo -e "\n**** $EXIV2 ****"
#EXIV2="$EXIV2-Source"
setup_lib http://www.exiv2.org/releases/$EXIV2.tar.gz $EXIV2
pushd $EXIV2
OPATH=$PATH
{ patch -p1 -Nt || true; } <<'END'
diff --git a/config/config.sub b/config/config.sub
index 320e303..4b80d8d 100755
--- a/config/config.sub
+++ b/config/config.sub
@@ -250,7 +250,7 @@ case $basic_machine in
 	| alpha | alphaev[4-8] | alphaev56 | alphaev6[78] | alphapca5[67] \
 	| alpha64 | alpha64ev[4-8] | alpha64ev56 | alpha64ev6[78] | alpha64pca5[67] \
 	| am33_2.0 \
-	| arc | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr | avr32 \
+	| arc | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr | avr32 | aarch64 \
 	| bfin \
 	| c4x | clipper \
 	| d10v | d30v | dlx | dsp16xx \
@@ -342,7 +342,7 @@ case $basic_machine in
 	| alpha-* | alphaev[4-8]-* | alphaev56-* | alphaev6[78]-* \
 	| alpha64-* | alpha64ev[4-8]-* | alpha64ev56-* | alpha64ev6[78]-* \
 	| alphapca5[67]-* | alpha64pca5[67]-* | arc-* \
-	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* \
+	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* | aarch64 \
 	| avr-* | avr32-* \
 	| bfin-* | bs2000-* \
 	| c[123]* | c30-* | [cjt]90-* | c4x-* \
diff --git a/configure b/configure
index 5c74e31..21a0e7a 100755
--- a/configure
+++ b/configure
@@ -15104,8 +15104,8 @@ linux* | k*bsd*-gnu)
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
if [ $CLEAN == 1 ]; then
	#rm -rf build
	#mkdir build
	make distclean || true
fi
local CPUOPT=
CPUOPT="-march=$CPU_ARCH"
./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	LDFLAGS="-lz" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--disable-xmp \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_exiv2_git() {
rm -rf build
EXIV2=exiv2-git
echo -e "\n**** $EXIV2 ****"
if [[ ! -d "$EXIV2" ]] ; then
    git clone https://github.com/Exiv2/exiv2.git exiv2-git
    pushd $EXIV2
    git reset --hard 449821cd5d
    popd
fi
pushd $EXIV2
OPATH=$PATH
{ patch -p1 -Nt -r - || true; } <<'END'
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index efabea7e..4ad7034a 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -125,8 +125,8 @@ if (${CMAKE_CXX_COMPILER_ID} STREQUAL GNU)
 endif()
 
 set_target_properties( exiv2lib PROPERTIES
-    VERSION       ${PROJECT_VERSION}
-    SOVERSION     ${PROJECT_VERSION_MINOR}
+    VVERSION      14.0
+    SSOVERSION    14
     OUTPUT_NAME   exiv2
     PDB_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
     COMPILE_FLAGS ${EXTRA_COMPILE_FLAGS}
END
if [ $CLEAN == 1 ]; then
	rm -rf build
	mkdir build
fi
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DANDROID_NDK=$ANDROID_NDK \
      -DANDROID_TOOLCHAIN="clang" \
      -DANDROID_ABI="$ARMEABI" \
      -DANDROID_NATIVE_API_LEVEL="$ANDROID_NATIVE_API_LEVEL"  \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=make \
      -DCMAKE_PREFIX_PATH="$INSTALLROOT" \
      -DCMAKE_INCLUDE_PATH="$INSTALLROOT/include" \
      -DCMAKE_LIBRARY_PATH="$INSTALLROOT/lib" \
      -DIconv_INCLUDE_DIR="$INSTALLROOT/include" \
      -DIconv_LIBRARY="$INSTALLROOT/lib/libiconv.a" \
      -DBUILD_SHARED_LIBS=ON \
      -DEXIV2_ENABLE_XMP=OFF \
      -DEXIV2_BUILD_SAMPLES=OFF \
      -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
      .. && \
      sed -i.bak -e 's/-static-libstdc++//;s/ [^ ]*libc\.a//' src/CMakeFiles/exiv2lib.dir/link.txt && \
      cmake --build . -j$NCPUS && \
      cmake --build . --target install
      ERR=$?
mv -f ${INSTALLROOT}/lib/libexiv2.so ${INSTALLROOT}/lib/libexiv2.14.so
(cd ${INSTALLROOT}/lib; ln -sf libexiv2.14.so libexiv2.so)
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_flac() {
rm -rf build
FLAC=flac-1.3.4
echo -e "\n**** $FLAC ****"
setup_lib https://ftp.osuosl.org/pub/xiph/releases/flac/$FLAC.tar.xz $FLAC
pushd $FLAC
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
CPUOPT="-march=$CPU_ARCH -fPIC"

./configure --help
./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--with-sysroot=$INSTALLROOT \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -C src/libFLAC -j$NCPUS &&
	make -C include install &&
	make -C src/libFLAC install
	ERR=$?

	# --with-ogg-libraries=$INSTALLROOT/lib \

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_ogg() {
rm -rf build
LIBOGG=libogg-1.3.5
echo -e "\n**** $LIBOGG ****"
setup_lib https://ftp.osuosl.org/pub/xiph/releases/ogg/$LIBOGG.tar.xz $OGG
pushd $LIBOGG
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
if [ $ARM64 == 1 ]; then
	CPUOPT="-march=$CPU_ARCH"
else
	CPUOPT="-march=$CPU_ARCH -fPIC"
fi

./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_vorbis() {
rm -rf build
LIBVORBIS=libvorbis-1.3.7
echo -e "\n**** $LIBVORBIS ****"
setup_lib https://ftp.osuosl.org/pub/xiph/releases/vorbis/$LIBVORBIS.tar.xz $LIBVORBIS
pushd $LIBVORBIS
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
if [ $ARM64 == 1 ]; then
	CPUOPT="-march=$CPU_ARCH"
else
	CPUOPT="-march=$CPU_ARCH"
fi

./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libxml2() {
rm -rf build
LIBXML2=libxml2-2.9.10
echo -e "\n**** $LIBXML2 ****"
setup_lib ftp://xmlsoft.org/libxml2/$LIBXML2.tar.gz $LIBXML2
pushd $LIBXML2
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
if [ $ARM64 == 1 ]; then
	CPUOPT="-march=$CPU_ARCH"
else
	CPUOPT="-march=$CPU_ARCH -fPIC"
fi
echo $INSTALLROOT
./configure \
	CFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
	LDFLAGS="-L$INSTALLROOT/lib $OPTS -pie -Wl,-rpath-link=$SYSROOT/usr/lib -Wl,-rpath-link=$SYSROOTARCH/usr/lib -Wl,-rpath-link=$INSTALLROOT/lib" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--disable-xmp \
	--without-iconv \
	--without-icu \
	--without-python \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS VERBOSE=1 &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_glib() {
# not used for all
rm -rf build
GLIB_VERSION=2.54
GLIB=glib-$GLIB_VERSION.0
echo -e "\n**** $GLIB ****"
setup_lib https://ftp.gnome.org/pub/gnome/sources/glib/$GLIB_VERSION/$GLIB.tar.xz $GLIB
pushd $GLIB
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
LDFLAGS="-L $INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-sysroot=$SYSROOT \
	--disable-dependency-tracking \
	--without-crypto \
	--disable-libmount \
	--with-pcre=no \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

#CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
#CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
#RANLIB=${CROSSPATH_LLVM}ranlib \
#OBJDUMP=${CROSSPATH_LLVM}objdump \
#AR=${CROSSPATH_LLVM}ar \
#LD=$CROSSPATH/$MY_ANDROID_NDK_TOOLS_PREFIX-ld \
#CC="$CROSSPATH/$MY_ANDROID_NDK_TOOLS_PREFIX-gcc" \
#CXX="$CROSSPATH/$MY_ANDROID_NDK_TOOLS_PREFIX-g++" \
#CPP="$CROSSPATH/$MY_ANDROID_NDK_TOOLS_PREFIX-cpp" \

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_ffi() {
# not used for all
rm -rf build
FFI_VERSION=3.3
FFI=libffi-$FFI_VERSION
echo -e "\n**** $FFI ****"
setup_lib ftp://sourceware.org/pub/libffi/$FFI.tar.gz
pushd $FFI
OPATH=$PATH
PATH=$CROSSPATH:$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
LDFLAGS="-L $INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
autoreconf --force --install --verbose &&
./configure \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--with-sysroot=$SYSROOT \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install includesdir=$INSTALLDIR/include
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_gettext() {
# not used for all
rm -rf build
GETTEXT_VERSION=0.19.8
GETTEXT=gettext-$GETTEXT_VERSION
echo -e "\n**** $GETTEXT ****"
setup_lib http://ftp.gnu.org/pub/gnu/gettext/$GETTEXT.tar.xz
pushd $GETTEXT
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF -isystem $INSTALLROOT/include" \
CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF -isystem $INSTALLROOT/include" \
LDFLAGS="-L$INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--with-sysroot=$SYSROOT \
	--prefix=$INSTALLROOT \
	--disable-rpath \
	--disable-libasprintf \
	--disable-java \
	--disable-native-java \
	--disable-openmp \
	--disable-curses \
	--disable-csharp \
	--disable-nls \
	--enable-shared \
	--enable-static \
	&&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libxslt() {
# not used for all
rm -rf build
LIBXSLT=libxslt-1.1.30
echo -e "\n**** $LIBXSLT ****"
setup_lib ftp://xmlsoft.org/libxslt/$LIBXSLT.tar.gz $LIBXSLT
pushd $LIBXSLT
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
CPUOPT="-march=$CPU_ARCH"
./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-libxml-prefix=$INSTALLROOT \
	--disable-xmp \
	--without-python \
	--without-crypto \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_fontconfig() {
rm -rf build
# note later versions require freetype2 update
FONTCONFIG_VERSION=2.13.96
FONTCONFIG=fontconfig-$FONTCONFIG_VERSION
echo -e "\n**** $FONTCONFIG ****"
#setup_lib https://github.com/freedesktop/fontconfig/archive/$FONTCONFIG_VERSION.tar.gz $FONTCONFIG
setup_lib https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/$FONTCONFIG_VERSION/fontconfig-$FONTCONFIG_VERSION.tar.bz2
pushd $FONTCONFIG
OPATH=$PATH

if [ -e "$BASE"/patches/${FONTCONFIG}.patch ]; then
	patch -p1 -Nt --no-backup-if-mismatch -r - < "$BASE"/patches/${FONTCONFIG}.patch || true
else
{ patch -p1 -Nt || true; } <<'END'
diff --git a/src/fcatomic.c b/src/fcatomic.c
index 2ce419f..d12d324 100644
--- a/src/fcatomic.c
+++ b/src/fcatomic.c
@@ -131,7 +131,7 @@ FcAtomicLock (FcAtomic *atomic)
 	return FcFalse;
     }
     ret = link ((char *) atomic->tmp, (char *) atomic->lck);
-    if (ret < 0 && (errno == EPERM || errno == ENOTSUP))
+    if (ret < 0 && (errno == EPERM || errno == ENOTSUP || errno == EACCES))
     {
 	/* the filesystem where atomic->lck points to may not supports
 	 * the hard link. so better try to fallback
diff --git a/src/fcobjs.c b/src/fcobjs.c
index 16ff31c..d8bf79d 100644
--- a/src/fcobjs.c
+++ b/src/fcobjs.c
@@ -25,10 +25,10 @@
 #include "fcint.h"
 
 static unsigned int
-FcObjectTypeHash (register const char *str, register unsigned int len);
+FcObjectTypeHash (register const char *str, register size_t len);
 
 static const struct FcObjectTypeInfo *
-FcObjectTypeLookup (register const char *str, register unsigned int len);
+FcObjectTypeLookup (register const char *str, register size_t len);
 
 #include "fcobjshash.h"
 
diff --git a/src/fcstr.c b/src/fcstr.c
index b65492d..600e42e 100644
--- a/src/fcstr.c
+++ b/src/fcstr.c
@@ -908,11 +908,13 @@ FcStrBuildFilename (const FcChar8 *path,
     p = ret;
     while ((s = FcStrListNext (list)))
     {
-	if (p != ret)
+	if (p != ret && p[-1] != FC_DIR_SEPARATOR)
 	{
 	    p[0] = FC_DIR_SEPARATOR;
 	    p++;
 	}
+	if (p != ret && p[-1] == FC_DIR_SEPARATOR && s[0] == FC_DIR_SEPARATOR)
+	    s++;
 	len = strlen ((const char *)s);
 	memcpy (p, s, len);
 	p += len;
END
fi

if [ $CLEAN == 1 ]; then
	# move generated fcblanks.h aside before clean
	# so unicode.org does not have to be spammed
	# as it looks like it has a DOS filter
	mv fc-blanks/fcblanks.h{,.1} || true
	make distclean || true
	mv fc-blanks/fcblanks.h{.1,} || true
fi

local OPTS=
if [ $ARM64 == 1 ]; then
	OPTS="-fPIE"
else
	OPTS="-fPIC"
fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT $CPUOPT $OPTS $ANDROID_API_DEF -DFONTCONFIG_FILE=\\\"~/fonts.conf\\\"" \
CXXFLAGS="-isysroot $SYSROOT $CPUOPT $OPTS $ANDROID_API_DEF -DFONTCONFIG_FILE=\\\"~/fonts.conf\\\"" \
LDFLAGS="-L$INSTALLROOT/lib $OPTS -pie -Wl,-rpath-link=$SYSROOT/usr/lib -Wl,-rpath-link=$SYSROOTARCH/usr/lib -Wl,-rpath-link=$INSTALLROOT/lib -llog" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./autogen.sh \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-gnu-ld=yes \
	--disable-docs \
	--disable-dependency-tracking \
	--enable-libxml2 \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd

# install our fonts.conf
mkdir -p $INSTALLROOT/assets/mythtv
cp $INSTALLROOT/../android-package-source/fonts.conf $INSTALLROOT/assets/mythtv

return $ERR
}

build_fribidi() {
rm -rf build
FRIBIDI_VERSION=1.0.8
FRIBIDI=fribidi-$FRIBIDI_VERSION
echo -e "\n**** $FRIBIDI ****"
setup_lib https://github.com/fribidi/fribidi/releases/download/v$FRIBIDI_VERSION/$FRIBIDI.tar.bz2 $FRIBIDI
pushd $FRIBIDI
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
LDFLAGS="-L$INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-sysroot=$SYSROOT \
	--disable-dependency-tracking \
	--without-crypto \
	--disable-libmount \
	--with-pcre=no \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_harfbuzz() {
rm -rf build
HARFBUZZ_VERSION=5.3.1
HARFBUZZ=harfbuzz-$HARFBUZZ_VERSION
echo -e "\n**** $HARFBUZZ ****"
setup_lib https://github.com/harfbuzz/harfbuzz/releases/download/$HARFBUZZ_VERSION/$HARFBUZZ.tar.xz $HARFBUZZ
pushd $HARFBUZZ
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
CXXFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
LDFLAGS="-L$INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-sysroot=$SYSROOT \
	--disable-dependency-tracking \
	--disable-require-system-font-provider \
	--enable-shared \
	--enable-static &&
	cd src &&
	make -j$NCPUS lib &&
	make install-libLTLIBRARIES install-pkgincludeHEADERS install-pkgconfigDATA
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_ass() {
rm -rf build
LIBASS_VERSION=0.17.0
LIBASS=libass-$LIBASS_VERSION
echo -e "\n**** $LIBASS ****"
setup_lib https://github.com/libass/libass/releases/download/$LIBASS_VERSION/$LIBASS.tar.xz $LIBASS
pushd $LIBASS
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	make distclean || true
fi

#local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
#./autogen.sh &&
PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
CFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
CXXFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
LDFLAGS="-L$INSTALLROOT/lib" \
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--build=x86_64-linux-gnu \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--disable-dependency-tracking \
	--disable-require-system-font-provider \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_android_external_liblzo() {
# not used for all
LIBLZO=lzo-2.10
echo -e "\n**** $LIBLZO ****"
rm -rf build
setup_lib http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz $LIBLZO
pushd $LIBLZO
OPATH=$PATH
#{ patch -p0 -Nt || true; } <<'END'
#--- autoconf/config.sub.orig	2015-02-15 16:07:07.005411976 +1100
#+++ autoconf/config.sub	2015-02-15 16:07:35.378208159 +1100
#@@ -1399,6 +1399,9 @@
# 	-dicos*)
# 		os=-dicos
# 		;;
#+	-android*)
#+		os=-android
#+		;;
# 	-none)
# 		;;
# 	*)
#END
export PATH="$PATH:$CROSSPATH"
RANLIB=${CROSSPATH_LLVM}ranlib \
OBJDUMP=${CROSSPATH_LLVM}objdump \
AR=${CROSSPATH_LLVM}ar \
LD=${CROSSPATH_LD}ld \
CC="${CROSSPATH3}clang" \
CXX="${CROSSPATH3}clang++" \
./configure \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static && \
make clean && \
CFLAGS="-isysroot $SYSROOT -mcpu=$CPU" \
CXXFLAGS="-isysroot $SYSROOT -mcpu=$CPU" \
make -j$NCPUS src/liblzo2.la && \
make install-libLTLIBRARIES install-data-am
ERR=$?
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libzip() {
rm -rf build
LIBZIP_VERSION=1.8.0
LIBZIP=libzip-$LIBZIP_VERSION
echo -e "\n**** $LIBZIP ****"
setup_lib https://libzip.org/download/libzip-$LIBZIP_VERSION.tar.gz $LIBZIP
pushd $LIBZIP
OPATH=$PATH

if [ $CLEAN == 1 ]; then
	rm -rf build
	mkdir build
fi
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
      -DANDROID_NDK=$ANDROID_NDK \
      -DANDROID_TOOLCHAIN="clang" \
      -DANDROID_ABI="$ARMEABI" \
      -DANDROID_NATIVE_API_LEVEL="$ANDROID_NATIVE_API_LEVEL"  \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=make \
      -DCMAKE_PREFIX_PATH="$INSTALLROOT" \
      -DBUILD_SHARED_LIBS=ON \
      .. && \
      cmake --build . -j$NCPUS && \
      cmake --build . --target install
      ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_icu() {
rm -rf build
#echo -e "\n**** icu 65.1 ****"
#setup_lib https://github.com/unicode-org/icu/releases/download/release-65-1/icu4c-65_1-src.tgz icu
echo -e "\n**** icu 70.1 ****"
setup_lib https://github.com/unicode-org/icu/releases/download/release-70-1/icu4c-70_1-src.tgz icu
pushd icu
OPATH=$PATH
ICUPATH=$PWD
ICU_FLAGS="-I$ICU_PATH/source/common/ -I$ICU_PATH/source/tools/tzcode/"
{ patch -p1 -Nt || true; } <<'END'
diff --git a/source/config/mh-linux b/source/config/mh-linux
index 53d6780..c8ed9f8 100644
--- a/source/config/mh-linux
+++ b/source/config/mh-linux
@@ -39,6 +39,10 @@ SO = so
 ## Non-shared intermediate object suffix
 STATIC_O = ao
 
+## Versioned target for a shared library.
+FINAL_SO_TARGET=  $(basename $(SO_TARGET))$(SO_TARGET_VERSION).$(SO)
+MIDDLE_SO_TARGET= $(basename $(SO_TARGET))$(SO_TARGET_VERSION_MAJOR).$(SO)
+
 ## Compilation rules
 %.$(STATIC_O): $(srcdir)/%.c
 	$(call SILENT_COMPILE,$(strip $(COMPILE.c) $(STATICCPPFLAGS) $(STATICCFLAGS)) -o $@ $<)
@@ -66,10 +70,10 @@ STATIC_O = ao
 
 ## Versioned libraries rules
 
-%.$(SO).$(SO_TARGET_VERSION_MAJOR): %.$(SO).$(SO_TARGET_VERSION)
-	$(RM) $@ && ln -s ${<F} $@
-%.$(SO): %.$(SO).$(SO_TARGET_VERSION_MAJOR)
-	$(RM) $@ && ln -s ${*F}.$(SO).$(SO_TARGET_VERSION) $@
+%$(SO_TARGET_VERSION_MAJOR).$(SO): %$(SO_TARGET_VERSION).$(SO)
+	$(RM) $@ && ln -s ${*F}$(SO_TARGET_VERSION).$(SO) $@
+%.$(SO): %$(SO_TARGET_VERSION).$(SO)
+	$(RM) $@ && ln -s ${*F}$(SO_TARGET_VERSION).$(SO) $@
 
 ##  Bind internal references
 
diff --git a/source/configure b/source/configure
index 36c06f9..aff20fe 100755
--- a/source/configure
+++ b/source/configure
@@ -4183,7 +4183,7 @@ fi
 #AC_CHECK_PROG(STRIP, strip, strip, true)
 
 # Check for the platform make
-for ac_prog in gmake gnumake
+for ac_prog in gmake gnumake make
 do
   # Extract the first word of "\$ac_prog", so it can be a program name with args.
 set dummy \$ac_prog; ac_word=\$2
@@ -7113,8 +7113,8 @@ fi
 
 
     if test "$ac_cv_header_xlocale_h" = yes; then
-      U_HAVE_XLOCALE_H=1
-      CONFIG_CPPFLAGS="${CONFIG_CPPFLAGS} -DU_HAVE_STRTOD_L=1 -DU_HAVE_XLOCALE_H=1"
+      U_HAVE_XLOCALE_H=0
+      CONFIG_CPPFLAGS="${CONFIG_CPPFLAGS} -DU_HAVE_STRTOD_L=1 -DU_HAVE_XLOCALE_H=0"
     else
       U_HAVE_XLOCALE_H=0
       CONFIG_CPPFLAGS="${CONFIG_CPPFLAGS} -DU_HAVE_STRTOD_L=1 -DU_HAVE_XLOCALE_H=0"
diff --git a/source/i18n/number_decimalquantity.cpp b/source/i18n/number_decimalquantity.cpp
index 7246357..15cd0cc 100644
--- a/source/i18n/number_decimalquantity.cpp
+++ b/source/i18n/number_decimalquantity.cpp
@@ -384,7 +384,7 @@ void DecimalQuantity::_setToDoubleFast(double n) {
         for (; i <= -22; i += 22) n /= 1e22;
         n /= DOUBLE_MULTIPLIERS[-i];
     }
-    auto result = static_cast<int64_t>(std::round(n));
+    auto result = static_cast<int64_t>(round(n));
     if (result != 0) {
         _setToLong(result);
         scale -= fracLength;
END

unset CPPFLAGS
unset LDFLAGS
unset CXXPPFLAGS

if [ $CLEAN == 1 ]; then
	test -d buildA && rm -rf buildA
	test -d buildB && rm -rf buildB
fi
mkdir buildA || true
mkdir buildB || true
pushd buildA
echo "**** Build ICU A ****"
../source/configure && \
make clean && \
make -j$NCPUS
ERR=$?

popd

[ "$ERR" == 0 ] || return $ERR

PATH=$CROSSPATH:$PATH
pushd buildB
echo "**** Build ICU B ****"
mkdir config || true
touch config/icucross.mk
touch config/icucross.inc
#../source/configure --help
../source/configure \
	CFLAGS="-mtune=$CPU -march=$CPU_ARCH -isysroot $SYSROOT" \
	CXXFLAGS="-mtune=$CPU -march=$CPU_ARCH --std=c++11 -isysroot $SYSROOT" \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--with-cross-build=$ICUPATH/buildA \
	--with-data-packaging=static \
	--prefix=$INSTALLROOT \
	--disable-extras \
	--disable-tools \
	--disable-tests \
	--disable-samples \
	--enable-shared \
	--enable-static
ERR=$?

[ "$ERR" == 0 ] && \
make clean && \
make -j$NCPUS &&\
make install && \
true
ERR=$?
popd

echo "*** Build ICU Done ***"
PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libsamplerate() {
rm -rf build
LIBSAMPLERATE_VERSION=0.2.2
LIBSAMPLERATE=libsamplerate-$LIBSAMPLERATE_VERSION
echo -e "\n**** $LIBSAMPLRATE ****"
#setup_lib http://www.mega-nerd.com/SRC/$LIBSAMPLERATE.tar.gz $LIBSAMPLERATE
setup_lib https://github.com/libsndfile/libsamplerate/releases/download/$LIBSAMPLERATE_VERSION/$LIBSAMPLERATE.tar.xz $LIBSAMPLERATE
pushd $LIBSAMPLERATE
OPATH=$PATH
{ patch -p0 -Nt -r - || true; } <<'END'
--- Cfg/config.sub~	2010-03-16 10:26:14.000000000 -0400
+++ Cfg/config.sub	2018-06-23 13:48:22.051866123 -0400
@@ -242,7 +242,7 @@
 	| alpha | alphaev[4-8] | alphaev56 | alphaev6[78] | alphapca5[67] \
 	| alpha64 | alpha64ev[4-8] | alpha64ev56 | alpha64ev6[78] | alpha64pca5[67] \
 	| am33_2.0 \
-	| arc | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr | avr32 \
+	| arc | aarch | aarch64 | arm | arm[bl]e | arme[lb] | armv[2345] | armv[345][lb] | avr | avr32 \
 	| bfin \
 	| c4x | clipper \
 	| d10v | d30v | dlx | dsp16xx \
@@ -322,7 +322,7 @@
 	| alpha-* | alphaev[4-8]-* | alphaev56-* | alphaev6[78]-* \
 	| alpha64-* | alpha64ev[4-8]-* | alpha64ev56-* | alpha64ev6[78]-* \
 	| alphapca5[67]-* | alpha64pca5[67]-* | arc-* \
-	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* \
+	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* | aarch64-* \
 	| avr-* | avr32-* \
 	| bfin-* | bs2000-* \
 	| c[123]* | c30-* | [cjt]90-* | c4x-* | c54x-* | c55x-* | c6x-* \
@@ -1407,6 +1407,9 @@
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
if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	LD=${CROSSPATH_LD}ld \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libsoundtouch() {
rm -rf build
#LIBSOUNDTOUCH=soundtouch-2.3.1-e1f315f5358d9db5cee35a7a2886425489fcefe8
#LIBSOUNDTOUCH_URL https://gitlab.com/soundtouch/soundtouch/-/archive/2.3.1/$LIBSOUNDTOUCH.tar.gz $LIBSOUNDTOUCH
LIBSOUNDTOUCH=soundtouch
LIBSOUNDTOUCH_VERSION=2.3.1
LIBSOUNDTOUCH_URL="https://codeberg.org/soundtouch/soundtouch/archive/$LIBSOUNDTOUCH_VERSION.tar.gz"
echo -e "\n**** $LIBSOUNDTOUCH $LIBSOUNDTOUCH_VERSION ****"
setup_lib $LIBSOUNDTOUCH_URL $LIBSOUNDTOUCH
pushd $LIBSOUNDTOUCH
OPATH=$PATH
{ patch -p1 -Nt -r - || true; } <<'END'
diff --git a/bootstrap b/bootstrap
index 7534e44..2ee0915 100755
--- a/bootstrap
+++ b/bootstrap
@@ -4,14 +4,14 @@ unset ACLOCAL
 
 if [ "$1" = "--clean" ]
 then
-       if [ -a Makefile ]
+       if [ -f Makefile ]
        then
                make maintainer-clean
-       elif [ -a configure ]
+       elif [ -f configure ]
        then
-               configure && $0 --clean
+               ./configure && $0 --clean
        else 
-               bootstrap && configure && $0 --clean
+               ./bootstrap && ./configure && $0 --clean
        fi
 
 	rm -rf configure libtool aclocal.m4 `find . -name Makefile.in` autom4te*.cache config/config.guess config/config.h.in config/config.sub config/depcomp config/install-sh config/ltmain.sh config/missing config/mkinstalldirs config/stamp-h config/stamp-h.in
diff --git a/configure.ac b/configure.ac
index d557fb6..497fa6d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -258,7 +258,7 @@ AC_FUNC_MALLOC
 AC_TYPE_SIGNAL
 
 dnl make -lm get added to the LIBS
-AC_CHECK_LIB(m, sqrt,,AC_MSG_ERROR([compatible libc math library not found])) 
+#AC_CHECK_LIB(m, sqrt,,AC_MSG_ERROR([compatible libc math library not found])) 
 
 dnl add whatever functions you might want to check for here
 #AC_CHECK_FUNCS([floor ftruncate memmove memset mkdir modf pow realpath sqrt strchr strdup strerror strrchr strstr strtol])
END
if [ $CLEAN == 1 ]; then
	./bootstrap --clean || true
fi

LOPTS="-fPIC"
./bootstrap && ./configure \
	CFLAGS="-isysroot $SYSROOT $ANDROID_API_DEF $LOPTS" \
	CXXFLAGS="-isysroot $SYSROOT $ANDROID_API_DEF $LOPTS" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	LD=${CROSSPATH_LD}ld \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_libbluray() {
rm -rf build
LIBBLURAYVER=1.3.4
LIBBLURAY=libbluray-$LIBBLURAYVER
echo -e "\n**** $LIBBLURAY ****"
setup_lib ftp://ftp.videolan.org/pub/videolan/libbluray/$LIBBLURAYVER/$LIBBLURAY.tar.bz2 $LIBBLURAY
pushd $LIBBLURAY
OPATH=$PATH
if [ $CLEAN == 1 ]; then
	make distclean || true
fi

local CPUOPT=
#if [ $ARM64 == 1 ]; then
#	CPUOPT="-march=$CPU_ARCH"
#else
#	CPUOPT="-march=$CPU_ARCH"
#fi
./configure \
	CFLAGS="-isysroot $SYSROOT -isystem $INSTALLROOT/include $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	LD=${CROSSPATH_LD}ld \
	LDFLAGS="-L$INSTALLROOT/lib" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
        --without-fontconfig \
        --disable-silent-rules \
        --disable-examples \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

build_fftw() {
rm -rf build
FFTWVER=3.3.8
FFTW=fftw-$FFTWVER
echo -e "\n**** $FFTW ****"
setup_lib http://www.fftw.org/$FFTW.tar.gz $FFTW
pushd $FFTW
OPATH=$PATH
if [ $CLEAN == 1 ]; then
	make distclean || true
fi

./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	LD=${CROSSPATH_LD}ld \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-fontconfig \
	--disable-silent-rules \
	--disable-examples \
	--enable-threads \
	--disable-single \
	--enable-neon \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

./configure \
	CFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	CXXFLAGS="-isysroot $SYSROOT $CPUOPT $ANDROID_API_DEF" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	OBJDUMP=${CROSSPATH_LLVM}objdump \
	AR=${CROSSPATH_LLVM}ar \
	LD=${CROSSPATH_LD}ld \
	CC="${CROSSPATH3}clang" \
	CXX="${CROSSPATH3}clang++" \
	PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR/pkgconfig \
	--host=$MY_ANDROID_NDK_TOOLS_PREFIX \
	--prefix=$INSTALLROOT \
	--with-fontconfig \
	--disable-silent-rules \
	--disable-examples \
	--enable-threads \
	--enable-single \
	--enable-neon \
	--enable-shared \
	--enable-static &&
	make -j$NCPUS &&
	make install
	ERR=$?

PATH=$OPATH
unset OPATH
popd
return $ERR
}

if [ $BUILD_NEWQTWEBKITONLY ]; then
	OS_WEBKIT=0
else
	OS_WEBKIT=1
fi

QT_SOURCE_DIR=qt-everywhere-opensource-src-$QTVERSION
if [ ${QTMAJORVERSION%.*} -ge 6 -o ${QTMAJORVERSION#*.} -gt 9 ]; then
	QT_SOURCE_DIR=qt-everywhere-src-$QTVERSION
fi
QT_URL=https://download.qt.io/archive/qt/$QTMAJORVERSION/$QTVERSION/single/$QT_SOURCE_DIR.tar.xz
if [ ${QTMAJORVERSION} == "5.15" -a ${QTMAJORVERSION%.*} -ge 3 ]; then
	# special case, mismatch of tarball and root directory names
	QT_DOWNLOAD_NAME=qt-everywhere-opensource-src-$QTVERSION
	QT_SOURCE_DIR=qt-everywhere-src-$QTVERSION
	QT_URL=https://download.qt.io/archive/qt/$QTMAJORVERSION/$QTVERSION/single/$QT_DOWNLOAD_NAME.tar.xz
fi
if [ $BUILD_WEBKIT == 1 ]; then
	if [ $OS_WEBKIT == 1 ]; then
		if [ $QTVERSION != "5.9.1" ]; then
			QTVERSION_WK=5.9.1
			QTMAJORVERSION_WK=5.9
			QT_WEBKIT_SOURCE_DIR=qtwebkit-opensource-src-$QTVERSION_WK
			QT_WEBKIT_URL=https://download.qt.io/archive/qt/$QTMAJORVERSION_WK/$QTVERSION_WK/submodules/$QT_WEBKIT_SOURCE_DIR.tar.xz
		else
			QTVERSION_WK=$QTVERSION
			QTMAJORVERSION_WK=$QTMAJORVERSION
			QT_WEBKIT_SOURCE_DIR=qtwebkit-opensource-src-$QTVERSION
			QT_WEBKIT_URL=https://download.qt.io/archive/qt/$QTMAJORVERSION/$QTVERSION/submodules/$QT_WEBKIT_SOURCE_DIR.tar.xz
		fi
	else
		QT_WEBKIT_SOURCE_DIR=qtwebkit-5.212.0-alpha2
		QT_WEBKIT_URL=https://github.com/annulen/webkit/releases/download/qtwebkit-5.212.0-alpha2/qtwebkit-5.212.0-alpha2.tar.xz
	#QT_WEBKIT_SOURCE_DIR=webkit-qtwebkit-5.212.0-alpha2
	#QT_WEBKIT_URL=https://github.com/annulen/webkit/archive/qtwebkit-5.212.0-alpha2.tar.gz
	fi
#QT_SOURCE_DIR=qt5
fi


patch_qt5() {
setup_lib $QT_URL $QT_SOURCE_DIR
if [ $BUILD_WEBKIT == 1 ]; then
	setup_lib $QT_WEBKIT_URL $QT_WEBKIT_SOURCE_DIR
fi

###################################################################
# Differences between qtwebkits
#
# qtwebkit-opensource-src-5.9.1/include/QtWebKit/qtwebkitversion.h
#
# @@ -2,8 +2,8 @@
#  #ifndef QT_QTWEBKIT_VERSION_H
#  #define QT_QTWEBKIT_VERSION_H
#   
# -#define QTWEBKIT_VERSION_STR "5.7.0"
# +#define QTWEBKIT_VERSION_STR "5.9.1"
#   
# -#define QTWEBKIT_VERSION 0x050700
# +#define QTWEBKIT_VERSION 0x050901
#   
#  #endif // QT_QTWEBKIT_VERSION_H
#
# +++ qtwebkit-opensource-src-5.9.1/include/QtWebKitWidgets/qtwebkitwidgetsversion.h      2017-06-29 09:41:51.000000000 +1000
# @@ -2,8 +2,8 @@
#  #ifndef QT_QTWEBKITWIDGETS_VERSION_H
#  #define QT_QTWEBKITWIDGETS_VERSION_H
#   
# -#define QTWEBKITWIDGETS_VERSION_STR "5.7.0"
# +#define QTWEBKITWIDGETS_VERSION_STR "5.9.1"
#   
# -#define QTWEBKITWIDGETS_VERSION 0x050700
# +#define QTWEBKITWIDGETS_VERSION 0x050901
#   
#  #endif // QT_QTWEBKITWIDGETS_VERSION_H
#
# +++ qtwebkit-opensource-src-5.9.1/.qmake.conf   2017-06-16 22:46:36.000000000 +1000
# @@ -3,4 +3,4 @@
#  QMAKEPATH += $$PWD/Tools/qmake $$MODULE_QMAKE_OUTDIR
#   load(qt_build_config)
#    
#  -MODULE_VERSION = 5.7.0
#  +MODULE_VERSION = 5.9.1
#
###################################################################

pushd $QT_SOURCE_DIR

if [ $BUILD_WEBKIT == 1 ]; then
	if [ $OS_WEBKIT == 1 ]; then
		ln -snf ../$QT_WEBKIT_SOURCE_DIR qtwebkit
	else
		rm qtwebkit || true
	fi
fi

if [ -e "$BASE"/patches/qt-${QTVERSION}.patch ]; then
	patch -p1 -Nt --no-backup-if-mismatch -r - < "$BASE"/patches/qt-${QTVERSION}.patch || true
if [ $BUILD_WEBKIT == 1 ]; then
{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/.gitmodules b/.gitmodules
index 7ff3013ee..2a048e0bd 100644
--- a/.gitmodules
+++ b/.gitmodules
@@ -323,4 +323,13 @@
 	path = qtquick3d
 	url = ../qtquick3d.git
 	branch = 5.14.0
-	status = preview
\ No newline at end of file
+	status = preview
+[submodule "qtwebkit"]
+	depends = qtbase
+	recommends = qtdeclarative qtlocation qtmultimedia qtsensors qtwebchannel qtxmlpatterns
+	path = qtwebkit
+	url = ../qtwebkit.git
+	branch = 5.9.1
+	status = obsolete
+	project = WebKit.pro
+	priority = 20
END
fi
elif [ ${QTVERSION} == "5.11.3" -o ${QTVERSION} == "5.12.0" ]; then
echo  5.11.3 patch is different enough to warrant its own section
{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/qtbase/mkspecs/common/android-base-head.conf b/qtbase/mkspecs/common/android-base-head.conf
index 9be6111..ebd3982 100644
--- a/qtbase/mkspecs/common/android-base-head.conf
+++ b/qtbase/mkspecs/common/android-base-head.conf
@@ -49,8 +49,9 @@ else: ANDROID_ARCHITECTURE = arm
 
 !equals(NDK_TOOLCHAIN_VERSION, 4.4.3): ANDROID_CXXSTL_SUFFIX = -$$NDK_TOOLCHAIN_VERSION
 
+NDK_TOOLCHAIN_PATH = $$(ANDROID_NDK_TOOLCHAIN_PATH)
 NDK_TOOLCHAIN = $$NDK_TOOLCHAIN_PREFIX-$$NDK_TOOLCHAIN_VERSION
-NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
+isEmpty(NDK_TOOLCHAIN_PATH): NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
 
 
 ANDROID_SDK_ROOT = $$(ANDROID_SDK_ROOT)
@@ -68,7 +69,8 @@ isEmpty(ANDROID_SDK_BUILD_TOOLS_REVISION) {
 CONFIG += $$ANDROID_PLATFORM
 QMAKE_CFLAGS = -D__ANDROID_API__=$$replace(ANDROID_PLATFORM, "android-", "")
 
-ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
+ANDROID_PLATFORM_ROOT_PATH = $$(ANDROID_NDK_PLATFORM_ROOT_PATH)
+isEmpty(ANDROID_PLATFORM_ROOT_PATH): ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
 ANDROID_PLATFORM_PATH  = $$ANDROID_PLATFORM_ROOT_PATH/usr
 
 equals(ANDROID_TARGET_ARCH, x86_64)|equals(ANDROID_TARGET_ARCH, mips64): \
diff --git a/qtbase/mkspecs/features/android/android.prf b/qtbase/mkspecs/features/android/android.prf
index 1dc8f87..e796f4a 100644
--- a/qtbase/mkspecs/features/android/android.prf
+++ b/qtbase/mkspecs/features/android/android.prf
@@ -4,11 +4,21 @@ contains(TEMPLATE, ".*app") {
         QMAKE_LFLAGS += -Wl,-soname,$$shell_quote($$TARGET)
 
         android_install {
-            target.path=/libs/$$ANDROID_TARGET_ARCH/
+            ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+            isEmpty(ANDROID_INSTALL_LIBS) {
+                target.path=/libs/$$ANDROID_TARGET_ARCH/
+            } else {
+                target.path=$$ANDROID_INSTALL_LIBS/
+            }
             INSTALLS *= target
         }
     }
 } else: contains(TEMPLATE, "lib"):!static:!QTDIR_build:android_install {
-    target.path = /libs/$$ANDROID_TARGET_ARCH/
+    ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+    isEmpty(ANDROID_INSTALL_LIBS) {
+        target.path=/libs/$$ANDROID_TARGET_ARCH/
+    } else {
+        target.path=$$ANDROID_INSTALL_LIBS/
+    }
     INSTALLS *= target
 }
diff --git a/qtbase/src/android/templates/build.gradle b/qtbase/src/android/templates/build.gradle
index 3a3e0cd..f98eed7 100644
--- a/qtbase/src/android/templates/build.gradle
+++ b/qtbase/src/android/templates/build.gradle
@@ -41,9 +41,12 @@ android {
     sourceSets {
         main {
             manifest.srcFile 'AndroidManifest.xml'
-            java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
-            aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
-            res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            //java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
+            java.srcDirs = ['src', 'java']
+            //aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
+            aidl.srcDirs = ['src', 'aidl']
+            //res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            res.srcDirs = ['res']
             resources.srcDirs = ['src']
             renderscript.srcDirs = ['src']
             assets.srcDirs = ['assets']
diff --git a/qtbase/src/tools/androiddeployqt/main.cpp b/qtbase/src/tools/androiddeployqt/main.cpp
index 918bc0f..d6bbf8a 100644
--- a/qtbase/src/tools/androiddeployqt/main.cpp
+++ b/qtbase/src/tools/androiddeployqt/main.cpp
@@ -984,8 +984,8 @@ bool copyAndroidTemplate(const Options &options)
     if (!copyAndroidTemplate(options, QLatin1String("/src/android/templates")))
         return false;
 
-    if (options.gradle)
-        return true;
+    //if (options.gradle)
+    //    return true;
 
     return copyAndroidTemplate(options, QLatin1String("/src/android/java"));
 }
diff --git a/qtbase/src/3rdparty/forkfd/forkfd.c b/qtbase/src/3rdparty/forkfd/forkfd.c
index 7f02ee9..74de1a7 100644
--- a/qtbase/src/3rdparty/forkfd/forkfd.c
+++ b/qtbase/src/3rdparty/forkfd/forkfd.c
@@ -45,8 +45,10 @@
 #include <time.h>
 #include <unistd.h>
 
-#ifdef __linux__
-#  define HAVE_WAIT4    1
+#if defined(__linux__)
+#  if __ANDROID_API__ > 19
+#    define HAVE_WAIT4    1
+#  endif
 #  if defined(__BIONIC__) || (defined(__GLIBC__) && (__GLIBC__ << 8) + __GLIBC_MINOR__ >= 0x208 && \
        (!defined(__UCLIBC__) || ((__UCLIBC_MAJOR__ << 16) + (__UCLIBC_MINOR__ << 8) + __UCLIBC_SUBLEVEL__ > 0x90201)))
 #    include <sys/eventfd.h>
END
elif [ ${QTMAJORVERSION%.*} -ge 6 -o ${QTMAJORVERSION#*.} -gt 9 ]; then
# 5.10 patch is different enough to warrant its own section
{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/qtbase/mkspecs/common/android-base-head.conf b/qtbase/mkspecs/common/android-base-head.conf
index 9be6111..ebd3982 100644
--- a/qtbase/mkspecs/common/android-base-head.conf
+++ b/qtbase/mkspecs/common/android-base-head.conf
@@ -49,8 +49,9 @@ else: ANDROID_ARCHITECTURE = arm
 
 !equals(NDK_TOOLCHAIN_VERSION, 4.4.3): ANDROID_CXXSTL_SUFFIX = -$$NDK_TOOLCHAIN_VERSION
 
+NDK_TOOLCHAIN_PATH = $$(ANDROID_NDK_TOOLCHAIN_PATH)
 NDK_TOOLCHAIN = $$NDK_TOOLCHAIN_PREFIX-$$NDK_TOOLCHAIN_VERSION
-NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
+isEmpty(NDK_TOOLCHAIN_PATH): NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
 
 
 ANDROID_SDK_ROOT = $$(ANDROID_SDK_ROOT)
@@ -68,7 +69,8 @@ isEmpty(ANDROID_SDK_BUILD_TOOLS_REVISION) {
 CONFIG += $$ANDROID_PLATFORM
 QMAKE_CFLAGS = -D__ANDROID_API__=$$replace(ANDROID_PLATFORM, "android-", "")
 
-ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
+ANDROID_PLATFORM_ROOT_PATH = $$(ANDROID_NDK_PLATFORM_ROOT_PATH)
+isEmpty(ANDROID_PLATFORM_ROOT_PATH): ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
 ANDROID_PLATFORM_PATH  = $$ANDROID_PLATFORM_ROOT_PATH/usr
 
 equals(ANDROID_TARGET_ARCH, x86_64)|equals(ANDROID_TARGET_ARCH, mips64): \
diff --git a/qtbase/mkspecs/features/android/android.prf b/qtbase/mkspecs/features/android/android.prf
index 1dc8f87..e796f4a 100644
--- a/qtbase/mkspecs/features/android/android.prf
+++ b/qtbase/mkspecs/features/android/android.prf
@@ -4,11 +4,21 @@ contains(TEMPLATE, ".*app") {
         QMAKE_LFLAGS += -Wl,-soname,$$shell_quote($$TARGET)
 
         android_install {
-            target.path=/libs/$$ANDROID_TARGET_ARCH/
+            ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+            isEmpty(ANDROID_INSTALL_LIBS) {
+                target.path=/libs/$$ANDROID_TARGET_ARCH/
+            } else {
+                target.path=$$ANDROID_INSTALL_LIBS/
+            }
             INSTALLS *= target
         }
     }
 } else: contains(TEMPLATE, "lib"):!static:!QTDIR_build:android_install {
-    target.path = /libs/$$ANDROID_TARGET_ARCH/
+    ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+    isEmpty(ANDROID_INSTALL_LIBS) {
+        target.path=/libs/$$ANDROID_TARGET_ARCH/
+    } else {
+        target.path=$$ANDROID_INSTALL_LIBS/
+    }
     INSTALLS *= target
 }
diff --git a/qtbase/src/android/templates/build.gradle b/qtbase/src/android/templates/build.gradle
index 3a3e0cd..f98eed7 100644
--- a/qtbase/src/android/templates/build.gradle
+++ b/qtbase/src/android/templates/build.gradle
@@ -41,9 +41,12 @@ android {
     sourceSets {
         main {
             manifest.srcFile 'AndroidManifest.xml'
-            java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
-            aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
-            res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            //java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
+            java.srcDirs = ['src', 'java']
+            //aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
+            aidl.srcDirs = ['src', 'aidl']
+            //res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            res.srcDirs = ['res']
             resources.srcDirs = ['src']
             renderscript.srcDirs = ['src']
             assets.srcDirs = ['assets']
diff --git a/qttools/src/androiddeployqt/main.cpp b/qttools/src/androiddeployqt/main.cpp
index 918bc0f..d6bbf8a 100644
--- a/qttools/src/androiddeployqt/main.cpp
+++ b/qttools/src/androiddeployqt/main.cpp
@@ -984,8 +984,8 @@ bool copyAndroidTemplate(const Options &options)
     if (!copyAndroidTemplate(options, QLatin1String("/src/android/templates")))
         return false;
 
-    if (options.gradle)
-        return true;
+    //if (options.gradle)
+    //    return true;
 
     return copyAndroidTemplate(options, QLatin1String("/src/android/java"));
 }
diff --git a/qtbase/src/3rdparty/forkfd/forkfd.c b/qtbase/src/3rdparty/forkfd/forkfd.c
index 7f02ee9..74de1a7 100644
--- a/qtbase/src/3rdparty/forkfd/forkfd.c
+++ b/qtbase/src/3rdparty/forkfd/forkfd.c
@@ -45,8 +45,10 @@
 #include <time.h>
 #include <unistd.h>
 
-#ifdef __linux__
-#  define HAVE_WAIT4    1
+#if defined(__linux__)
+#  if __ANDROID_API__ > 19
+#    define HAVE_WAIT4    1
+#  endif
 #  if defined(__BIONIC__) || (defined(__GLIBC__) && (__GLIBC__ << 8) + __GLIBC_MINOR__ >= 0x208 && \
        (!defined(__UCLIBC__) || ((__UCLIBC_MAJOR__ << 16) + (__UCLIBC_MINOR__ << 8) + __UCLIBC_SUBLEVEL__ > 0x90201)))
 #    include <sys/eventfd.h>
END

{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
commit b7887f9b4faad2227691a2af589e9d7680d6ae08
Author: Thiago Macieira <thiago.macieira@intel.com>
Date:   Wed Sep 19 00:05:54 2018 -0500

    Linux: Remove our use of syscall() for statx(2) and renameat2(2)
    
    Those system calls are present in glibc 2.28. Instead of using
    syscall(3) to place the system calls directly, let's use only the glibc
    functions. That also means we no longer accept ENOSYS from either
    function, if they were detected in glibc.
    
    Change-Id: I44e7d800c68141bdaae0fffd1555b4b8fe63786b
    Reviewed-by: Oswald Buddenhagen <oswald.buddenhagen@qt.io>
    Reviewed-by: Lars Knoll <lars.knoll@qt.io>
    Reviewed-by: Jüri Valdmann <juri.valdmann@qt.io>

diff --git a/src/corelib/global/minimum-linux_p.h b/src/corelib/global/minimum-linux_p.h
index bad2488b4d..9c074e13ba 100644
--- a/qtbase/src/corelib/global/minimum-linux_p.h
+++ b/qtbase/src/corelib/global/minimum-linux_p.h
@@ -75,9 +75,14 @@ QT_BEGIN_NAMESPACE
  * - accept4                    2.6.28
  * - renameat2                  3.16                    QT_CONFIG(renameat2)
  * - getrandom                  3.17                    QT_CONFIG(getentropy)
+ * - statx                      4.11                    QT_CONFIG(statx)
  */
 
-#if QT_CONFIG(getentropy)
+#if QT_CONFIG(statx)
+#  define MINLINUX_MAJOR        4
+#  define MINLINUX_MINOR        11
+#  define MINLINUX_PATCH        0
+#elif QT_CONFIG(getentropy)
 #  define MINLINUX_MAJOR        3
 #  define MINLINUX_MINOR        17
 #  define MINLINUX_PATCH        0
diff --git a/src/corelib/io/qfilesystemengine_unix.cpp b/src/corelib/io/qfilesystemengine_unix.cpp
index deb4a9f220..40e8f82a80 100644
--- a/qtbase/src/corelib/io/qfilesystemengine_unix.cpp
+++ b/qtbase/src/corelib/io/qfilesystemengine_unix.cpp
@@ -1,6 +1,6 @@
 /****************************************************************************
 **
-** Copyright (C) 2017 Intel Corporation.
+** Copyright (C) 2018 Intel Corporation.
 ** Copyright (C) 2016 The Qt Company Ltd.
 ** Copyright (C) 2013 Samuel Gaist <samuel.gaist@edeltech.ch>
 ** Contact: https://www.qt.io/licensing/
@@ -88,7 +88,6 @@ extern "C" NSString *NSTemporaryDirectory();
 
 #if defined(Q_OS_LINUX)
 #  include <sys/ioctl.h>
-#  include <sys/syscall.h>
 #  include <sys/sendfile.h>
 #  include <linux/fs.h>
 
@@ -96,28 +95,6 @@ extern "C" NSString *NSTemporaryDirectory();
 #ifndef FICLONE
 #  define FICLONE       _IOW(0x94, 9, int)
 #endif
-
-#  if defined(Q_OS_ANDROID)
-// renameat2() and statx() are disabled on Android because quite a few systems
-// come with sandboxes that kill applications that make system calls outside a
-// whitelist and several Android vendors can't be bothered to update the list.
-#    undef SYS_renameat2
-#    undef SYS_statx
-#    undef STATX_BASIC_STATS
-#  else
-#    if !QT_CONFIG(renameat2) && defined(SYS_renameat2)
-static int renameat2(int oldfd, const char *oldpath, int newfd, const char *newpath, unsigned flags)
-{ return syscall(SYS_renameat2, oldfd, oldpath, newfd, newpath, flags); }
-#    endif
-
-#    if !QT_CONFIG(statx) && defined(SYS_statx)
-#      include <linux/stat.h>
-static int statx(int dirfd, const char *pathname, int flag, unsigned mask, struct statx *statxbuf)
-{ return syscall(SYS_statx, dirfd, pathname, flag, mask, statxbuf); }
-#    elif !QT_CONFIG(statx) && !defined(SYS_statx)
-#      undef STATX_BASIC_STATS
-#    endif
-#  endif // !Q_OS_ANDROID
 #endif
 
 #ifndef STATX_ALL
@@ -331,22 +308,8 @@ mtime(const T &statBuffer, int)
 #ifdef STATX_BASIC_STATS
 static int qt_real_statx(int fd, const char *pathname, int flags, struct statx *statxBuffer)
 {
-#ifdef Q_ATOMIC_INT8_IS_SUPPORTED
-    static QBasicAtomicInteger<qint8> statxTested  = Q_BASIC_ATOMIC_INITIALIZER(0);
-#else
-    static QBasicAtomicInt statxTested = Q_BASIC_ATOMIC_INITIALIZER(0);
-#endif
-
-    if (statxTested.load() == -1)
-        return -ENOSYS;
-
     unsigned mask = STATX_BASIC_STATS | STATX_BTIME;
     int ret = statx(fd, pathname, flags, mask, statxBuffer);
-    if (ret == -1 && errno == ENOSYS) {
-        statxTested.store(-1);
-        return -ENOSYS;
-    }
-    statxTested.store(1);
     return ret == -1 ? -errno : 0;
 }
 
@@ -1282,14 +1245,12 @@ bool QFileSystemEngine::renameFile(const QFileSystemEntry &source, const QFileSy
     if (Q_UNLIKELY(srcPath.isEmpty() || tgtPath.isEmpty()))
         return emptyFileEntryWarning(), false;
 
-#if defined(RENAME_NOREPLACE) && (QT_CONFIG(renameat2) || defined(SYS_renameat2))
+#if defined(RENAME_NOREPLACE) && QT_CONFIG(renameat2)
     if (renameat2(AT_FDCWD, srcPath, AT_FDCWD, tgtPath, RENAME_NOREPLACE) == 0)
         return true;
 
-    // If we're using syscall(), check for ENOSYS;
-    // if renameat2 came from libc, we don't accept ENOSYS.
     // We can also get EINVAL for some non-local filesystems.
-    if ((QT_CONFIG(renameat2) || errno != ENOSYS) && errno != EINVAL) {
+    if (errno != EINVAL) {
         error = QSystemError(errno, QSystemError::StandardLibraryError);
         return false;
     }
END
else
# note: no !static: in 5.7.0
{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/qtbase/mkspecs/common/android-base-head.conf b/qtbase/mkspecs/common/android-base-head.conf
index ae4933c..a0a505b 100644
--- a/qtbase/mkspecs/common/android-base-head.conf
+++ b/qtbase/mkspecs/common/android-base-head.conf
@@ -49,8 +49,9 @@ else: ANDROID_ARCHITECTURE = arm
 
 !equals(NDK_TOOLCHAIN_VERSION, 4.4.3): ANDROID_CXXSTL_SUFFIX = -$$NDK_TOOLCHAIN_VERSION
 
+NDK_TOOLCHAIN_PATH = $$(ANDROID_NDK_TOOLCHAIN_PATH)
 NDK_TOOLCHAIN = $$NDK_TOOLCHAIN_PREFIX-$$NDK_TOOLCHAIN_VERSION
-NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
+isEmpty(NDK_TOOLCHAIN_PATH): NDK_TOOLCHAIN_PATH = $$NDK_ROOT/toolchains/$$NDK_TOOLCHAIN/prebuilt/$$NDK_HOST
 
 
 ANDROID_SDK_ROOT = $$(ANDROID_SDK_ROOT)
@@ -66,7 +67,8 @@ isEmpty(ANDROID_SDK_BUILD_TOOLS_REVISION) {
 }
 
 CONFIG += $$ANDROID_PLATFORM
-ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
+ANDROID_PLATFORM_ROOT_PATH = $$(ANDROID_NDK_PLATFORM_ROOT_PATH)
+isEmpty(ANDROID_PLATFORM_ROOT_PATH): ANDROID_PLATFORM_ROOT_PATH  = $$NDK_ROOT/platforms/$$ANDROID_PLATFORM/arch-$$ANDROID_ARCHITECTURE/
 ANDROID_PLATFORM_PATH  = $$ANDROID_PLATFORM_ROOT_PATH/usr
 
 # used to compile platform plugins for android-4 and android-5
diff --git a/qtbase/mkspecs/common/android-base-tail.conf b/qtbase/mkspecs/common/android-base-tail.conf
index 2610918..464cfed 100644
--- a/qtbase/mkspecs/common/android-base-tail.conf
+++ b/qtbase/mkspecs/common/android-base-tail.conf
@@ -91,7 +91,7 @@ QMAKE_LFLAGS_NOUNDEF    = -Wl,--no-undefined
 QMAKE_LFLAGS_RPATH      = -Wl,-rpath=
 QMAKE_LFLAGS_RPATHLINK  = -Wl,-rpath-link=
 
-QMAKE_LIBS_PRIVATE      = -lgnustl_shared -llog -lz -lm -ldl -lc -lgcc
+QMAKE_LIBS_PRIVATE      = -lgnustl_shared -fexceptions -frtti -llog -lz -lm -ldl -lc -lgcc
 QMAKE_LIBS_X11          =
 QMAKE_LIBS_THREAD       =
 QMAKE_LIBS_EGL          = -lEGL
diff -uNr src_orig/qtbase/src/corelib/io/qfilesystemengine.cpp src_new/qtbase/src/corelib/io/qfilesystemengine.cpp
--- src_orig/qtbase/src/corelib/io/qfilesystemengine.cpp	2017-04-21 08:48:40.801105796 +0300
+++ src_new/qtbase/src/corelib/io/qfilesystemengine.cpp	2017-04-18 17:39:13.000000000 +0300
@@ -291,7 +291,7 @@
 #endif
 
     // Times
-#if _POSIX_VERSION >= 200809L
+#if !defined(Q_OS_ANDROID) && _POSIX_VERSION >= 200809L
     modificationTime_ = timespecToMSecs(statBuffer.st_mtim);
     creationTime_ = timespecToMSecs(statBuffer.st_ctim);
     if (!creationTime_)
diff --git a/qtbase/mkspecs/features/android/android.prf b/qtbase/mkspecs/features/android/android.prf
index 1dc8f87..e796f4a 100644
--- a/qtbase/mkspecs/features/android/android.prf
+++ b/qtbase/mkspecs/features/android/android.prf
@@ -4,11 +4,21 @@ contains(TEMPLATE, ".*app") {
         QMAKE_LFLAGS += -Wl,-soname,$$shell_quote($$TARGET)
 
         android_install {
-            target.path=/libs/$$ANDROID_TARGET_ARCH/
+            ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+            isEmpty(ANDROID_INSTALL_LIBS) {
+                target.path=/libs/$$ANDROID_TARGET_ARCH/
+            } else {
+                target.path=$$ANDROID_INSTALL_LIBS/
+            }
             INSTALLS *= target
         }
     }
 } else: contains(TEMPLATE, "lib"):!static:!QTDIR_build:android_install {
-    target.path = /libs/$$ANDROID_TARGET_ARCH/
+    ANDROID_INSTALL_LIBS = $$(ANDROID_INSTALL_LIBS)
+    isEmpty(ANDROID_INSTALL_LIBS) {
+        target.path=/libs/$$ANDROID_TARGET_ARCH/
+    } else {
+        target.path=$$ANDROID_INSTALL_LIBS/
+    }
     INSTALLS *= target
 }
diff --git a/qtbase/src/android/templates/build.gradle b/qtbase/src/android/templates/build.gradle
index 3a3e0cd..f98eed7 100644
--- a/qtbase/src/android/templates/build.gradle
+++ b/qtbase/src/android/templates/build.gradle
@@ -41,9 +41,12 @@ android {
     sourceSets {
         main {
             manifest.srcFile 'AndroidManifest.xml'
-            java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
-            aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
-            res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            //java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
+            java.srcDirs = ['src', 'java']
+            //aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
+            aidl.srcDirs = ['src', 'aidl']
+            //res.srcDirs = [qt5AndroidDir + '/res', 'res']
+            res.srcDirs = ['res']
             resources.srcDirs = ['src']
             renderscript.srcDirs = ['src']
             assets.srcDirs = ['assets']
diff --git a/qttools/src/androiddeployqt/main.cpp b/qttools/src/androiddeployqt/main.cpp
index dd5b74b..8c94c8b 100644
--- a/qttools/src/androiddeployqt/main.cpp
+++ b/qttools/src/androiddeployqt/main.cpp
@@ -966,8 +966,8 @@ bool copyAndroidTemplate(const Options &options)
     if (!copyAndroidTemplate(options, QLatin1String("/src/android/templates")))
         return false;
 
-    if (options.gradle)
-        return true;
+    //if (options.gradle)
+    //    return true;
 
     return copyAndroidTemplate(options, QLatin1String("/src/android/java"));
 }
END
fi

if [ $BUILD_WEBKIT == 1 ]; then
if [ $OS_WEBKIT == 1 ]; then
pushd ../$QT_WEBKIT_SOURCE_DIR
{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/.qmake.conf b/.qmake.conf
index 86d0ec0..de140f8 100644
--- a/.qmake.conf
+++ b/.qmake.conf
@@ -4,3 +4,4 @@ QMAKEPATH += $$PWD/Tools/qmake $$MODULE_QMAKE_OUTDIR
 load(qt_build_config)
 
 MODULE_VERSION = 5.9.1
+QMAKE_CXXFLAGS += -DU_PLATFORM_HAS_WINUWP_API=0
diff --git a/Source/JavaScriptCore/LLIntOffsetsExtractor.pro b/Source/JavaScriptCore/LLIntOffsetsExtractor.pro
index 1d13d30..3e293d6 100644
--- a/Source/JavaScriptCore/LLIntOffsetsExtractor.pro
+++ b/Source/JavaScriptCore/LLIntOffsetsExtractor.pro
@@ -7,6 +7,7 @@
 
 TEMPLATE = app
 TARGET = LLIntOffsetsExtractor
+android: CONFIG += android_app
 
 debug_and_release {
     CONFIG += force_build_all
diff --git a/Source/WTF/wtf/Platform.h b/Source/WTF/wtf/Platform.h
index 562840c..a3faa00 100644
--- a/Source/WTF/wtf/Platform.h
+++ b/Source/WTF/wtf/Platform.h
@@ -577,7 +577,7 @@
 #endif  /* OS(WINCE) && !PLATFORM(QT) */
 
 #if OS(ANDROID) && PLATFORM(QT)
-# define WTF_USE_WCHAR_UNICODE 1
+# define WTF_USE_ICU_UNICODE 1
 #endif
 
 #if !USE(WCHAR_UNICODE)
diff --git a/Tools/qmake/mkspecs/features/configure.prf b/Tools/qmake/mkspecs/features/configure.prf
index 23d9904..53b9e73 100644
--- a/Tools/qmake/mkspecs/features/configure.prf
+++ b/Tools/qmake/mkspecs/features/configure.prf
@@ -127,7 +127,7 @@ defineTest(finalizeConfigure) {
         addReasonForSkippingBuild("Build not supported on BB10.")
     }
     production_build:android {
-        addReasonForSkippingBuild("Build not supported on Android.")
+        #addReasonForSkippingBuild("Build not supported on Android.")
     }
     QT_FOR_CONFIG += gui-private
     production_build:qtConfig(mirclient) {
diff --git a/Tools/qmake/mkspecs/features/default_post.prf b/Tools/qmake/mkspecs/features/default_post.prf
index 77375c6..56604ca 100644
--- a/Tools/qmake/mkspecs/features/default_post.prf
+++ b/Tools/qmake/mkspecs/features/default_post.prf
@@ -201,7 +201,7 @@ needToLink() {
         linkAgainstLibrary($$library, $$eval(WEBKIT.$${library_identifier}.root_source_dir))
         LIBS += $$eval(WEBKIT.$${library_identifier}.dependent_libs)
     }
-    posix:!darwin: LIBS += -lpthread
+    posix:!darwin:!android: LIBS += -lpthread
 }
 
 creating_module {
END

# this may not be needed
if [ $QTVERSION_WK != $QTVERSION ]; then
	QTWK_V1=${QTVERSION/.*}
	QTWK_V2=${QTMAJORVERSION#*.}
	QTWK_V3=${QTVERSION/*.}
	QTWK_MACHVER=$(printf "%02x%02x%02x" $QTWK_V1 $QTWK_V2 $QTWK_V3)
	echo "$QTWK_V1 $QTWK_V2 $QTWK_V3 0x$QTWK_MACHVER"
	echo "include/QtWebKit/qtwebkitversion.h"
	sed -i 's/\(#define QTWEBKIT_VERSION_STR "\)[^"]*\("\)/\1'"$QTVERSION\2/; s/\(#define QTWEBKIT_VERSION 0x\).*$/\1$QTWK_MACHVER/;" include/QtWebKit/qtwebkitversion.h
	echo "include/QtWebKitWidgets/qtwebkitwidgetsversion.h"
	sed -i 's/\(#define QTWEBKITWIDGETS_VERSION_STR "\)[^"]*\("\)/\1'"$QTVERSION\2/; s/\(#define QTWEBKITWIDGETS_VERSION 0x\).*$/\1$QTWK_MACHVER/;" include/QtWebKitWidgets/qtwebkitwidgetsversion.h
	echo ".qmake.conf"
	#MODULE_VERSION = 5.9.1
	sed -i 's/\(MODULE_VERSION = \).*$/\1'"$QTVERSION/;" .qmake.conf
fi

popd
# back to qt src dir
# this is so qt can find qtwebkit again after being removed
if ! grep 'submodule "qtwebkit"' .gitmodules >/dev/null 2>/dev/null ; then
	echo "qtwebkit missing from modules, add it"
	cat <<'END' >> .gitmodules

[submodule "qtwebkit"]
	depends = qtbase
	recommends = qtdeclarative qtlocation qtmultimedia qtsensors qtwebchannel qtxmlpatterns
	path = qtwebkit
	url = ../qtwebkit.git
	branch = 5.9.1
	status = obsolete
	project = WebKit.pro
	priority = 20
END
fi
fi
fi
popd
}

configure_qt5() {
	pushd $QT_SOURCE_DIR
	OPATH=$PATH

	if [ $CLEAN == 1 ]; then
		test -d $QTBUILDROOT && rm -rf $QTBUILDROOT
	fi
	mkdir $QTBUILDROOT || true
	pushd $QTBUILDROOT

	#install ../qtbase/src/3rdparty/sqlite/sqlite3.h $INSTALLROOT/include/

	export PKG_CONFIG_SYSROOT_DIR=$INSTALLROOT
	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_ABIS=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	if [ ${ANDROID_API_VERSION/*-/} -lt 29 ]; then
		export ANDROID_API_VERSION=android-29
	fi
	#export ANDROID_NDK_TOOLCHAIN_PATH
	#export ANDROID_NDK_PLATFORM_ROOT_PATH="$SYSROOT"
	export ANDROID_INSTALL_LIBS="/lib"
	export SQLITE3SRCDIR="`readlink -f qtbase/src/3rdparty/sqlite`/"
	if [ $BUILD_WEBKIT == 1 ]; then
		#export QMAKE_CXXFLAGS="-DENABLE_JIT=0 -DENABLE_LLINT=0"
		grep -vE "DENABLE_JIT=|DENABLE_LLINT=" ../qtwebkit/.qmake.conf > ../qtwebkit/.qmake.conf.tmp
		mv ../qtwebkit/.qmake.conf.tmp ../qtwebkit/.qmake.conf
		if [ $OS_WEBKIT == 1 ]; then
			#echo "QMAKE_CXXFLAGS += -DENABLE_JIT=1" >> ../qtwebkit/.qmake.conf
			#echo "QMAKE_CXXFLAGS += -DENABLE_LLINT=0" >> ../qtwebkit/.qmake.conf
			echo "QMAKE_CXXFLAGS += -DU_PLATFORM_HAS_WINUWP_API=0" >> ../qtwebkit/.qmake.conf
			true
		fi
	fi

	SKIPS=
	SKIPS="$SKIPS -skip qt3d"
	SKIPS="$SKIPS -skip qtactiveqt"
	#SKIPS="$SKIPS -skip qtandroidextras"
	#SKIPS="$SKIPS -skip qtbase"
	SKIPS="$SKIPS -skip qtcharts"
	SKIPS="$SKIPS -skip qtconnectivity"
	SKIPS="$SKIPS -skip qtdatavis3d"
	SKIPS="$SKIPS -skip qtdeclarative"
	SKIPS="$SKIPS -skip qtdoc"
	SKIPS="$SKIPS -skip qtgamepad"
	SKIPS="$SKIPS -skip qtgraphicaleffects"
	SKIPS="$SKIPS -skip qtimageformats"
	SKIPS="$SKIPS -skip qtlocation"
	SKIPS="$SKIPS -skip qtlottie"
	SKIPS="$SKIPS -skip qtmacextras"
	SKIPS="$SKIPS -skip qtmultimedia"
	SKIPS="$SKIPS -skip qtnetworkauth"
	SKIPS="$SKIPS -skip qtpurchasing"
	SKIPS="$SKIPS -skip qtquick3d"
	SKIPS="$SKIPS -skip qtquickcontrols"
	SKIPS="$SKIPS -skip qtquickcontrols2"
	SKIPS="$SKIPS -skip qtquicktimeline"
	SKIPS="$SKIPS -skip qtremoteobjects"
	#SKIPS="$SKIPS -skip qtscript"
	SKIPS="$SKIPS -skip qtscxml"
	SKIPS="$SKIPS -skip qtsensors"
	SKIPS="$SKIPS -skip qtserialbus"
	SKIPS="$SKIPS -skip qtserialport"
	SKIPS="$SKIPS -skip qtspeech"
	SKIPS="$SKIPS -skip qtsvg"
	SKIPS="$SKIPS -skip qttools"
	SKIPS="$SKIPS -skip qttranslations"
	SKIPS="$SKIPS -skip qtvirtualkeyboard"
	SKIPS="$SKIPS -skip qtwayland"
	SKIPS="$SKIPS -skip qtwebchannel"
	SKIPS="$SKIPS -skip qtwebengine"
	SKIPS="$SKIPS -skip qtwebglplugin"
	SKIPS="$SKIPS -skip qtwebsockets"
	SKIPS="$SKIPS -skip qtwebview"
	SKIPS="$SKIPS -skip qtwinextras"
	SKIPS="$SKIPS -skip qtx11extras"
	SKIPS="$SKIPS -skip qtxmlpatterns"

	SKIPS="$SKIPS -nomake qtprintsupport"
	SKIPS="$SKIPS -nomake qttest"

	#../configure -list-features
	../configure -h
	MAKEFLAGS="-j$NCPUS" \
	RANLIB=${CROSSPATH_LLVM}ranlib \
	../configure \
		-xplatform android-clang \
		-opensource -confirm-license \
		-prefix $QTINSTALLROOT \
		-extprefix $QTINSTALLROOT \
		-hostprefix $QTINSTALLROOT \
		-nomake tests -nomake examples \
		-android-arch $ARMEABI \
		-continue \
		--disable-rpath \
		-I "$QT_SOURCE_DIR/include" \
		-I "$INSTALLROOT/include" \
		-I "$INSTALLROOT/include/mariadb" \
		-L "$INSTALLROOT/lib" \
		-L "$INSTALLROOT/lib/mariadb" \
		-plugin-sql-mysql \
		-plugin-android \
		-qt-sqlite \
		$SKIPS \
		-feature-rtti \
		-feature-exceptions \
		-no-warnings-are-errors \
		-sysroot $SYSROOT \
		$EXTRA_QT_CONFIGURE_ARGS \

	ERR=$?
	export ANDROID_API_VERSION=${ANDROID_API_VERSION:-$ANDROID_SDK_PLATFORM}

	popd
	PATH=$OPATH
	unset OPATH
	popd
	return $ERR
}

build_sqlite() {
	pushd $QT_SOURCE_DIR
	OPATH=$PATH

	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export CPPFLAGS="--sysroot=\"$SYSROOT\" -isysroot \"$SYSROOT\""
	export LDFLAGS="--sysroot=\"$SYSROOT\" -isysroot \"$SYSROOT\""
	export CXXPPFLAGS="--sysroot=\"$SYSROOT\""
	#export INSTALL_ROOT="$INSTALLROOT"
	if [ $CLEAN == 1 ]; then
	test -d $QTBUILDROOT && rm -r $QTBUILDROOT
	fi
	mkdir $QTBUILDROOT || true
	cd $QTBUILDROOT
	../qtwebengine/src/3rdparty/chromium/third_party/sqlite/src/configure --help
		CFLAGS="-isysroot $SYSROOT -mcpu=$CPU" \
		CXXFLAGS="-isysroot $SYSROOT -mcpu=$CPU" \
		CC="$CROSSPATH/arm-linux-androideabi-gcc" \
		CXX="$CROSSPATH/arm-linux-androideabi-g++" \
		CPP="$CROSSPATH/arm-linux-androideabi-cpp" \
	../qtwebengine/src/3rdparty/chromium/third_party/sqlite/src/configure \
		--host=arm-linux-androideabi \
		--prefix=$QTINSTALLROOT \
		--enable-shared \
		--enable-static &&
	make -j$NCPUS &&
	make install

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXPPFLAGS

	PATH=$OPATH
	unset OPATH
	popd
}

build_qt5() {
	echo "PWD $PWD"
	ERR=0
	pushd $QT_SOURCE_DIR
	OPATH=$PATH
	export QTDIR=$QTSRCDIR/qtbase

	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export ROOT_WEBKIT_DIR="`pwd`"
	export ANDROID_INSTALL_LIBS="/lib"
	export SQLITE3SRCDIR="`readlink -f qtbase/src/3rdparty/sqlite`/"
	if [ ${ANDROID_API_VERSION/*-/} -lt 29 ]; then
		export ANDROID_API_VERSION=android-29
	fi

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXFLAGS

	mkdir $QTBUILDROOT || true
	pushd $QTBUILDROOT
	#NCPUS=1
	#THINGS_TO_MAKE="module-qtbase module-qtscript module-qtandroidextras"
	if [ $BUILD_WEBKIT == 1 ]; then
		if [ $OS_WEBKIT == 1 ]; then
			THINGS_TO_MAKE="$THINGS_TO_MAKE module-qtwebkit"
		fi
	fi
	make -j$NCPUS $THINGS_TO_MAKE || ERR=$?
	echo "Build Completed build_qt5 $ERR"
	[ $ERR == 0 ] && \
	make -j$NCPUS install \
	|| ERR=$?
	if [ $ERR -eq 2 ]; then
		ERR=0
	fi

	popd

	export ANDROID_API_VERSION=${ANDROID_API_VERSION:-$ANDROID_SDK_PLATFORM}
	unset CPPFLAGS
	unset LDFLAGS
	unset CXXPPFLAGS
	unset SQLITE3SRCDIR
	PATH=$OPATH
	unset OPATH
	popd
	echo "All Completed build_qt5 $ERR"
	return $ERR
}

build_webkit_59() {
	echo "PWD $PWD"
	ERR=0
	pushd $QT_SOURCE_DIR
	#QTSRCDIR="$PWD/qt-everywhere-opensource-src-$QTVERSION"
	#pushd qtwebkit-opensource-src-$QTVERSION
	OPATH=$PATH
	#export QTDIR=$QTINSTALLROOT
	export QTDIR=$QTSRCDIR/qtbase
	#PATH="$QTDIR/bin:$PATH"

	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export ROOT_WEBKIT_DIR="`pwd`"
	export ANDROID_INSTALL_LIBS="/lib"
	export SQLITE3SRCDIR="`readlink -f qtbase/src/3rdparty/sqlite`/"

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXFLAGS

	mkdir $QTBUILDROOT || true
	pushd $QTBUILDROOT
	#NCPUS=1
	export PKG_CONFIG_DIR=
	export PKG_CONFIG_LIBDIR=$INSTALLROOT/lib/pkgconfig:$INSTALLROOT/share/pkgconfig:$QTBASE/lib/pkgconfig
	export PKG_CONFIG_SYSROOT_DIR=$INSTALLROOT
	#cat Makefile $INSTALLROOT/../qtwebkitmakebits > Makefile.withqtwebkit
	set -x
	#make -j$NCPUS -f Makefile.withqtwebkit module-qtwebkit && \
	#make -j$NCPUS -f Makefile.withqtwebkit module-qtlocation-install_subtargets && \
	make -j$NCPUS -C qtwebkit/Source -f Makefile.api install && \
	make -j$NCPUS -C qtwebkit/Source -f Makefile.widgetsapi install \
		|| ERR=$?
	set +x

	#make -j$NCPUS module-qtwebkit-install_subtargets
	#make -j$NCPUS module-qtwebengine-install_subtargets
	true
	#make -C qtwebkit/Source -f Makefile.api INSTALL_ROOT="$INSTALLROOT" install &&
	#make -C qtwebkit/Source -f Makefile.widgetsapi INSTALL_ROOT="$INSTALLROOT" install &&
	#echo rsync -av --remove-source-files $INSTALLROOT$INSTALLROOT/ $INSTALLROOT/
	#make -C qtwebkit INSTALL_ROOT="$INSTALLROOT" install
	#make -C qtscript install &&
	#true
	popd

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXPPFLAGS
	unset SQLITE3SRCDIR
	PATH=$OPATH
	unset OPATH
	popd
	return $ERR
}

build_webkit_59a() {
	echo "PWD $PWD"
	QTSRCDIR="$PWD/qt-everywhere-opensource-src-$QTVERSION"
	pushd $QT_WEBKIT_SOURCE_DIR
	{ patch -p1 -Nt --no-backup-if-mismatch -r - || true; } <<'END'
diff --git a/Tools/qmake/mkspecs/features/functions.prf b/Tools/qmake/mkspecs/features/functions.prf
index 3e0d406..6ab3c24 100644
--- a/Tools/qmake/mkspecs/features/functions.prf
+++ b/Tools/qmake/mkspecs/features/functions.prf
@@ -96,7 +96,7 @@ defineTest(isPlatformSupported) {
             skipBuild("QtWebKit requires an macOS SDK version of 10.10 or newer. Current version is $${sdk_version}.")
         }
     } else {
-        android: skipBuild("Android is not supported.")
+        #android: skipBuild("Android is not supported.")
         uikit: skipBuild("UIKit platforms are not supported.")
         qnx: skipBuild("QNX is not supported.")
 
END
	#pushd qtwebkit-opensource-src-$QTVERSION
	OPATH=$PATH
	export QTDIR=$QTINSTALLROOT
	#export QTDIR=$QTSRCDIR/qtbase
	#PATH="$QTDIR/bin:$PATH"

	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export ROOT_WEBKIT_DIR="`pwd`"
	export ANDROID_INSTALL_LIBS="/lib"
	export SQLITE3SRCDIR="$QTSRCDIR/qtbase/src/3rdparty/sqlite/"

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXFLAGS

	mkdir $QTBUILDROOT || true
	pushd $QTBUILDROOT

	if [ $CLEAN == 1 ]; then
		rm -r *
		#make distclean || true
	fi

	printf -v L_CMAKE_MODULE_PATH "%s:" $QTINSTALLROOT/lib/cmake/*
	#BASE_CMAKE_PATH=$(cmake --system-information | grep CMAKE_SYSTEM_PREFIX_PATH | cut -d'"' -f2)
	#L_CMAKE_PREFIX_PATH="$INSTALLROOT/qt/lib/cmake:${BASE_CMAKE_PATH//;/:}"
	echo "prefix path $L_CMAKE_PREFIX_PATH"
	set +e
	#NCPUS=1
	PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR/pkgconfig:$QTINSTALLROOT/lib/pkgconfig" \
	cmake \
	      -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
	      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
	      -DCMAKE_ANDROID_NDK=$ANDROID_NDK                \
	      -DANDROID_NDK1=$ANDROID_NDK                \
	      -DANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK_TOOLCHAIN_PATH \
	      -DCMAKE_BUILD_TYPE=Release                \
	      -DANDROID_TOOLCHAIN="gcc"	\
	      -DANDROID_ABI="$ARMEABI"                  \
	      -DPORT=Qt \
	      -DQt5_DIR="$QTINSTALLROOT/lib/cmake/Qt5" \
	      -DQt5Core_DIR="$QTINSTALLROOT/lib/cmake/Qt5Core" \
	      -DQt5Gui_DIR="$QTINSTALLROOT/lib/cmake/Qt5Gui" \
	      -DQt5Network_DIR="$QTINSTALLROOT/lib/cmake/Qt5Network" \
	      -DQt5Widgets_DIR="$QTINSTALLROOT/lib/cmake/Qt5Widgets" \
	      -DQt5Qml_DIR="$QTINSTALLROOT/lib/cmake/Qt5Qml" \
	      -DQt5Quick_DIR="$QTINSTALLROOT/lib/cmake/Qt5Quick" \
	      -DQt5WebChannel_DIR="$QTINSTALLROOT/lib/cmake/Qt5WebChannel" \
	      -DQt5OpenGL_DIR="$QTINSTALLROOT/lib/cmake/Qt5OpenGL" \
	      -DENABLE_API_TESTS=OFF \
	      -DENABLE_TEST_SUPPORT=OFF \
	      -DENABLE_GEOLOCATION=OFF \
	      -DENABLE_DEVICE_ORIENTATION=OFF \
	      -DENABLE_PRINT_SUPPORT=OFF \
	      -DQT_BUNDLED_JPEG=1 \
	      -DQT_BUNDLED_PNG=1 \
	      -DCMAKE_PREFIX_PATH="$INSTALLROOT:$QTINSTALLROOT" \
	      -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
	      -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
	      -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=BOTH \
	      -DCMAKE_FIND_ROOT_PATH="$INSTALLROOT" \
	      -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=1 \
	      -DENABLE_TOOLS=OFF \
	      -DENABLE_API_TESTS=OFF \
	      -DUSE_GSTREAMER=OFF \
	      -DUSE_LIBHYPHEN=OFF \
		.. &&
	make -j$NCPUS VERBOSE=0 install
	if [ 0 = 1 ]; then
	cmake \
	      -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE2 \
	      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT  \
	      -DANDROID_NDK=$ANDROID_NDK                \
	      -DCMAKE_BUILD_TYPE=Release                \
	      -DANDROID_TOOLCHAIN_NAME="$MY_ANDROID_NDK_TOOLS_PREFIX-gcc4.9"	\
	      -DANDROID_ABI="$ARMEABI"                  \
	      -DPORT=Qt \
	      -DCMAKE_REQUIRED_INCLUDES="$INSTALLROOT/include:$SYSROOT/usr/include" \
	      -DCMAKE_PREFIX_PATH="$INSTALLROOT:$SYSROOT/usr" \
	      -DSQLITE3_SOURCE_DIR=$SQLITE3SRCDIR \
	      -DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config \
	      -DQT_BUNDLED_JPEG=1 \
	      -DQT_BUNDLED_PNG=1 \
	      -DVERBOSE=1 \
	      --verbose=1 \
	      --debug-output=0 \
	      --trace \
	      .. && \
	xxmake VERBOSE=0 install
	fi

	      #-DXXXCMAKE_MODULE_PATH="$L_CMAKE_MODULE_PATH" \
	      #-DXXXCMAKE_MODULE_PATH="$QTINSTALLROOT/lib/cmake/Qt5Core" \
	      #-DCMAKE_CXX_FLAGS="-include ctype.h" \
	      #-DCMAKE_C_FLAGS="-include ctype.h" \
	      #-DQt5_DIR="$Qt5_DIR/lib/cmake" \
		#-DCMAKE_C_FLAGS="--sysroot=$SYSROOT" \
		#-DCMAKE_CXX_FLAGS="--sysroot=$SYSROOT" \
	      #-DCMAKE_PREFIX_PATH=${L_CMAKE_PREFIX_PATH%:}	\
	      #-DCMAKE_PREFIX_PATH="$INSTALLROOT" \
	      #-DBISON_EXECUTABLE=`which bison` \
	      #-DGPERF_EXECUTABLE=`which gperf` \
	      #-DPERL_EXECUTABLE=`which perl` \
	      #-DPYTHON_EXECUTABLE=`which python` \
	      #--debug-output \

	popd

	set -e
	unset CPPFLAGS
	unset LDFLAGS
	unset CXXPPFLAGS
	unset SQLITE3SRCDIR
	PATH=$OPATH
	unset OPATH
	popd
}

build_qtwebengine() {
	pushd $QT_SOURCE_DIR
#	pushd qt-everywhere-opensource-src-$QTVERSION/qtwebengine
	OPATH=$PATH

	export ANDROID_NDK_PLATFORM=android-17
	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
	export CPPFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\""
	export LDFLAGS="--sysroot=\"$sysroot\" -isysroot \"$sysroot\""
	export CXXPPFLAGS="--sysroot=\"$sysroot\""
	export ANDROID_INSTALL_LIBS="/lib"
	#export INSTALL_ROOT="$INSTALLROOT"
	$QTINSTALLROOT/bin/qmake &&
	cd qtwebengine &&
	make -j$NCPUS qmake_all
#	cd Source
#	make -f Makefile.widgetsapi install
#	make -f Makefile.api install

	PATH=$OPATH
	unset OPATH
	popd
}

build_mysqlplugin() {
	# make sure to use the shadow build
	pushd $QT_SOURCE_DIR/$QTBUILDROOT/qtbase/src/plugins/sqldrivers/mysql
	OPATH=$PATH
	QT_PRO_DIR="`readlink -f qtbase/src/plugins/sqldrivers/mysql`"

	export ANDROID_TARGET_ARCH=$ARMEABI
	export ANDROID_NDK_TOOLS_PREFIX=$MY_ANDROID_NDK_TOOLS_PREFIX
	export CPPFLAGS="--sysroot=\"$SYSROOT\" -isysroot \"$SYSROOT\" -I$INSTALLROOT/include/mariadb"
	export LDFLAGS="--sysroot=\"$SYSROOT\" -isysroot \"$SYSROOT\" -L$INSTALLROOT/lib/mariadb"
	export CXXPPFLAGS="--sysroot=\"$SYSROOT\" -I$INSTALLROOT/include"
	export ANDROID_INSTALL_LIBS="/lib"
	#export INSTALL_ROOT="$INSTALLROOT"
	$QTINSTALLROOT/bin/qmake \
		"INCLUDEPATH+=$INSTALLROOT/include/mariadb" \
		"LIBPATH+=$INSTALLROOT/lib/mariadb" \
       		"LIBS+=-lmysqlclient_r" \
		"$QT_PRO_DIR" &&
	make -j$NCPUS &&
	make install
	#make INSTALL_ROOT="$INSTALLROOT" install

	unset CPPFLAGS
	unset LDFLAGS
	unset CXXPPFLAGS
	PATH=$OPATH
	unset OPATH
	popd
}

[ -d $LIBSDIR ] || mkdir $LIBSDIR
pushd $LIBSDIR

#get_android_cmake
[ -n "$BUILD_MISSING_HEADERS" ] && copy_missing_sys_headers
[ -n "$BUILD_TAGLIB" ] && build_taglib
[ -n "$BUILD_FREETYPE" ] && build_freetype
[ -n "$BUILD_GETTEXT" ] && build_gettext
[ -n "$BUILD_OPENSSL" ] && build_openssl
[ -n "$BUILD_ICONV" ] && build_iconv
[ -n "$BUILD_ICU" ] && build_icu
[ -n "$BUILD_XML2" ] && build_xml2
[ -n "$BUILD_MARIADB" ] && build_mariadb
[ -n "$BUILD_LAME" ] && build_lame
[ -n "$BUILD_EXIV2" ] && build_exiv2_git
[ -n "$BUILD_OGG" ] && build_ogg
[ -n "$BUILD_VORBIS" ] && build_vorbis
[ -n "$BUILD_FLAC" ] && build_flac
[ -n "$BUILD_LIBXML2" ] && build_libxml2
[ -n "$BUILD_LIBXSLT" ] && build_libxslt
[ -n "$BUILD_FFI" ] && build_ffi
[ -n "$BUILD_GLIB" ] && build_glib
[ -n "$BUILD_LZO" ] && build_android_external_liblzo
[ -n "$BUILD_LIBZIP" ] && build_libzip
[ -n "$BUILD_FONTCONFIG" ] && build_fontconfig
[ -n "$BUILD_FRIBIDI" ] && build_fribidi
[ -n "$BUILD_HARFBUZZ" ] && build_harfbuzz
[ -n "$BUILD_ASS" ] && build_ass
[ -n "$BUILD_LIBSAMPLERATE" ] && build_libsamplerate
[ -n "$BUILD_LIBSOUNDTOUCH" ] && build_libsoundtouch
[ -n "$BUILD_LIBBLURAY" ] && build_libbluray
[ -n "$BUILD_FFTW" ] && build_fftw
if [ -n "$BUILD_QT5EXTRAS" ]; then
	echo -e "\n**** patch qt5 ***"
	patch_qt5
	echo -e "\n**** configure_qt5 ***"
	configure_qt5
	#echo -e "\n**** SQLITE ***"
	#build_sqlite
	echo -e "\n**** build qt5 ***"
	build_qt5
	if [ $BUILD_WEBKIT == 1 ]; then
		echo -e "\n**** WEBKIT ***"
		build_webkit_59
	fi
	#build_qtwebengine
	#echo -e "\n**** MYSQLPLUGIN ***"
	#build_mysqlplugin
fi
if [ -n "$BUILD_QTMYSQLPLUGIN" ]; then
	build_mysqlplugin
fi
if [ -n "$BUILD_QTWEBKITONLY" ]; then
	if [ $OS_WEBKIT == 1 ]; then
		build_webkit_59
	else
		build_webkit_59a
	fi
fi
if [ -n "$BUILD_NEWQTWEBKITONLY" ]; then
	build_webkit_59a
fi


popd
