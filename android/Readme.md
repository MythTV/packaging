Android Mythfrontend Build Procedure
------------------------------------

Currently there is no automated way to get all dependencies and build an apk in one step (although if you only want a build environment, using [Docker](https://github.com/MythTV/packaging/tree/master/android/docker) gets you started quite quickly).
NOTE: The build platform is linux

Prior to this step the user should go to their github.com account and create ssh keys per the documentation at [Connecting with ssh keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

1. Clone and configure the repos.
   * mkdir workdir
   * cd workdir
   * git clone git@github.com:MythTV/packaging.git
   * git clone git@github.com:MythTV/mythtv.git
   * at this point cd into the mythtv and packaging directories and checkout fixes/32 or whatever branch is desired.
   * prior to running the build the first time the git statements below are needed:

```
git config --global user.name "John Doe"
git config --global user.email "johndoe@example.com"
```
   * cd packaging/android
   * make.inc is no longer needed

2. Get Android Studio, SDK and NDK.
   * Get Android Studio from https://developer.android.com/studio/index.html
     and unpack it into $HOME/Android.

   * After Android Studio is installed, use it to install the Android SDK.
     * In Android Studio, choose More Action / SDK Manager.
     * Building mythfrontend with andriod can be problemmatic if you have the wrong versions of tools and SDK installed.
     * Install the desired SDK versions.  Install SDK 29. Uncheck the other build-tools and SDKs.
     * Select Android 8 (Oreo) API 26, Build-tools 29.0.2, NDK (Side by Side) 21.4.7075529, and CMake 3.22.1
     * By clicking "Show package details" you can select a specific version. Currently we are using the versions, NDK 21, build-tools 29. Note that setenv.sh is hardcoded for build tools 29.0.2. Make sure you install that. When that is unavailable we will have to update setenv.sh.
   * Set up links as follows, using the version of ndk that was installed.

```
cd $HOME/Android
ln -s Sdk/ndk/21.4.7075529 android-ndk
```

   * We no longer need to copy setenv.sh to ~/android
   * We no longer need to create a toolchain.
   * Create a file buildrc in the packaging/android directory for any desired overrides
   * If you want to build a release apk, you need to create a key. For more information on keys, see note at the bottom. After creating the key, add these to the end of buildrc:

```
KEYSTORE=$HOME/.android/android-release-key.jks
KEYALIAS=<key alias>
KEYSTOREPASSWORD=<key password>
BUNDLESIGN="--sign $KEYSTORE $KEYALIAS --storepass $KEYSTOREPASSWORD"
```

   * Optionally add these lines to buildrc. The ARM64 value can be set to 0 or 1 to build 32-bit or 64-bit packages. The API level can be set to 21 or 24, however for Android 5 it needs to be set at 21. 21 and 24 both work for later versions of android.

```
ARM64=0
ANDROID_NATIVE_API_LEVEL=21
```

   * If you want to override schema mismatch processing (at your own risk)
   add this to buildrc. You can also put other configure overrides in IGNOREDEFINES.

```
IGNOREDEFINES="-DIGNORE_SCHEMA_VER_MISMATCH -DIGNORE_PROTO_VER_MISMATCH"
```

   You should have a dir structure like this after you are done:

```
ls -1 $HOME/Android/
android-ndk -> Sdk/ndk/21.4.7075529
android-studio
Sdk
```

    Android studio by default installs a debug keystore in $HOME/.android/

3. Other dependencies
    * bison
    * flex
    * gperf
    * ruby
    * ant (for libbluray)
    * gettext development libraries
    * cmake
    * fontconfig
    * libtool
    * autopoint

4. Fetch and build all the libraries.
   The script downloads source to build and builds it.
   In workdir/packaging/android, run this. Set "arm" or "arm64" for the mode. If you set the sdk version and ARM64 variable in buildrc you need not set them here.

```
    make SDK=21 MODE=arm64 libs
```

   or with logging

```
    make SDK=21 MODE=arm64 libs |& tee build_lib64.log
```

   Note that branches fixes/31 and master download different library versions. If you have built libraries for one branch and then need to build another, you will have to completely clear out the prior ones. Since building the libraries takes a long time, it may be preferable to keep two copies of the packaging directory, one for each branch. (Building fixes/31 libraries without first clearing master libraries causes error "AutoPtr is not defined" when subsequently building MythTV).

   This creates some 350 MB of data in a directory called
   workdir/packaging/android/libsinstall64 (for 64bit).  Its contents
   will be copied to a directory called
   workdir/packaging/android/mythinstall64 and grow to about 2.5 GB
   when MythTV is built.

5. Build MythTV (debug by default)
   In workdir/packaging/android, run this. As for the libs, set "arm" or "arm64" for the mode. If you set the sdk version and ARM64 variable in buildrc you need not set them here.

```
   make SDK=21 MODE=arm64 apk
```

6. Other targets for make are "clean" to clean the application, "distclean" to clean the libs and application, "everything" for libs and apk.

Debugging
---------

* Enable debugging on your target device.  Depending on the device, this might
  require enabling Developer Options first, then USB Debugging and finally
* Network Debugging.
  * install apk with 'adb install -r mythfrontend*.apk'
  * ndk-gdb --launch --delay=0 -p mythinstall
  * or use supplied gdb.sh script


Setup
-----
Normal Mythfrontend setup procedures apply.

Playback and LiveTV Usage
-------------------------

These notes apply to android on a phone or tablet. When using Android TV you need to use the android TV remote. Instructions for this are in the MythTV wiki.

There are click zones in the playback window. The window is divided into a 4x3 grid with the
following configurable key presses.

* Settings Name : PlaybackScreenPressKeyMap
* Default: "P,Up,Z,],Left,Return,Return,Right,A,Down,Q,["

```
P    |   Up   |   Z    |   [
Left | Return | Return | Right
A    |  Down  |   Q    |   ]
```
* Settings Name : LiveTVScreenPressKeyMap
* Default: "P,Up,Z,S,Left,Return,Return,Right,A,Down,Q,F"

```
P    |   Up   |   Z    |   S
Left | Return | Return | Right
A    |  Down  |   Q    |   F
```

* A is time stretch
* P is pause
* Z is skip commercial
* Q is skip back commercial
* S is program guide
* F is function toggle
* [ is volume down
* ] is volume up

Also see the wiki page https://www.mythtv.org/wiki/MythTV_on_Android

For running on Android TV see https://www.mythtv.org/wiki/Android

Building Keys in Android
------------

Build keys this way:

```
keytool -genkey -v -keystore android-release-key.jks -alias mythfrontend -keyalg RSA -keysize 2048 -validity 10000
```
"keytool" comes with java. You can use any alias name; it does not have to be "mythfrontend".
It prompts for passwords and a bunch of other things.

You need to always use the same keystore when building, otherwise you have to uninstall before installing a new version. If you do not create keys it uses debug keys that come with android studio.

