#!/bin/zsh
# Renders the reference set the universe-modules refactor is checked against: every character, place, ride, magic
# stream, drill, a fight and the transitions for each universe, the docs pictures, every reel's storyboard, and every
# saved id and what it means. Same code, same pictures: compare two runs with Tools/Baseline/compare.sh.
#   Tools/Baseline/baseline.sh .baseline/main           everything (the reels' storyboards take a few minutes)
#   QUICK=1 Tools/Baseline/baseline.sh .baseline/check  without the storyboards
# Keep the output out of build/: ./build.sh deletes that folder. .baseline/ is git-ignored.
# The full moon is forced off, so Clawd Slayer's werewolves don't change with the date, and BASELINE=1 pins the
# cantina's band, which is otherwise picked at random.
set -euo pipefail
cd "${0:A:h}/../.."
OUT="${1:?usage: Tools/Baseline/baseline.sh <out folder>}"
rm -rf "$OUT"; mkdir -p "$OUT"/{cast,drills,places,fights,transitions,docs,storyboards}
export MOON=new BASELINE=1
SRC=(Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift
     Sources/App/Universes/**/*.swift Sources/Shared/*.swift)
echo "→ building the tools"
Tools/Preview/build.sh >/dev/null
Tools/Transitions/build.sh >/dev/null
swiftc -O -swift-version 5 $SRC Tools/RenderDocs/main.swift -o build/renderdocs 2>/dev/null
[[ -n ${QUICK:-} ]] || swiftc -O -swift-version 5 $SRC Tools/RenderPromo/main.swift -o build/renderpromo 2>/dev/null

echo "→ ids"
build/preview ids "$OUT/ids.txt" >/dev/null
KEYS=($(awk '/^universe /{sub("key=","",$3); print $3}' "$OUT/ids.txt"))

echo "→ characters, drills, places, fights and transitions, universe by universe"
for k in $KEYS; do
    build/preview cast "$OUT/cast/$k.png" $k >/dev/null
    build/preview drills "$OUT/drills/$k.png" $k >/dev/null
    build/preview place "$OUT/places/$k.png" $k >/dev/null
    # Its first villain against its first hero, and its trips between its first two places.
    block=$(awk -v k="key=$k" '$1=="universe"{on=($3==k)} on' "$OUT/ids.txt")
    villain=$(print -r -- $block | awk '$1=="cast" && $2%1000<100 {$1=$2=""; sub(/ weapon=.*/,""); sub(/^ +/,""); print; exit}')
    hero=$(print -r -- $block | awk '$1=="cast" && $2%1000>=100 {$1=$2=""; sub(/ weapon=.*/,""); sub(/^ +/,""); print; exit}')
    build/preview fight "$OUT/fights/$k.png" "$villain" "$hero" >/dev/null
    places=($(print -r -- $block | awk '$1=="place"{print $2}' | head -2))
    SHEET_ONLY=1 W=640 H=400 build/transitions "$OUT/transitions/$k" $places[1] $places[2] >/dev/null
done
build/preview magic "$OUT/magic.png" >/dev/null
build/preview rides "$OUT/rides.png" >/dev/null

echo "→ docs pictures"
build/renderdocs "$OUT/docs" >/dev/null

if [[ -z ${QUICK:-} ]]; then
    echo "→ storyboards"
    for r in promo bloopers royale starclawds marvelous detective doctor files clawdberg clawdoftherings slayer; do
        REEL=$r build/renderpromo storyboard "$OUT/storyboards" >/dev/null
    done
fi
echo "✓ baseline in $OUT ($(find "$OUT" -type f | wc -l | tr -d ' ') files)"
