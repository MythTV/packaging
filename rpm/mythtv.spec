#
# Specfile for building MythTV and MythPlugins RPMs from a subversion checkout.
#
# by:   Chris Petersen <rpm@forevermore.net>
#       Jarod Wilson <jarod@wilsonet.com>
#
#  Modified/Extended from the great (non-svn based) work of:
#     Axel Thimm <Axel.Thimm@ATrpms.net>
#     David Bussenschutt <buzz@oska.com>
#     and others; see changelog at bottom for details.
#
# The latest version of this file can be found at:
#
#     http://www.mythtv.org/wiki/index.php/Mythtv-svn-rpmbuild.spec
#
# Note:
#
#     This spec relies upon several files included in the RPMFusion mythtv
#     src.rpm file.  Please install it into your build tree before trying to
#     build anything with this spec.
#
# Explanation of options:
#
# --with proc_opt           Enable MythTV's optimized processor detection code
#                               and override RPM's defaults.
# --with debug              Enable debug mode
#
# The following options are disabled by default.  Use these options to enable:
#
# --with directfb           Enable directfb support
#
# The following options are enabled by default.  Use these options to disable:
#
# --without xvmcnvidia      Disable NVidia XvMC support
# --without perl            Disable building of the perl bindings
# --without python          Disable building of the python bindings
#
# # All plugins get built by default, but you can disable them as you wish:
#
# --without mytharchive
# --without mythbrowser
# --without mythcontrols
# --without mythflix
# --without mythgallery
# --without mythgame
# --without mythmovies
# --without mythmusic
# --without mythnews
# --without mythphone
# --without mythvideo
# --without mythweather
# --without mythzoneminder
# --without mythweb
#
# The following options are disabled by default.  Use these options to enable:
#
# --with festival           Enable festival/festvox support in MythPhone
#

################################################################################

# A list of which applications we want to put into the desktop menu system
%define desktop_applications mythfrontend mythtv-setup

# The vendor name we should attribute the aforementioned entries to
%define desktop_vendor  xris

# SVN Revision number and branch ID
%define _svnrev r19390
%define branch trunk

#
# Basic descriptive tags for this package:
#
Name:           mythtv
Summary:        A digital video recorder (DVR) application.
URL:            http://www.mythtv.org/
Group:          Applications/Multimedia

# Version/Release info
Version: 0.22
%if "%{branch}" == "trunk"
Release: 0.1.svn.%{_svnrev}%{?dist}
%else
Release: 1%{?dist}
%endif

# The primary license is GPLv2+, but bits are borrowed from a number of
# projects... For a breakdown of the licensing, see PACKAGE-LICENSING.
License: GPLv2+ and LGPLv2+ and LGPLv2 and (GPLv2 or QPL) and (GPLv2+ or LGPLv2+)

################################################################################

# Set "--with proc_opt" to let mythtv autodetect your CPU and run its
# processor-specific optimizations.  It seems to cause compile problems on many
# systems (particularly x86_64), so it is classified by the MythTV developers
# as "use at your own risk."
%define with_proc_opt      %{?_with_proc_opt:       1} %{!?_with_proc_opt:      0}

# Set "--with debug" to enable MythTV debug compile mode
%define with_debug         %{?_with_debug:          1} %{?!_with_debug:         0}

# The following options are enabled by default.  Use --without to disable them
%define with_perl          %{?_without_perl:        0} %{!?_without_perl:       1}
%define with_python        %{?_without_python:      0} %{!?_without_python:     1}

# The following options are disabled by default.  Use --with to enable them
%define with_directfb      %{?_with_directfb:       1} %{!?_with_directfb:      0}
%define with_xvmcnvidia    %{?_with_xvmcnvidia:     1} %{?!_with_xvmcnvidia:    0}

# All plugins get built by default, but you can disable them as you wish
%define with_plugins        %{?_without_plugins:        0} %{!?_without_plugins:         1}
%define with_mytharchive    %{?_without_mytharchive:    0} %{!?_without_mytharchive:     1}
%define with_mythbrowser    %{?_without_mythbrowser:    0} %{!?_without_mythbrowser:     1}
%define with_mythcontrols   %{?_without_mythcontrols:   0} %{!?_without_mythcontrols:    1}
%define with_mythflix       %{?_without_mythflix:       0} %{!?_without_mythflix:        1}
%define with_mythgallery    %{?_without_mythgallery:    0} %{!?_without_mythgallery:     1}
%define with_mythgame       %{?_without_mythgame:       0} %{!?_without_mythgame:        1}
%define with_mythmovies     %{?_without_mythmovies:     0} %{!?_without_mythmovies:      1}
%define with_mythmusic      %{?_without_mythmusic:      0} %{!?_without_mythmusic:       1}
%define with_mythnews       %{?_without_mythnews:       0} %{!?_without_mythnews:        1}
%define with_mythphone      %{?_without_mythphone:      0} %{!?_without_mythphone:       1}
%define with_mythvideo      %{?_without_mythvideo:      0} %{!?_without_mythvideo:       1}
%define with_mythweather    %{?_without_mythweather:    0} %{!?_without_mythweather:     1}
%define with_mythweb        %{?_without_mythweb:        0} %{!?_without_mythweb:         1}
%define with_mythzoneminder %{?_without_mythzoneminder: 0} %{!?_without_mythzoneminder:  1}

# The following plugin options are disabled by default.  Use --with to enable them

# MythPhone
%define with_festival       %{?_with_festival:      1} %{!?_with_festival:      0}

################################################################################

Source0:   http://www.mythtv.org/mc/mythtv-%{version}.tar.bz2
Source1:   http://www.mythtv.org/mc/mythplugins-%{version}.tar.bz2
Source10:  PACKAGE-LICENSING
Source101: mythbackend.sysconfig.in
Source102: mythbackend.init.in
Source103: mythbackend.logrotate.in
Source106: mythfrontend.png
Source107: mythfrontend.desktop
Source108: mythtv-setup.png
Source109: mythtv-setup.desktop
Source110: mysql.txt
Source401: mythweb.conf

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

################################################################################
# Python setup

%if %{with_python}
%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%{!?python_version: %define python_version %(%{__python} -c 'import sys; print sys.version.split(" ")[0]')}
%endif

################################################################################

# Global MythTV and Shared Build Requirements

BuildRequires:  desktop-file-utils
BuildRequires:  freetype-devel >= 2
BuildRequires:  gcc-c++
BuildRequires:  mysql-devel >= 5
BuildRequires:  qt4-devel

BuildRequires:  lm_sensors-devel
BuildRequires:  lirc-devel
BuildRequires:  nasm, yasm-devel

# X, and Xv video support
BuildRequires:  libXmu-devel
BuildRequires:  libXv-devel
BuildRequires:  libXvMC-devel
BuildRequires:  libXxf86vm-devel
BuildRequires:  mesa-libGLU-devel
BuildRequires:  xorg-x11-proto-devel
%ifarch %{ix86} x86_64
BuildRequires:  xorg-x11-drv-i810-devel
BuildRequires:  xorg-x11-drv-openchrome-devel
%endif

