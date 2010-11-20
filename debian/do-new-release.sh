debian/rules update-latest-revision
debian/rules get-svn-source
debian/rules update-control-files
debian/rules update-upstream-changelog
if [ -n "$1" ]; then
	DIST="$1"
else
	DIST="natty"
fi
dch -r -D $DIST --force-distribution ""
