# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=2
PYTHON_DEPEND="python? 2:2.6"
MYTHTV_VERSION="v0.25.1-58-g1d41f74"
MYTHTV_BRANCH="fixes/0.25"
MYTHTV_REV="1d41f74720f0c89ef73e25fe7586e33caf946802"
MYTHTV_SREV="1d41f74"

inherit flag-o-matic multilib eutils qt4-r2 mythtv toolchain-funcs python
inherit linux-info

DESCRIPTION="Homebrew PVR project"
SLOT="0"
KEYWORDS="amd64 x86 ~ppc"

IUSE_VIDEO_CARDS="video_cards_nvidia"
IUSE_INPUT_DEVICES="input_devices_joystick"
IUSE="altivec ass autostart \
dvb dvd bluray \
ieee1394 lcd lirc cec \
alsa jack pulseaudio \
debug hls raop fftw \
perl python \
vdpau vaapi crystalhd \
xmltv xvid \
${IUSE_VIDEO_CARDS} \
${IUSE_INPUT_DEVICES}
"

SDEPEND="
	>=media-sound/lame-3.93.1
	virtual/glu
	virtual/mysql
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXv
	x11-libs/libXrandr
	x11-libs/libXxf86vm
	x11-libs/qt-core:4[qt3support]
	x11-libs/qt-gui:4[qt3support]
	x11-libs/qt-sql:4[qt3support,mysql]
	x11-libs/qt-opengl:4[qt3support]
	x11-libs/qt-webkit:4
	alsa? ( >=media-libs/alsa-lib-0.9 )
	ass? ( media-libs/libass )
	bluray? (	dev-libs/libxml2
			media-libs/libbluray )
	cec? (	dev-libs/libcec )
	dvb? (	media-libs/libdvb
		virtual/linuxtv-dvb-headers )
	fftw? (	sci-libs/fftw )
	hls? (	>=media-libs/x264-0.0.20100605
		media-libs/libvpx
		media-sound/lame 
		media-libs/faac )
	ieee1394? (	>=sys-libs/libraw1394-1.2.0
			>=sys-libs/libavc1394-0.5.3
			>=media-libs/libiec61883-1.0.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	lcd? ( app-misc/lcdproc )
	lirc? ( app-misc/lirc )
	perl? (	dev-perl/DBD-mysql
		dev-perl/Net-UPnP
		dev-perl/LWP-Protocol-https
		dev-perl/HTTP-Message
		dev-perl/IO-Socket-INET6
		>=dev-perl/libwww-perl-5 )
	pulseaudio? ( media-sound/pulseaudio )
	python? (	dev-python/mysql-python
			dev-python/lxml
			dev-python/urlgrabber )
	raop? (	net-dns/avahi[mdnsresponder-compat] )
	vaapi? ( x11-libs/libva )
	vdpau? ( x11-libs/libvdpau )
	xvid? ( >=media-libs/xvid-1.1.0 )
	!media-tv/mythtv-bindings
	!media-plugins/mythvideo
	!x11-themes/mythtv-themes
	"

RDEPEND="${SDEPEND}
	media-fonts/corefonts
	media-fonts/dejavu
	media-fonts/liberation-fonts
	>=media-libs/freetype-2.0
	x11-apps/xinit
	autostart? (	net-dialup/mingetty
			x11-wm/evilwm
			x11-apps/xset )
	dvd? ( media-libs/libdvdcss )
	video_cards_nvidia? (	x11-drivers/nvidia-drivers 
				vdpau? ( >=x11-drivers/nvidia-drivers-256 ) )
	xmltv? ( >=media-tv/xmltv-0.5.43 )
	"

DEPEND="${SDEPEND}
	x11-proto/xineramaproto
	x11-proto/xf86vidmodeproto
	x11-apps/xinit
	dev-lang/yasm
	"

MYTHTV_GROUPS="video,audio,tty,uucp"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	enewuser mythtv -1 /bin/bash /home/mythtv ${MYTHTV_GROUPS}
	usermod -a -G ${MYTHTV_GROUPS} mythtv
}

src_prepare() {
# upstream wants the revision number in their version.cpp
# since the subversion.eclass strips out the .svn directory
# svnversion in MythTV's build doesn't work
	sed -e "s#\${SOURCE_VERSION}#${MYTHTV_VERSION}#g" \
		-e "s#\${BRANCH}#${MYTHTV_BRANCH}#g" \
		-i "${S}"/version.sh


# Perl bits need to go into vender_perl and not site_perl
	sed -e "s:pure_install:pure_install INSTALLDIRS=vendor:" \
		-i "${S}"/bindings/perl/Makefile

	epatch "${FILESDIR}/fixLdconfSandbox.25.patch"

#	if use experimental
#	then
#		epatch "${FILESDIR}/optimizeMFDBClearingBySource-3.patch"
#		epatch "${FILESDIR}/jobQueueIgnoreDeletedRecgroup.patch"
#
#		if has_version ">=virtual/mysql-5.5"
#		then
#			epatch "${FILESDIR}/mythtv-8585-use_proper_ISO_SQL_format_in_database_logging.patch"
#		fi
#
#		true
#	fi
}

