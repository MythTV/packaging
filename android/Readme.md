Android Mythfrontend Build Procedure
------------------------------------

Currently there is no automated way to get all dependencies and build an apk in one step.
NOTE: The build platform is linux

1. clone the repos
   cd workdir
   git clone git@github.com/packaging.git
   cd packaging/android
   git clone git@github.com/mythtv.git

1. Get Android sdk, ndk and Qt using the online installer
   * It currently uses Qt 5.9.1
    * File will be something like qt-opensource-linux-x64-1.6.0-8-online.run
    * not required as part of android anymore, this is fetched and built but makelibs.sh
   * You need the sdk version you are compiling to. I used 17 for 4.2.2 as minimum
     compatability level.
   * install in ~/android as the build scripts assume its there
   * also get android-ndk-r15c-linux-x86_64.bin and install it in ~/android too.
   * also get android-cmake-master.zip and install that too in ~/android
    * no longer required, its part of android
   * if you want to build a release apk, you need to create a key.
   * modify and copy android-utilities/* to ~/android
       cp android-utilities/setenv.sh ~/android
   * create a toolchain for the correct version. see maketoolchain.sh for this. sdk 17 is the default

   You should have a dir structure like this after you are done:
```
   ~/android
	Qt
	android-cmake
	android-ndk -> android-ndk-r15c
	android-ndk-r15c
	android-sdk-linux
	android-studio
	xxxxx-release.keystore
	xxxxx.keystore
	maketoolchain.sh
	setenv.sh
```

2. Get a sufficiently suitable version of java. I used oracle-java8-jdk_7u76_amd64.deb
  * Install it and make it the active one. Modify setenv.sh to change the targeted java version.
  * I'm not sure but 9 might not work so YMMV.

3. Other dependencies
  * bison
  * flex
  * ant
  * gradle
    * this is downloaded on demand so is self fulfilling.

4. fetch and build all the libraries
```
   ./makelibs.sh
```

5. build it (debug by default)
```
   ./mythbuild.sh
```

Cross your fingers and hope I didnt miss a step.

Debugging
---------

* install Wifi ADB on your target device
* install apk with 'adb install -r mythfrontend*.apk'
ndk-gdb --start --delay=0


Setting up the Options
----------------------

1. In Setup
  * In Appearance, set render to Qt
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
