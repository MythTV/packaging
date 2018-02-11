#!/bin/bash

. ~/android/setenv.sh

source make.inc

if [ $ARM64 == 1 ]; then
	MYGDB="$ANDROID_NDK/my-android-toolchain64/bin/ndk-gdb"
	BUILDDIR=build64
	PROJDIR=mythinstall64
	APP_PROCESS_NAME=app_process64
	LIBDIR_NAME=lib64
	LINKER_NAME=linker64
	TARGET_ARCH=arm64
	TOOLCHAIN_PREFIX=$ANDROID_NDK_ROOT/my-android-toolchain64/bin/aarch64-linux-android-
	TOOLCHAIN_PREFIX2=$ANDROID_NDK_ROOT/my-android-toolchain64/bin/
else
	MYGDB="$ANDROID_NDK/my-android-toolchain/bin/ndk-gdb"
	BUILDDIR=build
	PROJDIR=mythinstall
	APP_PROCESS_NAME=app_process32
	LIBDIR_NAME=lib
	LINKER_NAME=linker
	TARGET_ARCH=arm
	TOOLCHAIN_PREFIX=$ANDROID_NDK_ROOT/my-android-toolchain/bin/arm-linux-androideabi-
	TOOLCHAIN_PREFIX2=$ANDROID_NDK_ROOT/my-android-toolchain/bin/
fi

