# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythmusic/mythmusic-0.21_p17821.ebuild,v 1.1 2008/08/01 16:43:37 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.25-rc-106-gf73dbda"
MYTHTV_BRANCH="master"
MYTHTV_REV="f73dbda4d44e3694c1374c2332ddfb80e2e7f355"
MYTHTV_SREV="f73dbda"

inherit mythtv-plugins flag-o-matic toolchain-funcs eutils

DESCRIPTION="Music player module for MythTV."
IUSE="aac cdr fftw projectm opengl"
KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND="
	>=media-libs/libmad-0.15.1b
	>=media-libs/libvorbis-1.0
	>=media-libs/flac-1.1.2
	>=media-libs/taglib-1.4
	dev-libs/libcdio
	media-gfx/dcraw
	fftw? ( sci-libs/fftw )
	opengl? ( virtual/opengl )
	cdr? ( virtual/cdrtools )
	projectm? ( media-plugins/libvisual-projectm
				>=media-libs/libsdl-1.2.5 
				=media-libs/libvisual-0.4*
				)
	"

DEPEND="${RDEPEND}"

#pkg_config() {
#}

MTVCONF="$(use_enable fftw) $(use_enable opengl)"
