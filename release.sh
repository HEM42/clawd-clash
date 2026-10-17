#!/bin/zsh
# Publishes a release: Apple silicon build → (optional) notarization → zip → GitHub release → Homebrew cask.
# Only the newest two GitHub releases are kept; older ones are deleted (their tags stay).
#   ./release.sh 2.14.0                refuses if tag v2.14.0 or its GitHub release already exists
#   ./release.sh 2.14.0 --force        replaces an existing tag and the GitHub release's zip and notes
#   ./release.sh 2.14.0 --no-notarize  ships without notarization (the cask then clears the quarantine flag)
# HEAD must be pushed: it has to equal origin/main.
# Notarization needs a notarytool keychain profile named "clawd-clash" (or Clawd Wars' "clawd-wars"):
#   xcrun notarytool store-credentials clawd-clash --apple-id <you@example.com> --team-id <TEAMID>
# Without one the release stops, unless --no-notarize says to go ahead without it. A profile that exists but
# fails (network, a locked keychain) always stops it: that must never quietly turn into an un-notarized release.
set -euo pipefail
cd "${0:A:h}"

USAGE="usage: ./release.sh <version> [--force] [--no-notarize]"
VERSION="${1:?$USAGE}"; shift
FORCE=0
NO_NOTARIZE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --no-notarize) NO_NOTARIZE=1 ;;
        *) echo "unknown option: $arg ($USAGE)" >&2; exit 2 ;;
    esac
done
# X.Y.Z only: the version goes into the tag, the cask and the plists, so nothing else gets through.
[[ $VERSION =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || { echo "version must look like 3.5.1, not '$VERSION'" >&2; exit 2; }
TAG="v$VERSION"
ZIP="build/Clawd-Clash-$VERSION.zip"
TAP_REPO="rodclemen/homebrew-tap"
KEEP_RELEASES=2   # this one and the one before it

gh auth status >/dev/null 2>&1 || { echo "gh isn't signed in to GitHub: run 'gh auth login' first" >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "commit your changes first" >&2; exit 1; }
# The notes: this version's CHANGELOG section, matched as plain text (the dots in a version aren't wildcards).
NOTES=$(awk -v head="## $VERSION " 'index($0, head) == 1 {f=1; next} /^## /{f=0} f' CHANGELOG.md)
[[ -n "${NOTES//[[:space:]]/}" ]] || { echo "add a '## $VERSION' entry with notes to CHANGELOG.md first" >&2; exit 1; }
git fetch -q origin
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] \
    || { echo "HEAD isn't origin/main: push (or pull) first" >&2; exit 1; }

# Does the release exist already? "Not found" and "couldn't tell" are different answers: a network or auth error
# stops here rather than reading as "absent".
RELEASE_EXISTS=0
if out=$(gh release view "$TAG" 2>&1); then RELEASE_EXISTS=1
elif [[ $out != *"release not found"* ]]; then echo "couldn't check GitHub release $TAG: $out" >&2; exit 1; fi
if [[ $FORCE == 0 ]]; then
    git rev-parse -q --verify "refs/tags/$TAG" >/dev/null && { echo "tag $TAG already exists locally (pass --force to replace it)" >&2; exit 1; }
    rc=0; git ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null || rc=$?
    case $rc in
        0) echo "tag $TAG already exists on GitHub (pass --force to replace it)" >&2; exit 1 ;;
        2) ;;   # no such tag
        *) echo "couldn't check GitHub for tag $TAG (git ls-remote failed)" >&2; exit 1 ;;
    esac
    [[ $RELEASE_EXISTS == 0 ]] || { echo "GitHub release $TAG already exists (pass --force to replace it)" >&2; exit 1; }
fi

# Which notarytool profile: "clawd-clash", or Clawd Wars' "clawd-wars" (same Apple ID, already set up). Checked
# before the build so a missing one stops the release straight away. A profile that's simply not in the keychain is
# skipped; any other failure stops the release.
PROFILE=""
if [[ $NO_NOTARIZE == 0 ]]; then
    for p in clawd-clash clawd-wars; do
        if out=$(xcrun notarytool history --keychain-profile $p 2>&1); then PROFILE=$p; break; fi
        [[ $out == *"No Keychain password item found"* ]] && continue
        echo "notarytool profile '$p' is there but failed (network? locked keychain?):" >&2
        echo "$out" >&2; exit 1
    done
    [[ -n $PROFILE ]] || { echo "no notarytool profile 'clawd-clash' or 'clawd-wars' (see the top of release.sh), or pass --no-notarize" >&2; exit 1; }
