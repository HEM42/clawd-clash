# Clawdify guide: adding a universe to Clawd Clash

## Last updated: 17 October 2026 (Clawd Clash 3.6.0)

This guide is for an AI assistant (Claude Code or similar) working in this repo. To start, point the assistant at it along with the franchise you want, for example:

> clawdify fraggle rock using clawdify_guide.md

Any film, show, game or comic works. The assistant reads this file and knows what to do from there, from checking that the franchise has enough characters to rendering the trailer.

Each step below ends at an **approval gate**: show the user what you have, then wait. Don't go on to the next step until they've said yes, or they've said what to change and you've changed it. Clawd Clash's universes were built this way, a step at a time with the user signing off. Expect the user to swap characters, rename things, and add ideas of their own.

Reference builds to read when you get stuck:
- **Clawd of the Rings** (`Sources/App/Universes/ClawdOfTheRings/`, released in 3.5.0) is the newest: roster, art, places, nine trips, the Great Eagle, guises and a homebound dragon, and a trailer. It was built on `main` behind `Universe.isReleased` (below).
- **Doctor Clawd** (`Sources/App/Universes/DoctorClawd/`, commit `37e1d4b`) is the most compact complete one: roster, art, places, transitions, a ride, regeneration on compaction, and a trailer.
- **The Clawd Files** (`Sources/App/Universes/ClawdFiles/`, released in 3.3.0) was built phase by phase using this process. Its early commits show what a skeleton and a phase look like.

---

## Step 0: Understand the request

"clawdify X using clawdify_guide.md" (or just "clawdify X") means: plan, and then build, X as a new Clawd Clash universe. Work out what X is:
- If X is ambiguous (a franchise with reboots, spin-offs or several eras), ask which parts count. Doctor Clawd covered every Doctor; Stevie Clawdberg was nine films the user picked.
- Some requests are a mix of several properties, like a director's films. Agree on the list first.

Then check the repo's current state, because things change between universes:
- `git status` and `git branch -a`. A universe may be half built on another branch.
- `Sources/Shared/Universe.swift` has the existing universes, their raw values and their cast sizes.
- `~/.claude/plans/` and any project memory may list planned universes that already have a raw value reserved. **Ask the user** if you're not sure which raw value is free.

---

## Step 1: Research and viability check

Research the franchise before you propose anything. Use web search: wikis, episode guides, cast lists. Go beyond what you remember, because a full ensemble needs the deep cuts as well as the main cast.

Count the characters who would make **good Clawd Clash characters**:
- **Recognisable:** a fan would know them from a 72×52 pixel sprite with a name tag.
- **Visually distinct:** a costume, silhouette, prop or colour that sets them apart. Ten identical grey suits are one character, not ten.
- **Something to do:** a weapon, a power, or a recognisable signature move or catchphrase.
- **Fits the tone:** the app is a desktop toy. Leave out characters whose whole point is gore, sexual violence, child harm or real-world atrocity. The Clawd Files left out Donnie Pfaster and the Peacock family for this reason.
- **Fictional:** no real people (politicians, celebrities). Never use actors' names.

Sort them into **heroes** and **villains**. Some franchises don't split neatly. Fraggle Rock, for example, has few true villains. In that case, "villains" can be the antagonists, troublemakers, monsters and rivals (the Gorgs, and the creatures that menace the Rock). Say how you sorted them.

**The threshold is 20 heroes and 20 villains.** If either side has fewer than 20 good candidates, tell the user plainly that this would be **a limited experience**: the same faces repeat, and some sides of a fight will be thin. Then offer them a choice:
1. Go ahead with a smaller universe anyway.
2. Widen the source: spin-offs, specials, comics, games, animated series, or a sister franchise.
3. Pick a different franchise.

Agent-only small fry, like Star Clawds' MSE-6 droid, are bit-part creatures that only ever appear as subagents. They help fill out a cast, but they don't count towards the 20.

---

## Step 2: The overview (approval gate 1)

Give the user a short overview to decide on. Include:

**1. A comparison with the universes already in the app.** Read the numbers from the code each time; don't copy them from this guide:
- Heroes and villains come from `heroCount` and `villainCount` in `Sources/Shared/Universe.swift`. `heroCount` includes HEM, and `villainCount` includes agent-only characters.
- Places: count the `places:` list in each universe's `Theme`, in `Universes/*/…Roster.swift`.
- Transitions: count the cases of each universe's wipe enum (`DoctorWipe`, `DCComicWipe`, …). Star Clawds uses plain wipes.

```
| Universe          | Heroes | Villains | Total | Places | Transitions |
|-------------------|--------|----------|-------|--------|-------------|
| Star Clawds       |     NN |       NN |    NN |     NN | plain wipes |
| …one row per universe in Universe.swift…                              |
| <New> (proposed)  |    ~NN |      ~NN |   ~NN |    ~20 |       8–15  |
```

**2. A viability verdict:** whether it clears 20 heroes and 20 villains, and the "limited experience" warning if it doesn't.

