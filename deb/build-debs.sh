#!/bin/bash
set -e -u

DEBDIR="$(dirname "$0")"
BASE="$(basename "$0")"

die()
{
    echo "$*" >&2
    exit 1
}

help()
{
	echo "Usage: $0 [git_branch] [target_dir] [additional_patches]"
	echo "git_branch -> optional: the GIT branch of MythTV to build"
	echo "target_dir -> optional: the dir used for the & GIT checkouts"
	echo "additional_patches -> optional: space separated full path to all patches to apply"
	echo ""
	echo "If the target_dir already contains git checkouts, they"
	echo "will just be updated to the latest HEAD followed by the git"
	echo "checkout being checked out to the branch indicated."
	echo ""
	echo "Example:"
	echo " $0"
	echo "  This would check out the branch matching packaging branch name and build debs in $PWD"
	echo ""
	echo " $0 fixes/0.27 /tmp"
	echo "  This would checkout out the fixes/0.27 branch, local packaging and build debs in /tmp"
	echo ""
	echo " $0 fixes/0.27 /tmp /full/path/to/patch"
	echo "  This would checkout the fixes/0.27 branch, local packaging, apply the patch called "
	echo "  'patch' located at /full/path/to/ to the build and then produce debs"
	exit 0
}

have () {
	command -v "$1" >/dev/null 2>&1
}

check_install_package()
{
	command=$1
	shift
	package=${1:-$command}
	shift || :
	if ! have "$command"; then
		echo "Missing $command, marking $package for installation"
		$root apt-get install "$package" -y "$@" || die "Error installing $package"
	fi
}

export QUILT_PATCHES="debian/patches"
: "${GIT_BRANCH:=}" "${DIRECTORY:=}" "${PATCHES:=}" "${DEBUILD_FLAGS:=-us -uc -i -I.git}"

if [ ! -d "$DEBDIR/debian" ]; then
	die "WARNING: This script will not work without a full checkout from git://github.com/MythTV/packaging.git"
fi

for arg in "$@"; do
	case "$arg" in
	help|--help|-h|/\?) help ;;
	esac
	if [ -z "$DIRECTORY" ] && [ -d "$arg" ]; then
		DIRECTORY=$arg
	elif [ -f "$arg" ]; then
		PATCHES="$PATCHES $arg"
	elif [ -z "$GIT_BRANCH" ]; then
		GIT_BRANCH=$arg
	else
		die "Invalid argument: '$arg'"
	fi
done

#identify running branch
RUNNING_BRANCH="$(git -C "$DEBDIR" rev-parse --abbrev-ref HEAD)"

if [ -z "$GIT_BRANCH" ]; then
	GIT_BRANCH=$RUNNING_BRANCH
elif [ "$GIT_BRANCH" != "$RUNNING_BRANCH" ]; then
	echo "Requested to build $GIT_BRANCH but running on $RUNNING_BRANCH."
	if git -C "$DEBDIR" branch -a | grep -Fqs "$GIT_BRANCH"; then
		echo "Repeating checkout process."
		git -C "$DEBDIR" checkout "$GIT_BRANCH"
		exec "$0" "$@"
	fi
	echo "$GIT_BRANCH not found.  Assuming development branch"
	echo "Building $GIT_BRANCH using packaging $RUNNING_BRANCH"
fi
if [ -z "$DIRECTORY" ]; then
	DIRECTORY=$PWD
fi
case "$GIT_BRANCH" in
*fixes*)
	GIT_TYPE="fixes"
	GIT_MAJOR_RELEASE="${GIT_BRANCH##*/}"
	DELIMITTER="+"
	GIT_BRANCH_FALLBACK="master"
	echo "Building for fixes, v0.$GIT_MAJOR_RELEASE in $DIRECTORY"
	;;
*master*)
	GIT_TYPE="master"
	DELIMITTER="~"
	GIT_BRANCH_FALLBACK="master"
	echo "Building for master in $DIRECTORY"
	;;
*)
	GIT_TYPE="arbitrary"
	DELIMITTER="~"
	GIT_BRANCH_FALLBACK="$RUNNING_BRANCH"
	echo "Building for arbitrary (likely development) branch $GIT_BRANCH using packaging from $RUNNING_BRANCH."
	;;
esac

if [ "$(id -ru)" -ne 0 ]; then
	if have sudo; then
		root=sudo
	else
		die "Need to be root or have sudo installed"
	fi
else
	root=
fi

#for checking out git
check_install_package git git-core

#make sure we have debuild no matter what
check_install_package debuild devscripts --no-install-recommends

#check for LSB information
check_install_package lsb_release lsb-release

#quilt needed for patching tests
check_install_package quilt

#need for debuild
check_install_package fakeroot

#need debhelper
check_install_package dh debhelper

#clone in our packaging branch
mkdir -p "$DIRECTORY/mythtv"
rm -rf "$DIRECTORY/mythtv/debian"
cp -R "$DEBDIR/debian" "$DIRECTORY/mythtv"
cp "$DIRECTORY/mythtv/debian/changelog.in" "$DIRECTORY/mythtv/debian/changelog"

