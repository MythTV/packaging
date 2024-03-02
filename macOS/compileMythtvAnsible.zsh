#!/bin/zsh

show_help(){
    cat <<EOF
Usage: compileMythtvAnsible.sh [options]
Options: [defaults in brackets after descriptions]

Standard options:
  --help                                 Print this help message
  --build-plugins=BUILD_PLUGINS          Build Mythtv Plugins (false)
  --python-version=PYTHON_VERS           Desired Python 3 Version (${2})
                                           Example: ${2}
  --version=MYTHTV_VERS                  Requested mythtv git repo (${1})
                                           Example: master for the latest master
                                                    fixes/34 for version 34
  --database-version=DATABASE_VERS       Requested version of mariadb/mysql to build agains (${3})
  --qt-version=qt5                       Select Qt version to build against (${4})
                                           Example: qt5 for qt5
                                                    qt6 for qt6
  --repo-prefix=REPO_PREFIX              Directory base to install the working repository (~)
  --generate-app=GENERATE_APP            Generate Applicaiton Bundles for executables (true)
                                         Currently, setting this to true only builds a working
                                         MythFrontend.app.  If building for unix-style executables, 
                                         set this to false.
  --custom-install-dir=INSTALL_DIR       Directory to copy the compiled executables and support files. ("")
                                           When generating app bundles (i.e. --generate-app=false),
                                           this defaults to the build directory.
                                           When building executables (i.e. --generate-app=false),
                                           this defaults to the either MacPors or Homebrews

Build Options
  --update-git=UPDATE_GIT                Update git repositories to latest (true)
                                         This is only used when the source has already been cloned via 
                                         git and you do not want to pull any updates from the master repo
  --skip-build=SKIP_BUILD                Skip configure and make
                                         This is used when you just want to repackage (false)
  --skip-ansible=SKIP_ANSIBLE            Skip ansible install (false)
                                         This avoids re-running ansible and should only be used
                                         if all packages have been correctly installed.
  --alt-compiler=ALT_COMPILER            Flag to specify compiler version to build with (clang)
                                         Use the format compiler-PackMgr-VersionNumber to
                                         specify customer compilers
                                           Example: clang for deafult Xcode/Commandline tools compiler
                                                    gcc-mp-13 For gcc 13 on MacPorts
                                                    gcc-hb-13 for gcc 13 on Hobebrew
                                                    clang-mp-17 for clang/llvm 17 on MacPorts
                                                    clang-hb-17 for clang/llvm 17 on Homebrew
  --extra-conf-flags=EXTRA_CONF_FLAGS    Addtional configure flags for mythtv ("")

Patch Options
  --apply-patches=APPLY_PATCHES          Apply patches specified in additional arguments (false)
  --mythtv-patch-dir=MYTHTV_PATCH_DIR    Directory containing patch files to be applied to Mythtv
  --plugins-patch-dir=PLUGINS_PATCH_DR   Directory containing patch files to be applied to Mythplugins

Support Ports Options
  --update-pkgmgr=UPDATE_PKGMGR          Update macports (false)

EOF

  exit 0
}

echoC(){
  MESSAGE=${1}
  COLOR=${2}
  COLOR=${COLOR:u}
  if [ ! -d $COLOR ]; then
    END_CODE='\033[m'
    case $COLOR in
    ### echo color codes
    RED)
      CODE='\033[0;31m'
    ;;
    ORANGE)
      CODE='\033[0;33m'
    ;;
    YELLOW)
      CODE='\033[1;33m'
    ;;
    GREEN)
      CODE='\033[0;32m'
    ;;
    BLUE)
      CODE='\033[0;34m'
    ;;
    CYAN)
      CODE='\033[0;36m'
    ;;
    esac
    echo -e $CODE"$MESSAGE"$END_CODE
  else
    echo $MESSAGE
  fi
}

### Note - macports or homebrew must be installed on your system for this script to work!!!!!
if [ -x "$(command -v port)" ]; then
  PKGMGR='macports'
elif [ -x "$(command -v brew)" ]; then
  PKGMGR='homebrew'
else
  echoC 'Error Neither macports or homebrew are present. Exiting...' RED
  exit 1
fi

###########################################################################################
### OS Specific Variables #################################################################
###########################################################################################
# setup OS / Architecture specific variables
OS_VERS=$(/usr/bin/sw_vers -productVersion)
OS_VERS_PARTS=(${(@s:.:)OS_VERS})
OS_MINOR=${OS_VERS_PARTS[2]}
OS_MAJOR=${OS_VERS_PARTS[1]}
OS_ARCH=$(/usr/bin/arch)

###########################################################################################
### Input Parsing #########################################################################
###########################################################################################
# setup default variables
BUILD_PLUGINS=false
UPDATE_PKGMGR=false
MYTHTV_VERS="master"
MYTHTV_PYTHON_SCRIPT="ttvdb4"
GENERATE_APP=true
INSTALL_DIR=""
UPDATE_GIT=true
SKIP_BUILD=false
ALT_COMPILER=clang
EXTRA_CONF_FLAGS=""
EXTRA_MYTHPLUGIN_FLAGS=""
SKIP_ANSIBLE=false
APPLY_PATCHES=false
MYTHTV_PATCH_DIR=""
PLUGINS_PATCH_DIR=""
REPO_PREFIX=$HOME

# macports / homebrew have different naming conventions
# for mysql, python, and qt
case $PKGMGR in
  macports)
    DATABASE_VERS=mysql8
    PYTHON_VERS="311"
    QT_VERS=qt5
  ;;
  homebrew)
    DATABASE_VERS=mysql@8.0
    PYTHON_VERS="312"
    QT_VERS=qt@5
  ;;
esac

# macports doesn't support mysql 8 for older versions of macOS, for those installs default to mariadb (unless the user overries)
# also, homebrew drops the version numbers...
if [ "$OS_MAJOR" -le 11 ] && [ "$OS_MINOR" -le 15 ]; then
  case $PKGMGR in
    macports)
      DATABASE_VERS=mariadb-10.5
    ;;
    homebrew)
      DATABASE_VERS=mariadb
    ;;
  esac
fi

# force expansion of magic substrings
set -o magicequalsubst

