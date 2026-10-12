import Foundation

// Heroes: War Machine, the Maximoff kids, Wakanda and Sakaar.

let heroes5: [Companion: Persona] = [
    .warMachine: Persona(name: "War Machine", weapon: .blaster, motion: .fly, shot: .bullet, armoured: true,
                  draw: drawWarMachine),
    .wiccan: Persona(name: "Wiccan", weapon: .lightning, motion: .fly, magic: Magic(core: C(0xE8F0FF), glow: C(0x6A8AFF)),
                  draw: drawWiccan),
    .speed: Persona(name: "Speed", weapon: .saber,
                  draw: drawSpeed),
    .quicksilver: Persona(name: "Quicksilver", weapon: .saber,
                  draw: drawQuicksilver),
    .kateBishop: Persona(name: "Kate Bishop", weapon: .blaster, shot: .arrow, handGun: false,
                  draw: drawKateBishop),
    .yelena: Persona(name: "Yelena Belova", weapon: .blaster, shot: .bullet,
                  draw: drawYelena),
    .okoye: Persona(name: "Okoye", weapon: .saber,
                  draw: drawOkoye),
    .shuri: Persona(name: "Shuri", weapon: .blaster, shot: .energy(core: C(0xF0E0FF), glow: C(0x9A4AFF)), handGun: false,
                  draw: drawShuri),
    .valkyrie: Persona(name: "Valkyrie", weapon: .saber,
                  draw: drawValkyrie),
    .korg: Persona(name: "Korg", weapon: .saber, armoured: true, callout: "Hey man, I'm Korg.",
                  draw: drawKorg),
]

/// War Machine.
private func drawWarMachine(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A6E78), trim: C(0x2A2A30))
}

/// Wiccan.
private func drawWiccan(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0x2A2A30))
}

/// Speed.
private func drawSpeed(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x2A9A3A), trim: C(0xE8E8EC))
}

/// Quicksilver.
private func drawQuicksilver(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6AA0E0), trim: C(0xE8E8EC))
}

/// Kate Bishop.
private func drawKateBishop(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x6A2A8A), trim: C(0x2A2A30))
}

/// Yelena Belova.
private func drawYelena(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8E8EC), trim: C(0x2A2A30))
}

/// Okoye.
private func drawOkoye(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xC8202A), trim: C(0xE8B530))
}

/// Shuri.
private func drawShuri(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x1E1E26), trim: C(0x8A6AD0))
}

/// Valkyrie.
private func drawValkyrie(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0xE8E8EC), trim: C(0x3A4A6A))
}

/// Korg.
private func drawKorg(_ c: PixelCanvas, _ p: Pose) {
    drawStandIn(c, p, body: C(0x8A7A6A), trim: C(0x5A4A3A))
}
