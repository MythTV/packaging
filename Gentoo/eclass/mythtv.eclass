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
				REPO="mythtv"
				MY_PN="mythtv";;
      mythtv-bindings)
                REPO="mythtv"
                MY_PN="mythtv";;
	       *)
				REPO="mythtv"
				MY_PN="mythplugins";;
esac

# _pre is from SVN trunk while _p and _beta are from SVN ${MY_PV}-fixes
# TODO: probably ought to do something smart if the regex doesn't match anything
[[ "${PV}" =~ (_alpha|_beta|_pre|_rc|_p)([0-9]+) ]] || {
	# assume a tagged release
	MYTHTV_REV="v${PV}"
}

HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI="https://github.com/MythTV/${REPO}/tarball/${MYTHTV_REV} -> mythtv-${PV}.tar.gz"
S="${WORKDIR}/MythTV-${REPO}-${MYTHTV_SREV}/${MY_PN}"
