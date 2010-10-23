#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# ----------------------
# Name: jamuconfiguration.py
# Python Script
# Author:     R.D. Vaughan
# Purpose:     This python script is intended to support common routines for maintenance of the ~/.mythtv/jamu.conf
#            file.
#
# License:Creative Commons GNU GPL v2
# (http://creativecommons.org/licenses/GPL/2.0/)
#-------------------------------------
__title__ ="jamuconfiguration.py - configuration maintenance routines";
__author__="R.D.Vaughan"
__purpose__='''
This python script is intended to support common routines for maintenance of the ~/.mythtv/jamu.conf file.

'''

__version__ = u"0.1.4"
# 0.0.1     Initial development
# 0.0.2     Alpha development version
# 0.0.3     Phase 2 development version - Adding TV Series Movie Title Override screens and logic
#           Also fixed an bug where the logger was called before it was actually initialized
#           Moved the logic for MythTV python binding import and initialization to it's own function
# 0.0.4     Improved the messges and details when a MythDB connection cannot be made at plugin initialization
# 0.1.0     Beta release of Phase 1 - Only essential jamu.conf editing other logic removed
# 0.1.1     Fixed a syntax error when getting Scheduled and Recorded data
# 0.1.2     Changed tabs to spaces and added functionality to callCommandLine() and
#           fixed getTvSeriesOrMovieList()
#           Made it optional to set the jamu.conf file ownership to group and owner to mythtv
#           A number of functionality changes to accomidate Title Override editing
# 0.1.3     Updated imports and calls to the new python bindings.
#           Chnage exception meassages to provide additional information
# 0.1.4     Removed the locate routine and replaced it with the more accurate "dpkg -L" package search

# System modules
import sys, os, re, locale, subprocess, ConfigParser, urllib, codecs, shutil, datetime, fnmatch, string
from socket import gethostname, gethostbyname
import tempfile


class jamuconf_error(Exception):
    """An error which stops the jamu MCC plugin from functioning
    """
    pass
# end Class jamuconf_error()


