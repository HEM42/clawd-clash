import Foundation

let scenes5: [Location: Place] = [
    .madripoor: Place(name: "Madripoor", panel: 0x1E1418, still: Scenes.madripoor),
    .sokovia: Place(name: "Sokovia", panel: 0x1A1A1E, still: Scenes.sokovia),
    .worldship: Place(name: "Galactus' Worldship", panel: 0x1A1028, still: Scenes.worldship),
    .harlem: Place(name: "Harlem", panel: 0x1E1814, still: Scenes.harlem),
    .kunLun: Place(name: "K'un-Lun", panel: 0x1A2018, still: Scenes.kunLun),
]

extension Scenes {
    /// Madripoor.
    static func madripoor(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A1028), C(0x6A2A5A))
        c.ground(g, C(0x2A2A30), edge: C(0x2A2A30).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Sokovia.
    static func sokovia(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x4A5A6A), C(0xA8B0B8))
        c.ground(g, C(0x4A4A44), edge: C(0x4A4A44).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Galactus' Worldship.
    static func worldship(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x0A0418), C(0x4A2A8A))
        c.ground(g, C(0x3A2A5A), edge: C(0x3A2A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Harlem.
    static func harlem(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A4A7A), C(0xE8A070))
        c.ground(g, C(0x4A4440), edge: C(0x4A4440).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// K'un-Lun.
    static func kunLun(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x6A9AD0), C(0xF0E0C8))
        c.ground(g, C(0x8A7A5A), edge: C(0x8A7A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
