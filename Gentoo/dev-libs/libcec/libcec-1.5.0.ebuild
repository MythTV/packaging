# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=2
PYTHON_DEPEND="2"
LIBCEC_VERSION="1.5.0-0-g0f1b44d"
LIBCEC_BRANCH="master"
LIBCEC_REV="0f1b44de471ac33cba9aa8f73bc174a17f606fdd"
LIBCEC_SREV="0f1b44d"

inherit mythtv

DESCRIPTION="Library for interfacing Pulse-Eight CEC adapters"
SLOT="0"
KEYWORDS="~amd64 ~x86"

SDEPEND=" || ( sys-devel/autoconf sys-devel/automake ) "
DEPEND="${SDEPEND}"

src_configure() {
	autoreconf -vif || die "automake failed"

	local myconf="--prefix=/usr"

	./configure ${myconf} || die "configure failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall || die "install failed"
}

