#!/bin/bash -e
# Build script for MythTV
# Created by Lawrence Rust, lvr at softsystem dot co dot uk
#
###############################################################################
# - On Windows 2k/XP/Vista/7 to build a native MythTV using the MSYS environment and MingGW
#   http://sourceforge.net/projects/mingw/files
#   # NB Min specs: 1GB (2GB for debug build) VM, physical RAM preferable, and 5GB disk
#   Click:
#     Automated MinGW Installer > mingw-get-inst
#   Then select a version e.g.
#     mingw-get-inst-20111118 > mingw-get-inst-20111118.exe
#     NB mingw-get-inst-20110211.exe doesn't work on Win2K & XP
#   Run the installer and ensure to add:
#     C++
#     MSYS basic system
#     MinGW Developer Toolkit
#   Start an Msys shell from the Windows desktop by clicking:
#     Start > All Programs > MinGW > MinGW Shell"
#   Copy this script to C:\MinGW\msys\1.0\home\[username]
#   At the Msys prompt enter:
#     ./mythbuild.sh
#   or for a debug build type:
#     ./mythbuild.sh -d
#
###############################################################################
# - On Linux to cross build a Windows installation using the MinGW C cross compiler from
#   http://sourceforge.net/projects/mingw/files/Cross-Hosted%20MinGW%20Build%20Tool/
#   Install the cross compiler.  On Debian:
#     sudo apt-get install mingw32
#   On Fedora:
#     sudo yum install mingw32-gcc.i686 mingw32-gcc-g++.i686
#   You will also need the Gnu C/C++ compiler and these packages:
#     wget patch git-core
#   At a command prompt type:
#     ./mythbuild.sh -W
#   or for a debug build type:
#     ./mythbuild.sh -W -d
#
###############################################################################
# - On Linux to cross build to MacOSX using Apple's gcc and odcctools from
#   http://www.opensource.apple.com/tarballs/gcc/gcc-5247.tar.gz
#   http://svn.macosforge.org/repository/odcctools/release/odcctools-20090808.tar.bz2
# 
#   You will need a C compiler and these packages:
#     wget patch git-core
#
#   Create the cross-tools folder:
#     export PREFIX=/opt/mac
#     sudo mkdir -p $PREFIX
#     sudo chown $USER:$USER $PREFIX
#   Build the cross compiler and tools:
#     mkdir -p xtools && cd xtools
#     wget http://www.softsystem.co.uk/download/mythtv/mkodcctools
#     chmod +x mkodcctools
#     ./mkodcctools
#   Add the path to the cross tools:
#     PATH=$PATH:$PREFIX/bin
#   At a command prompt type:
#     ./mythbuild.sh -M
#   or for a debug build type:
#     ./mythbuild.sh -M -d
#
###############################################################################
# - On Linux to build a native MythTV.
#   You will need the Gnu C/C++ compiler collection and these packages:
#     wget patch git-core
#   At a command prompt type:
#     ./mythbuild.sh -H
#   or for a debug build type:
#     ./mythbuild.sh -H -d
#
#   For an optimised build:
#     CFLAGS="-march=native -O2" CXXFLAGS="-march=native -O2" mythbuild.sh -r -c host
#
#   Package dependecies:
#   MythTV Xv:    libxxf86vm-dev libxv-dev
#   MythTV ALSA:  libasound2-dev
#   MythTV Perl:  libnet-upnp-perl
#   Qt DBus:      libdbus-1-dev
#
#   Host dependencies:
#   Mac B/W G3: mythbuild.sh -c g3
set -e
[ -n "$DEBUG" ] && set -x

readonly version="0.9"
readonly myname="$0"
readonly myargs="$*"

# Myth code repo
: ${MYTHREPO:="http://mythtv-for-windows.googlecode.com/files"}
# Myth git repo
: ${MYTHGIT:="git://github.com/MythTV"}

# SourceForge auto mirror re-direct
: ${SOURCEFORGE:="downloads.sourceforge.net"}

# The libraries to be installed:
: ${PKGCONFIG:="pkg-config_0.26-1_win32"}
: ${PKGCONFIG_URL:="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/$PKGCONFIG.zip"}
: ${GLIB:="glib_2.28.8-1_win32"}
: ${GLIB_URL:="http://ftp.gnome.org/pub/gnome/binaries/win32/glib/${GLIB:5:4}/$GLIB.zip"}
: ${GETTEXT:="gettext-runtime_0.18.1.1-2_win32"}
: ${GETTEXT_URL:="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/$GETTEXT.zip"}
: ${PTHREADS:="pthreads-w32-2-8-0-release"}
: ${PTHREADS_URL:="ftp://sourceware.org/pub/pthreads-win32/$PTHREADS.tar.gz"}
: ${ZLIB:="zlib-1.2.5"}
: ${ZLIB_URL:="http://$SOURCEFORGE/project/libpng/zlib/${ZLIB/zlib-/}/$ZLIB.tar.gz"}
: ${FREETYPE:="freetype-2.4.3"}
: ${FREETYPE_URL:="http://download.savannah.gnu.org/releases/freetype/$FREETYPE.tar.gz"}
: ${LAME:="lame-3.98.4"}
: ${LAME_URL:="http://$SOURCEFORGE/project/lame/lame/${LAME/lame-/}/$LAME.tar.gz"}
: ${WINE:="wine-1.3.6"}
: ${WINE_URL:="http://$SOURCEFORGE/project/wine/Source/$WINE.tar.bz2"}
: ${DXVA2_URL:="http://download.videolan.org/pub/videolan/contrib/dxva2api.h"}
: ${LIBEXIF:="libexif-0.6.19"}
: ${LIBEXIF_URL:="http://$SOURCEFORGE/project/libexif/libexif/${LIBEXIF/libexif-/}/$LIBEXIF.tar.bz2"}
: ${LIBOGG:="libogg-1.2.1"}
: ${LIBOGG_URL:="http://downloads.xiph.org/releases/ogg/$LIBOGG.tar.bz2"}
: ${LIBVORBIS:="libvorbis-1.3.2"}
: ${LIBVORBIS_URL:="http://downloads.xiph.org/releases/vorbis/$LIBVORBIS.tar.bz2"}
: ${FLAC:="flac-1.2.1"}
: ${FLAC_URL:="http://$SOURCEFORGE/project/flac/flac-src/$FLAC-src/$FLAC.tar.gz"}
: ${LIBCDIO:="libcdio-0.82"}
: ${LIBCDIO_URL:="ftp.gnu.org/gnu/libcdio/$LIBCDIO.tar.gz"}
: ${TAGLIB:="taglib-1.6.3"}
: ${TAGLIB_URL:="http://developer.kde.org/~wheeler/files/src/$TAGLIB.tar.gz"}
: ${FFTW:="fftw-3.2.2"}
: ${FFTW_URL:="http://www.fftw.org/$FFTW.tar.gz"}
: ${LIBSDL:="SDL-1.2.14"}
: ${LIBSDL_URL:="http://www.libsdl.org/release/$LIBSDL.tar.gz"}
: ${LIBVISUAL:="libvisual-0.4.0"}
: ${LIBVISUAL_URL:="http://$SOURCEFORGE/project/libvisual/libvisual/$LIBVISUAL/$LIBVISUAL.tar.gz"}
: ${LIBDVDCSS:="libdvdcss-1.2.10"}
: ${LIBDVDCSS_URL:="http://download.videolan.org/pub/libdvdcss/${LIBDVDCSS/libdvdcss-/}/$LIBDVDCSS.tar.bz2"}
: ${LIBXML2:="libxml2-2.7.8"}
: ${LIBXML2_URL:="ftp://xmlsoft.org/libxml2/$LIBXML2.tar.gz"}
: ${LIBXSLT:="libxslt-1.1.26"}
: ${LIBXSLT_URL:="ftp://xmlsoft.org/libxslt/${LIBXSLT}.tar.gz"}
# 16-Sep-2011 latest: mysql-5.5.16
: ${MYSQL:="mysql-5.1.71"}
: ${MYSQL_URL:="http://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQL:6:3}/$MYSQL.tar.gz"}
# Pre-built win32 install. NB mysql-5.1 requires winXP-SP2, 5.0 works on win2k
# 5.0.89 unavailable 11-feb-11
#: ${MYSQLW:="mysql-5.0.89-win32"}
# 5.1.55 unavailable 15-sep-11
#: ${MYSQLW:="mysql-5.1.55-win32"}
: ${MYSQLW:="mysql-5.1.71-win32"}
: ${MYSQLW_URL:="ftp://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQLW:6:3}/${MYSQLW/mysql-/mysql-noinstall-}.zip"}
#: ${MYSQLW_URL:="ftp://ftp.mirrorservice.org/sites/ftp.mysql.com/Downloads/MySQL-${MYSQLW:6:3}/${MYSQLW/mysql-/mysql-noinstall-}.zip"}
# Pre-built MacOSX install
: ${MYSQLM:="mysql-5.1.71-osx10.6-x86"}
: ${MYSQLM_URL:="ftp://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQLM:6:3}/$MYSQLM.tar.gz"}
# Pre-built MacOSX powerpc
: ${MYSQLX:="mysql-standard-4.1.22-apple-darwin7.9.0-powerpc"}
: ${MYSQLX_URL:="ftp://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQLX:15:3}/$MYSQLX.tar.gz"}
#: ${QT:="qt-everywhere-opensource-src-4.8.5"} # Builds for host OK but win32 & mac need updated patches
: ${QT:="qt-everywhere-opensource-src-4.8.5"}
: ${QT_URL:="http://download.qt-project.org/official_releases/qt/4.8/4.8.5/$QT.tar.gz"}
# Configurable libraries
readonly packages1="MYTHTV MYTHPLUGINS QT MYSQL FREETYPE LAME LIBEXIF LIBXML2"
readonly packages2="LIBXSLT LIBOGG LIBVORBIS FLAC LIBCDIO TAGLIB FFTW LIBSDL"
readonly packages3="LIBVISUAL LIBDVDCSS"

