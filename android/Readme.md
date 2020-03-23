Android Mythfrontend Build Procedure
------------------------------------

Currently there is no automated way to get all dependencies and build an apk in one step.
NOTE: The build platform is linux

1. Clone and configure the repos.
   * mkdir workdir
   * cd workdir
   * git clone git@github.com:MythTV/packaging.git
   * git clone git@github.com:MythTV/mythtv.git
   * cd packaging/android
   * make.inc is no longer needed

2. Get Android Studio, SDK and NDK.
   * Get Android Studio from https://developer.android.com/studio/index.html
     and install it. The default location is $HOME/Android. Install it in $HOME/android or else create a link from the default location:
     
```
cd
ln -s Android android
```  
   
   * After Android Studio is installed, use it to install the Android SDK.
     * In Android Studio, choose Configure / SDK Manager.
     * Install the desired SDK versions.  Install SDK 28 and 29.
     * Install the desired SDK Tools. Select CMake, build tools and NDK (Side by Side). By clicking "Show package details" you can select a specific version. Currently we are using the latest versions, NDK 21, build-tools 29, SDK tools 26.
   * Set up links as follows, using the version of ndk that was installed.

```
cd $HOME/android
ln -s Sdk android-sdk-linux
ln -s Sdk/ndk/21.0.6113669 android-ndk
```

   * We no longer need to copy setenv.sh to ~/android
   * We no longer need to create a toolchain.
   * Create a file buildrc in the packaging/android directory for any desired overrides
   * If you want to build a release apk, you need to create a key. After creating the key, add these to the end of buildrc:

```
export KEYSTORE=$HOME/.android/android-release-key.jks
export KEYALIAS=<key alias>
export KEYSTOREPASSWORD=<key password>
```

   * Optionally add these lines to buildrc. The ARM64 value can be set to 0 or 1 to build 32-bit or 64-bit packages.

```
export ARM64=0
export ANDROID_NATIVE_API_LEVEL=24
```

   * If you want to override schema mismatch processing (at your own risk)
   add this to buildrc. You can also put other configure overrides in IGNOREDEFINES.

```
export IGNOREDEFINES="-DIGNORE_SCHEMA_VER_MISMATCH -DIGNORE_PROTO_VER_MISMATCH"
```

   You should have a dir structure like this after you are done:

```
ls -1 $HOME/android/
android-ndk -> Sdk/ndk/21.0.6113669
android-sdk-linux -> Sdk
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

4. Fetch and build all the libraries.
   The script downloads source to build and builds it.
   In workdir/packaging/android, run this. Set "arm" or "arm64" for the mode. If you set the sdk version and ARM64 variable in buildrc you need not set them here.

```
    make SDK=24 MODE=arm64 libs
```

   or with logging

```
    make SDK=24 MODE=arm64 libs |& tee build_lib64.log
```

   This creates some 350 MB of data in a directory called
   workdir/packaging/android/libsinstall64 (for 64bit).  Its contents
   will be copied to a directory called
   workdir/packaging/android/mythinstall64 and grow to about 2.5 GB
   when MythTV is built.

5. Build MythTV (debug by default)
   In workdir/packaging/android, run this. As for the libs, set "arm" or "arm64" for the mode. If you set the sdk version and ARM64 variable in buildrc you need not set them here.

```
   make SDK=24 MODE=arm64 apk
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

YMMV
Mark
