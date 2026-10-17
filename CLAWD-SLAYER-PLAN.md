# Plan: a new universe, Clawd Slayer (Buffy the Vampire Slayer parody)

## Context

Clawd Clash has six universes. This plan adds Buffy the Vampire Slayer as a full ensemble, built the same way as Doctor Clawd and The Clawd Files. Every character, place, move and transition has to carry the show. Nothing is added just to grow the count.

- **Name: Clawd Slayer** (chosen on 2026-10-16). The alternatives were Buffy the Vampire Clawder (long, and it echoes Fox Clawder) and Buffy the Clawd Slayer.
- **Code naming** avoids the franchise name, as the other universes do:
  - `case slayer = 7` with key `"slayer"`.
  - Folder `Sources/App/Universes/Slayer/`, file prefix `Slayer…`.
  - Branch `buffy`.
- **Raw value:** the next free one when its build starts (Buffy is planned as 6); ids are rawValue*1000 and permanent. Six other universes are being planned at the same time (Star Trek, 007, Transformers, He-Man, Game of Thrones, Tim Burton), so every key, prefix and place key here is flavoured `slayer` so nothing clashes.
- **Scope:** all seven seasons of Buffy, plus Angel (the spin-off, five seasons). The season 8 comics aren't needed: the two shows already clear 20 heroes and 20 villains with room to spare.
- **Naming style:** light puns on the on-screen names (Buffy Clawmers, Willow Rosenclaw, Cordelia Chaise). Actors' names are never used. Where a pun would be forced, a near-spelling (Kendra Yung, Faith Lehayne).
- **Size:** about **84 characters**: 36 heroes including HEM and one agent-only kitten, and 48 villains including 4 agent-only small fry. Plus **20 places** and **13 transitions**. A little bigger than Star Clawds and The Clawd Files, a little smaller than Doctor Clawd.
- **Tone:** the show mixes comedy, teen drama and real horror. Vampires turn to dust, which is ideal for a desktop toy: no blood, just a puff. Characters whose point is sexual violence, child harm or gore are left out (the list is under Cast). Horror is kept eerie rather than gruesome.
- **Viability: a full experience.** Both sides clear 20 easily: 34 heroes and 44 villains who can lead a session.

| Universe                      | Heroes | Villains | Total | Places | Transitions |
|-------------------------------|--------|----------|-------|--------|-------------|
| Star Clawds                   |     36 |       46 |    82 |     22 | plain wipes |
| Marvelous Clawds              |    106 |       88 |   194 |     43 |           7 |
| Detective Clawds              |    111 |       97 |   208 |     43 |          15 |
| Doctor Clawd                  |     56 |       42 |    98 |     20 |          10 |
| The Clawd Files               |     36 |       46 |    82 |     20 |          10 |
| Stevie Clawdberg              |     64 |       54 |   118 |     23 |          10 |
| Clawd Slayer (proposed) | 36 |   48 |    84 |     20 |          13 |

(heroCount includes HEM and Miss Kitty; villainCount includes the four agent-only small fry. Numbers for the six existing universes as of `main` at `ebc02be`, 2026-10-16.)

## How a universe plugs in (checked against the code on 2026-10-16, `main` at `ebc02be`)

**New code: `Sources/App/Universes/Slayer/`**
- `SlayerRoster.swift` (pattern: `StevieClawdberg/ClawdbergRoster.swift`):
  - `enum SlayerHero: Int, CaseIterable` and `enum SlayerVillain: Int, CaseIterable`, append-only, with `hem` as the last hero. Case names follow the pun names (`buffyClawmers`, `willowRosenclaw`, `oldMaster`…).
  - The persona dictionaries, `.reduce([.hem: hemPersona(.slayer)])`.
  - `Location.slayerHome(of:)` for heroes and villains, `slayerNemeses`, the ride closure, `let slayerTheme = Theme(universe:villains:heroes:places:home:nemeses:ride:menuIcon:legend:)`.
  - The `static let` place keys (all prefixed `slayer…`), and `let slayerPlaces` merged from the Places files.
- `Art/SlayerHeroes1…N.swift` and `Art/SlayerVillains1…N.swift`, 8–10 personas per file. Anything shared between them (a stake, a game face, a Wolfram & Hart suit) goes in `SlayerKit.swift` with `slayer…` names.
- `Places/SlayerScenes1…N.swift` as `let slayerScenesN: [Location: Place]`.
- `SlayerIcon.swift`: the menu bar icon, 28×26, colour and mono. A wooden stake standing in front of a rounded gravestone, a crescent moon behind; in mono, the stake and stone as one silhouette.
- `SlayerRides.swift`: the school bus, Spike's DeSoto and Angel's convertible (Mechanics).
- `SlayerTabulaRasa.swift`: the forgetting spell on compaction (Mechanics).
- `SlayerDrills.swift`: the bespoke drills.
- `SlayerWipes.swift`: the transitions, last (see the end of this plan).

**Wiring into the existing code.** Every exhaustive `switch` on `Universe` turns a missed spot into a compile error, except the ones marked ⚠︎. Copy what `clawdberg` did in each spot.
- **`Sources/Shared/Universe.swift:8–33`:** the case, `key`, `title`, `villainCount`, `heroCount`.
  - `:44–52` `agentOnly`: the four small fry and Miss Kitty, as global ids.
  - `:58` `claudeSide`: Claude plays the heroes (the default `false` already covers it).
  - `:61` `rivals`: Angstel and Spyke (see Cast).
  - `:66–79` `abductees`: the eight Tabula Rasa characters (see Mechanics), with a line in the doc comment the way Clawd Files and Clawdberg have one.
