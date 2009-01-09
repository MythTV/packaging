#! /bin/sh
set -e

# Don't bother to restart sshd when lo is configured.
if [ "$IFACE" = lo ]; then
	exit 0
fi

# Only run from ifup.
if [ "$MODE" != "start" ]; then
	exit 0
fi
if [ "$METHOD" != "NetworkManager" ]; then
	exit 0
fi

# Is /usr mounted?
if [ ! -e /usr/bin/mythbackend ]; then
	exit 0
fi

/etc/init.d/mythtv-backend restart >/dev/null 2>&1 || true

exit 0
