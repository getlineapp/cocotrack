#!/usr/bin/env bash
set -euo pipefail

# Add path to xcrun/actool if needed, usually in /usr/bin or /usr/bin/xcrun


APP_NAME="Cocotrack"
BUNDLE_ID="me.cocotrack.app"
EXECUTABLE_NAME="cocotrack"
MIN_MACOS_VERSION="13.0"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
BUILD_DIR="$ROOT_DIR/.build"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

ZIP_PATH="$DIST_DIR/$APP_NAME-macOS.zip"
DMG_PATH="$DIST_DIR/$APP_NAME-macOS.dmg"

SIGN_IDENTITY="${SIGN_IDENTITY:-}"
NOTARIZE_PROFILE="${NOTARIZE_PROFILE:-}"

mkdir -p "$DIST_DIR"

echo "[1/6] Building release binary"
swift build -c release

RELEASE_BIN="$BUILD_DIR/arm64-apple-macosx/release/$EXECUTABLE_NAME"
if [[ ! -f "$RELEASE_BIN" ]]; then
  echo "Release binary not found: $RELEASE_BIN" >&2
  exit 1
fi

echo "[2/6] Creating .app bundle"
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
cp "$RELEASE_BIN" "$MACOS_DIR/$EXECUTABLE_NAME"
chmod +x "$MACOS_DIR/$EXECUTABLE_NAME"

mkdir -p "$RESOURCES_DIR"

echo "[2.5/6] Compiling Assets"
if [[ -d "$ROOT_DIR/Sources/cocotrack/Resources/cocotrack.xcassets" ]]; then
    xcrun actool "$ROOT_DIR/Sources/cocotrack/Resources/cocotrack.xcassets" --compile "$RESOURCES_DIR" --platform macosx --minimum-deployment-target "$MIN_MACOS_VERSION" --app-icon AppIcon --output-partial-info-plist "$BUILD_DIR/assets-Info.plist" >/dev/null
    echo "Compiled Assets.car"
else
    echo "Warning: No asset catalog found at Sources/cocotrack/Resources/cocotrack.xcassets"
fi

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_MACOS_VERSION</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

echo "[3/6] Signing app bundle"
if [[ -n "$SIGN_IDENTITY" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_DIR"
  echo "Signed with identity: $SIGN_IDENTITY"
else
  codesign --force --deep --sign - "$APP_DIR"
  echo "Signed ad-hoc (SIGN_IDENTITY not provided)."
fi

codesign --verify --deep --strict "$APP_DIR"

echo "[4/6] Creating ZIP"
rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"

echo "[5/6] Creating DMG"
rm -f "$DMG_PATH"
TMP_DMG_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DMG_DIR"' EXIT
cp -R "$APP_DIR" "$TMP_DMG_DIR/"
hdiutil create -volname "$APP_NAME" -srcfolder "$TMP_DMG_DIR" -ov -format UDZO "$DMG_PATH" > /dev/null

if [[ -n "$SIGN_IDENTITY" ]]; then
  codesign --force --sign "$SIGN_IDENTITY" "$DMG_PATH" || true
fi

echo "[6/6] Optional notarization"
if [[ -n "$NOTARIZE_PROFILE" && -n "$SIGN_IDENTITY" ]]; then
  xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARIZE_PROFILE" --wait
  xcrun stapler staple "$APP_DIR"
  xcrun stapler staple "$DMG_PATH"
  echo "Notarization completed."
else
  echo "Skipped notarization (set SIGN_IDENTITY and NOTARIZE_PROFILE to enable)."
fi

echo
ls -lh "$APP_DIR" "$ZIP_PATH" "$DMG_PATH"
echo
echo "Artifacts ready in: $DIST_DIR"
