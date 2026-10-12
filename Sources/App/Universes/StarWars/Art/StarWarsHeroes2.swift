import Foundation

// Star Wars heroes: Jar Jar to Admiral Ackbar.

let starWarsHeroes2: [SWHero: Persona] = [
    .jarjar: Persona(name: "Jar Jar Binks", headTop: 18,
                  draw: drawJarjar),
    .lando: Persona(name: "Lando Calrissian", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawLando),
    .zorii: Persona(name: "Zorii Bliss", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  draw: drawZorii),
    .boKatan: Persona(name: "Bo-Katan Kryze", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  draw: drawBoKatan),
    .maz: Persona(name: "Maz Kanata", headTop: 22, signature: 2.4,
                  draw: drawMaz),
    .wedge: Persona(name: "Wedge Antilles", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  draw: drawWedge),
    .l337: Persona(name: "L3-37", headTop: 17,
                  draw: drawL337),
    .monMothma: Persona(name: "Mon Mothma", canSit: false, headTop: 22,
                  draw: drawMonMothma),
    .padme: Persona(name: "Padmé Amidala", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawPadme),
    .ackbar: Persona(name: "Admiral Ackbar", headTop: 17,
                  draw: drawAckbar),
]

/// Jar Jar Binks.
private func drawJarjar(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Lando Calrissian.
private func drawLando(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Zorii Bliss.
private func drawZorii(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Bo-Katan Kryze.
private func drawBoKatan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Maz Kanata.
private func drawMaz(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Wedge Antilles.
private func drawWedge(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// L3-37.
private func drawL337(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Mon Mothma.
private func drawMonMothma(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Padmé Amidala.
private func drawPadme(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}

/// Admiral Ackbar.
private func drawAckbar(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD97757), trim: C(0xB85F40))
}
