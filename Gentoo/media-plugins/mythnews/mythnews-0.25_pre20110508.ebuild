# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.25pre-1937-g3c2f214"
MYTHTV_BRANCH="master"
MYTHTV_REV="3c2f214633f14a0e02cd6e4b1dd87ae597bd477a"
MYTHTV_SREV="3c2f214"

inherit mythtv-plugins

DESCRIPTION="Module for MythTV."
IUSE="+exif +opengl raw"
KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND="exif? ( >=media-libs/libexif-0.6.10 )
         media-libs/tiff
         opengl? ( virtual/opengl )
         raw? ( media-gfx/dcraw )"
DEPEND="${RDEPEND}"
MTVCONF="$(use_enable exif) $(use_enable exif new-exif) $(use_enable raw dcraw)
$(use_enable opengl)"

src_install() {
	mythtv-plugins_src_install
}

