#!/bin/bash

BASE=`pwd`
source ~/android/setenv.sh

SHADOW_BUILD=0
ARM64=0

SYSROOT=$ANDROID_NDK/my-android-toolchain/sysroot
SYSINC=$ANDROID_NDK/my-android-toolchain
CROSSPREFIX=$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-
#CROSSPREFIX=$ANDROID_NDK/my-android-toolchain/arm-linux-androideabi/bin/
export ANDROID_NDK_ROOT=$ANDROID_NDK

MYMYTHPATH="`readlink -f ../../mythtv`"
export NCPUS=$(nproc)

[ -e make.inc ] && source make.inc

export ANDROID_NDK_API=21
export ANDROID_NDK_PLATFORM=android-$ANDROID_NDK_API
export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
export ANDROID_BUILD_TOOLS_REVISION=27.0.3

#CFLAGS='-march=armv7-a -mfloat-abi=softfp'
#CFLAGS='-march=armv7-a -mfloat-abi=softfp -mfpu=neon'
#LDFLAGS='-Wl,--fix-cortex-a8'
# -lsupc++ if using rtti or expections
# stl use -lstdc++ or -lgnustl_shared

# http://www.kandroid.org/ndk/docs/STANDALONE-TOOLCHAIN.html


function deploy-extra-libs() {
	#pushd $INSTALLROOT/libs/$ANDROID_TARGET_ARCH
	#for i in ../../lib/*; do
	#	ln -snf $i
	#done
	#popd
	[ -d "$INSTALLROOT/assets" ] || mkdir $INSTALLROOT/assets
	pushd $INSTALLROOT/assets
	cp -aL ../share/mythtv .
	rm -r mythtv/html mythtv/backend-config mythtv/mythconverg*.pl
	popd
	[ -d "$INSTALLROOT/jni" ] || mkdir $INSTALLROOT/jni
	pushd "$INSTALLROOT/jni"
	echo <<-END > Android.mk
	LOCAL_PATH := \$(call my-dir)
	include \$(CLEAR_VARS)
	LOCAL_MODULE    := mythfrontend
	END
	echo <<-END > Application.mk
	APP_PLATFORM := android-$ANDROID_NDK_API
	APP_OPTIM = debug
	APP_ABI := $ANDROID_TARGET_ARCH
	END
	popd
}

function makeapk() {
	$ANDROID_SDK_ROOT/tools/android update project \
		--path $INSTALLROOT/ \
		--target $ANDROID_NDK_PLATFORM \
		--name MythFrontend
}

RELEASE=0
CONFIGUREBUILDTYPE="debug --enable-small"
NEONFLAGS=
#NEONFLAGS="-mfpu=neon"
ARCH=armv7-a
CPU=armv7-a
#CPU=cortex-a53
DEPLOYTYPE="--debug"
EXTRASPECS="-after QMAKE_CFLAGS-=-mfpu=vfp QMAKE_CXXFLAGS-=-mfpu=vfp"

function bundle_apk() {
	mkdir -p $MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/ || true
	cp $MYTHINSTALLROOT/lib/libmythfrontend.so $MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/
	$QTBASE/bin/androiddeployqt \
		--gradle \
		--output $INSTALLROOT \
		$DEPLOYTYPE \
		--verbose \
		--android-platform $ANDROID_NDK_PLATFORM \
		--input programs/mythfrontend/android-libmythfrontend.so-deployment-settings.json \
		--jdk $JDK_PATH $BUNDLESIGN
	if [ $? -ne 0 ]; then
		echo "Error androiddeployqt result is $?"
	else
		TARGETVERSION=`date +"%F" | tr -d '-'`-$BUNDLE_NAME-`grep "define MYTH_SOURCE_VERSION" libs/libmythbase/version.h | cut -d' ' -f 3 | tr -d '"'`
		echo "*** copy apk to $BASE/mythfrontend-$TARGETVERSION.apk ***"
		for apk in $TARGETAPKPREFIX*.apk; do
			cp $apk $BASE/mythfrontend-$TARGETVERSION.apk
		done
	fi
}

