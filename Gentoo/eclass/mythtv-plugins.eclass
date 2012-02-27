# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv-plugins.eclass,v 1.35 2009/07/19 04:18:58 cardoe Exp $
#
# @ECLASS: mythtv-plugins.eclass
# @AUTHOR: Doug Goldstein <cardoe@gentoo.org>
# @MAINTAINER: Doug Goldstein <cardoe@gentoo.org>
# @BLURB: Installs MythTV plugins along with patches from the release-${PV}-fixes branch
#

# NOTE: YOU MUST INHERIT EITHER qt3 or qt4 IN YOUR PLUGIN!

inherit mythtv multilib versionator

# Extra configure options to pass to econf
MTVCONF=${MTVCONF:=""}

SLOT="0"
IUSE="${IUSE} profile debug experimental"

	if [[ -z $MYTHTV_NODEPS ]]
	then
		RDEPEND="${RDEPEND}
				=media-tv/mythtv-${MY_PV}*"
		DEPEND="${DEPEND}
				=media-tv/mythtv-${MY_PV}*
				>=sys-apps/sed-4"
	fi


	if use debug
	then
		myconf="${myconf} --compile-type=debug"
		FEATURES="$FEATURES nostrip"
		RESTRICT="strip"
	elif use profile
	then
		myconf="${myconf} --compile-type=profile"
	else
		myconf="${myconf} --compile-type=release"
#		myconf="${myconf} --enable-proc-opt"
	fi

mythtv-plugins_pkg_setup() {
# List of available plugins (needs to include ALL of them in the tarball)
	MYTHPLUGINS=""
	MYTHPLUGINS="${MYTHPLUGINS} mytharchive"
	MYTHPLUGINS="${MYTHPLUGINS} mythbrowser"
	MYTHPLUGINS="${MYTHPLUGINS} mythgallery"
	MYTHPLUGINS="${MYTHPLUGINS} mythgame"
	MYTHPLUGINS="${MYTHPLUGINS} mythmusic"
	MYTHPLUGINS="${MYTHPLUGINS} mythnetvision"
	MYTHPLUGINS="${MYTHPLUGINS} mythnews"
	if [[ ${MY_PV} == "0.24.1" ]]; then
		MYTHPLUGINS="${MYTHPLUGINS} mythvideo"
	fi
	MYTHPLUGINS="${MYTHPLUGINS} mythweather"
	MYTHPLUGINS="${MYTHPLUGINS} mythzoneminder"
}

mythtv-plugins_src_prepare() {
	sed -e 's!PREFIX = /usr/local!PREFIX = /usr!' \
	-i 'settings.pro' || die "fixing PREFIX to /usr failed"

	sed -e "s!QMAKE_CXXFLAGS_RELEASE = -O3 -march=pentiumpro -fomit-frame-pointer!QMAKE_CXXFLAGS_RELEASE = ${CXXFLAGS}!" \
	-i 'settings.pro' || die "Fixing QMake's CXXFLAGS failed"

	sed -e "s!QMAKE_CFLAGS_RELEASE = \$\${QMAKE_CXXFLAGS_RELEASE}!QMAKE_CFLAGS_RELEASE = ${CFLAGS}!" \
	-i 'settings.pro' || die "Fixing Qmake's CFLAGS failed"

	find "${S}" -name '*.pro' -exec sed -i \
		-e "s:\$\${PREFIX}/lib/:\$\${PREFIX}/$(get_libdir)/:g" \
		-e "s:\$\${PREFIX}/lib$:\$\${PREFIX}/$(get_libdir):g" \
	{} \;
}

mythtv-plugins_src_configure() {
	cd "${S}"

	if hasq ${PN} ${MYTHPLUGINS} ; then
		for x in ${MYTHPLUGINS} ; do
			if [[ ${PN} == ${x} ]] ; then
				myconf="${myconf} --enable-${x}"
			else
				myconf="${myconf} --disable-${x}"
			fi
		done
	else
		die "Package ${PN} is unsupported"
	fi

	chmod +x configure
	econf ${myconf} ${MTVCONF}
}

mythtv-plugins_src_compile() {
	qmake mythplugins.pro || die "eqmake4 failed"
	emake || die "make failed to compile"
}

mythtv-plugins_src_install() {
	if hasq ${PN} ${MYTHPLUGINS}
	then
		cd "${S}"/${PN}
	else
		die "Package ${PN} is unsupported"
	fi

	einstall INSTALL_ROOT="${D}"
	for doc in AUTHORS COPYING FAQ UPGRADING ChangeLog README
	do
		test -e "${doc}" && dodoc ${doc}
	done
}

EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_compile src_install
