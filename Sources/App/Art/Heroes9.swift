import Foundation

// Heroes: mystics, cosmic and the funny ones.

let heroes9: [Companion: Persona] = [
    .monicaRambeau: Persona(name: "Monica Rambeau", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xFFFFFF), glow: C(0x8AC8FF)), handGun: false,
                  draw: drawMonicaRambeau),
    .clea: Persona(name: "Clea", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xF0E0FF), glow: C(0xC04AFF), jagged: false),
                  draw: drawClea),
    .doctorVoodoo: Persona(name: "Doctor Voodoo", weapon: .lightning, magic: Magic(core: C(0xF0FFE0), glow: C(0x6AE04A)),
                  draw: drawDoctorVoodoo),
    .howardTheDuck: Persona(name: "Howard the Duck", weapon: .blaster, shot: .bullet,
                  draw: drawHowardTheDuck),
    .squirrelGirl: Persona(name: "Squirrel Girl", weapon: .saber,
                  draw: drawSquirrelGirl),
    .jeffTheLandShark: Persona(name: "Jeff the Land Shark", weapon: .saber, canSit: false,
                  draw: drawJeffTheLandShark),
    .throg: Persona(name: "Throg", weapon: .saber, callout: "For Asgard! Ribbit.",
                  draw: drawThrog),
    .lockjaw: Persona(name: "Lockjaw",
                  draw: drawLockjaw),
    .forbushMan: Persona(name: "Forbush Man",
                  draw: drawForbushMan),
]

/// Monica Rambeau.
private func drawMonicaRambeau(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A3A8A), trim: C(0xF0F0F4))
}

/// Clea.
private func drawClea(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0xF0F0F4))
}

/// Doctor Voodoo.
private func drawDoctorVoodoo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0xE8C02A))
}

/// Howard the Duck.
private func drawHowardTheDuck(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xF0F0F4), trim: C(0x2A3A8A))
}

/// Squirrel Girl.
private func drawSquirrelGirl(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A5A3A), trim: C(0xE8C02A))
}

/// Jeff the Land Shark.
private func drawJeffTheLandShark(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A8AA0), trim: C(0xF0F0F4))
}

/// Throg.
private func drawThrog(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5AA03A), trim: C(0xC8202A))
}

/// Lockjaw.
private func drawLockjaw(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A5A4A), trim: C(0xE8C02A))
}

/// Forbush Man.
private func drawForbushMan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8E8EC), trim: C(0xC8202A))
}
