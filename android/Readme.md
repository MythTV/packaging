Android Mythfrontend Build Procedure
------------------------------------

Currently there is no automated way to get all dependencies and build an apk in one step.
NOTE: The build platform is linux

1. Clone and configure the repos.
   * mkdir workdir
   * cd workdir
   * git clone git@github.com/packaging.git
   * git clone git@github.com/mythtv.git
   * cd packaging/android
   * If building for arm64, run "echo ARM64=1 >make.inc".

2. Get Android Studio, SDK and NDK.
   * Get Android Studio from https://developer.android.com/studio/index.html
     and install it into ~/android/android-studio.
   * After Android Studio is installed, use it to install the Android SDK and NDK.
     * In Android Studio, choose Configure / SDK Manager.
     * INstall the desired SDK versions.  Lollipop, Marshmallow and Nougat are
       the likely choices right now.
     * Install the desired SDK Tools.  CMake and the NDK are the main ones.
   * For the NDK
     * Get android-ndk-r15c-linux-x86_64.bin and install it in ~/android too.
     * Symlink it as android-ndk -> android-ndk-r15c.
     * android-ndk-16b currently does not work due to missing headers.
   * if you want to build a release apk, you need to create a key.
   * Copy android-utilities/* to ~/android
      * cp android-utilities/setenv.sh ~/android
   * Create a toolchain for the correct version.  See maketoolchain.sh for this.
     SDK 21 is the default

   You should have a dir structure like this after you are done:
```
   ~/android
	android-ndk -> android-ndk-r15c
	android-ndk-r15c
	android-sdk-linux
	android-studio
	xxxxx-release.keystore
	xxxxx.keystore
	maketoolchain.sh
	setenv.sh
```

3. Other dependencies
  * bison
  * flex
  * gradle
    * this is downloaded on demand so is self fulfilling.

4. Fetch and build all the libraries
   In workdir/packaging/android, run
```
   ./makelibs.sh all
```

5. Build MythTV (debug by default)
   In workdir/packaging/android, run
```
   ./mythbuild.sh
```

Cross your fingers and hope I didnt miss a step.

Debugging
---------

* Enable debugging on your target device.  Depending on the device, this might
  require enabling Developer Options first, then USB Debugging and finally
* Network Debugging.
  * install apk with 'adb install -r mythfrontend*.apk'
  * ndk-gdb --launch --delay=0 -p mythinstall
  * or use supplied gdb.sh script

Setting up the Options
----------------------

1. In Setup
  * In Appearance, set render to Qt
    * video will not work with this mode enabled
    * try opengl2 but YMMV
  * In Wizard, Audio, test speakers


Previous Setup
--------------
1. Select country/language
2. Add DB details.
  * Note: Un check ping server otherwise it won't work. There is no ping
3. In Setup (you can only go back with Qt painter painter but video doesnt work with Qt theme Painter)
  * select Theme first
  * set key bindings for your back key and menu key
  * Menu to Global.Menu
  * Back to TV Playback.Back
  * Finally in Appearance set painter to OpenGL
    * After this, setup wont work properly, but playing video will
    * if you want to do intensive setup work, switch back to Qt painter temporarily

Playback and LiveTV Usage
-------------------------

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

YMMV
Mark
