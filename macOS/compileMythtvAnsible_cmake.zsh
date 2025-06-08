#!/bin/zsh

show_help(){
    cat <<EOF
Usage: compileMythtvAnsible.sh [options]
Options: [defaults in brackets after descriptions]

Standard Options:
  --help                                  Print this help message
  --version=MYTHTV_VERS                   Requested mythtv git repo (${1})
                                            Example: master for the latest master
                                                     fixes/35 for version 35
  --build-plugins=BUILD_PLUGINS           Build MythTV Plugins (false)
Environmental Options:
  --database-version=DATABASE_VERS        Requested version of mariadb/mysql to build agains (${3})

  --qt-version=QT_PKMGR_VERS              Select Qt version to build against (${4})
                                            Example: qt5 for qt5
                                                     qt6 for qt6
  --python-version=PYTHON_VERS            Desired Python 3 Version (${2})
                                            Example: ${2}
  --working_dir=WORKING_DIR_BASE          Directory base to install the working directorty ("")

  --custom-install-dir=INSTALL_DIR        Directory to copy executables and support files. ("")
                                            This defaults to the MacPort's or Homebrew's prefix
Configure and Build Options
  --update-git=UPDATE_GIT                 Update git repositories to latest (true)
                                            This is only used when the source has already been
                                            cloned via git and you do not want to pull any updates
                                            from the master repo
  --skip-ansible=SKIP_ANSIBLE             Skip ansible install (false)
                                            This avoids re-running ansible and should only be used
                                            if all packages have been correctly installed.
  --repackage-only=REPACKAGE_ONLY          Perform only the tasks necessary to repackage an app bundle
                                            This is used when you just want to repackage (false)
  --extra-cmake-flags=EXTRA_CMAKE_FLAGS   Addtional configure flags for mythtv ("")
Bundling, Signing, and Notarization Options
  --frontend-bundle=BUILD_FRONTEND_BUNDLE Generate an Applicaiton Bundle for Mythfrontend (OFF)
                                            Setting this to ON builds a working MythFrontend.app.
                                            If building for unix-style executables,
                                            set this to OFF.
  --generate-distribution=DISTIBUTE_APP   Generate the Distribution Package (OFF)
                                            Setting to ON will enable App Signing and Notarization
  --signing-id=CODESIGN_ID                ID for signing the app bundles. ("")
                                            Default uses the environmental variable CODESIGN_ID.
                                            IF CODESIGN_ID is not set, the distribution package will
                                            not be signed.
  --notarization-keychain=NOTAR_KEYCHAIN  Keychain used to store notarization credentials ("")
                                            Default uses the environmental variable NOTAR_KEYCHAIN.
                                            IF NOTAR_KEYCHAIN is not set, the distribution package
                                            will not be notarized
                                            hese can be stored by running the following command:
xcrun notarytool store-credentials KEYCHAIN_NAME --apple-id APPLE_ID --team-id=TEAM_ID --password APP_PWD"
                                          Note: Notarization can take quite a bit of time
                                                occasionally beyond the default keychain lock time.
                                                To extend (unfortunately permanently) the keychain
                                                lock time run the following command where the last
                                                value is your preferred timeout in seconds
                                                two hours - 7200 sec has worked so far:
                                          security set-keychain-settings -t 7200

EOF
  exit 0
}

### Utility Functions ##############################################################################
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

