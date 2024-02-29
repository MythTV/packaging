FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG SDK_VER=29
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install \
    openjdk-8-jdk \
    pkg-config \
    build-essential \
    git \
    vim \
    bison \
    flex \
    gperf \
    ruby \
    ant \
    gettext \
    cmake \
    fontconfig \
    libtool \
    autopoint \
    libfreetype6-dev \
    sudo \
    wget \
    python3

COPY docker_init.sh /

ENTRYPOINT ["/docker_init.sh"]

ADD commandlinetools-linux.tgz /opt/android

# Install required Android packages
RUN echo "y" | /opt/android/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android "build-tools;29.0.2" "ndk;21.4.7075529" "platforms;android-$SDK_VER" "cmake;3.22.1" && /opt/android/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android --uninstall "emulator"

