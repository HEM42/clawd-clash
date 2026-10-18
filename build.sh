#!/bin/zsh
# Builds "Clawd Clash.app", installs it to /Applications, refreshes the hooks of the AIs you've connected and launches it.
# It never connects a new AI: the app offers that, and Settings in its menu does it.
#   ./build.sh                     build + install + refresh connected hooks + launch
#   ./build.sh --no-hooks          build + install + launch (leave every AI's settings alone)
#   ./build.sh --no-install        build + launch the copy in build/ (nothing copied to /Applications, hooks left alone)
#   ./build.sh --untrusted         build into build/ only, for trying someone's PR: signed ad hoc (so it gets none of
#                                  the installed app's permissions), not installed, not launched, hooks left alone.
#                                  Start it yourself once you've read the code: open "build/Clawd Clash.app"
#   ./build.sh --release <version> Apple silicon (arm64) build into build/, signed for distribution;
#                                  no install, no hooks (used by release.sh)
#   ./build.sh --no-install --dev-tools
#                                  also compile the --jump=<pid> <file> and --ax-dump=<pid> [file] click-to-jump
#                                  diagnostics. Only with --no-install: any process that launches a copy built with
#                                  it can use the app's Accessibility grant, so it never goes to /Applications or
#                                  into a release (release.sh also checks the binary for it)
set -euo pipefail
cd "${0:A:h}"

MODE=install
HOOKS=1
VERSION=""
DEV_TOOLS=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-hooks) HOOKS=0 ;;
        --no-install) MODE=local; HOOKS=0 ;;
        --untrusted) MODE=untrusted; HOOKS=0 ;;
        --release) MODE=release; VERSION="${2:?--release needs a version}"; shift ;;
        --dev-tools) DEV_TOOLS=1 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
if [[ $DEV_TOOLS == 1 && $MODE != local ]]; then
    echo "error: --dev-tools only goes with --no-install (never installed, never released)" >&2; exit 2
fi
# Default version: the newest entry in the CHANGELOG.
if [[ -z "$VERSION" ]]; then
    VERSION=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | cut -c4- || true)
    [[ -n "$VERSION" ]] || { echo "error: no '## X.Y.Z' version heading found in CHANGELOG.md" >&2; exit 1; }
fi

APP="build/Clawd Clash.app"
DEST="/Applications/Clawd Clash.app"
OLD_DESTS=("$HOME/Applications/Clawd Clash.app" )   # earlier installs
# -num-threads: -O compiles each binary as one whole-module job, which would otherwise generate code on one core.
FLAGS=(-O -swift-version 5 -num-threads "$(sysctl -n hw.ncpu)")
# The app's diagnostics (main.swift), only with --dev-tools.
DEV_FLAGS=()
[[ $DEV_TOOLS == 0 ]] || DEV_FLAGS=(-D CLAWD_DEV_TOOLS)

# Separate commands, not `&&`: set -e doesn't stop on a failure inside a chain, and a build/ that couldn't be cleared
# (Finder rewriting its .DS_Store mid-delete) would otherwise go on to fail at the link step, far from the cause.
rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# compile <output> <sources…>: Apple silicon, for installs and releases alike
compile() {
    local out=$1; shift
    swiftc "${FLAGS[@]}" -target arm64-apple-macos13.0 "$@" -o "$out"
}

