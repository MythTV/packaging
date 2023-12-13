### Deprecated Packaging files for MacOS
These files are used to help create and package Application for Macports.


### Utilities in current directory
```
makebundle.sh - Script to produce an application bundle with language translations, themes,
            etc.  The script uses "osx-bundler.pl" to do most of the heavy lifting

osx-bundler.pl - Perl driven general purpose application bundling utility.  This Application
            copies the library dependencies into the target application as frameworks linking
            the library paths internal to the application
```
### osx-packager
```
This is directory contains the legacy packager and for OSX and its README.txt instructions.

osx-packager.pl - A legacy script to compile and package Mythtv and Mythfrontend up to v0.27
            and possibly later versions.  This script is currently not working for v31.
```