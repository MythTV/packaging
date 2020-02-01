

from __future__ import print_function
import os.path, os
import subprocess
import apport.hookutils
import apport.packaging

def add_info(report):
    logdir = '/var/log/mythtv'
    if os.path.isdir(logdir):
        for logname in os.listdir(logdir):
            if logname.endswith('.log'):
                apport.hookutils.attach_file_if_exists(report, os.path.join(logdir, logname))

    report['MythTVDirectoryPermissions'] = apport.hookutils.command_output(['ls', '-l', '/var/lib/mythtv'])

    try:
        status = apport.packaging.get_version('mythtv-dbg')
    except ValueError:
        status = '0.0'
    report["Installed_mythtv_dbg"] = status

    if 'Package' in report and not apport.packaging.is_distro_package(report['Package'].split()[0]):
        report['CrashDB'] = 'mythbuntu'

## DEBUGING ##
if __name__ == '__main__':
    report = {}
    add_info(report)
    for key in report:
        print('[%s]\n%s' % (key, report[key]))
