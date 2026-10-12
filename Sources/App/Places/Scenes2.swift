import Foundation

let scenes2: [Location: Place] = [
    .helicarrier: Place(name: "S.H.I.E.L.D. Helicarrier", panel: 0x16181D, still: Scenes.helicarrier),
    .xMansion: Place(name: "Xavier's School", panel: 0x14231A, still: Scenes.xMansion),
    .hellsKitchen: Place(name: "Hell's Kitchen", panel: 0x1A1418, still: Scenes.hellsKitchen),
    .vormir: Place(name: "Vormir", panel: 0x161A22, still: Scenes.vormir),
    .quantumRealm: Place(name: "Quantum Realm", panel: 0x1E1028, still: Scenes.quantumRealm),
    .latveria: Place(name: "Latveria", panel: 0x1A1E1A, still: Scenes.latveria),
    .hydraBase: Place(name: "Hydra Base", panel: 0x1A1414, still: Scenes.hydraBase),
    .dailyBugle: Place(name: "Daily Bugle", panel: 0x1A1E2A, still: Scenes.dailyBugle),
]

extension Scenes {
    /// S.H.I.E.L.D. Helicarrier.
    static func helicarrier(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A6AB0), C(0xA8D0F0))
        c.ground(g, C(0x4A4E58), edge: C(0x4A4E58).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Xavier's School.
    static func xMansion(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A6AB0), C(0xA8D0F0))
        c.ground(g, C(0x3A5A2A), edge: C(0x3A5A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Hell's Kitchen.
    static func hellsKitchen(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A1428), C(0x3A2A4A))
        c.ground(g, C(0x2A2A30), edge: C(0x2A2A30).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Vormir.
    static func vormir(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A2440), C(0x6A7AA0))
        c.ground(g, C(0x3A3E48), edge: C(0x3A3E48).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Quantum Realm.
    static func quantumRealm(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A0A30), C(0xC83AE0))
        c.ground(g, C(0x3A1A4A), edge: C(0x3A1A4A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Latveria.
    static func latveria(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A4A5A), C(0x8A9AA8))
        c.ground(g, C(0x3A4A3A), edge: C(0x3A4A3A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Hydra Base.
    static func hydraBase(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A2A30), C(0x4A4A52))
        c.ground(g, C(0x3A3A40), edge: C(0x3A3A40).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Daily Bugle.
    static func dailyBugle(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x4A8AD0), C(0xB8E0F8))
        c.ground(g, C(0x4A4E58), edge: C(0x4A4E58).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
