# Compiling MythTV via Ansible and MacPorts
This is directory contains a packaging script for MythFrontend for MacOS and a codesigning utlity.
The use of this script is documented on the mythtv wiki here:
https://www.mythtv.org/wiki/Building_MythFrontend_on_Mac_OS_X

* **compileMythtvAnsible.zsh** - A script that compiles and installs all mythtv binaries. The script downloads and installs any mythtv/mythplugins dependencies as specified in the mythtv ansible repo via MacPorts.  It also clones the appropriate ansible/mythtv/packaging git repos from github, compiles mythtv and optionally mythplugins, bundles the necessary Support libraries and files into the application, and finally generates a .dmg file for distribution.  The scripts default behavior is to build the Mythfrontend.app app bundle, but a run switch
is available to install all mythtv binaries (e.g. mythfrontend, mythbackend, mythutil) as unix executables (vs. app bundles) into a user secified path.

* **codesignAndPackage.zsh** - A script that code signs / notarizes the Mythfrontend.app app bungle, generates a dmg file, and code signs. / notarizes the dmg bundle.

Before running the script, the user must have Xcode, Xcode Command Line Tools, and MacPorts
working on their system.

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

### Homebrew Instrutions
Follow Homebrew's directions here: https://brew.sh/

* Remember to run update Homebrew after installation
> brew update

## Step Two: Run the compileMythtvAnsible.zsh Script
Run "compileMythtvAnsible.zsh".

The script automatically performs the following steps:
1. Sets up the build directory structure (tries to mirror the mythtv dev team's structure)
1. Installs ansible-playbook via MacPorts or Homebrew
1. Clones the MythTV ansible git repository
1. Installs MythTV compile requirements and their dependencies va ansible/macports/homebrew/pip/cpanm
1. Clones the MythTV git repository, applying any user specified patches to mythtv or plugins
1. Clones the MythTV Packaging git repository, applying any user specified patches
1. Configures, builds, and installs MythTV to a temp directory
1. Optionally Configures, builds, and installs MythPlugins to a temp directory
1. Deploys QT and python to the compiled mythfrontend.app
1. Copies the required dylibs, support data, and fonts into the app linking
1. Packages mythfrontend.app into a .dmg file