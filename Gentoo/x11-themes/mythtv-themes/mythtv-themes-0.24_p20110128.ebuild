# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

MYTHTV_VERSION="v0.24-127-gbb5e107"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="1c84b134711163ef613c8d8567baf29fd31c41a6"
MYTHTV_SREV="1c84b13"

EAPI=2
inherit qt4 mythtv

DESCRIPTION="A collection of themes for the MythTV project."
HOMEPAGE="http://www.mythtv.org/wiki/Category:Themes"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="x11-libs/qt-core:4
	=media-tv/mythtv-${MY_PV}*"

src_configure() {
	sh ./configure --prefix=/usr || die "configure died"
}

src_compile() {
	eqmake4 myththemes.pro || die "qmake failed"
}

src_install() {
	einstall INSTALL_ROOT="${D}" || die "install failed"

	# With thanks to MarcT for automatically installing the fonts.
	# This theme doesn't exist past this commit.
	if [ -a "${S}/Arclight" ] ; then
		dodir /usr/share/fonts/Arclight
		cp -r "${S}/Arclight/CartoGothicStd-Book.otf" "${D}/usr/share/fonts/Arclight"
		cp -r "${S}/Arclight/League Gothic.otf" "${D}/usr/share/fonts/Arclight"
	fi
}

pkg_postinst() {

        if [[ ${ROOT} == / ]]; then
                ebegin "Updating fontcache"
                fc-cache -f /usr/share/fonts
                eend $?
        fi
}
