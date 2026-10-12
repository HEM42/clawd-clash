import Foundation

// The Marvel cast: 46 heroes and 46 villains. Any of them can lead a session (drawn large) or be an agent (small).
// Who they are, how they fight and how they move is a `Persona`, registered in one of the Art/*.swift files next to
// its drawing code; who lives where, who fights whom first and who gets picked up is decided here.
//
// Ids are stored in the status file: villains are `Leader.rawValue` (< 100), heroes 100 + `Companion.rawValue`.
// Only ever append cases, so running sessions keep their characters across an update.

enum Companion: Int, CaseIterable {
    // Avengers
    case ironMan, captainAmerica, thor, hulk, blackWidow, hawkeye, spiderMan, blackPanther, doctorStrange, scarletWitch
    case vision, captainMarvel
    // More Avengers and the Guardians of the Galaxy
    case antMan, wasp, falcon, winterSoldier, starLord, gamora, drax, rocket, groot, mantis, nickFury, sheHulk
    // X-Men
    case wolverine, cyclops, storm, jeanGrey, professorX, beast, nightcrawler, gambit, rogue, iceman, colossus
    // Fantastic Four, the street and the rest
    case humanTorch, thing, mrFantastic, invisibleWoman, silverSurfer, daredevil, deadpool, shangChi, msMarvel
    case moonKnight, ghostRider
    // War Machine, the Maximoff kids, Wakanda and Sakaar.
    case warMachine, wiccan, speed, quicksilver, kateBishop, yelena, okoye, shuri, valkyrie, korg
    // Kamar-Taj, the cosmos and the younger X-Men.
    case wong, hercules, sentry, cosmo, kraglin, adamWarlock, nova, kittyPryde, jubilee, psylocke
    // more X-Men and the Spider-heroes.
    case bishop, cable, havok, emmaFrost, banshee, angel, domino, x23, milesMorales, spiderGwen
    // the street — Defenders, Punisher, Blade and friends.
    case spiderWoman, blackCat, lukeCage, ironFist, jessicaJones, punisher, elektra, blade, blackKnight
    // mystics, cosmic and the funny ones.
    case monicaRambeau, clea, doctorVoodoo, howardTheDuck, squirrelGirl, jeffTheLandShark, throg, lockjaw, forbushMan
    // The TVA, the Red Room, the Savage Land, Stark's workshop and Ta Lo
    case mobius, sylvie, kidLoki, alligatorLoki, hunterB15, redGuardian, kaZar, rescue, zabu, morris, dumE

    var persona: Persona { heroPersonas[self] ?? Persona.missing(String(describing: self)) }
    var name: String { persona.name }
    var weapon: Weapon { persona.weapon }
    var headTop: Int { persona.headTop }
    var canSit: Bool { persona.canSit }
    var muzzle: (x: Double, y: Double) { persona.muzzle }
}

enum Leader: Int, CaseIterable {
    // Cosmic and Avengers foes
    case thanos, loki, ultron, redSkull, doctorDoom, hela, ronan, nebula, ebonyMaw, chitauri, grandmaster, ultronSentry
    // Spider-Man's rogues
    case greenGoblin, venom, carnage, docOck, mysterio, electro, vulture, rhino, sandman, lizard, kraven
    // Mutants, monsters and machines
    case magneto, juggernaut, sabretooth, mystique, apocalypse, sentinel, abomination, finFangFoom, modok, dormammu
    case doombot
    // The street, spies and soldiers
    case kingpin, bullseye, handNinja, hydraAgent, aimAgent, skrull, taskmaster, zemo, whiplash, mandarin, killmonger
    case batroc
    // cosmic powers and more of Spider-Man's rogues.
    case galactus, kang, mephisto, knull, annihilus, highEvolutionary, morganLeFay, scorpion, shocker, hobgoblin
    // the street and the mutant foes.
    case morbius, misterNegative, chameleon, tombstone, misterSinister, omegaRed, toad, pyro, blob
    // aliens, Avengers foes and sorcerers.
    case brood, cassandraNova, graviton, absorbingMan, crimsonDynamo, wrecker, baronMordo, enchantress, arnimZola
    // gamma, Asgard's enemies and foot soldiers.
    case countNefaria, theLeader, maestro, malekith, surtur, kurse, frostGiant, hydraSuperSoldier, kreeSoldier
    // The TVA, the Morlock Tunnels, Asteroid M, Ta Lo and the Red Room
    case missMinutes, callisto, exodus, soulEater, redRoomWidow

