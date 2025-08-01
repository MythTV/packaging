#!/bin/bash
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
scriptargs=("$@")
set -e

if [[ -f $HOME/.buildrc ]] ; then
    . $HOME/.buildrc
fi

strip=
while (( "$#" >= 1 )) ; do
    case $1 in
        --nostrip)
            strip="_nostrip"
            ;;
        --strip)
            strip=
            ;;
        *)
            echo "Error invalid option $1"
            echo valid options: --strip --nostrip
            exit 2
            ;;
    esac
    shift||rc=$?
done

gitbasedir=`git rev-parse --show-toplevel`

# This will get projname and destdir
. "$scriptpath/getdestdir.source"

gitpath="$PWD"

sourcedir=$destdir

if [[ "$sourcedir" == "" ]] ; then
    echo Before running this the latest version must be built
    echo with --prefix=/usr --runprefix=/usr and installed
    echo Parameter 1 = SUBRELEASE number
    echo Run this from the git source directory
    exit 2
fi
sourcedir=`readlink -f "$sourcedir"`
if [[ "$SUBRELEASE" == "" ]] ; then SUBRELEASE=0 ; fi
gitver=`git -C "$gitpath" describe --dirty|cut -c2-`
# gitbranch=`git branch|grep "^\* "|cut -b3-`
gitbranch=`git branch | grep '*'| cut -f2 -d' '`
if [[ "$gitbranch" == '(HEAD' ]] ; then
    gitbranch=`git branch | grep '*'| cut -f3 -d' '`
fi
# support for bisect:
if [[ "$branch" == '(no' ]] ; then
    branch=detached
fi
# example of packagever 30-Pre-545-g51d6fdf
packagever=`env LD_LIBRARY_PATH=$sourcedir/usr/lib $sourcedir/usr/bin/mythutil --version |grep "MythTV Version"|cut -d ' ' -f 4|cut -c2-`
packagebranch=`env LD_LIBRARY_PATH=$sourcedir/usr/lib $sourcedir/usr/bin/mythutil --version |grep "MythTV Branch"|cut -d ' ' -f 4`
echo Package branch: $packagebranch, git branch: $gitbranch
if [[ "$packagever" != "$gitver" && "$packagever" != "$gitver"-dirty ]] ; then
    echo ERROR Package version $packagever does not match git version $gitver
    exit 2
fi
# Change dash to tilde in some cases
# Note that according to debian (with any numbers or letters)
# 30-Pre > 30
# 30~Pre < 30
# 30-Pre < 30.0
packagever=`echo $packagever|sed  's/-pre/~pre/'`
# Skip this check for 30 because there are already
# some builds out there with 30-Pre.
# If the release version is 30.0 it will be OK.
if [[ "$packagever" != 30-Pre* ]] ; then
    packagever=`echo $packagever|sed  's/-Pre/~Pre/'`
fi
packagever=`echo $packagever|sed  's/-rc/~rc/'`
packagerel=$packagever-$SUBRELEASE
gitbasedir=`git -C "$gitpath" rev-parse --show-toplevel`
installdir=`dirname "$gitbasedir"`
arch=`dpkg-architecture -q DEB_TARGET_ARCH`
codename=`lsb_release -c|cut -f 2`
source=
# This expects that remote tracking branches for official
# repositories start with "mythtv"
if [[ "$packagebranch" != master && "$packagebranch" != fixes* ]] ; then
    source="test_"
