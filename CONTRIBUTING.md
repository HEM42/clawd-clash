# Contributing to Clawd Clash

New universes, characters, places and fixes are all welcome. The README's [Contributing](README.md#contributing) section explains how the code is laid out; to build a whole universe, point your AI assistant at [clawdify_guide.md](clawdify_guide.md).

This page is about what a pull request may change, and why.

## Why there are rules at all

A universe is Swift code compiled into the app. The app holds permissions people have given it (Accessibility, and Automation for Terminal and iTerm), and it writes the hook settings of every AI it's connected to. Code in a universe could use all of that. So every PR is checked by a guard, `scripts/pr-guard.py`, before anyone builds it. A universe that only draws things never notices the guard.

## What a PR may change

The guard sorts every file a PR changes into one of three groups.

**Green: change freely.**
- Your universe's own folder, `Sources/App/Universes/<YourUniverse>/`
- Pictures in `docs/`
- `README.md` and `CHANGELOG.md`

**Yellow: fine, and the maintainer reads these closely.** This covers the registration files every universe touches, and the rest of the app:
- `Sources/Shared/Universe.swift`
- `Theme.swift`, `Locations.swift`, `Rides.swift`, `Drills.swift` and `Overlay.swift`
- `Universes/Hem.swift` and `Universes/ComicTransition.swift`
- `SaverView.swift`
- the Tools' `main.swift`

**Red: the guard fails, so ask the maintainer.** A universe never needs to change these, and they're where harm would be done:
- **The build and release scripts:** `build.sh`, `release.sh`, `Tools/*/build.sh`, and any other script.
- **Repo and editor config:** anything starting with a dot (`.github/`, `.claude/`, `.vscode/`, `.gitattributes`…).
- **Instructions for AI assistants and contributors:** `llms.txt`, `clawdify_guide.md`, `CLAUDE.md`, `AGENTS.md` and this file.
- **The hook and the code compiled into it:** `Sources/Hook/`, plus `StatusStore`, `Processes`, `GitRemote` and `SaverFeed` in `Sources/Shared/`.
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

**Imports.** Only `Foundation`, `CoreGraphics`, `CoreText` and `AppKit`.

**Names.** A new top-level name is either `private` or starts with your universe's prefix: the `<Prefix>` of your `<Prefix>Roster.swift`, as in `ringsHeroes1` or `RingsTrip`. A plain top-level name can quietly replace one of the system's (a `chmod` of your own would switch off one of the app's protections), so the guard refuses it. It also refuses a name the app's own code already uses.

**Extensions.**
- Extend only `Scenes`, `Location`, `Cast`, or types your universe declares.
- Don't add protocol conformances in an extension.

**Not allowed:**
- attributes other than `@discardableResult`, `@escaping` and a few like them
- `#if` and other compiler directives
- macros and custom operators
- a file called `main.swift`

**Layout.**
- Files of at most 2,000 lines.
- Lines of at most 260 characters.
- No code after a long run of spaces, where a reviewer wouldn't see it.
- No invisible or text-direction Unicode characters anywhere.
- No non-ASCII characters outside strings and comments.

**Ids.** At most 100 villains and 900 heroes per universe. Character ids are saved, so the cast enums are append-only.

Check your PR yourself before opening it:

```sh
python3 scripts/pr-guard.py main HEAD
```

It reads your branch as text and builds or runs nothing.

## For the maintainer: reviewing a PR

1. **Read the guard's report.**
   - It's on the PR's checks, or run `python3 scripts/pr-guard.py <PR number>`.
   - Red has to be fixed before anything else.
   - Read every yellow file in full, and every warning.
2. **Look at the shape.** Run `git diff --stat main...<branch>` and look for anything outside the universe folder.
3. **Don't run anything yet.**
   - Never start Claude Code (or any AI assistant) in an unreviewed checkout. A PR can add instructions or settings an assistant would follow.
   - Never run plain `./build.sh` on it. That installs the app, rewrites your AIs' hooks and launches it with your Accessibility grant.
4. **Try it with `./build.sh --untrusted`.**
   - The copy is signed ad hoc, so it gets none of your permissions.
   - It isn't installed or launched, and no AI's hooks are touched.
   - Once you've read the code, open `build/Clawd Clash.app` yourself.
5. **Know what the guard is.** It's a text check, and a determined attacker could find a way past it. It narrows what a PR can hide, so a review only has to read the parts that matter. The review is still yours.
6. **After merging, thank them.** Add the author to `collaborators` in `Sources/App/Overlay.swift` (name, GitHub username, what they made), so they're listed under "Thanks to" in Settings → About.
