#!/bin/zsh
# Compiles the preview tool into build/preview (see Tools/Preview/main.swift for how to use it), or into the path given:
#   Tools/Preview/build.sh                                   build/preview
#   TEMPLATE=1 Tools/Preview/build.sh build/check/template/preview   with the template in it (check-universe --template)
set -euo pipefail
cd "${0:A:h}/../.."
OUT=${1:-build/preview}
mkdir -p build "${OUT:h}"
source Tools/universes.sh || exit 1
swiftc -swift-version 5 -target "$(uname -m)-apple-macos13.0" \
    Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
    "${UNIVERSE_APP[@]}" Sources/Shared/*.swift \
    Tools/Preview/main.swift -o "$OUT"
echo "✓ $OUT"