# OpenGL video output and vsync support
BuildRequires:  libGL-devel, libGLU-devel

# Misc A/V format support
BuildRequires:  a52dec-devel
BuildRequires:  faac-devel
BuildRequires:  faad2-devel
BuildRequires:  fftw2-devel < 3
BuildRequires:  fftw2-devel >= 2.1.3
BuildRequires:  flac-devel >= 1.0.4
BuildRequires:  gsm-devel
BuildRequires:  lame-devel
BuildRequires:  libdca-devel
# libdvdcss will be dynamically loaded if installed
#BuildRequires:  libdvdcss-devel >= 1.2.7
BuildRequires:  libdvdnav-devel
BuildRequires:  libdvdread-devel >= 0.9.4
BuildRequires:  libfame-devel >= 0.9.0
BuildRequires:  libmad-devel
BuildRequires:  libogg-devel
BuildRequires:  libtheora-devel
BuildRequires:  libvorbis-devel >= 1.0
BuildRequires:  mjpegtools-devel >= 1.6.1
BuildRequires:  taglib-devel >= 1.4
BuildRequires:  transcode >= 0.6.8
BuildRequires:  x264-devel
BuildRequires:  xvidcore-devel >= 0.9.1

# Audio framework support
BuildRequires:  alsa-lib-devel
BuildRequires:  arts-devel
BuildRequires:  jack-audio-connection-kit-devel

# Need dvb headers to build in dvb support
BuildRequires: kernel-headers

# FireWire cable box support
BuildRequires:  libavc1394-devel
BuildRequires:  libiec61883-devel
BuildRequires:  libraw1394-devel

%if %{with_directfb}
BuildRequires:  directfb-devel
%endif

%if %{with_xvmcnvidia}
BuildRequires:  xorg-x11-drv-nvidia-devel
%endif

# API Build Requirements

%if %{with_perl}
BuildRequires:  perl
BuildRequires:  perl(ExtUtils::MakeMaker)
%endif

%if %{with_python}
BuildRequires:  python-devel
%endif

# Plugin Build Requirements

%if %{with_plugins}

%if %{with_mythbrowser}
BuildRequires:  kdelibs3-devel
%endif

%if %{with_mythgallery}
BuildRequires:  libtiff-devel
BuildRequires:  libexif-devel >= 0.6.9
%endif

%if %{with_mythgame}
BuildRequires:  zlib-devel
%endif

%if %{with_mythmusic}
BuildRequires:  libcdaudio-devel >= 0.99.6
BuildRequires:  cdparanoia-devel
BuildRequires:  libvisual-devel
BuildRequires:  SDL-devel
%endif

%if %{with_mythnews}
%endif

%if %{with_mythphone}
%endif
%if 0%{?fedora} >= 9
BuildRequires: ncurses-devel
%else
BuildRequires: libtermcap-devel
%endif
%if %{with_festival}
BuildRequires:  festival-devel
%endif

%if %{with_mythvideo}
%endif

%if %{with_mythweather}
Requires:       mythweather      >= %{version}
Requires:       perl(XML::Simple)
Requires:       perl(LWP::Simple)
%endif

%if %{with_mythzoneminder}
%endif

%endif

################################################################################
# Requirements for the mythtv meta package

Requires:  libmyth            = %{version}-%{release}
Requires:  mythtv-backend     = %{version}-%{release}
Requires:  mythtv-base-themes = %{version}-%{release}
Requires:  mythtv-common      = %{version}-%{release}
Requires:  mythtv-docs        = %{version}-%{release}
Requires:  mythtv-frontend    = %{version}-%{release}
Requires:  mythtv-setup       = %{version}-%{release}
Requires:  perl-MythTV        = %{version}-%{release}
Requires:  python-MythTV      = %{version}-%{release}

Requires:  mythplugins        = %{version}-%{release}
Requires:  mythtv-themes      = %{version}

Requires:  mysql-server >= 5, mysql >= 5
# XMLTV is not yet packaged for rpmfusion
#Requires: xmltv
Requires:  wget >= 1.9.1

# faad2-devel.ppc64 is not available, so:
ExcludeArch: ppc64

# Generate the required mythtv-frontend-api version string here so we only
# have to do it once.
%define mythfeapiver %(echo %{version} | awk -F. '{print $1 "." $2}')

################################################################################

%description
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

There are also several add-ons and themes available. In order to facilitate
installations with smart/apt-get/yum and other related package
resolvers this meta-package can be used to install all in one sweep.

MythTV implements the following DVR features, and more, with a
unified graphical interface:

 - Basic 'live-tv' functionality.  Pause/Fast Forward/Rewind "live" TV.
 - Video compression using RTjpeg or MPEG-4, and support for DVB and
   hardware encoder cards/devices.
 - Program listing retrieval using XMLTV
 - Themable, semi-transparent on-screen display
 - Electronic program guide
 - Scheduled recording of TV programs
 - Resolution of conflicts between scheduled recordings
 - Basic video editing

################################################################################

%package docs
Summary: MythTV documentation
Group:   Documentation

%description docs
The MythTV documentation, contrib files, database initialization file
and miscellaneous other bits and pieces.

################################################################################

%package -n libmyth
Summary:   Library providing mythtv support.
Group:     System Environment/Libraries

Requires:  freetype >= 2
Requires:  lame
Requires:  qt4
Requires:  qt4-MySQL

%description -n libmyth
Common library code for MythTV and add-on modules (development)
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

################################################################################

%package -n libmyth-devel
Summary:   Development files for libmyth.
Group:     Development/Libraries

Requires:  libmyth = %{version}-%{release}

Requires:  freetype-devel >= 2
Requires:  mysql-devel >= 5
Requires:  qt4-devel
Requires:  lm_sensors-devel
Requires:  lirc-devel

# X, and Xv video support
Requires:  libXmu-devel
Requires:  libXv-devel
Requires:  libXvMC-devel
Requires:  libXxf86vm-devel
Requires:  mesa-libGLU-devel
Requires:  xorg-x11-proto-devel
%ifarch %{ix86} x86_64
Requires:  xorg-x11-drv-i810-devel
Requires:  xorg-x11-drv-openchrome-devel
%endif

# OpenGL video output and vsync support
Requires:  libGL-devel, libGLU-devel

# Misc A/V format support
Requires:  a52dec-devel
Requires:  faac-devel
Requires:  faad2-devel
Requires:  fftw2-devel < 3
Requires:  fftw2-devel >= 2.1.3
Requires:  flac-devel >= 1.0.4
Requires:  gsm-devel
Requires:  lame-devel
Requires:  libdca-devel
#Requires:  libdvdcss-devel >= 1.2.7
Requires:  libdvdnav-devel
Requires:  libdvdread-devel >= 0.9.4
Requires:  libfame-devel >= 0.9.0
Requires:  libmad-devel
Requires:  libogg-devel
Requires:  libtheora-devel
Requires:  libvorbis-devel >= 1.0
Requires:  mjpegtools-devel >= 1.6.1
Requires:  taglib-devel >= 1.4
Requires:  transcode >= 0.6.8
Requires:  x264-devel
Requires:  xvidcore-devel >= 0.9.1

