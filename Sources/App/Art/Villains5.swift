import Foundation

// Villains: cosmic powers and more of Spider-Man's rogues.

let villains5: [Leader: Persona] = [
    .galactus: Persona(name: "Galactus", weapon: .lightning, magic: Magic(core: C(0xF0E0FF), glow: C(0xA060FF), jagged: false), armoured: true, canSit: false, callout: "I hunger.",
                  draw: drawGalactus),
    .kang: Persona(name: "Kang", weapon: .blaster, shot: .energy(core: C(0xF0E0FF), glow: C(0xA04AFF)),
                  draw: drawKang),
    .mephisto: Persona(name: "Mephisto", weapon: .lightning, magic: Magic(core: C(0xFFE0D0), glow: C(0xFF3A1E)),
                  draw: drawMephisto),
    .knull: Persona(name: "Knull", weapon: .saber,
                  draw: drawKnull),
    .annihilus: Persona(name: "Annihilus", weapon: .lightning, magic: Magic(core: C(0xF0FFE0), glow: C(0x8AE04A)), armoured: true,
                  draw: drawAnnihilus),
    .highEvolutionary: Persona(name: "High Evolutionary", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xF0E8FF), glow: C(0xC88AFF), jagged: false),
                  draw: drawHighEvolutionary),
    .morganLeFay: Persona(name: "Morgan le Fay", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xE0FFE8), glow: C(0x3AD06A), jagged: false),
                  draw: drawMorganLeFay),
    .scorpion: Persona(name: "Scorpion", weapon: .saber, armoured: true,
                  draw: drawScorpion),
    .shocker: Persona(name: "Shocker", weapon: .blaster, shot: .beam(core: C(0xF0F8FF), glow: C(0x8AC8FF)), handGun: false,
                  draw: drawShocker),
    .hobgoblin: Persona(name: "Hobgoblin", weapon: .blaster, motion: .fly, shot: .thrown(C(0xFF8A1E)), callout: "Ha ha ha!",
                  draw: drawHobgoblin),
]

/// Galactus.
private func drawGalactus(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A3A9A), trim: C(0x3A9A4A))
}

/// Kang.
private func drawKang(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A9A3A), trim: C(0x6A2A8A))
}

/// Mephisto.
private func drawMephisto(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0x1E1E26))
}

/// Knull.
private func drawKnull(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xF0F0F4))
}

/// Annihilus.
private func drawAnnihilus(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0xC8A02A))
}

/// High Evolutionary.
private func drawHighEvolutionary(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A2A9A), trim: C(0xE8E8EC))
}

/// Morgan le Fay.
private func drawMorganLeFay(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A6A3A), trim: C(0xE8B530))
}

/// Scorpion.
private func drawScorpion(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0xE8C02A))
}

/// Shocker.
private func drawShocker(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0x8A5A2A))
}

/// Hobgoblin.
private func drawHobgoblin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8902A), trim: C(0x3A2A8A))
}
