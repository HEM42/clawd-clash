import Foundation

// Heroes: more X-Men and the Spider-heroes.

let heroes7: [Companion: Persona] = [
    .bishop: Persona(name: "Bishop", weapon: .blaster, shot: .energy(core: C(0xFFE8D0), glow: C(0xFF8A3A)),
                  draw: drawBishop),
    .cable: Persona(name: "Cable", weapon: .blaster, shot: .energy(core: C(0xE0F4FF), glow: C(0x3A9AFF)),
                  draw: drawCable),
    .havok: Persona(name: "Havok", weapon: .lightning, magic: Magic(core: C(0xFFFBD0), glow: C(0xFFE01E), jagged: false),
                  draw: drawHavok),
    .emmaFrost: Persona(name: "Emma Frost", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xC8E8FF), jagged: false), armoured: true,
                  draw: drawEmmaFrost),
    .banshee: Persona(name: "Banshee", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xF0FFF0), glow: C(0x8AE08A), jagged: false),
                  draw: drawBanshee),
    .angel: Persona(name: "Angel", weapon: .saber, motion: .fly,
                  draw: drawAngel),
    .domino: Persona(name: "Domino", weapon: .blaster, shot: .bullet,
                  draw: drawDomino),
    .x23: Persona(name: "X-23", weapon: .saber,
                  draw: drawX23),
    .milesMorales: Persona(name: "Miles Morales", weapon: .blaster, motion: .swing, shot: .web, handGun: false,
                  draw: drawMilesMorales),
    .spiderGwen: Persona(name: "Spider-Gwen", weapon: .blaster, motion: .swing, shot: .web, handGun: false,
                  draw: drawSpiderGwen),
]

/// Bishop.
private func drawBishop(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3A42), trim: C(0xE8B530))
}

/// Cable.
private func drawCable(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A4A6A), trim: C(0xB8BCC4))
}

/// Havok.
private func drawHavok(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xE8C02A))
}

/// Emma Frost.
private func drawEmmaFrost(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0xC8E8FF))
}

/// Banshee.
private func drawBanshee(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0xE8C02A))
}

/// Angel.
private func drawAngel(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xE8E8EC))
}

/// Domino.
private func drawDomino(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xF0F0F4))
}

/// X-23.
private func drawX23(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xE8C02A))
}

/// Miles Morales.
private func drawMilesMorales(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xC8202A))
}

/// Spider-Gwen.
private func drawSpiderGwen(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0xE84AA0))
}
