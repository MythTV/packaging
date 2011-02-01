# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24-144-g8bf1a3a"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="8bf1a3a492d5b0b9c152fd4a3d97e31adcde28af"
MYTHTV_SREV="8bf1a3a"

inherit mythtv-plugins

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

RDEPEND=""
DEPEND=""

src_install() {
	mythtv-plugins_src_install
}

