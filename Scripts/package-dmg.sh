#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/KeyMacro.app"
STAGE="$BUILD/dmg-stage"
DMG="$BUILD/KeyMacro.dmg"
TMP_DMG="$BUILD/KeyMacro-tmp.dmg"

if [ ! -d "$APP" ]; then
  echo "Run Scripts/build.sh first."
  exit 1
fi

rm -rf "$STAGE" "$TMP_DMG" "$DMG"
mkdir -p "$STAGE"

cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create -volname "KeyMacro" \
  -srcfolder "$STAGE" \
  -ov -format UDRW "$TMP_DMG"

# Set window appearance via AppleScript
DEVICE=$(hdiutil attach -readwrite -noverify "$TMP_DMG" | grep -E '^/dev/' | head -1 | awk '{print $1}')
osascript << EOF
tell application "Finder"
  tell disk "KeyMacro"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {400, 100, 940, 480}
    set icon size of icon view options of container window to 128
    set arrangement of icon view options of container window to not arranged
    set position of item "KeyMacro.app" of container window to {130, 180}
    set position of item "Applications" of container window to {410, 180}
    close
    open
    update without registering applications
    delay 2
  end tell
end tell
EOF
hdiutil detach "$DEVICE"

hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG"
codesign --sign - "$DMG"
rm -f "$TMP_DMG"

echo "DMG created: $DMG"
