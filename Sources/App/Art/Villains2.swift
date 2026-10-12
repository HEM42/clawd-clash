import Foundation

// Villains: Spider-Man's rogues.

let villains2: [Leader: Persona] = [
    .greenGoblin: Persona(name: "Green Goblin", weapon: .blaster, motion: .fly, shot: .thrown(C(0xFF8A1E)), callout: "Ha ha ha ha!",
                  draw: drawGreenGoblin),
    .venom: Persona(name: "Venom", weapon: .saber, callout: "We are Venom.",
                  draw: drawVenom),
    .carnage: Persona(name: "Carnage", weapon: .saber,
                  draw: drawCarnage),
    .docOck: Persona(name: "Doctor Octopus", weapon: .saber, armoured: true,
                  draw: drawDocOck),
    .mysterio: Persona(name: "Mysterio", weapon: .lightning, magic: Magic(core: C(0xE0FFE8), glow: C(0x4AE08A), jagged: false),
                  draw: drawMysterio),
    .electro: Persona(name: "Electro", weapon: .lightning, magic: Magic(core: C(0xFFFFE0), glow: C(0xFFE01E)),
                  draw: drawElectro),
    .vulture: Persona(name: "Vulture", weapon: .saber, motion: .fly,
                  draw: drawVulture),
    .rhino: Persona(name: "Rhino", weapon: .saber, armoured: true, canSit: false,
                  draw: drawRhino),
    .sandman: Persona(name: "Sandman", weapon: .saber,
                  draw: drawSandman),
    .lizard: Persona(name: "Lizard", weapon: .saber,
                  draw: drawLizard),
    .kraven: Persona(name: "Kraven", weapon: .saber,
                  draw: drawKraven),
]

/// Green Goblin.
private func drawGreenGoblin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0x6A2A8A))
}

/// Venom.
private func drawVenom(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1A1A22), trim: C(0xF0F0F4))
}

/// Carnage.
private func drawCarnage(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC01A1A), trim: C(0x1A1A22))
}

/// Doctor Octopus.
private func drawDocOck(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0xE8C02A))
}

/// Mysterio.
private func drawMysterio(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0x6A2A8A))
}

/// Electro.
private func drawElectro(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0xE8D02A))
}

/// Vulture.
private func drawVulture(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A6A3A), trim: C(0x8A8C94))
}

/// Rhino.
private func drawRhino(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A8C94), trim: C(0x5A5C64))
}

/// Sandman.
private func drawSandman(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A8A3A), trim: C(0xD8B878))
}

/// Lizard.
private func drawLizard(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x4A8A3A), trim: C(0xE8E8F0))
}

/// Kraven.
private func drawKraven(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD8A040), trim: C(0x8A5A2A))
}