# rebaseLibs finds all @rpath dylibs for the input binary/dylib
# changing the rpath to a direct path on the system
rebaseLibs(){
  binFile=$1
  rpathDepList=$(/usr/bin/otool -L "$binFile"|grep rpath)
  rpathDepList=$(echo "$rpathDepList"| gsed 's/(.*//')
  while read -r dep; do
    lib=${dep##*/}
    if [ -n "$lib" ]; then
      NAME_TOOL_CMD="install_name_tool -change $dep $RUNPREFIX/lib/$lib $binFile" &> /dev/null
      eval "${NAME_TOOL_CMD}"
    fi
  done <<< "$rpathDepList"
}

# Function to set inputs to ON or OFF when passed in as true or false
setONOFF(){
  VALUE=$1
  VALUE=${VALUE:u}
  if [[ $VALUE == TRUE || $VALUE == ON ]]; then
    echo "ON"
  else
    echo "OFF"
  fi
}

### PKGMGR Check ###################################################################################
if [ -x "$(command -v port)" ]; then
  PKGMGR='macports'
elif [ -x "$(command -v brew)" ]; then
  PKGMGR='homebrew'
  export ANSIBLE_BECOME=false
  export ANSIBLE_BECOME_ASK_PASS=false
else
  echoC 'Error Neither macports or homebrew are present. Exiting...' RED
  exit 1
fi

# force expansion of magic sub-strings
set -o magicequalsubst

### OS Specific Variables ##########################################################################
OS_VERS=$(/usr/bin/sw_vers -productVersion)
OS_VERS_PARTS=(${(@s:.:)OS_VERS})
OS_MINOR=${OS_VERS_PARTS[2]}
OS_MAJOR=${OS_VERS_PARTS[1]}
OS_ARCH=$(/usr/bin/arch)

### Github Specific Variables ##########################################################################
isGITHUB=false
if [ -n "$GITHUB_ENV" ]; then
  isGITHUB=true;
fi
### Input Parsing ##################################################################################
# setup default variables
MYTHTV_VERS="fixes/35"
BUILD_PLUGINS=false
BUNDLE_APPLICTION=false
BUILD_FRONTEND_BUNDLE=OFF
BUNDLE_APPLICTION=false
WORKING_DIR_BASE=$HOME
INSTALL_DIR=""
UPDATE_GIT=true
SKIP_ANSIBLE=false
REPACKAGE_ONLY=false
EXTRA_CMAKE_FLAGS=""
DISTIBUTE_APP=OFF
if [[ ! -v CODESIGN_ID ]]; then
  CODESIGN_ID=""
fi
if [[ ! -v NOTAR_KEYCHAIN ]]; then
  NOTAR_KEYCHAIN=""
fi

# macports / homebrew have different naming conventions for mysql, python, and qt
case $PKGMGR in
  macports)
    DATABASE_VERS=mysql8
    if [ "$OS_MAJOR" -le 11 ] && [ "$OS_MINOR" -le 15 ]; then
      DATABASE_VERS=mariadb-10.5
    fi
    QT_PKMGR_VERS=qt6
    PYTHON_VERS="313"
  ;;
  homebrew)
    DATABASE_VERS=mariadb
    QT_PKMGR_VERS=qt@6
    PYTHON_VERS="313"
  ;;
esac

# parse user inputs into variables
for i in "$@"; do
  case $i in
      -h|--help)
        show_help "${MYTHTV_VERS}" "${PYTHON_VERS}" "${MYTHTV_VERS}" "${QT_PKMGR_VERS}"
        exit 0
      ;;
      --version=*)
        MYTHTV_VERS="${i#*=}"
      ;;
      --build-plugins=*)
        BUILD_PLUGINS="${i#*=}"
      ;;
      --frontend-bundle=*)
        BUILD_FRONTEND_BUNDLE=$(setONOFF "${i#*=}")
      ;;
      --database-version=*)
        DATABASE_VERS="${i#*=}"
      ;;
      --qt-version=*)
        QT_PKMGR_VERS="${i#*=}"
      ;;
      --python-version=*)
        PYTHON_VERS="${i#*=}"
      ;;
      --working_dir=*)
        WORKING_DIR_BASE="${i#*=}"
      ;;
      --custom-install-dir=*)
        INSTALL_DIR="${i#*=}"
      ;;
      --update-git*)
        UPDATE_GIT="${i#*=}"
      ;;
      --skip-ansible=*)
        SKIP_ANSIBLE="${i#*=}"
      ;;
      --repackage-only=*)
        REPACKAGE_ONLY="${i#*=}"
      ;;
      --extra-cmake-flags=*)
        EXTRA_CMAKE_FLAGS="${i#*=}"
      ;;
      --generate-distribution=*)
        DISTIBUTE_APP=$(setONOFF "${i#*=}")
      ;;
      --signing-id=*)
        CODESIGN_ID="${i#*=}"
      ;;
      --notarization-keychain=*)
        NOTAR_KEYCHAIN="${i#*=}"
      ;;
      *)
        echo -e 'compileMythtv: Unknown or incomplete option '"\033[31m"$i"\033[m"
              # unknown option
        exit 1
      ;;
  esac