# parse user inputs into variables
for i in "$@"; do
  case $i in
      -h|--help)
        show_help "${MYTHTV_VERS}" "${PYTHON_VERS}" "${MYTHTV_VERS}" "${QT_VERS}"
        exit 0
      ;;
      --build-plugins=*)
        BUILD_PLUGINS="${i#*=}"
      ;;
      --python-version=*)
        PYTHON_VERS="${i#*=}"
      ;;
      --update-pkgmgr=*)
        UPDATE_PKGMGR="${i#*=}"
      ;;
      --skip-build=*)
        SKIP_BUILD="${i#*=}"
      ;;
      --alt-compiler=*)
        ALT_COMPILER="${i#*=}"
      ;;
      --extra-conf-flags=*)
        EXTRA_CONF_FLAGS="${i#*=}"
      ;;
      --skip-ansible=*)
        SKIP_ANSIBLE="${i#*=}"
      ;;
      --version=*)
        MYTHTV_VERS="${i#*=}"
      ;;
      --database-version=*)
        DATABASE_VERS="${i#*=}"
      ;;
      --qt-version=*)
        QT_VERS="${i#*=}"
      ;;
      --repo-prefix=*)
        REPO_PREFIX="${i#*=}"
      ;;
      --generate-app=*)
        GENERATE_APP="${i#*=}"
      ;;
      --custom-install-dir=*)
        INSTALL_DIR="${i#*=}"
      ;;
      --update-git*)
        UPDATE_GIT="${i#*=}"
      ;;
      --apply-patches=*)
        APPLY_PATCHES="${i#*=}"
      ;;
      --mythtv-patch-dir=*)
        MYTHTV_PATCH_DIR="${i#*=}"
      ;;
      --plugins-patch-dir=*)
        PLUGINS_PATCH_DIR="${i#*=}"
      ;;
      *)
        echo -e 'Unknown or incomplete option '"\033[31m"$i"\033[m"
              # unknown option
        exit 1
      ;;
  esac
done

# Remove any magic substrings
if [ ! -z $REPO_PREFIX ]; then
  eval "REPO_PREFIX=$REPO_PREFIX"
fi
if [ ! -z $INSTALL_DIR ]; then
  eval "INSTALL_DIR=$INSTALL_DIR"
fi

echoC '****************************************************************************' CYAN
echoC "***** Setting $PKGMGR for package installation ****************************" CYAN
echoC '****************************************************************************' CYAN

echoC "------------ Setting Up Build Variables ------------" GREEN
###########################################################################################
### MythTV Specific Variables #############################################################
###########################################################################################
# Handle any version specific parsing and flags
case $MYTHTV_VERS in
    # this condition covers the current master
    master*)
      # if we're building on master - get release number from the git tags
      VERS=$(git ls-remote --tags  https://github.com/MythTV/mythtv.git|tail -n 1)
      VERS=${VERS##*/v}
      VERS=$(echo "$VERS"|tr -dc '0-9')
      EXTRA_CONF_FLAGS="$EXTRA_CONF_FLAGS --disable-qtwebkit --disable-qtscript"
    ;;
    # this condition covers supported versions prior to v33 where the fftw was removed
    *32*|*31*)
      VERS=${MYTHTV_VERS: -2}
      EXTRA_MYTHPLUGIN_FLAGS="$EXTRA_CONF_FLAGS --enable-fftw"
    ;;
    *33)
      VERS=${MYTHTV_VERS: -2}
    ;;
    # this condition covers v34 and later
    *)
      VERS=${MYTHTV_VERS: -2}
      EXTRA_CONF_FLAGS="$EXTRA_CONF_FLAGS --disable-qtwebkit --disable-qtscript"
      INSTALL_WEBKIT=false
esac

###########################################################################################
### PKGMGR Specific Variables #############################################################
###########################################################################################
PYTHON_DOT_VERS="${PYTHON_VERS:0:1}.${PYTHON_VERS:1:4}"
PYTHON_CMD="python$PYTHON_DOT_VERS"
case $PKGMGR in
  macports)
    PKGMGR_INST_PATH=$(dirname $(dirname $(which port)))
    PKGMGR_ALT_PATH="$PKGMGR_INST_PATH/libexec"
    PKGMGR_BIN="$PKGMGR_INST_PATH/bin"
    PKGMGR_INC="$PKGMGR_INST_PATH/include"
    PKGMGR_LIB="$PKGMGR_INST_PATH/lib"
    ANSIBLE_PB_EXE="$PKGMGR_BIN/ansible-playbook-$PYTHON_DOT_VERS"
    FONT_PATH="$PKGMGR_INST_PATH/share/fonts"
    # Select the correct QT version of tools / libraries
    HDHR_INC_PATH="$PKGMGR_INC/libhdhomerun"
    #set as null since its on the default macports location 
    HDHR_LIB_PATH=""
    INSTALL_WEBKIT=true
  ;;
  homebrew)
    PKGMGR_INST_PATH=$(brew --prefix)
    PKGMGR_ALT_PATH="$PKGMGR_INST_PATH/opt"
    PKGMGR_BIN="$PKGMGR_INST_PATH/bin"
    PKGMGR_INC="$PKGMGR_INST_PATH/include"
    PKGMGR_LIB="$PKGMGR_INST_PATH/lib"
    ANSIBLE_PB_EXE="$PKGMGR_BIN/ansible-playbook"
    FONT_PATH="$HOME/Library/Fonts"
    HDHR_INC_PATH="$PKGMGR_ALT_PATH/libhdhomerun/include"
    HDHR_LIB_PATH="$PKGMGR_ALT_PATH/libhdhomerun/lib"
    INSTALL_WEBKIT=false
    # Special handling for hdhomerun on arm where the internal dylib path is setup
    # to point to an incorrectly named dylib
    case $OS_ARCH in
      arm64)
        HDHR_ARM=$HDHR_LIB_PATH/libhdhomerun_arm64.dylib
        if [ ! -f $HDHR_ARM ]; then
          cp -Hnp $HDHR_LIB_PATH/libhdhomerun.dylib $HDHR_ARM
          chmod ug+w $HDHR_ARM
        fi
      ;;
    esac
  ;;
esac
if ! $BUILD_PLUGINS; then
  INSTALL_WEBKIT=false
fi
export PATH=$PKGMGR_LIB/$DATABASE_VERS/bin:$PATH
BLURAY_INC_PATH="$PKGMGR_INC/libbluray"

###########################################################################################
### Setup QT Specific Parameters ##########################################################
###########################################################################################
case $PKGMGR in
  homebrew)
    QT_VERS="qt@${QT_VERS: -1}"
  ;;
esac
QT_PATH="$PKGMGR_ALT_PATH/$QT_VERS"
QT_INC_PATH="$QT_PATH/include"
QT_LIB_PATH="$QT_PATH/lib"
QT_PLUGINS_PATH="$QT_PATH/plugins"
QT_SQL_PATH="$QT_PLUGINS_PATH/sqldrivers"
# Setup QT variables (QT_PATH should handle both qt version and PKGMGR paths)
QMAKE_CMD=$QT_PATH/bin/qmake
QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
ANSIBLE_QT=mythtv.yml
MACDEPLOYQT_CMD=$QT_PATH/bin/macdeployqt
# if we're running qt6, disable plugins
case $QT_VERS in
    qt6|qt@6)
       echoC '    Building with Qt6 - disabling plugins' BLUE
       BUILD_PLUGINS=false
    ;;
