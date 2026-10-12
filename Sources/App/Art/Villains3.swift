import Foundation

// Villains: mutants, monsters and machines.

let villains3: [Leader: Persona] = [
    .magneto: Persona(name: "Magneto", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE8FF), glow: C(0xC83AE0), jagged: false),
                  draw: drawMagneto),
    .juggernaut: Persona(name: "Juggernaut", weapon: .saber, armoured: true, canSit: false, callout: "I\'m the Juggernaut!",
                  draw: drawJuggernaut),
    .sabretooth: Persona(name: "Sabretooth", weapon: .saber,
                  draw: drawSabretooth),
    .mystique: Persona(name: "Mystique", weapon: .saber,
                  draw: drawMystique),
    .apocalypse: Persona(name: "Apocalypse", weapon: .saber,
                  draw: drawApocalypse),
    .sentinel: Persona(name: "Sentinel", weapon: .blaster, shot: .beam(core: C(0xFFE0E0), glow: C(0xFF3A3A)), armoured: true, canSit: false, handGun: false,
                  draw: drawSentinel),
    .abomination: Persona(name: "Abomination", weapon: .saber,
                  draw: drawAbomination),
    .finFangFoom: Persona(name: "Fin Fang Foom", weapon: .blaster, shot: .fire, canSit: false, handGun: false,
                  draw: drawFinFangFoom),
    .modok: Persona(name: "MODOK", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFF6C0), glow: C(0xFFB01E), jagged: false), canSit: false,
                  draw: drawModok),
    .dormammu: Persona(name: "Dormammu", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE8B0), glow: C(0xFF6A1E)), canSit: false,
                  draw: drawDormammu),
    .doombot: Persona(name: "Doombot", weapon: .blaster, shot: .energy(core: C(0xE0FFE0), glow: C(0x3AE05A)), armoured: true,
                  draw: drawDoombot),
]

/// Magneto.
private func drawMagneto(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA01A3A), trim: C(0x6A2A8A))
}

/// Juggernaut.
private func drawJuggernaut(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A5A3A), trim: C(0x6A6E78))
}

/// Sabretooth.
private func drawSabretooth(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A6A3A), trim: C(0xE8D8A0))
}

/// Mystique.
private func drawMystique(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A5AC8), trim: C(0xE8E8F0))
}

/// Apocalypse.
private func drawApocalypse(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A4ABA), trim: C(0x8A8C94))
}

/// Sentinel.
private func drawSentinel(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A3AA0), trim: C(0xB8BCC8))
}

/// Abomination.
private func drawAbomination(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A7A4A), trim: C(0x3A4A2A))
}

/// Fin Fang Foom.
private func drawFinFangFoom(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A9A4A), trim: C(0x8A3A9A))
}

/// MODOK.
private func drawModok(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C0A0), trim: C(0xE8C02A))
}

/// Dormammu.
private func drawDormammu(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0xFF8A1E))
}

/// Doombot.
private func drawDoombot(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A909C), trim: C(0x2A6A3A))
}
