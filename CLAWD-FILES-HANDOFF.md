# The Clawd Files: handoff

Everything needed to pick up work on the fifth universe, **The Clawd Files** (an X-Files parody), in a new session.
Written 2026-10-15 at the end of phase 4, updated at the end of phase 5. **Delete this file before the branch is merged into `main`.**

## Where things stand

- **Branch:** `x-files`, off `main` after the 3.2.0 release. Local only: **not pushed**, unless the user has since
  agreed to push it.
- **Done:** phases 1–5.
  - **Phase 1:** the skeleton.
  - **Phase 2:** the core ensemble.
  - **Phase 3:** the full cast of 82 characters and all 20 places.
  - **Phase 4:** rides, missing time, bespoke drills.
  - **Phase 5:** the ten transitions and the typed captions.
- **Commits on the branch,** newest first:
  - `cc1f774` phase 4: rides, missing time, drills
  - `1d2d3da` phase 3: full cast and all places
  - `d35c82a` phase 3 groundwork (enums, homes, nemeses, stub files)
  - `bd39438` phase 2
  - `53a6945` phase 2 groundwork
  - `820025f` phase 1 skeleton
- **Next:** the polish pass (in progress), then phase 6 (docs, icon, trailer, release prep).
- **Installed app:** the user's Mac runs Clawd Clash **3.2.0** from `/Applications`. That's the `main` build, without
  The Clawd Files.
- **CHANGELOG.md** has an `## Unreleased` section describing The Clawd Files as it stands. Keep it up to date in each
  phase.

## Decisions already made (don't re-ask)

- **Name:** "The Clawd Files". The user called it "a perfect name".
- **Universe number:** `case clawdFiles = 4`. It comes before Stevie Clawdberg, whose plan in the private repo
  `rodclemen/stevie-clawdberg` still says 4 and must move to 5. Ids are `rawValue * 1000` and are saved, so this can
  never change once it ships.
- **Code naming:**
  - Folder `Sources/App/Universes/ClawdFiles/`, file prefix `Files…`, key `"clawdFiles"`.
  - Enums `FilesHero` and `FilesVillain`.
  - The code avoids the franchise name.