    var persona: Persona { villainPersonas[self] ?? Persona.missing(String(describing: self)) }
    var name: String { persona.name }
    var weapon: Weapon { persona.weapon }
    var headTop: Int { persona.headTop }
    var canSit: Bool { persona.canSit }
    var armoured: Bool { persona.armoured }
    var weaponPivot: (x: Double, y: Double) { persona.pivot }
    var muzzle: (x: Int, y: Int) { (Int(persona.muzzle.x), Int(persona.muzzle.y)) }

    init(index: Int) { self = Leader(rawValue: index % Leader.allCases.count) ?? .thanos }
}

// MARK: - Personas

/// How a character fights. The cases keep Clawd Wars' names; in the Marvel cast they mean:
/// - `saber`: up close — shields, hammers, claws, fists, swords, staffs. Deflects shots, blocks magic.
/// - `blaster`: at range — repulsors, webs, arrows, bullets, optic blasts, fire, ice… (`Persona.shot` says which).
/// - `lightning`: magic and energy streams — sorcery, telekinesis, Thanos' gauntlet (`Persona.magic` says how it looks).
/// - `none`: stays out of it.
enum Weapon { case saber, blaster, lightning, none }

/// How a character gets about when it moves along the line.
enum Motion {
    case walk
    case fly       // takes off to travel and lands where it's going (Iron Man, Thor, Captain Marvel…)
    case hover     // never quite touches the ground (Doctor Strange, Magneto, MODOK…)
    case swing     // swings on a web line (Spider-Man)
}

/// What a ranged character's shots look like.
enum ShotStyle {
    case energy(core: Px, glow: Px)   // a glowing streak: repulsors, photon blasts, Hydra rifles
    case beam(core: Px, glow: Px)     // a continuous ray from the muzzle: Cyclops, Sentinels
    case bullet                       // a small hot tracer
    case arrow                        // a feathered arrow
    case web                          // a web line with a blob on the end
    case fire                         // a fireball
    case ice                          // a frosty stream
    case card                         // a glowing playing card (Gambit)
    case thrown(Px)                   // something spinning: knives, pumpkin bombs, shuriken
}

/// What a magic or energy stream looks like.
struct Magic {
    var core: Px
    var glow: Px
    var jagged = true                 // forked like lightning; false: a steady, wavering ray
    static let lightning = Magic(core: C(0xF4F8FF), glow: C(0x7FB2FF))
}

/// One character: who it is and how it's drawn. Registered in an Art/*.swift file next to its drawing function.
struct Persona {
    let name: String
    var weapon: Weapon = .none
    var motion: Motion = .walk
    /// Ranged characters: what the shots look like.
    var shot: ShotStyle = .energy(core: C(0xFFE0E0), glow: C(0xFF2A2A))
    /// Magic characters: what the stream looks like.
    var magic: Magic = .lightning
    /// Shots ricochet off it (armour, metal, rock).
    var armoured = false
    /// Sits down when its session has been idle a while.
    var canSit = true
    /// Where shots leave from, canvas pixels, facing right.
    var muzzle: (x: Double, y: Double) = (52, 32)
    /// Where its melee weapon swings from, or where magic leaves its hand.
    var pivot: (x: Double, y: Double) = Sprite.hand
    /// Its ranged weapon is held in the hand (so it raises it to check it, idle). False when it's built in:
    /// repulsors, optic blasts, a Sentinel's palms.
    var handGun = true
    /// How many pixels further forward than plain Clawd its body reaches (the Hulk, the Juggernaut…): duels stand
    /// that much further apart so the other's weapon doesn't go through its face.
    var bulk = 0.0
    /// Top row of the head/helmet/hair on the canvas, for placing its label (the drawn sprite is measured too).
    var headTop = 21
    /// Length in seconds of its idle signature move, if it has one (`Pose.signature` runs 0…1 through it).
    var signature: Double? = nil
    /// What it says now and then while leading a session.
    var callout: String? = nil
    /// Draws it facing right on the 72×52 canvas.
    let draw: (PixelCanvas, Pose) -> Void

    /// A placeholder for a character whose persona isn't registered (shouldn't happen).
    static func missing(_ name: String) -> Persona {
        Persona(name: name, draw: { c, p in drawStandIn(c, p, body: C(0x8A8A96), trim: C(0x5A5A66)) })
    }
}

