# Plan: Stevie Clawdberg (a Spielberg/Amblin parody universe)

## Context

Another universe for Clawd Clash, built by following `clawdify_guide.md` step by step. One ensemble from nine films Spielberg directed or produced: Jaws, Close Encounters of the Third Kind, the Indiana Jones films, E.T., Hook and Jurassic Park (directed); Gremlins, The Goonies and Back to the Future (produced). Jurassic World and Dial of Destiny only where the cast needs someone (Owen, Claire, Blue, the Indominous Rex, Helena, Vollar). Everything comes from the films; nothing is added to grow the count.

- **Gate 1 (approved):** films, the name **Stevie Clawdberg**, the **88 mph** compaction mechanic.
- **Gate 2 (approved):** the roster below (63 heroes + HEM, 49 villains, 5 agent-only small fry: 118). The shark is Bruise the Shark.
- **Gate 3 (approved):** 23 places (the 22 drafted plus the Jolly Roger).
- **Gate 4 (decided by Claude while the user slept; listed in `attention.md` to review):** rides, set piece, habits, drills, the 10 transitions below.
- **Branch:** `stevie_clawdberg`, off main after 3.3.0. Not pushed until the user says so.

## Code

- `case clawdberg = 5` (base 5000), key `"clawdberg"`, title `"Stevie Clawdberg"`.
- Folder `Sources/App/Universes/StevieClawdberg/`, prefix `Clawdberg`:
  - `ClawdbergRoster.swift`: `ClawdbergHero`, `ClawdbergVillain` (append-only, HEM last), personas, homes, nemeses, `clawdbergTheme`, the place keys and `clawdbergPlaces`.
  - `Art/ClawdbergHeroes1…N.swift`, `Art/ClawdbergVillains1…N.swift`: about one film per file.
  - `Places/ClawdbergScenes1…N.swift`.
  - `ClawdbergIcon.swift`: the bike crossing the full moon, 28×26, colour and mono.
  - `ClawdbergWipes.swift`: `ClawdbergTrip`, the 10 transitions.
  - `IndyShootsFirst` logic: reuse `ShootsFirst` with Indy as Han and the Cairo Swordsman as Greedo.
  - `OutaTime.swift`: 88 mph.

### Wiring checklist

- `Sources/Shared/Universe.swift`: case, key, title, `villainCount` 54, `heroCount` 64, `agentOnly` (49…53), 88 mph ids.
- `Sources/App/Theme.swift`: `Theme.of`, `Ride.delorean`, `.moonBike`, `.mothership`, `.jeep`.
- `Sources/App/Locations.swift`: merge `clawdbergPlaces`.
- `Sources/App/Universes/ComicTransition.swift`: nil case in the skeleton, `.clawdberg(ClawdbergTrip)` in phase 5.
- `Sources/App/Universes/Hem.swift`: every switch (fedora, leather jacket, whip).
- `Sources/Saver/SaverView.swift`: Options doc comment, choices, trip switch.
- `Sources/App/Drills.swift`: no meditation in this universe.
- `Sources/App/Overlay.swift`: Playground prompts; ShootsFirst for Indy.
- `Sources/App/Rides.swift`: the four rides.
- `Sources/App/StatusStore.swift`: PreCompact for 88 mph.
- Tools: Preview, Transitions, RenderDocs, RenderPromo (`REEL=clawdberg`), RenderShowcase, MakeSocial demo.

## Roster

Heroes (case names in order), by film:
- Gremlins: billyPeltclawd, kateBeringer, gizmoe, randPeltclawd, lynnPeltclawd, mrWing, futterclaw, grandpaDread
- E.T.: eClawd, elliclawd, gurtie
- Jaws: chiefBroody, hoopah, squint
- The Goonies: mikeyWaltz, brandWaltz, chunk, mouth, data, andyCarmichaw, stefSteinclawd, slawth
- Indiana Jones: indianaBones, marion, shortRounds, willieScoot, sallaw, henryBones, marcusBrodie, grailKnight, mutt, helenaShore
- Jurassic Park: alanGrand, ellieSaddler, ianMalclawm, johnHammend, muldune, timMurphey, lexMurphey, rayArnie, owenGravy, claireDaring, blue, trike
- Close Encounters: royNeery, jillianGeyser, littleBarry, clawdLacombe, tallVisitor
- Hook: peterPanning, tinkerbelle, roofio, thudButt, jackBanning, tootles
- Back to the Future: martyMcFry, docBrawn, jenniferParka, georgeMcFry, lorraineBaynes, einsteinDog, claraClawton, goldieWilsun
- hem (last)

