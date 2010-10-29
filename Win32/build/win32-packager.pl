#!c:/perl/bin/perl.exe -w
##############################################################################
### =file
### win32-packager.pl
###
### =location
### http://svn.mythtv.org/svn/trunk/packaging/Win32/build/win32-packager.pl
###
### =description
### Tool for automating frontend builds on MS Windows XP (and compatible)
### originally based loosely on osx-packager.pl, but now is its own beast.
###
### =examples
### win32-packager.pl -h
###      => Print usage
### win32-packager.pl
###      => based on latest "tested" SVN trunk (ie a known-good win32 build)
### win32-packager.pl -r head
###      => based on trunk head
### win32-packager.pl -b
###      => based on release-021-fixes branch
### win32-packager.pl -b -t
###      => include some patches which are not accepted, but needed for Win32
### win32-packager.pl -b -t -k
###      =>Same but package and create setup.exe at the end
###
### =revision
### $Id$
###
### =author
### David Bussenschutt
##############################################################################

use strict;
use LWP::UserAgent;
use IO::File;
use Data::Dumper; 
use File::Copy qw(cp);
use Getopt::Std;
use Digest::MD5;


$SIG{INT} = sub { die "Interrupted\n"; };
$| = 1; # autoflush stdout;

# this script was last tested to work with this version, on other versions YMMV.
my $SVNRELEASE = '25919'; # Recent trunk
#my $SVNRELEASE = 'HEAD'; # If you are game, go forth and test the latest!


# We allow SourceForge to tell us which server to download from,
# rather than assuming specific server/s
my $sourceforge = 'downloads.sourceforge.net';     # auto-redirect to a
                                                   # mirror of SF's choosing,
                                                   # hopefully close to you
# alternatively you can choose your own mirror:
#my $sourceforge = 'optusnet.dl.sourceforge.net';  # Australia
#my $sourceforge = 'internap.dl.sourceforge.net';  # USA,California
#my $sourceforge = 'easynews.dl.sourceforge.net';  # USA,Arizona,Phoenix,
#my $sourceforge = 'jaist.dl.sourceforge.net';     # Japan
#my $sourceforge = 'mesh.dl.sourceforge.net';      # Germany
#my $sourceforge = 'transact.dl.sourceforge.net';  # Germany

# Set this to the empty string for no-proxy:
my $proxy = '';
#my $proxy = 'http://enter.your.proxy.here:8080';
# Subversion proxy settings are configured in %APPDATA%\Subversion\servers

my $NOISY   = 1;            # Set to 0 for less output to the screen
my $version = '0.24';       # Main mythtv version - used to name dlls
my $package = 0;            # Create a Win32 Distribution package? 1 for yes
my $compile_type = "profile"; # compile options: debug, profile or release
my $tickets = 0;            # Apply specific win32 tickets -
                            #  usually those not merged into SVN
my $dbconf = 0;             # Configure MySQL as part of the build process.
                            #  Required only for testing
my $makeclean = 0;          # Flag to make clean
my $svnlocation = "trunk";  # defaults to trunk unless -b specified
my $qtver = 4;              # default to 4 until we can test otherwise
my $continuous = 0 ;        # by default the app pauses to notify you what
                            #  it's about to do, -y overrides for batch usage.

##############################################################################
# get command line options
my $opt_string = 'vhogkp:r:c:tldby';
my %opt = ();
getopts( "$opt_string", \%opt );
usage() if $opt{h};

$package    = 1       if defined $opt{k};
$NOISY      = 1       if defined $opt{v};
$tickets    = 1       if defined $opt{t};
$proxy      = $opt{p} if defined $opt{p};
$SVNRELEASE = $opt{r} if defined $opt{r};
$dbconf     = 1       if defined $opt{d};
$makeclean  = 1       if defined $opt{l};
$continuous  = 1       if defined $opt{y};


if (defined $opt{c}) {
    $compile_type = $opt{c} if ($opt{c} eq "release") ;
    $compile_type = $opt{c} if ($opt{c} eq "profile") ;
}

if (defined $opt{b}) {
    my @num = split /\./, $version;
    $svnlocation = "branches/release-$num[0]-$num[1]-fixes";
    #
    # Releases like 0.23.1 are actually tags, and use a different location:
    #if ($version =~ m/-\d$/) {
    #    $svnlocation = "tags/release-$num[0]-$num[1]-$num[2]";
    #}
} else {
    $svnlocation = "trunk";
}

# Try to use parallel make
my $numCPU = $ENV{'NUMBER_OF_PROCESSORS'} or 1;
my $parallelMake = 'make';
if ( $numCPU gt 1 ) {
    # Pre-queue one extra job to keep the pipeline full:
    $parallelMake = 'make -j '. ($numCPU + 1);
}

# this list defines the components to build
my @components = ( 'mythtv', 'packaging', 'myththemes' );
push @components, 'oldthemes' if defined $opt{o};
push @components, 'mythplugins' unless defined $opt{g};

print "Config:\n\tQT version: $qtver\n\tDLLs will be labeled as: $version\n";
if ( $numCPU gt 1 ) {
    print "\tBuilding with ", $numCPU, " processors\n";
}
print "\tSVN location is: $svnlocation\n\tSVN revision is: $SVNRELEASE\n";
print "\tComponents to build: ";
foreach my $comp( @components ) { print "$comp " }
print "\n\nPress [enter] to continue, or [ctrl]-c to exit now....\n";
getc() unless $continuous;

# this will be used to test if we the same
# basic build type/layout as previously.
my $is_same = "$compile_type-$svnlocation-$qtver.same";
$is_same =~ s#/#-#g; # don't put dir slashes in a filename!


# TODO - we should try to autodetect these paths, rather than assuming
#        the defaults - perhaps from environment variables like this:
#  die "must have env variable SOURCES pointing to your sources folder"
#      unless $ENV{SOURCES};
#  my $sources = $ENV{SOURCES};
# TODO - although theoretically possible to change these paths,
#        it has NOT been tested much,
#        and will with HIGH PROBABILITY fail somewhere.
#      - Only $mingw is tested and most likely is safe to change.

# Perl compatible paths. DOS style, but forward slashes, and must end in slash:
# TIP: using paths with spaces in them is NOT supported, and will break.
#      patches welcome.
my $msys    = 'C:/MSys/1.0/';
my $sources = 'C:/MSys/1.0/sources/';
my $mingw   = 'C:/MinGW/';
my $mythtv  = 'C:/mythtv/';       # this is where the entire SVN checkout lives
                                  # so c:/mythtv/mythtv/ is the main codebase.
my $build   = 'C:/mythtv/build/'; # where 'make install' installs into

# Where is the users home?
# Script later creates $home\.mythtv\mysql.txt
my $doshome = '';
if ( ! exists $ENV{'HOMEPATH'} || $ENV{'HOMEPATH'} eq '\\' ) {
  $doshome = $ENV{'USERPROFILE'};
} else {
  $doshome = $ENV{HOMEDRIVE}.$ENV{HOMEPATH};
}
my $home = $doshome;
$home =~ s#\\#/#g;
$home =~ s/ /\\ /g;
$home .= '/'; # all paths should end in a slash

# Where are program files (32-bit)?
my $dosprogramfiles = '';
if ( $ENV{'ProgramFiles(x86)'} ) {
  $dosprogramfiles = $ENV{'ProgramFiles(x86)'};
} else {
  $dosprogramfiles = $ENV{'ProgramFiles'};
}
my $programfiles = $dosprogramfiles;
$programfiles =~ s#\\#/#g;

my $mysql   = $programfiles.'/MySQL/MySQL Server 5.1/';

# DOS executable CMD.exe versions of the paths (for when we shell to DOS mode):
my $dosmsys    = perl2dos($msys);
my $dossources = perl2dos($sources);
my $dosmingw   = perl2dos($mingw);
my $dosmythtv  = perl2dos($mythtv);
my $dosmysql   = perl2dos($mysql);

# Unix/MSys equiv. versions of the paths (for when we shell to MSYS/UNIX mode):
my $unixmsys  = '/';       # MSys root is always mounted here,
                           # irrespective of where DOS says it really is.
my $unixmingw = '/mingw/'; # MinGW is always mounted here under unix,
                           # if you setup mingw right in msys,
                           # so we will usually just say /mingw in the code,
                           # not '.$unixmingw.' or similar (see /etc/fstab)
my $unixsources      = perl2unix($sources);
my $unixmythtv       = perl2unix($mythtv);
my $unixhome         = perl2unix($home);
my $unixprogramfiles = perl2unix($programfiles);
my $unixbuild        = perl2unix($build);

# Qt4 directory
my $qt4dir     = 'C:/qt/4.6.3/';
my $dosqt4dir  = perl2dos($qt4dir);
my $unixqt4dir = perl2unix($qt4dir);

#NOTE: IT'S IMPORTANT that the PATHS use the correct SLASH-ing method for
#the type of action:
#      for [exec] actions, use standard DOS paths, with single BACK-SLASHES
#      '\' (unless in double quotes, then double the backslashes)
#      for [shell] actions, use standard UNIX paths, with single
#      FORWARD-SLASHES '/'
#
#NOTE: when referring to variables in paths, try to keep them out of double
#quotes, or the slashing can get confused:
#      [exec]   actions should always refer to  $dosXXX path variables
#      [shell]  actions should always refer to $unixXXX path  variables
#      [dir],[file],[mkdirs],[archive] actions should always refer to
#      default perl compatible paths
# NOTE:  The architecture of this script is based on cause-and-event.
#        There are a number of "causes" (or expectations) that can trigger
#        an event/action.
#        There are a number of different actions that can be taken.
#
# eg: [ dir  => "c:/MinGW", exec => $dossources.'MinGW-5.1.4.exe' ],
#
# means: expect there to be a dir called "c:/MinGW", and if there isn't
# execute the file MinGW-5.1.4.exe. (clearly there needs to be a file
# MinGW-5.1.4.exe on disk for that to work, so there is an earlier
# declaration to 'fetch' it)


#build expectations (causes) :
#  missing a file (given an expected path)                           [file]
#  missing folder                                                    [dir]
#  missing source archive (version of 'file' to fetch from the web)  [archive]
#  apply a perl pattern match and if it DOESNT match execute action  [grep]
#  - this 'cause' actually needs two parameters in an array
#    [ pattern, file].  If the file is absent, the pattern
#    is assumed to not match (and emits a warning).
#  test the file/s are totally the same (by size and mtime)          [filesame]
#  - if first file is non-existant then that's permitted,
#    it causes the action to trigger.
#  test the first file is newer(mtime) than the second one           [newer]
#  - if given 2 existing files, not necessarily same size/content,
#    and the first one isn't newer, execute the action!
#    If the first file is ABSENT, run the action too.
#  execute the action only if a file or directory exists             [exists]
#  stop the run, useful for script debugging                         [stop]
#  pause the run, await a enter                                      [pause]
#  always execute the action  (try to minimise the use of this!)     [always]

#build actions (events) are:
#  fetch a file from the web (to a location)                         [fetch]
#  execute a DOS/Win32 exe/command and wait to complete              [exec]
#  execute a MSYS/Unix script/command in bash and wait to complete   [shell]
#  - this 'effect' actually accepts many parameters in an array
#    [ cmd1, cmd2, etc ]
#  extract a .tar .tar.gz or .tar.bz2 or ,zip file ( to a location)  [extract]
#  - (note that .gz and .bz2 are thought equivalent)
#  write a small patch/config/script file directly to disk           [write]
#  make directory tree upto the path specified                       [mkdirs]
#  copy a new version of a file, set mtime to the original           [copy]
#  tell the user there is something we can't fix, then exit          [exit]

#TODO:
#  copy a set of files (path/filespec,  destination)               not-yet-impl
#   =>  use exec => 'copy /Y xxx.* yyy'
#  apply a diff                                                    not-yet-impl
#   =>   use shell => 'patch -p0 < blah.patch'
#  search-replace text in a file                                   not-yet-impl
#   =>   use grep => ['pattern',subject],
#                     exec => shell 'patch < etc to replace it'


