import Foundation

// Star Wars villains: the second wave, Sebulba to Bib Fortuna.

let starWarsVillains2: [SWVillain: Persona] = [
    .sebulba: Persona(name: "Sebulba", weapon: .blaster, armoured: true, muzzle: (70, 31), handGun: false, headTop: 19,
                  draw: drawSebulba),
    .salacious: Persona(name: "Salacious Crumb", headTop: 16,
                  draw: drawSalacious),
    .grievous: Persona(name: "General Grievous", weapon: .saber, armoured: true, headTop: 14, signature: 2.2,
                  draw: drawGrievous),
    .tusken: Persona(name: "Tusken Raider", weapon: .saber, headTop: 19,
                  draw: drawTusken),
    .cadBane: Persona(name: "Cad Bane", weapon: .blaster, muzzle: (47, 32), headTop: 15,
                  draw: drawCadBane),
    .thrawn: Persona(name: "Admiral Thrawn", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawThrawn),
    .hammerhead: Persona(name: "Hammerhead", headTop: 10,
                  draw: drawHammerhead),
    .mse6: Persona(name: "MSE-6", armoured: true, headTop: 35,
                  draw: drawMse6),
    .baylan: Persona(name: "Baylan Skoll", weapon: .saber, headTop: 21,
                  draw: drawBaylan),
    .shinHati: Persona(name: "Shin Hati", weapon: .saber, headTop: 21,
                  draw: drawShinHati),
    .id9: Persona(name: "ID9 Seeker Droid", armoured: true, headTop: 17,
                  draw: drawId9),
    .grandInquisitor: Persona(name: "Grand Inquisitor", weapon: .saber, headTop: 17,
                  draw: drawGrandInquisitor),
    .secondSister: Persona(name: "Second Sister", weapon: .saber, headTop: 18,
                  draw: drawSecondSister),
    .bantha: Persona(name: "Bantha", headTop: 15,
                  draw: drawBantha),
    .bibFortuna: Persona(name: "Bib Fortuna", headTop: 21,
                  draw: drawBibFortuna),
]

/// Sebulba.
private func drawSebulba(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Salacious Crumb.
private func drawSalacious(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// General Grievous.
private func drawGrievous(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Tusken Raider.
private func drawTusken(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Cad Bane.
private func drawCadBane(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Admiral Thrawn.
private func drawThrawn(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Hammerhead.
private func drawHammerhead(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// MSE-6.
private func drawMse6(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Baylan Skoll.
private func drawBaylan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Shin Hati.
private func drawShinHati(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// ID9 Seeker Droid.
private func drawId9(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Grand Inquisitor.
private func drawGrandInquisitor(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Second Sister.
private func drawSecondSister(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Bantha.
private func drawBantha(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Bib Fortuna.
private func drawBibFortuna(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}