esac

###########################################################################################
### Build Output Variables ################################################################
###########################################################################################
# Setup version specific working path
REPO_DIR=$REPO_PREFIX/mythtv-$VERS
echo $REPO_DIR
# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins

# Setup app build outputs and lib linking
if $GENERATE_APP; then
  ENABLE_MAC_BUNDLE="--enable-mac-bundle"
  if [ -z $INSTALL_DIR ]; then
    INSTALL_DIR="$REPO_DIR/$VERS-osx-64bit"
  fi
  RUNPREFIX=../Resources
else
  ENABLE_MAC_BUNDLE=""
  if [ -z $INSTALL_DIR ]; then
    INSTALL_DIR=$PKGMGR_INST_PATH
  fi
  RUNPREFIX=$INSTALL_DIR
fi

echoC "    Installing Build Outputs to $INSTALL_DIR" BLUE

###########################################################################################
### Setup Python Specific variables #######################################################
###########################################################################################
# Setup Initial Python variables and dependencies for port / ansible installation
PYTHON_PKMGR_BIN="$PKGMGR_BIN/$PYTHON_CMD"
PYTHON_VENV_PATH="$HOME/.mythtv/python-virtualenv"
PY2APP_PKGS="MySQLdb,pycurl,requests_cache,urllib3,future,lxml,oauthlib,requests,simplejson,\
  audiofile,bs4,argparse,common,configparser,datetime,discid,et,features,HTMLParser,httplib2,\
  musicbrainzngs,traceback2,dateutil,importlib_metadata"
PY2APP_EXLCUDE="soundfile"
# Add flags to allow pip3 / python to find mysql8
case $PKGMGR in
  macports)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_LIB/$DATABASE_VERS/pkgconfig/
  ;;
  homebrew)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_LIB/opt/$DATABASE_VERS/lib/pkgconfig/
  ;;
esac

###########################################################################################
### Setup Compiler and Related Search Paths ###############################################
###########################################################################################
# First verify that the SDK is setup and command line tools license has been accepted
export SDK_ROOT=$(xcrun --sdk macosx --show-sdk-path)
export SDK_VERS=$(xcrun --sdk macosx --show-sdk-version)
if [ ! -n  $SDK_ROOT ]; then
  echoC "Error: macOS SDK is not set!!!" RED
  echoC "To set the SDK, you must accept the Xcode Developer Tool License."
  echoC "To accept the license, run the following command."
  echoC "Per Apple licensing, sudo privledges are required."
  echoC "     sudo xcodebuild -license" GREEN
  exit 1
fi

if [ ${SDK_VERS%%.*} -ge 14 ]; then 
    COMP_LDFLAGS="-Wl,-ld_classic" 
fi

# Set COMP_LDFLAGS and COMP_INC to null since we only need to add paths for custom compilers
# Check if the user specifed a compiler
case $ALT_COMPILER in
    *mp*)
      # macports specific case
      if [ ! $PKGMGR = "macports" ]; then
        echoC 'Error: You requested a MacPorts compiler on Homebrew.  Exiting!' RED
        exit 1
      fi

      # macports kindly labels all of their alternative compilers as compilerName-mp-compilerVersion,
      # for macport, we need the version string
      COMP_NAME=${ALT_COMPILER%%-*}
      COMP_VERS=${ALT_COMPILER##*-}

      # Setup the path to the requested c/cpp compilers
      # as well as assemble the port name in case it's not
      # installed
      C_CMD="$PKGMGR_BIN/$ALT_COMPILER"
      case $COMP_NAME in
        clang*)
          COMP_PATH="$PKGMGR_ALT_PATH/llvm-$COMP_VERS"
          CPP_CMD="$PKGMGR_BIN/clang++-mp-$COMP_VERS"
          COMP_PORT="clang-$COMP_VERS"
          COMP_LDFLAGS="-L$COMP_PATH/lib -Wl,-rpath,$COMP_PATH/lib"
          COMP_INC="$COMP_PATH/include"
          export PATH="$COMP_PATH/bin:$COMP_PATH/libexec:$PATH"
        ;;
        gcc*)
          COMP_PATH="$PKGMGR_ALT_PATH/gcc$COMP_VERS"
          CPP_CMD="$PKGMGR_BIN/g++-mp-$COMP_VERS"
          COMP_PORT="gcc$COMP_VERS"
          COMP_LDFLAGS="-L$COMP_PATH/lib/$COMP_PORT"
          COMP_INC="$PKGMGR_INC/$COMP_PORT:$PKGMGR_INC/$COMP_PORT/c++"
        ;;
      esac
      # check if specified compiler is installed
      if [ ! -d "$COMP_PATH" ]; then
        echoC '    Macports: Installing missing compiler: COMP_PORT' ORANGE
        sudo port -N install "$COMP_PORT"
      fi

      echoC "    Compiling with custom compiler: $ALT_COMPILER" BLUE
    ;;
    *hb*)
      # homebrew specific case
      if [ ! $PKGMGR = "homebrew" ]; then
        echoC 'Error: You requested a Homebrew compiler on MacPorts.  Exiting!' RED
        exit 1
      fi

      # homebrew stashes all of the compilers in their own directory in the $PKGMGR_INST_PATH
      # to use them, we'll need the compile name and version string
      COMP_NAME=${ALT_COMPILER%%-*}
      COMP_VERS=${ALT_COMPILER##*-}

      # Setup the path to the requested c/cpp compilers  as well as assemble the recipe name
      # in case it's not installed
      case $COMP_NAME in
        clang*)
          COMP_PATH="$(realpath "$PKGMGR_ALT_PATH/llvm@$COMP_VERS")"
          COMP_RCP="llvm@$COMP_VERS"
          COMP_BIN="$COMP_PATH/bin"
          C_CMD="$COMP_BIN/clang"
          CPP_CMD="$COMP_BIN/clang++"
          COMP_LIB_PATH="$COMP_PATH/lib/"
          COMP_INC_PATH="$COMP_PATH/include"
          COMP_LDFLAGS="-L$COMP_LIB_PATH/c++ -Wl,-rpath,$COMP_LIB_PATH/c++"
          COMP_INC="$COMP_INC_PATH:$COMP_INC_PATH/c++:$COMP_INC_PATH/c++/v1"
        ;;
        gcc*)
          COMP_PATH="$(realpath "$PKGMGR_ALT_PATH/gcc@$COMP_VERS")"
          COMP_RCP="gcc@$COMP_VERS"
          COMP_BIN="$COMP_PATH/bin"
          C_CMD="$COMP_BIN/gcc-$COMP_VERS"
          CPP_CMD="$COMP_BIN/g++-$COMP_VERS"
          COMP_LIB_PATH="$COMP_PATH/lib/gcc/$COMP_VERS"
          COMP_INC="$COMP_PATH/include/c++/$COMP_VERS"
        ;;
      esac

      # check is specified compiler is installed
      if [ ! -d "$COMP_PATH" ]; then
        echoC "    Homebrew: Installing missing compiler: $COMP_RCP" ORANGE
        brew install "$COMP_RCP"
      fi

      # Update the path to use the compiler's executables
      #export PATH="$COMP_PATH/bin:$PATH"

      echoC "    Compiling with custom compiler: $ALT_COMPILER" ORANGE
    ;;
    gcc)
      C_CMD="gcc"
      CPP_CMD="g++"
    ;;
    clang|default)
      C_CMD="clang"
      CPP_CMD="clang++"
    ;;
    *)
      echoC 'Error: unkown compiler specified.  Exiting!' RED
      exit 1
    ;;
