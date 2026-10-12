import Foundation

// Heroes: the Avengers.

let heroes1: [Companion: Persona] = [
    .ironMan: Persona(name: "Iron Man", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xF4FCFF), glow: C(0x6FD8FF)), armoured: true, handGun: false, callout: "I am Iron Man.",
                  draw: drawIronMan),
    .captainAmerica: Persona(name: "Captain America", weapon: .saber, callout: "Avengers, assemble!",
                  draw: drawCaptainAmerica),
    .thor: Persona(name: "Thor", weapon: .saber, motion: .fly, callout: "For Asgard!",
                  draw: drawThor),
    .hulk: Persona(name: "Hulk", weapon: .saber, callout: "HULK SMASH!",
                  draw: drawHulk),
    .blackWidow: Persona(name: "Black Widow", weapon: .blaster, shot: .bullet,
                  draw: drawBlackWidow),
    .hawkeye: Persona(name: "Hawkeye", weapon: .blaster, shot: .arrow,
                  draw: drawHawkeye),
    .spiderMan: Persona(name: "Spider-Man", weapon: .blaster, motion: .swing, shot: .web, handGun: false,
                  draw: drawSpiderMan),
    .blackPanther: Persona(name: "Black Panther", weapon: .saber, armoured: true, callout: "Wakanda forever!",
                  draw: drawBlackPanther),
    .doctorStrange: Persona(name: "Doctor Strange", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFE8B0), glow: C(0xFF8A1E), jagged: false),
                  draw: drawDoctorStrange),
    .scarletWitch: Persona(name: "Scarlet Witch", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFD0DA), glow: C(0xFF2A4A), jagged: false),
                  draw: drawScarletWitch),
    .vision: Persona(name: "Vision", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xFFF6C0), glow: C(0xFFC81E), jagged: false),
                  draw: drawVision),
    .captainMarvel: Persona(name: "Captain Marvel", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFF4D0), glow: C(0xFF9A2A)), handGun: false,
                  draw: drawCaptainMarvel),
]

/// Iron Man.
private func drawIronMan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xB3202A), trim: C(0xE8B530))
}

/// Captain America.
private func drawCaptainAmerica(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A4FA0), trim: C(0xC8202A))
}

/// Thor.
private func drawThor(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3E4A), trim: C(0xC8202A))
}

/// Hulk.
private func drawHulk(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AA03A), trim: C(0x6A3A8A))
}

/// Black Widow.
private func drawBlackWidow(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x23232A), trim: C(0xC8302A))
}

/// Hawkeye.
private func drawHawkeye(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0x3A2A4A))
}

/// Spider-Man.
private func drawSpiderMan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xD02A2A), trim: C(0x2A4FB0))
}

/// Black Panther.
private func drawBlackPanther(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0x8A6AD0))
}

/// Doctor Strange.
private func drawDoctorStrange(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A7A), trim: C(0xB02A2A))
}

/// Scarlet Witch.
private func drawScarletWitch(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xA01A3A), trim: C(0x6A0A1A))
}

/// Vision.
private func drawVision(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8304A), trim: C(0x3A8A4A))
}

/// Captain Marvel.
private func drawCaptainMarvel(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xC8202A))
}
