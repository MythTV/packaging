# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24.1-0-gb5a3805"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="b5a3805b92624dc91c0289162600ad7129f291e6"
MYTHTV_SREV="b5a3805"

inherit mythtv-plugins eutils

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

RDEPEND=""
DEPEND="x11-libs/qt-webkit:4"

src_prepare() {
	if use experimental
	then
		true
	fi
}

src_install() {
	mythtv-plugins_src_install
}