done

# Remove any magic substrings
if [ ! -z $WORKING_DIR_BASE ]; then
  eval "WORKING_DIR_BASE=$WORKING_DIR_BASE"
fi
if [ ! -z $INSTALL_DIR ]; then
  eval "INSTALL_DIR=$INSTALL_DIR"
fi
# check is we're bundling any applications
if [[ $BUILD_FRONTEND_BUNDLE == "ON" ]]; then
  BUNDLE_APPLICTION=true
fi

# if we're signing an application frontend bundling must be enabled
if [[ $DISTIBUTE_APP == "ON" && $BUILD_FRONTEND_BUNDLE == "OFF" ]]; then
  echoC 'Error: Signing, Notarizing, and Bundling requires at least one App Bundle to be made' RED
  exit 1
fi

echoC "***** Setting $PKGMGR for package installation ****************************" CYAN

echoC "------------ Setting Up Build Variables ------------" GREEN
### MythTV Specific Variables ######################################################################
# Handle any version specific parsing and flags
ANSIBLE_GIT_REPO="https://github.com/MythTV/ansible.git"
MYTHTV_GIT_REPO="https://github.com/MythTV/mythtv.git"
case $MYTHTV_VERS in
    # this condition covers the current master
    master*)
      # if we're building on master - get release number from the git tags
      VERS=$(git ls-remote --tags  $MYTHTV_GIT_REPO|tail -n 1)
      VERS=${VERS##*/v}
      VERS=$(echo "$VERS"|tr -dc '0-9')
    ;;
    # This case covers versions prior to v34 which do not support cmake
    $((MYTHTV_VERS<34))*)
      echo -e 'Error: only versions 34 and newer support for cmake builds. '"\033[31m"$i"\033[m"
              # unknown option
      exit 1
    ;;
    # this condition covers v34 and later
    *)
      VERS=${MYTHTV_VERS: -2}
    ;;
esac

### PKGMGR Specific Variables ######################################################################
PYTHON_DOT_VERS="${PYTHON_VERS:0:1}.${PYTHON_VERS:1:4}"
PYTHON_CMD="python$PYTHON_DOT_VERS"
case $PKGMGR in
  macports)
    PKGMGR_INST_PATH=$(dirname $(dirname $(which port)))
    PKGMGR_BIN="$PKGMGR_INST_PATH/bin"
    PKGMGR_LIB="$PKGMGR_INST_PATH/lib"
    ANSIBLE_PB_EXE="$PKGMGR_BIN/ansible-playbook-$PYTHON_DOT_VERS"
    FONT_PATH="$PKGMGR_INST_PATH/share/fonts"
  ;;
  homebrew)
    PKGMGR_INST_PATH=$(brew --prefix)
    PKGMGR_BIN="$PKGMGR_INST_PATH/bin"
    PKGMGR_LIB="$PKGMGR_INST_PATH/lib"
    ANSIBLE_PB_EXE="$PKGMGR_BIN/ansible-playbook"
    FONT_PATH="$HOME/Library/Fonts"
  ;;
esac
export PATH=$PKGMGR_LIB/$DATABASE_VERS/bin:$PATH

### Setup QT Specific Parameters ###################################################################
case $PKGMGR in
  homebrew)
    QT_PKMGR_VERS="qt@${QT_PKMGR_VERS: -1}"
  ;;
esac
QT_CMAKE_VERS="${QT_PKMGR_VERS//@}"

### Build Variables ################################################################################
WORKING_DIR=$WORKING_DIR_BASE/mythtv-$VERS
SRC_DIR=$WORKING_DIR/mythtv/mythtv
# setup some paths to make the following commands easier to understand
CMAKE_CONFIGURE_DIR=$WORKING_DIR/mythtv
CMAKE_BUILD_DIR=$CMAKE_CONFIGURE_DIR/build-$QT_CMAKE_VERS

