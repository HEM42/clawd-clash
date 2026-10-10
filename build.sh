#!/bin/zsh
# Builds "Clawd Wars.app", installs it to ~/Applications, wires up the Claude Code hooks and launches it.
#   ./build.sh            build + install + hooks + launch
#   ./build.sh --no-hooks build + install + launch (leave ~/.claude/settings.json alone)
set -euo pipefail
cd "${0:A:h}"

APP="build/Clawd Wars.app"
DEST="$HOME/Applications/Clawd Wars.app"
OLD_DEST="$HOME/Applications/VaderClaude.app"   # pre-rename install
FLAGS=(-O -swift-version 5 -target arm64-apple-macos13.0)
[[ "$(uname -m)" == "x86_64" ]] && FLAGS=(-O -swift-version 5 -target x86_64-apple-macos13.0)

rm -rf build && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "→ compiling app"
swiftc "${FLAGS[@]}" Sources/Shared/*.swift Sources/App/*.swift -o "$APP/Contents/MacOS/ClawdWars"
echo "→ compiling hook"
swiftc "${FLAGS[@]}" Sources/Shared/*.swift Sources/Hook/main.swift -o "$APP/Contents/MacOS/vader-hook"

echo "→ icon"
ICONSET=build/AppIcon.iconset
mkdir -p "$ICONSET"
for px in 16 32 128 256 512; do
    sips -z $px $px Resources/AppIcon.png --out "$ICONSET/icon_${px}x${px}.png" >/dev/null
    sips -z $((px * 2)) $((px * 2)) Resources/AppIcon.png --out "$ICONSET/icon_${px}x${px}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.rodclemen.vaderclaude</string>
    <key>CFBundleName</key><string>Clawd Wars</string>
    <key>CFBundleDisplayName</key><string>Clawd Wars</string>
    <key>CFBundleExecutable</key><string>ClawdWars</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSAppleEventsUsageDescription</key><string>Clicking a villain selects the Terminal or iTerm tab running that Claude session.</string>
</dict>
</plist>
PLIST

# Sign with a real identity if there is one, so macOS keeps the Accessibility grant across rebuilds.
IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | grep -m1 -oE '"(Developer ID Application|Apple Development)[^"]*"' | tr -d '"' || true)
codesign --force --deep --timestamp=none --sign "${IDENTITY:--}" "$APP" >/dev/null 2>&1 \
    || codesign --force --deep --sign - "$APP" >/dev/null
echo "→ signed with: ${IDENTITY:-ad-hoc}"

echo "→ installing to $DEST"
pkill -x VaderClaude 2>/dev/null || true
pkill -x ClawdWars 2>/dev/null || true
mkdir -p "$HOME/Applications"
rm -rf "$DEST" "$OLD_DEST" && cp -R "$APP" "$DEST"

if [[ "${1:-}" != "--no-hooks" ]]; then
    "$DEST/Contents/MacOS/ClawdWars" --install-hooks
fi

open "$DEST"
echo "✓ Clawd Wars is running. Right-click any villain for options."
