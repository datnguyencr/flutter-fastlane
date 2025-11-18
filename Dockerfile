# --- dynamic versions---
ARG FLUTTER_VERSION=3.32.5
ARG OPENJDK_VERSION=17
ARG BUILD_TOOLS_VERSION=36.1.0
ARG ANDROID_PLATFORM=android-36.1
ARG CMAKE_VERSION=3.22.1
ARG NDK_VERSION=27.0.12077973

# --- Base image with Flutter preinstalled ---
FROM ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}

# --- Environment setup ---
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    ANDROID_SDK_ROOT=/opt/android-sdk-linux \
    ANDROID_HOME=/opt/android-sdk-linux \
    PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# --- Install essential dependencies and Fastlane ---
RUN apt-get update && apt-get install -y --no-install-recommends ruby ruby-dev git wget unzip ca-certificates curl xz-utils zip
RUN apt-get install -y --no-install-recommends openjdk-17-jdk-headless
RUN gem install fastlane -NV
RUN rm -rf /var/lib/apt/lists/*

# --- Accept Android licenses & install all required SDK components ---
RUN yes | sdkmanager --licenses && \
    sdkmanager --install \
        "platform-tools" \
        "build-tools;36.1.0" \
        "platforms;android-36.1" \
        "cmake;3.22.1" \
        "ndk;27.0.12077973"

# --- Flutter configuration and precache ---
RUN flutter config --no-analytics && \
    flutter precache --android --ios --no-web

# --- Cleanup to reduce image size ---
RUN rm -rf /root/.cache /usr/share/doc /usr/share/man /tmp/* /var/tmp/*

# --- Set working directory ---
WORKDIR /app
CMD ["bash"]
