import os.path, os
import subprocess
import apport.hookutils
import apport.packaging

def add_info(report):
    logs = [ '/var/log/mythtv/mythbackend.log',
             '/var/log/mythtv/mythfrontend.log',
           ]
    for log in logs:
        apport.hookutils.attach_file_if_exists(report, log)

    report['MythTVDirectoryPermissions'] = apport.hookutils.command_output(['ls', '-l', '/var/lib/mythtv'])

    dbg_packages = [ 'mythtv-dbg',
                     'mythplugins-dbg'
                   ]
    for dbg in dbg_packages:
        try:
            status = apport.packaging.get_version(dbg)
        except ValueError:
            status = '0.0'
        report["Installed_" + dbg] = status

    if report.has_key('Package') and not apport.packaging.is_distro_package(report['Package'].split()[0]):
        report['CrashDB'] = 'mythbuntu'

## DEBUGING ##
if __name__ == '__main__':
    report = {}
    add_info(report)
    for key in report:
        print '[%s]\n%s' % (key, report[key])
