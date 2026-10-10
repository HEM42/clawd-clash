# Clawd Wars

![Clawd Wars icon](Resources/AppIcon.png)

A desktop overlay for macOS that shows what Claude Code is doing. The sprite is Clawd, Claude Code's pixel crab, dressed as Darth Vader. When Claude spawns subagents, the Rebel crew shows up next to him.

| Claude is…                        | Darth Clawd…                                                        |
|-----------------------------------|---------------------------------------------------------------------|
| idle                              | stands and breathes, saber hilt on his belt                         |
| thinking                          | shows a thought bubble with animated dots                           |
| working (running tools)           | runs a lightsaber kata: slashes, a thrust and a full twirl          |
| waiting on a permission prompt    | holds his saber upright and shows a red **!** bubble                |
| idle while agents are still running | stands guard with his saber lit                                   |

Each subagent appears next to its Claude as a random hero: **Luke**, **Obi-Wan**, **Qui-Gon**, **Mace Windu**, **Yoda**, **Rey** and **Ahsoka** (sabers), **Han** (DL-44), **Leia** (Defender), **Chewbacca** (bowcaster) and a **Jawa** (ion blaster), or the unarmed **R2-D2** and **C-3PO**. Agents fade in when they spawn and fade out when they finish.

### Several Claudes at once

Each Claude Code session gets a random villain: **Vader**, **Kylo Ren** (unstable crossguard saber), **Darth Maul** (double-bladed saber), **Boba Fett** (EE-3), a **Stormtrooper** (E-11), **the Emperor** (Force lightning) **R0-GR** (a B1 battle droid with an E-5 who says "Roger roger!"), **Count Dooku**, the **Gamorrean Guard** (vibro-axe), **IG-88** or **Jabba the Hutt** (unarmed: he laughs and cheers). Vader and Kylo never spawn one right after the other. A label above each one's head shows the project folder it's working in.

Claudes always fight Claudes, and agents fight agents (across sessions too). Saber users pair first. If a Claude and an agent are both left over, they fight each other. Anyone else left over cheers. R2-D2 and C-3PO are bystanders.

| Matchup | What happens |
|---|---|
| saber vs saber | they step in and duel, blades clashing with sparks |
| blaster vs saber | bolts fly, the saber swings to deflect each one off into the sky |
| lightning vs saber | the saber catches the lightning |
| lightning vs blaster | the gunner gets zapped |
| blaster vs blaster | a shootout |

### Staying on screen

Speech bubbles flip to whichever side of the head has room. The whole crew lines up toward the side of the screen with more space, facing that way so sabers and bolts swing into open space. If it still doesn't fit, everyone walks along the screen until it does, and walks back once the agents finish. The layout always reserves saber room, so the crew doesn't pace back and forth every time Claude switches between thinking and running a tool.

### Window mode

Right-click a villain and choose **Show in Window** to swap the desktop overlay for a regular window set where the first Claude belongs — the Death Star for Vader, the sarlacc pit for Boba, Jabba's palace, the Supremacy, Theed, Geonosis… (19 locations; pick one yourself under **Location**): the crew fighting on the cantina floor, and a card per Claude with its status and how long it's been in it, what it's doing right now, your last prompt, its last reply, prompt and tool counts, and every agent's task and current tool. Click a card to jump to that session; tick **Keep on top** to pin the window.

### Little signals

| You see | It means |
|---|---|
| `?` bubble | that session has no hooks (started before install) — restart it for live status |
| zZz bubble | idle for 5+ minutes |
| villain jumping, `!` flashing fast | it's been waiting for you for over a minute |
| bobbing yellow marker | that's the Claude whose terminal/tab is in front |
| matching label colours | a Claude and its agents share their project's colour |

## Install

```sh
./build.sh            # build, install "Clawd Wars.app" to ~/Applications, add Claude Code hooks, launch
./build.sh --no-hooks # same, but leave ~/.claude/settings.json alone
```

## Use

- **Click a villain** to jump to its Claude session (the exact Terminal/iTerm tab, or the VS Code/Cursor window for that project; asks once for Accessibility permission).
- **Drag any villain** to move the whole crew. The position is saved, and Vader stays fully on screen.
- **Right-click a villain** for every session's status and agents, Show in Window, Size, Show Project Names, Playground (pick villains and agents and watch them fight), Demo Mode (cycles every scene, fights included), Forget Idle Sessions, Reset Position, Launch at Login, Install/Remove hooks and Quit.
- The rest of the overlay is click-through, so it never blocks the window underneath.
- The overlay floats above every app, including full-screen spaces, on all desktops.

## How it works

- `vader-hook` (inside the app bundle) is registered in `~/.claude/settings.json` for these events: SessionStart/End, UserPromptSubmit, Pre/PostToolUse, PermissionRequest, Notification, Stop, SubagentStart/Stop.
- On each event it updates `~/.claude/vader-status/state.json` under a file lock, then exits 0 without printing anything, so it can never get in Claude's way.
- The app reads that file twice a second. Each session keeps its own villain (lowest free slot, so the first one is always Vader) and its own mood.
- States expire on their own (thinking after 10 min, working after 30 min, agents after 20 min) because no hook fires when you press Esc.
- The first install backs up your settings to `~/.claude/settings.json.before-vader`.

## Uninstall

Right-click Vader, choose **Remove Claude Code Hooks**, then **Quit**. Then:

```sh
rm -rf ~/Applications/"Clawd Wars.app" ~/.claude/vader-status
```
