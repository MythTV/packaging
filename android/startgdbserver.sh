#!/bin/bash

ADB=${HOME}/Android/Sdk/platform-tools/adb

if [ -n "$1" ]; then
MPID=`${ADB} shell ps | grep mythfrontend | cut -c11-16`
echo "MPID is $MPID"
${ADB} shell su -c /data/data/org.mythtv.mythfrontend/lib/gdbserver :3333 --attach $MPID
else
MPID=`${ADB} shell ps w | grep mythfrontend | cut -c-5`
${ADB} shell /data/data/org.mythtv.mythfrontend/lib/gdbserver :3333 --attach $MPID
fi
#${ADB} shell /mnt/asec/org.mythtv.mythfrontend-1/lib/gdbserver :3333 --attach $MPID