# Audio framework support
Requires:  alsa-lib-devel
Requires:  arts-devel
Requires:  jack-audio-connection-kit-devel

# Need dvb headers for dvb support
Requires:  kernel-headers

# FireWire cable box support
Requires:  libavc1394-devel
Requires:  libiec61883-devel
Requires:  libraw1394-devel

%if %{with_directfb}
Requires:  directfb-devel
%endif

%if %{with_xvmcnvidia}
Requires:  xorg-x11-drv-nvidia-devel
%endif

%description -n libmyth-devel
This package contains the header files and libraries for developing
add-ons for mythtv.

################################################################################

%package base-themes
Summary: Core user interface themes for mythtv
Group:   Applications/Multimedia

# Replace an old ATRMS package
Provides:   mythtv-theme-gant
Obsoletes:  mythtv-theme-gant

%description base-themes
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv-docs package for more information.

This package contains the base themes for the mythtv user interface.

################################################################################

%package frontend
Summary:   Client component of mythtv (a DVR)
Group:     Applications/Multimedia
Requires:  freetype, lame
Requires:  mythtv-common       = %{version}-%{release}
Requires:  mythtv-base-themes  = %{version}
Provides:  mythtv-frontend-api = %{mythfeapiver}

%description frontend
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains only the client software, which provides a
front-end for playback and configuration.  It requires access to a
mythtv-backend installation, either on the same system or one
reachable via the network.

################################################################################

%package backend
Summary:    Server component of mythtv (a DVR)
Group:      Applications/Multimedia
Requires:   lame
Requires:   mythtv-common = %{version}-%{release}
Conflicts:  xmltv-grabbers < 0.5.37

%description backend
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains only the server software, which provides video
and audio capture and encoding services.  In order to be useful, it
requires a mythtv-frontend installation, either on the same system or
one reachable via the network.

################################################################################

%package setup
Summary:   Setup the mythtv backend
Group:     Applications/Multimedia
Requires:  freetype
Requires:  mythtv-backend = %{version}-%{release}
Requires:  mythtv-base-themes = %{version}

%description setup
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains only the setup software for configuring the
mythtv backend.

################################################################################

%package common
Summary: Common components needed by multiple other MythTV components
Group: Applications/Multimedia

%description common
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains components needed by multiple other MythTV components.

################################################################################

%if %{with_perl}

%package -n perl-MythTV
Summary:        Perl bindings for MythTV
Group:          Development/Languages
# Wish we could do this:
#BuildArch:      noarch

Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(DBD::mysql)
# Disabled because there are no RPM packages for these yet,
# and RPM doesn't seem to be picking up on CPAN versions
#Requires:       perl(Net::UPnP)
#Requires:       perl(Net::UPnP::ControlPoint)

%description -n perl-MythTV
Provides a perl-based interface to interacting with MythTV.

%endif

################################################################################

%if %{with_python}

%package -n python-MythTV
Summary:        Python bindings for MythTV
Group:          Development/Languages
# Wish we could do this:
#BuildArch:      noarch

Requires:       MySQL-python

%description -n python-MythTV
Provides a python-based interface to interacting with MythTV.

%endif

################################################################################

%if %{with_plugins}

# Meta package for all mythtv plugins
%package -n mythplugins

Summary:  Main MythTV plugins
Group:    Applications/Multimedia

Requires:  mythmusic      = %{version}-%{release}
Requires:  mythvideo      = %{version}-%{release}
Requires:  mythweather    = %{version}-%{release}
Requires:  mythgallery    = %{version}-%{release}
Requires:  mythgame       = %{version}-%{release}
Requires:  mythnews       = %{version}-%{release}
Requires:  mythbrowser    = %{version}-%{release}
Requires:  mythphone      = %{version}-%{release}
Requires:  mythcontrols   = %{version}-%{release}
Requires:  mythflix       = %{version}-%{release}
Requires:  mytharchive    = %{version}-%{release}
Requires:  mythzoneminder = %{version}-%{release}
Requires:  mythmovies     = %{version}-%{release}
Requires:  mythweb        = %{version}-%{release}

%description -n mythplugins
This is a consolidation of all the official MythTV plugins that used to be
distributed as separate downloads from mythtv.org.

################################################################################
%if %{with_mytharchive}

%package -n mytharchive
Summary:   A module for MythTV for creating and burning DVDs
Group:     Applications/Multimedia

Requires:  mythtv-frontend-api = %{mythfeapiver}
Requires:  MySQL-python
Requires:  cdrecord >= 2.01
Requires:  dvd+rw-tools >= 5.21.4.10.8
Requires:  dvdauthor >= 0.6.11
Requires:  ffmpeg >= 0.4.9
Requires:  mjpegtools >= 1.6.2
Requires:  mkisofs >= 2.01
Requires:  python >= 2.3.5
Requires:  python-imaging
Requires:  transcode >= 1.0.2

%description -n mytharchive
MythArchive is a new plugin for MythTV that lets you create DVDs from
your recorded shows, MythVideo files and any video files available on
your system.

%endif
################################################################################
%if %{with_mythbrowser}

%package -n mythbrowser
Summary:   A small web browser module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythbrowser
MythBrowser is a full fledged web-browser (multiple tabs) to display
webpages in full-screen mode. Simple page navigation is possible.
Starting with version 0.13 it also has full support for mouse driven
navigation (right mouse opens and clos es the popup menu).

MythBrowser also contains a BookmarkManager to manage the website
links in a simple mythplugin.

%endif
################################################################################
%if %{with_mythcontrols}

%package -n mythcontrols
Summary:   A key bindings editor for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythcontrols
MythControls is a key bindings editor for MythTV.

%endif
################################################################################
%if %{with_mythflix}

%package -n mythflix
Summary:   A NetFlix module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythflix
MythFlix is a NetFlix queue manager for MythTV.

%endif
################################################################################
%if %{with_mythgallery}

%package -n mythgallery
Summary:   A gallery/slideshow module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythgallery
A gallery/slideshow module for MythTV.

%endif
################################################################################
%if %{with_mythgame}

%package -n mythgame
Summary:   A game frontend (xmame, nes, snes, pc) for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythgame
A game frontend (xmame, nes, snes, pc) for MythTV.

################################################################################
%package -n mythgame-emulators
Summary:   Meta-package requiring emulators for game types mythgame knows about
Group:     Applications/Multimedia
Requires:  mythgame = %{version}-%{release}
# Multi Arcade Machine Emulator, Amiga, Atari 2600
Requires:  sdlmame
Requires:  e-uae
Requires:  stella
# Nintendo, Super Nintendo, Nintendo 64
Requires:  fceultra
Requires:  zsnes
Requires:  mupen64, mupen64-ricevideo
# Sega Genesis, Sega Master System, Game Gear
Requires:  gens
Requires:  dega-sdl
Requires:  osmose
# TurboGraphx 16 (and others)
Requires:  mednafen

