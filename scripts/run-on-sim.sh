#!/bin/bash
set -euo pipefail

echo "==================================================="
echo " Build + run an iOS app on the Simulator from CLI"
echo "==================================================="
echo ""
echo "Picks the best available iPhone simulator by UDID,"
echo "builds, boots it, installs the app, and launches it."
echo ""
echo "Why by UDID and not name: if you have more than one"
echo "iOS runtime installed, matching 'OS:latest' or a sim"
echo "name like 'iPhone 16 Pro' is flaky and often fails"
echo "with 'Unable to find a device matching...'. A UDID is"
echo "exact, so it always hits the right sim."
echo ""

SCHEME="${SCHEME:-}"
BUNDLE_ID="${BUNDLE_ID:-}"
PROJECT="${PROJECT:-}"

if [ -z "$SCHEME" ] || [ -z "$BUNDLE_ID" ]; then
  echo "Set these first (export, or edit the top of this file):"
  echo ""
  echo "  export SCHEME=\"YourScheme\""
  echo "  export BUNDLE_ID=\"com.example.app\""
  echo "  export PROJECT=\"YourApp.xcodeproj\"   (optional, omit if a workspace or auto-detect works)"
  echo ""
  echo "Then run this again."
  exit 1
fi

echo "Finding an available iPhone simulator..."
SIM_UDID="$(xcrun simctl list devices available \
  | grep -Eo 'iPhone[^(]*\(([0-9A-F-]{36})\)' \
  | grep -Eo '[0-9A-F-]{36}' \
  | head -1)"

if [ -z "$SIM_UDID" ]; then
  echo "No available iPhone simulator found."
  echo "Open Xcode > Settings > Platforms and download an iOS runtime, then retry."
  exit 1
fi

SIM_NAME="$(xcrun simctl list devices available | grep "$SIM_UDID" | sed -E 's/ *\(.*//; s/^ *//')"
echo "Using simulator: ${SIM_NAME:-unknown} ($SIM_UDID)"
echo ""

PROJECT_FLAG=""
if [ -n "$PROJECT" ]; then
  PROJECT_FLAG="-project $PROJECT"
fi

echo "Building..."
xcodebuild $PROJECT_FLAG \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$SIM_UDID" \
  -derivedDataPath ./.build \
  build

APP_PATH="$(find ./.build/Build/Products -name '*.app' -maxdepth 2 -type d | head -1)"
if [ -z "$APP_PATH" ]; then
  echo "Build finished but no .app was found under ./.build/Build/Products"
  exit 1
fi
echo "Built: $APP_PATH"
echo ""

echo "Booting simulator (ignore 'already booted' if it shows)..."
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
open -a Simulator || true

echo "Installing..."
xcrun simctl install "$SIM_UDID" "$APP_PATH"

echo "Launching..."
xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID"

echo ""
echo "Done. The app should be open in the Simulator."
