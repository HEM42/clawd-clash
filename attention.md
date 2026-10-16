# Attention: Stevie Clawdberg, built overnight

What to look at first, after a night of building Stevie Clawdberg without approval gates. Delete this file and `handoff/` before merging.

## Start here

1. **Try it:** `./build.sh` on the `stevie_clawdberg` branch, then Settings → Universe → Stevie Clawdberg. For a quick show: hold ⌘ in the menu for the Playground. To see 88 mph and the set pieces in a test run: `CLAWD_GREEDO_EVERY=3 "build/Clawd Clash.app/Contents/MacOS/ClawdClash" -universe clawdberg -location hillValley1955 --missing-time --playground=5155,5021,5122,5031,5040` (Marty, the Cairo Swordsman, Indy, T. Wrecks, Captain Clawk).
2. **Watch the trailer:** `promo/stevie-clawdberg-promo.mp4` (1080p) and `promo/720p/Stevie-Clawdberg.mp4` (9.4 MB, for uploading). On another computer, the 720p copy is `handoff/Stevie-Clawdberg.mp4`. The storyboard is `handoff/storyboard-stevie-clawdberg.png`. The storyboard approval gate was skipped; the video was rendered straight away.
3. **Skim the sheets:** `docs/roster-stevie-clawdberg.png`, `docs/locations-stevie-clawdberg.png`, `docs/desktop-stevie-clawdberg.png`, `docs/social-preview-stevie-clawdberg.png`.
4. **On another computer:** `handoff/` holds the plan, Claude's memory notes, the storyboard and the 720p trailer (see `handoff/README.md`).
5. **The overview page** with the trailer, the polish pass before and after, and the transitions: https://claude.ai/artifact/6k9SE1AQcBSnSC4tioHGQB

## What's done (all committed on `stevie_clawdberg`, not pushed)

- The universe: `case clawdberg = 5`, wired everywhere (theme, places, HEM, screen saver Options, Playground prompts, Preview, Transitions, RenderDocs, RenderPromo).
- All 117 characters and HEM (fedora, leather jacket, bullwhip), checked against the approved roster: every weapon, signature and callout matches.
- All 23 places, the moon-bike menu icon.
- Rides (DeLorean, moon bike, mothership, park jeep), 88 mph, Indy shoots first, the two habits, five drills, ten transitions.
- Polish pass: Einstein the Dog, Trike, the Tall Visitor, Thud Butt's legs, Gizmoe's head, the Inferno, the Jolly Roger and the park gates were redrawn.
- README, `llms.txt`, CHANGELOG, the guide's gaps fixed, the trailer.
- Tested in the app: a Playground run at Hill Valley showed the storm, the water glass, Clawk, 88 mph with OUTATIME, and Indy's revolver knocking the swordsman over.

## Done on 2026-10-16 (after review)

- Doc Brawn: RC DeLorean plus the brainwave helmet (your pick). E.Clawd: no beam, just the glowing finger.
- Every magic user in every universe now has its own small variation (check with `build/preview magic out.png`).
- Park gates taller, the Jolly Roger a whole galleon from the dock.
- Trailer: crisp bike, the DeLorean picking Marty up, "universe" under the title. Transitions showcase: `SHOWCASE=` in `Tools/Transitions`.

## Decisions made without you (gate 4)

These were yours to approve. I picked them so the build could go on; change any of them freely.

