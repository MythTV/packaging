# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/mythweb/mythweb-0.23.1_p25396.ebuild,v 1.1 2010/07/27 03:14:08 cardoe Exp $

EAPI=2

MYTHTV_VERSION="v0.24-127-gbb5e107"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="10e990ed6a13b1245205b97b3b6580f0d794f7ac"
MYTHTV_SREV="10e990e"

inherit mythtv webapp depend.php

DESCRIPTION="PHP scripts intended to manage MythTV from a web browser."
IUSE=""
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="dev-lang/php[json,mysql,session,posix]
	|| ( <dev-lang/php-5.3[spl,pcre] >=dev-lang/php-5.3 )
	dev-perl/DBI
	dev-perl/DBD-mysql
	dev-perl/Net-UPnP"

DEPEND="${RDEPEND}
		app-arch/unzip"

need_httpd_cgi
need_php5_httpd

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	webapp_src_preinst

	cd "${S}"
	dodoc README INSTALL

	dodir "${MY_HTDOCSDIR}"/data

	insinto "${MY_HTDOCSDIR}"
	doins -r [[:lower:]]*

	webapp_configfile "${MY_HTDOCSDIR}"/mythweb.conf.{apache,lighttpd}

	webapp_serverowned "${MY_HTDOCSDIR}"/data

	webapp_postinst_txt en "${FILESDIR}"/postinstall-en-0.21.txt

	webapp_src_install

	fperms 755 /usr/share/webapps/mythweb/${PV}/htdocs/mythweb.pl
}
