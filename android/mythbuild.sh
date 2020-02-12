#!/bin/bash

BASE=`pwd`
ARM64=0
source android-utilities/setenv.sh

SHADOW_BUILD=0
BUILD_PLUGINS=0

export ANDROID_NDK_ROOT=$ANDROID_NDK

MYMYTHPATH="`readlink -f ../../mythtv`"
export NCPUS=$(nproc)

[ -e make.inc ] && source make.inc

export ANDROID_TARGET_ARCH=armeabi-v7a
export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi

#CFLAGS='-march=armv7-a -mfloat-abi=softfp'
#CFLAGS='-march=armv7-a -mfloat-abi=softfp -mfpu=neon'
#LDFLAGS='-Wl,--fix-cortex-a8'
# -lsupc++ if using rtti or expections
# stl use -lstdc++ or -lgnustl_shared

# http://www.kandroid.org/ndk/docs/STANDALONE-TOOLCHAIN.html

RELEASE=0
CONFIGUREBUILDTYPE="debug --enable-small"
NEONFLAGS=
#NEONFLAGS="-mfpu=neon"
ARCH=armv7-a
#CPU=armv7-a
#CPU=cortex-a53
DEPLOYTYPE="--debug"

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
	--oldarm)
		shift
		ARM64=0
		ANDROID_NATIVE_API_LEVEL=19
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
	--plugins)
		shift
		BUILD_PLUGINS=1
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

# This is here instead of defaulted at the beginning because
# I want to be able to export it ahead of time instead of
# passing in sdk parameter.
if [[ "$ANDROID_NATIVE_API_LEVEL" == "" ]] ; then
    export ANDROID_NATIVE_API_LEVEL=29
fi    

export ANDROID_NDK_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL

if [ $ARM64 == 1 ]; then
	TOOLCHAIN_SUFFIX=64
	export ANDROID_TARGET_ARCH=arm64-v8a
	export ANDROID_NDK_TOOLS_PREFIX=aarch64-linux-android
	export ANDROID_NDK_TOOLS_CC_PREFIX=$ANDROID_NDK_TOOLS_PREFIX
	export SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm64
	ARCH=armv8-a
	ARCH=aarch64
	CPU=cortex-a53
	BUNDLE_NAME=arm64
	LIB_ANDROID_REL_PATH="lib"
else
	if [ $ANDROID_NATIVE_API_LEVEL -gt 19 ]; then
		TOOLCHAIN_SUFFIX=
	else
		TOOLCHAIN_SUFFIX=old
	fi
	export ANDROID_TARGET_ARCH=armeabi-v7a
	export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
	export ANDROID_NDK_TOOLS_CC_PREFIX=armv7a-linux-androideabi
	export SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm
	ARCH=armv7-a
	CPU=armv7-a
	BUNDLE_NAME=arm$TOOLCHAIN_SUFFIX
	#LIB_ANDROID_REL_PATH="lib/$ARCH"
	LIB_ANDROID_REL_PATH="lib"
fi

MYMYTHBUILDBASEPATH=build$TOOLCHAIN_SUFFIX
INSTALLROOT=$BASE/mythinstall$TOOLCHAIN_SUFFIX
export MYTHINSTALLROOT=$INSTALLROOT
export ANDROID_NDK_TOOLCHAIN_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
SYSROOT_BASE=$ANDROID_NDK/sysroot
SUPPORT_INC=$ANDROID_NDK/sources/android/support/include
SYSROOT=$ANDROID_NDK_TOOLCHAIN_PATH/sysroot
CROSSPATH=$ANDROID_NDK_TOOLCHAIN_PATH/bin
CROSSPATH2=$CROSSPATH/$ANDROID_NDK_TOOLS_PREFIX-
CROSSPATH3=$CROSSPATH/$ANDROID_NDK_TOOLS_CC_PREFIX${ANDROID_NATIVE_API_LEVEL}-
CROSSCC=$ANDROID_NDK_TOOLS_CC_PREFIX${ANDROID_NATIVE_API_LEVEL}-clang
LIB_ANDROID_PATH="$ANDROID_NDK_TOOLCHAIN_PATH/$ANDROID_NDK_TOOLS_PREFIX/$LIB_ANDROID_REL_PATH"

