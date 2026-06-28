#!/usr/bin/env bash
#
# capture.sh — raw App Store screenshots, clean status bar, curated mock data.
#
# Builds Phorm, boots an iPhone 17 Pro Max (6.9" — Apple's required hero size,
# 1320×2868), then for each marketing screen launches the app in SCREENSHOT mode
# (see Phorm/Screenshots/ScreenshotSupport.swift) and grabs a pixel-perfect PNG.
# No UI driving: the app routes straight to each screen via the SCREEN env var.
#
# Output: tools/screenshots/raw/<screen>.png
#
# Usage:  tools/screenshots/capture.sh
set -euo pipefail

# ---- config ---------------------------------------------------------------
BUNDLE_ID="com.quyctd.phorm"
SCHEME="Phorm"
DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max"
SIM_NAME="Phorm-Shots-6.9"
SCREENS=(session roundEntry summary newSession history)
SETTLE_SECONDS=4   # let SwiftUI lay out + any sheet finish presenting

# ---- paths ----------------------------------------------------------------
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_DIR="$(cd "$HERE/../.." && pwd)"
RAW_DIR="$HERE/raw"
DD="$HERE/.build"        # private derived data, so the .app path is predictable
mkdir -p "$RAW_DIR"

echo "▸ Generating project"
( cd "$IOS_DIR" && xcodegen generate >/dev/null )

echo "▸ Resolving simulator runtime"
RUNTIME="$(xcrun simctl list runtimes available | grep -oE 'com.apple.CoreSimulator.SimRuntime.iOS-[0-9-]+' | tail -1)"
[ -n "$RUNTIME" ] || { echo "No iOS simulator runtime installed"; exit 1; }

# Reuse the device if it already exists, else create it.
UDID="$(xcrun simctl list devices | grep -F "$SIM_NAME (" | grep -oE '[0-9A-F-]{36}' | head -1 || true)"
if [ -z "$UDID" ]; then
  echo "▸ Creating $SIM_NAME"
  UDID="$(xcrun simctl create "$SIM_NAME" "$DEVICE_TYPE" "$RUNTIME")"
fi
echo "  udid: $UDID"

echo "▸ Booting"
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true

echo "▸ Building app"
xcrun xcodebuild \
  -project "$IOS_DIR/andiem-ios.xcodeproj" \
  -scheme "$SCHEME" \
  -sdk iphonesimulator -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DD" \
  build >/dev/null

APP="$(/usr/bin/find "$DD/Build/Products" -maxdepth 2 -name '*.app' -type d | head -1)"
[ -n "$APP" ] || { echo "Built .app not found"; exit 1; }
echo "  app: $APP"

echo "▸ Installing"
xcrun simctl install "$UDID" "$APP"

echo "▸ Clean status bar (9:41 · full wifi · 100%)"
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 \
  --batteryState charged --batteryLevel 100

for SCREEN in "${SCREENS[@]}"; do
  echo "▸ Capturing: $SCREEN"
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  SIMCTL_CHILD_SCREENSHOT=1 SIMCTL_CHILD_SCREEN="$SCREEN" \
    xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null
  sleep "$SETTLE_SECONDS"
  xcrun simctl io "$UDID" screenshot "$RAW_DIR/$SCREEN.png" >/dev/null
  echo "  → raw/$SCREEN.png"
done

xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "✓ Raw screenshots in $RAW_DIR"
