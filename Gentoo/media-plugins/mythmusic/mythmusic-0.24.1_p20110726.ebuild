# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythmusic/mythmusic-0.21_p17821.ebuild,v 1.1 2008/08/01 16:43:37 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24.1-58-g760c8db"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="760c8db330134fbd4b084473bace157ea778aa27"
MYTHTV_SREV="760c8db"

inherit mythtv-plugins flag-o-matic toolchain-funcs eutils

DESCRIPTION="Music player module for MythTV."
IUSE="aac cdr fftw libvisual projectm opengl sdl"
KEYWORDS="amd64 x86 ~ppc"

RDEPEND=">=media-sound/cdparanoia-3.9.8
	>=media-libs/libmad-0.15.1b
	>=media-libs/libvorbis-1.0
	>=media-libs/libcdaudio-0.99.6
	>=media-libs/flac-1.1.2
	>=media-libs/taglib-1.4
	media-gfx/dcraw
	fftw? ( sci-libs/fftw )
	opengl? ( virtual/opengl )
	sdl? ( >=media-libs/libsdl-1.2.5 )
	cdr? ( virtual/cdrtools )
	libvisual? ( =media-libs/libvisual-0.4*
				 media-plugins/libvisual-plugins
				 >=media-libs/libsdl-1.2.5
				 )
	projectm? ( media-plugins/libvisual-projectm
				>=media-libs/libsdl-1.2.5 
				=media-libs/libvisual-0.4*
				)"

DEPEND="${RDEPEND}"

#pkg_config() {
#}

MTVCONF="$(use_enable fftw) $(use_enable sdl) $(use_enable opengl) $(use_enable libvisual)"
