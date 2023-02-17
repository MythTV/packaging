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
  --generate-dmg=GENERATE_DMG            Generate a DMG file for distribution (false)
Build Options
  --update-git=UPDATE_GIT                Update git repositories to latest (true)
  --skip-build=SKIP_BUILD                Skip configure and make - used when you just want to repackage (false)
  --macports-clang=MP_CLANG              Flag to specify clang version to build with (default)
  --extra-conf-flags=XTRA_CONF_FLAGS     Addtional configure flags for mythtv ("")
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

OS_VERS=$(/usr/bin/sw_vers -productVersion)
OS_MAJOR=(${(@s:.:)OS_VERS})
OS_MINOR=$OS_MAJOR[2]
OS_MAJOR=$OS_MAJOR[1]

# setup default variables
BUILD_PLUGINS=false
PYTHON_VERS="311"
UPDATE_PORTS=false
MYTHTV_VERS="master"
MYTHTV_PYTHON_SCRIPT="ttvdb4"
QT_VERS=qt5
GENERATE_APP=true
GENERATE_DMG=false
UPDATE_GIT=true
SKIP_BUILD=false
MP_CLANG=default
XTRA_CONF_FLAGS=""
APPLY_PATCHES=false
MYTHTV_PATCH_DIR=""
PACK_PATCH_DIR=""
PLUGINS_PATCH_DIR=""
REPO_PREFIX=$HOME

# maports doesn't support mysql 8 for older versions of macOS, for those installs default to mariadb (unless the user overries)
if [ $OS_MAJOR -le 11 ] && [ $OS_MINOR -le 15 ]; then
  DATABASE_VERS=mariadb-10.5
else
  DATABASE_VERS=mysql8
fi

# parse user inputs into variables
for i in "$@"; do
  case $i in
      -h|--help)
        show_help ${MYTHTV_VERS} ${PYTHON_VERS} ${MYTHTV_VERS} ${QT_VERS}
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
        XTRA_CONF_FLAGS="${i#*=}"
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
      --generate-dmg=*)
        GENERATE_DMG="${i#*=}"
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
        echo "Unknown option $i"
              # unknown option
        exit 1
      ;;
  esac
done

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

# Specify mythtv version to pull from git
# if we're building on master - get release number from the git tags
# otherwise extract it from the MYTHTV_VERS
case $MYTHTV_VERS in
    master*)
      VERS=$(git ls-remote --tags  https://github.com/MythTV/mythtv.git|tail -n 1)
      VERS=${VERS##*/v}
      VERS=$(echo $VERS|tr -dc '0-9')
      EXTRA_MYTHPLUGIN_FLAG=""
    ;;
    *32*|*31*)
      VERS=${MYTHTV_VERS: -2}
      EXTRA_MYTHPLUGIN_FLAG="--enable-fftw"
    ;;
    *)
      VERS=${MYTHTV_VERS: -2}
      EXTRA_MYTHPLUGIN_FLAG=""
esac
ARCH=$(/usr/bin/uname -m)
REPO_DIR=$REPO_PREFIX/mythtv-$VERS


if $GENERATE_APP; then
  ENABLE_MAC_BUNDLE="--enable-mac-bundle"
  INSTALL_DIR=$REPO_DIR/$VERS-osx-64bit
  RUNPREFIX=../Resources
else
  ENABLE_MAC_BUNDLE=""
  INSTALL_DIR=$PKGMGR_INST_PATH
  RUNPREFIX=$INSTALL_DIR
fi

