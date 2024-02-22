FROM phusion/baseimage:jammy-1.0.2
LABEL maintainer="Victor Lap <victor@elnino.tech>"

CMD ["/sbin/my_init"]

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "11076708"
ENV VERSION_BUILD_TOOLS "34.0.0"
ENV VERSION_TARGET_SDK "34"

ENV ANDROID_SDK_ROOT "/sdk"

ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/tools:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    curl \
    openjdk-17-jdk \
    unzip \
    zip \
    git \
    ruby-full \
    build-essential \
    file \
    ssh

ADD https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK_TOOLS}_latest.zip /tools.zip
RUN mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" && unzip /tools.zip -d "/tools" && mv /tools/cmdline-tools "$ANDROID_SDK_ROOT/cmdline-tools/latest" && rm -rf /tools /tools.zip

RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

RUN mkdir -p $HOME/.android && touch $HOME/.android/repositories.cfg
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}" --verbose
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN gem install fastlane

ADD id_rsa $HOME/.ssh/id_rsa
ADD id_rsa.pub $HOME/.ssh/id_rsa.pub
ADD adbkey $HOME/.android/adbkey
ADD adbkey.pub $HOME/.android/adbkey.pub

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
