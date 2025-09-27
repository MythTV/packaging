# Compiling MythTV via Ansible and MacPorts
This is directory contains a packaging script for MythFrontend for MacOS and a codesigning utility.
The use of this script is documented on the mythtv wiki here:
https://www.mythtv.org/wiki/Building_MythFrontend_on_Mac_OS_X

* **compileMythtvAnsible_cmake.zsh** - A script that compiles and installs all mythtv binaries using cmake. The script downloads and installs any mythtv/mythplugins dependencies as specified in the mythtv ansible repo via MacPorts.  It also clones the appropriate ansible/mythtv/packaging git repos from github, compiles mythtv and optionally mythplugins, bundles the necessary Support libraries and files into the application, and finally generates a .dmg file for distribution.  The scripts default behavior is to build the Mythfrontend.app app bundle, but a run switch
is available to install all mythtv binaries (e.g. mythfrontend, mythbackend, mythutil) as unix executables (vs. app bundles) into a user specified path.

Before running the script, the user must have Xcode, Xcode Command Line Tools, and MacPorts
or Hombrew working on their system.

## Step One: Install Xcode, and Xcode Command Line Tools and either Macports or Homebrew
Both Xcode and Xcode Command Line Tools are available for installation via the Apple App Store.

Make sure to accept the xcode license by running:
>  sudo xcodebuild -license

## Step Two: Install either Macports or Homebrew
### Macports Instructions
These instructions walk you through installing Xcode, the Xcode Command Line Tools, and MacPorts.
Follow MacPorts' directions here: https://www.macports.org/install.php

* Remember to run update the ports tree after installing MacPorts
> sudo port -v selfupdate

### Homebrew Instructions
Follow Homebrew's directions here: https://brew.sh/

* Remember to run update Homebrew after installation
> brew update

## Step Two: Run the compileMythtvAnsible.zsh Script
Run "compileMythtvAnsible_cmake.zsh".

The script automatically performs the following steps:
1. Sets up the build directory structure
1. Installs ansible-playbook via MacPorts or Homebrew
1. Clones the MythTV ansible git repository
1. Installs MythTV compile requirements and their dependencies via ansible/macports/homebrew/pip/cpanm
1. Clones the MythTV git repository
1. Clones the MythTV Packaging git repository
1. Configures, builds, and installs MythTV to a user specified directory
1. Optionally Configures, builds, and installs MythPlugins
1. Optionally generates the mythfrontend.app bundle
1. Optionally code signs and notarizes the app bundle
1. Optionally Packages mythfrontend.app into a .dmg file