fi

./build.sh --release "$VERSION"
APP="build/Clawd Clash.app"

# A --dev-tools build must never ship (see main.swift): its diagnostics carry this text, so it's checked for here.
if grep -aq "dev-tools build, never ship" "$APP/Contents/MacOS/ClawdClash"; then
    echo "error: the release binary contains the --dev-tools diagnostics" >&2; exit 1
fi

if [[ -n $PROFILE ]]; then
    echo "→ notarizing (profile $PROFILE)"
    ditto -c -k --keepParent "$APP" build/notarize.zip
    xcrun notarytool submit build/notarize.zip --keychain-profile $PROFILE --wait
    xcrun stapler staple "$APP"
    NOTARIZED=1
else
    echo "→ --no-notarize: skipping notarization"
    NOTARIZED=0
fi

# Check the signature (and, when notarized, the stapled ticket and Gatekeeper's verdict) before anything goes public.
echo "→ verifying the signature"
codesign --verify --strict --deep "$APP"
if [[ $NOTARIZED == 1 ]]; then
    xcrun stapler validate -q "$APP"
    spctl --assess --type execute "$APP"
fi

echo "→ packaging $ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
SHA=$(shasum -a 256 "$ZIP" | cut -d' ' -f1)

echo "→ GitHub release $TAG"
if [[ $FORCE == 1 ]]; then
    git tag -f "$TAG" && git push -f origin "$TAG"
else
    git tag "$TAG" && git push origin "$TAG"
fi
NOTES="$NOTES

