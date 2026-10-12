import Foundation

// Star Wars heroes: the originals.

let starWarsHeroes1: [SWHero: Persona] = [
    .luke: Persona(name: "Luke Skywalker", weapon: .saber, headTop: 21, signature: 2.6,
                  draw: drawLuke),
    .han: Persona(name: "Han Solo", weapon: .blaster, muzzle: (53, 32), headTop: 22, signature: 3,
                  draw: drawHan),
    .leia: Persona(name: "Princess Leia", weapon: .blaster, canSit: false, muzzle: (46, 32), headTop: 23,
                  draw: drawLeia),
    .obiwan: Persona(name: "Obi-Wan Kenobi", weapon: .saber, headTop: 19, signature: 3.2,
                  draw: drawObiwan),
    .r2d2: Persona(name: "R2-D2", canSit: false, headTop: 17, signature: 4,
                  draw: drawR2d2),
    .c3po: Persona(name: "C-3PO", headTop: 22, signature: 2,
                  draw: drawC3po),
    .quigon: Persona(name: "Qui-Gon Jinn", weapon: .saber, headTop: 21,
                  draw: drawQuigon),
    .mace: Persona(name: "Mace Windu", weapon: .saber, headTop: 26,
                  draw: drawMace),
    .yoda: Persona(name: "Yoda", weapon: .saber, headTop: 24, signature: 3.4,
                  draw: drawYoda),
    .jawa: Persona(name: "Jawa", weapon: .blaster, canSit: false, muzzle: (46, 32), headTop: 19,
                  draw: drawJawa),
    .chewie: Persona(name: "Chewbacca", weapon: .blaster, muzzle: (54, 31), headTop: 21, signature: 2,
                  draw: drawChewie),
    .rey: Persona(name: "Rey", weapon: .saber, headTop: 19,
                  draw: drawRey),
    .ahsoka: Persona(name: "Ahsoka Tano", weapon: .saber, headTop: 16,
                  draw: drawAhsoka),
    .ewok: Persona(name: "Wicket the Ewok", weapon: .saber, headTop: 22,
                  draw: drawEwok),
    .tauntaun: Persona(name: "Tauntaun", canSit: false, headTop: 14, signature: 2.4,
                  draw: drawTauntaun),
]

/// Luke Skywalker.
private func drawLuke(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Han Solo.
private func drawHan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Princess Leia.
private func drawLeia(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Obi-Wan Kenobi.
private func drawObiwan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// R2-D2.
private func drawR2d2(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// C-3PO.
private func drawC3po(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Qui-Gon Jinn.
private func drawQuigon(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Mace Windu.
private func drawMace(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Yoda.
private func drawYoda(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Jawa.
private func drawJawa(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Chewbacca.
private func drawChewie(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Rey.
private func drawRey(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Ahsoka Tano.
private func drawAhsoka(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Wicket the Ewok.
private func drawEwok(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Tauntaun.
private func drawTauntaun(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}
