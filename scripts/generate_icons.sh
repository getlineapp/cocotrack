#!/bin/bash
set -euo pipefail

# Usage: generate_icons.sh [path/to/source.png]
# Source must be at least 1024x1024 PNG. Default location: scripts/source-assets/cocotrack-source.png
SOURCE="${1:-scripts/source-assets/cocotrack-source.png}"
DEST="Sources/cocotrack/Resources/cocotrack.xcassets/AppIcon.appiconset"

if [[ ! -f "$SOURCE" ]]; then
  echo "Source PNG not found: $SOURCE" >&2
  echo "Pass a path as the first argument or place a 1024x1024 PNG at scripts/source-assets/cocotrack-source.png" >&2
  exit 1
fi

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
