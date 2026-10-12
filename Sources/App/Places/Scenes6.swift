import Foundation

let scenes6: [Location: Place] = [
    .xandar: Place(name: "Xandar", panel: 0x161E2A, still: Scenes.xandar),
    .avengersCompound: Place(name: "Avengers Compound", panel: 0x16201A, still: Scenes.avengersCompound),
    .tva: Place(name: "Time Variance Authority", panel: 0x221A12, still: Scenes.tva),
    .krakoa: Place(name: "Krakoa", panel: 0x142016, still: Scenes.krakoa),
    .morlockTunnels: Place(name: "Morlock Tunnels", panel: 0x141410, still: Scenes.morlockTunnels),
    .asteroidM: Place(name: "Asteroid M", panel: 0x161420, still: Scenes.asteroidM),
]

extension Scenes {
    /// Xandar.
    static func xandar(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A6AC8), C(0xC8E0F8))
        c.ground(g, C(0x8A8A90), edge: C(0x8A8A90).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Avengers Compound.
    static func avengersCompound(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x5A8AC8), C(0xD8E8F0))
        c.ground(g, C(0x5A6A4A), edge: C(0x5A6A4A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Time Variance Authority.
    static func tva(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A2A1A), C(0x8A6A3A))
        c.ground(g, C(0x4A3A2A), edge: C(0x4A3A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Krakoa.
    static func krakoa(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A6A9A), C(0xA8D0B0))
        c.ground(g, C(0x3A5A2A), edge: C(0x3A5A2A).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Morlock Tunnels.
    static func morlockTunnels(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A1A14), C(0x3A3A2A))
        c.ground(g, C(0x2A2A22), edge: C(0x2A2A22).alpha(0.6), speck: C(0x000000, 0.15))
    }

    /// Asteroid M.
    static func asteroidM(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x0A0818), C(0x3A2A5A))
        c.ground(g, C(0x5A4A5A), edge: C(0x5A4A5A).alpha(0.6), speck: C(0x000000, 0.15))
    }

}
