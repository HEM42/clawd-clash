import Foundation

// Heroes: the street — Defenders, Punisher, Blade and friends.

let heroes8: [Companion: Persona] = [
    .spiderWoman: Persona(name: "Spider-Woman", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xF0FFE0), glow: C(0x9AE04A)), handGun: false,
                  draw: drawSpiderWoman),
    .blackCat: Persona(name: "Black Cat", weapon: .saber,
                  draw: drawBlackCat),
    .lukeCage: Persona(name: "Luke Cage", weapon: .saber, armoured: true, callout: "Sweet Christmas!",
                  draw: drawLukeCage),
    .ironFist: Persona(name: "Iron Fist", weapon: .saber,
                  draw: drawIronFist),
    .jessicaJones: Persona(name: "Jessica Jones", weapon: .saber,
                  draw: drawJessicaJones),
    .punisher: Persona(name: "The Punisher", weapon: .blaster, shot: .bullet,
                  draw: drawPunisher),
    .elektra: Persona(name: "Elektra", weapon: .saber,
                  draw: drawElektra),
    .blade: Persona(name: "Blade", weapon: .saber,
                  draw: drawBlade),
    .blackKnight: Persona(name: "Black Knight", weapon: .saber, armoured: true,
                  draw: drawBlackKnight),
]

/// Spider-Woman.
private func drawSpiderWoman(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0xE8C02A))
}

/// Black Cat.
private func drawBlackCat(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xF0F0F4))
}

/// Luke Cage.
private func drawLukeCage(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C02A), trim: C(0x2A2A30))
}

/// Iron Fist.
private func drawIronFist(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A9A3A), trim: C(0xE8C02A))
}

/// Jessica Jones.
private func drawJessicaJones(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3A42), trim: C(0x5A4A3A))
}

/// The Punisher.
private func drawPunisher(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0xF0F0F4))
}

/// Elektra.
private func drawElektra(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0x8A1A1A))
}

/// Blade.
private func drawBlade(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0x5A5A64))
}

/// Black Knight.
private func drawBlackKnight(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xC8202A))
}
