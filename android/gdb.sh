#!/bin/bash

# Environment variables that can be changed in setenv.sh
# or via export before running gdb.sh
# Use su - USE_SU=1
# Use IP - USE_IP=1
# If neither is set will use adb port forwarding
# Android push directory - TMPDIR=/data/local/tmp

. ~/android/setenv.sh

if [ -z "$USE_SU" ] ; then USE_SU=0 ; fi
if [ -z "$USE_IP" ] ; then USE_IP=0 ; fi
if [ -z "$TMPDIR" ] ; then TMPDIR=/data/local/tmp ; fi

source make.inc
if [ "$ARM64" == 1 ]; then
	MYGDB="$ANDROID_NDK/my-android-toolchain64/bin/ndk-gdb"
	BUILDDIR=build64
	PROJDIR=mythinstall64
	APP_PROCESS_NAME=app_process64
	LIBDIR_NAME=lib64
	LINKER_NAME=linker64
	TARGET_ARCH=arm64
	TOOLCHAIN_PREFIX=$ANDROID_NDK_ROOT/my-android-toolchain64/bin/aarch64-linux-android-
	TOOLCHAIN_PREFIX2=$ANDROID_NDK_ROOT/my-android-toolchain64/bin/
    sodir=so64
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
    sodir=so32
fi

[ ! -d $sodir ] && mkdir $sodir
#if [ ! -f $sodir/app_process ]; then
#	pushd $sodir
#	adb pull /system/bin/app_process
#	popd
#fi
#cp `find $BUILDDIR/mythtv -name "*.so"` $sodir/
cp -auv $PROJDIR/lib/* $sodir/
cp -auv $PROJDIR/qt/lib/* $sodir/
find $PROJDIR/qt/plugins -name "*.so" -exec cp -auv {} $sodir/ \;

if [ ! -e "qt5printers" ]; then
	git clone https://github.com/Lekensteyn/qt5printers.git
fi

#$ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb -ix gdbinit $sodir/app_process "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/arm-linux-androideabi-gdb $sodir/app_process -x gdbinitandroid "$@"
#exec $ANDROID_NDK/my-android-toolchain/bin/gdb $sodir/app_process -x gdbinitandroid "$@"
#$ANDROID_NDK/ndk-gdb --start --delay=0 --port=tcp:192.168.1.191:3333 $sodir/app_process "$@"
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
DATA_DIR=$(adb shell run-as $PACKAGE_NAME sh -c pwd)
# remove carriage return at end
DATA_DIR=$(echo "$DATA_DIR" | sed 's/\r$//')
DEVICE_GDBSERVER=$DATA_DIR/gdbserver
DEBUG_SOCKET=$DATA_DIR/debug-socket

rc=$(adb shell sh -c "test -e $DEVICE_GDBSERVER ; echo $?")
if [[ "$rc" != 0 ]] ; then
	#adb shell mkdir -p $(dirname $DEVICE_GDBSERVER)
	adb push ${ANDROID_NDK_ROOT}/prebuilt/android-${TARGET_ARCH}/gdbserver/gdbserver $TMPDIR
	adb shell run-as $PACKAGE_NAME cp $TMPDIR/gdbserver $DEVICE_GDBSERVER
	adb shell run-as $PACKAGE_NAME chmod a+x $DEVICE_GDBSERVER
fi

rc=$(adb shell sh -c "test -e /system/bin/$APP_PROCESS_NAME ; echo $?")
if [[ $rc != 0 ]] ; then
	APP_PROCESS_NAME=app_process
fi
adb pull /system/bin/$APP_PROCESS_NAME $sodir/$APP_PROCESS_NAME
echo "Pulled $APP_PROCESS_NAME from device/emulator."

adb pull /system/bin/$LINKER_NAME $sodir/$LINKER_NAME
echo "Pulled $LINKER_NAME from device/emulator."

adb pull /system/$LIBDIR_NAME/libc.so $sodir/libc.so
echo "Pulled /system/$LIBDIR_NAME/libc.so from device/emulator."

# also source and directory
cat <<-END > $sodir/gdb.setup
	python
	import sys, os.path
	sys.path.insert(0, os.path.expanduser('.'))
	import qt5printers
	qt5printers.register_printers(gdb.current_objfile())
	end
	set breakpoint pending on
	file $sodir/$APP_PROCESS_NAME
	END
if [ $USE_IP == 1 ]; then
	IPADDR=$(adb shell ifconfig | awk -F '[ \t:]+' '/inet addr:127/ { next;}; /inet addr:/ { print $4; }')
	echo "target remote $IPADDR:$DEBUG_PORT" >> $sodir/gdb.setup
else
	echo "target remote :$DEBUG_PORT" >> $sodir/gdb.setup
fi
cat <<-END >> $sodir/gdb.setup
	set solib-absolute-prefix $sodir
	set solib-search-path $sodir
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
	adb forward tcp:$DEBUG_PORT localfilesystem:$DEBUG_SOCKET
fi
if [ $? != 0 ] ; then
	echo "ERROR: Could not setup network redirection to gdbserver?"
	echo "       Maybe using --port=<port> to use a different TCP port might help?"
	exit 1
fi

cat $sodir/gdb.setup
echo wait
echo launch
$GDBCLIENT -n -x $sodir/gdb.setup