while : ; do
case "$1" in
	-no-neon|--no-neon)
		EXTRASPECS=
		NEONFLAGS=
		shift
		;;
	-unsafe-neon|--unsafe-neon)
		NEONFLAGS="$NEONFLAGS -funsafe-math-optimizations"
		shift
		;;
	-cortex-a9|--cortex-a9)
		CPU=cortex-a9
		shift
		;;
	-cpus|--cpus)
		shift
		NCPUS=$1
		shift
		;;
	--arm)
		shift
		ARM64=0
		;;
	--arm64)
		shift
		ARM64=1
		;;
	"")
		break
		;;
	-*)
		echo "unknown option $1"
		exit 1
		;;
	*)
		break
		;;
esac
done

if [ $ARM64 == 1 ]; then
	MYMYTHBUILDBASEPATH=build64
	INSTALLROOT=$BASE/mythinstall64
	export MYTHINSTALLROOT=$INSTALLROOT
	SYSROOT=$ANDROID_NDK/my-android-toolchain64/sysroot
	SYSINC=$ANDROID_NDK/my-android-toolchain64
	CROSSPREFIX=$ANDROID_NDK/my-android-toolchain64/bin/aarch64-linux-android-
	export ANDROID_TARGET_ARCH=arm64-v8a
	export ANDROID_NDK_TOOLS_PREFIX=aarch64-linux-android
	ARCH=armv8-a
	ARCH=aarch64
	CPU=cortex-a53
	BUNDLE_NAME=arm64
else
	MYMYTHBUILDBASEPATH=build
	INSTALLROOT=$BASE/mythinstall
	export MYTHINSTALLROOT=$INSTALLROOT
	SYSROOT=$ANDROID_NDK/my-android-toolchain/sysroot
	SYSINC=$ANDROID_NDK/my-android-toolchain
	CROSSPREFIX=$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-
	export ANDROID_TARGET_ARCH=armeabi-v7a
	export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
	ARCH=armv7-a
	CPU=armv7-a
	BUNDLE_NAME=arm
fi

if [ -z "$MYTHLIBVERSION" ]; then
	export MYTHLIBVERSION=30
fi
export MYTHINSTALLLIBCOMMON=$MYTHINSTALLROOT/lib/
export MYTHINSTALLLIB=$MYTHINSTALLROOT/lib/
#export MYTHINSTALLLIB=$MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/
#export MYTHINSTALLLIBCOMMON=lib/
#export MYTHINSTALLLIB=lib/
export MYTHPACKAGEBASE=$BASE
export QTBASE=$INSTALLROOT/qt
export ANDROID_INSTALL_LIBS="/lib"

PATH="$INSTALLROOT/bin:$PATH"

MYMYTHBUILDPATH=$MYMYTHBUILDBASEPATH/mythtv

export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$INSTALLROOT/lib/pkgconfig:$INSTALLROOT/share/pkgconfig:$QTBASE/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=$INSTALLROOT

export ANDROID_EXTRA_LIBS="$INSTALLROOT"

# ant TARGETAPKPREFIX=$INSTALLROOT/bin/QtApp
TARGETAPKPREFIX=$INSTALLROOT/build/outputs/apk/myth

IGNOREDEFINES="-DIGNORE_SCHEMA_VER_MISMATCH -DIGNORE_PROTO_VER_MISMATCH"

# process command
case "$1" in
	release)
		BUNDLESIGN="--sign $KEYSTORE $KEYALIAS --storepass $KEYSTOREPASSWORD"
		RELEASE=1
		CONFIGUREBUILDTYPE=release
		DEPLOYTYPE=
		shift
		;;
	reconfig*)
		rm $MYMYTHBUILDPATH/stamp_configure_android
		shift
		;;
	"clean" )
		cd $MYMYTHBUILDPATH
		rm stamp_configure_android
		make clean
		exit 0
		;;
	"distclean" )
		cd $MYMYTHBUILDPATH
		rm stamp_configure_android
		make distclean
		cd $MYMYTHBUILDBASEPATH
		#git -C $MYMYTHPATH ls-files -o | grep -vE "kdev4|user|src" | xargs -n1 rm
		git -C $MYMYTHPATH ls-files -o | xargs -n1 rm
		exit 0
		;;
	"fresh" )
		[ -n "$MYMYTHBUILDBASEPATH" ] && rm -r $MYMYTHBUILDBASEPATH
		exit 0
		;;
	"bundle")
		bundle_apk
		exit 0
		;;
	"")
		;;
	*)
		echo "unknown command"
		exit 2
		;;
