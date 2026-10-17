import Foundation

// A universe's content: its cast, its places, who lives where, who fights whom first, who gets picked up, and the
// little things that dress the app in it (the menu bar icon, the Status Symbols character). Each universe defines one
// in its folder (Universes/<Name>/); the engine only ever asks the current `Theme`.

struct Theme {
    let universe: Universe
    /// Villains by local index (0…), then heroes by local index (0…).
    let villains: [Persona]
    let heroes: [Persona]
    /// Every place, in menu order. The first is where the crew stands when nobody's home is known.
    let places: [Location]
    /// Where a character belongs.
    let home: (Cast) -> Location
    /// Arch-enemies, paired first whenever both are fighting.
    let nemeses: [(Cast, Cast)]
    /// Who gets picked up by a ship when its agent is done.
    let ride: (Cast) -> Ride?
    /// The menu bar icon, on a 28×26 canvas; `mono`: one colour, for a template image.
    let menuIcon: (PixelCanvas, _ mono: Bool) -> Void
    /// Who stands in for a session in Status Symbols.
    let legend: Cast

    func persona(_ c: Cast) -> Persona {
        let list = c.isDark ? villains : heroes
        guard list.indices.contains(c.index) else { return Persona.missing("\(universe.key) \(c.id)") }
        var p = list[c.index]
        if p.weapon == .lightning { p.magic.variant = magicVariants[c.id] ?? 0 }
        return p
    }

    var cast: [Cast] {
        villains.indices.map { Cast(universe: universe, isDark: true, index: $0) }
            + heroes.indices.map { Cast(universe: universe, isDark: false, index: $0) }
    }

    func isNemesis(_ a: Cast, _ b: Cast) -> Bool { nemeses.contains { ($0.0 == a && $0.1 == b) || ($0.0 == b && $0.1 == a) } }

    static func of(_ u: Universe) -> Theme {
        switch u {
        case .starWars: return starWarsTheme
        case .marvel: return marvelTheme
        case .dc: return dcTheme
        case .doctor: return doctorTheme
        case .clawdFiles: return filesTheme
        case .clawdberg: return clawdbergTheme
        case .middleEarth: return middleEarthTheme
        case .slayer: return slayerTheme
        }
    }
}

/// Each magic user's `Magic.variant`, by cast id: numbered in order through every universe within each family of looks
/// (lightning, rays, rings…), so no two characters anywhere draw their magic exactly alike.
let magicVariants: [Int: Int] = {
    var next: [Int: Int] = [:], out: [Int: Int] = [:]
    for u in Universe.allCases {
        let theme = Theme.of(u)
        for c in theme.cast {
            let list = c.isDark ? theme.villains : theme.heroes
            guard list.indices.contains(c.index), list[c.index].weapon == .lightning else { continue }
            let f = list[c.index].magic.family
            out[c.id] = next[f, default: 0]
            next[f, default: 0] += 1
        }
    }
    return out
}()

extension Universe {
    /// The universe on show in this process: the app's choice, or the screen saver's for the trip it's on. In Clawd
    /// Royale, the universe of the place on show (for the menu bar icon, Status Symbols and the transitions).
    static var shown: Universe = .starWars
    /// Clawd Royale: everyone from every universe, each as themselves (`Roster`).
    static var mixed = false
}

extension Roster {
    /// Who's on show in this process.
    static var shown: Roster { Roster(.shown, mixed: Universe.mixed) }
}

extension Cast {
    func isNemesis(of other: Cast) -> Bool { universe == other.universe && Theme.of(universe).isNemesis(self, other) }
    var ride: Ride? { Theme.of(universe).ride(self) }
}

/// The ships that come to pick someone up (`Theme.ride`).
enum Ride {
    case falcon, quinjet, milano, javelin, batwing, tardis, sedan, helicopter, saucer, delorean, moonBike, mothership, jeep, eagle

    /// Drives in along the ground and away again instead of flying: the Files' sedan, Clawdberg's DeLorean and jeep.
    var drives: Bool { self == .sedan || self == .delorean || self == .jeep }
    /// How far left of centre (canvas pixels) whoever boards walks to: the ships' ramps 14, the TARDIS's door 6, the
    /// saucer's beam, the mothership's light and the moon bike right under their middles.
    var boardingOffset: CGFloat {
        switch self { case .tardis: return 6; case .saucer, .mothership, .moonBike: return 0; default: return 14 }
    }
}