let heroPersonas: [Companion: Persona] = heroes1.merging(heroes2) { a, _ in a }.merging(heroes3) { a, _ in a }
    .merging(heroes4) { a, _ in a }
    .merging(heroes5) { a, _ in a }.merging(heroes6) { a, _ in a }.merging(heroes7) { a, _ in a }
    .merging(heroes8) { a, _ in a }.merging(heroes9) { a, _ in a }
    .merging(heroes10) { a, _ in a }
let villainPersonas: [Leader: Persona] = villains1.merging(villains2) { a, _ in a }.merging(villains3) { a, _ in a }
    .merging(villains4) { a, _ in a }
    .merging(villains5) { a, _ in a }.merging(villains6) { a, _ in a }.merging(villains7) { a, _ in a }
    .merging(villains8) { a, _ in a }.merging(villains9) { a, _ in a }

// MARK: - Homes

extension Location {
    static func home(of leader: Leader) -> Location {
        switch leader {
        case .thanos, .nebula, .ebonyMaw: return .titan
        case .loki, .hela: return .asgard
        case .ultron, .ultronSentry, .whiplash: return .avengersTower
        case .redSkull: return .vormir
        case .doctorDoom, .doombot: return .latveria
        case .ronan: return .knowhere
        case .chitauri, .vulture: return .battleOfNewYork
        case .grandmaster, .abomination, .finFangFoom: return .sakaar
        case .greenGoblin, .venom, .docOck, .mysterio: return .dailyBugle
        case .carnage, .electro, .rhino, .sandman, .taskmaster: return .raft
        case .lizard, .kraven, .sabretooth: return .savageLand
        case .magneto: return .asteroidM
        case .juggernaut, .mystique, .sentinel: return .xMansion
        case .apocalypse: return .krakoa
        case .modok, .hydraAgent, .aimAgent, .zemo: return .hydraBase
        case .dormammu: return .darkDimension
        case .kingpin, .bullseye, .handNinja: return .hellsKitchen
        case .skrull, .batroc: return .helicarrier
        case .mandarin: return .kamarTaj
        case .killmonger: return .wakanda
        case .galactus: return .worldship
        case .kang: return .quantumRealm
        case .mephisto, .knull: return .darkDimension
        case .annihilus: return .baxterBuilding
        case .highEvolutionary: return .knowhere
        case .morganLeFay: return .latveria
        case .scorpion, .chameleon, .absorbingMan, .theLeader: return .raft
        case .shocker, .hobgoblin: return .dailyBugle
        case .morbius, .omegaRed, .countNefaria: return .madripoor
        case .misterNegative, .tombstone: return .harlem
        case .misterSinister, .toad, .pyro, .cassandraNova: return .genosha
        case .blob: return .xMansion
        case .brood, .kreeSoldier: return .hala
        case .graviton: return .helicarrier
        case .crimsonDynamo, .hydraSuperSoldier: return .sokovia
        case .wrecker: return .battleOfNewYork
        case .baronMordo: return .kamarTaj
        case .enchantress: return .asgard
        case .arnimZola: return .hydraBase
        case .maestro: return .sakaar
        case .malekith, .frostGiant: return .jotunheim
        case .surtur, .kurse: return .muspelheim
        case .missMinutes: return .tva
        case .callisto: return .morlockTunnels
        case .exodus: return .asteroidM
        case .soulEater: return .taLo
        case .redRoomWidow: return .redRoom
        }
    }

