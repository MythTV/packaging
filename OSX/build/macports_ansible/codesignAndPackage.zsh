#!/bin/zsh

show_help(){
    cat <<EOF
Usage: codesignAndPackage.sh mythfrontend.app

To enable codesigning / notarization, you must have a valid Apple Developer
account. Additionally, you'll need to  establish a valid Developer ID/certificate,
App Identifier, and App Password.
The Developer ID/Certificate can be obtained at https://developer.apple.com/
  (Account -> Certificates, Identifiers & Profiles -> Developer ID Application)
The App Identifier can be obtained at https://developer.apple.com/
  (Account -> Certificates, Identifiers & Profiles -> Identifiers -> App IDs)
The App Password can be obtained at https://appleid.apple.com/account/manage
  (Sign In -> APP-SPECIFIC PASSWORDS: Generate Password)

The CODESIGN_ID and APP_BNDL_ID variables can be input by the user by exporting
from the calling shell or .zprofile.
For example, you can modify your user's ~/.zprofile to include:
  export CODESIGN_ID="Developer ID Application: Your Name (XXXXXXXXXX)"
  export APP_BNDL_ID="org.mythtv.mythfrontend"

To notarize the application, your app password must be in your keychain as
MYTHFRONTEND_APP_PWD. To do this, run the following command:
  security add-generic-password -a "YOUR_APPLE_ID" -w "YOUR_APP_PWD" -s "MYTHFRONTEND_APP_PWD"
EOF

  exit 0
}

if [ -z $1 ] ; then
  show_help
  exit 0
fi

# parse user inputs into variables
for i in "$@"; do
  case $i in
      -h|--help)
        show_help
        exit 0
      ;;
      *)
        APP="${i#*=}"
      ;;
  esac
done

checkNotarization(){
  APP_UUID=$1
  APPLE_ID=$2
  # loop until the notarization process finishes
  # loop for about 20 minutes, then exit
  WAITIME=20
  LOOPMAX=$(expr 1200 / $WAITIME)
  # loop for ~20 minutes
  # Add initial sleep to prevent failing before the notarization task is accepted
  sleep $WAITTIME
  for ((i=1;i<=$LOOPMAX;i++));
  do
    # get notarization status
    noteOutput=$(xcrun altool --notarization-info $APP_UUID -u $APPLE_ID -p "@keychain:MYTHFRONTEND_APP_PWD")
    # extract out the status line
    STATUS=$(echo $noteOutput| gsed 1d | gsed 's/^.*Status: *//')
    case $STATUS in
      # notarization still in progrss (can take 15 or so minutes)
      *progress*)
        echo >&2 "      Waiting an additional $WAITIME seconds"
        sleep $WAITIME
        ;;
      # status reflects success
      *sucess*)
        echo >&2 $noteOutput
        echo >&2 "      Notaization Accepted"
        retval=true
        break
        ;;
      # status reflects approval
      *Approved*)
        echo >&2 $noteOutput
        echo >&2 "      Notaization Accepted"
        retval=true
        break
        ;;
      *)
        echo >&2 $noteOutput
        echo >&2 "      Notarization Failed or Timedout, exiting"
        retval=false
        break
        ;;
    esac
  done
  echo $retval
}

