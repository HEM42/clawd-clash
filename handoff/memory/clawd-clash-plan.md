---
name: clawd-clash-plan
description: "Clawd Clash = one app combining Clawd Wars (Star Wars) and Avengers: Clawd Wars (Marvel); old repos become showcase-only"
metadata:
  node_type: memory
  type: project
  originSessionId: 6dec5bb7-1a75-4576-a901-c669f11bce9a
  modified: 2026-10-12T19:27:29.784Z
---

Decided 2026-10-12: merge both apps into one app and repo named **Clawd Clash** (github.com/rodclemen/clawd-clash), with a universe picker (Star Wars or Marvel, never mixed in one scene) and a screen-saver setting (same universe as the app, or random).

- The old repos `clawd-wars` and `avengers-clawd-wars` become showcase repos: focused README, promo video, images only, no code. Their install sections must link to the Clawd Clash repo/releases. Reason: the user likes separate single-focus READMEs because they "sell better"; the combined README will be busy.
- Homebrew casks `clawd-wars` and `avengers-clawd-wars` should keep working, installing Clawd Clash preset to that universe.
- Order: build Clawd Clash first; only convert the showcase repos once Clawd Clash is public and released (public clawd-wars must not link to a private repo). Check with the user before rewriting the public clawd-wars repo.

**Why:** one app to maintain, two marketing pages.
**How to apply:** keep universe content in per-universe folders; keep README/promo tooling able to render per-universe images for the showcase repos. Related: [[avengers-clawd-wars-spec]], [[no-em-dashes]].

Status 2026-10-12 evening: Clawd Clash built in `/Volumes/8TB/- CODE -/Clawd-Clash`, pushed to github.com/rodclemen/clawd-clash (private). Both universes complete (Star Wars ported frame by frame from Clawd Wars 2ed8266), screen saver Options sheet for universe, Keep Characters on Top, three-cask release.sh. Not yet: user test run, release 3.0.0 (needs Developer ID), making the repo public, and converting the clawd-wars / avengers-clawd-wars repos into showcase repos (ask first).

Update 2026-10-13: everything renamed to parody names (branch `parody-names` in Clawd Clash). GitHub repos renamed: `avengers-clawd-wars` → `clawdvengers-clawd-wars`, `justice-league-clawd-wars` → `justice-clawds-clawd-wars` (`clawd-wars` stays); casks use the same names. All three converted locally into showcase pages (code removed, parody README, plain-language per-universe CHANGELOG), committed but NOT pushed: they wait for Clawd Clash to go public and for re-rendered images. Local folders (all in `/Volumes/8TB/- CODE -/clawd app/`, moved 2026-10-14): `Clawd-Clash`, `Clawd-Wars`, `clawdvengers-clawd-wars`, `justice-clawds-clawd-wars`. The user avoids trademark names everywhere except the disclaimer.

Naming rule (2026-10-13): lean on "Clawd" (every character is Clawd), not "claw" (few have claws). Universes: Star Clawds, Marvelous Clawds, Detective Clawds. Teams/pages: Clawdvengers (Clawdvengers: Clawd Wars), Justice Clawds (Justice Clawds: Clawd Wars). Batclaw family emblem is a cowl mask (pointed ears over a domino mask), not claw slashes.

