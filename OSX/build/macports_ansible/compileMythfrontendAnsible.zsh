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
  --database-version=DATABASE_VERS       Requested version of mariadb/mysql to build agains (mariadb-10.2)
Build Options
  --update-git=UPDATE_GIT                Update git repositories to latest (true)
  --skip-build=SKIP_BUILD                Skip configure and make - used when you just want to repackage (false)
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
MYTHTV_VERS="master"
DATABASE_VERS=mariadb-10.2
UPDATE_GIT=true
SKIP_BUILD=false
SKIP_ANSIBLE=false
APPLY_PATCHES=false
MYTHTV_PATCH_DIR=""
PACK_PATCH_DIR=""
PLUGINS_PATCH_DIR=""

# parse user inputs into variables
for i in "$@"; do
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
      --skip-build=*)
        SKIP_BUILD="${i#*=}"
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
PKGMGR_INST_PATH=/opt/local
PKG_CONFIG_SYSTEM_INCLUDE_PATH=$PKGMGR_INST_PATH/include

# setup some paths to make the following commands easier to understand
SRC_DIR=$REPO_DIR/mythtv/mythtv
PLUGINS_DIR=$REPO_DIR/mythtv/mythplugins
THEME_DIR=$REPO_DIR/mythtv/myththemes
PKGING_DIR=$REPO_DIR/mythtv/packaging
OSX_PKGING_DIR=$PKGING_DIR/OSX/build
export PATH=$PKGMGR_INST_PATH/lib/$DATABSE_VERS/bin:$PATH
OS_VERS=$(/usr/bin/sw_vers -productVersion)

# macOS internal appliction paths
APP_DIR=$SRC_DIR/programs/mythfrontend
APP_RSRC_DIR=$APP_DIR/mythfrontend.app/Contents/Resources
APP_FMWK_DIR=$APP_DIR/mythfrontend.app/Contents/Frameworks
APP_EXE_DIR=$APP_DIR/mythfrontend.app/Contents/MacOS
APP_PLUGINS_DIR=$APP_DIR/mythfrontend.app/Contents/PlugIns/
APP_INFO_FILE=$APP_DIR/mythfrontend.app/Contents/Info.plist

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
  echo "    Installing python and ansilble"
  sudo port -N install py$PYTHON_VERS-ansible
  sudo port select --set python python$PYTHON_VERS
  sudo port select --set python3 python$PYTHON_VERS
  sudo port select --set ansible py$PYTHON_VERS-ansible
else
  echo "    Skipping ansible install - it is already installed"
fi

# check is gsed is installed (for patching the .plist file)
if ! [ -x "$(command -v gsed)" ]; then
  sudo port -N install gsed
else
    echo "    Skipping gsed install - it is already installed"
fi

echo "------------ Running Ansible ------------"
if $SKIP_ANSIBLE || $SKIP_BUILD; then
  echo "    Skipping port installation via ansible"
else
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
  $ANSIBLE_PLAYBOOK qt5.yml --extra-vars "database_version=$DATABASE_VERS" --ask-become-pass
fi
# get the version of python installed by MacPorts
PYTHON_BIN=$(which python$PYTHON_DOT_VERS)
PYTHON_RUNTIME_BIN="./python$PYTHON_DOT_VERS"
PY2APPLET_BIN=$(dirname $PYTHON_BIN)/py2applet-$PYTHON_DOT_VERS

# also get the location of the framework - /opt/local because this is where MacPorts stores its packages
# and its site packages
PYTHON_MACOS_FWRK=$PKGMGR_INST_PATH/Library/Frameworks/Python.framework
PYTHON_MACOS_SP_LOC=$PYTHON_MACOS_FWRK/Versions/$PYTHON_DOT_VERS/lib/python$PYTHON_DOT_VERS/site-packages

# and the destination for where the python bits get copied into the application framework and site_packages
PYTHON_APP_FWRK=$APP_FMWK_DIR/Python.framework
PYTHON_APP_SP_LOC="$APP_RSRC_DIR/lib/python$PYTHON_DOT_VERS/site-packages"
# list of packages necessary to run python bindings / scripts
PYTHON_RUNTIME_PKGS="MySQLdb,lxml,urllib3,simplejson,pycurl,future,httplib2"

