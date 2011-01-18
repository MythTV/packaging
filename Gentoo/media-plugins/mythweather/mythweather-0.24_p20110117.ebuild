# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythweather/mythweather-0.21_p17719.ebuild,v 1.1 2008/08/12 23:56:11 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24-110-g3f991fa"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="3f991fa41a030c585661782d638868e88c64f5dd"
MYTHTV_SREV="3f991fa"

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
