import Foundation

// Villains: the Upside Down and the people who hunt the kids. Drawn eerie, never gory: Clawd in costume like the rest,
// on Clawd's four legs.

let hawkinsVillains1: [HawkinsVillain: Persona] = [
    .vecna: Persona(name: "Vecna", weapon: .lightning,
                    magic: Magic(core: C(0xFFD0C8), glow: C(0xD0202A), jagged: false, rings: true),
                    pivot: (48, 32), bulk: 4, headTop: 12, signature: 3.6, draw: drawVecna),
]

// MARK: - Vecna

/// Vecna: tall and gaunt, a high bald head on a thin neck over Clawd's body with its shoulders sloping, his reddish-grey
/// skin knotted all over with dark vines, his ribs showing, pale milky eyes in deep sockets and a thin, lipless mouth. One long arm hangs at his back; the other reaches
/// forward with long pale claws, the vines twisting round his four legs to clawed toes. His mind power is red rings
/// rippling out of his hand. Signature: he raises his hand, claws spread, and the vines all over him writhe, three
/// tendrils rising off his shoulders and head, then settling.
private func drawVecna(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A5A50), skinD = C(0x5E3A36), skinL = C(0xA87468)
    let vine = C(0x3A161A), vineL = C(0x6E2E2C), vein = C(0xB04A3E)
    let claw = C(0xE2D4BC), clawD = C(0xA8987E)
    let rise = p.signature.map { $0 > 0.08 && $0 < 0.9 ? ($0 - 0.08) / 0.82 : -1 } ?? -1
    let writhe = rise >= 0 ? sin(rise * .pi) : 0
    let wt = p.t * 7

    // The legs, the vines wound round them, long pale toes on the ground.
    drawLegs(c, Look(leg: skinD), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.px(lx, bottom - 6, vine); c.px(lx + 1, bottom - 5, vine); c.px(lx, bottom - 3, vine); c.px(lx + 1, bottom - 2, vineL)
            c.px(lx, bottom - 6, vineL)
            c.px(lx + 2, bottom, clawD)
        }
    }

    c.oy += p.breathe
    // The body: Clawd's block with its shoulders sloping, a thin neck, and the tall bald head on top, lit along the
    // top and the left, shaded on the right and underneath, the cheeks hollow.
    c.pattern(17, 26, [
        "....SSSSSSSSSSSSSS....",
        "..SSSSSSSSSSSSSSSSSS..",
        ".SSSSSSSSSSSSSSSSSSSS.",
    ], ["S": skin])
    c.rect(17, 29, 22, 9, skin)
    c.rect(25, 24, 6, 2, skinD)
    c.pattern(21, 12, [
        "....SSSSSS....",
        "..SSSSSSSSSS..",
        ".SSSSSSSSSSSS.",
        "SSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSS",
        ".SSSSSSSSSSSS.",
        ".SSSSSSSSSSSS.",
        "..SSSSSSSSSS..",
        "...SSSSSSSS...",
    ], ["S": skin])
    c.rect(25, 12, 4, 1, skinL); c.rect(23, 13, 3, 1, skinL); c.rect(22, 14, 1, 2, skinL); c.rect(21, 15, 1, 6, skinL)
    c.rect(34, 15, 1, 6, skinD); c.rect(33, 21, 1, 3, skinD); c.rect(22, 21, 1, 2, skinD); c.rect(23, 23, 8, 1, skinD)
    c.rect(19, 27, 4, 1, skinL); c.rect(18, 28, 1, 2, skinL); c.rect(17, 29, 1, 8, skinL)
    c.rect(38, 29, 1, 9, skinD); c.rect(36, 27, 2, 1, skinD); c.rect(17, 37, 22, 1, skinD)

    // The vines knotted over him: dark strands lit on their left, over his head and down his body, twisting as he
    // breathes and writhing in his signature.
    let strands: [(x: Double, top: Int, bottom: Int, lo: Int, hi: Int, ph: Double)] = [
        (24, 13, 22, 22, 33, 0.5), (31, 14, 23, 22, 33, 2.6),
        (20, 27, 37, 18, 37, 0), (26, 27, 37, 18, 37, 2.1), (32, 27, 37, 18, 37, 4.2), (36, 29, 36, 18, 37, 3.1),
    ]
    for v in strands {
        for y in v.top...v.bottom {
            let wob = sin(Double(y) * 0.55 + v.ph) * 1.2 + writhe * sin(wt + Double(y) * 0.8 + v.ph) * 1.6
            let x = Int((v.x + wob).rounded())
            guard x >= v.lo, x <= v.hi else { continue }
            c.px(x, y, vine); if x > v.lo { c.px(x - 1, y, vineL) }
        }
    }
    // A few raw red veins between them, and the ribs' shadows across his chest.
    for (x, y) in [(19, 31), (20, 32), (29, 29), (30, 30), (34, 34), (35, 35), (23, 35)] { c.px(x, y, vein) }
    for y in [30, 32] { c.rect(22, y, 3, 1, skinD); c.rect(28, y, 3, 1, skinD) }

    // The face: deep sockets, pale milky eyes, and the thin mouth with its row of small teeth.
    c.rect(23, 17, 4, 4, skinD); c.rect(29, 17, 4, 4, skinD)
    c.rect(24, 18, 2, 2, C(0xD4DCD4)); c.px(24, 18, C(0xF4F8F0)); c.rect(30, 18, 2, 2, C(0xD4DCD4)); c.px(30, 18, C(0xF4F8F0))
    c.rect(24, 22, 8, 1, C(0x2A0E10))
    for x in [25, 27, 29, 31] { c.px(x, 22, C(0xC8B8A0)) }

    // The far arm, long and hanging at his back, its claws pointing down.
    c.rect(14, 28, 3, 8, skin); c.rect(14, 28, 1, 8, skinL); c.px(15, 30, vine); c.px(16, 31, vine)
    for x in [14, 16] { c.rect(x, 36, 1, 3, claw); c.px(x, 38, clawD) }

    if rise >= 0 {
        // The hand raised high, its long claws spread, and tendrils rising off his shoulders and head, waving.
        let lift = Int((min(1, rise * 4) * 10).rounded())
        c.rect(39, 30 - lift, 3, 4 + lift, skin); c.rect(41, 30 - lift, 1, 4 + lift, skinD); c.px(39, 32 - lift / 2, vine)
        let hy = 28 - lift
        c.rect(39, hy, 4, 2, skin)
        // Three claws fanned out, two pixels apart so they stay three.
        for (k, len) in [5, 6, 5].enumerated() {
            for d in 0..<len { c.px(38 + k * 2 + (k - 1) * d / 2, hy - 1 - d, d == len - 1 ? clawD : claw) }
        }
        for (k, base) in [(x: 18, y: 27), (x: 27, y: 12), (x: 37, y: 27)].enumerated() {
            let len = Int((writhe * Double(k == 1 ? 7 : 9)).rounded())
            guard len > 0 else { continue }
            for d in 0..<len {
                let x = base.x + Int((sin(wt * 0.8 + Double(d) * 0.6 + Double(k) * 2) * 1.5).rounded()) + (k - 1) * d / 3
                c.px(x, base.y - 1 - d, vine); c.px(x - 1, base.y - 1 - d, vineL)
            }
        }
        return
    }

    // The near arm, reaching forward, its three long pale claws out straight, raised as far as he casts.
    let r = p.armRaise
    c.rect(39, 31 - r, 5, 3, skin); c.rect(39, 33 - r, 5, 1, skinD); c.px(41, 31 - r, vine); c.px(42, 32 - r, vine)
    c.rect(44, 30 - r, 1, 5, skin)
    c.pattern(45, 28 - r, [
        "....Cc",
        "..CC..",
        "CC....",
        "......",
        "CCCCCc",
        "......",
        "CC....",
        "..CC..",
        "....Cc",
    ], ["C": claw, "c": clawD])
}
