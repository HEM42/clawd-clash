import Foundation

// Villains: the TVA, the Morlock Tunnels, Asteroid M, Ta Lo and the Red Room.

let villains9: [Leader: Persona] = [
    .missMinutes: Persona(name: "Miss Minutes", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFF0D0), glow: C(0xFF9A1E), jagged: false), canSit: false, callout: "Hey y'all!",
                  draw: drawMissMinutes),
    .callisto: Persona(name: "Callisto", weapon: .saber,
                  draw: drawCallisto),
    .exodus: Persona(name: "Exodus", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE0F0), glow: C(0xE84A9A), jagged: false),
                  draw: drawExodus),
    .soulEater: Persona(name: "Soul Eater", weapon: .saber, motion: .fly, canSit: false,
                  draw: drawSoulEater),
    .redRoomWidow: Persona(name: "Red Room Widow", weapon: .blaster, shot: .bullet,
                  draw: drawRedRoomWidow),
]

/// Miss Minutes.
private func drawMissMinutes(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xFF9A1E), trim: C(0xFFE0A0))
}

/// Callisto.
private func drawCallisto(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0x8A5A3A))
}

/// Exodus.
private func drawExodus(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A1A3A), trim: C(0xE8B530))
}

/// Soul Eater.
private func drawSoulEater(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0x8A2A3A))
}

/// Red Room Widow.
private func drawRedRoomWidow(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xC8202A))
}
