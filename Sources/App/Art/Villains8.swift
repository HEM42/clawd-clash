import Foundation

// Villains: gamma, Asgard's enemies and foot soldiers.

let villains8: [Leader: Persona] = [
    .countNefaria: Persona(name: "Count Nefaria", weapon: .blaster, shot: .energy(core: C(0xFFE0E0), glow: C(0xFF4A2A)), handGun: false,
                  draw: drawCountNefaria),
    .theLeader: Persona(name: "The Leader", weapon: .lightning, magic: Magic(core: C(0xF0FFE0), glow: C(0x8AE04A), jagged: false),
                  draw: drawTheLeader),
    .maestro: Persona(name: "Maestro", weapon: .saber,
                  draw: drawMaestro),
    .malekith: Persona(name: "Malekith", weapon: .lightning, magic: Magic(core: C(0xF0F0FF), glow: C(0x6A6AFF)),
                  draw: drawMalekith),
    .surtur: Persona(name: "Surtur", weapon: .saber, armoured: true, canSit: false, callout: "I am Ragnarok.",
                  draw: drawSurtur),
    .kurse: Persona(name: "Kurse", weapon: .saber, armoured: true,
                  draw: drawKurse),
    .frostGiant: Persona(name: "Frost Giant", weapon: .saber, canSit: false,
                  draw: drawFrostGiant),
    .hydraSuperSoldier: Persona(name: "Hydra Super Soldier", weapon: .saber,
                  draw: drawHydraSuperSoldier),
    .kreeSoldier: Persona(name: "Kree Soldier", weapon: .blaster, shot: .energy(core: C(0xE0F4FF), glow: C(0x3A9AFF)),
                  draw: drawKreeSoldier),
]

/// Count Nefaria.
private func drawCountNefaria(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xC8202A))
}

/// The Leader.
private func drawTheLeader(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AA03A), trim: C(0x6A2A8A))
}

/// Maestro.
private func drawMaestro(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AA03A), trim: C(0x1E1E26))
}

/// Malekith.
private func drawMalekith(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0x1E1E26))
}

/// Surtur.
private func drawSurtur(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A2A2A), trim: C(0xFF6A1E))
}

/// Kurse.
private func drawKurse(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A5A64), trim: C(0xC8202A))
}

/// Frost Giant.
private func drawFrostGiant(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A8AC8), trim: C(0x2A3A6A))
}

/// Hydra Super Soldier.
private func drawHydraSuperSoldier(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xC8202A))
}

/// Kree Soldier.
private func drawKreeSoldier(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0x2A3A8A))
}
