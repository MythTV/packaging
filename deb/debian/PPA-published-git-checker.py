#!/usr/bin/env python

import sys 

cachedir = "~/.launchpadlib/cache/"

from launchpadlib.launchpad import Launchpad
launchpad = Launchpad.login_anonymously('mythbuntu PPA version checker', 'production', cachedir)

people = launchpad.people

## Which team 
mythbuntugroup = people['mythbuntu']

## Which PPA?
archive = mythbuntugroup.getPPAByName(name=sys.argv[1])

## Which source package?
package=archive.getPublishedSources(source_name="mythtv")

try:
    ## Print latest published source package
    fullversion=package[0].source_package_version
    ## Pull out GIT hash
    hash = fullversion.split('-')[0].split('.')[4]
except IndexError:
    hash = ''
print hash
