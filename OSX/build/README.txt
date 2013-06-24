osx-packager-qtsdk replaces the old osx-packager. You do not have to build Qt yourself any longer.

If you previously built MythFrontend using the older osx-packager, make sure you delete previously installed external dependencies with:
# rm -rf .osx-packager/build
# rm .osx-packager/src/*/.osx-{built,config}

which will force rebuilding everything.

---

1) Preliminaries

To build on Lion or Snow Leopard against SDK 10.6 or 10.7, you need XCode 4.x
To build on Snow Leaopard against 10.5, you need XCode 3.x

The build has been tested on Lion 10.7 using the newly release XCode 4.3 and on SL 10.6 using the ancient XCode 3.2 (also tested using XCode 4.2 on SL)

Unlike the previous build system, you need to have a properly setup xcode environment.
Prior to XCode 4.3, SDKs were located by default in /Developer/SDKs/. This is no longer the case, the SDKs are now self contained within the XCode 4.3 application bundle, as such the location of the SDKs will vary depending on where you stored XCode 4.3

Prior running osx-packager.pl, you have to ensure xcode is properly configured.
In a terminal, run xcode-select -print-path

With XCode <= 4.2 (includes 3.x), it should display: /Developer
With XCode 4.3, assuming the XCode.app is stored in /Applications it should read:
/Applications/Xcode.app/Contents/Developer

If xcode-select doesn't display either of these paths, you will need to adjust it with:
XCode <= 4.2:
xcode-select -switch /Developer

XCode >= 4.3:
xcode-select -switch /Applications/Xcode.app/Contents/Developer

adjust the path according to your own setup.

osx-packager-qtsdk.pl will determine what the lowest SDKs available is and attempt to build against it.
So if you have a system with the 10.5, 10.6 and 10.7 SDK installed, it will build against the 10.5 SDK.
Having the 10.4 SDK installed will result in an early compilation failure. So either move it outside the /SDKs directory, or delete it.

Using the latest version of XCode is highly recommended, at time of writing it's 4.6.2.
Newer versions of XCode ships with the latest clang/clang++ compiler.
Older versions of clang have been known to cause unexpected behaviour in h264 playback and fail to compile some myth video filters.

2) Building using pre-packaged Qt

You need to have installed either Qt SDK (64 bits only) or Qt libraries package (both 32 and 64 bits) from http://qt-project.org/downloads/

At this stage, compiling Myth against the newly released Qt 5.x hasn't been tested.
Only using Qt 4.8.x is officially supported.

2-a) Building using Qt binary package (preferred)

Get it from http://qt-project.org/downloads, and download, as of time of writing
"Qt libraries 4.8.4 for Mac (185 MB)"

Run osx-packager-qtsdk.pl with the option -qtbin /usr/bin -qtplugins /Developer/Applications/Qt/plugins.
Qt Headers must be installed.

Note that with Qt 4.6.x and Qt 4.7.x are universal 32/64 bits libraries.
Qt 4.8.x only provides 64 bits libraries.
You will not be able to compile MythFrontend in 32 bits with Qt 4.8 unless you compile Qt 4.8 from source.

Options has been tested against 4.6.x, 4.7.x and 4.8.x (With x <= 4)

2-b) Building using Qt SDK

Building against Qt SDK is the easiest, be aware that it is a big download.
Get it from http://qt.nokia.com/downloads/sdk-mac-os-cpp-offline

Perform a default install.

Run osx-packager-qtsdk.pl with the option -qtsdk ~/QtSDK/Desktop/Qt/[VERSION]/gcc where
       version is 4.8.0 (SDK 1.2) or 473 (SDK 1.1)


3) Building against Qt built from source.

Run osx-packager-qtsdk.pl with -qtsrc [VERSION]
where version is one of the following: 4.7.4, 4.8.0, 4.8.1, 4.8.2, 4.8.3 and 4.8.4

I have found Qt 4.8.0 to fail half-way when using parallel builds. If you find that it is the case, you can either restart osx-packager-qtsdk.pl (it will restart where it last stopped) or run it with the setting -noparallel.
A note of warning: compile Qt using a single process is *EXTREMELY* long. On my 3.4GHz i7 iMac (the fastest currently available) we're talking several hours.
Once Qt has been built however, you won't need to rebuild it again.

4) Compiling everything else

I personally compile MythTV like so:
git/packaging/OSX/build/osx-packager-qtsdk.pl -qtsrc 4.8.1 -force -nohead -verbose -universal
which will build the current mythtv git directory without attemption to pull new updates.

5) Common Troubleshootings:
Q: Qt doesn't build and error-out on some header file
A: If you've previously compiled MythFrontend.app using an older version of Qt, you are better off deleting the whole .osx-packager/build directory and all directories (except myth-git) in .osx-packager/src. Previously installed Qt headers conflicts during the build of newer Qt (like 4.8.0 previously installed, and build 4.8.1)

Q: mythtv configure script failed with ERROR: libmp3lame not found
A: You have built the dependencies using a different architecture. E.g build with -m32 first and are now attempting to build a 64 bits MythFrontend
   Delete .osx-packager/build and all directories (except myth-git) in .osx-packager/src. Re-run the packager with -universal. This will build both 32 and 64 bits dependencies
