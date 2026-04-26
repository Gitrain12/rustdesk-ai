#!/bin/bash

# RustDesk AI - Mobile Build Script
# Builds Android and iOS applications

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/flutter"

ANDROID_OUTPUT_DIR="$SCRIPT_DIR/build/android"
IOS_OUTPUT_DIR="$SCRIPT_DIR/build/ios"
WEB_OUTPUT_DIR="$SCRIPT_DIR/build/web"

VERSION=${VERSION:-"1.0.0"}
BUILD_NUMBER=${BUILD_NUMBER:-"1"}

android_build() {
    echo "================================================"
    echo "  Building Android APK"
    echo "================================================"

    cd "$FLUTTER_DIR"

    flutter clean
    flutter pub get

    echo "Building debug APK..."
    flutter build apk --debug \
        --target-platform android-arm,android-arm64 \
        --output-directory "$ANDROID_OUTPUT_DIR/debug"

    echo "Building release APK..."
    flutter build apk --release \
        --target-platform android-arm,android-arm64 \
        --build-number "$BUILD_NUMBER" \
        --output-directory "$ANDROID_OUTPUT_DIR/release"

    flutter build apk --release \
        --target-platform android-x86,android-x64 \
        --build-number "$BUILD_NUMBER" \
        --output-directory "$ANDROID_OUTPUT_DIR/release"

    echo ""
    echo "Android build completed successfully!"
    echo "Debug APK: $ANDROID_OUTPUT_DIR/debug/app-debug.apk"
    echo "Release APK: $ANDROID_OUTPUT_DIR/release/app-release.apk"
}

ios_build() {
    if [ ! -d "$FLUTTER_DIR/ios" ]; then
        echo "iOS build requires Xcode and macOS. Skipping..."
        return
    fi

    echo "================================================"
    echo "  Building iOS App"
    echo "================================================"

    cd "$FLUTTER_DIR"

    flutter clean
    flutter pub get

    echo "Building iOS simulator build..."
    flutter build ios --simulator --no-codesign

    echo "Building iOS release..."
    flutter build ios --release --no-codesign

    echo ""
    echo "iOS build completed successfully!"
    echo "Output: $IOS_OUTPUT_DIR"
}

web_build() {
    echo "================================================"
    echo "  Building Web App"
    echo "================================================"

    cd "$FLUTTER_DIR"

    flutter clean
    flutter pub get

    flutter build web --release --pwa --output-directory "$WEB_OUTPUT_DIR"

    echo ""
    echo "Web build completed successfully!"
    echo "Output: $WEB_OUTPUT_DIR"
}

all_build() {
    android_build
    ios_build
    web_build
}

verify_build() {
    echo "================================================"
    echo "  Verifying Build Outputs"
    echo "================================================"

    if [ -f "$ANDROID_OUTPUT_DIR/release/app-release.apk" ]; then
        echo "✓ Android release APK found"
        ls -lh "$ANDROID_OUTPUT_DIR/release/app-release.apk"
    else
        echo "✗ Android release APK not found"
    fi

    if [ -d "$IOS_OUTPUT_DIR" ]; then
        echo "✓ iOS build output found"
        ls -la "$IOS_OUTPUT_DIR"
    else
        echo "✗ iOS build output not found"
    fi

    if [ -d "$WEB_OUTPUT_DIR" ]; then
        echo "✓ Web build output found"
        ls -la "$WEB_OUTPUT_DIR"
    else
        echo "✗ Web build output not found"
    fi
}

case "${1:-all}" in
    android)
        android_build
        ;;
    ios)
        ios_build
        ;;
    web)
        web_build
        ;;
    all)
        all_build
        ;;
    verify)
        verify_build
        ;;
    clean)
        echo "Cleaning build outputs..."
        rm -rf "$ANDROID_OUTPUT_DIR"
        rm -rf "$IOS_OUTPUT_DIR"
        rm -rf "$WEB_OUTPUT_DIR"
        cd "$FLUTTER_DIR" && flutter clean
        ;;
    *)
        echo "Usage: $0 {android|ios|web|all|verify|clean}"
        echo ""
        echo "Commands:"
        echo "  android - Build Android APK"
        echo "  ios     - Build iOS app"
        echo "  web     - Build Web app"
        echo "  all     - Build all platforms (default)"
        echo "  verify  - Verify build outputs"
        echo "  clean   - Clean build outputs"
        exit 1
        ;;
esac