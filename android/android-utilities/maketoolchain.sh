#!/bin/bash

usage() {
	cat <<END
$1 [options]
Options:
	--force		force overwrite of existing toolchains
	--sdkver	set sdk version, default 21
	--gccversion	set gcc version, default 4.9, no others exist
	--stl		set c++ stl to use: gnustl (default), libc++, stlport
	--help		this help
END
}

while : ; do
	case "$1" in
		--force)
			shift
			FORCE=--force
			;;
		--stl)
			shift
			STL=$1
			shift
			;;
		--sdkver)
			shift
			SDKVERSION=$1
			shift
			;;
		--gccver)
			shift
			GCCVERSION=$1
			shift
			;;
		--help)
			usage "$0"
			exit 0
			;;
		-*)
			echo "Invalid option: $1"
			usage "$0"
			exit 1
			;;
		*)
			break
			;;
	esac
done

[ -z "$SDKVERSION" ] && SDKVERSION=21
[ -z "$STL" ] && STL=gnustl
[ -z "$GCCVERSION" ] && GCCVERSION=4.9

cd android-ndk
for i in "" 64; do
	./build/tools/make-standalone-toolchain.sh \
		--platform=android-$SDKVERSION \
		--verbose \
		--install-dir=`pwd`/my-android-toolchain$i \
		--stl=$STL \
		--arch=arm$i \
		--toolchain=arm-linux-androideabi-$GCCVERSION $FORCE
done
