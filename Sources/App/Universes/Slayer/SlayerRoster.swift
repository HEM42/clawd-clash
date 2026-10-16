import Foundation

// Clawd Slayer: Buffy the Vampire Slayer's universe, Sunnydale and the Angel spin-off's Los Angeles. Any character can
// lead a session (drawn large) or be an agent (small). Who they are, how they fight and how they move is a `Persona`,
// registered in one of the Art/*.swift files next to its drawing code; who lives where, who fights whom first and who
// gets picked up is decided here, in `slayerTheme`.
//
// Ids are stored in the status file: `Universe.slayer.base` plus `SlayerVillain.rawValue` (< 100) or
// 100 + `SlayerHero.rawValue`. Only ever append cases (HEM stays last), so running sessions keep their characters
// across an update.

enum SlayerHero: Int, CaseIterable {
    // The Scooby Gang
    case buffyClawmers, willowRosenclaw, xanderHarrows, rupertGyles, cordeliaChaise, ozz, anyaJinkins, taraMaclaw
    case spyke, dawnClawmers, joyceClawmers
    // Slayers, Watchers and Potentials
    case faithLehayne, kendraYung, firstSlayer, jennyClawlendar, robinWoode, kennedie, vy, rhona
    // Sunnydale friends
    case rileyFynn, jonathanLevinsun, clemm, whistlr, sidTheDummy
    // Angel Investigations
    case angstel, wesleyWindupPryce, charlesGunne, fredBurkel, lorn, doyl, conner, kateLockclaw, groosalug, drogynn
    // Pets (agent-only)
    case missKitty
    case hem   // always last (`Universe.hem`)

