# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24-177-g316718a"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="316718a140ed5c498b8b84d1c6d0c11fc2838580"
MYTHTV_SREV="316718a"

inherit mythtv-plugins

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

RDEPEND=""
DEPEND=""

src_install() {
	mythtv-plugins_src_install
}