- **`Sources/App/Theme.swift:47`:** `Theme.of`.
- **`Sources/App/Locations.swift:74`:** `.merging(slayerPlaces)`.
- **`Sources/App/Universes/ComicTransition.swift:12, 16, 26, 36–38`:** in phase 1 add `.slayer` to the `nil` cases; in phase 5 a `.slayer(SlayerTrip)` case in `duration`, `draw` and `pick`, and the doc comment.
- **`Sources/App/Universes/Hem.swift:27, 87, 101, 121, 143, 180`:** HEM's persona and costume in every switch: a tweed Watcher's jacket, round glasses, and a wooden stake for a weapon (`.saber`).
- **`Sources/App/Rides.swift`:** three new `Ride` cases (`schoolBus`, `deSoto`, `gtx`) in the enum (`Theme.swift`) and the `drawRide` switch; the drawings live in `SlayerRides.swift`. Add them to the comment at the top.
- ⚠︎ **`Sources/Saver/SaverView.swift:79, 89, 214`:** the Options doc comment, the choices list, and `case "slayer": tripUniverse = .slayer; tripMixed = false`.
- ⚠︎ **`Sources/App/Drills.swift:54`:** the meditation guard. Only the witches should float (Willow, Tara, Jenny Clawlendar); see Mechanics. **`:488`:** `.merging(slayerBespokeDrills)`.
- ⚠︎ **`Sources/App/Overlay.swift:865`:** the Playground's sample prompts, `Universe.shown == .slayer ? [...]`:
  `"stake the bug in the Hellmouth loop"`, `"make the window resize to fit the Claudes"`, `"why does the library's book cage keep swinging?"`, `"write a nice README with screenshots"`, `"fix the portrait crop for Glorificlaws's hair"`.
  - Lines 1113 and 1226 show how Clawdberg hooked in its set piece and drew `OutaTime`; the Tabula Rasa effect is drawn in the same place (`actor.cast.universe == .slayer ? … TabulaRasa(k:) …`). The Gentlemen's silence habit hooks into the callout code in the tick.
- ⚠︎ **`Sources/App/Pose.swift`** (`classic`) and **`Habits.swift`**: decide for each universe-specific `if` whether Slayer joins. The full-moon werewolves and the First Evil's faces are new habits (Mechanics).
- ⚠︎ **`Sources/Shared/StatusStore.swift`:** nothing new if Tabula Rasa reuses `abductees` and `rec.abducted`, as Clawdberg's 88 mph does. Check it.
- **Clawd Royale** picks up the new cast and places through `Universe.allCases`. Check that the menu bar icon and arch-enemies still hold when the scene is a Slayer place.
- **Tools:**
  - `Tools/Preview/main.swift:60–93`: the doc comment, `slayerHeroes`/`slayerVillains` batch arrays, `"slayer": Theme.of(.slayer).cast`, the batch loops, and the enum lookups by case name.
  - `Tools/Transitions/main.swift:12, 122`: the usage comment and the branch that renders `SlayerWipe.allCases`; a `slayerTitle` and `slayerShowcase` like Clawdberg's (`:201`, `:262`).
  - Phase 6: `Tools/RenderPromo` (`REEL=slayer`), `Tools/RenderDocs`, `Tools/MakeSocial`, `Tools/RenderShowcase`.

## Cast

How the engine's weapons map onto the show:
- **`.saber`** is the house style. Slayers fight hand to hand with a wooden stake; the Scythe, swords, axes and fists all count. Vampires fight with fists and fangs.
- **`.blaster`** is for the crossbows (`.arrow`), Riley's Initiative taser rifle (`.energy`, blue), Adam's arm gun, Wesley's and Kate's pistols (`.bullet`), Andrew's freeze ray (`.ice`) and D'Hoffryn's fire (`.fire`).
- **`.lightning`** is for witches and sorcerers. Each caster has their own colour and family (list below), so no two look alike here or elsewhere.
- **`armoured: true`** fits the Judge ("no weapon forged can stop him"), the invulnerable Mayor, Adam, Olaf, the Turok-Han, the Stone Beast and Skip.
- **`.hover`** for the Gentlemen (they float), Dark Willow and the First Evil.

**Every caster's look** (core / glow, family). None repeats another caster in this universe, and the colours differ from the nearest existing ones (Scarlet Glitch's pink spell, the Clawd Files' dark-core teal ray):

| Caster | Family | Colours | Why |
|---|---|---|---|
| Willow Rosenclaw | spell (sparkle ribbon) | pale leaf green / emerald | her early spells, the willow-leaf colour |
| Dark Willow | jagged lightning | near-black / crimson | "Villains": black veins, red-black bolts |
| Tara Maclaw | touch | white / soft lavender | gentle, protective magic |
| Jenny Clawlendar | steady ray | pale gold / amber | the Orb of Thessulah's glow |
| Drusillah | rings (thrall) | pale lilac / mauve | her hypnotic stare |
| Draclawla | rings (thrall) | white / blood red | his thrall over Buffy |
| The Judge | steady ray, thick | white / violet-blue | burns the humanity out of people |
| Ethan Raine | jagged lightning | magenta / orange | chaos magic |
| Gwendolyn Poste | jagged lightning, from the gloved hand only | icy white / teal-blue | the Glove of Myhnegon |
| Sweete | waves (sound) | gold / scarlet | the songs that make people sing |
| Halfreck | touch | white / hot pink | "wish granted" |
| Jazzmine | touch | cream / warm gold | everyone she touches adores her |

### Heroes (36)

