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
  --python-version=PYTHON_VERS           Desired Python 3 Version (38)
  --version=MYTHTV_VERS                  Requested mythtv git repo (fixes/31)
Build Options
  --update-git=UPDATE_GIT                Update git repositories to latest (true)
Patch Options
  --apply-patches=APPLY_PATCHES          Apply patches specified in additional arguments (false)
  --mythtv-patch-dir=MYTHTV_PATCH_DIR    Directory containing patch files to be applied to Mythtv
  --packaging-patch-dir=PACK_PATCH_DIR   Directory containing patch files to be applied to Packaging
  --plugins-patch-dir=PLUGINS_PATCH_DR   Directory containing patch files to be applied to Mythplugins
Support Ports Options
  --skip-ansible=SKIP_ANSIBLE            Skip downloading ports with ansible (false)
                                         NOTE: Only do this if you are sure you have installed ALL dependencies
  --update-ports=UPDATE_PORTS            Update macports (false)
EOF

  exit 0
}

# setup default variables
BUILD_PLUGINS=false
PYTHON_VERS="38"
UPDATE_PORTS=false
MYTHTV_VERS="fixes/31"
UPDATE_GIT=true
SKIP_ANSIBLE=false
APPLY_PATCHES=false
MYTHTV_PATCH_DIR=""
PACK_PATCH_DIR=""
PLUGINS_PATCH_DIR=""

# parse user inputs into variables
for i in "$@"
do
  case $i in
      -h|--help)
        show_help
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
      --skip-ansible=*)
        SKIP_ANSIBLE="${i#*=}"
      ;;
      --version=*)
        MYTHTV_VERS="${i#*=}"
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

