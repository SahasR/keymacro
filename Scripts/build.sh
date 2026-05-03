#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/KeyMacro.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES"

echo "-> Compiling Swift sources..."
SWIFT_FILES=$(find "$ROOT/Sources" -name "*.swift" | tr '\n' ' ')
swiftc -O \
  -target arm64-apple-macos13.0 \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
  -framework Cocoa \
  -framework Carbon \
  -framework SwiftUI \
  -framework Combine \
  $SWIFT_FILES \
  -o "$MACOS/KeyMacro"

echo "-> Generating app icon..."
ICONSET="/tmp/KeyMacro.iconset"
swift "$ROOT/Scripts/generate-icon.swift" "$ICONSET"
iconutil -c icns "$ICONSET" -o "$RESOURCES/AppIcon.icns"
rm -rf "$ICONSET"

echo "-> Copying resources..."
cp "$ROOT/Resources/Info.plist" "$CONTENTS/"

echo "-> Ad-hoc signing..."
codesign --force --deep --sign - "$APP"

echo "Built: $APP"
echo "   Run: open $APP"
