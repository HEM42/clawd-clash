import Foundation

// Villains: aliens, Avengers foes and sorcerers.

let villains7: [Leader: Persona] = [
    .brood: Persona(name: "Brood", weapon: .saber,
                  draw: drawBrood),
    .cassandraNova: Persona(name: "Cassandra Nova", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE0F0), glow: C(0xE84AA0), jagged: false),
                  draw: drawCassandraNova),
    .graviton: Persona(name: "Graviton", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xF0E0FF), glow: C(0x8A4AFF), jagged: false),
                  draw: drawGraviton),
    .absorbingMan: Persona(name: "Absorbing Man", weapon: .saber, armoured: true,
                  draw: drawAbsorbingMan),
    .crimsonDynamo: Persona(name: "Crimson Dynamo", weapon: .blaster, shot: .energy(core: C(0xFFE0E0), glow: C(0xFF2A2A)), armoured: true, canSit: false, handGun: false,
                  draw: drawCrimsonDynamo),
    .wrecker: Persona(name: "Wrecker", weapon: .saber,
                  draw: drawWrecker),
    .baronMordo: Persona(name: "Baron Mordo", weapon: .lightning, magic: Magic(core: C(0xE0FFE0), glow: C(0x3AE05A)),
                  draw: drawBaronMordo),
    .enchantress: Persona(name: "Enchantress", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xE0FFE8), glow: C(0x3AD06A), jagged: false),
                  draw: drawEnchantress),
    .arnimZola: Persona(name: "Arnim Zola", weapon: .blaster, shot: .energy(core: C(0xE0FFE0), glow: C(0x3AE05A)), armoured: true, handGun: false,
                  draw: drawArnimZola),
]

/// Brood.
private func drawBrood(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3A4A), trim: C(0x8A9A3A))
}

/// Cassandra Nova.
private func drawCassandraNova(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A9A3A), trim: C(0x1E1E26))
}

/// Graviton.
private func drawGraviton(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xA040FF))
}

/// Absorbing Man.
private func drawAbsorbingMan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A8C94), trim: C(0x5A5C64))
}

/// Crimson Dynamo.
private func drawCrimsonDynamo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0x6A6E78))
}

/// Wrecker.
private func drawWrecker(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0x6A2A8A))
}

/// Baron Mordo.
private func drawBaronMordo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0xE8B530))
}

/// Enchantress.
private func drawEnchantress(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A9A3A), trim: C(0xE8C02A))
}

/// Arnim Zola.
private func drawArnimZola(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A3A), trim: C(0x3A6A3A))
}
