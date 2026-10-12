import Foundation

// Villains: the street, spies and soldiers.

let villains4: [Leader: Persona] = [
    .kingpin: Persona(name: "Kingpin", weapon: .saber,
                  draw: drawKingpin),
    .bullseye: Persona(name: "Bullseye", weapon: .blaster, shot: .thrown(C(0xC8CCD4)),
                  draw: drawBullseye),
    .handNinja: Persona(name: "Hand Ninja", weapon: .saber,
                  draw: drawHandNinja),
    .hydraAgent: Persona(name: "Hydra Agent", weapon: .blaster, shot: .energy(core: C(0xE0F4FF), glow: C(0x3A9AFF)), callout: "Hail Hydra!",
                  draw: drawHydraAgent),
    .aimAgent: Persona(name: "A.I.M. Agent", weapon: .blaster, shot: .energy(core: C(0xFFFBD0), glow: C(0xFFD21E)),
                  draw: drawAimAgent),
    .skrull: Persona(name: "Skrull", weapon: .blaster, shot: .energy(core: C(0xE0FFE0), glow: C(0x3AE05A)),
                  draw: drawSkrull),
    .taskmaster: Persona(name: "Taskmaster", weapon: .saber,
                  draw: drawTaskmaster),
    .zemo: Persona(name: "Baron Zemo", weapon: .blaster, shot: .bullet,
                  draw: drawZemo),
    .whiplash: Persona(name: "Whiplash", weapon: .saber,
                  draw: drawWhiplash),
    .mandarin: Persona(name: "Mandarin", weapon: .lightning, magic: Magic(core: C(0xFFF0E0), glow: C(0xFF5A3A)),
                  draw: drawMandarin),
    .killmonger: Persona(name: "Killmonger", weapon: .saber, armoured: true,
                  draw: drawKillmonger),
    .batroc: Persona(name: "Batroc", weapon: .saber,
                  draw: drawBatroc),
]

/// Kingpin.
private func drawKingpin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8E8EC), trim: C(0x5A3A6A))
}

/// Bullseye.
private func drawBullseye(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xE8E8EC))
}

/// Hand Ninja.
private func drawHandNinja(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA01A1A), trim: C(0x2A1A1A))
}

/// Hydra Agent.
private func drawHydraAgent(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A2A), trim: C(0xC8202A))
}

/// A.I.M. Agent.
private func drawAimAgent(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0x3A3A30))
}

/// Skrull.
private func drawSkrull(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A9A3A), trim: C(0x6A2A8A))
}

/// Taskmaster.
private func drawTaskmaster(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A6A), trim: C(0xE8E8EC))
}

/// Baron Zemo.
private func drawZemo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A6A), trim: C(0xE8C02A))
}

/// Whiplash.
private func drawWhiplash(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A6E78), trim: C(0x3AAAFF))
}

/// Mandarin.
private func drawMandarin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A6A3A), trim: C(0xE8B530))
}

/// Killmonger.
private func drawKillmonger(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xE8B530))
}

/// Batroc.
private func drawBatroc(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0xE8C02A))
}
