#!/bin/sh
# Mario Limonciello, March 2007
# partially merged with startmythtv.sh by Michael Haas, October 2007

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#find the session, dialog, and su manager we will be using for display
find_session
find_dialog
find_su

#check that we are in the mythtv group
check_groups

if [ "$1" = "--service" ]; then
    #source frontend session settings
    . /etc/mythtv/session-settings
    echo "Please note: additional command line arguments will not be passed"
    echo "  to mythfrontend when using --service"
    echo "Please set them in /etc/mythtv/session-settings instead"

    # set log files
    MYTHFELOG="/var/log/mythtv/mythfrontend.log"
    MYTHWELCOMELOG="/var/log/mythtv/mythwelcome.log"

    # make sure that our log files exist
    # it's ok if we fail, we'll fall back to a different logfile location later on
    if [ ! -f "${MYTHFELOG}" ]; then
        touch "${MYTHFELOG}" || true
    fi
    if [ ! -f "${MYTHWELCOMELOG}" ]; then
        touch "${MYTHWELCOMELOG}" || true
    fi
    # make sure log files are writeable by members of the "mythtv" group
    # again, it's ok if we fail so we redirect STDERR to /dev/null
    chgrp mythtv "${MYTHFELOG}" 2>/dev/null && \
    chmod g+rw "${MYTHFELOG}" 2>/dev/null || true
    chgrp mythtv "${MYTHWELCOMELOG}" 2>/dev/null && \
    chmod g+rw "${MYTHWELCOMELOG}" 2>/dev/null || true

    # Are the log files writeable as well? If not, warn the user and
    # fall back to tempory log location
    if [ ! -w "${MYTHFELOG}" ]; then
        echo "Sorry, "${MYTHFELOG}" is not writeable. Please make sure it's writeable"
        echo "  for the \"mythtv\" group."
        echo "Logging to /tmp/mythfrontend.${$}.log instead"
        MYTHFELOG="/tmp/mythfrontend.${$}.log"
    fi

    if [ ! -w "${MYTHWELCOMELOG}" ]; then
        echo "Sorry, "${MYTHWELCOMELOG}" is not writeable. Please make sure it's writeable"
        echo "  for the \"mythtv\" group."
        echo "Logging to /tmp/mythwelcome.${$}.log instead"
        MYTHWELCOMELOG="/tmp/mythwelcome.${$}.log"
    fi


    #if group membership is okay, go ahead and launch
    if [ "$IGNORE_NOT" = "0" ]; then
        # start mythtv frontend software
        if [ "$MYTHWELCOME" = "true" ]; then
            if [ ! -z $MYTHFRONTEND_OPTS ]; then
                echo "Note: It looks like you set MYTHFRONTEND_OPTS in /etc/mythtv/session-settings" | tee -a "${MYTHWELCOMELOG}"
                echo "However, mythwelcome won't recognize these." | tee -a "${MYTHWELCOMELOG}"
                echo "You have to set to set your startup options in the mythwelcome settings screens" | tee -a "${MYTHWELCOMELOG}"
                echo "Starting mythwelcome.." | tee -a "${MYTHWELCOMELOG}"
            fi
            # Note: if mythwelcome would support -O to override database settings,
            # we could tell it to start the frontend with $MYTHFRONTEND_OPTS
            # This is not possible yet, but maybe it'll happen in the future
            exec mythwelcome | tee -a "${MYTHWELCOMELOG}"
        else
            echo "Starting mythfrontend.real.." >> "${MYTHFELOG}"
            exec mythfrontend --logfile "${MYTHFELOG}" "${MYTHFRONTEND_OPTS}"
        fi
    fi
# if we're not in --service mode, just behave normally
elif [ "$1" != "--service" ]; then
    # if group membership is okay, go ahead and launch
    if [ "$IGNORE_NOT" = "0" ]; then
        exec /usr/bin/mythfrontend.real "$@"
    fi
fi
 
