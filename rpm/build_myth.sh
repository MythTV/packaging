#!/bin/bash

#
# Script for building MythTV packages from an SVN checkout.
#
# by:   Chris Petersen <rpm@forevermore.net>
#
# The latest version of this file can be found at:
#
#     http://www.mythtv.org/wiki/index.php/Mythtv-svn-rpmbuild.spec
#
# This file is intended to be sourced into bash with the "." command,
# not just run directly on the command line.  If you just run this as
# ./build_myth.sh you will not load the installmyth function into your
# environment, and will be unable to install packages should you choose
# to put off doing so immediately after compiling.
#
# Please make sure that the rpm build parameters are to your liking (a
# number of plugins are disabled by default/example in this script to
# show you that the spec is capable of compiling only those plugins that
# you wish to install).  The same goes for the installmyth function,
# which only installs those packages which I personally use.
#
# I will eventually clean up this script to add parameters and make it
# a little easier to configure/use.
#

# A function to build mythtv
    function buildmyth {
        REV="$1"
        DIR=/usr/src/mythtv-svn
        VERSION="0.22"
    # Remove the existing libmyth-devel so it doesn't confuse qmake
    # (we can't override the order of the include file path)
        echo "Removing existing libmyth-devel package to avoid conflicts"
        sudo rpm -e libmyth-devel
    # Check out or update the svn checkout
        if [ -d "$DIR" ]; then
            if [ -z "$REV" -o 0"$REV" -lt 1 ]; then
                echo "Updating svn checkout"
                REL=`svn up "$DIR"`
            else
                echo "Updating svn checkout to r$REV"
                REL=`svn up -r "$REV" "$DIR"`
            fi
        else
            if [ -z "$REV" -o 0"$REV" -lt 1 ]; then
                echo "Checking out mythtv-svn to $DIR"
                REL=`svn co http://svn.mythtv.org/svn/trunk/ "$DIR"`
            else
                echo "Checking out mythtv-svn r$REV to $DIR"
                REL=`svn co -r "$REV" http://svn.mythtv.org/svn/trunk/ "$DIR"`
            fi
        fi
        if [ $? != 0 ]; then
            echo "Problem with svn checkout"
            return $?
        fi
        REL=`echo "$REL" | grep -i revision | sed -e 's/[^0-9]\\+//g'`
        echo "SVN Revision $REL"
    # Update SPEC
        echo "Update specfile _svnver to r$REL"
        sed -i \
            -e "s,define _svnrev .\+,define _svnrev r$REL," \
            -e "s,define branch .\+,define branch trunk,"   \
            -e "s,Version:.\+,Version: $VERSION,"           \
            /usr/src/redhat/SPECS/mythtv-svn.spec
            /usr/src/redhat/SPECS/mythtv-themes-svn.spec
    # Create the appropriate tarballs
        echo "Creating tarballs from svn checkout at $DIR"
        mkdir -p /usr/src/redhat/SOURCES/{mythtv,mythtv-themes}
        cd "$DIR"
        for file in mythtv mythplugins; do
            mv "$file" "$file-$VERSION"
            tar jcf /usr/src/redhat/SOURCES/mythtv/$file-$VERSION.tar.bz2 --exclude .svn "$file-$VERSION"
            mv "$file-$VERSION" "$file"
        done
        for file in myththemes themes; do
            mv "$file" "$file-$VERSION"
            tar jcf /usr/src/redhat/SOURCES/mythtv-themes/$file-$VERSION.tar.bz2 --exclude .svn "$file-$VERSION"
            mv "$file-$VERSION" "$file"
        done
        cd -
    # Build MythTV
        rpmbuild -bb /usr/src/redhat/SPECS/mythtv-svn.spec \
            --with debug            \
            --without mytharchive   \
            --without mythflix      \
            --without mythgallery   \
            --without mythcontrols  \
            --without mythgame      \
            --without mythphone     \
            --without mythbrowser   \
            --without mythmovies    \
            --without mythnews      \
            --without mythzoneminder
    # Error?
        if [ "$?" -ne 0 ]; then
            echo "MythTV build error."
            return
        fi
    # Build MythTV Themes
        rpmbuild -bb /usr/src/redhat/SPECS/mythtv-themes-svn.spec
    # Error?
        if [ "$?" -ne 0 ]; then
            echo "MythTV Themes build error."
            return
        fi
    # Install
        echo -n "Install r$REL? [n] "
        read INST
        if [ "$INST" = "y" -o "$INST" = "Y" -o "$INST" = "yes" ]; then
            installmyth "$VERSION" "$REL"
        else
            echo "If you wish to install later, just run: installmyth \"$VERSION\" \"$REL\""
        fi
    }

# A separate function to install mythtv packages, so it can be called separately
    function installmyth {
        VERSION="$1"
        REL="$2"
        sudo rpm -Uvh --force                                                            \
            /usr/src/redhat/RPMS/x86_64/mythtv-docs-$VERSION-0.1.svn.r$REL.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/libmyth-$VERSION-0.1.svn.r$REL.*.rpm             \
            /usr/src/redhat/RPMS/x86_64/libmyth-devel-$VERSION-0.1.svn.r$REL.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/mythtv-base-themes-$VERSION-0.1.svn.r$REL.*.rpm  \
            /usr/src/redhat/RPMS/x86_64/mythtv-themes-$VERSION-0.1.svn.r$REL.*.rpm  \
            /usr/src/redhat/RPMS/x86_64/mythtv-frontend-$VERSION-0.1.svn.r$REL.*.rpm     \
            /usr/src/redhat/RPMS/x86_64/mythtv-backend-$VERSION-0.1.svn.r$REL.*.rpm      \
            /usr/src/redhat/RPMS/x86_64/mythtv-setup-$VERSION-0.1.svn.r$REL.*.rpm        \
            /usr/src/redhat/RPMS/x86_64/mythtv-common-$VERSION-0.1.svn.r$REL.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/perl-MythTV-$VERSION-0.1.svn.r$REL.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/python-MythTV-$VERSION-0.1.svn.r$REL.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/mythmusic-$VERSION-0.1.svn.r$REL.*.rpm           \
            /usr/src/redhat/RPMS/x86_64/mythvideo-$VERSION-0.1.svn.r$REL.*.rpm           \
            /usr/src/redhat/RPMS/x86_64/mythweather-$VERSION-0.1.svn.r$REL.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/mythtv-debuginfo-$VERSION-0.1.svn.r$REL.*.rpm
    }

# Actually build the packages.
    buildmyth

