import Foundation

// Star Wars villains: the originals.

let starWarsVillains1: [SWVillain: Persona] = [
    .vader: Persona(name: "Darth Vader", weapon: .saber, headTop: 14, signature: 2.6,
                  draw: drawVader),
    .kylo: Persona(name: "Kylo Ren", weapon: .saber, headTop: 15, signature: 1.8,
                  draw: drawKylo),
    .maul: Persona(name: "Darth Maul", weapon: .saber, headTop: 23,
                  draw: drawMaul),
    .boba: Persona(name: "Boba Fett", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 11, signature: 2.6,
                  draw: drawBoba),
    .trooper: Persona(name: "Stormtrooper", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 16, signature: 2.6,
                  draw: drawTrooper),
    .emperor: Persona(name: "The Emperor", weapon: .lightning, headTop: 19,
                  draw: drawEmperor),
    .rogr: Persona(name: "R0-GR", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 15, callout: "Roger roger!",
                  draw: drawRogr),
    .dooku: Persona(name: "Count Dooku", weapon: .saber, headTop: 21,
                  draw: drawDooku),
    .gamorrean: Persona(name: "Gamorrean Guard", weapon: .saber, headTop: 17,
                  draw: drawGamorrean),
    .jabba: Persona(name: "Jabba the Hutt", headTop: 19, signature: 2.4, callout: "Ho ho ho!",
                  draw: drawJabba),
    .ig88: Persona(name: "IG-88", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 9, signature: 2.4,
                  draw: drawIg88),
    .atst: Persona(name: "AT-ST", weapon: .blaster, armoured: true, muzzle: (47, 22), handGun: false, headTop: 10,
                  draw: drawAtst),
    .atat: Persona(name: "AT-AT", weapon: .blaster, armoured: true, muzzle: (64, 21), handGun: false, headTop: 11,
                  draw: drawAtat),
    .rancor: Persona(name: "Rancor", weapon: .saber, pivot: (35, 25), headTop: 8, signature: 2,
                  draw: drawRancor),
    .greedo: Persona(name: "Greedo", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  draw: drawGreedo),
    .royalGuard: Persona(name: "Royal Guard", weapon: .saber, headTop: 13, fidgets: false,
                  draw: drawRoyalGuard),
]

/// Darth Vader.
private func drawVader(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Kylo Ren.
private func drawKylo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Darth Maul.
private func drawMaul(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Boba Fett.
private func drawBoba(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Stormtrooper.
private func drawTrooper(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// The Emperor.
private func drawEmperor(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// R0-GR.
private func drawRogr(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Count Dooku.
private func drawDooku(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Gamorrean Guard.
private func drawGamorrean(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Jabba the Hutt.
private func drawJabba(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// IG-88.
private func drawIg88(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// AT-ST.
private func drawAtst(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// AT-AT.
private func drawAtat(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Rancor.
private func drawRancor(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Greedo.
private func drawGreedo(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}

/// Royal Guard.
private func drawRoyalGuard(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2E2F36), trim: C(0x16161B))
}