# NOTES on specific actions:
# 'extract' now requires all paths to be perl compatible (like all other
# commands) If not supplied, it extracts into the folder the .tar.gz is in.
# 'exec' actually runs all your commands inside a single cmd.exe
# command-line. To link commands use '&&'
# 'shell' actually runs all your commands inside a bash shell with -c "(
# cmd;cmd;cmd )" so be careful about quoting.


#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# DEFINE OUR EXPECTATIONS and the related ACTIONS:
#  - THIS IS THE GUTS OF THE APPLICATION!
#  - A SET OF DECLARATIONS THAT SHOULD RESULT IN A WORKING WIN32 INSTALATION
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

my $expect;

push @{$expect},

[ dir => [$sources] ,
  mkdirs  => [$sources],
  comment => 'We download all the files from the web, and save them here:'],

# (alternate would be from the gnuwin32 project,
#  which is actually from same source)
#  run it into a 'unzip' folder, because it doesn't extract to a folder:
[ dir     => $sources."unzip",
  mkdirs  => $sources.'unzip',
  comment => 'unzip.exe - Get a precompiled '.
             'native Win32 version from InfoZip' ],
[ archive => $sources.'unzip/unz552xN.exe',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/unz552xn.exe'],
[ file    => $sources.'unzip/unzip.exe',
  exec    => 'chdir /d '.$dossources.'unzip && '.
             $dossources.'unzip/unz552xN.exe' ],
# we could probably put the unzip.exe into the path...

[ archive => $sources.'MinGW-gcc440_1.zip',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/MinGW-gcc440_1.zip',
  comment => 'Get mingw and addons first, or we cant do [shell] requests!' ],
[ archive => $sources.'mingw-utils-0.3.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/mingw-utils-0.3.tar.gz' ],
# Need updated binutils to build ffmpeg DLLs properly with gcc 4.4
[ archive => $sources.'binutils-2.20-1-mingw32-bin.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/binutils-2.20-1-mingw32-bin.tar.gz' ],
# Need updated mingwrt for fixed usleep()
[ archive => $sources.'mingwrt-3.17-mingw32-dev.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/mingwrt-3.17-mingw32-dev.tar.gz' ],
[ archive => $sources.'mingwrt-3.17-mingw32-dll.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/mingwrt-3.17-mingw32-dll.tar.gz' ],
# patch.exe included with MSYS 1.0.11 is broken, so update it
[ archive => $sources.'patch-2.5.9-1-msys-1.0.11-bin.tar.lzma',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/patch-2.5.9-1-msys-1.0.11-bin.tar.lzma' ],

[ dir     => $mingw,
  mkdirs  => $mingw],
[ file    => $mingw.'mingw/manifest.txt',
  extract => [$sources.'MinGW-gcc440_1.zip', $mingw],
  comment => 'install Qt MinGW bundle (includes gcc, g++, gdb, mingw-make)' ],
[ dir     => $mingw.'_patches',
  exec    => "for /d %i in ($dosmingw\\mingw\\*.*) do move /y %i $dosmingw",
  comment => 'Move mingw directories to install location' ],

[ archive => $sources.'MSYS-1.0.11.exe',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/MSYS-1.0.11.exe',
  comment => 'Get the MSYS and addons:' ] ,
[ archive => $sources.'libz-1.2.3-1-mingw32-dev.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/libz-1.2.3-1-mingw32-dev.tar.gz' ] ,
[ archive => $sources.'libz-1.2.3-1-mingw32-dll-1.tar.gz',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/libz-1.2.3-1-mingw32-dll-1.tar.gz' ] ,
[ archive => $sources.'coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2' ] ,
[ archive => $sources.'mktemp-1.5-MSYS.tar.bz2',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/mktemp-1.5-MSYS.tar.bz2' ] ,

# install MSYS, it supplies the 'tar' executable, among others:
[ file    => $msys.'bin/tar.exe',
  exec    => $dossources.'MSYS-1.0.11.exe',
  comment => 'Install MSYS, it supplies the tar executable, among others. You '.
             'should follow prompts, AND do post-install in DOS box.' ] ,

#  don't use the [shell] or [copy] actions here,
# as neither are avail til bash is installed!
[ file    => $msys.'bin/sh2.exe',
  exec    => 'copy /Y '.$dosmsys.'bin\sh.exe '.$dosmsys.'bin\sh2.exe',
  comment => 'make a copy of the sh.exe so that we can '.
             'utilise it when we extract later stuff' ],

# prior to this point you can't use the 'extract' 'copy' or 'shell' features!

# now that we have the 'extract' feature, we can finish ...
[ file    => $mingw.'/bin/reimp.exe',
  extract => [$sources.'mingw-utils-0.3.tar', $mingw],
  comment => 'Now we can finish all the mingw and msys addons:' ],
[ file    => $mingw.'/share/info/binutils.info',
  extract => [$sources.'binutils-2.20-1-mingw32-bin.tar', $mingw] ],
[ grep    => ['__MINGW32_VERSION           3.17', $mingw.'include/_mingw.h'],
  extract => [$sources.'mingwrt-3.17-mingw32-dev.tar', $mingw] ],
[ always  => ['No unique file to check'],
  extract => [$sources.'mingwrt-3.17-mingw32-dll.tar', $mingw] ],
[ dir     => $sources.'coreutils-5.97',
  extract => [$sources.'coreutils-5.97-MSYS-1.0.11-snapshot.tar'] ],
[ file    => $msys.'bin/pr.exe',
  shell   => ["cd ".$unixsources."coreutils-5.97","cp -r * / "] ],
[ file    => $msys.'bin/mktemp.exe',
  extract => [$sources.'mktemp-1.5-MSYS.tar', $msys] ],
[ always  => ['No unique file to check'],
  extract => [$sources.'patch-2.5.9-1-msys-1.0.11-bin.tar', $msys] ],
[ always  => ['Make sure we overwrite old msys-z lib files'],
  extract => [$sources.'libz-1.2.3-1-mingw32-dev.tar', $msys] ],
[ file    => $msys.'bin/libz-1.dll',
  extract => [$sources.'libz-1.2.3-1-mingw32-dll-1.tar', $msys] ],

[ dir     => $msys."lib" ,  mkdirs => $msys.'lib' ],
[ dir     => $msys."include" ,  mkdirs => $msys.'include' ],

# we now use SVN 1.6.x
[ archive => $sources.'svn-win32-1.6.12.zip',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/svn-win32-1.6.12.zip',
  comment => 'Subversion comes as a zip file, so it '.
             'cant be done earlier than the unzip tool!'],
[ dir     => $sources.'svn-win32-1.6.12',
  extract => $sources.'svn-win32-1.6.12.zip' ],

# link to svn instead of installing it, to avoid packaging its dlls later
[ always  => $msys.'bin/svn.bat',
  write   => [$msys.'bin/svn.bat',
  '@'.$dossources.'svn-win32-1.6.12\bin\svn.exe %*' ],
  comment => 'put svn.bat into the path, '.
             'so we can use it easily later!' ],

[ always  => $msys.'bin/svnversion',
  write   => [$msys.'bin/svnversion', 
'#!/bin/sh
'.$unixsources.'svn-win32-1.6.12/bin/svnversion.exe $*' ],
  comment => 'put svnversion into the path, '.
             'so mythtv can use it later!' ],

# fetch mysql
# primary server site is:
# http://dev.mysql.com/downloads/mysql/5.1.html#downloads
# but that has no mirror autoselection, so we have just picked one.
# If this fails you, try another mirror, or maybe an archived version:
# http://downloads.mysql.com/archives/mysql-5.1/mysql-essential-5.1.42-win32.msi
[ archive => $sources.'mysql-essential-5.1.49-win32.msi',
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/mysql-essential-5.1.49-win32.msi',
  comment => 'fetch mysql binaries - this is a big download(35MB) '.
             'so it might take a while' ],
[ file    => $mysql.'bin/libmySQL.dll',
  exec    => $dossources.'mysql-essential-5.1.49-win32.msi INSTALLLEVEL=2',
  comment => 'Install mysql - be sure to choose to do a "COMPLETE" install. '.
             'You should also choose NOT to "configure the server now" ' ],

# after mysql install
[ filesame => [$msys.'bin/libmySQL.dll', $mysql.'bin/libmySQL.dll'],
  copy     => [''=>'',
  comment  => 'post-mysql-install'] ],
[ filesame => [$msys.'lib/libmySQL.dll', $mysql.'bin/libmySQL.dll'],
  copy     => [''=>'',
  comment  => 'post-mysql-install'] ],
[ filesame => [$msys.'lib/libmysql.lib', $mysql.'lib/opt/libmysql.lib'],
  copy     => [''=>''] ],
[ file     => $msys.'include/mysql.h',
  exec     => 'copy /Y "'.$dosmysql.'include\*" '.$dosmsys.'include' ],


# make sure that /mingw is mounted in MSYS properly before trying
# to use the /mingw folder.  this is supposed to happen as part
# of the MSYS post-install, but doesnt always work.
[ always  => '',
  shell   => ['rm -f mingw-is-good',
              '[ -d /mingw/bin ] && touch mingw-is-good'],
  comment => 'Looking for /mingw mountpoint' ],

[ file    => 'mingw-is-good',
  exit    => 'There is no /mingw mount point under MSYS.
Maybe the MSYS post-install failed?

Please create/edit C:\MSYS\1.0\etc\fstab and add a line like:

C:/MinGW	/mingw'],

#
# TIP: we use a special file (with two extra _'s )
#      as a marker to say this acton is already done!
[ file    => $msys.'lib/libmysql.lib__',
  shell   => ["cd /usr/lib","reimp -d libmysql.lib",
           "dlltool -k --input-def libmysql.def --dllname libmysql.dll".
           " --output-lib libmysql.a",
           "touch ".$unixmsys.'lib/libmysql.lib__'],
  comment => ' rebuild libmysql.a' ],

# grep    => [pattern,file] , actions/etc
[ file    => $msys.'include/mysql___h.patch',
  write   => [$msys.'include/mysql___h.patch',
'--- mysql.h_orig	Fri Jan  4 19:35:33 2008
+++ mysql.h	Tue Jan  8 14:48:36 2008
@@ -45,11 +45,9 @@

 #ifndef _global_h				/* If not standard header */
 #include <sys/types.h>
-#ifdef __LCC__
 #include <winsock2.h>				/* For windows */
-#endif
 typedef char my_bool;
-#if (defined(_WIN32) || defined(_WIN64)) && !defined(__WIN__)
+#if (defined(_WIN32) || defined(_WIN64) || defined(__MINGW32__)) && !defined(__WIN__)
 #define __WIN__
 #endif
 #if !defined(__WIN__)
' ],comment => 'write the patch for the the mysql.h file'],
# apply it!?
[ grep    => ['\|\| defined\(__MINGW32__\)',$msys.'include/mysql.h'],
  shell   => ["cd /usr/include","patch -p0 < mysql___h.patch"],
  comment => 'Apply mysql.h patch file, if not already applied....' ],

# Qt MinGW distribution includes pthread headers but not the DLL, so fetch it
[ archive => $sources.'pthreadGC2.dll',  
  'fetch' => 'http://mythtv-for-windows.googlecode.com/files/pthreadGC2.dll' ], 
[ filesame => [$mingw.'bin/pthreadGC2.dll', $sources."pthreadGC2.dll"], 
  copy     => [''=>''] ], 

# apply sspi.h patch
[ file    => $mingw.'include/sspi_h.patch',
  write   => [$mingw.'include/sspi_h.patch',
'*** sspi.h      Sun Jan 25 17:55:57 2009
--- sspi.h.new  Sun Jan 25 17:55:51 2009
***************
*** 8,13 ****
--- 8,15 ----
  extern "C" {
  #endif
  
+ #include <subauth.h>
+ 
  #define SECPKG_CRED_INBOUND 1
  #define SECPKG_CRED_OUTBOUND 2
  #define SECPKG_CRED_BOTH (SECPKG_CRED_OUTBOUND|SECPKG_CRED_INBOUND)

' ],comment => 'write the patch for the the sspi.h file'],
# apply it!?
[ grep    => ['subauth.h',$mingw.'include/sspi.h'], 
  shell   => ["cd /mingw/include","patch -p0 < sspi_h.patch"],
  comment => 'Apply sspi.h patch file, if not already applied....' ],

#[ pause => 'check  patch.... press [enter] to continue !'],

# apply sched.h patch
[ always    => $mingw.'mingw32/include/sched_h.patch', 
  write   => [$mingw.'mingw32/include/sched_h.patch',
"--- include/sched.h.org	Thu Dec  4 12:00:16 2008
+++ include/sched.h	Wed Dec  3 13:42:54 2008
@@ -124,8 +124,17 @@
 typedef int pid_t;
 #endif
 
-/* Thread scheduling policies */
+/* pid_t again! */
+#if defined(__MINGW32__) || defined(_UWIN)
+/* Define to `int' if <sys/types.h> does not define. */
+/* GCC 4.x reportedly defines pid_t. */
+#ifndef _PID_T_
+#define _PID_T_
+#define pid_t int
+#endif
+#endif
 
+/* Thread scheduling policies */
 enum {
   SCHED_OTHER = 0,
   SCHED_FIFO,
" ],comment => 'write the patch for the the sched.h file'],
# apply it!?
[ grep    => ['pid_t again!',$mingw.'mingw32/include/sched.h'], 
  shell   => ["cd /mingw/mingw32/include", "patch -p1 < sched_h.patch"],
  comment => 'Apply sched.h patch file, if not already applied....' ],

#[ pause => 'check  patch.... press [enter] to continue !'],


#   ( save bandwidth compare to the above full SDK where they came from:
[ archive  => $sources.'DX9SDK_dsound_Include_subset.zip', 
  'fetch'  => 'http://mythtv-for-windows.googlecode.com/files/DX9SDK_dsound_Include_subset.zip',
  comment  => 'We download just the required Include files for DX9' ], 
[ dir      => $sources.'DX9SDK_dsound_Include_subset', 
  extract  => $sources.'DX9SDK_dsound_Include_subset.zip' ],
[ filesame => [$mingw.'include/dsound.h',$sources.
               "DX9SDK_dsound_Include_subset/dsound.h"], 
  copy     => [''=>''] ],
[ filesame => [$mingw.'include/dinput.h',$sources.
               "DX9SDK_dsound_Include_subset/dinput.h"], 
  copy     => [''=>''] ],
[ filesame => [$mingw.'include/ddraw.h', $sources.
               "DX9SDK_dsound_Include_subset/ddraw.h"],  
  copy     => [''=>''] ],
[ filesame => [$mingw.'include/dsetup.h',$sources.
               "DX9SDK_dsound_Include_subset/dsetup.h"], 
  copy     => [''=>''] ],
;

# if packaging is selected, get innosetup
if ($package == 1) {
  push @{$expect},
 [ archive => $sources.'isetup-5.2.3.exe',
     fetch => 'http://files.jrsoftware.org/ispack/ispack-5.2.3.exe',
   comment => 'fetch inno setup setup' ],
 [ file    => $programfiles.'/Inno Setup 5/iscc.exe',
   exec    => $dossources.'isetup-5.2.3.exe', #/silent is broken! 
   comment => 'Install innosetup - install ISTool, '.
              'ISSP, AND encryption support.' ],
 # Get advanced uninstall
 [ archive => $sources.'UninsHs.rar',
     fetch => 'http://www.uninshs.com/down/UninsHs.rar',
   comment => 'fetch uninstall for innosetup' ],
 [ archive => $sources.'unrar-3.4.3-bin.zip',
     fetch => 'http://downloads.sourceforge.net/gnuwin32/unrar-3.4.3-bin.zip',
   comment => 'fetching unrar'],
 [ file    => $sources.'bin/unrar.exe',
  shell    => ["cd ".$sources, "unzip/unzip.exe unrar-3.4.3-bin.zip"]],
 [ file    => $programfiles.'/Inno Setup 5/UninsHs.exe',
  shell    => ['cd "'.$unixprogramfiles.'/inno setup 5"',
              $sources.'bin/unrar.exe e '.$sources.'UninsHs.rar'],
  comment  => 'Install innosetup' ],
 [ archive => $sources.'istool-5.2.1.exe',
     fetch => 'http://downloads.sourceforge.net/sourceforge'.
              '/istool/istool-5.2.1.exe',
   comment => 'fetching istool' ],
 [ file    => $programfiles.'/ISTool/isxdl.dll',
   exec    => $dossources.'istool-5.2.1.exe /silent',
   comment => 'Install istool'],
 [ archive => $sources.'logo_mysql_sun.gif',
     fetch => 'http://www.mysql.com/common/logos/logo_mysql_sun.gif',
   comment => 'Download MySQL logo for an install page in the package' ],
 [ exists  => $mythtv.'build/package_flag',
    shell  => ["rm ".$unixmythtv."build/package_flag"],
   comment => '' ],
;
}


#----------------------------------------
# Install QT4 binaries now to get interactive elements out of the way
#----------------------------------------
if ( $qtver == 4  ) {
push @{$expect}, 
[ archive => $sources.'qt-win-opensource-4.6.3-mingw.exe',  
    fetch => 'http://get.qt.nokia.com/qt/source/'.
             'qt-win-opensource-4.6.3-mingw.exe',
    comment => 'Downloading QT binaries; this will take a LONG time (267MB)' ],
[ file => $qt4dir.'bin/QtCore4.dll', 
  exec => $dossources.'qt-win-opensource-4.6.3-mingw.exe',
  comment => 'Install Qt - use default options.  ' ],
;
} # end of QT4 install - we will patch and build mysql driver later


#----------------------------------------
# now we do each of the source library dependencies in turn:
# download,extract,build/install
# TODO - ( and just pray that they all work?)  These should really be more
# detailed, and actually check that we got it installed properly.
# Most of these look for a Makefile as a sign that the ./configure was
# successful (not necessarily true, but it's a start) but this requires that
# the .tar.gz didn't come with a Makefile in it.

# Most of these look for a Makefile as a sign that the
# ./configure was successful (not necessarily true, but it's a start)
# but this requires that the .tar.gz didn't come with a Makefile in it.
push @{$expect},
[ archive => $sources.'freetype-2.3.5.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/freetype-2.3.5.tar.gz'],
[ dir     => $sources.'freetype-2.3.5', 
  extract => $sources.'freetype-2.3.5.tar' ],
# caution... freetype comes with a Makefile in the .tar.gz, so work around it!
[ file    => $sources.'freetype-2.3.5/Makefile__', 
  shell   => ["cd $unixsources/freetype-2.3.5",
              "./configure --prefix=/usr",
              "touch $unixsources/freetype-2.3.5/Makefile__"],
  comment => 'building freetype' ],
              
# here's an example of specifying the make and make install steps separately, 
# for apps that can't be relied on to have the make step work!
[ file    => $sources.'freetype-2.3.5/objs/.libs/libfreetype.a', 
  shell   => ["cd $unixsources/freetype-2.3.5",
              "make"],
  comment => 'checking freetype' ],
[ file    => $msys.'lib/libfreetype.a', 
  shell   => ["cd $unixsources/freetype-2.3.5",
              "make install"],
  comment => 'installing freetype' ],
[ file    => $msys.'bin/libfreetype-6.dll', 
  shell   => ["cp $unixsources/freetype-2.3.5/objs/.libs/libfreetype-6.dll ".
              "$msys/bin/"] ],

#eg: http://transact.dl.sourceforge.net/sourceforge/lame/lame-398-2.tar.gz
[ archive => $sources.'lame-398-2.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/lame-398-2.tar.gz'],
[ dir     => $sources.'lame-398-2', 
  extract => $sources.'lame-398-2.tar' ],
[ file    => $msys.'lib/libmp3lame.a', 
  shell   => ["cd $unixsources/lame-398-2",
              "./configure --prefix=/usr",
              "make",
              "make install"],
  comment => 'building and installing: msys lame' ],
;

if ( grep m/mythplugins/, @components ) {
push @{$expect},
# taglib 1.6 sources changed it's build system under win32 to use 'cmake', 
# which we don't have, however pre-compiled mingw 1.6 binaries are available:
[ archive => $sources.'taglib-1.6.1-mingw-bin.zip',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/taglib-1.6.1-mingw-bin.zip'],
[ dir     => $sources.'taglib-1.6.1-mingw-bin',
  mkdirs  => $sources.'taglib-1.6.1-mingw-bin'],
[ dir     => $sources.'taglib-1.6.1-mingw-bin/bin',
  extract => [$sources.'taglib-1.6.1-mingw-bin.zip',
              $sources.'taglib-1.6.1-mingw-bin' ]],
[ file    => $msys.'lib/libtag.dll.a',
  shell   => ['cd '.$sources.'taglib-1.6.1-mingw-bin',
              "cp -vr * $unixmsys"],
  comment => 'installing: msys taglib' ],
# Hack for mythplugins/configure to detect taglib version:
[ file    => $mingw.'bin/taglib-config',
  write   => [$mingw.'bin/taglib-config',
'#!/bin/sh
case $1 in
  "--version") echo 1.6.1    ;;
  "--prefix")  echo /mingw ;;
esac'] ],
[ always  => [],
  shell   => ["chmod 755 $mingw/bin/taglib-config"] ],
              
# NOTE: --disable-fast-perl fixes makefiles that otherwise have bits like below:
# INSTALL = ../C:/msys/1.0/bin/install -c -p
# INSTALL = ../../C:/msys/1.0/bin/install -c -p

# confirmed latest version as at 26-12-2008:
[ archive => $sources.'libao-0.8.8.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/libao-0.8.8.tar.gz'],
[ dir     => $sources.'libao-0.8.8', 
  extract => $sources.'libao-0.8.8.tar' ],
[ file    => $msys.'bin/libao-2.dll',  
  # test completion of LAST step (ie make install), not the first one.
  shell   => ["cd $unixsources/libao-0.8.8",
              "./configure --prefix=/usr",
              "make",
              "make install"],
  comment => 'building and installing: libao' ],

# confirmed latest version as at 26-12-2008:
# definitely need mingw version of ogg for plugins,
# and for mingw vorbis to build!
[ archive => $sources.'libogg-1.1.3.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/libogg-1.1.3.tar.gz'],
[ dir     => $sources.'libogg-1.1.3', 
  extract => $sources.'libogg-1.1.3.tar' ],
[ file    => $msys.'bin/libogg-0.dll', 
  shell   => ["cd $unixsources/libogg-1.1.3",
              "./configure --prefix=/usr",
              "make",
              "make install"],
  comment => 'building and installing: msys libogg' ],

# confirmed latest version as at 26-12-2008:
[ archive => $sources.'libvorbis-1.2.0.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/libvorbis-1.2.0.tar.gz'],
[ dir     => $sources.'libvorbis-1.2.0', 
  extract => $sources.'libvorbis-1.2.0.tar' ],
[ file    => $msys.'lib/libvorbis.a', 
  shell   => ["cd $unixsources/libvorbis-1.2.0",
              "./configure --prefix=/usr --disable-shared",
              "make",
              "make install"],
  comment => 'building and installing: msys libvorbis' ],

# confirmed latest source version as at 26-12-2008:
[ archive => $sources.'SDL-devel-1.2.13-mingw32.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/SDL-devel-1.2.13-mingw32.tar.gz'],
[ file    => $sources.'SDL-1.2.13/bin/SDL.dll', 
  extract => $sources.'SDL-devel-1.2.13-mingw32.tar.gz' ],
[ file    => $msys.'bin/SDL.dll', 
  shell   => ["cd $unixsources/SDL-1.2.13",
              "make install-sdl prefix=/usr"],
  comment => 'building and installing: SDL' ],

# confirmed latest source version as at 26-12-2008
[ archive => $sources.'libexif-0.6.17.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/libexif-0.6.17.tar.gz'],
[ dir     => $sources.'libexif-0.6.17', 
  extract => $sources.'libexif-0.6.17.tar' ],
[ file    => $msys.'bin/libexif-12.dll', 
  shell   => ["cd $unixsources/libexif-0.6.17",
              "./configure --prefix=/usr",
              "make",
              "make install"],
  comment => 'building and installing: libexif' ],
[ file    => $msys.'bin/libexif.dll',
  shell   => 'ln -s /bin/libexif-12.dll /bin/libexif.dll',
  comment => 'correcting installed libexif name' ],

# confirmed latest source version as at 26-12-2008
[ archive => $sources.'libvisual-0.4.0.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/libvisual-0.4.0.tar.gz'],
[ dir     => $sources.'libvisual-0.4.0', 
  extract => $sources.'libvisual-0.4.0.tar' ],
[ file  => $sources.'libvisual.patch',
  write => [$sources.'libvisual.patch',
"--- lv_os.c~	Thu Jan 26 09:13:37 2006
+++ lv_os.c	Fri May  8 22:45:58 2009
@@ -59,7 +59,7 @@
 	attr.sched_priority = 99;
 
 	/* FIXME: Do we want RR or FIFO here ? */
-	ret = sched_setscheduler (getpid (), SCHED_FIFO, &attr);
+	ret = sched_setscheduler (getpid (), SCHED_FIFO);
 
 	return ret >= 0 ? VISUAL_OK : -VISUAL_ERROR_OS_SCHED;
 #else
@@ -77,7 +77,7 @@
 	int ret;
 	attr.sched_priority = 0;
 
-	ret = sched_setscheduler (getpid (), SCHED_OTHER, &attr);
+	ret = sched_setscheduler (getpid (), SCHED_OTHER);
 
 	return ret >= 0 ? VISUAL_OK : -VISUAL_ERROR_OS_SCHED;
 #else
"], comment => 'Create patch for libvisual'],
[ grep  => ['sched_setscheduler \(getpid \(\), SCHED_OTHER\);',
            $sources.'libvisual-0.4.0/libvisual/lv_os.c'], 
  shell => ["cd $unixsources/libvisual-0.4.0/libvisual",
            'patch -p0 < '.$sources.'libvisual.patch'] ],
[ file   => $sources.'libvisual-0.4.0/Makefile', 
  shell  => ["cd $unixsources/libvisual-0.4.0",
             "export LIBS=-lpthread",
             "./configure --prefix=/usr",
             "make",
             "make install"],
  comment => 'building and installing: libvisual' ],


[ archive => $sources.'fftw-3.2.1.tar.gz',  
  fetch   => 'http://mythtv-for-windows.googlecode.com/files/fftw-3.2.1.tar.gz'],
[ dir     => $sources.'fftw-3.2.1', 
  extract => $sources.'fftw-3.2.1.tar' ],
[ file    => $msys.'lib/libfftw3.a', 
  shell  => ["cd $unixsources/fftw-3.2.1",
             "./configure --prefix=/usr",
             "make",
             "make install"],
  comment => 'building and installing: msys fftw' ],

# typical template:
#[ archive => $sources.'xxx.tar.gz',  fetch => ''],
#[ dir => $sources.'xxx', extract => $sources.'xxx.tar' ],
#[ file => $msys.'lib/something-xx.a', 
#  shell => ["cd $unixsources/xxx",
#            "./configure --prefix=/usr",
#            "make",
#            "make install"] ],

;}

# 
#----------------------------------------
# building QT4 is complicated too
#----------------------------------------
if ( $qtver == 4  ) {
push @{$expect}, 
#[ pause => 'press [enter] to extract and patch QT4 next!'],

[ always => [],
  write => [$sources.'qt-4.6.3.patch1',
"--- 4.6.3/qmake/option.cpp.bak	2009-06-28 16:35:29 -0500
+++ 4.6.3/qmake/option.cpp	2009-06-28 16:35:47 -0500
@@ -622,7 +622,10 @@
     Q_ASSERT(!((flags & Option::FixPathToLocalSeparators) && (flags & Option::FixPathToTargetSeparators)));
     if(flags & Option::FixPathToLocalSeparators) {
 #if defined(Q_OS_WIN32)
-        string = string.replace('/', '\\\\');
+        if(Option::shellPath.isEmpty())  // i.e. not running under MinGW
+            string = string.replace('/', '\\\\');
+        else
+            string = string.replace('\\\\', '/');
 #else
         string = string.replace('\\\\', '/');
 #endif
"], comment => 'Create patch1 for QT4'],
[ grep  => ['Option::shellPath.isEmpty',
            $qt4dir.'qmake/option.cpp'], 
  shell => ['cd '.$unixqt4dir, 'dos2unix qmake/option.cpp', 
            'patch -p1 < '.$sources.'qt-4.6.3.patch1'] ],


[ always => [],
  write => [$sources.'qt-4.6.3.patch2',
"--- 4.6.3/mkspecs/win32-g++/qmake.conf.bak	2009-06-28 14:58:42 -0500
+++ 4.6.3/mkspecs/win32-g++/qmake.conf	2009-06-28 14:59:01 -0500
@@ -75,14 +75,16 @@
 !isEmpty(QMAKE_SH) {
     MINGW_IN_SHELL      = 1
 	QMAKE_DIR_SEP		= /
-	QMAKE_QMAKE		~= s,\\\\\\\\,/,
 	QMAKE_COPY		= cp
-	QMAKE_COPY_DIR		= xcopy /s /q /y /i
+	QMAKE_COPY_DIR		= cp -r
 	QMAKE_MOVE		= mv
 	QMAKE_DEL_FILE		= rm
-	QMAKE_MKDIR		= mkdir
+	QMAKE_MKDIR		= mkdir -p
 	QMAKE_DEL_DIR		= rmdir
     QMAKE_CHK_DIR_EXISTS = test -d
+    QMAKE_MOC		= \$\$[QT_INSTALL_BINS]/moc
+    QMAKE_UIC		= \$\$[QT_INSTALL_BINS]/uic
+    QMAKE_IDC		= \$\$[QT_INSTALL_BINS]/idc
 } else {
 	QMAKE_COPY		= copy /y
 	QMAKE_COPY_DIR		= xcopy /s /q /y /i
@@ -91,12 +93,11 @@
 	QMAKE_MKDIR		= mkdir
 	QMAKE_DEL_DIR		= rmdir
     QMAKE_CHK_DIR_EXISTS	= if not exist
+    QMAKE_MOC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}moc.exe
+    QMAKE_UIC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}uic.exe
+    QMAKE_IDC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}idc.exe
 }
 
-QMAKE_MOC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}moc.exe
-QMAKE_UIC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}uic.exe
-QMAKE_IDC		= \$\$[QT_INSTALL_BINS]\$\${DIR_SEPARATOR}idc.exe
-
 QMAKE_IDL		= midl
 QMAKE_LIB		= ar -ru
 QMAKE_RC		= windres
"], comment => 'Create patch2 for QT4'],
[ grep  => ['QMAKE_COPY_DIR.*?= cp -r',
            $qt4dir.'mkspecs/win32-g++/qmake.conf'], 
  shell => ['cd '.$unixqt4dir, 'dos2unix mkspecs/win32-g++/qmake.conf',
            'patch -p1 < '.$sources.'qt-4.6.3.patch2'] ],


# Write a batch script for the QT environment under DOS:
[ always => [], write => [$qt4dir.'qt4_env.bat',
'rem a batch script for building the QT environment under DOS:
set QTDIR='.$dosqt4dir.'
set MINGW='.$dosmingw.'
set PATH=%QTDIR%\bin;%MINGW%\bin;%SystemRoot%\System32
set QMAKESPEC=win32-g++
set LIBRARY_PATH='.$dosmsys.'\lib
set CPATH='.$dosmsys.'\include
cd /d %QTDIR%
goto SQLONLY

rem This would do a full build:
'.$dosmsys.'bin\yes | configure -opensource -plugin-sql-mysql -no-sql-sqlite -debug-and-release -fast -no-sql-odbc -no-qdbus
mingw32-make -j '.($numCPU + 1).'
goto END

:SMALL
rem This cuts out the examples and demos:
'.$dosmsys.'bin\yes | configure -opensource -plugin-sql-mysql -no-sql-sqlite -debug-and-release -fast -no-sql-odbc -no-qdbus
bin\qmake projects.pro
mingw32-make -j '.($numCPU + 1).' sub-plugins-make_default-ordered
goto END

:SQLONLY
rem This compiles only the sqldrivers folder:
'.$dosmsys.'bin\yes | configure -opensource -plugin-sql-mysql -no-sql-sqlite -debug-and-release -fast -no-sql-odbc -no-qdbus
cd %QTDIR%\src\plugins\sqldrivers
%QTDIR%\bin\qmake
mingw32-make -j '.($numCPU + 1).'
goto END

:NODEBUGSMALL
rem This cuts out the examples and demos, and only builds release libs
'.$dosmsys.'bin\yes | configure -opensource -plugin-sql-mysql -no-sql-sqlite -release -fast -no-sql-odbc -no-qdbus
bin\qmake projects.pro
mingw32-make -j '.($numCPU + 1).' sub-plugins-make_default-ordered
rem
rem Since we omit debug libs, this pretends release is debug:
cd lib
copy QtCore4.dll     QtCored4.dll
copy QtXml4.dll      QtXmld4.dll
copy QtSql4.dll      QtSqld4.dll
copy QtGui4.dll      QtGuid4.dll
copy QtNetwork4.dll  QtNetworkd4.dll
copy QtOpenGL4.dll   QtOpenGLd4.dll
copy Qt3Support4.dll Qt3Supportd4.dll
copy libqtmain.a     libqtmaind.a

:END
',
],comment=>'write a batch script for the QT4 environment under DOS'],

# test if the core .dll is built, and build QT if it isn't! 
[ file    => $qt4dir.'plugins/sqldrivers/qsqlmysql4.dll', 
  exec    => $dosqt4dir.'qt4_env.bat',
  comment => 'Execute qt4_env.bat to actually build QT now!  - '.
             'ie configures qt and also makes it, hopefully! '  ],
[ file    => $qt4dir.'plugins/sqldrivers/qsqlmysql4.dll', 
  exec    => '', 
  comment => 'plugins\sqldrivers\qsqlmysql4.dll - validating some basics '.
             'of the QT4 install, and if any of these components are missing, '.
             'the build must have failed (is the sql driver built properly?) '],

;
} # end of QT4 install


push @{$expect},
#----------------------------------------
# is the build type we are doing basically the same as any previous one?
# if not, we must cleanup our build and SVN area BEFORE
# we try to do any SVN activities! 
#----------------------------------------
# $compile_type, $svnlocation, and $qtver changing
# are all good reasons to cleanup the build area:
# later on, we'll also see if the $SVNRELEASE has changed,
# and trigger on that to....
[ file  => $mythtv.$is_same,
  shell   => ['source '.$unixmythtv.'make_clean.sh',
              'nocheck' ],
  comment => 'cleaning environment - step 1a' ],

[ file  => $mythtv."delete_to_do_make_clean.txt",
  shell   => ['source '.$unixmythtv.'make_clean.sh',
              'nocheck' ],
  comment => 'cleaning environment - step 1b' ],

#----------------------------------------
# get mythtv sources, if we don't already have them
# download all the files from the web, and save them here:
#----------------------------------------
[ dir     => $mythtv.'mythtv',
  mkdirs  => $mythtv.'mythtv',
  comment => 'make myth dir'],


# if we dont have the sources at all, get them all from SVN!
# (do a checkout, but only if we don't already have the .pro file
#  as a sign of an earlier checkout)
;

foreach my $comp( @components ) {
  push @{$expect}, [ dir => $mythtv.$comp, mkdirs => $mythtv.$comp ];
  push @{$expect},
  [ dir => "$mythtv$comp/.svn",
    exec => ["$dosmsys\\bin\\svn checkout ".
             "http://svn.mythtv.org/svn/$svnlocation/$comp $dosmythtv$comp",
             'nocheck'],
    comment => "Get all the mythtv sources from SVN!:$comp" ];

}


push @{$expect}, 
# now lets write some build scripts to help with mythtv itself

# Qt4
[ always => [], 
  write => [$mythtv.'qt4_env.sh',
'export QTDIR='.$unixqt4dir.'
export QMAKESPEC=$QTDIR/mkspecs/win32-g++
export LD_LIBRARY_PATH=$QTDIR/lib:/usr/lib:/mingw/lib:/lib
export LIBRARY_PATH=/usr/lib
export CPATH=/usr/include
export PATH=$QTDIR/bin:/usr/bin:$PATH
' ],
  comment => 'write a QT4 script that we can source later when inside msys '.
             'to setup the environment variables'],


[ always => [], 
  write => [$mythtv.'make_clean.sh',
'source '.$unixmythtv.'qt'.$qtver.'_env.sh
cd '.$unixmythtv.'mythtv
make distclean
cd '.$unixmythtv.'mythplugins
make distclean
cd '.$unixmythtv.'myththemes
make distclean
cd '.$unixmythtv.'oldthemes
make distclean
cd '.$unixmythtv.'
find . -type f -name \*.dll -o -name \*.exe -o -name \*.a \
       -o -name \*.o -o -name moc_\*.cpp -o -name version.cpp \
     | grep -v build | grep -v setup | grep -v svn | xargs -n1 rm -v
rm -f '.$mythtv.'delete_to_do_make_clean.txt
'], 
  comment => 'write a script to clean up myth environment'],


# chmod the shell scripts, everytime
[ always => [] ,
  shell => ["cd $mythtv","chmod 775 *.sh"] ],

#----------------------------------------
# now we prep for the build of mythtv! 
#----------------------------------------
;
if ($makeclean) {
  push @{$expect},
  [ always  => [],
    shell   => ['source '.$unixmythtv.'make_clean.sh'],
    comment => 'cleaning environment'],
  ;
}

foreach my $comp( @components ) {

# switch to the correct SVN branch before we do anything,
# if we are on the wrong one...
  push @{$expect},
  #[ file  => $mythtv.$is_same,
  [ always => '',
    exec => [ "$dosmsys\\bin\\svn cleanup $dosmythtv$comp",
             'nocheck'],
    comment => " SVN cleanup:$comp" ],
    
  #[ file  => $mythtv.$is_same,
  [ always => '',
    exec => [ "$dosmsys\\bin\\svn -r $SVNRELEASE  switch ".
             "http://svn.mythtv.org/svn/$svnlocation/$comp $dosmythtv$comp",
             'nocheck'],
    comment => " SVN SWITCH BRANCH!:$comp" ],
    
  # if we don't have the needed indicator of the branch we are now on,
  # save that info...
  [ file  => $mythtv.$is_same,
    shell => ['rm -f '.$unixmythtv.'*.same',
              'touch '.$unixmythtv.$is_same,
             ],
    comment => 'cleaning environment' ], 

  #[ pause => 'press [enter] to continue !'],

# ... then SVN update every time, before patches

  [ always  => [],
    exec    => [$dosmsys."bin\\svn -r $SVNRELEASE update $dosmythtv$comp"],
    comment => "Getting SVN updates for:$comp on $svnlocation" ];
}

push @{$expect}, 

# always get svn num
[ always   => [],
  exec     => ['cd '.$dosmythtv.'mythtv && '.
               $dosmsys.'bin\svn info > '.$dosmythtv.'mythtv\svn_info.new'],
 comment   => 'fetching the SVN number to a text file, if we can'],
[ filesame => [$mythtv.'mythtv/svn_info.txt',$mythtv.'mythtv/svn_info.new'],
  shell    => ['touch -r '.$unixmythtv.'mythtv/svn_info.txt '.
               $unixmythtv.'mythtv/svn_info.new', 'nocheck'],
  comment  => 'match the datetime of these files, '.
              'so that the contents only can be compared next' ],

# is svn num (ie file contents) changed since last run, if so, do a 'make
# clean' (overkill, I know, but safer)!
[ filesame => [$mythtv.'mythtv/svn_info.txt',$mythtv.'mythtv/svn_info.new'], 
  shell => ['source '.$unixmythtv.'make_clean.sh',
            'touch '.$unixmythtv.'mythtv/last_build.txt',
            'cp -p '.$unixmythtv.'mythtv/svn_info.new '
             .$unixmythtv.'mythtv/svn_info.txt'],
  comment => 'if the SVN number is changed, then remember that, AND arrange for a full re-make of mythtv. (overkill, I know, but safer)' ], 


#  [ pause => 'press [enter] to continue !'],
  
# apply any outstanding win32 patches - this section will be hard to keep upwith HEAD/SVN:
#----------------------------------------
# expired patches
#----------------------------------------

# Ticket 15831 
#[ archive => $sources.'15831_win32_fs.patch', 'fetch' => 'http://svn.mythtv.org/trac/changeset/15831?format=diff&new=15831', comment => 'win32_fs.patch - apply any outstanding win32 patches - this section will be hard to keep upwith HEAD/SVN'],
#[ filesame => [$mythtv.'mythtv/15831_win32_fs.patch',$sources."15831_win32_fs.patch"], copy => [''=>'',comment => 'XXXX'] ],
#[ grep  =>  ['\+', $mythtv.'mythtv/15831_win32_fs.patch'], shell => ["cd ".$unixmythtv."mythtv","dos2unix 15831_win32_fs.patch"], comment => ' .'],
#[ grep  => ['LOCALAPPDATA',$mythtv.'mythtv/libs/libmyth/mythcontext.cpp'], shell => ["cd ".$unixmythtv."mythtv","patch -p0 < ".$unixmythtv."mythtv/15831_win32_fs.patch"] , comment => ' 15831'],

; 
#
if ($tickets == 1) {
 push @{$expect}, 

# Ticket 4702
[ archive => $sources.'4702_mingw.patch', 
  'fetch' => 'http://svn.mythtv.org/trac/raw-attachment'.
             '/ticket/4702/mingw.patch', 
  comment => 'mingw.patch - apply any outstanding win32 patches - '.
             'this section will be hard to keep upwith HEAD/SVN'],
[ filesame => [$mythtv.'mythtv/4702_mingw.patch',$sources."4702_mingw.patch"], 
  copy     => [''=>'',comment => 'XXXX'] ],
[ grep  => ['\$\$\{PREFIX\}\/bin',
            $mythtv.'mythtv/libs/libmythui/libmythui.pro'], 
  shell => ["cd ".$unixmythtv."mythtv",
            "patch -p0 < ".$unixmythtv."mythtv/4702_mingw.patch"] , 
  comment => ' 4702'],


#  [ pause => 'press [enter] to continue !'],
;

} # End if for $ticket


#----------------------------------------
# now we actually build mythtv! 
#----------------------------------------
push @{$expect}, 

[ file    => $mythtv.'delete_to_do_make_clean.txt',
  shell   => ['touch '.$unixmythtv.'delete_to_do_make_clean.txt'],
  comment => 'do a "make clean" first? not strictly necessary in all cases, '.
             'and the build will be MUCH faster without it, but it is safer '.
             'with it... ( we do a make clean if the SVN revision changes) '], 


#broken Makefile?, delete it
[ grep    => ['Makefile|MAKEFILE',$mythtv.'mythtv/Makefile'],
  shell   => ['rm '.$unixmythtv.'mythtv/Makefile','nocheck'],
  comment => 'broken Makefile, delete it' ],

# configure
[ file   => $mythtv.'mythtv/config.mak',
  shell  => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'mythtv',
            './configure --prefix='.$unixbuild.' --runprefix=..'.
            ' --disable-iptv --disable-joystick-menu --disable-xvmc-vld'.
            ' --disable-xvmc --disable-lirc'.
            ' --cpu=pentium4 --compile-type='.$compile_type],
  comment => 'do we already have a Makefile for mythtv?' ],

# make

[ newer => [$mythtv."mythtv/libs/libmyth/libmyth-$version.dll",
            $mythtv.'mythtv/last_build.txt'],
  shell => ['rm '.$unixmythtv."mythtv/libs/libmyth/libmyth-$version.dll",
            'source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'mythtv', $parallelMake],
  comment => 'libs/libmyth/libmyth-$version.dll - '.
             'redo make unless all these files exist, '.
             'and are newer than the last_build.txt identifier' ],
[ newer => [$mythtv."mythtv/libs/libmythtv/libmythtv-$version.dll",
            $mythtv.'mythtv/last_build.txt'],
  shell => ['rm '.$unixmythtv."mythtv/libs/libmythtv/libmythtv-$version.dll",
            'source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'mythtv', $parallelMake],
  comment => 'libs/libmythtv/libmythtv-$version.dll - '.
             'redo make unless all these files exist, '.
             'and are newer than the last_build.txt identifier' ],
[ newer => [$mythtv.'mythtv/programs/mythfrontend/mythfrontend.exe',
            $mythtv.'mythtv/last_build.txt'],
  shell => ['rm '.$unixmythtv.'mythtv/programs/mythfrontend/mythfrontend.exe',
            'source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'mythtv', $parallelMake],
  comment => 'programs/mythfrontend/mythfrontend.exe - '.
             'redo make unless all these files exist, '.
             'and are newer than the last_build.txt identifier' ],
[ newer => [$mythtv.'mythtv/programs/mythbackend/mythbackend.exe',
            $mythtv.'mythtv/last_build.txt'],
  shell => ['rm '.$unixmythtv.'mythtv/programs/mythbackend/mythbackend.exe',
            'source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'mythtv', $parallelMake],
  comment => 'programs/mythbackend/mythbackend.exe - '.
             'redo make unless all these files exist, '.
             'and are newer than the last_build.txt identifier' ],


# Archive old build before we create a new one with make install:
[ exists  => $mythtv.'build_old',
  shell   => ['rm -fr '.$unixmythtv.'build_old'],
  comment => 'Deleting old build backup'],
[ exists  => $build,
  shell   => ['mv '.$unixbuild.' '.$unixmythtv.'build_old'],
  comment => 'Renaming build to build_old for backup....'],

# re-install to /c/mythtv/build if we have a newer mythtv build
# ready:
[ newer   => [$build.'bin/mythfrontend.exe',
              $mythtv.'mythtv/programs/mythfrontend/mythfrontend.exe'],
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
              'cd '.$unixmythtv.'mythtv',
              'make install'],
  comment => 'was the last configure successful? then install mythtv ' ],


# setup_build tidies up the build area and copies extra libs in there
[ always => [], 
  write => [$mythtv.'setup_build.sh',
'#!/bin/bash
source '.$unixmythtv.'qt'.$qtver.'_env.sh
cd '.$unixmythtv.'
echo copying main QT dlls to build folder...
# mythtv needs the qt4 dlls at runtime:
cp '.$unixqt4dir.'bin/*.dll '.$unixmythtv.'build/bin
# qt mysql connection dll has to exist in a subfolder called sqldrivers:
echo Creating build-folder Directories...
# Assumptions
# <installprefix> = ./mythtv
# themes go into <installprefix>/share/mythtv/themes
# fonts go into <installprefix>/share/mythtv
# libraries go into installlibdir/mythtv
# plugins go into installlibdir/mythtv/plugins
# filters go into installlibdir/mythtv/filters
# translations go into <installprefix>/share/mythtv/i18n
mkdir '.$unixmythtv.'/build/bin/sqldrivers
echo Copying QT plugin required dlls....
cp '.$unixqt4dir.'plugins/sqldrivers/qsqlmysql*.dll '.$unixmythtv.'build/bin/sqldrivers 
# need imageformat plugins to display channel icons
mkdir '.$unixmythtv.'/build/bin/imageformats
cp -p '.$unixqt4dir.'plugins/imageformats/*.dll '.$unixmythtv.'build/bin/imageformats 
echo Copying ming and msys dlls to build folder.....
# pthread dlls and mingwm10.dll are copied from here:
cp /mingw/bin/*.dll '.$unixmythtv.'build/bin
# msys-1.0.dll and library dlls are copied from here:
cp /bin/*.dll '.$unixmythtv.'build/bin
echo copying lib files...
mv '.$unixmythtv.'build/lib/*.dll '.$unixmythtv.'build/bin/
mv '.$unixmythtv.'build/bin/*.a '.$unixmythtv.'build/lib/

touch '.$unixmythtv.'/build/package_flag
cp '.$unixmythtv.'packaging/Win32/debug/*.cmd '.$unixmythtv.'build/bin
'],
  comment => 'write a script to install mythtv to build folder'],


# chmod the shell scripts, everytime
[ always  => [],
  shell   => ["cd $mythtv","chmod 755 *.sh"] ],

# Change - don't run this until mythplugins are complete -
#          otherwise dll/exe are copied twice
# Run setup_build.sh which creates the build area and copies executables
[ always  => [], 
  shell   => [$unixmythtv.'setup_build.sh' ], 
  comment => 'Copy mythtv into ./build folder' ],
;

if ($dbconf) {
# --------------------------------
# DB Preperation for developers - need a similar process in the installation
# --------------------------------
# TODO allow a configuration for local SQL server, as well as frontend only -
# with remote SQL will move all testing to vbs script


push @{$expect},
[ dir => $home.'.mythtv', 
  mkdirs => $home.'.mythtv' ] ,
;

 
#execute and capture output: C:\Program Files\MySQL\MySQL Server 5.1\bin\
#                            mysqlshow.exe -u mythtv --password=mythtv
# example response:
# mysqlshow.exe: Can't connect to MySQL server on 'localhost' (10061)
# if this is doing an anonymous connection, so the BEST we should expect is
# an "access denied" message if the server is running properly.
push @{$expect},
[ always => [],
  exec   => [ 'sc query mysql > '.$mythtv.'testmysqlsrv.bat']],
[ grep   => ['SERVICE_NAME',$mythtv.'testmysqlsrv.bat'],
  exec   => ['sc start mysql','nocheck']],
[ grep   => ['does not exist',$mythtv.'testmysqlsrv.bat'],
  exec   => [$dosprogramfiles.'\MySQL\MySQL Server 5.1\bin\MySQLd-nt.exe '.
             '--standalone  -console','nocheck']],

 
[ always => [], 
  write  => [ $mythtv.'testmysql.bat',
'@echo off
echo testing connection to a local mysql server...
sleep 5
del '.$dosmythtv.'_mysqlshow_err.txt
"'.$dosprogramfiles.'\MySQL\MySQL Server 5.1\bin\mysqlshow.exe" -u mythtv --password=mythtv 2> '.$dosmythtv.'_mysqlshow_err.txt  > '.$dosmythtv.'_mysqlshow_out.txt 
type '.$dosmythtv.'_mysqlshow_out.txt >> '.$dosmythtv.'_mysqlshow_err.txt 
del '.$dosmythtv.'_mysqlshow_out.txt
sleep 1
']],

# try to connect as mythtv/mythtv first (the best case scenario)
[ file    => $mythtv.'skipping_db_tests.txt', 
  exec    => [$mythtv.'testmysql.bat','nocheck'], 
  comment => 'First check - is the local mysql server running, accepting '.
             'connections, and all that? (follow the bouncing ball on '.
             'the install, a standard install is OK, remember the root '.
             'password that you set, start it as a service!)' ],

# if the connection was good, or the permissions were wrong, but the server 
# was there, there's no need to reconfigure the server!
[ grep    => ['(\+--------------------\+|Access denied for user)',
              $mythtv.'_mysqlshow_err.txt'], 
  exec    => [$dosprogramfiles.'\MySQL\MySQL Server 5.1\bin\MySQLd-nt.exe '.
              '--standalone  -console', 'nocheck'], 
  comment => 'See if we couldnt connect to a local mysql server. '.
             'Please re-configure the MySQL server to start as a service.'],

# try again to connect as mythtv/mythtv first (the best case scenario) - the
# connection info should have changed!
[ file    => $mythtv.'skipping_db_tests.txt', 
  exec    => [$mythtv.'testmysql.bat','nocheck'], 
  comment => 'Second check - that the local mysql server '.
             'is at least now now running?' ],


#set/reset mythtv/mythtv password! 
[ always => [], 
  write => [ $mythtv.'resetmythtv.bat',
"\@echo off
echo stopping mysql service:
net stop MySQL
".$dosmsys.'bin\sleep 2'."
echo writing script to reset mythtv/mythtv passwords:
echo USE mysql; >resetmythtv.sql
echo. >>resetmythtv.sql
echo INSERT IGNORE INTO user VALUES ('localhost','mythtv', PASSWORD('mythtv'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0); >>resetmythtv.sql
echo REPLACE INTO user VALUES ('localhost','mythtv', PASSWORD('mythtv'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0); >>resetmythtv.sql
echo INSERT IGNORE INTO user VALUES ('\%\%','mythtv', PASSWORD('mythtv'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0); >>resetmythtv.sql
echo REPLACE INTO user VALUES ('\%\%','mythtv', PASSWORD('mythtv'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0); >>resetmythtv.sql
echo trying to reset mythtv/mythtv passwords:
\"' . $mysql . 'bin\\mysqld-nt.exe\" --no-defaults --bind-address=127.0.0.1 --bootstrap --console --skip-grant-tables --skip-innodb --standalone <resetmythtv.sql
del resetmythtv.sql
echo trying to re-start mysql
rem net stop MySQL
net start MySQL
rem so that the server has time to start before we query it again
".$dosmsys.'bin\sleep 5'."
echo.
echo Password for user 'mythtv' was reset to 'mythtv'
echo.
"],
  comment => 'writing a script to create the mysql user (mythtv/mythtv) '.
             'without needing to ask you for the root password ...'],

# reset passwords, this give the mythtv user FULL access to the entire mysql
# instance!
# TODO give specific access to just the the mythconverg DB, as needed.
[ grep    => ['(\+--------------------\+)',$mythtv.'_mysqlshow_err.txt'], 
  exec    => [$dosmythtv.'resetmythtv.bat','nocheck'], 
  comment => 'Resetting the mythtv/mythtv permissions to mysql - '.
             'if the user already has successful login access '.
             'to the mysql server, theres no need to run this' ],


# try again to connect as mythtv/mythtv first (the best case scenario) - the
# connection info should have changed!
[ file    => $mythtv.'skipping_db_tests.txt', 
  exec    => [$mythtv.'testmysql.bat','nocheck'], 
  comment => 'Third check - that the local mysql server '.
             'is fully accepting connections?' ],

# create DB:
# this has the 'nocheck' flag because the creation of the DB doesn't
# instantly reflect in the .txt file we are looking at:
[ grep    => ['mythconverg',$mythtv.'_mysqlshow_err.txt'], 
  exec    => [ 'echo create database mythconverg;'.
               ' | "' . $mysql . '\bin\mysql.exe" '.
               ' -u mythtv --password=mythtv','nocheck'], 
  comment => 'does the mythconverg database exist? (and can this user see it?)'
],

# Make mysql.txt file required for testing
[ file  => $home.'.mythtv\mysql.txt', 
  write => [$home.'.mythtv\mysql.txt', 
'DBHostName=127.0.0.1
DBHostPing=no
DBUserName=mythtv
DBPassword=mythtv
DBName=mythconverg
DBType=QMYSQL3
LocalHostName='.$ENV{COMPUTERNAME}
],
  comment => 'create a mysql.txt file at: %HOMEPATH%\.mythtv\mysql.txt' ],

;
} # end if($dbconf)


if ( grep m/mythplugins/, @components ) {
#----------------------------------------
#  build the mythplugins now:
#----------------------------------------
# 
push @{$expect},
#
# hack location of //include/mythtv/mythconfig.mak
# so that configure is successful
[ always  => [], 
  shell   => ['mkdir /include/mythtv',
             'cp '.$unixbuild.'include/mythtv/mythconfig.mak'.
               ' /include/mythtv/mythconfig.mak'], 
  comment => 'link mythconfig.mak'],
## config:
[ file    => $mythtv.'mythplugins/Makefile', 
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
             'cd '.$unixmythtv.'mythplugins',
             './configure --prefix='.$unixbuild.
             ' --disable-mythmusic'.
             ' --disable-mytharchive --disable-mythbrowser --disable-mythflix'.
             ' --disable-mythgame --disable-mythnews'.
             ' --disable-mythzoneminder'.
             ' --enable-libvisual --enable-fftw --compile-type='.$compile_type,
             ], 
  comment => 'do we already have a Makefile for myth plugins?' ],
  
#[ pause => 'how does the mythplugins Makefile look? '.
#           '(did we get any errors on screen?)'],

# make
[ newer   => [$mythtv.'mythplugins/mythvideo/mythvideo/libmythvideo.dll',
              $mythtv.'mythtv/last_build.txt'], 
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
              'cd '.$unixmythtv.'mythplugins', $parallelMake], 
  comment => 'PLUGINS! redo make if we need to '.
             '(see the  last_build.txt identifier)' ],

# make install
[ newer   => [$mythtv.'build/lib/mythtv/plugins/libmythvideo.dll',
              $mythtv.'mythplugins/mythvideo/mythvideo/libmythvideo.dll'],
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
              'cd '.$unixmythtv.'mythplugins','make install'],
  comment => 'PLUGINS! make install' ],

;
}


foreach my $themecomp ( grep m/themes/, @components ) {
# -------------------------------
# Make themes
# -------------------------------
push @{$expect},
## config:
[ file    => $mythtv.$themecomp.'/Makefile',
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.$themecomp,'./configure --prefix='.$unixbuild],
  comment => "do we already have a Makefile for $themecomp?" ],

## make
[ file    => [$mythtv.'build/share/'.$themecomp.'.installed'], 
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
              'cd '.$unixmythtv.$themecomp,'make', 'make install', 
	      'touch '.$unixmythtv.'build/share/'.$themecomp.'.installed'], 
  comment => 'THEMES! redo make if we need to '.
             '(see the  last_build.txt identifier)' ],
;
}

if ( grep m/themes/, @components ) {
push @{$expect},	
# Get any extra Themes
#

# MePo is currently incompatilble with trunk but is left here as a template
#[ archive => $sources.'MePo-wide-0.50.tar.gz',  
#  fetch   => 'http://home.comcast.net/~zdzisekg/'.
#             'download/MePo-wide-0.50.tar.gz'],
#[ dir     => $sources.'MePo-wide', 
#  extract => $sources.'MePo-wide-0.50.tar.gz' ],
#[ file    => $mythtv.'build/share/mythtv/themes/MePo-wide/ui.xml', 
#  shell   => ['cp -fr '.$unixsources.'MePo-wide '.
#                      $unixmythtv.'build/share/mythtv/themes','nocheck'], 
#  comment => 'install MePo-wide'],

# Move ttf fonts to font directory
[ always  => [],
  shell   => ['source '.$unixmythtv.'qt'.$qtver.'_env.sh',
            'cd '.$unixmythtv.'build',
            'find '.$unixmythtv.'build/share/mythtv/themes/ -name "*.ttf"'.
            ' | xargs -n1 -i__ cp __ '.$unixmythtv.'build/share/mythtv'],
  comment => 'move ttf files'],
;
}


# -------------------------------
# Prepare Readme.txt for distribution file - temporary for now
# -------------------------------


push @{$expect},
[ file => $mythtv.'build/readme.txt',
 write => [$mythtv.'build/readme.txt',
'README for Win32 Installation of MythTV version: '.$version.
' svn '.$SVNRELEASE.'
=============================================================
The current installation very basic:
 - All exe and dlls are %PROGRAMFILES%\mythtv\bin
 - share/mythtv is copied to %PROGRAMFILES%\mythtv\share\mythtv
 - lib/mythtv is copied to %PROGRAMFILES%\mythtv\lib\mythtv
 - mysql.txt and user configuration files are set to %APPDATA%\mythtv

If you have MYSQL installed locally, mysql.txt will be configured to use it.
If you want to run the frontend with a remote MYSQL server,
edit mysql.txt in %APPDATA%\mythtv

If you don\'t have MYSQL installed locally, only the frontend will be installed
and mysql.txt needs to be configured to the backend IP address.

If you install the components in other directories other than the default,
some environment variables will need to be set:
MYTHCONFDIR = defaulting to %APPDATA%\mythtv
MYTHLIBDIR  = defaulting to %PROGRAMFILES%\mythv\lib
MYTHTVDIR   = defaulting to %APPDATA%\mythtv
','nocheck'],comment => ''],

[ file => $mythtv.'build/readme.txt_', 
  shell => ['unix2dos '.$unixmythtv.'build/readme.txt', 'nocheck'],
  comment => '' ],
;

if ($package == 1) {
    push @{$expect},
    # Create directories
    [ dir     => [$mythtv.'setup'] , 
      mkdirs => [$mythtv.'setup'],
      comment => 'Create Packaging directory'],
    [ dir     => [$mythtv.'build/isfiles'] , 
      mkdirs => [$mythtv.'build/isfiles'],
      comment => 'Create Packaging directory'],
    # Move required files from inno setup to setup directory
    [ file    => $mythtv."build/isfiles/UninsHs.exe",
      exec    => 'copy /Y "'.$dosprogramfiles.'\Inno Setup 5\UninsHs.exe" '.
                 $dosmythtv.'build\isfiles\UninsHs.exe',
      comment => 'Copy UninsHs to setup directory' ],
    [ file    => $mythtv."build/isfiles/isxdl.dll",
      exec    => 'copy /Y "'.$dosprogramfiles.'\ISTool\isxdl.dll" '.
                 $dosmythtv.'build\isfiles\isxdl.dll',
      comment => 'Copy isxdl.dll to setup directory' ],
    [ file    => $mythtv."build/isfiles/WizModernSmallImage-IS.bmp",
      exec    => 'copy /Y "'.$dosprogramfiles.'\Inno Setup 5'.
                 '\WizModernSmallImage-IS.bmp" '.
                 $dosmythtv.'build\isfiles\WizModernSmallImage-IS.bmp',
      comment => 'Copy WizModernSmallImage-IS.bmp to setup directory' ],
    # Copy required files from sources or packaging to setup directory:
    [ filesame => [$mythtv.'build/isfiles/mythtvsetup.iss',
                   $mythtv.'packaging/win32/build/mythtvsetup.iss'],
      copy     => [''=>'', 
      comment  => 'mythtvsetup.iss'] ],
    [ filesame => [$mythtv.'build/isfiles/mysql.gif',
                   $sources.'logo_mysql_sun.gif'],
      copy     => [''=>'', 
      comment  => 'mysql.gif'] ],
    # Create on-the-fly  files required
    [ file     => $mythtv.'build/isfiles/configuremysql.vbs',
      write    => [$mythtv.'build/isfiles/configuremysql.vbs',
'WScript.Echo "Currently Unimplemented"
' ], 
      comment   => 'Write a VB script to configure MySQL' ],
    [ always   => [],
      write    => [$mythtv.'build/isfiles/versioninfo.iss', '
#define MyAppName      "MythTv"
#define MyAppVerName   "MythTv '.$version.'(svn_'.$SVNRELEASE .')"
#define MyAppPublisher "Mythtv"
#define MyAppURL       "http://www.mythtv.org"
#define MyAppExeName   "Win32MythTvInstall.exe"
' ], 
      comment  => 'write the version information for the setup'],
    [ file     => $mythtv.'genfiles.sh', 
      write    => [$mythtv.'genfiles.sh','
cd '.$unixmythtv.'build
find . -type f -printf "Source: '.$mythtv.'build/%h/%f; Destdir: {app}/%h\n" | sed "s/\.\///" | grep -v ".svn" | grep -v "isfiles" | grep -v "include" > '.$unixmythtv.'/build/isfiles/files.iss
',], 
      comment  => 'write script to generate setup files'], 
    [ newer    => [$mythtv.'build/isfiles/files.iss',
                   $mythtv.'mythtv/last_build.txt'],
      shell    => [$unixmythtv.'genfiles.sh'] ],
# Run setup
#    [ newer   => [$mythtv.'setup/MythTvSetup.exe',
#                   $mythtv.'mythtv/last_build.txt'],
#      exec    => ['"'.$dosprogramfiles.'\Inno Setup 5\Compil32.exe" /cc "'.
#                  $dosmythtv.'build\isfiles\mythtvsetup.iss"' ]],
    [ newer    => [$mythtv.'setup/MythTvSetup.exe',
                    $mythtv.'mythtv/last_build.txt'],
      exec     => ['cd '.$dosmythtv.'build\isfiles && '.
                   '"'.$dosprogramfiles.'\Inno Setup 5\iscc.exe" "'.
                   $dosmythtv.'build\isfiles\mythtvsetup.iss"' ]],

    ;
}


#------------------------------------------------------------------------------

; # END OF CAUSE->ACTION DEFINITIONS

#------------------------------------------------------------------------------

sub _end {
    comment("This version of the Win32 Build script ".
            "last was last tested on: $SVNRELEASE");

    print << 'END';    
#
# SCRIPT TODO/NOTES:  - further notes on this scripts direction....
END
}

#------------------------------------------------------------------------------

# this is the mainloop that iterates over the above definitions and
# determines what to do:
# cause:
foreach my $dep ( @{$expect} ) { 
    my @dep = @{$dep};

    #print Dumper(\@dep);

    my $causetype = $dep[0];
    my $cause =  $dep[1];
    my $effecttype = $dep[2];
    my $effectparams = $dep[3] || '';
    die "too many parameters in cause->event declaration (".join('|',@dep).")"
        if defined $dep[4] && $dep[4] ne 'comment'; 
    # four pieces: cause => [blah] , effect => [blah]

    my $comment = $dep[5] || '';

    if ( $comment && $NOISY ) {
        comment($comment);
    }

    my @cause;
    if (ref($cause) eq "ARRAY" ) {
        @cause = @{$cause};
    } else { 
        push @cause, $cause ;
    }

    # six pieces: cause => [blah] , effect => [blah] , comment => ''
    die "too many parameters in cause->event declaration (@dep)"
        if defined $dep[6];

    my @effectparams = ();
    if (ref($effectparams) eq "ARRAY" ) {
        @effectparams = @{$effectparams};
    } else { 
        push @effectparams, $effectparams ;
    }
    # if a 'nocheck' parameter is passed through, dont pass it through to
    # the 'effect()', use it to NOT check if the file/dir exists at the end.
    my @nocheckeffectparams = grep { ! /nocheck/i } @effectparams; 
    my $nocheck = 0;
    if ( $#nocheckeffectparams != $#effectparams ) { $nocheck = 1; } 

    if ( $causetype eq 'archive' ) {
        die "archive only supports type fetch ($cause)($effecttype)"
            unless $effecttype eq 'fetch';
        if ( -f $cause[0] ) {print "file exists: $cause[0]\n"; next;}
        # 2nd and 3rd params get squashed into
        # a single array on passing to effect();
        effect($effecttype,$cause[0],@nocheckeffectparams);
        if ( ! -f $cause[0] && $nocheck == 0) {
            die "EFFECT FAILED ($causetype -> $effecttype): unable to ".
                "locate expected file ($cause[0]) that was to be ".
                "fetched from $nocheckeffectparams[0]\n";
        }

    }   elsif ( $causetype eq 'dir' ) {
        if ( -d $cause[0] ) {
            print "directory exists: $causetype,$cause[0]\n"; next;
        }
        effect($effecttype,@nocheckeffectparams);
        if ( ! -d $cause[0] && $nocheck == 0) {
            die "EFFECT FAILED ($causetype -> $effecttype): unable to ".
                "locate expected directory ($cause[0]).\n";
        }

    } elsif ( $causetype eq 'file' ) {
        if ( -f $cause[0] ) {print "file already exists: $cause[0]\n"; next;}
        effect($effecttype,@nocheckeffectparams);
        if ( ! -f $cause[0] && $nocheck == 0) {
            die "EFFECT FAILED ($causetype -> $effecttype): unable to ".
                "locate expected file ($cause[0]).\n";
        }
    } elsif ( $causetype eq 'filesame' ) {
        # NOTE - we check file mtime, byte size, AND MD5 of contents
        #      as without the MD5, the script can break in some circumstances.
        my ( $size,$mtime,$md5)=fileinfo($cause[0]);
        my ( $size2,$mtime2,$md5_2)=fileinfo($cause[1]);
        if ( $mtime != $mtime2 || $size != $size2 || $md5 ne $md5_2 ) {
          if ( ! $nocheckeffectparams[0] ) {
            die "sorry but you can not leave the arguments list empty for ".
                "anything except the 'copy' action (and only when used with ".
                "the 'filesame' cause)" unless $effecttype eq 'copy';
            print "no parameters defined, so applying effect($effecttype) as ".
                  "( 2nd src parameter => 1st src parameter)!\n";
            effect($effecttype,$cause[1],$cause[0]); 
          } else {
            effect($effecttype,@nocheckeffectparams);
            # do something else if the files are not 100% identical?
            if ( $nocheck == 0 ) {
              # now verify the effect was successful
              # at matching the file contents!:
              undef $size; undef $size2;
              undef $mtime; undef $mtime2;
              undef $md5; undef $md5_2;
              ( $size,$mtime,$md5)=fileinfo($cause[0]);
              ( $size2,$mtime2,$md5_2)=fileinfo($cause[1]);
            }
          }  
        }else {
           print "effect not required files already up-to-date/identical: ".
                 "($cause[0] => $cause[1]).\n";
        }
        undef $size; undef $size2;
        undef $mtime; undef $mtime2;
        undef $md5; undef $md5_2;
        
    } elsif ( $causetype eq 'newer' ) {
        my $mtime = 0;
        if ( -f $cause[0] ) {
          $mtime = (stat($cause[0]))[9]
                   || warn("$cause[0] could not be stated");
        }
        if (! ( -f $cause[1]) ) {
            die "cause: $causetype requires it's SECOND filename to exist ".
                "for comparison: $cause[1].\n";
        }
        my $mtime2  = (stat($cause[1]))[9];
        if ( $mtime < $mtime2 ) {
          effect($effecttype,@nocheckeffectparams);
          if ( $nocheck == 0 ) {
            # confirm it worked, mtimes should have changed now: 
            my $mtime3 = 0;
            if ( -f $cause[0] ) {
              $mtime3   = (stat($cause[0]))[9];
            }
            my $mtime4  = (stat($cause[1]))[9];
            if ( $mtime3 < $mtime4  ) {
                die "EFFECT FAILED ($causetype -> $effecttype): mtime of file".
                    " ($cause[0]) should be greater than file ($cause[1]).\n".
                    "[$mtime3]  [$mtime4]\n";
            }
          }
        } else {
           print "file ($cause[0]) has same or newer mtime than ".
                 "($cause[1]) already, no action taken\n";
        } 
        undef $mtime;
        undef $mtime2;
        
    } elsif ( $causetype eq 'grep' ) {
        print "grep-ing for pattern($cause[0]) in file($cause[1]):\n"
            if $NOISY >0;
        if ( ! _grep($cause[0],$cause[1]) ) {
# grep actually needs two parameters on the source side of the action
            effect($effecttype,@nocheckeffectparams);   
        } else {
            print "grep - already matched source file($cause[1]), ".
                  "with pattern ($cause[0]) - no action reqd\n";
        }
        if ( (! _grep($cause[0],$cause[1])) && $nocheck == 0 ) { 
           die "EFFECT FAILED ($causetype -> $effecttype): unable to locate regex pattern ($cause[0]) in file ($cause[1])\n";
        }

    } elsif ( $causetype eq 'exists' ) {
        print "testing if '$cause[0]' exists...\n" if $NOISY >0;
        if ( -e $cause[0] ) {
            effect($effecttype,@nocheckeffectparams);
        }
    } elsif ( $causetype eq 'always' ) {
        effect($effecttype,@nocheckeffectparams);
    } elsif ( $causetype eq 'stop' ){
        die "Stop found \n";
    } elsif ( $causetype eq 'pause' ){
        comment("PAUSED! : ".$cause);
        my $temp = getc() unless $continuous;
    } else {
        die " unknown causetype $causetype \n";
    }
}
print "\nwin32-packager all done\n";
_end();

#------------------------------------------------------------------------------
# each cause has an effect, this is where we do them:
sub effect {
    my ( $effecttype, @effectparams ) = @_;

        if ( $effecttype eq 'fetch') {
            # passing two parameters that came in via the array
            _fetch(@effectparams);

        } elsif ( $effecttype eq 'extract') {
            my $tarfile = $effectparams[0];
            my $destdir = $effectparams[1] || '';
            if ($destdir eq '') {
                $destdir = $tarfile;
                # strip off everything after the final forward slash
                $destdir =~ s#[^/]*$##;
            }
            my $t = findtar($tarfile);
            print "found equivalent: ($t) -> ($tarfile)\n" if $t ne $tarfile;
            print "extracttar($t,$destdir);\n";
            extracttar($t,$destdir);

        } elsif ($effecttype eq 'exec') { # execute a DOS command
            my $cmd = shift @effectparams;
            #print `$cmd`;
            print "exec:$cmd\n";
            open F, $cmd." |"  || die "err: $!";
            while (<F>) {
                print;
            }   

        } elsif ($effecttype eq 'shell') {
            shell(@effectparams);
            
        } elsif ($effecttype eq 'copy') {
            die "Can not copy non-existant file ($effectparams[0])\n"
                unless -f $effectparams[0];
            print "copying file ($effectparams[0] => $effectparams[1]) \n";
            cp($effectparams[0],$effectparams[1]);
            # make destn mtime the same as the original for ease of comparison:
            shell("touch --reference='".perl2unix($effectparams[0])."' '"
                                       .perl2unix($effectparams[1])."'");

        } elsif ($effecttype eq 'mkdirs') {
            mkdirs(shift @effectparams);

        } elsif ($effecttype eq 'write') {
            # just dump the requested content from the array to the file.
            my $filename = shift @effectparams;
            my $fh = new IO::File ("> $filename")
                || die "error opening $filename for writing: $!\n";
            $fh->binmode();
            $fh->print(join('',@effectparams));
            $fh->close();

        } elsif ($effecttype eq 'exit') {
            print "\n---------------------------------------\n";
            print "@effectparams\n";
            exit;

        } else {
            die " unknown effecttype $effecttype from cause 'dir'\n";
        }
        return; # which ever one we actioned,
                # we don't want to action anything else 
}

#------------------------------------------------------------------------------
# get info from a file for comparisons
sub fileinfo {
    # filename passed in should be perl compatible path
    # using single FORWARD slashes
    my $filename = shift;

    my ( $size,$mtime,$md5)=(0,0,0);
    
    if ( -f $filename ) {
        $size = (stat($filename))[7];
        $mtime  = (stat($filename))[9];
        my $md5obj = Digest::MD5->new();
        my $fileh = IO::File->new($filename);
        binmode($fileh);
        $md5obj->addfile($fileh);
        $md5 = $md5obj->digest();
    } else {
        warn(" invalid file name provided for testing: ($filename)\n");
        $size=rand(99);
        $mtime=rand(999);
        $md5=rand(999);
        }

    #print "compared: $size,$mtime,$md5\n";
    return ($size,$mtime,$md5);
}

#------------------------------------------------------------------------------
# kinda like a directory search for blah.tar* but faster/easier.
#  only finds .tar.gz, .tar.bz2, .zip
sub findtar {
    my $t = shift;
    return "$t.gz" if -f "$t.gz";
    return "$t.bz2" if -f "$t.bz2";
    return "$t.lzma" if -f "$t.lzma";

    if ( -f "$t.zip" || $t =~ m/\.zip$/ ) {
        die "no unzip.exe found ! - yet" unless -f $sources."unzip/unzip.exe";
        # TODO - a bit of a special test, should be fixed better.
        return "$t.zip" if  -f "$t.zip";
        return $t if -f $t;
    }
    return $t if -f $t;
    die "findtar failed to match a file from:($t)\n";
}

#------------------------------------------------------------------------------
# given a ($t) .tar.gz, .tar.bz2, .zip extract it to the directory ( $d)
# changes current directory to $d too
sub extracttar {
    my ( $t, $d) = @_;

    # both $t and $d at this point should be perl-compatible-forward-slashed
    die "extracttar expected forward-slashes only in pathnames ($t,$d)"
        if $t =~ m#\\# || $d =~ m#\\#;

    unless ( $t =~ m/zip/ ) {
        # the unzip tool need the full DOS path,
        # the msys commands need that stripped off.
        $t =~ s#^$msys#/#i;
    }

    print "extracting to: $d\n";

    # unzipping happens in DOS as it's a dos utility:
    if ( $t =~ /\.zip$/ ) {
        #$d =~ s#/#\\#g;  # the chdir command MUST have paths with backslashes,
                          # not forward slashes. 
        $d = perl2dos($d);
        $t = perl2dos($t);
        my $cmd = 'chdir /d '.$d.' && '.$dossources.'unzip\unzip.exe -o '.$t;
        print "extracttar:$cmd\n";
        open F, "$cmd |"  || die "err: $!";
        while (<F>) {
            print;
        }
        return; 
    }

    $d = perl2unix($d);
    $t = perl2unix($t);
    # untarring/gzipping/bunzipping happens in unix/msys mode:
    die "unable to locate sh2.exe" unless -f $dosmsys.'bin/sh2.exe';
    my $cmd = $dosmsys.
              'bin\sh2.exe -c "( export PATH=/bin:/mingw/bin:$PATH ; ';
    $cmd .= "cd $d;";
    if ( $t =~ /\.gz$/ ) {
        $cmd .= $unixmsys."bin/tar.exe -zxvpf $t";
    } elsif ( $t =~ /\.bz2$/ ) {
        $cmd .= $unixmsys."bin/tar.exe -jxvpf $t";
    } elsif ( $t =~ /\.lzma$/ ) {
        $cmd .= $unixmsys."bin/tar.exe --lzma -xvpf $t";
    } elsif ( $t =~ /\.tar$/ ) {
        $cmd .= $unixmsys."bin/tar.exe -xvpf $t";
    } else {
        die  "extract tar failed on ($t,$d)\n";
    }
    $cmd .= ')"'; # end-off the brackets around the shell commands.

    # execute the cmd, and capture the output!  
    # this is a glorified version of "print `$cmd`;"
    # except it doesn't buffer the output, if $|=1; is set.
    # $t should be a msys compatible path ie /sources/etc
    print "extracttar:$cmd\n";
    open F, "$cmd |"  || die "err: $!";
    while (<F>) {
        print;
    }   
}

#------------------------------------------------------------------------------
# get the $url (typically a .tar.gz or similar) , and save it to $file
sub _fetch {
    my ( $file,$url ) = @_;

    #$file =~ s#/#\\\\#g;
    print "already exists: $file \n" if -f $file;
    return undef if -f $file;

    print "fetching $url to $file (please wait)...\n";
    my $ua = LWP::UserAgent->new;
    $ua->proxy(['http', 'ftp'], $proxy);

    my $res = $ua->request(HTTP::Request->new(GET => $url),
      sub {
          if (! -f $file) {
              open(FILE, ">$file") || die "_fetch can't open $file: $!\n";
              binmode FILE;
          }
          print FILE $_[0] or die "_fetch can't write to $file: $!\n";
      }
    );
    close(FILE) || print "_fetch can't close $file: $!\n";
    if (my $mtime = $res->last_modified) {
        utime time, $mtime, $file;
    }
    if ($res->header("X-Died") || !$res->is_success) {
        unlink($file) && print "Transfer failed.  File deleted.\n";
    }

    if ( ! -s $file ) {
      die ('ERR: Unable to automatically fetch file!\nPerhaps manually '.
           'downloading from the URL to the filename (both listed above) '.
           'might work, or you might want to choose your own SF mirror '.
           '(edit this script for instructions), or perhaps this version'.
           ' of the file is no longer available.');
    }
}

#------------------------------------------------------------------------------
# execute a sequence of commands in a bash shell.
# we explicitly add the /bin and /mingw/bin to the path
# because at this point they aren't likely to be there
# (cause we are in the process of installing them)
sub shell {
    my @cmds = @_;
    my $cmd = $dosmsys.'bin\bash.exe -c "( export PATH=/bin:/mingw/bin:$PATH;'.
              join(';',@cmds).') 2>&1 "';
    print "shell:$cmd\n";
    # execute the cmd, and capture the output!  this is a glorified version
    # of "print `$cmd`;" except it doesn't buffer the output if $|=1; is set.
    open F, "$cmd |"  || die "err: $!";
    while (<F>) {
        if (! $NOISY )  {
          # skip known spurious messages from going to the screen unnecessarily
          next if /redeclared without dllimport attribute after being referenced with dllimpo/;
          next if /declared as dllimport: attribute ignored/;
          next if /warning: overriding commands for target `\.\'/;
          next if /warning: ignoring old commands for target `\.\'/;
          next if /Nothing to be done for `all\'/;
          next if /^cd .* \&\& \\/;
          next if /^make -f Makefile/;
        }
        print;
    }
}

#------------------------------------------------------------------------------
# recursively make folders, requires perl-compatible folder separators
# (ie forward slashes)
# 
sub mkdirs {
    my $path = shift;
    die "backslash in foldername not allowed in mkdirs function:($path)\n"
        if $path =~ m#\\#;
    $path = perl2dos($path);
    print "mkdir $path\n";
    # reduce path to just windows,
    # incase we have a rogue unix mkdir command elsewhere!
    print `set PATH=C:\\WINDOWS\\system32;c:\\WINDOWS;C:\\WINDOWS\\System32\\Wbem && mkdir $path`;

}

#------------------------------------------------------------------------------
# unix compatible  versions of the perl paths (for when we [shell] to unix/bash mode):
sub perl2unix  {
    my $p = shift;
    print "perl2unix: $p\n";
    $p =~ s#$msys#/#i;  # remove superfluous msys folders if they are there

    #change c:/ into /c  (or a D:)   so c:/msys becomes /c/msys etc.
    $p =~ s#^([A-Z]):#/$1#ig;
    $p =~ s#//#/#ig; # reduce any double forward slashes to single ones.
    return $p;
}

#------------------------------------------------------------------------------
# DOS executable CMD.exe versions of the paths (for when we [exec] to DOS mode):
sub perl2dos {
    my $p = shift;
    $p =~ s#/#\\#g; # single forward to single backward
    return $p;
}

#------------------------------------------------------------------------------
# find a pattern in a file and return if it was found or not.
# Absent file assumes pattern was not found.
sub _grep {
    my ($pattern,$file) = @_;
    #$pattern = qw($pattern);
    
    my $fh = IO::File->new("< $file");
    unless ( $fh) {
        print "WARNING: Unable to read file ($file) when searching for ".
              "pattern:($pattern), assumed to NOT match pattern\n";
        return 0;
    }
    my $found = 0;
    while ( my $contents = <$fh> ) {
        if ( $contents =~ m/$pattern/ ) { $found= 1; }
    }
    $fh->close();
    return $found;
}

#------------------------------------------------------------------------------
# where is this script? 
sub scriptpath {
  return "" if ($0 eq "");
  my @path = split /\\/, $0;
  
  pop @path;
  return join '\\', @path;
}

#------------------------------------------------------------------------------
# display stuff to the user in a manner that unclutters it from
# the other compilation messages that will be scrolling past! 
sub comment {
    my $comment = shift;
    print "\nCOMMENTS:";
    print "-"x30;
    print "\n";
    print "COMMENTS:$comment\nCOMMENTS:";
    print "-"x30;
    print "\n";
    print "\n";
}

#------------------------------------------------------------------------------
# how? what the?   oh! like that!  I get it now, I think.
sub usage {
    print << 'END_USAGE';

-h             This message
-v             Verbose output
-o             Include oldthemes in the build [default off]
-g             Exclude mythplugins from the build [default off]
-k             Package win32 distribution
-p proxy:port  Your proxy
-r XXXX|head   Your prefered revision (to change revision)
-b             Checkout release-0-xx-fixes instead of trunk
-c debug|release|profile
               Compile type for mythtv/mythplugins [default debug]
-t             Apply post $SVNRELEASE patches [default off]
-l             Make clean
-d             Configure Database [default off]
END_USAGE
    exit;
}

#------------------------------------------------------------------------------
