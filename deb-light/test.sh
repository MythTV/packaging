#!/bin/bash

scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
scriptname=`basename "$scriptname"`
shortname=$1
pgm=$2
shift
shift
set -e

if [[ -f $HOME/.testrc ]] ; then
    . $HOME/.testrc
fi

. "$scriptpath/getlongname.source"

if [[ "$longname" == "" ]] ; then
    echo "ERROR - $shortname not recognized - valid values below"
    cat $HOME/.buildnames
    exit 2
fi

branch=$(basename "$longname")
project=$(basename $(dirname "$longname"))

case $project in
    mythtv|mythplugins)
        basedir=$destdir/usr
        set -x
        export PATH=$basedir/bin:$basedir/local/bin:$PATH
        export MYTHTVDIR=$basedir
        export LD_LIBRARY_PATH=$basedir/lib:$basedir/share/mythtv/lib:$LD_LIBRARY_PATH
        export MYTHCONFDIR=$HOME/.mythtv-$shortname
        # dist-packages if installed by debian
        export PYTHONPATH=`ls -d $basedir/local/lib/python*/dist-packages`
        export PERL5LIB=`ls -d $basedir/local/share/perl/*`${PERL5LIB:+:${PERL5LIB}}
        exec $pgm "$@"
        ;;
    *)
        basedir=$destdir/usr
        export PATH=$basedir/bin:$PATH
        exec $pgm "$@"
        ;;
esac