src_configure() {
	local myconf="--prefix=/usr"
	myconf="${myconf} --mandir=/usr/share/man"
	myconf="${myconf} --libdir-name=$(get_libdir)"

	myconf="${myconf} --enable-pic"

	use alsa       || myconf="${myconf} --disable-audio-alsa"
	use altivec    || myconf="${myconf} --disable-altivec"
	use jack       || myconf="${myconf} --disable-audio-jack"
	use pulseaudio || myconf="${myconf} --disable-audio-pulseoutput"

	myconf="${myconf} $(use_enable dvb)"
	myconf="${myconf} $(use_enable ieee1394 firewire)"
	myconf="${myconf} $(use_enable lirc)"
	myconf="${myconf} --dvb-path=/usr/include"
	myconf="${myconf} --enable-xrandr"
	myconf="${myconf} --enable-xv"
	myconf="${myconf} --enable-x11"

	if use perl && use python
	then
		myconf="${myconf} --with-bindings=perl,python"
	elif use perl
	then
		myconf="${myconf} --without-bindings=python"
		myconf="${myconf} --with-bindings=perl"
	elif use python
	then
		myconf="${myconf} --without-bindings=perl"
		myconf="${myconf} --with-bindings=python"
	else
		myconf="${myconf} --without-bindings=perl,python"
	fi

	if use python
	then
		myconf="${myconf} --python=$(PYTHON)"
	fi

	if use debug
	then
		myconf="${myconf} --compile-type=debug"
	else
		myconf="${myconf} --compile-type=profile"
		myconf="${myconf} --enable-proc-opt"
	fi

	if use vdpau && use video_cards_nvidia
	then
		myconf="${myconf} --enable-vdpau"
	fi

	if use vaapi
	then
		myconf="${myconf} --enable-vaapi"
	fi
	if use crystalhd
	then
		myconf="${myconf} --enable-crystalhd"
	fi

	myconf="${myconf} $(use_enable xvid libxvid)"

	if use hls
	then
		myconf="${myconf} --enable-libmp3lame"
		myconf="${myconf} --enable-libx264"
		myconf="${myconf} --enable-libvpx"
		myconf="${myconf} --enable-libfaac"
		myconf="${myconf} --enable-nonfree"
	fi

	use input_devices_joystick || myconf="${myconf} --disable-joystick-menu"
	use cec || myconf="${myconf} --disable-libcec"

	myconf="${myconf} --enable-symbol-visibility"

	has distcc ${FEATURES} || myconf="${myconf} --disable-distcc"
	has ccache ${FEATURES} || myconf="${myconf} --disable-ccache"

# let MythTV come up with our CFLAGS. Upstream will support this
	strip-flags
	CFLAGS=""
	CXXFLAGS=""

	chmod +x ./external/FFmpeg/version.sh

	einfo "Running ./configure ${myconf}"
	chmod +x ./configure
	./configure ${myconf} || die "configure died"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	make INSTALL_ROOT="${D}" install || die "install failed"
	dodoc AUTHORS FAQ UPGRADING  README

	insinto /usr/share/mythtv/database
	doins database/*

	exeinto /usr/share/mythtv

	newinitd "${FILESDIR}"/mythbackend-0.25.rc mythbackend
	newconfd "${FILESDIR}"/mythbackend-0.25.conf mythbackend

	dodoc keys.txt docs/*.{txt,pdf}
	dohtml docs/*.html

	keepdir /etc/mythtv
	chown -R mythtv "${D}"/etc/mythtv
	keepdir /var/log/mythtv
	chown -R mythtv "${D}"/var/log/mythtv


	insinto /etc/logrotate.d
	newins "${FILESDIR}"/mythtv.25.logrotate.d mythtv

	insinto /etc/cron.daily
	insopts -m0544
	newins "${FILESDIR}"/runlogcleanup mythtv.logcleanup

	dodir /usr/share/mythtv/bin
	insinto /usr/share/mythtv/bin
	insopts -m0555
	doins "${FILESDIR}"/logcleanup.py
    

	insinto /usr/share/mythtv/contrib
	insopts -m0644
	doins -r contrib/*

	dobin "${FILESDIR}"/runmythfe

	if use autostart
	then
		dodir /etc/env.d/
		echo 'CONFIG_PROTECT="/home/mythtv/"' > "${D}"/etc/env.d/95mythtv

		insinto /home/mythtv
		newins "${FILESDIR}"/bash_profile .bash_profile
		newins "${FILESDIR}"/xinitrc.25 .xinitrc
	fi

	for file in `find ${D} -type f -name \*.py \
						-o -type f -name \*.sh \
						-o -type f -name \*.pl`;
	do
		chmod a+x $file;
	done
}

pkg_preinst() {
	export CONFIG_PROTECT="${CONFIG_PROTECT} ${ROOT}/home/mythtv/"
}

pkg_postinst() {
	elog "Want mythfrontend to start automatically?"
	elog "Set USE=autostart. Details can be found at:"
	elog "http://www.mythtv.org/wiki/Gentoo_Autostart"

	elog
	elog "To always have MythBackend running and available run the following:"
	elog "rc-update add mythbackend default"
	elog
	ewarn "Your recordings folder must be owned by the user 'mythtv' now"
	ewarn "chown -R mythtv /path/to/store"

	if use autostart
	then
		elog
		elog "Please add the following to your /etc/inittab file at the end of"
		elog "the TERMINALS section"
		elog "c8:2345:respawn:/sbin/mingetty --autologin mythtv tty8"
	fi

}

pkg_info() {
	"${ROOT}"/usr/bin/mythfrontend --version
}

pkg_config() {
	echo "Creating mythtv MySQL user and mythconverg database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	"${ROOT}"/usr/bin/mysql -u root -p < "${ROOT}"/usr/share/mythtv/database/mc.sql
}

