#!/bin/bash

#
# Script for building MythTV packages from an SVN checkout.
#
# by:   Chris Petersen <cpetersen@mythtv.org>
#
# The latest version of this file can be found in the mythtv git repository:
#
# https://github.com/MythTV/packaging/raw/master/rpm/build_myth.sh
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
    VERSION="0.26"

# Branch should be "master" or "stable"
    BRANCH="master"

# Hard-code the git clone directory.  Leave blank to auto-detect based on
# the location of this script
    GITDIR=""

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

# Update the requested spec to the requested revision/branch/version
    function updatespec {
        R="$1"
        SPEC="$2"
        echo "Updating $SPEC _gitver to r$R"
        sed -i \
            -e "s,define _gitrev .\+,define _svnrev r$R," \
            -e "s,define branch .\+,define branch $BRANCH,"  \
            -e "s,Version:.\+,Version: $VERSION,"             \
            $SPEC
    }

# Function to build mythtv packages
    function buildmyth {
    # Remove the existing mythtv-devel so it doesn't confuse qmake
    # (we can't override the order of the include file path)
        PKG=`rpm -q mythtv-devel`
        if [ `expr match "$PKG" 'mythtv-libs.*'` -gt 0 ]; then
            echo "Removing existing mythtv-devel package to avoid conflicts"
            sudo rpm -e mythtv-devel.i386 mythtv-devel.x86_64 2>/dev/null
        fi
    # Clean up any old tarballs that might exist
        rm -f "$ABSPATH"/mythtv/myth*.tar.bz2
    # Create the appropriate tarballs
        echo "Creating tarballs from git clones at $GITDIR"
        for file in mythtv mythplugins; do
            git archive --format tar --remote "$GITDIR"/ HEAD "$file"/ | bzip2  > "$ABSPATH/mythtv/$file-$GITVER.tar.bz2"
            echo "$ABSPATH/mythtv/$file-$GITVER.tar.bz2"
        done
    # Build MythTV
        time rpmbuild -bb "$ABSPATH"/mythtv.spec \
            --define "_sourcedir $ABSPATH/mythtv" \
            --with debug            \
            --without crystalhd    \
            --without mytharchive   \
            --without mythgallery   \
            --without mythgame      \
            --without mythnews      \
            --without mythzoneminder
    # Error?
        if [ "$?" -ne 0 ]; then
            echo "MythTV build error."
            return
        fi
    # Install
        echo -n "Install $VSTRING? [n] "
        read INST
        if [ "$INST" = "y" -o "$INST" = "Y" -o "$INST" = "yes" ]; then
            installmyth "$VSTRING"
        else
            echo "If you wish to install later, just run: $PROG --install \"$VSTRING\""
        fi
    }

