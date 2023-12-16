#!/bin/zsh

show_help(){
    cat <<EOF
Usage: compileMythtvAnsible.sh [options]
Options: [defaults in brackets after descriptions]

Standard options:
  --help                                 Print this message
  --build-plugins=BUILD_PLUGINS          Build Mythtvplugins (false)
  --python-version=PYTHON_VERS           Desired Python 3 Version (${2})
  --version=MYTHTV_VERS                  Requested mythtv git repo (${1})
  --database-version=DATABASE_VERS       Requested version of mariadb/mysql to build agains (${3})
  --qt-version=qt5                       Select Qt version to build against (${4})
  --repo-prefix=REPO_PREFIX              Directory base to install the working repository (~)
  --generate-app=GENERATE_APP            Generate .app bundles for executables (true)
Build Options
  --update-git=UPDATE_GIT                Update git repositories to latest (true)
  --skip-build=SKIP_BUILD                Skip configure and make - used when you just want to repackage (false)
  --alt-compiler=ALT_COMPILER            Flag to specify compiler version to build with (clang)
  --extra-conf-flags=EXTRA_CONF_FLAGS    Addtional configure flags for mythtv ("")
  --skip-ansible=SKIP_ANSIBLE            Skip ansible install (false)
Patch Options
  --apply-patches=APPLY_PATCHES          Apply patches specified in additional arguments (false)
  --mythtv-patch-dir=MYTHTV_PATCH_DIR    Directory containing patch files to be applied to Mythtv
  --plugins-patch-dir=PLUGINS_PATCH_DR   Directory containing patch files to be applied to Mythplugins
Support Ports Options
  --update-ports=UPDATE_PORTS            Update macports (false)

EOF

  exit 0
}

echoC(){
  COLOR=${1}
  MESSAGE=${2}
  END_CODE='\033[m'
  case $COLOR in
  ### echo color codes
  RED)
    CODE='\033[31m'
  ;;
  ORANGE)
    CODE='\033[33m'
  ;;
  GREEN)
    CODE='\033[32m'
  ;;
  BLUE)
    CODE='\033[34m'
  ;;
  CYAN)
    CODE='\033[36m'
  ;;
  esac
  echo -e $CODE"$MESSAGE"$END_CODE
}

### Note - macports or homebrew must be installed on your system for this script to work!!!!!
echoC CYAN '****************************************************************************'
if [ -x "$(command -v port)" ]; then
  echoC CYAN '***** Setting macports for package installation ****************************'
  PKGMGR='macports'
elif [ -x "$(command -v brew)" ]; then
  echoC CYAN '***** Setting homebrew for package installation ****************************'
  PKGMGR='homebrew'
else
  echoC RED 'Error Neither macports or homebrew are present. Exiting...'
  exit 1
fi
echoC CYAN '****************************************************************************'

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
PYTHON_VERS="311"
UPDATE_PORTS=false
MYTHTV_VERS="fixes/33"
MYTHTV_PYTHON_SCRIPT="ttvdb4"
QT_VERS=qt5
GENERATE_APP=true
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
else
  case $PKGMGR in
    macports)
      DATABASE_VERS=mysql8
    ;;
    homebrew)
      DATABASE_VERS=mysql
    ;;
  esac
fi

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
      --update-ports=*)
        UPDATE_PORTS="${i#*=}"
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
### Build Output Variables ################################################################
###########################################################################################
# Setup version specific working path
REPO_DIR=$REPO_PREFIX/mythtv-$VERS

# Setup app build outputs and lib linking
if $GENERATE_APP; then
  ENABLE_MAC_BUNDLE="--enable-mac-bundle"
  INSTALL_DIR=$REPO_DIR/$VERS-osx-64bit
  RUNPREFIX=../Resources
else
  ENABLE_MAC_BUNDLE=""
  INSTALL_DIR=$PKGMGR_INST_PATH
  RUNPREFIX=$INSTALL_DIR
fi

