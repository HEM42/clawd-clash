import Foundation

// Star Wars heroes: Grogu to Kuiil.

let starWarsHeroes3: [SWHero: Persona] = [
    .grogu: Persona(name: "Grogu", canSit: false, headTop: 23, signature: 3.2,
                  draw: drawGrogu),
    .babuFrik: Persona(name: "Babu Frik", canSit: false, headTop: 16,
                  draw: drawBabuFrik),
    .mando: Persona(name: "The Mandalorian", weapon: .blaster, muzzle: (58, 32), headTop: 19,
                  draw: drawMando),
    .k2so: Persona(name: "K-2SO", weapon: .blaster, muzzle: (52, 32), headTop: 14,
                  draw: drawK2so),
    .gonk: Persona(name: "GNK Power Droid", canSit: false, headTop: 23,
                  draw: drawGonk),
    .cassian: Persona(name: "Cassian Andor", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawCassian),
    .bix: Persona(name: "Bix Caleen", headTop: 19,
                  draw: drawBix),
    .cobbVanth: Persona(name: "Cobb Vanth", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawCobbVanth),
    .pitDroid: Persona(name: "Pit Droid", canSit: false, headTop: 16,
                  draw: drawPitDroid),
    .kuiil: Persona(name: "Kuiil", weapon: .blaster, canSit: false, muzzle: (50, 18), headTop: 7, callout: "I have spoken.",
                  draw: drawKuiil),
]

/// Grogu.
private func drawGrogu(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Babu Frik.
private func drawBabuFrik(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// The Mandalorian.
private func drawMando(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// K-2SO.
private func drawK2so(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// GNK Power Droid.
private func drawGonk(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Cassian Andor.
private func drawCassian(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Bix Caleen.
private func drawBix(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Cobb Vanth.
private func drawCobbVanth(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Pit Droid.
private func drawPitDroid(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Kuiil.
private func drawKuiil(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}