EXTRASPECS="CONFIG+=single_arch CONFIG+=rtti CONFIG+=exceptions ANDROID_ABIS=$ANDROID_TARGET_ARCH -after QMAKE_CFLAGS-=-mfpu=vfp QMAKE_CXXFLAGS-=-mfpu=vfp QMAKE_LFLAGS*=-rdynamic QMAKE_LFLAGS*=-frtti" # QMAKE_CXXFLAGS+=-frtti QMAKE_CXXFLAGS+=-fexceptions QMAKE_LFLAGS+=-frtti"
EXTRA_ANDROID_LIBS="libcrystax.so libpng.so libjpeg.so"
#EXTRASPECS="$EXTRASPECS -d 1"

if [ -z "$MYTHLIBVERSION" ]; then
	export MYTHLIBVERSION=31
fi
export MYTHINSTALLLIBCOMMON=$MYTHINSTALLROOT/lib/
export MYTHINSTALLLIB=$MYTHINSTALLROOT/lib/
export MYTHPACKAGEBASE=$BASE
export QTBASE=$INSTALLROOT/qt
export ANDROID_INSTALL_LIBS="/lib"

PATH="$INSTALLROOT/bin:$PATH"

MYMYTHBUILDPATH=$MYMYTHBUILDBASEPATH/mythtv

export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$INSTALLROOT/lib/pkgconfig:$INSTALLROOT/share/pkgconfig:$QTBASE/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=$INSTALLROOT
export PKG_CONFIG_SYSROOT_DIR=

export ANDROID_EXTRA_LIBS="$INSTALLROOT"

TARGETAPKPREFIX=$INSTALLROOT/build/outputs/apk/myth

# if you want to ignore mismatch please add this to your buildrc file
#IGNOREDEFINES="-DIGNORE_SCHEMA_VER_MISMATCH -DIGNORE_PROTO_VER_MISMATCH"
BUNDLESIGN="--sign $KEYSTORE $KEYALIAS --storepass $KEYSTOREPASSWORD"

build_log=build_summary.log
date | tee -a $build_log
echo mythbuild.sh | tee -a $build_log
echo ANDROID_NATIVE_API_LEVEL [SDK]: $ANDROID_NATIVE_API_LEVEL | tee -a $build_log
echo ARM64: $ARM64 | tee -a $build_log
echo sign $KEYSTORE $KEYALIAS | tee -a $build_log

# process command
case "$1" in
	release)
		BUNDLESIGN="--sign $KEYSTORE $KEYALIAS --storepass $KEYSTOREPASSWORD"
		RELEASE=1
		CONFIGUREBUILDTYPE=profile
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
		git -C $MYMYTHPATH ls-files -o | xargs -n1 rm
		exit 0
		;;
	"fresh" )
		[ -n "$MYMYTHBUILDBASEPATH" ] && rm -r $MYMYTHBUILDBASEPATH
		if [ -d "$INSTALLROOT" ]; then
			rm -rf "$INSTALLROOT"
		fi
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

