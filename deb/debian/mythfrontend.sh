#!/bin/sh
# Mario Limonciello, March 2007
# partially merged with startmythtv.sh by Michael Haas, October 2007

pidof mythfrontend.real 2>&1 >/dev/null && wmctrl -a "MythTV Frontend" 2>/dev/null && exit 0

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#find the session, dialog, and su manager we will be using for display
find_session
find_dialog
find_su

#check that we are in the mythtv group
check_groups
arch=`arch | cut -b 1-3`
codename=`lsb_release -c -s`
if [ "$arch" = arm -a "$codename" = xenial ] ; then
    environ="env LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf/mesa-egl:$LD_LIBRARY_PATH"
else
    environ=
fi

if [ "$1" = "--service" ]; then
    #source frontend session settings
    if [ -f /etc/mythtv/session-settings ]; then
        . /etc/mythtv/session-settings
    fi
    echo "Please note: additional command line arguments will not be passed"
    echo "  to mythfrontend when using --service"
    echo "Please set them in /etc/mythtv/session-settings instead"

    #if group membership is okay, go ahead and launch
    if [ "$IGNORE_NOT" = "0" ]; then
        # start mythtv frontend software
        if [ "$MYTHWELCOME" = "true" ]; then
            # Note: if mythwelcome would support -O to override database settings,
            # we could tell it to start the frontend with $MYTHFRONTEND_OPTS
            # This is not possible yet, but maybe it'll happen in the future
            exec $environ mythwelcome --syslog local7
        else
            until $environ /usr/bin/mythfrontend.real --syslog local7 ${MYTHFRONTEND_OPTS}
                  RET=$?
                  [ "$RET" = "0" -o "$RET" = "1" -o "$RET" = "254" ]
            do
                  notify-send -i info 'Restarting Frontend' "The front-end crashed unexpectedly (exit code $RET) and is restarting. Please wait..."
            done
        fi
    fi
# if we're not in --service mode, just behave normally
elif [ "$1" != "--service" ]; then
    # if group membership is okay, go ahead and launch
    if [ "$IGNORE_NOT" = "0" ]; then
        exec $environ /usr/bin/mythfrontend.real --syslog local7 "$@"
    fi
fi
 
 