# Tools
: ${MYTHPATCHES:="mythpatches-0.24"}
: ${MYTHPATCHES_URL:="http://www.softsystem.co.uk/download/mythtv/$MYTHPATCHES.tar.bz2"}
: ${YASM:="yasm-1.1.0"}
: ${YASM_URL:="http://www.tortall.net/projects/yasm/releases/$YASM.tar.gz"}
: ${UNZIP:="unzip60"}
: ${UNZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/src/$UNZIP.zip"}

# Windows hosted tools
: ${WINWGET:="wget-1.11.4"}
: ${WINWGET_URL:="ftp://ftp.gnu.org/gnu/wget/$WINWGET.tar.bz2"}
: ${WINUNZIP:="unz600xn"}
: ${WINUNZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINUNZIP.exe"}
: ${WINZIP:="zip300xn"}
: ${WINZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINZIP.zip"}
: ${WINGIT:="Git-1.7.3.1-preview20101002"}
: ${WINGIT_URL:="http://msysgit.googlecode.com/files/$WINGIT.exe"}
: ${WININSTALLER:="mythinstaller-win32"}
: ${WININSTALLER_URL:="http://www.softsystem.co.uk/download/mythtv/$WININSTALLER.tar.bz2"}

# Debug build: yes|no|auto, auto=follow MYTHBUILD
: ${QT_DEBUG:="auto"}
: ${MYSQL_DEBUG:="auto"}
: ${LAME_DEBUG:="auto"}
: ${FLAC_DEBUG:="no"}
: ${TAGLIB_DEBUG:="no"}
: ${FFTW_DEBUG:="no"}
: ${LIBVISUAL_DEBUG:="no"}
# These libs are rebuilt whenever MYTHBUILD changes
readonly debug_packages="QT MYSQL LAME FLAC TAGLIB FFTW LIBVISUAL"


# Dir for myth sources
: ${MYTHDIR:=$PWD}

# Working dir for downloads & sources
if [ -d "$MYTHDIR/mythwork" ]; then
    # Backwards compatibility for v1 script
    : ${MYTHWORK:="$MYTHDIR/mythwork"}
    : ${MYTHINSTALL:="$MYTHDIR/mythbuild"}
else
    : ${MYTHWORK:="$MYTHDIR/mythbuild"}
    # prefix for package installs
    : ${MYTHINSTALL:="$MYTHDIR/mythinstall"}
fi


# Default parameters
unset MYTHTARGET
unset MYTHBUILD
unset MYTHBRANCH
readtimeout=60
logging="no"
unset patches
cleanbuild="no"
reconfig="no"
reinstall="no"
themes="no"
unset cpu
if [ -n "$NUMBER_OF_PROCESSORS" ]; then
    cpus=$NUMBER_OF_PROCESSORS
elif [ -r "/proc/cpuinfo" ]; then
    cpus=`grep -c "^processor" /proc/cpuinfo`
else
    cpus=1
fi
[ $cpus -gt 1 ] && makejobs=`expr $cpus + 1` || makejobs=1
verbose="no"
unset dosudo
unset patchmaster
: ${DXVA2:="no"}


###############################################################
# Parse the command line
###############################################################
readonly currdir="$PWD"
readonly logfile="mythbuild.log"

# Get the current git branch
# $1= path to .git
function gitbranch() {
    [ -d "$1/.git" ] && git --git-dir="$1/.git" branch --no-color|grep "^\*"|cut -d ' ' -f 2 || true
}

function myhelp() {
    local branch="$MYTHBRANCH"
    : ${branch:=`gitbranch "$MYTHDIR/mythtv"`}
    echo "A script to build MythTV"
    echo "Usage: $myname [options] [packages_to_make]"
    echo "Options:"
    echo "  -b tag        Checkout MythTV branch [$branch]"
    echo "  -r           *Release build (sticky)"
    echo "  -d            Debug build (sticky)"
    echo "  -p            Profile build (sticky)"
    echo "  -I <path>     Install prefix [${MYTHINSTALL#$MYTHDIR/}]"
    echo "  -H            Build for Host (sticky)"
    echo "  -M            Build for MacOSX-i686 (32-bit) (sticky)"
    echo "  -X            Build for MacOSX-PPC (sticky)"
    echo "  -W           *Build for Windows (sticky)"
    echo "  -l            Tee stdout and stderr to $logfile"
    echo "  -c <cpu>      Set target CPU (host|i?86|...) [$cpu]"
    echo "  -j n          Number of parallel make jobs [$makejobs]"
    echo "  -t <n>        Timeout after configure [$readtimeout Seconds]"
    echo "  -v            Verbose build messages [$verbose]"
    echo "  -C            Force a clean re-build"
    echo "  -E            Force a clean re-install"
    echo "  -F            Enable mythtv and mythplugins master patches [${patchmaster:-no}]"
    echo "  -P            Apply all patches to mythtv and mythplugins then exit"
    echo "  -R            Reverse all patches applied to mythtv & mythplugins then exit"
    echo "  -S            Run make install/uninstall with sudo"
    echo "  -T            Build and install myththemes [$themes]"
    echo "  -h            Display this help then exit"
    echo "  -V            Display version then exit"
    echo ""
    echo "The following shell variables are influential:"
    echo "MYTHDIR         Build tree root [current directory]"
    echo "MYTHWORK        Directory to unpack and build packages [${MYTHWORK#$MYTHDIR/}]"
    echo "MYTHPATCHES     Patches to apply [$MYTHPATCHES]"
    echo "MYTHVER         MythTV version [$MYTHVER]"
    echo "DXVA2           Windows DXVA2 support [$DXVA2]"
    echo "MYTHGIT         Myth git repository [$MYTHGIT]"
    echo "MYTHREPO        Primary mirror [$MYTHREPO]"
    echo "SOURCEFORGE     Sourceforge mirror [$SOURCEFORGE]"
    echo "<name>_CFG      Additional configure options for package <name> e.g."
    echo "                $packages1"
    echo "                $packages2"
    echo "                $packages3"
    echo "                Set to \" \" to force configure & rebuild of the package."
    local pkg dbg
    for pkg in $debug_packages ; do
        dbg=${pkg}_DEBUG
        printf "%-15s %s debugging (yes|no|auto) [%s]\n" $dbg $pkg ${!dbg} 
    done
}
function version() {
    echo "Version $version, last modified `date -Rr $myname`"
}
function die() {
    echo "" >&2
    echo -e "ERROR - $*" >&2
    exit 1
}

# Options
while getopts ":b:c:dj:lprt:vhVCEFHI:MPRSTWX" opt
do
    case "$opt" in
        b) [ "${OPTARG:0:1}" != "-" ] && MYTHBRANCH=$OPTARG || die "Invalid branch tag: $OPTARG" ;;
        c) [ "${OPTARG:0:1}" != "-" ] && cpu=$OPTARG || die "Invalid CPU: $OPTARG" ;;
        d) MYTHBUILD="debug" ;;
        p) MYTHBUILD="profile" ;;
        r) MYTHBUILD="release" ;;
        j) [ $OPTARG -lt 0 -o $OPTARG -gt 99 ] && die "Invalid number of jobs: $OPTARG"
           [ $OPTARG -lt 1 ] && die "Invalid make jobs: $OPTARG"
            makejobs=$OPTARG ;;
        t) [ $OPTARG \< 0 -o $OPTARG -gt 999 ] && die "Invalid timeout: $OPTARG"
            readtimeout=$OPTARG ;;
        v) verbose="yes" ;;
        l) logging="yes" ;;
        C) cleanbuild="yes" ;;
        E) reinstall="yes" ;;
        F) [ "$patchmaster" != "yes" ] && patchmaster="yes" || patchmaster="no" ;;
        H) MYTHTARGET="Host" ;;
        M) MYTHTARGET="MacOSX-i686" ;;
        X) MYTHTARGET="MacOSX-PPC" ;;
        W) MYTHTARGET="Windows" ;;
        I) MYTHINSTALL=`readlink -f "$OPTARG" 2>/dev/null` || die "Invalid path: $OPTARG" ;;
        P) patches="apply" ;;
        R) patches="reverse" ;;
        S) dosudo="sudo" ;;
        T) [ "$themes" = "no" ] && themes="yes" || themes="no" ;;
        h) myhelp; exit ;;
        V) version; exit ;;
        \?) [ -n "$OPTARG" ] && die "Invalid option -$OPTARG" ;;
        :) [ -n "$OPTARG" ] && die "-$OPTARG requires an argument" ;;
        *) die "Unknown option $opt" ;;
    esac
done
shift `expr $OPTIND - 1`

# Arguments - named packages to build
readonly forcebuild=$@


###############################################################
# Functions
###############################################################

# Install a package, $1= package
function install_pkg() {
    echo "Installing $1..."
    if which apt-get > /dev/null 2>&1 ; then
        sudo apt-get install $1 || die "Failed to install $1"
    elif which yum >/dev/null 2>&1 ; then
        sudo yum install $1 || die "Failed to install $1"
    elif which urpmi >/dev/null 2>&1 ; then
        sudo urpmi $1 || die "Failed to install $1"
    else
        die "Don't know how to install $1"
    fi
}

# Download a file. $1= URL
function download() {
    local obj=`basename "$1"`
    echo ""
    echo "*********************************************************************"
    echo "wget $obj"
    # Try the myth code repo first, if not use the full URL
    if ! wget "$MYTHREPO/$obj" ; then
        wget $1
    fi
}