# Specify mythtv version to pull from git
# if we're building on master - get release number from the git tags
# otherwise extract it from the MYTHTV_VERS
case $MYTHTV_VERS in
    master*)
       VERS=$(git ls-remote --tags  git://github.com/MythTV/mythtv.git|tail -n 1)
       VERS=${VERS##*/v}
       VERS=$(echo $VERS|tr -dc '0-9')
    ;;
    *)
      VERS=${MYTHTV_VERS: -2}
    ;;
esac
REPO_DIR=~/mythtv-$VERS
INSTALL_DIR=$REPO_DIR/$VERS-osx-64bit
PYTHON_DOT_VERS="${PYTHON_VERS:0:1}.${PYTHON_VERS:1:4}"
ANSIBLE_PLAYBOOK="ansible-playbook-$PYTHON_DOT_VERS"

# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
APP_DIR=$SRC_DIR/programs/mythfrontend
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins
THEME_DIR=$REPO_DIR/mythtv/myththemes
PKGING_DIR=$REPO_DIR/mythtv/packaging
OSX_PKGING_DIR=$PKGING_DIR/OSX/build
#PKGMGR_INST_PATH=/opt/local
PKG_CONFIG_SYSTEM_INCLUDE_PATH=/opt/local/include
export PATH=/opt/local/lib/mysql57/bin:$PATH
OS_VERS=$(/usr/bin/sw_vers -productVersion)

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
# check if ansible_playbook is installed, if not install it
if ! [ -x "$(command -v $ANSIBLE_PLAYBOOK)" ]; then
  echo Installing python and ansilble
  sudo port -N install py$PYTHON_VERS-ansible
  sudo port select --set python python$PYTHON_VERS
  sudo port select --set python3 python$PYTHON_VERS
  sudo port select --set ansible py$PYTHON_VERS-ansible
else
  echo "skipping ansible install - it is already installed"
fi

# check is gsed is installed (for patching the .plist file)
if ! [ -x "$(command -v gsed)" ]; then
  sudo port -N install gsed
else
    echo "skipping gsed install - it is already installed"
fi

echo "------------ Running Ansible ------------"
if $SKIP_ANSIBLE; then
  echo "Skipping port installation via ansible"
else
  # get mythtv's ansible playbooks, and install required ports
  # if the repo exists, update (assume the flag is set)
  if [ -d "$REPO_DIR/ansible" ]; then
    echo "updating mythtv-anisble git repo"
    cd $REPO_DIR/ansible
    if $UPDATE_GIT; then
      echo "Updating ansible git repo"
      git pull
    else
      echo "Skipping ansible git repo update"
    fi
  # pull down a fresh repo if none exist
  else
    echo "cloning mythtv-anisble git repo"
    git clone https://github.com/MythTV/ansible.git
  fi
  cd $REPO_DIR/ansible
  export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
  $ANSIBLE_PLAYBOOK qt5.yml --ask-become-pass
fi
# get the version of python installed by MacPorts
PYTHON_BIN=$(which python$PYTHON_DOT_VERS)
# also get the location of the framework - /opt/local because this is where MacPorts stores its packages
PYTHON_INSTALL_LOC=/opt/local/Library/Frameworks/Python.framework/Versions/$PYTHON_DOT_VERS/lib/python$PYTHON_DOT_VERS/site-packages


echo "------------ Cloning / Updating Mythtv Git Repository ------------"
# setup mythtv source from git
cd $REPO_DIR
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd $REPO_DIR/mythtv
  if $UPDATE_GIT; then
    echo "Updateing mythtv/mythplugins git repo"
    git pull
  else
      echo "Skipping mythtv/mythplugins git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "cloning mythtv git repo"
  git clone -b $MYTHTV_VERS git://github.com/MythTV/mythtv.git
fi
# apply specified patches
if [ $APPLY_PATCHES ] && [ ! -z $MYTHTV_PATCH_DIR ]; then
  cd $REPO_DIR/mythtv
  for file in $MYTHTV_PATCH_DIR/*
    do
    if [ -f "$file" ]; then
      echo "Applying Mythtv patch: $file"
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
  if $UPDATE_GIT; then
    echo "Update packaging git repo"
    git pull
  else
    echo "Skipping packaging git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "cloning mythtv-packaging git repo"
  git clone -b $MYTHTV_VERS https://github.com/MythTV/packaging.git
fi

# apply any user specified patches if the flag is set
if [ $APPLY_PATCHES ] && [ ! -z $PACK_PATCH_DIR ]; then
  cd $PKGING_DIR
  for file in $PACK_PATCH_DIR/*
    do
    if [ -f "$file" ]; then
      echo "Applying Packaging patch: $file"
      patch -p1 < $file
    fi
  done
fi

echo "------------ Configuring Mythtv ------------"
# configure mythfrontend
cd $SRC_DIR
GIT_VERS=$(git rev-parse --short HEAD)
./configure --prefix=$INSTALL_DIR \
			--runprefix=../Resources \
			--enable-mac-bundle \
			--qmake=/opt/local/libexec/qt5/bin/qmake \
			--cc=clang \
			--cxx=clang++ \
			--extra-cxxflags='-I $SRC_DIR/external -I /opt/local/include' \
			--extra-ldflags='-L $SRC_DIR/external -L /opt/local/lib' \
			--disable-backend \
			--disable-distcc \
			--disable-firewire \
			--enable-libmp3lame \
			--enable-libxvid \
			--enable-libx264 \
			--enable-libx265 \
			--enable-libvpx \
			--enable-bdjava \
	 		--python=$PYTHON_BIN

echo "------------ Compiling Mythtv ------------"
#compile mythfrontend
make
# error out if make failed
if [ $? != 0 ]; then
  echo "Compiling Mythtv failed" >&2
  exit 1
fi
echo "------------ Installing Mythtv ------------"
# need to do a make install or macdeployqt will not copy everything in.
make install

if $BUILD_PLUGINS; then
  echo "------------ Configuring Mythplugins ------------"
  # apply specified patches if flag is set
  if [ $APPLY_PATCHES ] && [ ! -z $PLUGINS_PATCH_DIR ]; then
    cd $PLUGINS_DIR
    for file in $PLUGINS_PATCH_DIR/*
      do
      if [ -f "$file" ]; then
        echo "Applying Plugins patch: $file"
        patch -p1 < $file
      fi
    done
  fi

  # configure plugins
  cd $PLUGINS_DIR
  ./configure --prefix=$INSTALL_DIR \
  			--runprefix=../Resources \
  			--qmake=/opt/local/libexec/qt5/bin/qmake \
  			--cc=clang \
  			--cxx=clang++ \
  			--enable-mythgame \
  			--enable-mythmusic \
   			--enable-fftw \
  			--enable-cdio \
  			--enable-mythnews \
  			--enable-mythweather \
  			--disable-mytharchive \
  			--disable-mythnetvision \
  			--disable-mythzoneminder \
  			--disable-mythzmserver \
  	 		--python=PYTHON_BIN

  echo "------------ Compiling Mythplugins ------------"
  #compile mythfrontend
  /opt/local/libexec/qt5/bin/qmake  mythplugins.pro
  make
  # error out if make failed
  if [ $? != 0 ]; then
    echo "Plugins compile failed" >&2
    exit 1
  fi
  echo "------------ Installing Mythplugins ------------"
  make install
else
  echo "------------ Skipping Mythplugins Compile ------------"
fi

echo "------------ Deploying QT to Mythfrontend Executable ------------"
# Package up the executable
cd $APP_DIR
# run macdeployqt
/opt/local/libexec/qt5/bin/macdeployqt $APP_DIR/mythfrontend.app

echo "------------ Update Mythfrontend.app to use internal dylibs ------------"
# run osx-bundler.pl to copy all of the libraries into the bundle as Frameworks
# we will need to run this utility multiple more time for any plugins and helper apps installed
$OSX_PKGING_DIR/osx-bundler.pl  $APP_DIR/mythfrontend.app/Contents/MacOS/mythfrontend $SRC_DIR/libs/* $INSTALL_DIR/lib/ /opt/local/lib

echo "------------ Installing libcec into Mythfrontend.app ------------"
# copy in libcec (missing for some reason...)
cp /opt/local/lib/libcec.4.*.dylib $APP_DIR/mythfrontend.app/Contents/Frameworks/
install_name_tool -add_rpath "@executable_path/../Frameworks/libcec.4.0.5.dylib" $APP_DIR/mythfrontend.app/Contents/MacOS/mythfrontend
cp /opt/local/lib/libcec.4.dylib $APP_DIR/mythfrontend.app/Contents/Frameworks/
install_name_tool -add_rpath "@executable_path/../Frameworks/libcec.4.dylib" $APP_DIR/mythfrontend.app/Contents/MacOS/mythfrontend
cp /opt/local/lib/libcec.dylib $APP_DIR/mythfrontend.app/Contents/Frameworks/
install_name_tool -add_rpath "@executable_path/../Resources/libcec.dylib" $APP_DIR/mythfrontend.app/Contents/MacOS/mythfrontend

echo "------------ Installing additional mythtv utility executables into Mythfrontend.app  ------------"
# loop over the compiler apps copying in the desired ones for mythfrontend
for helperBinPath in $INSTALL_DIR/bin/*.app
do
  case $helperBinPath in
    *mythmetadatalookup*|*mythreplex*|*mythutil*|*mythpreviewgen*|*mythavtest*)
      # extract the filename from the path
      helperBinFile=$(basename $helperBinPath)
      helperBinFile=${helperBinFile%.app}
      echo "installing $helperBinFile into app"
      # copy into the app
      cp -rp $helperBinPath/Contents/MacOS/$helperBinFile $APP_DIR/mythfrontend.app/Contents/MacOS
      # run osx-bundler.pl to setup and copy support libraries into app framework
      $OSX_PKGING_DIR/osx-bundler.pl  $APP_DIR/mythfrontend.app/Contents/MacOS/$helperBinFile
    ;;
    *)
      continue
    ;;
  esac
done

if $BUILD_PLUGINS; then
  echo "------------ Copying Mythplugins dylibs into app ------------"
      #*libmythpostproc*|*libmythavdevice*|*libmythavfilter*|*libmythpostproc*|*libmythprotoserver*|*libmythswscale*)
  #done

  # Now we need to make the plugin dylibs use the dylibs copied into the app's Framework
  # to do this, we're going to copy them into the app's PlugIns dir and the use osx-bundler.pl to point them to the
  # app frameworks' versions
  for plugFilePath in $INSTALL_DIR/lib/mythtv/plugins/*.dylib
  do
      plugFileName=$(basename $plugFilePath)
      echo "installing $plugFileName into app"
      cp $plugFilePath $APP_DIR/mythfrontend.app/Contents/PlugIns/
      # run osx-bundler.pl to setup and copy support libraries into app framework
      $OSX_PKGING_DIR/osx-bundler.pl  $APP_DIR/mythfrontend.app/Contents/PlugIns/$plugFileName $INSTALL_DIR/libs
  done
fi

echo "------------ Copying mythtv share directory into executable  ------------"
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p $APP_DIR/mythfrontend.app/Contents/Resources/share/mythtv
cp -rp $INSTALL_DIR/share/mythtv/* $APP_DIR/mythfrontend.app/Contents/Resources/share/mythtv/

echo "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------"
mkdir -p $APP_DIR/mythfrontend.app/Contents/Resources/lib
cp -rp $INSTALL_DIR/lib/python* $APP_DIR/mythfrontend.app/Contents/Resources/lib/
cp -rp $INSTALL_DIR/lib/perl* $APP_DIR/mythfrontend.app/Contents/Resources/lib/
if [ ! -f $APP_DIR/mythfrontend.app/Contents/Resources/lib/python ]; then
   cd $APP_DIR/mythfrontend.app/Contents/Resources/lib
   ln -s python$PYTHON_DOT_VERS python
   cd $APP_DIR
fi
echo "------------ Copying additional python modules into application  ------------"
PYTHON_APP_LOC="$APP_DIR/mythfrontend.app/Contents/Resources/lib/python$PYTHON_DOT_VERS/site-packages"
# These libraries were all "dependencies" in MacPorts for the ansible required python-libs
cp -rp $PYTHON_INSTALL_LOC/future* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/requests* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/lxml* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/oauthlib* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/curl* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/simplejson* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/wheel* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/PyMySQL* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/pymysql* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/chardet* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/idna* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/urllib3* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/certifi* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/blinker* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/cryptography* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/jwt* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/asn1crypto* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/six* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/cffi* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/pycparser* $PYTHON_APP_LOC
cp -rp $PYTHON_INSTALL_LOC/pycurl* $PYTHON_APP_LOC
# need to copy py-mysqlclient over to the app, but theres a chance that is may have been installed by either
# MacPorts or Pip - if it exists, copy the MacPorts version over otherwise the pip version.
if [ -d $PYTHON_INSTALL_LOC/MySQLdb ]; then
    cp -rp $PYTHON_INSTALL_LOC/mysqlclient* $PYTHON_APP_LOC
    cp -rp $PYTHON_INSTALL_LOC/MySQLdb* $PYTHON_APP_LOC
else
    ~/Library/Python/$PYTHON_DOT_VERS/lib/python/site-packages/MySQLdb* $PYTHON_APP_LOC
    ~/Library/Python/$PYTHON_DOT_VERS/lib/python/site-packages/mysqlclient* $PYTHON_APP_LOC
fi
# Now we need to make sure any python .so dependencies get copied into as a framework and linked
#for file in $(find $PYTHON_APP_LOC -name "*.so")
#  do
#    echo "installing $(basename $file) support libraries into app"
#    $OSX_PKGING_DIR/osx-bundler.pl $file $INSTALL_DIR/libs /opt/local/lib
#done

echo "------------ Copying in dejavu and liberation fonts into Mythfrontend.app   ------------"
# copy in missing fonts
cp /opt/local/share/fonts/dejavu-fonts/*.ttf $APP_DIR/mythfrontend.app/Contents/Resources/share/mythtv/fonts/
cp /opt/local/share/fonts/liberation-fonts/*.ttf $APP_DIR/mythfrontend.app/Contents/Resources/share/mythtv/fonts/

echo "------------ Copying in Mythfrontend.app icon  ------------"
# copy in the icon
cp mythfrontend.icns $APP_DIR/mythfrontend.app/Contents/Resources/application.icns

echo "------------ Add symbolic link structure for copied in files  ------------"
# make some symbolic links to match past working copies
cd $APP_DIR/mythfrontend.app/Contents/MacOS
if $BUILD_PLUGINS; then
  ln -s ../PlugIns/sqldrivers .
fi
cd $APP_DIR/mythfrontend.app/Contents/Resources
ln -s ../MacOS bin
if $BUILD_PLUGINS; then
  mkdir -p $APP_DIR/mythfrontend.app/Contents/Resources/lib/mythtv
  cd $APP_DIR/mythfrontend.app/Contents/Resources/lib/mythtv
  ln -s ../../../PlugIns plugins
fi

echo "------------ Updating application plist  ------------"
# Update the plist
gsed -i "8c\	<string>application.icns</string>" $APP_DIR/mythfrontend.app/Contents/Info.plist
gsed -i "10c\	<string>org.osx-bundler.mythfrontend</string>\n	<key>CFBundleInfoDictionaryVersion</key>\n	<string>6.0</string>" $APP_DIR/mythfrontend.app/Contents/Info.plist
gsed -i "14a\	<key>CFBundleShortVersionString</key>\n	<string>$VERS</string>" $APP_DIR/mythfrontend.app/Contents/Info.plist
gsed -i "18c\	<string>osx-bundler</string>\n	<key>NSAppleScriptEnabled</key>\n	<string>NO</string>\n	<key>CFBundleGetInfoString</key>\n	<string></string>\n	<key>CFBundleVersion</key>\n	<string>1.0</string>\n	<key>NSHumanReadableCopyright</key>\n	<string>MythTV Team</string>" $APP_DIR/mythfrontend.app/Contents/Info.plist

echo "------------ Generating .dmg file  ------------"
# Package up the build
cd $APP_DIR
if $BUILD_PLUGINS; then
    VOL_NAME=MythFrontend-$VERS-intel-$OS_VERS-v$VERS-$GIT_VERS-with-plugins
else
    VOL_NAME=MythFrontend-$VERS-intel-$OS_VERS-v$VERS-$GIT_VERS
fi
if [ -f $APP_DIR/$VOL_NAME.dmg ] ; then
    mv $APP_DIR/$VOL_NAME.dmg $APP_DIR/$VOL_NAME$(date +'%d%m%Y%H%M%S').dmg
fi
hdiutil create $APP_DIR/$VOL_NAME.dmg -fs HFS+ -srcfolder $APP_DIR/Mythfrontend.app -volname $VOL_NAME
