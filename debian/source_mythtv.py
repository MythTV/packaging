import os.path, os
import subprocess
import apport.hookutils

def is_ppa(pkg):
    script = subprocess.Popen(['apt-cache', 'policy', pkg], stdout=subprocess.PIPE)
    output = script.communicate()[0]
    return 'mythbuntu' in output.split('\n')[1].replace("Installed: ", "")

def add_info(report):
    logs = [ '/var/log/mythtv/mythbackend.log',
             '/var/log/mythtv/mythfrontend.log',
             '/var/log/mythtv/jamu.log',
             '/proc/cpuinfo'
           ]
    for log in logs:
        apport.hookutils.attach_file_if_exists(report, log)

    report['MythTVDirectoryPermissions'] = apport.hookutils.command_output(['ls', '-l', '/var/lib/mythtv'])

    apport.hookutils.attach_hardware(report)

    if is_ppa('mythtv-common'):
        report['CrashDB'] = 'mythbuntu'

## DEBUGING ##
if __name__ == '__main__':
    report = {}
    add_info(report)
    for key in report:
        print '[%s]\n%s' % (key, report[key])
