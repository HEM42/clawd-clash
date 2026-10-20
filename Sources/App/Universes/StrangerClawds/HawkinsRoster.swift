import Foundation

// The universe's roster: who the characters are (their personas, from the Art files), where each one lives, who fights
// whom first, who gets picked up by what, and the `Theme` that puts it all together. Then the place keys, and every
// place's drawing merged from the Places files.
//
// Names: every top-level name in the folder starts with the prefix (lower-cased for helpers) or is `private`. Preview
// compiles every universe together, so two universes' `drawHat`s would clash, and a plain name could shadow one the
// app relies on (scripts/pr-guard.py refuses it). Helpers one file uses stay `private` to it; helpers several files
// share go in a `<Prefix>Kit.swift` with prefixed names.

extension HawkinsHero {
    var persona: Persona { hawkinsHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension HawkinsVillain {
    var persona: Persona { hawkinsVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

/// Every hero's persona, from the Art/HawkinsHeroes*.swift files (8 to 10 a file), and HEM's, who the engine draws
/// in this universe's costume (HawkinsHem.swift). Add each new art file to the list.
let hawkinsHeroPersonas: [HawkinsHero: Persona] = [hawkinsHeroes1, hawkinsHeroes2, hawkinsHeroes3, hawkinsHeroes4]
    .reduce([.hem: hemPersona(.hawkins)]) { $0.merging($1) { a, _ in a } }
/// Every villain's persona, from the Art/HawkinsVillains*.swift files.
let hawkinsVillainPersonas: [HawkinsVillain: Persona] = [hawkinsVillains1, hawkinsVillains2]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

// MARK: - Homes

extension Location {
    /// Where each villain belongs: the crew gathers there when one leads the first session (window mode, Automatic).
    /// Every character's home is one of this universe's places, and a `switch` with no `default` makes the compiler
    /// ask for each new case.
    /// Characters whose own place isn't drawn yet wait in the basement, each with a comment naming where they belong.
    static func hawkinsHome(of villain: HawkinsVillain) -> Location {
        switch villain {
        case .vecna: return .hawkinsMind
        case .one: return .hawkinsCreel
        case .mindFlayer, .democlawgon: return .hawkinsUpsideDown
        case .drBrenner: return .hawkinsLab
        case .billyHargrove: return .hawkinsBasement   // for now: his home is the Community Pool
        }
    }

    static func hawkinsHome(of hero: HawkinsHero) -> Location {
        switch hero {
        case .mikeWheeler, .nancyWheeler, .barb, .hem: return .hawkinsBasement
        case .joyceByers, .jonathanByers: return .hawkinsByers
        case .steveHarringclawd, .robinBuckley, .ericaSinclair, .derekTurnbow: return .hawkinsStarcourt
        case .chiefHopper, .eleven: return .hawkinsCabin
        case .dustinHenderson, .lucasSinclawd: return .hawkinsBasement   // for now: their home is the Snow Ball
        case .maxMayfield: return .hawkinsBasement                       // for now: her home is the Palace Arcade
        case .willByers: return .hawkinsBasement                         // for now: his home is Castle Byers
        case .eddieMunclawd, .argyle: return .hawkinsBasement            // for now: their home is Eddie's trailer
        }
    }
}

// MARK: - The theme

/// A character as a `Cast`. Everywhere else, name the enum too (`.hero(HawkinsHero.eleven)`): every universe has
/// a `.hero(_:)` and a `.hem`, so a bare `.hero(.hem)` is ambiguous once they're all compiled together.
extension Cast {
    static func hero(_ h: HawkinsHero) -> Cast { Cast(universe: .hawkins, isDark: false, index: h.rawValue) }
    static func villain(_ v: HawkinsVillain) -> Cast { Cast(universe: .hawkins, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line. Each
/// pair is a hero and a villain from this universe; a character can be in more than one pair. The rest of the plan's
/// pairs (Holly and One, Karen and the Democlawgon, Hopper and Grigori…) come as their other halves are drawn.
private let hawkinsNemeses: [(HawkinsHero, HawkinsVillain)] = [
    (.eleven, .drBrenner),          // Papa
    (.maxMayfield, .vecna),         // season 4
    (.willByers, .mindFlayer),      // its host in season 2
    (.steveHarringclawd, .billyHargrove),   // their fight, season 2
]

let hawkinsTheme = Theme(
    universe: .hawkins,
    villains: HawkinsVillain.allCases.map(\.persona),
    heroes: HawkinsHero.allCases.map(\.persona),
    // Every place, in menu order. The first is the default: where the crew stands when nobody's home is known. A full
    // universe has about 20.
    places: [.hawkinsBasement, .hawkinsByers, .hawkinsLab, .hawkinsUpsideDown, .hawkinsStarcourt, .hawkinsArcade,
             .hawkinsCabin, .hawkinsCastleByers, .hawkinsCreel, .hawkinsMind, .hawkinsTrailer, .hawkinsKamchatka,
             .hawkinsVoid, .hawkinsPool, .hawkinsSnowBall, .hawkinsBennys],
    home: { c in
        c.isDark ? .hawkinsHome(of: HawkinsVillain(rawValue: c.index) ?? .vecna)
                 : .hawkinsHome(of: HawkinsHero(rawValue: c.index) ?? .mikeWheeler)
    },
    nemeses: hawkinsNemeses.map { (.hero($0.0), .villain($0.1)) },
    // Who gets picked up when their agent is done, and by what: nil walks off on foot, as everyone does for now. The
    // Party's BMX bikes come with the mechanics.
    ride: { c in
        guard c.universe == .hawkins else { return nil }
        return nil
    },
    menuIcon: hawkinsMenuIcon,
    // Who stands in for a session in Status Symbols: usually the universe's lead hero.
    legend: .hero(HawkinsHero.eleven))

// MARK: - Places

// The place keys. They're saved in settings and the screen-saver feed, and unique across every universe, so each starts
// with the prefix.
extension Location {
    static let hawkinsBasement = Location("hawkinsBasement")
    static let hawkinsByers = Location("hawkinsByers")
    static let hawkinsLab = Location("hawkinsLab")
    static let hawkinsUpsideDown = Location("hawkinsUpsideDown")
    static let hawkinsStarcourt = Location("hawkinsStarcourt")
    static let hawkinsCabin = Location("hawkinsCabin")
    static let hawkinsCreel = Location("hawkinsCreel")
    static let hawkinsMind = Location("hawkinsMind")
    static let hawkinsArcade = Location("hawkinsArcade")
    static let hawkinsCastleByers = Location("hawkinsCastleByers")
    static let hawkinsTrailer = Location("hawkinsTrailer")
    static let hawkinsKamchatka = Location("hawkinsKamchatka")
    static let hawkinsVoid = Location("hawkinsVoid")
    static let hawkinsPool = Location("hawkinsPool")
    static let hawkinsSnowBall = Location("hawkinsSnowBall")
    static let hawkinsBennys = Location("hawkinsBennys")
}

/// Every place's drawing, from the Places/HawkinsScenes*.swift files (a few places a file). Add each new file to the
/// list.
let hawkinsPlaces: [Location: Place] = [hawkinsScenes1, hawkinsScenes2, hawkinsScenes3, hawkinsScenes4, hawkinsScenes5,
                                                hawkinsScenes6]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
