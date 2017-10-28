#!/bin/sh
# Mario Limonciello, March 2007
# Mathieu Laurendeau, January 2016

#source our dialog functions
. /usr/share/mythtv/dialog_functions.sh

#get database info
getXmlParam() {
  perl -e '
    use XML::Simple;
    use Data::Dumper;
    $xml = new XML::Simple;
    $data = $xml->XMLin("/etc/mythtv/config.xml");
    print "$data->{Database}->{$ARGV[0]}\n";
  ' -- "$1"
}
DBHost="$(getXmlParam Host)"
DBUserName="$(getXmlParam UserName)"
DBPassword="$(getXmlParam Password)"
DBName="$(getXmlParam DatabaseName)"

#get mythfilldatabase arguments
mbargs=$(mysql -N \
 --host="$DBHost" \
 --user="$DBUserName" \
 --password="$DBPassword" \
 "$DBName" \
 --execute="SELECT data FROM settings WHERE value = 'MythFillDatabaseArgs';" \
)

#find the session, dialog and su manager we will be using for display
find_session
find_dialog
find_su

#check that we are in the mythtv group
check_groups

#if group membership is okay, go ahead and continue
if [ "$IGNORE_NOT" = "0" ]; then
	RUNNING=$(ps -A | grep mythbackend)
	if [ -n "$RUNNING" ]; then
		dialog_question "MythTV Setup Preparation" "Mythbackend must be closed before continuing.\nIs it OK to close any currently running mythbackend processes?"
		CLOSE_NOT=$?
	else
		CLOSE_NOT=0
	fi
	if [ "$CLOSE_NOT" = "0" ]; then
		if [ -n "$RUNNING" ]; then
			if [ "$DE" = "kde" ]; then
				$SU_TYPE /usr/sbin/service mythtv-backend stop
			else
				$SU_TYPE /usr/sbin/service mythtv-backend stop --message "Please enter your current login password to stop mythtv-backend."
			fi
		fi
		xterm -title "MythTV Setup Terminal" -e taskset -c 0 /usr/bin/mythtv-setup.real --syslog local7 "$@"
		if [ -z "$RUNNING" ]; then
			dialog_question "Start backend" "Would you like to start the mythtv backend?"
			START_NOT=$?
		else
			START_NOT=0
		fi
		if [ "$START_NOT" = "0" ]; then
			if [ "$DE" = "kde" ]; then
				$SU_TYPE /usr/sbin/service mythtv-backend start
			else
				$SU_TYPE /usr/sbin/service mythtv-backend start --message "Please enter your current login password to start mythtv-backend."
			fi
		fi
		dialog_question "Fill Database?" "Would you like to run mythfilldatabase?"
		DATABASE_NOT=$?
		if [ "$DATABASE_NOT" = "0" ]; then
			xterm -title "Running mythfilldatabase" -e "unset DISPLAY && unset SESSION_MANAGER && mythfilldatabase $mbargs; sleep 3"
		fi
	fi
fi
