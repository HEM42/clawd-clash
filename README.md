<p align="center">
  <img src="Resources/AppIcon.png" width="180" alt="Clawd Clash icon: a comic cover in three panels, one per universe, with CLAWD CLASH across them, Spider-Clawd hanging on his web, Darth Vapor raising his saber and Batclawd under the Night Beacon">
</p>

<h1 align="center">Clawd Clash</h1>

<p align="center">
  <b>Your Claude Code, Codex, Qwen Code, Gemini CLI and GitHub Copilot CLI sessions, as a pixel-art Star Clawds, Marvelous Clawds or Detective Clawds battle on your desktop.</b><br>
  Every session is a hero or a villain, every subagent joins in, and they fight while they work.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT license"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-black?logo=apple" alt="macOS 13+">
  <img src="https://img.shields.io/badge/Swift-5-orange?logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/for-Claude%20Code-D97757" alt="for Claude Code">
  <img src="https://img.shields.io/badge/free-to%20use-brightgreen" alt="Free to use">
</p>

https://github.com/user-attachments/assets/40f38c93-73f5-41a9-9d64-f468d5cde2d3

Clawd Clash is one app with three universes: **Star Clawds** (formerly [Clawd Wars](https://github.com/rodclemen/clawd-wars)), **Marvelous Clawds** (formerly [Clawdvengers: Clawd Wars](https://github.com/rodclemen/clawdvengers-clawd-wars)) and **Detective Clawds** (formerly [Justice Clawds: Clawd Wars](https://github.com/rodclemen/justice-clawds-clawd-wars)). Pick one in Settings; a scene never mixes them. Those three pages show each universe on its own; this one is the app.

| Star Clawds | Marvelous Clawds | Detective Clawds |
|---|---|---|
| https://github.com/user-attachments/assets/aff1b2f9-9b96-4dea-8eef-c3f469c93a6b | https://github.com/user-attachments/assets/6b4f2fc2-30cf-4566-a921-0b84d4066867 | https://github.com/user-attachments/assets/0396abbc-5ddd-4345-8e27-f33c2e79d616 |

<p align="center"><sub>🔊 Click the speaker in a player for sound: GitHub starts videos muted.</sub></p>

---

## Contents

- [What it does](#what-it-does)
- [Three universes](#three-universes)
- [Window mode and the screen saver](#window-mode-and-the-screen-saver)
- [The little things](#the-little-things)
- [Install](#install)
- [Coming from Clawd Wars, Clawdvengers or Justice Clawds](#coming-from-clawd-wars-clawdvengers-or-justice-clawds)
- [How it works](#how-it-works)
- [Uninstall](#uninstall)
- [Contributing](#contributing)
- [License](#license)

## What it does

You run Claude Code in three terminals. One is thinking, one is waiting for your permission, one finished ten minutes ago and you didn't notice. Clawd Clash tells you at a glance, without switching windows.

- **Working?** Your Claude fights: a laser sword, a shield, repulsors, heat vision, a spell.
- **Thinking?** A thought bubble.
- **Needs you?** A red `!`, and if you ignore it for a minute, it starts jumping up and down. It keeps asking until you answer; press Esc instead and it stands down.
- **Done and idle?** It stops fighting and passes the time with habits of its own, and most characters have a signature move (Ahh2-De2 plays Princess Laya's message, Han Yolo spins his blaster, Iron Clawd flips his faceplate up, Thanoz snaps, Batclawd's clawdarang loops back to his hand). After a couple of minutes it sits down; after five it's asleep (zZz).
- **Spawned subagents?** They walk (or fly, or swing) in one by one, each labelled with what it's doing, and leave when they finish.
- **Hover** any character for the details; **click** it to jump straight to that session's terminal or editor tab.

<p align="center">
  <img src="docs/desktop-starwars.png" alt="Star Clawds sessions and agents fighting along the bottom of the screen"><br>
  <img src="docs/desktop-marvel.png" alt="Marvelous Clawds sessions and agents fighting along the bottom of the screen"><br>
  <img src="docs/desktop-dc.png" alt="Detective Clawds sessions and agents fighting along the bottom of the screen">
</p>

## Three universes

Choose in **Settings… → Universe**: **Star Clawds**, **Marvelous Clawds**, **Detective Clawds** or **Random**. Switching recasts everyone on screen (each character becomes the one in the same place in the other cast, on the same side), moves the scene to one of the new universe's places, and changes the menu bar icon (Darth Vapor's helmet, Captain Americlawd's shield or Superb-Man's C-shield). In the window, the whole window changes over with the new universe's transition. **Random** switches on its own every 1, 5, 10, 15, 30 or 60 minutes.

| | Star Clawds | Marvelous Clawds | Detective Clawds |
|---|---|---|---|
| Cast | 46 villains, 35 heroes | 88 villains, 105 heroes | 97 villains, 110 heroes |
| Places | 22, from the Mos Easy Cantina to the Battle of Froth | 43, from Clawdvengers Tower to Ta Loh | 43, from the Lookout to the Hall of Gloom |
| Weapons | laser swords, blasters, dark lightning | shields, hammers, claws, repulsors, webs, arrows, magic | fists, swords, heat vision, power rings, clawdarangs, arrows, magic |
| Set pieces | Han Yolo and Greedy-O face off, and Han shoots first; the Millennial Falcon picks Han up | arch-enemies face off first; the Clawdjet and the Milano pick people up; flyers take to the air and fight from there | arch-enemies face off first; the Lance and the Clawdwing pick people up; the Batclawd family swings on grapnel lines |
| Sides | whoever came first keeps their side; Darth Vapor and Kylo Rant never lead back to back | Claude Code plays the heroes when another AI runs | Claude Code plays the heroes when another AI runs |

<details>
<summary><b>The Star Clawds cast and places</b></summary>
<p align="center"><img src="docs/roster-starwars.png" alt="All Star Clawds characters" width="760"></p>
<p align="center"><img src="docs/locations-starwars.png" alt="All Star Clawds places" width="760"></p>
</details>

<details>
<summary><b>The Marvelous Clawds cast and places</b></summary>
<p align="center"><img src="docs/roster-marvel.png" alt="All Marvelous Clawds characters" width="760"></p>
<p align="center"><img src="docs/locations-marvel.png" alt="All Marvelous Clawds places" width="760"></p>
</details>

<details>
<summary><b>The Detective Clawds cast and places</b></summary>
<p align="center"><img src="docs/roster-dc.png" alt="All Detective Clawds characters" width="760"></p>
<p align="center"><img src="docs/locations-dc.png" alt="All Detective Clawds places" width="760"></p>
</details>

## Window mode and the screen saver

It opens in a window by default (switch to the desktop from the menu): the whole crew in a scene set where the first session's character belongs, with a card for every session: its project, what it's doing right now, your last prompt, its last reply, and its agents in a little tree.

<p align="center">
  <img src="docs/window-cantina.png" alt="Window mode in the Mos Easy Cantina: Han Yolo with Luke Skyclawder and Obi-Juan Kanoobie, Greedy-O on Codex" width="760">
</p>

**The screen saver** (Settings… → Screen Saver → Install…) shows the place full screen with the crew fighting across its floor, a card per session, name tags, a clock and a crawl of what happened lately, and moves somewhere new every 10 minutes: with a Star Clawds wipe, or in Marvelous Clawds with a comic-book transition (halftone dots, a SNIKT!, PHOOMF!, FWIP! or KAPOW! for whoever's on screen, panels, speed lines, "MEANWHILE…", and with Deadpond about, Deadpond peeling the page off the screen or surfing past on a chimichanga), or in Detective Clawds with one of fifteen of its own (the Flare racing through the Speed Source, the Night Beacon, Superb-Man bursting through the page, the Lariat of Truth, a Jester card, Darksyde's Omicron Beams and more). Its **Options…** button in System Settings picks the universe: the same as the app, Star Clawds, Marvelous Clawds, Detective Clawds, or Random (a new pick on each trip).

<p align="center">
  <img src="docs/screensaver.png" alt="The screen saver" width="760">
</p>

## The little things

| You see | It means |
|---|---|
| fighting | Claude is running tools |
| 💭 thought bubble | thinking |
| red `!` | waiting for your permission, **jumping** after a minute |
| `?` | that session started before the hooks were installed; restart it for live status |
| sitting on the floor | idle for 2+ minutes |
| zZz | idle for 5+ minutes |
| bobbing yellow marker | the Claude whose terminal you're looking at right now |
| outline colour | which AI: Claude white, Claude desktop app coral, Codex cyan, Qwen lavender, Gemini gold, Copilot mint |

<p align="center">
  <img src="docs/hover.png" alt="The hover card" width="640">
</p>

- **Double-click the menu bar icon** to hide or show the crew; a single click opens the menu.
- **Keep Window on Top** (window mode) or **Keep Characters on Top** (desktop mode): off, the window behaves like any other, and the desktop crew lives on the desktop behind your windows.
- **Drag** the crew anywhere on either monitor.
- **Status Symbols** in the menu is this key, drawn with the app's own sprites.
- **Settings…** (⌘,) opens one window with every option: the universe, the window and the desktop, which AIs are connected, the screen saver, and Forget Idle Sessions.
- Hold **⌘** in the menu for the **Playground** (put anyone on stage and watch them fight) and Demo Mode.

## Install

Needs macOS 13+ (Apple Silicon or Intel) and at least one of [Claude Code](https://claude.com/claude-code), [Codex](https://developers.openai.com/codex), [Qwen Code](https://github.com/QwenLM/qwen-code), [Gemini CLI](https://github.com/google-gemini/gemini-cli) or [GitHub Copilot CLI](https://github.com/github/copilot-cli). Clawd Clash asks before connecting any of them, and only touches the ones you connect.

**With Homebrew:**

```sh
brew install --cask rodclemen/tap/clawd-clash
```

`rodclemen/tap/clawd-wars`, `rodclemen/tap/clawdvengers-clawd-wars` and `rodclemen/tap/justice-clawds-clawd-wars` install the same app, starting in Star Clawds, Marvelous Clawds or Detective Clawds. Or download the zip from [Releases](https://github.com/rodclemen/clawd-clash/releases), unzip it and drag **Clawd Clash** to Applications.

**From source** (no Xcode project, no packages, only Apple's free Command Line Tools):

```sh
xcode-select --install     # one time, if you don't have the developer tools
git clone https://github.com/rodclemen/clawd-clash.git && cd clawd-clash
./build.sh --no-install    # build and run the copy in build/: nothing installed, no AI's settings changed
./build.sh                 # build, install "Clawd Clash.app" to /Applications, refresh connected hooks, launch
```

Claude Code sessions that were already running pick up the hooks after a restart (`/exit`, then `claude --continue`). Until then they still show up, with a `?`.

> **Codex users:** Codex only runs hooks you've approved. After connecting it, run **`/hooks`** in Codex once and approve Clawd Clash.

Clicking to jump to a session in Terminal or iTerm2 asks once for **Automation** permission; jumping to VS Code or Cursor asks once for **Accessibility** permission.

## Coming from Clawd Wars, Clawdvengers or Justice Clawds

Clawd Clash replaces Clawd Wars, Clawdvengers: Clawd Wars and Justice Clawds: Clawd Wars. Through Homebrew, upgrading the `clawd-wars` cask installs Clawd Clash in Star Clawds. Installed by hand, it starts in the universe of the app it finds, and when it connects an AI it swaps the old app's hook for its own, so the old app can go. Star Wars keeps Clawd Wars' characters for sessions that are already running.

## How it works

- A tiny Foundation-only binary, `clawd-clash-hook`, is registered for each connected AI's hook events (session start/end, prompts, tool calls, permission requests, subagents, stop). It writes `~/.claude/clawd-clash/state.json` under a file lock and exits silently, so it can never get in Claude's way. It casts new characters from the universe on show.
- The app reads that twice a second, finds sessions without hooks from the process table, and drops a session the moment its process exits.
- Everything you see (481 characters, their weapons and effects, 108 places, the ships, the icon) is pixel art drawn in Swift at runtime. The whole app is about 10 MB; only the characters and the place on screen are ever drawn.

## Uninstall

With Homebrew: `brew uninstall --cask clawd-clash` (add `--zap` to also remove its settings and status file). Otherwise: menu bar icon → **Settings…** → **Remove** beside each connected AI, then **Quit**, or from the terminal:

```sh
"/Applications/Clawd Clash.app/Contents/MacOS/ClawdClash" --uninstall-hooks
rm -rf "/Applications/Clawd Clash.app" ~/.claude/clawd-clash
```

## Contributing

Each universe lives in its own folder, `Sources/App/Universes/StarWars`, `.../Marvel` and `.../DC`:

- **A character** is a `Persona` (name, weapon, how it moves, what its shots or magic look like, its signature move) registered next to its drawing function in the universe's `Art/*.swift` files. Add its case at the **end** of the universe's hero or villain enum (ids are saved, so never reorder), give it a home in the roster file, and bump the count in `Sources/Shared/Universe.swift`. `Sources/App/Pose.swift` explains what a drawing function gets and must do.
- **A place** is a `Place` in the universe's `Places/` files: a still picture and an optional moving layer.
- **A whole universe** is a `Theme` (`Sources/App/Theme.swift`): its cast, places, homes, arch-enemies, ships, menu bar icon. Add a case to `Universe` and a theme folder.
- **Check it** with `Tools/Preview/build.sh`, then `build/preview cast out.png vader thor` (every pose), `build/preview fight out.png luke vader`, `build/preview place out.png cantina asgard`. `Tools/RenderDocs` renders this page's sheets, `Tools/MakeIcon` the icon.

## License

**Free to use.** The code is [MIT licensed](LICENSE): use it, change it, share it, just keep the license notice.

---

<p align="center"><sub>An independent parody fan project, not affiliated with or endorsed by Lucasfilm, Disney, Marvel, DC Comics or Warner Bros. Claude and Clawd belong to Anthropic.</sub></p>
