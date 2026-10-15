import Foundation

// The Clawd of the Rings universe (inspired by The Lord of the Rings): 38 villains, 38 heroes and 4 places. Each
// character is a `Persona` registered in one of the Art/*.swift files next to its drawing code. Who lives where, the
// arch-enemies and the Eagle are decided here, in `middleEarthTheme`.
//
// Ids: villains `LOTRVillain.rawValue`, heroes 100 + `LOTRHero.rawValue`, plus `Universe.middleEarth.base`. Only ever
// append cases, so running sessions keep their characters across an update.

enum LOTRVillain: Int, CaseIterable {
    case sauron, saruman, witchKing, nazgul, balrog, gollum, uruk, orc, shelob
    case wormtongue, lurtz, gothmog, mouthOfSauron, watcher, oliphaunt, barrowWight, warg
    case denethor, ugluk, grishnakh, shagrat, ologHai, caveTroll, kingOfTheDead, corsair, haradrim, easterling, oldManWillow
    case lotho, billFerny, sharkey, necromancer, smaug, azog, bolg, goblinKing, mirkwoodSpider, masterOfLaketown

    var persona: Persona { middleEarthVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

enum LOTRHero: Int, CaseIterable {
    case gandalf, frodo, sam, pippin, aragorn, legolas, gimli, boromir, galadriel
    case merry, bilbo, elrond, arwen, theoden, faramir, treebeard, bombadil, gandalfWhite, eowyn
    case radagast, glorfindel, haldir, celeborn, eomer, butterbur, rosie, farmerMaggot, quickbeam, strider
    case thorin, balin, kili, fili, gloin, bard, beorn, thranduil
    case hem   // always last (`Universe.hem`)

    var persona: Persona { middleEarthHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let middleEarthVillainPersonas: [LOTRVillain: Persona] = ringsVillains1.merging(ringsVillains2) { a, _ in a }
    .merging(ringsVillains3) { a, _ in a }.merging(ringsVillains4) { a, _ in a }
    .merging(ringsVillains5) { a, _ in a }.merging(ringsVillains6) { a, _ in a }.merging(ringsVillains7) { a, _ in a }
    .merging(ringsVillains8) { a, _ in a }
let middleEarthHeroPersonas: [LOTRHero: Persona] = ringsHeroes1.merging(ringsHeroes2) { a, _ in a }
    .merging(ringsHeroes3) { a, _ in a }.merging(ringsHeroes4) { a, _ in a }
    .merging(ringsHeroes5) { a, _ in a }.merging(ringsHeroes6) { a, _ in a }.merging(ringsHeroes7) { a, _ in a }
    .merging(ringsHeroes8) { a, _ in a }
    .merging([.hem: hemPersona(.middleEarth)]) { a, _ in a }

// MARK: - Homes

extension Location {
    static func middleEarthHome(of villain: LOTRVillain) -> Location {
        switch villain {
        case .sauron, .saruman, .witchKing, .nazgul, .uruk, .shelob, .wormtongue, .lurtz, .gothmog, .mouthOfSauron, .oliphaunt,
             .warg, .denethor, .ugluk, .grishnakh, .shagrat, .ologHai, .kingOfTheDead, .corsair, .haradrim, .easterling,
             .necromancer, .smaug: return .mountDoom
        case .balrog, .gollum, .orc, .watcher, .barrowWight, .caveTroll, .azog, .bolg, .goblinKing, .mirkwoodSpider: return .moria
        case .oldManWillow, .lotho, .sharkey: return .bagEnd
        case .billFerny, .masterOfLaketown: return .prancingPony
        }
    }

    static func middleEarthHome(of hero: LOTRHero) -> Location {
        switch hero {
        case .frodo, .sam, .pippin, .galadriel, .merry, .bilbo, .treebeard, .bombadil, .radagast, .rosie, .farmerMaggot,
             .quickbeam, .beorn: return .bagEnd
        case .aragorn, .legolas, .boromir, .hem, .elrond, .arwen, .theoden, .faramir, .eowyn, .glorfindel, .haldir,
             .celeborn, .eomer, .butterbur, .strider, .bard, .thranduil: return .prancingPony
        case .gandalf, .gimli, .gandalfWhite, .thorin, .balin, .kili, .fili, .gloin: return .moria
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: LOTRHero) -> Cast { Cast(universe: .middleEarth, isDark: false, index: h.rawValue) }
    static func villain(_ v: LOTRVillain) -> Cast { Cast(universe: .middleEarth, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let middleEarthNemeses: [(LOTRHero, LOTRVillain)] = [
    (.gandalf, .balrog), (.frodo, .gollum), (.sam, .shelob), (.aragorn, .sauron), (.boromir, .uruk), (.gimli, .orc),
    (.galadriel, .nazgul), (.hem, .witchKing),
]

/// When these agents are done, the Great Eagle comes for them: Gandclawd from Orthanc's roof, Frodough and Samwise
/// from the slopes of Mount Doom.
private let eagleCrew: [LOTRHero] = [.gandalf, .frodo, .sam]

let middleEarthTheme = Theme(
    universe: .middleEarth,
    villains: LOTRVillain.allCases.map(\.persona),
    heroes: LOTRHero.allCases.map(\.persona),
    places: [.bagEnd, .prancingPony, .moria, .mountDoom],
    home: { c in
        c.isDark ? .middleEarthHome(of: LOTRVillain(rawValue: c.index) ?? .sauron) : .middleEarthHome(of: LOTRHero(rawValue: c.index) ?? .frodo)
    },
    nemeses: middleEarthNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { c in
        guard c.universe == .middleEarth, !c.isDark, let h = LOTRHero(rawValue: c.index) else { return nil }
        return eagleCrew.contains(h) ? .eagle : nil
    },
    menuIcon: { c, mono in drawOneRingIcon(c, mono: mono) },
    legend: .hero(.frodo))

// MARK: - Places

extension Location {
    static let bagEnd = Location("bagEnd"), prancingPony = Location("prancingPony")
    static let moria = Location("moria"), mountDoom = Location("mountDoom")
}

/// Every Clawd of the Rings place, from the Places/RingsScenes*.swift files.
let middleEarthPlaces: [Location: Place] = ringsScenes1.merging(ringsScenes2) { a, _ in a }