#build packaging changelog
DATE=$(date +%F -d "$(dpkg-parsechangelog -l"$DIRECTORY/mythtv/debian/changelog" -SDate)")
TODAY=$(date +%F)
PACKAGING_HASH=$(git -C "$DEBDIR" rev-parse --short HEAD)
if [ "$DATE" != "$TODAY" ]; then
	echo "Packaging changes between $DATE and $TODAY:"
	git -C "$DEBDIR" log --grep="^deb: " --oneline --since="$DATE" | sed 's/^/[/; s/ deb:/]/' > "$DIRECTORY/mythtv/.gitout"
fi

#if we have patch arguments, apply them
if [ -n "$PATCHES" ]; then
	for PATCH in $PATCHES; do
		cp "$PATCH" "$DIRECTORY/mythtv/debian/patches"
		basename "$PATCH" >> "$DIRECTORY/mythtv/debian/patches/series"
		echo "Applied $PATCH to build"
	done > "$DIRECTORY/mythtv/.gitout"
fi

# Change to the build directory
cd "$DIRECTORY/mythtv"

parse_debver () { #parse debian/changelog: [ $EPOCH ':' ] [ '0.' ] $MAJOR '.' $MINOR ( '+fixes' | '~master' ) [ '.' $YEAR $MONTH $DAY '.' $hash '-0ubuntu' $COUNTER ]
	#these should always be parsed from the old changelog
	EPOCH=${1%%:*}

	local IFS='.~+-'
	set -- ${1#*:}

	#these can be filled in potentially from external sources
	: "${GIT_MAJOR_RELEASE:=$1}" "${GIT_MINOR_RELEASE:=$2}" "${DEBIAN_SUFFIX:=0ubuntu0}" "${DEBEMAIL:=$USER@$HOSTNAME}" "${DEBFULLNAME=$USER}"
	export DEBEMAIL DEBFULLNAME

	# /usr/share/dpkg/pkg-info.mk
	DEB_VERSION_UPSTREAM="${GIT_MAJOR_RELEASE}.${GIT_MINOR_RELEASE}${DELIMITTER}${GIT_TYPE}.${TODAY//-/}"
	DEB_VERSION_UPSTREAM_REVISION="${DEB_VERSION_UPSTREAM}-${DEBIAN_SUFFIX}"
	DEB_VERSION="${EPOCH}:${DEB_VERSION_UPSTREAM_REVISION}"
}
parse_debver "$(dpkg-parsechangelog -SVersion)"

##set changelog entry
#actually bump the changelog up. don't include a git hash here right now.
dch -b -v "$DEB_VERSION" "Scripted Build from $GIT_TYPE git packaging [$PACKAGING_HASH]"
if [ -f .gitout ]; then
	while read -r line
	do
		dch -a "$line"
	done < .gitout
	rm .gitout
fi

#clean up any old patches (just in case)
if [ -d .pc ]; then
	quilt pop -a 2>/dev/null || rm -rf .pc
fi

#make sure that we have things stashed if necessary
DELTA=$(git status -s -uno || true)
if [ -n "$DELTA" ]; then
	git stash -q 2>/dev/null || true
fi

#check out/update checkout
debian/rules get-git-source LAST_GIT_HASH='' GIT_BRANCH="$GIT_BRANCH" GIT_BRANCH_FALLBACK="$GIT_BRANCH_FALLBACK"

# 0) Check for a orig tarball file.  If no file then:
# 1) build a tarball
# 2) is this an autobuild?  if so, double check whether the tarball already
#    existed in the primary archive
#    A) if so, this replaces it so that we have consistent md5sums
#    B) if it didn't this will do nothing.
if [ ! -f "../mythtv_${DEB_VERSION_UPSTREAM}.orig.tar.gz" ]; then
	debian/rules build-tarball
	case "$DEBIAN_SUFFIX" in
	*mythbuntu*) debian/rules get-orig-source ;;
	esac
fi

case "$BASE" in
build-dsc.sh)
    DEBUILD_FLAGS="-S --no-check-builddeps $DEBUILD_FLAGS"
	;;
build-deb.sh|*)
    #test and install deps as necessary
    if ! dpkg-checkbuilddeps 1>/dev/null 2>&1; then
		echo "Missing build dependencies for mythtv, will install them now:"
		$root apt-get build-dep . || die "error installing dependencies"
    fi
	;;
esac

#mark the ubuntu target in the changelog
: "${UBUNTU_RELEASE:=$(lsb_release -s -c)}"
dch -b --force-distribution -D "$UBUNTU_RELEASE" ""

echo "Testing all patches before building the packages"
quilt push -aq || (quilt pop -aqf && exit 1)
quilt pop -aq

#build the packages
echo "Building the packages"
debuild $DEBUILD_FLAGS

#remove all patches and cleanup
#seems newer dpkg-source might not need the extra quilt pop
echo "Cleaning up"
quilt pop -aqf || true
debian/rules clean
