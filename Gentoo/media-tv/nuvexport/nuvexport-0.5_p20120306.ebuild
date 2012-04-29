# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

NUVEXPORT_BRANCH="master"
NUVEXPORT_REV="ad7e20af6e8961c4eea3b79b8022f86c6bf1b9d4"
NUVEXPORT_SREV="ad7e20a"
REPO="nuvexport"

inherit mythtv

DESCRIPTION="Export recordings from MythTV"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+faac mplayer +xvid"

DEPEND=""
RDEPEND=">=dev-lang/perl-5.6
	dev-perl/DBI
	dev-perl/DBD-mysql
	dev-perl/DateManip
    >=media-video/mjpegtools-1.6.2
	media-sound/sox[encode]
	media-libs/id3lib
	mplayer? ( media-video/mplayer[encode,mp3,faac?,xvid?] )
	>=media-tv/mythtv-0.25_pre20120223[perl,hls,xvid?]"

src_install() {
	einstall || die "einstall failed"
}
