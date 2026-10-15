# Attention: Stevie Clawdberg, built overnight

What to look at first, after a night of building Stevie Clawdberg without approval gates. Delete this file before merging.

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
- **Places:** Amity's flags are a simplified US flag; Grandpa Dread's coffin has a small cross; Mr. Wing's shop has no lettering; the Temple of Doom's lava is a thin seam (a broad orange band clashed with Clawd's orange).

## Public steps I did not take

- Pushing the `stevie_clawdberg` branch.
- A showcase repo (the private `rodclemen/stevie-clawdberg` could become it), a cask, a release.
- Uploading the trailer to GitHub so the README can link it.

## Still to verify (from the roster research)

- Mad Dog Tannin's exact line, whether Little Barry says "Toys!", and a few Jaws props (Squint's chalkboard, Hoopah's cup).

## Left over from earlier

- The remote `x-files` branch still exists (merged into main). Delete it?
- `docs/social-preview.png` and `docs/social-preview-the-clawd-files.png` need uploading in GitHub's settings by hand.
