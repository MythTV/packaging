#!/bin/bash

function fail() {
    echo "$*" >&2
    exit 1
}

function usage() {
  {
    echo "$*"
    echo
    echo 'Usage:'
    echo
    echo 'docker run [docker arguments] [docker image] -u <uid> -g <gid> [command] [args]'
    echo
    echo ' -u <uid>: numeric user id of user on host system'
    echo ' -g <gid>: numeric group id of group on host system'
  } >&2
  exit 1
}

function checkID {
   case ${1} in
     ''|*[!0-9]*)
       return 1 ;;
     *)
       return 0 ;;
   esac
}

COMMAND=""
USERNAME=mythtv

while [[ ${#@} -gt 0 ]] ; do
  case "$1" in
    -u) USERID=${2} ; shift 2 ;;
    -g) GROUPID=${2} ; shift 2 ;;
    *) COMMAND="${@}" ; break ;;
  esac
done

if [ -z "${USERID}" ] || [ -z "${GROUPID}" ]; then
  usage "user id and group id must be provided"
fi

checkID ${USERID}  || fail "user id '${USERID}' is non-numeric"
checkID ${GROUPID} || fail "group id '${GROUPID}' is non-numeric"

# runtime setup
groupadd -f -g ${GROUPID} ${USERNAME} || fail "Failed to create group"
useradd -o -m -g ${USERNAME} -G sudo -N -u ${USERID} ${USERNAME} -p '' -s /bin/bash || fail "Failed to add user"

INSTDIR=/opt/android
NDKVER=`ls -1 ${INSTDIR}/ndk`
SDKVER=`ls -1 ${INSTDIR}/platforms/ | sed 's/android-//'`
BUILDTOOLSVER=`ls -1 ${INSTDIR}/build-tools`

su "${USERNAME}" -c "mkdir -p ~/Android/android-studio && cd ~/Android && ln -s ${INSTDIR}/ Sdk && ln -s ${INSTDIR}/ndk/$NDKVER android-ndk"
su "${USERNAME}" -c "ln -s $(dirname $(dirname $(readlink -f $(which javac)))) ~/Android/android-studio/jre"
su "${USERNAME}" -c "git config --global user.email \"none@none.com\""
su "${USERNAME}" -c "git config --global user.name \"No-one\""

echo "--------------------------------------------"
echo "Installed Android packages:"
echo "Build tools: ${BUILDTOOLSVER}"
echo "NDK: ${NDKVER}"
echo "SDK: ${SDKVER}"
echo "--------------------------------------------"

if [ -z "${COMMAND}" ]; then
    su "${USERNAME}" -
else
    su "${USERNAME}" -c "${COMMAND}"
fi

exit $?
