#!/bin/sh
# Mario Limonciello, March 2007

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#find the session, dialog and su manager we will be using for display
find_session
find_dialog
find_su

#check that we are in the mythtv group
check_groups

#if group membership is okay, go ahead and continue
if [ "$IGNORE_NOT" = "0" ]; then

	dialog_question "MythTV Setup Preparation" "Mythbackend must be closed before continuing.\nIs it OK to close any currently running mythbackend processes?"
	CLOSE_NOT=$?
	if [ "$CLOSE_NOT" = "0" ]; then
		if [ "$DE" = "kde" ]; then
			$SU_TYPE /etc/init.d/mythtv-backend stop
		else
			$SU_TYPE /etc/init.d/mythtv-backend stop --message "Please enter your current login password to stop mythtv-backend."
		fi
		/usr/bin/x-terminal-emulator -e /usr/bin/mythtv-setup.real "$@"
		dialog_question "Fill Database?" "Would you like to run mythfilldatabase?"
		DATABASE_NOT=$?
		if [ "$DATABASE_NOT" = "0" ]; then
			xterm -title "Running mythfilldatabase" -e "unset DISPLAY && unset SESSION_MANAGER && mythfilldatabase; sleep 3"
		fi
		if [ "$DE" = "kde" ]; then
			$SU_TYPE /etc/init.d/mythtv-backend restart
		else
			$SU_TYPE /etc/init.d/mythtv-backend restart --message "Please enter your current login password to start mythtv-backend."
		fi
	fi
fi