# make sure we have a valid path to mythfrontent.app
APP_NAME=$(basename $APP)
FILE_EXT=${APP_NAME##*.}
# make sure we have an application
if [ ! -e $APP ]; then
  echo "Invalid path input"
  exit
fi
# make sure we have an application
if [ $FILE_EXT != "app" ]; then
  echo "Invalid application input"
fi

# Setup variables to point to the internals of the app
APP_RSRC_DIR=$APP/Contents/Resources
APP_FMWK_DIR=$APP/Contents/Frameworks
APP_EXE_DIR=$APP/Contents/MacOS
APP_PLUGINS_DIR=$APP_FMWK_DIR/PlugIns/
ARCH=$(/usr/bin/arch)
OS_VERS=$(/usr/bin/sw_vers -productVersion)
VERS=$(/usr/libexec/PlistBuddy -c 'print ":CFBundleShortVersionString"' $APP/Contents/Info.plist)
FULLVERS=$($APP_EXE_DIR/mythfrontend --version|grep "MythTV Version"|gsed 's/^.*Version : *//')
# trim -dirty in case we've patched the repo / fixed the Xcode 12.5 VERSION bug
FULLVERS=${FULLVERS%-dirty}
# check to see if the application has PlugIns
HAS_PLUGINS=false
if [ -e $APP_FMWK_DIR/PlugIns/libmythweather.dylib ]; then
  HAS_PLUGINS=true
fi

# setup codesign / notarization variables
echo "------------ Setup Code Signing Variables ------------"
if [ -z $CODESIGN_ID ]; then
  vared -p 'Input Apple Developer ID (codesign): ' -c CODESIGN_ID
fi
if [ -z $APP_BNDL_ID ]; then
  # check if the user exported a custom bumdle ID, if not use the default
  APP_BNDL_ID=$APP_DFLT_BNDL_ID
fi
# to notarize the application, your app password must be in your keychain
APPLE_ID=$(security find-generic-password -s "MYTHFRONTEND_APP_PWD" |grep acct|gsed 's/^.*<blob>=*//')
if [ -z $APPLE_ID ]; then
  echo "To notarize the application, your app password must be in your keychain as MYTHFRONTEND_APP_PWD"
  echo "You can get an App password (with valid Apple ID) here: https://appleid.apple.com/account/manage"
  echo "To do this, run the following command:"
  echo '     security add-generic-password -a "YOUR_APPLE_ID" -w "YOUR_APP_PWD" -s "MYTHFRONTEND_APP_PWD"'
  exit
fi

echo "------------ Signing Application  ------------"
# first we need to generate a entitlement plist for runtime exceptons, these are
# necessary to allow the applidation to run the qt, python, and perl scripts
# contained within the application
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.security.cs.allow-jit</key>
  <true/>
  <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
  <true/>
  <key>com.apple.security.cs.disable-executable-page-protection</key>
  <true/>
  <key>com.apple.security.cs.disable-library-validation</key>
  <true/>
  <key>com.apple.security.cs.allow-dyld-environment-variables</key>
  <true/>
  <key>com.apple.security.cs.debugger</key>
  <true/>
  <key>com.apple.security.network.server</key>
  <true/>
  <key>com.apple.security.network.client</key>
  <true/>
  <key>com.apple.security.device.usb</key>
  <true/>
</dict>
</plist>' > entitlement.plist

# Per the Apple developer notes on codesigning, you must codesign from the inside out
# macdeployqt misses the python .so files in the Resources directory, so do that first
find $APP_RSRC_DIR -name '*.so' -print0 |
  while IFS= read -r -d '' line; do
      codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" "$line"
  done
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_FMWK_DIR/*.framework
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_FMWK_DIR/*.dylib
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_FMWK_DIR/PlugIns/*.dylib
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_FMWK_DIR/PlugIns/*/*.dylib
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_EXE_DIR/python
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_EXE_DIR/mythutil
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_EXE_DIR/mythpreviewgen
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_EXE_DIR/mythfrontend
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist --continue -i "$APP_BNDL_ID" $APP_EXE_DIR/mythfrontend.sh
# finally sign the application
codesign -v -s $CODESIGN_ID --timestamp --options runtime -f --entitlements entitlement.plist $APP
# verify that the codesigning took
codesign --verify -vv --deep $APP
# clean up entitlement file
rm entitlement.plist

echo "------------ Notarizing Application  ------------"
echo "------------ Preparing App for Notarization  ------------"
/usr/bin/ditto -c -k --keepParent $APP $APP.zip
# notarize the App file
# send the zipped dmg file to apple for notarization
noteOutput=$(xcrun altool --notarize-app --primary-bundle-id $APP_BNDL_ID -u $APPLE_ID -p "@keychain:MYTHFRONTEND_APP_PWD" --file $APP.zip)
# extract the upload specific UUID since we need it to track notarization status
APP_UUID=$(echo $noteOutput| gsed 1d | gsed 's/^.*RequestUUID = *//')
echo "App UUID is :$APP_UUID"
echo "     Waiting on notarization to complete  ------------"
NOTE_SUCCESS=$(checkNotarization $APP_UUID $APPLE_ID)

# clean up zip file
rm $APP.zip
# if notarization if successful, staple the notarization onto the dmg file
if $NOTE_SUCCESS; then
  echo "     Stapling notarization to $APP  ------------"
  xcrun stapler staple $APP
else
  echo "     App notarization failed, exiting  ------------"
  exit
fi

echo "------------ Generating .dmg file  ------------"
# Package up the build
if $HAS_PLUGINS; then
  VOL_NAME=MythFrontend-$VERS-$ARCH-$OS_VERS-$FULLVERS-with-plugins
else
  VOL_NAME=MythFrontend-$VERS-$ARCH-$OS_VERS-$FULLVERS
fi
DMG_FILE=$VOL_NAME.dmg

# Archive off any previous files
if [ -f $DMG_FILE ] ; then
    mv $DMG_FILE $VOL_NAME$(date +'%d%m%Y%H%M%S').dmg
fi
# Generate the .dmg file
hdiutil create -volname "$VOL_NAME" -srcfolder "$APP" -ov -format UDRO "$VOL_NAME"
# codesign the dmg file
codesign --deep --force --verify --verbose --sign $CODESIGN_ID --options runtime $DMG_FILE

# notarize the dmg file
echo "------------ Notarizing DMG  ------------"
# send the zipped dmg file to apple for notarization
noteOutput=$(xcrun altool --notarize-app --primary-bundle-id $APP_BNDL_ID -u $APPLE_ID -p "@keychain:MYTHFRONTEND_APP_PWD" --file $DMG_FILE)
# extract the upload specific UUID since we need it to track notarization status
APP_UUID=$(echo $noteOutput| gsed 1d | gsed 's/^.*RequestUUID = *//')
echo "DMG UUID is :$APP_UUID"
echo "     Waiting on notarization to complete  ------------"
NOTE_SUCCESS=$(checkNotarization $APP_UUID $APPLE_ID)

# if notarization if successful, staple the notarization onto the dmg file
if $NOTE_SUCCESS; then
  echo "     Stapling notarization to $DMG_FILE  ------------"
  xcrun stapler staple $DMG_FILE
  echo "     stapled DMG file is located:"
  echo "     $PWD/$DMG_FILE"
  exit 1
else
  echo "     DMG notarization failed, exiting  ------------"
  exit 0
fi