**The Scooby Gang (11)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 1 | Buffy Clawmers | blonde, short leather jacket, cross necklace | stake (melee) | flips the stake, catches it; "Beep me if the apocalypse comes" |
| 2 | Willow Rosenclaw | long red hair, fuzzy jumper, knit hat (early) | magic: spell ribbon, green | floats a pencil and spins it ("Doppelgangland") |
| 3 | Xander Harrows | dark hair, loud Hawaiian shirt | melee (a 2×4) | hoists the rocket launcher onto his shoulder ("Innocence") |
| 4 | Rupert Gyles | tweed suit, round glasses | crossbow (`.arrow`) | takes off his glasses and polishes them |
| 5 | Cordelia Chaise | brown hair, cheerleader top, red-and-black skirt | crossbow (`.arrow`) | a vision hits: clutches her head, a white flash |
| 6 | Ozz | spiky dyed hair, band T-shirt, guitar on his back | melee (werewolf claws) | wolfs out for a second, fur and snout, then back |
| 7 | Anya Jinkins | blonde bob, cardigan, Magic Box apron | sword (melee, as in "Chosen") | counts money at the till, delighted |
| 8 | Tara Maclaw | long fair hair, long floral skirt, cardigan | magic: touch, lavender | cups her hands and a little lavender light rises |
| 9 | Spyke | platinum hair, long black leather duster | melee (fists) | lunges, the chip zaps him, he clutches his head |
| 10 | Dawn Clawmers | long brown hair, teen jumper | none | the Key's green energy flickers through her |
| 11 | Joyce Clawmers | short blonde hair, smart blouse | axe (melee, "School Hard") | arms folded, a mum's look |

**Slayers, Watchers and Potentials (8)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 12 | Faith Lehayne | dark hair, black vest top, leather trousers | knife (melee) | twirls the Mayor's knife |
| 13 | Kendra Yung | braided hair, practical top, Caribbean-born Slayer | stake (melee) | holds up Mr. Pointy |
| 14 | The First Slayer | white-and-black painted face, wild dreadlocks, hide wrap | spear (melee) | crouches low; sand swirls round her |
| 15 | Jenny Clawlendar | dark hair, long cardigan, laptop | magic: steady ray, amber | holds up the Orb of Thessulah, which lights |
| 16 | Principal Robin Woode | shaved head, his mother's leather coat | stake (melee) | a stake slides out of his sleeve |
| 17 | Kennedie | dark ponytail, combat trousers | quarterstaff (melee) | the drill sergeant: whistle, clipboard |
| 18 | Vy | woolly hat, glasses | stake (melee) | pulls her hat down shyly |
| 19 | Rhona | braids, sports top | axe (melee) | rolls her eyes, arms out ("this is so unfair") |

**Sunnydale friends (5)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 20 | Riley Fynn | tall, Initiative fatigues | taser rifle (`.energy`, blue) | stands to attention: "Ma'am" |
| 21 | Jonathan Levinsun | short, curly hair, tuxedo ("Superstar") | none | holds up the gold Class Protector umbrella |
| 22 | Clemm | droopy wrinkled skin, cardigan | none | munches from a bag of cheesy snacks |
| 23 | Whistlr | pork-pie hat, loud shirt | none | flips a coin, a knowing grin |
| 24 | Sid the Dummy | ventriloquist dummy in a little suit, demon hunter | knife (melee) | turns his head right round |

**Angel Investigations (10)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 25 | Angstel | dark spiky hair, long black coat | melee (fists, sword) | turns into a felt puppet for a second ("Smile Time"), then back, embarrassed |
| 26 | Wesley Windup-Pryce | Angel-era stubble, leather jacket | pistols (`.bullet`) | flicks his coat back: "Rogue demon hunter!" |
| 27 | Charles Gunne | shaved head, hoodie | hubcap axe (melee) | spins the hubcap axe |
| 28 | Fred Burkel | long brown hair, glasses, cardigan | none | scribbles equations in the air |
| 29 | Lorn | green skin, little red horns, bright suit | none | lifts a microphone and sings, notes floating up |
| 30 | Doyl | tousled hair, old jacket | melee (fists) | shifts into his blue spiky demon face and back |
| 31 | Conner | hooded teenager | stake (melee) | a leap and a crouch |
| 32 | Kate Lockclaw | blonde, LAPD badge, trouser suit | pistol (`.bullet`) | flashes her badge |
| 33 | The Groosalug | long hair, Pylean armour, broadsword | sword (melee) | heroic stance, sword up: "Princess!" |
| 34 | Drogynn | grey hair, leather armour, the Battlebrand | sword (melee) | none |

**Pets (1)**, agent-only:

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 35 | Miss Kitty Fanclawstico | Willow and Tara's grey kitten | none | chases a ball of wool |