%description -n mythgame-emulators
Meta-package requiring emulators for game types mythgame knows about.

%endif
################################################################################
%if %{with_mythmovies}

%package -n mythmovies
Summary:   A module for MythTV for providing local show times and cinema listings
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythmovies
MythZoneMinder is a plugin to provide show times and cinema listings
based on Zip/Post code and a given radius. It uses external scripts to
grab times and so can be used in any country so long as a script is
written for a local data source. It ships with a grabber for the USA
which uses the ignyte website.

%endif
################################################################################
%if %{with_mythmusic}

%package -n mythmusic
Summary:   The music player add-on module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythmusic
Music add-on for mythtv.

%endif
################################################################################
%if %{with_mythnews}

%package -n mythnews
Summary:   An RSS news feed plugin for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythnews
An RSS news feed reader plugin for MythTV.

%endif
################################################################################
%if %{with_mythphone}

%package -n mythphone
Summary:   A video conferencing module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythphone
Mythphone is a phone and videophone capability on MYTH using the
standard SIP protocol.  It is compatible with Microsoft XP Messenger
and with SIP Service Providers such as Free World Dialup
(fwd.pulver.com).

%endif
################################################################################
%if %{with_mythvideo}

%package -n mythvideo
Summary:   A generic video player frontend module for MythTV
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}
Requires:  mplayer
Requires:  transcode >= 0.6.8

Provides:  mythdvd = %{version}-%{release}
Obsoletes: mythdvd < %{version}-%{release}

%description -n mythvideo
MythVideo is a MythTV module that allows you to play videos, DVDs and
(optionally) VCDs. It can also be configured to let you rip DVDs and
transcode their video and audio content to other (generally smaller)
formats. The player can either use the MythTV internal software (which
now supports DVD menus), or simply to invoke your favorite DVD/XVCD
playing software (mplayer, ogle, xine, etc) as an external
command. The transcoding is based on and derived from the excellent
transcode package.

%endif
################################################################################
%if %{with_mythweather}

%package -n mythweather
Summary:   A MythTV module that displays a weather forcast
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}
Requires:  perl(XML::SAX::Base)

%description -n mythweather
A MythTV module that displays a weather forcast.

%endif
################################################################################
%if %{with_mythweb}

%package -n mythweb
Summary:   The web interface to MythTV
Group:     Applications/Multimedia
Requires:  httpd >= 1.3.26
Requires:  php >= 5.1
Requires:  php-mysql

%description -n mythweb
The web interface to MythTV.

%endif
################################################################################
%if %{with_mythzoneminder}

%package -n mythzoneminder
Summary:   A module for MythTV for camera security and surveillance
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}

%description -n mythzoneminder
MythZoneMinder is a plugin to interface to some of the features of
ZoneMinder. You can use it to view a status window similar to the
console window in ZM. Also there are screens to view live camera shots
and replay recorded events.

%endif
################################################################################

# End of plugins
%endif

################################################################################

%prep
%setup -q -c -a 1

# Replace static lib paths with %{_lib} so we build properly on x86_64
# systems, where the libs are actually in lib64.
    if [ "%{_lib}" != "lib" ]; then
        grep -rlZ /lib/   . | xargs -r0 sed -i -e 's,/lib/,/%{_lib}/,g'
        grep -rlZ /lib$   . | xargs -r0 sed -i -e 's,/lib$,/%{_lib},'
        grep -rlZ '/lib ' . | xargs -r0 sed -i -e 's,/lib ,/%{_lib} ,g'
    fi

##### MythTV

cd mythtv-%{version}

# Drop execute permissions on contrib bits, since they'll be %doc
    find contrib/ -type f -exec chmod -x "{}" \;

# Nuke Windows and Mac OS X build scripts
    rm -rf contrib/Win32 contrib/OSX

# Put perl bits in the right place and set opt flags
    sed -i -e 's#perl Makefile.PL#%{__perl} Makefile.PL INSTALLDIRS=vendor OPTIMIZE="$RPM_OPT_FLAGS"#' \
        bindings/perl/perl.pro

# Install other source files, and fix pathnames
    cp -a %{SOURCE10} %{SOURCE101} %{SOURCE102} %{SOURCE103} .
    cp -a %{SOURCE106} %{SOURCE107} %{SOURCE108} %{SOURCE109} .
    for file in mythbackend.init \
                mythbackend.sysconfig \
                mythbackend.logrotate; do
        sed -e's|@logdir@|%{_localstatedir}/log|g' \
            -e's|@rundir@|%{_localstatedir}/run|g' \
            -e's|@sysconfdir@|%{_sysconfdir}|g' \
            -e's|@sysconfigdir@|%{_sysconfdir}/sysconfig|g' \
            -e's|@initdir@|%{_sysconfdir}/init.d|g' \
            -e's|@bindir@|%{_bindir}|g' \
            -e's|@sbindir@|%{_sbindir}|g' \
            -e's|@subsysdir@|%{_localstatedir}/lock/subsys|g' \
            -e's|@varlibdir@|%{_localstatedir}/lib|g' \
            -e's|@varcachedir@|%{_localstatedir}/cache|g' \
            -e's|@logrotatedir@|%{_sysconfdir}/logrotate.d|g' \
            < $file.in > $file
    done

# Prevent all of those nasty installs to ../../../../../bin/whatever
#    echo "QMAKE_PROJECT_DEPTH = 0" >> mythtv.pro
#    echo "QMAKE_PROJECT_DEPTH = 0" >> settings.pro
#    chmod 644 settings.pro

# We also need Xv libs to build XvMCNVIDIA
    sed -i -e 's,VENDOR_XVMC_LIBS="-lXvMCNVIDIA",VENDOR_XVMC_LIBS="-lXvMCNVIDIA -lXv",' configure

# On to mythplugins
    cd ..

##### MythPlugins
%if %{with_plugins}

cd mythplugins-%{version}

# Fix /mnt/store -> /var/lib/mythmusic
    cd mythmusic
    sed -i -e's,/mnt/store/music,%{_localstatedir}/lib/mythmusic,' mythmusic/globalsettings.cpp
    cd ..

# Fix /mnt/store -> /var/lib/mythvideo
    cd mythvideo
    sed -i -e 's,/share/Movies/dvd,%{_localstatedir}/lib/mythvideo,' mythvideo/globalsettings.cpp
    cd ..