    var persona: Persona { slayerHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

enum SlayerVillain: Int, CaseIterable {
    // Vampires
    case oldMaster, lukewarm, darlah, drusillah, mrTricks, harmonyClawdall, kakistoes, sundae, lyleGrouch, draclawla
    case turokHahn
    // Big Bads
    case judge, mayorWilclaws, adamm, professorWalshe, glorificlaws, firstEvil, preacherCalebb, darkWillow
    // Henchmen, rivals and monsters of the week
    case bringer, knightOfByzantium, dok, gentlemen, andrewWellz, ethanRaine, sweete, tedd, molok, olaffTheTroll
    case dHoffrin, halfreck, veruka, gwendolynPoste, quentinTravesty, principalSnide
    // Wolfram & Hart and Angel's foes
    case lindseyMcDonclawd, lilahMorgane, hollandMannerly, jazzmine, stoneBeast, holts, sahjhann, illyrya, skipp
    // Agent-only small fry
    case fledgling, gloryMinion, gachnar, amyTheRat

    var persona: Persona { slayerVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let slayerHeroPersonas: [SlayerHero: Persona] = [slayerHeroes1]
    .reduce([.hem: hemPersona(.slayer)]) { $0.merging($1) { a, _ in a } }
let slayerVillainPersonas: [SlayerVillain: Persona] = [slayerVillains1]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

/// The witches, the only ones in this universe who float cross-legged in meditation (`Drills`), by hero index.
let slayerWitches: Set<Int> = [SlayerHero.willowRosenclaw, .taraMaclaw, .jennyClawlendar].reduce(into: []) { $0.insert($1.rawValue) }

// MARK: - Homes

extension Location {
    static func slayerHome(of leader: SlayerVillain) -> Location {
        switch leader {
        case .oldMaster, .lukewarm, .darlah: return .slayerSunkenChurch
        case .drusillah, .judge: return .slayerFactory
        case .kakistoes, .lyleGrouch, .draclawla, .fledgling: return .slayerCemetery
        case .harmonyClawdall, .sweete: return .slayerBronze
        case .sundae, .gentlemen, .veruka, .gachnar: return .slayerCampus
        case .mayorWilclaws, .mrTricks: return .slayerCityHall
        case .adamm, .professorWalshe: return .slayerInitiative
        case .glorificlaws, .dok, .gloryMinion: return .slayerTower
        case .knightOfByzantium: return .slayerTownSign
        case .firstEvil, .preacherCalebb, .turokHahn, .bringer: return .slayerHellmouth
        case .darkWillow, .ethanRaine, .olaffTheTroll, .quentinTravesty: return .slayerMagicBox
        case .molok, .gwendolynPoste, .principalSnide: return .slayerLibrary
        case .tedd, .amyTheRat: return .slayerRevello
        case .andrewWellz: return .slayerDoublemeat
        case .dHoffrin, .halfreck, .skipp: return .slayerCaritas
        case .lindseyMcDonclawd, .lilahMorgane, .hollandMannerly, .stoneBeast, .sahjhann, .illyrya: return .slayerWolframHart
        case .jazzmine, .holts: return .slayerHyperion
        }
    }

    static func slayerHome(of hero: SlayerHero) -> Location {
        switch hero {
        case .buffyClawmers, .willowRosenclaw, .xanderHarrows, .rupertGyles, .cordeliaChaise, .ozz, .jennyClawlendar,
             .sidTheDummy, .hem:
            return .slayerLibrary
        case .joyceClawmers, .dawnClawmers, .missKitty: return .slayerRevello
        case .anyaJinkins, .taraMaclaw: return .slayerMagicBox
        case .spyke, .clemm: return .slayerCrypt
        case .faithLehayne, .jonathanLevinsun: return .slayerBronze
        case .kendraYung: return .slayerCemetery
        case .firstSlayer: return .slayerDreamDesert
        case .robinWoode: return .slayerHellmouth
        case .kennedie, .vy, .rhona: return .slayerCrater
        case .rileyFynn: return .slayerInitiative
        case .whistlr: return .slayerTownSign
        case .angstel, .wesleyWindupPryce, .charlesGunne, .fredBurkel, .doyl, .conner, .kateLockclaw, .groosalug:
            return .slayerHyperion
        case .lorn: return .slayerCaritas
        case .drogynn: return .slayerWolframHart
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: SlayerHero) -> Cast { Cast(universe: .slayer, isDark: false, index: h.rawValue) }
    static func villain(_ v: SlayerVillain) -> Cast { Cast(universe: .slayer, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let slayerNemeses: [(SlayerHero, SlayerVillain)] = [
    (.buffyClawmers, .oldMaster), (.willowRosenclaw, .glorificlaws), (.xanderHarrows, .darkWillow),
    (.rupertGyles, .ethanRaine), (.cordeliaChaise, .harmonyClawdall), (.ozz, .veruka), (.anyaJinkins, .olaffTheTroll),
    (.spyke, .draclawla), (.faithLehayne, .kakistoes), (.kendraYung, .drusillah), (.joyceClawmers, .tedd),
    (.dawnClawmers, .dok), (.rileyFynn, .adamm), (.jonathanLevinsun, .andrewWellz), (.robinWoode, .preacherCalebb),
    (.kennedie, .turokHahn), (.vy, .turokHahn), (.rhona, .turokHahn), (.firstSlayer, .firstEvil),
    (.jennyClawlendar, .molok), (.taraMaclaw, .gentlemen), (.angstel, .holts), (.wesleyWindupPryce, .lilahMorgane),
    (.fredBurkel, .illyrya), (.lorn, .lindseyMcDonclawd), (.conner, .sahjhann), (.charlesGunne, .stoneBeast),
]

let slayerTheme = Theme(
    universe: .slayer,
    villains: SlayerVillain.allCases.map(\.persona),
    heroes: SlayerHero.allCases.map(\.persona),
    places: [.slayerLibrary, .slayerBronze, .slayerCemetery, .slayerRevello, .slayerMagicBox, .slayerCrypt,
             .slayerSunkenChurch, .slayerHellmouth, .slayerCampus, .slayerInitiative, .slayerCityHall, .slayerTower,
             .slayerFactory, .slayerDoublemeat, .slayerTownSign, .slayerCrater, .slayerDreamDesert, .slayerHyperion,
             .slayerCaritas, .slayerWolframHart],
    home: { c in
        c.isDark ? .slayerHome(of: SlayerVillain(rawValue: c.index) ?? .oldMaster)
                 : .slayerHome(of: SlayerHero(rawValue: c.index) ?? .buffyClawmers)
    },
    nemeses: slayerNemeses.map { (.hero($0.0), .villain($0.1)) },
    // The school bus, Spike's DeSoto and Angel's convertible come in phase 4; until then everyone leaves on foot.
    ride: { _ in nil },
    menuIcon: drawStakeIcon,
    legend: .hero(.buffyClawmers))

// MARK: - Places

extension Location {
    static let slayerLibrary = Location("slayerLibrary")
    static let slayerBronze = Location("slayerBronze")
    static let slayerCemetery = Location("slayerCemetery")
    static let slayerRevello = Location("slayerRevello")
    static let slayerMagicBox = Location("slayerMagicBox")
    static let slayerCrypt = Location("slayerCrypt")
    static let slayerSunkenChurch = Location("slayerSunkenChurch")
    static let slayerHellmouth = Location("slayerHellmouth")
    static let slayerCampus = Location("slayerCampus")
    static let slayerInitiative = Location("slayerInitiative")
    static let slayerCityHall = Location("slayerCityHall")
    static let slayerTower = Location("slayerTower")
    static let slayerFactory = Location("slayerFactory")
    static let slayerDoublemeat = Location("slayerDoublemeat")
    static let slayerTownSign = Location("slayerTownSign")
    static let slayerCrater = Location("slayerCrater")
    static let slayerDreamDesert = Location("slayerDreamDesert")
    static let slayerHyperion = Location("slayerHyperion")
    static let slayerCaritas = Location("slayerCaritas")
    static let slayerWolframHart = Location("slayerWolframHart")
}

/// Every Clawd Slayer place, from the Places/SlayerScenes*.swift files.
let slayerPlaces: [Location: Place] = [slayerScenes1]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
