#!/bin/bash

ANDROID_ROOT=$HOME/Android
ANDROID_ROOT=`readlink -f "$ANDROID_ROOT"`
export ANDROID_SDK=$ANDROID_ROOT/Sdk
export ANDROID_NDK=$ANDROID_ROOT/android-ndk
export ANDROID_SDK_ROOT=$ANDROID_SDK
export ANDROID_NDK_ROOT=$ANDROID_NDK
if [ $(ls -1 "$ANDROID_SDK_ROOT/build-tools" | wc -l) == 1 ] ; then
	export ANDROID_BUILD_TOOLS_REVISION=$(ls -1 $ANDROID_SDK_ROOT/build-tools | grep "^[0-9]" | tail -1)
	echo "Using discovered tools version $ANDROID_BUILD_TOOLS_REVISION"
else
	export ANDROID_BUILD_TOOLS_REVISION=29.0.2
	echo "Using hardcoded tools version $ANDROID_BUILD_TOOLS_REVISION"
fi
export JAVA_HOME=${ANDROID_ROOT}/android-studio/jre
export JDK_PATH=${JAVA_HOME}/bin

export ANDROID_KEYSTORE=$ANDROID_ROOT/sample-release.keystore
export KEYSTORE=$ANDROID_ROOT/sample-release.keystore
export KEYALIAS=sample
export KEYSTOREPASSWORD="password"

export PATH

privatepathadd() {
if [ -d "$1" ] && [[ ! $PATH =~ (^|:)$1(:|$) ]]; then
	PATH+=:$1
fi
}

privatepathadd $ANDROID_SDK/tools
privatepathadd $ANDROID_SDK/platform-tools
privatepathadd $ANDROID_NDK
privatepathadd $JDK_PATH

unset -f privatepathadd

if [[ -f buildrc ]] ; then
    . buildrc
fi
