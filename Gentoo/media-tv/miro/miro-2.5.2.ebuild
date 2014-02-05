# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"

inherit eutils multilib distutils confutils fdo-mime versionator

MY_P="${P/m/M}"
DESCRIPTION="The free open-source video platform."
HOMEPAGE="http://www.getmiro.com/"
SRC_URI="http://ftp.osuosl.org/pub/pculture.org/miro/src/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"

IUSE="libnotify gstreamer xine"

RDEPEND=">=dev-python/pygtk-2.10
	|| ( >=dev-lang/python-2.5[berkdb,sqlite]
	     >=dev-python/pysqlite-2 )
	|| ( dev-python/gnome-python
		 dev-python/gconf-python )
	>=dev-python/gtkmozembed-python-2.19.1-r11
	x11-base/xorg-server	
	dev-python/dbus-python
	>=net-libs/xulrunner-1.9
	>=dev-python/pyrex-0.9.6.4
	media-gfx/imagemagick
	|| ( =net-libs/rb_libtorrent-0.13
		>=net-libs/rb_libtorrent-0.14[python] )
	dev-python/bsddb3
	libnotify? ( dev-python/notify-python dev-libs/poppler-glib )
	gstreamer? ( media-libs/gstreamer dev-python/gst-python media-libs/gst-plugins-good media-libs/gst-plugins-bad media-libs/gst-plugins-ugly media-plugins/gst-plugins-faad sci-libs/cblas-reference )
	xine? ( media-libs/xine-lib[aac] )"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}/platform/gtk-x11"


pkg_postinst() {
	ebeep 5
	ewarn "The dbus service must be installed and running for this package to work"
	elog
	ewarn "The gstreamer or xine USE flag must be selected for this package to work"
	elog 
	elog "It is ok to select the gstreamer and xine USE flag at the same time"
	elog
	elog "To switch between gstreamer and xine playback open video in the top menu."
	elog "Than go into options. Than go into playback and select gstreamer or xine."
	elog "Miro must be restarted for a change in playback option to take effect." 
}
