FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG SDK_VER=21
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
    wget

COPY docker_init.sh /

ENTRYPOINT ["/docker_init.sh"]

ADD commandlinetools-linux.tgz /opt/android

# Install required Android packages
RUN echo "y" | /opt/android/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android "build-tools;28.0.3" "ndk;21.0.6113669" "platforms;android-$SDK_VER" "cmake;3.10.2.4988404" && /opt/android/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android --uninstall "emulator"

