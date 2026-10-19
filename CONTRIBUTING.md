# Contributing to Clawd Clash

New universes, characters, places and fixes are all welcome. The README's [Contributing](README.md#contributing) section explains how the code is laid out; to build a whole universe, point your AI assistant at [clawdify_guide.md](clawdify_guide.md).

This page is about what a pull request may change, and why.

## Why there are rules at all

A universe is Swift code compiled into the app. The app holds permissions people have given it (Accessibility, and Automation for Terminal and iTerm), and it writes the hook settings of every AI it's connected to. Code in a universe could use all of that. So every PR is checked by a guard, `scripts/pr-guard.py`, before anyone builds it. A universe that only draws things never notices the guard.

## What a PR may change

The guard sorts every file a PR changes into one of three groups.

**Green: change freely.**
- Your universe's own folder, `Sources/App/Universes/<YourUniverse>/`, its `universe.conf` included
- PNG pictures in `docs/`
- `README.md` and `CHANGELOG.md`

A new universe needs nothing but its folder: the app finds it there (the clawdify guide explains how). So a universe's pull request should be all green, and the README and changelog text goes in the PR's description for the maintainer to add after merging.

**Yellow: fine, and the maintainer reads these closely.** The rest of the app and the tools: the engine every universe shares, such as `Theme.swift`, `Locations.swift`, `Overlay.swift`, `Universes/UniverseModule.swift`, `SaverView.swift` and the Tools' `main.swift`. A universe never needs to change these. If yours needs something new from the engine, ask for it (an issue saying what should happen on screen and who uses it) and the maintainer builds it as a hook any universe can use. Engine changes and universe folders never travel in the same pull request.

**Red: the guard fails, so ask the maintainer.** A universe never needs to change these, and they're where harm would be done:
- **The build and release scripts:** `build.sh`, `release.sh`, `Tools/*/build.sh`, and any other script.
- **Build and project files:** a `Makefile`, `Package.swift`, or an Xcode project or workspace.
- **Repo and editor config:** anything starting with a dot (`.github/`, `.claude/`, `.vscode/`, `.gitattributes`…).
- **Instructions for AI assistants and contributors:** `llms.txt`, `clawdify_guide.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` and this file.
- **The universes' numbers:** `Sources/App/Universes/NUMBERS`. The maintainer hands numbers out, and adds your universe's line before you start.
- **The hook and the code compiled into it:** `Sources/Hook/`, plus `StatusStore`, `Processes`, `GitRemote` and `SaverFeed` in `Sources/Shared/`. Your universe's `<Prefix>Facts.swift` is compiled into the hook too, so it's flagged for a close read: keep it to the cast's enums and its facts.
- **The code that holds the app's permissions:** `HookInstaller`, `SaverInstaller`, `Jump` and `main.swift`.
- **New core files:** a new file directly in `Sources/Shared/`, `Sources/App/`, `Sources/App/Universes/` or `Sources/Saver/`.
- **Other file types:** symlinks, submodules and executable files.

If your universe needs something from a red file, say a new hook event for a mechanic, describe it in the PR and the maintainer will add it.

## Rules for universe code

These apply to the lines your PR adds in a universe folder.

**APIs.**
- Only drawing: Core Graphics, Core Text and the parts of Foundation and AppKit that drawing uses (colours, fonts, attributed strings, maths).
- Nothing that reaches files, processes, the network, other apps, the clipboard, settings or the environment: `FileManager`, `Process`, `URLSession`, `NSWorkspace`, `UserDefaults` and the like.
- None of the app's own sensitive types: `StatusStore`, `HookInstaller`, `Jump`…
- No system calls by bare name: `open(…)`, `exit(…)`, `kill(…)`…
- A local variable may still be called `open` or `raise`.
- A few things pass but are flagged for the maintainer to look at: `ProcessInfo` (it reads the environment), locks, and raw memory access.

**Imports.** Only `Foundation`, `CoreGraphics`, `CoreText` and `AppKit`.

**Names.** A new top-level name is either `private` or starts with your universe's prefix: the `prefix` in your `universe.conf`, the `<Prefix>` of your `<Prefix>Roster.swift`, as in `ringsHeroes1` or `RingsTrip`. A plain top-level name can quietly replace one of the system's (a `chmod` of your own would switch off one of the app's protections), so the guard refuses it. It also refuses a name the app's own code already uses.

**Extensions.**
- Extend only `Scenes`, `Location`, `Cast`, `Universe`, `Ride`, or types your universe declares.
- In an extension, your own types may conform only to the engine's `Trip`, `CompactionLook` and `UniverseModule`.

**Not allowed:**
- attributes other than `@discardableResult`, `@escaping` and a few like them
- `#if` and other compiler directives (`#available` and `#unavailable` checks are fine; the template's `#if CLAWD_TEMPLATE` lines are taken out by `Tools/new-universe.sh`)
- macros and custom operators
- a file called `main.swift`

**Layout.**
- Files of at most 2,000 lines.
- Lines of at most 260 characters.
- No code after a long run of spaces, where a reviewer wouldn't see it.
- No invisible or text-direction Unicode characters anywhere.
- No non-ASCII characters outside strings and comments.

**Ids.** At most 100 villains and 900 heroes per universe. Character ids are saved, so the cast enums are append-only.

**The manifest.** `universe.conf` is plain `key = value` lines (number, key, title, prefix, entry, reel, cask, detail), and nothing else.

Check your PR yourself before opening it:

```sh
Tools/CheckUniverse/check.sh <YourUniverse>
python3 scripts/pr-guard.py main HEAD
```

The first checks the universe itself (names, counts, ids, that only its folder changed) and builds it; the second reads your branch as text and builds or runs nothing.

## For the maintainer: reviewing a PR

1. **Read the guard's report.**
   - It's on the PR's checks, or run `python3 scripts/pr-guard.py <PR number>`.
   - Red has to be fixed before anything else.
   - Read every yellow file in full, and every warning.
2. **Look at the shape.** Run `git diff --stat main...<branch>` and look for anything outside the universe folder. A universe's PR should change nothing else.
3. **Don't run anything yet.**
   - Never start Claude Code (or any AI assistant) in an unreviewed checkout. A PR can add instructions or settings an assistant would follow.
   - Never run plain `./build.sh` on it. That installs the app, rewrites your AIs' hooks and launches it with your Accessibility grant.
4. **Try it with `./build.sh --untrusted`.**
   - The copy is signed ad hoc, so it gets none of your permissions.
   - It isn't installed or launched, and no AI's hooks are touched.
   - Once you've read the code, open `build/Clawd Clash.app` yourself.
5. **Know what the guard is.** It's a text check, and a determined attacker could find a way past it. It narrows what a PR can hide, so a review only has to read the parts that matter. The review is still yours.
6. **After merging, thank them.** Add the author to `collaborators` in `Sources/App/Overlay.swift` (name, GitHub username, and the universes they made, if any; a bug fix or a feature is thanked by name alone), so they're listed under "Thanks to" in Settings → About.