**3. Name options.** Give two to four, with your recommendation. The style is a light pun that works "Clawd" in: Star Clawds, Marvelous Clawds, Detective Clawds, Doctor Clawd, The Clawd Files, Stevie Clawdberg. The user picks.

**4. Code naming.** The code never uses the franchise's trademark:
- `case <key> = <next free raw value>` in `Universe`. Raw values start at 0 (Star Clawds), so the sixth universe is 5; its ids are `rawValue * 1000` and up.
- The key string, a folder `Sources/App/Universes/<FolderName>/`, and a file prefix that is unique across the repo (Swift needs unique file names).
- The git branch name.

**5. The cast at a glance:** the groups you'd draw from (for Fraggle Rock: the Fraggles, the Doozers, the Gorgs, Doc and Sprocket in Outer Space…), with rough numbers per group.

**6. Ideas that make it its own universe.** One or two each:
- the ride (how people arrive and leave);
- a set piece;
- a habit;
- a compaction mechanic, if the franchise has a natural one. Doctor Clawd regenerates and The Clawd Files has missing time. Not every universe needs one.
- **the signature opening**: the show's title sequence, the film's iconic opening, the game's attract screen. This becomes a transition and opens the trailer (see Step 5 and Promo).

**7. A tone note:** anything you plan to leave out, and why.

Wait for a go-ahead and a name before you draft the roster.

---

## Step 3: The roster (approval gate 2)

Draft the full cast in tables, grouped the way fans think of the franchise. Every character must carry the show. **Nothing is added just to grow the count.** For scale:
- Star Clawds has 82 characters.
- Doctor Clawd has 98.
- The comic universes have about 200.
- 70–100 is a good target for a TV or film franchise.

### Naming

- **Light puns on the on-screen name:** Darth Vapor, Fox Clawder, Dana Scrawly, Doctor Gloom. Readable at a glance, never mean-spirited.
- Generic titles get a number or nickname: Doctor One … Fifteen, the Burnt Master.
- **Never use actors' names.** Never use real people.
- If a name has no pun, a near-spelling is fine (Gibson Prays, Max Fenig). A forced pun is worse than none.

### Columns

Heroes and villains each get a table:

```
| # | Name | Look | Weapon | Signature |
```

- **Look:** what makes them recognisable as pixels: hair, outfit, colour, prop.
- **Weapon:** mapped onto the engine (below).
- **Signature:** a recognisable idle move or catchphrase. Write "none" when there isn't a clear one; don't invent one.

### Signature moves and callouts

A character's signature move is the little routine it plays now and then while idle. It's what fans notice and screenshot: Han Yolo spinning his blaster, Thanoz snapping, Doctor Four offering round his jelly babies, the Smoking Clawd blowing smoke rings. Each one is worth getting right.

- **Take it from the source.** Use a gesture, prop or habit the character is known for: Fox Clawder spitting sunflower seeds, Scrawly's raised eyebrow, Doctor Eleven putting on the fez. Look each one up rather than guessing.
- **It has to read at 72×52 pixels.** Big, clear motions work: a spin, a throw, a prop coming out, something rising or glowing. A facial twitch or a fine hand gesture won't show. If the iconic gesture is too small, build it around a prop: Skinnard takes off his glasses rather than just frowning.
- **Keep it short and loopable:** 2–4 seconds (`Persona.signature`, in seconds). The drawing function gets `p.signature` running 0…1 through it, and has to start and end in the character's normal pose.
- **Keep it fun at desktop scale.** A horror character's move should be eerie rather than gruesome: Tooms stretches into a vent, Leonard Betts sheds his head cartoonishly.
- **Callouts** (`Persona.callout`) are what the character says now and then while leading a session. Use a catchphrase, short enough for a speech bubble: "Hmm!", "Jelly baby?", "Allons-y!", "I want to believe". Puns on the catchphrase are fine; long quotes aren't.
- **Not everyone needs one.** "none" is better than a made-up move nobody would recognise. The leads, though, should all have one.

### Get the weapons right

Research **each character's** actual weapon or power. Don't assign one by group. Ask: what do they fight with on screen? What colour is it? Do they fly, hover or walk? Does anything bounce off them? A wrong weapon (a pacifist with a gun, a fire-user shooting blue) breaks the character for fans. If a character never fights, `.none` is the right answer.

### Mapping the franchise onto the engine's weapons (`Sources/App/Persona.swift`)

| Engine | Use it for |
|---|---|
| `.saber` | melee: swords, fists, claws, bats, staffs. Deflects shots. |
| `.blaster` + `ShotStyle` | anything at range: `.energy`, `.beam`, `.bullet`, `.arrow`, `.fire`, `.ice`, `.card`, `.thrown(colour)`, `.web` |
| `.lightning` + `Magic` | magic and energy streams. `jagged: false` gives a steady ray (sonic screwdriver, flashlight beam, mind control). |
| `.none` | stays out of fights: runs, points, cheers |
| `motion: .fly / .hover / .swing` | flyers, floaters, web-swingers. `canSit: false` for things that can't sit (a fish, a ghost). |
| `armoured: true` | shots ricochet off: robots, armour, rock, the unstoppable |
| `bulk` | big bodies, so duels stand further apart |
| `callout` | the line they say now and then while leading a session |

