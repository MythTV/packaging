=====
Debian & Ubuntu Packaging (.deb)
=====

The deb packaging directory contains two scripts "build-debs.sh" and 
"build-dsc.sh".

 - Invoking "build-debs.sh" will install all prerequisites and build
   binary .deb packages that could be directly installed.
 - Invoking "build-dsc.sh" will install prerequisites for building a
   source package (.dsc) that can then be built using pbuilder, sbuild
   Launchpad, dpkg-buildpackage, debuild or a similar tool.
   Use this if you don't want to install all build dependencies on
   your local box and have a remote builder box.

Usage
-----
./build-debs.sh [git_branch] [target_dir] [additional_patches]

	git_branch -> optional: the GIT branch of MythTV to build

	target_dir -> optional: the dir used for the & GIT checkouts

	additional_patches -> optional: space separated full path to all patches to apply

If the target_dir already contains git checkouts, they
will just be updated to the latest HEAD followed by the git
checkout being checked out to the branch indicated.

Examples:
 - ./build-debs.sh
	This would check out the branch matching packaging branch name and build debs in `pwd`
 - ./build-debs.sh fixes/0.27 /tmp
	This would checkout out the fixes/0.27 branch, local packaging and build debs in /tmp
 - ./build-debs.sh fixes/0.27 /tmp /full/path/to/patch
	This would checkout the fixes/0.27 branch, local packaging, apply the patch called
	'patch' located at /full/path/to/ to the build and then produce debs
 - DEBUILD_FLAGS='-sa' ./build-dsc.sh fixes/0.27 /tmp /full/path/to/patch
	This would build source packages (that could be later built somewhere such as 
	launchpad PPA's) from the 0.27 fixes branch, in the tmp directory, while
	apply the patch /full/path/to/patch
 - DEBIAN_SUFFIX='0ubuntu4' DEBUILD_FLAGS='-sa' ./build-dsc.sh fixes/0.27 /tmp /full/path/to/patch
	This would build source packages (that could be later built somewhere such as 
	launchpad PPA's) from the 0.27 fixes branch, in the tmp directory, while
	apply the patch /full/path/to/patch. It would also force the debian suffix
        '0ubuntu4' in the version rather than default to '0ubuntu1'
 - UBUNTU_RELEASE='wily' DEBIAN_SUFFIX='0ubuntu3' DEBUILD_FLAGS='-sa' ./build-dsc.sh fixes/0.27 /tmp /full/path/to/patch
	This would build source packages (that could be later built somewhere such as 
	launchpad PPA's) from the 0.27 fixes branch, in the tmp directory, while
	apply the patch /full/path/to/patch for Ubuntu Wily. It would also force the 
        debian suffix '0ubuntu3' (in case of multiple builds in a single day)
