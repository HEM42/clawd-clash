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
let villainPersonas: [Leader: Persona] = villains1.merging(villains2) { a, _ in a }.merging(villains3) { a, _ in a }
    .merging(villains4) { a, _ in a }

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
        case .lizard, .kraven, .magneto, .sabretooth: return .savageLand
        case .juggernaut, .mystique, .sentinel: return .xMansion
        case .apocalypse: return .attilan
        case .modok, .hydraAgent, .aimAgent, .zemo: return .hydraBase
        case .dormammu: return .darkDimension
        case .kingpin, .bullseye, .handNinja: return .hellsKitchen
        case .skrull, .batroc: return .helicarrier
        case .mandarin: return .kamarTaj
        case .killmonger: return .wakanda
        }
    }

    static func home(of hero: Companion) -> Location {
        switch hero {
        case .ironMan, .vision: return .avengersTower
        case .captainAmerica, .blackWidow, .falcon, .nickFury: return .helicarrier
        case .thor: return .asgard
        case .hulk: return .sakaar
        case .hawkeye, .thing: return .battleOfNewYork
        case .spiderMan: return .dailyBugle
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
        case .humanTorch, .mrFantastic, .invisibleWoman: return .latveria
        case .daredevil, .deadpool, .moonKnight: return .hellsKitchen
        case .shangChi: return .kamarTaj
        case .msMarvel: return .attilan
        case .ghostRider: return .darkDimension
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
        case .hero(.captainAmerica), .hero(.blackWidow), .hero(.hawkeye), .hero(.nickFury), .hero(.hulk): return .quinjet
        case .hero(.starLord), .hero(.gamora), .hero(.drax), .hero(.rocket), .hero(.groot), .hero(.mantis): return .milano
        default: return nil
        }
    }
}

enum Ride { case quinjet, milano }
