#!/bin/bash

BASE=`pwd`
source ~/android/setenv.sh

SHADOW_BUILD=0
ARM64=0
BUILD_PLUGINS=0

export ANDROID_NDK_ROOT=$ANDROID_NDK

export NCPUS=$(nproc)

[ -e make.inc ] && source make.inc

if [ $ARM64 == 1 ]; then
	TOOLCHAIN_SUFFIX=64
	export ANDROID_TARGET_ARCH=arm64-v8a
	export ANDROID_NDK_TOOLS_PREFIX=aarch64-linux-android
	export SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm64
	ARCH=armv8-a
	ARCH=aarch64
	CPU=cortex-a53
	BUNDLE_NAME=arm64
	LIB_ANDROID_REL_PATH="lib"
else
	if [ $ANDROID_NATIVE_API_LEVEL -gt 19 ]; then
		TOOLCHAIN_SUFFIX=
	else
		TOOLCHAIN_SUFFIX=old
	fi
	export ANDROID_TARGET_ARCH=armeabi-v7a
	export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
	export SYSROOTARCH=$ANDROID_NDK/platforms/$ANDROID_NDK_PLATFORM/arch-arm
	ARCH=armv7-a
	CPU=armv7-a
	BUNDLE_NAME=arm$TOOLCHAIN_SUFFIX
	LIB_ANDROID_REL_PATH="lib/$ARCH"
fi

INSTALLROOT=$BASE/mythinstall$TOOLCHAIN_SUFFIX
export MYTHINSTALLROOT=$INSTALLROOT
SYSROOT=$ANDROID_NDK_TOOLCHAIN_PATH/sysroot
export ANDROID_NDK_TOOLCHAIN_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
CROSSPATH=$ANDROID_NDK_TOOLCHAIN_PATH/bin 
CROSSPATH2=$CROSSPATH/$ANDROID_NDK_TOOLS_PREFIX- 

#cd $MYTHINSTALLROOT/lib
cd $MYTHINSTALLROOT/libs/$ANDROID_TARGET_ARCH

perl -e "$(cat <<'EOF'
my %scanned;
my %libs;

$priority = 1;

@elf = split /\n/, `$ENV{"CROSSPATH2"}readelf -d libplugins_* ../../bin/mythfrontend* ../bin/mythfrontend* 2>&1`;
foreach $line (@elf) {
	$line =~ /NEEDED.*\[([^\]]*)\]/ and do {
		$scanned{$1} = 0;
		$libs{$1} = $priority;
		$priority++;
		next;
	};
}

$done = 0;
while (!$done) {
	$done = 1;
	# print "pass\n";
	outside: foreach $key (keys(%libs)) {
		if ($scanned{$key} == 0) {
			@elf = split /\n/, `$ENV{"CROSSPATH2"}readelf -d $key 2>&1`;
			foreach $line (@elf) {
				$line =~ /No such file/ and do {
					$scanned{$key} = "not found";
					# print "not found $key\n";
					next outside;
				};
				$line =~ /NEEDED.*\[([^\]]*)\]/ and do {
					$lib =$1;
					if (!exists($libs{$lib})) {
						# print "new lib $lib\n";
						$libs{$lib} = $priority;
						$scanned{$lib} = 0;
						$done = 0;
					} else {
						$libs{$lib} = $priority;
					}
					$priority++;
				};
			}
			if ($scanned{$key} == 0) {
				$scanned{$key} = "";
			}
		}
	}
}

foreach $key (sort(keys(%libs))) {
	print "$key $libs{$key} $scanned{$key}\n";
}

EOF
)"

#$CROSSPATH/ld.lld --help