# Function to build mythtv packages
    function buildmythweb {
    # Clean up any old tarballs that might exist
        rm -f "$ABSPATH"/mythtv/mythweb*.tar.bz2
    # Create the appropriate tarballs
        echo "Creating tarball from git clones at $GITDIR"
        for file in mythweb; do
            git archive --format tar --prefix "$file/" --remote "$GITDIR"/../"$file" HEAD | bzip2  > "$ABSPATH/mythtv/$file-$GITVER.tar.bz2"
            echo "$ABSPATH/mythtv/$file-$GITVER.tar.bz2"
        done
    # Build MythTV
        time rpmbuild -bb "$ABSPATH"/mythweb.spec \
            --define "_sourcedir $ABSPATH/mythtv" \
            --with debug
    # Error?
        if [ "$?" -ne 0 ]; then
            echo "MythWeb build error."
            return
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
    # Disabled until I can clean this up later -- themes now require mythtv-libs in
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
        sudo rpm -Uvh --force --nodeps                                                    \
            /usr/src/redhat/RPMS/x86_64/mythtv-docs-$GITVER-0.1.git.$GITREV.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/mythtv-libs-$GITVER-0.1.git.$GITREV.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/mythtv-devel-$GITVER-0.1.git.$GITREV.*.rpm        \
            /usr/src/redhat/RPMS/x86_64/mythtv-base-themes-$GITVER-0.1.git.$GITREV.*.rpm  \
            /usr/src/redhat/RPMS/x86_64/mythtv-frontend-$GITVER-0.1.git.$GITREV.*.rpm     \
            /usr/src/redhat/RPMS/x86_64/mythtv-backend-$GITVER-0.1.git.$GITREV.*.rpm      \
            /usr/src/redhat/RPMS/x86_64/mythtv-common-$GITVER-0.1.git.$GITREV.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/perl-MythTV-$GITVER-0.1.git.$GITREV.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/python-MythTV-$GITVER-0.1.git.$GITREV.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/mythffmpeg-$GITVER-0.1.git.$GITREV.*.rpm          \
            /usr/src/redhat/RPMS/x86_64/mythmusic-$GITVER-0.1.git.$GITREV.*.rpm           \
            /usr/src/redhat/RPMS/x86_64/mythbrowser-$GITVER-0.1.git.$GITREV.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/mythnetvision-$GITVER-0.1.git.$GITREV.*.rpm       \
            /usr/src/redhat/RPMS/x86_64/mythweather-$GITVER-0.1.git.$GITREV.*.rpm         \
            /usr/src/redhat/RPMS/x86_64/mythtv-debuginfo-$GITVER-0.1.git.$GITREV.*.rpm
            # These are disabled because the developer doesn't use them
            #/usr/src/redhat/RPMS/x86_64/mythweb-$GITVER-0.1.git.$GITREV.*.rpm  \
            #/usr/src/redhat/RPMS/x86_64/mythtv-themes-$GITVER-0.1.git.$GITREV.*.rpm  \
    }

# And a function to install mythtv theme packages, since they need mythtv-libs
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
    if [ -z "$GITDIR" ]; then
        GITDIR=$(dirname $(dirname "$ABSPATH"))/mythtv
    fi
    if [ ! -d "$GITDIR" ]; then
        echo "$GITDIR does not exist.  Please check out using:"
        echo "    git clone https://github.com/MythTV/mythtv"
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

# Make sure our git clone is up to date
    echo "Fetching latest information from git repository."
    cd "$GITDIR"
    git fetch
    git fetch --tags

# Get information about the latest/requested Git sha
    if [[ $REV ]]; then
        DESCRIBE=`git describe "$REV" -- 2>/dev/null`
    else
        DESCRIBE=`git describe -- 2>/dev/null`
    fi
    if [[ ! $DESCRIBE ]]; then
        echo "Unknown/Invalid revision:  $REV"
        exit
    fi
    GITVER=`echo "$DESCRIBE" | sed -e 's,^\([^-]\+\)-.\+$,\1,'`
    GITREV=`echo "$DESCRIBE" | sed -e 's,^[^-]\+-,,' -e 's,-,.,g'`
    # do some magic here to detect v, b, rc, or pre notations
    if [[ $GITREV =~ ^rc || $GITREV =~ ^pre || $GITREV =~ ^alpha ]]; then
        GITVER=${GITVER#v}
        GITREV="0.0.$GITREV"
    elif [[ $GITVER =~ ^v ]]; then
        GITVER=${GITVER#v}
        GITREV=1
    elif [[ $GITVER =~ ^b ]]; then
        GITVER=0.$((${GITVER#b0.}+1))
        GITREV="0.$GITREV"
    fi
    VSTRING="$GITVER.$GITREV"

# Done doing that, now back to the working dir
    cd - >/dev/null

# What to do now?
    if [[ ! $REV ]]; then
        echo "Building $VSTRING (latest revision)"
    else
        echo "Building $VSTRING"
    fi

# Update the revision in the specfile
    for SPEC in mythtv mythweb; do
        echo "Updating $SPEC.spec _gitver to $VSTRING"
        sed -i \
            -e "s,define _gitrev .\+,define _gitrev $GITREV," \
            -e "s,define branch .\+,define branch $BRANCH,"   \
            -e "s,define vers_string .\+,define vers_string $DESCRIBE,"   \
            -e "s,Version:.\+,Version: $GITVER,"              \
            "$ABSPATH/$SPEC.spec"
    done

# Update the other spec files to the MythTV spec version
    # later...

# Build MythTV
    buildmythweb
    buildmyth

# Done
    exit