case $MP_CLANG in
    clang-mp*)
      CLANG_CMD=$PKGMGR_INST_PATH/bin/$MP_CLANG
      CLANGPP_CMD=$PKGMGR_INST_PATH/bin/${MP_CLANG//clang/clang++}
      # check is specified compiler is installed 
      if ! [ -x "$(command -v $CLANG_CMD)" ]; then
        CLANG_PORT=${MP_CLANG//clang-mp/clang}
        sudo port -N install $CLANG_PORT
      fi
    ;;
    *)
      CLANG_CMD="clang"
      CLANGPP_CMD="clang++"
    ;;
esac

# Add some flags for the compiler to find the package manager locations
export LDFLAGS="-L$PKGMGR_INST_PATH/libexec/$QT_VERS/lib -L$PKGMGR_INST_PATH/lib"
export C_INCLUDE_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$PKGMGR_INST_PATH/include/libhdhomerun:$PKGMGR_INST_PATH/include/glslang
export CPLUS_INCLUDE_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS/include/:$PKGMGR_INST_PATH/include:$PKGMGR_INST_PATH/include/libbluray:$PKGMGR_INST_PATH/include/libhdhomerun:$PKGMGR_INST_PATH/include/glslang
export LIBRARY_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS/lib/:$PKGMGR_INST_PATH/lib

# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins
THEME_DIR=$REPO_DIR/mythtv/myththemes
PKGING_DIR=$REPO_DIR/mythtv/packaging
OSX_PKGING_DIR=$PKGING_DIR/OSX/build
export PATH=$PKGMGR_INST_PATH/lib/$DATABSE_VERS/bin:$PATH

# macOS internal appliction paths
APP_DIR=$SRC_DIR/programs/mythfrontend
APP=$APP_DIR/mythfrontend.app
APP_RSRC_DIR=$APP/Contents/Resources
APP_FMWK_DIR=$APP/Contents/Frameworks
APP_EXE_DIR=$APP/Contents/MacOS
APP_PLUGINS_DIR=$APP_FMWK_DIR/PlugIns/
APP_INFO_FILE=$APP/Contents/Info.plist
# Tell pkg_config to ignore the paths for the package manager
PKG_CONFIG_SYSTEM_INCLUDE_PATH=$PKGMGR_INST_PATH/include
APP_DFLT_BNDL_ID="org.mythtv.mythfrontend"


# installLibs finds all @rpath dylibs for the input binary/dylib
# copying any missing ones in the application's FrameWork directory
# then updates the binary/dylib's internal link to point to copy location
installLibs(){
  binFile=$1
  # find all externally-linked lib
  pathDepList=$(/usr/bin/otool -L $binFile|grep -e rpath -e $PKGMGR_INST_PATH/lib -e $INSTALL_DIR)
  pathDepList=$(echo $pathDepList| gsed 's/(.*//')
  # loop over each lib
  while read -r dep; do
    lib=${dep##*/}
    # we have multiple types of libs to work with, QT5, QT6, package managed, and mythtv
    # setup the correct source / destination / linking schema for each
    case "$dep" in
      *Qt*)
        case "$QT_VERS" in
          *qt5*)
            sourcePath="$QT_PATH/lib/$lib.framework"
            destinPath=$APP_FMWK_DIR
            newLink="@executable_path/../Frameworks/$lib.framework/Versions/5/$lib"
          ;;
          *)
            sourcePath="$QT_PATH/lib/$lib.framework/Versions/Current/$lib"
            destinPath=$APP_FMWK_DIR
            newLink="@executable_path/../Frameworks/$lib"
          ;;
        esac
      ;;
      *libmyth*|*$INSTALL_DIR*)
        sourcePath=$INSTALL_DIR/lib
        destinPath=$APP_FMWK_DIR
        newLink="@executable_path/../Frameworks/$lib"
      ;;
      *$PKGMGR_INST_PATH*)
        sourcePath=$PKGMGR_INST_PATH/lib
        destinPath=$APP_FMWK_DIR
        newLink="@executable_path/../Frameworks/$lib"
      ;;
    esac
    # check to see if the lib is already copied in, if not do so
    if [ ! -f "$destinPath/$lib" ] && [ ! -f "$destinPath/$lib.framework" ] ; then
      echo "    Installing $lib into app"
      cp -RH $sourcePath/$lib $destinPath
    fi
    # update the link in the app/executable to the new interal Framework
    echo "    Updating $lib link to internal lib"
    # its already been copied in, we just need to update the link
    install_name_tool -change $dep $newLink $binFile
  done <<< "$pathDepList"
}

rebaseLibs(){
    binFile=$1
    rpathDepList=$(/usr/bin/otool -L $binFile|grep rpath)
    rpathDepList=$(echo $rpathDepList| gsed 's/(.*//')
    while read -r dep; do
        lib=${dep##*/}
        if [ -n $lib ]; then
            install_name_tool -change $dep $RUNPREFIX/lib/$lib $binFile
        fi
    done <<< "$rpathDepList"
}

# Function used to convert version strings into integers for comparison
version (){
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

# Select the correct QT version of tools / libraries
case $QT_VERS in
    qt5)
       QT_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS
       QMAKE_CMD=$QT_PATH/bin/qmake
       QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
       ANSIBLE_QT=mythtv.yml
    ;;
    *)
       QT_PATH=$PKGMGR_INST_PATH/libexec/$QT_VERS
       QMAKE_CMD=$QT_PATH/bin/qmake6
       QMAKE_SPECS=$QT_PATH/mkspecs/macx-clang
       ANSIBLE_QT=mythtv.yml
       echo "!!!!! Building with Qt6 - disabling plugins !!!!!"
       BUILD_PLUGINS=false
    ;;