# Setup app build outputs and lib linking
# INSTALL_DIR should be set to empty unless a user flag overrides it.
if $BUNDLE_APPLICTION; then
  # If not set by the user, install in the working directory.
  if [ -z $INSTALL_DIR ]; then
    INSTALL_DIR="$WORKING_DIR/$VERS-osx-64bit"
  fi
  EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS \
                     -DCMAKE_BUILD_TYPE=Release \
                     -DDARWIN_FRONTEND_BUNDLE=$BUILD_FRONTEND_BUNDLE \
                     -DDARWIN_GENERATE_DISTRIBUTION=$DISTIBUTE_APP \
                     -DDARWIN_SIGNING_ID=\"$CODESIGN_ID\" \
                     -DDARWIN_NOTARIZATION_KEYCHAIN=\"$NOTAR_KEYCHAIN\""
else
  # If not set by the user, install in the package manager's location.
  if [ -z $INSTALL_DIR ]; then
    INSTALL_DIR=$PKGMGR_INST_PATH
  fi
fi
RUNPREFIX=$INSTALL_DIR
echoC "    Installing Build Outputs to $INSTALL_DIR" BLUE

### Setup Python Specific variables ################################################################
PYTHON_PKMGR_BIN="$PKGMGR_BIN/$PYTHON_CMD"
PYTHON_VENV_PATH="$HOME/.mythtv/python-venv$PYTHON_VERS"

### Setup Compiler and Related Search Paths ########################################################
# First verify that the SDK is setup and command line tools license has been accepted
export SDK_ROOT=$(xcrun --sdk macosx --show-sdk-path)
export SDK_VERS=$(xcrun --sdk macosx --show-sdk-version)
if [ ! -n  $SDK_ROOT ]; then
  echoC "Error: macOS SDK is not set!!!" RED
  echoC "To set the SDK, you must accept the Xcode Developer Tool License."
  echoC "To accept the license, run the following command."
  echoC "Per Apple licensing, sudo privileges are required."
  echoC "     sudo xcodebuild -license accept" GREEN
  exit 1
fi

# Add flags to allow pkgconfig to find mysql8
case $PKGMGR in
  macports)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_LIB/$DATABASE_VERS/pkgconfig/
  ;;
  homebrew)
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKGMGR_LIB/opt/$DATABASE_VERS/lib/pkgconfig/
  ;;
esac

### Configure and Build Functions ##################################################################
# check to see if the working directory exists, if not create it
if [ ! -d $WORKING_DIR ]; then
  mkdir -p $WORKING_DIR
fi
runAnsible(){
  cd $WORKING_DIR
  if $SKIP_ANSIBLE; then
    echoC "    User requested skip of ansible package installation" ORANGE
    return 0
  elif $REPACKAGE_ONLY; then
    echoC "    User requested repackaging only - skipping package installation via ansible" ORANGE
    return 0
  fi
  # install and configure ansible if not already installed ansible
  echoC "------------ Setting Up Initial Ports for Ansible ------------" GREEN
  # check if the ANSIBLE_PB_EXE is installed, if not install it
  if ! [ -x "$(command -v "$ANSIBLE_PB_EXE")" ]; then
    echoC "    Installing python and ansible" BLUE
    case $PKGMGR in
      macports)
        sudo port -N install "py$PYTHON_VERS-ansible"
      ;;
      homebrew)
        brew install python@$PYTHON_DOT_VERS
        brew install ansible
    esac
  fi
  echoC "------------ Running Ansible ------------" GREEN
  # get mythtv's ansible playbooks, and install required ports if the repo exists, update
  # (assume the flag is set)
  if [ -d "$WORKING_DIR/ansible" ]; then
    cd "$WORKING_DIR/ansible" || exit 1
    if $UPDATE_GIT; then
      echoC "    Updating ansible git repo" BLUE
      git pull
    fi
  # clone the repo
  else
    echoC "    Cloning mythtv-anisble git repo" BLUE
    git clone $ANSIBLE_GIT_REPO
  fi
  cd "$WORKING_DIR/ansible" || exit 1
  case $QT_PKMGR_VERS in
      *5*)
         ANSIBLE_EXTRA_FLAGS="--extra-vars \"ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS\""
      ;;
      *)
         ANSIBLE_EXTRA_FLAGS="--extra-vars \"qt6=true ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS\""
      ;;
  esac
  ANSIBLE_FULL_CMD="$ANSIBLE_PB_EXE --limit=localhost $ANSIBLE_EXTRA_FLAGS mythtv.yml"
  # Need to use eval as zsh does not split multiple-word variables (https://zsh.sourceforge.io/FAQ/zshfaq03.html)
  eval "${ANSIBLE_FULL_CMD}"
  cd $WORKING_DIR
}

