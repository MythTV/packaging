# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="bd4b084473bace157ea"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="760c8db330134fbd4b084473bace157ea778aa27"
MYTHTV_SREV="760c8db"

inherit mythtv-plugins eutils

DESCRIPTION="Video player module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

RDEPEND="media-tv/mythtv[python]
        sys-block/eject"
DEPEND=""

src_prepare() {
	if use experimental
	then
		true;
	fi
}

src_install() {
	for file in `find ${S} -type f -name *.py`
	do
		chmod +x $file
    done

	mythtv-plugins_src_install
}

pkg_postinst() {
	elog "MythVideo can use any media player to playback files, since"
	elog "it's a setting in the setup menu."
	elog
	elog "MythTV also has an 'Internal' player you can use, which will"
	elog "be the default for new installs.  If you want to use it,"
	elog "set the player to 'Internal' (note spelling & caps)."
	elog
	elog "Otherwise, you can install mplayer, xine or any other video"
	elog "player and use that instead by configuring the player to use."
}
