# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythtv/mythtv-0.22_alpha18535.ebuild,v 1.4 2008/10/09 20:52:54 cardoe Exp $

EAPI=2
PYTHON_DEPEND="2:2.6"
MYTHTV_VERSION="v0.25.1-58-g1d41f74"
MYTHTV_BRANCH="fixes/0.25"
MYTHTV_REV="1d41f74720f0c89ef73e25fe7586e33caf946802"
MYTHTV_SREV="1d41f74"

inherit flag-o-matic multilib eutils qt4 mythtv toolchain-funcs python

DESCRIPTION="Homebrew PVR project language bindings"
SLOT="0"
KEYWORDS="amd64 x86 ~ppc"

IUSE="perl python php"

RDEPEND="
	perl? (	dev-lang/perl
		dev-perl/DBD-mysql
		dev-perl/DateManip
		dev-perl/LWP-Protocol-https
		dev-perl/HTTP-Message
		dev-perl/Net-UPnP )
	python? ( >=dev-lang/python-2.6
		dev-python/mysql-python
		dev-python/lxml )
	php? (	>=dev-lang/php-5.3
		dev-php/PEAR-Net_Socket
		dev-php/PEAR-MDB2_Driver_mysqli )
	!media-tv/mythtv
	"

DEPEND="${RDEPEND}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_configure() {
	echo "PREFIX=/usr" > "${S}/config.mak"
	echo "PYTHON=$(PYTHON)" >> "${S}/config.mak"
	use perl   && echo "CONFIG_BINDINGS_PERL=yes" >> "${S}/config.mak"
	use python && echo "CONFIG_BINDINGS_PYTHON=yes" >> "${S}/config.mak"
	use php    && echo "CONFIG_BINDINGS_PHP=yes" >> "${S}/config.mak"

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

