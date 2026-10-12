import Foundation

// Heroes: the Fantastic Four, the street and the rest.

let heroes4: [Companion: Persona] = [
    .humanTorch: Persona(name: "Human Torch", weapon: .blaster, motion: .fly, shot: .fire, handGun: false, callout: "Flame on!",
                  draw: drawHumanTorch),
    .thing: Persona(name: "The Thing", weapon: .saber, armoured: true, callout: "It\'s clobberin\' time!",
                  draw: drawThing),
    .mrFantastic: Persona(name: "Mr. Fantastic", weapon: .saber,
                  draw: drawMrFantastic),
    .invisibleWoman: Persona(name: "Invisible Woman", weapon: .lightning, magic: Magic(core: C(0xE8F8FF), glow: C(0x6AC8FF), jagged: false),
                  draw: drawInvisibleWoman),
    .silverSurfer: Persona(name: "Silver Surfer", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xFFFFFF), glow: C(0xA8E8FF), jagged: false), armoured: true,
                  draw: drawSilverSurfer),
    .daredevil: Persona(name: "Daredevil", weapon: .saber,
                  draw: drawDaredevil),
    .deadpool: Persona(name: "Deadpool", weapon: .saber, callout: "Maximum effort!",
                  draw: drawDeadpool),
    .shangChi: Persona(name: "Shang-Chi", weapon: .saber,
                  draw: drawShangChi),
    .msMarvel: Persona(name: "Ms. Marvel", weapon: .saber,
                  draw: drawMsMarvel),
    .moonKnight: Persona(name: "Moon Knight", weapon: .saber,
                  draw: drawMoonKnight),
    .ghostRider: Persona(name: "Ghost Rider", weapon: .saber,
                  draw: drawGhostRider),
]

/// Human Torch.
private func drawHumanTorch(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xFF8A1E), trim: C(0xFFD24A))
}

/// The Thing.
private func drawThing(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD07A3A), trim: C(0x2A4FB0))
}

/// Mr. Fantastic.
private func drawMrFantastic(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A4FB0), trim: C(0xE8E8F0))
}

/// Invisible Woman.
private func drawInvisibleWoman(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A4FB0), trim: C(0xE8E8F0))
}

/// Silver Surfer.
private func drawSilverSurfer(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8D0DC), trim: C(0x8A96A8))
}

/// Daredevil.
private func drawDaredevil(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA01A1A), trim: C(0x6A0A0A))
}

/// Deadpool.
private func drawDeadpool(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xB01A1A), trim: C(0x1E1E24))
}

/// Shang-Chi.
private func drawShangChi(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8302A), trim: C(0xE8C02A))
}

/// Ms. Marvel.
private func drawMsMarvel(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xC8202A))
}

/// Moon Knight.
private func drawMoonKnight(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8E8EC), trim: C(0xB8BCC4))
}

/// Ghost Rider.
private func drawGhostRider(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A2A30), trim: C(0xFF7A1E))
}
