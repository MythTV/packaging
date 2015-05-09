#!/bin/bash

BASE=`pwd`
source ~/android/setenv.sh

#SYSROOT=$ANDROID_NDK/platforms/android-17/arch-arm
#SYSINC=$ANDROID_NDK/platforms/android-17/arch-arm/usr/include
#CROSSPREFIX=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
SYSROOT=$ANDROID_NDK/my-android-toolchain/sysroot
SYSINC=$ANDROID_NDK/my-android-toolchain
#SYSINC=$INSTALLROOT
CROSSPREFIX=$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-
CROSSPREFIX=$ANDROID_NDK/my-android-toolchain/arm-linux-androideabi/bin/
export ANDROID_NDK_ROOT=$ANDROID_NDK

export ANDROID_NDK_PLATFORM=android-17
export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
export ANDROID_NDK_TOOLCHAIN_VERSION=4.9

INSTALLROOT=$BASE/mythinstall
export MYTHINSTALLROOT=$BASE/mythinstall
export MYTHINSTALLLIBCOMMON=$MYTHINSTALLROOT/lib/
export MYTHINSTALLLIB=$MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/
export MYTHPACKAGEBASE=$BASE

PATH="$INSTALLROOT/bin:$PATH"

export PKG_CONFIG_DIR=
#export PKG_CONFIG_LIBDIR=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig
#export PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
export PKG_CONFIG_LIBDIR=$INSTALLROOT/lib/pkgconfig:$INSTALLROOT/share/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=$INSTALLROOT

#CFLAGS='-march=armv7-a -mfloat-abi=softfp'
#CFLAGS='-march=armv7-a -mfloat-abi=softfp -mfpu=neon'
#LDFLAGS='-Wl,--fix-cortex-a8'
# -lsupc++ if using rtti or expections
# stl use -lstdc++ or -lgnustl_shared

# http://www.kandroid.org/ndk/docs/STANDALONE-TOOLCHAIN.html

cd mythtv/mythtv

export ANDROID_EXTRA_LIBS="$INSTALLROOT"
#export ANDROID_EXTRA_LIBS="$INSTALLROOT/libs/armeabi-v7a/libmyth-0.28.so"
#export ANDROID_EXTRA_LIBS="$INSTALLROOT/libs/armeabi-v7a"

function deploy-extra-libs() {
	pushd $INSTALLROOT/libs/$ANDROID_TARGET_ARCH
	#for i in ../../lib/*; do
	#	ln -snf $i
	#done
	popd
	[ -d "$INSTALLROOT/assets" ] || mkdir $INSTALLROOT/assets
	pushd $INSTALLROOT/assets
	cp -a ../share/mythtv .
	rm -r mythtv/html mythtv/backend-config mythtv/mythconverg*.pl
	popd
}

# these go in the json
#ANDROID_EXTRA_LIBS=`$BASE/findlibdeps.pl $INSTALLROOT/libs/armeabi-v7a $INSTALLROOT/lib $INSTALLROOT/libs/armeabi-v7a/libmythfrontend.so` \
#ANDROID_EXTRA_PLUGINS="sqlmysql" \
#ANDROID_PACKAGE_SOURCE_DIR="$BASE/android-package-source" \

function makeapk() {
	$ANDROID_SDK_ROOT/tools/android update project \
		--path $INSTALLROOT/ \
		--target android-17 \
		--name MythFrontend
}

RELEASE=0
TARGETAPK=$INSTALLROOT/bin/QtApp-debug.apk
CONFIGUREBUILDTYPE="debug --enable-small"
NEONFLAGS="-mfpu=neon"
#NEONFLAGS="$NEONFLAGS -funsafe-math-optimizations"
CPU=armv7-a
DEPLOYTYPE="--debug"
EXTRASPECS="-after QMAKE_CFLAGS-=-mfpu=vfp QMAKE_CXXFLAGS-=-mfpu=vfp"

while : ; do
case "$1" in
	-no-neon)
		EXTRASPECS=
		NEONFLAGS=
		shift
		;;
	-cortex-a9)
		CPU=cortex-a9
		shift
		;;
	release)
		BUNDLESIGN="--sign $KEYSTORE $KEYALIAS --storepass $KEYSTOREPASSWORD"
		RELEASE=1
		TARGETAPK=$INSTALLROOT/bin/QtApp-release-signed.apk
		CONFIGUREBUILDTYPE=release
		DEPLOYTYPE=
		shift
		;;
	reconfig*)
		stamp_configure_android
		shift
		;;
	"clean" )
		rm stamp_configure_android
		make clean
		exit 0
		;;
	"distclean" )
		rm stamp_configure_android
		make distclean
		exit 0
		;;
	"bundle")
		$QTBASE/bin/androiddeployqt \
			--output $INSTALLROOT \
			$DEPLOYTYPE \
			--verbose \
			--android-platform $ANDROID_NDK_PLATFORM \
			--input programs/mythfrontend/android-libmythfrontend.so-deployment-settings.json \
			--jdk $JDK_PATH $BUNDLESIGN
		cp $TARGETAPK $BASE/mythfrontend.apk
		exit 0
		;;
	"")
		break
		;;
esac
done

IGNOREDEFINES="-DIGNORE_SCHEMA_VER_MISMATCH -DIGNORE_PROTO_VER_MISMATCH"

./configure --help
if [ ! -e stamp_configure_android ] ; then
./configure \
	--disable-ccache \
	--cross-prefix=$CROSSPREFIX \
	--arch=arm7a --cpu=$CPU \
	--target-os=android \
	--compile-type=$CONFIGUREBUILDTYPE \
	--prefix=/ \
	--runprefix=/ \
	--libdir-name=$INSTALLROOT/lib \
	--enable-backend \
	--enable-cross-compile \
	--sysroot=$SYSROOT \
	--extra-cflags="-DANDROID -I$INSTALLROOT/include $IGNOREDEFINES $NEONFLAGS " \
	--extra-cxxflags="-DANDROID -I$INSTALLROOT/include $IGNOREDEFINES $NEONFLAGS " \
	--qmake=$QTBASE/bin/qmake \
	--qmakespecs="android-g++ $EXTRASPECS" \
	--disable-qtwebkit \
	--disable-qtdbus \
	--disable-dvb \
	--disable-hdhomerun \
	--disable-v4l2 \
	--disable-firewire \
	--disable-ceton \
	--disable-ivtv \
	--disable-hdpvr \
	--disable-lirc \
	--disable-libcec \
	--disable-x11 \
	--disable-libxml2 \
	--disable-libdns-sd \
	--disable-libcrypto \
	--disable-libass \
	--disable-mheg \
	--disable-vdpau \
	--disable-crystalhd \
	--disable-vaapi \
	--disable-dxva2 \
	--disable-quartz-video \
	--enable-opengl-video \
	--enable-opengl \
	--without-bindings=perl,python,php \
	&& touch stamp_configure_android
fi

if [ -e stamp_configure_android ] ; then
	set -e
	make
	make install INSTALL_ROOT=$INSTALLROOT
	deploy-extra-libs
	$QTBASE/bin/androiddeployqt \
		--output $INSTALLROOT \
		$DEPLOYTYPE \
		--verbose \
		--android-platform $ANDROID_NDK_PLATFORM \
		--jdk $JDK_PATH $BUNDLESIGN \
		--input programs/mythfrontend/android-libmythfrontend.so-deployment-settings.json
	cp $TARGETAPK $BASE/mythfrontend.apk
fi

