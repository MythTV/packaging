#!/usr/bin/env python

import subprocess
import optparse
import datetime
import urllib2
import urllib
import sys
import os
import re

class Ebuild( object ):
    def __init__(self, package):
        self.package = package
        self.name = package.split('/')[-1]
        if self.opts.verbose: print 'Updating '+self.package 

    def update(self):
        self.get_base()
        self.get_cur()
        if not self.opts.verbose:
            print '{0}-{1} --> {0}-{2}'.format(self.name, self.get_version(self.base), self.get_version(self.cur))
        self.get_tarball()
        self.get_shorthash()
        self.copy_base()
        self.digest()

    def get_tarball(self):
        if self.opts.gitver is not None:
            # only need to run once
            return

        url = 'https://github.com/MythTV/mythtv/tarball/'
        if self.cur[1] == 4:
            url += 'v'+self.cur[0]
        else:
            url += self.opts.hash

        request = urllib2.Request(url)
        opener = urllib2.build_opener()
        f = opener.open(request)
        url = f.url

        self.opts.gitver = url.split('/')[-1][14:-7]

        if self.opts.tarball is not None:
            return

        self.opts.tarball = '/usr/portage/distfiles/mythtv-{0}.tar.gz'.format(self.get_version(self.cur))
        if os.access(self.opts.tarball, os.F_OK):
            # tarball already exists
            return

        if self.opts.verbose: print 'Downloading "{0}" to "{1}"'.format(url, self.opts.tarball)
        urllib.urlretrieve(url, self.opts.tarball)

    def get_shorthash(self):
        if self.opts.shash is not None:
            # only need to run once
            return

        if self.opts.verbose: print 'Opening "{0}" to find shortened hash: '.format(self.opts.tarball),
        nr = open('/dev/null','r')
        nw = open('/dev/null','w')
        tar = subprocess.Popen(['tar','-tf',self.opts.tarball], stdin=nr, stderr=nw, stdout=-1)
        self.opts.shash = tar.stdout.readline().strip().strip('/').split('-')[-1]
        tar.stdout.close()
        tar.wait()
        if self.opts.verbose: print self.opts.shash

    def get_base(self):
        rever = re.compile('{0}-(?P<version>[0-9\.]+)(_(?P<type>alpha|beta|pre|rc|p)(?P<date>[0-9]+))?\.ebuild'.format(self.name))
        types = ('alpha','beta','pre','rc',None,'p')
        if self.opts.base:
            match = rever.match(self.opts.base)
            type = types.index(match.group('type'))
            self.base = (match.group('version'), type, match.group('date'))
            if self.opts.verbose: print 'Base manually chosen: ',self.base
        else:
            types = ('alpha','beta','pre','rc',None,'p')
            best = ('0','alpha','00000000')
            for f in os.listdir(self.package):
                match = rever.match(f)
                if not match:
                    continue

                type = types.index(match.group('type'))
                cur = (match.group('version'), type, match.group('date'))

                if self.opts.version:
                    if cur[0] > self.opts.version:
                        continue
                if cur > best:
                    best = cur

            self.base = best

            if self.opts.verbose: print 'Base automatically chosen: {0}-{1}'.format(self.name,self.get_version(self.base))

    def get_cur(self):
        types = ('alpha','beta','pre','rc',None,'p')
        version = self.base[0]
        if self.opts.version is not None:
            version = self.opts.version

        type = self.base[1]
        if self.opts.hash is None:
            type = 4
        elif self.opts.type is not None:
            type = types.index(self.opts.type)

        self.cur = (version, type, self.opts.date)
        if self.opts.verbose: print 'New version set to: {0}-{1}'.format(self.name,self.get_version(self.cur))

        if self.opts.branch:
            self.branch = self.opts.branch
        elif self.cur[1] < 4:
            self.branch = 'master'
        else:
            self.branch = 'fixes/{0}'.format(self.cur[0])

    def get_version(self, version):
        types = ('alpha','beta','pre','rc',None,'p')
        v = version[0]
        if version[1] != 4:
            type = types[version[1]]
            v += '_{0}{1}'.format(type,version[2])
        return v

    def get_name(self, version):
        return '{0}/{1}-{2}.ebuild'.format(self.package, self.name, self.get_version(version))

    def copy_base(self):
        base = self.get_name(self.base)
        cur = self.get_name(self.cur)

        if self.opts.verbose: print 'Updating "{0}" to "{1}"'.format(base, cur)
        
        bp = open(base, 'r')
        cp = open(cur, 'w')

        for line in bp:
            if 'MYTHTV_REV="' in line:
                hash = self.opts.hash and self.opts.hash or ''
                cp.write('MYTHTV_REV="{0}"\n'.format(hash))
            elif 'MYTHTV_SREV="' in line:
                cp.write('MYTHTV_SREV="{0}"\n'.format(self.opts.shash))
            elif 'MYTHTV_VERSION="' in line:
                cp.write('MYTHTV_VERSION="{0}"\n'.format(self.opts.gitver))
            elif 'MYTHTV_BRANCH="' in line:
                cp.write('MYTHTV_BRANCH="{0}"\n'.format(self.branch))
            elif 'KEYWORDS="' in line:
                if self.opts.keyword:
                    keyword = self.opts.keyword
                else:
                    keyword = ('fixes' in self.branch) and 'amd64 x86 ~ppc' or '~amd64 ~x86 ~ppc'
                cp.write('KEYWORDS="{0}"\n'.format(keyword))
            else:
                cp.write(line)

        bp.close()
        cp.close()

    def digest(self, verbose=False, force=False):
        if self.opts.verbose: print 'Digesting...'
        nr = open('/dev/null','r')
        nw = open('/dev/null','w')
        if verbose:
            nw = sys.stdout
        cmd = ['ebuild']
        if force:
            cmd.append('--force')
        cmd.append(self.get_name(self.base))
        cmd.append('digest')
        dp = subprocess.Popen(cmd, stdin=nr, stdout=nw, stderr=nw)
        dp.wait()

