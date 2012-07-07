# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"
PYTHON_DEPEND="2:2.6"
MYTHTV_VERSION="v0.26pre-800-gbde24c5"
MYTHTV_BRANCH="master"
MYTHTV_REV="bde24c5cd3050252687890f9261e4706b513acd3"
MYTHTV_SREV="bde24c5"

inherit mythtv-plugins python

DESCRIPTION="Module for MythTV."
IUSE=""
KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND="
	|| ( media-tv/mythtv[python] media-tv/mythtv-bindings[python] )
	dev-python/imaging
	"

DEPEND="
	media-video/mjpegtools[png]
	media-video/dvdauthor
	app-cdr/dvd+rw-tools
	virtual/cdrtools
	media-video/transcode
	"

src_install() {
	mythtv-plugins_src_install
}

