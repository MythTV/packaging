#!/bin/bash

# Abort on error
set -e

function readlinkf() {
    # Should be the same as 'readlink -f' but ought to also work on MacOS
    perl -MCwd -e 'print Cwd::abs_path shift' "$1"
}

IFS=
THISDIR=$(readlinkf ${BASH_SOURCE%/*})
BASEDIR=$(readlinkf ${BASH_SOURCE%/*}/../../..)

SDK_VER=21
COMMAND=""

function usage() {
  {
    echo 'Usage:'
    echo
    echo 'start.sh [options] [command] [args]'
    echo
    echo 'Options:'
    echo '-h --help        Show this help'
    echo '--sdk <version>  Use a specific SDK version (building Docker image if necessary)'
    echo
    echo 'If no command is given, a BASH shell will be started in the Docker image'
  } >&2
  exit 1
}

while [[ ${#@} -gt 0 ]] ; do
  case "$1" in
    -h|--help) usage ; exit 0 ;;
    --sdk) SDK_VER=${2} ; echo "SDK_VER ${SDK_VER}"; shift 2 ;;
    *) COMMAND="${@}" ; break ;;
  esac
done

IMAGE_NAME=mythtv_android_buildenv
IMAGE_TAG=SDK_${SDK_VER}
IMAGE_FULL_NAME=${IMAGE_NAME}:${IMAGE_TAG}

if [ $(docker images ${IMAGE_FULL_NAME} | wc -l) -eq 1 ]; then
    echo "${IMAGE_FULL_NAME} doesn't exist.  Building..."
    CMDTGZ=${THISDIR}/commandlinetools-linux.tgz
    if [ -e ${CMDTGZ} ]; then
        rm -f ${CMDTGZ}
    fi

    # Android command line tools are only available as a ZIP but that can't be
    # unpacked by Docker so unpack them and repack as a TGZ
    TMPARCHIVEDIR=$(mktemp -d)
    CMDLINEZIP=${THISDIR}/commandlinetools-linux.zip
    wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip -O ${CMDLINEZIP}
    unzip -d ${TMPARCHIVEDIR} ${CMDLINEZIP}
    tar czf ${CMDTGZ} -C ${TMPARCHIVEDIR} .
    rm -rf ${TMPARCHIVEDIR}
    rm ${CMDLINEZIP}

    echo Building docker image.  Please wait this may take a few minutes...
    docker build -t ${IMAGE_FULL_NAME} --build-arg SDK_VER=${SDK_VER} ${THISDIR}
    rm -f ${CMDTGZ}
fi

docker run -ti \
           --rm \
           --hostname ${IMAGE_NAME} \
           --workdir ${THISDIR}/.. \
           --volume ${BASEDIR}:${BASEDIR} \
           ${IMAGE_FULL_NAME} \
           -u $(id -u) \
           -g $(id -g) \
           $@