###########################################################################################
### PKGMGR Specific Variables #############################################################
###########################################################################################
PYTHON_DOT_VERS="${PYTHON_VERS:0:1}.${PYTHON_VERS:1:4}"
PYTHON_CMD="python$PYTHON_DOT_VERS"
case $PKGMGR in
  macports)
    PKGMGR_INST_PATH=$(dirname $(dirname $(which port)))
    PKGMGR_ALT_PATH=$PKGMGR_INST_PATH/libexec
    ANSIBLE_PB_EXE="$PKGMGR_INST_PATH/bin/ansible-playbook-$PYTHON_DOT_VERS"
    FONT_PATH=$PKGMGR_INST_PATH/share/fonts
    # Select the correct QT version of tools / libraries
    QT_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS
    HDHOMERUN_LIB=$PKGMGR_INST_PATH/include/libhdhomerun
    INSTALL_WEBKIT=true
  ;;
  homebrew)
    PKGMGR_INST_PATH=$(brew --prefix)
    PKGMGR_ALT_PATH=$PKGMGR_INST_PATH/opt
    ANSIBLE_PB_EXE="$PKGMGR_INST_PATH/bin/ansible-playbook"
    FONT_PATH=$HOME/Library/Fonts
    QT_PATH=$PKGMGR_INST_PATH/opt/$QT_VERS
    HDHOMERUN_LIB="$PKGMGR_INST_PATH/opt/libhdhomerun/lib/"
    INSTALL_WEBKIT=false
    # Special handling for hdhomerun on arm where the internal dylib path is setup
    # to point to an incorrectly named dylib
    case $OS_ARCH in
      arm64)
        HDHOMERUN_ARM=$HDHOMERUN_LIB/libhdhomerun_arm64.dylib
        if [ ! -f $HDHOMERUN_ARM ]; then
          cp -Hnp $HDHOMERUN_LIB/libhdhomerun.dylib $HDHOMERUN_ARM
          chmod ug+w $HDHOMERUN_ARM
        fi
      ;;
    esac
  ;;
esac
if ! $BUILD_PLUGINS; then
  INSTALL_WEBKIT=false
fi

###########################################################################################
### Build Variable and Pathing ############################################################
###########################################################################################
# Setup Initial Python variables and dependencies for port / ansible installation
PYTHON_PKMGR_BIN="$PKGMGR_INST_PATH/bin/$PYTHON_CMD"
PYTHON_VENV_PATH="$HOME/.mythtv/python-virtualenv"
PY2APP_PKGS="MySQLdb,pycurl,requests_cache,urllib3,future,lxml,oauthlib,requests,simplejson,\
  audiofile,bs4,argparse,common,configparser,datetime,discid,et,features,HTMLParser,httplib2,\
  musicbrainzngs,port,put,traceback2,markdown,dateutil,importlib_metadata"

# Check if the user specifed a compiler
case $ALT_COMPILER in
    clang-mp*)
      if [ $PKGMGR = "homebrew" ]; then
        echoC RED 'Error: Homebrew compile currently only supports clang or gcc based compiles.  Exiting!'
        exit 1
      fi
      # macports specific case
      C_CMD=$PKGMGR_INST_PATH/bin/$ALT_COMPILER
      CPP_CMD=$PKGMGR_INST_PATH/bin/${ALT_COMPILER/clang/clang++}
      # check is specified compiler is installed
      if ! [ -x "$(command -v "$C_CMD")" ]; then
        CLANG_PORT=${ALT_COMPILER/clang-mp/clang}
        echoC BLUE '    Macports: Installing the requested compiler'
        sudo port -N install "$CLANG_PORT"
      fi
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
      echoC RED 'Error: unkown compiler specified.  Exiting!'
      exit 1
    ;;
esac

# Setup QT variables (QT_PATH should handle both qt version and PKGMGR paths)
QMAKE_CMD=$QT_PATH/bin/qmake
QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
ANSIBLE_QT=mythtv.yml
MACDEPLOYQT_CMD=$QT_PATH/bin/macdeployqt
# if we're running qt6, disable plugins
case $QT_VERS in
    qt6|qt@6)
       echoC BLUE '    Building with Qt6 - disabling plugins'
       BUILD_PLUGINS=false
    ;;
esac

# Add some flags for the compiler to find the package manager locations
export LDFLAGS="$LDFLAGS -L$QT_PATH/lib -L$QT_PATH/plugins -L$PKGMGR_INST_PATH/lib"
export C_INCLUDE_PATH=$QT_PATH/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$HDHOMERUN_LIB:$PKGMGR_INST_PATH/include/glslang:$PKGMGR_INST_PATH/include/vulkan:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$QT_PATH/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$HDHOMERUN_LIB:$PKGMGR_INST_PATH/include/glslang:$PKGMGR_INST_PATH/include/vulkan:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$QT_PATH/lib:$QT_PATH/plugins:$PKGMGR_INST_PATH/lib:$PKGMGR_INST_PATH/share/qt/plugins/sqldrivers:$LIBRARY_PATH