[ ! -d so ] && mkdir so
#if [ ! -f so/app_process ]; then
#	pushd so
#	adb pull /system/bin/app_process
#	popd
#fi
#cp `find $BUILDDIR/mythtv -name "*.so"` so/
cp -a $PROJDIR/lib/* so/
cp -a $PROJDIR/qt/lib/* so/
find $PROJDIR/qt/plugins -name "*.so" -exec cp {} so/ \;

if [ ! -e "qt5printers" ]; then
	git clone https://github.com/Lekensteyn/qt5printers.git
fi

#$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb -ix gdbinit so/app_process "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb so/app_process -x gdbinitandroid "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/gdb so/app_process -x gdbinitandroid "$@"
#$ANDROID_NDK/ndk-gdb --start --delay=0 --port=tcp:192.168.1.191:3333 so/app_process "$@"
#cd mythinstall
#$ANDROID_NDK/my-android-toolchain/bin/ndk-gdb --delay=0 "$@"
#if [ -z "$1" ]; then
#	ARGS="--start --delay=1.0 --project=$PROJDIR mythfrontend"
#fi
#IPADDR=192.168.1.188 \
#$MYGDB $ARGS "$@"

DEBUG_PORT=5039
JDB_PORT=65534
GDBCLIENT=${TOOLCHAIN_PREFIX}gdb
if [ ! -e "$GDBCLIENT" ]; then
	GDBCLIENT=${TOOLCHAIN_PREFIX2}gdb
fi
PACKAGE_NAME=org.mythtv.mythfrontend
LAUNCH_ACTIVITY=org.qtproject.qt5.android.bindings.QtActivity
START_WAIT=-D
DATA_DIR=$(adb shell run-as $PACKAGE_NAME pwd)
DEVICE_GDBSERVER=$DATA_DIR/gdbserver
DEBUG_SOCKET=$DATA_DIR/debug-socket
USE_SU=0
USE_IP=1

if ! adb shell test -e $DEVICE_GDBSERVER ; then
	#adb shell mkdir -p $(dirname $DEVICE_GDBSERVER)
	adb push ${ANDROID_NDK_ROOT}/prebuilt/android-${TARGET_ARCH}/gdbserver/gdbserver /sdcard/Download
	adb shell run-as $PACKAGE_NAME cp /sdcard/Download/gdbserver $DEVICE_GDBSERVER
	adb shell run-as $PACKAGE_NAME chmod a+x $DEVICE_GDBSERVER
fi

if ! adb shell test -e /system/bin/$APP_PROCESS_NAME ; then
	APP_PROCESS_NAME=app_process
fi
adb pull /system/bin/$APP_PROCESS_NAME so/$APP_PROCESS_NAME
echo "Pulled $APP_PROCESS_NAME from device/emulator."

adb pull /system/bin/$LINKER_NAME so/$LINKER_NAME
echo "Pulled $LINKER_NAME from device/emulator."

adb pull /system/$LIBDIR_NAME/libc.so so/libc.so
echo "Pulled /system/$LIBDIR_NAME/libc.so from device/emulator."

# also source and directory
cat <<-END > so/gdb.setup
	python
	import sys, os.path
	sys.path.insert(0, os.path.expanduser('.'))
	import qt5printers
	qt5printers.register_printers(gdb.current_objfile())
	end
	set breakpoint pending on
	file so/$APP_PROCESS_NAME
	END
if [ $USE_IP == 1 ]; then
	IPADDR=$(adb shell ifconfig | awk -F '[ \t:]+' '/inet addr:127/ { next;}; /inet addr:/ { print $4; }')
	echo "target remote $IPADDR:$DEBUG_PORT" >> so/gdb.setup
else
	echo "target remote :$DEBUG_PORT" >> so/gdb.setup
fi
cat <<-END >> so/gdb.setup
	set solib-absolute-prefix so
	set solib-search-path so
	END

adb forward --remove-all

PID=$(adb shell ps | awk "/$PACKAGE_NAME/"' { print $2; }')
if [ -z "$PID" ]; then
	echo "Launching activity: $PACKAGE_NAME/$LAUNCH_ACTIVITY"
	adb shell am start $START_WAIT -n $PACKAGE_NAME/$LAUNCH_ACTIVITY
	if [ $? != 0 ] ; then
		echo "ERROR: Could not launch specified activity: $LAUNCH_ACTIVITY"
		echo "       Use --launch-list to dump a list of valid values."
		exit 1
	fi
else
	echo "Already running"
fi

exit_handler() {
	if [ -n "$JCONNECTOR" ]; then
		kill $JCONNECTOR
	fi
	if [ $USE_SU == 1 ]; then
		adb shell su -c killall $DEVICE_GDBSERVER
	else
		adb shell run-as $PACKAGE_NAME killall $DEVICE_GDBSERVER
	fi
	adb forward --remove-all
}

waittime=50
while [ $waittime -gt 0 ] ; do
	PID=$(adb shell ps | awk "/$PACKAGE_NAME/"' { print $2; }')
	if [ -n "$PID" ]; then
		break
	fi
	sleep 0.2
	waittime=$(($waittime - 1))
done

echo "setting up jdb forward"
adb forward tcp:$JDB_PORT jdwp:$PID
echo "jdb connect..."
jdb -connect com.sun.jdi.SocketAttach:hostname=localhost,port=$JDB_PORT >/dev/null 2>/dev/null &
CONNECTOR=$!
trap exit_handler EXIT

# Launch gdbserver now
echo "Launch gdbserver now on $IPADDR:$DEBUG_PORT"
if [ $USE_IP == 1 ]; then
	if [ $USE_SU == 1 ]; then
		adb shell su -c $DEVICE_GDBSERVER $IPADDR:$DEBUG_PORT --attach $PID &
	else
		adb shell run-as $PACKAGE_NAME $DEVICE_GDBSERVER $IPADDR:$DEBUG_PORT --attach $PID &
	fi
else
	if [ $USE_SU == 1 ]; then
		adb shell su -c $DEVICE_GDBSERVER +$DEBUG_SOCKET --attach $PID &
	else
		adb shell run-as $PACKAGE_NAME $DEVICE_GDBSERVER +$DEBUG_SOCKET --attach $PID &
	fi
fi
if [ $? != 0 ] ; then
	echo "ERROR: Could not launch gdbserver on the device?"
	exit 1
fi
echo "Launched gdbserver succesfully."

# Setup network redirection
echo "Setup network redirection"
if [ $USE_IP == 1 ]; then
	true
else
	if [ $USE_SU == 1 ]; then
		sleep 2
		PUSER=$(adb shell run-as $PACKAGE_NAME lsi -ald .  | awk '{ print $3; }')
		adb shell su -c "chown $PUSER:$PUSER $DATA_DIR/$DEBUG_SOCKET"
		adb shell su -c "chmod a+rwx $DATA_DIR/$DEBUG_SOCKET"
	fi
	adb forward tcp:$DEBUG_PORT localfilesystem:$DATA_DIR/$DEBUG_SOCKET
fi
if [ $? != 0 ] ; then
	echo "ERROR: Could not setup network redirection to gdbserver?"
	echo "       Maybe using --port=<port> to use a different TCP port might help?"
	exit 1
fi

cat so/gdb.setup
echo wait
echo launch
$GDBCLIENT -x so/gdb.setup
