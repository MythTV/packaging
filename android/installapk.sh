#!/bin/bash

if [ -z "$1" ]; then
	echo "Needs apk for parameter"
fi

#${HOME}/Android/Sdk/platform-tools/adb install -r "$1"
adb install -r "$1"
