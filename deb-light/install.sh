#!/bin/bash
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
set -e

gitbasedir=`git rev-parse --show-toplevel`

projname=`basename $PWD`

# This will get projname and destdir
. "$scriptpath/getdestdir.source"

echo destination is  $destdir.

echo "chroot: $SCHROOT_CHROOT_NAME" > $gitbasedir/../install_${projname}.out
echo "branch: $branch" >> $gitbasedir/../install_${projname}.out
echo "dest: $destdir" >> $gitbasedir/../install_${projname}.out
case $projname in
    mythtv)
        rm -rf $destdir
        mkdir -p $destdir
        export INSTALL_ROOT=$destdir
        ;;
    mythplugins)
        ;;
    jampal)
        rm -rf $destdir
        mkdir -p $destdir
        export DESTDIR=$destdir
        ;;
esac
make install |& tee -a $gitbasedir/../install_${projname}.out
echo Install Complete on `date`
