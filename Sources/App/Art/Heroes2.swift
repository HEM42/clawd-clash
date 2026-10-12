import Foundation

// Heroes: more Avengers and the Guardians of the Galaxy.

let heroes2: [Companion: Persona] = [
    .antMan: Persona(name: "Ant-Man", weapon: .saber,
                  draw: drawAntMan),
    .wasp: Persona(name: "Wasp", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFFBD0), glow: C(0xFFC81E)), handGun: false,
                  draw: drawWasp),
    .falcon: Persona(name: "Falcon", weapon: .blaster, motion: .fly, shot: .bullet,
                  draw: drawFalcon),
    .winterSoldier: Persona(name: "Winter Soldier", weapon: .blaster, shot: .bullet,
                  draw: drawWinterSoldier),
    .starLord: Persona(name: "Star-Lord", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFE8C0), glow: C(0xFF6A2A)),
                  draw: drawStarLord),
    .gamora: Persona(name: "Gamora", weapon: .saber,
                  draw: drawGamora),
    .drax: Persona(name: "Drax", weapon: .saber,
                  draw: drawDrax),
    .rocket: Persona(name: "Rocket", weapon: .blaster, shot: .energy(core: C(0xF0E0FF), glow: C(0x9A4AFF)),
                  draw: drawRocket),
    .groot: Persona(name: "Groot", weapon: .saber, callout: "I am Groot.",
                  draw: drawGroot),
    .mantis: Persona(name: "Mantis",
                  draw: drawMantis),
    .nickFury: Persona(name: "Nick Fury", weapon: .blaster, shot: .bullet,
                  draw: drawNickFury),
    .sheHulk: Persona(name: "She-Hulk", weapon: .saber,
                  draw: drawSheHulk),
]

/// Ant-Man.
private func drawAntMan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xB02A2A), trim: C(0x2A2A30))
}

/// Wasp.
private func drawWasp(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xE8C02A))
}

/// Falcon.
private func drawFalcon(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A6E78), trim: C(0xC8202A))
}

/// Winter Soldier.
private func drawWinterSoldier(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xB8BCC4))
}

/// Star-Lord.
private func drawStarLord(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A3A2A), trim: C(0x3A3A42))
}

/// Gamora.
private func drawGamora(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AA05A), trim: C(0x2A2A30))
}

/// Drax.
private func drawDrax(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A9AA0), trim: C(0xB02A2A))
}

/// Rocket.
private func drawRocket(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A5A3A), trim: C(0x2A3A6A))
}

/// Groot.
private func drawGroot(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x7A5A3A), trim: C(0x5A3A22))
}

/// Mantis.
private func drawMantis(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0xE8DCA0))
}

/// Nick Fury.
private func drawNickFury(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E24), trim: C(0x3A2A1E))
}

/// She-Hulk.
private func drawSheHulk(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AB04A), trim: C(0x6A3A8A))
}
