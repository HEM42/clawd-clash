# Changelog

## 2.21.0 — 2026-10-10

### Added
- **Gemini CLI support.** Hooks go in `~/.gemini/settings.json`, next to the user's own settings and hooks. A backup is kept, and the handler is named `clawd-wars` so `/hooks disable clawd-wars` works. Gemini CLI uses its own event names, which the hook translates: `BeforeAgent` → prompt, `BeforeTool`/`AfterTool` → tool calls, `AfterAgent` → done (its `prompt_response` becomes the reply), and a `ToolPermission` notification → needs you. Timeouts are in milliseconds there. Its tools are described like Qwen's (`replace`, `write_file`, `run_shell_command`, `grep_search`, `list_directory`, `write_todos`…).
  - `~/.gemini` is shared with Google's newer Antigravity CLI, so Gemini CLI counts as installed only when a `gemini` command exists. The app looks in Homebrew, `/usr/local`, `~/.local`, npm-global, nvm, Volta, Bun, pnpm, Yarn, asdf and mise, because an app's own PATH is bare.
- **GitHub Copilot CLI support.** Our hooks get a file of their own, `~/.copilot/hooks/clawd-wars.json` (`"version": 1`, flat entries with `bash` and `timeoutSec`), which is deleted on uninstall. Using PascalCase event names gets Copilot's Claude-compatible payloads (snake_case fields, Claude tool names), so nearly everything maps directly.
  - `SubagentStart` only exists in camelCase. That one entry is camelCase, and the hook converts the payload (`sessionId`, `agentName`, `agentDescription` → the agent's task).
  - Copilot's `SubagentStop` carries an id its start event never sent, so a Copilot agent that can't be matched by id removes the oldest agent of the same type.
  - Like Gemini, it only counts as installed when a `copilot` command exists. A `~/.copilot` folder alone can come from Copilot in VS Code.
- Gemini CLI (gold) and Copilot CLI (mint) get their own outline colours and list sections, take sides like the others, and are covered by the hook health checks, the first-launch offer and Settings → Install/Remove … Hooks.
- **Claude Desktop vs Claude Code CLI.** Claude Code sessions started from the Claude desktop app get their own "Claude Desktop" section in the window and the menu, and are labelled "Claude Desktop" on cards, hover cards and menu lines. VS Code sessions say "Claude · VS Code".
  - The hook reads `CLAUDE_CODE_ENTRYPOINT`, which Claude Code passes to every hook. Verified on this Mac: `claude-desktop` for the desktop app and `cli` in a terminal. It's stored per session as `client`.
  - Sessions without hooks are recognised by where the `claude` binary lives: `~/Library/Application Support/Claude/claude-code/…` is the desktop app, and `…/extensions/anthropic.claude-code…` is VS Code.
  - Desktop sessions (and their agents) get a coral outline so they stand out from terminal Claude's white. The same colour is used for their section header and card portraits. They're still Claude, so they take Claude's side. Clicking a desktop session brings the Claude app forward.
- The hook takes `--event <name>` for AIs whose payloads don't name the event or use their own names. `StatusStore.normalize` translates the payload before `apply`.

### Fixed
- **Sides with old sessions.** A session recorded before sessions had a start time fell back to its last-update time, which keeps moving, so the oldest AI could look like the newest and the side rule flipped. A missing start time now counts as the oldest.
- **npm-installed AIs that launch a child process.** The scan found both the npm wrapper and the real process, kept the wrapper, and dropped the process actually running the hooks. For Codex, Qwen, Gemini and Copilot it now keeps the child; Claude keeps its old rule for nested runs.

### Changed
- **Window title bar redesigned.** The system close/minimize buttons are gone. The location name moves to the left, and the right side has our own buttons:
  - The **collapse** button (arrows pointing in) hides the session list, leaving just the scene strip. It then becomes an **expand** button (arrows pointing out) that brings the full view back. These replace a minus sign and a chevron, which read like "minimize window" and "menu".
  - **×** quits Clawd Wars. Window mode is remembered, so the next launch opens the window again. ⌘W still closes the window and switches to desktop mode.
  - The location name, collapse icon and close × all share the bar's vertical centre, measured on a real non-Retina window. The × is drawn by hand because the built-in xmark symbol's odd pixel height left it half a pixel low.
  - **Contents centred on the bar as you see it.** Several scenes (the cantina, for one) start with a dark ceiling beam that blends into the bar, so the bar looked 40 px tall and its correctly centred contents looked too high. The scene now measures how many of its top rows are dark (average brightness under 0.24, up to 10 pt). The label and buttons centre on bar + band; scenes with a light top centre on the bar alone. This replaces a short-lived bottom separator line, which didn't help.
  - Both highlight on hover (the close button turns red) and have tooltips. The rest of the bar still drags the window, and ⌘W still closes it.
- **Settings → Show Session List in Window** (on by default). Turned off, the window becomes just its header and the location scene: the list is hidden and the window locks to that height. Turning it back on restores the height you had, or fits the sessions if Fit Window Height is on.
- **Hover cards in window mode only appear when the session list is hidden.** With the list showing, the same details are already right below the scene, so the pop-up just got in the way. The desktop is unchanged.
- "Fit Window Height to Claudes" is now "Fit Window Height to Sessions", since the window lists every AI, not just Claude.
- **Agent rows in the window carry a small "AGENT" tag** before the agent's name, a grey pill like the status chips. Being nested inside the session's card was the only cue before, which was easy to miss.
- **The menu no longer lists the sessions.** The menu bar helmet, right-click and the top-bar Crew menu now open straight onto the options. The window's list and the desktop's hover cards already show every session. ⚠︎ items for hooks that need fixing still sit at the top when there are any.
- **Top-bar menus while the window is in front.** macOS only shows an app's menus with a Dock icon, so with Show Dock Icon off there was nothing up there when Clawd Wars was active. Now, in window mode, the Dock icon and the Clawd Wars / Crew / Window menus appear while the window is the active app and disappear when you switch away. With Show Dock Icon on, nothing changes.
- Window cards lose the thick accent bar on their left edge. The card's border, in the project colour, is now the same width all the way round.
- Settings lists Install/Remove Hooks for every supported AI found on the Mac, generated from `HookInstaller.others`. Cards name the reply's author by AI ("Gemini: …") instead of always "Claude:".

## 2.20.0 — 2026-10-10

### Added
- **Hook health checks for every supported AI, but only the ones installed on this Mac.** Claude Code counts as installed when `~/.claude/projects`, `~/.claude.json` or `~/.claude/settings.json` exists (`~/.claude` alone isn't enough, since Clawd Wars keeps its own state there). Codex and Qwen Code count when `~/.codex` or `~/.qwen` exists. Two things are checked every 10 s:
  - **Installed but not connected.** A banner says "Codex isn't connected", and a **⚠︎ Connect Codex…** item at the top of the menu installs the hooks in one click.
  - **Connected but silent.** A session started after our hooks were written, has been seen working (so a turn ran and a live hook would have fired), yet never reported. For Codex this means the hook hasn't been approved in `/hooks`. The card shows "APPROVE IN /hooks" (other AIs: "NOT REPORTING"), and the hover card, menu line and banner say what to type.
  - Requiring the session to have been busy avoids a false alarm on a freshly opened, idle Codex that hasn't fired any event yet.
- **macOS notification for silent sessions**, once per session: "Approve Clawd Wars in Codex — type /hooks in Codex and approve Clawd Wars (project) to see its live status." Clicking it jumps to that session. Notifications are skipped in playground, demo, chaos and frame-dump runs.
- Process scan records each process's start time (`kp_proc.p_starttime`); the silent check compares it with the hook file's modification time.

- **Each AI looks different.** Sprites get an outline in their AI's colour: white for Claude (as before), cyan for Codex, lavender for Qwen Code. The colours are always light, never black, so they read on any desktop wallpaper. Agents take their session's colour, and the window's card portraits match.
- **The list is split by AI.** With more than one AI running, the window's cards are grouped Claude Code → Codex → Qwen Code, each group under a small coloured divider ("CODEX ────"). The menu bar list gets the same sections. With one AI there are no headers, so nothing changes.
- `--ais=claude,codex,qwen` playground flag: assigns an AI to each playground session (cycled), to check outlines and grouping.

### Changed
- **The first-launch offer covers every AI that's on the Mac and not yet connected**, not just Claude Code. Each AI is offered once (`offeredHooks.<name>`), so someone who connected Claude Code earlier and installs Codex later is asked about Codex on next launch. The offer explains Codex's one-time `/hooks` approval up front.
- The red OFFLINE banner is now only for an unreadable status file. A missing hook shows as the AI-specific banner above, and no longer appears when Claude Code isn't installed at all (e.g. Codex-only users).

## 2.19.0 — 2026-10-10

### Added
- **Qwen Code support.** Qwen Code's hooks are Claude Code-compatible (same events and payload fields), so the same hook binary runs with `--assistant qwen`.
  - Installed into `~/.qwen/settings.json`: existing settings and the user's own hooks are kept, a backup is made, ours use matcher `.*` (Qwen matchers are regexes) and a name so they can be toggled in Qwen's `/hooks`. No trust step is needed.
  - Qwen's tools are described like the others: `run_shell_command` → "Bash: …", `edit` / `write_file` / `read_file` → "Edit/Write/Read <file>", plus grep, glob, web fetch and search, todos, and `task` subagents (whose descriptions become agent tasks).
  - `qwen` processes are found too, so sessions without hooks still appear.
  - Settings has Install/Remove Qwen Code Hooks. `--install-hooks` and the first-launch offer install hooks for every AI found on the Mac.
  - Verified against a sandbox `settings.json` (install, keep, uninstall) and with simulated Qwen events. Qwen sessions take sides like Codex.
- After installing hooks, the app says when Codex needs its one-time `/hooks` approval.

### Changed
- `HookInstaller` describes other AIs generically (`OtherAI`: config file, events, matcher spelling, timeouts). Codex and Qwen share the install/uninstall code.
- With three or more AIs running, the first AI keeps its side and every other AI takes the opposite one.

## 2.18.0 — 2026-10-10

### Added
- **Codex support.** OpenAI's Codex CLI sessions show up next to Claude's, with the same live status (working, thinking, needs you, subagents and their tasks, current tool) and click-to-jump.
  - Codex's hooks use the same event names and payload fields as Claude Code's, so one hook binary serves both: `--assistant codex` tells it which AI is calling.
  - The installer writes `~/.codex/hooks.json` (backup kept, existing hooks preserved). Codex runs new hooks only after you trust them with `/hooks`.
  - Codex's `Interrupt` (Esc) event sets the session idle straight away.
  - Its `apply_patch` edits show as "Edit <file>", and its shell tools as "Bash: …".
  - `codex` processes are found too, so Codex sessions without hooks still appear.
  - Cards, hover cards and the menu say Claude or Codex for each session. Settings has Install/Remove Codex Hooks, and `--install-hooks` / `--uninstall-hooks` handle both.
- **Light side vs dark side.** Heroes and villains are now one cast of 30, and anyone can be a session (drawn large) or an agent (drawn small).
  - With one AI running, characters are random from the whole cast.
  - When a second AI starts, the AI that was there first keeps the side it mostly has (ties go to its first character's side), and the other AI takes the opposite side. Claude with Vader means Codex gets heroes. Each AI's agents join their session's side.
  - A side borrows from the other only when all its own characters are on screen.
  - When one AI closes, it's random again. Existing characters never change.
  - Verified with simulated scenarios: one AI, Claude-first, light-majority-first, closing an AI, exhausted side, agent sides, and Vader/Kylo spacing.
- A hero leading an idle session rests: saber off, blaster lowered. Han gets his Falcon exit as a session too.

### Changed
- Cast ids: villains keep 0…, heroes are 100 + hero index. Agent records carry `cast` (older records fall back to their hero index), and session records carry `assistant`.

## 2.17.4 — 2026-10-10

### Changed
- README: new images of Han's Millennium Falcon departure (a four-step strip) and a desktop hover card. The window screenshots are re-shot without project names over the Claudes (the new window default), and the text explains per-mode labels and the optional fixed window height. The locations sheet always shows the Modal Nodes in the cantina.

## 2.17.3 — 2026-10-10

### Changed
- Project names over the Claudes are remembered per mode: shown by default on the desktop, hidden by default in the window (its cards already name every project). Settings → "Show Project Names on Desktop" / "… in Window" toggles the current mode's choice, which is saved and survives restarts; existing desktop settings carry over. Agents' task labels always show.

## 2.17.2 — 2026-10-10

### Changed
- The cantina's band is now random: each time the cantina comes up (at launch, or on switching to it) it's either Figrin D'an and the Modal Nodes or the Max Rebo Band, on the same stage. The stage is widened to 66 px to fit either. The Max Rebo Band still plays in Jabba's palace.

## 2.17.1 — 2026-10-10

### Fixed
- Droopy McCool now matches the film (checked against Wikipedia and starwars.com): an eyeless Kitonak playing a slim chindinkalu flute, instead of a horn and two little eyes. The band is the original three-piece lineup (Max Rebo, Sy Snootles, Droopy McCool), not the Special Edition one.

## 2.17.0 — 2026-10-10

### Added
- **Han leaves on the Millennium Falcon.** When Han Solo's agent finishes, instead of fading out:
  1. the Falcon swoops in over his head toward the open side of the screen and lands beside him (landing gear down);
  2. the ramp lowers, Han walks over and up it, and the ramp closes;
  3. the engines glow blue and it lifts off and flies away.
  The whole thing takes 6 s. The Falcon is drawn in code as a saucer seen slightly from above: central hatch, split front mandibles with the cargo gap, side cockpit, radar dish, engine glow.
- Developer aids: `CLAWD_SHOT` accepts `%d` for numbered frame sequences, with `CLAWD_SHOT_EVERY=<seconds>` (default 5), and `CLAWD_DISMISS_AFTER=<seconds>` makes Playground agents finish, for testing departures.

## 2.16.0 — 2026-10-10

### Added
- The cantina band as seen in the film: **Figrin D'an and the Modal Nodes**, four Bith with their instruments. Figrin D'an plays a kloo horn (black, silver keys, flared bell), Doikk Na'ts the Fizzz, and Ickabel G'ont and Tedn Dahai fanfars. Each bobs on their own beat.
- **The Max Rebo Band** in Jabba's palace: Max Rebo (blue Ortolan with floppy ears and a trunk) at his red organ with blinking keys, Sy Snootles (thin yellow-green singer with the long lips) at a microphone stand, and Droopy McCool (chubby pale Kitonak) on his long horn.
- **The bar crowd** in the cantina: Wuher the bartender behind the counter polishing a glass, and Dr. Cornelius Evazan (scarred face, dark coat) with Ponda Baba (Aqualish, tusks) leaning on the end of the bar.
- **Chaos test** (`--chaos[=seconds]`, a developer tool, hidden from users). Every half second it randomly adds and removes Claudes (up to 7) and agents (up to 12) and flips their moods, while checking that:
  - no character is off screen after walking in;
  - nobody walks for more than 8 s;
  - every session and agent appears within 3 s;
  - there are no extra characters;
  - labels stay on screen and never overlap.
  It prints a report and exits non-zero on violations. First runs: 90 s on the desktop (36 agents) and 90 s in window mode (43 agents), no violations.

### Changed
- README: describes both bands, the bar crowd, hover cards, walk-ins, sitting idle, NOT REPORTING and the OFFLINE banner. `docs/locations.png` and `docs/window-cantina.png` are regenerated.

## 2.15.3 — 2026-10-10

### Fixed
- Everyone now stands on the same pixel row. Measured every character's lowest pixel; feet should end on row 43:
  - Vader, Kylo, Dooku, the Emperor, Leia and the Jawa stood 1 px lower because their capes, robes and gowns hung one row past the feet. Hems now end on row 43.
  - The tauntaun stood 1 px higher (feet one row short).
  - Jabba floated 1 px when laughing. His belly now stays planted and only the upper body bobs.
  - The Gamorrean's resting axe and the Rancor's resting claw poked below the floor. The axe is now shouldered and the claw hangs forward.
- Positions saved under the older snap rule were still 1 px too low after the snap fix, because the fix only ran while dragging. The saved position is now re-snapped on launch and on Reset Position.

## 2.15.2 — 2026-10-10

### Changed
- Releases are notarized by Apple and stapled (via the `clawd-wars` notarytool keychain profile), so the downloaded app opens without a Gatekeeper warning. The Homebrew cask no longer needs to clear the quarantine flag.

## 2.15.1 — 2026-10-10

### Fixed
- Snapping the crew to the bottom of a screen put them 1 pixel too low. The snap treated all 8 canvas rows under the feet as empty, but the bottom row holds the feet's white outline, which ended up just below the screen edge. The snap now leaves 7 rows, so the outline sits on the edge.
- The Homebrew cask uses the current Homebrew syntax: `depends_on macos: :ventura`, and the quarantine-clearing step as a `postflight_steps` `run` step with an `{{appdir}}` path (was the deprecated `postflight` / `system_command`). `brew style` and `brew audit` pass. `release.sh` writes the new form.

## 2.15.0 — 2026-10-10

### Added
- **Homebrew install**: `brew install --cask rodclemen/tap/clawd-wars`. `release.sh <version>` does the whole release:
  1. builds a universal app (arm64 + x86_64, via `lipo`), signed with the Developer ID, hardened runtime, a secure timestamp, and the Apple Events entitlement so click-to-jump keeps working;
  2. notarizes and staples it when a `notarytool` keychain profile named `clawd-wars` exists;
  3. zips it, tags it and publishes a GitHub release with the CHANGELOG section as notes;
  4. writes the cask into `rodclemen/homebrew-tap`. Until releases are notarized, the cask clears the quarantine flag after install. Uninstalling the cask removes the hooks; `--zap` also removes settings and the status file.
- `build.sh --release <version>` makes the universal, distribution-signed build without installing it. The app version now comes from the newest CHANGELOG entry.
- **First-launch offer** to connect to Claude Code (install the hooks) when the app wasn't set up by `build.sh`, e.g. installed from Homebrew. It's asked once and can be done later from Settings.
- **`llms.txt`**: a guide to the repo for AI coding tools (build and run, code map, sprite conventions, how to add characters, fight rules).

## 2.14.0 — 2026-10-10

### Added
- **Hover details** (from agent-view): hovering any villain or agent, on the desktop or in the window, shows a card beside it, kept on screen. For a Claude: name and project, status and duration, current activity, your last prompt, agent count, and "Click to jump". For an agent: its task, current tool, age and tool count, and which Claude it belongs to. Agents now take hover and clicks on the desktop too (a click jumps to their Claude).
- **Walk-ins** (from agent-view's door): new Claudes and agents walk in from the side, 240 pt × zoom away, one at a time with 0.6 s between them, instead of fading in where they stand. On launch everyone is simply in place.
- **Staged idle**: a lone idle Claude stands for 2 minutes, then sits down (legs folded, body on the floor, cape stopping at the floor), and shows zZz after 5 minutes. Walkers, Jabba, the Rancor and the Emperor stay standing. Claudes that are fighting don't sit.
- **Explicit offline state** (from agent-view): a pulsing red OFFLINE banner over the crew on the desktop when the hooks aren't installed or the status file can't be read (the window shows it above the cards). A session the hooks still call idle, whose process has been busy for over a minute with no agent reporting, is marked **not reporting**: "?" bubble, NOT REPORTING on its card, and a hover note to restart it.
- Debug and screenshot aids: `CLAWD_HOVER=<key>` pretends to hover a character, `--mood=idle|thinking|waiting|working` sets the Playground mood at launch, and Playground "Idle" spreads villains across the idle stages.

## 2.13.1 — 2026-10-10

### Added
- Ready to share as a public repo:
  - MIT `LICENSE`, so the code is free to use, change and share. It's the plain MIT text so GitHub recognises it; the trademark note (Star Wars belongs to Lucasfilm/Disney, Claude and Clawd to Anthropic) lives in the README footer.
  - README badges (MIT, macOS 13+, Swift, for Claude Code, free to use), a Contributing section on how to add a villain, hero or location, and a License section.
  - `docs/social-preview.png` (1280×640), the link card for X, Slack, Discord and iMessage, rendered by `Tools/RenderDocs`.
  - GitHub description and topics.

## 2.13.0 — 2026-10-10

### Added
- A GitHub README with the pitch up top, the icon, a desktop battle strip, the full roster, window-mode screenshots in the Mos Eisley Cantina and on Hoth, and a grid of all 22 locations. Images live in `docs/`.
- `Tools/RenderDocs`: renders `docs/roster.png` (every villain and hero, labelled, mid-action) and `docs/locations.png` (every location with its animation frame) with the app's own sprite code. Window and desktop screenshots are made with `CLAWD_SHOT` and the Playground.
- Playground sessions get realistic sample details (model, current activity, last prompt and reply, prompt and tool counts, uptime, and each agent's activity, age and tool count), so their cards look like live ones.

## 2.12.0 — 2026-10-10

### Added
- **Greedo** villain: a green Rodian Clawd with huge glossy black eyes, a tapir snout, head spines and ear fans, a dark vest over a pale tunic, and his small blaster pistol (bolts leave from its muzzle). Home: the Mos Eisley Cantina.

## 2.11.2 — 2026-10-10

### Fixed
- The Rancor's card portrait was shown at 1× because the redrawn upright rancor is 42 px tall. The portrait box is now sized from measured maxima across all villains (widest: AT-AT, 53 px; tallest: Rancor, 42 px) to 112×86 pt, so every portrait fits at 2×.

## 2.11.1 — 2026-10-10

### Changed
- The rancor is now just "Rancor" and redrawn to match the film (per the Star Wars databank): upright on two short, stubby legs with three-toed feet, a tall torso hunched forward, spines along its back and shoulders, scaly grey-brown hide, a flat face that's mostly fanged mouth with tiny eyes, and disproportionately long arms. One arm hangs almost to the ground; the other swipes from below the jaw.

## 2.11.0 — 2026-10-10

### Added
- **The Rancor** villain: a hulking brown beast-Clawd with warty hide, a huge fanged mouth, tiny yellow eyes, thick clawed legs and a hanging arm. It fights with claw swipes on its other arm (melee, so it duels sabers).
- **Rancor Pit** location under Jabba's palace: rough stone, the keeper's barred gate, bones and skulls on the floor, and light falling through the grate above with drifting dust.

### Fixed
- The card portrait box is 80 pt tall (was 76), so the rancor shows at 2× instead of dropping to 1×.

## 2.10.0 — 2026-10-10

### Added
- **Tauntaun** hero (agent): a shaggy grey-white biped with curled horns, a long snout, two big feet and a swishing tail. It's unarmed like R2-D2 and C-3PO, so it doesn't fight. It stomps now and then, bobs its head, and huffs frosty breath. Home: Hoth.

### Changed
- The location name in the window's title bar is back to its earlier style (10.5 pt semibold, light grey, uppercase) instead of crawl-yellow, and stays on the right.

## 2.9.1 — 2026-10-10

### Fixed
- The AT-AT (and other wide characters) were cut off in the window's cards. Portraits used a fixed crop sized for a standard Clawd. They are now cropped to each character's visible pixels (`PixelCanvas.opaqueBounds`) and drawn as large as fits, up to 2× (whole-number scales keep pixels crisp), centred at the bottom. The portrait column is widened to 112 pt so the AT-AT fits at 2×. Agent portraits use the same fitting.

## 2.9.0 — 2026-10-10

### Added
- **AT-ST** villain: a grey cockpit Clawd (viewport slit, side pods, chin guns) on two long, backward-bending legs with wide feet that step when walking. Fires from its chin guns. Home: the Forest Moon of Endor.
- **AT-AT** villain: Clawd as the walker's body (it already had four legs), with armour plates, neck, head with viewport and snout, and heavy chin cannons. Home: the Battle of Hoth.
- **Wicket the Ewok** hero: a small furry Clawd in a leather hood with ears poking through, big dark eyes, and a stone-tipped spear that fights as a melee weapon (duels sabers). Home: Endor.
- Two locations: **Forest Moon of Endor** (giant redwoods, Ewok huts on platforms with rope ladders, ferns, forest floor) and **Battle of Hoth** (snowfields and mountains, the shield generator dish, the Rebel trench with a turret, falling snow).
- `Leader.muzzle`, so a walker's bolts leave from its chin guns in fights.

### Changed
- The window's title bar shows only the location name, right-aligned in crawl-yellow. The CLAWD WARS title and the yellow rule under the bar are removed.

## 2.8.0 — 2026-10-10

### Changed
- New **Settings** submenu in every menu (menu bar helmet, Crew, right-click) holding the preferences: Size (desktop only), Show Project Names, Keep Window on Top, Fit Window Height to Claudes, Show Dock Icon, Launch at Login, and Install/Remove Claude Code Hooks. The top level keeps the everyday actions: session status, Show in Window/Desktop, Location, Forget Idle Sessions, Reset Position (desktop only) and Quit, plus Playground and Demo with ⌘.
- The pin capsule is gone from the window's title bar; it's now Settings → Keep Window on Top.

## 2.7.2 — 2026-10-10

### Changed
- The window's green maximise button is hidden, full screen is disabled (`.fullScreenNone`), and double-clicking the title bar no longer zooms. Width is resized by dragging the edge, and height follows the Claudes (or is set by hand when auto-height is off).

## 2.7.1 — 2026-10-10

### Fixed
- Cards no longer leave a scrollbar-sized gap on the right, or shift sideways when the window changes height. The card area uses overlay scrollers (re-applied on resize, because macOS can switch back to legacy scrollers when a mouse is connected), and cards are sized to the scroll view's full width, so both margins are 12 pt. Auto-height pauses while you drag the window edge and settles when you let go (`windowDidEndLiveResize`), so the cards don't jump around mid-drag.

### Added
- "Fit Window Height to Claudes" toggle in window mode (on by default). With it off, the window keeps whatever height you give it, and the cards scroll if needed.

## 2.7.0 — 2026-10-10

### Changed
- Window mode has a themed title bar instead of the grey system one. The window uses a full-size content view with a transparent, title-less system bar, and the traffic lights stay. In their place is a `HeaderView` in the current location's colours, with a thin crawl-yellow rule, **CLAWD WARS** in condensed bold crawl-yellow (Futura Condensed ExtraBold, falling back to Helvetica Neue Condensed Black), and the location's name. Dragging the bar moves the window and double-clicking zooms it. The "Keep on top" checkbox is replaced by a yellow pin capsule in the bar (filled "◉ ON TOP" when pinned). The bar redraws when the location changes, and auto-height includes it.

## 2.6.2 — 2026-10-10

### Changed
- "Show Dock Icon" now applies in both desktop and window mode (on by default). With it on, Clawd Wars has a Dock icon and an app menu bar (app menu + Crew menu) in both modes. With it off, it's a menu-bar-only accessory in both, reached through the helmet. Clicking the Dock icon in window mode brings the window forward. The app menu's Show in Window / Show on Desktop label follows the current mode.

## 2.6.1 — 2026-10-10

### Added
- "Show Dock Icon in Window Mode" toggle (on by default). With it off, window mode keeps the app as an accessory: no Dock icon and no app menu bar. The menu bar helmet still has every option. Toggling it while the window is open re-shows the window, because changing the activation policy hides it.

## 2.6.0 — 2026-10-10

### Added
- The window sizes its height to its content: the scene strip plus one card per Claude, agent lists included. It grows and shrinks as Claudes and agents come and go, keeps its top edge in place, and stops at the screen's visible height (the cards scroll beyond that). The width stays under your control. Checked: 296 pt of content for one Claude, 524 pt for three.

## 2.5.1 — 2026-10-10

### Changed
- Playground and Demo Mode are hidden unless ⌘ is held while opening the menu: the Crew menu, the menu bar helmet or the right-click menu. While either is running, both stay visible so you can leave.

## 2.5.0 — 2026-10-10

### Added
- Menu bar icon: a Vader Clawd helmet cropped from the sprite, always present in desktop and window mode. It opens the same menu as right-clicking a villain (session status and agents, Show in Window / on Desktop, Location, Size, Playground, Demo, hooks, Quit). Checked with `VADER_DEBUG`: the item is visible on screen in the main display's menu bar.
- In window mode the app's menu bar gains a **Crew** menu with the same items.
- Both menus are rebuilt from live state each time they open (`NSMenuDelegate.menuNeedsUpdate`).

## 2.4.2 — 2026-10-10

### Changed
- Window mode always uses the Small size (0.67), still shrinking further if the window is too narrow. The location backdrops now use 2 pt pixels to match the crew, and the scene strip is shorter (170 pt; floor 20 pt, feet at 16 pt), leaving more room for the cards.

## 2.4.1 — 2026-10-10

### Changed
- Size is disabled in window mode; the menu shows "Size (desktop only)". The window always draws the crew at full size and shrinks it only to fit the window width, with a fixed scene height. Before, the desktop size setting also shrank the crew and the scene strip inside the window.

## 2.4.0 — 2026-10-10

### Added
- 19 window-mode locations (`Locations.swift`), each drawn as pixel art in code on shared helpers (banded gradients, stars, dunes, circles and ellipses, textured ground). On Automatic, the first-spawned Claude decides where the crew is:
  - Vader: Death Star corridor, with a viewport onto space
  - Boba Fett: Great Pit of Carkoon, with the sarlacc (tentacles waving) and Jabba's sail barge
  - Jabba / Gamorrean Guard: Jabba's palace throne room (dais, hookah, rancor grate, flickering torches)
  - Stormtrooper: the Mos Eisley cantina
  - Kylo Ren: Snoke's red throne room on the *Supremacy*, with Praetorian guards
  - Darth Maul: the Theed generator complex, with pulsing laser gates
  - The Emperor: Death Star II throne room, with Endor and the battle flashing in the round window
  - Count Dooku: Geonosis rock spires
  - R0-GR: the plains of Naboo, with Trade Federation tanks
  - IG-88: the *Executor*'s bridge (Star Destroyers outside, crew pits, blinking consoles)
  - Hero homes, chosen from the Location menu: Lars homestead under the twin suns (Luke), Obi-Wan's hut, the Jawa sandcrawler (Jawa, R2-D2), Dagobah with drifting fog (Yoda), the Millennium Falcon hold with a flickering dejarik game (Han, Chewbacca), the Tantive IV (Leia, C-3PO), the Jundland Wastes with a Tusken Raider and a bantha (Qui-Gon), Jakku with the crashed Star Destroyer (Rey), and the Jedi Council chamber over the Coruscant skyline (Mace Windu, Ahsoka).
- Window right-click menu → Location: Automatic (where the first Claude belongs), or pin any scene. Each entry lists who it belongs to.
- The card area takes on each location's tone (desert sand, Death Star grey, Supremacy red, Dagobah green…).

### Changed
- Each scene is cached per window size and location; only its animated layer is redrawn per frame.

## 2.3.0 — 2026-10-10

### Added
- Window mode is set in the Mos Eisley cantina (A New Hope). `Cantina.swift` draws the scene strip as pixel art: white-plaster adobe walls with a hand-finished texture, ceiling beams, hanging lamps with faint light shafts, arched booth alcoves (round table, lamp, bench), the curved bar with a brass rail and a shelf of glowing bottles, a packed-earth floor, and Figrin D'an and the Modal Nodes — three Bith on a stage, bobbing in time with music notes drifting up. The room is rendered once per window size and cached; only the band animates. The crew stands a little way into the floor.
- The card area is restyled as warm dark adobe with a plaster texture, and cards are warm-tinted to match. The window background follows.

## 2.2.0 — 2026-10-10

### Added
- **Show in Window** (right-click menu). A normal window with a Dock icon and menu bar replaces the desktop overlay. A starfield strip on top shows the crew, laid out and drawn by the same code as the overlay, with the strip acting as their "screen". The crew is centred and shrinks to fit the window width. Below it is one card per Claude:
  - villain portrait, name and project in its accent colour, plus a status chip with how long it's been in that state (WORKING · 2m 10s, THINKING, NEEDS YOU, IDLE, ASLEEP, NO LIVE STATUS, BUSY (CPU));
  - model and session title, what it's doing now ("Now: Edit Overlay.swift"), your last prompt, and its last reply when idle;
  - prompt and tool-call counts, uptime and working folder;
  - its agents, each with portrait, hero name, task, current tool, age and tool count.
  Clicking a card or a character jumps to that session. "Keep on top" pins the window. A red banner says so when the hooks aren't installed (from agent-view: never show stale data silently). Closing the window goes back to the desktop overlay, and the window remembers its frame.
- The hook records more per session: model and session title (SessionStart / UserPromptSubmit), last prompt, Claude's last reply (Stop's `last_assistant_message`), the current activity, tool and prompt counts, and when the state last changed. Tool calls are summarised as "Edit Overlay.swift", "Bash: swift build", "Grep fightRoles", "Fetch github.com", or "server: tool" for MCP. Agents get their current activity and tool count too.
- From [agent-view](https://github.com/HEM42/agent-view):
  - Status debounce: a new mood must hold for two refreshes, except "needs you", which shows instantly.
  - A "?" bubble for sessions without hooks, instead of pretending they're idle.
  - A zZz bubble after 5 minutes idle.
  - A "needs you" ignored for more than a minute makes the villain jump and wave, and the "!" flashes faster.
  - A bobbing yellow marker over the Claude whose terminal or VS Code tab is in front.
  - Project accent colours: collision-free, remembered, and shared by a Claude and its agents on label borders and cards.
  - Labels never overlap: Claudes get first pick and colliding labels move up a row.
  - `CLAWD_SHOT=/path.png` writes the rendered scene (or the whole window) every 5 s, so visuals can be checked without screen recording.

### Changed
- Speech bubbles go on the side away from the nearest neighbour, so it's clear whose bubble it is. When a bubble sits on the left, only its frame is mirrored; the "?" and zZz never read backwards.
- The "hooks installed" check matches the hook by name instead of exact path.
- Playground and Demo agents start their clocks when created instead of showing nonsense ages.

## 2.1.1 — 2026-10-10

### Added
- Version control: the project is now a git repository, pushed to a private GitHub repo (`rodclemen/clawd-wars`). `.gitignore` excludes `build/` (recreated by `build.sh`), personal `.vscode/` settings and `.DS_Store`.

## 2.1.0 — 2026-10-10

### Added
- Agents show what they're doing, in a label box above their head. `SubagentStart` only carries the agent's type, so the hook queues the `description` from each Agent/Task `PreToolUse` and gives it to the next agent of that type that starts in the same session (oldest first, any type as a fallback). Agents without a description, such as workflow agents, show their type ("Workflow Agent", "Explore"; general-purpose shows "Agent"). Checked with the live hook: two agents started in reverse order each got the right task.
- Agent label boxes are blue-tinted with a smaller font and an 88 pt × zoom max width (two lines), so they fit between neighbours and stand apart from the grey project-name boxes over Claudes.
- The right-click menu lists each agent as "Hero — task". Playground and Demo agents get sample tasks.

### Changed
- `AgentRecord` gains `task` and `StatusFile` gains a `pending` queue, pruned after 120 s or when the session ends. Both are optional, so state written by older versions still loads. Each companion also has a `headTop` so labels sit just above its hair, dome or helmet.

## 2.0.1 — 2026-10-10

### Changed
- Speech bubbles are about half the size: an 18×13 canvas with a 15×9 box, down from 28×18 and 23×12. They only ever hold three thinking dots or a "!", so the extra room was wasted. The dots are 2×2 squares and the "!" is a 3-pixel bar with a dot. Because the bubbles are smaller, a label pushed over a bubble needs to rise less.

## 2.0.0 — 2026-10-10

### Changed
- Renamed to **Clawd Wars**. The app installs as `~/Applications/Clawd Wars.app` and the executable is `ClawdWars`. `build.sh` removes the old `VaderClaude.app`, stops either process name, and re-points the Claude Code hooks at the new path (quoted, since it contains a space). The bundle ID (`com.rodclemen.vaderclaude`), the hook binary name and `~/.claude/vader-status` are unchanged, so the Accessibility grant, saved position and size carry over. Checked after the rename: the hook fires and Accessibility is still trusted.

### Added
- App icon: Vader Clawd and Luke crossing red and green sabers with a clash spark, on a pixel starfield over a Claude-orange horizon. It's drawn by `Tools/MakeIcon` with the app's own sprite code (outline included), stored as `Resources/AppIcon.png`, and turned into `AppIcon.icns` by `build.sh` (sips + iconutil).

### Fixed
- The project label of the rightmost Claude could run off the right edge of the screen, especially with two busy Claudes and their speech bubbles. Labels (and the "Roger roger!" / "Ho ho ho!" callouts) are now kept inside the screen. When the clamp pulls a label back over a speech bubble, it moves up to sit on top of the bubble.

## 1.9.5 — 2026-10-10

### Fixed
- Jumping to a VS Code native tab actually switches the tab now. Traced with the new `--jump` diagnostic: AXPress on the tab's AXRadioButton returned success (0), but VS Code (Electron) ignored it, even after being activated first. Jump still activates the app and presses the tab, then checks whether the window title changed. If it didn't, it opens the project folder in the same app. That folder is already open as a tab, so VS Code just focuses that tab and opens no new window. The folder path is cut from the session's cwd at the exact folder whose name matched a tab title, so a subfolder never opens a fresh window. Checked live: another project's tab came forward.

### Added
- `--jump=<pid> <logfile>` diagnostic: runs the click-to-jump path for a Claude process and logs each step (host app, cwd, windows and tabs seen, press result, fallback taken).

## 1.9.4 — 2026-10-10

### Fixed
- Clicking a villain now selects the right VS Code tab when `window.nativeTabs` is on. With native tabs, macOS exposes only one window per tab group, titled after the selected tab. The other projects exist only as AXRadioButton tabs in its AXTabGroup, so the old window-title search found nothing and just activated VS Code. Jump now searches every window's tab bar first and presses the tab whose title matches the session's project folder (deepest folder first, exact before substring), then raises that window. It falls back to window titles for apps without native tabs.

### Added
- `--ax-dump=<pid> [file]` diagnostic: lists the Accessibility trust status, the host app, the session's cwd, and every window and tab title the app can see. Run it with `open -n VaderClaude.app --args …` so it uses the app's own Accessibility grant.

## 1.9.3 — 2026-10-10

### Changed
- Project label boxes sit 5 pt higher above each villain's head (8 pt instead of 3 pt × zoom), so the box doesn't crowd the helmet or hood.

## 1.9.2 — 2026-10-10

### Changed
- Long project names wrap onto two centred lines in the label box (max width about 110 pt × zoom, roughly a villain's width). Lines break at spaces, dashes and underscores. A single word too long for one line fills the first line and continues on the second, and anything past two lines ends in "…". For example, "my long project name" shows as "my long / project name".

## 1.9.1 — 2026-10-10

### Fixed
- On stacked monitors the crew couldn't stand on the bottom edge of the upper monitor. The drag clamp chose the screen from the canvas bottom, which sits 8 rows below the feet. Once that point crossed into the lower monitor, the clamp used the lower monitor's limits and stopped the drag. Now the clamp uses the screen under the cursor while dragging (otherwise the one under the feet). The empty rows under the feet may hang off the edge, and feet dropped within 12 pt of a bottom edge snap onto it. Checked against the real layout: dragging past the upper monitor's bottom puts the feet exactly on its bottom edge, and the same on the lower monitor.
- Saved positions are validated by where the feet are, so a crew standing on an edge at a large size isn't reset on launch.

## 1.9.0 — 2026-10-10

### Added
- Four new villains:
  - Count Dooku: red saber, dark cape, white hair and pointed beard.
  - Gamorrean Guard: green pig face, horned leather cap and tusks; swings a vibro-axe (fights as melee, drawn as an axe, no glow).
  - Jabba the Hutt: a big slug body with a tail and slit eyes. Unarmed, so he joins the cheerers and calls "Ho ho ho!" instead of being paired into a fight.
  - IG-88: grey droid with a tall striped sensor head and a blaster rifle.
- Seven new heroes:
  - Saber users: Qui-Gon Jinn (long hair and beard, green), Mace Windu (bald, brown robes, purple), Yoda (green with big ears and a short green blade), Rey (buns, wraps, blue) and Ahsoka Tano (striped montrals, facial markings, twin white sabers).
  - Blaster users: Chewbacca (fur, bandolier, bowcaster) and a Jawa (hooded robe, glowing yellow eyes, ion blaster).
- White 1px outline around every character, so dark sprites read on a black desktop. Only fully opaque pixels are outlined, so saber glows and bolts stay clean.
- Project labels sit in a dark rounded box with white text and a faint border, readable on any wallpaper.

### Changed
- Agents are now random heroes not already on screen, the same way villains are. Before, the lowest free one was picked, so the new heroes would only appear with 7+ agents at once.
- The crew can sit right on the bottom edge of the screen. Each sprite has 8 empty pixel rows under its feet (24 pt at normal size), and dragging used to stop that empty space, not the feet, at the edge. "Reset Position" also puts the feet on the edge now.

## 1.8.0 — 2026-10-10

### Added
- R0-GR, a B1 battle droid, as a seventh villain. It's a tan droid Clawd with the long forward snout head on a thin neck, skinny legs and an E-5 blaster. It fights like the other blaster villains, and every 5 s it calls out "Roger roger!" on the side of its head away from the speech bubble. It's in the random spawn pool and the Playground.

### Changed
- Vader is no longer always first. The first session gets a random villain like everyone else, and the Vader/Kylo spacing rule still applies. Simulation: Vader came first in 287 of 2000 runs, about 1 in 7, with zero back-to-back Vader/Kylo spawns. The first-spawned villain stands on the saved spot and the crew lines up from there. An idle Vader appears only as a placeholder when no Claude sessions are running.

## 1.7.0 — 2026-10-10

### Changed
- Villains are assigned at random instead of in fixed order. The first session is still Vader (the crew forms around him). After that, each new session gets a random free villain, and Vader and Kylo never spawn one right after the other. A simulation of 2000 four-session sequences found zero Vader→Kylo or Kylo→Vader spawns. Sessions found only by the process scan use a pid-seeded pick so they keep the same villain between refreshes.
- Sessions are recorded with a `created` time, and the line is ordered by spawn order (Vader first) instead of villain index, so "who came after whom" matches what you see.

## 1.6.0 — 2026-10-10

### Changed
- New fight rules:
  1. Claudes always fight Claudes, whatever each one is doing. Their bubbles and labels still show status.
  2. Agents fight agents, across sessions.
  3. If one Claude and one agent are left over, they fight each other (one Claude + one agent = Vader vs Luke).
  4. Anyone else left over cheers, so a second session's Claude starts duelling Vader while a lone agent cheers them on.
  5. A lone Claude with nobody to fight does its normal kata when working.
  Within each group saber users pair first. R2-D2 and C-3PO remain bystanders.
- Fighting no longer depends on activity, so the activity window and the working/thinking check for fights are gone.

## 1.5.0 — 2026-10-10

### Added
- Everyone fights. Every armed character on screen pairs off, active villains and agents alike. R2-D2 and C-3PO stay unarmed bystanders. Pairing is greedy in priority order: villain vs agent saber duels (Vader vs Luke) first, then any saber vs saber, then villain vs agent, then whoever is left. Villains fight while their Claude is working or thinking (with a 3 s linger) and step out when idle or waiting on you.
- With an odd number of fighters, the leftover cheers: it hops twice a second, waves its saber overhead (blasters are raised, the Emperor crackles) and has blinking stars above its head.
- Agents take fight roles. Luke and Obi-Wan duel, deflect bolts and block lightning. Han and Leia shoot at their opponent with bolts drawn by the effects layer, and shake when zapped.
- `--agents=0,1,…` launch flag (pairs with `--playground=`) for testing.

### Changed
- Fight effects work between different-sized sprites. Each side is described by a `Fighter` (position, scale, canvas offset, facing, muzzle). Clash sparks are placed where the two mirrored blades actually intersect, bolts aim at the deflecting blade's peak position (or the target's body), and lightning targets the blocking blade.
- Saber duel distance scales with both sprites, so blades cross whether it's villain vs villain (170 pt), villain vs agent (~126 pt) or agent vs agent.
- `Weapon` is a top-level type shared by villains and agents. `fightRoles` and `fightIsCloseQuarters` take weapons instead of villains.

## 1.4.1 — 2026-10-10

### Fixed
- Duels never started with real sessions that predate the hooks. Those sessions only came from the process scan and were always idle, so they never counted as active and couldn't fight. Vader ended up swinging at an idle Kylo. Hook-less sessions now count as working while their claude process uses more than 3% CPU, sampled every 3 s and held for 6 s (measured: idle about 0.3%, working 5–10%). They still can't report thinking, permission prompts or agents until they're restarted with hooks.

### Added
- Debug aids: `--playground=0,1,…` starts the Playground with those villains, and `VADER_DEBUG=1` logs each villain's position, facing, mood and fight role twice a second.

## 1.4.0 — 2026-10-10

### Added
- Click a villain to jump to its Claude session. The app walks up from the claude process to the GUI app hosting it. In Terminal.app or iTerm2 it selects the exact tab by tty (AppleScript). In VS Code, Cursor and other editors it raises the window whose title names the session's project (Accessibility API). The project is matched deepest folder first and never opens a new window. A click is told apart from a drag by under 4 pt of movement. Playground and demo villains, which have no process, just beep.
- `build.sh` signs with your Developer ID / Apple Development certificate when one exists, so the Accessibility grant survives rebuilds. It falls back to ad-hoc signing.

### Changed
- Fight pairing is now dynamic instead of fixed slots (1st+2nd, 3rd+4th). Active saber users are paired with each other first, then the remaining active Claudes pair in order, and idle Claudes stand aside. Before, a third lightsaber Claude practised next to a duelling pair, facing the same way as its neighbour. Now any two active saber Claudes walk over and duel. The line keeps session order, so it only reshuffles when someone starts or stops working.

## 1.3.0 — 2026-10-10

### Added
- Playground (right-click → Playground) for previewing villains and matchups without real Claude sessions:
  - Tick any of the six villains to put them on screen. They pair up and fight in the order you add them, so you pick the matchups (e.g. Boba then Vader to watch deflections, Emperor then Maul for saber-vs-lightning).
  - Tick any of the six agents; they join the first villain.
  - "Villains Are…" switches everyone between Working (fighting), Thinking, Waiting for you and Idle.
  - "Add All Villains" adds the whole roster; "Exit Playground" goes back to live status.
  - Turning on Demo Mode leaves the Playground, and vice versa.

### Changed
- Project labels now sit just above each villain's helmet or hood instead of under its feet. Each villain has its own head height (Boba's clears his antenna), and if a speech bubble is showing on that side, the label slides away from it.

## 1.2.0 — 2026-10-10

### Added
- Session discovery from the process table (`Sources/Shared/Processes.swift`). The app scans for interactive `claude` processes every 3 s and reads each one's working directory, so every open Claude Code session gets a villain and project label even if its hooks never fired. Claude Code only loads hooks at startup, so sessions started before the install were invisible. Sessions found this way show as idle, and the menu marks them "no live status (restart this Claude session)".
- The hook records the PID of the Claude process that ran it. The app and the hook both drop a session (and its agents) the moment that process exits, which replaces the 3-hour stale timeout for anything with a PID.

### Changed
- Records without a PID are matched to a running process by project folder, so a session isn't counted twice while it upgrades.

## 1.1.0 — 2026-10-10

### Added
- Several Claudes at once: each Claude Code session gets its own Clawd villain (Vader, Kylo Ren, Darth Maul, Boba Fett, Stormtrooper, Emperor) with its own mood and its own agents. The hook stores the leader index and project folder per session, and the overlay labels each villain with its project name. You can turn the labels off in the menu.
- Fights between paired Claudes when both are working. Saber vs saber steps in to a synced duel with clash sparks where the blades cross. Blaster vs saber shoots bolts, and the defender's swing is timed to deflect each one up and away. Emperor lightning is caught on a saber blade or zaps a blaster user. Blaster vs blaster is a shootout. A fight carries on for 3 s after one side stops working, so the gaps between tool calls don't break it up.
- Proper blasters drawn from the film designs: Han's DL-44 (scope, conical flash hider, wood grip), Leia's Defender sporting blaster (chrome slide), the Stormtrooper's E-11 (scope, magazine, cooling holes) and Boba's EE-3 (brass fittings). Boba's jetpack fires while he shoots.
- Walking: every character walks (stepping legs, facing the way it's going) to its spot in the formation, so the crew shifts as a group to stay on screen and walks back home afterwards.
- Menu items: Show Project Names and Forget Idle Sessions (clears sessions whose terminal closed without a clean exit). There's also a `--demo` launch flag.

### Changed
- Layout: the fixed slot window is replaced by a formation laid out toward the side of the screen with more room. Every sprite faces open space, the window resizes to fit what's drawn, and the layout reserves saber room so the crew doesn't jitter between thinking and working.
- Thought and "!" bubbles are drawn separately from the sprite and flip to whichever side of the head fits on screen.
- A "thinking" status within 3 s of a tool call still counts as working, so the lightsaber kata no longer flickers between tool calls.
- Dragging keeps Vader and his bubble fully on screen. Any villain can be grabbed to move the whole crew.
- Idle scenes render at 10 fps instead of 30 to cut CPU use.

### Fixed
- Sessions recorded before 1.1 had no leader assigned. The hook now fills one in on the next event, so an existing session doesn't keep showing as the wrong villain.

## 1.0.0 — 2026-10-10

### Added
- Darth Clawd: a transparent, always-on-top desktop overlay (status-bar window level, every Space, full-screen apps) showing Clawd in a Vader helmet, cape and chest box. All sprites are procedural pixel art drawn at runtime, so there are no image assets.
- Mood animations: idle breathing, a thought bubble while thinking, a looping lightsaber kata while running tools (with motion trails), a red "!" bubble while a permission prompt waits, and a lit-saber guard stance while agents run after Claude itself has stopped.
- Subagent companions, assigned in this order: Luke (green saber kata), Han and Leia (blaster fire with muzzle flash and bolts), Obi-Wan (blue saber), R2-D2 (rocking, blinking dome light, music notes) and C-3PO (flailing arms). They fade in and out, sit in slots around Vader, gather on the side with more screen room, and mirror on the left so their weapons point outward.
- Drag-to-place: only Vader's body takes clicks and the rest of the overlay is click-through. The position is saved between launches, and the agents follow him.
- Right-click menu: live status and agent roster, Size (Small/Medium/Large/Huge), Demo Mode, Reset Position, Launch at Login, Install/Remove hooks, Quit.
- `vader-hook`: a Foundation-only binary for fast startup that Claude Code runs on 12 hook events. It writes `~/.claude/vader-status/state.json` under `flock`, merges multiple sessions, and expires stuck states because Esc interrupts fire no hook.
- `build.sh`: builds the app, ad-hoc signs it, installs to `~/Applications`, merges the hooks into `~/.claude/settings.json` (backup in `settings.json.before-vader`) and launches it.

### Fixed
- The overlay had dropped to floating level: `isFloatingPanel = true` was overriding the status-bar level, so some windows could cover it.
- First launch now places Vader on the screen under the mouse. Before, it used AppKit's "main" screen, which on a stacked two-display setup can be the display you're not looking at.

---

*Taught a crab the ways of the Sith, then gave it rivals. Spent more time on the blaster deflection angles than on anything with actual business value.*
