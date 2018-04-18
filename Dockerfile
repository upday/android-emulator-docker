FROM ubuntu:16.04

LABEL maintainer "Pawel Polanski <pawel@upday.com>"

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    openjdk-8-jdk \
    ca-certificates \
    tzdata \
    zip \
    unzip \
    curl \
    wget \
    xterm \
    supervisor \
    socat \
    x11vnc \
    openbox \
    menu \
    python-numpy \
    net-tools \
    qemu-kvm \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
    python3 \
    telnet \
    expect \
  && rm -rf /var/lib/apt/lists/*

#===============
# Set JAVA_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    PATH=$PATH:$JAVA_HOME/bin

#=====================
# Install Android SDK
#=====================
ARG SDK_VERSION=sdk-tools-linux-3859397

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_HOME=/root

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
    unzip tools.zip && rm tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin
ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

#==================================
# Fix Issue with timezone mismatch
#==================================
ENV TZ="US/Pacific"
RUN echo "${TZ}" > /etc/timezone

#======================
# Install SDK packages
#======================
ARG ANDROID_VERSION=7.1.1
ARG API_LEVEL=25
ARG PROCESSOR=x86
ARG SYS_IMG=x86
ARG IMG_TYPE=google_apis
ENV ANDROID_VERSION=$ANDROID_VERSION \
    API_LEVEL=$API_LEVEL \
    PROCESSOR=$PROCESSOR \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

RUN mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg && \
    echo y | sdkmanager "platform-tools" && \
    echo y | sdkmanager "platforms;android-${API_LEVEL}" && \
    echo y | sdkmanager "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" && \
    echo y | sdkmanager "emulator"

RUN sdkmanager --update

#===============
# Expose Ports
#---------------
# 5554
#   Emulator port
# 5555
#   ADB connection port
#===============
EXPOSE 5554 5555

COPY src /root/src
COPY supervisord.conf /root/
RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf

HEALTHCHECK --interval=2s --timeout=40s --retries=1 \
    CMD adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

CMD ["/usr/bin/supervisord", "--configuration", "supervisord.conf"]
