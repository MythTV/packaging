#!/bin/bash

#
# Script for building MythTV packages from an SVN checkout.
#
# by:   Chris Petersen <rpm@forevermore.net>
#
# The latest version of this file can be found in mythtv svn:
#
#    $URL$
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

# Hard-code the version of MythTV
    VERSION="0.22"

# Branch should be "trunk" or "stable"
    BRANCH="trunk"

# Hard-code the svn checkout directory.  Leave blank to auto-detect based on
# the location of this script
    SVNDIR=""

###############################################################################

# Pass in the revision we want to build for
    REV="$1"

# Get the absolute path to this script
    ABSPATH=$(cd `dirname "$0"` && pwd)

# Check a few things for sanity
    for PROG in 'mythtv' 'mythtv-themes'; do
    # Make sure the spec exists
        if [ ! -f "$ABSPATH/$PROG.spec" ]; then
            echo "$ABSPATH/$PROG.spec does not exist"
            exit
        fi
    # Make sure we have a sources directory
        if [ ! -d "$ABSPATH/$PROG/" ]; then
            echo "$ABSPATH/$PROG does not exist"
            exit
        fi
    done

# Auto-detect the source directory?
    if [ -z "$SVNDIR" ]; then
        SVNDIR=$(dirname $(dirname "$ABSPATH"))
    elif [ ! -d "$SVNDIR" ]; then
        echo "$SVNDIR does not exist.  Please check out using:"
        echo "    svn co http://svn.mythtv.org/svn/trunk/ $SVNDIR"
        exit
    fi

# Update the SVN checkout -- make sure not to
    if [ -z "$REV" -o 0"$REV" -lt 1 ]; then
        echo "Updating svn checkout"
        svn up "$SVNDIR"/mythtv-themes 2>/dev/null >/dev/null
        REL=`svn up "$SVNDIR"/mythtv 2>/dev/null`
    else
        echo "Updating svn checkout to r$REV"
        svn up -r "$REV" "$SVNDIR"/mythtv-themes 2>/dev/null >/dev/null
        REL=`svn up -r "$REV" "$SVNDIR"/mythtv 2>/dev/null`
    fi
    if [ $? != 0 ]; then
        echo "Problem updating svn checkout"
        return $?
    fi
    REL=`echo "$REL" | grep -i revision | sed -e 's/[^0-9]\\+//g'`
    echo "Updated to SVN Revision $REL"

# Remove the existing libmyth-devel so it doesn't confuse qmake
# (we can't override the order of the include file path)
    PKG=`rpm -q libmyth-devel`
    if [ `expr match "$PKG" 'libmyth.*'` -gt 0 ]; then
        echo "Removing existing libmyth-devel package to avoid conflicts"
        sudo rpm -e libmyth-devel.i386 libmyth-devel.x86_64 2>/dev/null
    fi

# Update SPEC
    echo "Updating specfile _svnver to r$REL"
    sed -i \
        -e "s,define _svnrev .\+,define _svnrev r$REL," \
        -e "s,define branch .\+,define branch $BRANCH," \
        -e "s,Version:.\+,Version: $VERSION,"           \
        "$ABSPATH"/mythtv.spec \
        "$ABSPATH"/mythtv-themes.spec

# Clean up any old tarballs that might exist
    rm -f "$ABSPATH"/mythtv/myth*.tar.bz2
    rm -f "$ABSPATH"/mythtv-themes/*themes*.tar.bz2

# Create the appropriate tarballs
    echo "Creating tarballs from svn checkout at $SVNDIR"
    cd "$SVNDIR"
    for file in mythtv mythplugins; do
        if [ -d "$file-$VERSION" ]; then
            rm -rf "$file-$VERSION"
        fi
        echo -n "    "
        mv "$file" "$file-$VERSION"
        tar jcf "$ABSPATH/mythtv/$file-$VERSION.tar.bz2" --exclude .svn "$file-$VERSION"
        mv "$file-$VERSION" "$file"
        echo "$ABSPATH/mythtv/$file-$VERSION.tar.bz2"
    done
    for file in myththemes themes; do
        if [ -d "$file-$VERSION" ]; then
            rm -rf "$file-$VERSION"
        fi
        echo -n "    "
        mv "$file" "$file-$VERSION"
        tar jcf "$ABSPATH/mythtv-themes/$file-$VERSION.tar.bz2" --exclude .svn "$file-$VERSION"
        mv "$file-$VERSION" "$file"
        echo "$ABSPATH/mythtv-themes/$file-$VERSION.tar.bz2"
    done

# Build MythTV
    rpmbuild -bb "$ABSPATH"/mythtv.spec \
        --define "_sourcedir $ABSPATH/mythtv"
        --with debug            \
        --without mytharchive   \
        --without mythgallery   \
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

# Install
    echo -n "Install r$REL? [n] "
    read INST
    if [ "$INST" = "y" -o "$INST" = "Y" -o "$INST" = "yes" ]; then
        installmyth "$VERSION" "$REL"
    else
        echo "If you wish to install later, just run: installmyth \"$VERSION\" \"$REL\""
    fi


# Disabled until I can clean this up later -- themes now require libmyth in
# order to compile.
#
## Build MythTV Themes
#    rpmbuild -bb /usr/src/redhat/SPECS/mythtv-themes.spec
## Error?
#    if [ "$?" -ne 0 ]; then
#        echo "MythTV Themes build error."
#        return
#    fi

###############################################################################

# A separate function to install mythtv packages, so it can be called separately
    function installmyth {
        VERSION="$1"
        REL="$2"
        sudo rpm -Uvh --force                                                            \
            /usr/src/redhat/RPMS/x86_64/mythtv-docs-$VERSION-0.1.svn.r$REL.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/libmyth-$VERSION-0.1.svn.r$REL.*.rpm             \
            /usr/src/redhat/RPMS/x86_64/libmyth-devel-$VERSION-0.1.svn.r$REL.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/mythtv-base-themes-$VERSION-0.1.svn.r$REL.*.rpm  \
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
            #/usr/src/redhat/RPMS/x86_64/mythtv-themes-$VERSION-0.1.svn.r$REL.*.rpm  \
    }

