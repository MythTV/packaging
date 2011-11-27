# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythweather/mythweather-0.21_p17719.ebuild,v 1.1 2008/08/12 23:56:11 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24.1-110-gf5fd11f"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="f5fd11fa54141cab0239f15947faa3a41a2e9cef"
MYTHTV_SREV="f5fd11f"

inherit mythtv-plugins

DESCRIPTION="Weather forecast module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

DEPEND="dev-perl/DateManip
	dev-perl/ImageSize
	dev-perl/SOAP-Lite
	dev-perl/XML-Simple
	dev-perl/XML-Parser
	dev-perl/XML-SAX
	dev-perl/DateTime-Format-ISO8601
	dev-perl/XML-XPath
	"
