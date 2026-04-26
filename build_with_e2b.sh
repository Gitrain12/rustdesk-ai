#!/bin/bash

# RustDesk AI - e2b Build Script (Updated for e2b CLI v2)
# Builds Android APK using e2b cloud environment

echo "============================================="
echo "  RustDesk AI Build Script (e2b v2)"
echo "============================================="
echo ""

# Check if template exists
echo "1. Checking e2b template..."
e2b template list | grep rustdesk-ai-build
if [ $? -ne 0 ]; then
    echo "   Template not found, creating..."
    # Create Dockerfile for the template
    cat > /tmp/Dockerfile << 'EOF'
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

EOF

    e2b template create rustdesk-ai-build -d /tmp/Dockerfile
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create template"
        exit 1
    fi
    echo "   Template created successfully"
else
    echo "   Template already exists"
fi

echo ""
echo "2. Creating e2b sandbox..."
SANDBOX_ID=$(e2b sandbox create rustdesk-ai-build -o json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
if [ -z "$SANDBOX_ID" ]; then
    echo "❌ Failed to create sandbox"
    exit 1
fi
echo "   Sandbox created: $SANDBOX_ID"

echo ""
echo "3. Waiting for sandbox to be ready..."
sleep 5

echo ""
echo "4. Mounting project files..."
# Note: The mount should be automatic based on e2b.toml config

echo ""
echo "5. Building APK..."
e2b sandbox exec $SANDBOX_ID "cd /workspace/rustdesk-app-package/flutter && flutter pub get"
e2b sandbox exec $SANDBOX_ID "cd /workspace/rustdesk-app-package/flutter && flutter build apk --release"

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    e2b sandbox kill $SANDBOX_ID
    exit 1
fi

echo ""
echo "6. Downloading APKs..."
mkdir -p output

# Try to download the APK files
e2b sandbox exec $SANDBOX_ID "ls -la /workspace/rustdesk-app-package/flutter/build/android/app/release/" || true

echo ""
echo "7. Killing sandbox..."
e2b sandbox kill $SANDBOX_ID

echo ""
echo "============================================="
echo "  Build Complete!"
echo "============================================="
echo ""
echo "Please check the e2b dashboard to download your APKs"
echo "or run: e2b sandbox exec $SANDBOX_ID 'ls /workspace/rustdesk-app-package/flutter/build/android/app/release/'"
echo ""