function deploy-extra-libs() {
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
	APP_PLATFORM := android-$ANDROID_NATIVE_API_LEVEL
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

function bundle_apk() {
	mkdir -p $MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/ || true
	for i in mythfrontend ; do
		cp $MYTHINSTALLROOT/bin/$i $MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/lib${i}_$ANDROID_TARGET_ARCH.so
	done
	# plugins are not automatically installed so copy them
	for i in $MYTHINSTALLROOT/lib/libmythpluginmyth{archive,netvision,news,browser,game,music,zoneminder}.so \
		$MYTHINSTALLROOT/lib/libmyth{archivehelper,fillnetvision}.so \
		$MYTHINSTALLROOT/lib/lib{ogg,vorbis,vorbisfile,vorbisenc,FLAC,fontconfig,icui18n60,icuuc60,icudata60,icudata60,iconv,ass,fribidi}.so \
		$QTBASE/lib/libQt5{OpenGL,WebKitWidgets,WebKit,Sensors,Positioning,MultimediaWidgets,Multimedia,PrintSupport,Quick,Qml,WebChannel}.so \
		; do
		if [ -e "$i" ]; then
			cp "$i" "$MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH/"
		fi
	done
	VERSIONNAME=$(date +"%F" | tr -d '-')-$BUNDLE_NAME-$(grep "define MYTH_SOURCE_VERSION" libs/libmythbase/version.h | cut -d' ' -f 3 | tr -d '"')
        # TODO: Eventually do something reasonable with versionCode.
	VERSIONCODE=1

	extraedit=
	if [ $ANDROID_NATIVE_API_LEVEL -le 19 ] ; then
		extraedit='s~android:banner="@drawable/banner"~~'
	fi
	# Setup the real Android versionName and versionCode..
	sed "s/\(android:versionName\)=\"1.0\"/\1=\"$VERSIONNAME\"/
		 s/\(android:versionCode\)=\"1\"/\1=\"$VERSIONCODE\"/
		$extraedit" \
		../../AndroidManifest.xml.in \
		>../../android-package-source/AndroidManifest.xml

	cat programs/mythfrontend/android-mythfrontend-deployment-settings.json
	$QTBASE/bin/androiddeployqt \
		--output $INSTALLROOT \
		$DEPLOYTYPE \
		--verbose \
		--android-platform $ANDROID_NDK_PLATFORM \
		--input programs/mythfrontend/android-mythfrontend-deployment-settings.json \
		--apk $BASE/mythfrontend-$VERSIONNAME.apk \
		--debug \
		--jdk $JDK_PATH $BUNDLESIGN

	if [ $? -ne 0 ]; then
		echo "Error androiddeployqt result is $?"
	else
		echo "*** copy apk to $BASE/mythfrontend-$VERSIONNAME.apk ***"
		#for apk in $TARGETAPKPREFIX*.apk; do
		#	cp $apk $BASE/mythfrontend-$VERSIONNAME.apk
		#done
	fi
}

if [ ! -d ${INSTALLROOT} ]; then
    rm -rf ${INSTALLROOT} ${INSTALLROOT}.tmp
    cp -al ${INSTALLROOT/mythinstall/libsinstall} ${INSTALLROOT}.tmp
    mv ${INSTALLROOT}.tmp ${INSTALLROOT}
fi

if [ $SHADOW_BUILD = 1 ]; then
	rm -r $MYMYTHBUILDBASEPATH
	mkdir -p $MYMYTHBUILDBASEPATH || true
	cd $MYMYTHBUILDBASEPATH
	MYTHTVSRC=../../../mythtv/mythtv
else
	# poor man's shadow build
	MYTHTVSRC=.
	SOURCE_VERSION=$(git -C $MYMYTHPATH describe --dirty || git -C $MYMYTHPATH describe || echo Unknown)
	BRANCH=$(git -C $MYMYTHPATH branch --no-color | sed -e '/^[^\*]/d' -e 's/^\* //' -e 's/(no branch)/exported/')
	if [ ! -e $MYMYTHBUILDBASEPATH/mythtv/stamp_shadow_android ] ; then
		rm -r $MYMYTHBUILDBASEPATH
		cp -as `readlink -f $MYMYTHPATH` $MYMYTHBUILDBASEPATH
		pushd $MYMYTHBUILDBASEPATH
		git -C $MYMYTHPATH status --ignored --porcelain | grep '!!' | sed 's/!!//' | xargs -n1 rm -fr
		popd
 		cp -asn $MYMYTHPATH/mythtv/android-package-source/* $PWD/android-package-source/
		touch $MYMYTHBUILDBASEPATH/mythtv/stamp_shadow_android
	fi
	pushd $MYMYTHBUILDPATH
	rm EXPORTED_VERSION VERSION
	echo "Format" > EXPORTED_VERSION
	echo "SOURCE_VERSION=\"$SOURCE_VERSION\"" > VERSION
	echo "BRANCH=\"$BRANCH\"" >> VERSION
	popd
	pwd
	cd $MYMYTHBUILDPATH
	export MYTHLIBVERSION=${SOURCE_VERSION%%-*}
	export MYTHLIBVERSION=${MYTHLIBVERSION#v}
	export MYTHLIBVERSION=${MYTHLIBVERSION%%.*}
	export GIT_CEILING_DIRECTORIES="`readlink -f ..`"
fi

pwd
$MYTHTVSRC/configure --help
if [ ! -e stamp_configure_android ] ; then
	#[ -n "$CPU" ] && CPU="--cpu=$CPU"
	[ -n "$CPU" ] && CPU=
$MYTHTVSRC/configure \
	--disable-ccache \
	--cross-prefix="$CROSSPATH2" \
	--cross-prefix-cc="$CROSSPATH3" \
	--arch=$ARCH $CPU \
	--target-os=android \
	--cc="clang" \
	--cxx="clang++" \
	--enable-set-cc-default \
	--compile-type=$CONFIGUREBUILDTYPE \
	--pkg-config=$(which pkg-config) \
	--prefix=/ \
	--runprefix=/ \
	--libdir-name=lib \
	--enable-backend \
	--enable-cross-compile \
	--sysroot=$SYSROOT \
	--sysinclude="no-special-cec-inc-path" \
	--extra-cflags="-D__ANDROID_API__=$ANDROID_NATIVE_API_LEVEL -DANDROID -I$SYSROOT/usr1/include -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS -rdynamic " \
	--extra-cxxflags="-D__ANDROID_API__=$ANDROID_NATIVE_API_LEVEL -I$SYSROOT/usr1/include/c++/v1 -I$SYSROOT/usr1/include -DANDROID -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS -rdynamic " \
	--extra-ldflags="-rdynamic -Wl,-rpath-link=$INSTALLROOT/lib -Wl,-rpath-link=$SYSROOTARCH/usr/lib -Wl,-rpath-link=$SYSROOT/usr/lib" \
	--qmake=$QTBASE/bin/qmake \
	--qmakespecs="android-clang $EXTRASPECS" \
	--disable-qtdbus \
	--disable-qtwebkit \
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
	--disable-mheg \
	--disable-vdpau \
	--disable-vaapi \
	--disable-dxva2 \
	--enable-opengl \
	--without-bindings=perl,python,php \
	&& touch stamp_configure_android

fi

make_plugins() {
	pushd ../mythplugins
	if [ ! -e stamp_configure_android ] ; then
		./configure \
			--compile-type=debug \
			--pkg-config=$(which pkg-config) \
			--prefix=/ \
			--runprefix=/ \
			--libdir-name=lib \
			--sysroot=$SYSROOT \
			--mythroot=$INSTALLROOT \
			--extra-cflags="-D__ANDROID_API__=$ANDROID_NATIVE_API_LEVEL -DANDROID -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS " \
			--extra-cxxflags=" -D__ANDROID_API__=$ANDROID_NATIVE_API_LEVEL -DANDROID -I$INSTALLROOT/include -I$QTBASE/include $IGNOREDEFINES $NEONFLAGS " \
			--extra-ldflags="-Wl,-rpath-link,$INSTALLROOT/lib" \
			--qmake=$QTBASE/bin/qmake \
			--qmakespecs="android-g++ $EXTRASPECS" \
			&& touch stamp_configure_android

	fi

	make -j$NCPUS

	make install INSTALL_ROOT=$INSTALLROOT

	popd
}

if [ -e stamp_configure_android ] ; then
	set -e
	echo "*** make ***"
	make -j$NCPUS
	echo "*** make install ***"
	make install INSTALL_ROOT=$INSTALLROOT
	if [ $BUILD_PLUGINS == 1 ]; then
		echo "*** make plugins ***"
		make_plugins
	fi
	echo "*** deploy-extra-libs ***"
	deploy-extra-libs
	echo "*** androiddeployqt ***"
	bundle_apk
fi

