#!/bin/bash

if [ -n "$1" ]; then
MPID=`~/android/android-sdk-linux/platform-tools/adb shell ps | grep mythfrontend | cut -c11-16`
echo "MPID is $MPID"
~/android/android-sdk-linux/platform-tools/adb shell su -c /data/data/org.mythtv.mythfrontend/lib/gdbserver :3333 --attach $MPID
else
MPID=`~/android/android-sdk-linux/platform-tools/adb shell ps w | grep mythfrontend | cut -c-5`
~/android/android-sdk-linux/platform-tools/adb shell /data/data/org.mythtv.mythfrontend/lib/gdbserver :3333 --attach $MPID
fi
#~/android/android-sdk-linux/platform-tools/adb shell /mnt/asec/org.mythtv.mythfrontend-1/lib/gdbserver :3333 --attach $MPID