**HEM (1)**, as in every universe, last (#36): a tweed Watcher's jacket, round glasses, a stake in one hand.

**Callouts for the leads:**
- Buffy Clawmers: "Beep me if the apocalypse comes."
- Willow Rosenclaw: "Resolve face!"
- Xander Harrows: "I laugh in the face of danger!"
- Rupert Gyles: "Oh, dear Lord."
- Cordelia Chaise: "Hel-lo?"
- Ozz: "Hey."
- Anya Jinkins: "Bunnies!"
- Spyke: "Bloody hell!"
- Joyce Clawmers: "Have you tried not being a Slayer?"
- Faith Lehayne: "Five by five."
- Kendra Yung: "Mr. Pointy."
- The First Slayer: "No friends. Just the kill."
- Angstel: "We help the helpless."
- Wesley Windup-Pryce: "Rogue demon hunter!"
- Riley Fynn: "Ma'am."
- The Groosalug: "Princess!"
- Tara, Dawn, Gunn, Fred and Lorn: none confirmed yet; I'd rather leave them silent than invent one. To check against transcripts in the phase 3 audit.

### Villains (48)

**Vampires (11)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 1 | The Old Master | bald, bat-faced, long black robes | melee (claws) | presses against the invisible barrier like a mime; "Here endeth the lesson" |
| 2 | Lukewarm | big vampire in black, game face (Luke, "The Harvest") | melee (fists) | spreads his arms and preaches |
| 3 | Darlah | blonde, dark dress (her Angel look) | twin pistols (`.bullet`, as in S1 "Angel") | twirls both pistols |
| 4 | Drusillah | long dark hair, white Victorian dress | magic: rings, lilac | holds up her doll, Miss Edith, and sways; "Naming all the stars" |
| 5 | Mr. Tricks | sharp suit, smooth | melee | straightens his tie |
| 6 | Harmony Clawdall | blonde, pink top | crossbow (`.arrow`, "Real Me") | a hair flip; "Blondie Bear!" |
| 7 | Kakistoes | huge, cloven hooves, battered coat | melee, `bulk` | stamps a hoof |
| 8 | Sundae | punk vampire, cropped hair | melee | snaps an umbrella in two (she broke Buffy's) |
| 9 | Lyle Grouch | cowboy hat, Texan | melee | spins a lasso |
| 10 | Draclawla | swept-back hair, black cape | magic: rings, red | turns to mist and back |
| 11 | The Turok-Hahn | grey, muscled, bat-faced ancient vampire | melee, `armoured`, `bulk` | roars |

**Big Bads (8)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 12 | The Judge | blue skin, horned, armour | magic: steady ray, violet-blue; `armoured` | raises a hand that crackles |
| 13 | Mayor Wilclaws | grey suit, side parting, big smile | none, `armoured` (invulnerable) | wipes his hands with a wet wipe; "Gosh!" |
| 14 | Adamm | patchwork demon-cyborg, metal plates | arm gun (`.energy`, uranium green); `armoured` | his chest opens on the glowing core |
| 15 | Professor Walshe | white lab coat, clipboard | none | taps notes on her clipboard |
| 16 | Glorificlaws | big blonde curls, red dress | melee (fists), `bulk` | admires her shoes; flickers into Ben for a frame; "I'm a god!" |
| 17 | The First Evil | its true form: a huge black horned beast | none, `.hover` | its face flickers through past Big Bads ("Lessons"); "From beneath you, it devours." |
| 18 | Preacher Calebb | black preacher's suit, hat | melee, `armoured` | rolls up his sleeves |
| 19 | Dark Willow | black hair, black eyes, dark veins, black clothes | magic: jagged lightning, black/crimson; `.hover` | letters fly up out of an open book into her arms; "Bored now." |

**Henchmen, rivals and monsters of the week (16)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 20 | A Bringer | brown robes, eyeless face | dagger (melee) | none |
| 21 | A Knight of Byzantium | chain mail, tabard, sword and shield | sword (melee), `armoured` | raises his shield |
| 22 | Dok | old man in a cardigan | knife (melee) | a long lizard tongue flicks out |
| 23 | The Gentlemen | bald, white faces, metal-toothed grin, black frock coats | scalpel (melee), `.hover`, `canSit: false` | a silent golf clap |
| 24 | Andrew Wellz | blond, Trio-era jumper | freeze ray (`.ice`) | films with his camcorder ("Storyteller") |
| 25 | Ethan Raine | leather jacket, the Mark of Eyghon tattoo | magic: jagged lightning, magenta | holds up the two-faced Janus bust |
| 26 | Sweete | red suit, top hat, cane | magic: waves, gold | taps a little dance with his cane |
| 27 | Tedd | 1950s cardigan, robot underneath | melee, `armoured` | offers a plate: "Mini pizza?" |
| 28 | Molok | robot demon of metal plates | melee, `armoured` | green text scrolls across his chest |
| 29 | Olaff the Troll | grey-green warty skin, huge hammer | hammer (melee), `armoured`, `bulk` | swings the hammer overhead: "Ale!" |
| 30 | D'Hoffrin | wrinkled demon face, long robes | fire (`.fire`) | offers his talisman |
| 31 | Halfreck | vengeance demon, ridged face, pretty dress | magic: touch, hot pink | "Wish granted!" |
| 32 | Veruka | rocker, fur-trimmed jacket | melee (werewolf claws) | howls; dark-brown wolf for a second |
| 33 | Gwendolyn Poste | prim suit, one long glove | magic: jagged lightning, teal | pulls on the glove; it crackles |
| 34 | Quentin Travesty | grey suit, Council tie | none | reads out a Council ruling |
| 35 | Principal Snide | short, suit, permanent scowl | none | wags his finger; "Watching you." |

**Wolfram & Hart and Angel's foes (9)**

| # | Name | Look | Weapon | Signature |
|---|---|---|---|---|
| 36 | Lindsey McDonclawd | young lawyer, open collar, guitar | melee (fists) | strums his guitar |
| 37 | Lilah Morgane | dark hair, black suit, briefcase | none | snaps the briefcase shut |
| 38 | Holland Mannerly | grey hair, glasses, perfect manners | none | offers a handshake |
| 39 | Jazzmine | flowing white dress, glowing smile | magic: touch, gold | arms wide; everyone nearby bows; "Love me." |
| 40 | The Stone Beast | dark grey rock skin, horns and spikes | melee, `armoured`, `bulk` | raises its arms and the sky darkens |
| 41 | Holts | 18th-century greatcoat, crossbow | crossbow (`.arrow`) | none |
| 42 | Sahjhann | scarred demon face, red | melee | flickers see-through and solid again |
| 43 | Illyrya | blue-streaked hair, red-and-black armour | melee | everyone round her freezes for a beat (she slows time) |
| 44 | Skipp | bony armoured demon, blade arm | melee, `armoured`, `bulk` | none |

**Agent-only small fry (4).** Like the MSE-6, these only ever appear as agents:
- 45. a fledgling vampire (game face, rumpled clothes from the grave);
- 46. one of Glory's minions (a scabby little robed demon, grovelling);
- 47. Gachnar, the tiny fear demon ("Fear, Itself": "Fear me!");
- 48. Amy the rat.

**Left out, and why:**
- **Warren Mears:** his arc is murder (Tara is shot) and the mind-control of his ex in "Dead Things". The Trio's comic side lives on in Andrew and Jonathan.
- **The Anointed One** and **Der Kindestod:** a child vampire who gets staked, and a demon that preys on children.
- **The She-Mantis** ("Teacher's Pet") and **Machida and the fraternity** ("Reptile Boy"): seduction and drugging plots.
- **Kralik** ("Helpless"): a serial killer. **Dr. Meltzer** (Angel): gore.
- **The Smile Time puppets:** they drain children's life force. Angel's puppet moment survives as his signature.
- **Hus** ("Pangs"): built on a stereotype. **Ampata** ("Inca Mummy Girl"): one episode, and a life-draining kiss.
- **Vamp Willow:** a lookalike of Willow and Dark Willow, and a leather-corset look. "Bored now" goes to Dark Willow.
- **The Buffybot:** a Buffy lookalike, with an awkward origin.
- **Ben** and **Angelus:** lookalikes of Glory and Angel; both live on in signatures (Glory flickers into Ben, Angel's game face).
- **The Gentlemen's footmen:** straitjacket imagery.

**Telling them apart:**
- **Inside the universe:** Willow and Dark Willow (red hair and colour vs black hair, black veins, hovering); Ozz and Veruka as wolves (grey-tan vs dark brown); the Old Master and the Turok-Hahn (black robes vs grey bare muscle); Giles and Wesley (Wesley drawn in his Angel look: stubble, leather, pistols); Buffy, Faith and Kendra (blonde and leather jacket, dark hair and black vest, braids); Angel and Spike (dark hair vs platinum); the three lawyers (Holland grey and bespectacled, Lindsey with a guitar, Lilah with a briefcase).
- **Against the other universes:** the Gentlemen vs Doctor Clawd's Silents (both pale and suited) — the Gentlemen get the big metal grin, white gloves and frock coats, the Silents have no mouth; Olaff vs Thorr (both hammers) — Olaff is warty grey-green, no cape, a much bigger hammer; the Stone Beast vs the Thingamajig — dark grey with horns, not orange; Illyrya vs Nebulah — pale skin, blue only in the hair; the Judge vs Thanoz — blue, horned, smaller; Adamm vs Solomon Grundy — metal plates, not white. Marvel's "Angell" is why Angel is "Angstel", and Doctor Clawd's "The Master" is why this one is "The Old Master".

### Nemeses

Each pair faces off on the same stage:
- Buffy Clawmers ↔ the Old Master
- Willow Rosenclaw ↔ Glorificlaws ("Tough Love")
- Xander Harrows ↔ Dark Willow (the yellow crayon, "Grave")
- Rupert Gyles ↔ Ethan Raine
- Cordelia Chaise ↔ Harmony Clawdall
- Ozz ↔ Veruka
- Anya Jinkins ↔ Olaff the Troll
- Spyke ↔ Draclawla (who owes him eleven quid)
- Faith Lehayne ↔ Kakistoes
- Kendra Yung ↔ Drusillah
- Joyce Clawmers ↔ Tedd
- Dawn Clawmers ↔ Dok
- Riley Fynn ↔ Adamm
- Jonathan Levinsun ↔ Andrew Wellz
- Principal Robin Woode ↔ Preacher Calebb
- Kennedie, Vy, Rhona ↔ the Turok-Hahn
- The First Slayer ↔ the First Evil
- Jenny Clawlendar ↔ Molok
- Tara Maclaw ↔ the Gentlemen ("Hush")
- Angstel ↔ Holts
- Wesley Windup-Pryce ↔ Lilah Morgane
- Fred Burkel ↔ Illyrya
- Lorn ↔ Lindsey McDonclawd
- Conner ↔ Sahjhann
- Charles Gunne ↔ the Stone Beast

**Rivals:** Angstel and Spyke never lead two sessions back to back (the Cup of Perpetual Torment rivalry).
**Claude's side:** the heroes.

## Places (20)

Each is a `Place` with a still picture and a moving layer, plus tall-canvas extras for the screen saver (`Scenes.isTall`). Keys are all `slayer…` (checked against every `Location("…")` on `main`; note Doctor Clawd's `theLibrary` already exists, hence `slayerLibrary`). Sunnydale is mostly at night; Los Angeles gives brighter, glassier colours, and the dream desert and the crater are the daytime places.

| # | Key | Place | Still | Moving | Tall extras |
|---|---|---|---|---|---|
| 1 | `slayerLibrary` | **Sunnydale High library** (the default) | the study table, the book cage, the stairs up to the stacks, the card catalogue | dust motes in the window light; the book cage door swings a little; now and then the Hellmouth seal glows under the floorboards | the upper stacks' balcony, the tall arched windows |
| 2 | `slayerBronze` | The Bronze | the stage, the bar, a pool table, sofas | stage lights sweep, a band silhouette plays | rafters and the lighting rig |
| 3 | `slayerCemetery` | Restfield Cemetery | crypts, leaning headstones | mist rolls; a hand pushes up out of a fresh grave | a huge full moon, a bare tree |
| 4 | `slayerRevello` | 1630 Revello Drive | the Summers house porch at dusk, lit windows | curtains stir, TV glow in the window | the roof and a starry sky |
| 5 | `slayerMagicBox` | The Magic Box | shelves of jars and crystals, the round table, the till | incense smoke curls, a hanging crystal sparkles | the training room's punch bag through the back door |
| 6 | `slayerCrypt` | Spike's crypt | an armchair, a little TV, candles | the TV flickers with a soap opera, candles gutter | stone vaulting, a ladder down |
| 7 | `slayerSunkenChurch` | The Master's sunken church | broken pews, candles, the Master's pool | candle flames, water dripping | the buried bell tower overhead |
| 8 | `slayerHellmouth` | The Hellmouth | the cavern under the school, the Seal of Danthazar | a red glow pulses through cracks | a long drop with glowing eyes far below |
| 9 | `slayerCampus` | UC Sunnydale | the quad and the clock tower | leaves blow, the clock hand moves | the clock tower full height |
| 10 | `slayerInitiative` | The Initiative | white corridors, holding cells | force-field shimmer on the cells, warning lights blink | the lift shaft up to Lowell House |
| 11 | `slayerCityHall` | The Mayor's office | wood panelling, the desk, the flag | the ceiling fan turns | a portrait wall, the dome |
| 12 | `slayerTower` | Glory's tower ("The Gift") | rickety scaffolding against the night | green-white portal energy crackles at the top | the tower's full height and the lightning |
| 13 | `slayerFactory` | The abandoned factory | chains, catwalks, a big brazier | brazier flames, a chain swaying | the catwalks and broken skylights |
| 14 | `slayerDoublemeat` | The Doublemeat Palace | the counter, the menu board, the silly hat | the neon sign flickers, the fryer bubbles | the giant burger sign on a pole |
| 15 | `slayerTownSign` | "Welcome to Sunnydale" sign | the sign by the road at night | headlights sweep past | stars, a far-off hill |
| 16 | `slayerCrater` | The crater ("Chosen") | sunrise over the crater where the town was, the sign tipping in | dust settles, the sun comes up | a wide dawn sky |
| 17 | `slayerDreamDesert` | The dream desert ("Restless") | red rocks, a campfire | heat shimmer, blowing sand | a vast sky |
| 18 | `slayerHyperion` | The Hyperion Hotel | the art deco lobby, the round desk, the stairs | the brass lift gate, a ceiling fan | the upper galleries |
| 19 | `slayerCaritas` | Caritas | the karaoke stage, the mic, demon patrons | a disco ball spins, lyrics scroll | coloured lights in the rafters |
| 20 | `slayerWolframHart` | Wolfram & Hart, Los Angeles | the glass lobby, the logo wall left blank, LA skyline | lift lights, city lights at night | the tower and the skyline |

**Homes:**
- **Scooby Gang:** Buffy, Willow, Xander, Giles, Cordelia and Ozz in the library; Joyce and Dawn at Revello Drive; Anya and Tara at the Magic Box; Spyke in his crypt.
- **Slayers:** Faith at the Bronze; Kendra in the cemetery; the First Slayer in the dream desert; Jenny in the library; Wood at the Hellmouth (his school is built on it); the Potentials at the crater.
- **Friends:** Riley at the Initiative; Jonathan at the Bronze; Clemm in Spyke's crypt; Whistlr at the town sign; Sid in the library.
- **Angel Investigations:** the Hyperion, except Lorn at Caritas and Drogynn at Wolfram & Hart. Miss Kitty at Revello Drive.
- **Villains:**
  - the sunken church: the Old Master, Lukewarm, Darlah;
  - the factory: Drusillah, the Judge;
  - the cemetery: Kakistoes, Lyle Grouch, Draclawla, the fledgling vampire;
  - the Bronze: Harmony, Sweete;
  - the campus: Sundae, the Gentlemen, Veruka, Gachnar;
  - the Mayor's office: the Mayor, Mr. Tricks;
  - the Initiative: Adamm, Walshe;
  - Glory's tower: Glorificlaws, Dok, the minion;
  - the town sign: the Knight of Byzantium (they attacked the RV on the road);
  - the Hellmouth: the First Evil, Calebb, the Turok-Hahn, the Bringer;
  - the Magic Box: Dark Willow, Ethan, Olaff, Travesty;
  - the library: Molok, Gwendolyn, Snide;
  - Revello Drive: Tedd, Amy the rat;
  - the Doublemeat Palace: Andrew;
  - Caritas: D'Hoffrin, Halfreck, Skipp;
  - Wolfram & Hart: Lindsey, Lilah, Holland, the Stone Beast, Sahjhann, Illyrya;
  - the Hyperion: Jazzmine (she took it over), Holts.

## Mechanics that make it its own universe

1. **Rides** (`SlayerRides.swift`, three new `Ride` cases):
   - **The school bus** (yellow, dented, from the "Chosen" escape) picks up and drops off the Scooby Gang, the Slayers and the Potentials.
   - **Spike's DeSoto** (a black 1950s DeSoto, its windows blacked out with paint and paper so a vampire can drive by day) for Spyke and the vampires.
   - **Angel's convertible** (a black 1967 Plymouth GTX, top down) for Angel Investigations.
   - Everyone else leaves on foot.
2. **Tabula Rasa, which is this universe's regeneration.** When a Claude Code or pi session led by one of the eight characters from "Tabula Rasa" compacts its context, Willow's forgetting spell goes off. Compaction is a session forgetting what it knew, which is exactly what that episode is. The eight: Buffy, Willow, Xander, Giles, Anya, Tara, Spyke and Dawn.
   - a crystal at their feet glows and puffs pale pink smoke;
   - a big "?" over their head, and a caption with who they think they are: **"JOAN?"** for Buffy (the name she picks), **"RANDY?"** for Spyke (from the label in his coat), **"ALEX?"** for Xander, and **"WHO AM I?"** for the rest;
   - the crystal cracks underfoot, as in the episode, and they remember: a short shimmer and the caption clears. The same face throughout.
   It reuses the clock Clawd Files and Clawdberg use: the eight go in `Universe.abductees`, and `SlayerTabulaRasa` is drawn where the overlay draws `OutaTime` (`Overlay.swift:1226`). `--missing-time` in the Playground tests it.
3. **Habits:**
   - **Hush:** while the Gentlemen are on stage, nobody's callouts show; speech bubbles come up empty.
   - **Full moon:** on nights when the real moon is full (worked out from the date), Ozz and Veruka stay as wolves.
   - **The First Evil** takes on a past Big Bad's look for a few seconds (the Old Master, the Mayor, Glory, Adam), as in "Lessons". Different from Clawd Files' Bounty Hunter, who copies whoever stands beside him.
   - **The Mayor** wipes his hands with a wet wipe after every duel.
4. **Practice drills, which are bespoke** (`SlayerDrills.swift`):
   - Buffy kicks a punch bag that swings back;
   - Willow floats a pencil ("emotional control");
   - Giles reads a dusty tome, then polishes his glasses;
   - Xander hammers nails into a plank (his building-site years);
   - Anya counts the takings;
   - the Potentials stake a training dummy;
   - Lorn sings karaoke into a mic.
   
   **Meditation: yes, but only for the witches.** Willow floats cross-legged in "Lessons" and "Chosen". Change the guard at `Drills.swift:54` so the slayer universe only lets Willow, Tara and Jenny meditate; Draclawla, the Judge and the rest don't.

## Phases

Each phase builds, is checked with Preview sheets, and is shown to you before the next one.

1. **Skeleton:**
   - the universe case, theme and all the wiring above;
   - Buffy Clawmers and Willow Rosenclaw (the first two hero cases) and the Old Master (the first villain case);
   - the Sunnydale High library, the menu icon, HEM's costume, the saver option and Preview support.
   
   It runs end to end in the app, the window, the screen saver and Clawd Royale, with plain wipes for now (`ComicTransition.pick` returns nil for it).
2. **Core ensemble.** About 35 characters:
   - the whole Scooby Gang, Faith, Kendra, Jenny, Angstel and Wesley;
   - the vampires and the Big Bads;
   - 8 places (library, Bronze, cemetery, Revello Drive, Magic Box, crypt, sunken church, Hellmouth), with the nemeses for these.
   
   As Clawd Files did, the enum cases may go in first as stand-ins, then the art in a second commit.
3. **Rest of the cast and places.** Up to 84 characters and 20 places, every home filled in. Ends with **the character audit**: every weapon, shot colour, magic family, motion, signature and callout checked against the show, and a table of only the mismatches for you.
4. **Mechanics:** the three rides, Tabula Rasa, the habits and the bespoke drills.
5. **Transitions:** the thirteen `SlayerTrip`s (see below), through `ComicTransition`.
6. **Docs and release:**
   - the README (universe table, screen-saver paragraph, a collapsible cast-and-places section, developer notes), roster and location sheets, a desktop line-up (`slayerLineup`) and a social preview;
   - `llms.txt` (the universe list, folder and prefix, the Tabula Rasa mechanic), and a `CHANGELOG.md` entry each phase;
   - a trailer, `REEL=slayer` (see Promo).
   - **Needs your OK first, since it's public:** a showcase repo and a cask in `release.sh` (`write_cask`, the `others` list, the main cask's description), releasing, pushing, a PR.

Ids are append-only, so the enum order is the order characters are added, and phases never renumber.

## Polish pass (after phase 5, before phase 6)

Keep a weak-spot list at the end of each phase and fix them all here, split by file across helpers, with before-and-after renders as the approval gate. Spots to watch from the start:
- **Stakes are small.** At 72×52 a stake is a few pixels; draw it chunky and pale so Buffy's flip reads.
- **Game faces** (ridged brows, yellow eyes) are fine detail; the vampires need their outfits and silhouettes to carry them.
- **Signatures that change the whole sprite** (Ozz's wolf, Angstel's puppet, Doyl's demon face, Glory's Ben flicker, the First Evil's faces) need checking in `build/preview cast` that they start and end in the normal pose.
- **Dark Willow's veins** may read as dirt; keep them few and bold.
- **The Gentlemen's grin** must read at agent size, or they become Silents.
- **Night places** risk all being the same navy; give each its own key colour (the Bronze's purple stage light, the factory's orange brazier, the Hellmouth's red).

**Weak spots found in phase 1** (fix in the polish pass):
- **Buffy's hair** reads a little like a helmet; a few strands breaking the outline would help.
- **The Old Master's collar** stands up like two posts; it might read better curved, and he doesn't read as bald.
- **The Old Master's signature barrier** is a faint line at desktop size; check it in the app.
- **The library on the screen saver:** the stacks are very regular, and the arched windows' tops are a little lopsided.

## Verification

- **Build:** `./build.sh`. The cast-size assert in `Overlay.swift` catches a wrong `heroCount` or `villainCount`. Before calling a phase done, `./build.sh --release <version>` to catch slow type-checking on dense drawing maths.
- **Characters:** `Tools/Preview/build.sh`, then:
  - `build/preview cast out.png "Buffy Clawmers"`;
  - `build/preview fight out.png "Buffy Clawmers" "The Old Master"`;
  - `build/preview place out.png "Clawd Slayer"`;
  - and the batch sheets, one per Art file. Look at every PNG for lookalikes and outline gaps before showing you.
- **Transitions:** `Tools/Transitions/build.sh`, then `build/transitions <outdir> slayerLibrary slayerCemetery`.
- **In the app:**
  - Settings → Universe → Clawd Slayer: new sessions get Scoobies and allies, subagents can be villains or small fry.
  - The screen saver's Options include it.
  - Random and Clawd Royale reach it.
- **Tabula Rasa:** `/compact` in a Claude session led by one of the eight, and the Playground's `--missing-time`.
- **Full moon:** fake the date in a Preview run to check the werewolves.

## Transitions (`SlayerTrip`, 13)

Each is weighted by who is on screen and where, like `DoctorTrip`.

**Style.** Everything in the app's pixel art, not painted or glossy. The palette is night-time Sunnydale: deep navy and graveyard black, moonlight blue-white, candle and brazier orange, the odd vivid accent (Willow's green, the Hellmouth's red, the Key's green-white). Los Angeles transitions are glassier: city-light ambers and cool steel. A little grain on the night ones.

**Ending.** No universe-wide finishing touch: the show has no on-screen captions to borrow, and the place label works as it is.

| # | Transition | What happens | More often with |
|---|---|---|---|
| 1 | **The Opening Titles** | The signature opening. A low organ chord over a night sky and a full moon; then fast cuts, punk-fast: a vampire lunges in game face, a gravestone, an old book flaring open, the leads' silhouettes slamming in one after another (a stake, a crossbow, a spell's glow, a rocket launcher). Our own jagged, brush-stroke lettering spells CLAWD SLAYER, with a stake for a stroke, then it clears on the new place. The longest and the rarest. | any time, rarely |
| 2 | **Dusting** | A stake strikes; the old place bursts into grey-gold dust that swirls and blows away to show the new place. The most common one. | Buffy, Faith, Kendra, the Potentials; when vampires are on stage |
| 3 | **The Watcher's Tome** | A heavy book thuds down, pages flip, and the new place appears as a woodcut illustration that fills with colour and grows to the screen. | Giles, Wesley, Jenny, Travesty, Gwendolyn; the library, the Magic Box |
| 4 | **Willow's Spell** | A circle of candles; a green ribbon of sparkles spirals in, the old scene twists through it and untwists as the new one. | Willow, Tara; the Magic Box |
| 5 | **Bored Now** | Black veins crawl across the old place from the edges until it's dark, then draw back and leave the new place. Only with Dark Willow on stage (`needsOwner`). | Dark Willow |
| 6 | **The Hellmouth Opens** | The floor splits, red light pours up, the old place tumbles in, and the new place rises out as the crack seals. | the Old Master, the First Evil, the Turok-Hahn; the Hellmouth, the library |
| 7 | **Hush** | The colour drains to grey and the Gentlemen float across in silhouette. Little glowing voices drift out of the scene into a wooden box, which snaps shut; silence; it opens on the new place. Only with the Gentlemen (`needsOwner`). | the Gentlemen; the campus |
| 8 | **Once More, With Feeling** | Red stage curtains sweep shut, a spotlight finds a top hat, and the curtains open on the new place. | Sweete, Tara, Anya; the Bronze |
| 9 | **Sunrise** | The sky blushes; a line of dawn light sweeps across, burning the old place off into brightness, and the new place settles in. | the cemetery, the crater; vampires (Spyke, Angstel) |
| 10 | **The Key** | Green energy coils in, the tower's portal tears open in green-white light, and the new place is seen through it before it closes. | Glorificlaws, Dawn, Dok; Glory's tower |
| 11 | **The Coat Swish** | A long black coat sweeps across the screen as someone strides past; city lights blur in its folds; the new place is behind it. | Angstel, Spyke; the Hyperion, Wolfram & Hart |
| 12 | **The Lift at Wolfram & Hart** | Steel lift doors close on the old place, the floor numbers count, a soft ding, and they open on the new place. | Lilah, Lindsey, Holland, Wesley; Wolfram & Hart |
| 13 | **Restless** | Sand blows across the picture; the First Slayer's painted face looms out of it and fades; the sand clears on the new place. | the First Slayer; the dream desert |

**Not used:**
- the "grr… argh" zombie tag at the end of each episode (it's the production company's logo);
- Angel's own opening titles (one signature opening is enough, and Buffy's is the better known);
- the Scythe (too close to Dusting);
- the Initiative's scanning grid (too close to Clawd Files' surveillance satellite and the lift);
- a vampire's face changing (too fine at pixel scale; it lives on as signatures);
- Sunnydale collapsing into the crater (overlaps the Hellmouth; the crater is a place instead).

**Check them** with `Tools/Transitions`, which renders all thirteen between two Slayer places.

## Promo

`REEL=slayer`, about 45–50 seconds, built on `doctorShots`:
- **`intro` (~9 s): the Opening Titles (#1).** The organ chord, the moon, the quick cuts and the silhouettes; the title (`slayerTitle`) slams in out of it, then the camera plunges into the library. Rebuilt in pixel art; no frames or logos copied.
- **Set piece (~9.5 s): "Home sweet home".** Night at the Welcome to Sunnydale sign. Spike's DeSoto smashes through it ("School Hard"), and fledgling vampires rise from the graves of Restfield. The school bus pulls up; Buffy flips her stake, Willow's green spell lights the scene, Giles fires his crossbow, and the vampires go up in dust as dawn breaks.
- Then the shared shots, with in-universe copy:
  - `desktop`: "Patrolling your desktop."
  - `status`: four characters, one per state (Giles idle, polishing his glasses; Spyke on an error, "Bloody hell!").
  - `agents`: "Every subagent gets to be a Scooby."
  - `window` at `slayerLibrary`: "Welcome to the Hellmouth."
  - `ais` and the `endcard` in the library, the crew lined up.
- **Music:** in the sound of the show's theme (an organ chord, then fast, crunchy punk guitar and drums) but our own notes; never the melody. Hits on the title slam, the DeSoto's crash and the end card.

The storyboard (`REEL=slayer build/renderpromo storyboard promo`) comes to you for approval before any video is rendered.

## Decisions (2026-10-16)

All the open questions are settled:
- **Name: Clawd Slayer.**
- **Scope:** Buffy's seven seasons and Angel's five, so the Angel cast and places stay in. No comics.
- **Sides:** Spike and Faith are heroes; Harmony and Illyria are villains.
- **Angel's name:** Angstel.
- **Caleb** stays in, tamed as planned.
- **Swaps:** none; the cast stands as written.

The plan is ready for phase 1 when you say start.