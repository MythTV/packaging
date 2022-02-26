#!/bin/sh
export LD_LIBRARY_PATH=debian/tmp/usr/lib
export LD_PRELOAD=''
VERSION=$(dpkg-parsechangelog -SVersion| sed 's/.*://;')
generate()
{
	help2man --no-info -n "$1" --version-string="$VERSION" --no-discard-stderr "$2" > debian/man/`basename $2`.1
}
mkdir -p debian/man
generate "MythTV AV Tester" debian/tmp/usr/bin/mythavtest
generate "MythTV Commercial Flagger" debian/tmp/usr/bin/mythcommflag
generate "MythTV FFMpeg Probe Debugger" debian/tmp/usr/bin/mythffprobe
generate "MythTV Frontend (Real)"       debian/tmp/usr/bin/mythfrontend.real
generate "MythTV LCD Server"     debian/tmp/usr/bin/mythlcdserver
generate "MythTV Preview Generator" debian/tmp/usr/bin/mythpreviewgen
generate "MythTV Shutdown helper" debian/tmp/usr/bin/mythshutdown
generate "MythTV Utility helper" debian/tmp/usr/bin/mythutil
generate "MythTV Backend" debian/tmp/usr/bin/mythbackend
generate "MythTV FFMpeg helper " debian/tmp/usr/bin/mythffmpeg
generate "MythTV HDHomerun Configuration" debian/tmp/usr/bin/mythhdhomerun_config
generate "MythTV Media Server" debian/tmp/usr/bin/mythmediaserver
generate "MythTV replex" debian/tmp/usr/bin/mythreplex
generate "MythTV Transcoder" debian/tmp/usr/bin/mythtranscode
generate "MythTV welcome" debian/tmp/usr/bin/mythwelcome
generate "MythTV closed caption extractor" debian/tmp/usr/bin/mythccextractor
generate "MythTV ffmpeg player" debian/tmp/usr/bin/mythffplay
generate "MythTV guide database filler" debian/tmp/usr/bin/mythfilldatabase
generate "MythTV Job Queue manager" debian/tmp/usr/bin/mythjobqueue
generate "MythTV metadata lookup" debian/tmp/usr/bin/mythmetadatalookup
generate "MythTV Screen Wizard" debian/tmp/usr/bin/mythscreenwizard
generate "MythTV Setup (real)" debian/tmp/usr/bin/mythtv-setup.real
generate "MythTV Archive helper" debian/mytharchive/usr/bin/mytharchivehelper
generate "MythTV Zoneminder server" debian/mythzoneminder/usr/bin/mythzmserver
#these don't have a --help right now
#export PYTHONPATH=debian/libmyth-python/usr/share/pyshared:$PYTHONPATH
#generate "MythTV Python shell" debian/libmyth-python/usr/bin/mythpython
#generate "MythTV wiki scripts" debian/libmyth-python/usr/bin/mythwikiscripts
