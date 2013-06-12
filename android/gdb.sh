#!/bin/bash

. ~/android/setenv.sh

[ ! -d so ] && mkdir so
#if [ ! -f so/app_process ]; then
#	pushd so
#	adb pull /system/bin/app_process
#	popd
#fi
cp `find build/mythtv -name "*.so"` so/

#$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb -ix gdbinit so/app_process "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb so/app_process -x gdbinitandroid "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/gdb so/app_process -x gdbinitandroid "$@"
#$ANDROID_NDK/ndk-gdb --start --delay=0 --port=tcp:192.168.1.191:3333 so/app_process "$@" 
#cd mythinstall
#$ANDROID_NDK/my-android-toolchain/bin/ndk-gdb --delay=0 "$@" 
$ANDROID_NDK/my-android-toolchain/bin/ndk-gdb "$@" 

