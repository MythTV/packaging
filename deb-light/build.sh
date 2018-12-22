#!/bin/bash
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
set -e

gitbasedir=`git rev-parse --show-toplevel`
projname=`basename $PWD`

if [[ -f $HOME/.buildrc ]] ; then
    . $HOME/.buildrc
fi

if [[ "$BUILD_PREPARE" != "" ]] ; then
    $BUILD_PREPARE
fi

. "$scriptpath/setccache.source"

branch=`git branch | grep '*'| cut -f2 -d' '`
if [[ "$branch" == '(HEAD' ]] ; then
    branch=`git branch | grep '*'| cut -f3 -d' '`
fi
date > $gitbasedir/../build_${projname}.out
if [[ "$SCHROOT_CHROOT_NAME" == "" ]] ; then
    chprefix=
else
    chprefix="chroot-${SCHROOT_CHROOT_NAME}-"
fi
echo "chroot: $SCHROOT_CHROOT_NAME" >> $gitbasedir/../build_${projname}.out
echo "arch: $arch codename: $codename branch: $branch" >> $gitbasedir/../build_${projname}.out
config_branch=`cat $gitbasedir/../config_${projname}.branch` || true
if [[ "$chprefix$arch/$codename/$branch" != "$config_branch" ]] ; then
    echo "Need to run config again. Now=$chprefix$arch/$codename/$branch Config=$config_branch"
    echo "Type I to Ignore once, O to override branch setting."
    read -e resp
    if [[ "$resp" == O ]]; then
        echo "$chprefix$arch/$codename/$branch" > $gitbasedir/../config_${projname}.branch
    elif [[ "$resp" != I ]]; then
        exit 2
    fi
fi

numjobs=5
if [[ `arch` == arm* ]] ; then
    numjobs=2
fi

rc=0
if [[ ! -f Makefile ]] ; then
    echo ERROR No Makefile found.
    rc=999
else
    set -o pipefail
    make -j $numjobs |& tee -a $gitbasedir/../build_${projname}.out || rc=$?
fi
echo Log File:
echo "$gitbasedir/../build_${projname}.out"

if [[ "$rc" == 0 ]] ; then
    if [[ "$BUILD_DONE" != "" ]] ; then
        $BUILD_DONE
    fi
    echo $'\n'"Build complete - Successful" on `date`
else
    echo $'\n'"ERROR ERROR Build Failed rc = $rc" on `date`
fi

exit $rc
