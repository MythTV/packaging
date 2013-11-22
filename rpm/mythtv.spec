#
# Specfile for building MythTV and MythPlugins RPMs from a git checkout.
#
# by:   Chris Petersen <cpetersen@mythtv.org>
#       Jarod Wilson <jwilson@mythtv.org>
#
#  Modified/Extended from the great (non-git/svn based) work of:
#     Axel Thimm <Axel.Thimm@ATrpms.net>
#     David Bussenschutt <buzz@oska.com>
#     and others; see changelog at bottom for details.
#
# The latest canonical upstream version of this file can be found at:
#
#     https://github.com/MythTV/packaging/tree/master/rpm
#
# The latest RPM Fusion version can be found at:
#
#     http://cvs.rpmfusion.org/viewvc/rpms/mythtv/devel/?root=free
#
# Note:
#
#     This spec relies upon several files included in the RPM Fusion mythtv
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
# --with crystalhd       Enable Crystal HD support
#
# The following options are enabled by default.  Use these options to disable:
#
# --without systemd         Use systemd for backend rather than SysV init.
# --without vdpau           Disable VDPAU support
# --without vaapi           Disable VAAPI support
# --without perl            Disable building of the perl bindings
# --without php             Disable building of the php bindings
# --without python          Disable building of the python bindings
#
# # All plugins get built by default, but you can disable them as you wish:
#
# --without mytharchive
# --without mythbrowser
# --without mythgallery
# --without mythgame
# --without mythmusic
# --without mythnetvision
# --without mythnews
# --without mythweather
# --without mythzoneminder
#

################################################################################

# A list of which applications we want to put into the desktop menu system
%define desktop_applications mythfrontend mythtv-setup

# The vendor name we should attribute the aforementioned entries to
%define desktop_vendor  mythtv

# MythTV Version string -- preferably the output from git --describe
%define vers_string v0.27-pre2-583-g031c724

# Git Revision number and branch
%define _gitrev 0.0.pre2.583.g031c724
%define branch master

#
# Basic descriptive tags for this package:
#
Name:           mythtv
Summary:        A digital video recorder (DVR) application
URL:            http://www.mythtv.org/
Group:          Applications/Multimedia

# Version/Release info
Version: 0.27
%if "%{branch}" == "master"
Release: 0.1.git.%{_gitrev}%{?dist}
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
%define with_proc_opt      %{?_with_proc_opt:      1} %{!?_with_proc_opt:      0}

# Set "--with debug" to enable MythTV debug compile mode
%define with_debug         %{?_with_debug:         1} %{?!_with_debug:         0}

# Use SystemD service by default but allow use of SysV init script.
%define with_systemd       %{?_without_systemd:    0} %{?!_without_systemd:    1}

# The following options are disabled by default.  Use --with to enable them
%define with_crystalhd     %{?_with_crystalhd:     1} %{?!_with_crystalhd:     0}

# The following options are enabled by default.  Use --without to disable them
%define with_vdpau         %{?_without_vdpau:      0} %{?!_without_vdpau:      1}
%define with_vaapi         %{?_without_vaapi:      0} %{?!_without_vaapi:      1}
%define with_xvmc          %{?_without_xvmc:       0} %{?!_without_xvmc:       1}
%define with_perl          %{?_without_perl:       0} %{!?_without_perl:       1}
%define with_php           %{?_without_php:        0} %{!?_without_php:        1}
%define with_python        %{?_without_python:     0} %{!?_without_python:     1}
%define with_pulseaudio    %{?_without_pulseaudio: 0} %{!?_without_pulseaudio: 1}

# All plugins get built by default, but you can disable them as you wish
%define with_plugins        %{?_without_plugins:        0} %{!?_without_plugins:         1}
%define with_mytharchive    %{?_without_mytharchive:    0} %{!?_without_mytharchive:     1}
%define with_mythbrowser    %{?_without_mythbrowser:    0} %{!?_without_mythbrowser:     1}
%define with_mythgallery    %{?_without_mythgallery:    0} %{!?_without_mythgallery:     1}
%define with_mythgame       %{?_without_mythgame:       0} %{!?_without_mythgame:        1}
%define with_mythmusic      %{?_without_mythmusic:      0} %{!?_without_mythmusic:       1}
%define with_mythnews       %{?_without_mythnews:       0} %{!?_without_mythnews:        1}
%define with_mythweather    %{?_without_mythweather:    0} %{!?_without_mythweather:     1}
%define with_mythzoneminder %{?_without_mythzoneminder: 0} %{!?_without_mythzoneminder:  1}
%define with_mythnetvision  %{?_without_mythnetvision:  0} %{!?_without_mythnetvision:   1}

################################################################################

Source0:   http://www.mythtv.org/mc/mythtv-%{version}.tar.bz2
Source1:   http://www.mythtv.org/mc/mythplugins-%{version}.tar.bz2
Source10:  PACKAGE-LICENSING
Source101: mythbackend.sysconfig
Source102: mythbackend.init
Source103: mythtv.logrotate
Source104: mythbackend.service
Source106: mythfrontend.png
Source107: mythfrontend.desktop
Source108: mythtv-setup.png
Source109: mythtv-setup.desktop
Source110: mysql.txt

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

################################################################################
# Python setup

%if %{with_python}
%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%{!?python_version: %define python_version %(%{__python} -c 'import sys; print sys.version.split(" ")[0]')}
%endif

################################################################################

# Global MythTV and Shared Build Requirements