- **Bill Clawder** (Mulder's father) is a **villain**.
- **Missing time** only affects the **seven FBI agents**: Clawder, Scrawly, Skinnard, Doggedd, Reyez, Einstine and
  Millar (`Universe.abductees`). "Agents" means FBI agents, not Clawd Clash subagents.
- **Transitions:** the user chose ten (the list is below). They want the **opening montage used as the title sequence
  of the trailer**.
- **The plan stays local:** no private plan repo for this universe.
- **Weak spots are fixed in a polish pass after phase 5 and before phase 6** (the user's instruction): the docs sheets,
  the icon and the trailer are rendered from the characters and places, so they must be finished first.
- **Skinnard does jumping jacks instead of push-ups.** Push-ups were tried and don't work: Clawd's body is wider than
  it is tall, so lying down it reads as a box on its end.

## The user's standing preferences

- **Commits and PRs:** never add Claude as co-author, and no Claude attribution line in PRs.
- **Releases:** check the version number and let the user approve it before doing anything. `./release.sh <version>`
  builds a universal binary, signs and notarizes it (keychain profile `clawd-clash`, team `2S5TWMXL9G`), creates the
  GitHub release and updates the Homebrew tap. It needs `## <version> (date)` in CHANGELOG.md, so rename `Unreleased`
  first.
- **Changelogs:** only `CHANGELOG.md` is kept current. `history/` is frozen. The universe showcase repos get an entry
  only for showcase-worthy changes.
- **Ask first** before anything public: pushing the branch, making a showcase repo, or adding a cask.
- **Pushing:** pushing straight to `main` has been fine when the user asked for it. Do the commit and the push as
  separate commands; the auto-mode safety check blocked one combined edit-commit-push.

## How to work on it

### Build and check

- **`Tools/Preview/build.sh`** compiles all the app's drawing code without touching the installed app. Use it for
  every check:
  - `build/preview cast out.png "Fox Clawder"`: every pose.
  - `build/preview cast out.png clawdFiles`: the whole cast.
  - `build/preview fight out.png "A" "B"`.
  - `build/preview place out.png "The X-Files Office"`: window strip plus the tall screen-saver version.
  - `build/preview rides out.png`.
  - `DRILL=bespoke build/preview drills out.png "Fox Clawder" …`.
  - The sheets are big: crop and enlarge them with PIL before looking (`python3`, **without** `-I`, or PIL won't
    import).
- **`./build.sh --no-install`** builds the whole app, screen saver included, and runs the copy in `build/`. It **quits
  the user's installed copy**, so always relaunch it afterwards with `open "/Applications/Clawd Clash.app"`.
- **Don't use plain `./build.sh`** on this branch: it installs over the user's 3.2.0.
- **Test run in the new universe, without changing the user's settings:**
  ```sh
  CLAWD_SHOT=/path/shot.png CLAWD_SHOT_EVERY=3 "build/Clawd Clash.app/Contents/MacOS/ClawdClash" \
    -universe clawdFiles --playground=0,7,9
  ```
  - `-universe` overrides the setting for that run only.
  - Any `--` flag marks it as a test run, so the status file's universe is left alone.
  - `--playground` takes local villain indices, or global ids for heroes (Fox Clawder is `4100`).
  - `CLAWD_SHOT="/path/f-%d.png"` writes numbered frames.
  - `--missing-time` makes the Playground's sessions lose time two seconds in.
  - To stop the run: `pkill -f "build/Clawd Clash.app/Contents/MacOS/ClawdClash"` (it's started with a relative path),
    then relaunch the installed app.
- **Release builds:** the optimized universal build has failed before with "unable to type-check in reasonable time"
  on dense drawing arithmetic. Keep expressions in drawing code small and typed. Find offenders with
  `-Xfrontend -warn-long-expression-type-checking=300`.

### Parallel helpers

Phases 2 and 3 were drawn by parallel `fork` helpers, one file each, `isolation: "worktree"`. What worked:
- **Lay groundwork first and commit it.** That means the enum cases (append-only, HEM last), homes, nemeses,
  `heroCount`/`villainCount`, `agentOnly`, Preview batch lists, and **stub files**
  (`let filesHeroesN: [FilesHero: Persona] = [:]`), so every helper compiles alone.
- **Worktrees start on `main`,** not the current branch. Tell each helper to run `git reset --hard <groundwork commit>`
  first.
- **Each helper edits only its own file** and prefixes any shared helper names (`h5…`, `v7…`, `s4…`). Detective
  Clawds already has globals like `s6Palm`.
- **Merging:** bring files in with `git checkout worktree-agent-<id> -- <file>`, after checking `git merge-base` and
  that only that one file changed.
- **Cleanup:** the repo path has spaces (`- CODE -`), so loop with `while IFS= read -r` when removing the worktrees
  and branches.

### Drawing lessons

- **Hair gaps:** a hair or hat pattern that leaves an empty row between it and the body (the body starts at row 26)
  shows the white outline as a line across the forehead. Make hair meet the body.
- **The Preview's "idle" column** runs the real idle routine and can land in the middle of a signature. That isn't a
  bug.
- **Outlines:** only fully opaque pixels count as solid, so faint beams and glows don't get outlined.
- **`PixelCanvas.px` blends,** so drawing a transparent colour erases nothing. To move part of a sprite, use
  `move(columns:rows:dy:)`.
- **Keep ride drawing deterministic:** no `Date()`. Light state comes from the caller, which keeps the
  Transitions/promo renders reproducible.

## What's in the code (phases 1–4)

- **`Sources/App/Universes/ClawdFiles/`**
  - `FilesRoster.swift`: enums, homes, nemeses, the ride per character, `filesTheme`, the place keys.
  - `FilesIcon.swift`: the saucer menu icon.
  - `FilesRides.swift`:
    - `drawSedan`, `drawHelicopter` and `drawSaucer`;
    - `Ride.drives`: the sedan drives along the ground;
    - `Ride.boardingOffset`: 14 for ships, 6 for the TARDIS, 0 for the saucer's beam.
  - `FilesMissingTime.swift`: `MissingTime(k:)` and `drawAbductionBeam`.
  - `FilesDrills.swift`: `filesBespokeDrills`, merged into `Cast.bespokeDrills`. The firing range is for the FBI
    agents; Scrawly reads a case file, the Gunclawds hack, Skinnard does jumping jacks and Queequeg chases his tail.
  - `Art/FilesHeroes1–7.swift`, `Art/FilesVillains1–8.swift`: shared bits `drawDressShoes` and `drawSidearm`, the
    pistol plus the flashlight beam, are in Heroes1.
  - `Places/FilesScenes1–6.swift`: `Scenes.drawTinyText` (a 3×5 font with few letters) is in Scenes1, and
    `filesPine`/`filesBeam` are in Scenes3.
- **Wiring elsewhere:**
  - `Universe.swift`: case, counts, `agentOnly` (villains 43–45), `abductees`.
  - `Theme.swift`: `Theme.of` and the `Ride` cases.
  - `Locations.swift`: the merge.
  - `ComicTransition.swift`: `.clawdFiles` returns nil for now, so plain wipes.
  - `Hem.swift`: trench coat, lanyard and flashlight.
  - `Rides.swift`: `drawRide`.
  - `Overlay.swift`:
    - the boarding offset and zero lift for driving rides;
    - `Actor.abducted` and the abduction drawing;
    - the `--missing-time` flag;
    - the Playground prompts.
  - `StatusStore.swift`: `SessionRecord.abducted`; PreCompact sets it for abductees.
  - `Drills.swift`: no meditation in this universe; `standing`/`setRamp` made non-private; the merge.
  - `SaverView.swift`: the Options choice and the trip switch.
  - `Tools/Preview`: batches and lookups.

## Phase 5: transitions (done)

**As built:**
- `FilesWipes.swift`: `FilesWipe` (the ten, with owners, turf and `isRare` for the montage, which is offered 30% of
  the time), `FilesTrip` (carries `from`/`to` for the satellite), `FilesMap` (rough lat/long per place),
  `FilesCaption` (the city line per place, the typing, the typewriter font).
- Every frame is put together at one cell per art pixel in a private `Lo` frame (Core Graphics without antialiasing,
  plus pixel ops: grade, green, grain, tear, warp, dither, the map) and scaled up crisp. The cell size comes from the
  old picture's size, so it matches the art in the window, the screen saver and the tools.
- `ComicTransition.pick` takes an optional `from:`; the window's place change and the screen saver pass it.
- The typed caption: `HeaderView` (window title bar, one line joined with " · ", redrawing itself every 0.05 s while
  it types; starts when `SceneView.wipeEnds` / `ClawdWindow.switchEnds` say the transition's over) and the screen
  saver's HUD (`caption`, two lines in the typewriter face via `text(…, typed: 2)`).
- `Tools/Transitions`: the Clawd Files branch, clips end on the typed caption, and `W`/`H` env vars render at another
  size (`W=960 H=224` is about the window's scene strip).
- **The trailer's title sequence** is `FilesWipe.montage` (6 s): `FilesTrip(kind: .montage, from:, to:)`.
- The Antarctic's saucer is in the moving layer, but the window and the screen saver flatten the live layer into the
  frozen picture, so the transitions do show it.

**Weak spots in phase 5** (for the polish pass): at the window's size the lettering (TOP SECRET, the satellite's
readout, REC) is only a few pixels tall; the satellite's map is noise, not real coastlines; the smoke's office tower
is a plain block; the montage's corridor ghost is the Colonist as a white silhouette, which is small at window size.
The screen saver's typed caption was checked by building, not by watching it run.

**The brief, as given:**

Model them on Doctor Clawd:
- **Reference files:** `Sources/App/Universes/DoctorClawd/DoctorWipes.swift` (`DoctorTrip`/`DoctorWipe`: kinds,
  `duration`, `draw(ctx, old:, new:, k:, in:)` and a weighted `pick(after:cast:to:)`) and
  `Sources/App/Universes/ComicTransition.swift`.
- **To do:**
  - Add `FilesWipes.swift` with `FilesTrip`/`FilesWipe`.
  - Add `.files(FilesTrip)` to `ComicTransition`'s `duration`, `draw` and `pick`, replacing the
    `case .starWars, .clawdFiles: return nil`.
  - Add the branch in `Tools/Transitions/main.swift`. It currently falls back to Marvel's set for any universe it
    doesn't know.
- **Check with `Tools/Transitions`,** which renders clips between two places.

**Style.** Everything is drawn in the app's pixel art, not as a painted comic:
- **Palette:** desaturated forest greens, cold blue-greys, deep black shadows and the odd eerie fluorescent green.
- **Texture:** halftone dots and a little grain where it helps.
- **No glossy or neon effects.**
- **Restraint, as in the show:** most transitions are something slightly unnatural happening to an ordinary picture.

**Ending.** Every transition ends with the **typewriter caption**: the new place's name and city type themselves in
letter by letter in a corner (e.g. "FBI HEADQUARTERS / WASHINGTON, D.C."), the way every scene opens in the show.
Typed captions also replace the usual place-name label in this universe. The window shows the place name top left,
and the screen saver in a corner; find where those are drawn and give The Clawd Files the typed version.

| # | Transition | What happens | More often with |
|---|---|---|---|
| 1 | **The Black Oil** | A pool of black oil spreads up from the floor against gravity, swallows the scene into a glossy black surface, ripples, then pulls back to reveal the new place. | Clawcek, the Black Oil, Marita; the Antarctic |
| 2 | **The Blinking Eye** | A huge eye fades in with the old place reflected in its pupil; it blinks to black, opens on the new place in the pupil, and pulls out until that fills the screen. | anyone; Gibson Prays |
| 3 | **The Classified File** | The old place becomes a black-and-white photo clipped to a case file; papers slide across with TOP SECRET stamps and redaction bars; a folder opens on a photo of the new place, which zooms in and gets its colour back. | the FBI unit; the office, Skinnard's office |
| 4 | **Television Interference** | The old place on a CRT: scanlines roll, it loses sync, surveillance fragments flash, static, then it clears on the new place and pushes through the screen. | the Lone Gunclawds; their den, Apartment 42 |
| 5 | **The Opening Montage** | The title sequence: UFO, the eye, the distorted face, the ghostly silhouette in a corridor, the red-lit hand, racing clouds and THE TRUTH IS OUT THERE; the clouds part on the new place. The longest and the rarest. | any time, rarely |
| 6 | **The UFO Abduction** | A saucer over a darkened scene; its green-white cone widens until the panel washes out, symbols flickering inside; it fades to the new place under the same light and the beam pulls back up. | the Grey, the Colonist, the Faceless Rebel; Area 51, the mothership |
| 7 | **The Flashlight Investigation** | The old place goes dark to faint outlines; two flashlight beams sweep and cross in a white flash, then light up the new place as it comes back. | Clawder, Scrawly; night places |
| 8 | **Cigarette Smoke** | A ribbon of smoke drifts in, thickens into spirals with brief silhouettes of figures and government buildings, then clears on the new place with a last wisp. | the Smoking Clawd, the Syndicate; the club |
| 9 | **Surveillance Satellite** | The old place becomes a gridded green satellite image and pulls up to a dot on a map; the reticle moves and locks on; the view dives through clouds into the new place. | trips between far-apart places |
| 10 | **Paranormal Distortion** | Rows of pixels slide out of line and stretch (the warped face in the credits), collapse to a thin line and open out on the new place. | the Pusher, Eve 6, Luther Lee Boggs; paranormal monsters |

Not used, from the user's list of 15: "The Truth Is Out There" and "The Mysterious Hand" (both are in the montage),
"The Alien Silhouette" (overlaps the abduction), "The Invisible Entity" and "The Alien Implant" (detail that won't
read at pixel scale).

## Phase 6: docs and release prep

- **README:** a Clawd Files column in the universe table, plus the roster and locations sheets via `Tools/RenderDocs`
  (`roster-the-clawd-files.png` or the like, matching how it names the others), a desktop line-up and a social
  preview.
- **The app icon** gains a fifth universe (`Tools/MakeIcon`).
- **`llms.txt`:** "four universes" becomes five in several places. The README's tagline and other counts change too.
- **Trailer:** `REEL=files` in `Tools/RenderPromo`, **opening on the montage transition** as its title sequence. The
  other trailers' end cards say "One of four universes"; that becomes five.
- **Ask the user first, since these are public:** a `the-clawd-files` (or similar) showcase repo, and a cask in
  `release.sh` (`write_cask`, the `others` list, and its universe preset, which now uses `preflight_steps`).
- **Before release:** delete this file, merge `x-files` into `main`, rename `Unreleased` in CHANGELOG.md, and get the
  user's OK on the version (a minor bump, e.g. 3.3.0).

## Not done or not verified

- **The Pusher's targets freezing** (a planned habit) isn't done. It needs the fight engine to stop his opponent; for
  now his signature shows hypnotic rings on him.
- **Rides haven't been seen picking someone up in the running app.** That only happens when a real agent finishes. They
  were checked on the Preview rides sheet (landed, door open, flying). The engine change is small: zero lift for
  `drives`, and `boardingOffset`.
- **Missing time** was checked frame by frame in a Playground run (`--missing-time`), not with a real `/compact`.
- **Clawd Royale with this universe** wasn't specifically checked. It picks up the cast and places through
  `Universe.allCases`.

## Polish pass: every weak spot noticed (fix after phases 5–6)

**Phase 2 characters**
- **The Jersey Devil:** a boxy hairy blob; needs a creature silhouette (hunched, long limbs).
- **The Flukeman:** a pale marshmallow; needs to look like a worm (segments, a longer body).
- **The Alien Bounty Hunter:** at the peak of his shift he looks striped rather than clearly like Scrawly.
- **The Toothpick Man:** the toothpick is a few pixels and barely shows. His crew cut was made pale blond in phase 2
  so he doesn't read as Clawcek or Rohrer.
- **The Well-Manicured Clawd and Kersh** have no weapon, so in a fight they stand holding a brandy glass or a file;
  give them something to do.
- **Smaller:**
  - Skinnard's eye-rubbing hand is small.
  - Einstine's folded arms read as a grey band.
  - Lanky's T-shirt logo reads as a "+".
  - Frohack's stubble is faint, and his flash wobbles as it travels, like all steady rays.
  - The Grey's head tilt is one pixel.
  - Tooms's legs merge into a line at the ends of his squeeze.
  - Samantha's glow washes her out, and her beam looks grey on dark backgrounds.
  - Gibson's ray wavers like the other steady rays.
  - Billy Miles's seams get white outline lines when he comes apart.
  - The super soldiers' legs (like Mulder's and Gordon's) read as white stripes, because of the outline round thin
    dark legs.

**Phase 3 characters**
- **Yves Harlowe:** almost all black, a silhouette with a face.
- **Margaret Scrawly:** her grey temples barely show.
- **Spendr:** his shredder is small, and the strips only read in motion.
- **The Wendigo:** looks giraffe-like when it rears (a long diagonal with no forelegs), and its claw swing doesn't show
  in the fight frame.
- **Mr. Chuckleteeth:** the mask tilt shows a sliver of orange body at the left edge.
- **Eve 6:** her hair frames her face like a helmet.
- **The Colonist:** the fading hem is subtle, so in a still it reads as a floating torso.
- **The Crew-Cut Man:** his dark turtleneck sits where a mouth would be.
- **Strughold:** his grey temples are only 2 px each side.
- **Lord Kinbote** might want `armoured`; the plan doesn't say.
- **Cecil L'ively and Luther Lee Boggs** lean on Clawd orange. Luther's jumpsuit is close to it; the stencil and cuffs
  carry it.
- **The Robo-Roach:** its feelers get a busy white outline.
- **The Flukeworm** is very small, which is fine for agent-only small fry.
- **Tithonus and Cecil:** their idle frames show the engine's usual crackle streak beside them. That's a shared
  weapon habit.
- **The Mothmen** read a little like a leafy hut.
- **The Trashman** is busy at desktop size.
- **Ronnie Strickland:** his resting fangs are two pixels.
- **Tad O'Clawley:** his sound arcs and LIVE light are tiny.
- **Daggoo:** the fish is small inside the bowl.
- **The Conundrum:** his jigsaw reads as a grid or net.
- **Clyde Bruckclaw:** his kewpie doll is small and pale.
- **Frank Blackclaw:** his turned-up collar reads a little like jowls.
- **Pendrill:** his blush is 2 px per cheek.

**Places**
- **Indoor rooms (phase 2):**
  - The furniture is small next to the characters.
  - The club's ceiling smoke is faint.
  - Skinnard's office has a bare upper wall on the screen saver.
- **The sewers:**
  - The screen-saver vault is a big plain area of dim brick.
  - The outlet sits half under the water line, so its pouring water barely shows.
- **Bellefleur Woods:** the screen saver's upper half is mostly empty sky. That was intended, to leave room for the
  clock.
- **The Antarctic:**
  - The ice ridges are simple flat-topped shapes.
- **The bee domes and Ruskin Dam:** plain starry skies on the screen saver.
- **Ruskin Dam:** the fire is small in the window.
- **The quarantine railcar:** on the screen saver the upper half is many repeated ribs.
- **Tooms's block:** the street lamp's glow reads grey.
- **The Reflecting Pool:** the Monument nearly touches the top of the window strip, leaving no room for clouds there.
- **The autopsy bay:** the operating light's cone is faint.
- **Gibsonton:**
  - The banner's strongman is crude; his trunks read as a black square.
  - The Ferris wheel is thin in the window.
- **Lake Okobogee:** on the screen saver the lake is a big plain area, and Big Blue is small on it.
- **The Mutato's farm:** the farmhouse roof is shallow.

**Phase 4**
- **The sedan** is long and reads a little like a station wagon. Its wheels are small (radius 3).
- **The helicopter:** the drooping rotor blades get a doubled outline.
- **The saucer:** a stray pixel under its middle (the outline of its glow row).
- **Missing time:** the agents keep fighting while they rise; shots fire from mid-air.
- **Callouts** of characters standing next to each other can overlap, e.g. the Wendigo's "Hrrrooo!" and Guy Mann's
  line. That's engine-wide, not specific to this universe.

## The cast (as built)

**Heroes** (`FilesHero`, in id order, HEM last):
- Fox Clawder, Dana Scrawly, A.D. Walter Skinnard, John Doggedd, Monica Reyez, Agent Einstine, Agent Millar
- Bytes, Frohack, Lanky, Deep Clawt, Mister X, Marita Covarrubyass, Gibson Prays, Samantha Clawder
- Jimmy Bondd, Yves Harlowe, Melissa Scrawly, Margaret Scrawly, Teena Clawder, Jeffrey Spendr, Shannon McMahawk
- Max Fenig, Agent Pendrill, Arthur Dales, Clyde Bruckclaw, Jose Chung, Leyla Harriclaw, Frank Blackclaw
- Tad O'Clawley, Dr. Blockclaw, the Conundrum, Sheriff Hartwell, Queequeg, Daggoo
- HEM

**Villains** (`FilesVillain`, in id order):
- **The Syndicate:** the Cigarette-Smoking Clawd, Alex Clawcek, the Well-Manicured Clawd, the First Elder, Diana
  Fowlclaw, Deputy Director Kersh, the Toothpick Man.
- **The aliens:** the Alien Bounty Hunter, the Black Oil, the Grey, the Faceless Rebel, Knowle Rohrer, Billy Miles.
- **Monsters of the week:** Eugene Clawms, the Flukeman, the Pusher, the Jersey Devil.
- **More of the Syndicate and the aliens:** Strughold, A.D. Follmer, Bill Clawder, the Crew-Cut Man, the Colonist,
  Duffy Haskell, Lord Kinbote.
- **More monsters:** Leonard Betts, the Great Mutato, the Wendigo, Mr. Chuckleteeth, Eve 6, Virgil Incanto.
- **More monsters:** the Chupacabra, Big Blue, Tithonus, Cecil L'ively, Luther Lee Boggs, Eddie Van Blundht.
- **More monsters:** Ronnie Strickland, Guy Mann, the Trashman, the Tulpa, the Mothmen, the Rain King, the Teliko.
- **Agent-only small fry:** a Killer Bee, the Robo-Roach, a Flukeworm.

**Rides:**
- **The sedan:** every hero but HEM.
- **The helicopter:** the Syndicate, the FBI villains and the super soldiers.
- **The saucer:** the Bounty Hunter, the Black Oil, the Grey, the Faceless Rebel, the Colonist and Lord Kinbote.
- **On foot:** the monsters of the week.

**Nemeses:**
- Clawder ↔ the Smoking Clawd; Scrawly ↔ Clawms; Skinnard ↔ Clawcek; Doggedd ↔ Rohrer; Reyez ↔ the Toothpick Man
- Einstine and Millar ↔ the Trashman; Bytes, Frohack and Lanky ↔ Strughold
- Deep Clawt ↔ the Well-Manicured Clawd; Mister X ↔ the Bounty Hunter; Marita ↔ the Black Oil
- Gibson ↔ the Faceless Rebel; Spendr ↔ the First Elder; Dales ↔ the Colonist
- Hartwell ↔ Ronnie; Chung ↔ Kinbote; Blockclaw ↔ the Jersey Devil; Samantha ↔ the Grey

**Places** (menu order; the first is the default):
- The X-Files Office, Skinnard's Office, the Lone Gunclawds' Den, Apartment 42, the Syndicate's Club
- Bellefleur Woods, Area 51, the Antarctic Ice Field, the Quarantine Railcar, Tooms's Apartment Block
- The Sewers of Newark, Gibsonton, Florida, the Cornfield and the Bee Domes, Lake Okobogee, the Mutato's Farm
- Ruskin Dam, the Autopsy Bay, Chaney, Texas, the Reflecting Pool, the Mothership

## Also on this machine (not in the repo)

- **`~/.claude/plans/clawd-files.md`:** the original plan, including the cast tables with each character's planned
  look and signature. Everything still relevant from it is in this file.
- **Claude Code memory for this project** has the same decisions in short form.
