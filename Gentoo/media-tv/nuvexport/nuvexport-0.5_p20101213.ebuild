# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

NUVEXPORT_REV="03a753d74908b6bdb7aefea73794f35433f0e1a9"
NUVEXPORT_SREV="03a753d"
REPO="nuvexport"

DESCRIPTION="Export recordings from MythTV"
HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI="https://github.com/MythTV/${REPO}/tarball/${NUVEXPORT_REV} -> ${REPO}-${PV}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+faac +ffmpeg +mp3 mplayer +x264 +xvid"

DEPEND=""
RDEPEND=">=dev-lang/perl-5.6
	dev-perl/DBI
	dev-perl/DBD-mysql
	dev-perl/DateManip
	ffmpeg? (
		>=media-video/mjpegtools-1.6.2
		media-sound/sox[encode]
	)
	mp3? ( media-libs/id3lib )
	mplayer? ( media-video/mplayer[encode,faac?,mp3?,xvid?] )
	>=media-tv/mythtv-0.24[perl]"

S="${WORKDIR}/MythTV-${REPO}-${NUVEXPORT_SREV}/"

src_install() {
	einstall || die "einstall failed"
}