Pick weapons that fit the franchise as a whole. The Doctors use sonic screwdrivers rather than guns. The FBI agents shoot, and carry a flashlight as their signature. A gentle franchise like Fraggle Rock might be mostly `.none` and `.thrown` (radishes!) with the odd `.saber` bonk. That's fine: fights can be silly.

### Also in the roster

- **HEM**, the app's rare cameo, is always **the last hero**. Give him a costume idea for this universe: a hat, a coat and a prop for a weapon. Doctor Clawd's is a fez, a bow tie and a sonic; The Clawd Files' is a trench coat, a lanyard and a flashlight.
- **Agent-only small fry:** 0–9 tiny creatures that only appear as agents.
- **Nemeses:** 10–25 hero ↔ villain pairs who face off first when both are on stage.
- **Rivals:** optionally, one pair that should never lead two sessions back to back (Vader and Kylo).
- **Claude's side:** heroes by default. Say if Claude should play the villains instead.
- **Enum order is the order characters are added, and it can never change** (ids are saved). Put the skeleton's first characters first.

Show the full roster with counts per group and totals, and wait for approval. Expect swaps. A swap keeps the count unless the user says otherwise.

---

## Step 4: The places (approval gate 3)

Draft about **20 places**. Doctor Clawd and The Clawd Files have 20; the comic universes have 43. Each is a pixel-art backdrop with:
- **a still picture**;
- **a moving layer**: something alive, like flicker, rain, water or a spinning reel. Be specific: "the I WANT TO BELIEVE poster, pencils stuck in the ceiling tiles, a slide projector flickering";
- **tall-canvas extras** for the screen saver, where the scene is much taller than the window's strip (`Scenes.isTall`).

Rules:
- **The first place is the default**, where the crew stands when nobody's home is known. Make it the franchise's most iconic spot: the TARDIS console room, the FBI basement, Fraggle Rock's Great Hall.
- Give every character a **home** among the places, and list the homes by group.
- Place keys must be **unique across all universes** (`static let` keys in the roster file). Check for clashes with `grep -rn 'Location("' Sources/App/Universes`.
- Prefer variety: interior and exterior, day and night, colour palettes that differ from each other.

Show the list and the homes, and wait for approval.

---

## Step 5: Mechanics and transitions (approval gate 4)

### Mechanics

