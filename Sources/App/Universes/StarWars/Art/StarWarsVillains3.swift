import Foundation

// Star Wars villains: the third wave, Watto to Reva.

let starWarsVillains3: [SWVillain: Persona] = [
    .watto: Persona(name: "Watto", headTop: 11, callout: "No money, no parts, no deal!",
                  draw: drawWatto),
    .moffGideon: Persona(name: "Moff Gideon", weapon: .saber, headTop: 22,
                  draw: drawMoffGideon),
    .deathTrooper: Persona(name: "Death Trooper", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 19,
                  draw: drawDeathTrooper),
    .scoutTrooper: Persona(name: "Scout Trooper", weapon: .blaster, armoured: true, muzzle: (50, 33), handGun: false, headTop: 12,
                  draw: drawScoutTrooper),
    .ventress: Persona(name: "Asajj Ventress", weapon: .saber, headTop: 22,
                  draw: drawVentress),
    .savageOpress: Persona(name: "Savage Opress", weapon: .saber, headTop: 20,
                  draw: drawSavageOpress),
    .jangoFett: Persona(name: "Jango Fett", weapon: .blaster, armoured: true, muzzle: (47, 32), headTop: 19,
                  draw: drawJangoFett),
    .bossk: Persona(name: "Bossk", weapon: .blaster, muzzle: (52, 32), headTop: 21,
                  draw: drawBossk),
    .dengar: Persona(name: "Dengar", weapon: .blaster, muzzle: (54, 32), headTop: 19,
                  draw: drawDengar),
    .droideka: Persona(name: "Droideka", weapon: .blaster, armoured: true, muzzle: (49, 31), handGun: false, headTop: 18,
                  draw: drawDroideka),
    .phasma: Persona(name: "Captain Phasma", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 19, signature: 1.4,
                  draw: drawPhasma),
    .krennic: Persona(name: "Director Krennic", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawKrennic),
    .tarkin: Persona(name: "Governor Tarkin", headTop: 22, callout: "You may fire when ready.",
                  draw: drawTarkin),
    .fifthBrother: Persona(name: "Fifth Brother", weapon: .saber, headTop: 22,
                  draw: drawFifthBrother),
    .reva: Persona(name: "Reva", weapon: .saber, headTop: 22,
                  draw: drawReva),
]

/// Watto.
private func drawWatto(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Moff Gideon.
private func drawMoffGideon(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Death Trooper.
private func drawDeathTrooper(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Scout Trooper.
private func drawScoutTrooper(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Asajj Ventress.
private func drawVentress(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Savage Opress.
private func drawSavageOpress(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Jango Fett.
private func drawJangoFett(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Bossk.
private func drawBossk(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Dengar.
private func drawDengar(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Droideka.
private func drawDroideka(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Captain Phasma.
private func drawPhasma(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Director Krennic.
private func drawKrennic(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Governor Tarkin.
private func drawTarkin(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Fifth Brother.
private func drawFifthBrother(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Reva.
private func drawReva(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}