esac

echo "------------ Setting Up Directory Structure ------------"
# setup the working directory structure
mkdir -p $REPO_DIR
cd $REPO_DIR
# create the install temporary directory
mkdir -p $INSTALL_DIR

# install and configure ansible and gsed
# ansible to install the missing required ports,
# gsed for the plist update later
echo "------------ Setting Up Initial Ports for Ansible ------------"
if $UPDATE_PORTS; then
  # tell macport to retrieve the latest repo
  sudo port selfupdate
  % upgrade all outdated ports
  sudo port upgrade
fi
# check if ANSIBLE_PB_EXE is installed, if not install it
if ! [ -x "$(command -v $ANSIBLE_PB_EXE)" ]; then
  echo "    Installing python and ansilble"
  sudo port -N install py$PYTHON_VERS-ansible
  sudo port select --set python python$PYTHON_VERS
  sudo port select --set python3 python$PYTHON_VERS
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
    cd $REPO_DIR/ansible
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
  cd $REPO_DIR/ansible
  export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
  ANSIBLE_FLAGS="--limit=localhost  --ask-become-pass"

  case $QT_VERS in
      qt5)
         ANSIBLE_EXTRA_FLAGS="--extra-vars 'ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS install_qtwebkit=$BUILD_PLUGINS'"
      ;;
      *)
         ANSIBLE_EXTRA_FLAGS="--extra-vars ansible_python_interpreter=$PYTHON_PKMGR_BIN database_version=$DATABASE_VERS" 
      ;;
  esac
  $ANSIBLE_PB_EXE $ANSIBLE_QT $ANSIBLE_FLAGS 
fi

echo "------------ Source the Python Virtual Environment ------------"
source "$PYTHON_VENV_PATH/bin/activate"
PYTHON_VENV_BIN=$PYTHON_VENV_PATH/bin/python3
PY2APPLET_BIN=$PYTHON_VENV_PATH/bin/py2applet

echo "------------ Cloning / Updating Mythtv Git Repository ------------"
# setup mythtv source from git
cd $REPO_DIR
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd $REPO_DIR/mythtv
  if $UPDATE_GIT && ! $SKIP_BUILD ; then
    echo "    Updating mythtv/mythplugins git repo"
    git pull
  else
    echo "    Skipping mythtv/mythplugins git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "    Cloning mythtv git repo"
  git clone -b $MYTHTV_VERS https://github.com/MythTV/mythtv.git