esac

# There's a conflice with FFMPEG and mythtv at least on macports.  Force mythtv's version to the front of the 
# include search path
INC_SRC="$SRC_DIR/external/FFmpeg"
# Add include paths for the compiler to find the package manager locations
for INC in "$PKGMGR_INC" "$QT_INC_PATH" "$BLURAY_INC_PATH" "$HDHR_INC_PATH" "$COMP_INC"; do
  if [ -n "$INC" ]; then
    INC_SRCH="$INC_SRCH:$INC"
  fi
done
export C_INCLUDE_PATH="$INC_SRCH:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="$INC_SRCH:$CPLUS_INCLUDE_PATH"

# Add library paths for the compiler to find the package manager libraries
for LIB in "$PKGMGR_LIB" "$QT_LIB_PATH" "$QT_PLUGINS_PATH" "$QT_SQL_PATH" "$HDHR_LIB_PATH" "$COMP_LIB_PATH"; do
  if [ -n "$LIB" ]; then
    if [ ! -n "$LDFLAGS" ]; then
      LDFLAGS="-L$LIB"
    else
      LDFLAGS="$LDFLAGS -L$LIB"
    fi
    if [ ! -n "$LIBRARY_PATH" ]; then
      LIBRARY_PATH="$LIB"
    else
      LIBRARY_PATH="$LIBRARY_PATH:$LIB"
    fi
  fi
done
export LDFLAGS="$LDFLAGS $COMP_LDFLAGS"
export LIBRARY_PATH=$LIBRARY_PATH

###########################################################################################
### Setup Application Bundle Variables ####################################################
###########################################################################################
# These variables are used to bundle the mythfronend.app application bundle.
# They point to internal appliction paths and are currently hardcoded to mythfrontend.
APP_NAME=mythfrontend
APP_DIR=$SRC_DIR/programs/$APP_NAME
APP=$APP_DIR/$APP_NAME.app
APP_RSRC_DIR=$APP/Contents/Resources
APP_FMWK_DIR=$APP/Contents/Frameworks
APP_EXE_DIR=$APP/Contents/MacOS
APP_PLUGINS_DIR=$APP_FMWK_DIR/PlugIns
APP_INFO_FILE=$APP/Contents/Info.plist

###########################################################################################
### Utiltity Functions ####################################################################
###########################################################################################
# installLibs finds all linked dylibs for the input binary/dylib
# copying any missing ones in the application's FrameWork directory
# then updates the binary/dylib's internal link to point to copy location
installLibs(){
  binFile=$1
  loopCTR=0
  # find all externally-linked libs and loop over them
  pathDepList=$(/usr/bin/otool -L "$binFile"|grep -e rpath -e loader_path -e "$PKGMGR_INST_PATH" -e "$INSTALL_DIR")
  pathDepList=$(echo "$pathDepList"| gsed 's/(.*//')
  while read -r dep; do
    if [ "$loopCTR" = 0 ]; then
      echoC "    installLibs: Parsing $binFile for linked libraries" YELLOW
    fi
    loopCTR=$loopCTR+1
    lib=${dep##*/}

    # Parse the lib if it isn't null
    if [ -n "$lib" ]; then
      #check if it is already installed in the framewrk, if so
      #update the link
      needsCopy=false
      FMWK_LIB=$(find "$APP_FMWK_DIR" -name "$lib" -print -quit)
      if [ ! -f "$FMWK_LIB" ]; then
        needsCopy=true
      fi

      # we have multiple types of libs to work with, QT, Qt Plugins, package managed, and mythtv
      # setup the correct source / destination / linking schema for each
      islib=false
      case "$dep" in
        # Qt based libraries / plugins
        *Qt*)
          libPath=${FMWK_LIB##"$APP_FMWK_DIR"/}
          newLink="@executable_path/../Frameworks/$libPath"
        ;;
        # mythtv libs
        *libmyth*)
          newLink="@executable_path/../Frameworks/$lib"
        ;;
        # mythplugin support libs stored in Frameworks/PlugIns (strangely all start with libq...)
        *libq*)
          pluginPath=${FMWK_LIB##"$APP_FMWK_DIR"/PlugIns/}
          newLink="@executable_path/../Frameworks/PlugIns/$pluginPath"
        ;;
        # Package manager or mythtv created libs
        *"$PKGMGR_INST_PATH"*|*"$INSTALL_DIR"*|*rpath*|*loader_path*)
          newLink="@executable_path/../Frameworks/$lib"
          islib=true
        ;;
        *)
          echoC "Unable to install $lib into Application Bundle" RED
          exit 1
        ;;
      esac
      # Copy in any missing files
      if $needsCopy && $islib; then
        echoC "      +++installLibs: Installing $lib into app" BLUE
        sourcePath=$(find "$INSTALL_DIR" "$PKGMGR_LIB" "$PKGMGR_ALT_PATH" -name "$lib" -print -quit)
        destinPath="$APP_FMWK_DIR"
        cp -RHn "$sourcePath" "$destinPath/"
        # we'll need to do this recursively
        recurse=true
      fi
      # update the link in the app/executable to the new interal Framework
      echoC "      ---installLibs: Updating $binFileName $lib link to internal lib" BLUE
      # it should now be in the App Bundle Frameworks, we just need to update the link
      NAME_TOOL_CMD="install_name_tool -change $dep $newLink $binFile"
      eval "${NAME_TOOL_CMD}"
      # If a new lib was copied in, recursively check it
      if  $needsCopy && $recurse ; then
        echoC "      ^^^installLibs: Recursively install $lib" BLUE
        installLibs "$destinPath/$lib"
      fi
    fi
  done <<< "$pathDepList"
}

