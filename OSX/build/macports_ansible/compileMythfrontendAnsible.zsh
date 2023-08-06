#!/bin/zsh

### Note - macports must be installed on your system for this script to work!!!!!
if ! [ -x "$(command -v port)" ]; then
  echo 'Error: Macports is not installed.' >&2
  exit 1
fi

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
  --macports-clang=MP_CLANG              Flag to specify clang version to build with (default)
  --extra-conf-flags=EXTRA_CONF_FLAGS    Addtional configure flags for mythtv ("")
Patch Options
  --apply-patches=APPLY_PATCHES          Apply patches specified in additional arguments (false)
  --mythtv-patch-dir=MYTHTV_PATCH_DIR    Directory containing patch files to be applied to Mythtv
  --packaging-patch-dir=PACK_PATCH_DIR   Directory containing patch files to be applied to Packaging
  --plugins-patch-dir=PLUGINS_PATCH_DR   Directory containing patch files to be applied to Mythplugins
Support Ports Options
  --update-ports=UPDATE_PORTS            Update macports (false)

EOF

  exit 0
}


###########################################################################################
### OS Specific Variable ##################################################################
###########################################################################################
# setup OS / Architecture specific variables
OS_VERS=$(/usr/bin/sw_vers -productVersion)
OS_VERS_PARTS=(${(@s:.:)OS_VERS})
OS_MINOR=${OS_VERS_PARTS[2]}
OS_MAJOR=${OS_VERS_PARTS[1]}


###########################################################################################
### Input Parsing #########################################################################
###########################################################################################
# setup default variables
BUILD_PLUGINS=false
PYTHON_VERS="311"
UPDATE_PORTS=false
MYTHTV_VERS="master"
MYTHTV_PYTHON_SCRIPT="ttvdb4"
QT_VERS=qt5
GENERATE_APP=true
UPDATE_GIT=true
SKIP_BUILD=false
MP_CLANG=default
EXTRA_CONF_FLAGS=""
APPLY_PATCHES=false
MYTHTV_PATCH_DIR=""
PACK_PATCH_DIR=""
PLUGINS_PATCH_DIR=""
REPO_PREFIX=$HOME

# maports doesn't support mysql 8 for older versions of macOS, for those installs default to mariadb (unless the user overries)
if [ "$OS_MAJOR" -le 11 ] && [ "$OS_MINOR" -le 15 ]; then
  DATABASE_VERS=mariadb-10.5
else
  DATABASE_VERS=mysql8
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
      --macports-clang=*)
        MP_CLANG="${i#*=}"
      ;;
      --extra-conf-flags=*)
        EXTRA_CONF_FLAGS="${i#*=}"
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
      --packaging-patch-dir=*)
        PACK_PATCH_DIR="${i#*=}"
      ;;
      --plugins-patch-dir=*)
        PLUGINS_PATCH_DIR="${i#*=}"
      ;;
      *)
        echo "Unknown or incomplete option $i"
              # unknown option
        exit 1
      ;;
  esac
done


###########################################################################################
### Build Variable and Pathing ############################################################
###########################################################################################
# Specify package manager harcodes (currently for macports...)
PKGMGR_INST_PATH=/opt/local

# Setup Initial Python variables and dependencies for port / ansible installation
PYTHON_DOT_VERS="${PYTHON_VERS:0:1}.${PYTHON_VERS:1:4}"
PYTHON_PKMGR_BIN="$PKGMGR_INST_PATH/bin/python$PYTHON_DOT_VERS"
ANSIBLE_PB_EXE="$PKGMGR_INST_PATH/bin/ansible-playbook-$PYTHON_DOT_VERS"
PYTHON_VENV_PATH="$HOME/.mythtv/python-virtualenv"
PY2APP_PKGS="MySQLdb,pycurl,requests_cache,urllib3,future,lxml,oauthlib,requests,simplejson,\
  audiofile,bs4,argparse,common,configparser,datetime,discid,et,features,HTMLParser,httplib2,\
  musicbrainzngs,port,put,traceback2,markdown,dateutil,importlib_metadata"