parser = optparse.OptionParser()
parser.add_option("--verbose", action="store_true", dest="verbose",
                  help="Set verbose output.")
parser.add_option('-v', "--version", dest="version",
                  help="Specify major version to make ebuild for.")
parser.add_option('-s', "--hash", dest="hash",
                  help="Specify hash for commit.  If not provided, this will assume a tagged release.")
parser.add_option('-t', "--type", dest="type",
                  help="Specify release type for non-tagged ebuilds.")
parser.add_option("--date", dest="date",
                  help="Specify date for version.  If not provided, this will assume today's date.")
parser.add_option("--base", dest="base",
                  help="Specify a previous version to use for the base ebuild.")
parser.add_option("--packages", dest="packages",
                  help="Specify a comma deliminated list of packages to update.")
parser.add_option("--keyword", dest="keyword",
                  help="Specify a list of architecture keywords to use for masking.")
parser.add_option("--branch", dest="branch",
                  help="Specifies an alternate branch to use.  This is only used for properly setting the --version output.")
parser.add_option("--digest-only", action="store_true", dest="digest",
                  help="This command only runs digest on all specified packages, for help resolving git merges.")

opts,args = parser.parse_args()
Ebuild.opts = opts

opts.tarball = None
opts.shash = None
opts.gitver = None

if opts.date is None:
    opts.date = datetime.datetime.now().strftime('%Y%m%d')

if opts.packages is None:
    opts.packages = ['media-tv/mythtv',             'media-plugins/mytharchive',
                     'media-plugins/mythbrowser',   'media-plugins/mythgallery',
                     'media-plugins/mythgame',      'media-plugins/mythmusic',
                     'media-plugins/mythnetvision', 'media-plugins/mythnews',
                     'media-plugins/mythvideo',     'media-plugins/mythweather',
                     'media-plugins/mythzoneminder','media-tv/mythtv-bindings']
else:
    opts.packages = opts.packages.split(',')

for package in opts.packages:
    if opts.digest:
        e = Ebuild(package)
        e.get_base()
        e.digest(True, True)
    else:
        Ebuild(package).update()

