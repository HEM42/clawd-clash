import Foundation

// Heroes: the TVA, the Red Room, the Savage Land, Stark's workshop and Ta Lo.

let heroes10: [Companion: Persona] = [
    .mobius: Persona(name: "Mobius", weapon: .saber,
                  draw: drawMobius),
    .sylvie: Persona(name: "Sylvie", weapon: .saber,
                  draw: drawSylvie),
    .kidLoki: Persona(name: "Kid Loki", weapon: .lightning, magic: Magic(core: C(0xE0FFE8), glow: C(0x3AD06A), jagged: false),
                  draw: drawKidLoki),
    .alligatorLoki: Persona(name: "Alligator Loki", weapon: .saber, canSit: false,
                  draw: drawAlligatorLoki),
    .hunterB15: Persona(name: "Hunter B-15", weapon: .saber,
                  draw: drawHunterB15),
    .redGuardian: Persona(name: "Red Guardian", weapon: .saber, callout: "I am Red Guardian!",
                  draw: drawRedGuardian),
    .kaZar: Persona(name: "Ka-Zar", weapon: .saber,
                  draw: drawKaZar),
    .rescue: Persona(name: "Rescue", weapon: .blaster, motion: .fly, shot: .energy(core: C(0xE8F0FF), glow: C(0x6A9AFF)), armoured: true, handGun: false,
                  draw: drawRescue),
    .zabu: Persona(name: "Zabu", weapon: .saber, canSit: false,
                  draw: drawZabu),
    .morris: Persona(name: "Morris", motion: .hover, canSit: false,
                  draw: drawMorris),
    .dumE: Persona(name: "Dum-E", canSit: false,
                  draw: drawDumE),
]

/// Mobius.
private func drawMobius(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A5A4A), trim: C(0xC8A060))
}

/// Sylvie.
private func drawSylvie(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A4A3A), trim: C(0xE8B530))
}

/// Kid Loki.
private func drawKidLoki(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A6A3A), trim: C(0xE8B530))
}

/// Alligator Loki.
private func drawAlligatorLoki(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x5A8A3A), trim: C(0xE8B530))
}

/// Hunter B-15.
private func drawHunterB15(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A3A30), trim: C(0xE8902A))
}

/// Red Guardian.
private func drawRedGuardian(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0xE8B530))
}

/// Ka-Zar.
private func drawKaZar(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8A060), trim: C(0x5A3A22))
}

/// Rescue.
private func drawRescue(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x3A5A9A), trim: C(0xB8BCC4))
}

/// Zabu.
private func drawZabu(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8A040), trim: C(0xF0E0C0))
}

/// Morris.
private func drawMorris(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8C890), trim: C(0xC8202A))
}

/// Dum-E.
private func drawDumE(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A6E78), trim: C(0x2A2A30))
}
