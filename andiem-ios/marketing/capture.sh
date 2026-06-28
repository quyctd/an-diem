#!/usr/bin/env bash
# Capture all six App Store raw screenshots autonomously (no hand-driving).
# Builds the DEBUG app, boots an iPhone 17 sim (1206×2622, matches the iPhone 16 Pro
# frame), and launches once per screen via PHORM_SEED/PHORM_OPEN, screenshotting each.
set -euo pipefail

SIM_NAME="${PHORM_SIM:-iPhone 17}"
BUNDLE_ID="com.quyctd.phorm"
DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$DIR/.." && pwd)"
RAW="$DIR/raw"; mkdir -p "$RAW"

# screen key -> raw filename (must match compose_listing.py FRAMES)
SCREENS=(
  "leaderboard:01-leaderboard.png"
  "roundEntry:02-round-entry.png"
  "summary:03-summary.png"
  "history:04-history.png"
  "newSession:05-new-session.png"
  "empty:06-empty.png"
)

echo "Booting $SIM_NAME…"
xcrun simctl boot "$SIM_NAME" 2>/dev/null || true
open -a Simulator

echo "Building DEBUG Phorm…"
xcodebuild build -scheme Phorm \
  -destination "platform=iOS Simulator,name=$SIM_NAME" \
  -derivedDataPath "$IOS_DIR/build" CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
APP=$(find "$IOS_DIR/build/Build/Products" -name Phorm.app -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$SIM_NAME" "$APP"

# 9:41, full battery/signal — clean status bar
xcrun simctl status_bar "$SIM_NAME" override \
  --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3

for entry in "${SCREENS[@]}"; do
  key="${entry%%:*}"; file="${entry##*:}"
  xcrun simctl terminate "$SIM_NAME" "$BUNDLE_ID" 2>/dev/null || true
  SIMCTL_CHILD_PHORM_SEED=demo SIMCTL_CHILD_PHORM_OPEN="$key" \
    xcrun simctl launch "$SIM_NAME" "$BUNDLE_ID" >/dev/null
  sleep 3
  xcrun simctl io "$SIM_NAME" screenshot "$RAW/$file"
  echo "✓ $file"
done

echo "Done → $RAW"
