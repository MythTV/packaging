# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv.eclass,v 1.20 2009/11/16 07:59:47 cardoe Exp $
#
# @ECLASS: mythtv.eclass
# @AUTHOR: Doug Goldstein <cardoe@gentoo.org>
# @MAINTAINER: Doug Goldstein <cardoe@gentoo.org>
# @BLURB: Downloads the MythTV source packages and any patches from the fixes branch
#

inherit versionator

# Release version
MY_PV="${PV%_*}"

# what product do we want
case "${PN}" in
	mythtv)
		PROJECT="MythTV"
		REPO="mythtv"
		MY_PN="mythtv"
		S="${WORKDIR}/${PROJECT}-${REPO}-${MYTHTV_SREV}/${MY_PN}"
		;;
	mythtv-bindings)
		PROJECT="MythTV"
		REPO="mythtv"
		MY_PN="mythtv"
		S="${WORKDIR}/${PROJECT}-${REPO}-${MYTHTV_SREV}/${MY_PN}"
		;;
	mythweb)
		PROJECT="MythTV"
		REPO="mythweb"
		MY_PN="mythweb"
		S="${WORKDIR}/${PROJECT}-${REPO}-${MYTHTV_SREV}/"
		;;
	nuvexport)
		PROJECT="MythTV"
		REPO="nuvexport"
		MY_PN="nuvexport"
		MYTHTV_REV="$NUVEXPORT_REV"
		S="${WORKDIR}/${PROJECT}-${REPO}-${NUVEXPORT_SREV}/"
		;;
	libcec)
		PROJECT="Pulse-Eight"
		REPO="libcec"
		MY_PN="libcec"
		MYTHTV_REV="${LIBCEC_REV}"
		S="${WORKDIR}/${PROJECT}-${REPO}-${LIBCEC_SREV}/"
		;;
	*)
		PROJECT="MythTV"
		REPO="mythtv"
		MY_PN="mythplugins"
		S="${WORKDIR}/${PROJECT}-${REPO}-${MYTHTV_SREV}/${MY_PN}"
		;;
esac

# _pre is from SVN trunk while _p and _beta are from SVN ${MY_PV}-fixes
# TODO: probably ought to do something smart if the regex doesn't match anything
[[ "${PV}" =~ (_alpha|_beta|_pre|_rc|_p)([0-9]+) ]] || {
	[[ "${PROJECT}" == "MythTV" ]] && {
		# assume a tagged release
		MYTHTV_REV="v${PV}"
	}

	[[ "${PROJECT}" == "Pulse-Eight" ]] && {
		MYTHTV_REV="${REPO}-${PV}"
	}
}

HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI="https://github.com/${PROJECT}/${REPO}/tarball/${MYTHTV_REV} -> ${REPO}-${PV}.tar.gz"

