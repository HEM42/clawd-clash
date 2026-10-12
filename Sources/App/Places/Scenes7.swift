import Foundation

let scenes7: [Location: Place] = [
    .newYorkStreets: Place(name: "New York City", panel: 0x1A1E2A, still: Scenes.newYorkStreets),
    .savageLandCitadel: Place(name: "Savage Land Citadel", panel: 0x1A1E1A, still: Scenes.savageLandCitadel),
    .starkWorkshop: Place(name: "Tony Stark's Workshop", panel: 0x14181E, still: Scenes.starkWorkshop),
    .redRoom: Place(name: "The Red Room", panel: 0x1E1414, still: Scenes.redRoom),
    .taLo: Place(name: "Ta Lo", panel: 0x14201A, still: Scenes.taLo),
]

extension Scenes {
    /// New York City.
    static func newYorkStreets(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x4A8AD0), C(0xC8E0F8))
        c.ground(g, C(0x3A3A40), edge: C(0x3A3A40).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Savage Land Citadel.
    static func savageLandCitadel(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x5A8AA0), C(0xE8E0C0))
        c.ground(g, C(0x5A5A50), edge: C(0x5A5A50).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Tony Stark's Workshop.
    static func starkWorkshop(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A1E26), C(0x3A4A5A))
        c.ground(g, C(0x3A3E44), edge: C(0x3A3E44).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// The Red Room.
    static func redRoom(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A1414), C(0x6A2A2A))
        c.ground(g, C(0x3A2A2A), edge: C(0x3A2A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Ta Lo.
    static func taLo(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x6A9AC8), C(0xE8F0D8))
        c.ground(g, C(0x5A7A4A), edge: C(0x5A7A4A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
