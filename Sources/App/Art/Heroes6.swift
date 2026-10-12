import Foundation

// Heroes: Kamar-Taj, the cosmos and the younger X-Men.

let heroes6: [Companion: Persona] = [
    .wong: Persona(name: "Wong", weapon: .lightning, magic: Magic(core: C(0xFFE8B0), glow: C(0xFF8A1E), jagged: false),
                  draw: drawWong),
    .hercules: Persona(name: "Hercules", weapon: .saber,
                  draw: drawHercules),
    .sentry: Persona(name: "Sentry", weapon: .saber, motion: .fly,
                  draw: drawSentry),
    .cosmo: Persona(name: "Cosmo", weapon: .lightning, magic: Magic(core: C(0xF0E8FF), glow: C(0xA08AFF), jagged: false),
                  draw: drawCosmo),
    .kraglin: Persona(name: "Kraglin", weapon: .blaster, shot: .energy(core: C(0xFFE0E0), glow: C(0xFF4A2A)),
                  draw: drawKraglin),
    .adamWarlock: Persona(name: "Adam Warlock", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xFFF6D0), glow: C(0xFFC81E), jagged: false),
                  draw: drawAdamWarlock),
    .nova: Persona(name: "Nova", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFF6D0), glow: C(0xFFC81E)), handGun: false,
                  draw: drawNova),
    .kittyPryde: Persona(name: "Kitty Pryde", weapon: .saber,
                  draw: drawKittyPryde),
    .jubilee: Persona(name: "Jubilee", weapon: .blaster, shot: .energy(core: C(0xFFF0FF), glow: C(0xFF5AC8)), handGun: false,
                  draw: drawJubilee),
    .psylocke: Persona(name: "Psylocke", weapon: .saber,
                  draw: drawPsylocke),
]

/// Wong.
private func drawWong(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A3A2A), trim: C(0xE8B530))
}

/// Hercules.
private func drawHercules(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C8A0), trim: C(0x8A5A2A))
}

/// Sentry.
private func drawSentry(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0x2A3A8A))
}

/// Cosmo.
private func drawCosmo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8A060), trim: C(0xC8202A))
}

/// Kraglin.
private func drawKraglin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A3A2A), trim: C(0x3A3A42))
}

/// Adam Warlock.
private func drawAdamWarlock(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8B530), trim: C(0xC8202A))
}

/// Nova.
private func drawNova(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xE8C02A))
}

/// Kitty Pryde.
private func drawKittyPryde(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6AB0), trim: C(0xE8C02A))
}

/// Jubilee.
private func drawJubilee(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0xC8202A))
}

/// Psylocke.
private func drawPsylocke(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3AA0), trim: C(0xC8202A))
}
