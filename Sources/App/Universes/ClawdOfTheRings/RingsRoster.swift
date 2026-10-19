import Foundation

// The Clawd of the Rings universe (inspired by The Lord of the Rings): 38 villains, 37 heroes (and HEM) and 22 places. Each
// character is a `Persona` registered in one of the Art/*.swift files next to its drawing code. Who lives where, the
// arch-enemies and the Eagle are decided here, in `ringsTheme`.
//
// Ids: villains `RingsVillain.rawValue`, heroes 100 + `RingsHero.rawValue`, plus `Universe.middleEarth.base`. Only ever
// append cases, so running sessions keep their characters across an update.

extension RingsVillain {
    var persona: Persona { middleEarthVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension RingsHero {
    var persona: Persona { middleEarthHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

private let middleEarthVillainPersonas: [RingsVillain: Persona] = ringsVillains1.merging(ringsVillains2) { a, _ in a }
    .merging(ringsVillains3) { a, _ in a }.merging(ringsVillains4) { a, _ in a }
    .merging(ringsVillains5) { a, _ in a }.merging(ringsVillains6) { a, _ in a }.merging(ringsVillains7) { a, _ in a }
    .merging(ringsVillains8) { a, _ in a }
private let middleEarthHeroPersonas: [RingsHero: Persona] = ringsHeroes1.merging(ringsHeroes2) { a, _ in a }
    .merging(ringsHeroes3) { a, _ in a }.merging(ringsHeroes4) { a, _ in a }
    .merging(ringsHeroes5) { a, _ in a }.merging(ringsHeroes6) { a, _ in a }.merging(ringsHeroes7) { a, _ in a }
    .merging(ringsHeroes8) { a, _ in a }
    .merging([.hem: hemPersona(.middleEarth)]) { a, _ in a }

// MARK: - Homes

extension Location {
    static func middleEarthHome(of villain: RingsVillain) -> Location {
        switch villain {
        case .sauron, .shelob, .grishnakh, .shagrat: return .mountDoom
        case .balrog, .orc, .watcher, .caveTroll: return .moria
        case .saruman, .uruk: return .isengard
        case .witchKing, .nazgul: return .weathertop
        case .gollum: return .deadMarshes
        case .wormtongue, .kingOfTheDead: return .edoras
        case .lurtz, .warg, .ugluk: return .helmsDeep
        case .gothmog, .mouthOfSauron, .oliphaunt, .ologHai, .haradrim, .easterling: return .blackGate
        case .barrowWight: return .barrowDowns
        case .denethor, .corsair: return .minasTirith
        case .oldManWillow: return .oldForest
        case .lotho: return .greenDragon
        case .billFerny: return .prancingPony
        case .sharkey: return .bagEnd
        case .necromancer, .mirkwoodSpider: return .dolGuldur
        case .smaug: return .erebor
        case .azog, .bolg, .goblinKing: return .goblinTown
        case .masterOfLaketown: return .laketown
        }
    }

    static func middleEarthHome(of hero: RingsHero) -> Location {
        switch hero {
        case .frodo, .sam, .bilbo, .farmerMaggot: return .bagEnd
        case .merry, .pippin, .rosie: return .greenDragon
        case .butterbur: return .prancingPony
        case .gandalf: return .moria
        case .aragorn, .gimli: return .helmsDeep
        case .legolas, .thranduil, .radagast, .beorn: return .mirkwood
        case .boromir, .faramir, .gandalfWhite: return .minasTirith
        case .galadriel, .haldir, .celeborn: return .lothlorien
        case .elrond, .arwen, .glorfindel: return .rivendell
        case .theoden, .eowyn, .eomer, .hem: return .edoras
        case .treebeard, .quickbeam: return .fangorn
        case .bombadil: return .oldForest
        case .strider: return .weathertop
        case .thorin, .balin, .kili, .fili, .gloin: return .erebor
        case .bard: return .laketown
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: RingsHero) -> Cast { Cast(universe: .middleEarth, isDark: false, index: h.rawValue) }
    static func villain(_ v: RingsVillain) -> Cast { Cast(universe: .middleEarth, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let middleEarthNemeses: [(RingsHero, RingsVillain)] = [
    (.gandalf, .balrog), (.frodo, .gollum), (.sam, .shelob), (.aragorn, .sauron), (.boromir, .uruk), (.gimli, .orc),
    (.galadriel, .nazgul), (.hem, .witchKing),
    // The Fellowship, again: who each of them faced on the way.
    (.gandalf, .goblinKing), (.frodo, .watcher), (.frodo, .sharkey), (.sam, .shagrat), (.aragorn, .mouthOfSauron),
    (.aragorn, .kingOfTheDead), (.boromir, .lurtz), (.legolas, .oliphaunt), (.legolas, .warg), (.gimli, .corsair),
    (.merry, .barrowWight), (.pippin, .grishnakh), (.pippin, .oldManWillow), (.pippin, .ologHai),
    (.strider, .witchKing), (.strider, .billFerny), (.gandalfWhite, .saruman), (.gandalfWhite, .gothmog),
    // Rohan and Gondor.
    (.eowyn, .witchKing), (.theoden, .haradrim), (.theoden, .wormtongue), (.eomer, .ugluk), (.eomer, .easterling),
    (.faramir, .denethor), (.haldir, .ugluk),
    // The elves, the wizards and the trees.
    (.elrond, .necromancer), (.arwen, .nazgul), (.glorfindel, .balrog), (.celeborn, .necromancer),
    (.thranduil, .mirkwoodSpider), (.radagast, .mirkwoodSpider), (.treebeard, .saruman), (.quickbeam, .uruk),
    // The Shire at home.
    (.rosie, .sharkey), (.farmerMaggot, .lotho),
    // The Hobbit: the company, the dragon and the orcs of the north.
    (.thorin, .azog), (.fili, .azog), (.kili, .bolg), (.beorn, .bolg), (.balin, .caveTroll), (.gloin, .goblinKing),
    (.bard, .smaug), (.bilbo, .smaug),
]

/// When these agents are done, the Great Eagle comes for them: Gandclawd from Orthanc's roof, Frodough and Samwise
/// from the slopes of Mount Doom.
private let eagleCrew: [RingsHero] = [.gandalf, .frodo, .sam]

let ringsTheme = Theme(
    universe: .middleEarth,
    villains: RingsVillain.allCases.map(\.persona),
    heroes: RingsHero.allCases.map(\.persona),
    places: [.bagEnd, .prancingPony, .moria, .mountDoom, .greenDragon, .oldForest, .barrowDowns, .weathertop, .rivendell,
             .lothlorien, .mirkwood, .edoras, .helmsDeep, .fangorn, .isengard, .minasTirith, .blackGate, .deadMarshes,
             .dolGuldur, .goblinTown, .erebor, .laketown],
    home: { c in
        c.isDark ? .middleEarthHome(of: RingsVillain(rawValue: c.index) ?? .sauron) : .middleEarthHome(of: RingsHero(rawValue: c.index) ?? .frodo)
    },
    nemeses: middleEarthNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { c in
        guard c.universe == .middleEarth, !c.isDark, let h = RingsHero(rawValue: c.index) else { return nil }
        return eagleCrew.contains(h) ? .eagle : nil
    },
    menuIcon: { c, mono in ringsDrawOneRingIcon(c, mono: mono) },
    legend: .hero(.frodo))

// MARK: - Places

extension Location {
    static let bagEnd = Location("bagEnd"), prancingPony = Location("prancingPony")
    static let moria = Location("moria"), mountDoom = Location("mountDoom")
    static let greenDragon = Location("greenDragon"), oldForest = Location("oldForest"), barrowDowns = Location("barrowDowns")
    static let weathertop = Location("weathertop"), rivendell = Location("rivendell"), lothlorien = Location("lothlorien")
    static let mirkwood = Location("mirkwood"), edoras = Location("edoras"), helmsDeep = Location("helmsDeep")
    static let fangorn = Location("fangorn"), isengard = Location("isengard"), minasTirith = Location("minasTirith")
    static let blackGate = Location("blackGate"), deadMarshes = Location("deadMarshes"), dolGuldur = Location("dolGuldur")
    static let goblinTown = Location("goblinTown"), erebor = Location("erebor"), laketown = Location("laketown")
}

/// Every Clawd of the Rings place, from the Places/RingsScenes*.swift files.
let ringsPlaces: [Location: Place] = ringsScenes1.merging(ringsScenes2) { a, _ in a }
    .merging(ringsScenes3) { a, _ in a }.merging(ringsScenes4) { a, _ in a }.merging(ringsScenes5) { a, _ in a }
    .merging(ringsScenes6) { a, _ in a }.merging(ringsScenes7) { a, _ in a }.merging(ringsScenes8) { a, _ in a }
