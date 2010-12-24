# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/ivtv/ivtv-1.0.2.ebuild,v 1.6 2007/08/31 14:14:49 beandog Exp $

inherit eutils linux-mod

DESCRIPTION="ivtv driver utils for Hauppauge PVR PCI cards"
HOMEPAGE="http://www.ivtvdriver.org"
SRC_URI="http://dl.ivtvdriver.org/ivtv/archive/1.0.x/ivtv-${PV}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RDEPEND="|| ( >=sys-fs/udev-103 sys-apps/hotplug )"
DEPEND="app-arch/unzip"
PDEPEND="media-tv/ivtv-firmware"

MY_S="${WORKDIR}/ivtv-${PV}"

src_compile() {
	cd "${MY_S}"
	if [ $ARCH == 'amd64' ]
	then
	 ARCH='x86_64'
	fi
	emake INCDIR="${KV_DIR}/include" || die "failed to build utils "
}

src_install() {
	cd "${MY_S}/utils"
	make DESTDIR="${D}" PREFIX="/usr" install || die "failed to install utils"
	dobin perl/*.pl

	cd "${S}"
	dodoc README* doc/* utils/README.X11 ChangeLog* utils/perl/README.ptune
}
