import Foundation

// Star Clawds's own drills (`UniverseModule.drills`): a few characters practise something only they would.

let starClawdsBespokeDrills: [Cast: BespokeDrill] = [
        // Yodle: a little cairn of stones lifted off the ground with the Force, turning slowly.
        .hero(StarClawdsHero.yoda): { c, who, d, t in
            standing(c, who, t: t)
            drawLiftedStones(c, d: d, t: t)
        },
        // Darth Vapor: an Imperial crate held up in the air, shaking with the strain.
        .villain(StarClawdsVillain.vader): { c, who, d, t in
            standing(c, who, t: t)
            let lift = 11 * setRamp(d, rise: 1.2)
            let shake = lift > 8 ? (noise(Int(t * 24)) > 0.5 ? 1 : 0) : 0
            let x = 53 + shake, y = Int((38 - lift).rounded())
            c.rect(x, y, 9, 7, C(0x4A4E58))
            c.rect(x, y, 9, 1, C(0x7A808C)); c.rect(x, y + 3, 9, 1, C(0x30333A))
            c.rect(x + 1, y + 1, 2, 2, C(0xC8A030)); c.rect(x + 6, y + 4, 2, 2, C(0x9AA0AC))
            if lift < 3 { c.rect(x - 1, 44, 11, 1, C(0x8A7E6E, 0.6)) }
        },
        // Ahh2-De2: playing a hologram message, a little flickering blue figure in a beam of light.
        .hero(StarClawdsHero.r2d2): { c, who, d, t in
            standing(c, who, t: t)
            let r = setRamp(d, rise: 0.5)
            guard r > 0.5, noise(Int(t * 16)) > 0.1 else { return }
            let beam = C(0x7FC8FF, 0.18), fig = C(0x8AD0FF, 0.55), lit = C(0xCFEFFF, 0.7)
            let proj = (38.0, 21.0)
            c.glowLine(proj.0, proj.1, 51, 41, core: beam, glow: C(0, 0), coreR: 0.4, glowR: 0.5)
            c.glowLine(proj.0, proj.1, 59, 41, core: beam, glow: C(0, 0), coreR: 0.4, glowR: 0.5)
            // A small robed figure, every other row missing.
            let jitter = noise(Int(t * 8)) > 0.85 ? 1 : 0
            for y in stride(from: 26 + Int(t * 10) % 2, through: 41, by: 2) {
                let w = y < 30 ? 3 : (y < 33 ? 5 : 4 + (y - 33) / 3)
                c.rect(55 - w / 2 + jitter, y, w, 1, y < 30 ? lit : fig)
            }
            c.px(53 + jitter, 27, fig); c.px(57 + jitter, 27, fig)           // the buns
        },
]

/// Three stones, biggest at the bottom, lifted together and turning, for Yodle.
private func drawLiftedStones(_ c: PixelCanvas, d: DrillPlay, t: Double) {
    let lift = 12 * setRamp(d, rise: 1.4)
    let stones: [(w: Int, h: Int, off: Double)] = [(7, 4, 0), (5, 3, 1.2), (3, 3, 2.1)]
    var y = 44 - lift
    for (i, s) in stones.enumerated() {
        let bob = lift > 6 ? sin(t * 2.2 + s.off) * 1.2 : 0
        let x = 55 + Int((sin(t * 1.4 + s.off) * Double(i) * 0.8).rounded()) - s.w / 2
        let top = Int((y - Double(s.h) + bob).rounded())
        c.rect(x, top, s.w, s.h, C(0x7A6E5E))
        c.rect(x, top, s.w, 1, C(0xA89A84)); c.rect(x + s.w - 1, top, 1, s.h, C(0x5A5044))
        y -= Double(s.h) + (lift > 6 ? 1.5 : 0)
    }
    if lift > 2 {
        for k in 0..<2 { c.px(52 + k * 6 + Int(noise(Int(t * 6) + k) * 2), 43 - Int(noise(Int(t * 6) + k + 4) * 3), C(0xA89A84, 0.6)) }
    }
}