# Handle any version specific parsing and flags
EXTRA_MYTHPLUGIN_FLAGS=""
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
      EXTRA_MYTHPLUGIN_FLAGS="--enable-fftw"
    ;;
    *33)
      VERS=${MYTHTV_VERS: -2}
    ;;
    # this condition covers v34 and later
    *)
      VERS=${MYTHTV_VERS: -2}
      EXTRA_CONF_FLAGS="EXTRA_CONF_FLAGS --disable-qtwebkit --disable-qtscript"
esac

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

# Check if the user specifed a compiler
case $MP_CLANG in
    clang-mp*)
      CLANG_CMD=$PKGMGR_INST_PATH/bin/$MP_CLANG
      CLANGPP_CMD=$PKGMGR_INST_PATH/bin/${MP_CLANG//clang/clang++}
      # check is specified compiler is installed
      if ! [ -x "$(command -v "$CLANG_CMD")" ]; then
        CLANG_PORT=${MP_CLANG//clang-mp/clang}
        echo "    Installing the requested compiler"
        sudo port -N install "$CLANG_PORT"
      fi
    ;;
    *)
      CLANG_CMD="clang"
      CLANGPP_CMD="clang++"
    ;;
esac

# Select the correct QT version of tools / libraries
case $QT_VERS in
    qt5)
       QT_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS
       QMAKE_CMD=$QT_PATH/bin/qmake
       QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
       ANSIBLE_QT=mythtv.yml
       MACDEPLOYQT_CMD=$QT_PATH/bin/macdeployqt
    ;;
    *)
       QT_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS
       QMAKE_CMD=$QT_PATH/bin/qmake6
       QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
       ANSIBLE_QT=mythtv.yml
       MACDEPLOYQT_CMD=$QT_PATH/bin/macdeployqt6
       echo "!!!!! Building with Qt6 - disabling plugins !!!!!"
       BUILD_PLUGINS=false
    ;;
esac

# Add some flags for the compiler to find the package manager locations
export LDFLAGS="-L$QT_PATH/lib -L$QT_PATH/plugins -L$PKGMGR_INST_PATH/lib"
export C_INCLUDE_PATH=$QT_PATH/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$PKGMGR_INST_PATH/include/libhdhomerun:$PKGMGR_INST_PATH/include/glslang
export CPLUS_INCLUDE_PATH=$QT_PATH/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$PKGMGR_INST_PATH/include/libhdhomerun:$PKGMGR_INST_PATH/include/glslang
export LIBRARY_PATH=$QT_PATH/lib:$QT_PATH/plugins:$PKGMGR_INST_PATH/lib

# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins
PKGING_DIR=$REPO_DIR/mythtv/packaging
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
  pathDepList=$(/usr/bin/otool -L "$binFile"|grep -e rpath -e "$PKGMGR_INST_PATH" -e "$INSTALL_DIR")
  pathDepList=$(echo "$pathDepList"| gsed 's/(.*//')
  while read -r dep; do
    if [ "$loopCTR" = 0 ]; then
      echo "    installLibs: Parsing $binFile for linked libraries"
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
        *"$PKGMGR_INST_PATH"*|*"$INSTALL_DIR"*)
          newLink="@executable_path/../Frameworks/$lib"
          islib=true
        ;;
        *)
           echo "Unable to install $lib into Application Bundle"
           exit 1
        ;;
      esac
      # Copy in any missing files
      if $needsCopy && $islib; then
        echo "      +++installLibs: Installing $lib into app"
        sourcePath=$(find "$INSTALL_DIR" "$PKGMGR_INST_PATH/libexec" "$PKGMGR_INST_PATH/lib" -name "$lib" -print -quit)
        destinPath="$APP_FMWK_DIR"
        cp -RHn "$sourcePath" "$destinPath/"
        # we'll need to do this recursively
        recurse=true
      fi
      # update the link in the app/executable to the new interal Framework
      echo "      ---installLibs: Updating $lib link to internal lib"
      # it should now be in the App Bundle Frameworks, we just need to update the link
      NAME_TOOL_CMD="install_name_tool -change $dep $newLink $binFile"
      eval "${NAME_TOOL_CMD}"
      # If a new lib was copied in, recursively check it
      if  $needsCopy && $recurse ; then
        echo "      ^^^installLibs: Recursively install $lib"
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
            install_name_tool -change "$dep" "$RUNPREFIX/lib/$lib"" $binFile"
        fi
    done <<< "$rpathDepList"
}

