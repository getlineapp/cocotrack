#!/bin/bash
set -e
SOURCE="/Users/pawelorzech/.gemini/antigravity/brain/e6429494-32eb-463b-82b6-3426e0750286/macos_icon_coconuts_1771010633662.png"
DEST="Sources/cocotrack/Resources/cocotrack.xcassets/AppIcon.appiconset"
mkdir -p "$DEST"

echo "Generating icons from $SOURCE to $DEST..."

sips -s format png --resampleHeightWidth 16 16 "$SOURCE" --out "$DEST/icon_16x16.png"
sips -s format png --resampleHeightWidth 32 32 "$SOURCE" --out "$DEST/icon_16x16@2x.png"
sips -s format png --resampleHeightWidth 32 32 "$SOURCE" --out "$DEST/icon_32x32.png"
sips -s format png --resampleHeightWidth 64 64 "$SOURCE" --out "$DEST/icon_32x32@2x.png"
sips -s format png --resampleHeightWidth 128 128 "$SOURCE" --out "$DEST/icon_128x128.png"
sips -s format png --resampleHeightWidth 256 256 "$SOURCE" --out "$DEST/icon_128x128@2x.png"
sips -s format png --resampleHeightWidth 256 256 "$SOURCE" --out "$DEST/icon_256x256.png"
sips -s format png --resampleHeightWidth 512 512 "$SOURCE" --out "$DEST/icon_256x256@2x.png"
sips -s format png --resampleHeightWidth 512 512 "$SOURCE" --out "$DEST/icon_512x512.png"
sips -s format png --resampleHeightWidth 1024 1024 "$SOURCE" --out "$DEST/icon_512x512@2x.png"

echo "Done."
