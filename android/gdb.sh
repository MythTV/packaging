#!/bin/bash

. ~/android/setenv.sh

[ ! -d so ] && mkdir so
if [ ! -f so/app_process ]; then
	pushd so
	adb pull /system/bin/app_process
	popd
fi
cp `find mythtv/mythtv -name "*.so"` so/

#$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb -ix gdbinit so/app_process "$@"
exec $ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb so/app_process -x gdbinitandroid "$@"

