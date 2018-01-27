#!/bin/bash

if [[ "$BASH_SOURCE" != "$0" ]] ; then
	ANDROID_ROOT=`dirname "$BASH_SOURCE"`
	ANDROID_ROOT=`readlink -f "$ANDROID_ROOT"`
else
	ANDROID_ROOT=`dirname "$BASH_SOURCE"`
	ANDROID_ROOT=`readlink -f "$ANDROID_ROOT"`
fi
export ANDROID_SDK=$ANDROID_ROOT/android-sdk-linux
export ANDROID_NDK=$ANDROID_ROOT/android-ndk
export ANDROID_SDK_ROOT=$ANDROID_SDK
export ANDROID_NDK_ROOT=$ANDROID_NDK
export JAVA_HOME=/home/david/android/android-studio/jre/jre
export JDK_PATH=${JAVA_HOME}/bin
export ANDROID_KEYSTORE=$ANDROID_ROOT/digivation.keystore

export KEYSTORE=~/android/sample-release.keystore
export KEYALIAS=sample
export KEYSTOREPASSWORD="password"

export PATH

privatepathadd() {
if [ -d "$1" ] && [[ ! $PATH =~ (^|:)$1(:|$) ]]; then
	PATH+=:$1
fi
}

export QTBASE=$ANDROID_ROOT/Qt/5.9.1/android_armv7

privatepathadd $ANDROID_SDK/tools
privatepathadd $ANDROID_SDK/platform-tools
privatepathadd $ANDROID_NDK
privatepathadd $JDK_PATH

unset -f privatepathadd

