import Foundation

let scenes3: [Location: Place] = [
    .egosPlanet: Place(name: "Ego's Planet", panel: 0x1E2416, still: Scenes.egosPlanet),
    .kamarTaj: Place(name: "Kamar-Taj", panel: 0x241C14, still: Scenes.kamarTaj),
    .raft: Place(name: "The Raft", panel: 0x16181D, still: Scenes.raft),
    .battleOfNewYork: Place(name: "Battle of New York", panel: 0x1E1814, still: Scenes.battleOfNewYork),
    .darkDimension: Place(name: "Dark Dimension", panel: 0x1E0A24, still: Scenes.darkDimension),
    .attilan: Place(name: "Attilan", panel: 0x1A1E2A, still: Scenes.attilan),
    .savageLand: Place(name: "Savage Land", panel: 0x14231A, still: Scenes.savageLand),
]

extension Scenes {
    /// Ego's Planet.
    static func egosPlanet(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x5AA0D0), C(0xE8F0C0))
        c.ground(g, C(0x6A8A3A), edge: C(0x6A8A3A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Kamar-Taj.
    static func kamarTaj(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x6A9AD0), C(0xE8E0C8))
        c.ground(g, C(0x8A7A5A), edge: C(0x8A7A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// The Raft.
    static func raft(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A3A5A), C(0x6A8AA8))
        c.ground(g, C(0x3A4048), edge: C(0x3A4048).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Battle of New York.
    static func battleOfNewYork(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A4A6A), C(0xC8A080))
        c.ground(g, C(0x4A4440), edge: C(0x4A4440).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Dark Dimension.
    static func darkDimension(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x0A0418), C(0x6A1A8A))
        c.ground(g, C(0x2A1030), edge: C(0x2A1030).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Attilan.
    static func attilan(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A2A4A), C(0x8AA8D0))
        c.ground(g, C(0x6A6E7A), edge: C(0x6A6E7A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Savage Land.
    static func savageLand(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x5AA0D0), C(0xE8F0C0))
        c.ground(g, C(0x4A6A2A), edge: C(0x4A6A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