# Add flags to allow pip3 / python to find mysql8
case $PKGMGR in
  macports)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_INST_PATH/lib/mysql8/pkgconfig/
  ;;
  homebrew)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_INST_PATH/opt/lib/pkgconfig/mysqlclient.pc
  ;;
esac
export MYSQLCLIENT_LDFLAGS=$(pkg-config --libs mysqlclient)
export MYSQLCLIENT_CFLAGS=$(pkg-config --cflags mysqlclient)

# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins
export PATH=$PKGMGR_INST_PATH/lib/$DATABASE_VERS/bin:$PATH

# macOS internal appliction paths
APP_DIR=$SRC_DIR/programs/mythfrontend
APP=$APP_DIR/mythfrontend.app
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
      echoC BLUE "    installLibs: Parsing $binFile for linked libraries"
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
          echoC RED "Unable to install $lib into Application Bundle"
          exit 1
        ;;
      esac
      # Copy in any missing files
      if $needsCopy && $islib; then
        echoC BLUE "      +++installLibs: Installing $lib into app"
        case $PKGMGR in
          macports)
            sourcePath=$(find "$INSTALL_DIR" "$PKGMGR_INST_PATH/libexec" "$PKGMGR_INST_PATH/lib" -name "$lib" -print -quit)
          ;;
          homebrew)
            sourcePath=$(find "$INSTALL_DIR" "$PKGMGR_INST_PATH/lib" "$PKGMGR_INST_PATH/opt" -name "$lib" -print -quit)
          ;;
        esac
        destinPath="$APP_FMWK_DIR"
        cp -RHn "$sourcePath" "$destinPath/"
        # we'll need to do this recursively
        recurse=true
      fi
      # update the link in the app/executable to the new interal Framework
      echoC BLUE "      ---installLibs: Updating $binFileName $lib link to internal lib"
      # it should now be in the App Bundle Frameworks, we just need to update the link
      NAME_TOOL_CMD="install_name_tool -change $dep $newLink $binFile"
      eval "${NAME_TOOL_CMD}"
      # If a new lib was copied in, recursively check it
      if  $needsCopy && $recurse ; then
        echoC BLUE "      ^^^installLibs: Recursively install $lib"
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
            install_name_tool -change "$dep" "$RUNPREFIX/lib/$lib" "$binFile"
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
      srchPATH="$APP_FMWK_DIRm$INSTALL_DIR $PKGMGR_INST_PATH/lib $PKGMGR_INST_PATH/libexec"
    ;;
    # cover all intel arch cases as the fall out condition
    *)
      srchSTR="_x64"
      srchPATH="$APP_FMWK_DIR $INSTALL_DIR $PKGMGR_INST_PATH/lib $PKGMGR_INST_PATH/opt"
    ;;
  esac
  # assemble a list of poorly linked dylib
  dylibList=$(/usr/bin/otool -L "$binFile"|grep -e $srchSTR)
  dylibList=$(echo "$dylibList"| gsed 's/(.*//')
  # loop over the list
  while read -r dep; do
    echoC BLUE "    correctHomebrewLibs: $(basename "$binFile") - Correcting internal link for $dep"
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
        echoC BLUE "      +++correctHomebrewLibs: Installing $lib into app"
        cp -RHn "$correctLIB" "$APP_FMWK_DIR/"
        # create a symlink to the improper filename (some links are not updateable)
        ln -s $lib $(basename dep)
        chmod ug+w $lib
      fi
      # update the link in the app/executable to the new interal Framework
      newLink="@executable_path/../Frameworks/$lib"
      echoC BLUE "      ---correctHomebrewLibs: Updating $binFileName $badlib link to internal lib"
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
  QT_SQLDRIVERS="$QT_SOURCES/qtbase/src/plugins/sqldrivers"
  MYSQL_PREFIX=$(brew --prefix mysql)
  MYSQL_INCDIR="$MYSQL_PREFIX/include/mysql"
  MYSQL_LIBDIR="$MYSQL_PREFIX/lib"

  echoC BLUE "    Build QT SQL Plugin"
  cd "$QT_SQLDRIVERS"
  $($QMAKE_CMD sqldrivers.pro -- MYSQL_INCDIR=$MYSQL_INCDIR MYSQL_LIBDIR=$MYSQL_LIBDIR)

  echoC BLUE "    Build QT MySQL Plugin"
  cd "$QT_SQLDRIVERS/mysql"
  $($QMAKE_CMD mysql.pro)
  make

  echoC BLUE "    Copying plugins intto QT plugins directory"
  cp -vr "$QT_SQLDRIVERS/plugins/sqldrivers/libqsqlmysql.dylib" "$QT_PATH/plugins/sqldrivers/"
}