# Function used to convert version strings into integers for comparison
version (){
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

###########################################################################################
### Main Function #########################################################################
###########################################################################################
echo "------------ Setting Up Directory Structure ------------"
# setup the working directory structure
mkdir -p "$REPO_DIR"
cd "$REPO_DIR" || exit 1
# create the install temporary directory
mkdir -p "$INSTALL_DIR"

# install and configure ansible and gsed
# ansible to install the missing required ports,
# gsed for the plist update later
echo "------------ Setting Up Initial Ports for Ansible ------------"
if $UPDATE_PORTS; then
  # tell macport to retrieve the latest repo
  sudo port selfupdate
  # upgrade all outdated ports
  sudo port upgrade
fi
# check if ANSIBLE_PB_EXE is installed, if not install it
if ! [ -x "$(command -v "$ANSIBLE_PB_EXE")" ]; then
  echo "    Installing python and ansilble"
  sudo port -N install "py$PYTHON_VERS-ansible"
  sudo port select --set python "python$PYTHON_VERS"
  sudo port select --set python3 "python$PYTHON_VERS"
else
  echo "    Ansible is correctly installed"
fi

# check is ffmpeg is installed (to avoid a linker conflict)
if [ -x "$(command -v ffmpeg)" ]; then
  echo "    Deactivating FFMPEG to avoid a linker issue"
  sudo port deactivate ffmpeg
  FFMPEG_INSTALLED=true
else
  FFMPEG_INSTALLED=false
fi

if $SKIP_BUILD; then
  echo "    Skipping port installation via ansible (repackaging only)"
else
  echo "------------ Running Ansible ------------"
  # get mythtv's ansible playbooks, and install required ports
  # if the repo exists, update (assume the flag is set)
  if [ -d "$REPO_DIR/ansible" ]; then
    echo "    Updating mythtv-anisble git repo"
    cd "$REPO_DIR/ansible" || exit 1
    if $UPDATE_GIT; then
      echo "    Updating ansible git repo"
      git pull
    else
      echo "    Skipping ansible git repo update"
    fi
  # pull down a fresh repo if none exist
  else
    echo "    Cloning mythtv-anisble git repo"
    git clone https://github.com/MythTV/ansible.git
  fi
  cd "$REPO_DIR/ansible" || exit 1
  ANSIBLE_FLAGS="--limit=localhost"

  case $QT_VERS in
      qt5)
         ANSIBLE_EXTRA_FLAGS="--extra-vars \"ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS install_qtwebkit=$BUILD_PLUGINS\""
      ;;
      *)
         ANSIBLE_EXTRA_FLAGS="--extra-vars \"qt6=true ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS\""
      ;;
  esac
  ANSIBLE_FULL_CMD="$ANSIBLE_PB_EXE $ANSIBLE_FLAGS $ANSIBLE_EXTRA_FLAGS $ANSIBLE_QT"
  # Need to use eval as zsh does not split multiple-word variables (https://zsh.sourceforge.io/FAQ/zshfaq03.html)
  eval "${ANSIBLE_FULL_CMD}"
fi

echo "------------ Source the Python Virtual Environment ------------"
source "$PYTHON_VENV_PATH/bin/activate"
PYTHON_VENV_BIN=$PYTHON_VENV_PATH/bin/python3
PY2APPLET_BIN=$PYTHON_VENV_PATH/bin/py2applet

echo "------------ Cloning / Updating Mythtv Git Repository ------------"
# setup mythtv source from git
cd "$REPO_DIR" || exit 1
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  if $UPDATE_GIT && ! $SKIP_BUILD ; then
    echo "    Updating mythtv/mythplugins git repo"
    git pull
  else
    echo "    Skipping mythtv/mythplugins git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "    Cloning mythtv git repo"
  git clone -b "$MYTHTV_VERS" https://github.com/MythTV/mythtv.git
