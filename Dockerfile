FROM debian:10.4
LABEL MAINTAINER="Ronan MOREL <ronanmorel@outlook.fr>"
USER root

# Install base packages
RUN apt update && apt install -y nano curl git g++ gcc make build-essential unzip && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt install -y nodejs && \
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update && apt install -y yarn && \
  curl -sL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
  echo "deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ buster main" | tee /etc/apt/sources.list.d/adoptopenjdk.list && \
  apt update && apt install adoptopenjdk-8-hotspot -y && \
  mkdir -p /opt && cd /opt && \
  curl -L https://services.gradle.org/distributions/gradle-6.5-bin.zip -o gradle.zip && \
  unzip gradle.zip && rm gradle.zip

# Environnement variables pour android tools
ENV JAVA_HOME /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
ENV GRADLE_HOME /opt/gradle-6.5
ENV ANDROID_SDK_ROOT /opt/android-sdk

# Install android SDK, tools and platforms
RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk && \
  curl -L https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip -o commandlinetools.zip && \
  unzip commandlinetools.zip && rm commandlinetools.zip

RUN cd $ANDROID_SDK_ROOT/tools/bin && \
  yes | ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
  ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update && \
  ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-28" && \
  ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;29.0.2"

# Add sdkmanager & android tools in path
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools/:$ANDROID_SDK_ROOT/tools/bin/:/opt/gradle-6.5/bin

# Install npm packages
RUN npm i -g @ionic/cli cordova

WORKDIR /app