#!/usr/bin/env bash
# Boot a 6.7"/6.9" iPhone simulator, install Phorm, and prep for App Store screenshots.
#
# Workflow:
#   1. Run this script — it boots the sim, builds + installs Phorm, opens Simulator.app.
#   2. Drive the app by hand to each state you want to capture (see SHOTS list below).
#   3. For each state, run:  ./capture-screenshots.sh shot <name>
#      e.g.   ./capture-screenshots.sh shot 01-sessions-empty
#   4. PNGs land in andiem-ios/tools/screenshots/.
#
# App Store requires either the 6.9" (1320×2868) OR 6.5" (1242×2688) class — one set covers
# all smaller iPhones. iPhone 17 Pro Max is 6.9"; iPhone 15 Pro Max is 6.7" (1290×2796) and
# also accepted as the largest set for older submissions. Pick whichever sim is installed.

set -euo pipefail

# --- Config -----------------------------------------------------------------
SIM_NAME="${PHORM_SIM:-iPhone 17 Pro Max}"   # override: PHORM_SIM="iPhone 15 Pro Max" ./capture-screenshots.sh
SCHEME="Phorm"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$PROJECT_DIR/andiem-ios.xcodeproj"
BUNDLE_ID="com.quyctd.phorm"
OUT_DIR="$PROJECT_DIR/tools/screenshots"
mkdir -p "$OUT_DIR"

# --- Subcommands ------------------------------------------------------------
cmd="${1:-up}"

resolve_sim() {
  xcrun simctl list devices available -j \
    | /usr/bin/python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    for d in devices:
        if d['name'] == '$SIM_NAME' and d['isAvailable']:
            print(d['udid']); sys.exit(0)
sys.exit('No available simulator named: $SIM_NAME')
"
}

case "$cmd" in
  up)
    if ! xcrun simctl list devices available | grep -q "$SIM_NAME"; then
      echo "Simulator '$SIM_NAME' not installed."
      echo "Install via Xcode → Settings → Components, or set PHORM_SIM to an available device:"
      xcrun simctl list devices available | grep "iPhone" || true
      exit 1
    fi
    udid=$(resolve_sim)
    echo "Booting $SIM_NAME ($udid)..."
    xcrun simctl boot "$udid" 2>/dev/null || true
    open -a Simulator

    echo "Building Phorm for simulator..."
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
      -destination "platform=iOS Simulator,id=$udid" \
      -configuration Release \
      CODE_SIGNING_ALLOWED=NO \
      -derivedDataPath "$PROJECT_DIR/build" \
      build | tail -5

    APP_PATH=$(find "$PROJECT_DIR/build/Build/Products" -name "Phorm.app" -path "*Release-iphonesimulator*" | head -1)
    if [[ -z "$APP_PATH" ]]; then
      APP_PATH=$(find "$PROJECT_DIR/build/Build/Products" -name "Phorm.app" -path "*Debug-iphonesimulator*" | head -1)
    fi
    echo "Installing $APP_PATH..."
    xcrun simctl install "$udid" "$APP_PATH"
    xcrun simctl launch "$udid" "$BUNDLE_ID"

    echo ""
    echo "Sim is ready. Now drive the app by hand to each state, then run:"
    echo "  $0 shot <name>"
    echo ""
    echo "Suggested shots (App Store wants up to 10):"
    echo "  01-sessions-empty       — first-run empty state of phiên list"
    echo "  02-sessions-populated   — 2–3 phiên với điểm thật"
    echo "  03-new-session          — màn 'Phiên mới' đang điền tên người chơi"
    echo "  04-leaderboard          — phiên đang chơi, có ấn vàng cho người dẫn đầu"
    echo "  05-round-entry          — keypad đang nhập, ô cuối tự cộng hiển thị"
    echo "  06-round-history        — lịch sử các ván trong 1 phiên"
    echo "  07-summary              — màn kết thúc phiên, leaderboard cuối"
    echo "  08-share-sheet          — ShareLink mở ra với link phorm://"
    ;;

  shot)
    name="${2:?Usage: $0 shot <name>}"
    udid=$(xcrun simctl list devices booted -j | /usr/bin/python3 -c "
import json, sys
for rt, ds in json.load(sys.stdin)['devices'].items():
    for d in ds:
        if d['state'] == 'Booted': print(d['udid']); sys.exit(0)
sys.exit('No booted sim')")
    out="$OUT_DIR/${name}.png"
    xcrun simctl io "$udid" screenshot "$out"
    dims=$(/usr/bin/sips -g pixelWidth -g pixelHeight "$out" | awk '/pixel/ {print $2}' | paste -sd× -)
    echo "Saved $out ($dims)"
    ;;

  list)
    ls -la "$OUT_DIR" 2>/dev/null || echo "No screenshots yet."
    ;;

  *)
    echo "Usage: $0 [up|shot <name>|list]"
    echo "  up           Boot sim, build, install, launch"
    echo "  shot <name>  Capture current screen → tools/screenshots/<name>.png"
    echo "  list         List captured screenshots"
    exit 1
    ;;
esac
