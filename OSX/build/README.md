### Packaging for MacOS
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
### macports_ansible
```
This is directory contains the a packaging script for MythFrontend for MacOS and its README.txt
instructions. The use of this script is documented on the mythtv wiki here:
https://www.mythtv.org/wiki/Building_MythFrontend_on_Mac_OS_X

compileMythfrontendAnsible.zsh - A script that creates a MythFrontend.app and .dmg files.
            The script downloads and installs any mythtv/mythplugins dependencies
            as specified in the mythtv ansible repo via MacPorts.  It also clones the
            appropriate ansible/mythtv/packaging git repos from github, compiles mythtv
            and optionally mythplugins, bundles the necessary Support libraries and
            files into the application, and finally generates a .dmg file for distribution.
            This script uses osx-bundler.pl.
```
