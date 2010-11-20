#!/usr/bin/env python

import re
import sys 

cachedir = "~/.launchpadlib/cache/"

from launchpadlib.launchpad import Launchpad
launchpad = Launchpad.login_anonymously('just testing', 'production', cachedir)

people = launchpad.people

## Which team 
mythbuntugroup = people['mythbuntu']

## Which PPA?
archive = mythbuntugroup.getPPAByName(name=sys.argv[1])

## Which source package?
package=archive.getPublishedSources(source_name="mythtv")

## Print latest published source package
fullversion=package[0].source_package_version

## Pull out SVN revision
svnrevision = re.search ( '\d{5}', fullversion ).group(0)

print svnrevision