# Function used to convert version strings into integers for comparison
version (){
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

###########################################################################################
### Main Function #########################################################################
###########################################################################################

echoC GREEN "------------ Setting Up Output Directory Structure ------------"
# setup the working directory structure
mkdir -p "$REPO_DIR"
cd "$REPO_DIR" || exit 1
# create the install temporary directory
mkdir -p "$INSTALL_DIR"

# install and configure ansible and gsed
# ansible to install the missing required ports,
# gsed for the plist update later
echoC GREEN "------------ Setting Up Initial Ports for Ansible ------------"
if $UPDATE_PORTS; then
  # tell macport to retrieve the latest repo
  sudo port selfupdate
  # upgrade all outdated ports
  sudo port upgrade
fi

if [ ! $SKIP_ANSIBLE ]; then
  # check if ANSIBLE_PB_EXE is installed, if not install it
  if ! [ -x "$(command -v "$ANSIBLE_PB_EXE")" ]; then
    echoC BLUE "    Installing python and ansilble"
    case $PKGMGR in
      macports)
        echoC "    Macports: Insatlling Ansible"
        sudo port -N install "py$PYTHON_VERS-ansible"
        sudo port select --set python "python$PYTHON_VERS"
        sudo port select --set python3 "python$PYTHON_VERS"
      ;;
      homebrew)
        echoC "    Homebrew: Insatlling Ansible"
        brew install python@$PYTHON_DOT_VERS
        brew install ansible
    esac
  else
    echoC BLUE "    Ansible is correctly installed"
  fi
fi

if $SKIP_BUILD; then
  echoC RED "    Skipping package installation via ansible (repackaging only)"
else
  if $SKIP_ANSIBLE; then
      echoC RED "    Skipping ansible installation"
  else
    echoC GREEN "------------ Running Ansible ------------"
    # get mythtv's ansible playbooks, and install required ports
    # if the repo exists, update (assume the flag is set)
    if [ -d "$REPO_DIR/ansible" ]; then
      echoC BLUE "    Updating mythtv-anisble git repo"
      cd "$REPO_DIR/ansible" || exit 1
      if $UPDATE_GIT; then
        echoC BLUE "    Updating ansible git repo"
        git pull
      else
        echoC RED "    Skipping ansible git repo update"
      fi
    # pull down a fresh repo if none exist
    else
      echoC BLUE "    Cloning mythtv-anisble git repo"
      git clone https://github.com/MythTV/ansible.git
    fi
    cd "$REPO_DIR/ansible" || exit 1
    ANSIBLE_FLAGS="--limit=localhost"
  
    case $QT_VERS in
        qt5)
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

  # if we're on homebrew and using qt5, we need to do more work to get the
  # QTMYSQL plugin working...
  case $PKGMGR in
    homebrew)
      case $QT_VERS in
        qt5)
          if [ ! -f $QT_PATH/plugins/sqldrivers/libqsqlmysql.dylib ]; then
            echoC BLUE "    Homebrew: Installing QTMYSQL plugin for $QT_VERS"
            brew unpack qt5 --destdir qt5_src
            buildQT5MYSQL
          else
            echoC BLUE "    Homebrew: QTMYSQL plugin is installed for $QT_VERS"
          fi
        ;;
      esac
    ;;
  esac
fi

echoC GREEN "------------ Source the Python Virtual Environment ------------"
source "$PYTHON_VENV_PATH/bin/activate"
PYTHON_VENV_BIN=$PYTHON_VENV_PATH/bin/$PYTHON_CMD
PY2APPLET_BIN=$PYTHON_VENV_PATH/bin/py2applet

