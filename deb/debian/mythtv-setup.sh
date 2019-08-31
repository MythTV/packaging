#!/bin/sh
# Mario Limonciello, March 2007
# Mathieu Laurendeau, January 2016
# Mike Bibbings July 2019

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
  ' -- "$1" 2> /dev/null
}
DBHost="$(getXmlParam Host)" 2> /dev/null
DBUserName="$(getXmlParam UserName)" 2> /dev/null
DBPassword="$(getXmlParam Password)" 2> /dev/null
DBName="$(getXmlParam DatabaseName)" 2> /dev/null

#get mythfilldatabase arguments
mbargs=$(mysql -N \
 --host="$DBHost" \
 --user="$DBUserName" \
 --password="$DBPassword" \
 "$DBName" \
 --execute="SELECT data FROM settings WHERE value = 'MythFillDatabaseArgs';" \
) 2> /dev/null

#find the dialog and su manager we will be using for display
find_dialog
find_su

#check that we are in the mythtv group
check_groups


#if group membership is okay, go ahead and continue
if [ "$IGNORE_NOT" = "0" ]; then
	RUNNING=$(systemctl status mythtv-backend | grep running)
    WAS_FAILED=$(systemctl status mythtv-backend | grep failed)
	if [ -n "$RUNNING" ]; then
		dialog_question "MythTV" "Mythbackend must be closed before continuing.\nIs it OK to close any currently running mythbackend processes?" 2> /dev/null
		CLOSE_NOT=$?
	else
		CLOSE_NOT=0
	fi
	if [ "$CLOSE_NOT" = "0" ]; then
		if [ -n "$RUNNING" ]; then
				run_sudo_command "systemctl stop mythtv-backend"
		fi
		xterm -title "MythTV Setup Terminal" -e taskset -c 0 /usr/bin/mythtv-setup.real --syslog local7 "$@"
 	    RUNNING=$(systemctl status mythtv-backend | grep running)
		if [ -z "$RUNNING" ]; then
			dialog_question "MythTV" "Would you like to start the mythtv backend?" 2> /dev/null
			START_NOT=$?
		else
			START_NOT=0
		fi

		if [ "$START_NOT" = "0" ]; then
				run_sudo_command "systemctl start mythtv-backend" $WAS_FAILED
		fi

		dialog_question "Fill Database?" "Would you like to run mythfilldatabase?" 2> /dev/null
		DATABASE_NOT=$?

		if [ "$DATABASE_NOT" = "0" ]; then
			xterm -title "Running mythfilldatabase" -e "unset DISPLAY && unset SESSION_MANAGER && mythfilldatabase $mbargs; sleep 3"
		fi
	fi
fi

