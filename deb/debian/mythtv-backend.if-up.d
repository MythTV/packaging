#! /bin/sh
set -e

# Don't bother to restart mytbackend when lo is configured.
if [ "$IFACE" = lo ]; then
	exit 0
fi

# Only run from ifup.
if [ "$MODE" != "start" ]; then
	exit 0
fi

# Is /usr mounted?
if [ ! -e /usr/bin/mythbackend ]; then
	exit 0
fi

invoke-rc.d mythtv-backend restart || true

exit 0
