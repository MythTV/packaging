#!/bin/bash

MPID=`~/android/android-sdk-linux/platform-tools/adb shell ps w | grep mythfrontend | cut -c-5`
~/android/android-sdk-linux/platform-tools/adb shell /data/data/org.mythtv.mythfrontend/lib/gdbserver :3333 --attach $MPID
#~/android/android-sdk-linux/platform-tools/adb shell /mnt/asec/org.mythtv.mythfrontend-1/lib/gdbserver :3333 --attach $MPID