%if %{with_systemd}
# Use systemd
BuildRequires:  systemd-units
Requires(post): systemd-units
Requires(preun): systemd-units
Requires(postun): systemd-units
%else
# Use SysV
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
%endif

BuildRequires:  desktop-file-utils
BuildRequires:  freetype-devel >= 2
BuildRequires:  gcc-c++
BuildRequires:  mysql-devel >= 5
BuildRequires:  qt-webkit-devel
BuildRequires:  qt-devel >= 4.5
BuildRequires:  phonon-devel

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
BuildRequires:  xorg-x11-drv-intel-devel
BuildRequires:  xorg-x11-drv-openchrome-devel
%endif

# OpenGL video output and vsync support
BuildRequires:  libGL-devel, libGLU-devel

# Misc A/V format support
BuildRequires:  fftw-devel >= 3
BuildRequires:  flac-devel >= 1.0.4
BuildRequires:  gsm-devel
BuildRequires:  lame-devel
BuildRequires:  libdca-devel
BuildRequires:  libdvdnav-devel
BuildRequires:  libdvdread-devel >= 0.9.4
# nb: libdvdcss will be dynamically loaded if installed
BuildRequires:  libfame-devel >= 0.9.0
BuildRequires:  libogg-devel
BuildRequires:  libtheora-devel
BuildRequires:  libvorbis-devel >= 1.0
BuildRequires:  mjpegtools-devel >= 1.6.1
BuildRequires:  taglib-devel >= 1.5
BuildRequires:  x264-devel
BuildRequires:  xvidcore-devel >= 0.9.1

# Audio framework support
BuildRequires:  alsa-lib-devel
BuildRequires:  arts-devel
BuildRequires:  jack-audio-connection-kit-devel
%if %{with_pulseaudio}
BuildRequires:  pulseaudio-libs-devel
%endif

# Video support, formerly MythVideo
Requires:       perl(XML::Simple)

# Perl Bindings
Requires:       perl(IO::Socket::INET6)
BuildRequires:  perl(IO::Socket::INET6)

# Need dvb headers to build in dvb support
BuildRequires: kernel-headers

# FireWire cable box support
BuildRequires:  libavc1394-devel
BuildRequires:  libiec61883-devel
BuildRequires:  libraw1394-devel

%if %{with_vdpau}
BuildRequires: libvdpau-devel
%endif

%if %{with_vaapi}
BuildRequires: libva-devel
%endif

%if %{with_crystalhd}
BuildRequires: libcrystalhd-devel
%endif

# API Build Requirements

%if %{with_perl}
BuildRequires:  perl
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Config)
BuildRequires:  perl(Exporter)
BuildRequires:  perl(Fcntl)
BuildRequires:  perl(File::Copy)
BuildRequires:  perl(Sys::Hostname)
BuildRequires:  perl(DBI)
BuildRequires:  perl(HTTP::Request)
BuildRequires:  perl(Net::UPnP::QueryResponse)
BuildRequires:  perl(Net::UPnP::ControlPoint)
%endif

%if %{with_php}
%endif

%if %{with_python}
BuildRequires:  python-devel
BuildRequires:  MySQL-python
%endif

# Plugin Build Requirements

%if %{with_plugins}

%if %{with_mythgallery}
BuildRequires:  libexif-devel >= 0.6.9
%endif

%if %{with_mythgame}
BuildRequires:  zlib-devel
%endif

%if %{with_mythmusic}
BuildRequires:  libcdaudio-devel >= 0.99.6
BuildRequires:  cdparanoia-devel
%endif

%if %{with_mythnews}
%endif

BuildRequires: ncurses-devel

%if %{with_mythweather}
Requires:       mythweather      >= %{version}
BuildRequires:  perl(XML::Simple)
Requires:       perl(XML::Simple)
Requires:       perl(LWP::Simple)
BuildRequires:  perl(DateTime::Format::ISO8601)
Requires:       perl(DateTime::Format::ISO8601)
BuildRequires:  perl(XML::XPath)
Requires:       perl(XML::XPath)
BuildRequires:  perl(Date::Manip)
Requires:       perl(Date::Manip)
BuildRequires:  perl(Image::Size)
Requires:       perl(Image::Size)
BuildRequires:  perl(SOAP::Lite)
Requires:       perl(SOAP::Lite)
BuildRequires:  perl(JSON)
Requires:       perl(JSON)
%endif

%if %{with_mythzoneminder}
%endif

%if %{with_mythnetvision}
BuildRequires:  python-pycurl
BuildRequires:  python-lxml
BuildRequires:  python-oauth
%endif

%endif

################################################################################
# Requirements for the mythtv meta package

Requires:  mythtv-libs        = %{version}-%{release}
Requires:  mythtv-backend     = %{version}-%{release}
Requires:  mythtv-base-themes = %{version}-%{release}
Requires:  mythtv-common      = %{version}-%{release}
Requires:  mythtv-docs        = %{version}-%{release}
Requires:  mythtv-frontend    = %{version}-%{release}
Requires:  mythtv-setup       = %{version}-%{release}
Requires:  perl-MythTV        = %{version}-%{release}
Requires:  php-MythTV         = %{version}-%{release}
Requires:  python-MythTV      = %{version}-%{release}

Requires:  mythplugins        = %{version}-%{release}
Requires:  mythtv-themes      = %{version}

Requires:  mysql-server >= 5, mysql >= 5
# XMLTV is not yet packaged for rpmfusion
#Requires: xmltv

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

%package libs
Summary:   Library providing mythtv support
Group:     System Environment/Libraries
Provides:  libmyth = %{version}-%{release}
Obsoletes: libmyth < %{version}-%{release}