echoC GREEN "------------ Cloning / Updating Mythtv Git Repository ------------"
# setup mythtv source from git
cd "$REPO_DIR" || exit 1
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  if $UPDATE_GIT && ! $SKIP_BUILD ; then
    echoC BLUE "    Updating mythtv/mythplugins git repo"
    git pull
  else
    echoC RED "    Skipping mythtv/mythplugins git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echoC BLUE "    Cloning mythtv git repo"
  git clone -b "$MYTHTV_VERS" https://github.com/MythTV/mythtv.git
fi
# apply specified patches
if [ "$APPLY_PATCHES" ] && [ -n "$MYTHTV_PATCH_DIR" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  for file in "$MYTHTV_PATCH_DIR"/*; do
    if [ -f "$file" ]; then
      echoC BLUE "    Applying Mythtv patch: $file"
      patch -p1 < "$file"
    fi
  done
fi

echoC GREEN "------------ Configuring Mythtv ------------"
# configure mythfrontend
cd "$SRC_DIR" || exit 1
GIT_VERS=$(git log -1 --format="%h")
GIT_BRANCH=$(git symbolic-ref --short -q HEAD)
GIT_TAG=$(git describe --tags --exact-match 2>/dev/null)
GIT_BRANCH_OR_TAG="${GIT_BRANCH:-${GIT_TAG}}"

if [ -d "$APP" ]; then
  echoC BLUE "    Cleaning up past Mythfrontend application"
  rm -Rf "$APP"
fi
if $SKIP_BUILD; then
  echoC RED "    Skipping mythtv configure and make"
else
  CONFIG_CMD="./configure --prefix=$INSTALL_DIR    \
                         --runprefix=$RUNPREFIX    \
                         $ENABLE_MAC_BUNDLE        \
                         $EXTRA_CONF_FLAGS         \
                         --qmake=$QMAKE_CMD        \
                         --cc=$C_CMD               \
                         --cxx=$CPP_CMD            \
                         --disable-backend         \
                         --disable-distcc          \
                         --disable-lirc            \
                         --disable-firewire        \
                         --disable-libcec          \
                         --disable-x11             \
                         --enable-libmp3lame       \
                         --enable-libxvid          \
                         --enable-libx264          \
                         --enable-libx265          \
                         --enable-libvpx           \
                         --enable-bdjava           \
                         --python=$PYTHON_VENV_BIN"
  eval "${CONFIG_CMD}"
  echoC GREEN "------------ Compiling Mythtv ------------"
  #compile mythfrontend
  make || { echo 'Compiling Mythtv failed' ; exit 1; }
fi

echoC GRREN"------------ Installing Mythtv ------------"
# This is necessary for both standalone and application builds.
# The latter because macdeployqt is told to search for the
# installed binaries at the install prefix
make install

if $BUILD_PLUGINS; then
  echoC GREEN "------------ Configuring Mythplugins ------------"
  # apply specified patches if flag is set
  if [ "$APPLY_PATCHES" ] && [ -n "$PLUGINS_PATCH_DIR" ]; then
    cd "$PLUGINS_DIR" || exit 1
    for file in "$PLUGINS_PATCH_DIR"/*; do
      if [ -f "$file" ]; then
        echoC BLUE "    Applying Plugins patch: $file"
        patch -p1 < "$file"
      fi
    done
  fi

  # configure plugins
  cd "$PLUGINS_DIR" || exit 1
  if $SKIP_BUILD; then
    echoC RED "    Skipping mythplugins configure and make"

  else
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
    echoC GREEN "------------ Compiling Mythplugins ------------"
    #compile plugins
    $QMAKE_CMD mythplugins.pro
    #compile mythfrontend
    make || { echo 'Compiling Plugins failed' ; exit 1; }
  fi
  echoC GREEN "------------ Installing Mythplugins ------------"
  make install
else
  echoC RED "------------ Skipping Mythplugins Compile ------------"
fi

echoC GREEN "------------ Performing Post Compile Cleanup ------------"

if [ -z $ENABLE_MAC_BUNDLE ]; then
  echoC RED "    Mac Bundle disabled - Skipping app bundling commands"
  echoC GREEN "    Rebasing @rpath to $RUNPREFIX"
  for mythExec in "$INSTALL_DIR/bin"/myth*; do
        echoC BLUE "     rebasing $mythExec"
        rebaseLibs "$mythExec"
  done
  echoC GREEN "Done"
  exit 0
fi

#################################################################################
#################################################################################
### Assume that all commands past this point only apply to app bundling ########
#################################################################################
#################################################################################

# on homebrew, point mythfrontend to the correct
case $PKGMGR in
  homebrew)
    if [ ! -d $APP_FMWK_DIR ]; then
      mkdir -p "$APP_FMWK_DIR"
    fi
    correctHomebrewLibs "$OS_ARCH" "$APP_EXE_DIR/mythfrontend"
  ;;
esac

echoC GREEN "------------ Copying in Mythfrontend.app icon  ------------"
cd "$APP_DIR" || exit 1
# copy in the icon
cp -RHnp "$APP_DIR/mythfrontend.icns" "$APP_RSRC_DIR/application.icns"

echoC GREEN "------------ Copying mythtv share directory into executable  ------------"
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p "$APP_RSRC_DIR/share/mythtv"
cp -RHn "$INSTALL_DIR/share/mythtv"/* "$APP_RSRC_DIR"/share/mythtv/

echoC GREEN "------------ Updating application plist  ------------"
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

echoC GREEN "------------ Copying libmyth* dylibs to Application Bundle ------------"
mkdir -p "$APP_FMWK_DIR/PlugIns"
cp -RHn "$INSTALL_DIR/lib"/*.dylib "$APP_FMWK_DIR"
if $BUILD_PLUGINS; then
  echoC GREEN "------------ Copying Mythplugins dylibs into app ------------"
  # copy the mythPluins dylibs into the application
  for plugFilePath in "$INSTALL_DIR/lib/mythtv/plugins"/*.dylib; do
    libFileName=$(basename "$plugFilePath")
    echoC BLUE "    Installing $libFileName into app"
    destFile="$APP_PLUGINS_DIR/$libFileName"
    cp -RHn "$plugFilePath" "$destFile"
    case $PKGMGR in
      homebrew)
        correctHomebrewLibs $OS_ARCH $destFile
      ;;
    esac
  done
fi

echoC GREEN "------------ Deploying QT to Mythfrontend Executable ------------"
# Do this last so that qt gets copied in correctly
cd "$APP_DIR" || exit 1
MACDEPLOYQT_FULL_CMD="$MACDEPLOYQT_CMD  $APP \
                                        -verbose=1                            \
                                        -libpath=$INSTALL_DIR/lib/            \
                                        -libpath=$PKGMGR_INST_PATH/lib/       \
                                        -libpath=$QT_PATH/lib/                \
                                        -libpath=$QT_PATH/plugins/            \
                                        -libpath=$QT_PATH/plugins/sqldrivers/ \
                                        -qmlimport=$QT_PATH/qml/"
eval "${MACDEPLOYQT_FULL_CMD}"

echoC GREEN "------------ Update Mythfrontend.app to use internal dylibs ------------"
# clean up dylib links for mythtv based libs in Frameworks
# macdeployqt leaves @rpath based links for mythtv libs and we need to replace these with
# @executable_path links
# We'lll want to do this with the dylibs first, then move onto mythfrontend to reduce recursion
for dylib in "$APP_FMWK_DIR"/*.dylib; do
    installLibs "$dylib"
done
if $BUILD_PLUGINS; then
  # clean up dylib links for mythtv plugin based libs in Frameworks
  for plugDylib in "$APP_PLUGINS_DIR"/*.dylib; do
    installLibs "$plugDylib"
  done
fi
# find all mythtv dylibs linked via @rpath in mythfrontend updating the internal link to point to
# the application
cd "$APP_EXE_DIR" || exit 1
installLibs "$APP_EXE_DIR/mythfrontend"

echoC GREEN "------------ Installing additional mythtv utility executables into Mythfrontend.app  ------------"
# loop over the compiler apps copying in the desired ones for mythfrontend
for helperBinPath in "$INSTALL_DIR/bin"/*; do
  case $helperBinPath in
    *"mythutil"*|*"mythpreviewgen"*)
      # extract the filename from the path
      helperBinFile=$(basename "$helperBinPath")
      helperBinFile=${helperBinFile%.app}
      helperBinPath=$helperBinPath/Contents/MacOS/$helperBinFile
      echoC BLUE "    Installing $helperBinFile into app"
      # copy into the app
      cp -RHn "$helperBinPath" "$APP_EXE_DIR"/
      # update the dylib links to internal
      installLibs "$APP_EXE_DIR/$helperBinFile"
    ;;
  esac
done

echoC GREEN "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------"
mkdir -p "$APP_RSRC_DIR/lib"
cp -RHn "$INSTALL_DIR/lib"/python* "$APP_RSRC_DIR"/lib/
cp -RHn "$INSTALL_DIR/lib"/perl* "$APP_RSRC_DIR"/lib/
if [ ! -f "$APP_RSRC_DIR/lib/python" ]; then
  cd "$APP_RSRC_DIR/lib" || exit 1
  ln -s "$PYTHON_CMD" python
  cd "$APP_DIR" || exit 1
fi

echoC GREEN "------------ Deploying python packages into application  ------------"
# make an application from  to package up python and the correct support libraries
PYTHON_APP=$APP_DIR/PYTHON_APP
mkdir -p "$PYTHON_APP"
export PYTHONPATH=$INSTALL_DIR/lib/$PYTHON_CMD/site-packages
cd "$PYTHON_APP" || exit 1
if [ -f setup.py ]; then
  rm setup.py
fi

echoC BLUE "    Creating a temporary application from $MYTHTV_PYTHON_SCRIPT"
# in order to get python embedded in the application we're going to make a temporyary application
# from one of the python scripts which will copy in all the required libraries for running
# and will make a standalone python executable not tied to the system ttvdb4 seems to be more
# particular than others (tmdb3)...
$PY2APPLET_BIN -i "$PY2APP_PKGS" -p "$PY2APP_PKGS" --use-pythonpath --no-report-missing-conditional-import --make-setup "$INSTALL_DIR/share/mythtv/metadata/Television/$MYTHTV_PYTHON_SCRIPT.py"
$PYTHON_VENV_BIN setup.py -q py2app 2>&1 > /dev/null
# now we need to copy over the python app's pieces into the mythfrontend.app to get it working
echoC BLUE "    Copying in Python Framework libraries"
mv -n "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Frameworks"/* "$APP_FMWK_DIR"
echoC BLUE "    Copying in Python Binary"
mv "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/MacOS/python" "$APP_EXE_DIR"
if [ -f "$APP_EXE_DIR/python3" ]; then
  ln -s "$APP_EXE_DIR/pyton" "$APP_EXE_DIR/python3"
fi
echoC BLUE "    Copying in Python Resources"
mv -n "$PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Resources"/* "$APP_RSRC_DIR"
# clean up temp application
cd "$APP_DIR" || exit 1
rm -Rf "$PYTHON_APP"
echoC BLUE "    Copying in Site Packages from Virtual Enironment"
cp -RHn "$PYTHON_VENV_PATH/lib/$PYTHON_CMD/site-packages"/* "$APP_RSRC_DIR/lib/$PYTHON_CMD/site-packages"
# do not need/want py2app in the application
rm -Rf "$APP_RSRC_DIR/lib/$PYTHON_CMD/site-packages/py2app"

echoC GREEN "------------ Replace application perl/python paths to relative paths inside the application   ------------"
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

echoC GREEN "------------ Copying in dejavu and liberation fonts into Mythfrontend.app   ------------"
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

echoC GREEN "------------ Add symbolic link structure for copied in files  ------------"
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

echoC GREEN "------------ Searching Applicaition for missing libraries ------------"
# Do one last sweep for missing or rpath linked dylibs in the Framework Directory
for dylib in "$APP_FMWK_DIR"/*.dylib; do
  pathDepList=$(/usr/bin/otool -L "$dylib"|grep -e rpath -e $"PKGMGR_INST_PATH/lib" -e "$INSTALL_DIR")
  if [ -n "$pathDepList" ] ; then
    installLibs "$dylib"
  fi
done

echoC GREEN "------------ Generating mythfrontend startup script ------------"
# since we now have python installed internally, we need to make sure that the mythfrontend
# executable launched from the curret directory so that the python relative paths point int
# to the internal python
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
./mythfrontend \$@" > mythfrontend.sh

chmod +x mythfrontend.sh

# Update the plist to use the startup script
/usr/libexec/PlistBuddy -c "Set CFBundleExecutable mythfrontend.sh" "$APP_INFO_FILE"

echoC GREEN "------------ Build Complete ------------"
echo "     Application is located:"
echoC GREEN "     $APP"
echo "If you intend to distribute the application, then next steps are to codesign
and notarize the appliction using the codesignAndPackage.zsh script with the
following command:"
echoC GREEN "    ./codesignAndPackage.zsh $APP"
