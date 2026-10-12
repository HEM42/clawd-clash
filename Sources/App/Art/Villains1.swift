import Foundation

// Villains: cosmic and Avengers foes.

let villains1: [Leader: Persona] = [
    .thanos: Persona(name: "Thanos", weapon: .lightning, magic: Magic(core: C(0xF4E0FF), glow: C(0xA040FF)), callout: "I am inevitable.",
                  draw: drawThanos),
    .loki: Persona(name: "Loki", weapon: .lightning, magic: Magic(core: C(0xE0FFE8), glow: C(0x3AD06A), jagged: false), callout: "I am burdened with glorious purpose.",
                  draw: drawLoki),
    .ultron: Persona(name: "Ultron", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFE0E0), glow: C(0xFF2A2A)), armoured: true, handGun: false,
                  draw: drawUltron),
    .redSkull: Persona(name: "Red Skull", weapon: .blaster, shot: .energy(core: C(0xE0F4FF), glow: C(0x3A9AFF)),
                  draw: drawRedSkull),
    .doctorDoom: Persona(name: "Doctor Doom", weapon: .lightning, magic: Magic(core: C(0xE0FFE0), glow: C(0x3AE05A)), armoured: true, callout: "Kneel before Doom!",
                  draw: drawDoctorDoom),
    .hela: Persona(name: "Hela", weapon: .saber,
                  draw: drawHela),
    .ronan: Persona(name: "Ronan", weapon: .saber,
                  draw: drawRonan),
    .nebula: Persona(name: "Nebula", weapon: .saber,
                  draw: drawNebula),
    .ebonyMaw: Persona(name: "Ebony Maw", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xF0F0FF), glow: C(0xA8A0FF), jagged: false),
                  draw: drawEbonyMaw),
    .chitauri: Persona(name: "Chitauri", weapon: .blaster, shot: .energy(core: C(0xE8F8FF), glow: C(0x5AC8FF)), armoured: true,
                  draw: drawChitauri),
    .grandmaster: Persona(name: "Grandmaster", callout: "Ha ha! Love it!",
                  draw: drawGrandmaster),
    .ultronSentry: Persona(name: "Ultron Sentry", weapon: .blaster, motion: .hover, shot: .energy(core: C(0xFFE0E0), glow: C(0xFF2A2A)), armoured: true, canSit: false, handGun: false,
                  draw: drawUltronSentry),
]

/// Thanos.
private func drawThanos(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x7A5A9A), trim: C(0xE8B530))
}

/// Loki.
private func drawLoki(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A6A3A), trim: C(0xE8B530))
}

/// Ultron.
private func drawUltron(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA8ACB8), trim: C(0xC8202A))
}

/// Red Skull.
private func drawRedSkull(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8302A), trim: C(0x3A4A3A))
}

/// Doctor Doom.
private func drawDoctorDoom(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A909C), trim: C(0x2A6A3A))
}

/// Hela.
private func drawHela(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E2A1E), trim: C(0x3AA05A))
}

/// Ronan.
private func drawRonan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0x3A4A8A))
}

/// Nebula.
private func drawNebula(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A5AA0), trim: C(0x2A2A34))
}

/// Ebony Maw.
private func drawEbonyMaw(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A8C94), trim: C(0x2A2A30))
}

/// Chitauri.
private func drawChitauri(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A6A5A), trim: C(0xA8A890))
}

/// Grandmaster.
private func drawGrandmaster(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD0A02A), trim: C(0x3A6AC8))
}

/// Ultron Sentry.
private func drawUltronSentry(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA8ACB8), trim: C(0xC8202A))
}