Requires:  freetype >= 2
Requires:  lame
Requires:  qt4 >= 4.5
Requires:  qt4-MySQL

%description libs
Common library code for MythTV and add-on modules (development)
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

################################################################################

%package devel
Summary:   Development files for mythtv
Group:     Development/Libraries
Provides:  libmyth-devel = %{version}-%{release}
Obsoletes: libmyth-devel < %{version}-%{release}

Requires:  mythtv-libs = %{version}-%{release}

Requires:  freetype-devel >= 2
Requires:  mysql-devel >= 5
Requires:  qt4-devel >= 4.5
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
Requires:  xorg-x11-drv-intel-devel
Requires:  xorg-x11-drv-openchrome-devel
%endif

# OpenGL video output and vsync support
Requires:  libGL-devel, libGLU-devel

# Misc A/V format support
Requires:  fftw-devel >= 3
Requires:  flac-devel >= 1.0.4
Requires:  gsm-devel
Requires:  lame-devel
Requires:  libdca-devel
Requires:  libdvdnav-devel
Requires:  libdvdread-devel >= 0.9.4
Requires:  libfame-devel >= 0.9.0
Requires:  libogg-devel
Requires:  libtheora-devel
Requires:  libvorbis-devel >= 1.0
Requires:  mjpegtools-devel >= 1.6.1
Requires:  taglib-devel >= 1.5
Requires:  x264-devel
Requires:  xvidcore-devel >= 0.9.1

# Audio framework support
Requires:  alsa-lib-devel
Requires:  arts-devel
Requires:  jack-audio-connection-kit-devel
%if %{with_pulseaudio}
Requires:  pulseaudio-libs-devel
%endif

# Need dvb headers for dvb support
Requires:  kernel-headers

# FireWire cable box support
Requires:  libavc1394-devel
Requires:  libiec61883-devel
Requires:  libraw1394-devel

%if %{with_vdpau}
Requires: libvdpau-devel
%endif

%if %{with_vaapi}
Requires: libva-devel
%endif

%if %{with_crystalhd}
Requires: libcrystalhd-devel
%endif

%description devel
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
Requires:  mplayer
Requires:  python-imdb
Requires:  python-MythTV = %{version}-%{release}
Obsoletes: mythcontrols
Obsoletes: mythvideo
Obsoletes: mythdvd

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
Requires:   wget
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
Requires:  wget

%description setup
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains only the setup software for configuring the
mythtv backend.

################################################################################

%package common
Summary: Common components needed by multiple other MythTV components
Group: Applications/Multimedia
# mythphone is now DOA, but we need this for upgrade path preservation.
Provides: mythphone = %{version}-%{release}
Obsoletes: mythphone < %{version}-%{release}
# same deal for mythflix
Provides: mythflix = %{version}-%{release}
Obsoletes: mythflix < %{version}-%{release}

%description common
MythTV provides a unified graphical interface for recording and viewing
television programs.  Refer to the mythtv package for more information.

This package contains components needed by multiple other MythTV components.

################################################################################

%package -n mythffmpeg
Summary: MythTV build of FFmpeg
Group: Applications/Multimedia

%description -n mythffmpeg
Several MythTV utilities interact with FFmpeg, which changes its parameters
often enough to make it a hassle to support the variety of versions used by
MythTV users.  This is a snapshot of the FFmpeg code so that MythTV utilities
can interact with a known verion.

################################################################################

%if %{with_perl}

%package -n perl-MythTV
Summary:        Perl bindings for MythTV
Group:          Development/Languages
# Wish we could do this:
#BuildArch:      noarch

Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(DBD::mysql)
Requires:       perl(Net::UPnP)
Requires:       perl(Net::UPnP::ControlPoint)

%description -n perl-MythTV
Provides a perl-based interface to interacting with MythTV.

%endif

################################################################################

%if %{with_php}

%package -n php-MythTV
Summary:        PHP bindings for MythTV
Group:          Development/Languages
# Wish we could do this:
#BuildArch:      noarch

%description -n php-MythTV
Provides a PHP-based interface to interacting with MythTV.

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
Requires:  mythweather    = %{version}-%{release}
Requires:  mythgallery    = %{version}-%{release}
Requires:  mythgame       = %{version}-%{release}
Requires:  mythnews       = %{version}-%{release}
Requires:  mythbrowser    = %{version}-%{release}
Requires:  mytharchive    = %{version}-%{release}
Requires:  mythzoneminder = %{version}-%{release}
Requires:  mythnetvision  = %{version}-%{release}

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

%description -n mytharchive
MythArchive is a new plugin for MythTV that lets you create DVDs from
your recorded shows, video files and any video files available on
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
#package -n mythgame-emulators
#Summary:   Meta-package requiring emulators for game types mythgame knows about
#Group:     Applications/Multimedia
#Requires:  mythgame = %{version}-%{release}
# Multi Arcade Machine Emulator, Amiga, Atari 2600
#Requires:  sdlmame
#Requires:  e-uae
#Requires:  stella
# Nintendo, Super Nintendo, Nintendo 64
#Requires:  fceultra
#Requires:  zsnes
#Requires:  mupen64, mupen64-ricevideo
# Sega Genesis, Sega Master System, Game Gear
#Requires:  gens
#Requires:  dega-sdl
#Requires:  osmose
# TurboGraphx 16 (and others)
#Requires:  mednafen

#description -n mythgame-emulators
#Meta-package requiring emulators for game types mythgame knows about.

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
%if %{with_mythweather}

