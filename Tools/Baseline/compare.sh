#!/bin/zsh
# Compares two baseline runs (Tools/Baseline/baseline.sh) file by file: the same pixels give the same PNG bytes.
#   Tools/Baseline/compare.sh .baseline/main .baseline/check
set -uo pipefail
A="${1:?usage: compare.sh <baseline> <new>}"; B="${2:?usage: compare.sh <baseline> <new>}"
diffs=0
for f in $(cd "$A" && find . -type f | sort); do
    [[ -n "$(ls -A "$B/${f:h}" 2>/dev/null)" ]] || continue   # a folder the new run skipped (QUICK: the storyboards)
    if [[ ! -f "$B/$f" ]]; then echo "missing  $f"; ((diffs++)); continue; fi
    cmp -s "$A/$f" "$B/$f" || { echo "differs  $f"; ((diffs++)); }
done
for f in $(cd "$B" && find . -type f | sort); do [[ -f "$A/$f" ]] || { echo "new      $f"; ((diffs++)); }; done
if (( diffs == 0 )); then echo "✓ identical"; else echo "✗ $diffs difference(s)"; exit 1; fi