    static func home(of hero: Companion) -> Location {
        switch hero {
        case .vision: return .avengersTower
        case .ironMan: return .starkWorkshop
        case .captainAmerica, .blackWidow, .falcon, .nickFury: return .helicarrier
        case .thor: return .asgard
        case .hulk: return .sakaar
        case .hawkeye: return .battleOfNewYork
        case .spiderMan: return .newYorkStreets
        case .blackPanther: return .wakanda
        case .doctorStrange: return .sanctum
        case .scarletWitch, .winterSoldier: return .hydraBase
        case .captainMarvel, .starLord, .drax, .rocket, .groot: return .knowhere
        case .antMan, .wasp: return .quantumRealm
        case .gamora, .silverSurfer: return .titan
        case .mantis: return .egosPlanet
        case .sheHulk, .colossus: return .raft
        case .wolverine, .gambit, .rogue: return .savageLand
        case .cyclops, .storm, .jeanGrey, .professorX, .beast, .nightcrawler, .iceman: return .xMansion
        case .humanTorch, .mrFantastic, .invisibleWoman, .thing: return .baxterBuilding
        case .daredevil, .deadpool, .moonKnight: return .hellsKitchen
        case .shangChi: return .taLo
        case .msMarvel: return .attilan
        case .ghostRider: return .darkDimension
        case .sentry, .blackKnight: return .avengersTower
        case .warMachine: return .avengersCompound
        case .wiccan, .speed, .quicksilver: return .sokovia
        case .kateBishop, .spiderGwen: return .dailyBugle
        case .psylocke, .domino, .x23, .blade: return .madripoor
        case .yelena: return .redRoom
        case .okoye, .shuri: return .wakanda
        case .valkyrie, .korg: return .sakaar
        case .wong: return .kamarTaj
        case .hercules, .throg: return .asgard
        case .cosmo, .kraglin, .adamWarlock, .howardTheDuck: return .knowhere
        case .monicaRambeau: return .hala
        case .nova: return .xandar
        case .kittyPryde, .jubilee, .banshee, .angel: return .xMansion
        case .bishop, .cable, .havok: return .genosha
        case .emmaFrost: return .krakoa
        case .milesMorales, .lukeCage: return .harlem
        case .spiderWoman: return .helicarrier
        case .blackCat, .jessicaJones, .punisher: return .hellsKitchen
        case .ironFist, .elektra: return .kunLun
        case .clea: return .darkDimension
        case .doctorVoodoo: return .sanctum
        case .squirrelGirl, .jeffTheLandShark, .forbushMan: return .baxterBuilding
        case .lockjaw: return .attilan
        case .mobius, .sylvie, .kidLoki, .alligatorLoki, .hunterB15: return .tva
        case .redGuardian: return .redRoom
        case .kaZar, .zabu: return .savageLandCitadel
        case .rescue: return .avengersCompound
        case .morris: return .taLo
        case .dumE: return .starkWorkshop
        }
    }
}

// MARK: - Rivalries and rides

extension Cast {
    /// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
    static let nemeses: [(Companion, Leader)] = [
        (.captainAmerica, .redSkull), (.thor, .loki), (.spiderMan, .greenGoblin), (.spiderMan, .venom),
        (.wolverine, .sabretooth), (.blackPanther, .killmonger), (.doctorStrange, .dormammu), (.hulk, .abomination),
        (.vision, .ultron), (.ironMan, .ultron), (.daredevil, .kingpin), (.daredevil, .bullseye), (.gamora, .nebula),
        (.starLord, .ronan), (.thor, .hela), (.shangChi, .mandarin), (.mrFantastic, .doctorDoom),
        (.blackWidow, .taskmaster), (.ironMan, .whiplash), (.captainMarvel, .skrull), (.cyclops, .magneto),
        (.storm, .apocalypse), (.captainAmerica, .zemo),
        (.silverSurfer, .galactus), (.antMan, .kang), (.ghostRider, .mephisto), (.doctorStrange, .baronMordo),
        (.thor, .malekith), (.thor, .surtur), (.valkyrie, .hela), (.punisher, .kingpin), (.wolverine, .omegaRed),
        (.cyclops, .misterSinister), (.hulk, .theLeader), (.hulk, .maestro), (.blade, .morbius), (.elektra, .bullseye),
        (.spiderMan, .scorpion), (.milesMorales, .hobgoblin), (.rocket, .highEvolutionary), (.captainMarvel, .kreeSoldier),
        (.lukeCage, .tombstone), (.ironFist, .handNinja), (.thor, .absorbingMan), (.mrFantastic, .annihilus),
        (.ironMan, .crimsonDynamo), (.thor, .frostGiant), (.spiderGwen, .lizard),
        (.sylvie, .missMinutes), (.blackWidow, .redRoomWidow), (.shangChi, .soulEater), (.storm, .callisto), (.cyclops, .exodus),
    ]

    func isNemesis(of other: Cast) -> Bool {
        switch (self, other) {
        case (.hero(let h), .villain(let v)), (.villain(let v), .hero(let h)): return Self.nemeses.contains { $0 == (h, v) }
        default: return false
        }
    }

    /// When this one's agent is done, its ship comes to pick it up instead of it just fading out.
    var ride: Ride? {
        switch self {
        case .hero(.captainAmerica), .hero(.blackWidow), .hero(.hawkeye), .hero(.nickFury), .hero(.hulk),
             .hero(.kateBishop), .hero(.yelena): return .quinjet
        case .hero(.starLord), .hero(.gamora), .hero(.drax), .hero(.rocket), .hero(.groot), .hero(.mantis),
             .hero(.kraglin), .hero(.cosmo): return .milano
        default: return nil
        }
    }
}

enum Ride { case quinjet, milano }
