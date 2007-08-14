#!/bin/sh
# Mario Limonciello, March 2007

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#find the session, dialog, and su manager we will be using for display
find_session
find_dialog
find_su

#check that we are in the mythtv group
check_groups

#if group membership is okay, go ahead and launch
if [ "$IGNORE_NOT" = "0" ]; then
	exec /usr/bin/mythfrontend.real "$@"
fi