# rebaseLibs finds all @rpath dylibs for the input binary/dylib
# changing the rpath to a direct path on the system
rebaseLibs(){
  binFile=$1
  rpathDepList=$(/usr/bin/otool -L "$binFile"|grep rpath)
  rpathDepList=$(echo "$rpathDepList"| gsed 's/(.*//')
  while read -r dep; do
    lib=${dep##*/}
    if [ -n "$lib" ]; then
      NAME_TOOL_CMD="install_name_tool -change $dep $RUNPREFIX/lib/$lib $binFile"
      eval "${NAME_TOOL_CMD}"
    fi
  done <<< "$rpathDepList"
}

# On homebrew, some dylibs get incorrectly internally linked, this utiltiy helps
# correct the issue
correctHomebrewLibs(){
  ARCH=$1
  binFile=$2
  startDIR=$(pwd)
  # we need to move into the APP_FMWK_DIR to make symbolic links to the broken filename
  cd $APP_FMWK_DIR
  # This first condition is for any libs marked with _x64 or _arm64
  case $ARCH in
    arm64)
      srchSTR="_arm64"
    ;;
    # cover all intel arch cases as the fall out condition
    *)
      srchSTR="_x64"
    ;;
  esac
  srchPATH="$APP_FMWK_DIR $INSTALL_DIR $PKGMGR_LIB $PKGMGR_ALT_PATH"
  # assemble a list of poorly linked dylib
  dylibList=$(/usr/bin/otool -L "$binFile"|grep -e $srchSTR)
  dylibList=$(echo "$dylibList"| gsed 's/(.*//')
  # loop over the list
  while read -r dep; do
    echoC "    correctHomebrewLibs: $(basename "$binFile") - Correcting internal link for $dep" BLUE
    badlib=${dep##*/}
    libPATH=$(dirname $dep)
    # Parse the lib if it isn't null
    if [ -n "$badlib" ]; then
      # assemble the new names for internal files
      lib=${badlib/$srchSTR*}.dylib
      correctLIB="$libPATH/$lib"
      # check if its already in the framework, if not we need to add and symlink it
      FMWK_LIB=$(find "$APP_FMWK_DIR" -name "$lib" -print -quit)
      if [ ! -f "$FMWK_LIB" ]; then
        echoC "      +++correctHomebrewLibs: Installing $lib into app" BLUE
        cp -RHn "$correctLIB" "$APP_FMWK_DIR/"
        # create a symlink to the improper filename (some links are not updateable)
        ln -s $lib $(basename dep)
        chmod ug+w $lib
      fi
      # update the link in the app/executable to the new interal Framework
      newLink="@executable_path/../Frameworks/$lib"
      echoC "      ---correctHomebrewLibs: Updating $binFileName $badlib link to internal lib" BLUE
      # the lib should now be in the App Bundle Frameworks, we just need to update the link
      NAME_TOOL_CMD="install_name_tool -change $dep $newLink $binFile"
      eval "${NAME_TOOL_CMD}"
    fi
  done <<< "$dylibList"
  # move path to the directory we started in
  cd $startDIR
}

# QT5 on homebrew no longe porvides a mechanism to install the QTMYSQL driver
buildQT5MYSQL(){
  QTVERS=$($QMAKE_CMD -query QT_VERSION)
  QT_SOURCES="$(pwd)/qt5_src/qt@5-$QTVERS"
  QT_INSTALL_PREFIX="$($QMAKE_CMD -query QT_INSTALL_PREFIX)"
  QT_SQLDRIVERS_SRC="$QT_SOURCES/qtbase/src/plugins/sqldrivers"
  MYSQL_PREFIX=$(brew --prefix $DATABASE_VERS)
  MYSQL_INCDIR="$MYSQL_PREFIX/include/mysql"
  MYSQL_LIBDIR="$MYSQL_PREFIX/lib"

  echoC "    Build QT SQL Plugin" BLUE
  cd "$QT_SQLDRIVERS_SRC"
  $($QMAKE_CMD sqldrivers.pro -- MYSQL_INCDIR=$MYSQL_INCDIR MYSQL_LIBDIR=$MYSQL_LIBDIR)

  echoC "    Build QT MySQL Plugin" BLUE
  cd "$QT_SQLDRIVERS_SRC/mysql"
  $($QMAKE_CMD mysql.pro)
  make

  echoC "    Copying plugins intto QT plugins directory" BLUE
  cp -vr "$QT_SQLDRIVERS_SRC/plugins/sqldrivers/libqsqlmysql.dylib" "$QT_PATH/plugins/sqldrivers/"
}

# Function used to convert version strings into integers for comparison
version (){
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

###########################################################################################
### Main Function #########################################################################
###########################################################################################

echoC "------------ Setting Up Output Directory Structure ------------" GREEN
# setup the working directory structure
mkdir -p "$REPO_DIR"
cd "$REPO_DIR" || exit 1
# create the install temporary directory
mkdir -p "$INSTALL_DIR"

# install and configure ansible and gsed
# ansible to install the missing required ports,
# gsed for the plist update later
echoC "------------ Setting Up Initial Ports for Ansible ------------" GREEN
if $UPDATE_PKGMGR; then
  # tell macport to retrieve the latest repo
  sudo port selfupdate
  # upgrade all outdated ports
  sudo port upgrade
fi

if [ ! $SKIP_ANSIBLE ]; then
  # check if the ANSIBLE_PB_EXE is installed, if not install it
  if ! [ -x "$(command -v "$ANSIBLE_PB_EXE")" ]; then
    echoC "    Installing python and ansilble" BLUE
    case $PKGMGR in
      macports)
        echoC "    Macports: Insatlling Ansible" ORANGE
        sudo port -N install "py$PYTHON_VERS-ansible"
        sudo port select --set python "python$PYTHON_VERS"
        sudo port select --set python3 "python$PYTHON_VERS"
      ;;
      homebrew)
        echoC "    Homebrew: Insatlling Ansible" ORANGE
        brew install python@$PYTHON_DOT_VERS
        brew install ansible
        alias python=python3
        alias pip=pip3
    esac
  else
    echoC "    Ansible is correctly installed" BLUE
  fi
fi

if $SKIP_BUILD; then
  echoC "    Skipping package installation via ansible (repackaging only)" ORANGE