# QT5 on homebrew no does not provide QTMYSQL driver so we might have to do this manually...
checkQT_MYSQL(){
  echoC "------------ Verifying QT / MySQL Plugin ------------" GREEN
  # if we're on homebrew and using qt5, we need to do more work to get the QTMYSQL plugin working...
  case $PKGMGR in
    homebrew)
      QT_PATH="$PKGMGR_INST_PATH/opt/$QT_PKMGR_VERS"
      QMAKE_CMD=$QT_PATH/bin/qmake
      QTVERS=$($QMAKE_CMD -query QT_VERSION)
      QT_SOURCES="$(pwd)/qt5_src/$QT_PKMGR_VERS-$QTVERS"
      QT_INSTALL_PREFIX="$($QMAKE_CMD -query QT_INSTALL_PREFIX)"
      QT_SQLDRIVERS_SRC="$QT_SOURCES/qtbase/src/plugins/sqldrivers"
      MYSQL_PREFIX=$(brew --prefix $DATABASE_VERS)
      MYSQL_INCDIR="$MYSQL_PREFIX/include/mysql"
      MYSQL_LIBDIR="$MYSQL_PREFIX/lib"
      case $QT_PKMGR_VERS in
        *5*)
          if [ ! -f $QT_PATH/plugins/sqldrivers/libqsqlmysql.dylib ]; then
            echoC "    Homebrew: Installing QTMYSQL plugin for $QT_PKMGR_VERS" BLUE
            brew unpack $QT_PKMGR_VERS --destdir qt5_src
            echoC "    Building QT SQL Plugin" BLUE
            cd "$QT_SQLDRIVERS_SRC"
            $($QMAKE_CMD sqldrivers.pro -- MYSQL_INCDIR=$MYSQL_INCDIR MYSQL_LIBDIR=$MYSQL_LIBDIR)
            echoC "    Building QT MySQL Plugin" BLUE
            cd "$QT_SQLDRIVERS_SRC/mysql"
            $($QMAKE_CMD mysql.pro)
            make
            cp -vr "$QT_SQLDRIVERS_SRC/plugins/sqldrivers/libqsqlmysql.dylib" "$QT_PATH/plugins/sqldrivers/"
          fi
        ;;
      esac
    ;;
  esac
}

# function to clone or update the mythtv git repo
getSource(){
  echoC "------------ Cloning / Updating MythTV Git Repository ------------" GREEN
  # setup mythtv source from git
  cd "$WORKING_DIR" || exit 1
  # if the repo exists, update it (assuming the flag is set)
  if [ -d "$WORKING_DIR/mythtv" ]; then
    cd "$WORKING_DIR/mythtv" || exit 1
    if $UPDATE_GIT && ! $REPACKAGE_ONLY ; then
      echoC "    Updating mythtv/mythplugins git repo" BLUE
      git pull
    else
      echoC "    Skipping mythtv/mythplugins git repo update" ORANGE
    fi
  # else pull down a fresh copy of the repo from github
  else
    echoC "    Cloning mythtv git repo" BLUE
    git clone -b "$MYTHTV_VERS" $MYTHTV_GIT_REPO
  fi
}

