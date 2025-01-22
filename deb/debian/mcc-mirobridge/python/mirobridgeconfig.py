## -*- coding: utf-8 -*-
## File name: mirobridgeconfig.py
## Mirobridge (Just.Another.Metadata.Utility) - Mythbuntu mcc plugin
## Purpose: This plugin allows a user install/uninstall and configure MiroBridge and its dependancies
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

__version__ = u"0.1.2"
# 0.0.1 - Initial development
# 0.1.0 - Public release
# 0.1.1 - Added detection that the Live CD is being used and the plugin exists
# 0.1.2 - Changed the gtk icon

from MythbuntuControlCentre.plugin import MCCPlugin
import gtk

import sys, os, ConfigParser, subprocess, shutil, pwd, datetime
import urllib2
import logging
from socket import gethostname, gethostbyname
import tarfile

# Added for the crontab functions (os and sys) were already in the mirobridge.py script
import re, tempfile


class MirobridgeconfigPlugin_error(Exception):
    """An error which stops the MiroBridge MCC plugin from functioning
    """
    pass

class MirobridgeconfigPlugin(MCCPlugin):
    """A Mirobridge Configuration Plugin to install/uninstall and configure MiroBridge and its dependancies"""
    #
    #Load GUI & Calculate Changes
    #
    def __init__(self):
        #Initialize parent class
        information = {}
        information["name"] = "Mirobridgeconfig"
        information["icon"] = "gtk-media-play-ltr"
        information["ui"] = "tab_mirobridge"

        #Detect if booted from Live CD, exit is this is true. This plugin cannot be run from a Live CD boot.
        lines=[]
        try:
            file = open('/proc/cmdline')    # Open for output (to read only)
            lines = file.readlines( )       # Read entire file into list of line strings
            file.close( )                   # Flush output buffers to disk
            if lines[0].find('boot=casper') != -1:
                print "This is a Live CD boot, the MiroBridge MCC plugin cannot be run from the Live CD"
                sys.exit(0)
        except Exception, e:
            print 'An exception occured while trying to read the "/proc/cmdline" file to detect a Live CD boot.\nError (%s)' % e
            sys.exit(1)

        self.settings_initialized = True    # Popular the screen variable on initial display

        # Create logger
        self.logger = logging.getLogger("mirobridgeconf")
        self.logger.setLevel(logging.DEBUG)

        hdlr = logging.FileHandler(u'/tmp/Mythbuntu_mirobridge_plugin.log')
        formatter = logging.Formatter(u"%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        hdlr.setFormatter(formatter)
        self.logger.addHandler(hdlr)

        self.mbfunctions = MirobridgeConfigFunctions(self.logger)

        MCCPlugin.__init__(self, information)
    # end __init__()


    def captureState(self):
        """Determines the state of the items managed by this plugin
        and stores it into the plugin's own internal structures
        """
        # Set the current condition of the MiroBridge installation and configuration
        self.mbfunctions.isInstalled()


        ### Used for debugging only. Usually commented out.
#        print '-----------------------'
#        print self.mbfunctions.config
#        print '-----------------------'


        self.changes = {}
        if self.settings_initialized:
            self.initialiseComboBoxLists()
            self.settings_initialized = False

        # Always reset active items according to the current installation conditions
        self.initialiseSettings()

        self.changes['enable_disable_combobox'] = self.enable_disable_combobox.get_active()
        self.changes['cronjob_freq_combobox'] = self.cronjob_freq_combobox.get_active()
        self.changes['behaviour_combobox'] = self.behaviour_combobox.get_active()

        # Force Step #2 so the user initiates Miro at least once incase the Miro package was re-installed
        if self.install_checkbutton.get_active() and self.mbfunctions.config['miro_test_passed']:
            self.mbfunctions.config['miro_test_passed'] = False

        # Always reset both check buttons to off for every screen rest. Stops both checked boxes being set.
        # for both (install/uninstall)
        self.changes['install'] = False
        self.changes['uninstall'] = False

        # Hide/Show UI objects depending on whether MiroBridge is installed or not
        if not self.mbfunctions.config['installed']:
            # Step #1: Something is missing and must be installed
            self.install_checkbutton.show()
            self.launch_miro_button.hide()
            self.import_opml_filechooserbutton.hide()
            self.uninstall_checkbutton.hide()
            self.enable_disable_combobox.hide()
            self.cronjob_freq_combobox.hide()
            self.behaviour_combobox.hide()
        elif not self.mbfunctions.config['miro_test_passed']:
            self.install_checkbutton.hide()
            self.launch_miro_button.show()
            # Step #2: Configure Miro Channels and options
            self.launch_miro_button.set_label(u'Step #2: Configure Miro Channels and options')
            self.import_opml_filechooserbutton.hide()
            self.uninstall_checkbutton.hide()
            self.enable_disable_combobox.hide()
            self.cronjob_freq_combobox.hide()
            self.behaviour_combobox.hide()
        else:
            # Regular maintenance/configuratio options
            self.install_checkbutton.hide()
            self.launch_miro_button.show()
            self.launch_miro_button.set_label(u'Launch Miro (Channel Add/Change/Delete)')
            self.import_opml_filechooserbutton.show()
            self.uninstall_checkbutton.show()
            self.enable_disable_combobox.show()
            self.cronjob_freq_combobox.show()
            self.behaviour_combobox.show()
    # end captureState()


    def applyStateToGUI(self):
        """Takes the current state information and sets the GUI
            for this plugin"""
        self.enable_disable_combobox.set_active(self.changes['enable_disable_combobox'])
        self.cronjob_freq_combobox.set_active(self.changes['cronjob_freq_combobox'])
        self.behaviour_combobox.set_active(self.changes['behaviour_combobox'])
        self.install_checkbutton.set_active(self.changes['install'])
        self.uninstall_checkbutton.set_active(self.changes['uninstall'])
    # end applyStateToGUI()


    def compareState(self):
        """Determines what items have been modified on this plugin"""
        MCCPlugin.clearParentState(self)
        if self.enable_disable_combobox.get_active() != self.changes['enable_disable_combobox']:
            if self.enable_disable_combobox.get_active() == 0:
                self._markReconfigureUser('enable_disable', True)
            else:
                self._markReconfigureUser('enable_disable', False)
        if self.cronjob_freq_combobox.get_active() != self.changes['cronjob_freq_combobox']:
            self._markReconfigureUser('cronjob_freq', self.cronjob_freq_combobox.get_active())
        if self.behaviour_combobox.get_active() != self.changes['behaviour_combobox']:
            self._markReconfigureUser('behaviour', self.behaviour_combobox.get_active())
        if self.install_checkbutton.get_active() != self.changes['install']:
            self._markReconfigureUser('install', self.install_checkbutton.get_active())
            if self.install_checkbutton.get_active():
                for package in self.mbfunctions.config['dependancies'].keys():
                    if not self.mbfunctions.config['dependancies'][package] and not package in self._to_install:
                       self._markInstall(package, install=True) # Add a missing package to install
            else:
                for package in self.mbfunctions.config['dependancies'].keys():
                    if package in self._to_install:
                       self._markInstall(package, install=False) # User cancelled install
        if self.uninstall_checkbutton.get_active() != self.changes['uninstall']:
            self._markReconfigureUser('uninstall', self.uninstall_checkbutton.get_active())
            # Only the 'miro' package is uninstalled as the others are common and could be being used
            # by other installed apps
            package = 'miro'
            if self.uninstall_checkbutton.get_active():
                if not package in self._to_remove:
                   self._markRemove(package, remove=True) # A package to add to uninstall
            else:
                if package in self._to_remove:
                   self._markRemove(package, remove=False) # A package to remove from uninstall list
    # end compareState()


    def initialiseSettings(self):
        """Initalize the tab values from the values in found during the MiroBridge installation/config check.
        This function will be ran by the frontend.
        """
        # Set the active values
        if self.mbfunctions.config['cronjob']:
            self.enable_disable_combobox.set_active(0)
        else:
            self.enable_disable_combobox.set_active(1)

        self.cronjob_freq_combobox.set_active(0)
        if self.mbfunctions.config['cronjob_freq']:
            for index in range(len(self.mbfunctions.cronjob_freq)):
                if self.mbfunctions.cronjob_freq[index].lower() == self.mbfunctions.config['cronjob_freq']:
                    self.cronjob_freq_combobox.set_active(index)
                    break
            else:
                self.cronjob_freq_combobox.set_active(0)

        index = 0
        if self.mbfunctions.config['cfg']:
            conflict_count = 0 # Check to see if there are conflicting "All" options in the config file
            for section in self.mbfunctions.config['cfg'].sections():
                if section == u'watch_only':
                    # All Channels will only not be moved to MythVideo
                    for option in self.mbfunctions.config['cfg'].options(section):
                        if option == u'all miro channels':
                            index = 1
                            conflict_count+=1
                            break
                        else:
                            continue
                    continue
                if section == u'mythvideo_only':
                    # Add the Channel names to the array of Channels that will be moved to MythVideo only
                    for option in self.mbfunctions.config['cfg'].options(section):
                        if option == u'all miro channels':
                            index = 2
                            conflict_count+=1
                            break
                        else:
                            continue
                    continue
                if section == u'watch_then_copy':
                    # Add the Channel names to the array of Channels once watched will be copied to MythVideo
                    for option in self.mbfunctions.config['cfg'].options(section):
                        if option == u'all miro channels':
                            index = 3
                            conflict_count+=1
                            break
                        else:
                            continue
                    continue
            if conflict_count > 1:
                errormsg = "Conflicting MiroBridge behavior options found. Only one 'all miro channels' can be set at a time.\nResetting to the default of no 'all miro channels'.\n"
                self.logger.error(errormsg)
                index = 0
        self.behaviour_combobox.set_active(index)
    # end initialiseSettings()

    def initialiseComboBoxLists(self):
        '''Set the list values in the combo boxes
        '''
        self.enable_disable_combobox.remove_text(0)    # Remove the empty initial first element
        self.cronjob_freq_combobox.remove_text(0)    # Remove the empty initial first element
        self.behaviour_combobox.remove_text(0)    # Remove the empty initial first element

        # Populate the choice of Cronjob enable/disable list
        for value in self.mbfunctions.cronjob:
            self.enable_disable_combobox.append_text(value)
        # Populate the choice of Cronjob frequency
        for value in self.mbfunctions.cronjob_freq:
            self.cronjob_freq_combobox.append_text(value)
        # Populate the choice of MiroBridge processing behaviour
        for value in self.mbfunctions.behaviour:
            self.behaviour_combobox.append_text(value)
    # end initialiseComboBoxLists()

    #
    # Front end : Process selected activities
    #

    def user_scripted_changes(self,reconfigure):
        """Local changes that can be performed by the user account.
        This function will be run by the frontend
        """
        #
        # Install MiroBridge configuration components
        #
        if reconfigure.has_key('install'):
            if reconfigure['install']:  # Set defaults
                if self.mbfunctions.config['mirochannel'] == None:
                    self.mbfunctions.addMiroBridgeChannel()
                self.mbfunctions.maintCronjobs('enable_disable', True)
                self.mbfunctions.maintCronjobs('cronjob_freq', 0)
                if not self.mbfunctions.config['cfg']: # If a conf file does not exist then use the example
                    self.mbfunctions.readExampleConf(self.mbfunctions.location_mirobridge_example_conf_file)
                    self.mbfunctions.maintConfigFile('behaviour', 0)
                self.mbfunctions.installDefaultImages()
        #
        # Uninstall MiroBridge configuration components
        # NOTE: Uninstall does not remove any existing Watch Recordings or MythVideo records or video files
        #
        elif reconfigure.has_key('uninstall'):
            if reconfigure['uninstall']:
                # Remove any the Mirobridge default images/Channel image/Folder image
                for key in self.mbfunctions.image_set.keys():
                    filepath = u'%s%s' % (self.mbfunctions.vid_graphics_dirs[key], self.mbfunctions.image_set[key])
                    if os.path.isfile(filepath):
                        os.remove(filepath)
                # Remove any mirobridge cronjobs
                self.mbfunctions.maintCronjobs('enable_disable', False)
                # Remove any mirobridge.conf file
                filename = os.path.expanduser("~")+u'/.mythtv/mirobridge.conf'
                if os.path.isfile(filename):
                    os.remove(filename)
                # Remove the MiroBridge Channel record if it exists
                channel = self.mbfunctions.MythDB(self.mbfunctions.mythdb).getChannel(9999)
                if channel['channum'] != None:
                    if channel['channum'] == '999' and channel['name'] == 'Miro':
                        self.mbfunctions.delChannel()
        #
        # Add/Change MiroBridge cronjob
        # Add/Change mirobridge.conf
        #
        else:
            for key in ['enable_disable', 'cronjob_freq']: # cronjob maintenance
                if reconfigure.has_key(key):
                    self.mbfunctions.maintCronjobs(key, reconfigure[key])
            if reconfigure.has_key('behaviour'): # mirobridge.conf maintenance
                self.mbfunctions.maintConfigFile('behaviour', reconfigure['behaviour'])
    # end user_scripted_changes()


    #
    # Callbacks
    #
    def callBacks(self, widget):
        """React to various button clicks or files selected
        """
        if widget is not None:
            if widget.get_name() == "launch_miro_button":
                MCCPlugin.launch_app(self, widget, 'miro')
                self.captureState()
            elif widget.get_name() == "import_opml_filechooserbutton":
                filename = self.import_opml_filechooserbutton.get_filename()
                if filename:
                    (dirName, fileName) = os.path.split(filename)
                    (fileBaseName, fileExtension)=os.path.splitext(fileName)
                    if not fileExtension.endswith(u'.opml'):
                        self.logger.error(u'The OPML import file must have an extension of ".opml", the selected file has an extension of (%s)' % fileExtension)
                    elif os.path.isfile(filename):
                        MCCPlugin.launch_app(self, widget, u'%s -i "%s"' % (self.mbfunctions.location_mirobridge_script, filename))
                    else:
                        self.logger.error(u'The import file(%s) does not exist' % filename)
    # end launch_app()


    #
    # Back end : Process selected activities
    #
    def root_scripted_changes(self,reconfigure):
        """System-wide changes that need root access to be applied.
        This function is run by the dbus backend
        """
        # No root specific config changes required
        pass
    # end root_scripted_changes()


############################################################################################################
# MiroBridge MCC support functions
############################################################################################################

class MirobridgeConfigFunctions():
    """A set of funtions that perform various tasks with the Mirobridge Configuration"""
    #
    # Evaluate the current installation of MiroBridge
    #
    def __init__(self, logger):
        self.logger = logger
        # Test and initialize the current configuration dictionary
        self.local_only = True # Default setting that determines to use local directories or storage groups
        self.accessMythDB() # Test that this is a BE
        # Test that there is internet access
        self.checkInternetAccess()
        # Option lists for UI selection
        self.cronjob = [u'Enabled', u'Disabled']
        self.cronjob_freq = [u'Hourly', u'Daily', u'Weekly']
        self.cronjob_keys = [u'hourly', u'daily', u'weekly']
        self.behaviour = [
            u'Default: Emulate Miro video processing',
            u'Watched Recordings screen only',
            u'Copy all Miro videos directly to MythVideo',
            u'Watch Miro videos then copy to MythVideo',
            ]
        self.behaviour_section = [
            u'default',
            u'watch_only',
            u'mythvideo_only',
            u'watch_then_copy',
            ]
        self.cron_regx = [
            # Hourly "?? * * * *"
            re.compile(u'''[0-9]|[0-9] \* \* \* \*''', re.UNICODE),
            # Daily "* ?? * * *"
            re.compile(u'''\* [0-9]|[0-9] \* \* \*''', re.UNICODE),
            # Weekly "* * * * ??"
            re.compile(u'''\* \* \* \* [0-9]|[0-9]''', re.UNICODE),
        ]
    # end __init__()

    def accessMythDB(self):
        '''Initialize MythTV python bindings
        return nothing
        '''
        # Find out if the MythTV python bindings can be accessed and instances can be created
        try:
            '''If the MythTV python interface is found, we can insert data directly to MythDB or
            get the directories to store poster, fanart, banner and episode graphics.
            '''
            from MythTV import MythDB, MythBE, Channel, MythError, MythLog, MythDBBase
            self.MythDB = MythDB
            self.MythBE = MythBE
            self.MythDBBase = MythDBBase
            self.Channel = Channel
            self.MythError = MythError
            self.MythLog = MythLog
            self.mythdb = None
            self.mythbeconn = None
            self.localhostname = gethostname()
            try:
                '''Create an instance of each: MythDB, MythVideo
                '''
                self.MythLog._setlevel('none') # Some non option -M cannot have any logging on stdout
                self.mythdb = self.MythDB()
                self.MythLog._setlevel('important,general')
            except self.MythError, e:
                self.logger.critical(e.args[0])
                filename = os.path.expanduser("~")+'/.mythtv/config.xml'
                if not os.path.isfile(filename):
                    self.logger.critical('A correctly configured (%s) file must exist' % filename)
                else:
                    self.logger.critical('Check that (%s) is correctly configured' % filename)
                raise MirobridgeconfigPlugin_error(e.args[0])
            except Exception, e:
                errormsg = "Creating an instance caused an error for one of: MythDBConn or MythVideo, error(%s)\n" % e
                self.logger.critical(errormsg)
                raise MirobridgeconfigPlugin_error(errormsg)
            try:
                self.MythLog._setlevel('none') # Some non option -M cannot have any logging on stdout
                self.mythbeconn = MythBE(backend=self.localhostname, db=self.mythdb)
                self.MythLog._setlevel('important,general')
            except self.MythError, e:
                self.logger.critical("MiroBridge and its MCC plugin must be run on a MythTV backend,\nError(%s)" % e.args[0])
                raise MirobridgeconfigPlugin_error(e.args[0])
        except Exception, e:
            errormsg = "MythTV python bindings could not be imported, error(%s)\n" % e
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
    # end accessMythDB()

    def checkInternetAccess(self):
        '''Check that there is an Internet Access
        return nothing
        '''
        try:
            urllib2.urlopen('http://www.google.com')
        except Exception, e:
            errormsg = "MiroBridge requiries an Internet connection, error(%s)\n" % e
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
    # end checkInternetAccess()

    def isInstalled(self):
        '''Check the system for MiroBridge script, all prerequisite packages, config file and default images.
        Establish what needs to be installed if anything.
        return nothing
        '''
        # Get the location of the MB script and example conf file
        self.location_mirobridge_script = u''
        self.location_mirobridge_example_conf_file = u''
        results = self.callCommandLine(u'dpkg -L mythtv-backend | grep -iE "(mirobridge-example.conf.gz|mirobridge.py)"', stderr=False)
        if results:
            for line in results:
                line = line.strip().replace(u'\n', u'')
                if line.endswith('mirobridge.py'):
                   self.location_mirobridge_script = line
                   continue
                if line.endswith('mirobridge-example.conf.gz'):
                   self.location_mirobridge_example_conf_file = line
                   continue
        if not self.location_mirobridge_script or not self.location_mirobridge_example_conf_file:
            errormsg = u"The 'mythtv-backend' package is not installed. Install/Reinstall that package and then retry"
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
        # Check that mirobridge.py is installed
        if not os.path.isfile(self.location_mirobridge_script):
            errormsg = u"The file 'mirobridge.py' is not installed at (%s)\n" % (self.location_mirobridge_script, )
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
        # Check that mirobridge-example.conf.gz is installed
        if not os.path.isfile(self.location_mirobridge_example_conf_file):
            errormsg = u"The file 'mirobridge-example.conf.gz' is not installed at (%s)\n" % (self.location_mirobridge_example_conf_file, )
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)

        self.config = {
            'installed': False,
            'dependancies': {'miro': False, 'ffmpeg': False, 'python-pyparsing': False, 'imagemagick': False},
            'mirochannel': None, # None is not created, False cannot be created, True already created
            'cfg': None,    # Current config file settings if there is a config file
            'posterdir': False,
            'bannerdir': False,
            'fanartdir': False,
            'cronjob': False,
            'cronjob_freq': None,
            'miro_test_passed': False,
        }

        # Check for MiroBridge package dependancies
        import apt
        cache = apt.cache.Cache()
        for package in self.config['dependancies'].keys():
            try:
                if cache[package].installed != None:
                    self.config['dependancies'][package] = True
                    if package == 'miro': # version example: 2.5.4-0pcf1
                        version = cache[package].installed.version
                        if version[:3] < '2.5':
                            errormsg = "The installed Miro package must be at least version '2.5.x' or higher, yours is (%s).\nUninstall the Miro package then retry the MCC plugin MiroBridge install.\n" % (version, )
                            self.logger.critical(errormsg)
                            raise MirobridgeconfigPlugin_error(errormsg)
            except KeyError, e:
                errormsg = "The MiroBridge dependancy package (%s) is not in your repository, error(%s)\n" % (package, e)
                self.logger.critical(errormsg)
                raise MirobridgeconfigPlugin_error(errormsg)

        # Check if channelid '9999' has been created and if it is assigned as the Miro channel
        channel = self.MythDB(self.mythdb).getChannel(9999)
        if channel['channum'] != None:
            if channel['channum'] != '999' or channel['name'] != 'Miro':
                self.logger.critical("MiroBridge found that there is already a Channel record for Channel num (%s) name (%s)\n" % (channel['channum'], channel['name']))
                self.config['mirochannel'] = False # The channel is already being used!
            else:
                self.config['mirochannel'] = True

        # Check if the mirobridge.conf file exists in the users home directory
        filename = os.path.expanduser("~")+u'/.mythtv/mirobridge.conf'
        if os.path.isfile(filename):
            self.config['cfg'] = ConfigParser.SafeConfigParser()
            self.config['cfg'].read(filename)
        else: # Check that there is an example config, if there is then use it to create a mirobridge.conf file
            if not os.path.isfile(self.location_mirobridge_example_conf_file):
                errormsg = u"The MiroBridge example config file (%s) is missing and it is required\n" % (self.location_mirobridge_example_conf_file, )
                self.logger.critical(errormsg)
                raise MirobridgeconfigPlugin_error(errormsg)

        # Get storage groups
        self.getStorageGroups()

        # Initialize the Video and graphics directory dictionary
        self.getMythtvDirectories()

        # Specify the MiroBridge default image set names
        self.image_set = {
            # posterdir the Miro logo used as the folder and channel image
            'posterdir': u'mirobridge_coverart.jpg',
            'bannerdir': u'mirobridge_banner.jpg',
            'fanartdir': u'mirobridge_fanart.jpg',
            }
        # Check for the Mirobridge default images/Channel image/Folder image
        for key in self.image_set.keys():
            if os.path.isfile(u'%s%s' % (self.vid_graphics_dirs[key], self.image_set[key])):
                self.config[key] = True
                continue

        # Check if there is a mirobridge cronjob and set the values if there is a cronjob
        self.getCronjobSettings()

        # Is MiroBridge fully installed?
        installed_total = len(self.config['dependancies'].keys())+len(self.image_set.keys())+3
        install_count = 0
        for package in self.config['dependancies'].keys():
            if self.config['dependancies'][package]:
               install_count+=1
        if self.config['cfg'] != None:
            install_count+=1
        if self.config['mirochannel'] != None:
            install_count+=1
        if self.config['cronjob_freq'] != None:
            install_count+=1
        for key in self.image_set.keys():
            if self.config[key]:
                install_count+=1
        if installed_total == install_count:
            self.config['installed'] = True
            self.testEnv()  # Verify that the Miro set up was completed with a MiroBridge environment test
    # end isInstalled()

    def getStorageGroups(self):
        '''Populate the storage group dictionary with the host's storage groups.
        return False if there is an error
        '''
        self.storagegroupnames = {u'Default': u'default', u'Videos': u'mythvideo', u'Coverart': u'posterdir', u'Banners': u'bannerdir', u'Fanart': u'fanartdir', u'Screenshots': u'episodeimagedir'}
        self.storagegroups={} # The dictionary is only populated with the current hosts storage group entries

        records = self.mythdb.getStorageGroup(hostname=self.localhostname)
        if records:
            for record in records:
                if record.groupname in self.storagegroupnames.keys():
                    try:
                        dirname = unicode(record.dirname, 'utf8')
                    except (UnicodeDecodeError):
                        self.logger.error(u"The local Storage group (%s) directory contained\ncharacters that caused a UnicodeDecodeError. This storage group has been rejected." % (record.groupname))
                        continue    # Skip any line that has non-utf8 characters in it
                    except (UnicodeEncodeError, TypeError):
                        pass

                    # Add a slash if missing to any storage group dirname
                    if dirname[-1:] == u'/':
                        self.storagegroups[self.storagegroupnames[record.groupname]] = dirname
                    else:
                        self.storagegroups[self.storagegroupnames[record.groupname]] = dirname+u'/'
                continue

        if len(self.storagegroups):
            # Verify that each storage group is an existing local directory
            storagegroup_ok = True
            for key in self.storagegroups.keys():
                if not os.path.isdir(self.storagegroups[key]):
                    self.logger.critical(u"The Storage group (%s) directory (%s) does not exist" % (key, storagegroups[key]))
                    storagegroup_ok = False
            if not storagegroup_ok:
                errormsg = "There are MythTV storage group configuration errors correct and retry installation, errors are displayed in the log.\n"
                self.logger.critical(errormsg)
                raise MirobridgeconfigPlugin_error(errormsg)
    # end getStorageGroups

    def getMythtvDirectories(self):
        """Get all video and graphics directories found in the MythTV DB and add them to the dictionary.
        Ignore any MythTV Frontend setting when there is already a storage group configured.
        """
        # Stop processing if this local host has any storage groups
        self.dir_dict={u'posterdir': u"VideoArtworkDir", u'bannerdir': u'mythvideo.bannerDir', u'fanartdir': 'mythvideo.fanartDir', u'episodeimagedir': u'mythvideo.screenshotDir', u'mythvideo': u'VideoStartupDir'}
        self.vid_graphics_dirs={u'default': u'', u'mythvideo': u'', u'posterdir': u'', u'bannerdir': u'', u'fanartdir': u'', u'episodeimagedir': u'',}

        # When there is NO SG for Videos then ALL graphics paths MUST be local paths set in the FE and accessable
        # from the backend
        if self.storagegroups.has_key(u'mythvideo'):
            self.local_only = False
            # Pick up storage groups first
            for key in self.storagegroups.keys():
                self.vid_graphics_dirs[key] = self.storagegroups[key]
            for key in self.dir_dict.keys():
                if key == u'default' or key == u'mythvideo':
                    continue
                if not self.storagegroups.has_key(key):
                    # Set fall back graphics directory to Videos
                    self.vid_graphics_dirs[key] = self.storagegroups[u'mythvideo']
                    # Set fall back SG graphics directory to Videos
                    self.storagegroups[key] = self.storagegroups[u'mythvideo']
        else:
            self.local_only = True
            if self.storagegroups.has_key(u'default'):
                self.vid_graphics_dirs[u'default'] = self.storagegroups[u'default']

        if self.local_only:
            self.logger.warning(u'There is no "Videos" Storage Group set so ONLY MythTV Frontend local paths for videos and graphics that are accessable from this MythTV Backend can be used.')

        for key in self.dir_dict.keys():
            if self.vid_graphics_dirs[key]:
                continue
            graphics_dir = self.mythdb.settings[self.localhostname][self.dir_dict[key]]
            # Only use path from MythTV if one was found
            if key == u'mythvideo':
                if graphics_dir:
                    tmp_directories = graphics_dir.split(u':')
                    if len(tmp_directories):
                        for i in range(len(tmp_directories)):
                            tmp_directories[i] = tmp_directories[i].strip()
                            if tmp_directories[i] != u'':
                                if os.path.exists(tmp_directories[i]):
                                    if tmp_directories[i][-1] != u'/':
                                        tmp_directories[i]+=u'/'
                                    self.vid_graphics_dirs[key] = tmp_directories[i]
                                    break
                                else:
                                    self.logger.error(u"MythVideo video directory (%s) does not exist(%s)" % (key, tmp_directories[i]))
                else:
                    self.logger.error(u"MythVideo video directory (%s) is not set" % (key, ))

            if key != u'mythvideo':
                if graphics_dir and os.path.exists(graphics_dir):
                    if graphics_dir[-1] != u'/':
                        graphics_dir+=u'/'
                    self.vid_graphics_dirs[key] = graphics_dir
                else:    # There is the chance that MythTv DB does not have a dir
                    self.logger.error(u"(%s) directory is not set or does not exist(%s)" % (key, self.dir_dict[key]))

        # Make sure there is a directory set for Videos and other graphics directories on this host
        dir_for_all = True
        for key in self.vid_graphics_dirs.keys():
            if not self.vid_graphics_dirs[key]:
                self.logger.critical(u"There must be a directory for Videos and each graphics type the (%s) directory is missing." % (key))
                dir_for_all = False
        if not dir_for_all:
            errormsg = "The MythTV video and/or image directories are not configured properly, correct and retry installation, errors are displayed in the log.\n"
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)

        # Make sure that there is read/write access to all the directories Miro Bridge uses
        access_issue = False
        for key in self.vid_graphics_dirs.keys():
            if not os.access(self.vid_graphics_dirs[key], os.F_OK | os.R_OK | os.W_OK):
                self.logger.critical(u"\nEvery Video and graphics directory must be read/writable for Miro Bridge to function. There is a permissions issue with (%s)." % (self.vid_graphics_dirs[key], ))
                access_issue = True
        if access_issue:
            errormsg = "The MythTV video and/or image directories do not have the proper read/write permission, correct and retry installation, errors are displayed in the log.\n"
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
        # end getMythtvDirectories()


    def readExampleConf(self, archivename):
        '''Extract the archive to /tmp and read the mirobridge-example.conf file as the new cfg
        return nothing
        '''
        import gzip
        tmp_name = '/tmp/mirobridge-example.conf'
        try:
            zip_file = gzip.open(archivename, 'r')
            file_content = zip_file.read()
            zip_file.close
        except Exception, e:
            errormsg = "The mirobridge-example.conf archive file(%s), could not be opened, error(%s)\n" % (archivename, e)
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
        try:
            target_file = open(tmp_name, "w")
            target_file.write(file_content)
            target_file.close()
        except Exception, e:
            errormsg = "The mirobridge-example.conf could not be created in '/tmp', error(%s)\n" % (e, )
            self.logger.critical(errormsg)
            raise MirobridgeconfigPlugin_error(errormsg)
        self.config['cfg'] = ConfigParser.SafeConfigParser()
        self.config['cfg'].read(tmp_name)
        os.remove(tmp_name)
    # readExampleConf()


    def callCommandLine(self, command, stderr=False):
        '''Perform the requested command line and return an array of stdout strings and stderr strings if
        stderr=True
        return array of stdout string array or stdout and stderr string arrays
        '''
        stderrarray = []
        stdoutarray = []
        try:
            p = subprocess.Popen(command, shell=True, bufsize=4096, stdin=subprocess.PIPE,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
        except Exception, e:
            self.logger.error(u'callCommandLine Popen Exception, error(%s)' % e)
            if stderr:
                return [[], []]
            else:
                return []

        if stderr:
            while True:
                data = p.stderr.readline()
                if not data:
                    break
                try:
                    data = unicode(data, 'utf8')
                except (UnicodeDecodeError):
                    continue    # Skip any line that has non-utf8 characters in it
                except (UnicodeEncodeError, TypeError):
                    pass
                stderrarray.append(data)

        while True:
            data = p.stdout.readline()
            if not data:
                break
            try:
                data = unicode(data, 'utf8')
            except (UnicodeDecodeError):
                continue    # Skip any line that has non-utf8 characters in it
            except (UnicodeEncodeError, TypeError):
                pass
            stdoutarray.append(data)

        if stderr:
            return [stdoutarray, stderrarray]
        else:
            return stdoutarray
    # end callCommandLine()


    def getCronjobSettings(self):
        '''Check the status of the MiroBridge cron job and initalize the values
        return nothing
        '''
        self.tab = CronTab()
        # Check if there is an existing cronjob
        list = self.tab.find_command(self.location_mirobridge_script)

        self.config['cronjob'] = False
        if not len(list):
            return

        self.config['cronjob'] = True

        # Check whether the cronjob is a Hourly, Daily or Weekly
        mb_cronjob = (u'%s' % list[0])
        for index in range(len(self.cron_regx)):
            if self.cron_regx[index].match(mb_cronjob):
                break
        else:
            index = 0 # Set to default of Daily as the cron job did not match hourly, daily or weekly options
        self.config['cronjob_freq'] = self.cronjob_keys[index]
    # end getCronjobSettings()


    def maintCronjobs(self, action, value):
        ''' Create the cron job if required
        Actions:
        (1) Enable/Disable the cronjob
        (2) Set the frequency of the cronjob (hourly, daily, weekly)
        return nothing
        '''
        # MiroBrdige cronjob - debus additions added even though they may not be needed for all users
        miro_cronjob = u'''env `dbus-launch` sh -c 'trap "kill $DBUS_SESSION_BUS_PID" EXIT; %s ' >> '/var/log/mythtv/mirobridge.log' 2>&1'''

        list = self.tab.find_command(self.location_mirobridge_script)
        # Does the cronjob exist?
        if not len(list) and action == 'enable_disable' and not value:
            return  # You cannot disable a cronjob that does not exist

        # Disable the conjob by removing it from the crontab
        if len(list) and action == 'enable_disable' and not value:
            self.tab.remove_all(self.location_mirobridge_script)
            # Write out changes
            self.tab.write()
            return

        # For all other actions a cronjob must exist so create one
        cron = None
        if not len(list): # Create the MiroBridge cronjob
            cron = self.tab.new(command=miro_cronjob % self.location_mirobridge_script, comment=u'MiroBridge cronjob')
            cron.valid = True   # Enable the cronjob to be written to the crontab
            if self.config['cronjob_freq'] == None:
                cron.minute().on(45) # On the 45 minute mark on every hour
            if action == 'enable_disable':
                self.tab.write()
                return

        if action == 'cronjob_freq':
            if not cron:    # Use either the newly created cron job or one that already exists.
                cron = list[0]
            cron.clear()    # Reset any frequency settings for thus cronjob
            if value == 0:
                cron.minute().on(45) # Hourly - On the 45 minute mark of every hour
            elif value == 1:
                cron.hour().on(2) # Daily - At 2:00 AM every day
            else:
                cron.dow().on(0) # Weekly - Every Sunday night at midnight

            cron.valid = True   # Enable the cronjob to be written to the crontab
            self.tab.write()
    # end maintCronjobs()


    def maintConfigFile(self, action, value):
        '''Actions: Set the behaviour of Mirobridge and how the Miro videos are processed.
        return nothing
        '''
        if action == 'behaviour':
            tmp = {}
            if self.behaviour_section[value] == 'default':
                for key in self.behaviour_section:
                    if key == 'default':
                        continue
                    tmp[key] = {u'all miro channels': u''}
            else:
                for key in self.behaviour_section:
                    if key == 'default':
                        continue
                    if key == self.behaviour_section[value]:
                        tmp[key] = {u'all miro channels': u'  '}
                        continue
                    tmp[key] = {u'all miro channels': u''}
            self.writeMiroBridgeConf(tmp, self.config['cfg'], mythtv=False)
    # end maintConfigFile()


    def installDefaultImages(self):
        '''Download for image archives from the internet and install any missing default MiroBridge images
        return nothing
        '''
        # Specify the MiroBridge default image download URLs
        self.image_links = {
            # posterdir the Miro logo used as the folder and channel image
            'posterdir': u'http://img641.imageshack.us/img641/2396/mirocoverart.jpg',
            'bannerdir': u'http://img402.imageshack.us/img402/7100/mirobridgebanner.jpg',
            'fanartdir': u'http://img76.imageshack.us/img76/9897/mirobridgefanart.jpg',
            }

        # Download only the missing images
        for key in self.image_links:
            filename = u'%s%s' % (self.vid_graphics_dirs[key], self.image_set[key])
            if not os.path.isfile(filename):
                url = self.image_links[key]
                org_url = url
                tmp_URL = url.replace("http://", "")
                url = "http://"+urllib2.quote(tmp_URL.encode("utf-8"))
                try:
                    image = urllib2.urlopen(url).read()
                except IOError, e:
                    errormsg = "The MiroBridge image image URL (%s) could not be opened, error(%s)\n" % (org_url, e, )
                    self.logger.error(errormsg)
                    continue

                try:
                    output_image = open(filename, "wb")
                    output_image.write(image)
                    output_image.close()
                except IOError, e:
                    errormsg = "The MiroBridge image URL (%s) could not be downloaded, error(%s)\n" % (filename, e, )
                    self.logger.error(errormsg)
                    continue
                os.chmod(filename, 0666)
    # end installDefaultImages()


    def readFile(self, filename):
        '''Read in the cron job and pass back an array of each line
        return array of strings
        return empty array of no file
        '''
        try:
            myfile = open(filename)                     # Open for output (to read only)
        except IOError:
            return False

        aList = myfile.readlines( )                     # Read entire file into list of line strings
        myfile.close( )                                 # Flush output buffers to disk
        array=[]                                        # Initialize 2 dimensional array
        x=0                                                # Initialize array row value
        for rec in aList:
            array.append(rec)                        # Put record array into array of records
        return array
    # end readFile()


    def writeFile(self, filename, textarray):
        '''Write out the text array to the cron job
        return True if writing was successful
        return False if the writing failed
        '''
        try:
            myfile = open(filename, 'w')     # Open for output (creates file)
        except IOError:
            return False
        for rec in textarray:
            myfile.write(rec)                 # Write a new-line deliminated strings
        myfile.close()                         # Flush output buffers to disk
        return True
    # end writeFile()


    def writeMiroBridgeConf(self, configupdates, cfg, mythtv=True):
        '''Perform add/change/delete functions to the key/value pairs in the mirobridge.conf file
        return True if the task was completed successfully
        return False if there were issues
        '''
        anything_updated = False
        for section in configupdates.keys():
            if not len(configupdates[section]): # Skip any section that has not been changed
                continue
            anything_updated = True
            for key in configupdates[section].keys():
                if not cfg.has_section(section):
                    if configupdates[section][key] == u'':
                        pass
                    else:
                        cfg.add_section(section)
                        cfg.set(section, key, configupdates[section][key])
                elif configupdates[section][key] == u'':
                    if cfg.has_option(section, key):
                        cfg.remove_option(section, key)
                else:
                    cfg.set(section, key, configupdates[section][key])

        filename = os.path.expanduser("~")+u'/.mythtv/mirobridge.conf'
        if not os.path.isfile(filename): # Create the file if it does not exist
            anything_updated = True

        if anything_updated:
            try:
                fd = open(filename, 'wb')
                cfg.write(fd)
            except IOError:
                return False
            # Change the owner and group from root to mythtv
            if mythtv:
                os.system('chown mythtv:mythtv %s & chmod g+rw %s' % (filename, filename))
        return True
    # end writeMiroBridgeConf()


    def addMiroBridgeChannel(self):
        '''Add the Mirobridge Channel and icon if possible
        return nothing
        '''
        # Check if channelid '9999' has been created and if it is assigned as the Miro channel
        channel = self.MythDB(self.mythdb).getChannel(9999)
        if channel['channum'] != None:
            if channel['channum'] != '999' or channel['name'] != 'Miro':
                self.logger.critical("MiroBridge cannot create a channel record as the channel is already used for Channel num (%s) name (%s)\n" % (channel['channum'], channel['name']))
                return
            else:
                return # The channel has already been created for MiroBridge

        data={}
        data['chanid'] = 9999
        data['channum'] = '999'
        data['freqid'] = '999'
        data['atsc_major_chan'] = 999
        data['icon'] = u'%s%s' % (self.vid_graphics_dirs['posterdir'], self.image_set['posterdir'])
        data['callsign'] = u'Miro'
        data['name'] = u'Miro'
        data['last_record'] = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Create the MiroBridge Channel record
        try:
            self.Channel().create(data)
        except MythError, e:
            errmsg = u"Failed writing the Miro channel record. Most likely the Channel Id and number already exists.\nUse Web App (http:yourbackend:6544) to alter or remove the offending channel.\nSpecified Channel ID (%d) and Channel Number (%d), error(%s)" % (channel_id, channel_num, e.args[0])
            self.logger.critical(errmsg)
            raise MirobridgeconfigPlugin_error(errmsg)
    # end addMiroBridgeChannel()


    def delChannel(self):
        '''Just delete a Channel record. Never abort as sometimes a record may not exist. This routine is
        not supported in the native python bindings as MiroBridge uses the Channel table outside of its
        original intent.
        return nothing
        '''
        db = self.MythDBBase(None)
        c = db.cursor()
        query = 'DELETE FROM channel WHERE chanid=9999 AND name="Miro"'
        try:
            c.execute(query)
        except Exception, e:
            self.logger.error(u"Channel record delete failed (%s)" % (e, ))
            pass
        c.close()

    def testEnv(self):
        '''Run the MiroBridge environment test to see if the installation and configuration is complete
        Use the return code to determine the results and set 'miro_test_passed' indicator accordingly.
        '''
        try:
            retcode = subprocess.check_call([self.location_mirobridge_script, u"-t"])
        except subprocess.CalledProcessError, e:
            self.logger.error(u'Testing the MiroBridge environment with the "-t" option failed, error(%s)' % e)
            return

        # MiroBridge is read to run
        self.config['miro_test_passed'] = True
# end class delChannel()# end MirobridgeConfigFunctions()


###########################################################################################
# This code has no package in the Ubuntu repository. It was easier to copy than install.
# Found at: http://pypi.python.org/pypi/python-crontab/0.9.4
###########################################################################################

#
# Copyright 2008, Martin Owens.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Rewritten from scratch, but based on the code from gnome-schedual by:
# - Philip Van Hoof <me at pvanhoof dot be>
# - Gaute Hope <eg at gaute dot vetsj dot com>
# - Kristof Vansant <de_lupus at pandora dot be>
#

"""
Example Use:

from crontab import CronTab

tab = CronTab()
cron = tab.new(command='/usr/bin/echo')

cron.minute().during(5,50).every(5)
cron.hour().every(4)

cron2 = tab.new(command='/foo/bar',comment='SomeID')
cron2.every_reboot()

list = tab.find_command('bar')
cron3 = list[0]
cron3.clear()
cron3.minute().every(1)

print unicode(tab.render())

for cron4 in tab.find_command('echo'):
    print cron4

for cron5 in tab:
    print cron5

tab.remove_all('echo')

t.write()
"""

# These imports were moved to the top of the miroconfig.py file
#import os, re, sys
#import tempfile

__version__ = '0.9.3'

CRONCMD = "/usr/bin/crontab"
ITEMREX = re.compile('^\s*([^@#\s]+)\s+([^@#\s]+)\s+([^@#\s]+)' +
    '\s+([^@#\s]+)\s+([^@#\s]+)\s+([^#\n]*)(\s+#\s*([^\n]*)|$)')
SPECREX = re.compile('@(\w+)\s([^#\n]*)(\s+#\s*([^\n]*)|$)')
DEVNULL = ">/dev/null 2>&1"

MONTH_ENUM = [
    'jan', 'feb', 'mar', 'apr', 'may',
    'jun', 'jul', 'aug', 'sep', 'oct',
    'nov', 'dec',
]
WEEK_ENUM  = [
    'sun', 'mon', 'tue', 'wed', 'thu',
    'fri', 'sat', 'sun',
]

SPECIALS = {
    "reboot"  : '@reboot',
    "hourly"  : '0 * * * *',
    "daily"   : '0 0 * * *',
    "weekly"  : '0 0 * * 0',
    "monthly" : '0 0 1 * *',
    "yearly"  : '0 0 1 1 *',
    "annually": '0 0 1 1 *',
    "midnight": '0 0 * * *'
}

S_INFO = [
    { 'name' : 'Minutes',      'max_v' : 59, 'min_v' : 0 },
    { 'name' : 'Hours',        'max_v' : 23, 'min_v' : 0 },
    { 'name' : 'Day of Month', 'max_v' : 31, 'min_v' : 1 },
    { 'name' : 'Month',        'max_v' : 12, 'min_v' : 1, 'enum' : MONTH_ENUM },
    { 'name' : 'Day of Week',  'max_v' : 7,  'min_v' : 0, 'enum' : WEEK_ENUM },
]

class CronTab(object):
    """
    Crontab object which can access any time based cron using the standard.

    user = Set the user of the crontab (defaults to $USER)
    fake_tab = Don't set to crontab at all, set to testable fake tab variable.
    """
    def __init__(self, user=None, fake_tab=None):
        self.user  = user
        self.root  = ( os.getuid() == 0 )
        self.lines = None
        self.crons = None
        self.fake = fake_tab
        self.read()

    def read(self):
        """
        Read in the crontab from the system into the object, called
        automatically when listing or using the object. use for refresh.
        """
        self.crons = []
        self.lines = []
        if self.fake:
          lines = self.fake.split('\n')
        else:
          lines = os.popen(self._read_execute()).readlines()
        for line in lines:
            cron = CronItem(line)
            if cron.is_valid():
                self.crons.append(cron)
                self.lines.append(cron)
            else:
                self.lines.append(line.replace('\n',''))

    def write(self):
        """Write the crontab to the system. Saves all information."""
        # Add to either the crontab or the fake tab.
        if self.fake != None:
          self.fake = self.render()
          return

        filed, path = tempfile.mkstemp()
        fileh = os.fdopen(filed, 'w')
        fileh.write(self.render())
        fileh.close()
        # Add the entire crontab back to the user crontab
        os.system(self._write_execute(path))
        os.unlink(path)

    def render(self):
        """Render this crontab as it would be in the crontab."""
        crons = []
        for cron in self.lines:
            if type(cron) == CronItem and not cron.is_valid():
                crons.append("# " + unicode(cron))
                sys.stderr.write(
                    "Ignoring invalid crontab line `%s`\n" % str(cron))
                continue
            crons.append(unicode(cron))
        result = '\n'.join(crons)

        if len(result): # This may be an empty crontab as if all cronjobs were deleted
            if result[-1] not in [ '\n', '\r' ]:
                result += '\n'
        return result

    def new(self, command='', comment=''):
        """
        Create a new cron with a command and comment.

        Returns the new CronItem object.
        """
        item = CronItem(command=command, meta=comment)
        self.crons.append(item)
        self.lines.append(item)
        return item

    def find_command(self, command):
        """Return a list of crons using a command."""
        result = []
        for cron in self.crons:
            if cron.command.match(command):
                result.append(cron)
        return result

    def remove_all(self, command):
        """Removes all crons using the stated command."""
        l_value = self.find_command(command)
        for c_value in l_value:
            self.remove(c_value)

    def remove(self, item):
        """Remove a selected cron from the crontab."""
        self.crons.remove(item)
        self.lines.remove(item)

    def _read_execute(self):
        """Returns the command line for reading a crontab"""
        return "%s -l%s" % (CRONCMD, self._user_execute())

    def _write_execute(self, path):
        """Return the command line for writing a crontab"""
        return "%s %s%s" % (CRONCMD, path, self._user_execute())

    def _user_execute(self):
        """User command switches to append to the read and write commands."""
        if self.user:
            return ' -u %s' % str(self.user)
        return ''

    def __iter__(self):
        return self.crons.__iter__()

    def __unicode__(self):
        return self.render()


class CronItem(object):
    """
    An item which objectifies a single line of a crontab and
    May be considered to be a cron job object.
    """
    def __init__(self, line=None, command='', meta=''):
        self.command = CronCommand(unicode(command))
        self._meta   = meta
        self.valid   = False
        self.slices  = []
        self.special = False
        self.set_slices()
        if line:
            self.parse(line)

    def parse(self, line):
        """Parse a cron line string and save the info as the objects."""
        result = ITEMREX.findall(line)
        if result:
            o_value = result[0]
            self.command = CronCommand(o_value[5])
            self._meta   = o_value[7]
            self.set_slices( o_value )
            self.valid = True
        elif line.find('@') < line.find('#') or line.find('#')==-1:
            result = SPECREX.findall(line)
            if result and SPECIALS.has_key(result[0][0]):
                o_value = result[0]
                self.command = CronCommand(o_value[1])
                self._meta   = o_value[3]
                value = SPECIALS[o_value[0]]
                if value.find('@') != -1:
                    self.special = value
                else:
                    self.set_slices( value.split(' ') )
                self.valid = True

    def set_slices(self, o_value=None):
        """Set the values of this slice set"""
        self.slices = []
        for i_value in range(0, 5):
            if not o_value:
                o_value = [None, None, None, None, None]
            self.slices.append(
                CronSlice(value=o_value[i_value], **S_INFO[i_value]))

    def is_valid(self):
        """Return true if this slice set is valid"""
        return self.valid

    def render(self):
        """Render this set slice to a string"""
        time = ''
        if not self.special:
            slices = []
            for i in range(0, 5):
                slices.append(unicode(self.slices[i]))
            time = ' '.join(slices)
        if self.special or time in SPECIALS.values():
            if self.special:
                time = self.special
            else:
                time = "@%s" % SPECIALS.keys()[SPECIALS.values().index(time)]

        result = "%s %s" % (time, unicode(self.command))
        if self.meta():
            result += " # " + self.meta()
        return result


    def meta(self, value=None):
        """Return or set the meta value to replace the set values"""
        if value:
            self._meta = value
        return self._meta

    def every_reboot(self):
        """Set to every reboot instead of a time pattern"""
        self.special = '@reboot'

    def clear(self):
        """Clear the special and set values"""
        self.special = None
        for slice_v in self.slices:
            slice_v.clear()

    def minute(self):
        """Return the minute slice"""
        return self.slices[0]

    def hour(self):
        """Return the hour slice"""
        return self.slices[1]

    def dom(self):
        """Return the day-of-the month slice"""
        return self.slices[2]

    def month(self):
        """Return the month slice"""
        return self.slices[3]

    def dow(self):
        """Return the day of the week slice"""
        return self.slices[4]

    def __str__(self):
        return self.__unicode__()

    def __unicode__(self):
        return self.render()


class CronSlice(object):
    """Cron slice object which shows a time pattern"""
    def __init__(self, name, min_v, max_v, enum=None, value=None):
        self.name  = name
        self.min   = min_v
        self.max   = max_v
        self.enum  = enum
        self.parts = []
        self.value(value)

    def value(self, value=None):
        """Return the value of the entire slice."""
        if value:
            self.parts = []
            for part in value.split(','):
                if part.find("/") > 0 or part.find("-") > 0 or part == '*':
                    self.parts.append( self.get_range( part ) )
                else:
                    if self.enum and part.lower() in self.enum:
                        part = self.enum.index(part.lower())
                    try:
                        self.parts.append( int(part) )
                    except:
                        raise ValueError(
                            'Unknown cron time part for %s: %s' % (
                            self.name, part))
        return self.render()

    def render(self):
        """Return the slice rendered as a crontab"""
        result = []
        for part in self.parts:
            result.append(unicode(part))
        if not result:
            return '*'
        return ','.join(result)

    def __str__(self):
        return self.__unicode__()

    def __unicode__(self):
        return self.render()

    def every(self, n_value):
        """Set the every X units value"""
        self.parts = [ self.get_range( '*/%d' % int(n_value) ) ]

    def on(self, *n_value):
        """Set the on the time value."""
        self.parts += n_value

    def during(self, value_from, value_to):
        """Set the During value, which sets a range"""
        range_value = self.get_range(
            "%s-%s" % (str(value_from), str(value_to)))
        self.parts.append( range_value )
        return range_value

    def clear(self):
        """clear the slice ready for new vaues"""
        self.parts = []

    def get_range(self, range_value):
        """Return a cron range for this slice"""
        return CronRange( self, range_value )


class CronRange(object):
    """A range between one value and another for a time range."""
    def __init__(self, slice_value, range_value=None):
        self.value_from = None
        self.value_to = None
        self.slice = slice_value
        self.seq   = 1
        if not range_value:
            range_value = '*'
        self.parse(range_value)

    def parse(self, value):
        """Parse a ranged value in a cronjob"""
        if value.find('/') > 0:
            value, self.seq = value.split('/')
        if value.find('-') > 0:
            from_val, to_val = value.split('-')
            self.value_from = self.clean_value(from_val)
            self.value_to  = self.clean_value(to_val)
        elif value == '*':
            self.value_from = self.slice.min
            self.value_to  = self.slice.max
        else:
            raise ValueError, 'Unknown cron range value %s' % value

    def render(self):
        """Render the ranged value for a cronjob"""
        value = '*'
        if self.value_from > self.slice.min or self.value_to < self.slice.max:
            value = "%d-%d" % (int(self.value_from), int(self.value_to))
        if int(self.seq) != 1:
            value += "/%d" % (int(self.seq))
        return value

    def clean_value(self, value):
        """Return a cleaned value of the ranged value"""
        if self.slice.enum and str(value).lower() in self.slice.enum:
            value = self.slice.enum.index(str(value).lower())
        try:
            value = int(value)
            if value >= self.slice.min and value <= self.slice.max:
                return value
        except ValueError:
            raise ValueError('Invalid range value %s' % str(value))

    def every(self, value):
        """Set the sequence value for this range."""
        self.seq = int(value)

    def __str__(self):
        return self.__unicode__()

    def __unicode__(self):
        return self.render()


class CronCommand(object):
    """Reprisent a cron command as an object."""
    def __init__(self, line):
        self._command = line

    def match(self, command):
        """Match the command given"""
        if command in self._command:
            return True
        return False

    def command(self):
        """Return the command line"""
        return self._command

    def __str__(self):
        """Return a string as a value"""
        return self.__unicode__()

    def __unicode__(self):
        """Return unicode command line value"""
        return self.command()
# end of crontab functions
