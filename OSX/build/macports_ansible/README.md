# Compiling Mythfrontend via Ansible and MacPorts
This is directory contains the a packaging script for MythFrontend for MacOS and its README.txt
instructions. The use of this script is documented on the mythtv wiki here:
https://www.mythtv.org/wiki/Building_MythFrontend_on_Mac_OS_X

compileMythtvAnsible.zsh - A script that creates a MythFrontend.app and .dmg files.
            The script downloads and installs any mythtv/mythplugins dependencies
            as specified in the mythtv ansible repo via MacPorts.  It also clones the
            appropriate ansible/mythtv/packaging git repos from github, compiles mythtv
            and optionally mythplugins, bundles the necessary Support libraries and
            files into the application, and finally generates a .dmg file for distribution.
            This script uses osx-bundler.pl.

Before running the script, the user must have Xcode, Xcode Command Line Tools, and MacPorts
working on their system.

## Step One: Install Xcode, Xcode Command Line Tools, and MacPorts
Follow MacPorts' directions here: https://www.macports.org/install.php
These instructions will walk you through installing Xcode, the Xcode Command Line Tools, and MacPorts.

* Remember to run "sudo port -v selfupdate" after installing MacPorts to update the MacPorts repositories

## Step Two: Run the compileMythFrontendAnsible.zsh Script
Run "compileMythFrontendAnsible.zsh".

The script automatically performs the following steps:
1. Sets up the build directory structure (tries to mirror the mythtv dev team's structure)
1. Installs ansible-playbook via MacPorts
1. Clones the MythTV ansible git repository
1. Installs MythTV compile requirements and their dependencies va ansible/macports
1. Clones the MythTV git repository, applying any user specified patches to mythtv or plugins
1. Clones the MythTV Packaging git repository, applying any user specified patches
1. Configures, builds, and installs MythTV to a temp directory
1. Optionally Configures, builds, and installs MythPlugins to a temp directory
1. Deploys QT to the compiled mythfrontend.app
1. Copies the required dylibs, support data, and fonts into the app linking
1. Packages mythfrontend.app into a .dmg file

## Resolved Issues
### Python Bindings:
The latest release of Mythfrontend (dated 2020-07-25 and later) should fix the python bindings / scripts issues.  The latest builds now include a fully executable python3 and support packages inside the application (unfortunately, this is why the application size has grown significantly).  If after the latest round of fixes you are still having issues with the python based scripts follow these steps to install a local version of python3 which mirrors the currently suggested build environment (The current build uses MacPorts python38 with the binary resident here at /opt/local/bin/python3.8)

To install the MacPorts version of Python 3.8, follow these instructions:

1. [Install MacPorts](https://www.macports.org/install.php)
2. Update MacPorts `sudo port selfupdate`
3. Install Python 3.8  `sudo port install python38`
4. Tell macOS to use Python 3.8 for python  `sudo port select python python38`
5. Tell macOS to use Python 3.8 for python3  `sudo port select python3 python38`
6. Install additional python libraries `sudo port install py38-future py38-requests py38-requests-cache py38-lxml py38-oauthlib py38-curl py38-simplejson py38-wheel py38-pip py38-pymysql py38-mysqlclient`

# Why Build With MacPorts
Currently, for MythTV builds, MacPorts has all of the necessary dependencies for compiling MythTV in it's repository. For this reason alone, it significantly simplifies getting all of the dependencies installed and working without the need to maintain countless download links and specific to macOS patches.

In the past I tried to build MythTV using both manual downloads and Homebrew. The manual install process was cumbersome and filled with too many macOS related patches that it was nearly impossible to keep under control.

This lead me to use a macOS package manager. First I tried Homebew. Unfortunately, Homebrew's default QT install was missing Webkit (requiring a customer QT compile and install) and had mixed compatibility with some of the python mysql pieces.

After much sunk time spent trying to get MythTV to compile on Homebrew, I switched over to MacPorts and got the dependencies installed in very short order. Seriously - they just worked.  

If anyone is interested in trying the Homebrew route please do so. If you are successful - please make suggestions on how to update the compile script and ansible. The best way to do this is to use the mythtv [users mailing list](http://lists.mythtv.org/mailman/listinfo/mythtv-users) or [forums](https://forum.mythtv.org/).