%package -n mythweather
Summary:   A MythTV module that displays a weather forecast
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}
Requires:  perl(XML::SAX::Base)

%description -n mythweather
A MythTV module that displays a weather forecast.

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
%if %{with_mythnetvision}

%package -n mythnetvision
Summary:   A MythTV module for Internet video on demand
Group:     Applications/Multimedia
Requires:  mythtv-frontend-api = %{mythfeapiver}
Requires:  mythbrowser = %{version}-%{release}
Requires:  python-MythTV = %{version}-%{release}
Requires:  python-pycurl
Requires:  python >= 2.5
# This is packaged in adobe's yum repo
Requires:  flash-plugin

%description -n mythnetvision
A MythTV module that supports searching and browsing of Internet video
on demand content.

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
         find \( -name 'configure' -o -name '*pro' -o -name 'Makefile' \) -exec sed -r -i -e 's,/lib\b,/%{_lib},g' {} \+
#        grep -rlZ '/lib/' . | xargs -r0 sed -i -e 's,/lib/,/%{_lib}/,g'
#        grep -rlZ '/lib$' . | xargs -r0 sed -i -e 's,/lib$,/%{_lib},'
#        grep -rlZ '/lib ' . | xargs -r0 sed -i -e 's,/lib ,/%{_lib} ,g'
    fi

##### MythTV

cd mythtv

# Set the mythtv --version string
    cat > EXPORTED_VERSION <<EOF
SOURCE_VERSION=%{vers_string}
BRANCH=%{branch}
EOF

# Delete any git control files
    find . -name .git\* -exec rm {} \+
# Drop execute permissions on contrib bits, since they'll be %doc
    find contrib/ -type f -exec chmod -x "{}" \;
