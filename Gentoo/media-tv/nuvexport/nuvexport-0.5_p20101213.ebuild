# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

NUVEXPORT_BRANCH="master"
NUVEXPORT_REV="c18508f20448077762d23ab9207c5eb643324dc0"
NUVEXPORT_SREV="c18508f"
REPO="nuvexport"

inherit mythtv

DESCRIPTION="Export recordings from MythTV"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+faac mplayer +x264 +xvid"

DEPEND=""
RDEPEND=">=dev-lang/perl-5.6
	dev-perl/DBI
	dev-perl/DBD-mysql
	dev-perl/DateManip
    >=media-video/mjpegtools-1.6.2
	media-sound/sox[encode]
	media-libs/id3lib
	mplayer? ( media-video/mplayer[encode,mp3,faac?,xvid?] )
	>=media-tv/mythtv-0.25_pre20110408[perl,xvid?,x264?]"

src_install() {
	einstall || die "einstall failed"
}
