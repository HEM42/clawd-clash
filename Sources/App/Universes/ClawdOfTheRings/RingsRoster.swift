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

// MARK: - Stand-ins (each Art file takes its dictionary over; delete the matching block when it does)

private func standIn(_ body: UInt32, _ trim: UInt32) -> (PixelCanvas, Pose) -> Void {
    { c, p in drawStandIn(c, p, body: C(body), trim: C(trim)) }
}

let ringsHeroes2: [LOTRHero: Persona] = [
    .gandalf: Persona(name: "Gandclawd the Grey", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xBFD8FF), jagged: false),
                      headTop: 12, signature: 3.0, callout: "A wizard is never late.", draw: standIn(0x8A8C92, 0x5E6066)),
    .aragorn: Persona(name: "Arrogorn", weapon: .saber, headTop: 20, callout: "For Frodough!", draw: standIn(0x3A3A32, 0x24241E)),
    .legolas: Persona(name: "Leggolas", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                      signature: 3.0, callout: "A red sun rises.", draw: standIn(0x5E7A3A, 0x3E5226)),
    .gimli: Persona(name: "Gimmie, son of Groan", weapon: .saber, headTop: 21, signature: 2.6, callout: "And my axe!",
                    draw: standIn(0x8A4A2A, 0x5A2E1A)),
    .boromir: Persona(name: "Boromeme", weapon: .saber, headTop: 20, signature: 3.4, callout: "One does not simply push to main.",
                      draw: standIn(0x7A2A2A, 0x4E1A1A)),
    .galadriel: Persona(name: "Gladriel", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFFFFF), glow: C(0x9FE8FF), jagged: false),
                        headTop: 19, signature: 3.0, callout: "Even the smallest Clawd can change the course of the future.",
                        draw: standIn(0xE8ECF2, 0xB8C2CE)),
]
let ringsVillains1: [LOTRVillain: Persona] = [
    .sauron: Persona(name: "Sourun", weapon: .saber, armoured: true, bulk: 2, headTop: 14, callout: "One Ring to rule them all.",
                     draw: standIn(0x2A2A30, 0x18181C)),
    .saruman: Persona(name: "Sarumanual", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xC8B8FF)), headTop: 18,
                      callout: "Read the manual, Gandclawd.", draw: standIn(0xE4E4E0, 0xB4B4AE)),
    .witchKing: Persona(name: "The Twitch-king", weapon: .saber, canSit: false, headTop: 16, callout: "No Clawd can kill me!",
                        draw: standIn(0x1E1E24, 0x101014)),
    .nazgul: Persona(name: "Nazgulp", weapon: .saber, canSit: false, headTop: 18, callout: "Baggins… Shire…",
                     draw: standIn(0x24242A, 0x141418)),
]
let ringsVillains2: [LOTRVillain: Persona] = [
    .balrog: Persona(name: "The Ballrog", weapon: .saber, armoured: true, canSit: false, bulk: 6, headTop: 8,
                     draw: standIn(0x3A1A10, 0xE8501E)),
    .gollum: Persona(name: "Smeagull", weapon: .saber, headTop: 26, signature: 3.6, callout: "My precious!",
                     draw: standIn(0xB8B49A, 0x8A866E)),
    .uruk: Persona(name: "Uruk-Hi", weapon: .saber, headTop: 19, callout: "Meat's back on the menu!",
                   draw: standIn(0x4A3A2E, 0x2E241C)),
    .orc: Persona(name: "Gorbage", weapon: .saber, headTop: 22, callout: "Collecting garbage!", draw: standIn(0x5A6A4A, 0x3A4630)),
    .shelob: Persona(name: "Shellob", weapon: .saber, canSit: false, bulk: 6, headTop: 24, draw: standIn(0x2A221E, 0x14100E)),
]

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
