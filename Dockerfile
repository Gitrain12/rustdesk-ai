FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    openjdk-17-jdk \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip && \
    mv cmdline-tools latest && \
    rm cmdline-tools.zip

# Accept Android SDK licenses
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses || true

# Install required Android SDK components
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

# Download and install Flutter
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz | tar -xJ -C /opt

# Set working directory
WORKDIR /workspace