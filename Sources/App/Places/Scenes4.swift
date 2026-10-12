import Foundation

let scenes4: [Location: Place] = [
    .baxterBuilding: Place(name: "Baxter Building", panel: 0x1A1E2A, still: Scenes.baxterBuilding),
    .jotunheim: Place(name: "Jotunheim", panel: 0x161C24, still: Scenes.jotunheim),
    .muspelheim: Place(name: "Muspelheim", panel: 0x2A1410, still: Scenes.muspelheim),
    .hala: Place(name: "Hala", panel: 0x161A2A, still: Scenes.hala),
    .genosha: Place(name: "Genosha", panel: 0x1A1E1A, still: Scenes.genosha),
]

extension Scenes {
    /// Baxter Building.
    static func baxterBuilding(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A6AB0), C(0xA8D0F0))
        c.ground(g, C(0x4A4E58), edge: C(0x4A4E58).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Jotunheim.
    static func jotunheim(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A3A5A), C(0x8AA8C8))
        c.ground(g, C(0x8AA0B8), edge: C(0x8AA0B8).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Muspelheim.
    static func muspelheim(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A1410), C(0xC8401E))
        c.ground(g, C(0x3A2420), edge: C(0x3A2420).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Hala.
    static func hala(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A2A5A), C(0x4A8AD0))
        c.ground(g, C(0x4A4E58), edge: C(0x4A4E58).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Genosha.
    static func genosha(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x6A9AD0), C(0xE8E0C8))
        c.ground(g, C(0x6A6A5A), edge: C(0x6A6A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