# install py2app if not already installed - we'll use this go get a portable version of python for the application
if ! [ -x "$(command -v $PY2APPLET_BIN)" ]; then
  sudo port -N install py$PYTHON_VERS-py2app
else
    echo "    Skipping py2app install - it is already installed"
fi

echo "------------ Cloning / Updating Mythtv Git Repository ------------"
# setup mythtv source from git
cd $REPO_DIR
# if the repo exists, update it (assuming the flag is set)
if [ -d "$REPO_DIR/mythtv" ]; then
  cd $REPO_DIR/mythtv
  if $UPDATE_GIT && ! $SKIP_BUILD ; then
    echo "    Updateing mythtv/mythplugins git repo"
    git pull
  else
      echo "    Skipping mythtv/mythplugins git repo update"
  fi
# else pull down a fresh copy of the repo from github
else
  echo "    Cloning mythtv git repo"
  git clone -b $MYTHTV_VERS git://github.com/MythTV/mythtv.git
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
if [ -d $APP_DIR/mythfrontend.app ]; then
  echo "    Cleaning up past Mythfrontend application"
  rm -Rf $APP_DIR/mythfrontend.app
fi
GIT_VERS=$(git rev-parse --short HEAD)
if $SKIP_BUILD; then
  echo "    Skipping mythtv configure and make"
else
    ./configure --prefix=$INSTALL_DIR \
    			--runprefix=../Resources \
    			--enable-mac-bundle \
    			--qmake=$PKGMGR_INST_PATH/libexec/qt5/bin/qmake \
    			--cc=clang \
    			--cxx=clang++ \
    			--extra-cxxflags="-I $SRC_DIR/external -I $PKGMGR_INST_PATH/include" \
    			--extra-ldflags="-L $SRC_DIR/external -L $PKGMGR_INST_PATH/lib" \
    			--disable-backend \
    			--disable-distcc \
    			--disable-firewire \
                        --disable-libcec \
                        --disable-x11 \
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
      			--runprefix=../Resources \
      			--qmake=$PKGMGR_INST_PATH/libexec/qt5/bin/qmake \
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
      	 		--python=$PYTHON_BIN
    echo "------------ Compiling Mythplugins ------------"
    #compile mythfrontend
    $PKGMGR_INST_PATH/libexec/qt5/bin/qmake  mythplugins.pro
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

echo "------------ Deploying QT to Mythfrontend Executable ------------"
# Package up the executable
cd $APP_DIR
# run macdeployqt
$PKGMGR_INST_PATH/libexec/qt5/bin/macdeployqt $APP_DIR/mythfrontend.app -appstore-compliant -libpath=$INSTALL_DIR/lib/ -libpath=$PKGMGR_INST_PATH/lib

