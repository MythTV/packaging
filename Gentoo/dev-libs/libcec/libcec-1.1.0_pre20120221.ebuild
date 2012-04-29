# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=2
PYTHON_DEPEND="2"
LIBCEC_VERSION="1.1.0-462-gabec5f1"
LIBCEC_BRANCH="master"
LIBCEC_REV="abec5f17e29ff169574dfd16a54380a19a8fc39b"
LIBCEC_SREV="abec5f1"

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

