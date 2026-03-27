#!/bin/bash
set -e

APP_NAME="Spank"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile
echo "Compiling..."
swiftc -o "$APP_BUNDLE/Contents/MacOS/SpankApp" \
    -target arm64-apple-macosx13.0 \
    -framework SwiftUI \
    -framework AppKit \
    -parse-as-library \
    SpankApp/SpankApp.swift

# Copy resources
cp SpankApp/Info.plist "$APP_BUNDLE/Contents/"
cp SpankApp/sound.mp3 "$APP_BUNDLE/Contents/Resources/"
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Include spank binary
if [[ -f /usr/local/bin/spank ]]; then
    cp /usr/local/bin/spank "$APP_BUNDLE/Contents/Resources/"
elif [[ -f /tmp/spank ]]; then
    cp /tmp/spank "$APP_BUNDLE/Contents/Resources/"
fi
chmod +x "$APP_BUNDLE/Contents/Resources/spank" 2>/dev/null || true

# Include installer
cp install-simple.sh "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/install-simple.sh"

# Code sign
codesign --force --deep --sign - "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
