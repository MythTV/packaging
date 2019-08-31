#!/bin/sh
# The following set of functions are borrowed from UCK and xdg-utils
# with minor modifications as well as a few written myself
#- Mario Limonciello, March 2007
#- Mike Bibbings July 2019 modifed due to removal of gksu,kdesudo,kdesu etc.
###################################################################

find_dialog()
{
DIALOG=`which zenity`

    if [ -z $DIALOG ]; then
        failure "You need zenity for first run of mythfrontend or mythtv-setup.\n Install with 'sudo apt install zenity'"
    fi
}

find_su()
{

SU=`which sudo`

    if [ -z "$SU" ]; then
        failure "You need sudo installed for first run of mythfrontend or mythtv-setup"
    fi
}

dialog_choose_file()
{
TITLE="$1"

$DIALOG --title "$TITLE" --file-selection "`pwd`/"
}

dialog_msgbox()
{
TITLE="$1"
TEXT="$2"
echo -n "$TEXT" | $DIALOG --title "$TITLE" --text-info --width=500 --height=400 2> /dev/null

}

dialog_question()
{
TITLE="$1"
TEXT="$2"
$DIALOG --title "$TITLE" --question --text "$TEXT" 2> /dev/null

}

failure()
{
echo "$@"
exit 1
}

check_groups()
{
if [ -n "$(groups | grep --invert-match mythtv)" ]
then
	if [ -e ~/.mythtv/ignoregroup ]
	then
		IGNORE_NOT=0
	else
		dialog_question "Incorrect Group Membership" "You must be a member of the \"mythtv\" group before starting any mythtv applications.\nWould you like to automatically be added to the group?\n(Note: sudo access required)"
		ADD_NOT=$?
		# 0 means that they do want in
		# 1 means that they don't want in
		if [ "$ADD_NOT" = "1" ]; then
			dialog_question "Incorrect Group Membership" "Would you like to disable this warning in the future and start anyway?"
			IGNORE_NOT=$?
			if [ "$IGNORE_NOT" = "0" ]; then
				mkdir -p ~/.mythtv
				touch ~/.mythtv/ignoregroup
			fi
		else
			run_sudo_command "adduser `whoami` mythtv"

            # add link from /etc/mythtv/config.xml to ~/.mythtv/config.xml if config.xml does not exist.
            link_configxml

			dialog_msgbox "MythTV" "For the changes to take effect, your current login session has to be restarted.\nPlease logout manually."

		fi
	fi
else
	IGNORE_NOT=0
fi
}

# replacement for obsolete gksu,kdesu etc.
# first parameter is command to run
# second parameter, if present, is used to force systemctl daemon-reload, before running the command
run_sudo_command()
{
# limit attempts to 3 for password
CNT=1
while [ $CNT -le 3 ]
do
if PASS=$($DIALOG --password --title "MythTV" 2> /dev/null); then
    if ! [ -z $PASS ]; then
        # check if password is valid
        echo "$PASS" | sudo -S -i -k pwd > /dev/null 2> /dev/null

        if ! [ $? -eq 0 ]; then
            # password is not valid: show warning
            CNT=$(( $CNT + 1 ))
            $DIALOG --warning --no-wrap --text "The password supplied was invalid!" --title "MythTV" 2> /dev/null

        else
            # password is valid: execute command
            # check if we need to force systemctl daemon-reload due to failed status, otherwise start mythtv-backend will fail
            if [ -n $2 ]; then
				echo "$PASS" | sudo -S -i -k systemctl daemon-reload 2> /dev/null
 	           # eval exit code of command
                if ! [ $? -eq 0 ]; then
                    $DIALOG --warning --no-wrap --text "The command systemctl daemon-reload  could not be executed!\n" --title "MythTV" 2> /dev/null
                	return
                fi
			fi
            #
            echo "$PASS" | sudo -S -i -k $1 2> /dev/null
            # eval exit code of command
            if ! [ $? -eq 0 ]; then
                $DIALOG --warning --no-wrap --text "The command $1  could not be executed!\n" --title "MythTV" 2> /dev/null
            fi
            return
        fi
    else
        # empty password: show warning
        CNT=$(( $CNT + 1 ))
        $DIALOG --warning --no-wrap --text "An empty password was supplied!" --title "MythTV" 2> /dev/null
    fi
else
# if password entry cancelled assume user cancelled whole operation
    return
fi
done
}

# checks and links /etc/mythtv/config.xml to ~/.mythtv/ if ~/.mythtv/config.xml does not exist
link_configxml()
{
        if ! [ -f ~/.mythtv/config.xml ]; then
            mkdir -p ~/.mythtv
            ln -s -f /etc/mythtv/config.xml ~/.mythtv/config.xml
        fi
}

###################################################################