- **Rides:** the DeLorean (Back to the Future), the moon bike (the E.T. kids and the Goonies), the mothership (Close Encounters), the park jeep (Jurassic Park's humans). Everyone else leaves on foot.
- **Set piece:** Indy shoots first, reusing Han and Greedo's `ShootsFirst` with Indy and the Cairo Swordsman.
- **Habits:** T. Wrecks's rippling water glass; Captain Clawk flinches at the Croc Clock's tick.
- **Drills:** Indy's whip, Squint's harpoon, Data's gadget, Roofio's fencing, Marty's guitar solo. No meditation in this universe.
- **10 transitions:** moon bike (the signature, opens the trailer), 88 mph, map route, the fin, flashbulb, park gates, five tones, rolling boulder, pixie dust, the doubloon.
- **Homes:** HEM lives in Hill Valley 1955; the Cairo Swordsman at the idol temple (so the set piece happens at home).

## Characters: worth a look

The helpers flagged these; some I fixed in the polish pass (marked there), the rest are judgement calls for you.

- **Biff's letterman patch** is a "C" (for Clawd), since a real school letter felt like an insignia.
- **Ray Arnie** has a lit cigarette, as in the film. Easy to drop.
- **Blue and Trike** are full creature suits. Muldune's callout is "Shoot her!" as the roster says (his famous line is "Clever girl").
- **One-Eyed Willy's** signature (sitting on his gold) briefly sets the shared `seatedPose` flag inside his own draw function, then restores it.
- **Squint's harpoon** flies as the shared arrow shot (two red fletch pixels); a real harpoon shot would need a new shared shot style. Same for the Gas-Mask Trooper's gas, which flies as a yellow-green streak (his signature draws real puffs).
- **Bruise the Shark's** signature puts semi-transparent water over his belly; the four legs still show through and below.
- **The Maharajah's** voodoo doll can't make a hero nearby say "ow" without shared code; he only jabs the doll.
- **Walter Donnervan's** greying draws him on a scratch canvas while his signature plays (as `remap` does in The Clawd Files).
- **Mola Ramm's** horns put his name tag high (headTop 11).
- **Tinkerbelle** is drawn half size and uses the sparkle-ribbon magic for fairy dust.
- **Billy's baseball bat against Strype** (in the roster) isn't drawn: a pose doesn't know who the opponent is, so he always uses the sword. It would need an opponent field on `Pose`.
- **Gizmoe's flaming arrow** burns while nocked, but flies as a plain arrow (a flaming one needs a new shared shot style). The Electric Gremlin's signature empties his sprite for a moment while he zips along the phone line.
- **Places:** Amity's flags are a simplified US flag; Grandpa Dread's coffin has a small cross; Mr. Wing's shop has no lettering; the Temple of Doom's lava is a thin seam (a broad orange band clashed with Clawd's orange).

## Docs

- **README totals were stale:** "481 characters, 108 places" dated from when Detective Clawds was added. I recounted every universe: 778 characters plus HEM (779) and 171 places. Worth a glance.
- **The trailer cell in the README's video table** is not there yet for Stevie Clawdberg: it needs the 720p video uploaded to GitHub by hand first (see below).

## Not done, on purpose or for lack of a tool

- **The showcase pictures** (`Tools/RenderShowcase`) and the **MakeSocial demo** have no Stevie Clawdberg branch yet: they only matter for a showcase page, which is a public step.
- **Engine-wide, not fixed here:** two callouts can overlap when neighbours speak at once (seen with Indy and T. Wrecks); The Clawd Files' `FilesWipes.swift:1062` takes 2.5 s to type-check (it shipped fine in 3.3.0, but it's the slowest expression in the app).
- **Housekeeping:** the helpers' local branches (`worktree-agent-*`, 18 of them) are merged and can be deleted with `git branch -D`.

## Public steps I did not take

- Pushing the `stevie_clawdberg` branch, merging it, a release.
- A showcase repo (the private `rodclemen/stevie-clawdberg` could become it, with `docs/social-preview-stevie-clawdberg.png` as its social preview) and a cask in `release.sh`.
- Uploading `promo/720p/Stevie-Clawdberg.mp4` to GitHub, then adding its link to the README's trailer table (the Stevie Clawdberg cell isn't there yet).

## Still to verify (from the roster research)

- Mad Dog Tannin's exact line, whether Little Barry says "Toys!", and a few Jaws props (Squint's chalkboard, Hoopah's cup).

## Left over from earlier

- The remote `x-files` branch still exists (merged into main). Delete it?
- `docs/social-preview.png` and `docs/social-preview-the-clawd-files.png` need uploading in GitHub's settings by hand.