fi
case $projname in
    mythtv)
        packagename=mythtv-light_${source}${packagerel}_${arch}_$codename$strip
        echo Package $packagename
        if [[ -f $installdir/$packagename.deb || -d $installdir/$packagename ]] ; then
            echo $installdir/$packagename already exists - incrementing SUBRELEASE number
            let SUBRELEASE=SUBRELEASE+1
            export SUBRELEASE
            exec "$scriptname" "${scriptargs[@]}"
        fi
        rm -rf $installdir/$packagename $installdir/$packagename.deb
        cp -a "$sourcedir/" "$installdir/$packagename/"

        # Remove files not needed for package
        rm -rf "$installdir/$packagename/usr/lib/cmake/"
        rm -rf "$installdir/$packagename/usr/lib/pkgconfig/"
        rm -rf "$installdir/$packagename/usr/lib/libmythexiv2-xmp.a"
        rm -rf "$installdir/$packagename/usr/lib/"*/perl/*/auto/MythTV/.packlist
        for (( x=0; x<6; x++ )) ; do
            # run this 6 times to remove empty nested directories up to 6 levels
            find $installdir/$packagename/usr/lib  -type d -empty -delete
        done

        mkdir -p $installdir/$packagename/DEBIAN
        if [[ "$strip" != "_nostrip" ]] ; then
            strip -g `find $installdir/$packagename/usr/bin/ -type f -executable`
            strip -g `find $installdir/$packagename/usr/lib/ -type f -executable -name '*.so*'`
        fi

        cat >$installdir/$packagename/DEBIAN/control <<FINISH
Package: mythtv-light
Version: $packagerel
Section: graphics
Priority: optional
Architecture: $arch
Essential: no
Installed-Size: `du -B1024 -d0 $installdir/$packagename | cut  -f1`
Maintainer: Peter Bennett <pbennett@mythtv.org>
Depends: libtag1v5 | libtag2, libavahi-compat-libdnssd1, libqt5widgets5, libqt5script5, libqt5sql5-mysql, libqt5xml5, libqt5network5, pciutils, libva-x11-1 | libva-x11-2, libva-glx1 | libva-glx2, libqt5opengl5, libdbi-perl,  libdbd-mysql-perl, libnet-upnp-perl, libcec3 | libcec4 | libcec6 | libcec7, libfftw3-double3, libfftw3-single3, libass5 | libass9, libfftw3-3 | libfftw3-bin, libraw1394-11, libiec61883-0, libavc1394-0, fonts-liberation, libva-drm1 | libva-drm2, libmp3lame0, libxv1, libpulse0, libhdhomerun3 | libhdhomerun4 | libhdhomerun5, libxnvctrl0, libsamplerate0, libbluray1 | libbluray2, liblzo2-2, libio-socket-inet6-perl, libxml-simple-perl, python3-lxml, python3-mysqldb, python3-requests, python3-requests-cache, libxinerama1, libzip4 | libzip5, libsoundtouch1
Conflicts: mythtv-common, mythtv-frontend, mythtv-backend
Homepage: http://www.mythtv.org
Description: MythTV Light
 Lightweight package that installs MythTV in one package, front end
 and backend. Does not install database or services.
FINISH
        if [[ "$arch" != armhf ]] ; then
            mkdir -p $installdir/$packagename/usr/share/applications/
            cat >$installdir/$packagename/usr/share/applications/mythtv.desktop \
            <<FINISH
[Desktop Entry]
Name=MythTV Frontend
Comment=A frontend for all content on a mythtv-backend
GenericName=MythTV Viewer
Exec=/usr/bin/mythfrontend --logpath /tmp
Type=Application
Encoding=UTF-8
Icon=/usr/share/pixmaps/mythtv.png
Categories=GNOME;Application;AudioVideo;Audio;Video
FINISH
            cat >$installdir/$packagename/usr/share/applications/mythtv-setup.desktop \
            <<FINISH
[Desktop Entry]
Name=MythTV Web App Backend Setup
Comment=Used to configure a backend
GenericName=MythTV Web App Backend Setup
URL=http://localhost:6544/setupwizard
Type=Link
Icon=/usr/share/pixmaps/mythtv.png
Categories=GTK;System;Settings;
X-AppInstall-Package=mythtv
FINISH
            mkdir -p $installdir/$packagename/usr/share/pixmaps/
            cp -f $scriptpath/mythtv.png $installdir/$packagename/usr/share/pixmaps/

            mkdir -p $installdir/$packagename/usr/share/menu/
            cat >$installdir/$packagename/usr/share/menu/mythtv-frontend \
            <<FINISH
?package(mythtv-frontend):needs="X11" section="Applications/Graphics" \
  title="MythTV" command="/usr/bin/mythfrontend"
FINISH
        fi
        cd $installdir
        chmod -R  g-w,o-w $packagename
        fakeroot dpkg-deb --build $packagename
        # Do not rm $packagename because it is needed for plugins build
        echo $PWD
        ls -ld ${packagename}*
        ;;
    mythplugins)
        mythtvpackagename=mythtv-light_${source}${packagerel}_${arch}_$codename$strip
        packagename=mythplugins-light_${source}${packagerel}_${arch}_$codename$strip
        echo Package $packagename
        if [[ -f $installdir/$packagename.deb ]] ; then
            echo $installdir/$packagename already exists - incrementing SUBRELEASE number
            let SUBRELEASE=SUBRELEASE+1
            export SUBRELEASE
            exec "$scriptname" "${scriptargs[@]}"
        fi
        if [[ ! -d $installdir/$mythtvpackagename ]] ; then
            echo $installdir/$mythtvpackagename does not exist.
            echo Build mythtv package first
            exit 2
        fi
        rm -rf $installdir/$packagename $installdir/$packagename.deb
        cp -a "$sourcedir/" "$installdir/$packagename/"

        # Remove files not needed for package
        rm -rf "$installdir/$packagename/usr/lib/cmake/"
        rm -rf "$installdir/$packagename/usr/lib/pkgconfig/"
        rm -rf "$installdir/$packagename/usr/lib/libmythexiv2-xmp.a"
        rm -rf "$installdir/$packagename/usr/lib/"*/perl/*/auto/MythTV/.packlist
        for (( x=0; x<6; x++ )) ; do
            # run this 6 times to remove empty nested directories up to 6 levels
            find $installdir/$packagename/usr/lib  -type d -empty -delete
        done

        # Remove mythtv files so that only plugin files remain
        cd $installdir/$packagename
        (cd $installdir/$mythtvpackagename ; find . \( -type f -o -type l \) -print0) | xargs -0 rm -f
        rc=0
        while [[ "$rc" == 0 ]] ; do
            find . -type d -empty -print0 | xargs -0 rmdir -v || rc=$?
        done
        mkdir -p $installdir/$packagename/DEBIAN
        if [[ "$strip" != "_nostrip" ]] ; then
            strip -g -v `find $installdir/$packagename/usr/bin/ -type f -executable`
            strip -g -v `find $installdir/$packagename/usr/lib/ -type f -executable`
        fi
        cat >$installdir/$packagename/DEBIAN/control <<FINISH
Package: mythplugins-light
Version: $packagerel
Section: graphics
Priority: optional
Architecture: $arch
Essential: no
Installed-Size: `du -B1024 -d0 $installdir/$packagename | cut  -f1`
Maintainer: Peter Bennett <pbennett@mythtv.org>
Depends: mythtv-light, perl, libimage-size-perl, perlmagick, libxml-parser-perl, libxml-sax-perl, libcarp-clan-perl, libsoap-lite-perl, libdate-manip-perl, libdate-calc-perl, libwww-perl, libxml-simple-perl, libdatetime-format-iso8601-perl, libjson-perl, libxml-xpath-perl, mjpegtools, dvdauthor, genisoimage, dvd+rw-tools,  python3-pil, python3-mysqldb, pmount, python3-feedparser, python3-pycurl
Conflicts: mythtv-common, mythtv-frontend, mythtv-backend
Homepage: http://www.mythtv.org
Description: MythTV Plugins Light
 MythTV plugins for the MythTV Light package. MythTV Light must be installed
 before this package. The following plugins are included:
  MythArchive 
  MythBrowser
  MythGallery
  MythGame
  MythMusic
  MythNetvision
  MythNews
  MythWeather
  MythZoneMinder
FINISH
        cd $installdir
        chmod -R  g-w,o-w $packagename
        fakeroot dpkg-deb --build $packagename

        echo $PWD
        ls -ld ${packagename}*
        ;;
esac
