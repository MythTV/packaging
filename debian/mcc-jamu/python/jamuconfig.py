## -*- coding: utf-8 -*-
## File name: jamuconfig.py
## Jamu (Just.Another.Metadata.Utility) - Mythbuntu mcc plugin
## Purpose: This plugin allows a user to create and modify the ~mythtv/.mythtv/jamu.conf file
## Author: R.D.Vaughan
## Original source was Mario Limonciello's "skeletory.py" mcc example
#
# «skeletor» - An Example Plugin for showing how to use MCC as a developer
#
# Copyright (C) 2009, Mario Limonciello, for Mythbuntu
#
#
# Mythbuntu is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this application; if not, write to the Free Software Foundation, Inc., 51
# Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##################################################################################

__version__ = u"0.1.3"
# 0.0.1 -   Initial development
# 0.0.2 -   Alpha development version
# 0.0.3 -   Phase 2 development version - Adding TV Series Movie Title Override screens and logic
#           Also fixed a bug where the logger was called before it was actually initialized
# 0.1.0 -   Beta release of Phase 1 - Only essential jamu.conf editing other logic removed
# 0.1.1 -   Changed the plug-in icon to "gtk-add"
# 0.1.2 -   Handle issues when the MythTV backend is not accessable with appropriate messages and logic.
#           Also commented out code not currently used with this release of this plugin.
# 0.1.3 -   Added detection that the Live CD is being used and the plugin exists

from MythbuntuControlCentre.plugin import MCCPlugin
import gtk

import sys, os
import logging


class JamuconfigPlugin_error(Exception):
    """An error which stops the jamu MCC plugin from functioning
    """
    pass