fi
# apply specified patches
if [ "$APPLY_PATCHES" ] && [ -n "$MYTHTV_PATCH_DIR" ]; then
  cd "$REPO_DIR/mythtv" || exit 1
  for file in "$MYTHTV_PATCH_DIR"/*; do
    if [ -f "$file" ]; then
      echo "    Applying Mythtv patch: $file"
      patch -p1 < "$file"
    fi
  done
fi

echo "------------ Cloning / Updating Packaging Git Repository ------------"
# get packaging
cd "$REPO_DIR/mythtv" || exit 1
# check if the repo exists and update (if the flag is set)
if [ -d "$PKGING_DIR" ]; then
  cd "$PKGING_DIR" || exit 1
  if $UPDATE_GIT  && ! $SKIP_BUILD; then
    echo "    Update packaging git repo"
    git pull
  else
    echo "    Skipping packaging git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "    Cloning mythtv-packaging git repo"
  git clone -b "$MYTHTV_VERS" https://github.com/MythTV/packaging.git
fi

# apply any user specified patches if the flag is set
if [ "$APPLY_PATCHES" ] && [ -n "$PACK_PATCH_DIR" ]; then
  cd "$PKGING_DIR" || exit 1
  for file in "$PACK_PATCH_DIR"/*; do
    if [ -f "$file" ]; then
      echo "    Applying Packaging patch: $file"
      patch -p1 < "$file"
    fi
  done
fi

echo "------------ Configuring Mythtv ------------"
# configure mythfrontend
cd "$SRC_DIR" || exit 1
if [ -d "$APP" ]; then
  echo "    Cleaning up past Mythfrontend application"
  rm -Rf "$APP"
fi
if $SKIP_BUILD; then
  echo "    Skipping mythtv configure and make"
else
  CONFIG_CMD="./configure --prefix=$INSTALL_DIR    \
                         --runprefix=$RUNPREFIX    \
                         $ENABLE_MAC_BUNDLE        \
                         $EXTRA_CONF_FLAGS         \
                         --qmake=$QMAKE_CMD        \
                         --cc=$CLANG_CMD           \
                         --cxx=$CLANGPP_CMD        \
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
  echo "------------ Compiling Mythtv ------------"
  #compile mythfrontend
  make || { echo 'Compiling Mythtv failed' ; exit 1; }
fi

echo "------------ Installing Mythtv ------------"
# This is necessary for both standalone and application builds.
# The latter because macdeployqt is told to search for the
# installed binaries at the install prefix
make install

if $BUILD_PLUGINS; then
  echo "------------ Configuring Mythplugins ------------"
  # apply specified patches if flag is set
  if [ "$APPLY_PATCHES" ] && [ -n "$PLUGINS_PATCH_DIR" ]; then
    cd "$PLUGINS_DIR" || exit 1
    for file in "$PLUGINS_PATCH_DIR"/*; do
      if [ -f "$file" ]; then
        echo "    Applying Plugins patch: $file"
        patch -p1 < "$file"
      fi
    done
  fi

  # configure plugins
  cd "$PLUGINS_DIR" || exit 1
  if $SKIP_BUILD; then
    echo "    Skipping mythplugins configure and make"

  else
    CONFIG_CMD="./configure --prefix=$INSTALL_DIR     \
                            --runprefix=$RUNPREFIX    \
                            --qmake=$QMAKE_CMD        \
                            --qmakespecs=$QMAKE_SPECS \
                            --cc=$CLANG_CMD           \
                            --cxx=$CLANGPP_CMD        \
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
    echo "------------ Compiling Mythplugins ------------"
    #compile plugins
    $QMAKE_CMD mythplugins.pro

    #compile mythfrontend
    make || { echo 'Compiling Plugins failed' ; exit 1; }
  fi
  echo "------------ Installing Mythplugins ------------"
  make install
else
  echo "------------ Skipping Mythplugins Compile ------------"
fi

# reactivate ffmpeg if installed
if $FFMPEG_INSTALLED; then
  echo "    Reactivating FFMPEG to avoid a linker issue"
  sudo port activate ffmpeg
fi

if [ -z $ENABLE_MAC_BUNDLE ]; then
  echo "    Mac Bundle disabled - Skipping app bundling commands"
  echo "    Rebasing @rpath to $RUNPREFIX"
  for mythExec in "$INSTALL_DIR/bin"/myth*; do
        echo "     rebasing $mythExec"
        rebaseLibs "$mythExec"
  done
  echo "Done"
  exit 0
fi
# Assume that all commands past this point only apply to app bundling

echo "------------ Copying in Mythfrontend.app icon  ------------"
cd "$APP_DIR" || exit 1
# copy in the icon
cp -RHnp "$APP_DIR/mythfrontend.icns" "$APP_RSRC_DIR/application.icns"

echo "------------ Copying mythtv share directory into executable  ------------"
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p "$APP_RSRC_DIR/share/mythtv"
cp -RHn "$INSTALL_DIR/share/mythtv"/* "$APP_RSRC_DIR"/share/mythtv/

echo "------------ Updating application plist  ------------"
# Update the plist.  Must be done after macdeployqt else macdeployqt gets pointed to the wrong bundle
gsed -i "8c\  <string>application.icns</string>" "$APP_INFO_FILE"
gsed -i "10c\ <string>$APP_BNDL_ID</string>\n <key>CFBundleInfoDictionaryVersion</key>\n  <string>6.0</string>" "$APP_INFO_FILE"
gsed -i "14a\ <key>CFBundleShortVersionString</key>\n <string>$VERS</string>" "$APP_INFO_FILE"
gsed -i "18c\ <string>mythtv</string>\n <key>NSAppleScriptEnabled</key>\n <string>NO</string>\n <key>CFBundleGetInfoString</key>\n  <string></string>\n <key>CFBundleVersion</key>\n  <string>1.0</string>\n  <key>NSHumanReadableCopyright</key>\n <string>MythTV Team</string>" "$APP_INFO_FILE"
gsed -i "34a\ <key>ATSApplicationFontsPath</key>\n  <string>share/mythtv/fonts</string>" "$APP_INFO_FILE"

echo "------------ Copying libmyth* dylibs to Application Bundle ------------"
mkdir -p "$APP_FMWK_DIR/PlugIns"
cp -RHn "$INSTALL_DIR/lib"/*.dylib "$APP_FMWK_DIR"
if $BUILD_PLUGINS; then
  echo "------------ Copying Mythplugins dylibs into app ------------"
  # copy the mythPluins dylibs into the application
  for plugFilePath in "$INSTALL_DIR/lib/mythtv/plugins"/*.dylib; do
    libFileName=$(basename "$plugFilePath")
    echo "    Installing $libFileName into app"
    cp -RHn "$plugFilePath" "$APP_PLUGINS_DIR/"
  done
fi

echo "------------ Deploying QT to Mythfrontend Executable ------------"
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

echo "------------ Update Mythfrontend.app to use internal dylibs ------------"
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

echo "------------ Installing additional mythtv utility executables into Mythfrontend.app  ------------"
# loop over the compiler apps copying in the desired ones for mythfrontend
for helperBinPath in "$INSTALL_DIR/bin"/*; do
  case $helperBinPath in
    *"mythutil"*|*"mythpreviewgen"*)
      # extract the filename from the path
      helperBinFile=$(basename "$helperBinPath")
      helperBinFile=${helperBinFile%.app}
      helperBinPath=$helperBinPath/Contents/MacOS/$helperBinFile
      echo "    Installing $helperBinFile into app"
      # copy into the app
      cp -RHn "$helperBinPath" "$APP_EXE_DIR"/
      # update the dylib links to internal
      installLibs "$APP_EXE_DIR/$helperBinFile"
    ;;
  esac
done

echo "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------"
mkdir -p "$APP_RSRC_DIR/lib"
cp -RHn "$INSTALL_DIR/lib"/python* "$APP_RSRC_DIR"/lib/
cp -RHn "$INSTALL_DIR/lib"/perl* "$APP_RSRC_DIR"/lib/
if [ ! -f "$APP_RSRC_DIR/lib/python" ]; then
  cd "$APP_RSRC_DIR/lib" || exit 1
  ln -s "python$PYTHON_DOT_VERS" python
  cd "$APP_DIR" || exit 1
fi

echo "------------ Deploying python packages into application  ------------"
# make an application from  to package up python and the correct support libraries
mkdir -p "$APP_DIR/PYTHON_APP"
export PYTHONPATH=$INSTALL_DIR/lib/python$PYTHON_DOT_VERS/site-packages
cd "$APP_DIR/PYTHON_APP" || exit 1
if [ -f setup.py ]; then
  rm setup.py
fi

echo "    Creating a temporary application from $MYTHTV_PYTHON_SCRIPT"
# in order to get python embedded in the application we're going to make a temporyary application
# from one of the python scripts which will copy in all the required libraries for running
# and will make a standalone python executable not tied to the system ttvdb4 seems to be more
# particular than others (tmdb3)...
$PY2APPLET_BIN -i "$PY2APP_PKGS" -p "$PY2APP_PKGS" --use-pythonpath --no-report-missing-conditional-import --make-setup "$INSTALL_DIR/share/mythtv/metadata/Television/$MYTHTV_PYTHON_SCRIPT.py"
$PYTHON_VENV_BIN setup.py -q py2app 2>&1 > /dev/null
# now we need to copy over the python app's pieces into the mythfrontend.app to get it working
echo "    Copying in Python Framework libraries"
mv -n "$APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Frameworks"/* "$APP_FMWK_DIR"
echo "    Copying in Python Binary"
mv "$APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/MacOS/python" "$APP_EXE_DIR"
if [ -f "$APP_EXE_DIR/python3" ]; then
  ln -s "$APP_EXE_DIR/pyton" "$APP_EXE_DIR/python3"
fi
echo "    Copying in Python Resources"
mv -n "$APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Resources"/* "$APP_RSRC_DIR"
# clean up temp application
cd "$APP_DIR" || exit 1
rm -Rf "$PYTHON_APP"
echo "    Copying in Site Packages from Virtual Enironment"
cp -RHn "$PYTHON_VENV_PATH/lib/python$PYTHON_DOT_VERS/site-packages"/* "$APP_RSRC_DIR/lib/python$PYTHON_DOT_VERS/site-packages"
# do not need/want py2app in the application
rm -Rf "$APP_RSRC_DIR/lib/python$PYTHON_DOT_VERS/site-packages/py2app"

echo "------------ Replace application perl/python paths to relative paths inside the application   ------------"
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

echo "------------ Copying in dejavu and liberation fonts into Mythfrontend.app   ------------"
# copy in missing fonts
cp -RHn "$PKGMGR_INST_PATH/share/fonts/dejavu-fonts"/*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"
cp -RHn "$PKGMGR_INST_PATH/share/fonts/liberation-fonts"/*.ttf "$APP_RSRC_DIR/share/mythtv/fonts/"

echo "------------ Add symbolic link structure for copied in files  ------------"
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

echo "------------ Searching Applicaition for missing libraries ------------"
# Do one last sweep for missing or rpath linked dylibs in the Framework Directory
for dylib in "$APP_FMWK_DIR"/*.dylib; do
  pathDepList=$(/usr/bin/otool -L "$dylib"|grep -e rpath -e $"PKGMGR_INST_PATH/lib" -e "$INSTALL_DIR")
  if [ -n "$pathDepList" ] ; then
    installLibs "$dylib"
  fi
done

echo "------------ Generating mythfrontend startup script ------------"
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
export PYTHONPATH=\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS:\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS/site-packages:\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS/sites-enabled
PATH=\$(pwd):\$PATH

cd \$BASEDIR
./mythfrontend \$@" > mythfrontend.sh

chmod +x mythfrontend.sh

# Update the plist to use the startup script
gsed -i "6c\        <string>mythfrontend.sh</string>" "$APP_INFO_FILE"

echo "------------ Build Complete ------------"
echo "     Application is located:"
echo "     $APP"
echo "If you intend to distribute the application, then next steps are to codesign
and notarize the appliction using the codesignAndPackage.zsh script with the
following command:"
echo "    ./codesignAndPackage.zsh $APP"
