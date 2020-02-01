# Checks launchpad for an orig.tar.gz
# first argument: upstream version
# second argument: full path of destination to save file if it's found

import sys
import os
from launchpadlib.launchpad import Launchpad
try:
    from urllib.request import urlretrieve
except:
    from urllib import urlretrieve

cachedir = os.path.join(os.environ['HOME'], '.launchpadlib', 'cache')
launchpad = Launchpad.login_anonymously('mythtv daily builder', 'production', cachedir)
ubuntu = launchpad.distributions["ubuntu"]
archive = ubuntu.main_archive
series = ubuntu.current_series
full_version = archive.getPublishedSources(exact_match=True,source_name="mythtv", distro_series=series)[0].source_package_version
upstream_version = full_version.split(':')[1].split('-')[0]
print "Current version in the archive is: %s" % upstream_version
if len(sys.argv) > 1 and sys.argv[1] == upstream_version:
    urls = archive.getPublishedSources(exact_match=True,source_name="mythtv")[0].sourceFileUrls()
    for url in urls:
        if 'orig.tar.gz' in url:
            if len(sys.argv) > 2:
                destination = sys.argv[2]
            else:
                destination = os.path.basename(url)                            
            print("Fetching %s to %s" % (url, destination))
            urlretrieve(url, destination)