# The app, the hook and the screen saver compile side by side (each is its own process; `wait` stops the build if one
# fails). The screen saver: a plug-in bundle macOS's screen saver host loads, carried inside the app, which installs
# it (Settings → Screen Saver) and keeps the installed copy up to date. It shares the sprite and location code.
SAVER="$APP/Contents/Resources/Clawd Clash.saver"
mkdir -p "$SAVER/Contents/MacOS"
echo "→ compiling app, hook and screen saver"
# The app carries the screen saver's view too: the window's third view is the screen saver itself.
compile "$APP/Contents/MacOS/ClawdClash" "${DEV_FLAGS[@]}" -framework ScreenSaver Sources/Shared/*.swift Sources/App/*.swift Sources/App/Universes/**/*.swift Sources/Saver/*.swift &
APP_JOB=$!
# The hook knows each universe through its facts file alone: no drawing code.
compile "$APP/Contents/MacOS/clawd-clash-hook" Sources/Shared/*.swift Sources/App/Universes/*/*Facts.swift Sources/Hook/main.swift &
HOOK_JOB=$!
compile "$SAVER/Contents/MacOS/ClawdClashSaver" -module-name ClawdClashSaver -emit-library -framework ScreenSaver \
    -Xlinker -install_name -Xlinker @rpath/ClawdClashSaver \
    Sources/Shared/*.swift Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Accents,Habits,Drills,Icon,Rides}.swift \
    Sources/App/Universes/**/*.swift Sources/Saver/*.swift &
SAVER_JOB=$!
wait $APP_JOB
wait $HOOK_JOB
wait $SAVER_JOB
# Its picture under "Other" in System Settings (180×116).
mkdir -p "$SAVER/Contents/Resources"
cp Resources/SaverThumbnail.png "$SAVER/Contents/Resources/thumbnail@2x.png"
sips -z 58 90 Resources/SaverThumbnail.png --out "$SAVER/Contents/Resources/thumbnail.png" >/dev/null
# Both sizes in one file too, as Xcode packages them ("combine high resolution artwork").
tiffutil -cathidpicheck "$SAVER/Contents/Resources/thumbnail.png" "$SAVER/Contents/Resources/thumbnail@2x.png" \
    -out "$SAVER/Contents/Resources/thumbnail.tiff" >/dev/null
cat > "$SAVER/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array>
    <key>CFBundleIdentifier</key><string>com.rodclemen.clawdclash.saver</string>
    <key>CFBundleName</key><string>Clawd Clash</string>
    <key>CFBundleDisplayName</key><string>Clawd Clash</string>
    <key>CFBundleExecutable</key><string>ClawdClashSaver</string>
    <key>CFBundlePackageType</key><string>BNDL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>NSPrincipalClass</key><string>ClawdClashSaverView</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
</dict>
</plist>
PLIST

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
    <key>CFBundleIdentifier</key><string>com.rodclemen.clawdclash</string>
    <key>CFBundleName</key><string>Clawd Clash</string>
    <key>CFBundleDisplayName</key><string>Clawd Clash</string>
    <key>CFBundleExecutable</key><string>ClawdClash</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>MIT licensed. A fan parody project for AI coding sessions.</string>
    <key>NSAppleEventsUsageDescription</key><string>Clicking a character (hero or villain) selects the Terminal or iTerm tab running that AI session.</string>
</dict>
</plist>
PLIST

# Sign. Releases need a Developer ID (for distribution) and fail without one; local builds take any real
# identity so macOS keeps the Accessibility grant across rebuilds, and fall back to ad-hoc. An --untrusted build is
# always ad hoc: a real identity would hand it the installed app's Accessibility grant.
# No --deep (deprecated): the nested hook binary is signed on its own first, then the bundle.
# Every build has the hardened runtime, so no other program can load code into the app (DYLD_INSERT_LIBRARIES) and
# borrow its permissions. The Apple Events entitlement keeps click-to-jump working for Terminal and iTerm2.
cat > build/entitlements.plist <<'ENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.automation.apple-events</key><true/></dict></plist>
ENT
IDENTITIES=$(security find-identity -v -p codesigning 2>/dev/null || true)
if [[ $MODE == release ]]; then
    IDENTITY=$(echo "$IDENTITIES" | grep -m1 -oE '"Developer ID Application[^"]*"' | tr -d '"' || true)
    [[ -n "$IDENTITY" ]] || { echo "error: no 'Developer ID Application' signing identity in the keychain" >&2; exit 1; }
    # Plus a secure timestamp: what notarization requires.
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP/Contents/MacOS/clawd-clash-hook"
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "$SAVER"
    codesign --force --options runtime --timestamp --entitlements build/entitlements.plist \
        --sign "$IDENTITY" "$APP"
else
    IDENTITY=""
    [[ $MODE == untrusted ]] || \
        IDENTITY=$(echo "$IDENTITIES" | grep -m1 -oE '"(Developer ID Application|Apple Development)[^"]*"' | tr -d '"' || true)
    sign_local() {
        codesign --force --options runtime --timestamp=none --sign "$1" "$APP/Contents/MacOS/clawd-clash-hook" \
            && codesign --force --options runtime --timestamp=none --sign "$1" "$SAVER" \
            && codesign --force --options runtime --timestamp=none --entitlements build/entitlements.plist \
                --sign "$1" "$APP"
    }
    if [[ -z "$IDENTITY" ]] || ! sign_local "$IDENTITY" >/dev/null 2>&1; then
        IDENTITY=""
        sign_local - >/dev/null
    fi
fi
echo "→ signed with: ${IDENTITY:-ad-hoc} (version $VERSION)"

if [[ $MODE == release ]]; then
    echo "✓ release build ready: $APP"
    exit 0
fi
if [[ $MODE == untrusted ]]; then
    echo "✓ untrusted build ready: $APP (ad hoc, not installed, not launched; read the code, then open it yourself)"
    exit 0
fi

# Only one Clawd Clash runs at a time (a second copy quits at launch), so stop whichever one is running.
pkill -x ClawdClash 2>/dev/null || true

if [[ $MODE == local ]]; then
    # Not installed: the build/ copy never takes over hooks that still point at a working app (HookInstaller.repairMoved).
    open "$APP"
    echo "✓ Clawd Clash is running from $APP (not installed). Right-click any character for options."
    exit 0
fi

echo "→ installing to $DEST"
rm -rf "$DEST" "${OLD_DESTS[@]}"
cp -R "$APP" "$DEST"

if [[ $HOOKS == 1 ]]; then
    "$DEST/Contents/MacOS/ClawdClash" --update-hooks
fi

open "$DEST"
echo "✓ Clawd Clash is running. Right-click any character for options."
