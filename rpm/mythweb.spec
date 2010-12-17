#
# Specfile for building MythTV and MythPlugins RPMs from a git checkout.
#
# by:   Chris Petersen <cpetersen@mythtv.org>
#       Jarod Wilson <jwilson@mythtv.org>
#
#  Modified/Extended from the great (non-svn based) work of:
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
# --with directfb           Enable directfb support
#
# The following options are enabled by default.  Use these options to disable:
#
# --without vdpau           Disable VDPAU support
# --without crystalhd       Disable Crystal HD support
# --without xvmc            Disable XvMC support
# --without perl            Disable building of the perl bindings
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
# --without mythvideo
# --without mythweather
# --without mythzoneminder
# --without mythweb
#

################################################################################

# A list of which applications we want to put into the desktop menu system
%define desktop_applications mythfrontend mythtv-setup

# The vendor name we should attribute the aforementioned entries to
%define desktop_vendor  xris

# SVN Revision number and branch ID
%define _svnrev r27303
%define branch trunk

#
# Basic descriptive tags for this package:
#
Name:           mythtv
Summary:        A digital video recorder (DVR) application
URL:            http://www.mythtv.org/
Group:          Applications/Multimedia

# Version/Release info
Version: 0.24
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
%define with_proc_opt      %{?_with_proc_opt:      1} %{!?_with_proc_opt:      0}

# Set "--with debug" to enable MythTV debug compile mode
%define with_debug         %{?_with_debug:         1} %{?!_with_debug:         0}

# The following options are enabled by default.  Use --without to disable them
%define with_vdpau         %{?_without_vdpau:      0} %{?!_without_vdpau:      1}
%define with_crystalhd     %{?_without_crystalhd:  0} %{?!_without_crystalhd:  1}
%define with_xvmc          %{?_without_xvmc:       0} %{?!_without_xvmc:       1}
%define with_perl          %{?_without_perl:       0} %{!?_without_perl:       1}
%define with_python        %{?_without_python:     0} %{!?_without_python:     1}
%define with_pulseaudio    %{?_without_pulseaudio: 0} %{!?_without_pulseaudio: 1}

# The following options are disabled by default.  Use --with to enable them
%define with_directfb      %{?_with_directfb:      1} %{!?_with_directfb:      0}

# All plugins get built by default, but you can disable them as you wish
%define with_plugins        %{?_without_plugins:        0} %{!?_without_plugins:         1}
%define with_mytharchive    %{?_without_mytharchive:    0} %{!?_without_mytharchive:     1}
%define with_mythbrowser    %{?_without_mythbrowser:    0} %{!?_without_mythbrowser:     1}
%define with_mythgallery    %{?_without_mythgallery:    0} %{!?_without_mythgallery:     1}
%define with_mythgame       %{?_without_mythgame:       0} %{!?_without_mythgame:        1}
%define with_mythmusic      %{?_without_mythmusic:      0} %{!?_without_mythmusic:       1}
%define with_mythnews       %{?_without_mythnews:       0} %{!?_without_mythnews:        1}
%define with_mythvideo      %{?_without_mythvideo:      0} %{!?_without_mythvideo:       1}
%define with_mythweather    %{?_without_mythweather:    0} %{!?_without_mythweather:     1}
%define with_mythweb        %{?_without_mythweb:        0} %{!?_without_mythweb:         1}
%define with_mythzoneminder %{?_without_mythzoneminder: 0} %{!?_without_mythzoneminder:  1}
%define with_mythnetvision  %{?_without_mythnetvision:  0} %{!?_without_mythnetvision:   1}

################################################################################

Source0:   http://www.mythtv.org/mc/mythtv-%{version}.tar.bz2
Source1:   http://www.mythtv.org/mc/mythplugins-%{version}.tar.bz2
Source10:  PACKAGE-LICENSING
Source401: mythweb.conf

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

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

%package -n mythweb
Summary:   The web interface to MythTV
Group:     Applications/Multimedia
Requires:  httpd >= 1.3.26
Requires:  php >= 5.1
Requires:  php-mysql
Requires:  php-process

%description -n mythweb
The web interface to MythTV.

################################################################################

%prep
%setup -q -c -a 1

# Fix up permissions for MythWeb
    cd 
    chmod -R g-w mythweb/*
    cd ..

# Remove unwanted execute bits from php mythweb files
    find mythweb/ -name '*.php' -exec chmod -x {} \+


################################################################################

%build

# Nothing to do here for MythWeb

################################################################################

%install

# Clean
    rm -rf %{buildroot}

# Install (manually)
    mkdir -p %{buildroot}%{_datadir}/mythweb
    cp -a * %{buildroot}%{_datadir}/mythweb/
    mkdir -p %{buildroot}%{_datadir}/mythweb/{image_cache,php_sessions}

    mkdir -p %{buildroot}%{_sysconfdir}/httpd/conf.d
    cp %{SOURCE401} %{buildroot}%{_sysconfdir}/httpd/conf.d/

# drop .htaccess file, settings handled in the above
    rm -f %{buildroot}%{_datadir}/mythweb/data/.htaccess

################################################################################

%clean
rm -rf %{buildroot}

################################################################################

%files
%defattr(-,root,root,-)
%doc mythplugins-%{version}/mythweb/README
%config(noreplace) %{_sysconfdir}/httpd/conf.d/mythweb.conf
%defattr(-,apache,apache,0775)
%dir %{_datadir}/mythweb
%{_datadir}/mythweb/*

################################################################################

%changelog
* Mon Dec 13 2010 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Split MythWeb package off of MythTV spec
