#!/bin/sh -e

die()
{
    echo $1
    exit 1
}

help()
{
	echo "Usage: $0 git_branch [target_dir]"
	echo "git_branch -> mandatory: the GIT branch of MythTV to build"
	echo "target_dir -> optional: the dir used for the BZR & GIT checkouts"
	echo ""
	echo "If the target_dir already contains git and bzr checkouts, they"
	echo "will just be updated to the latest HEAD followed by the git"
	echo "checkout being checked out to the branch indicated."
	echo ""
	echo "Example:"
	echo " $0 master"
	echo "  This would check out the master branch and master packaging and build debs in `pwd`"
	echo ""
	echo " $0 fixes/0.24 /tmp"
	echo "  This would checkout out the fixes/0.24 branch, fixes packaging and build debs in /tmp"
	exit 0
}

[ -z "$DEBUILD_FLAGS" ] && DEBUILD_FLAGS="-us -uc -i -I.git"

if [ -z "$1" ]; then
	help
else
	GIT_BRANCH="$1"
	DIRECTORY="$2"
	if echo "$GIT_BRANCH" | grep fixes 2>&1 1>/dev/null; then
		GIT_TYPE="fixes"
		GIT_MAJOR_RELEASE=$(echo $1 |sed 's,.*0.,,')
		DELIMITTER="+"
		echo "Building for fixes, v0.$GIT_MAJOR_RELEASE"
	else
		GIT_TYPE="master"
		DELIMITTER="~"
		echo "Building for master"
	fi
	if [ -z "$DIRECTORY" ]; then
		DIRECTORY=`pwd`
	fi
fi

if [ "`basename $0`" = "build-dsc.sh" ]; then
    TYPE="source"
else
    TYPE="binary"
fi

#for checking out packaging
if ! which bzr 1>/dev/null; then
	echo "Missing bzr, marking for installation"
	sudo apt-get install bzr || die "Error installing bzr"
fi

#for checking out git
if ! which git 1>/dev/null; then
	echo "Missing git-core, marking for installation"
	sudo apt-get install git-core || die "Error installing git-core"
fi

#make sure we have debuild no matter what
if ! which debuild 1>/dev/null; then
    echo "Missing debuild, marking for installation"
    sudo apt-get install devscripts --no-install-recommends|| die "Error installing devscripts"
fi


mkdir -p $DIRECTORY
cd $DIRECTORY

#update bzr branches that are supported
#reset them and stage the proper one
if [ ! -d ".bzr" ]; then
	bzr init-repo .
fi
if [ ! -d bzr-$GIT_TYPE ]; then
	bzr branch http://bazaar.launchpad.net/~mythbuntu/mythtv/mythtv-$GIT_TYPE bzr-$GIT_TYPE
else
	cd bzr-$GIT_TYPE && bzr pull && cd ..
fi
mkdir -p git
cd git
rm -rf .bzr
ln -s ../bzr-$GIT_TYPE/.bzr .
bzr revert
bzr clean-tree --force

##set changelog entry
#these can be filled in potentially from external sources
[ -z "$GIT_MAJOR_RELEASE" ] && GIT_MAJOR_RELEASE=$(dpkg-parsechangelog | dpkg-parsechangelog | sed '/^Version/!d; s/.*[0-9]:0.//; s/~.*//; s/+.*//' | awk -F. '{print $1 }')
[ -z "$GIT_MINOR_RELEASE_FIXES" ] && GIT_MINOR_RELEASE=$(dpkg-parsechangelog | dpkg-parsechangelog | sed '/^Version/!d; s/.*[0-9]:0.//; s/~.*//; s/+.*//' | awk -F. '{print $2 }')
[ -z "$DEBIAN_SUFFIX" ] && DEBIAN_SUFFIX=$(dpkg-parsechangelog | sed '/^Version/!d; s/.*-//;')
#these should always be parsed from the old changelog
EPOCH=$(dpkg-parsechangelog | sed '/^Version/!d; s/.* //; s/:.*//;')
TODAY=$(date +%Y%m%d)
#actually bump the changelog up. don't include a git hash here right now.
dch -b -v $EPOCH:0.$GIT_MAJOR_RELEASE.$GIT_MINOR_RELEASE$DELIMITTER$GIT_TYPE.$TODAY.-$DEBIAN_SUFFIX "Automated Build"

#clean up any old patches (just in case)
if [ -d .pc ]; then
	quilt pop -a 2>/dev/null || true
fi

#check out/update checkout
debian/rules get-git-source LAST_GIT_HASH='' GIT_BRANCH=$GIT_BRANCH

#new upstream version
UPSTREAM_VERSION=$(dpkg-parsechangelog | sed '/^Version/!d; s/.*[0-9]://; s/-.*//')

# 0) Check for a orig tarball file.  If no file then:
# 1) build a tarball
# 2) is this an autobuild?  if so, double check whether the tarball already
#    existed in the primary archive
#    A) if so, this replaces it so that we have consistent md5sums
#    B) if it didn't this will do nothing.
if [ ! -f ../mythtv_$UPSTREAM_VERSION.orig.tar.gz ]; then
	debian/rules build-tarball
	if echo $DEBIAN_SUFFIX | grep 'mythbuntu' 2>&1 1>/dev/null; then
		debian/rules get-orig-source
	fi
fi

if [ "$TYPE" = "binary" ]; then
    #Make sure we have the package for get-build-deps
    if ! which get-build-deps 2>&1 1>/dev/null; then
        echo "Missing ubuntu-dev-tools, marking for installation"
        sudo apt-get install ubuntu-dev-tools --no-install-recommends || die "Error installing ubuntu-dev-tools"
    fi

    #pbuilder is used by get-build deps
    if ! which pbuilder 2>&1 1>/dev/null; then
        echo "Missing pbuilder, marking for installation"
        sudo apt-get install pbuilder || die "Error installing pbuilder"
    fi

    #aptitude is used by get-build deps
    if ! which aptitude 2>&1 1>/dev/null; then
        echo "Missing aptitude, marking for installation"
        sudo apt-get install aptitude || die "Error installing aptitude"
    fi

    #grab build dependencies
    get-build-deps || die "Error installing build dependencies"

elif [ "$TYPE" = "source" ]; then
    DEBUILD_FLAGS="-S -sa $DEBUILD_FLAGS"
fi

#update changelog and control files
debian/rules update-control-files

#mark the ubuntu target in the changelog
[ -z "$UBUNTU_RELEASE" ] && UBUNTU_RELEASE=$(lsb_release -s -c)
dch -b --force-distribution -D $UBUNTU_RELEASE ""

#build the packages
debuild $DEBUILD_FLAGS

#remove all patches and cleanup
quilt pop -af
debian/rules clean
