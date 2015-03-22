Android Mythfrontend Build Procedure
------------------------------------

Currently there is no automated way to get all dependencies and build an apk in one step

1. clone the repos
   cd workdir
   git clone git@github.com:mspieth/packaging.git
   cd packaging/android
   git clone git@github.com:mspieth/mythtv.git

1. Get Android sdk, ndk and Qt using the online installer
   * I used Qt 5.4.1
   * You need the sdk version you are compiling to. I used 17 for 4.2.2 as minimum
     compatability level. File will be something like qt-opensource-linux-x64-1.6.0-8-online.run
   * install in ~/android as the build scripts assume its there
   * also get android-ndk-r10d-linux-x86_64.bin and install it in ~/android too.
   * also get android-cmake-master.zip and install that too in ~/android
   * if you want to build a release apk, you need to create a key.
   * modify and copy android-utilities/* to ~/android
       cp android-utilities/setenv.sh ~/android
   * create a toolchain for the correct version. see maketoolchain.sh for this. sdk 17 is the default

   You should have a dir structure like this after you are done:
   ~/android
	Qt
	android-cmake
	android-ndk -> android-ndk-r10d
	android-ndk-r10d
	android-sdk-linux
	android-studio
	digivation-release.keystore
	digivation.keystore
	maketoolchain.sh
	setenv.sh

2. Get a sufficiently suitable version of java. I used oracle-java7-jdk_7u76_amd64.deb
  * Install it and make it the active one. Note that you cant use java8.

3. Get the following tarballs and put then in ./libs and extract (tar xf) them in this directory
   1. exiv2-0.24.tar.gz
   2. freetype-2.5.5.tar.bz2
   3. lame-3.99.5.tar.gz
   4. libiconv-1.14.tar.gz
   5. mariadb-connector-c-2.1.0-src.tar.gz
   6. openssl-1.0.2.tar.gz
   7. taglib-1.9.1.tar.gz
   8. qt-everywhere-opensource-src-5.4.1.tar.xz

4. build all the libraries
   ./makelibs.sh

5. build it (debug by default)
   ./mythbuild.sh

Cross your fingers and hope I didnt miss a step.

Setting up the Options
----------------------

1. Select country/language
2. Add DB details.
  * Note: Un check ping server otherwise it wont work. There is no ping
3. In Setup (you can only go back with Qt painter painter but video doesnt work with Qt theme Painter)
  * select Theme first
  * set key bindings for your back key and menu key
  * Menu to Global.Menu
  * Back to TV Playback.Back
  * Finally in Appearance set painter to OpenGL
    * After this, setup wont work properly, but playing video will
    * if you want to do intensive setup work, switch back to Qt painter temporarily

Playback Usage
--------------

There are click zones in the playback window. The window is divided into a 3x3 grid with the
following hard coded key presses.

P    |   Up   |   Z    |   [
Left | Return | Return | Right
A    |  Down  |   Q    |   ]

A is time stretch
P is pause
Z is skip commercial
Q is skip back commercial
[ is volume down
] is volume up

note volume does not currently work but you can use the side buttons.
See tv_play.cpp regionKeyList

Also see the wiki page Ill put together on this.

YMMV
Mark
