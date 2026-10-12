import Foundation

// Heroes: the X-Men.

let heroes3: [Companion: Persona] = [
    .wolverine: Persona(name: "Wolverine", weapon: .saber,
                  draw: drawWolverine),
    .cyclops: Persona(name: "Cyclops", weapon: .blaster, shot: .beam(core: C(0xFFE0E0), glow: C(0xFF2A3A)), handGun: false,
                  draw: drawCyclops),
    .storm: Persona(name: "Storm", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xFFFFFF), glow: C(0x8AC8FF)),
                  draw: drawStorm),
    .jeanGrey: Persona(name: "Jean Grey", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE0F4), glow: C(0xFF4AC8), jagged: false),
                  draw: drawJeanGrey),
    .professorX: Persona(name: "Professor X", motion: .hover, canSit: false,
                  draw: drawProfessorX),
    .beast: Persona(name: "Beast", weapon: .saber,
                  draw: drawBeast),
    .nightcrawler: Persona(name: "Nightcrawler", weapon: .saber,
                  draw: drawNightcrawler),
    .gambit: Persona(name: "Gambit", weapon: .blaster, shot: .card,
                  draw: drawGambit),
    .rogue: Persona(name: "Rogue", weapon: .saber, motion: .fly,
                  draw: drawRogue),
    .iceman: Persona(name: "Iceman", weapon: .blaster, motion: .fly, shot: .ice, handGun: false,
                  draw: drawIceman),
    .colossus: Persona(name: "Colossus", weapon: .saber, armoured: true,
                  draw: drawColossus),
]

/// Wolverine.
private func drawWolverine(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0x2A4FB0))
}

/// Cyclops.
private func drawCyclops(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A7A), trim: C(0xE8C02A))
}

/// Storm.
private func drawStorm(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A34), trim: C(0xE8E8F0))
}

/// Jean Grey.
private func drawJeanGrey(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A9A3A), trim: C(0xE8C02A))
}

/// Professor X.
private func drawProfessorX(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A6A), trim: C(0xE8C8A8))
}

/// Beast.
private func drawBeast(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A4ABA), trim: C(0x2A2A34))
}

/// Nightcrawler.
private func drawNightcrawler(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A5A), trim: C(0xC8202A))
}

/// Gambit.
private func drawGambit(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A4A3A), trim: C(0xD04A9A))
}

/// Rogue.
private func drawRogue(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0xE8C02A))
}

/// Iceman.
private func drawIceman(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA8E0F8), trim: C(0x6AB8E0))
}

/// Colossus.
private func drawColossus(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xB8BCC8), trim: C(0xC8202A))
}
