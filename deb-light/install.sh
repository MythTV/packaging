#!/bin/bash
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
set -e

gitbasedir=`git rev-parse --show-toplevel`

projname=`basename $PWD`

# This will get projname and destdir
. "$scriptpath/getdestdir.source"

echo destination is  $destdir.

projdir=$(basename "$gitbasedir")
echo projdir=$projdir

echo "chroot: $SCHROOT_CHROOT_NAME" > $gitbasedir/../install_${projdir}.out
echo "branch: $branch" >> $gitbasedir/../install_${projdir}.out
echo "dest: $destdir" >> $gitbasedir/../install_${projdir}.out
case $projname in
    mythtv)
        rm -rf $destdir
        mkdir -p $destdir
        export INSTALL_ROOT=$destdir
        ;;
    mythplugins)
        ;;
    *)
        rm -rf $destdir
        mkdir -p $destdir
        export DESTDIR=$destdir
        ;;
esac
make install |& tee -a $gitbasedir/../install_${projdir}.out

if [[ "$projname" == mythtv ]] ; then
    if [[ ! -d $destdir/usr/share/doc/mythtv-backend/contrib ]] ; then
        if [[ -d $gitbasedir/mythtv/contrib ]] ; then
            mkdir -p $destdir/usr/share/doc/mythtv-backend/contrib
            cp -a $gitbasedir/mythtv/contrib/*  \
                $destdir/usr/share/doc/mythtv-backend/contrib/
        else
            echo ERROR Running from wrong directory, $gitbasedir/mythtv/contrib not found \
                |& tee -a $gitbasedir/../install_${projdir}.out
            exit 2
        fi
    fi
fi

echo Install Complete on `date`
