#!/bin/bash

if [ -z "$1" ]; then
	echo "Needs apk for parameter"
fi

#~/android/android-sdk-linux/platform-tools/adb install -r "$1"
adb install -r "$1"