class JamuconfigPlugin(MCCPlugin):
    """A Jamu Configuration Plugin to create and modify ~mythtv/.mythtv/jamu.conf settings"""
    #
    #Load GUI & Calculate Changes
    #
    def __init__(self):
        #Initialize parent class
        information = {}
        information["name"] = "Jamuconfig"
        information["icon"] = "gtk-add"
        information["ui"] = "tab_jamuconfig"

        #Detect if booted from Live CD, exit is this is true. This plugin cannot be run from a Live CD boot.
        lines=[]
        try:
            file = open('/proc/cmdline')    # Open for output (to read only)
            lines = file.readlines( )       # Read entire file into list of line strings
            file.close( )                   # Flush output buffers to disk
            if lines[0].find('boot=casper') != -1:
                print "This is a Live CD boot, the Jamu MCC plugin cannot be run from the Live CD"
                sys.exit(0)
        except Exception, e:
            print 'An exception occured while trying to read the "/proc/cmdline" file to detect a Live CD boot.\nError (%s)' % e
            sys.exit(1)

        self.settings_initialized = True    # Popular the screen variable on initial display

        # Create logger
        self.logger = logging.getLogger("jamuconf")
        self.logger.setLevel(logging.DEBUG)

        hdlr = logging.FileHandler(u'/tmp/Mythbuntu_jamu_plugin.log')
        formatter = logging.Formatter(u"%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        hdlr.setFormatter(formatter)
        self.logger.addHandler(hdlr)

        import jamuconfiguration
        self.jamuconf = jamuconfiguration.jamuconf()
        self.jamuconf.logger = self.logger

        self.jamuconf.accessMythDB()
        if self.jamuconf.mythdb == None:
            errormsg = u"Jamu configuration plugin must have access to the MythTV database. Check the logs for messages indicating the issue.\nAlso note that this plugin CANNOT be run from a Live CD disk as nothing can be updated!\n"
            self.logger.critical(errormsg)
            raise JamuconfigPlugin_error(errormsg)

        if not self.jamuconf.mythdb.getSetting('BackendServerIP', hostname = self.jamuconf.localhostname):
            errormsg = u"Jamu configuration plugin must be run on a MythTV backend. Local host (%s) is not a MythTV backend.\n" % self.jamuconf.localhostname
            self.logger.critical(errormsg)
            raise JamuconfigPlugin_error(errormsg)

        # Create a jamu.conf if it does not exist and read in the current settings
        (self.cfg, self.config) = self.jamuconf.jamuconfig(u'mythtv', create=True)
        if self.config == None:
            errormsg = u'A jamu.conf file could not be read. No processing is possible - Check the log for details'
            self.logger.critical(errormsg)
            raise JamuconfigPlugin_error(errormsg)
        self.tvdb_tmdb = self.jamuconf.findGrabbers()
        if self.tvdb_tmdb[0] == None or self.tvdb_tmdb[1] == None:
            errormsg = u'Either the ttvdb.py and/or tmdb.py metadata grabber scripts are not installed - Check the log for details'
            self.logger.critical(errormsg)
            raise JamuconfigPlugin_error(errormsg)

        # If the backend is down or inaccessable then do not try to read the Scheduled TV shows
        # NOTE: These lines of code have been commented out as this functionaly is only necessary for
        #        a feature that has not been implemented yet.
#        if self.jamuconf.mythbeconn == None:
#            errormsg = u"The MythTV backend is not accessable or not running.\nSome plugin functionality will not be available as it requires a running MythTV backend.\n"
#            self.logger.critical(errormsg)
#            raise JamuconfigPlugin_error(errormsg)
#        if self.jamuconf.mythbeconn != None:
#            self.scheduledprograms = self.jamuconf.getScheduledTvShowsMovies()

        self.conjobstatus = {'maint_checkbutton': [u'-M ', u'/etc/cron.daily/mythvideo', False, False], 'tvprog_checkbutton': [u'-MW ', u'/etc/cron.hourly/mythvideo', False, False], 'janitor_checkbutton': [u'-MJ ', u'/etc/cron.weekly/mythvideo', False, False], 'nfs_checkbutton': [u'', u'', False, False], }
        for key in self.conjobstatus.keys():
            if key == 'nfs_checkbutton':
                continue
            else:
                result = self.jamuconf.getCronJobStatus(self.conjobstatus[key])
                self.conjobstatus[key][2] = result[0]
                if result[1]:
                    self.conjobstatus['nfs_checkbutton'][2] = True        # At least one cronjob has a NFS flag

        MCCPlugin.__init__(self, information)
    # end __init__()


    def captureState(self):
        """Determines the state of the items on managed by this plugin
            and stores it into the plugin's own internal structures"""
        import os
        if self.settings_initialized:
            self.initailizeSettings()
            self.settings_initialized = False
        self.changes = {}
        self.changes['maint_checkbutton'] = self.maint_checkbutton.get_active()
        self.changes['tvprog_checkbutton'] = self.tvprog_checkbutton.get_active()
        self.changes['janitor_checkbutton'] = self.janitor_checkbutton.get_active()
        self.changes['nfs_checkbutton'] = self.nfs_checkbutton.get_active()
        self.changes['lang_combobox'] = self.lang_combobox.get_active()
    # end captureState()


    def applyStateToGUI(self):
        """Takes the current state information and sets the GUI
            for this plugin"""
        self.maint_checkbutton.set_active(self.changes['maint_checkbutton'])
        self.tvprog_checkbutton.set_active(self.changes['tvprog_checkbutton'])
        self.janitor_checkbutton.set_active(self.changes['janitor_checkbutton'])
        self.nfs_checkbutton.set_active(self.changes['nfs_checkbutton'])
        self.lang_combobox.set_active(self.changes['lang_combobox'])
    # end applyStateToGUI()


    def compareState(self):
        """Determines what items have been modified on this plugin"""
        MCCPlugin.clearParentState(self)
        if self.maint_checkbutton.get_active() != self.changes['maint_checkbutton']:
            self._markReconfigureRoot('maint_checkbutton', self.maint_checkbutton.get_active())
        if self.tvprog_checkbutton.get_active() != self.changes['tvprog_checkbutton']:
            self._markReconfigureRoot('tvprog_checkbutton', self.tvprog_checkbutton.get_active())
        if self.janitor_checkbutton.get_active() != self.changes['janitor_checkbutton']:
            self._markReconfigureRoot('janitor_checkbutton', self.janitor_checkbutton.get_active())
        if self.nfs_checkbutton.get_active() != self.changes['nfs_checkbutton']:
            self._markReconfigureRoot('nfs_checkbutton', self.nfs_checkbutton.get_active())
        if self.lang_combobox.get_active() != self.changes['lang_combobox']:
            self._markReconfigureRoot('lang_change', self.jamuconf.languages[self.lang_combobox.get_active()][0])
    # end compareState()


    def initailizeSettings(self):
        """Initalize the tab values from the values in jamu.conf
            This function will be ran by the frontend"""
        self.maint_checkbutton.set_active(self.conjobstatus['maint_checkbutton'][2])
        self.tvprog_checkbutton.set_active(self.conjobstatus['tvprog_checkbutton'][2])
        self.janitor_checkbutton.set_active(self.conjobstatus['janitor_checkbutton'][2])
        self.nfs_checkbutton.set_active(self.conjobstatus['nfs_checkbutton'][2])

        self.lang_combobox.remove_text(0)    # Remove the empty initial first element

        # Check that the font pack to display asian fonts are installed
        asian_lang = {'zh': [False, u'Chinese'], 'ja': [False, u'Japanese'], 'ko': [False, u'Korean']}
        #ttf-wqy-zenhei   "WenQuanYi Zen Hei" A Hei-Ti Style (sans-serif) Chinese font - Can also handle ja & ko
        for key in asian_lang.keys():
            if self.query_installed('ttf-wqy-zenhei'):
                asian_lang[key][0] = True
            else:
                asian_lang[key][0] = self.query_installed('language-support-fonts-%s' % key)

        # When the corect language fonts are not installed substitute English labels
        for key in asian_lang.keys():
            for lang in self.jamuconf.languages:
                if lang[0] == key and not asian_lang[key][0]:
                    lang[2] = asian_lang[key][1]

        # Populate the choice of languages
        for lang in self.jamuconf.languages:
            self.lang_combobox.append_text(lang[2])

        # Set the current active langauage selection use "Default" if it was not set in jamu.conf
        index = 0
        if self.cfg.has_option(u'variables', 'local_language'):
            conf_lang = self.cfg.get(u'variables', 'local_language')
            for lang in self.jamuconf.languages:
                if conf_lang == lang[0]:
                    break
                index+=1
            else:
                index = 0
        self.lang_combobox.set_active(index)
    # end initailizeSettings()


    #
    # Process selected activities
    #

    def root_scripted_changes(self,reconfigure):
        """System-wide changes that need root access to be applied.
            This function is ran by the dbus backend"""
        #
        # Cronjob related changes
        #
        cron_job_change = False
        for item in reconfigure:
            if item in self.conjobstatus.keys():
                self.conjobstatus[item][2] = reconfigure[item]
                self.conjobstatus[item][3] = True
                cron_job_change = True
        # Apply any cronjob changes
        if cron_job_change:
            self.jamuconf.setCronJobStatus(self.conjobstatus)

        #
        # jamu.conf file changes
        #
        conf_change = False
        # Language change
        if reconfigure.has_key('lang_change'):
            if not self.config[u'configchangeflag'].has_key(u'variables'):
                self.config[u'configchangeflag'][u'variables'] = {}
            self.config[u'configchangeflag'][u'variables']['local_language'] = reconfigure['lang_change']
            conf_change = True

        # Apply any jamu.conf changes
        if conf_change:
            self.jamuconf.writeJamuConf(self.config[u'configchangeflag'], self.cfg)
    # end root_scripted_changes()


    def user_scripted_changes(self,reconfigure):
        """Local changes that can be performed by the user account.
            This function will be run by the frontend"""
        # No jamu config changes can be done at the user level
        pass


    #
    # Callbacks
    #
    def launch_app(self, widget):
        """Launches the Jamu overrides configuration application"""
        if widget is not None:
            if widget.get_name() == "overrides_button":
                MCCPlugin.launch_app(self, widget, '/media/Plugins/source/python/jamu_overrides.py "~/.mythtv/jamu.conf"')

    # end launch_app()
