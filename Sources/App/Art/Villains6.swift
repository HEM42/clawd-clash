import Foundation

// Villains: the street and the mutant foes.

let villains6: [Leader: Persona] = [
    .morbius: Persona(name: "Morbius", weapon: .saber, motion: .fly,
                  draw: drawMorbius),
    .misterNegative: Persona(name: "Mister Negative", weapon: .lightning, magic: Magic(core: C(0x1E1E26), glow: C(0xF0F0F4), jagged: false),
                  draw: drawMisterNegative),
    .chameleon: Persona(name: "Chameleon", weapon: .blaster, shot: .bullet,
                  draw: drawChameleon),
    .tombstone: Persona(name: "Tombstone", weapon: .saber,
                  draw: drawTombstone),
    .misterSinister: Persona(name: "Mister Sinister", weapon: .lightning, magic: Magic(core: C(0xFFE0E0), glow: C(0xFF2A3A)),
                  draw: drawMisterSinister),
    .omegaRed: Persona(name: "Omega Red", weapon: .saber,
                  draw: drawOmegaRed),
    .toad: Persona(name: "Toad", weapon: .saber,
                  draw: drawToad),
    .pyro: Persona(name: "Pyro", weapon: .blaster, shot: .fire,
                  draw: drawPyro),
    .blob: Persona(name: "Blob", weapon: .saber, canSit: false,
                  draw: drawBlob),
]

/// Morbius.
private func drawMorbius(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xC8202A))
}

/// Mister Negative.
private func drawMisterNegative(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0x1E1E26))
}

/// Chameleon.
private func drawChameleon(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0x6A2A8A))
}

/// Tombstone.
private func drawTombstone(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0x2A2A30))
}

/// Mister Sinister.
private func drawMisterSinister(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A5A), trim: C(0xC8202A))
}

/// Omega Red.
private func drawOmegaRed(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0xB8BCC4))
}

/// Toad.
private func drawToad(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A7A3A), trim: C(0x8A6A3A))
}

/// Pyro.
private func drawPyro(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8902A), trim: C(0xC8202A))
}

/// Blob.
private func drawBlob(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C8A0), trim: C(0xE8C02A))
}
