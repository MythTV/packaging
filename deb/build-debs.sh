#!/bin/sh -e

die()
{
    echo $1
    exit 1
}

help()
{
	echo "Usage: sh /path/to/build-deps.sh $O git_branch [target_dir] [additional_patches]"
	echo "git_branch -> mandatory: the GIT branch of MythTV to build"
	echo "target_dir -> optional: the dir used for the BZR & GIT checkouts"
	echo "additional_patches -> optional: space separated full path to all patches to apply"
	echo ""
	echo "If the target_dir already contains git and bzr checkouts, they"
	echo "will just be updated to the latest HEAD followed by the git"
	echo "checkout being checked out to the branch indicated."
	echo ""
	echo "Example:"
	echo " $O master"
	echo "  This would check out the master branch and master packaging and build debs in `pwd`"
	echo ""
	echo " $O fixes/0.24 /tmp"
	echo "  This would checkout out the fixes/0.24 branch, fixes packaging and build debs in /tmp"
	echo ""
	echo " $O fixes/0.24 /tmp /full/path/to/patch"
	echo "  This would checkout the fixes/0.24 branch, fixes packaging, apply the patch called "
	echo "  'patch' located at /full/path/to/ to the build and then produce debs"
	exit 0
}

export QUILT_PATCHES="debian/patches"
[ -n "$GIT_BRANCH" ] && GIT_BRANCH=""
[ -n "$DIRECTORY" ] && DIRECTORY=""
[ -n "$PATCHES" ] && PATCHES=""
[ -z "$DEBUILD_FLAGS" ] && DEBUILD_FLAGS="-us -uc -i -I.git"

if [ -z "$1" ]; then
	help
else
	for arg in $@; do
		if [ -z "$GIT_BRANCH" ]; then
			GIT_BRANCH=$arg
			continue
		fi
		if [ -z "$DIRECTORY" ] && [ -d "$arg" ]; then
			DIRECTORY=$arg
			continue
		fi
		if [ -f "$arg" ]; then
			PATCHES="$PATCHES $arg"
			continue
		fi
	done
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

#make sure we have build-essential
if ! which gcc 2>&1 1>/dev/null; then
    echo "Missing build-essential, marking for installation"
    sudo apt-get install build-essential || die "Error installing build-essential"
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
#this uses quilt
if ! which quilt 2>&1 1>/dev/null; then
    echo "Missing quilt, marking for installation"
    sudo apt-get install quilt || die "Error installing quilt"
fi
if [ -d .pc ]; then
	quilt pop -a 2>/dev/null || rm -rf .pc
fi

#make sure that we have things stashed if necessary
DELTA=$(git status -s -uno || true)
if [ -n "$DELTA" ]; then
	git stash -q 2>/dev/null || true
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
    #If we are running Oneiric or later get-build-deps is
    #replaced with mk-build-deps which is in the devscripts package
    #If devscripts > 2.10.xx we are running Oneiric or later and will be using mk-build-deps
    if ! dpkg-query -s devscripts | sed '/^Version:/!d; s/Version: //' | cut -c3-4 | grep 10 > /dev/null; then
	    echo ' '
	    echo ' '
	    echo '  ####################################'
	    echo '  # We will be using mk-build-deps   #'
	    echo '  ####################################'
	    echo ' '
	    echo ' '
	    sleep 2

		#equivs is used by mk-build-deps
		if ! which equivs-build 2>&1 1>/dev/null; then
		    echo "Missing equivs, marking for installation"
		    sudo apt-get install equivs || die "Error installing equivs"
    		fi

	    #grab build dependencies
	    mk-build-deps -ir -s sudo || die "Error installing build dependencies"

	    #mk-build-deps is not totaly reliable yet
	    #at the moment it misses libiec61883-dev (firewire support)
	    #the following will make sure it is installed
	    sudo apt-get build-dep mythtv || die "Error installing build-dep mythtv"
    else
	    echo ' '
	    echo ' '
	    echo '  #####################################'
	    echo '  # We will be using get-build-deps   #'
	    echo '  #####################################'
	    echo ' '
	    echo ' '
	    sleep 2

		if ! which get-build-deps 2>&1 1>/dev/null; then
		    echo "Missing ubuntu-dev-tools, marking for installation"
		    sudo apt-get install ubuntu-dev-tools --no-install-recommends || die "Error installing ubuntu-dev-tools"
		fi

		#pbuilder is used by get-build deps
		if ! which debuild-pbuilder 2>&1 1>/dev/null; then
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
    fi

elif [ "$TYPE" = "source" ]; then
    DEBUILD_FLAGS="-S $DEBUILD_FLAGS"
fi

#update changelog and control files
debian/rules update-control-files

#mark the ubuntu target in the changelog
[ -z "$UBUNTU_RELEASE" ] && UBUNTU_RELEASE=$(lsb_release -s -c)
dch -b --force-distribution -D $UBUNTU_RELEASE ""

#if we have patch arguments, apply them
if [ -n "$PATCHES" ]; then
	for PATCH in $PATCHES; do
		cp $PATCH debian/patches
		echo $(basename $PATCH) >> debian/patches/series
		dch -a "Applied $PATCH to build"
	done
fi

echo "Testing all patches before building the packages"
quilt push -aq || (quilt pop -aqf && exit 1)
quilt pop -aq

#build the packages
echo "Building the packages"
debuild $DEBUILD_FLAGS

#remove all patches and cleanup
echo "Cleaning up"
quilt pop -aqf
debian/rules clean
