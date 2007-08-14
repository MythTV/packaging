#!/bin/sh
# The following set of functions are borrowed from UCK and xdg-utils
# with minor modifications as well as a few written myself
#- Mario Limonciello, March 2007
###################################################################

find_dialog()
{
        if [ -z "$DIALOG" ] ; then
                DIALOG=`which zenity`

                if [ ! -z "$DIALOG" ]; then
                        DIALOG_TYPE=zenity
                fi
        fi

        if [ -z "$DIALOG" ]; then
                DIALOG=`which kdialog`

                if [ ! -z "$DIALOG" ]; then
                        DIALOG_TYPE=kdialog
                fi
        fi

        if [ -z $DIALOG ]; then
                failure "You need zenity or kdialog installed to run mythfrontend"
        fi
}

find_session()
{
    if [ x"$KDE_FULL_SESSION" = x"true" ]; then 
	DE=kde;
	DIALOG=`which kdialog`;
	DIALOG_TYPE=kdialog;
        SU=`which kdesu`
	SU_TYPE=kdesu	
    elif [ x"$GNOME_DESKTOP_SESSION_ID" != x"" ]; then 
	DE=gnome;
	DIALOG=`which zenity`;
	DIALOG_TYPE=zenity;
        SU=`which gksu`
	SU_TYPE=gksu
    elif xprop -root _DT_SAVE_MODE | grep ' = \"xfce4\"$' >/dev/null 2>&1; then 
	DE=xfce;
	DIALOG=`which zenity`;
	DIALOG_TYPE=zenity;
        SU=`which gksu`
	SU_TYPE=gksu
    fi
}

find_su()
{
        if [ -z "$SU" ] ; then
                SU=`which gksu`

                if [ -z "$SU_TYPE" ]; then
                        SU_TYPE=gksu
                fi
        fi

        if [ -z "$SU" ]; then
                SU=`which kdesu`

                if [ -z "$SU_TYPE" ]; then
                        SU_TYPE=kdesu
                fi
        fi

        if [ -z "$SU_TYPE" ]; then
                failure "You need gksu or kdesu installed to run mythfrontend"
        fi
}

dialog_choose_file()
{
        TITLE="$1"

        if [ "$DIALOG_TYPE" = "zenity" ] ; then
                $DIALOG --title "$TITLE" --file-selection "`pwd`/"
        else
                if [ "$DIALOG_TYPE" = "kdialog" ] ; then
                        $DIALOG --title "$TITLE" --getopenfilename "`pwd`/"
                else
                        $DIALOG --stdout --title "$TITLE" --fselect "`pwd`/" 20 80
                fi
        fi
}

dialog_msgbox()
{
        TITLE="$1"
        TEXT="$2"

        if [ "$DIALOG_TYPE" = "zenity" ]; then
                echo -n "$TEXT" | $DIALOG --title "$TITLE" --text-info --width=500 --height=400
        else
                $DIALOG --title "$TITLE" --msgbox "$TEXT" 20 80
        fi
}

dialog_question()
{
        TITLE="$1"
        TEXT="$2"

        if [ "$DIALOG_TYPE" = "zenity" ]; then
                $DIALOG --title "$TITLE" --question --text "$TEXT"
        else
                $DIALOG --title "$TITLE" --yesno "$TEXT" 20 80
        fi
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
			if [ "$DE" = "kde" ]; then
				$SU_TYPE adduser `whoami` mythtv
			else
				$SU_TYPE adduser `whoami` mythtv --message "Please enter your current login password to add `whoami` to the mythtv group."
			fi
			dialog_question "Log out/in" "For the changes to take effect, your current login session will have to be restarted.  Save all work and then press OK to restart your session."
			LOGOUT_NOT=$?
			if [ "$LOGOUT_NOT" = "0" ]; then
				if [ "$DE" = "gnome" ]; then
					gnome-session-save --kill
				elif [ "$DE" = "kde" ]; then
					dcop ksmserver ksmserver logout 0 0 0
				elif [ "$DE" = "xfce" ]; then
					xfce4-session-logout
				else
					dialog_msgbox "No running KDM/Gnome/Xfce" "Please manually log out of your session for the changes to take effect."
				fi
				#exit in case they hit cancel here
				exit 2
			else		
				exit 3			
			fi
		fi
	fi
else
	IGNORE_NOT=0
fi
}
###################################################################

