#!/usr/bin/perl

### = file
### osx-packager-qtsdk.pl
###
### = revision
### 2.0
####
### Copyright (c) 2012 Jean-Yves Avenard
### based on osx-packager.pl by by Jeremiah Morris <jm@whpress.com>
###
### = location
### https://github.com/MythTV/packaging//OSX/build/osx-packager-qtsdk.pl
###
### = description
### Tool for automating frontend builds on Mac OS X.
### Run "osx-packager.pl -man" for full documentation.

use strict;
use Getopt::Long qw(:config auto_abbrev);
use Pod::Usage ();
use Cwd ();
use File::Temp qw/ tempfile tempdir /;

### Configuration settings (stuff that might change more often)

# We try to auto-locate the Git client binaries.
# If they are not in your path, we build them from source
#
our $git = `which git`; chomp $git;

# This script used to always delete the installed include and lib dirs.
# That probably ensures a safe build, but when rebuilding adds minutes to
# the total build time, and prevents us skipping some parts of a full build
#
our $cleanLibs = 1;

# By default, only the frontend is built (i.e. no backend or transcoding)
#
our $backend = 0;
our $jobtools = 0;

# Start with a generic address and let sourceforge
# figure out which mirror is closest to us.
#
our $sourceforge = 'http://downloads.sourceforge.net';

# At the moment, there is mythtv plus...
our @components = ( 'mythplugins' );

# The OS X programs that we are likely to be interested in.
our @targets   = ( 'MythFrontend',  'MythWelcome' );
our @targetsJT = ( 'MythCommFlag', 'MythJobQueue');
our @targetsBE = ( 'MythBackend',  'MythFillDatabase', 'MythTV-Setup');

# Name of the PlugIns directory in the application bundle
our $BundlePlugins = "PlugIns";
our $OSTARGET = "10.5";

# Patches for MythTV source
our %patches = ();

our %build_profile = (
  'master'
   => [
    'branch' => 'master',
    'mythtv'
    => [
        'ccache',
        'pkgconfig',
        'dvdcss',
        'freetype',
        'lame',
        'mysqlclient',
        #'dbus',
        'qt',
        'yasm',
        'liberation-sans',
        'firewiresdk',
       ],
    'mythplugins'
    => [
        'exif',
# MythMusic needs these:
        'libtool',
        'autoconf',
        'automake',
        'taglib',
        'libogg',
        'vorbis',
        'flac',
        'libcddb',
        'libcdio',
       ],
     ],
  '0.24-fixes'
  => [
    'branch' => 'fixes/0.24',
    'mythtv'
    =>  [
        'ccache',
        'pkgconfig',
        'dvdcss',
        'freetype',
        'lame',
        'mysqlclient',
        #'dbus',
        'qt',
        'yasm',
        'liberation-sans',
        'firewiresdk',
      ],
    'mythplugins'
    =>  [
        'exif',
# MythMusic needs these:
        'libtool',
        'autoconf',
        'automake',
        'taglib',
        'libogg',
        'vorbis',
        'flac',
      ],
    ],
);

=head1 NAME

osx-packager.pl - build OS X binary packages for MythTV

