#! /bin/sh
# MythTV Openbox Startup Session Script for Ubuntu Linux
# by Mario Limonciello <superm1@ubuntu.com>
# November 2006-2007

#source frontend session settings
. /etc/mythtv/session-settings

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#For our backend configure test scripts
find_session
find_dialog
find_su

#set background
feh --bg-center /usr/share/mythtv/background.xpm

#spawn gnome-screensaver if installed
if [ -x /usr/bin/gnome-screensaver ]; then
    gnome-screensaver
fi

#start gnome-power-manager if installed
if [ -x /usr/bin/gnome-power-manager ]; then
    gnome-power-manager
fi

#check if irexec is needed, and start if need be
if [ -x /usr/bin/irexec ] && [ ! -f ~/.noirexec ] && [ -f ~/.lircrc ]; then
            if [ -n "$(cat ~/.lircrc | grep --invert-match "#" | grep irexec | grep prog)" ]
            then
        killall irexec
        irexec -d
            fi
fi

#if nvidia settings are saved and nvidia drivers installed, load them
if [ -x /usr/bin/nvidia-settings ]; then
    if [ -f ~/.nvidia-settings-rc ]; then
        nvidia-settings -l
    fi
fi

#If the user has customized any xmodmap settings, load them
if [ -x /usr/bin/xmodmap ]; then
    if [ -f ~/.xmodmap ]; then
        xmodmap ~/.xmodmap
    fi
fi

#If we have mtd around (and not running), good idea to start it too
if ! `pgrep mtd>/dev/null`; then
    if [ -x /usr/bin/mtd ]; then
        /usr/bin/mtd -d
    fi
fi

#start window manager
openbox &

echo "Checking for custom mythtv commands in ~/.mythtv/session"
if [ -x $HOME/.mythtv/session ]; then
    $HOME/.mythtv/session &
fi

if [ -x /usr/bin/mythbackend ]; then
    if [ -e $HOME/.mythtv/backend_configured ]; then
        HAS_BACKEND_CONFIGURED=1
    else
        dialog_question "Run MythTV Configuration" "It appears that a backend is installed, but mythtv-setup hasn't been run yet on this machine.  Would you like to run it?"
        HAS_BACKEND_CONFIGURED=$?
        mkdir -p $HOME/.mythtv
        touch $HOME/.mythtv/backend_configured
    fi
else
    HAS_BACKEND_CONFIGURED=1
fi

if [ "$HAS_BACKEND_CONFIGURED" = "0" ]; then
    NAME="mythbackend"
    RUNDIR=/var/run/mythtv
    EXTRA_ARGS=""
    ARGS="--daemon --logfile /var/log/mythtv/mythbackend.log --pidfile $RUNDIR/$NAME.pid"
    if [ -f /etc/default/mythtv-backend ]; then
      . /etc/default/mythtv-backend
    fi
    kill `pgrep mythbackend`
    test -e $RUNDIR/$NAME.pid && rm $RUNDIR/$NAME.pid
    /usr/bin/mythtv-setup.real
    dialog_question "Fill Database?" "Would you like to run mythfilldatabase?"
    DATABASE_NOT=$?
    if [ "$DATABASE_NOT" = "0" ]; then
        xterm -title "Running mythfilldatabase" -e "unset DISPLAY && unset SESSION_MANAGER && mythfilldatabase; sleep 3"
    fi
    xterm -title "Starting Backend" -e "unset DISPLAY && unset SESSION_MANAGER && mythbackend $ARGS $EXTRA_ARGS; sleep 3"
fi

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
# again, it's ok if we fail
chgrp mythtv "${MYTHFELOG}" && \
chmod g+rw "${MYTHFELOG}" || true
chgrp mythtv "${MYTHWELCOMELOG}" && \
chmod g+rw "${MYTHWELCOMELOG}" true

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


#start mythtv frontend software
if [ "$MYTHWELCOME" = "true" ]; then
    if [ ! -z $MYTHFRONTEND_OPTS ]; then
        echo "Note: It looks like you set MYTHFRONTEND_OPTS in /etc/mythtv/session-settings" | tee -a "${MYTHWELCOMELOG}"
        echo "However, mythwelcome won't recognize these." | tee -a "${MYTHWELCOMELOG}"
        echo "You have to set to set your startup options in the mythwelcome settings screens" | tee -a "${MYTHWELCOMELOG}"
        echo "Starting mythwelcome.." | tee -a "${MYTHWELCOMELOG}"
    fi
# Note: if mythwelcome would support -O to override database settings, we could tell it to start the frontend with $MYTHFRONTEND_OPTS
# This is not possible yet, but maybe it'll happen in the future
    exec mythwelcome | tee -a "${MYTHWELCOMELOG}"
else
    exec mythfrontend --logfile "${MYTHFELOG}" "${MYTHFRONTEND_OPTS}"
fi
