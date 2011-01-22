# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.25pre-927-gfc146d5"
MYTHTV_BRANCH="master"
MYTHTV_REV="fc146d5f311e872b63cf16f75ff337e5f70a2621"
MYTHTV_SREV="fc146d5"

inherit mythtv-plugins

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND=""
DEPEND=""

src_install() {
	mythtv-plugins_src_install
}

