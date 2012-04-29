quilt pop -a 2>/dev/null || true
debian/rules get-git-source
debian/rules update-control-files
if [ -n "$1" ]; then
	DIST="$1"
else
	DIST="natty"
fi
dch -r -D $DIST --force-distribution ""
