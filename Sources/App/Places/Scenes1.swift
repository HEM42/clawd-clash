import Foundation

let scenes1: [Location: Place] = [
    .avengersTower: Place(name: "Avengers Tower", panel: 0x1A1E2A, still: Scenes.avengersTower),
    .sanctum: Place(name: "Sanctum Sanctorum", panel: 0x241A14, still: Scenes.sanctum),
    .wakanda: Place(name: "Wakanda", panel: 0x14231A, still: Scenes.wakanda),
    .asgard: Place(name: "Asgard", panel: 0x1A1A24, still: Scenes.asgard),
    .sakaar: Place(name: "Sakaar", panel: 0x2A1A14, still: Scenes.sakaar),
    .knowhere: Place(name: "Knowhere", panel: 0x16141E, still: Scenes.knowhere),
    .titan: Place(name: "Titan", panel: 0x2A1A12, still: Scenes.titan),
]

extension Scenes {
    /// Avengers Tower.
    static func avengersTower(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A))
        c.ground(g, C(0x3A3E4A), edge: C(0x3A3E4A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Sanctum Sanctorum.
    static func sanctum(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A2A1E), C(0x6A4A2A))
        c.ground(g, C(0x4A3626), edge: C(0x4A3626).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Wakanda.
    static func wakanda(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xE8A060), C(0xFFD8A0))
        c.ground(g, C(0x5A4A3A), edge: C(0x5A4A3A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Asgard.
    static func asgard(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A4A8A), C(0xE8C870))
        c.ground(g, C(0x8A7A5A), edge: C(0x8A7A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Sakaar.
    static func sakaar(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xC86A3A), C(0xF0C080))
        c.ground(g, C(0x6A4A3A), edge: C(0x6A4A3A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Knowhere.
    static func knowhere(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A1030), C(0x4A2A6A))
        c.ground(g, C(0x4A4448), edge: C(0x4A4448).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Titan.
    static func titan(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xC86A2A), C(0xE8A060))
        c.ground(g, C(0x7A4A2A), edge: C(0x7A4A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
