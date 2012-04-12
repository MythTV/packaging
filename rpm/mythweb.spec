#
# Specfile for building MythWeb RPM from a git checkout.
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

################################################################################

# The vendor name we should attribute the aforementioned entries to
%define desktop_vendor  mythtv

# Git Revision number and branch ID
%define _gitrev 0.0.rc.68.g74d4a29
%define branch master

#
# Basic descriptive tags for this package:
#
Name:           mythweb
Summary:        The web interface to MythTV
URL:            http://www.mythtv.org/
Group:          Applications/Multimedia

# Version/Release info
Version: 0.25
%if "%{branch}" == "master"
Release: 0.1.git.%{_gitrev}%{?dist}
%else
Release: 1%{?dist}
%endif

# The primary license is GPLv2+, but bits are borrowed from a number of
# projects... For a breakdown of the licensing, see PACKAGE-LICENSING.
License: GPLv2+ and LGPLv2+ and LGPLv2 and (GPLv2 or QPL) and (GPLv2+ or LGPLv2+)

Requires:  php-MythTV >= %{version}
Requires:  httpd >= 1.3.26
Requires:  php >= 5.3
Requires:  php-mysql
Requires:  php-process

################################################################################

Source:    http://www.mythtv.org/mc/mythweb-%{version}.tar.bz2
Source401: mythweb.conf

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

################################################################################

%description
The web interface to MythTV.

################################################################################

%prep
%setup -c -q

# Delete any git control files
    find . -name .git\* -exec rm {} \+

# Fix up permissions for MythWeb
    chmod -R g-w mythweb/*

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
%doc mythweb/README
%config(noreplace) %{_sysconfdir}/httpd/conf.d/mythweb.conf
%defattr(-,apache,apache,0775)
%dir %{_datadir}/mythweb
%{_datadir}/mythweb/*

################################################################################

%changelog
* Wed Mar 12 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Remove .git* meta data files before installing

* Sun Mar 03 2012 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Make this package compile

* Mon Dec 13 2010 Chris Petersen <cpetersen@mythtv.org> 0.25-0.1.git
- Split MythWeb package off of MythTV spec
