FROM appium/appium:1.7.2-p0

LABEL maintainer "Pawel Polanski <pawel@upday.com>"

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# xterm
#   Terminal emulator
# supervisor
#   Process manager
# socat
#   Port forwarder
#------------------
#    KVM Package
# for emulator x86
# https://help.ubuntu.com/community/KVM/Installation
#------------------
# qemu-kvm
# libvirt-bin
# ubuntu-vm-builder
# bridge-utils
#==================
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    xterm \
    supervisor \
    socat \
    qemu-kvm \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
 && rm -rf /var/lib/apt/lists/*

#======================
# Install SDK packages
#======================
# TODO: REFACTOR
ARG ANDROID_VERSION=5.0.1
ARG API_LEVEL=21
ARG PROCESSOR=x86
ARG SYS_IMG=x86_64
ARG IMG_TYPE=google_apis
ARG BROWSER=android
ENV ANDROID_VERSION=$ANDROID_VERSION \
    API_LEVEL=$API_LEVEL \
    PROCESSOR=$PROCESSOR \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE \
    BROWSER=$BROWSER
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools
RUN echo y | sdkmanager "platforms;android-${API_LEVEL}" && \
    echo y | sdkmanager "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" && \
    echo y | sdkmanager "emulator"
RUN rm ${ANDROID_HOME}/tools/emulator \
 && ln -s ${ANDROID_HOME}/emulator/emulator64-${PROCESSOR} ${ANDROID_HOME}/tools/emulator
ENV LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib

#================================================
# IF SOMETHING'S BROKEN CHECK THIS, ELSE REMOVE
#================================================
# ENV LOG_PATH=/var/log/supervisor

#===============
# Expose Ports
#---------------
# 5554 - Emulator port
# 5555 - ADB connection port
#===============
EXPOSE 5554 5555

COPY src /root/src
COPY supervisord.conf /root/

# Update to the latest emulator
RUN echo y | sdkmanager --update && \
    chmod -R +x /root/src && \
    chmod +x /root/supervisord.conf

HEALTHCHECK --interval=2s --timeout=40s --retries=1 \
    CMD adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

CMD ["/usr/bin/supervisord", "--configuration", "supervisord.conf"]
