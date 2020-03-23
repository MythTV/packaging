#!/bin/bash
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
set -e

gitbasedir=`git rev-parse --show-toplevel`
projname=`basename $PWD`

if [[ -f $HOME/.buildrc ]] ; then
    . $HOME/.buildrc
fi

. "$scriptpath/setccache.source"
branch=`git branch | grep '*'| cut -f2 -d' '`
if [[ "$branch" == '(HEAD' ]] ; then
    branch=`git branch | grep '*'| cut -f3 -d' '`
fi
echo "chroot: $SCHROOT_CHROOT_NAME" > $gitbasedir/../config_${projname}.out
echo "arch: $arch codename: $codename branch: $branch" >> $gitbasedir/../config_${projname}.out
echo "$chprefix$arch/$codename/$branch" > $gitbasedir/../config_${projname}.branch

case $projname in
    mythtv)
        git clean -Xfd
        if which $BUILD_PREPARE ; then
            $BUILD_PREPARE
        fi
        config_opt="--enable-libmp3lame"
        config_opt="$config_opt $MYTHTV_CONFIG_OPT_EXTRA"
        if [[ `arch` == arm* ]] ; then
            config_opt="$omx_option --disable-vdpau \
              --enable-opengl  \
              --disable-vaapi $MYTHTV_CONFIG_OPT_EXTRA"
        fi
        set -x
        ./configure --prefix=/usr $config_opt "$@" |& tee -a $gitbasedir/../config_${projname}.out
        set -
        ;;
    mythplugins)
        git clean -Xfd
        if which $BUILD_PREPARE ; then
            $BUILD_PREPARE
        fi
        # Reset the mythtv config because this overwrites it
        rm -f $gitbasedir/../config_mythtv.branch
        . "$scriptpath/getdestdir.source"
        mkdir -p $destdir
        sourcedir=`echo $destdir|sed s/mythplugins/mythtv/`
        gitver=`git describe --dirty|cut -c2-`
        packagever=`env LD_LIBRARY_PATH=$sourcedir/usr/lib $sourcedir/usr/bin/mythutil --version |grep "MythTV Version"|cut -d ' ' -f 4|cut -c2-`
        if [[ "$packagever" != "$gitver" ]] ; then
            echo ERROR Package version $packagever does not match git version $gitver
            exit 2
        fi
        cd ../mythtv
        git clean -Xfd
        config_opt="--enable-libmp3lame"
        config_opt="$config_opt $MYTHTV_CONFIG_OPT_EXTRA"
        omx_option=
        if [[ `arch` == arm* ]] ; then
            config_opt="$omx_option --disable-vdpau \
              --enable-opengl \
              --disable-vaapi $MYTHTV_CONFIG_OPT_EXTRA"
        fi
        set -x
        ./configure --prefix=$destdir/usr \
          --runprefix=/usr $config_opt "$@" |& tee -a  $gitbasedir/../config_${projname}.out
        rm -rf $destdir
        cp -a $sourcedir/ $destdir/
        cp libs/libmythbase/mythconfig.h libs/libmythbase/mythconfig.mak \
         $destdir/usr/include/mythtv/
        cd ../mythplugins
        git clean -Xfd
        basedir=$destdir/usr
        export PYTHONPATH=`ls -d $basedir/local/lib/python*/dist-packages`
        config_opt=
        config_opt=" $MYTHTV_CONFIG_OPT_EXTRA"
        ./configure --prefix=$destdir/usr \
         $config_opt "$@" |& tee -a  $gitbasedir/../config_${projname}.out
         set -
        ;;
    *)
        echo "ERROR Unrecognized project $projname"
        exit 2
        ;;
esac
echo Completed configure
