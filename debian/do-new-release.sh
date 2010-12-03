quilt pop -a 2>/dev/null || true
debian/rules update-control-files
debian/rules get-git-source
if [ -n "$1" ]; then
	DIST="$1"
else
	DIST="natty"
fi
dch -r -D $DIST --force-distribution ""