=head1 SYNOPSIS

 osx-packager.pl [options]

 Options:
  -help              print the usage message
  -man               print full documentation
  -verbose           print informative messages during the process
  -distclean         throw away all myth installed and intermediates
                     files and exit
  -qtsdk <path>      path to Qt SDK Deskop
                     (e.g. -qtsdk ~/QtSDK/Desktop/Qt/4.8.0
  -qtbin <path>      path to Qt utilitities (qmake etc)
  -qtplugins <path>  path to Qt plugins
  -qtsrc <version>   build Qt from source
  -m32               build for a 32-bit environment only
                     (default is to build for the host's architecture)
  -universal         build for both 32 and 64 bits architectures
                     (only works with 0.25 or later,
                     requires Qt libraries)
  -gitrev <str>      build a specified Git revision or tag

 You must provide either -qtsdk or -qtbin *and * -qtplugins

 Advanced Options:
  -srcdir  <path>    build using provided root mythtv directory
  -pkgsrcdir <path>  build using provided packaging directory
  -archive <path>    specify where dependencies archives can be found
                     (default is .osx-packager/src)
  -force             use myth source directory as-is,
                     with no GIT validity check
  -nodistclean       do not perform a distclean prior to building myth
  -thirdclean        do a clean rebuild of third party packages
  -thirdskip         don't rebuild the third party packages
  -mythtvskip        don't rebuild/install mythtv, requires -nodistclean
  -pluginskip        don't rebuild/install mythplugins
  -nohead            don't update to HEAD revision of MythTV before
                     building
  -clean             clean myth module before rebuilding it (default)
  -noclean           use with -nohead, do not re-run configure nor clean
  -usehdimage        perform build inside of a case-sensitive disk image
  -leavehdimage      leave disk image mounted on exit
  -enable-backend    build the backend server as well as the frontend
  -enable-jobtools   build commflag/jobqueue  as well as the frontend
  -profile           build with compile-type=profile
  -debug             build with compile-type=debug
  -plugins <str>     comma-separated list of plugins to include
  -noparallel        do not use parallel builds.
                     compiling Qt from source will fail will parallel builds
  -nobundle          only recompile, do not create application bundle
  -bootstrap         exit after building all thirdparty components
  -nosysroot         compiling with sysroot only works with 0.25 or later
                     use -nosysroot if compiling earlier version
  -olevel <n>        compile with extra -On
  -buildprofile <x>  build either master or fixes-0.24 (default: master)


=head1 DESCRIPTION

This script builds a MythTV frontend and all necessary dependencies, along
with plugins as specified, as a standalone binary package for Mac OS X.

It is designed for building daily Git snapshots,
and can also be used to create release builds with the '-gitrev' option.

All intermediate files go into an '.osx-packager' directory in the current
working directory. The finished application is named 'MythFrontend.app' and
placed in the current working directory.
 
By default, the end application will only run on the architecture of the machine
used to compile (32 or 64 bits). Use -universal to compile an application for both
32 and 64 bits. For -universal to work, you must compile on a 64 bits intel host.

=head1 REQUIREMENTS
 
You need to have installed either Qt SDK (64 bits only) or
Qt libraries package (both 32 and 64 bits) from http://qt.nokia.com/downloads.
 
When using the Qt SDK, use the -qtsdk flag to define the location of the Desktop Qt,
by default it is ~/QtSDK/Desktop/Qt/[VERSION]/gcc where version is 4.8.0 (SDK 1.2)
or 473 (SDK 1.1)

When using the Qt libraries package, use the -qtbin and -qtplugins. Values for default
Qt installation are: -qtbin /usr/bin -qtplugins /Developer/Applications/Qt/plugins.
Qt Headers must be installed.

=head1 EXAMPLES

Building two snapshots, one with all plugins and one without:

  osx-packager.pl -qtbin /usr/bin -qtplugins /Developer/Applications/Qt/plugins
  mv MythFrontend.app MythFrontend-plugins.app 
  osx-packager.pl -nohead -pluginskip -qtbin /usr/bin -qtplugins /Developer/Applications/Qt/plugins
  mv MythFrontend.app MythFrontend-noplugins.app

Building a "fixes" branch:

  osx-packager.pl -gitrev fixes/0.24 -qtsrc 4.6.4 -nosysroot -m32

Note that this script will not build old branches.
Please try the branched version instead. e.g.
http://svn.mythtv.org/svn/branches/release-0-21-fixes/mythtv/contrib/OSX/osx-packager.pl

=head1 CREDITS

Written by Jean-Yves Avenard <jyavenard@gmail.com>
Based on work by Jeremiah Morris <jm@whpress.com>

Includes contributions from Nigel Pearson, Jan Ornstedt, Angel Li, and Andre Pang, Bas Hulsken (bhulsken@hotmail.com)

=cut

# Parse options
our (%OPT);
Getopt::Long::GetOptions(\%OPT,
                         'help|?',
                         'man',
                         'verbose',
                         'distclean',
                         'thirdclean',
                         'nodistclean',
                         'noclean',
                         'thirdskip',
                         'mythtvskip',
                         'pluginskip',
                         'gitrev=s',
                         'nohead',
                         'usehdimage',
                         'leavehdimage',
                         'enable-backend',
                         'enable-jobtools',
                         'profile',
                         'debug',
                         'm32',
                         'universal',
                         'plugins=s',
                         'srcdir=s',
                         'pkgsrcdir=s',
                         'force',
                         'archives=s',
                         'buildprofile=s',
                         'bootstrap',
                         'nohacks',
                         'noparallel',
                         'qtsdk=s',
                         'qtbin=s',
                         'qtplugins=s',
                         'qtsrc=s',
                         'nobundle',
                         'olevel=s',
                         'nosysroot',
                         
                        ) or Pod::Usage::pod2usage(2);
Pod::Usage::pod2usage(1) if $OPT{'help'};
Pod::Usage::pod2usage('-verbose' => 2) if $OPT{'man'};

if ( $OPT{'enable-backend'} )
{   $backend = 1  }

if ( $OPT{'noclean'} )
{   $cleanLibs = 0  }

if ( $OPT{'enable-jobtools'} )
{   $jobtools = 1  }

if ( $OPT{'srcdir'} )
{
    $OPT{'nohead'} = 1;
    $OPT{'gitrev'} = '';
}

# Build our temp directories
our $SCRIPTDIR = Cwd::abs_path(Cwd::getcwd());
if ( $SCRIPTDIR =~ /\s/ )
{
    &Complain(<<END);
Working directory contains spaces

Error: Your current working path:

   $SCRIPTDIR

contains one or more spaces. This will break the compilation process,
so the script cannot continue. Please re-run this script from a different
directory (such as /tmp).

The application produced will run from any directory, the no-spaces
rule is only for the build process itself.

END
    die;
}

our $WORKDIR = "$SCRIPTDIR/.osx-packager";
mkdir $WORKDIR;

if ( $OPT{'nohead'} && ! $OPT{'force'} && ! $OPT{'srcdir'} )
{
    my $GITTOP="$WORKDIR/src/myth-git/.git";

    if ( ! -d $GITTOP )
    {   die "No source code to build?"   }

    if ( ! `grep refs/heads/master $GITTOP/HEAD` )
    {   die "Source code does not match GIT master"   }
}
elsif ( $OPT{'gitrev'} =~ m,^fixes/, && $OPT{'gitrev'} lt "fixes/0.23" )
{
    &Complain(<<END);
This version of this script can not build old branches.
Please try the branched version instead. e.g.
http://svn.mythtv.org/svn/branches/release-0-23-fixes/packaging/OSX/build/osx-packager.pl
http://svn.mythtv.org/svn/branches/release-0-21-fixes/mythtv/contrib/OSX/osx-packager.pl
END
    die;
}

if ($OPT{usehdimage})
{   MountHDImage()   }

our $PREFIX = "$WORKDIR/build";
mkdir $PREFIX;

our $SRCDIR = "$WORKDIR/src";
mkdir $SRCDIR;

our $ARCHIVEDIR ='';
if ( $OPT{'archives'} )
{
    $ARCHIVEDIR = "${SCRIPTDIR}/$OPT{'archives'}";
} else {
    $ARCHIVEDIR = "$SRCDIR";
}

our $QTSDK = "";
our $QTBIN = "";
our $QTLIB = "";
our $QTPLUGINS = "";
our $QTVERSION = "";
our $GITVERSION = "";

if ( ! $OPT{'qtsrc'} )
{
    if ( $OPT{'qtsdk'} )
    {
        $QTSDK = $OPT{'qtsdk'};
    }

    if ( $OPT{'qtbin'} )
    {
        $QTBIN = "$OPT{'qtbin'}";
    }
    elsif ( $OPT{'qtsdk'} )
    {
        $QTBIN = "$OPT{'qtsdk'}/bin";
    }
    if ( $OPT{'qtplugins'} )
    {
        $QTPLUGINS = "$OPT{'qtplugins'}";
    }
    elsif ( $OPT{'qtsdk'} )
    {
        $QTPLUGINS = "$QTSDK/plugins";
    }

    # Test if Qt conf is valid, all paths must exist
    if ( ! ( (($QTBIN ne "") && ($QTPLUGINS ne "")) &&
         ( -d $QTBIN && -d $QTPLUGINS )) )
    {
        &Complain("bin:$QTBIN lib:$QTLIB plugins:$QTPLUGINS You must define a valid Qt SDK path with -qtsdk <path> or -qtbin <path> *and* -qtplugins <path>");
        exit;
    }

    #Determine the version Qt SDK we are using, we need to retrieve the source code to build MySQL Qt plugin
    if ( ! -e "$QTBIN/qmake" )
    {
        &Complain("$QTBIN isn't a valid Qt bin path (qmake not found)");
        exit;
    }
    my @ret = `$QTBIN/qmake --version`;
    my $regexp = qr/Qt version (\d+\.\d+\.\d+) in (.*)$/;
    foreach my $line (@ret)
    {
        chomp $line;
        next if ($line !~ m/$regexp/);
        $QTVERSION = $1;
        $QTLIB = $2;
        &Verbose("Qt version is $QTVERSION");
    }

    if ($QTVERSION eq "")
    {
        &Complain("Couldn't identify Qt version");
        exit;
    }
    if ( ! -d $QTLIB )
    {
        &Complain("$QTLIB doesn't exist. Invalid Qt sdk");
        exit;
    }
}
else
{
    $QTVERSION = $OPT{'qtsrc'};
    if ( $QTVERSION !~ m/^\d.\d.\d$/ )
    {
        &Complain("$QTVERSION isn't a valid version number");
        exit;
    }
    elsif ( $QTVERSION =~ m/^3|^4\.[0-5]/ )
    {
        &Complain("You must use Qt 4.6.0 and above");
        exit;
    }
    my $hostos = `uname -r`; chomp $hostos;
    if ( $hostos =~ m/^1[12]\./ && $QTVERSION !~ m/^4\.[89]\./ )
    {
        &Complain("You must use Qt 4.8.0 or above with your OS");
        exit;
    }
    $QTBIN="$PREFIX/bin";
    $QTPLUGINS="$PREFIX/plugins";
    $QTLIB="$PREFIX/lib";
}

our %depend_order = '';
my $gitrevision = 'master';  # Default thingy to checkout
if ( $OPT{'buildprofile'} && $OPT{'buildprofile'} == '0.24-fixes' )
{
    &Verbose('Building using 0.24-fixes profile');
    %depend_order = @{ $build_profile{'0.24-fixes'} };
    $gitrevision = 'fixes/0.24'
} else {
    &Verbose('Building using master profile');
    %depend_order = @{ $build_profile{'master'} };
}

our $GITDIR = "$SRCDIR/myth-git";

our @pluginConf;
if ( $OPT{plugins} )
{
    @pluginConf = split /,/, $OPT{plugins};
    @pluginConf = grep(s/^/--enable-/, @pluginConf);
    unshift @pluginConf, '--disable-all';
}
else
{
    @pluginConf = (
        '--enable-opengl',
        '--enable-mythgallery',
        '--enable-exif',
        '--enable-new-exif',
    );
}

# configure mythplugins, and mythtv, etc
our %conf = (
  'mythplugins'
  =>  [
        @pluginConf
      ],
  'mythtv'
  =>  [
        '--runprefix=../Resources',
        '--enable-libmp3lame',
        '--disable-lirc',
        '--disable-distcc',

        # To "cross compile" something for a lesser Mac:
        #'--tune=G3',
        #'--disable-altivec',
      ],
);

# configure mythplugins, and mythtv, etc
our %makecleanopt = (
  'mythplugins'
  =>  [
        'distclean',
      ],
);

use File::Basename;
our $gitpath = dirname $git;

# Clean the environment
$ENV{'PATH'} = "$PREFIX/bin:/bin:/usr/bin:/usr/sbin:$gitpath";
$ENV{'PKG_CONFIG_PATH'} = "$PREFIX/lib/pkgconfig:";
delete $ENV{'CPP'};
delete $ENV{'CXX'};

our $DEVROOT = `xcode-select -print-path`; chomp $DEVROOT;
our $SDKVER = `xcodebuild -showsdks | grep macosx10 | sort | head -n 1 | awk '{ print \$4 }' `; chomp $SDKVER;
our $SDKNAME = `xcodebuild -showsdks | grep macosx10 | sort | head -n 1 | awk '{ print \$6 }' `; chomp $SDKNAME;
our $SDKROOT = "$DEVROOT/SDKs/MacOSX$SDKVER.sdk";

$ENV{'DEVROOT'} = $DEVROOT;
$ENV{'SDKVER'} = $SDKVER;
$ENV{'SDKROOT'} = $SDKROOT;

# Determine appropriate gcc/g++ path for the selected SDKs
our $CCBIN = `xcodebuild -find gcc -sdk $SDKNAME`; chomp $CCBIN;
our $CXXBIN = `xcodebuild -find g++ -sdk $SDKNAME`; chomp $CXXBIN;
my $XCODEVER = `xcodebuild -version`; chomp $XCODEVER;
if ( $XCODEVER =~ m/Xcode\s+(\d+\.\d+(\.\d+)?)/ && ! $OPT{'olevel'} )
{
    if ( $1 =~ m/^4\.2/ )
    {
        &Complain("XCode 4.2 is buggy, please upgrade to 4.3 or later");
    }
}

$ENV{'CC'} = $CCBIN;
$ENV{'CXX'} = $CXXBIN;
$ENV{'CPP'} = "$CCBIN -E";
$ENV{'CXXCPP'} = "$CXXBIN -E";

if ( ! -e "$SDKROOT" && ! $OPT{'nosysroot'} )
{
    #Handle special case for 10.4 where the SDK name is 10.4u.sdk
    $SDKROOT = "$DEVROOT/SDKs/MacOSX${SDKVER}u.sdk";
    if ( ! -e "$SDKROOT" )
    {
        # Handle XCode 4.3 new location
        $SDKROOT = "$DEVROOT/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$SDKVER.sdk";
        if ( ! -e "$SDKROOT" )
        {
            &Complain("$SDKROOT doesn't exist");
            &Complain("Did you set your xcode environmment path properly ? (xcode-select utility)");
            exit;
        }
    }
}

#Compilation was broken when using sysroots, mythtv code was fixed from 0.25 only. so this makes it configurable
our $SDKISYSROOT = "-isysroot $SDKROOT";
our $SDKLSYSROOT = "-Wl,-syslibroot,${SDKROOT}";
if ( $OPT{'nosysroot'} )
{
    $SDKISYSROOT = "";
    $SDKLSYSROOT = "";
}

# set up Qt environment
$ENV{'QTDIR'} = "$QTSDK";
$ENV{'QMAKESPEC'} = 'macx-g++';
$ENV{'MACOSX_DEPLOYMENT_TARGET'} = $OSTARGET;

our $OLEVEL="";
if ( $OPT{'olevel'} =~ /^\d+$/ )
{
    $OLEVEL="-O" . $OPT{'olevel'} . " ";
}

my $SDK105FLAGS="";
if ( $SDKVER =~ m/^10\.[3-5]/ )
{
    $SDK105FLAGS = " -D_USING_105SDK=1";
}
$ENV{'CFLAGS'} = $ENV{'CXXFLAGS'} = $ENV{'ECXXFLAGS'} = $ENV{'CPPFLAGS'} = "${OLEVEL}${SDKISYSROOT}${SDK105FLAGS} -mmacosx-version-min=$OSTARGET -I$PREFIX/include -I$PREFIX/mysql";
$ENV{'LDFLAGS'} = "$SDKLSYSROOT -mmacosx-version-min=$OSTARGET -L$PREFIX/lib -F$QTLIB";
$ENV{'PREFIX'} = $PREFIX;
$ENV{'SDKROOT'} = $SDKROOT;

# compilation flags used for compiling dependency tools, do not use multi-architecture
our $CFLAGS    = $ENV{'CFLAGS'};
our $CXXFLAGS  = $ENV{'CXXFLAGS'};
our $ECXXFLAGS = $ENV{'ECXXFLAGS'};
our $CPPFLAGS  = $ENV{'CPPFLAGS'};
our $LDFLAGS   = $ENV{'LDFLAGS'};
our $ARCHARG   = "";
our @ARCHS;

# Check host computer architecture and create list of architecture to build
my $arch = `sysctl -n hw.machine`; chomp $arch;
#hw.machine returns what the kernel is using, not if the machine is 64 bits capable
#so compile for the appropriate 64 bits target if we can
my $m64 = `sysctl hw.cpu64bit_capable`; chomp $m64;
if ( $? == 0 && $m64 =~ m/\s+1$/ )
{
    if ( $arch eq "i386" )
    {
        $arch = "x86_64";
    }
}
if ( $OPT{'m32'} && ! $OPT{'universal'} )
{
    &Verbose('Forcing 32 bits build...');
    if ( $arch eq "x86_64" || $arch eq "i386" )
    {
        push @ARCHS, "i386";
    }
    else
    {
        # assume PPC, what else could it be?
        push @ARCHS, "ppc7400";
    }
}
elsif ( $arch eq "x86_64" || $arch eq "ppc64" )
{
    if ( $OPT{'universal'} )
    {
        # Requested universal, and 64 bits host
        &Verbose('Building 32/64 bits universal app...');
        if ( $arch eq "x86_64" )
        {
            push @ARCHS, "i386", "x86_64";
        }
        else
        {
            push @ARCHS, "ppc7400", "ppc64";
        }
    }
    else
    {
        if ( $arch eq "x86_64" )
        {
            push @ARCHS, "x86_64";
        }
        else
        {
            push @ARCHS, "ppc64";
        }
    }
}
else
{
    if ( $arch eq "i386" )
    {
        push @ARCHS, "i386";
    }
    else
    {
        push @ARCHS, "ppc7400";
    }
    $OPT{'universal'} = 0;
}

for my $arch (@ARCHS)
{
    $ENV{'CFLAGS'}    .= " -arch $arch";
    $ENV{'CXXFLAGS'}  .= " -arch $arch";
    $ENV{'ECXXFLAGS'} .= " -arch $arch";  # MythTV configure
    $ENV{'LDFLAGS'}   .= " -arch $arch";
    $ARCHARG .= " -arch $arch";
}

# Test if Qt libraries support required architectures. We do so by generating a dummy project and trying to compile it
if ( ! $OPT{'qtsrc'} )
{
    &Verbose("Testing Qt environment");
    my $dir = tempdir( CLEANUP => 1 );
    my $tmpe = "$dir/test";
    my $tmpcpp = "$dir/test.cpp";
    my $tmppro = "$dir/test.pro";
    my $make = "$dir/Makefile";
    open fdcpp, ">", $tmpcpp;
    print fdcpp "#include <QString>\nint main(void) { QString(); }\n";
    close fdcpp;
    open fdpro, ">", $tmppro;
    my $name = basename($tmpe);
    print fdpro "SOURCES=$tmpcpp\nTARGET=$name\nDESTDIR=$dir\nCONFIG-=app_bundle";
    close fdpro;
    my $cmd = "$QTBIN/qmake \"QMAKE_CC=$CCBIN\" \"QMAKE_CXX=$CXXBIN\" \"QMAKE_CXXFLAGS=$ENV{'ECXXFLAGS'}\" \"QMAKE_CFLAGS=$ENV{'CFLAGS'}\" \"QMAKE_LFLAGS+='$ENV{'LDFLAGS'}'\" -o $make $tmppro";
    $cmd .= " 2> /dev/null > /dev/null" if ( ! $OPT{'verbose'} );
    &Syscall($cmd);
    &Syscall(['/bin/rm' , '-f', $tmpe]);
    $cmd = "/usr/bin/make -C $dir -f $make $name";
    $cmd .= " 2>/dev/null >/dev/null" if ( ! $OPT{'verbose'} );
    my $result = &Syscall($cmd);

    if ( $result ne "1" )
    {
        &Complain("Couldn't use Qt for the architectures @ARCHS. If using -universal or -m32, make sure the Qt frameworks is build for those architectures");
        exit;
    }
}

# show summary of build parameters.
&Verbose("Target architectures: @ARCHS");
&Verbose("DEVROOT = $DEVROOT");
&Verbose("SDKVER = $SDKVER");
&Verbose("SDKROOT = $SDKROOT");
&Verbose("CCBIN = $ENV{'CC'}");
&Verbose("CXXBIN = $ENV{'CXX'}");
&Verbose("CFLAGS = $ENV{'CFLAGS'}");
&Verbose("LDFLAGS = $ENV{'LDFLAGS'}");

# Test if LLVM, mythtv doesn't compile unless you build in debug mode
my $out = `$CCBIN --version`;
if ( $out =~ m/llvm/ )
{
    $OPT{'debug'} = 1;
    &Verbose('Using LLVM: Forcing debug compile...');
}

our $standard_make = '/usr/bin/make';
our $parallel_make = $standard_make;
our $parallel_make_flags = '';

my $cmd = "/usr/bin/hostinfo | grep 'processors\$'";
&Verbose($cmd);
my $cpus = `$cmd`; chomp $cpus;
$cpus =~ s/.*, (\d+) processors$/$1/;
if ( $cpus gt 1 )
{
    &Verbose("Using", $cpus+1, "jobs on $cpus parallel CPUs");
    ++$cpus;
    $parallel_make_flags = "-j$cpus";
}

if ($OPT{'noparallel'})
{
    $parallel_make_flags = '';
}
$parallel_make .= " $parallel_make_flags";

our %depend = (

    'git' =>
    {
        'url'           => 'http://www.kernel.org/pub/software/scm/git/git-1.7.3.4.tar.bz2',
        'parallel-make' => 'yes'
    },

    'freetype' =>
    {
        'url' => "$sourceforge/sourceforge/freetype/freetype-2.4.8.tar.gz",
    },

    'lame' =>
    {
        'url'           =>  "$sourceforge/sourceforge/lame/lame-3.99.5.tar.gz",
        'conf'          =>  [
            '--disable-frontend',
        ],
    },

    'libmad' =>
    {
        'url'           => "$sourceforge/sourceforge/mad/libmad-0.15.0b.tar.gz",
        'parallel-make' => 'yes'
    },

    # default generated taglib configure is bugger and won't compile universal file. So need to regenerate it
    # new version of taglib 1.7 uses cmake which takes excessively long time to compile. So stick with 1.6.3
    'taglib' =>
    {
        'url'           => 'http://developer.kde.org/~wheeler/files/src/taglib-1.6.3.tar.gz',
        'pre-conf'      => "cp $PREFIX/share/libtool/config/ltmain.sh admin/ ; " .
            "cp $PREFIX/share/aclocal/libtool.m4 admin/libtool.m4.in ; " .
            "$PREFIX/bin/autoreconf",
    },

    'libogg' =>
    {
        'url'           => 'http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz',
    },

    'vorbis' =>
    {
        'url'           => 'http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.2.tar.gz',
    },

    'flac' =>
    {
        'url'  => "$sourceforge/sourceforge/flac/flac-1.2.1.tar.gz",
        # Workaround Intel problem - Missing _FLAC__lpc_restore_signal_asm_ia32
        'conf' => [
            '--disable-asm-optimizations',
        ],
        # patch to support universal compilation and fix incorrect sizeof
        'post-conf' => "echo \"/#define SIZEOF_VOIDP/c\n" .
            "#ifdef __LP64__\n" .
            "#define SIZEOF_VOIDP 8\n" .
            "#else\n" .
            "#define SIZEOF_VOIDP 4\n" .
            "#endif\n" .
            ".\n" .
            "w\" | /bin/ed config.h ; sed -i -e 's/CC -dynamiclib/CC -dynamiclib $ARCHARG/g' libtool",
    },

    # pkgconfig 0.26 and above do not include glib which is required to compile
    # glib requires pkgconfig to compile, so it's a chicken and egg problem.
    # Use nothing newer than 0.25 on OSX.
    'pkgconfig' =>
    {
        'url'           => "http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz",
        'conf-cmd'      =>  "CFLAGS=\"\" LDFLAGS=\"\" ./configure",
        'conf'          => [
            "--prefix=$PREFIX",
            "--disable-static",
            "--enable-shared",
        ],
        
    },

    'dvdcss' =>
    {
        'url'           =>  'http://download.videolan.org/pub/videolan/libdvdcss/1.2.11/libdvdcss-1.2.11.tar.bz2',
    },

    'mysqlclient' =>
    {
        'url'           => 'http://downloads.mysql.com/archives/mysql-5.1/mysql-5.1.56.tar.gz',
        'conf'          =>  [
            '--without-debug',
            '--without-docs',
            '--without-man',
            '--without-bench',
            '--without-server',
            '--without-geometry',
            '--without-extra-tools',
        ],
    },

    'dbus' =>
    {
        'url' => 'http://dbus.freedesktop.org/releases/dbus/dbus-1.0.3.tar.gz',
        'post-make' => 'mv $PREFIX/lib/dbus-1.0/include/dbus/dbus-arch-deps.h '.
        ' $PREFIX/include/dbus-1.0/dbus ; '.
        'rm -fr $PREFIX/lib/dbus-1.0 ; '.
        'cd $PREFIX/bin ; '.
        'echo "#!/bin/sh
        if [ \"\$2\" = dbus-1 ]; then
        case \"\$1\" in
        \"--version\") echo 1.0.3  ;;
        \"--cflags\")  echo -I$PREFIX/include/dbus-1.0 ;;
        \"--libs\")    echo \"-L$PREFIX/lib -ldbus-1\" ;;
        esac
        fi
        exit 0"   > pkg-config ; '.
        'chmod 755 pkg-config'
    },

    'qt'
    =>
    {
        'url' => "http://download.qt.nokia.com/qt/source/qt-everywhere-opensource-src-${QTVERSION}.tar.gz",
        'pre-conf'
        =>  # Get around Qt bug QTBUG-24498 (4.8.0) && stupid thing can't compile in release mode on mac without framework active
        #also hack for QTBUG-23258
        "find . -name \"*.pro\" -exec sed -i -e \"s:/Developer/SDKs/:.*:g\" {} \\;",
        'conf-cmd'
        =>  "cd src/plugins/sqldrivers/mysql && $QTBIN/qmake \"QMAKE_CC=$CCBIN\" \"QMAKE_CXX=$CXXBIN\" \"QMAKE_CXXFLAGS=$ENV{'ECXXFLAGS'}\" \"QMAKE_CFLAGS=$ENV{'CFLAGS'}\" \"QMAKE_LFLAGS+='$ENV{'LDFLAGS'}'\" \"INCLUDEPATH+=$PREFIX/include/mysql\" \"LIBS+=-L$PREFIX/lib/mysql -lmysqlclient_r\" \"target.path=$PREFIX/qtplugins-$QTVERSION\" mysql.pro",
        'make-cmd' => 'cd src/plugins/sqldrivers/mysql',
        'make' => [ ],
        'post-make' => 'cd src/plugins/sqldrivers/mysql ; make install ; '.
            'make -f Makefile.Release install ; '.
            "cd $PREFIX/lib ; ln -s mysql lib; ".
            "rm -f $PREFIX/bin/pkg-config ; ".
            '',
        #WebKit in Qt keeps erroring half way on my quad-core when using -jX, use -noparallel
        'parallel-make' => 'yes'
    },

    'qt-src'
    =>
    {
        'url'
        => "http://download.qt.nokia.com/qt/source/qt-everywhere-opensource-src-${QTVERSION}.tar.gz",
        'arg-patches'
        => "echo $QTVERSION",
        'patches' =>
        {
            #also hack for QTBUG-23258
            '4.8.1' => "sed -i -e \"s:#elif defined(Q_OS_SYMBIAN) && defined (QT_NO_DEBUG):#else:g\" src/corelib/kernel/qcoreapplication.cpp; sed -i -e \"s:#if\\( \\!defined (QT_NO_DEBUG) || defined (QT_MAC_FRAMEWORK_BUILD) || defined (Q_OS_SYMBIAN)\\):#if 1 //\1:g\" src/corelib/kernel/qcoreapplication_p.h; sed -i -e \"s:^\\(#import <QTKit/QTKit.h>\\):#if defined(slots)\\\\\n#undef slots\\\\\n#endif\\\\\n \\1:g\" src/3rdparty/webkit/Source/WebCore/platform/graphics/mac/MediaPlayerPrivateQTKit.mm",
            '4.8.0' => "sed -i -e \"s:#elif defined(Q_OS_SYMBIAN) && defined (QT_NO_DEBUG):#else:g\" src/corelib/kernel/qcoreapplication.cpp; sed -i -e \"s:#if\\( \\!defined (QT_NO_DEBUG) || defined (QT_MAC_FRAMEWORK_BUILD) || defined (Q_OS_SYMBIAN)\\):#if 1 //\1:g\" src/corelib/kernel/qcoreapplication_p.h; sed -i -e \"s:^\\(#import <QTKit/QTKit.h>\\):#if defined(slots)\\\\\n#undef slots\\\\\n#endif\\\\\n \\1:g\" src/3rdparty/webkit/Source/WebCore/platform/graphics/mac/MediaPlayerPrivateQTKit.mm",
            '4.7.4' => "patch -f -p0 <<EOF\n" . <<EOF
--- tools/qdoc3/cppcodemarker.cpp.ori	2012-03-07 10:26:46.000000000 +1100
+++ tools/qdoc3/cppcodemarker.cpp	2012-03-07 10:51:33.000000000 +1100
@@ -43,6 +43,7 @@
   cppcodemarker.cpp
 */
 
+#include "ctype.h"
 #include "atom.h"
 #include "cppcodemarker.h"
 #include "node.h"
EOF
            . "\nEOF",
        },
        'pre-conf'
        =>  # Get around Qt bug QTBUG-24498 (4.8.0) && stupid thing can't compile in release mode on mac without framework active
        "find . -name \"*.pro\" -exec sed -i -e \"s:/Developer/SDKs/:.*:g\" {} \\; ",
        'conf-cmd'
        # Using $LDFLAGS as the -arch blah confuses their Makefile
        =>  "echo yes | LDFLAGS=\"$LDFLAGS\" ./configure $ARCHARG -v",
        'conf'
        =>  [
        '-opensource',
        '-prefix', '"$PREFIX"',
        '-release',
        '-fast',
        '-no-accessibility',
        '-no-stl',
        '-sdk' , '$SDKROOT',
        
        # When MythTV all ported:  '-no-qt3support',
        
        '-no-sql-mysql',
        '-no-sql-sqlite',
        '-no-sql-odbc',
        '-system-zlib',
        '-no-libtiff',
        '-no-libmng',
        '-nomake examples -nomake demos',
        '-no-nis',
        '-no-cups',
        '-no-qdbus',
        '-no-framework',
        '-no-multimedia',
        '-no-phonon',
        '-no-svg',
        '-no-javascript-jit',
        '-no-scripttools',
        ],
        # Get around Qt configure bug QTBUG-17203 when you define -arch
        'post-conf'
        => 'find . -name "Makefile*" -exec sed -i -e "s/ -arch -/ -/g;s/-arch$//g" {} \;', 
        'make'
        =>  [ ],
        # Build mysql module separately, the info provided by mysql_config confuses Qt makefile.
        'post-make' => "make sub-plugins-install_subtargets-ordered install_qmake install_mkspecs ;".
        "if [ -d src/gui/mac/qt_menu.nib ]; then rm -rf $PREFIX/lib/qt_menu.nib ; cp -R src/gui/mac/qt_menu.nib $PREFIX/lib ; fi ; cd src/plugins/sqldrivers/mysql && $QTBIN/qmake \"QMAKE_CC=$CCBIN\" \"QMAKE_CXX=$CXXBIN\" \"QMAKE_CXXFLAGS=$ENV{'ECXXFLAGS'}\" \"QMAKE_CFLAGS=$ENV{'CFLAGS'}\" \"QMAKE_LFLAGS+=$LDFLAGS\" \"INCLUDEPATH+=$PREFIX/include/mysql\" \"LIBS+=-L$PREFIX/lib/mysql -lmysqlclient_r\" \"target.path=$PREFIX/qtplugins-$QTVERSION\" mysql.pro ; ".
            'make install ; '.
            'make -f Makefile.Release install ; '.
            "cd $PREFIX/lib ; ln -s mysql lib; ".
        # Using configure -release saves a lot of space and time,
        # but by default, debug builds of mythtv try to link against
        # debug libraries of Qt. This works around that:
            'ln -sf libQt3Support.dylib libQt3Support_debug.dylib ; '.
            'ln -sf libQtSql.dylib      libQtSql_debug.dylib      ; '.
            'ln -sf libQtXml.dylib      libQtXml_debug.dylib      ; '.
            'ln -sf libQtOpenGL.dylib   libQtOpenGL_debug.dylib   ; '.
            'ln -sf libQtGui.dylib      libQtGui_debug.dylib      ; '.
            'ln -sf libQtNetwork.dylib  libQtNetwork_debug.dylib  ; '.
            'ln -sf libQtCore.dylib     libQtCore_debug.dylib     ; '.
            'ln -sf libQtWebKit.dylib   libQtWebKit_debug.dylib   ; '.
            'ln -sf libQtScript.dylib   libQtScript_debug.dylib   ; '.
            "rm -f $PREFIX/bin/pkg-config ; ".
            '',
        #WebKit in Qt keeps erroring half way on my quad-core when using -jX, use -noparallel
        'parallel-make' => 'yes'
    },

    'exif' =>
    {
        'url'           => "$sourceforge/sourceforge/libexif/libexif-0.6.20.tar.bz2",
        'conf'          => [
            '--disable-docs'
        ]
    },

    'yasm' =>
    {
        'url'           => 'http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz',
    },

    'ccache' =>
    {
        'url'           => 'http://samba.org/ftp/ccache/ccache-3.1.4.tar.bz2',
        'parallel-make' => 'yes'
    },

    'libcddb' =>
    {
        'url'           => 'http://prdownloads.sourceforge.net/libcddb/libcddb-1.3.2.tar.bz2',
    },

    'libcdio' =>
    {
        'url'           => 'http://ftp.gnu.org/pub/gnu/libcdio/libcdio-0.83.tar.bz2',
    },

    'liberation-sans' =>
    {
        'url'      => 'https://fedorahosted.org/releases/l/i/liberation-fonts/liberation-fonts-ttf-1.07.1.tar.gz',
        'conf-cmd' => 'echo "all:" > Makefile',
        'make'     => [ ],  # override the default 'make all install' targets
    },

    'firewiresdk' =>
    {
        'url'      => 'http://www.avenard.org/files/mac/AVCVideoServices.framework.tar.gz',
        'conf-cmd' => 'cd',
        'make-cmd' => "rm -rf $PREFIX/lib/AVCVideoServices.framework ; cp -R . $PREFIX/lib/AVCVideoServices.framework",
        'make'     => [ ],
    },

    'cmake'       =>
    {
        'url'      => 'http://www.cmake.org/files/v2.8/cmake-2.8.7.tar.gz',
    },

    'libtool'     =>
    {
        'url'     => 'http://ftpmirror.gnu.org/libtool/libtool-2.4.2.tar.gz',
    },

    'autoconf'    =>
    {
        'url'     => 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.gz',
    },
    'automake'    =>
    {
        'url'     => 'http://ftp.gnu.org/gnu/automake/automake-1.11.tar.gz',
    },

);


### Check for app present in target location
our $MFE = "$SCRIPTDIR/MythFrontend.app";
if ( -d $MFE && ! $OPT{'nobundle'} && ! $OPT{'distclean'} )
{
    &Complain(<<END);
$MFE already exists

Error: a MythFrontend application exists where we were planning
to build one. Please move this application away before running
this script.

END
    exit;
}

### Third party packages
my ( @build_depends, %seen_depends );
my @comps = ( 'mythtv', @components, 'packaging' );

# Deal with user-supplied skip arguments
if ( $OPT{'mythtvskip'} )
{   @comps = grep(!m/mythtv/,      @comps)   }
if ( $OPT{'pluginskip'} )
{   @comps = grep(!m/mythplugins/, @comps)   }

if ( ! @comps )
{
    &Complain("Nothing to build! Too many ...skip arguments?");
    exit;
}

&Verbose("Including components:", @comps);

# If no Git in path, and we are checking something out, build Git:
if ( ( ! $git || $git =~ m/no git in / ) && ! $OPT{'nohead'} )
{
    $git = "$PREFIX/bin/git";
    @build_depends = ( 'git' );
}

foreach my $comp (@comps)
{
    foreach my $dep (@{ $depend_order{$comp} })
    {
        unless (exists $seen_depends{$dep})
        {
            push(@build_depends, $dep);
            $seen_depends{$dep} = 1;
        }
    }
}

#Build qt-src instad of 'qt' if we are building Qt from source
if ( $OPT{'qtsrc'} )
{
    my $depends = join(",", @build_depends);
    $depends =~ s/qt/qt-src/;
    @build_depends = split /,/, $depends;
}
foreach my $sw ( @build_depends )
{
    # Get info about this package
    my $pkg = $depend{$sw};
    my $url = $pkg->{'url'};
    my $filename = $url;
    $filename =~ s|^.+/([^/]+)$|$1|;
    my $dirname = $filename;
    $filename = $ARCHIVEDIR . '/' . $filename;
    $dirname =~ s|\.tar\.gz$||;
    $dirname =~ s|\.tar\.bz2$||;

    chdir($SRCDIR);

    # Download and decompress
    unless ( -e $filename )
    {
        &Verbose("Downloading $sw");
        unless (&Syscall([ '/usr/bin/curl', '-f', '-L', $url, '>', $filename ],
                         'munge' => 1))
        {
            &Syscall([ '/bin/rm', $filename ]) if (-e $filename);
            die;
        }
    }
    else
    {   &Verbose("Using previously downloaded $sw")   }

    if ( $pkg->{'skip'} )
    {   next   }

    if ( -d $dirname )
    {
        if ( $OPT{'thirdclean'} )
        {
            &Verbose("Removing previous build of $sw");
            &Syscall([ '/bin/rm', '-f', '-r', $dirname ]) or die;
        }

        if ( $OPT{'thirdskip'} )
        {
            &Verbose("Using previous build of $sw");
            next;
        }

        &Verbose("Using previously unpacked $sw");
    }
    else
    {
        &Verbose("Unpacking $sw");
        if ( substr($filename,-3) eq ".gz" )
        {   &Syscall([ '/usr/bin/tar', '-xzf', $filename ]) or die   }
        elsif ( substr($filename,-4) eq ".bz2" )
        {   &Syscall([ '/usr/bin/tar', '-xjf', $filename ]) or die   }
        else
        {
            &Complain("Cannot unpack file $filename");
            exit;
        }
    }

    # Configure
    chdir($dirname);
    unless (-e '.osx-config')
    {
        &Verbose("Configuring $sw");
        if ( $pkg->{'pre-conf'} )
        {   &Syscall([ $pkg->{'pre-conf'} ], 'munge' => 1) or die   }

        my (@configure, $munge);

        my $arg = $pkg->{'arg-patches'};
        my $patches = $pkg->{'patches'};
        if ( $arg && $patches )
        {
            $arg        = `$arg`; chomp $arg;
            my $patch   = $patches->{$arg};
            if ( $patch )
            {
                &Syscall($patch);
            }
        }
        if ( $pkg->{'conf-cmd'} )
        {
            my $tmp = $pkg->{'conf-cmd'};
            push(@configure, $tmp);
            $munge = 1;
        }
        else
        {
            push(@configure, "./configure",
                       "--prefix=$PREFIX",
                       "--disable-static",
                       "--enable-shared");
            if ( $OPT{'universal'} )
            {
                push(@configure, "--disable-dependency-tracking");
            }
        }
        if ( $pkg->{'conf'} )
        {
            push(@configure, @{ $pkg->{'conf'} });
        }
        &Syscall(\@configure, 'interpolate' => 1, 'munge' => $munge) or die;
        if ( $pkg->{'post-conf'} )
        {
            &Syscall([ $pkg->{'post-conf'} ], 'munge' => 1) or die;
        }
        &Syscall([ '/usr/bin/touch', '.osx-config' ]) or die;
    }
    else
    {   &Verbose("Using previously configured $sw")   }

    # Build and install
    unless (-e '.osx-built')
    {
        &Verbose("Making $sw");
        my (@make);

        if ( $pkg->{'make-cmd' } )
        {
            push(@make, $pkg->{'make-cmd' });
        }
        else
        {
            push(@make, $standard_make);
            if ( $pkg->{'parallel-make'} && $parallel_make_flags )
            {   push(@make, $parallel_make_flags)   }
        }
        if ( $pkg->{'make'} )
        {   push(@make, @{ $pkg->{'make'} })   }
        else
        {   push(@make, 'all', 'install')   }

        &Syscall(\@make) or die;
        if ( $pkg->{'post-make'} )
        {
            &Syscall([ $pkg->{'post-make'} ], 'munge' => 1) or die;
        }
        &Syscall([ '/usr/bin/touch', '.osx-built' ]) or die;
    }
    else
    {
        &Verbose("Using previously built $sw");
    }
}

if ( $OPT{'bootstrap'} )
{
    exit;
}

#
# Work out Git branches, revisions and tags.
# Note these vars are unused if nohead or srcdir set!
#
my $gitrepository = 'git://github.com/MythTV/mythtv.git';
my $gitpackaging  = 'git://github.com/MythTV/packaging.git';

my $gitfetch  = 0;  # Synchronise cloned database copy before checkout?
my $gitpull   = 1;  # Cause a fast-forward
my $gitrevSHA = 0;
my $gitrevert = 0;  # Undo any local changes?

if ( $OPT{'gitrev'} )
{
    # This arg. could be '64d9d7c5...' (up to 40 hex digits),
    # a branch like 'mythtv-rec', 'nigelfixes' or 'master',
    # or a tag name like 'fixes/0.24'.
 
    $gitrevision = $OPT{'gitrev'};

    # If it is a hex revision, we checkout and don't pull mythtv src
    if ( $gitrevision =~ /^[0-9a-f]{7,40}$/ )
    {
        $gitrevSHA = 1;
        $gitfetch  = 1;  # Rev. might be newer than local cache
        $gitpull   = 0;  # Checkout creates "detached HEAD", git pull will fail
    }
}

# Retrieve source
if ( $OPT{'srcdir'} )
{
    chdir($SCRIPTDIR);
    &Syscall(['rm', '-fr', $GITDIR]);
    &Syscall(['mkdir', '-p', $GITDIR]);
    foreach my $dir ( @comps )
    {
        if ($dir eq 'packaging' && $OPT{'pkgsrcdir'})
        {
            &Syscall(['cp', '-pR', "$OPT{'pkgsrcdir'}", "$GITDIR/$dir"]);
        }
        else
        {
            &Syscall(['cp', '-pR', "$OPT{'srcdir'}/$dir", "$GITDIR/$dir"]);
        }
    }
    &Syscall("mkdir -p $GITDIR/mythtv/config")
}
elsif ( ! $OPT{'nohead'} )
{
    # Only do 'git clone' if mythtv directory does not exist.
    # Always do 'git checkout' to make sure we have the right branch,
    # then 'git pull' to get up to date.
    if ( ! -e $GITDIR )
    {
        Verbose("Checking out source code");
        &Syscall([ $git, 'clone', $gitrepository, $GITDIR ]) or die;
    }
    if ( ! -e "$GITDIR/packaging" )
    {
        Verbose("Checking out packaging code");
        &Syscall([ $git, 'clone',
                   $gitpackaging, $GITDIR . '/packaging' ]) or die;
    }

    my @gitcheckoutflags;

    if ( $gitrevert )
    {   @gitcheckoutflags = ( 'checkout', '--force', $gitrevision )   }
    else
    {   @gitcheckoutflags = ( 'checkout', '--merge', $gitrevision )   }


    chdir $GITDIR;
    if ( $gitfetch )   # Update Git DB
    {   &Syscall([ $git, 'fetch' ]) or die   }
    &Syscall([ $git, @gitcheckoutflags ]) or die;
    if ( $gitpull )    # Fast-forward
    {   &Syscall([ $git, 'pull' ]) or die   }

    chdir "$GITDIR/packaging";
    if ( $gitfetch )   # Update Git DB
    {   &Syscall([ $git, 'fetch' ]) or die   }
    if ( $gitrevSHA )
    {
        &Syscall([ $git, 'checkout', 'master' ]) or die;
        &Syscall([ $git, 'merge',    'master' ]) or die;
    }
    else
    {
        &Syscall([ $git, @gitcheckoutflags ]) or die;
        if ( $gitpull )   # Fast-forward
        {   &Syscall([ $git, 'pull' ]) or die   }
    }
}

# Make a convenience (non-hidden) directory for editing src code:
system("ln -sf $GITDIR $SCRIPTDIR/src");

if ( $OPT{'universal'} && ($OPT{'nodistclean'} || $OPT{'noclean'}) )
{
    &Complain("Cannot use noclean options when building universal packages");
    exit;
}

if ( ! $OPT{'nodistclean'} )
{
    if ( $OPT{'mythtvskip'} )
    {
        &Complain("Cannot skip building mythtv src if also cleaning, use -nodistclean");
        exit;
    }
    &Distclean(""); # Clean myth system installed libraries
}

foreach my $arch (@ARCHS)
{
    ### build MythTV
    &Verbose("Compiling for $arch architecture");
    
    # Clean any previously installed libraries
    if ( ! $OPT{'nodistclean'} )
    {
        &Verbose("Cleaning previous installs of MythTV for arch: $arch");
        &Distclean($arch);
    }

    $ENV{'CFLAGS'}    = "-arch $arch $CFLAGS";
    $ENV{'CXXFLAGS'}  = "-arch $arch $CXXFLAGS";
    $ENV{'CPPFLAGS'}  = "-arch $arch $CPPFLAGS";
    $ENV{'LDFLAGS'}   = "-arch $arch $LDFLAGS";
    $ENV{'ECXXFLAGS'} = "-arch $arch $ECXXFLAGS";

    # show summary of build parameters.
    &Verbose("CFLAGS = $ENV{'CFLAGS'}");
    &Verbose("LDFLAGS = $ENV{'LDFLAGS'}");

    # Build MythTV and any plugins
    foreach my $comp (@comps)
    {
        my $compdir = "$GITDIR/$comp/" ;

        chdir $compdir || die "No source directory $compdir";

        if ( ! -e "$comp.pro" and ! -e 'Makefile' and ! -e 'configure' )
        {
            &Complain("Nothing to configure/make in $compdir for $arch");
            next;
        }

        if ( ($OPT{'distclean'} || ! $OPT{'noclean'}) && -e 'Makefile' )
        {
            &Verbose("Cleaning $comp for $arch");
            &Syscall([ $standard_make, 'distclean' ]);
        }
        next if $OPT{'distclean'};

        # Apply any nasty mac-specific patches
        if ( $patches{$comp} )
        {
            &Syscall([ "echo '$patches{$comp}' | patch -p0 --forward" ]);
        }

        # configure and make
        if ( $makecleanopt{$comp} && -e 'Makefile' && ! $OPT{'noclean'} )
        {
            my @makecleancom = $standard_make;
            push(@makecleancom, @{ $makecleanopt{$comp} }) if $makecleanopt{$comp};
            &Syscall([ @makecleancom ]) or die;
        }
        
        if ( -e 'configure' && ! $OPT{'noclean'} )
        {
            &Verbose("Configuring $comp for $arch");
            my @config = './configure';
            push(@config, @{ $conf{$comp} }) if $conf{$comp};
            if ( $OPT{'universal'} )
            {
                push @config, "--prefix=$PREFIX/$arch";
            }
            else
            {
                push @config, "--prefix=$PREFIX";
            }
            push @config, "--cc=$CCBIN";
            push @config, "--cxx=$CXXBIN";
            push @config, "--qmake=$QTBIN/qmake";
            push @config, "--extra-libs=-F$QTLIB";

            if ( $comp eq "mythtv" )
            {
                # Test if configure supports --firewire-sdk option
                my $result = `./configure --help | grep -q firewire-sdk`;
                if ( $? == 0 )
                {
                    push @config, "--firewire-sdk=$PREFIX/lib";
                }
            }

            if ( $OPT{'profile'} )
            {
                push @config, '--compile-type=profile'
            }
            if ( $OPT{'debug'} )
            {
                push @config, '--compile-type=debug'
            }
            &Syscall([ @config ]) or die;
        }
        if ( (! -e 'configure') && -e "$comp.pro" && ! $OPT{'noclean'} )
        {
            &Verbose("Running qmake for $comp for $arch");
            my @qmake_opts = (
                "\"QMAKE_CC=$CCBIN\" \"QMAKE_CXX=$CXXBIN\" \"QMAKE_CXXFLAGS=$ENV{'CXXFLAGS'}\" \"QMAKE_CFLAGS=$ENV{'CFLAGS'}\" \"QMAKE_LFLAGS+=$ENV{'LDFLAGS'}\"",
                "INCLUDEPATH+=\"$PREFIX/include\"",
                "LIBS+=\"-F$QTLIB -L\"$PREFIX/lib\"",
                );
            &Syscall([ "$QTBIN/qmake",
                       'PREFIX=../Resources',
                       @qmake_opts,
                       "$comp.pro" ]) or die;
        }

        &Verbose("Making $comp for $arch");
        &Syscall([ $parallel_make ]) or die;

        &Verbose("Installing $comp for $arch");
        &Syscall([ $standard_make, 'install' ]) or die;

        if ( $cleanLibs && $comp eq 'mythtv' )
        {
            # If we cleaned the libs, make install will have recopied them,
            # which means any dynamic libraries that the static libraries depend on
            # are newer than the table of contents. Hence we need to regenerate it:
            my @mythlibs = glob "$PREFIX/lib/libmyth*.a";
            if ( scalar @mythlibs )
            {
                &Verbose("Running ranlib on reinstalled static libraries");
                foreach my $lib (@mythlibs)
                {   &Syscall("ranlib $lib") or die }
            }
        }
    }
}

if ( $OPT{'distclean'} )
{
    &Complain("Distclean done ..");
    exit;
}
&Complain("Compilation done ..");

if ( $OPT{'universal'} )
{
    ### Create universal binaries
    ### BIN files
    &MakeFilesUniversal("bin", $ARCHS[0], glob "$PREFIX/$ARCHS[0]/bin/*");
    ### Libs
    &MakeFilesUniversal("lib", $ARCHS[0], glob "$PREFIX/$ARCHS[0]/lib/*");

    &RecursiveCopy("$PREFIX/$ARCHS[0]/share", "$PREFIX");
    &RecursiveCopy("$PREFIX/$ARCHS[0]/include", "$PREFIX");
}

# stop here if no bundle is to be created
if ( $OPT{'nobundle'} )
{
    exit;
}

### Program which creates bundles:
our @bundler = "$GITDIR/packaging/OSX/build/osx-bundler.pl";
if ( $OPT{'verbose'} )
{   push @bundler, '-verbose'   }

# Strip unused architectures, this reduces the size quite significantly when linking against universal libs
if ( @ARCHS == 1)
{
    push @bundler, '-arch', $ARCHS[0];
}

# Determine version number
$GITVERSION = `cd $GITDIR && $git describe` ; chomp $GITVERSION;
if ( $? != 0)
{
    $GITVERSION = `find $PREFIX/lib -name 'libmyth-[0-9].[0-9][0-9].[0-9].dylib' | tail -1`;
    chomp $GITVERSION;
    $GITVERSION =~ s/^.*\-(.*)\.dylib$/$1/s;
}
push @bundler, '-longversion', $GITVERSION;
push @bundler, '-shortversion', $GITVERSION;

### Create each package.
### Note that this is a bit of a waste of disk space,
### because there are now multiple copies of each library.

if ( $jobtools )
{   push @targets, @targetsJT   }

if ( $backend )
{   push @targets, @targetsBE   }

my @libs = ( "$PREFIX/lib/", "$PREFIX/lib/mysql", "$QTLIB" );
foreach my $target ( @targets )
{
    my $finalTarget = "$SCRIPTDIR/$target.app";
    my $builtTarget = lc $target;

    # Get a fresh copy of the binary
    &Verbose("Building self-contained $target");
    &Syscall([ 'rm', '-fr', $finalTarget ]) or die;
    &Syscall([ 'cp',  "$PREFIX/bin/$builtTarget",
                      "$SCRIPTDIR/$target" ]) or die;

    # Convert it to a bundled .app
    &Syscall([ @bundler, "$SCRIPTDIR/$target", @libs ]) or die;

    # Remove copy of binary
    unlink "$SCRIPTDIR/$target" or die;

    # Themes are required by all GUI apps. The filters and plugins are not
    # used by mythtv-setup or mythwelcome, but for simplicity, do them all.
    if ( $target eq "MythFrontend" or
         $target eq "MythWelcome" or $target =~ m/^MythTV-/ )
    {
        my $res  = "$finalTarget/Contents/Resources";
        my $libs = "$res/lib";
        my $plug = "$libs/mythtv/plugins";

        # Install themes, filters, etc.
        &Verbose("Installing resources into $target");
        mkdir $res; mkdir $libs;
        &RecursiveCopy("$PREFIX/lib/mythtv", $libs);
        mkdir "$res/share";
        &RecursiveCopy("$PREFIX/share/mythtv", "$res/share");

        # Correct the library paths for the filters and plugins
        foreach my $lib ( glob "$libs/mythtv/*/*" )
        {   &Syscall([ @bundler, $lib, @libs ]) or die   }

        if ( -e $plug )
        {
            # Allow Finder's 'Get Info' to manage plugin list:
            &Syscall([ 'mv', $plug, "$finalTarget/Contents/$BundlePlugins" ]) or die;
            &Syscall([ 'ln', '-s', "../../../$BundlePlugins", $plug ]) or die;
        }

        # The icon
        &Syscall([ 'cp',
                   "$GITDIR/mythtv/programs/mythfrontend/mythfrontend.icns",
                   "$res/application.icns" ]) or die;
        &Syscall([ 'xcrun', '-sdk', "$SDKNAME", 'SetFile', '-a', 'C', $finalTarget ])
            or die;

        # Create PlugIns directory
        mkdir("$finalTarget/Contents/PlugIns");
        
        # Tell Qt to use the PlugIns for the Qt plugins
        open FH, ">$res/qt.conf";
        print FH "[Paths]\nPlugins = $BundlePlugins\n";
        close FH;
        
        if ( $OPT{'qtsrc'} && -d "$PREFIX/lib/qt_menu.nib" )
        {
            if ( -d "$finalTarget/Contents/Frameworks/QtGui.framework/Resources" )
            {
                &Syscall([ 'cp', '-R', "$PREFIX/lib/qt_menu.nib", "$finalTarget/Contents/Frameworks/QtGui.framework/Resources" ]);
            }
            else
            {
                &Syscall([ 'cp', '-R', "$PREFIX/lib/qt_menu.nib", "$finalTarget/Contents/Resources" ]);
            }
        }

        # Copy the required Qt plugins
        foreach my $plugin ( "imageformats" )
        {
            &Syscall([ 'mkdir', "$finalTarget/Contents/$BundlePlugins/$plugin" ]) or die;
            # Have to create links in application folder due to QTBUG-24541
            &Syscall([ 'ln', '-s', "../$BundlePlugins/$plugin", "$finalTarget/Contents/MacOs/$plugin" ]) or die;
        }
        
        foreach my $plugin ( 'imageformats/libqgif.dylib', 'imageformats/libqjpeg.dylib' )
        {
            my $pluginSrc = "$QTPLUGINS/$plugin";
            if ( -e $pluginSrc )
            {
                &Syscall([ 'cp', "$QTPLUGINS/$plugin",
                       "$finalTarget/Contents/$BundlePlugins/$plugin" ])
                    or die;
                &Syscall([ @bundler,
                       "$finalTarget/Contents/$BundlePlugins/$plugin", @libs ])
                    or die;
            }
        }

        # A font the Terra theme uses:
        my $url = $depend{'liberation-sans'}->{'url'};
        my $dirname = $url;
        $dirname =~ s|^.+/([^/]+)$|$1|;
        $dirname =~ s|\.tar\.gz$||;
        $dirname =~ s|\.tar\.bz2$||;

        my $fonts = "$res/share/mythtv/fonts";
        mkdir $fonts;
        &RecursiveCopy("$SRCDIR/$dirname/LiberationSans-Regular.ttf", $fonts);
        &EditPList("$finalTarget/Contents/Info.plist",
                   'ATSApplicationFontsPath', 'share/mythtv/fonts');
    }

    if ( $target eq "MythFrontend" )
    {
        my $extralib;

        foreach my $extra ( 'mythavtest', 'ignyte', 'mythpreviewgen', 'mtd' )
        {
            if ( -e "$PREFIX/bin/$extra" )
            {
                &Verbose("Installing $extra into $target");
                &Syscall([ 'cp', "$PREFIX/bin/$extra",
                           "$finalTarget/Contents/MacOS" ]) or die;

                &Verbose('Updating lib paths of',
                         "$finalTarget/Contents/MacOS/$extra");
                &Syscall([ @bundler, "$finalTarget/Contents/MacOS/$extra", @libs ])
                    or die;
            }
        }
        &AddFakeBinDir($finalTarget);

        # Allow playback of region encoded DVDs
        $extralib = "libdvdcss.2.dylib";
        &Syscall([ 'cp', "$PREFIX/lib/$extralib",
                         "$finalTarget/Contents/Frameworks" ]) or die;
        &Syscall([ @bundler, "$finalTarget/Contents/Frameworks/$extralib", @libs ])
            or die;
    }

    if ( $target eq "MythWelcome" )
    {
        &Verbose("Installing mythfrontend into $target");
        &Syscall([ 'cp', "$PREFIX/bin/mythfrontend",
                         "$finalTarget/Contents/MacOS" ]) or die;
        &Syscall([ @bundler, "$finalTarget/Contents/MacOS/mythfrontend", @libs ])
            or die;
        &AddFakeBinDir($finalTarget);

        # For some unknown reason, mythfrontend looks here for support files:
        &Syscall([ 'ln', '-s', "../Resources/share",   # themes
                               "../Resources/lib",     # filters/plugins
                   "$finalTarget/Contents/MacOS" ]) or die;
    }

    # Copy the required Qt plugins
    foreach my $plugin ( "sqldrivers" )
    {
        &Syscall([ 'mkdir', "-p", "$finalTarget/Contents/$BundlePlugins/$plugin" ]) or die;
        # Have to create links in application folder due to QTBUG-24541
        &Syscall([ 'ln', '-s', "../$BundlePlugins/$plugin", "$finalTarget/Contents/MacOs/$plugin" ]) or die;
    }

    # copy the MySQL sqldriver
    &Syscall([ 'cp', "$PREFIX/qtplugins-$QTVERSION/libqsqlmysql.dylib", "$finalTarget/Contents/$BundlePlugins/sqldrivers/" ])
    or die;
    &Syscall([ @bundler, "$finalTarget/Contents/$BundlePlugins/sqldrivers/libqsqlmysql.dylib", @libs ])
    or die;

    # rebase segfault on my mac, so disable it for the time being
    # Run 'rebase' on all the frameworks, for slightly faster loading.
    # Note that we process the real library, not symlinks to it,
    # to prevent rebase erroneously creating copies:
    #my @libs = glob "$finalTarget/Contents/Frameworks/*";
    #@libs = grep(s,(.*/)(\w+).framework$,$1$2.framework/Versions/A/$2, , @libs);

    # Also process all the filters/plugins:
    #push(@libs, glob "$finalTarget/Contents/Resources/lib/mythtv/*/*.dylib");
    #push(@libs, glob "$finalTarget/Contents/PlugIns/*/*.dylib");

    #if ( $OPT{'verbose'} )
    #{   &Syscall([ 'rebase', '-v', @libs ]) or die   }
    #else
    #{   &Syscall([ 'rebase', @libs ]) or die   }

}

if ( $backend && grep(m/MythBackend/, @targets) )
{
    my $BE = "$SCRIPTDIR/MythBackend.app";

    # Copy XML files that UPnP requires:
    my $share = "$BE/Contents/Resources/share/mythtv";
    &Syscall([ 'mkdir', '-p', $share ]) or die;
    &Syscall([ 'cp', glob("$PREFIX/share/mythtv/*.xml"), $share ]) or die;

    # Same for default web server page:
    &Syscall([ 'cp', '-pR', "$PREFIX/share/mythtv/html", $share ]) or die;

    # The backend gets all the useful binaries it might call:
    foreach my $binary ( 'mythjobqueue', 'mythcommflag',
                         'mythpreviewgen', 'mythtranscode', 'mythfilldatabase' )
    {
        my $SRC  = "$PREFIX/bin/$binary";
        if ( -e $SRC )
        {
            &Verbose("Installing $SRC into $BE");
            &Syscall([ '/bin/cp', $SRC, "$BE/Contents/MacOS" ]) or die;

            &Verbose("Updating lib paths of $BE/Contents/MacOS/$binary");
            &Syscall([ @bundler, "$BE/Contents/MacOS/$binary", @libs ]) or die;
        }
    }
    &AddFakeBinDir($BE);
}

if ( $backend && grep(m/MythTV-Setup/, @targets) )
{
    my $SET = "$SCRIPTDIR/MythTV-Setup.app";
    my $SRC  = "$PREFIX/bin/mythfilldatabase";
    if ( -e $SRC )
    {
        &Verbose("Installing $SRC into $SET");
        &Syscall([ '/bin/cp', $SRC, "$SET/Contents/MacOS" ]) or die;

        &Verbose("Updating lib paths of $SET/Contents/MacOS/mythfilldatabase");
        &Syscall([ @bundler, "$SET/Contents/MacOS/mythfilldatabase", @libs ]) or die;
    }
    &AddFakeBinDir($SET);
}

if ( $jobtools )
{
    # JobQueue also gets some binaries it might call:
    my $JQ   = "$SCRIPTDIR/MythJobQueue.app";
    my $DEST = "$JQ/Contents/MacOS";
    my $SRC  = "$PREFIX/bin/mythcommflag";

    &Syscall([ '/bin/cp', $SRC, $DEST ]) or die;
    &AddFakeBinDir($JQ);
    &Verbose("Updating lib paths of $DEST/mythcommflag");
    &Syscall([ @bundler, "$DEST/mythcommflag", @libs ]) or die;

    $SRC  = "$PREFIX/bin/mythtranscode.app/Contents/MacOS/mythtranscode";
    if ( -e $SRC )
    {
        &Verbose("Installing $SRC into $JQ");
        &Syscall([ '/bin/cp', $SRC, $DEST ]) or die;
        &Verbose("Updating lib paths of $DEST/mythtranscode");
        &Syscall([ @bundler, "$DEST/mythtranscode", @libs ]) or die;
    }
}

# Clean tmp files. Most of these are leftovers from configure:
#
&Verbose('Cleaning build tmp directory');
&Syscall([ 'rm', '-fr', $WORKDIR . '/tmp' ]) or die;
&Syscall([ 'mkdir',     $WORKDIR . '/tmp' ]) or die;

if ($OPT{usehdimage} && !$OPT{leavehdimage} )
{
    Verbose("Dismounting case-sensitive build device");
    UnmountHDImage();
}

&Verbose("Build complete. Self-contained package is at:\n\n    $MFE\n");

### end script
exit 0;


######################################
## RecursiveCopy copies a directory tree, stripping out .git
## directories and properly managing static libraries.
######################################

sub RecursiveCopy($$)
{
    my ($src, $dst) = @_;

    # First copy absolutely everything
    &Syscall([ '/bin/cp', '-pR', "$src", "$dst"]) or die;

    # Then strip out any .git directories
    my @files = map { chomp $_; $_ } `find $dst -name .git`;
    if ( scalar @files )
    {
        &Syscall([ '/bin/rm', '-f', '-r', @files ]);
    }

    # And make sure any static libraries are properly relocated.
    my @libs = map { chomp $_; $_ } `find $dst -name "lib*.a"`;
    if ( scalar @libs )
    {
        &Syscall([ 'ranlib', '-s', @libs ]);
    }
}

######################################
## CleanMakefiles removes every generated Makefile
## from our MythTV build that contains PREFIX.
## Necessary when we change the
## PREFIX variable.
######################################

sub CleanMakefiles
{
    &Verbose("Cleaning MythTV makefiles containing PREFIX");
    &Syscall([ 'find', '.', '-name', 'Makefile', '-exec',
               'egrep', '-q', 'qmake.*PREFIX', '{}', ';', '-delete' ]) or die;
} # end CleanMakefiles


######################################
## Syscall wrappers the Perl "system"
## routine with verbosity and error
## checking.
######################################

sub Syscall($%)
{
    my ($arglist, %opts) = @_;

    unless (ref $arglist)
    {
        $arglist = [ $arglist ];
    }
    if ( $opts{'interpolate'} )
    {
        my @args;
        foreach my $arg (@$arglist)
        {
            $arg =~ s/\$PREFIX/$PREFIX/ge;
            $arg =~ s/\$SDKROOT/$SDKROOT/ge;
            $arg =~ s/\$CFLAGS/$ENV{'CFLAGS'};/ge;
            $arg =~ s/\$LDFLAGS/$ENV{'LDFLAGS'};/ge;
            $arg =~ s/\$parallel_make_flags/$parallel_make_flags/ge;
            push(@args, $arg);
        }
        $arglist = \@args;
    }
    if ( $opts{'munge'} )
    {
        $arglist = [ join(' ', @$arglist) ];
    }
    # clean out any null arguments
    $arglist = [ map $_, @$arglist ];
    &Verbose(@$arglist);
    my $ret = system(@$arglist);
    if ( $ret )
    {
        &Complain('Failed system call: "', @$arglist,
                  '" with error code', $ret >> 8);
    }
    return ($ret == 0);
} # end Syscall


######################################
## Verbose prints messages in verbose
## mode.
######################################

sub Verbose
{
    print STDERR '[osx-pkg] ' . join(' ', @_) . "\n"
        if $OPT{'verbose'};
} # end Verbose


######################################
## Complain prints messages in any
## verbosity mode.
######################################

sub Complain
{
    print STDERR '[osx-pkg] ' . join(' ', @_) . "\n";
} # end Complain


######################################
## Manage usehdimage disk image
######################################

sub MountHDImage
{
    if ( ! HDImageDevice() )
    {
        if ( -e "$SCRIPTDIR/.osx-packager.dmg" )
        {
            Verbose("Mounting existing UFS disk image for the build");
        }
        else
        {
            Verbose("Creating a case-sensitive (UFS) disk image for the build");
            Syscall(['hdiutil', 'create', '-size', '2048m',
                     "$SCRIPTDIR/.osx-packager.dmg", '-volname',
                     'MythTvPackagerHDImage', '-fs', 'UFS', '-quiet']) || die;
        }

        &Syscall(['hdiutil', 'mount',
                  "$SCRIPTDIR/.osx-packager.dmg",
                  '-mountpoint', $WORKDIR, '-quiet']) || die;
    }

    # configure defaults to /tmp and OSX barfs when mv crosses
    # filesystems so tell configure to put temp files on the image

    $ENV{TMPDIR} = $WORKDIR . "/tmp";
    mkdir $ENV{TMPDIR};
}

sub UnmountHDImage
{
    my $device = HDImageDevice();
    if ( $device )
    {
        &Syscall(['hdiutil', 'detach', $device, '-force']);
    }
}

sub HDImageDevice
{
    my @dev = split ' ', `/sbin/mount | grep $WORKDIR`;
    $dev[0];
}

sub CaseSensitiveFilesystem
{
    my $funky = $SCRIPTDIR . "/.osx-packager.FunkyStuff";
    my $unfunky = substr($funky, 0, -10) . "FUNKySTuFF";

    unlink $funky if -e $funky;
    `touch $funky`;
    my $sensitivity = ! -e $unfunky;
    unlink $funky;

    return $sensitivity;
}


#######################################################
## Parts of MythTV try to call helper apps like this:
## gContext->GetInstallPrefix() + "/bin/mythtranscode";
## which means we need a bin directory.
#######################################################

sub AddFakeBinDir($)
{
    my ($target) = @_;

    &Syscall("mkdir -p $target/Contents/Resources");
    &Syscall(['ln', '-sf', '../MacOS', "$target/Contents/Resources/bin"]);
}

###################################################################
## Update or add <dict> properties in a (non-binary) .plist file ##
###################################################################

sub EditPList($$$)
{
    my ($file, $key, $value) = @_;

    &Verbose("Looking for property $key in file $file");

    open(IN,  $file)         or die;
    open(OUT, ">$file.edit") or die;
    while ( <IN> )
    {
        if ( m,\s<key>$key</key>, )
        {
            <IN>;
            &Verbose("Value was $_");  # Does this work?
            print OUT "<key>$key</key>\n<string>$value</string>\n";
            next;
        }
        elsif ( m,^</dict>$, )  # Not there. Add at end
        {
            print OUT "<key>$key</key>\n<string>$value</string>\n";
            print OUT "</dict>\n</plist>\n";
            last;
        }

        print OUT;
    }
    close IN; close OUT;
    rename("$file.edit", $file);
}

sub Distclean
{
    my $arch = $_[0];
    if ( $arch ne "" )
    {
        $arch .= "/";
    }
    &Syscall("/bin/rm -f $PREFIX/${arch}include/mythtv");
    &Syscall("/bin/rm -f $PREFIX/${arch}bin/myth*"     );
    &Syscall("/bin/rm -fr $PREFIX/${arch}lib/libmyth*" );
    &Syscall("/bin/rm -fr $PREFIX/${arch}lib/mythtv"   );
    &Syscall("/bin/rm -fr $PREFIX/${arch}share/mythtv" );
    &Syscall("/bin/rm -fr $PREFIX/${arch}share/mythtv" );
    &Syscall([ 'find', "$GITDIR/", '-name', '*.o',     '-delete' ]);
    &Syscall([ 'find', "$GITDIR/", '-name', '*.a',     '-delete' ]);
    &Syscall([ 'find', "$GITDIR/", '-name', '*.dylib', '-delete' ]);
    &Syscall([ 'find', "$GITDIR/", '-name', '*.orig',  '-delete' ]);
    &Syscall([ 'find', "$GITDIR/", '-name', '*.rej',   '-delete' ]);
}

#########################################################################
## Go through the list of files recursively and combine all architectures
## together to form a "fat" universal file
#########################################################################

sub MakeFilesUniversal($@)
{
    my ($base, $archbase, @files) = @_;
    if ( ! -d "$PREFIX/$base" )
    {
        &Syscall([ '/bin/mkdir', "$PREFIX/$base" ]);
    }
    for my $bin (@files)
    {
        my @lipo = "/usr/bin/lipo";
        my $name = basename($bin);
        if ( -l $bin || -f $bin )
        {
            # destination file exists, remove it
            &Syscall([ '/bin/rm', "$PREFIX/$base/$name" ] );
        }
        if ( -l $bin )
        {
            # copy link as is
            &Syscall([ '/bin/cp', '-R',
                "$PREFIX/$archbase/$base/$name",
                "$PREFIX/$base/$name" ]);
        }
        elsif ( -f $bin )
        {
            &Verbose("ARCHS = @ARCHS");
            for my $arch (@ARCHS)
            {
                push @lipo, "$PREFIX/$arch/$base/$name";
            }
            push @lipo, "-create", "-output", "$PREFIX/$base/$name";
            &Syscall([ @lipo ]);
        }
        elsif ( -d $bin )
        {
            &MakeFilesUniversal("$base/$name", $archbase, glob "$PREFIX/$archbase/$base/$name/*")
        }
    }
}
### end file
1;
