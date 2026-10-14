import Foundation

// The Clawd of the Rings universe (inspired by The Lord of the Rings): 9 villains, 10 heroes and 4 places. Not released yet
// (`Universe.isReleased`): only the tools show it. Each character is a `Persona` registered in one of the Art/*.swift
// files next to its drawing code. Who lives where, the arch-enemies and the Eagle are decided here, in `middleEarthTheme`.
//
// Ids: villains `LOTRVillain.rawValue`, heroes 100 + `LOTRHero.rawValue`, plus `Universe.middleEarth.base`. Only ever
// append cases, so running sessions keep their characters across an update.

enum LOTRVillain: Int, CaseIterable {
    case sauron, saruman, witchKing, nazgul, balrog, gollum, uruk, orc, shelob

    var persona: Persona { middleEarthVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

enum LOTRHero: Int, CaseIterable {
    case gandalf, frodo, sam, pippin, aragorn, legolas, gimli, boromir, galadriel
    case hem   // always last (`Universe.hem`)

    var persona: Persona { middleEarthHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let middleEarthVillainPersonas: [LOTRVillain: Persona] = ringsVillains1.merging(ringsVillains2) { a, _ in a }
let middleEarthHeroPersonas: [LOTRHero: Persona] = ringsHeroes1.merging(ringsHeroes2) { a, _ in a }
    .merging([.hem: hemPersona(.middleEarth)]) { a, _ in a }

// MARK: - Homes

extension Location {
    static func middleEarthHome(of villain: LOTRVillain) -> Location {
        switch villain {
        case .sauron, .saruman, .witchKing, .nazgul, .uruk, .shelob: return .mountDoom
        case .balrog, .gollum, .orc: return .moria
        }
    }

    static func middleEarthHome(of hero: LOTRHero) -> Location {
        switch hero {
        case .frodo, .sam, .pippin, .galadriel: return .bagEnd
        case .aragorn, .legolas, .boromir, .hem: return .prancingPony
        case .gandalf, .gimli: return .moria
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

let middleEarthTheme = Theme(
    universe: .middleEarth,
    villains: LOTRVillain.allCases.map(\.persona),
    heroes: LOTRHero.allCases.map(\.persona),
    places: [.bagEnd, .prancingPony, .moria, .mountDoom],
    home: { c in
        c.isDark ? .middleEarthHome(of: LOTRVillain(rawValue: c.index) ?? .sauron) : .middleEarthHome(of: LOTRHero(rawValue: c.index) ?? .frodo)
    },
    nemeses: middleEarthNemeses.map { (.hero($0.0), .villain($0.1)) },
    // The Eagles are coming: every hero's agent is flown home.
    ride: { c in c.universe == .middleEarth && !c.isDark ? .eagle : nil },
    menuIcon: { c, mono in drawOneRingIcon(c, mono: mono) },
    legend: .hero(.frodo))

// MARK: - Places

extension Location {
    static let bagEnd = Location("bagEnd"), prancingPony = Location("prancingPony")
    static let moria = Location("moria"), mountDoom = Location("mountDoom")
}

/// Every Clawd of the Rings place, from the Places/RingsScenes*.swift files.
let middleEarthPlaces: [Location: Place] = ringsScenes1.merging(ringsScenes2) { a, _ in a }

// Stand-in places (each Places file takes its dictionary over; delete the matching block when it does).
let ringsScenes1: [Location: Place] = [
    .bagEnd: Place(name: "Bag Endpoint", panel: 0x1C2A16, still: { c, g in c.rect(0, 0, c.w, g, C(0x6FA8DC)) }),
    .prancingPony: Place(name: "The Prancing Ponytail", panel: 0x221810, still: { c, g in c.rect(0, 0, c.w, g, C(0x4A3020)) }),
]
let ringsScenes2: [Location: Place] = [
    .moria: Place(name: "The Mines of Mori-ah", panel: 0x101216, still: { c, g in c.rect(0, 0, c.w, g, C(0x14161C)) }),
    .mountDoom: Place(name: "Mount Doomscroll", panel: 0x1E0E0A, still: { c, g in c.rect(0, 0, c.w, g, C(0x3A1A12)) }),
]

// Stand-ins until Task 9.
func drawOneRingIcon(_ c: PixelCanvas, mono: Bool = false) {
    let gold = mono ? C(0x000000) : C(0xE8B33A)
    for y in 0..<26 { for x in 0..<28 {
        let dx = Double(x) - 13.5, dy = Double(y) - 12.5, r: Double = (dx * dx + dy * dy).squareRoot()
        if r >= 8 && r <= 12 { c.px(x, y, gold) }
    } }
}
func drawEagle(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) { c.rect(10, 10, 46, 12, C(0x6A4A2A)) }
