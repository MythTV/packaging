# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythtv/mythtv-0.22_alpha18535.ebuild,v 1.4 2008/10/09 20:52:54 cardoe Exp $

EAPI=2
PYTHON_DEPEND="2"
MYTHTV_VERSION="v0.24.1-58-g760c8db"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="760c8db330134fbd4b084473bace157ea778aa27"
MYTHTV_SREV="760c8db"

inherit flag-o-matic multilib eutils qt4 mythtv toolchain-funcs python

DESCRIPTION="Homebrew PVR project language bindings"
SLOT="0"
KEYWORDS="amd64 x86 ~ppc"

IUSE="perl python"

RDEPEND="
	perl?   (   dev-lang/perl
                dev-perl/DBD-mysql
                dev-perl/DateManip
                dev-perl/Net-UPnP )
	python? ( >=dev-lang/python-2.6
                dev-python/mysql-python
                dev-python/lxml )
	!media-tv/mythtv"

DEPEND="${RDEPEND}"

src_configure() {
    echo "PREFIX=/usr" > "${S}/config.mak"
    echo "PYTHON=/usr/bin/python" >> "${S}/config.mak"
    use perl   && echo "CONFIG_BINDINGS_PERL=yes" >> "${S}/config.mak"
    use python && echo "CONFIG_BINDINGS_PYTHON=yes" >> "${S}/config.mak"

    S="${S}/bindings"
    cp "${FILESDIR}/Makefile" "${S}/Makefile"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall INSTALL_ROOT="${D}" || die "install failed"

	for file in `find ${D} -type f -name \*.py`; do chmod a+x $file; done
	for file in `find ${D} -type f -name \*.sh`; do chmod a+x $file; done
	for file in `find ${D} -type f -name \*.pl`; do chmod a+x $file; done
}

#pkg_postinst() {
#
#}

