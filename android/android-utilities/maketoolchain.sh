#!/bin/bash

[ -z "$SDKVERSION" ] && SDKVERSION=21
[ -z "$GCCVERSION" ] && GCCVERSION=4.9

cd android-ndk
build/tools/make-standalone-toolchain.sh --platform=android-$SDKVERSION --install-dir=`pwd`/my-android-toolchain --arch=arm --toolchain=arm-linux-androideabi-$GCCVERSION