Villains:
- Gremlins: strype, mohawk, theBrain, batGremlin, electricGremlin, greta, daffy, mrsDeegle, drClawtheter
- E.T.: keyz, spacesuitMan
- Jaws: bruise, mayorVaun
- The Goonies: mamaFratelly, jakeFratelly, francisFratelly, troyPerkins, elginPerkins, oneEyedWilly
- Indiana Jones: reneBellock, majorTote, cairoSwordsman, mechanic, molaRamm, laoChay, colonelVogle, walterDonnervan, elsaSnyder, irinaSpalco, jurgenVollar, maharajah
- Jurassic Park: tWrecks, cleverGirl, spitter, dennisNerdry, indominusRex, gennarrow, drWoo
- Close Encounters: majorMildBill, gasMaskTrooper
- Hook: captainClawk, mrSmeeh, billJukes
- Back to the Future: biffTannin, oldBiff, griffTannin, madDogTannin, mrStricklaw, needles
- Agent-only small fry: compy, mogwaiPup, snake, frog, crocClock

Looks, weapons, signatures and callouts: the approved roster page (https://claude.ai/artifact/Fj4xWwd7CGgv2HMA3pe6Ro), copied into `roster.md` next to this file's scratchpad source, and into each Art file's header comment as it's drawn.

**Nemeses:** Indy ↔ Bellock, Marion ↔ Tote, Short Rounds ↔ Mola Ramm, Henry Sr. ↔ Donnervan, Helena ↔ Vollar, Mutt ↔ Spalco, Marty ↔ Mad Dog, George ↔ Biff, Doc ↔ Old Biff, Marty ↔ Griff, Billy ↔ Strype, Gizmoe ↔ Mohawk, Futterclaw ↔ the Bat Gremlin, E.Clawd ↔ Keyz, Elliclawd ↔ the Spacesuit Man, Broody ↔ Bruise, Hoopah ↔ Mayor Vaun, Mikey ↔ Mama Fratelly, Data ↔ Francis, Brand ↔ Troy, Malclawm ↔ T. Wrecks, Muldune ↔ Clever Girl, Lex ↔ Nerdry, Owen ↔ Indominous Rex, Peter ↔ Clawk, Roofio ↔ Bill Jukes, Roy ↔ Major Mild Bill.

## Places and homes

| Key | Place | Moving | Home to |
|---|---|---|---|
| hillValley1955 (default) | Hill Valley, 1955 | lightning, clock hands, rain | Marty, Doc, George, Lorraine, Goldie, Einstein, HEM |
| biffsParadise | Biff's Pleasure Paradise | neon, searchlights | Biff, Old Biff, Griff, Stricklaw, Needles |
| hillValley1885 | Hill Valley, 1885 | steam train, tumbleweed | Clara, Mad Dog, Jennifer |
| amityBeach | Amity Island beach | waves, the fin, flags | Mayor Vaun |
| orca | The Orca | bobbing, yellow barrels, gulls | Broody, Squint, Hoopah, Bruise |
| kingstonFalls | Kingston Falls | snow, Christmas lights | Billy, Kate, Rand, Lynn, Futterclaw, Mrs. Deegle, Strype, Greta, Daffy |
| wingShop | Mr. Wing's shop | lanterns, incense, a rattling cage | Mr. Wing, Gizmoe, the mogwai pup |
| clampCentre | The Clamp Centre gene lab | vats, monitors, sparks | Grandpa Dread, Dr. Clawtheter, Mohawk, the Brain, the Bat and Electric Gremlins |
| elliottStreet | Elliott's street | porch lights, fans, fog | Elliclawd, Gurtie, Keyz, the Spacesuit Man, the frog |
| moonHill | The moonlit hill | the bike across the moon, the communicator | E.Clawd |
| goondocks | The Goondocks | waves, lighthouse beam | the Goonies, the Fratellys, the Perkinses |
| inferno | The Inferno | water, torchlight | Slawth, One-Eyed Willy |
| idolTemple | The idol temple | boulder, dust | Indy, Bellock, the Cairo Swordsman, Mutt, Spalco, Helena, Vollar |
| wellOfSouls | The Well of Souls | snakes, torches, sand | Marion, Sallaw, Tote, the mechanic, the snake |
| templeOfDoom | The Temple of Doom | lava, mine carts | Short Rounds, Willie, Mola Ramm, the Maharajah, Lao Chay |
| grailTemple | The Grail temple | dust, torches | Henry Sr., Brodie, the Grail Knight, Donnervan, Elsa, Vogle |
| parkGates | The park gates | torches, the gates, mist | Muldune, Owen, Claire, Blue, Dr. Woo |
| visitorCentre | The visitor centre | the banner, a fan | Grand, Ellie, Malclawm, Hammend, Tim, Lex, Ray, Trike |
| rexPaddock | The T. rex paddock | rain, the fence, the water glass | T. Wrecks, Clever Girl, Spitter, Nerdry, Indominous Rex, Gennarrow, the Compy |
| devilsTower | Devils Tower | the mothership's lights | Roy, Jillian, Barry, Lacombe, the Tall Visitor, Major Mild Bill, the Trooper |
| neverland | Neverland | fairy lights, zip lines, waterfall | Peter, Tinkerbelle, Roofio, Thud Butt, Jack, Tootles |
| pirateTown | Pirate Town | the Croc Clock, ships, gulls | Bill Jukes, the Croc Clock |
| jollyRoger | The Jolly Roger | the deck rocking, lanterns, the sea | Captain Clawk, Mr. Smeeh |

## Mechanics (gate 4)

- **Rides:** the DeLorean (Back to the Future: drops in on fire trails), the moon bike (E.T. kids and the Goonies), the mothership (Close Encounters: a glowing descent), the park jeep (Jurassic Park humans; drives in like the sedan). Everyone else leaves on foot.
- **88 mph** (PreCompact): Marty, Doc, Jennifer, Einstein the Dog and Old Biff. The DeLorean takes them away and drops them back in fire trails, the same face.
- **Indy shoots first:** the ShootsFirst set piece with Indy as Han and the Cairo Swordsman as Greedo (the twirl, the shrug, the shot).
- **Habits:** T. Wrecks's water glass ripples; Captain Clawk flinches at the Croc Clock's tick.
- **Drills:** Indy cracks his whip at a target, Squint's harpoon, Data's gadget, Roofio fences the air, Marty's guitar solo. No meditation in this universe.

## Transitions (10)

1. **Moon bike** (the signature; also opens the trailer): the bike crosses a full moon that grows into an iris onto the new place.
2. **88 mph:** the DeLorean streaks across, a flash, fire trails split old from new.
3. **Map route:** a red line crosses an old map from the old place to the new.
4. **The fin:** a dorsal fin cuts across; the new place is in its wake.
5. **Flashbulb:** a white-out camera flash.
6. **Park gates:** the gates swing open onto the new place.
7. **Five tones:** the five coloured light panels play, each lighting a strip of the new place.
8. **Rolling boulder:** the boulder rolls across and the new place is behind it.
9. **Pixie dust:** a gold trail sparkles the new place in.
10. **The doubloon:** One-Eyed Willy's coin spins; its far side is the new place.

## Phases

1. **Skeleton:** the case and all wiring, Indiana Bones, René Bellock and Marty McFry, HEM, Hill Valley 1955, the menu icon. Every other character is a stand-in until drawn.
2. **Groundwork:** every enum case, homes, nemeses, place keys, stub files.
3. **Characters and places** (parallel helpers, one batch of files each; merge by file).
4. **Mechanics:** rides, 88 mph, Indy shoots first, habits, drills.
5. **Transitions.**
6. **Character audit, polish pass.**
7. **Docs and promo:** README, RenderDocs sheets, `llms.txt`, the trailer (`REEL=clawdberg`), RenderShowcase. No public steps.

## Verification

- `./build.sh --no-install` compiles; the cast-size assert in Overlay checks the counts.
- Preview `cast`, `fight` and `place` sheets for every batch, checked for four legs and readability.
- A Playground run with `CLAWD_SHOT` at a few places.
- `Tools/Transitions` frames for all 10.
