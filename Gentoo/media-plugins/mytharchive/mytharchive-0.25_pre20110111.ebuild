# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.25pre-846-g173d0d7"
MYTHTV_BRANCH="master"
MYTHTV_REV="173d0d760ea688b5d1a6c8328c850aa47b787177"
MYTHTV_SREV="173d0d7"

inherit mythtv-plugins

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND=""
DEPEND=""

src_install() {
	mythtv-plugins_src_install
}