Propose whichever of these fit:
1. **The ride.** Who gets picked up or dropped off, and by what: the Millennial Falcon, the Clawdjet, the TARDIS that materialises, the FBI sedan, a saucer's abduction beam. Drawn in `Sources/App/Rides.swift`, chosen in the theme's `ride:` closure.
2. **A compaction mechanic** (optional). When a Claude Code or pi session compacts its context, something in-universe happens to its leader. Doctor Clawd regenerates into the next Doctor; The Clawd Files abducts the agent and drops them back with "MISSING TIME". It reuses the `PreCompact` path (`StatusStore`, `Universe.regenerations`, `DoctorRegeneration.swift`). Limit it to a clear group of characters. A new mechanic can reuse an existing clock: Stevie Clawdberg's 88 mph lists its time travellers in `Universe.abductees` and draws its own effect (`OutaTime`) where the overlay draws The Clawd Files' abduction.
3. **Habits** (`Sources/App/Habits.swift`, Overlay's tick): idle behaviour unique to a character, like the Weeping Angle only moving while nobody looks.
4. **Bespoke practice drills** (`Sources/App/Drills.swift`): what characters do when working alone (Dalicks "Elevate!", Doctor Four's jelly babies). Also decide whether this universe's casters **float cross-legged in meditation** (`Drills.swift`, the guard near line 54). Doctor Clawd and The Clawd Files don't.

### Transitions: between 8 and 15

Every universe except Star Clawds changes place with transitions of its own, so plan **at least 8 and no more than 15**.

- **If the franchise has a signature opening** (a title sequence, a film's opening crawl or logo sting, a game's intro), **it must be one of the transitions.** It's usually the longest and rarest one. It also **opens the trailer** (see Promo).
- Base the rest on the franchise's own visual language: how scenes change in the show, iconic effects, props, creatures. The user may bring their own list. Use theirs first and fill in from yours.
- Each transition has an **owner** (characters who make it come up more often when they're on screen) and optionally a **turf** (places that do the same). Some, like Doctor Clawd's Blink and the Dalick eyestalk, only come up with their owner present (`needsOwner`).
- **Style:** everything is drawn in the app's **pixel art**, not painted or glossy. Use a palette that fits the franchise (The Clawd Files: desaturated greens, cold blue-greys, deep blacks, the odd fluorescent green), with halftone dots or grain where it helps. Avoid fine detail that won't read at pixel scale.
- Optionally, a **universe-wide finishing touch**. The Clawd Files ends every transition with a typewriter caption of the new place's name, the way scenes open in the show.
- List what you **left out and why**: overlaps, too fine to read, or a better fit as a habit.

Show a table with #, name, what happens, and who or where makes it come up more often. Wait for approval.

---

## Step 6: Write the plan

Once all four gates are passed, write the whole plan to `~/.claude/plans/<slug>.md`, or to a private repo if the user asks. Use the latest universe's plan in `~/.claude/plans/` as the template if there is one (for example `stevie-clawdberg.md`); otherwise follow these sections:

1. **Context:** the name, code naming, raw value, size, naming style, tone.
2. **How a universe plugs in:** the file list and wiring checklist below, re-checked against the code as it is today with line numbers. The code moves, so don't trust this guide's line numbers blindly.
3. **Cast:** the approved tables, the weapon mapping, HEM, agent-only, nemeses.
4. **Places:** the approved list and the homes.
5. **Mechanics.**
6. **Phases:** see below.
7. **Verification.**
8. **Transitions:** the approved table, the style, and what was left out.
9. **Promo:** which transition opens the trailer.

If the assistant has a memory system, save a short project memory pointing at the plan file and branch. Then create the branch off `main` and start phase 1 when the user says so. Alternatively, build on `main` with the universe unreleased: `Universe.isReleased` returning `false` for it keeps it out of Settings, Random, Clawd Royale and the screen saver's Options, while the tools (Preview, the docs and promo renderers) still see it. Clawd of the Rings was built that way. Flip it to released in phase 6.

---

## Step 7: Build it, in phases

Each phase **builds, gets checked with Preview sheets, and is shown to the user** before the next one starts. Commit at the end of each phase, and add a `CHANGELOG.md` entry each phase. Only `CHANGELOG.md` is kept current; `history/` is frozen.

| Phase | What |
|---|---|
| 1. Skeleton | The `Universe` case and all the wiring; 2–3 characters (the lead hero, the lead villain, one more); the default place; menu icon; HEM's costume; screen-saver option; Preview support. Runs end to end in the app, the window, the screen saver and Clawd Royale, with plain wipes for now (`ComicTransition.pick` returns nil for it). |
| 2. Core ensemble | About 30–40 characters and about 8 places, with their homes and nemeses. It's fine to commit the enum cases first, which then show as stand-ins, and draw them in a second commit. The Clawd Files did this. |
| 3. The rest | The full cast and all places, with every home filled in. Ends with **the character audit** (below). |
| 4. Mechanics | Ride, compaction mechanic, habits, bespoke drills. |
| 5. Transitions | The 8–15 trips and any finishing touch, wired through `ComicTransition`. |
| Polish pass | Every weak spot noted in phases 2–5, fixed (see below). **Always before phase 6.** |
| 6. Docs and release | README, docs images, app icon, `llms.txt`, trailer. Public steps need the user's OK. |

### The character audit (end of phase 3, approval gate)

Once every character is drawn, go back over the whole cast before starting on mechanics. When characters are drawn in batches over several sessions, details drift: a weapon gets swapped for one that was easier to draw, a shot colour gets copied from the persona above it, a signature never gets drawn.

For **every** character, check the `Persona` and the drawing against the source and against the approved roster:

- **Weapon:** the right kind (`.saber`, `.blaster`, `.lightning`, `.none`) for how they fight on screen.
- **Shots and magic:** the right `ShotStyle`, the right colours for core and glow, and `jagged` set correctly (steady ray or forked lightning).
- **Motion and body:** `.fly`, `.hover` or `.swing` only if they do that in the source; `armoured`, `canSit` and `bulk` where they fit.
- **Signature:** it's in the roster, `signature:` is set, and the drawing actually uses `p.signature`. Check that it plays and reads in `build/preview cast`.
- **Callout:** in character, and short.
- **Look:** recognisable, and not confusable with anyone else in this universe or with a lookalike in another one (they meet in Clawd Royale).
- **Home and nemesis:** they make sense.

Re-check the facts with a quick search where you're not sure. Then show the user a table of **only the mismatches**, with a proposed fix for each:

```
| Character | What's wrong | Fix |
```

Apply the fixes once the user agrees, and re-render the Preview sheets. Changing a `Persona` or a drawing is safe at any time. Only the enum order is permanent.

### Keep a weak-spot list as you go

At the end of every phase, write down everything that doesn't quite read in the Preview sheets: a prop too small to
see, an outline artefact, a place with a big empty area on the screen saver, a transition whose lettering is too small
at window size. Name the character or place, say what's wrong, and add it to the plan (or the handoff file). **Don't
stop to fix these mid-phase.** The phase's job is to get everything in; the polish pass fixes them all together.

### The polish pass (after phase 5, before phase 6)

Go through the whole weak-spot list before starting on docs and the trailer. **The order matters:** the README's
roster and locations sheets, the desktop line-up, the social preview, the app icon and above all the trailer are all
rendered from the characters, places, rides and transitions. Anything polished after them means rendering them again,
and redoing a trailer is the expensive part. So everything that shows on screen gets finished first, and phase 6 only
renders what's done.

- **Split it by file** and run it in parallel, the way phases 2 and 3 were drawn: one helper per group of art files
  (`Art/<Prefix>Heroes…`, `Art/<Prefix>Villains…`) and per group of `Places/` files, each in its own worktree,
  editing only its own files. Rides, mechanics and transitions are in their own files, so they can be done alongside.
- **Launching many helpers at once** can fail to create some of their worktrees (a race in git). Check every launch
  result, and relaunch exactly the ones that failed: it's easy to relaunch the wrong brief and end up with two helpers
  on one batch and none on another.
- **Before and after.** Each helper renders every fixed character or place before and after, side by side, enlarged.
  Show those to the user: that's the polish pass's approval gate.
- **Engine-wide issues** (a habit every universe shares, like callouts overlapping or steady rays wobbling) are
  reported, not fixed inside one universe's files. Fix them separately, or leave them noted.
- Re-check the rest of the cast too while you're there: the polish pass is the last look before the universe is shown
  off in public.

### New files: `Sources/App/Universes/<FolderName>/`

- **`<Prefix>Roster.swift`** (the pattern is in `DoctorClawd/DoctorRoster.swift`):
  - `enum <Prefix>Hero: Int, CaseIterable` and `enum <Prefix>Villain: Int, CaseIterable`. They're **append-only**, and `hem` is the last hero.
  - The persona dictionaries, merged from the Art files, with `.reduce([.hem: hemPersona(.<key>)])`.
  - `Location.<prefix>Home(of:)` for heroes and villains.
  - `Cast.hero(_:)` and `Cast.villain(_:)`, the nemeses, and `let <prefix>Theme = Theme(universe:villains:heroes:places:home:nemeses:ride:menuIcon:legend:)`.
  - The `static let` place keys, and `let <prefix>Places` merged from the Places files.
- **`Art/<Prefix>Heroes1…N.swift` and `Art/<Prefix>Villains1…N.swift`:** 8–10 personas per file, each a `Persona(...)` entry plus its `private func draw…(_ c: PixelCanvas, _ p: Pose)`. Read the comment at the top of `Sources/App/Pose.swift` before drawing: it covers the 72×52 canvas facing right, `drawLegs`, `p.breathe`, melee angles, `armRaise`, `signature`. Every character is Clawd (the orange body) in costume, always on Clawd's four legs. Draw the legs and shoes first, then `c.oy += p.breathe`, then the body; anything that hangs over the legs (coat tails, skirts, a robe's hem) goes after the breath, over the legs, and still leaves four distinct legs showing below. Keep a group's shared helpers private to its file; anything shared across a universe's art files goes in one `<Prefix>Kit.swift` with prefixed names (Preview compiles every universe together, so top-level names must be unique app-wide). Every other top-level name is `private` or starts with the prefix too: `scripts/pr-guard.py` refuses a plain one, because it could shadow a system function the app relies on.
- **`Places/<Prefix>Scenes1…N.swift`:** `let <prefix>ScenesN: [Location: Place]` entries, each `Place(name:panel:still:moving:)`, drawn in code. Scale landmarks up when `Scenes.isTall(c)`.
- **`<Prefix>Icon.swift`:** the menu bar icon, 28×26, in colour and in mono (a template image).
- **`<Prefix>Wipes.swift`:** the transitions (phase 5). Follow `DoctorClawd/DoctorWipes.swift`: an enum of kinds with `duration`, `needsOwner`, `isOwned(by:)` and `turf`, and a `…Trip` struct with `pick(after:cast:to:)` and `draw(_:old:new:k:in:)`.
- Mechanic-specific files as needed, like `DoctorRegeneration.swift`.

### Wiring checklist

Any exhaustive `switch` on `Universe` turns a missed spot into a compile error. The ⚠︎ ones **don't**: the build passes if you miss them, so check them by hand. Find the current spots with `grep -rn "clawdFiles\|\.doctor\b" Sources Tools`, copying whatever the last universe did.

- [ ] **`Sources/Shared/Universe.swift`:** the case, `key`, `title`, `villainCount`, `heroCount`, `agentOnly` (global ids), and if needed `claudeSide`, `rivals`, `regenerations` (or its equivalent).
- [ ] **`Sources/App/Theme.swift`:** `Theme.of`.
- [ ] **`Sources/App/Locations.swift`:** `.merging(<prefix>Places)` in `places`.
- [ ] **`Sources/App/Universes/Hem.swift`:** HEM's persona and costume in every switch.
- [ ] **`Sources/App/Universes/ComicTransition.swift`:** add the universe to the `nil` cases in phase 1. In phase 5, add a `.<key>(<Prefix>Trip)` case to `duration`, `draw` and `pick`, and update the doc comment.
- [ ] **`Sources/App/Rides.swift`:** the ride's drawing (phase 4). A ride that drives in along the ground instead of flying also goes in `Ride.drives` (`Theme.swift`).
- [ ] **`Sources/Saver/SaverView.swift`:** nothing to add. The Options list and the trip choice build themselves from `Universe.offered`.
- [ ] ⚠︎ **`Sources/App/Drills.swift`:** the meditation guard, plus bespoke drills keyed by cast.
- [ ] ⚠︎ **`Sources/App/Overlay.swift`:** the Playground's sample prompts, a `case .<key>:` in the `switch Universe.shown` that builds them. It has a `default`, so the compiler won't flag a missing one. Write five in-universe ones. Also check the Weeping-Angle-style habit hooks in the tick if you add a habit.
- [ ] ⚠︎ **`Sources/App/Pose.swift`** (`classic`), **`Habits.swift`**: universe-specific `if`s. Decide whether the new universe joins each one.
- [ ] ⚠︎ **Compaction mechanic only:** `StatusStore.swift` (PreCompact handling) and `HookInstaller.swift`. Doctor Clawd already registers the hook. Both are the maintainer's (`CONTRIBUTING.md`): from a fork, say in the PR what the mechanic needs instead.
- [ ] **Clawd Royale** gets the new cast and places through `Universe.allCases`. Check that the menu bar icon and arch-enemies still behave when a scene is in one of the new places.
- [ ] **`Tools/Preview/main.swift`:** the batch names (`<prefix>Heroes1…`), the universe lookup, and the enum lookups by case name.
- [ ] **`Tools/Transitions/main.swift`:** the branch that renders this universe's trips (phase 5).

### Verification, every phase

- `./build.sh` builds, installs and launches. The cast-size check at launch (a `precondition` in `Overlay.swift`) stops the app with a message naming the universe if a `heroCount` or `villainCount` doesn't match the enums.
- The optimized release build can hit Swift's "unable to type-check in reasonable time" on dense `sin`/`cos` drawing expressions. Find them with `-Xfrontend -warn-long-expression-type-checking=300` and split them up. Check with `./build.sh --release <version>` before calling a phase done.
- `Tools/Preview/build.sh`, then:
  - `build/preview cast out.png "<Name>"` shows every pose of one character;
  - `build/preview fight out.png "<Hero>" "<Villain>"`;
  - `build/preview place out.png "<Universe title>"` shows every place;
  - and the batch sheets, one per Art file.
  
  **Look at the PNGs yourself** before showing the user. Check that each character reads as who it's meant to be, that nobody is confusable with someone else in the cast, and that there are no outline gaps.
  - `build/preview edges out.txt "<Universe title>"` lists every moment solid art touches the frame's edge (see Look and style); everything it lists should be on purpose.
- Transitions: `Tools/Transitions/build.sh`, then `build/transitions <outdir> <placeA> <placeB>` between two of the new places.
- In the app:
  - Settings → Universe → the new one. New sessions get cast from it, and subagents include villains and small fry.
  - The screen saver's Options list it.
  - Random and Clawd Royale reach it.
- For a compaction mechanic, run `/compact` in a Claude session.

---

## Step 8: Docs and release (phase 6)

Do these freely (on the branch):
- **README.md:**
  - the tagline and intro say "many" or "several" universes, never a number, so they need no change;
  - the universe table's new column (set pieces, ride, mechanic);
  - the screen-saver paragraph about transitions;
  - a collapsible cast-and-places section;
  - the developer notes on where universes live.
- **`llms.txt`:** the count, the universe list, the folder and file-prefix list, and any new mechanic.
- **`Tools/RenderDocs`:** a `<prefix>Lineup` desktop strip, the roster and locations sheets, and a social preview. Output goes to `docs/`, named by the universe's title (`roster-the-clawd-files.png` …).
- **`Tools/MakeIcon`:** the app icon is one character standing on the logo, so a new universe needs no change there.
- **`Tools/MakeSocial`**, and **`Tools/RenderShowcase`** for the universe's own showcase pictures.
- Trailers never say how many universes there are (the end card reads "One of many universes in Clawd Clash"), so nothing needs updating when one is added. Don't add a count anywhere else either: the README and `llms.txt` say "many" or "several".
- `CHANGELOG.md`.

**Ask the user first**, because these are public:
- creating or publishing a showcase repo (`rodclemen/<universe-name>`);
- adding a cask in `release.sh`: `write_cask <name> <key> "<description>"`, adding it to the `others` list in `write_cask`, and updating the main cask's description;
- releasing (`./release.sh <version>`), pushing, opening a PR.

**Version numbers:** a new universe, and only a new universe, raises the middle number: 3.6.x → 3.7.0. Everything else (fixes, tweaks, features that don't add a universe) raises only the last: 3.6.0 → 3.6.1 → 3.6.2. So a universe ships as the next `3.N.0`, and its own fixes after that as `3.N.1`, `3.N.2`…

**Sending it as a pull request from a fork:** run `python3 scripts/pr-guard.py main HEAD` and fix what it reports. Leave `llms.txt`, `release.sh` and the other files `CONTRIBUTING.md` lists as red to the maintainer, and say in the PR what they need.

---

## Promo: the universe's trailer

Each universe has its own trailer in `Tools/RenderPromo/main.swift`, rendered with the app's own sprites, places and transitions, with a synthesized chiptune soundtrack. **Read the Doctor Clawd trailer (`// MARK: The Doctor Clawd trailer`) as the model.**

### Structure

Use `doctorShots` as the pattern. The trailer runs about 45–50 seconds:

| Shot | Length | What |
|---|---|---|
| `intro` | ~9 s | **The signature opening**, the same one as the transition. For Doctor Clawd it's lightning, the time vortex, and the police box tumbling past; then the title (`<prefix>Title`) swells out of it and the camera plunges into white. Rebuild the original's composition, beats and feel in pixel art. Don't copy frames or logos. |
| set piece | ~9.5 s | A short scene that shows the franchise off with its own cast and ride. In Doctor Clawd, Dalicks invade Christmas London, the TARDIS lands under fire, and Doctor Ten sees them off. |
| `hook` | 4 s | Shared: three busy terminals. "Three AIs. Nine agents. One very confused human." / "Sound familiar?" |
| `desktop` | ~4.6 s | `brawl(ctx, .<key>, …)`: desktop mode, with one line of in-universe copy. |
| `status` | ~4.2 s | `statusOf(...)`: four characters, one per state, with a funny aside. |
| `agents` | 4 s | `agentsOf(...)`: "Every subagent gets to be a <hero word>." |
| `window` | ~4.8 s | `windowShot(ctx, .<key>, …, at: .<defaultPlace>)`, with an in-universe pun ("It's bigger on the inside."). |
| `ais` | ~4.4 s | `everyAI(...)`: the BRING YOUR OWN AI* line-up, one character per AI (Claude, Desktop, Codex, Copilot, Qwen, Gemini, pi), with the README footnote. |
| `endcard` | ~4.2 s | The default place, the crew lined up, the title lands, "Have fun. Keep track.", "One of many universes in Clawd Clash · free for macOS", the app icon and the GitHub URL. |

### Wiring a new reel `REEL=<reel>`

`<reel>` is a short lowercase name, like `doctor` or `files`. All of this is in `Tools/RenderPromo/main.swift`:
- [ ] the header comment: add the `REEL=<reel> build/renderpromo video promo → promo/<universe-name>-promo.mp4` line;
- [ ] `let <prefix>Shots: [Shot]`, plus the intro and set-piece drawing functions, and `<prefix>Title`;
- [ ] `let <prefix>Beats`: the storyboard, one row per beat (time, title, what happens, on-screen text, sound);
- [ ] `func <prefix>Sound(_ m: Mix)`: the soundtrack. Add new `Mix` sound effects in an `extension Mix` next to it, like `wheeze` and `exterminate`;
- [ ] the `shots` switch under `// MARK: Which video`, `softWipe`'s reel list, and the poster frame's reel list;
- [ ] the soundtrack switch (`case "<reel>": <prefix>Sound(m)`);
- [ ] the `base` file-name map, and the `720p` name map;
- [ ] the storyboard `save(storyboard("<TITLE>", <prefix>Beats), …)` line;
- [ ] the per-universe switches the shared shots use: the window-mode cast and prompts, the brawl cast, the "pick your universe" caption, and the `gemini ▸ …` terminal line. The compiler flags the exhaustive ones; grep for `reel == "doctor"` for the rest.
- [ ] Optionally, the main promo (`REEL=promo`) and the Clawd Royale teaser can show off the new universe too. Ask the user.

### Music and sound

- **Write original notes.** You can evoke the theme's *sound*: its instrumentation, tempo, mood, and signature sounds like a wheeze, a sting or thunder. Never reproduce the copyrighted melody. Doctor Clawd's storyboard puts it this way: "in the sound of the old electronic theme but our own notes".
- Line the hits up with the beats: the title landing, the ride arriving, the end card's sting.

### The routine

1. Build. The full `swiftc` command is in the file's header comment. It compiles the App sources, `Universes/**`, `Shared/` and `Tools/RenderPromo/main.swift` into `build/renderpromo`.
2. `REEL=<reel> build/renderpromo storyboard promo` writes `promo/storyboard-<universe-name>.png`. **Show the storyboard to the user for approval before rendering video.** This is an approval gate.
3. `REEL=<reel> build/renderpromo frame promo 4.5` renders spot-check frames. Look at them, the intro especially.
4. `REEL=<reel> build/renderpromo check` renders every frame once.
5. `REEL=<reel> build/renderpromo video promo` writes `promo/<universe-name>-promo.mp4` at 1080p, H.264 + AAC.
6. `REEL=<reel> build/renderpromo 720p promo` writes `promo/720p/<Universe-Name>.mp4`, the copy under 10 MB for GitHub. The user uploads it by hand.

`promo/` is git-ignored apart from the main trailer and the blooper reel, so rendered videos aren't committed.

---

## Look and style

Every universe has to sit next to the others in Clawd Royale, so the art follows one house style. Read this before
drawing anything, and check your work against it at the end of every phase.

### Characters

- **Clawd in costume.** Every character is Clawd's blocky orange body (x 18…37, y 26…37) on four legs (y 38…43),
  facing right on a 72×52 canvas. The view mirrors it to face left. A costume, hair, a helmet, a prop or a creature
  body go over and round that; the four legs always show. Giants and creatures can fill the frame, but they still
  stand on four legs on the ground row.
- **Pixel art, drawn in code.** Whole pixels, flat colours (`C(0xRRGGBB)`), no gradients or blur on the body. Give
  each material two or three tones: a base, a darker shade and a lighter highlight (`suit`, `suitDark`, `stripe`).
  Light comes from the front-left: highlights on top and left edges, shade on the right and underneath.
- **Don't outline the silhouette yourself.** The app adds a 1-pixel outline round every character in its AI's colour
  (white for Claude Code), so dark costumes read on a dark desktop. Use the dark `outline` colour only for lines
  inside the figure: a belt, a visor, the edge of a coat.
- **Solid or see-through, nothing in between at the edge.** The outline goes round **fully opaque** pixels only.
  Anything partly see-through counts as a glow and gets no outline. So:
  - draw the body, costume, hair, props and signs fully opaque;
  - keep see-through for what should stay soft: glows, magic, smoke, ghosts, phasing, water, speed blur;
  - where something see-through touches the silhouette, make it either solid or faint (under about 25% opacity).
    Half-opaque pixels along an edge make the outline dotted. The Necro-maintainer's smoke had exactly this.
- **Stay inside the frame, with a pixel to spare.** Anything past the canvas edge is cut off, outline and all, and a
  solid pixel on the edge itself loses its outline on that side. Keep solid art within columns 1…70 and from row 1 down, in
  **every pose at every moment**: walking, fighting, waiting, cheering, sitting, every idle habit and the whole
  signature move. Some things eat into that room:
  - the breathing bob lifts the upper body 1 px;
  - hovering, hops and the bounce habit lift the whole sprite 2 to 4 px (the engine gives back what it must, but
    only that lift, not your own raised arms);
  - raised weapons, arms, wings, tails and signature props swing out further than they rest.

  So a tall character's head should start around row 5 or lower, and long weapons, wings and tails should shorten
  or tuck in as they swing towards an edge. Set the persona's `headTop` to the head's real top row.
- **What may leave the frame on purpose:** shots, beams, thrown things, lassos and sound rings flying out; a
  character running, charging or teleporting off; lightning, birds or ships coming in from above; anything below
  the feet touching the bottom edge. Nothing of the character's own body or held props.
- **Check it:** `build/preview edges out.txt "<Universe title>"` draws everyone at 80 moments of every state and 40
  of every habit and signature move, and lists each state where solid art touches an edge, with a picture of the
  first such moment next to the report. Everything it lists should be on purpose. `build/preview cast` shows the
  outline itself: look for gaps.

### Places

- **The same pixel art**, at the same pixel size as the crew. A palette of the franchise's own (The Clawd Files:
  desaturated greens, cold blue-greys, deep blacks), with grain or halftone where it helps. Nothing painted, glossy or
  photographic.
- **The crew has to read on it.** Characters stand on the bottom `floorRows` rows, and their names and speech
  appear above them. Keep the floor and the band just above it plain and mid-to-dark, so white outlines and labels
  stand out. Put the busy detail (shelves, machinery, signs, crowds) higher up and at the sides.
- **The moving layer stays subtle:** a flicker, rain, water, a blinking light. Nothing that flashes across the
  crew or pulls the eye from them.
- **Window and screen saver.** The window shows a short strip of the place; the screen saver shows it much taller
  (`Scenes.isTall`). Check both with `build/preview place`: the strip must read on its own, and the tall version
  needs something in its upper part, not a big empty sky.
- **Text in a place** (a sign, a poster) is short and big enough to read at window size, or left out.

## House style

- **Writing** (comments, docs, changelog, commit messages): plain, friendly English, British spelling ("colour", "armoured"). Short sentences that explain *why*. Comments describe what you'd see on screen ("the fez, a little to the back, its tassel hanging"). Match the density and voice of the surrounding code.
- **Code:** match the existing universes exactly: file layout, naming, `private` helpers per file, `C(0xRRGGBB)` colours, no new dependencies, no image assets. Every sprite, place and effect is drawn in code.
- **Commits:** conventional commits scoped to the universe key, e.g. `feat(clawdfiles): phase 2, the core ensemble and seven more places`, with a body that says what's in it in plain words. One commit per phase, or two (stand-ins, then the art).
- **Ids are forever:** never reorder or remove enum cases once they've been committed to `main`. Only append.
- **Ask before anything public:** pushing, PRs, repos, casks, releases.

## Approval gates, in order

1. **Overview:** the comparison table, viability, name, code naming. → go or no-go, and a name.
2. **Roster:** the full cast tables with each character's weapon and signature move, HEM, agent-only, nemeses. → approved, or swaps.
3. **Places:** about 20 places and the homes. → approved.
4. **Mechanics and transitions:** the ride, the compaction mechanic, habits, drills, 8–15 transitions including the signature opening. → approved.
5. **Plan file** written, then the branch is created. → the user says start.
6. **Each build phase** is shown with Preview sheets. → next phase.
7. **The character audit** (end of phase 3): every character's weapon, shots, magic, motion, signature and callout checked against the source; the mismatches table. → fixes approved.
8. **The polish pass** (after phase 5): before-and-after renders of every weak spot fixed. → phase 6 can start.
9. **The promo storyboard.** → render the video.
10. **Anything public.** → explicit OK.