echo "------------ Update Mythfrontend.app to use internal dylibs ------------"
# run osx-bundler.pl to copy all of the libraries into the bundle as Frameworks
# we will need to run this utility multiple more time for any plugins and helper apps installed
$OSX_PKGING_DIR/osx-bundler.pl $APP_EXE_DIR/mythfrontend $SRC_DIR/libs/* $INSTALL_DIR/lib/ $PKGMGR_INST_PATH/lib

echo "------------ Installing libcec into Mythfrontend.app ------------"
# copy in libcec (missing for some reason...)
cd $APP_FMWK_DIR
# loop over the installed versions of libcec and copy them in
for libcecFile in $PKGMGR_INST_PATH/lib/*libcec*.dylib; do
  # make sure its a file and not a symlink
  if [ -f $libcecFile ] && [ ! -h $libcecFile ]; then
    libcecNewFile=$APP_FMWK_DIR/$(basename $libcecFile)
    # extract out major version number
    LIBCECVERS=${$(basename $libcecFile)#"libcec."}
    LIBCECVERS=${LIBCECVERS%%.*}
    # copy and link the library
    cp -p $libcecFile $libcecNewFile
    ln -s $libcecNewFile libcec.dylib
    ln -s $libcecNewFile libcec.$LIBCECVERS.dylib
    # update the library to link to the app the installed dylibs
    $OSX_PKGING_DIR/osx-bundler.pl $libcecNewFile $PKGMGR_INST_PATH/lib
    # make the application aware of libcec
    install_name_tool -add_rpath "@executable_path/../Frameworks/$(basename $libcecNewFile)" $APP_EXE_DIR/mythfrontend
  fi
done
cd $APP_DIR

echo "------------ Installing additional mythtv utility executables into Mythfrontend.app  ------------"
# loop over the compiler apps copying in the desired ones for mythfrontend
for helperBinPath in $INSTALL_DIR/bin/*.app; do
  case $helperBinPath in
    *mythreplex*|*mythutil*|*mythpreviewgen*|*mythavtest*)
      # extract the filename from the path
      helperBinFile=$(basename $helperBinPath)
      helperBinFile=${helperBinFile%.app}
      echo "    Installing $helperBinFile into app"
      # copy into the app
      cp -Rp $helperBinPath/Contents/MacOS/$helperBinFile $APP_EXE_DIR
      # run osx-bundler.pl to setup and copy support libraries into app framework
      $OSX_PKGING_DIR/osx-bundler.pl  $APP_EXE_DIR/$helperBinFile
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
  for plugFilePath in $INSTALL_DIR/lib/mythtv/plugins/*.dylib; do
      plugFileName=$(basename $plugFilePath)
      echo "    Installing $plugFileName into app"
      cp $plugFilePath $APP_PLUGINS_DIR
      # run osx-bundler.pl to setup and copy support libraries into app framework
      $OSX_PKGING_DIR/osx-bundler.pl  $APP_PLUGINS_DIR/$plugFileName $PKGMGR_INST_PATH/lib
  done
fi

echo "------------ Copying mythtv share directory into executable  ------------"
# copy in i18n, fonts, themes, plugin resources, etc from the install directory (share)
mkdir -p $APP_RSRC_DIR/share/mythtv
cp -Rp $INSTALL_DIR/share/mythtv/* $APP_RSRC_DIR/share/mythtv/

echo "------------ Copying mythtv lib/python* and lib/perl directory into application  ------------"
mkdir -p $APP_RSRC_DIR/lib
cp -Rp $INSTALL_DIR/lib/python* $APP_RSRC_DIR/lib/
cp -Rp $INSTALL_DIR/lib/perl* $APP_RSRC_DIR/lib/
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
echo "    Creating a temporary application from ttvdb.py"
# in order to get python embedded in the application we're going to make a temporyary application
# from one of the python scripts (ttvdb) which will copy in all the required libraries for
# running and will make a standalone python executable not tied to the system
# ttvdb seems to be more particular than tmdb3...
$PY2APPLET_BIN -p $PYTHON_RUNTIME_PKGS --site-packages --use-pythonpath --make-setup $INSTALL_DIR/share/mythtv/metadata/Television/ttvdb.py
$PYTHON_BIN setup.py -q py2app 2>&1 > /dev/null
# now we need to copy over the pythong app's pieces into the mythfrontend.app to get it working
echo "    Copying in Python Framework libraries"
cd $APP_DIR/PYTHON_APP/dist/ttvdb.app

cp -Rnp Contents/Frameworks/* $APP_DIR/mythfrontend.app/Contents/Frameworks/
echo "    Copying in Python Binary"
cp -p Contents/MacOS/python $APP_DIR/mythfrontend.app/Contents/MacOS/
echo "    Copying in Python Resources"
cp -Rnp Contents/Resources/* $APP_DIR/mythfrontend.app/Contents/Resources/
rm -Rf
cd $APP_DIR
# clean up temp application
rm -Rf PYTHON_APP

echo "------------ Replace application perl/python paths to relative paths inside the application   ------------"
# mythtv "fixes" the sheband in all python scripts to an absolute path on the compiling system.  We need to
# change this to a relative path pointint internal to the application.
# Note - when MacOS apps run, their starting path is the path as the directory the .app is stored in

cd $APP_RSRC_DIR/share/mythtv/metadata
# edit the items that point to INSTALL_DIR
sedSTR=s#$INSTALL_DIR#../Resources#g
grep -rlI $INSTALL_DIR $APP_RSRC_DIR | xargs gsed -i $sedSTR

# edit those that point to $SRC_DIR/programs/scripts/
sedSTR=s#$PYTHON_BIN#python#g
grep -rlI $PYTHON_BIN $APP_RSRC_DIR | xargs gsed -i $sedSTR

echo "------------ Copying in dejavu and liberation fonts into Mythfrontend.app   ------------"
# copy in missing fonts
cp $PKGMGR_INST_PATH/share/fonts/dejavu-fonts/*.ttf $APP_RSRC_DIR/share/mythtv/fonts/
cp $PKGMGR_INST_PATH/share/fonts/liberation-fonts/*.ttf $APP_RSRC_DIR/share/mythtv/fonts/

echo "------------ Add symbolic link structure for copied in files  ------------"
# make some symbolic links to match past working copies
cd $APP_EXE_DIR
if $BUILD_PLUGINS; then
  ln -s ../PlugIns/sqldrivers .
fi
cd $APP_RSRC_DIR
ln -s ../MacOS bin
if $BUILD_PLUGINS; then
  mkdir -p $APP_RSRC_DIR/lib/mythtv
  cd $APP_RSRC_DIR/lib/mythtv
  ln -s ../../../PlugIns plugins
fi

echo "------------ Generating mythfrontend startup script ------------"
# since we now have python installed internally, we need to make sure that the mythfrontend
# executable launched from the curret directory so that the python relative paths point int
# to the internal python
cd $APP_EXE_DIR
mv mythfrontend mythfrontend.real
echo "#!/bin/sh

BASEDIR=\$(dirname "\$0")
if [ \${BASEDIR:0:1} = \".\" ] ;then
  BASEDIR=\$(pwd)/\${BASEDIR:2}
fi

cd \$BASEDIR
cd ../..
APP_DIR=\$(pwd)
export PYTHONHOME=\$APP_DIR/Contents/Resources
export PYTHONPATH=\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS:\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS/site-packages:\$APP_DIR/Contents/Resources/lib/python$PYTHON_DOT_VERS/sites-enabled

cd \$BASEDIR
./mythfrontend.real \$@" >> mythfrontend

chmod +x mythfrontend

echo "------------ Copying in Mythfrontend.app icon  ------------"
cd $APP_DIR
# copy in the icon
cp $APP_DIR/mythfrontend.icns $APP_RSRC_DIR/application.icns

echo "------------ Updating application plist  ------------"
# Update the plist
gsed -i "8c\	<string>application.icns</string>" $APP_INFO_FILE
gsed -i "10c\	<string>org.osx-bundler.mythfrontend</string>\n	<key>CFBundleInfoDictionaryVersion</key>\n	<string>6.0</string>" $APP_INFO_FILE
gsed -i "14a\	<key>CFBundleShortVersionString</key>\n	<string>$VERS</string>" $APP_INFO_FILE
gsed -i "18c\	<string>osx-bundler</string>\n	<key>NSAppleScriptEnabled</key>\n	<string>NO</string>\n	<key>CFBundleGetInfoString</key>\n	<string></string>\n	<key>CFBundleVersion</key>\n	<string>1.0</string>\n	<key>NSHumanReadableCopyright</key>\n	<string>MythTV Team</string>" $APP_INFO_FILE
gsed -i "34a\	<key>ATSApplicationFontsPath</key>\n	<string>share/mythtv/fonts</string>" $APP_DIR/mythfrontend.app/Contents/Info.plist

echo "------------ Generating .dmg file  ------------"
# Package up the build
cd $APP_DIR
if $BUILD_PLUGINS; then
    VOL_NAME=MythFrontend-$VERS-intel-$OS_VERS-v$VERS-$GIT_VERS-with-plugins
else
    VOL_NAME=MythFrontend-$VERS-intel-$OS_VERS-v$VERS-$GIT_VERS
fi
# Archive off any previous files
if [ -f $APP_DIR/$VOL_NAME.dmg ] ; then
    mv $APP_DIR/$VOL_NAME.dmg $APP_DIR/$VOL_NAME$(date +'%d%m%Y%H%M%S').dmg
fi
# Generate the .dmg file
hdiutil create $APP_DIR/$VOL_NAME.dmg -fs HFS+ -srcfolder $APP_DIR/Mythfrontend.app -volname $VOL_NAME
