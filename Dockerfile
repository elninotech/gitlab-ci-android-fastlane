FROM ubuntu:20.04
LABEL maintainer="El Niño <info@elnino.tech>"

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "6858069"
ENV VERSION_BUILD_TOOLS "30.0.0"
ENV VERSION_TARGET_SDK "30"

ENV ANDROID_SDK_ROOT "/sdk"

ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools:${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    curl \
    openjdk-11-jdk \
    unzip \
    zip \
    git \
    ruby2.7 \
    ruby2.7-dev \
    build-essential \
    file \
    ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK_TOOLS}_latest.zip /tools.zip
RUN mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" && \
    unzip /tools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools" && \
    rm -rf /tools.zip

RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses

RUN mkdir -p $HOME/.android && touch $HOME/.android/repositories.cfg
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN gem install fastlane

ADD id_rsa $HOME/.ssh/id_rsa
ADD id_rsa.pub $HOME/.ssh/id_rsa.pub
ADD adbkey $HOME/.android/adbkey
ADD adbkey.pub $HOME/.android/adbkey.pub