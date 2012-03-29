#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#----------------------------
# Name: logrotate.py
# Python Script
# Author: Raymond Wagner
# Purpose
#   This python script is intended to help manage the new logging format
#   introduced to MythTV in version 0.25. Each instance of each application
#   run generates a new log file, meaning log rotation applications do not
#   know to treat them as a group.
#   This script treats each application individually, and will delete
#   anything beyond a minimum number of log sets that have aged beyond the
#   minimum number of days.  One log set is one instance of the application,
#   and however many rotated files have been generated for it.
#----------------------------

from __future__ import print_function

import os
import re
import sys
from datetime import datetime, timedelta
from optparse import OptionParser

class LogFile( object ):
    _re = re.compile("(?P<appname>[a-z]*(\.[a-z]+)?).(?P<date>[0-9]{14}).(?P<pid>[0-9]{1,6}).log((?P<sequence>.[0-9]+)\.(?P<compression>[a-zA-Z0-9]+)?)?")
    path = None
    application = None
    datetime = None
    pid = None
    compressed = False
    sequence = None

    @classmethod
    def filter(cls, path, filelist):
        return [cls(path, f) for f in filelist if cls._re.match(f)]

    def __init__(self, path, filename):
        self.path = path
        self.filename = filename
        self.lastmod = datetime.fromtimestamp(os.stat(
                            os.path.join(self.path, self.filename)).st_mtime)

        m = self._re.match(filename)
        self.application = m.group('appname')
        self.datetime = datetime.strptime(m.group('date'), "%Y%m%d%H%M%S")
        self.pid = int(m.group('pid'))
        if m.group('sequence'):
            self.sequence = int(m.group('sequence'))
            if m.group('compression'):
                self.compressed = True
        self.children = []

    def __repr__(self):
        return "<LogFile {0}, {1}{2}{3}>".format(
                self.application, self.datetime.strftime("%b %d, %H:%M"),
                " #{0}".format(self.sequence) if self.sequence is not None else "",
                " (compressed)" if self.compressed else "")

    def __lt__(self, other):
        if self.application != other.application:
            return (self.application < other.application)
        if self.datetime != other.datetime:
            return (self.datetime < other.datetime)
        if self.pid != other.pid:
            return (self.pid < other.pid)

        if self.sequence == other.sequence:
            return False
        if self.sequence is None:
            return True
        if other.sequence is None:
            return False
        return (self.sequence < other.sequence)

    def __gt__(self, other):
        if self.application != other.application:
            return (self.application > other.application)
        if self.datetime != other.datetime:
            return (self.datetime > other.datetime)
        if self.pid != other.pid:
            return (self.pid > other.pid)

        if self.sequence == other.sequence:
            return False
        if self.sequence is None:
            return False
        if other.sequence is None:
            return True
        return (self.sequence > other.sequence)

    def __eq__(self, other):
        return (self.application == other.application) and \
               (self.datetime == other.datetime) and \
               (self.pid == other.pid) and \
               (self.sequence == other.sequence)

    def append(self, child):
        self.children.append(child)

    def delete(self):
        for child in self.children:
            child.delete()
        os.unlink(os.path.join(self.path, self.filename))

def deletelogs(instances, opts):
    deletelist = []
    instances.sort(reverse=True)
    while len(instances) > int(opts.minfiles):
        cur = instances.pop()
        if instances[-1].lastmod < (datetime.now() -\
                                   timedelta(hours=24*int(opts.minage))):
            deletelist.append(cur)
    if len(deletelist):
        print("Deleting {0} log sets ({1} files) for {2}".format(
                        len(deletelist),
                        sum([len(item.children)+1 for item in deletelist]),
                        deletelist[0].application))
        for item in deletelist:
#            print("  deleting {0}".format(item))
            item.delete()

def main(opts):
    ls = LogFile.filter(opts.logpath, os.listdir(opts.logpath))
    ls.sort(reverse=True)

    if len(ls) == 0:
        print("Warning: Empty log path!")
        sys.exit(1)

    cur = None
    while len(ls):
        f = ls.pop()
        if cur is None:
            # first run of a new application name
            # start collecting instances
            instances = [f]
            cur = f
            continue

        if cur.application != f.application:
            # new application name, run existing instances and restart loop
            ls.append(f)
            cur = None
            deletelogs(instances, opts)
            continue

        if (cur.datetime != f.datetime) or (cur.pid != f.pid):
            # new instance of existing application
            cur = f
            instances.append(f)
            continue

        # logrotate copy of current instance
        # mark as child for collective handling
        cur.append(f)

    deletelogs(instances, opts)

if __name__ == "__main__":
    try:
        from argparse import ArgumentParser
    except ImportError:
        parser = OptionParser()
        parser.add_option("-p", "--path", dest="logpath", default="/var/log/mythtv",
                          help="Path where log files are stored")
        parser.add_option("-n", "--min-files", dest="minfiles", default="5",
                          help="Minimum number of logs per application to keep")
        parser.add_option("-t", "--min-age", dest="minage", default="7",
                          help="Minimum time (days) to keep log files")
        (opts, args) = parser.parse_args()
    else:
        parser = ArgumentParser()
        parser.add_argument('-p', "--path", dest="logpath", default="/var/log/mythtv",
                            help="Path where log files are stored")
        parser.add_argument('-n', "--min-files", dest="minfiles", type=int, default=5,
                            help="Minimum number of logs per application to keep")
        parser.add_argument("-t", "--min-age", dest="minage", type=int, default=7,
                            help="Minimum time (days) to keep log files")
        opts = parser.parse_args()

    main(opts)
