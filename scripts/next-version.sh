#!/bin/zsh
# The next release's version, from what HEAD has since the last release tag (clawdify_guide.md, "Version numbers"):
#   a universe newly `shipped` in NUMBERS    → the first number:  4.1.2 → 5.0.0
#   otherwise, any `feat:` commit             → the middle one:    4.1.2 → 4.2.0
#   otherwise (fix:, docs:, chore:…)          → the last one:      4.1.2 → 4.1.3
# Prints the version on stdout and why on stderr; release.sh uses it when no version is given.
#   scripts/next-version.sh
set -euo pipefail
cd "${0:A:h}/.."

last=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' HEAD)
parts=(${(s:.:)${last#v}})
major=$parts[1] minor=$parts[2] patch=$parts[3]

subjects=$(git log "$last..HEAD" --no-merges --format=%s)
[[ -n $subjects ]] || { echo "nothing since $last to release" >&2; exit 1; }

numbers=Sources/App/Universes/NUMBERS
shipped() { awk '!/^#/ && $4 == "shipped" { print $3 }' | sort }
new=$(comm -13 <(git show "$last:$numbers" 2>/dev/null | shipped) <(shipped < $numbers))
feats=$(print -r -- $subjects | grep -cE '^feat(\([^)]*\))?!?:' || true)
fixes=$(( $(print -r -- $subjects | wc -l) - feats ))

if [[ -n $new ]]; then
    echo "$((major + 1)).0.0"
    echo "universe: ${(j:, :)${(f)new}} newly shipped since $last" >&2
elif (( feats > 0 )); then
    echo "$major.$((minor + 1)).0"
    echo "feature: $feats feat commit(s) since $last" >&2
else
    echo "$major.$minor.$((patch + 1))"
    echo "fix: $fixes commit(s) since $last, none of them feat" >&2
fi