# FTP download. $1= URL
function ftpget() {
    local host path filename
    case "$1" in
        ftp://*) ;;
        *) die "Not an FTP URL: $1" ;;
    esac
    path=`dirname "${1#ftp://}"`
    host=${path%%/*}
    path=${path#$host}
    filename=`basename "$1"`
    echo ""
    echo "*********************************************************************"
    echo "ftp ftp://$host/$path/$filename"
    ftp.exe -n $host <<-EOF
		user anonymous mythbuildw32@$HOSTNAME
		cd $path
		binary
		passive
		get $filename
		quit
	EOF
}

# Display a timed message
# $1= seconds $2= message
function pause() {
    local seconds
    echo ""
    echo "*********************************************************************"
    if [ $1 -eq 0 ]; then
        :
    elif [ $1 -lt 0 ]; then
        read -p "$2" || echo ""
    else
        for (( seconds=$1 ; seconds > 0 ; --seconds )) do
            printf -v prompt "\r$2(%3u)" $seconds
            read -t 1 -p "$prompt" && break || true
        done
        [ $seconds -le 0 ] && echo ""
    fi
    echo ""
}

# Print message and timed wait
# $1=seconds, $2=message
function pausecont() {
    local msg=$2
    if [ -z "$msg" ]; then
        local pkg=`basename "$PWD"`
        msg="Press [Return] to make ${pkg:0:26} or [Control-C] to abort "
    fi
    pause ${1:-$readtimeout} "$msg"
}

# Display a banner
# $1= message
function banner() {
    echo ""
    echo "*********************************************************************"
    echo "${1:0:80}"
    echo "*********************************************************************"
    echo ""
}

# Unpack an archive
# $1= filename
function unpack() {
    echo "Extracting `basename "$1"` ..."
    case "$1" in
        *.tar.gz) tar -zxf "$@" ;;
        *.tar.bz2) tar -jxf "$@" ;;
        *.zip) unzip -a -q "$@" ;;
        *) die "Unknown archive type: $1" ;;
    esac
}

function patchapplied() {
    local n x
    case "$1" in
        *.diff) x=".diff" ;;
        *.patch) x=".patch" ;;
    esac
    n=`basename "$1" "$x"`
    echo "patch-$n.applied"
}

# Apply patches to a component
# $1= component name, $2... args to patch
function dopatches() {
    local d=$1 i ret=0 patched dryrun
    shift
    echo "$*" | grep -- --dry > /dev/null 2>&1 && dryrun="yes"
    local patches=`ls 2>/dev/null $MYTHDIR/$MYTHPATCHES/$d/*.{patch,diff} | sort`
    for i in $patches ; do
        if [ -r "$i" ]; then
            patched=`patchapplied "$i"`
            if [ ! -e "$patched" ]; then
                echo "Applying patch $d/`basename $i`"
                patch -s -p1 -N -i "$i" "$@"
                [ -z "$dryrun" ] && touch "$patched"
                let ++ret
            fi
        fi
    done
    return $ret
}

# Undo patches to a component
# $1= component name, $2... args to patch
function undopatches() {
    local d=$1 i patched
    shift
    local patches=`ls 2>/dev/null $MYTHDIR/$MYTHPATCHES/$d/*.{patch,diff} | sort -r`
    for i in $patches ; do
        if [ -r "$i" ]; then
            patched=`patchapplied "$i"`
            if [ -e "$patched" ]; then
                echo "Reversing patch $d/`basename $i`"
                patch -s -p1 -R -E -i "$i" "$@" || true
                rm -f "$patched"
            fi
        fi
    done
}

# Download a git repo
# $1= URL $2= dir
function gitclone() {
    banner "git clone $*"
    git config --global core.autocrlf false
    git clone "$@"
}

# Get the most recent git tag
# $1= path to .git
function gitdescribe() {
    [ -d "$1/.git" ] && git --git-dir="$1/.git" describe || echo "unknown"
}

# make distclean
function make_distclean() {
    echo "make distclean..."
    $make -s -k distclean >/dev/null 2>&1 || true
}

# make install
function make_install() {
    echo "make install..."
    $dosudo $make -j1 install
}

# make uninstall
function make_uninstall() {
    echo "make uninstall..."
    $dosudo make -j1 -s -k uninstall >/dev/null 2>&1 || true
}

# Test if building debug version of package
# $1= package name
function isdebug() {
    local tag=${1}_DEBUG
    local dbg=${!tag}
    case "$dbg" in
        auto) [ "$MYTHBUILD" = "debug" ] && return 0 || return 1 ;;
        y|yes|Y|YES) return 0 ;;
        n|no|N|NO) return 1 ;;
        "") return 2 ;;
        *) die "Invalid debug value: $tag=$dbg" ;;
    esac
}

# Test for altivec instructions
function isAltivec() {
    case "$MYTHTARGET" in
        [Ww]indows) ;;
        MacOSX-i686) ;;
        MacOSX-PPC) ;; # Safer to say no
        [Hh]ost)
            case "$cpu" in
                [gG]3) ;;
                *) [ -r "/proc/cpuinfo" ] && grep -i "altivec" /proc/cpuinfo >/dev/null && return 0 ;;
            esac
            ;;
        *) ;;
    esac
    return 1
}

# Recursive file listing
# $1= prefix
function listfiles() {
    local d=$1 n
    for n in *; do
        if [ -d "$n" ]; then
            pushd "$n" >/dev/null
            listfiles "$d$n\\"
            popd >/dev/null
        else
            echo "$d$n"
        fi
    done
}

# 'make install' done indicator filename
# $1= package
function installed() {
    echo "$MYTHWORK/installed-$1"
}

# Print configuation and important environmental settings
function dumpenv() {
    echo "$myname $myargs"
    version
    echo "Current time: `date`"

    echo ""
    echo "MythTV version: `gitdescribe "$MYTHDIR/mythtv"`"
    echo ""

    uname -a
    which lscpu > /dev/null 2>&1 && { lscpu ; echo "" ; }
    echo "PATH: $PATH"
    echo "Cwd: $PWD"
    which df > /dev/null 2>&1 && { df -h . ; echo "" ; }
    which free > /dev/null 2>&1 && { free -m; echo "" ; }

    local ev evs="MYTHDIR MYTHWORK MYTHPATCHES MYTHGIT MYTHREPO SOURCEFORGE"
    for ev in $evs ; do
        echo "$ev=${!ev}"
    done
    echo ""

    local param param1="MYTHTARGET MYTHBUILD MYTHBRANCH readtimeout logging patches"
    local param2="cleanbuild reconfig reinstall cpu cpus makejobs verbose dosudo themes patchmaster"
    for param in $param1 $param2 ; do
        echo "$param=${!param}"
    done
    echo ""

    local pkg dbg
    for pkg in $debug_packages ; do
        dbg=${pkg}_DEBUG
        echo "$dbg=${!dbg}"
    done
    echo ""

    local cfg
    for pkg in $packages1 $packages2 $packages3 ; do
        cfg=${pkg}_CFG
        [ -n "${!cfg}" ] && echo "$cfg=\"${!cfg}\""
    done

    # Shell variable dump
    #set -o posix; set

    return 0
}

# Test for Windows target
function isWinTarget() {
    case "$MYTHTARGET" in
        [Ww]indows) return 0 ;;
    esac
    return 1
}


###############################################################
# Installation check
###############################################################

# ./configure done indicator
readonly stampconfig="stamp.mythtv.org"
# make done indicator
readonly stampbuild="stampbuild.mythtv.org"

# Myth build type
case "$MYTHBUILD" in
    "") if [ -e "$MYTHDIR/mythtv/mythtv/$stampconfig.debug" -o \
             -e "$MYTHDIR/mythtv/mythplugins/$stampconfig.debug" ]; then
            MYTHBUILD="debug"
        elif [ -e "$MYTHDIR/mythtv/mythtv/$stampconfig.profile" -o \
               -e "$MYTHDIR/mythtv/mythplugins/$stampconfig.profile" ]; then
            MYTHBUILD="profile"
        elif [ -e "$MYTHWORK/$QT/$stampconfig.debug" ]; then
            MYTHBUILD="debug"
        else
            MYTHBUILD="release"
        fi
        ;;
    debug|release|profile) ;;
    *) die "Invalid MYTHBUILD: $MYTHBUILD" ;;
esac


# Determine Myth version from branch name
function branch2ver() {
    case "$1" in
        *master) echo "master" ;;
        fixes/*) echo "${1#fixes/}" ;;
        *-[0-9].[1-9]*) echo "${1#*-}" ;;
        *) ;;
    esac
}
branch=$MYTHBRANCH
[ -z "$branch" ] && branch=`gitbranch "$MYTHDIR/mythtv"`
case "$branch" in
    "") : ${MYTHVER:="master"} ;;
    master) : ${MYTHVER:="master"} ;;
    fixes/*) : ${MYTHVER:=`branch2ver "$branch"`} ;;
esac


# Determine target build type
readonly stamptarget="$MYTHWORK/target"
if [ "$MSYSTEM" = "MINGW32" ]; then
    # Native Windows
    MYTHTARGET="Windows"
else
    case "$MYTHTARGET" in
        "") for t in MacOSX-i686 MacOSX-PPC Windows Host ; do
                if [ -e "$stamptarget-$t" ]; then
                    MYTHTARGET="$t"
                    break
                fi
            done
        : ${MYTHTARGET:="Windows"}
        ;;
        # Cross compile to Windows
        [Ww]indows) MYTHTARGET="Windows" ;;
        # Cross compile to MacOSX
        MacOSX-i686|MacOSX-PPC) ;;
        # Native build
        [Hh]ost) MYTHTARGET="Host" ;;
        *) die "Unsupported target system: $MYTHTARGET" ;;
    esac
fi


# Determine host architecture
machine=`uname -m`
case $machine in
    i?86|x86|i86pc) arch="x86" ;;
    x86_64)         arch="x86_64" ;;
    amd64|AMD64)    arch="x86_64" ;;
    ppc)            arch="ppc" ;;
    ppc64)          arch="ppc64" ;;
    ppc*)           arch="ppc" ;;
    *)              arch=$machine ;;
esac

# Set host triplet if cross compiling
bprefix=
if [ "$MYTHTARGET" != "Host" -a "$MSYSTEM" != "MINGW32" ]; then
    kernel=`uname -s`
    platform=`uname -i`
    os=`uname -o`
    case "$os" in
        GNU*|Gnu*|gnu*) os="gnu" ;;
    esac
    case "$arch:$kernel:$platform:$os" in
        x86:Linux:*:*)      bprefix="$machine-pc-linux-$os" ;;
        x86_64:Linux:*:*)   bprefix="$machine-unknown-linux-$os" ;;
        *:Linux:*:*)        bprefix="$machine-$platform-linux-$os" ;;
        *)                  bprefix="$machine-$platform-$os" ;;
    esac

    # Set target architecture
    case "$MYTHTARGET" in
        [Ww]indows) arch="x86" ;;
        MacOSX-i686) arch="x86" ;;
        MacOSX-PPC) arch="ppc" ;;
        *) die "Unhown target: $MYTHTARGET" ;;
    esac
fi


# Redirect output to log file as if invoked by: mythbuild.sh 2>&1 | tee -a mythbuild.log
if [ "$logging" = "yes" ]; then
    dumpenv >> "$logfile"
    pipe=`mktemp -u`
    if mkfifo "$pipe" >/dev/null 2>&1 ; then
        trap "rm -f $pipe" EXIT
        tee -a "$logfile" < "$pipe" &
        exec > "$pipe" 2>&1
    else
        echo "Unable to create named FIFO, logging disabled" >&2
    fi
fi


# Download the patches
function get_patches() {
    pushd "$MYTHDIR" >/dev/null
    local arc=`basename "$MYTHPATCHES_URL"`
    if [ "$cleanbuild" = "yes" ]; then
        [ ! -L "$MYTHPATCHES" ] && rm -rf "$MYTHPATCHES" "$arc"
    fi
    if [ ! -d "$MYTHPATCHES" ]; then
        [ ! -e "$arc" ] && download "$MYTHPATCHES_URL"
        unpack "$arc"
    fi
    popd >/dev/null
}


# Apply/reverse Myth patches
# $1=message $2=action $3.. args to patch
function patchmyth() {
    local message=$1 action=$2
    shift 2
    banner "$message all MythTV $MYTHVER patches." >&2
    read -p "Press [Return] to continue or [Control-C] to abort: "

    get_patches
    if [ -d "$MYTHDIR/mythtv" ]; then
        pushd "$MYTHDIR/mythtv" >/dev/null
        #rm -f $stampconfig*
        $action "mythtv-$MYTHVER" "$@" || true
        popd >/dev/null
    fi
}

case "$patches" in
    "") ;;
    apply)   [ -n "$MYTHVER" ] && patchmyth "Apply"   "dopatches"   "$@" ; exit ;;
    reverse) [ -n "$MYTHVER" ] && patchmyth "Reverse" "undopatches" "$@" ; exit ;;
    *) die "Unknown patches option: $patches" ;;
esac


# Display Myth branch & build type and wait for OK
banner "Building MythTV${branch:+ branch '$branch'} ($MYTHBUILD) for $MYTHTARGET" >&2
[ "$cleanbuild" = "yes" ] && echo "WARNING: All packages will be rebuilt from scratch." >&2
read -p "Press [Return] to continue or [Control-C] to abort: "
echo ""

# Change to the working dir
mkdir -p "$MYTHWORK"
cd "$MYTHWORK"


###############################################################
# Check for & install required tools
###############################################################

banner "Checking for required tools..."

readonly bindir="$MYTHINSTALL/bin"
readonly incdir="$MYTHINSTALL/include"
readonly libdir="$MYTHINSTALL/lib"
readonly windir="$MYTHINSTALL/win32"

if [ "$cleanbuild" = "yes" -o "$reinstall" = "yes" ]; then
    case "$MYTHINSTALL" in
        /|/usr|/usr/*|/opt) ;;
        *) rm -rf $bindir/ $incdir/ $libdir/ "$MYTHINSTALL/share/" || true ;;
    esac
    rm -f $( installed '*')
fi
mkdir -p "$bindir" "$incdir" "$libdir" || die "Failed to create install paths"

# Set PATH for configure scripts needing freetype-config & taglib-config sh scripts
export PATH="$bindir:$PATH"


# Check make
make --version >/dev/null 2>&1 || install_pkg make

# Parallel make
[ $makejobs -gt 1 ] && make="make -j$makejobs" || make="make"


# Check the C & C++ compilers exist
gcc --version >/dev/null 2>&1 || install_pkg gcc
g++ --version >/dev/null 2>&1 || install_pkg g++

if isWinTarget && [ "$MSYSTEM" != "MINGW32" ]; then
    # Cross compiling to Windows
    if [ -z "$xprefix" ]; then
        # Ubuntu 10.10
        if which i586-mingw32msvc-gcc >/dev/null 2>&1 ; then
            xprefix="i586-mingw32msvc"
        # Mandriva 2010.2 (32 bit)
        elif which i586-pc-mingw32-gcc >/dev/null 2>&1 ; then
            xprefix="i586-pc-mingw32"
        # Fedora 14
        elif which i686-pc-mingw32-gcc >/dev/null 2>&1 ; then
            xprefix="i686-pc-mingw32"
        elif xcc=`locate "/usr/bin/*mingw32*-gcc" 2>/dev/null` ; then
            xprefix=`basename "${xcc%-gcc}"`
        else
            die "mingw is required for cross compiling to Windows.\n"\
                "Try: sudo apt-get install mingw32\n"\
                "Or: sudo yum install mingw32-gcc.i686 mingw32-g++.i686"
        fi
    fi
elif [ "$MYTHTARGET" = "MacOSX-i686" ]; then
    # Cross compiling to MacOSX
    for xprefix in i686-apple-darwin11 i686-apple-darwin10 i686-apple-darwin9 i686-apple-darwin8 ; do
        which "$xprefix-gcc" >/dev/null 2>&1 && break
    done
elif [ "$MYTHTARGET" = "MacOSX-PPC" ]; then
    # Cross compiling to MacOSX
    for xprefix in powerpc-apple-darwin10 powerpc-apple-darwin9 powerpc-apple-darwin8 powerpc-apple-darwin7 ; do
        which "$xprefix-gcc" >/dev/null 2>&1 && break
    done
fi
# Check the C/C++ cross compilers exist
if [ -n "$xprefix" ]; then
    # Check the C/C++ cross compilers exist
    ${xprefix}-gcc --version >/dev/null 2>&1 || \
        die "The C cross compiler ${xprefix}-gcc is not installed."
    ${xprefix}-g++ --version >/dev/null 2>&1 || \
        die "The C++ cross compiler ${xprefix}-g++ is not installed."fi
fi


# Check patch
patch --version >/dev/null 2>&1 || install_pkg patch


# Need wget http://www.gnu.org/software/wget/ to download everything
if ! wget --version >/dev/null 2>&1 ; then
    if [ "$MSYSTEM" != "MINGW32" ]; then
        install_pkg wget
    # No wget so use ftp to download the wget source
    else
        if ! which ftp >/dev/null 2>&1 ; then
            echo "There is no FTP client so you must manually install wget from:"
            echo "  http://$SOURCEFORGE/gnuwin32/wget-1.11.4-1-setup.exe"
            echo "Run the installer and then add wget to the PATH:"
            echo "  Start > My Computer > RightClick: Properties"
            echo "  Tab: Advanced > Click: Environment Variables > Click: New"
            echo "  PATH=C:\Program Files\GnuWin32\bin"
            echo "Then restart any shells."
            exit 1
        fi
        name=$WINWGET; url=$WINWGET_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && ftpget $url
        [ ! -d $name ] && unpack $arc
        banner "Building $name"
        pushd "$name" >/dev/null
        cmd /c "configure.bat --mingw"
        cd src
        $make
        cp -p wget.exe /usr/bin/
        popd >/dev/null
    fi
fi


# Need unzip for mysql
if isWinTarget && ! which unzip >/dev/null 2>&1 ; then
    if [ "$MSYSTEM" != "MINGW32" ]; then
        install_pkg unzip
    else
        name=$WINUNZIP; url=$WINUNZIP_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        banner "Installing $name..."
        ./$arc -d "$name"
        cp -p "$name/unzip.exe" /usr/bin/
    fi
fi

# Need zip to create install archive
if isWinTarget && ! which zip >/dev/null 2>&1 ; then
    if [ "$MSYSTEM" != "MINGW32" ]; then
        install_pkg zip
    else
        name=$WINZIP; url=$WINZIP_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        banner "Installing $name..."
        unzip -d "$name" "$arc"
        cp -p "$name/zip.exe" /usr/bin/
    fi
fi


# Need pkg-config
if ! pkg-config --version >/dev/null 2>&1 ; then
    if [ "$MSYSTEM" != "MINGW32" ]; then
        install_pkg pkg-config
    else
        name=$PKGCONFIG; url=$PKGCONFIG_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        unzip -d "$name" "$arc"
        cp -p "$name/bin/pkg-config.exe" /usr/bin/

        name=$GLIB; url=$GLIB_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        unzip -d "$name" "$arc"
        cp -p "$name/bin/libglib-2.0-0.dll" /usr/bin/

        name=$GETTEXT; url=$GETTEXT_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        unzip -d "$name" "$arc"
        cp -p "$name/bin/intl.dll" /usr/bin/
    fi
fi


# Need git to get myth sources
if ! git --version >/dev/null 2>&1 ; then
    if [ "$MSYSTEM" != "MINGW32" ]; then
        install_pkg git-core
    else
        gitexe="c:\Program Files\Git\bin\git.exe"
        gitexe32="C:\Program Files (x86)\Git\bin\git.exe"
        if [ ! -e "$gitexe" -a ! -e "$gitexe32" ]; then
            name=$WINGIT; url=$WINGIT_URL; arc=`basename "$url"`
            [ ! -e "$arc" ] && download "$url"
            banner "Installing $name..."
            ./$arc
        fi
        [ -e "$gitexe32" ] && gitexe="$gitexe32"
        args='$@'
        cat >/usr/bin/git <<-EOF
			#!/bin/sh
			"$gitexe" $args
		EOF
        if ! git --version >/dev/null ; then
            rm /usr/bin/git
            echo "Although $WINGIT was installed, the git program cannot be found."
            echo "You must add the directory containing git.exe to PATH and restart this script."
            exit 1
        fi
    fi
fi


# Need YASM http://www.tortall.net/projects/yasm for FFMpeg
if [ "$arch" = "x86" ] &&  ! which yasm >/dev/null 2>&1 ; then
    name=$YASM; url=$YASM_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Building $name..."
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    ./configure -q "--prefix=$MYTHINSTALL" $YASM_CFG
    $make
    make_install
    popd >/dev/null
fi


# Download the patches
get_patches


# Apply the mingw <float.h> patch for Qt
# Qt tools/qlocale.cpp:6628: error: ‘_clear87’ was not declared in this scope
# Qt tools/qlocale.cpp:6629: error: ‘_control87’ was not declared in this scope
# $1= sudo
# $2.. patch args
function patchmingw() {
    local gccversion=`${xprefix:+$xprefix-}gcc -dumpversion`
    local path1 path2
    local dosudo=$1
    shift

    case "$xprefix" in
        i586-mingw32msvc) # Ubuntu 10.04, 10.10
            path1="/usr/$xprefix/include"
            path2="/usr/lib/gcc/$xprefix/$gccversion/include"
            ;;
        i586-pc-mingw32) # Mandriva 2010.2 (32 bit)
            path1="/usr/$xprefix/sys-root/mingw/include"
            path2="/usr/lib/gcc/$xprefix/$gccversion/include"
            ;;
        i686-pc-mingw32) # Fedora 14
            path1="/usr/$xprefix/sys-root/mingw/include"
            [ -d "/usr/lib64/gcc/$xprefix/$gccversion/include" ] && \
                path2="/usr/lib64/gcc/$xprefix/$gccversion/include" ||
                path2="/usr/lib/gcc/$xprefix/$gccversion/include"
            ;;
        *mingw*)
            echo "WARNING: Guessing include paths"
            path1="/usr/${xprefix:+$xprefix/}include"
            path2="/usr/lib/gcc/${xprefix:+$xprefix/}$gccversion/include"
            ;;
        *) die "Unable to patch this compiler: $xprefix" ;;
    esac

	$dosudo patch -p0 "$@" <<-EOF
		--- $path1/float.h	2009-06-30 10:32:33.000000000 +0200
		+++ $path1/float.h	2010-11-03 22:55:07.000000000 +0100
		@@ -16,7 +16,7 @@
		  *
		  */
		 
		-#include_next<float.h>
		+
		 
		 #ifndef _MINGW_FLOAT_H_
		 #define _MINGW_FLOAT_H_
		--- $path2/float.h	2010-01-03 02:57:35.000000000 +0100
		+++ $path2/float.h	2010-01-03 02:57:35.000000000 +0100
		@@ -27,6 +27,7 @@
		 /*
		  * ISO C Standard:  5.2.4.2.2  Characteristics of floating types <float.h>
		  */
		+#include_next<float.h>
		 
		 #ifndef _FLOAT_H___
		 #define _FLOAT_H___
	EOF
}