# And drop execute bit on theme html files
    chmod -x themes/default/htmls/*.html

# Nuke Windows and Mac OS X build scripts
    rm -rf contrib/Win32 contrib/OSX

# Put perl bits in the right place and set opt flags
    sed -i -e 's#perl Makefile.PL#%{__perl} Makefile.PL INSTALLDIRS=vendor OPTIMIZE="$RPM_OPT_FLAGS"#' \
        bindings/perl/Makefile

# Install other source files
    cp -a %{SOURCE10} %{SOURCE101} %{SOURCE102} %{SOURCE103} .
    cp -a %{SOURCE106} %{SOURCE107} %{SOURCE108} %{SOURCE109} .

# Prevent all of those nasty installs to ../../../../../bin/whatever
#    echo "QMAKE_PROJECT_DEPTH = 0" >> mythtv.pro
#    echo "QMAKE_PROJECT_DEPTH = 0" >> settings.pro
#    chmod 644 settings.pro

# We also need Xv libs to build XvMCNVIDIA
    sed -i -e 's,VENDOR_XVMC_LIBS="-lXvMCNVIDIA",VENDOR_XVMC_LIBS="-lXvMCNVIDIA -lXv",' configure

# Fix the default video directory so it points to something more standard
    sed -i -e 's,/share/Movies/dvd,%{_localstatedir}/lib/mythtv/dvd,' libs/libmythmetadata/globals.cpp

# Add execute bits to the various python helper scripts
    find programs/scripts/metadata -name '*.py' -exec chmod +x "{}" \;

# Fix /mnt/store -> /var/lib/mythtv
    sed -i -e's,/mnt/store,%{_localstatedir}/lib/mythtv,' libs/libmythbase/storagegroup.cpp

# On to mythplugins
cd ..

##### MythPlugins
%if %{with_plugins}

cd mythplugins

# Delete any git control files
    find . -name .git\* -exec rm {} \+

# And back to the compile root
cd ..

%endif

################################################################################

%build

# First, we build MythTV
cd mythtv

# Similar to 'percent' configure, but without {_target_platform} and
# {_exec_prefix} etc... MythTV no longer accepts the parameters that the
# configure macro passes, so we do this manually.
./configure \
    --prefix=%{_prefix}                         \
    --libdir=%{_libdir}                         \
    --libdir-name=%{_lib}                       \
    --mandir=%{_mandir}                         \
    --enable-pthreads                           \
    --enable-ffmpeg-pthreads                    \
    --enable-joystick-menu                      \
    --enable-audio-alsa                         \
    --enable-audio-oss                          \
    --enable-audio-jack                         \
    --enable-libfftw3                           \
    --enable-x11 --x11-path=%{_includedir}      \
    --enable-xv                                 \
    --enable-opengl-video                       \
    --enable-xrandr                             \
    --enable-lirc                               \
    --enable-ivtv                               \
    --enable-firewire                           \
    --enable-dvb                                \
    --enable-libmp3lame                         \
    --enable-libtheora --enable-libvorbis       \
    --enable-libx264                            \
    --enable-libxvid                            \
%if %{with_vdpau}
    --enable-vdpau                              \
%endif
%if %{with_vaapi}
    --enable-vaapi                              \
%endif
%if %{with_crystalhd}
    --enable-crystalhd                          \
%endif
%if !%{with_perl}
    --without-bindings=perl                     \
%endif
%if !%{with_php}
    --without-bindings=php                      \
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

# Insert rpm version-release for mythbackend --version output
    sed -i -e 's,###SOURCE_VERSION###,%{version}-%{release} (%_gitrev),' version.sh

# Make
    make %{?_smp_mflags}

# Prepare to build the plugins
    cd ..
    mkdir temp
    temp=`pwd`/temp
    make -C mythtv install INSTALL_ROOT=$temp
    export LD_LIBRARY_PATH=$temp%{_libdir}:$LD_LIBRARY_PATH

# Next, we build the plugins
%if %{with_plugins}
cd mythplugins

# Fix things up so they can find our "temp" install location for mythtv-libs
    echo "QMAKE_PROJECT_DEPTH = 0" >> settings.pro
    find . -name \*.pro \
        -exec sed -i -e "s,INCLUDEPATH += .\+/include/mythtv,INCLUDEPATH += $temp%{_includedir}/mythtv," {} \; \
        -exec sed -i -e "s,DEPLIBS = \$\${LIBDIR},DEPLIBS = $temp%{_libdir}," {} \; \
        -exec sed -i -e "s,\$\${PREFIX}/include/mythtv,$temp%{_includedir}/mythtv," {} \;
    echo "INCLUDEPATH -= \$\${PREFIX}/include" >> settings.pro
    echo "INCLUDEPATH -= \$\${SYSROOT}/\$\${PREFIX}/include" >> settings.pro
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
    %else
        --disable-mytharchive \
    %endif
    %if %{with_mythbrowser}
        --enable-mythbrowser \
    %else
        --disable-mythbrowser \
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
    %if %{with_mythweather}
        --enable-mythweather \
    %else
        --disable-mythweather \
    %endif
    %if %{with_mythzoneminder}
        --enable-mythzoneminder \
    %else
        --disable-mythzoneminder \
    %endif
    %if %{with_mythnetvision}
        --enable-mythnetvision \
    %else
        --disable-mythnetvision \
    %endif
        --enable-opengl \
        --enable-fftw

    make %{?_smp_mflags}

    cd ..
%endif

################################################################################

%install

# Clean
    rm -rf %{buildroot}

# First, install MythTV
cd mythtv

    make install INSTALL_ROOT=%{buildroot}

    ln -s mythtv-setup %{buildroot}%{_bindir}/mythtvsetup
    mkdir -p %{buildroot}%{_localstatedir}/lib/mythtv
    mkdir -p %{buildroot}%{_localstatedir}/cache/mythtv
    mkdir -p %{buildroot}%{_localstatedir}/log/mythtv
    mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
    %if %{with_systemd}
    mkdir -p %{buildroot}%{_unitdir}
    %else
    mkdir -p %{buildroot}%{_sysconfdir}/init.d
    %endif
    mkdir -p %{buildroot}%{_sysconfdir}/sysconfig
    mkdir -p %{buildroot}%{_sysconfdir}/mythtv

# Fix permissions on executable python bindings
#    chmod +x %{buildroot}%{python_sitelib}/MythTV/Myth*.py

# mysql.txt and other config/init files
    install -m 644 %{SOURCE110} %{buildroot}%{_sysconfdir}/mythtv/
    echo "# to be filled in by mythtv-setup" > %{buildroot}%{_sysconfdir}/mythtv/config.xml
    %if %{with_systemd}
    install -D -p -m 0644 %{SOURCE104} %{buildroot}%{_unitdir}/
    %else
    install -p -m 755 mythbackend.init %{buildroot}%{_sysconfdir}/init.d/mythbackend
    %endif
    install -p -m 644 mythbackend.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/mythbackend
    install -p -m 644 mythtv.logrotate  %{buildroot}%{_sysconfdir}/logrotate.d/mythtv

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

# Clean up some stuff we don't want to include
rm -f %{buildroot}%{_libdir}/libmythqjson.prl \
      %{buildroot}%{_libdir}/libmythzmq.la    \
      %{buildroot}%{_libdir}/pkgconfig/libmythzmq.pc

# MythPlugins
%if %{with_plugins}
cd mythplugins

    make install INSTALL_ROOT=%{buildroot}

%if %{with_mythmusic}
    mkdir -p %{buildroot}%{_localstatedir}/lib/mythmusic
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

# And back to the build/install root
    cd ..
%endif

################################################################################

%clean
rm -rf %{buildroot}

################################################################################

%post libs -p /sbin/ldconfig

%postun libs -p /sbin/ldconfig

%pre backend
# Add the "mythtv" user, with membership in the video group
/usr/sbin/useradd -c "mythtvbackend User" \
    -s /sbin/nologin -r -d %{_localstatedir}/lib/mythtv -G audio,video mythtv 2> /dev/null || :

%post backend
%if %{with_systemd}
if [ $1 -eq 1 ] ; then
    # Initial installation
    /bin/systemctl daemon-reload >/dev/null 2>&1 || :
fi
%else
/sbin/chkconfig --add mythbackend
%endif

%preun backend
%if %{with_systemd}
if [ $1 -eq 0 ] ; then
    # Package removal, not upgrade
    /bin/systemctl --no-reload disable mythbackend.service > /dev/null 2>&1 || :
    /bin/systemctl stop mythbackend.service > /dev/null 2>&1 || :
fi
%else
if [ $1 = 0 ]; then
    /sbin/service mythbackend stop > /dev/null 2>&1
    /sbin/chkconfig --del mythbackend
fi
%endif

%postun backend
%if %{with_systemd}
/bin/systemctl daemon-reload >/dev/null 2>&1 || :
if [ $1 -ge 1 ] ; then
    # Package upgrade, not uninstall
    /bin/systemctl try-restart mythbackend.service >/dev/null 2>&1 || :
fi
%else
if [ "$1" -ge "1" ] ; then
    /sbin/service mythbackend condrestart >/dev/null 2>&1 || :
fi
%endif

################################################################################

%files
%defattr(-,root,root,-)

%files docs
%defattr(-,root,root,-)
%doc mythtv/README* mythtv/UPGRADING
%doc mythtv/AUTHORS mythtv/COPYING mythtv/FAQ
%doc mythtv/database mythtv/keys.txt
%doc mythtv/contrib
%doc %{_datadir}/mythtv/fonts/*.txt
%doc mythtv/PACKAGE-LICENSING

%files common
%defattr(-,root,root,-)
%dir %{_sysconfdir}/mythtv
%dir %{_datadir}/mythtv
%config(noreplace) %{_sysconfdir}/mythtv/mysql.txt
%config(noreplace) %{_sysconfdir}/mythtv/config.xml
%{_bindir}/mythccextractor
%{_bindir}/mythcommflag
%{_bindir}/mythpreviewgen
%{_bindir}/mythtranscode
%{_bindir}/mythwikiscripts
%{_bindir}/mythmetadatalookup
%{_bindir}/mythutil
%{_bindir}/mythlogserver
%{_datadir}/mythtv/mythconverg*.pl
%dir %{_datadir}/mythtv/locales
%dir %{_datadir}/mythtv/metadata
%{_datadir}/mythtv/locales/*
%{_datadir}/mythtv/metadata/*
%dir %{_datadir}/mythtv/hardwareprofile
%{_datadir}/mythtv/hardwareprofile/*

%files backend
%defattr(-,root,root,-)
%{_bindir}/mythbackend
%{_bindir}/mythfilldatabase
%{_bindir}/mythjobqueue
%{_bindir}/mythmediaserver
%{_bindir}/mythreplex
%{_bindir}/mythhdhomerun_config
%{_datadir}/mythtv/MXML_scpd.xml
%{_datadir}/mythtv/backend-config/
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/lib/mythtv
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/cache/mythtv
%if %{with_systemd}
%{_unitdir}/mythbackend.service
%else
%{_sysconfdir}/init.d/mythbackend
%endif
%config(noreplace) %{_sysconfdir}/sysconfig/mythbackend
%config(noreplace) %{_sysconfdir}/logrotate.d/mythtv
%attr(-,mythtv,mythtv) %dir %{_localstatedir}/log/mythtv
%dir %{_datadir}/mythtv/internetcontent
%{_datadir}/mythtv/internetcontent/*
%dir %{_datadir}/mythtv/html
%{_datadir}/mythtv/html/*

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
%{_datadir}/mythtv/setup.xml
%{_bindir}/mythavtest
%{_bindir}/mythfrontend
%{_bindir}/mythlcdserver
%{_bindir}/mythscreenwizard
%{_bindir}/mythshutdown
%{_bindir}/mythwelcome
%dir %{_libdir}/mythtv
%dir %{_libdir}/mythtv/filters
%{_libdir}/mythtv/filters/*
%dir %{_libdir}/mythtv/plugins
%dir %{_datadir}/mythtv/i18n
%dir %{_datadir}/mythtv/fonts
%{_datadir}/mythtv/fonts/*.ttf
%{_datadir}/mythtv/fonts/*.otf
%{_datadir}/mythtv/i18n/mythfrontend_*.qm
%{_datadir}/applications/*mythfrontend.desktop
%{_datadir}/pixmaps/myth*.png
#%doc mythplugins/mythvideo/COPYING
#%doc mythplugins/mythvideo/README*
#%{_datadir}/mythtv/i18n/mythvideo_*.qm
#%{_datadir}/mythtv/video_settings.xml
#%{_datadir}/mythtv/videomenu.xml
#%{_localstatedir}/lib/mythvideo

%files base-themes
%defattr(-,root,root,-)
%dir %{_datadir}/mythtv/themes
%{_datadir}/mythtv/themes/*

%files libs
%defattr(-,root,root,-)
%{_libdir}/*.so.*

%files devel
%defattr(-,root,root,-)
%{_includedir}/*
%{_libdir}/*.so
%exclude %{_libdir}/*.a
%dir %{_datadir}/mythtv/build
%{_datadir}/mythtv/build/settings.pro

%files -n mythffmpeg
%defattr(-,root,root,-)
%{_bindir}/mythffmpeg
%{_bindir}/mythffprobe
%{_bindir}/mythffserver

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

%if %{with_php}
%files -n php-MythTV
%defattr(-,root,root,-)
%{_datadir}/mythtv/bindings/php/*
%endif

%if %{with_python}
%files -n python-MythTV
%defattr(-,root,root,-)
%dir %{python_sitelib}/MythTV/
%{_bindir}/mythpython
%{python_sitelib}/MythTV/*
%{python_sitelib}/MythTV-*.egg-info
%endif

%if %{with_plugins}
%files -n mythplugins
%defattr(-,root,root,-)
%doc mythplugins/COPYING

%if %{with_mytharchive}
%files -n mytharchive
%defattr(-,root,root,-)
%doc mythplugins/mytharchive/AUTHORS
%doc mythplugins/mytharchive/COPYING
%doc mythplugins/mytharchive/README
%doc mythplugins/mytharchive/TODO
%{_bindir}/mytharchivehelper
%{_libdir}/mythtv/plugins/libmytharchive.so
%{_datadir}/mythtv/archivemenu.xml
%{_datadir}/mythtv/archiveutils.xml
%{_datadir}/mythtv/mytharchive
%{_datadir}/mythtv/i18n/mytharchive_*.qm
%endif

%if %{with_mythbrowser}
%files -n mythbrowser
%defattr(-,root,root,-)
%doc mythplugins/mythbrowser/AUTHORS
%doc mythplugins/mythbrowser/COPYING
%doc mythplugins/mythbrowser/README
%{_libdir}/mythtv/plugins/libmythbrowser.so
%{_datadir}/mythtv/i18n/mythbrowser_*.qm
%endif

%if %{with_mythgallery}
%files -n mythgallery
%defattr(-,root,root,-)
%doc mythplugins/mythgallery/AUTHORS
%doc mythplugins/mythgallery/COPYING
%doc mythplugins/mythgallery/README
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
%dir %{_datadir}/mythtv/games
%{_datadir}/mythtv/games/*
%dir %{_datadir}/mame/screens
%dir %{_datadir}/mame/flyers
%{_datadir}/mythtv/game_settings.xml
%{_datadir}/mythtv/i18n/mythgame_*.qm

#files -n mythgame-emulators
#defattr(-,root,root,-)
#{_datadir}/mythtv/games/xmame
#{_datadir}/mame/screens
#{_datadir}/mame/flyers
%endif

%if %{with_mythmusic}
%files -n mythmusic
%defattr(-,root,root,-)
%doc mythplugins/mythmusic/AUTHORS
%doc mythplugins/mythmusic/COPYING
%doc mythplugins/mythmusic/README
%{_libdir}/mythtv/plugins/libmythmusic.so
%{_localstatedir}/lib/mythmusic
%{_datadir}/mythtv/mythmusic/streams.xml
%{_datadir}/mythtv/musicmenu.xml
%{_datadir}/mythtv/music_settings.xml
%{_datadir}/mythtv/i18n/mythmusic_*.qm
%endif

%if %{with_mythnews}
%files -n mythnews
%defattr(-,root,root,-)
%doc mythplugins/mythnews/AUTHORS
%doc mythplugins/mythnews/COPYING
%doc mythplugins/mythnews/README
%{_libdir}/mythtv/plugins/libmythnews.so
%{_datadir}/mythtv/mythnews
%{_datadir}/mythtv/i18n/mythnews_*.qm
%endif

%if %{with_mythweather}
%files -n mythweather
%defattr(-,root,root,-)
%doc mythplugins/mythweather/AUTHORS
%doc mythplugins/mythweather/COPYING
%doc mythplugins/mythweather/README
%{_libdir}/mythtv/plugins/libmythweather.so
%{_datadir}/mythtv/i18n/mythweather_*.qm
%{_datadir}/mythtv/weather_settings.xml
%dir %{_datadir}/mythtv/mythweather
%{_datadir}/mythtv/mythweather/*
%endif

%if %{with_mythzoneminder}
%files -n mythzoneminder
%defattr(-,root,root,-)
%{_libdir}/mythtv/plugins/libmythzoneminder.so
%{_datadir}/mythtv/zonemindermenu.xml
%{_bindir}/mythzmserver
%{_datadir}/mythtv/i18n/mythzoneminder_*.qm
%endif

%if %{with_mythnetvision}
%files -n mythnetvision
%defattr(-,root,root,-)
%doc mythplugins/mythnetvision/AUTHORS
%doc mythplugins/mythnetvision/ChangeLog
%doc mythplugins/mythnetvision/README
%{_bindir}/mythfillnetvision
%{_libdir}/mythtv/plugins/libmythnetvision.so
%{_datadir}/mythtv/mythnetvision
%{_datadir}/mythtv/netvisionmenu.xml
%{_datadir}/mythtv/i18n/mythnetvision_*.qm
%endif

%endif

################################################################################

%changelog
* Tue Jan 29 2013 Chris Petersen <cpetersen@mythtv.org> 0.27-0.1.git
- add mythscreenwizard, mythffserver, mythffprobe, mythhdhomerun_config

* Thu Aug 09 2012 Chris Petersen <cpetersen@mythtv.org> 0.26-0.1.git
- rename i810 driver BR to intel

* Fri Aug 06 2012 Chris Petersen <cpetersen@mythtv.org> 0.26-0.1.git
- Update logrotate config, rename from mythbackend to mythtv
- add mythmusic/streams.xml file

* Tue Jun 26 2012 Chris Petersen <cpetersen@mythtv.org> 0.26-0.1.git
- Fix lib -> lib64 replacement command to be more accurate and support mythzmq
- Add mythzmq stuff

* Wed Jun 13 2012 Chris Petersen <cpetersen@mythtv.org> 0.26-0.1.git
- no more mythffplay
- include *.otf fonts

* Wed Jun 06 2012 Chris Petersen <cpetersen@mythtv.org> 0.26-0.1.git
- Systemd is now on by default
- Disable crystalhd by default

* Sun Mar 25 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Enable libx264, which we now have to specify explicitly

* Thu Mar 22 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove mythmessage

* Wed Mar 12 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove .git* meta data files before installing

* Wed Mar 07 2012 Richard Shaw <hobbes1069@gmail.com> - 0.25-0.1.git
- Update spec to allow for use of systemd for mythbackend.
- Add systemd service file.
- Remove conditionals for Fedora versions less than 14 since it's EOL.
- Remove obsolete options for xvmc.
- Add mythtv user to audio group as well for realtime audio support.

* Wed Feb 22 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Add perl(IO::Socket::INET6) req for perl bindings

* Sun Jan 29 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove mythmusic configure options that no longer exist
- Fix storage group location from /mnt/store to /var/lib/mythtv

* Wed Dec 28 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove official docs (now on the wiki)
- Mythweather needs perl(JSON)

* Sat Oct 06 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Add mythutil

* Thu Jul 21 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Add mythccextractor

* Wed Jul 08 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Add mythmetadatalookup
- Move other metadata files into -common

* Wed Jun 08 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Merge MythVideo into the frontend
- Add mythmediaserver to the backend package

* Wed May 30 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- remove directfb compile options

* Wed Apr 20 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- add backend-config directory

* Thu Mar 10 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- add hardware profile scripts to mythtv-common
- add html server static files to mythbackend

* Tue Feb 22 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove xvmc-vld, opengl-vsync
- Rename mythtvosd to mythmessage

* Thu Feb 17 2011 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Require Qt >= 4.5

* Tue Dec 28 2010 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Add PHP bindings
- Fix my email address in changelogs

* Wed Dec 15 2010 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Fedora 11 minimum requirement
- Split out mythweb
- Update for Git
- Add mythffmpeg

* Sat Aug 28 2010 Jarod Wilson <jarod@wilsonet.com> 0.24-0.1.svn
- Fix up perl bindings
- Enable crystalhd support
- Remove obsolete libfaad2 bits

* Sat Aug 14 2010 Jarod Wilson <jarod@wilsonet.com> 0.24-0.1.svn
- Resync with RPM Fusion spec, now builds cleanly again on a
  Fedora 13 host as of svn revision 25638

* Thu Aug 05 2010 Chris Petersen <cpetersen@mythtv.org> 0.24-0.1.svn
- Add mythpreviewgen

* Sun Jun 20 2010 Chris Petersen <cpetersen@mythtv.org> 0.24-0.1.svn
- Add new MythWeather perl dep
- Rearrange file lists for new/deleted/moved installed files

* Sun Jun 06 2010 Chris Petersen <cpetersen@mythtv.org> 0.24-0.1.svn
- Remove deprecated MythMovies
- Add support for some new files
- Move share/internetcontent to the backend subpackage

* Sun May 23 2010 Chris Petersen <cpetersen@mythtv.org> 0.24-0.1.svn
- Bump version number
- Remove legacy --enable-x configure flags
- Add python builddeps for mythnetvision
- Add new mythnetvision files
- Rename libmyth to mythtv-libs
- Add perl build deps

* Sat Jan 23 2010 Chris Petersen <cpetersen@mythtv.org> 0.23-0.1.svn
- Add MythNetVision requirement for MythBrowser

* Wed Jan 13 2010 Harry Orenstein <hospam@verizon.net> 0.23-0.1.svn
- Add MythNetVision

* Sat Dec 05 2009 Chris Petersen <cpetersen@mythtv.org> 0.23-0.1.svn
- Remove MythFlix

* Sat Nov 07 2009 Chris Petersen <cpetersen@mythtv.org> 0.23-0.1.svn
- New tags for trunk

* Mon Nov 02 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.6.svn
- Compensate for moved tvdb script directory
- Make php chmod fix more robust
- Remove --enable-audio-arts because it doesn't exist anymore

* Tue Oct 06 2009 Jarod Wilson <jarod@wilsonet.com> 0.22-0.5.svn
- Remove more obsolete BR
- Switch from fftw v2 to fftw v3
- Add mythmovies and mythzoneminder i18n files
- Bump taglib version requires to >= 1.5

* Fri Oct 02 2009 Jarod Wilson <jarod@wilsonet.com> 0.22-0.5.svn
- Remove libmad BR, its not used at all any longer

* Sat Sep 19 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.5.svn
- Re-remove non-GPL libfaac options (not really used by MythTV anyway)

* Fri Sep 18 2009 Jarod Wilson <jarod@wilsonet.com> 0.22-0.4.svn
- Resync with build fixes from RPM Fusion
- Remove BR: on xorg-x11-drv-nvidia-devel, just use XvMC wrapper
- Rename option to build VDPAU support, since its not nVidia-specific
- Add assorted cleanups from James Twyford (via trac ticket #7090)

* Thu Aug 13 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Add XML::Simple requirement for mythvideo (for tmdb.pl)
- Remove now-deprecated call for XvMCNVIDIA_dynamic

* Mon Jul 27 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Rename xvmcnvidia stuff to just nvidia, and add vdpau options to it

* Sat Jul 25 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Remove all a52 references because ./configure no longer accepts even "disable"
- Remove non-GPL libfaac options (not really used by MythTV anyway)

* Sun Jun 28 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Remove xvmc-opengl references that were removed in r20723
- Add requirement for pulseaudio-libs-devel now that some distros are requiring it

* Sat Jun 20 2009 Jarod Wilson <jarod@wilsonet.com> 0.22-0.1.svn
- Drop kdelibs3-devel BR for MythBrowser, its been ported to qt4 now
- Add Requires: php-process (needed for posix_get*() functions)

* Mon May 04 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Require Qt >= 4.4

* Fri Apr 10 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Disable liba52 options because they seem to cause no end of trouble
  with AC3 recordings from hdhomerun/firewire.

* Wed Mar 04 2009 Jarod Wilson <jarod@wilsonet.com> 0.22-0.1.svn
- Resync with RPM Fusion spec to pick up packaging fix-ups and
  kill off the defunct mythphone plugin

* Wed Jan 21 2009 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Remove mythcontrols, which no longer exists

* Sat Nov 01 2008 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
- Add a --without plugins option to disable all plugin builds

* Tue Oct 28 2008 Chris Petersen <cpetersen@mythtv.org> 0.22-0.1.svn
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