esac

if [ $SHADOW_BUILD = 1 ]; then
	rm -r $MYMYTHBUILDBASEPATH
	mkdir -p $MYMYTHBUILDBASEPATH || true
	cd $MYMYTHBUILDBASEPATH
	MYTHTVSRC=../../../mythtv/mythtv
else
	# cheap mans shadow build
	MYTHTVSRC=.
	if [ ! -e $MYMYTHBUILDBASEPATH/mythtv/stamp_shadow_android ] ; then
		rm -r $MYMYTHBUILDBASEPATH
		cp -as `readlink -f $MYMYTHPATH` $MYMYTHBUILDBASEPATH
		#rm -r $MYMYTHBUILDBASEPATH/.git
		pushd $MYMYTHBUILDBASEPATH
		git -C $MYMYTHPATH ls-files -o | grep -vE "kdev4|user|src" | xargs -n1 rm
		popd
		SOURCE_VERSION=$(git -C $MYMYTHPATH describe --dirty || git -C $MYMYTHPATH describe || echo Unknown)
		BRANCH=$(git -C $MYMYTHPATH branch --no-color | sed -e '/^[^\*]/d' -e 's/^\* //' -e 's/(no branch)/exported/')
		pushd $MYMYTHBUILDPATH
		rm EXPORTED_VERSION || true
		rm VERSION || true
		popd
		touch $MYMYTHBUILDBASEPATH/mythtv/stamp_shadow_android
	fi
	pwd
	if [ ! -e $MYMYTHBUILDBASEPATH/mythtv/stamp_configure_android ] ; then
		cd $MYMYTHBUILDPATH
		echo "Format" > EXPORTED_VERSION
		echo "SOURCE_VERSION=\"$SOURCE_VERSION\"" > VERSION
		echo "BRANCH=\"$BRANCH\"" >> VERSION
		export MYTHLIBVERSION=${SOURCE_VERSION%%-*}
		export MYTHLIBVERSION=${MYTHLIBVERSION#v}
	else
		cd $MYMYTHBUILDPATH
		source VERSION
		export MYTHLIBVERSION=${SOURCE_VERSION%%-*}
		export MYTHLIBVERSION=${MYTHLIBVERSION#v}
	fi
	export GIT_CEILING_DIRECTORIES="`readlink -f ..`"
fi

pwd
$MYTHTVSRC/configure --help
if [ ! -e stamp_configure_android ] ; then
	[ -n "$CPU" ] && CPU="--cpu=$CPU"
$MYTHTVSRC/configure \
	--disable-ccache \
	--cross-prefix=$CROSSPREFIX \
	--arch=$ARCH $CPU \
	--target-os=android \
	--compile-type=$CONFIGUREBUILDTYPE \
	--prefix=/ \
	--runprefix=/ \
	--libdir-name=lib \
	--enable-backend \
	--enable-cross-compile \
	--sysroot=$SYSROOT \
	--extra-cflags="-D__ANDROID_API__=$ANDROID_NDK_API -DANDROID -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS " \
	--extra-cxxflags="-D__ANDROID_API__=$ANDROID_NDK_API -DANDROID -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS " \
	--qmake=$QTBASE/bin/qmake \
	--qmakespecs="android-g++ $EXTRASPECS" \
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
	--enable-opengl-video \
	--enable-opengl \
	--without-bindings=perl,python,php \
	&& touch stamp_configure_android

	#--disable-opengl-themepainter \
	#--disable-qtwebkit \
	#--arch=arm7a --cpu=$CPU \

fi

if [ -e stamp_configure_android ] ; then
	set -e
	echo "*** make ***"
	make -j$NCPUS
	echo "*** make install ***"
	make install INSTALL_ROOT=$INSTALLROOT
	echo "*** deploy-extra-libs ***"
	deploy-extra-libs
	echo "*** androiddeployqt ***"
	bundle_apk
fi