else
  if $SKIP_ANSIBLE; then
      echoC "    Skipping ansible installation" ORANGE
  else
    echoC "------------ Running Ansible ------------" GREEN
    # get mythtv's ansible playbooks, and install required ports
    # if the repo exists, update (assume the flag is set)
    if [ -d "$REPO_DIR/ansible" ]; then
      echoC "    Updating mythtv-anisble git repo" BLUE
      cd "$REPO_DIR/ansible" || exit 1
      if $UPDATE_GIT; then
        echoC "    Updating ansible git repo" BLUE
        git pull
      else
        echoC "    Skipping ansible git repo update" ORANGE
      fi
    # pull down a fresh repo if none exist
    else
      echoC "    Cloning mythtv-anisble git repo" BLUE
      git clone https://github.com/MythTV/ansible.git
    fi
    cd "$REPO_DIR/ansible" || exit 1
    ANSIBLE_FLAGS="--limit=localhost"
    case $QT_VERS in
        *5*)
           ANSIBLE_EXTRA_FLAGS="--extra-vars \"ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS install_qtwebkit=$INSTALL_WEBKIT\""
        ;;
        *)
           ANSIBLE_EXTRA_FLAGS="--extra-vars \"qt6=true ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS\""
        ;;
    esac
    ANSIBLE_FULL_CMD="$ANSIBLE_PB_EXE $ANSIBLE_FLAGS $ANSIBLE_EXTRA_FLAGS $ANSIBLE_QT"
    # Need to use eval as zsh does not split multiple-word variables (https://zsh.sourceforge.io/FAQ/zshfaq03.html)
    eval "${ANSIBLE_FULL_CMD}"
  fi
  cd "$REPO_DIR" || exit 1

  # if we're on homebrew and using qt5, we need to do more work to get the
  # QTMYSQL plugin working...
  case $PKGMGR in
    homebrew)
      case $QT_VERS in
        *5*)
          if [ ! -f $QT_PATH/plugins/sqldrivers/libqsqlmysql.dylib ]; then
            echoC "    Homebrew: Installing QTMYSQL plugin for $QT_VERS" BLUE
            brew unpack $QT_VERS --destdir qt5_src
            buildQT5MYSQL
          else
            echoC "    Homebrew: QTMYSQL plugin is installed for $QT_VERS" BLUE
          fi
        ;;
      esac
    ;;
  esac
fi

# This needs to be done after ansible installs pkg-config and the requested version of mysql
export MYSQLCLIENT_LDFLAGS=$(pkg-config --libs mysqlclient)
export MYSQLCLIENT_CFLAGS=$(pkg-config --cflags mysqlclient)

echoC "------------ Source the Python Virtual Environment ------------" GREEN
# since we're using a custom python virtual environment, we need to source it to get the
# build process to use it.
source "$PYTHON_VENV_PATH/bin/activate"
PYTHON_VENV_BIN=$PYTHON_VENV_PATH/bin/$PYTHON_CMD
PY2APPLET_BIN=$PYTHON_VENV_PATH/bin/py2applet

echoC "------------ Cloning / Updating Mythtv Git Repository ------------" GREEN
# setup mythtv source from git
cd "$REPO_DIR" || exit 1
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  if $UPDATE_GIT && ! $SKIP_BUILD ; then
    echoC "    Updating mythtv/mythplugins git repo" BLUE
    git pull
  else
    echoC "    Skipping mythtv/mythplugins git repo update" ORANGE
  fi
# else pull down a fresh copy of the repo from github
else
  echoC "    Cloning mythtv git repo" BLUE
  git clone -b "$MYTHTV_VERS" https://github.com/MythTV/mythtv.git