**Install:** \`brew tap rodclemen/tap && brew trust rodclemen/tap && brew install --cask clawd-clash\` (\`brew trust\` only on newer Homebrew), or download the zip, unzip, and move *Clawd Clash.app* to Applications. (\`star-clawds\`, \`marvelous-clawds\` and \`detective-clawds\` install the same app, starting in Star Clawds, Marvelous Clawds or Detective Clawds.)"
if [[ $RELEASE_EXISTS == 1 ]]; then
    # --force on a published release: swap its zip and notes in place, so there's never a moment with no release
    # for the cask's download URL to point at.
    gh release upload "$TAG" "$ZIP" --clobber
    gh release edit "$TAG" --title "Clawd Clash $VERSION" --notes "$NOTES"
else
    gh release create "$TAG" "$ZIP" --title "Clawd Clash $VERSION" --notes "$NOTES"
fi

echo "→ Homebrew cask ($TAP_REPO)"
TAP=$(mktemp -d)
trap 'rm -rf "$TAP"' EXIT
# A tap that's there must be cloned: falling back to an empty repo would push a tap with only these casks in it.
if gh repo view "$TAP_REPO" >/dev/null 2>&1; then
    gh repo clone "$TAP_REPO" "$TAP" -- -q
else
    gh repo create "$TAP_REPO" --public --description "Homebrew tap for Clawd Clash and friends" >/dev/null
    git -C "$TAP" init -q -b main
fi
mkdir -p "$TAP/Casks"
QUARANTINE=""
if [[ $NOTARIZED == 0 ]]; then
    QUARANTINE='
  # Not notarized yet: clear the download quarantine so macOS lets it open.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Clawd Clash.app"],
        writable_paths: ["Clawd Clash.app"],
        writable_base:  :appdir
  end
'
fi
# Four casks, one app: clawd-clash, and one per universe, which starts it there (only if no universe has been chosen
# yet, so an upgrade never undoes your choice).
write_cask() {   # write_cask <cask name> <universe key or empty> <description>
    local name=$1 universe=$2 desc=$3 others preset=""
    others=$(printf '"%s", ' clawd-clash star-clawds marvelous-clawds detective-clawds | sed "s/\"$name\", //; s/, $//")
    if [[ -n $universe ]]; then
        preset="
  # Start in $universe, unless a universe was already picked.
  preflight_steps do
    run \"/bin/sh\",
        args:           [\"-c\", \"defaults read com.rodclemen.clawdclash universe >/dev/null 2>&1 || defaults write com.rodclemen.clawdclash universe -string $universe\"],
        writable_paths: [\"Library/Preferences\"],
        writable_base:  :home
  end
"
    fi
    cat > "$TAP/Casks/$name.rb" <<CASK
cask "$name" do
  version "$VERSION"
  sha256 "$SHA"

  url "https://github.com/rodclemen/clawd-clash/releases/download/v#{version}/Clawd-Clash-#{version}.zip"
  name "Clawd Clash"
  desc "$desc"
  homepage "https://github.com/rodclemen/clawd-clash"

  depends_on macos: :ventura
  depends_on arch: :arm64
  conflicts_with cask: [$others]

  app "Clawd Clash.app"
$preset$QUARANTINE
  # brew runs this on upgrade too (uninstall, then install): the hooks come out, and the new app puts
  # them back on its next launch. It may fail (macOS can refuse to run an installed copy that's been
  # changed, and kills it), and that mustn't stop the upgrade: the hooks then just stay, pointing at the
  # same path the new app is installed to.
  uninstall quit:   "com.rodclemen.clawdclash",
            script: {
              executable:   "#{appdir}/Clawd Clash.app/Contents/MacOS/ClawdClash",
              args:         ["--uninstall-hooks"],
              must_succeed: false,
            }

  zap trash: [
    "~/.claude/clawd-clash",
    "~/Library/Application Support/Clawd Clash",
    "~/Library/Screen Savers/Clawd Clash.saver",
    "~/Library/Preferences/com.rodclemen.clawdclash.plist",
    "~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Application Support/Clawd Clash Saver",
  ]
end
CASK
}
write_cask clawd-clash "" "Your AI coding sessions as a pixel-art battle across many universes, on your desktop"
write_cask star-clawds starWars "Claude Code sessions as a pixel-art Star Clawds battle on your desktop"
write_cask marvelous-clawds marvel "Claude Code sessions as a pixel-art Marvelous Clawds battle on your desktop"
write_cask detective-clawds dc "Claude Code sessions as a pixel-art Detective Clawds battle on your desktop"
# The universe casks used to be named after the old apps: Homebrew moves installs of those over (cask_renames.json).
rm -f "$TAP/Casks/clawd-wars.rb" "$TAP/Casks/clawdvengers-clawd-wars.rb" "$TAP/Casks/justice-clawds-clawd-wars.rb"
cat > "$TAP/cask_renames.json" <<'RENAMES'
{
  "clawd-wars": "star-clawds",
  "clawdvengers-clawd-wars": "marvelous-clawds",
  "justice-clawds-clawd-wars": "detective-clawds"
}
RENAMES
[[ -f "$TAP/README.md" ]] || printf '# Homebrew tap\n\n```sh\nbrew tap rodclemen/tap\nbrew trust rodclemen/tap      # newer Homebrew asks you to trust a third-party tap once\nbrew install --cask clawd-clash\n```\n' > "$TAP/README.md"
git -C "$TAP" add -A
git -C "$TAP" commit -q -m "clawd-clash $VERSION (also star-clawds, marvelous-clawds, detective-clawds)"
git -C "$TAP" remote get-url origin >/dev/null 2>&1 || git -C "$TAP" remote add origin "https://github.com/$TAP_REPO.git"
git -C "$TAP" push -q -u origin main

# Keep the newest $KEEP_RELEASES releases: older zips are never used (the cask names only the latest), and the one
# before the latest stays as a quick rollback. Tags are kept, so every version's code is still marked in git. Last,
# so a failed cask push never leaves the cask pointing at a deleted release; sorted by version, not date, so
# re-releasing an older version with --force never prunes the newest.
OLD=$(gh release list --limit 200 --exclude-drafts --json tagName \
          --jq "sort_by(.tagName | ltrimstr(\"v\") | split(\".\") | map(tonumber? // 0)) | reverse | .[$KEEP_RELEASES:] | .[].tagName")
for old in ${(f)OLD}; do
    gh release delete "$old" --yes && echo "→ removed old release $old (tag kept)"
done

echo "✓ released $TAG: brew tap rodclemen/tap && brew trust rodclemen/tap && brew install --cask clawd-clash"