# Fix up permissions for MythWeb
    cd mythweb
    chmod -R g-w ./*
    cd ..

# Prevent all of those nasty installs to ../../../../../bin/whatever
#    echo "QMAKE_PROJECT_DEPTH = 0" >> mythtv.pro
#    echo "QMAKE_PROJECT_DEPTH = 0" >> settings.pro
#    chmod 644 settings.pro

# And back to the compile root
    cd ..

%endif

################################################################################

%build

# First, we build MythTV
cd mythtv-%{version}

# Similar to 'percent' configure, but without {_target_platform} and
# {_exec_prefix} etc... MythTV no longer accepts the parameters that the
# configure macro passes, so we do this manually.
./configure \
    --prefix=%{_prefix}                         \
    --libdir=%{_libdir}                         \
    --libdir-name=%{_lib}                       \
    --mandir=%{_mandir}                         \
--disable-iptv \
    --enable-pthreads                           \
    --enable-ffmpeg-pthreads                    \
    --enable-joystick-menu                      \
    --enable-audio-arts                         \
    --enable-audio-alsa                         \
    --enable-audio-oss                          \
    --enable-audio-jack                         \
    --enable-x11 --x11-path=%{_includedir}      \
    --enable-xv                                 \
    --enable-xvmc-vld --enable-xvmc-pro         \
    --enable-opengl-video --enable-opengl-vsync \
    --enable-xrandr                             \
    --enable-lirc                               \
    --enable-ivtv                               \
    --enable-firewire                           \
    --enable-dvb                                \
    --enable-libfaac                            \
    --enable-libfaad --enable-libfaad --enable-libfaadbin \
    --enable-liba52                             \
    --enable-libmp3lame                         \
    --enable-libtheora --enable-libvorbis       \
    --enable-libxvid                            \
%if %{with_xvmcnvidia}
    --xvmc-lib=XvMCNVIDIA_dynamic               \
    --enable-xvmc-opengl                        \
%else
    --disable-xvmc-opengl                       \
%endif
%if %{with_directfb}
    --enable-directfb                           \
%else
    --disable-directfb                          \
%endif
%if !%{with_perl}
    --without-bindings=perl                     \
%endif
%if !%{with_python}
    --without-bindings=python                   \
%endif
%ifarch ppc
    --extra-cflags="%{optflags} -maltivec -fomit-frame-pointer" \
    --extra-cxxflags="%{optflags} -maltivec -fomit-frame-pointer" \
%else
    --extra-cflags="%{optflags} -fomit-frame-pointer" \
    --extra-cxxflags="%{optflags} -fomit-frame-pointer" \
%endif
%ifarch %{ix86}
    --cpu=i686 --tune=i686 --enable-mmx \
%endif
%if %{with_proc_opt}
    --enable-proc-opt \
%endif
%if %{with_debug}
    --compile-type=debug                        \
%else
    --compile-type=release                      \
%endif
    --enable-debug
###    --enable-libx264                            \

# Insert rpm version-release for mythbackend --version output
    find . -name version.pro -exec sed -i -e 's,svnversion \$\${SVNTREEDIR},echo "%{version}-%{release}",g' {} \;

# Make
    make %{?_smp_mflags}

# Prepare to build the plugins
    cd ..
    mkdir temp
    temp=`pwd`/temp
    make -C mythtv-%{version} install INSTALL_ROOT=$temp
    export LD_LIBRARY_PATH=$temp%{_libdir}:$LD_LIBRARY_PATH

# Next, we build the plugins
%if %{with_plugins}
cd mythplugins-%{version}

# Fix things up so they can find our "temp" install location for libmyth
    echo "QMAKE_PROJECT_DEPTH = 0" >> settings.pro
    find . -name \*.pro \
        -exec sed -i -e "s,INCLUDEPATH += .\+/include/mythtv,INCLUDEPATH += $temp%{_includedir}/mythtv," {} \; \
        -exec sed -i -e "s,TARGETDEPS += \$\${LIBDIR}/libmyth,TARGETDEPS += $temp%{_libdir}/libmyth," {} \; \
        -exec sed -i -e "s,\$\${PREFIX}/include/mythtv,$temp%{_includedir}/mythtv," {} \;
    echo "INCLUDEPATH -= \$\${PREFIX}/include" >> settings.pro
    echo "INCLUDEPATH -= %{_includedir}"       >> settings.pro
    echo "INCLUDEPATH += $temp%{_includedir}"  >> settings.pro
    echo "INCLUDEPATH += %{_includedir}"       >> settings.pro
    echo "LIBS *= -L$temp%{_libdir}"           >> settings.pro
    echo "QMAKE_LIBDIR += $temp%{_libdir}"     >> targetdep.pro

    ./configure \
        --prefix=${temp}%{_prefix} \
        --libdir=%{_libdir} \
        --libdir-name=%{_lib} \
    %if %{with_mytharchive}
        --enable-mytharchive \
        --enable-create-dvd \
        --enable-create-archive \
    %else
        --disable-mytharchive \
    %endif
    %if %{with_mythbrowser}
        --enable-mythbrowser \
    %else
        --disable-mythbrowser \
    %endif
    %if %{with_mythcontrols}
        --enable-mythcontrols \
    %else
        --disable-mythcontrols \
    %endif
    %if %{with_mythflix}
        --enable-mythflix \
    %else
        --disable-mythflix \
    %endif
    %if %{with_mythgallery}
        --enable-mythgallery \
        --enable-exif \
        --enable-new-exif \
    %else
        --disable-mythgallery \
    %endif
    %if %{with_mythgame}
        --enable-mythgame \
    %else
        --disable-mythgame \
    %endif
    %if %{with_mythmovies}
        --enable-mythmovies \
    %else
        --disable-mythmovies \
    %endif
    %if %{with_mythmusic}
        --enable-mythmusic \
    %else
        --disable-mythmusic \
    %endif
    %if %{with_mythnews}
        --enable-mythnews \
    %else
        --disable-mythnews \
    %endif
    %if %{with_mythphone}
        --enable-mythphone \
    %else
        --disable-mythphone \
    %endif
    %if %{with_mythvideo}
        --enable-mythvideo \
        --enable-transcode \
        --enable-vcd \
    %else
        --disable-mythvideo \
    %endif
    %if %{with_mythweather}
        --enable-mythweather \
    %else
        --disable-mythweather \
    %endif
    %if %{with_mythweb}
        --enable-mythweb \
    %else
        --disable-mythweb \
    %endif
    %if %{with_mythzoneminder}
        --enable-mythzoneminder \
    %else
        --disable-mythzoneminder \
    %endif
    %if %{with_festival}
        --enable-festival \
    %else
        --disable-festival \
    %endif
        --enable-opengl \
        --enable-libvisual \
        --enable-fftw \
        --enable-sdl \
        --enable-aac

    make %{?_smp_mflags}

    cd ..
%endif

################################################################################

%install

# Clean
    rm -rf %{buildroot}

# First, install MythTV
cd mythtv-%{version}

    make install INSTALL_ROOT=%{buildroot}

    ln -s mythtv-setup %{buildroot}%{_bindir}/mythtvsetup
    mkdir -p %{buildroot}%{_localstatedir}/lib/mythtv
    mkdir -p %{buildroot}%{_localstatedir}/cache/mythtv
    mkdir -p %{buildroot}%{_localstatedir}/log/mythtv
    mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
    mkdir -p %{buildroot}%{_sysconfdir}/init.d
    mkdir -p %{buildroot}%{_sysconfdir}/sysconfig
    mkdir -p %{buildroot}%{_sysconfdir}/mythtv

# Fix permissions on executable python bindings
    chmod +x %{buildroot}%{python_sitelib}/MythTV/Myth{DB,TV}.py

# mysql.txt and other config/init files
    install -m 644 %{SOURCE110} %{buildroot}%{_sysconfdir}/mythtv/
    echo "# to be filled in by mythtv-setup" > %{buildroot}%{_sysconfdir}/mythtv/config.xml
    install -p -m 755 mythbackend.init %{buildroot}%{_sysconfdir}/init.d/mythbackend
    install -p -m 644 mythbackend.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/mythbackend
    install -p -m 644 mythbackend.logrotate  %{buildroot}%{_sysconfdir}/logrotate.d/mythbackend

# Desktop entries
    mkdir -p %{buildroot}%{_datadir}/pixmaps
    mkdir -p %{buildroot}%{_datadir}/applications
    for file in %{desktop_applications}; do
      install -p $file.png %{buildroot}%{_datadir}/pixmaps/$file.png
      desktop-file-install --vendor %{desktop_vendor} \
        --dir %{buildroot}%{_datadir}/applications    \
        --add-category X-Fedora-Extra     \
        --add-category Application        \
        --add-category AudioVideo         \
        $file.desktop
    done

    mkdir -p %{buildroot}%{_libdir}/mythtv/plugins

    mkdir -p %{buildroot}%{_datadir}/mythtv/build/
    install -p -m 644 settings.pro %{buildroot}%{_datadir}/mythtv/build/

    cd ..

# MythPlugins
%if %{with_plugins}
cd mythplugins-%{version}

    make install INSTALL_ROOT=%{buildroot}

%if %{with_mythmusic}
    mkdir -p %{buildroot}%{_localstatedir}/lib/mythmusic
%endif
%if %{with_mythvideo}
    mkdir -p %{buildroot}%{_localstatedir}/lib/mythvideo
%endif
%if %{with_mythgallery}
    mkdir -p %{buildroot}%{_localstatedir}/lib/pictures
%endif
%if %{with_mythgame}
    mkdir -p %{buildroot}%{_datadir}/mythtv/games/nes/{roms,screens}
    mkdir -p %{buildroot}%{_datadir}/mythtv/games/snes/{roms,screens}
#   mkdir -p %{buildroot}%{_datadir}/mythtv/games/mame/{roms,screens,flyers,cabs}
    mkdir -p %{buildroot}%{_datadir}/mythtv/games/PC/screens
    mkdir -p %{buildroot}%{_datadir}/mame
    ln -s ../../mame %{buildroot}%{_datadir}/mythtv/games/xmame
    mkdir -p %{buildroot}%{_datadir}/mame/flyers
    ln -s snap %{buildroot}%{_datadir}/mythtv/games/xmame/screens
    mkdir -p %{buildroot}%{_sysconfdir}/mythgame
    cp -a mythgame/gamelist.xml %{buildroot}%{_sysconfdir}/mythgame/
    ln -s ../../../../../%{_sysconfdir}/mythgame/ \
        %{buildroot}%{_datadir}/mythtv/games/PC/gamelist.xml
%endif

%if %{with_mythweb}
    cd mythweb
    mkdir -p %{buildroot}%{_datadir}/mythweb
    cp -a * %{buildroot}%{_datadir}/mythweb/
    mkdir -p %{buildroot}%{_datadir}/mythweb/{image_cache,php_sessions}
# fix up permissions
    chmod -R g-x %{buildroot}%{_datadir}/mythweb

    mkdir -p %{buildroot}%{_sysconfdir}/httpd/conf.d
    cp %{SOURCE401} %{buildroot}%{_sysconfdir}/httpd/conf.d/
# drop .htaccess file, settings handled in the above
    rm -f %{buildroot}%{_datadir}/mythweb/data/.htaccess
    cd ..
%endif

# And back to the build/install root
    cd ..
%endif

################################################################################

%clean
rm -rf %{buildroot}

################################################################################

%pre
# Add the "mythtv" user
/usr/sbin/useradd -c "mythtvbackend User" \
    -s /sbin/nologin -r -d %{_varlibdir}/mythtv mythtv 2> /dev/null || :

%post

%post -n libmyth -p /sbin/ldconfig

%postun -n libmyth -p /sbin/ldconfig

%post backend
/sbin/chkconfig --add mythbackend

%preun backend
if [ $1 = 0 ]; then
    /sbin/service mythbackend stop > /dev/null 2>&1
    /sbin/chkconfig --del mythbackend
fi

################################################################################

%files
%defattr(-,root,root,-)

%files docs
%defattr(-,root,root,-)
%doc mythtv-%{version}/README* mythtv-%{version}/UPGRADING
%doc mythtv-%{version}/AUTHORS mythtv-%{version}/COPYING mythtv-%{version}/FAQ
%doc mythtv-%{version}/database mythtv-%{version}/keys.txt
%doc mythtv-%{version}/docs/*.html mythtv-%{version}/docs/*.png
%doc mythtv-%{version}/docs/*.txt mythtv-%{version}/contrib
%doc mythtv-%{version}/PACKAGE-LICENSING

%files common
%defattr(-,root,root,-)
%dir %{_sysconfdir}/mythtv
%dir %{_datadir}/mythtv
%config(noreplace) %{_sysconfdir}/mythtv/mysql.txt
%config(noreplace) %{_sysconfdir}/mythtv/config.xml
%{_bindir}/mythcommflag
%{_bindir}/mythtranscode
%{_datadir}/mythtv/mythconverg*.pl

%files backend
%defattr(-,root,root,-)
%{_bindir}/mythbackend
%{_bindir}/mythfilldatabase
%{_bindir}/mythjobqueue
%{_bindir}/mythreplex
%{_datadir}/mythtv/MXML_scpd.xml
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/lib/mythtv
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/cache/mythtv
%{_sysconfdir}/init.d/mythbackend
%config(noreplace) %{_sysconfdir}/sysconfig/mythbackend
%config(noreplace) %{_sysconfdir}/logrotate.d/mythbackend
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/log/mythtv

%files setup
%defattr(-,root,root,-)
%{_bindir}/mythtv-setup
%{_bindir}/mythtvsetup
%{_datadir}/mythtv/setup.xml
%{_datadir}/applications/*mythtv-setup.desktop

%files frontend
%defattr(-,root,root,-)
%{_datadir}/mythtv/CDS_scpd.xml
%{_datadir}/mythtv/CMGR_scpd.xml
%{_datadir}/mythtv/MFEXML_scpd.xml
%{_datadir}/mythtv/MSRR_scpd.xml
%{_datadir}/mythtv/devicemaster.xml
%{_datadir}/mythtv/deviceslave.xml
%{_datadir}/mythtv/info_menu.xml
%{_datadir}/mythtv/info_settings.xml
%{_datadir}/mythtv/library.xml
%{_datadir}/mythtv/main_settings.xml
%{_datadir}/mythtv/mainmenu.xml
%{_datadir}/mythtv/manage_recordings.xml
%{_datadir}/mythtv/media_settings.xml
%{_datadir}/mythtv/optical_menu.xml
%{_datadir}/mythtv/recpriorities_settings.xml
%{_datadir}/mythtv/setup.xml
%{_datadir}/mythtv/tv_lists.xml
%{_datadir}/mythtv/tv_schedule.xml
%{_datadir}/mythtv/tv_search.xml
%{_datadir}/mythtv/tv_settings.xml
%{_datadir}/mythtv/tvmenu.xml
%{_datadir}/mythtv/util_menu.xml
%{_bindir}/mythfrontend
%{_bindir}/mythtv
%{_bindir}/mythtvosd
%{_bindir}/mythlcdserver
%{_bindir}/mythshutdown
%{_bindir}/mythwelcome
%dir %{_libdir}/mythtv
%dir %{_libdir}/mythtv/filters
%{_libdir}/mythtv/filters/*
%dir %{_libdir}/mythtv/plugins
%{_datadir}/mythtv/*.ttf
%dir %{_datadir}/mythtv/i18n
%{_datadir}/mythtv/i18n/mythfrontend_*.qm
%{_datadir}/applications/*mythfrontend.desktop
%{_datadir}/pixmaps/myth*.png

%files base-themes
%defattr(-,root,root,-)
%dir %{_datadir}/mythtv/themes
%{_datadir}/mythtv/themes/*

%files -n libmyth
%defattr(-,root,root,-)
%{_libdir}/*.so.*

%files -n libmyth-devel
%defattr(-,root,root,-)
%{_includedir}/*
%{_libdir}/*.so
%exclude %{_libdir}/*.a
%dir %{_datadir}/mythtv/build
%{_datadir}/mythtv/build/settings.pro

%if %{with_perl}
%files -n perl-MythTV
%defattr(-,root,root,-)
%{perl_vendorlib}/MythTV.pm
%dir %{perl_vendorlib}/MythTV
%{perl_vendorlib}/MythTV/*.pm
%dir %{perl_vendorlib}/IO/Socket
%dir %{perl_vendorlib}/IO/Socket/INET
%{perl_vendorlib}/IO/Socket/INET/MythTV.pm
%exclude %{perl_vendorarch}/auto/MythTV/.packlist
%endif

%if %{with_python}
%files -n python-MythTV
%defattr(-,root,root,-)
%dir %{python_sitelib}/MythTV/
%{python_sitelib}/MythTV/*
%if 0%{?fedora} >= 9
%{python_sitelib}/MythTV-*.egg-info
%endif
%endif

%if %{with_plugins}
%files -n mythplugins
%defattr(-,root,root,-)
%doc mythplugins-%{version}/COPYING

%if %{with_mytharchive}
%files -n mytharchive
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mytharchive/AUTHORS
%doc mythplugins-%{version}/mytharchive/COPYING
%doc mythplugins-%{version}/mytharchive/README
%doc mythplugins-%{version}/mytharchive/TODO
%{_bindir}/mytharchivehelper
%{_libdir}/mythtv/plugins/libmytharchive.so
#{_datadir}/mythtv/archiveformat.xml
%{_datadir}/mythtv/archivemenu.xml
%{_datadir}/mythtv/archiveutils.xml
%{_datadir}/mythtv/mytharchive
%{_datadir}/mythtv/i18n/mytharchive_*.qm
%endif

%if %{with_mythbrowser}
%files -n mythbrowser
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythbrowser/AUTHORS
%doc mythplugins-%{version}/mythbrowser/COPYING
%doc mythplugins-%{version}/mythbrowser/README
%{_bindir}/mythbrowser
%{_libdir}/mythtv/plugins/libmythbookmarkmanager.so
%{_datadir}/mythtv/i18n/mythbrowser_*.qm
%endif

%if %{with_mythcontrols}
%files -n mythcontrols
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythcontrols/AUTHORS
%doc mythplugins-%{version}/mythcontrols/COPYING
%doc mythplugins-%{version}/mythcontrols/README
%doc mythplugins-%{version}/mythcontrols/TODO
%{_libdir}/mythtv/plugins/libmythcontrols.so
%{_datadir}/mythtv/i18n/mythcontrols_*.qm
%endif

%if %{with_mythflix}
%files -n mythflix
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythflix/AUTHORS
%doc mythplugins-%{version}/mythflix/COPYING
%doc mythplugins-%{version}/mythflix/README
%{_libdir}/mythtv/plugins/libmythflix.so
%{_datadir}/mythtv/mythflix
%{_datadir}/mythtv/i18n/mythflix_*.qm
%{_datadir}/mythtv/i18n/mythflix_*.ts
%{_datadir}/mythtv/netflix_menu.xml
%endif

%if %{with_mythgallery}
%files -n mythgallery
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythgallery/AUTHORS
%doc mythplugins-%{version}/mythgallery/COPYING
%doc mythplugins-%{version}/mythgallery/README
%{_libdir}/mythtv/plugins/libmythgallery.so
%{_datadir}/mythtv/i18n/mythgallery_*.qm
%{_localstatedir}/lib/pictures
%endif

%if %{with_mythgame}
%files -n mythgame
%defattr(-,root,root,-)
%dir %{_sysconfdir}/mythgame
%config(noreplace) %{_sysconfdir}/mythgame/gamelist.xml
%{_libdir}/mythtv/plugins/libmythgame.so
%{_datadir}/mythtv/games
%exclude %{_datadir}/mythtv/games/xmame
%{_datadir}/mythtv/game_settings.xml
%{_datadir}/mythtv/i18n/mythgame_*.qm

%files -n mythgame-emulators
%defattr(-,root,root,-)
%{_datadir}/mythtv/games/xmame
%{_datadir}/mame/screens
%{_datadir}/mame/flyers
%endif

%if %{with_mythmovies}
%files -n mythmovies
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythmovies/COPYING
%doc mythplugins-%{version}/mythmovies/README
%doc mythplugins-%{version}/mythmovies/TODO
%{_bindir}/ignyte
%{_datadir}/mythtv/themes/default/movies-ui.xml
%{_libdir}/mythtv/plugins/libmythmovies.so
%endif

%if %{with_mythmusic}
%files -n mythmusic
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythmusic/AUTHORS
%doc mythplugins-%{version}/mythmusic/COPYING
%doc mythplugins-%{version}/mythmusic/README
%{_libdir}/mythtv/plugins/libmythmusic.so
%{_localstatedir}/lib/mythmusic
%{_datadir}/mythtv/musicmenu.xml
%{_datadir}/mythtv/music_settings.xml
%{_datadir}/mythtv/i18n/mythmusic_*.qm
%endif

%if %{with_mythnews}
%files -n mythnews
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythnews/AUTHORS
%doc mythplugins-%{version}/mythnews/COPYING
%doc mythplugins-%{version}/mythnews/README
%{_libdir}/mythtv/plugins/libmythnews.so
%{_datadir}/mythtv/mythnews
%{_datadir}/mythtv/i18n/mythnews_*.qm
%endif

%if %{with_mythphone}
%files -n mythphone
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythphone/AUTHORS
%doc mythplugins-%{version}/mythphone/COPYING
%doc mythplugins-%{version}/mythphone/README
%doc mythplugins-%{version}/mythphone/TODO
%{_libdir}/mythtv/plugins/libmythphone.so
%{_datadir}/mythtv/i18n/mythphone_*.qm
%endif

%if %{with_mythvideo}
%files -n mythvideo
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythvideo/COPYING
%doc mythplugins-%{version}/mythvideo/README*
%{_libdir}/mythtv/plugins/libmythvideo.so
%{_datadir}/mythtv/mythvideo
%{_datadir}/mythtv/i18n/mythvideo_*.qm
%{_datadir}/mythtv/video_settings.xml
%{_datadir}/mythtv/videomenu.xml
%{_localstatedir}/lib/mythvideo
%{_bindir}/mtd
%endif

%if %{with_mythweather}
%files -n mythweather
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythweather/AUTHORS
%doc mythplugins-%{version}/mythweather/COPYING
%doc mythplugins-%{version}/mythweather/README
%{_libdir}/mythtv/plugins/libmythweather.so
%{_datadir}/mythtv/i18n/mythweather_*.qm
%{_datadir}/mythtv/weather_settings.xml
%{_datadir}/mythtv/mythweather
%endif

%if %{with_mythweb}
%files -n mythweb
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythweb/README
%config(noreplace) %{_sysconfdir}/httpd/conf.d/mythweb.conf
%defattr(-,apache,apache,0775)
%dir %{_datadir}/mythweb
%{_datadir}/mythweb/*
%endif

%if %{with_mythzoneminder}
%files -n mythzoneminder
%defattr(-,root,root,-)
%{_libdir}/mythtv/plugins/libmythzoneminder.so
%{_datadir}/mythtv/zonemindermenu.xml
%{_bindir}/mythzmserver
%endif

%endif

################################################################################

%changelog
* Wed Dec 17 2008 Jarod Wilson <jarod@wilsonet.com> 0.22-0.1.svn
- Drop BR: on libdvdcss, it will be dynamically loaded if its installed
- Clean up some file/directory ownership issues
- Add BR: yasm-devel to enable yasm-specific enhancements

* Sat Nov 01 2008 Chris Petersen <rpm@forevermore.net> 0.22-0.1.svn
- Add a --without plugins option to disable all plugin builds

* Tue Oct 28 2008 Chris Petersen <rpm@forevermore.net> 0.22-0.1.svn
- Update to compile for pre-0.22 svn trunk, including new files and qt4 deps
- Major cleanup and porting from my personal spec (which was a combination
  of works from atrpms and some of Jarod's earlier works).
- Add a few more --with and --without options, including the ability to
  disable specific mythplugins.

* Wed Sep 10 2008 Thorsten Leemhuis <fedora [AT] leemhuis [DOT] info - 0.21-8
- rebuild for new libraw1394

* Sun Jul 20 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-7
- Disable XvMC VLD and Pro support on ppc due to lack of
  openchrome driver.

* Sat Jul 19 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-6
- Fix spec typo
- Disable mythstream patch for now, too much fuzz, revisit later

* Fri Jul 18 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-5
- Update release-0-21-fixes patches (r17859)
- Don't use %%bcond, breaks on some older buildsystems
- Put several bits in -common sub-package, as both backend
  and frontend may need them for one reason or another

* Fri May 16 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-4
- Add BR: xorg-x11-drv-i810-devel, xorg-x11-drv-openchrome-devel
- Make building with nVidia XvMC an available custom option, fix up
  conflict between it and other XvMC implementations
- Update release-0-21-fixes patches (r17338)

* Sat Apr 05 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-3
- Fix up PACKAGE-LICENSING inclusion

* Sat Apr 05 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-2
- RPMFusion package review cleanups
- Put mythtv-setup.desktop in mythtv-setup package
- Fix up initscript to start properly
- Drop unused %%ghostattr define
- Attempt to clarify licensing
- Clean up assorted Requires and BuildRequires
- Update release-0-21-fixes patches (r16965)

* Sun Mar 09 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-1
- MythTV 0.21 (r16468)
- Add release-0-21-fixes for DVD menu display fix (r16486)

* Tue Mar 04 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.17.r16394
- Update to latest release-0-21-fixes pre-release branch code (16394).

* Fri Feb 29 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.16.r16316
- Update to latest release-0-21-fixes pre-release branch code (16316).
- Add mythgame-emulators meta-package that requires a bunch of
  emulators for roms mythgame knows about.
- Account for python egg on f9+
- Enable gsm support by default

* Wed Feb 27 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.15.r16307
- Update to latest release-0-21-fixes pre-release branch code (16307).
- Try to fix up a bunch of rpmlint warnings and errors.

* Sat Feb 23 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.14.r16238
- Update to latest svn trunk (16238).
- Package up python bits.

* Thu Feb 14 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.13.r16019
- Update to latest svn trunk (16019).

* Mon Feb 11 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.12.r15914
- Update to latest svn trunk (15914).
- Turn on multi-threaded video decoding.

* Thu Jan 31 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.11.r15699
- More spec file overhauling, make it build in Fedora 9

* Thu Jan 31 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.10.r15699
- Update to latest svn trunk (15699).
- Misc spec reformatting.

* Sat Jan 26 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.9.r15614
- Update to latest svn trunk (15614).

* Tue Jan 01 2008 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.8.r15281
- Update to latest svn trunk (15281).
- Fix up version-release insertion in mythbackend --version output

* Fri Dec 07 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.7.r15081
- Update to latest svn trunk (15081).

* Sat Nov 17 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.6.r14888
- Update to latest svn trunk (14888).

* Wed Oct 17 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.6.r14695
- Update to latest svn trunk (14695).

* Fri Oct 12 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.6.r14667
- Update to latest svn trunk (14667).
- Build dvb support against kernel-headers instead
- Drop unnecessary patches
- Tweak BR: to not use any file deps (I only care about recent distros)
- Rework mythweb bits to be compliant w/Fedora packaging guidelines
- Enable OpenGL video output support
- Make dvb and opengl bits non-conditional (always enabled)

* Wed Oct 10 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.5.r14658
- Update to latest svn trunk (14658).
- Tweak configure options a bit more

* Tue Oct 02 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.4.r14589
- Update to latest svn trunk (14589).
- Restructure how optflags are passed into build
- Nuke some extra non-standard macros
- Drop ancient dvb tarball, create with_dvb option, always using v4l-devel

* Wed Sep 12 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.4.r14488
- Update to latest svn trunk (14488).

* Tue Aug 28 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.3.r14346
- Update to latest svn trunk (14346).

* Mon Aug 27 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.3.r14337
- Update to latest svn trunk (14337).

* Tue May 22 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.2.r13492
- Update to latest svn trunk (13492).
- More non-standard macro nuking

* Mon May 21 2007 Jarod Wilson <jarod@wilsonet.com> - 0.21-0.1.r13487
- Update to latest svn trunk (13487).
- Reshuffle theme files
- Credit where credit is due: forking this off the current ATrpms spec