# funtion to call cmake to configure and build mythtv
configureAndBuild(){
  case $DATABASE_VERS in
    mariadb*)
      export MYSQLCLIENT_LDFLAGS=$(pkg-config --libs libmariadb)
      export MYSQLCLIENT_CFLAGS=$(pkg-config --cflags libmariadb)
    ;;
    mysql*)
      export MYSQLCLIENT_LDFLAGS=$(pkg-config --libs mysqlclient)
      export MYSQLCLIENT_CFLAGS=$(pkg-config --cflags mysqlclient)
  esac

  echoC "------------ Source the Python Virtual Environment ------------" GREEN
  # since we're using a custom python virtual environment, we need to source it to get the
  # build process to use it.
  source "$PYTHON_VENV_PATH/bin/activate"
  if [ ! -n "$VIRTUAL_ENV" ]; then
    if [[ $BUILD_FRONTEND_BUNDLE == "ON" ]]; then
      echoC "Error: no python virtual envirnment found, exiting" RED
      exit 1
    else
      echoC "Warning: no python virtual envirnment found, using system python" Yellow
    fi
  fi

  echoC "------------ Configuring MythTV ------------" GREEN
  # configure mythtv
  cd "$SRC_DIR" || exit 1
  GIT_VERS=$(git log -1 --format="%h")
  GIT_BRANCH=$(git symbolic-ref --short -q HEAD)
  GIT_TAG=$(git describe --tags --exact-match 2>/dev/null)
  GIT_BRANCH_OR_TAG="${GIT_BRANCH:-${GIT_TAG}}"

  if $REPACKAGE_ONLY; then
    echoC "    Cleaning up past Builds" BLUE
    rm -Rf $WORKING_DIR/mythtv/build-$QT_CMAKE_VERS/PackageDarwin-prefix
    rm -Rf $WORKING_DIR/cpack_output
    find $WORKING_DIR/mythtv -name "*.app"|xargs rm -Rf
    find $INSTALL_DIR -name "*.app"|xargs rm -Rf
  fi

  cd "$CMAKE_CONFIGURE_DIR" || exit 1
  EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DENABLE_VULKAN=OFF"
  if $BUILD_PLUGINS; then
      EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DMYTH_BUILD_PLUGINS=ON"
  else
      EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DMYTH_BUILD_PLUGINS=OFF"
  fi
  echoC "    Configuring via cmake" BLUE
  CONFIG_CMD="cmake --preset $QT_CMAKE_VERS               \
                    -B $CMAKE_BUILD_DIR                   \
                    -G Ninja                              \
                    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR   \
                    -DCMAKE_RUN_PREFIX=$RUNPREFIX         \
                    $EXTRA_CMAKE_FLAGS"
  eval "${CONFIG_CMD}"
  echoC "------------ Building MythTV ------------" GREEN
  #compile MythTV
  echoC "    Building via cmake" BLUE
  BUILD_CMD="cmake --build build-$QT_CMAKE_VERS"
  eval "${BUILD_CMD}" || { echo 'Building MythTV failed' ; exit 1; }
}

# function to perform any post compile activities
postBuild(){
  cd "$WORKING_DIR" || exit 1
  echoC "------------ Performing Post Compile Cleanup ------------" GREEN
  if ! $GENERATE_APP; then
    echoC "    Re-basing @rpath to $RUNPREFIX" GREEN
    for mythExec in "$INSTALL_DIR/bin/"myth*; do
          if [ -x "$mythExec" ] && file "$mythExec" | grep -q "Mach-O"; then
            echoC "     re-basing $mythExec" BLUE
            rebaseLibs "$mythExec"
            install_name_tool -add_rpath "$QT_LIB_PATH" "$mythExec"
          fi
    done
  else
    if [[ $DISTIBUTE_APP == "ON" ]]; then
      echoC "------------ Generating DragNDrop dmg's with CPack ------------" GREEN
      # no need to request security unlock on github
      if ! $isGITHUB; then
        # see help message for note on keychain lock time
        /usr/bin/security unlock-keychain
      fi
      CPACK_CFG=$(find $WORKING_DIR/mythtv/ -name "CPackConfig.cmake")
      CPACK_CMD="cpack --config $CPACK_CFG"
      eval "${CPACK_CMD}" || { echo 'Bundling MythTV failed' ; exit 1; }
    fi
  fi
}

### Run through Necessary Functions ################################################################
runAnsible         || exit 1
checkQT_MYSQL      || exit 1
getSource          || exit 1
configureAndBuild  || exit 1
postBuild          || exit 1