function patchmingw32() {
    local gccversion=$(gcc -dumpversion)
    local path="/mingw/lib/gcc/mingw32/$gccversion/include"

	$dosudo patch -p0 "$@" <<-EOF
		--- $path/float.h	2012-03-10 17:43:36 +0100
		+++ $path/float.h	2012-03-10 17:25:34 +0100
		@@ -28,6 +28,8 @@ see the files COPYING3 and COPYING.RUNTI
		 #ifndef _FLOAT_H___
		 #define _FLOAT_H___
		 
		+#include_next <float.h>
		+
		 /* Radix of exponent representation, b. */
		 #undef FLT_RADIX
		 #define FLT_RADIX	__FLT_RADIX__
	EOF
}

# Check if the mingw <float.h> patch for Qt is required
function check_float() {
    ${xprefix:+$xprefix-}gcc -c -x c++ - -o /dev/null >/dev/null 2>&1 <<-EOF
		#include <float.h>
		int main(void){ _clear87(); _control87(0,0); return 0; }
	EOF
}
if isWinTarget && ! check_float ; then
    echo ""
    echo "The $xprefix <float.h> header must be patched to compile Qt."
    while read -p "Do you wish to apply this patch (sudo is required) [Yn] " ; do
        case "$REPLY" in
            n|no|N) echo "NOTE: Qt may not build."; break ;;
            y|yes|Y|"")
                if [ "$MSYSTEM" == "MINGW32" ]; then
                    patchmingw32 "" -s --dry-run && patchmingw32 || true
                else
                    patchmingw "" -s --dry-run && patchmingw "sudo" || true
                fi
                if ! check_float ; then
                    echo ""
                    echo "WARNING: The patch failed. Qt may not build."
                    read -p "Press [Return] to continue or [Control-C] to abort "
                fi
                break
                ;;
        esac
    done
fi


###############################################################
# Start of build
###############################################################
# Set the pkg-config search path
export PKG_CONFIG_PATH="$libdir/pkgconfig"
mkdir -p "$PKG_CONFIG_PATH"
# If cross-compiling set the pkg-config default search directory
[ -n "$xprefix" ] && export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"

case "$arch" in
    ppc*)
        # To run mythtv need to build all shared libs without R_PPC_REL24 relocations.
        # 24-bit (4*16Meg) limit to pc relative addresses causes ld.so to fail
        export CFLAGS="-fPIC $CFLAGS"
        export CXXFLAGS="-fPIC $CXXFLAGS"
        export LDFLAGS="-fPIC $LDFLAGS"
        ;;
esac