fi
# apply specified patches
if [ $APPLY_PATCHES ] && [ ! -z $MYTHTV_PATCH_DIR ]; then
  cd $REPO_DIR/mythtv
  for file in $MYTHTV_PATCH_DIR/*; do
    if [ -f "$file" ]; then
      echo "    Applying Mythtv patch: $file"
      patch -p1 < $file
    fi
  done
fi

echo "------------ Cloning / Updating Packaging Git Repository ------------"
# get packaging
cd $REPO_DIR/mythtv
# check if the repo exists and update (if the flag is set)
if [ -d $PKGING_DIR ]; then
  cd $PKGING_DIR
  if $UPDATE_GIT  && ! $SKIP_BUILD; then
    echo "    Update packaging git repo"
    git pull
  else
    echo "    Skipping packaging git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "    Cloning mythtv-packaging git repo"
  git clone -b $MYTHTV_VERS https://github.com/MythTV/packaging.git
fi

# apply any user specified patches if the flag is set
if [ $APPLY_PATCHES ] && [ ! -z $PACK_PATCH_DIR ]; then
  cd $PKGING_DIR
  for file in $PACK_PATCH_DIR/*; do
    if [ -f "$file" ]; then
      echo "    Applying Packaging patch: $file"
      patch -p1 < $file
    fi
  done
fi

echo "------------ Configuring Mythtv ------------"
# configure mythfrontend
cd $SRC_DIR
if [ -d $APP ]; then
  echo "    Cleaning up past Mythfrontend application"
  rm -Rf $APP
fi
GIT_VERS=$(git rev-parse --short HEAD)
if $SKIP_BUILD; then
  echo "    Skipping mythtv configure and make"
else
  ./configure --prefix=$INSTALL_DIR \
              --runprefix=$RUNPREFIX \
              $ENABLE_MAC_BUNDLE \
              $XTRA_CONF_FLAGS \
              --qmake=$QMAKE_CMD \
              --cc=$CLANG_CMD \
              --cxx=$CLANGPP_CMD \
              --disable-backend \
              --disable-distcc \
              --disable-lirc \
              --disable-firewire \
              --disable-libcec \
              --disable-x11 \
              --enable-libmp3lame \
              --enable-libxvid \
              --enable-libx264 \
              --enable-libx265 \
              --enable-libvpx \
              --enable-bdjava \
              --python=$PYTHON_VENV_BIN
  echo "------------ Compiling Mythtv ------------"
  #compile mythfrontend
  make
  # error out if make failed
  if [ $? != 0 ]; then
    echo "    Compiling Mythtv failed" >&2
    exit 1
  fi
fi

echo "------------ Installing Mythtv ------------"
# need to do a make install or macdeployqt will not copy everything in.
make install

if $BUILD_PLUGINS; then
  echo "------------ Configuring Mythplugins ------------"
  # apply specified patches if flag is set
  if [ $APPLY_PATCHES ] && [ ! -z $PLUGINS_PATCH_DIR ]; then
    cd $PLUGINS_DIR
    for file in $PLUGINS_PATCH_DIR/*; do
      if [ -f "$file" ]; then
        echo "    Applying Plugins patch: $file"
        patch -p1 < $file
      fi
    done
  fi

  # configure plugins
  cd $PLUGINS_DIR
  if $SKIP_BUILD; then
    echo "    Skipping mythplugins configure and make"

  else
    ./configure --prefix=$INSTALL_DIR \
                --runprefix=$RUNPREFIX \
                --qmake=$QMAKE_CMD \
                --qmakespecs=$QMAKE_SPECS \
                --cc=$CLANG_CMD \
                --cxx=$CLANGPP_CMD \
                --enable-mythgame \
                --enable-mythmusic \
                --enable-cdio \
                --enable-mythnews \
                --enable-mythweather \
                --disable-mytharchive \
                --disable-mythnetvision \
                --disable-mythzoneminder \
                --disable-mythzmserver \
                --python=$PYTHON_VENV_BIN \
                $EXTRA_MYTHPLUGIN_FLAG
    echo "------------ Compiling Mythplugins ------------"
    #compile plugins
    $QMAKE_CMD mythplugins.pro
    make
    # error out if make failed
    if [ $? != 0 ]; then
      echo "    Plugins compile failed" >&2
      exit 1
    fi
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
  for mythExec in $INSTALL_DIR/bin/myth*; do
        echo "     rebasing $mythExec"
        rebaseLibs $mythExec
  done
  echo "Done"
  exit 0
fi
# Assume that all commands past this point only apply to app bundling

echo "------------ Update Mythfrontend.app to use internal dylibs ------------"
# find all mythtv dylibs linked via @rpath in mythfrontend, move them into the
# application application Framwork dir and update the internal link to point to
# the application
cd $APP_EXE_DIR
mkdir $APP_FMWK_DIR
installLibs "$APP_EXE_DIR/mythfrontend"
mkdir $APP_PLUGINS_DIR

if $BUILD_PLUGINS; then
  echo "------------ Copying Mythplugins dylibs into app ------------"
  # copy the mythPluins dylibs into the application
  for plugFilePath in $INSTALL_DIR/lib/mythtv/plugins/*.dylib; do
    libFileName=$(basename $plugFilePath)
    echo "    Installing $libFileName into app"
    cp $plugFilePath $APP_PLUGINS_DIR
    installLibs "$APP_PLUGINS_DIR/$libFileName"
  done
fi

echo "------------ Installing additional mythtv utility executables into Mythfrontend.app  ------------"
# loop over the compiler apps copying in the desired ones for mythfrontend
for helperBinPath in $INSTALL_DIR/bin/*.app; do
  case $helperBinPath in
    *mythutil*|*mythpreviewgen*)
      # extract the filename from the path
      helperBinFile=$(basename $helperBinPath)
      helperBinFile=${helperBinFile%.app}
      echo "    Installing $helperBinFile into app"
      # copy into the app
      cp -RHp $helperBinPath/Contents/MacOS/$helperBinFile $APP_EXE_DIR
      installLibs "$APP_EXE_DIR/$helperBinFile"
    ;;
    *)
      continue
    ;;
  esac
done

echo "------------ Copying in Mythfrontend.app icon  ------------"
cd $APP_DIR
# copy in the icon
cp $APP_DIR/mythfrontend.icns $APP_RSRC_DIR/application.icns

echo "------------ Copying mythtv share directory into executable  ------------"
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p $APP_RSRC_DIR/share/mythtv
cp -RHp $INSTALL_DIR/share/mythtv/* $APP_RSRC_DIR/share/mythtv/

echo "------------ Updating application plist  ------------"
# Update the plist
gsed -i "8c\	<string>application.icns</string>" $APP_INFO_FILE
gsed -i "10c\	<string>$APP_BNDL_ID</string>\n	<key>CFBundleInfoDictionaryVersion</key>\n	<string>6.0</string>" $APP_INFO_FILE
gsed -i "14a\	<key>CFBundleShortVersionString</key>\n	<string>$VERS</string>" $APP_INFO_FILE
gsed -i "18c\	<string>mythtv</string>\n	<key>NSAppleScriptEnabled</key>\n	<string>NO</string>\n	<key>CFBundleGetInfoString</key>\n	<string></string>\n	<key>CFBundleVersion</key>\n	<string>1.0</string>\n	<key>NSHumanReadableCopyright</key>\n	<string>MythTV Team</string>" $APP_INFO_FILE
gsed -i "34a\	<key>ATSApplicationFontsPath</key>\n	<string>share/mythtv/fonts</string>" $APP_INFO_FILE

echo "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------"
mkdir -p $APP_RSRC_DIR/lib
cp -RHp $INSTALL_DIR/lib/python* $APP_RSRC_DIR/lib/
cp -RHp $INSTALL_DIR/lib/perl* $APP_RSRC_DIR/lib/
if [ ! -f $APP_RSRC_DIR/lib/python ]; then
  cd $APP_RSRC_DIR/lib
  ln -s python$PYTHON_DOT_VERS python
  cd $APP_DIR
fi

echo "------------ Deploying python packages into application  ------------"
# make an application from  to package up python and the correct support libraries
mkdir -p $APP_DIR/PYTHON_APP
export PYTHONPATH=$INSTALL_DIR/lib/python$PYTHON_DOT_VERS/site-packages
cd $APP_DIR/PYTHON_APP
if [ -f setup.py ]; then
  rm setup.py
fi

echo "    Creating a temporary application from $MYTHTV_PYTHON_SCRIPT"
# in order to get python embedded in the application we're going to make a temporyary application
# from one of the python scripts which will copy in all the required libraries for running
# and will make a standalone python executable not tied to the system ttvdb4 seems to be more
# particular than others (tmdb3)...
$PY2APPLET_BIN -i $PY2APP_PKGS -p $PY2APP_PKGS --use-pythonpath --no-report-missing-conditional-import --make-setup $INSTALL_DIR/share/mythtv/metadata/Television/$MYTHTV_PYTHON_SCRIPT.py
$PYTHON_VENV_BIN setup.py -q py2app 2>&1 > /dev/null
# now we need to copy over the python app's pieces into the mythfrontend.app to get it working
echo "    Copying in Python Framework libraries"
mv -n $APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Frameworks/* $APP_FMWK_DIR
echo "    Copying in Python Binary"
mv $APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/MacOS/python $APP_EXE_DIR
if [ -f "$APP_EXE_DIR/python3" ]; then
  ln -s $APP_EXE_DIR/pyton $APP_EXE_DIR/python3
fi
echo "    Copying in Python Resources"
mv -n $APP_DIR/PYTHON_APP/dist/$MYTHTV_PYTHON_SCRIPT.app/Contents/Resources/* $APP_RSRC_DIR
# clean up temp application
cd $APP_DIR
rm -Rf PYTHON_APP
echo "    Copying in Site Packages from Virtual Enironment"
cp -RL $PYTHON_VENV_PATH/lib/python$PYTHON_DOT_VERS/site-packages/* $APP_RSRC_DIR/lib/python$PYTHON_DOT_VERS/site-packages 
# do not need/want py2app in the application
rm -Rf $APP_RSRC_DIR/lib/python$PYTHON_DOT_VERS/site-packages/py2app

echo "------------ Replace application perl/python paths to relative paths inside the application   ------------"
# mythtv "fixes" the shebang in all python scripts to an absolute path on the compiling system.  We need to
# change this to a relative path pointint internal to the application.
# Note - when MacOS apps run, their starting path is the path as the directory the .app is stored in

cd $APP_RSRC_DIR/share/mythtv/metadata
# edit the items that point to INSTALL_DIR
sedSTR=s#$INSTALL_DIR#../Resources#g
grep -rlI $INSTALL_DIR $APP_RSRC_DIR | xargs gsed -i $sedSTR

# edit those that point to $SRC_DIR/programs/scripts/
sedSTR=s#$PYTHON_VENV_BIN#python#g
grep -rlI $PYTHON_VENV_BIN $APP_RSRC_DIR | xargs gsed -i $sedSTR
sedSTR=s#$PYTHON_PKMGR_BIN#python#g
grep -rlI $PYTHON_PKMGR_BIN $APP_RSRC_DIR | xargs gsed -i $sedSTR

echo "------------ Copying in dejavu and liberation fonts into Mythfrontend.app   ------------"
# copy in missing fonts
cp $PKGMGR_INST_PATH/share/fonts/dejavu-fonts/*.ttf $APP_RSRC_DIR/share/mythtv/fonts/
cp $PKGMGR_INST_PATH/share/fonts/liberation-fonts/*.ttf $APP_RSRC_DIR/share/mythtv/fonts/

echo "------------ Add symbolic link structure for copied in files  ------------"
# make some symbolic links to match past working copies
if $BUILD_PLUGINS; then
  mkdir -p $APP_RSRC_DIR/lib/mythtv
  cd $APP_RSRC_DIR/lib/mythtv
  ln -s ../../../Frameworks/PlugIns plugins
fi

echo "------------ Deploying QT to Mythfrontend Executable ------------"
# Do this last in case we want to codesign later
# Package up the executable
cd $APP_DIR
$QT_PATH/bin/macdeployqt $APP \
                    -libpath=$INSTALL_DIR/lib/\
                    -libpath=$PKGMGR_INST_PATH/lib\
                    -libpath=$QT_PATH/lib

# move the QT PlugIns into the App's framework to pass app signing
# we'll set the QT_QPA_PLATFORM_PLUGIN_PATH to point the app to the new location
mv $APP/Contents/PlugIns/* $APP_PLUGINS_DIR
gsed -i "2c\Plugins = Frameworks/PlugIns" $APP_RSRC_DIR/qt.conf

echo "------------ Searching Applicaition for missing libraries ------------"
# Do one last sweep for missing dylibs in the Framework Directory
for dylib in $APP_FMWK_DIR/*.dylib; do
  pathDepList=$(/usr/bin/otool -L $dylib|grep -e $PKGMGR_INST_PATH/lib -e $INSTALL_DIR)
  if [ ! -z $pathDepList ] ; then
    installLibs $dylib
  fi
done

echo "------------ Generating mythfrontend startup script ------------"
# since we now have python installed internally, we need to make sure that the mythfrontend
# executable launched from the curret directory so that the python relative paths point int
# to the internal python
# We need to do this step after macdeployqt since the startup script breaks macdeployqt
cd $APP_EXE_DIR
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
gsed -i "6c\        <string>mythfrontend.sh</string>" $APP_INFO_FILE

# only generate the DMG here if requested
if $GENERATE_DMG; then
  cd $APP_DIR
  echo "------------ Generating .dmg file  ------------"
  # Package up the build
  if $BUILD_PLUGINS; then
    VOL_NAME=MythFrontend-$VERS-$ARCH-$OS_VERS-v$VERS-$GIT_VERS-with-plugins
  else
    VOL_NAME=MythFrontend-$VERS-$ARCH-$OS_VERS-v$VERS-$GIT_VERS
  fi
  # Archive off any previous files
  if [ -f $VOL_NAME.dmg ] ; then
      mv $VOL_NAME.dmg $VOL_NAME$(date +'%d%m%Y%H%M%S').dmg
  fi
  # Generate the .dmg file
  hdiutil create $VOL_NAME.dmg -fs HFS+ -srcfolder $APP -volname $VOL_NAME
fi

echo "------------ Build Complete ------------"
echo "     Application is located:"
echo "     $APP"
if $GENERATE_DMG; then
  echo "     DMG is located:"
  echo "     $APP_DIR/$VOL_NAME.dmg"
fi
echo ""
echo "If you intend to distribute the application, then next steps are to codesign
and notarize the appliction using the codesignAndPackage.zsh script with the
following command:"
echo "    codesignAndPackage.zsh $APP"
