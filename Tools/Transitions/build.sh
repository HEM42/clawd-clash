#!/bin/zsh
# Compiles the comic-transition renderer into build/transitions (see Tools/Transitions/main.swift).
set -euo pipefail
cd "${0:A:h}/../.."
mkdir -p build
source Tools/universes.sh || exit 1
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos13.0" \
    Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
    "${UNIVERSE_APP[@]}" Sources/Shared/*.swift Tools/Transitions/main.swift -o build/transitions
echo "✓ build/transitions"