fi
# apply specified patches
if [ "$APPLY_PATCHES" ] && [ -n "$MYTHTV_PATCH_DIR" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  for file in "$MYTHTV_PATCH_DIR"/*; do
    if [ -f "$file" ]; then
      echoC "    Applying Mythtv patch: $file" BLUE
      patch -p1 < "$file"
    fi
  done
fi

echoC "------------ Configuring Mythtv ------------" GREEN
# configure mythtv
cd "$SRC_DIR" || exit 1
GIT_VERS=$(git log -1 --format="%h")
GIT_BRANCH=$(git symbolic-ref --short -q HEAD)
GIT_TAG=$(git describe --tags --exact-match 2>/dev/null)
GIT_BRANCH_OR_TAG="${GIT_BRANCH:-${GIT_TAG}}"

if [ -d "$APP" ]; then
  echoC "    Cleaning up past Builds" BLUE
  find $SRC_DIR -name "*.app"|xargs rm -Rf
fi
if $SKIP_BUILD; then
  echoC "    Skipping MythTV configure and make" ORANGE
else
  echoC "    Running configure" BLUE
  CONFIG_CMD="./configure --prefix=$INSTALL_DIR     \
                         --runprefix=$RUNPREFIX     \
                         $ENABLE_MAC_BUNDLE         \
                         $EXTRA_CONF_FLAGS          \
                         --qmake=$QMAKE_CMD         \
                         --cc=$C_CMD                \
                         --cxx=$CPP_CMD             \
                         --disable-backend          \
                         --disable-distcc           \
                         --disable-lirc             \
                         --disable-firewire         \
                         --disable-libcec           \
                         --disable-x11              \
                         --enable-libmp3lame        \
                         --enable-libxvid           \
                         --enable-libx264           \
                         --enable-libx265           \
                         --enable-libvpx            \
                         --enable-bdjava            \
                         --python=$PYTHON_VENV_BIN"
  eval "${CONFIG_CMD}"
  echoC "------------ Compiling Mythtv ------------" GREEN
  #compile MythTV
  echoC "    Running make" BLUE
  make -j4 || { echo 'Compiling Mythtv failed' ; exit 1; }
fi

echoC "------------ Installing Mythtv ------------" GREEN
# This is necessary for both standalone and application builds.
# The latter because macdeployqt is told to search for the
# installed binaries at the install prefix
make install

if $BUILD_PLUGINS; then
  echoC "------------ Configuring Mythplugins ------------" GREEN
  # apply specified patches if flag is set
  if [ "$APPLY_PATCHES" ] && [ -n "$PLUGINS_PATCH_DIR" ]; then
    cd "$PLUGINS_DIR" || exit 1
    for file in "$PLUGINS_PATCH_DIR"/*; do
      if [ -f "$file" ]; then
        echoC "    Applying Plugins patch: $file" BLUE
        patch -p1 < "$file"
      fi
    done
  fi

  # configure plugins
  cd "$PLUGINS_DIR" || exit 1
  if $SKIP_BUILD; then
    echoC "    Skipping Plugins configure and make" ORANGE

  else
    echoC "    Running configure" BLUE
    CONFIG_CMD="./configure --prefix=$INSTALL_DIR     \
                            --runprefix=$RUNPREFIX    \
                            --qmake=$QMAKE_CMD        \
                            --qmakespecs=$QMAKE_SPECS \
                            --cc=$C_CMD               \
                            --cxx=$CPP_CMD            \
                            --enable-mythgame         \
                            --enable-mythmusic        \
                            --enable-cdio             \
                            --enable-mythnews         \
                            --enable-mythweather      \
                            --disable-mytharchive     \
                            --disable-mythnetvision   \
                            --disable-mythzoneminder  \
                            --disable-mythzmserver    \
                            --python=$PYTHON_VENV_BIN \
                            $EXTRA_MYTHPLUGIN_FLAGS"
    eval "${CONFIG_CMD}"
    echoC "------------ Compiling Mythplugins ------------" GREEN
    #compile plugins
    echoC "    Running qmake/make" BLUE
    $QMAKE_CMD mythplugins.pro
    #compile mythplugins
    make -j4 || { echo 'Compiling Plugins failed' ; exit 1; }
  fi
  echoC "------------ Installing Mythplugins ------------" GREEN
  make install
else
  echoC "------------ Skipping Mythplugins Compile ------------" ORANGE
fi

echoC "------------ Performing Post Compile Cleanup ------------" GREEN

if [ -z $ENABLE_MAC_BUNDLE ]; then
  echoC "    Mac Bundle disabled - Skipping app bundling commands" ORANGE
  echoC "    Rebasing @rpath to $RUNPREFIX" GREEN
  for mythExec in "$INSTALL_DIR/bin/"myth*; do
        if [ -x "$mythExec" ] && file "$mythExec" | grep -q "Mach-O"; then
          echoC "     rebasing $mythExec" BLUE
          rebaseLibs "$mythExec"
          install_name_tool -add_rpath "$QT_LIB_PATH" "$mythExec"
        fi
  done
  echoC "Done" GREEN
  exit 0
fi

#################################################################################
#################################################################################
### Assume that all commands past this point only apply to app bundling ########
#################################################################################
#################################################################################

# Fix incorrectly linked dylibs on homebrew
case $PKGMGR in
  homebrew)
    if [ ! -d $APP_FMWK_DIR ]; then
      mkdir -p "$APP_FMWK_DIR"
    fi
    correctHomebrewLibs "$OS_ARCH" "$APP_EXE_DIR/$APP_NAME"
  ;;
esac

echoC "------------ Copying in Application Bundle icon  ------------" GREEN
cd "$APP_DIR" || exit 1
# copy in the icon
cp -RHnp "$APP_DIR/$APP_NAME.icns" "$APP_RSRC_DIR/application.icns"

echoC "------------ Copying mythtv share directory into executable  ------------" GREEN
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p "$APP_RSRC_DIR/share/mythtv"
cp -RHn "$INSTALL_DIR/share/mythtv"/* "$APP_RSRC_DIR"/share/mythtv/

echoC "------------ Updating application plist  ------------" GREEN
# Update the plist
/usr/libexec/PlistBuddy -c "Add ATSApplicationFontsPath string 'share/mythtv/fonts'" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add CFBundleGetInfoString string ''" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Set CFBundleIdentifier $APP_BNDL_ID" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add CFBundleInfoDictionaryVersion string 6.0" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Set CFBundleIconFile application.icns" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Set CFBundleSignature mythtv" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add CFBundleShortVersionString string $VERS" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add CFBundleVersion string $GIT_BRANCH-$GIT_VERS" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add NSAppleScriptEnabled string NO" "$APP_INFO_FILE"
/usr/libexec/PlistBuddy -c "Add NSHumanReadableCopyright string 'MythTV Team'" "$APP_INFO_FILE"

echoC "------------ Copying libmyth* dylibs to Application Bundle ------------" GREEN
mkdir -p "$APP_FMWK_DIR/PlugIns"
cp -RHn "$INSTALL_DIR/lib"/*.dylib "$APP_FMWK_DIR"
if $BUILD_PLUGINS; then
  echoC "------------ Copying Mythplugins dylibs into app ------------" GREEN
  # copy the mythPluins dylibs into the application
  for plugFilePath in "$INSTALL_DIR/lib/mythtv/plugins"/*.dylib; do
    libFileName=$(basename "$plugFilePath")
    echoC "    Installing $libFileName into app" BLUE
    destFile="$APP_PLUGINS_DIR/$libFileName"
    cp -RHn "$plugFilePath" "$destFile"
    case $PKGMGR in
      homebrew)
        correctHomebrewLibs $OS_ARCH $destFile
      ;;
    esac
  done
fi

echoC "------------ Deploying QT to Application Bundle ------------" GREEN
# Do this last so that qt gets copied in correctly
cd "$APP_DIR" || exit 1
MACDEPLOYQT_FULL_CMD="$MACDEPLOYQT_CMD  $APP \
                                        -verbose=1                            \
                                        -libpath=$INSTALL_DIR/lib/            \
                                        -libpath=$PKGMGR_LIB/                 \
                                        -libpath=$QT_PATH/lib/                \
                                        -libpath=$QT_PATH/plugins/            \
                                        -libpath=$QT_PATH/plugins/sqldrivers/ \
                                        -qmlimport=$QT_PATH/qml/"
eval "${MACDEPLOYQT_FULL_CMD}"

echoC "------------ Update Application Bundle to use internal dylibs ------------" GREEN
# clean up dylib links for mythtv based libs in Frameworks
# macdeployqt leaves @rpath based links for mythtv libs and we need to replace these with
# @executable_path links
# We'lll want to do this with the dylibs first, then move onto the executble to reduce recursion
for dylib in "$APP_FMWK_DIR"/*.dylib; do
    installLibs "$dylib"
done
if $BUILD_PLUGINS; then
  # clean up dylib links for mythtv plugin based libs in Frameworks
  for plugDylib in "$APP_PLUGINS_DIR"/*.dylib; do
    installLibs "$plugDylib"
  done
fi
# find all mythtv dylibs linked via @rpath in the application bundle updating the internal link
# to point to the application
cd "$APP_EXE_DIR" || exit 1
installLibs "$APP_EXE_DIR/$APP_NAME"

echoC "------------ Installing additional mythtv utility executables into the Application Bundle  ------------" GREEN
# loop over the utility apps copying in the desired ones into the application bundle
for helperBinPath in "$INSTALL_DIR/bin"/*; do
  case $helperBinPath in
    *"mythutil"*|*"mythpreviewgen"*)
      # extract the filename from the path
      helperBinFile=$(basename "$helperBinPath")
      helperBinFile=${helperBinFile%.app}
      helperBinPath=$helperBinPath/Contents/MacOS/$helperBinFile
      echoC "    Installing $helperBinFile into app" BLUE
      # copy into the app
      cp -RHn "$helperBinPath" "$APP_EXE_DIR"/
      # update the dylib links to internal
      installLibs "$APP_EXE_DIR/$helperBinFile"
    ;;
  esac
done

echoC "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------" GREEN
mkdir -p "$APP_RSRC_DIR/lib"
cp -RHn "$INSTALL_DIR/lib"/python* "$APP_RSRC_DIR"/lib/
cp -RHn "$INSTALL_DIR/lib"/perl* "$APP_RSRC_DIR"/lib/
if [ ! -f "$APP_RSRC_DIR/lib/python" ]; then
  cd "$APP_RSRC_DIR/lib" || exit 1
  ln -s "$PYTHON_CMD" python
  cd "$APP_DIR" || exit 1
fi

echoC "------------ Deploying python packages into application  ------------" GREEN
# make an application from  to package up python and the correct support libraries
PYTHON_APP=$APP_DIR/PYTHON_APP
mkdir -p "$PYTHON_APP"
export PYTHONPATH=$INSTALL_DIR/lib/$PYTHON_CMD/site-packages
cd "$PYTHON_APP" || exit 1
if [ -f setup.py ]; then
  rm setup.py
fi

echoC "    Creating a temporary application from $MYTHTV_PYTHON_SCRIPT" BLUE
# in order to get python embedded in the application we're going to make a temporyary application
# from one of the python scripts which will copy in all the required libraries for running
# and will make a standalone python executable not tied to the system ttvdb4 seems to be more
# particular than others (tmdb3)...
$PY2APPLET_BIN -i "$PY2APP_PKGS" -p "$PY2APP_PKGS" -e "$PY2APP_EXLCUDE" --use-pythonpath --no-report-missing-conditional-import --make-setup "$INSTALL_DIR/share/mythtv/metadata/Television/$MYTHTV_PYTHON_SCRIPT.py"
$PYTHON_VENV_BIN setup.py -q py2app 2>&1 > /dev/null
# now we need to copy over the python app's pieces into the application bundle to get it working
echoC "    Copying in Python Framework libraries" BLUE
cp -RHn "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Frameworks"/* "$APP_FMWK_DIR"
echoC "    Copying in Python Binary" BLUE
cp -RHn "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/MacOS"/py* "$APP_EXE_DIR/"
echoC "    Copying in Python Resources" BLUE
cp -RHn "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Resources"/* "$APP_RSRC_DIR"
# clean up temp application
cd "$APP_DIR" || exit 1
rm -Rf "$PYTHON_APP"
echoC "    Copying in Site Packages from Virtual Enironment" BLUE
cp -RHn "$PYTHON_VENV_PATH/lib/$PYTHON_CMD/site-packages"/* "$APP_RSRC_DIR/lib/$PYTHON_CMD/site-packages"
# do not need/want py2app in the application
rm -Rf "$APP_RSRC_DIR/lib/$PYTHON_CMD/site-packages/py2app"

echoC "------------ Replace application perl/python paths to relative paths inside the application   ------------" GREEN
# mythtv "fixes" the shebang in all python scripts to an absolute path on the compiling system.  We need to
# change this to a relative path pointint internal to the application.
# Note - when MacOS apps run, their starting path is the path as the directory the .app is stored in

cd "$APP_RSRC_DIR/share/mythtv/metadata" || exit 1
# edit the items that point to INSTALL_DIR
sedSTR=s#$INSTALL_DIR#../Resources#g
grep -rlI "$INSTALL_DIR" "$APP_RSRC_DIR" | xargs gsed -i "$sedSTR"

# edit those that point to $SRC_DIR/programs/scripts/
sedSTR=s#$PYTHON_VENV_BIN#python#g
grep -rlI "$PYTHON_VENV_BIN" "$APP_RSRC_DIR" | xargs gsed -i "$sedSTR"
sedSTR=s#$PYTHON_PKMGR_BIN#python#g
grep -rlI "$PYTHON_PKMGR_BIN" "$APP_RSRC_DIR" | xargs gsed -i "$sedSTR"

echoC "------------ Copying in dejavu and liberation fonts into the Application Bundle   ------------" GREEN
# copy in missing fonts
case $PKGMGR in
  macports)
    cp -RHn "$FONT_PATH/dejavu-fonts"/*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"
    cp -RHn "$FONT_PATH/liberation-fonts"/*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"
  ;;
  homebrew)
    cp -RHn "$FONT_PATH"/DejaVu*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"
    cp -RHn "$FONT_PATH"/Liberation*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"
  ;;
esac

echoC "------------ Add symbolic link structure for copied in files  ------------" GREEN
# make some symbolic links to match past working copies
if $BUILD_PLUGINS; then
  mkdir -p "$APP_RSRC_DIR/lib/mythtv"
  cd "$APP_RSRC_DIR/lib/mythtv" || exit 1
  ln -s ../../../Frameworks/PlugIns plugins
fi

# move the QT PlugIns into the App's framework to pass app signing
# we'll set the QT_QPA_PLATFORM_PLUGIN_PATH to point the app to the new location
mv "$APP"/Contents/PlugIns/* "$APP_PLUGINS_DIR"/
gsed -i "2c\Plugins = Frameworks/PlugIns" "$APP_RSRC_DIR/qt.conf"

echoC "------------ Searching Applicaition for missing libraries ------------" GREEN
# Do one last sweep for missing or rpath linked dylibs in the Framework Directory
for dylib in "$APP_FMWK_DIR"/*.dylib; do
  pathDepList=$(/usr/bin/otool -L "$dylib"|grep -e rpath -e $"PKGMGR_LIB" -e "$INSTALL_DIR")
  if [ -n "$pathDepList" ] ; then
    installLibs "$dylib"
  fi
done

echoC "------------ Generating Application Bundle startup script ------------" GREEN
# since we now have python installed internally, we need to make sure that the
# executable launched from the curret directory points to the internal python
# We need to do this step after macdeployqt since the startup script breaks macdeployqt
cd "$APP_EXE_DIR" || exit 1
echo "#!/bin/sh

BASEDIR=\$(dirname "\$0")
if [ \${BASEDIR:0:1} = \".\" ] ;then
  BASEDIR=\$(pwd)/\${BASEDIR:2}
fi

cd \$BASEDIR
cd ../..
APP_DIR=\$(pwd)
export PYTHONPATH=\$APP_DIR/Contents/Resources/lib/$PYTHON_CMD:\$APP_DIR/Contents/Resources/lib/$PYTHON_CMD/site-packages:\$APP_DIR/Contents/Resources/lib/$PYTHON_CMD/sites-enabled
PATH=\$(pwd):\$PATH

cd \$BASEDIR
./$APP_NAME \$@" > $APP_NAME.sh

chmod +x $APP_NAME.sh

# Update the plist to use the startup script
/usr/libexec/PlistBuddy -c "Set CFBundleExecutable $APP_NAME.sh" "$APP_INFO_FILE"

echoC "------------ Build Complete ------------" GREEN
echoC "     Application is located:"
echoC "     $APP" GREEN
echoC "If you intend to distribute the application, then next steps are to codesign
and notarize the appliction using the codesignAndPackage.zsh script with the
following command:"
echoC "    ./codesignAndPackage.zsh $APP" GREEN
