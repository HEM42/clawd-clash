#!/bin/zsh
# Builds "Clawd Wars.app", installs it to ~/Applications, wires up the Claude Code hooks and launches it.
#   ./build.sh                     build + install + hooks + launch
#   ./build.sh --no-hooks          build + install + launch (leave ~/.claude/settings.json alone)
#   ./build.sh --release <version> universal (arm64 + x86_64) build into build/, signed for distribution;
#                                  no install, no hooks (used by release.sh)
set -euo pipefail
cd "${0:A:h}"

MODE=install
HOOKS=1
VERSION=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-hooks) HOOKS=0 ;;
        --release) MODE=release; VERSION="${2:?--release needs a version}"; shift ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
# Default version: the newest entry in the CHANGELOG.
[[ -z "$VERSION" ]] && VERSION=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | cut -c4-)

APP="build/Clawd Wars.app"
DEST="$HOME/Applications/Clawd Wars.app"
OLD_DEST="$HOME/Applications/VaderClaude.app"   # pre-rename install
FLAGS=(-O -swift-version 5)

rm -rf build && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# compile <output> <sources…>: native arch for installs, a universal binary for releases
compile() {
    local out=$1; shift
    if [[ $MODE == release ]]; then
        swiftc "${FLAGS[@]}" -target arm64-apple-macos13.0 "$@" -o "$out.arm64"
        swiftc "${FLAGS[@]}" -target x86_64-apple-macos13.0 "$@" -o "$out.x86_64"
        lipo -create "$out.arm64" "$out.x86_64" -output "$out"
        rm "$out.arm64" "$out.x86_64"
    else
        local arch=arm64; [[ "$(uname -m)" == "x86_64" ]] && arch=x86_64
        swiftc "${FLAGS[@]}" -target $arch-apple-macos13.0 "$@" -o "$out"
    fi
}

echo "→ compiling app"
compile "$APP/Contents/MacOS/ClawdWars" Sources/Shared/*.swift Sources/App/*.swift
echo "→ compiling hook"
compile "$APP/Contents/MacOS/vader-hook" Sources/Shared/*.swift Sources/Hook/main.swift

echo "→ icon"
ICONSET=build/AppIcon.iconset
mkdir -p "$ICONSET"
for px in 16 32 128 256 512; do
    sips -z $px $px Resources/AppIcon.png --out "$ICONSET/icon_${px}x${px}.png" >/dev/null
    sips -z $((px * 2)) $((px * 2)) Resources/AppIcon.png --out "$ICONSET/icon_${px}x${px}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
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
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>MIT licensed. A Star Wars fan project for Claude Code.</string>
    <key>NSAppleEventsUsageDescription</key><string>Clicking a villain selects the Terminal or iTerm tab running that Claude session.</string>
</dict>
</plist>
PLIST

# Sign. Releases prefer a Developer ID (for distribution); local builds take any real identity so macOS keeps
# the Accessibility grant across rebuilds. Falls back to ad-hoc.
IDENTITIES=$(security find-identity -v -p codesigning 2>/dev/null || true)
if [[ $MODE == release ]]; then
    IDENTITY=$(echo "$IDENTITIES" | grep -m1 -oE '"Developer ID Application[^"]*"' | tr -d '"' || true)
else
    IDENTITY=$(echo "$IDENTITIES" | grep -m1 -oE '"(Developer ID Application|Apple Development)[^"]*"' | tr -d '"' || true)
fi
SIGN_FLAGS=(--force --deep)
if [[ $MODE == release && -n "$IDENTITY" ]]; then
    # Hardened runtime + secure timestamp: what notarization requires. Apple Events entitlement keeps
    # click-to-jump working for Terminal and iTerm2.
    cat > build/entitlements.plist <<'ENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.automation.apple-events</key><true/></dict></plist>
ENT
    SIGN_FLAGS+=(--options runtime --timestamp --entitlements build/entitlements.plist)
else
    SIGN_FLAGS+=(--timestamp=none)
fi
codesign "${SIGN_FLAGS[@]}" --sign "${IDENTITY:--}" "$APP" >/dev/null 2>&1 \
    || { IDENTITY=""; codesign --force --deep --sign - "$APP" >/dev/null; }
echo "→ signed with: ${IDENTITY:-ad-hoc} (version $VERSION)"

if [[ $MODE == release ]]; then
    echo "✓ release build ready: $APP"
    exit 0
fi

echo "→ installing to $DEST"
pkill -x VaderClaude 2>/dev/null || true
pkill -x ClawdWars 2>/dev/null || true
mkdir -p "$HOME/Applications"
rm -rf "$DEST" "$OLD_DEST" && cp -R "$APP" "$DEST"

if [[ $HOOKS == 1 ]]; then
    "$DEST/Contents/MacOS/ClawdWars" --install-hooks
fi

open "$DEST"
echo "✓ Clawd Wars is running. Right-click any villain for options."
