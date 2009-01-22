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
# See --help for usage instructions.
#
# Please make sure that the rpm build parameters are to your liking (a
# number of plugins are disabled by default/example in this script to
# show you that the spec is capable of compiling only those plugins that
# you wish to install).  The same goes for the installmyth function,
# which only installs those packages which I personally use.
#
# I will eventually clean up this script to enhance the parameters and
# make it a little easier to configure/use.
#

###############################################################################
# Configuration
###############################################################################

# Hard-code the version of MythTV
    VERSION="0.22"

# Branch should be "trunk" or "stable"
    BRANCH="trunk"

# Hard-code the svn checkout directory.  Leave blank to auto-detect based on
# the location of this script
    SVNDIR=""

###############################################################################
# Functions to be used by the program
###############################################################################

# Print the help/usage message
    function usage {
        cat <<EOF
Usage:  $PROG [OPTIONS]

Build RPMs for MythTV, MythPlugins, etc.

Options:

$PROG --help

    print this menu

$PROG -i REVISION
$PROG --install REVISION

    Install the pre-build package for REVISION

$PROG REVISION
$PROG -r REVISION
$PROG --revision REVISION

    Build/install the requested revision

EOF
    }

# Update to the latest/requested SVN version
    function updatesvn {
        PKG="$1"
        if [ -z "$REV" -o 0"$REV" -lt 1 ]; then
            echo "Updating svn checkout for $PKG"
            REL=`svn up "$SVNDIR"/"$PKG" 2>/dev/null`
        else
            echo "Updating svn checkout for $PKG to r$REV"
            REL=`svn up -r "$REV" "$SVNDIR"/"$PKG" 2>/dev/null`
        fi
        if [ $? != 0 ]; then
            echo "Problem updating svn checkout"
            return $?
        fi
        REL=`echo "$REL" | grep -i revision | sed -e 's/[^0-9]\\+//g'`
        echo "Updated to SVN Revision $REL"
    }

# Update the requested spec to the requested revision/branch/version
    function updatespec {
        R="$1"
        SPEC="$2"
        echo "Updating $SPEC _svnver to r$R"
        sed -i \
            -e "s,define _svnrev .\+,define _svnrev r$R," \
            -e "s,define branch .\+,define branch $BRANCH,"  \
            -e "s,Version:.\+,Version: $VERSION,"             \
            $SPEC
    }

# Function to build mythtv packages
    function buildmyth {
    # Update the SVN checkout
        updatesvn mythtv "$1"
    # Remove the existing libmyth-devel so it doesn't confuse qmake
    # (we can't override the order of the include file path)
        PKG=`rpm -q libmyth-devel`
        if [ `expr match "$PKG" 'libmyth.*'` -gt 0 ]; then
            echo "Removing existing libmyth-devel package to avoid conflicts"
            sudo rpm -e libmyth-devel.i386 libmyth-devel.x86_64 2>/dev/null
        fi
    # Update the spec
        updatespec $REL "$ABSPATH/mythtv.spec"
    # Clean up any old tarballs that might exist
        rm -f "$ABSPATH"/mythtv/myth*.tar.bz2
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
    # Build MythTV
        rpmbuild -bb "$ABSPATH"/mythtv.spec \
            --define "_sourcedir $ABSPATH/mythtv" \
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
            installmyth "$REL"
        else
            echo "If you wish to install later, just run: $PROG --install \"$REL\""
        fi
    }

# Function to build mythtv themes packages
    function buildthemes {
    # Update the SVN checkout -- make sure not to
        svnupdate mythtv-themes "$1"
    # Update the spec
        updatespec $REL "$ABSPATH/mythtv-themes.spec"
    # Clean up any old tarballs that might exist
        rm -f "$ABSPATH"/mythtv-themes/*themes*.tar.bz2
    # Create the appropriate tarballs
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
    }

# A function to install mythtv packages
    function installmyth {
        REL="$1"
        sudo rpm -Uvh --force --nodeps                                                   \
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

# And a function to install mythtv theme packages, since they need libmyth
# to be already installed in order to build them
    function installthemes {
        REL="$1"
    }


###############################################################################
# Actually execute the program here
###############################################################################

# Get the absolute path to this script
    ABSPATH=$(cd `dirname "$0"` && pwd)

# The nice name of this program
    PROG=`basename $0`

# Check a few things for sanity
    for PKG in 'mythtv' 'mythtv-themes'; do
    # Make sure the spec exists
        if [ ! -f "$ABSPATH/$PKG.spec" ]; then
            echo "$ABSPATH/$PKG.spec does not exist"
            exit
        fi
    # Make sure we have a sources directory
        if [ ! -d "$ABSPATH/$PKG/" ]; then
            echo "$ABSPATH/$PKG does not exist"
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

# Default revision
    REV=""

# Do the requested operation
    case "$1" in
        -h*|--h*|h*|-u*|--u*|u*)
            usage
            exit
            ;;
        -i*|--i*|i*)
            installmyth "$2"
            exit
            ;;
        -r*|--r*|r*)
            REV="$2"
            ;;
        *)
            REV="$1"
    esac

# Sanity check
    if [ `expr "$REV" : "[^0-9]"` -ne 0 ]; then
        echo "Invalid revision:  $REV"
        exit
    fi

# What to do now?
    if [ -z "$REV" ]; then
        echo "Building latest revision"
    else
        echo "Building Revision:  $REV"
    fi
    buildmyth "$REV"

# Done
    exit

