#!/usr/bin/env bash
#
# render.sh — compose raw captures into branded App Store marketing images.
#
# Renders frame.html (one panel per screen) to PNG at 1320×2868 using headless
# Chrome. Run capture.sh first to produce raw/<screen>.png.
#
# Output: tools/screenshots/out/<screen>.png
#
# Usage:  tools/screenshots/render.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$HERE/out"
SCREENS=(session roundEntry summary newSession history)
W=1320; H=2868

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "Google Chrome not found at $CHROME"; exit 1; }

rm -rf "$OUT_DIR"; mkdir -p "$OUT_DIR"

# Filenames are prefixed with their position (1..N) so App Store Connect — which
# orders screenshots alphabetically by filename — shows them in upload order.
n=0
for SCREEN in "${SCREENS[@]}"; do
  n=$((n + 1))
  [ -f "$HERE/raw/$SCREEN.png" ] || { echo "Missing raw/$SCREEN.png — run capture.sh first"; exit 1; }
  OUT="$OUT_DIR/${n}-${SCREEN}.png"
  echo "▸ Rendering: $SCREEN"
  "$CHROME" \
    --headless=new \
    --hide-scrollbars \
    --force-device-scale-factor=1 \
    --window-size=$W,$H \
    --default-background-color=00000000 \
    --virtual-time-budget=8000 \
    --screenshot="$OUT" \
    "file://$HERE/frame.html?screen=$SCREEN" >/dev/null 2>&1
  echo "  → out/${n}-${SCREEN}.png ($(sips -g pixelWidth -g pixelHeight "$OUT" | grep pixel | awk '{print $2}' | paste -sd'x' -))"
done

echo "✓ Marketing images in $OUT_DIR"