class jamuconf():

    def __init__(self):
        # List of language from http://www.thetvdb.com/api/0629B785CE550C8D/languages.xml
        # Hard-coded here as it is realtively static, and saves another HTTP request, as
        # recommended on http://thetvdb.com/wiki/index.php/API:languages.xml
        # Language array elements [two character code, numeric code for tvdb api, display text]
        self.languages = [[u'', u'', u'Default'], [u'en', u'7', u'English'], [u'sv', u'8', u'Svenska'], [u'no', u'9', u'Norsk'], [u'da', u'10', u'Dansk'], [u'fi', u'11', u'Suomeksi'], [u'nl', u'13', u'Nederlands'], [u'de', u'14', u'Deutsch'], [u'it', u'15', u'Italiano'], [u'es', u'16', u'Español'], [u'fr', u'17', u'Français'], [u'pl', u'18', u'Polski'], [u'hu', u'19', u'Magyar'], [u'el', u'20', u'Ελληνικά'], [u'tr', u'21', u'Türkçe'], [u'ru', u'22', u'русский язык'], [u'he', u'24', u'עברית'], [u'ja', u'25', u'日本語'], [u'pt', u'26', u'Português'], [u'zh', u'27', u'中文'], [u'cs', u'28', u'čeština'], [u'sl', u'30', u'Slovenski'], [u'hr', u'31', u'Hrvatski'], [u'ko', u'32', u'한국어'], ]

        self.localhostname = gethostname()
        self.matchto = u'/usr/bin/python /usr/share/mythtv/mythvideo/scripts/jamu.py'
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
            from MythTV import MythDB, MythBE, MythError, MythLog
            self.MythDB = MythDB
            self.MythBE = MythBE
            self.MythError = MythError
            self.MythLog = MythLog
            self.mythdb = None
            self.mythbeconn = None
            try:
                '''Create an instance of each: MythDB, MythVideo
                '''
                self.MythLog._setlevel('none') # Some non option -M cannot have any logging on stdout
                self.mythdb = self.MythDB()
                self.MythLog._setlevel('important,general')
            except self.MythError, e:
                self.logger.critical(e.message)
                filename = os.path.expanduser("~")+'/.mythtv/config.xml'
                if not os.path.isfile(filename):
                    self.logger.critical('A correctly configured (%s) file must exist' % filename)
                else:
                    self.logger.critical('Check that (%s) is correctly configured' % filename)
            except Exception, e:
                self.logger.warn("Creating an instance caused an error for one of: MythDBConn or MythVideo, error(%s)\n" % e)
            try:
                self.MythLog._setlevel('none') # Some non option -M cannot have any logging on stdout
                self.mythbeconn = MythBE(backend=self.localhostname, db=self.mythdb)
                self.MythLog._setlevel('important,general')
            except self.MythError, e:
                self.logger.warn("With any -M option Jamu and its MCC plugin must be run on a MythTV backend,\nError(%s)" % e.args[0])
                self.mythbeconn = None
        except Exception, e:
            self.logger.warn("MythTV python bindings could not be imported, error(%s)\n" % e)
            self.mythdb = None
            self.mythbeconn = None
    # end accessMythDB()


    def accessCheck(self, filename):
        '''Check that a file can be access as could be required to do the update functions
        return True if all required access is available
        rerutn False if there are any access issues
        '''
        # jamu.conf exists RW
        # '/etc/cron.daily/mythvideo', '/etc/cron.weekly/mythvideo', '/etc/cron.hourly/mythvideo',  exists RW
        return os.access(filename, os.F_OK | os.R_OK | os.W_OK)
    # end accessChecks()


    # Two routines used for movie title search and matching
    def is_punct_char(self, char):
        '''check if char is punctuation char
        return True if char is punctuation
        return False if char is not punctuation
        '''
        return char in string.punctuation
    # end is_punct_char()


    def is_not_punct_char(self, char):
        '''check if char is not punctuation char
        return True if char is not punctuation
        return False if chaar is punctuation
        '''
        return not self.is_punct_char(char)
    # end is_not_punct_char()


    def readJamuConf(self, useroptions):
        '''Read in all jamu.conf sections and key/value pairs
        return a dictionary of the sections and the key/value pairs as they are in the jamu.conf file
        '''
        config={}
        cfg = ConfigParser.SafeConfigParser()
        cfg.read(useroptions)

        # Flag all the config file sections as unchanged
        config[u'configchangeflag'] = {}
        for key in cfg.sections():
            config[u'configchangeflag'][key] = {}

        return (cfg, config)
    # end readJamuConf


    def writeJamuConf(self, configupdates, cfg, mythtv=True):
        '''Perform add/change/delete functions to the key/value pairs in the jamu.conf file
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

        if not os.path.isfile(self.configfile): # Create the file if it does not exist
            anything_updated = True

        if anything_updated:
            try:
                fd = open(self.configfile, 'wb')
                cfg.write(fd)
            except IOError:
                return False
            # Change the owner and group from root to mythtv
            if mythtv:
	            os.system('chown mythtv:mythtv %s & chmod g+rw %s' % (self.configfile, self.configfile))
        return True
    # end writeJamuConf()


    def getCronJobStatus(self, whichcronjob):
        '''Read a specific cron job and return its status
        return a cron jobs stats and current option switches in an array
        return False if cron job could not be found or had garbage data
        '''
        results = self.callCommandLine(u'grep "%s" "%s"' % (self.matchto, whichcronjob[1]))
        if len(results):
            result = results[0]
        else:
            return [False, False]

        if result[0] == '#':
            return [False, False]
        NFS = result.find(' -N')
        if NFS != -1:
            return [True, True]
        else:
            return [True, False]
    # end getCronJobStatus()


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


    def setCronJobStatus(self, whichcronjobs):
        '''Change a specific cron job to disables and/or its command line options
        return True if the changes were made
        return Flase if the changes were not made
        '''
        insertpoint = u'jamu.py'
        nfsoverride = u' -N'
        disableline = u'    echo "Cron Job Disabled by User"\n'
        for key in whichcronjobs.keys():
            if whichcronjobs['nfs_checkbutton'][3] or (key != 'nfs_checkbutton' and whichcronjobs[key][3]):
                if key == 'nfs_checkbutton':
                    continue

                if not self.accessCheck(whichcronjobs[key][1]):
                    errormsg = u'The cron job file (%s) cannot be accessed with (RW) permissions. This is required for updating.' % whichcronjobs[key][1]
                    self.logger.critical(errormsg)
                    raise jamuconf_error(errormsg)

                filearray = self.readFile(whichcronjobs[key][1])
                if filearray == False:
                    errormsg = u'The cron job (%s) could not be read' % whichcronjobs[key][1]
                    self.logger.critical(errormsg)
                    raise jamuconf_error(errormsg)
                if whichcronjobs['nfs_checkbutton'][3]:         # Has the NFS flag changed
                    if whichcronjobs['nfs_checkbutton'][2]:        # Enable the NFS  override option
                        for index in range(len(filearray)):
                            found = filearray[index].find(self.matchto)
                            if found == -1:
                                continue
                            found = filearray[index].find(nfsoverride)
                            if found == -1:
                                filearray[index] = filearray[index].replace(insertpoint, insertpoint+nfsoverride)
                            break
                    else:                                        # Disable thr NFS override option
                        for index in range(len(filearray)):
                            found = filearray[index].find(self.matchto)
                            if found == -1:
                                continue
                            filearray[index] = filearray[index].replace(nfsoverride, u'')
                            break

                if whichcronjobs[key][3]:
                    if whichcronjobs[key][2]:                    # Enable the cron job
                        for index in range(len(filearray)):
                            found = filearray[index].find(self.matchto)
                            if found == -1:
                                continue
                            if filearray[index][0] == u'#':
                                filearray[index] = filearray[index][1:]
                            break
                        for index in range(len(filearray)):
                            found = filearray[index].find(disableline)
                            if found == -1:
                                continue
                            filearray.pop(index)
                            break
                    else:                                        # Disable thr NFS override option
                        for index in range(len(filearray)):
                            found = filearray[index].find(self.matchto)
                            if found == -1:
                                continue
                            if filearray[index][0] != u'#':
                                filearray[index] = u'#'+filearray[index]
                                filearray.insert(index, disableline)
                            break
                if not self.writeFile(whichcronjobs[key][1], filearray):
                    errormsg = u'The cron job (%s) could not be updated (written)' % whichcronjobs[key][1]
                    self.logger.critical(errormsg)
                    raise jamuconf_error(errormsg)

        return True
    # end setCronJobStatus()


    def jamuconfig(self, user, create=False):
        '''Retrieve the jamu config information. If no jamu.conf exists then use jamu-example.conf
        return the jamu config info
        return None if there were errors
        '''
        config_file = None
        results = self.callCommandLine(u'dpkg -L mythvideo | grep -iE "(jamu-example.conf)"', stderr=False)
        if results:
            for line in results:
                line = line.strip().replace(u'\n', u'')
                if line.endswith('jamu-example.conf'):
                   config_file = line
                   continue

        # Check if the config file exists for the specified user and if not then create it
        # from jamu-example.conf
        if user == None:
            if config_file == None:
                return (None, None)
            else:
                return self.readJamuConf(config_file)
        elif user[0] == u'/':
            self.configfile = user
        else:
            self.configfile = u'%s/.mythtv/jamu.conf' % os.path.expanduser(u"~"+user)
        if os.path.isfile(self.configfile):
            return self.readJamuConf(self.configfile)
        else:
            if create == True:
                if config_file == None:
                    self.logger.critical(u'Could not locate the (%s) file so no jamu.conf file can be created' % u'jamu-example.conf')
                    return (None, None)
                else:
                    return self.readJamuConf(config_file)    # Use jamu-example.conf as the base for a new jamu.conf
            else:
                self.logger.critical(u'Config file (%s) does not exist and the auto create flag is not set to true' % self.configfile)
                return (None, None)
    # end jamuconfig()


    def findGrabbers(self):
        '''Find out the full path locations of the TVDB and TMDB metadata grabbers
        return an array of the two full paths for the grabbers
        '''
        ttvdb = None
        tmdb = None

        results = self.callCommandLine(u'dpkg -L mythvideo | grep -iE "(ttvdb.py|tmdb.py)"', stderr=False)
        if results:
            for line in results:
                line = line.strip().replace(u'\n', u'')
                if line.endswith('ttvdb.py'):
                   ttvdb = line
                   continue
                if line.endswith('tmdb.py'):
                   tmdb = line
                   continue
        if not ttvdb or not tmdb:
            errormsg = u"The 'mythvideo' package is not installed. Install/Reinstall that package and then retry"
            self.logger.critical(errormsg)
            return [ttvdb, tmdb]

        if not ttvdb:
            if not os.path.isfile(ttvdb):
                self.logger.critical(u'ttvdb.py metadata grabber cannot be found at (%s)' % ttvdb)
                ttvdb = None
        if not tmdb:
            if not os.path.isfile(tmdb):
                self.logger.critical(u'tmdb.py metadata grabber cannot be found at (%s)' % tmdb)
                tmdb = None
        return [ttvdb, tmdb]
    # end findGrabbers()


    def getTvSeriesOrMovieList(self, title, grabber):
        '''Retrieve a list of possible TV series or Movies that match the passed title.
        return an array of "TV series and their TVDB#s" or "Movie titles and their IMDB#s"
        return an empty array if there were likely matches
        '''
        array = []
        arraydict = {}
        dataarray = self.callCommandLine(u'%s -M "%s"' % (grabber, title))
        for data in dataarray:
            data = data.strip()
            if not len(data):
                continue
            keyvalue=data.split(u':')
            if len(keyvalue) != 2:  # Make sure that the values being returned are valid
                return array

            keyvalue[0] = keyvalue[0].strip()
            keyvalue[1] = keyvalue[1].strip()
            arraydict[keyvalue[1]] = keyvalue[0] # Reorder to title then ref#

        # Sort array to place most likely matches first
        sorted_keys = sorted(arraydict.keys())
        sorted_keys2 = sorted_keys
        for key in sorted_keys: # First add the near matches
            if filter(self.is_not_punct_char, key.lower()).startswith(filter(self.is_not_punct_char, title.lower())):
                array.append([key, arraydict[key]])
                sorted_keys2.remove(key)
        for key in sorted_keys2: # Now add the rest
            array.append([key, arraydict[key]])
        return array
    # end getTvSeriesOrMovieList()


    def getScheduledTvShowsMovies(self):
        '''Fetch the Scheduled or Recorded TV Series and Movies videos titles and subtitles from MythTV
        return an array of scheduled or recorded TV series and movie video titles
        return an empty array if there are no scheduled or recorded TV Series
        '''
        tv = []
        movies = []
        for program in self._getScheduledRecordedProgramList():
            if program[u'subtitle']:
                tv.append(program)
            else:
                movies.append(program)
        return [tv, movies]
    # getScheduledTvShowsMovies()


    def callCommandLine(self, command, stderr=False):
        '''Perform the requested command line and return an array of stdout strings and stderr strings if
        stderd=True
        return array of stdout string array or stdout and stderr string arrays
        '''
        stderrarray = []
        stdoutarray = []
        try:
            p = subprocess.Popen(command, shell=True, bufsize=4096, stdin=subprocess.PIPE,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
        except:
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


    def _getFileList(self, dst):
        ''' Create an array of fully qualified file names
        return an array of file names
        '''
        file_list = []
        names = []

        try:
            for directory in dst:
                tmp_dir = directory
                try:
                    tmp_dir = unicode(directory, 'utf8')
                except (UnicodeEncodeError, TypeError):
                    pass
                for filename in os.listdir(tmp_dir):
                    names.append(os.path.join(tmp_dir, filename))
        except OSError, e:
            self.logger.error(u"Getting a list of files for directory (%s)\nThis is most likely a 'Permission denied' error, Error(%s)" % (dst, e))
            return file_list

        for video_file in names:
            if os.path.isdir(video_file):
                new_files = _getFileList([video_file])
                for new_file in new_files:
                    file_list.append(new_file)
            else:
                file_list.append(video_file)
        return file_list
    # end _getFileList


    def _getScheduledRecordedProgramList(self):
        '''Find all Scheduled and Recorded programs
        return array of found programs, if none then empty array is returned
        '''
        programs=[]

        # Get pending recordings
        try:
            progs = self.MythBE(backend=self.mythbeconn.hostname, db=self.mythbeconn.db).getUpcomingRecordings()
        except self.MythError, e:
            sys.stderr.write(u"\n! Error: Getting Upcoming Recordings list: %s\n" % e.args[0])
            return programs

        for prog in progs:
            record={}
            record['title'] = prog.title
            record['subtitle'] = prog.subtitle
            record['seriesid'] = prog.seriesid

            if record['subtitle'] and prog.airdate != None:
                record['originalairdate'] = prog.airdate[:4]
            else:
                if prog.year != '0':
                    record['originalairdate'] = prog.year
                elif prog.airdate != None:
                    record['originalairdate'] = prog.airdate[:4]
            for program in programs:    # Skip duplicates
                if program['title'] == record['title']:
                    break
            else:
                programs.append(record)

        # Get recorded table field names:
        try:
            recordedlist = self.MythBE(backend=self.mythbeconn.hostname, db=self.mythbeconn.db).getRecordings()
        except self.MythError, e:
            sys.stderr.write(u"\n! Error: Getting recorded programs list: %s\n" % e.args[0])
            return programs

        if not recordedlist:
            return programs

        recordedprogram = {}
        for recordedProgram in recordedlist:
            try:
                recordedRecord = recordedProgram.getRecorded()
            except MythError, e:
                sys.stderr.write(u"\n! Error: Getting recorded table record: %s\n" % e.args[0])
                return programs
            if recordedRecord.recgroup == u'Deleted':
                continue
            recorded = {}
            if recordedRecord.chanid == 9999:
                recorded[u'miro_tv'] = True
            recorded[u'title'] = recordedRecord.title
            recorded[u'subtitle'] = recordedRecord.subtitle
            recorded[u'seriesid'] = recordedRecord.seriesid
            for program in programs:    # Skip duplicates
                if program['title'] == recorded['title']:
                    break
            else:
                programs.append(recorded)
                # Get Release year for recorded movies
                # Get Recorded videos recordedprogram / airdate
                try:
                    recordedDetails = recordedRecord.getRecordedProgram()
                except MythError, e:
                    sys.stderr.write(u"\n! Error: Getting recordedprogram table record: %s\n" % e.args[0])
                    continue
                if not recordedDetails:
                    continue
                if not recordedDetails.subtitle:
                    recordedprogram[recordedDetails.title]= u'%d' % recordedDetails.airdate

        # Add release year to recorded movies
        for program in programs:
            if recordedprogram.has_key(program['title']):
                program['originalairdate'] = recordedprogram[program['title']]

        # Check that each program has an original airdate
        for program in programs:
            if not program.has_key('originalairdate'):
                program['originalairdate'] = u'0000' # Set the original airdate to zero (unknown)

        # Check that each program has seriesid
        for program in programs:
            if not program.has_key('seriesid'):
                program['seriesid'] = u''     # Set an empty seriesid - Generall only for Miro Videos
            if program['seriesid'] == None:
                program['seriesid'] = u''     # Set an empty seriesid

        return programs
    # end _getScheduledRecordedProgramList

# end Class jamuconf()
