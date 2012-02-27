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

osx-packager.pl will determine what the lowest SDKs available is and attempt to build against it.
So if you have a system with the 10.5, 10.6 and 10.7 SDK installed, it will build against the 10.5 SDK.
Having the 10.4 SDK installed will result in an early compilation failure. So either move it outside the /SDKs directory, or delete it.

I have found Qt 4.8 to fail half-way when using parallel builds. If you find that it is the case, you can either restart osx-packager.pl (it will restart where it last stopped) or run it with the setting -noparallel.
A note of warning: compile Qt using a single process is *EXTREMELY* long. On my 3.4GHz i7 iMac (the fastest currently available) we're talking several hours.
Once Qt has been built however, you won't need to rebuild it again.

On XCode 4.x with the clang/LLVM, MythTV will not compile and the compiler will crash. I found that running osx-packager.pl with the switch -debug is what is needed.

I personally compile MythTV like so:
git/packaging/OSX/build/osx-packager.pl -force -nohead -verbose -debug 

Common Troubleshooting:
Q: Qt doesn't build and error-out on some header file
A: If you've previously compiled MythFrontend.app using Qt 4.7, you are better off deleting the whole .osx-packager/build directory and all directories (except myth-git) in .osx-packager/src. Previously install 4.7 Qt header conflicts during the build of 4.8