# Check for clean re-build
if [ "$cleanbuild" = "yes" ]; then
    echo "NOTE: Clean rebuild"
    for d in $MYTHWORK/* ; do [ -d "$d" ] && rm -rf "$d" ; done
    # Force a reconfigure
    rm -f "$stamptarget-$MYTHTARGET"
else
    # Re-make named packages
    for name in $forcebuild ; do
        case "$name" in
            MYTHTV|mythtv)
                rm -f "$MYTHDIR/mythtv/mythtv/$stampbuild"
                ;;
            MYTHPLUGINS|mythplugins)
                rm -f "$MYTHDIR/mythtv/mythplugins/$stampbuild"
                ;;
            MYTHTHEMES|myththemes)
                rm -f "$MYTHDIR/myththemes/$stampbuild"
                ;;
            *)
                [ -n "${!name}" ] || die "No such package: $name"
                rm -f "$MYTHWORK/${!name}/$stampbuild"
                ;;
        esac
        echo "NOTE: make $name"
    done
fi


# Test if changing target
if [ ! -e "$stamptarget-$MYTHTARGET" ]; then
    echo "NOTE: Target type changed, reconfiguring all packages"
    rm -f $( installed '*')
    rm -f $stamptarget-*
    touch "$stamptarget-$MYTHTARGET"
    reconfig="yes"
fi


# Ensure packages are rebuilt if their debug status has changed
for name in $debug_packages LIBXML2 ; do
    pkg=${!name}
    if isdebug $name; then
        [ ! -e "$MYTHWORK/$pkg/$stampconfig.debug" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    elif [ $? -eq 1 ]; then
        [ ! -e "$MYTHWORK/$pkg/$stampconfig.release" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    else
        [ ! -e "$MYTHWORK/$pkg/$stampconfig" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    fi
done


# Build and install a library
# $1= lib name
# $2...= optional configure args
function build() {
    local lib=$1
    shift
    local liburl=${lib}_URL
    local libcfg=${lib}_CFG
    local libdbg=${lib}_DEBUGFLAG
    local name=${!lib}
    [ -n "$name" ] || die "No directory for $lib"
    local url=${!liburl}
    [ -n "$url" ] || die "No URL for $lib"
    local arc=`basename "$url"`

    # Debug build?
    local buildtag="" debugflag=""
    if isdebug $lib ; then
        buildtag="debug"
        debugflag=${!libdbg}
    elif [ "$?" = "1" ]; then
        buildtag="release"
    fi
    local stampconfigtag="$stampconfig${buildtag:+.$buildtag}"

    # Download
    [ ! -e "$arc" ] && download "$url"

    banner "Building $name${buildtag:+ ($buildtag)}"

    [ "$clean" = "yes" ] && rm -rf "$name"

    # Unpack
    [ ! -d "$name" ] && unpack "$arc"

    # Patch
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild" "$stampconfigtag"

    # Force configure if clean re-build
    [ "$reconfig" = "yes" ] && rm -f "$stampbuild" "$stampconfigtag"

    # configure
    if [ ! -e "$stampconfigtag" -o -n "${!libcfg}" -o ! -e "Makefile" ]; then
        rm -f "$stampconfigtag"
        [ -e Makefile ] && make_distclean || true
        set -x
        ./configure "--prefix=$MYTHINSTALL" ${xprefix:+--host=$xprefix} \
            ${bprefix:+--build=$bprefix} $debugflag "$@" ${!libcfg}
        set +x
        # Call post-config function if defined
        local libpost=${lib}_POST
        local libpostv=${!libpost}
        [ -n "$libpostv" ] && $libpostv
        pausecont
        touch "$stampconfigtag"
        rm -f "$stampbuild"
    fi

    # make
    local stampinstall="$( installed $name)"
    if [ ! -e "$stampbuild" ] ; then
        $make
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi

    # install
    if [ ! -e "$stampinstall" ]; then
        make_install
        touch "$stampinstall"
    fi
    popd >/dev/null
}

###############################################################################
# unzip - http://www.info-zip.org
# Build custom SFXWiz32.exe with autorun & bugfix for mythinstaller
if isWinTarget ; then
    name=$UNZIP; url=$UNZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Building $name..."
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    # BUG: SFXWiz32.exe fails with insufficient memory in init
    dopatches "$name" || rm -f Makefile
    if [ ! -e Makefile ]; then
        cp -f win32/Makefile.gcc Makefile
        set -x
        $make ${xprefix:+CC=$xprefix-gcc} \
            ${xprefix:+AR=$xprefix-ar} \
            ${xprefix:+RC=$xprefix-windres} \
            LOCAL_UNZIP="-DCHEAP_SFX_AUTORUN" \
            guisfx
        set +x
    fi
    popd >/dev/null
fi

###############################################################################
# Install pthreads - http://sourceware.org/pthreads-win32/
if isWinTarget ; then
    comp=PTHREADS; compurl=${comp}_URL; compcfg=${comp}_CFG
    name=${!comp}; url=${!compurl}; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild"
    [ "$reconfig" = "yes" ] && rm -f "$stampbuild"
    if [ ! -e "$stampbuild" ] ; then
        $make -s -k -f GNUmakefile ${xprefix:+CROSS=$xprefix-} clean > /dev/null 2>&1
        $make -f GNUmakefile ${xprefix:+CROSS=$xprefix-} GC ${!compcfg}
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi
    if [ ! -e "$stampinstall" ]; then
        # cp -p libpthreadGC2.a "$libdir/libpthread.a"
        cp -p libpthreadGC2.a "$libdir/"
        cp -p pthreadGC2.dll "$bindir/"
        cp -p sched.h semaphore.h pthread.h "$incdir/"
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# Install zlib - http://www.zlib.net/
if isWinTarget ; then
    comp=ZLIB; compurl=${comp}_URL; compcfg=${comp}_CFG
    name=${!comp}; url=${!compurl}; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild"
    [ "$reconfig" = "yes" ] && rm -f "$stampbuild"
    if [ ! -e "$stampbuild" ] ; then
        $make -s -k -f win32/Makefile.gcc clean
        $make -f win32/Makefile.gcc ${xprefix:+PREFIX=$xprefix-} SHARED_MODE=1 IMPLIB=libz.dll.a
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi
    if [ ! -e "$stampinstall" ]; then
        $make -s -f win32/Makefile.gcc \
            "BINARY_PATH=$bindir" "INCLUDE_PATH=$incdir" "LIBRARY_PATH=$libdir" \
            SHARED_MODE=1 IMPLIB=libz.dll.a install
        # Create libtool file needed by taglib
        cat > "$libdir/libz.la" <<-END
			# libz.la - a libtool library file
			# Generated by ltmain.sh (GNU libtool)
			dlname='$bindir/zlib1.dll'
			library_names='libz.dll.a'
			old_library='libz.a'
			inherited_linker_flags=''
			dependency_libs='-lmsvcrt'
			weak_library_names=''
			current=0
			age=0
			revision=1
			installed=yes
			shouldnotlink=no
			dlopen=''
			dlpreopen=''
			libdir='$libdir'
		END
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# Install freetype - http://savannah.nongnu.org/projects/freetype/
# Including path to zlib
CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build FREETYPE

###############################################################################
# Install lame - http://lame.sourceforge.net/index.php
LAME_DEBUGFLAG="--enable-debug=norm"
build LAME --disable-frontend

###############################################################################
# Install libxml2 - http://xmlsoft.org

# BUG building with MSys get error in testThreads.c line 110
#build LIBXML2 $( [ "$MSYSTEM" = "MINGW32" ] && echo "--without-threads")
# Also when xbuilding on some 'used' Fedora 14 32/64 bit
#
# However:
#build LIBXML2 --without-threads
# xcompile on Ubuntu: runxmlconf.c:271: undefined reference to `__imp__xmlLastError'
#
# NB configure will pickup host python and try to install support:
# libtool: compile:  i686-pc-mingw32-gcc -DHAVE_CONFIG_H -I. -I.. -I/usr/include/python2.7 -I../include -I../include -I../python -DWIN32 -g -O2 -pedantic -W -Wformat -Wunused -Wimplicit -Wreturn-type -Wswitch -Wcomment -Wtrigraphs -Wformat -Wchar-subscripts -Wuninitialized -Wparentheses -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Winline -Wredundant-decls -MT libxml.lo -MD -MP -MF .deps/libxml.Tpo -c ./libxml.c  -DDLL_EXPORT -DPIC -o .libs/libxml.o
#In file included from /usr/include/python2.7/Python.h:8:0,
#                 from ./libxml_wrap.h:1,
#                 from ./types.c:9:
#/usr/include/python2.7/pyconfig.h:1:27: fatal error: bits/wordsize.h: No such file or directoryIn file included from /usr/include/python2.7/Python.h:8:0,

# Including path to zlib
# --with-reader required by spumux (mytharhive util) link to xmlReaderForIO
# --with-html required by libxslt
# --with-xpath required by libxslt (mytharhive util) link to xmlXPathFreeCompExpr
# --with-tree required by libxslt (mytharhive util) link to xmlNewChild
# --with-valid required by libxslt (mytharhive util) link to xmlNewValidCtxt
# --with-schemas required by libxslt (mytharhive util) link to xmlSchemaValidateDoc
# --with-schematron required by libxslt (mytharhive util) link to xmlSchemaValidateDoc
# --with-c14n required by libxslt (mytharhive util) link to xmlC14NDocDumpMemory
# --with-xinclude required by libxslt (mytharhive util) link to xmlXIncludeProcessTree
# --with-xptr required by --with-xinclude
# The windows xbuild needs LDFLAGS="-Wl,--export-all" otherwise the variable xmlLastError is not exported
CPPFLAGS="-I$incdir $CPPFLAGS" \
LDFLAGS="`isWinTarget && echo "-Wl,--export-all"` -L$libdir $LDFLAGS" \
build LIBXML2 --with-minimum --with-output --with-reader \
 --with-html --with-xpath  --with-tree --with-valid --with-schemas --with-schematron --with-c14n --with-xinclude --with-xptr 
#build LIBXML2 $( [ "$MSYSTEM" = "MINGW32" ] && echo "--without-threads") --without-python


###############################################################################
# Install libxslt - http://xmlsoft.org
# Required by Python bindings used by mytharchive

CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build LIBXSLT --without-crypto --without-debug --without-debugger --without-plugins


###############################################################################
# DirectX - http://msdn.microsoft.com/en-us/directx/
if isWinTarget ; then
    name=$WINE; url=$WINE_URL; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Installing DirectX headers from $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || true
    if [ ! -e "$stampinstall" ]; then
        cp -p "include/dsound.h" "$incdir/"
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# DXVA2
if isWinTarget && [ "$DXVA2" == "yes" ]; then
    url=$DXVA2_URL; arc=`basename "$url"`
    stampinstall="$( installed DXVA2)"

    [ ! -e "$arc" ] && download "$url"
    banner "Installing DXVA2 header"
    if [ ! -e "$stampinstall" ]; then
        cp -p "$arc" "$incdir/"
        touch "$stampinstall"
    fi
fi

###############################################################################
# Install libexif - http://libexif.sourceforge.net/
# For MythGallery
build LIBEXIF

###############################################################################
# Install libogg - http://www.xiph.org/ogg/
# For MythMusic
build LIBOGG

###############################################################################
# Install libvorbis - http://www.xiph.org/vorbis/
# For MythMusic
build LIBVORBIS

###############################################################################
# Install flac - http://flac.sourceforge.net/
# For MythMusic
FLAC_DEBUGFLAG="--enable-debug"
# --disable-cpplibs 'cos examples/cpp/encode/file/main.cpp doesn't #include <string.h> for memcmp
# --disable-ogg 'cos otherwise need libogg in all config tests
# Need to set LD_LIBRARY_PATH so ld.so can find libogg when configure runs ogg test
#LD_LIBRARY_PATH="$( [ "$MYTHTARGET" = "Host" ] && echo "${libdir}:" )$LD_LIBRARY_PATH" \
build FLAC --disable-cpplibs --disable-ogg $( isAltivec || echo "--disable-altivec")

###############################################################################
# Install libcdio - http://www.gnu.org/software/libcdio/
# For MythMusic
# --disable-joliet or need iconv
build LIBCDIO --disable-joliet

###############################################################################
# Install taglib - http://freshmeat.net/projects/taglib
# For MythMusic
TAGLIB_DEBUGFLAG="--enable-debug=yes"
# Including path to zlib
CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build TAGLIB

###############################################################################
# Install fftw - http://www.fftw.org/
# For MythMusic
FFTW_DEBUGFLAG="--enable-debug"
[ ! -e "$libdir/libfftw3.a" ] && rm -f $MYTHWORK/$FFTW/$stampconfig*
build FFTW --enable-threads $( isAltivec || echo "--disable-altivec")
# Single precision
[ ! -e "$libdir/libfftw3f.a" ] && rm -f $MYTHWORK/$FFTW/$stampconfig*
build FFTW --enable-threads --enable-float $( isAltivec || echo "--disable-altivec")

###############################################################################
# Install libsdl - http://www.libsdl.org/
# For MythMusic, needed by libvisual
args="--disable-video-ps3"
isAltivec || args="$args --disable-altivec" 
#CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build LIBSDL $args 

###############################################################################
# Install libvisual - http://libvisual.sourceforge.net/
# For MythMusic
LIBVISUAL_DEBUGFLAG="--enable-debug"
build LIBVISUAL --disable-threads

###############################################################################
# Install libdvdcss - http://www.videolan.org/developers/libdvdcss.html
# For MythVideo
# NB need LDFLAGS=-no-undefined to enable dll creation
LDFLAGS="-Wl,-no-undefined${LDFLAGS:+ $LDFLAGS}" build LIBDVDCSS

###############################################################################
# Install MySQL - http://mysql.com/
if isWinTarget ; then
    name=$MYSQLW; url=$MYSQLW_URL; arc=`basename "$url"`
    stampinstall="$( installed $name)"
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || true
    # Debug build asserts at libmysql.c line 4314: param_>buffer_length != 0
    # Triggered from mythmusic::Playlist::loadPlaylist(backup_playlist_storage)
    # and mythvideo/browse if the query returns a zero length blob.
    #isdebug MYSQL && MYSQLW_LIB="lib/debug" || MYSQLW_LIB="lib/opt"
    MYSQLW_LIB="lib/opt"
    if [ ! -e "$stampinstall" ]; then
        cd "$bindir"
        # Create config file for Qt
        cat > mysql_config <<-END
			#!/bin/sh
			case "\$1" in
				--include)       echo "-I$incdir/mysql" ;;
				--libs|--libs_r) echo "-L$libdir -lmysql" ;;
				--version)       echo "${MYSQLW:6:6}"
			esac
		END
        chmod +x mysql_config
        cd "$incdir"
        ln -f -s "$MYTHWORK/$name/include" mysql
        cd "$libdir"
        ln -f -s "$MYTHWORK/$name/$MYSQLW_LIB/mysqlclient.lib" .
        cp -p "$MYTHWORK/$name/$MYSQLW_LIB/libmysql.lib" .
        # For mythzoneminder
        cp -p "$MYTHWORK/$name/$MYSQLW_LIB/libmysql.lib" libmysql.a
        touch "$stampinstall"
    fi
    popd >/dev/null
elif [ "$MYTHTARGET" = "MacOSX-i686" -o "$MYTHTARGET" = "MacOSX-PPC" ]; then
    if [ "$MYTHTARGET" = "MacOSX-i686" ]; then
        name=$MYSQLM; url=$MYSQLM_URL;
    else
        name=$MYSQLX; url=$MYSQLX_URL;
    fi
    arc=`basename "$url"`
    stampinstall="$( installed $name)"
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || true
    if [ ! -e "$stampinstall" ]; then
        cd "$bindir"
        # Create config file for Qt
        cat > mysql_config <<-END
			#!/bin/sh
			case "\$1" in
				--include) echo "-I$incdir/mysql" ;;
				--libs)    echo "-L$libdir/mysql -lmysqlclient -lz" ;;
				--libs_r)  echo "-L$libdir/mysql -lmysqlclient_r -lz" ;;
				--version) echo "${MYSQLM:6:6}"
			esac
		END
        chmod +x mysql_config
        cd "$incdir"
        ln -f -s "$MYTHWORK/$name/include/" mysql
        cd "$libdir"
        ln -f -s "$MYTHWORK/$name/lib/" mysql
        touch "$stampinstall"
    fi
    popd >/dev/null
else
    MYSQL_DEBUGFLAG="--with-debug"
    # BUG: debug build of mysql 5.1.54 enables -Werror which errors with
    # gcc 4.4.5 so disable those warnings...
    CXXFLAGS="-Wno-uninitialized $CXXFLAGS" \
    CFLAGS="-Wno-unused-result -Wno-unused-function $CFLAGS" \
    build MYSQL --enable-thread-safe-client \
        --without-server --without-docs --without-man --without-geometry
    # v5.0 --without-extra-tools --without-bench
fi

###############################################################################
# Build Qt - http://get.qt.nokia.com/
###############################################################################
comp=QT; compurl=${comp}_URL; compcfg=${comp}_CFG
name=${!comp}; url=${!compurl}; arc=`basename "$url"`
stampinstall="$( installed $name)"

if isdebug QT ; then
    debug="debug"
    # BUG: debug build with i586-mingw32msvc-gcc version 4.2.1 fails due to
    # multiple definitions of inline functions like powf conflicting with stdlibc++
    # Workaround: set CXXFLAGS=-O1 before configuring Qt
    cxxflags_save=$CXXFLAGS
    export CXXFLAGS="$CXXFLAGS -O1"
else
    debug="release"
fi

# Create a mkspecs tailored for the xprefix of the cross tool
function mkspecsW32() {
    # mkspecs name
    qtXplatform="win32-g++linux"
    rm -rf "mkspecs/$qtXplatform"
    mkdir -p "mkspecs/$qtXplatform"
    cp -f "mkspecs/win32-g++/qplatformdefs.h" "mkspecs/$qtXplatform/"
    cat > "mkspecs/$qtXplatform/qmake.conf" <<-EOF
		#
		# qmake configuration for cross building with Mingw on Linux
		#
		
		MAKEFILE_GENERATOR	= MINGW
		TARGET_PLATFORM		= win32
		TEMPLATE            = app
		CONFIG              += qt warn_on release link_prl copy_dir_files debug_and_release debug_and_release_target precompile_header
		QT                  += core gui
		DEFINES             += UNICODE QT_LARGEFILE_SUPPORT
		QMAKE_INCREMENTAL_STYLE = sublib
		QMAKE_COMPILER_DEFINES  += __GNUC__ WIN32
		QMAKE_EXT_OBJ       = .o
		QMAKE_EXT_RES       = _res.o
		
		include(../common/g++.conf)
		include(../common/unix.conf)
		
		QMAKE_RUN_CC		= \$(CC) -c \$(CFLAGS) \$(INCPATH) -o \$obj \$src
		QMAKE_RUN_CC_IMP	= \$(CC) -c \$(CFLAGS) \$(INCPATH) -o \$@ \$<
		QMAKE_RUN_CXX		= \$(CXX) -c \$(CXXFLAGS) \$(INCPATH) -o \$obj \$src
		QMAKE_RUN_CXX_IMP	= \$(CXX) -c \$(CXXFLAGS) \$(INCPATH) -o \$@ \$<
		
		##########################################
		# Mingw customization of g++.conf
		QMAKE_CC                = ${xprefix:+$xprefix-}gcc
		QMAKE_CXX               = ${xprefix:+$xprefix-}g++
		QMAKE_CFLAGS_SHLIB	=
		QMAKE_CFLAGS_STATIC_LIB	=
		QMAKE_CFLAGS_THREAD     += -D_REENTRANT
		QMAKE_CXXFLAGS_SHLIB	=
		QMAKE_CXXFLAGS_STATIC_LIB =
		QMAKE_CXXFLAGS_THREAD	+= \$\$QMAKE_CFLAGS_THREAD
		QMAKE_CXXFLAGS_RTTI_ON	= -frtti
		QMAKE_CXXFLAGS_RTTI_OFF	= -fno-rtti
		QMAKE_CXXFLAGS_EXCEPTIONS_ON = -fexceptions -mthreads
		QMAKE_CXXFLAGS_EXCEPTIONS_OFF = -fno-exceptions
		
		QMAKE_LINK              = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_SHLIB        = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_C            = ${xprefix:+$xprefix-}gcc
		QMAKE_LINK_C_SHLIB      = ${xprefix:+$xprefix-}gcc
		QMAKE_LFLAGS            = -enable-stdcall-fixup -Wl,-enable-auto-import -Wl,-enable-runtime-pseudo-reloc
		QMAKE_LFLAGS_EXCEPTIONS_ON = -mthreads
		QMAKE_LFLAGS_EXCEPTIONS_OFF =
		QMAKE_LFLAGS_RELEASE	+= -Wl,-s
		QMAKE_LFLAGS_DEBUG      =
		QMAKE_LFLAGS_CONSOLE	+= -Wl,-subsystem,console
		QMAKE_LFLAGS_WINDOWS	+= -Wl,-subsystem,windows
		QMAKE_LFLAGS_DLL        += -shared
		QMAKE_LFLAGS_PLUGIN     += -shared
		
		QMAKE_LINK_OBJECT_MAX	= 30
		QMAKE_LINK_OBJECT_SCRIPT= object_script
		
		##########################################
		# mingw target
		QMAKE_INCDIR            =
		QMAKE_LIBDIR            += \$\$[QT_INSTALL_LIBS]
		QMAKE_INCDIR_QT         = \$\$[QT_INSTALL_HEADERS]
		QMAKE_LIBDIR_QT         = \$\$[QT_INSTALL_LIBS]
		
		QMAKE_INCDIR_X11        =
		QMAKE_LIBDIR_X11        =
		QMAKE_INCDIR_OPENGL     =
		QMAKE_LIBDIR_OPENGL     =
		QMAKE_INCDIR_OPENGL_ES1 =
		QMAKE_LIBDIR_OPENGL_ES1 =
		QMAKE_INCDIR_OPENGL_ES2 =
		QMAKE_LIBDIR_OPENGL_ES2 =
		QMAKE_LIBS_X11          =
		QMAKE_LIBS_X11SM        =
		
		QMAKE_LIBS              =
		QMAKE_LIBS_CORE         = -lkernel32 -luser32 -lshell32 -luuid -lole32 -ladvapi32 -lws2_32
		QMAKE_LIBS_GUI          = -lgdi32 -lcomdlg32 -loleaut32 -limm32 -lwinmm -lwinspool -lws2_32 -lole32 -luuid -luser32 -ladvapi32
		QMAKE_LIBS_OPENGL       = -lglu32 -lopengl32 -lgdi32 -luser32
		QMAKE_LIBS_OPENGL_QT    =
		QMAKE_LIBS_NETWORK      = -lws2_32
		QMAKE_LIBS_COMPAT       = -ladvapi32 -lshell32 -lcomdlg32 -luser32 -lgdi32 -lws2_32
		QMAKE_LIBS_QT_ENTRY     = -lmingw32 -lqtmain
		
		# Linux hosted Qt cross tools
		QMAKE_MOC               = \$\$[QT_INSTALL_BINS]/moc
		QMAKE_UIC               = \$\$[QT_INSTALL_BINS]/uic
		QMAKE_IDC               = \$\$[QT_INSTALL_BINS]/idc
		
		# Linux hosted Mingw tools
		#QMAKE_AR                = ${xprefix:+$xprefix-}ar cqs
		QMAKE_LIB               = ${xprefix:+$xprefix-}ar -ru
		QMAKE_OBJCOPY           = ${xprefix:+$xprefix-}objcopy
		QMAKE_RANLIB            = ${xprefix:+$xprefix-}ranlib
		QMAKE_STRIP             = ${xprefix:+$xprefix-}strip
		QMAKE_STRIPFLAGS_LIB    += --strip-unneeded
		QMAKE_RC                = ${xprefix:+$xprefix-}windres
		#QMAKE_IDL               = midl
		
		# Linux hosted coreutils
		QMAKE_TAR               = tar -cf
		QMAKE_GZIP              = gzip -9f
		QMAKE_ZIP               = zip -r -9
		
		QMAKE_COPY              = cp -f
		QMAKE_COPY_FILE         = \$(COPY)
		QMAKE_COPY_DIR          = \$(COPY) -r
		QMAKE_MOVE              = mv -f
		QMAKE_DEL_FILE          = rm -f
		QMAKE_DEL_DIR           = rmdir
		QMAKE_CHK_DIR_EXISTS    = test -d
		QMAKE_MKDIR             = mkdir -p
		QMAKE_INSTALL_FILE      = install -m 644 -p
		QMAKE_INSTALL_PROGRAM   = install -m 755 -p
		
		load(qt_config)
	EOF
}

function mkspecsOSX() {
    # mkspecs name
    qtXplatform="macx-g++linux"
    rm -rf "mkspecs/$qtXplatform"
    mkdir -p "mkspecs/$qtXplatform"
    cp -f "mkspecs/macx-g++/Info.plist.app" "mkspecs/$qtXplatform/"
    cp -f "mkspecs/macx-g++/Info.plist.lib" "mkspecs/$qtXplatform/"
    cp -f "mkspecs/macx-g++/qplatformdefs.h" "mkspecs/$qtXplatform/"
    local frameworks=`$xprefix-cpp -v 2>&1 </dev/null | grep -m 1 /System/Library/Frameworks | cut -d ' ' -f 2`
    cat > "mkspecs/$qtXplatform/qmake.conf" <<-EOF
		#
		# qmake configuration for cross building to MacOSX on Linux
		#
		MAKEFILE_GENERATOR  = UNIX
		TARGET_PLATFORM     = macx
		TEMPLATE            = app
		CONFIG              += qt warn_on release app_bundle incremental global_init_link_order lib_version_first plugin_no_soname link_prl
		QT                  += core gui
		QMAKE_INCREMENTAL_STYLE = sublib
		QMAKE_CC                = ${xprefix:+$xprefix-}gcc
		QMAKE_CXX               = ${xprefix:+$xprefix-}g++
		include(../common/mac-g++.conf)
		##########################################
		# customization of mac-g++.conf
		QMAKE_CFLAGS_THREAD     += -D_REENTRANT
		QMAKE_CXXFLAGS_RTTI_ON	= -frtti
		QMAKE_CXXFLAGS_RTTI_OFF	= -fno-rtti
		QMAKE_CXXFLAGS_EXCEPTIONS_ON = -fexceptions -mthreads
		QMAKE_CXXFLAGS_EXCEPTIONS_OFF = -fno-exceptions
		QMAKE_LINK              = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_SHLIB        = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_C            = ${xprefix:+$xprefix-}gcc
		QMAKE_LINK_C_SHLIB      = ${xprefix:+$xprefix-}gcc
		QMAKE_LFLAGS_EXCEPTIONS_ON = -mthreads
		QMAKE_LFLAGS_EXCEPTIONS_OFF =
		##########################################
		QMAKE_INCDIR            =
		#QMAKE_LIBDIR            += \$\$[QT_INSTALL_LIBS]
		QMAKE_INCDIR_QT         = \$\$[QT_INSTALL_HEADERS]
		QMAKE_LIBDIR_QT         = \$\$[QT_INSTALL_LIBS]
		QMAKE_INCDIR_OPENGL     = $frameworks/OpenGL.framework/Headers $frameworks/AGL.framework/Headers
		# Linux hosted Qt cross tools
		QMAKE_MOC               = \$\$[QT_INSTALL_BINS]/moc
		QMAKE_UIC               = \$\$[QT_INSTALL_BINS]/uic
		QMAKE_IDC               = \$\$[QT_INSTALL_BINS]/idc
		# Linux hosted cross tools
		QMAKE_AR                = ${xprefix:+$xprefix-}ar cq
		QMAKE_LIB               = ${xprefix:+$xprefix-}ar -ru
		QMAKE_OBJCOPY           = ${xprefix:+$xprefix-}objcopy
		QMAKE_RANLIB            = ${xprefix:+$xprefix-}ranlib -s
		#QMAKE_STRIP             = ${xprefix:+$xprefix-}strip
		#QMAKE_STRIPFLAGS_LIB    += --strip-unneeded
		# Linux hosted coreutils
		QMAKE_TAR               = tar -cf
		QMAKE_GZIP              = gzip -9f
		QMAKE_ZIP               = zip -r -9
		QMAKE_COPY              = cp -f
		QMAKE_MOVE              = mv -f
		QMAKE_DEL_FILE          = rm -f
		QMAKE_DEL_DIR           = rmdir
		QMAKE_CHK_DIR_EXISTS    = test -d
		QMAKE_MKDIR             = mkdir -p
		load(qt_config)
	EOF
}
[ ! -e "$arc" ] && download "$url"
banner "Building $name ($debug)"
[ "$clean" = "yes" ] && rm -rf "$name"
[ ! -d "$name" ] && unpack "$arc"
pushd "$name" >/dev/null
dopatches "$name" || rm -f "$stampbuild" $stampconfig*
[ "$reconfig" = "yes" ] && rm -f "$stampbuild" $stampconfig*
if [ ! -e "$stampconfig.$debug" -o -n "${!compcfg}" -o ! -e Makefile ]; then
    rm -f $stampconfig*
    if [ -n "$xprefix" ]; then
        case "$MYTHTARGET" in
            [Ww]indows) mkspecsW32 ;;
            MacOSX*) mkspecsOSX ;;
            *) die "Unknown target: $MYTHTARGET" ;;
        esac
    fi
    if [ -e Makefile ]; then
        make_uninstall || true
        echo "make confclean..."
        $make confclean >/dev/null 2>&1 || true
    fi

    # Common configure options
    # Disable unused examples, demos and tools to speed up build
    # Disable unused sripttools, declarative and multimedia to speed up build
    # BUG Even though script is not used the header is ref'd by webkit
    # Add -no-phonon or need directX9 header dsound.h on Windows
    args="-opensource -confirm-license \
        ${qtXplatform:+-xplatform $qtXplatform} \
        -$debug -fast -nomake tools \
        -nomake examples -nomake demos -nomake docs -nomake translations \
        -no-scripttools -no-declarative -no-multimedia \
        -no-phonon -no-sql-sqlite -no-sql-odbc -plugin-sql-mysql"

    # BUG Adding -I $incdir breaks the native compilation of tools like rcc/moc
    # used to cross build for Windows, which find the Win32 pthread.h before the
    # native one. Therefore can't use our zlib dll
    # TODO test this with native builds only
    #[ -z "$xprefix" ] && args="$args -I $incdir -L $libdir"

    if [ "$MSYSTEM" = "MINGW32" ]; then
        args="$args -I $incdir/mysql -L `pwd -W`/../$MYSQLW/lib/opt -l mysql"
        set -x
        cmd /c "configure.exe $args ${!compcfg}"
        set +x
    else
        # Disable unused XmlPatterns to speed up build
        args="$args -no-javascript-jit -no-xmlpatterns"

        # Mysql libs
        if [ -x "$bindir/mysql_config" ]; then
            args="$args -mysql_config $bindir/mysql_config"
        elif isWinTarget ; then
            args="$args -I $incdir/mysql -L $libdir"
        else
            args="$args -I $incdir/mysql -L $libdir/mysql"
        fi

        case "$MYTHTARGET" in
            [Hh]ost)
                # BUG: The mysql plugin refs mysqlclient in $libdir/mysql, which is added
                # by mysql_config to LFLAGS. However, at runtime ld.so also needs to find
                # it but Qt only sets rpath to $libdir so add an explicit rpath
                args="$args -R $libdir/mysql"
            ;;
            [Ww]indows)
                # Add -no-reduce-exports to prevent "undefined reference to `_inflate..." in zlib.h line 45
                args="$args -no-reduce-exports"

                # Add -no-iconv else build fails on Mandriva with mingw iconv installed
                args="$args -no-iconv"
            ;;
            MacOSX*)
                case "$MYTHTARGET" in
                    MacOSX-i686) args="$args -arch x86 -little-endian" ;;
                    MacOSX-PPC) args="$args -arch powerpc -big-endian" ;;
                esac

                args="$args -no-framework"

                # Dwarf2 symbols cause memory exhaustion in debug build
                args="$args -no-dwarf2"

                # MacOSX qfontengine includes fontconfig.h unless explicitly disabled
                args="$args -no-fontconfig"

                # Pass system root to configure to detect PLATFORM_MAC
                QT_SYSROOT=`$xprefix-cpp -v 2>&1 </dev/null | grep -m 1 /System/Library/Frameworks | cut -d ' ' -f 2`
                export QT_SYSROOT=${QT_SYSROOT%/System/Library/Frameworks}

                case "$QT_SYSROOT" in
                    # Force carbon while using 10.4 SDK
                    *MacOSX10.3*|*MacOSX10.4*) args="$args -carbon" ;;
                    *) ;;
                esac
            ;;
        esac

        set -x
        ./configure -prefix $MYTHINSTALL $args ${!compcfg}
        set +x 
    fi
    pausecont
    touch "$stampconfig.$debug"
    rm -f "$stampbuild"
fi
function helpQt() {
    echo ""
    echo "ERROR: make failed."
    if [ "$MSYSTEM" = "MINGW32" ]; then
        echo "Sometimes this is due to a VM shortage:"
        echo "  make.exe: *** couldn't commit memory for cygwin heap, Win32 error 487"
        echo "If so then ensure that you have at least 1GB of VM and restart this script."
    fi
    exit 1
}
if [ ! -e "$stampbuild" ] ; then
    $make || helpQt
    touch "$stampbuild"
    rm -f "$stampinstall"
fi
if [ "$MSYSTEM" != "MINGW32" -a ! -e "$stampinstall" ]; then
    banner "Installing $QT ($debug)"
    make_install
    touch "$stampinstall"
fi
popd >/dev/null
isdebug QT && export CXXFLAGS=$cxxflags_save

###############################################################################
###############################################################################
# Build MythTV - http://www.mythtv.org/
###############################################################################
###############################################################################
cd "$MYTHDIR"
name="mythtv"
[ ! -d $name ] && gitclone ${MYTHBRANCH:+-b $MYTHBRANCH} "$MYTHGIT/$name.git" $name
pushd "$name" >/dev/null

branch=`gitbranch .`
if [ -n "$MYTHBRANCH" -a "$MYTHBRANCH" != "$branch" ]; then
    banner "Switching to $name branch $MYTHBRANCH" >&2
    ver=`branch2ver "$branch"`

    # Uninstall & distclean plugins
    pushd mythplugins >/dev/null
    [ -e Makefile ] && { make_uninstall; make_distclean; } || true
    rm -f $stampconfig*
    popd >/dev/null

    # Uninstall & distclean mythtv
    pushd mythtv >/dev/null
    [ -e config.mak ] && { make_uninstall; make_distclean; } || true

    # Undo patches
    undopatches "mythtv-$ver" || true
    rm -f $stampconfig*
    popd >/dev/null

    status=$( git status -s -uno)
    if [ -n "$status" ]; then
        echo "WARNING: You requested to switch branches but have uncommited changes." >&2
        echo "WARNING: Proceeding will discard those changes." >&2
        read -p "Press [Return] to continue or [Control-C] to abort: "
        #pause $readtimeout "Press [Return] to continue or [Control-C] to abort: "
    fi

    git clean -f -d -x >/dev/null
    git checkout -f "$MYTHBRANCH"
    branch="$MYTHBRANCH"
elif [ "$clean" = "yes" ]; then
    git clean -f -d -x >/dev/null
    git checkout .
fi

mythtag=$( git describe)
banner "Building $name branch $branch ($MYTHBUILD)"

# Apply patches
case "$MYTHVER" in
    0.[0-9]|0.[1-9]*|[1-9].*|[1-9][0-9].*)
        [ "$patchmaster" != "no" ] &&  { dopatches "$name-$MYTHVER" || rm -f $stampconfig* ; }
        ;;
    master)
        [ "$patchmaster" = "yes" ] && { dopatches "$name-$MYTHVER" || rm -f $stampconfig* ; }
        ;;
    *)
        ;;
esac

# Create the 'precis' handler for tools with long command lines
# This allows warning messages to be more easily seen
precis="$bindir/makelessnoise"
if [ ! -e "$precis" ]; then
    cat > "$precis" <<-EOF && chmod +x "$precis"
		#!/bin/sh
		cmd="\$1"
		tgt="\$2"
		shift 2
		case "\$MYTHVERBOSE" in
		    no|NO|"")
		        fname=\`basename "\$tgt"\`
		        dname=\`dirname "\$tgt"\`
		        if [ -n "\$dname" -a "\$dname" != "." ]; then
		            dname=\`basename "\$dname"\`
		            tgt="\$dname/\$fname"
		        fi
		        len=\${#tgt}
		        maxlen=67
		        if [ \$len -gt \$maxlen ]; then
		            len=\$(( \$len - \$maxlen + 1 ))
		            tgt="...\`expr substr "\$tgt" \$len \$maxlen\`"
		        fi
		        printf "%-8.8s %.70s\\n" "\$cmd" "\$tgt"
		    ;;
		    off|OFF|0) ;;
		    *) echo "\$*" ;;
		esac
		exec "\$@"
	EOF
fi

pushd "$name" >/dev/null
[ "$reconfig" = "yes" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHTV_CFG" \
        -o ! -e "config.h" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e config.mak ] && { make_uninstall; make_distclean; } || true

    # Remove the last traces left after make uninstall
    # mythffmpeg is left in bin
    $dosudo rm -f $bindir/*myth*
    # mythtv/libav... are left in inc
    $dosudo rm -rf $incdir/mythtv/
    # liblibmythav... are left in lib
    $dosudo rm -f $libdir/lib*myth*

    args="--sysinclude=$incdir \
        --extra-cflags=-I$incdir --extra-cxxflags=-I$incdir --extra-libs=-L$libdir \
        --disable-avdevice --disable-avfilter \
        --enable-libfftw3 --disable-joystick-menu"
    case "$MYTHVER" in
        0.23*) args="$args --disable-directfb" ;;
        0.24*) args="$args --disable-directfb --enable-vaapi" ;;
        ""|0.25*|0.26*|0.27*|master) args="$args --enable-vaapi" ;;
    esac
    rprefix=".."
    case "$MYTHTARGET" in
        [Hh]ost)
            targetos=""
            # Enable x264 for mythffmpeg transcoding
            args="$args --enable-libx264 --enable-libmp3lame"
        ;;
        [Ww]indows)
            targetos="mingw32"
            rprefix="."

            # Disable hdhomerun & lirc since they use get/freeaddrinfo which is XPSP2+ only
            # BUG Should use HAVE_GETADDRINFO
            args="$args --disable-lirc --disable-hdhomerun"

            # DXVA2
            [ "$DXVA2" = "no" ] || args="$args --enable-dxva2"

            # Disable symbol-visibility or build problems on 0.24 & 0.23
            # Also disabled on master to quieten warnings which otherwise hide real probs
            args="$args --disable-symbol-visibility"
        ;;
        MacOSX*)
            targetos="darwin"

            # BUG the ppc x-compiler defines __vector but the SDK expects vector
            # in CarbonCore/MachineExceptions.h so disable altivec
            [ "$MYTHTARGET" == "MacOSX-PPC" ] && : ${cpu:=g3}
        ;;
        *) die "Unknown target: $MYTHTARGET" ;;
    esac

    set -x
    ./configure "--prefix=$MYTHINSTALL" "--runprefix=$rprefix" \
        "--qmake=$MYTHWORK/$QT/bin/qmake" \
        ${xprefix:+--enable-cross-compile} \
        ${xprefix:+--cross-prefix=$xprefix-} \
        ${targetos:+--target_os=$targetos} \
        ${arch:+--arch=$arch} ${cpu:+--cpu=$cpu} \
        $args --compile-type=$MYTHBUILD $MYTHTV_CFG
    set +x

    case "$MYTHTARGET" in
        [Hh]ost)
            # So LD_LIBRARY_PATH can override rpath, set RUNPATH
            cat >> config.mak <<< QMAKE_LFLAGS+="-Wl,--enable-new-dtags"
        ;;
    esac

    # This quietens the build noise but is irreversible
    #cat >> config.mak <<< CCONFIG+=silent

    # Install the 'precis' handler
    cat >> config.mak <<-EOF
		 QMAKE_CC=@$precis CC \$(abspath \$<) \$\$QMAKE_CC
		 QMAKE_CXX=@$precis CXX \$(abspath \$<) \$\$QMAKE_CXX
		 QMAKE_LINK=@$precis LINK \$@ \$\$QMAKE_LINK
		 QMAKE_AR=@$precis AR \$@ \$\$QMAKE_AR
		 QMAKE_MOC=@$precis MOC \$(abspath \$<) \$\$QMAKE_MOC
	EOF

    pausecont
    touch "$stampconfig${MYTHBUILD:+.$MYTHBUILD}"
fi

function helpmyth() {
    echo ""
    echo "ERROR: make failed."
    if [ "$MSYSTEM" == "MINGW32" ]; then
        echo "Sometimes this is due to an internal compiler fault in:"
        echo "  external/ffmpeg/libavacodec/imgconvert.c"
        echo "If so then it can help to restart the system and run this script again."
    fi
    exit 1
}

[ "$verbose" = "no" ] && make="$make -s"
: ${MYTHVERBOSE:=$verbose}
$make || helpmyth

banner "Installing $name ($MYTHBUILD)"
make_install
popd >/dev/null

###############################################################################
# Build MythPlugins - http://www.mythtv.org/
name="mythplugins"
pushd "$name" >/dev/null
banner "Building $name branch $branch ($MYTHBUILD)"

[ "$reconfig" = "yes" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHPLUGINS_CFG" \
        -o ! -e "config.pro" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e Makefile ] && { make_uninstall; make_distclean; } || true

    plugins="--enable-all --enable-fftw"
    case "$MYTHVER" in
        0.23*|0.24*) plugins="$plugins --enable-libvisual" ;;
        ""|0.25*|0.26*|0.27*|master) ;;
    esac

    if ! isdebug QT ; then
        # These plugins require a debug build of Qt in .pro file
        [ "$MYTHNEWS" = "yes" ] || plugins="$plugins --disable-mythnews"
        [ "$MYTHNETVISION" = "yes" ] || plugins="$plugins --disable-mythnetvision"
        case "$MYTHVER" in
            ""|0.23*|0.24*) [ "$MYTHWEATHER" = "yes" ] || plugins="$plugins --disable-mythweather" ;;
            0.25*|0.26*|0.27*|master) ;;
        esac
    fi

    args="--prefix=$MYTHINSTALL --qmake=$MYTHWORK/$QT/bin/qmake --compile-type=$MYTHBUILD"
    [ -n "$xprefix" ] && args="$args --cross-prefix=${xprefix}- --sysroot=$MYTHINSTALL"
    case "$MYTHTARGET" in
    [Ww]indows)
        [ -n "$xprefix" ] && args="$args --targetos=MINGW32"
        plugins="$plugins --disable-dcraw"
        # NB patches reqd for Windows for mytharchive & mythzoneminder
        [ "$MYTHZONEMINDER" = "yes" ] || plugins="$plugins --disable-mythzoneminder"
        [ "$MYTHARCHIVE" = "yes" ] || plugins="$plugins --disable-mytharchive"
        ;;
    MacOSX*)
        [ -n "$xprefix" ] && args="$args --targetos=Darwin"
        plugins="$plugins --disable-dcraw"
        ;;
    *)
        ;;
    esac

    set -x; ./configure $args $plugins $MYTHPLUGINS_CFG ; set +x
    pausecont
    touch "$stampconfig${MYTHBUILD:+.$MYTHBUILD}"
fi
$make
banner "Installing $name ($MYTHBUILD)"
make_install
popd >/dev/null ; # mythtv/mythplugins

popd >/dev/null ; # mythtv

###############################################################################
# Build MythThemes
if [ "$themes" = "yes" ]; then
    name="myththemes"
    [ ! -d $name ] && gitclone ${MYTHBRANCH:+-b $MYTHBRANCH} "$MYTHGIT/$name.git" $name
    pushd "$name" >/dev/null

    branch=`gitbranch .`
    if [ -n "$MYTHBRANCH" -a "$MYTHBRANCH" != "$branch" ]; then
        banner "Switching to $name branch $MYTHBRANCH"
        git clean -f -d -x >/dev/null
        git checkout -f "$MYTHBRANCH"
        branch="$MYTHBRANCH"
    elif [ "$clean" = "yes" ]; then
        git clean -f -d -x >/dev/null
        git checkout .
    fi

    banner "Building $name branch $branch"
    [ "$reconfig" = "yes" ] && rm -f "mythconfig.mak"
    if [ ! -e "mythconfig.mak" ]; then
        [ -e Makefile ] && { make_uninstall; make_distclean; } || true
        ./configure "--prefix=$MYTHINSTALL" --qmake="$MYTHWORK/$QT/bin/qmake" $MYTHTHEMES_CFG
        rm -f "$stampbuild"
    fi

    if [ ! -e "$stampbuild" ] ; then
        $make
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi

    if [ ! -e "$stampinstall" ]; then
        banner "Installing $name"
        make_install
        touch "$stampinstall"
    fi

    popd >/dev/null
fi
###############################################################################
# Build MythInstaller
if isWinTarget ; then
    name=$WININSTALLER; url=$WININSTALLER_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url" || true
    [ ! -d "$name" -a -e "$arc" ] && unpack "$arc"
    if [ -d "$name" ]; then
        banner "Building $name"
        pushd "$name" >/dev/null
        [ ! -e setup.exe ] && $make ${xprefix:+PREFIX=$xprefix-}
        popd >/dev/null
    fi
fi


###############################################################################
# Create the installation
###############################################################################
mythlibs="myth mythfreemheg mythtv mythui mythupnp mythlivemedia"
if [ -z "$MYTHVER" ]; then
    case "$branch" in
        *-master) MYTHVER="master" ;;
        *-0*24)   MYTHVER="0.24" ;;
        *-0*25)   MYTHVER="0.25" ;;
        *-0*26)   MYTHVER="0.26" ;;
        *-0*27)   MYTHVER="0.27" ;;
    esac
fi
case "$MYTHVER" in
    0.23*)        mythlibs="$mythlibs mythdb" ;;
    0.24*)        mythlibs="$mythlibs mythdb mythmetadata" ;;
    0.25*|0.26*|0.27*|master) mythlibs="$mythlibs mythbase mythmetadata mythservicecontracts mythprotoserver" ;;
    *)            mythlibs="$mythlibs mythbase mythmetadata mythservicecontracts mythprotoserver"
                  echo "WARNING Installation untested with this version." ;;
esac
ffmpeglibs="mythavcodec mythavformat mythavutil mythswscale"
case "$MYTHVER" in
    0.24*|0.23*)     ffmpeglibs="$ffmpeglibs mythavcore mythpostproc" ;;
    0.25*|0.26*|0.27*|master|"") ffmpeglibs="$ffmpeglibs mythpostproc" ;;
esac
xtralibs="xml2 xslt freetype mp3lame dvdcss exif ogg vorbis vorbisenc tag cdio cdio_cdda cdio_paranoia udf visual-0.4"
QTDLLS="QtCore QtGui QtNetwork QtOpenGL QtSql QtSvg QtWebKit QtXml Qt3Support"
case "$MYTHVER" in
    ""|0.25*|0.26*|0.27*|master) QTDLLS="$QTDLLS QtScript" ;;
esac

if isWinTarget ; then
    banner "Building MythTV $MYTHTARGET runtime in $windir"
    rm -rf "$windir"
    mkdir -p "$windir"
    pushd "$windir" >/dev/null

    # Myth binaries
    ln -s $bindir/myth*.exe .
    [ -r "$bindir/mtd.exe" ] && ln -s $bindir/mtd.exe .
    for lib in $mythlibs ; do
        ln -s $bindir/lib$lib-*.dll .
    done

    # Mingw runtime
    if [ "$MSYSTEM" == "MINGW32" ]; then
        mingw="/mingw//bin"
        ln -s $mingw/libstdc++-*.dll $mingw/libgcc_s_dw2-*.dll .
    elif [ -e "/usr/share/doc/mingw32-runtime/mingwm10.dll.gz" ]; then
        cp -p "/usr/share/doc/mingw32-runtime/mingwm10.dll.gz" .
        gunzip "mingwm10.dll.gz"
    elif [ -d "/usr/$xprefix/sys-root/mingw/bin/" ]; then
        ln -s /usr/$xprefix/sys-root/mingw/bin/mingwm??.dll .
        ln -s /usr/$xprefix/sys-root/mingw/bin/libstdc++-?.dll .
        ln -s /usr/$xprefix/sys-root/mingw/bin/libgcc_s_sjlj-?.dll .
    elif dll=`locate "/usr/*mingw*.dll"` ; then
        ln -s `echo "$dll" | tr "\n" " "` .
    else
        echo "WARNING: Mingw32 runtime dll's not found."
        read -p "Press [Return] to continue: "
    fi

    # FFmpeg
    for lib in $ffmpeglibs ; do
        for file in $bindir/lib$lib-*.dll ; do
            [ -e "$file" ] && ln -s "$file" .
        done
    done

    # External libs
    for lib in $xtralibs ; do
        for file in $bindir/lib$lib-*.dll ; do
            [ -e "$file" ] && ln -s "$file" .
        done
    done

    # Windows only libs
    ln -s $bindir/SDL.dll .
    ln -s $bindir/pthreadGC2.dll .
    ln -s $bindir/zlib1.dll .
    [ -r libdvdcss-2.dll ] && ln -s libdvdcss-2.dll libdvdcss.dll

    # QT
    isdebug QT && v="d4" || v="4"
    if [ "$MSYSTEM" == "MINGW32" ]; then
        for dll in $QTDLLS ; do
            ln -s $MYTHWORK/$QT/bin/$dll$v.dll .
        done
        ln -s $MYTHWORK/$QT/plugins/* .
    else
        for dll in $QTDLLS ; do
            ln -s $bindir/$dll$v.dll .
        done
        ln -s $MYTHINSTALL/plugins/* .
    fi

    # MySQL for QT plugin
    ln -s $MYTHWORK/$MYSQLW/$MYSQLW_LIB/libmysql.dll .

    # Myth plugins
    mkdir -p lib
    ln -s $libdir/mythtv/ lib/
    mkdir -p share
    ln -s $MYTHINSTALL/share/mythtv/ share/

    if [ -d "$MYTHDIR/mythinstaller-win32" ]; then
        # Installer
        cp "$MYTHDIR/mythinstaller-win32/mythtv.inf" .
        listfiles >> mythtv.inf
        ln -s "$MYTHDIR/mythinstaller-win32/setup.exe" .
    fi

    popd >/dev/null

    # Create archive
    archive="mythtv-$mythtag-w32"
    [ "$MYTHBUILD" != "release" ] && archive="$archive-$MYTHBUILD"
    archive="$MYTHDIR/$archive.zip"
    banner "Building MythTV archive `basename "$archive" .zip`"
    pushd "$windir" >/dev/null

    [ -e "$archive" ] && mv -f "$archive" "${archive%.zip}-bak.zip"
    zip -9 -r -q "$archive" *

    if [ -e "setup.exe" ]; then
        # Set autorun comment:
        zip -z "$archive" >/dev/null <<<\$AUTORUN\$\>setup.exe
        # Make self extracting archive
        for sfx in "$MYTHWORK/$UNZIP/SFXWiz32.exe" "$MYTHWORK/$UNZIP/unzipsfx.exe" ; do
            if [ -r "$sfx" ]; then
                [ -e "${archive%.zip}.exe" ] && mv -f "${archive%.zip}.exe" "${archive%.zip}-bak.exe"
                cat "$sfx" "$archive" > "${archive%.zip}.exe"
                rm -f "$archive"
            fi
        done
    fi

    popd >/dev/null
else
    # Build list of files for host installation archive
    pushd "$MYTHINSTALL" >/dev/null
    files=

    # Myth binaries
    for bin in bin/myth* ; do
        [ -x "$bin" ] && files="$files $bin"
    done
    [ -x "bin/mtd" ] && files="$files bin/mtd"

    case "$MYTHTARGET" in
        Host)
            libext=".so.@(?|??)" ;;
        MacOSX*)
            libext=".@(?|??).dylib" ;;
    esac

    shopt -s extglob
    for lib in $mythlibs mythhdhomerun ; do
        [ -e lib/lib$lib-????$libext ] && files="$files lib/lib$lib-????$libext"
    done

    for lib in $ffmpeglibs ; do
        [ -e lib/lib$lib$libext ] && files="$files lib/lib$lib$libext"
    done

    # External libs
    for lib in $xtralibs ; do
        [ -e lib/lib$lib$libext ] && files="$files lib/lib$lib$libext"
    done

    # Special libs
    files="$files lib/libSDL-?.?$libext"
    files="$files lib/libudf$libext"

    # QT.  NB QtDBus may be missing if libdbus-1-dev is not installed
    for lib in $QTDLLS QtDBus ; do
        [ -e lib/lib$lib$libext ] && files="$files lib/lib$lib$libext"
    done
    files="$files plugins"

    # MySQL for QT plugin
    case "$MYTHTARGET" in
        MacOSX-PPC) ;; # Static libs
       *) files="$files lib/mysql/libmysqlclient_r$libext" ;;
    esac

    # Myth plugins
    files="$files lib/mythtv share/mythtv"
    [ -d "lib/perl" ] && files="$files lib/perl"
    [ -d "share/perl" ] && files="$files share/perl"
    [ -d "lib/python2.6" ] && files="$files lib/python2.6"

    # Create host installation archive
    archive="mythtv${mythtag:+-$mythtag}"
    case "$MYTHTARGET" in
        MacOSX*)
            sdk=`$xprefix-cpp -v 2>&1 </dev/null | grep -m 1 /System/Library/Frameworks | cut -d ' ' -f 2`
            sdk=${sdk%.sdk*}
            sdk=${sdk##*SDKs/}
            archive="$archive-$sdk-${MYTHTARGET#MacOSX-}"
        ;;
        [Hh]ost) archive="$archive-$arch" ;;
        *) archive="$archive-$MYTHTARGET" ;;
    esac
    [ -n "$cpu" ] && archive="$archive-$cpu"
    [ "$MYTHBUILD" != "release" ] && archive="$archive-$MYTHBUILD"
    archive="$MYTHDIR/$archive.tar.bz2"
    banner "Building MythTV archive `basename "$archive"`"
    [ -e "$archive" ] && mv -f "$archive" "${archive%.tar.bz2}-bak.tar.bz2"
    tar -v --owner nobody --group nogroup -hjcf "$archive" $files
    popd >/dev/null
fi

banner "Finished"

echo "To run a myth program, such as mythfrontend, execute:"
if [ "$MSYSTEM" = "MINGW32" ]; then
    cat <<-EOF
	${windir#$currdir/}/mythfrontend

	Persisent settings are stored in c:\Documents and Settings\[user]\.mythtv
	To use a different location prepend MYTHCONFDIR=<path>
	EOF
elif isWinTarget ; then
    cat <<-EOF
	wine ${windir#$currdir/}/mythfrontend -p

	Click 'Set configuration manually'
	On the page 'Database Configuration 2/2' set 'Use a custom identifier...'
	Enter a name, e.g. wine, otherwise the host's settings will be used.

	Persisent settings are stored in c:/users/[name]/.mythtv
	To use a different location prepend MYTHCONFDIR=z:<path>
	EOF
else
    cat <<-EOF
	${bindir#$currdir/}/mythfrontend

	If the installtion is moved from $MYTHINSTALL then prepend:
	LD_LIBRARY_PATH="<path>/lib:<path>/lib/mysql" QT_PLUGIN_PATH="<path>/plugins"

	Persisent settings are stored in ~/.mythtv
	To use a different location prepend MYTHCONFDIR=path
	EOF
fi

:<<"COMMENT"
cat <<-EOF

To simplify setting up and running MythTV on Linux or Windows, try this script:
wget http://www.softsystem.co.uk/download/mythtv/mythrun && chmod +x mythrun
Run mythfrontend: ./mythrun fe [args]
Run mythbackend: ./mythrun be [args]
Run mythtv-setup: ./mythrun su [args]
EOF
COMMENT
