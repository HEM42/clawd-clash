import Foundation

// Villains: the Upside Down and the people who hunt the kids. Drawn eerie, never gory: Clawd in costume like the rest,
// on Clawd's four legs.

let hawkinsVillains1: [HawkinsVillain: Persona] = [
    .vecna: Persona(name: "Vecna", weapon: .lightning,
                    magic: Magic(core: C(0xFFD0C8), glow: C(0xD0202A), jagged: false, rings: true),
                    pivot: (48, 32), bulk: 4, headTop: 6, signature: 3.6, draw: drawVecna),
]

// MARK: - Vecna

/// Vecna: tall and gaunt, his long narrow skull high above Clawd's body on a thin neck, ash-grey skin with dark red-black
/// vines wound all over it: across the scalp, down the neck, round the ribs, the arms and the four thin, knotted legs.
/// Deep black eye sockets with a pale glint in each, no nose but two slits, and a lipless mouth of small teeth. His
/// ribs show over a hollow belly and a narrow waist. One long arm hangs at his back, its claws pointing down; the other
/// reaches forward, its long bony fingers ending in claws. His mind power is red rings rippling out of that hand.
/// Signature: he raises the hand high, claws spread, the vines all over him writhe, and three tendrils rise off his
/// back, curling at the tips, then settle.
private func drawVecna(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8E8982), skinD = C(0x635D58), skinL = C(0xB2ADA4), deep = C(0x3C3634)
    let vine = C(0x2A080C), vineL = C(0x5E1820), vein = C(0xB0303A)
    let claw = C(0xE2D8C4), clawD = C(0xA89A86)
    let rise = p.signature.map { $0 > 0.08 && $0 < 0.9 ? ($0 - 0.08) / 0.82 : -1 } ?? -1
    let writhe = rise >= 0 ? sin(rise * .pi) : 0
    let wt = p.t * 7

    // The legs: thin and grey, shaded on the far side, a knobbly knee, a vine wound round each and long pale toes.
    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx + 1, 38, 1, bottom - 37, skinD)
            c.px(lx, bottom - 4, skinL)
            c.px(lx, bottom - 3, vine); c.px(lx + 1, bottom - 2, vine); c.px(lx + 1, bottom - 5, vineL); c.px(lx, bottom - 6, vine)
            c.px(lx + 2, bottom, claw); c.px(lx + 3, bottom, clawD)
        }
    }

    c.oy += p.breathe
    // The far arm, long and thin, hanging at his back, its fingers ending in claws pointing down.
    // Sitting, it rests shorter, its claws on the ground.
    let reach = seatedPose ? 4 : 0
    c.rect(15, 25, 2, 12 - reach, skin); c.rect(15, 25, 1, 12 - reach, skinL); c.rect(16, 30, 1, 1, vine); c.rect(15, 32, 1, 2, vine)
    c.px(16, 27, vine)
    c.rect(14, 37 - reach, 1, 3, skin); c.rect(16, 37 - reach, 1, 3, skin)
    c.px(14, 40 - reach, claw); c.px(14, 41 - reach, clawD); c.px(16, 40 - reach, claw); c.px(16, 41 - reach, clawD)

    // The body: sloping shoulders, the ribcage the width of Clawd's block, then a hollow belly pulled in to a narrow
    // waist and the hips over the legs. Lit on the left and along the shoulders, shaded on the right.
    c.pattern(17, 23, [
        ".........LSSD.........",
        "......LLLSSSSSSSD.....",
        "...LLLSSSSSSSSSSSSDD..",
        ".LLSSSSSSSSSSSSSSSSSD.",
        ".LSSSSSSSSSSSSSSSSSSDD",
        ".LSSSSSSSSSSSSSSSSSSDD",
        ".LSSSSSSSSSSSSSSSSSSD.",
        ".LSSSSSSSSSSSSSSSSSSD.",
        "..LSSSSSSSSSSSSSSSSD..",
        "..LSSSSSSSSSSSSSSSSD..",
        "...LSSSSSSSSSSSSSSD...",
        "....LSSSSSSSSSSSSD....",
        "....LSSSSSSSSSSSSD....",
        "...LSSSSSSSSSSSSSSD...",
        "..LSSSSSSSSSSSSSSSSD..",
    ], ["S": skin, "L": skinL, "D": skinD])
    // The ribcage: the flesh sunk in shadow between the ribs, and three ribs lit along their tops, curving down and out
    // from the breastbone.
    c.rect(20, 26, 16, 6, skinD)
    for base in [26, 28, 30] {
        for x in 20...35 where x < 27 || x > 28 {
            let y = base + abs(x * 2 - 55) / 7
            guard y <= 32 else { continue }
            c.px(x, y, skinL); c.px(x, y + 1, skin)
        }
    }
    c.rect(27, 25, 2, 7, skinD); c.px(27, 25, skinL)          // the breastbone
    c.rect(22, 34, 12, 1, skinD); c.rect(23, 35, 10, 1, deep)  // the hollow belly

    // The neck: thin, its cords standing out.
    c.rect(25, 19, 6, 5, skin); c.rect(26, 20, 1, 4, skinD); c.rect(29, 20, 1, 4, skinD); c.rect(30, 19, 1, 5, deep)

    // The head: a long, narrow skull with its crown swept back, lit along the top and the left, the cheeks hollow under
    // the bone, a narrow jaw.
    c.pattern(22, 6, [
        "...LLLLL...",
        ".LLSSSSSSL.",
        ".LSSSSSSSSD",
        "LSSSSSSSSSD",
        "LSSSSSSSSSD",
        "LSSSSSSSSSD",
        "LSSSSSSSSSD",
        "LSSSSSSSSSD",
        ".SSSSSSSSSD",
        ".SSSSSSSSSD",
        ".LSSSSSSSD.",
        "..SSSSSSSD.",
        "..SSSSSSSD.",
        "...SSSSSD..",
        "....SSSD...",
    ], ["S": skin, "L": skinL, "D": skinD])
    c.rect(23, 16, 1, 2, skinD); c.rect(31, 15, 1, 2, deep)   // hollow cheeks
    c.rect(23, 12, 3, 1, skinL); c.rect(28, 12, 3, 1, skinL)  // the brow ridges
    // Deep sockets, nearly black, each with a pale milky glint; two slits for a nose.
    let socket = C(0x120608)
    c.rect(23, 13, 3, 3, socket); c.rect(28, 13, 3, 3, socket); c.px(24, 16, socket); c.px(29, 16, socket)
    c.px(24, 14, C(0xC8D6DA)); c.px(29, 14, C(0xC8D6DA))
    c.px(26, 16, deep); c.px(27, 16, deep)
    // The lipless mouth: a dark slit with a row of small teeth bared.
    c.rect(24, 18, 6, 2, C(0x1A0808))
    for x in [24, 26, 28] { c.px(x, 18, C(0xD0C4A8)) }
    for x in [25, 27, 29] { c.px(x, 19, C(0xA89A80)) }

    // The vines: dark red-black strands lit on their left, ridged over his scalp and down his temple, round his neck,
    // down his flanks and once across his ribs, twisting as he breathes and writhing in his signature.
    let strands: [(x: Double, top: Int, bottom: Int, lo: Int, hi: Int, ph: Double)] = [
        (25, 6, 11, 23, 31, 0.5), (29, 7, 12, 23, 32, 2.0), (22.5, 9, 16, 22, 23, 1.2),
        (27, 20, 24, 25, 29, 0.2),
        (19.5, 25, 37, 18, 21, 0), (35.5, 25, 36, 34, 37, 3.1),
    ]
    for v in strands {
        for y in v.top...v.bottom {
            let wob = sin(Double(y) * 0.55 + v.ph) * 1.0 + writhe * sin(wt + Double(y) * 0.8 + v.ph) * 1.4
            let x = Int((v.x + wob).rounded())
            guard x >= v.lo, x <= v.hi else { continue }
            c.px(x, y, vine); if x > v.lo { c.px(x - 1, y, vineL) }
        }
    }
    // Vines twisting across his ribs: one from each shoulder, crooked, meeting over the breastbone and running on
    // down to the hips, with short shoots branching off them.
    for (k, from) in [(x: 21, y: 25, dir: 1), (x: 34, y: 25, dir: -1)].enumerated() {
        for d in 0...10 {
            let x = from.x + from.dir * (d * 6 / 10) + Int((sin(Double(d) * 1.1 + Double(k) * 2 + wt * writhe) * 1.1).rounded())
            let y = from.y + d
            c.px(x, y, vine); c.px(x - 1, y, vineL)
        }
    }
    for (x, y) in [(23, 28), (24, 29), (32, 29), (31, 30), (26, 33), (25, 34), (29, 33), (30, 34)] { c.px(x, y, vine) }
    for x in 21...34 where x % 5 != 0 { c.px(x, 36 - (x % 3 == 0 ? 1 : 0), vine) }
    // Vines over both shoulders from the neck, knotted where they meet the arms.
    for k in 0...5 { c.px(25 - k, 23 + k / 2 + (k > 3 ? 1 : 0), vine); c.px(30 + k, 23 + k / 2 + (k > 3 ? 1 : 0), vine) }
    c.px(24, 23, vineL); c.px(19, 25, vineL); c.px(36, 26, vine)
    // A few raw red veins between them.
    for (x, y) in [(20, 30), (34, 28), (30, 31), (24, 9), (28, 22)] { c.px(x, y, vein) }

    if rise >= 0 {
        // The hand raised high, its long fingers and claws spread, and tendrils rising off his back, waving.
        let lift = Int((min(1, rise * 4) * 13).rounded())
        limb(c, 36, 25, 39, 26 - lift / 2, skin, skinD); limb(c, 39, 26 - lift / 2, 40, 23 - lift, skin, skinD)
        c.px(38, 25 - lift / 4, vine); c.px(40, 24 - lift * 3 / 4, vine)
        let hy = 22 - lift
        c.rect(38, hy, 5, 2, skin); c.rect(38, hy, 5, 1, skinL)
        // Four long fingers fanned wide, each ending in a claw hooked over at the tip.
        for (k, len) in [5, 7, 7, 6].enumerated() {
            let a = -0.55 + Double(k) * 0.38
            for d in 0..<len {
                let x = 39 + k + Int((sin(a) * Double(d)).rounded()), y = hy - 1 - Int((cos(a) * Double(d)).rounded())
                c.px(x, y, d >= len - 2 ? (d == len - 1 ? clawD : claw) : skin)
            }
        }
        for (k, base) in [(x: 19, y: 24, dx: -0.5), (x: 23, y: 8, dx: -0.45), (x: 18, y: 33, dx: -0.85)].enumerated() {
            let full = k == 1 ? 5 : 13
            let len = Int((writhe * Double(full)).rounded())
            guard len > 0 else { continue }
            for d in 0..<len {
                let f = Double(d) / Double(full)
                let curl = f * f * 4 * (k == 2 ? -1 : 1)   // the tip curling over
                let x = base.x + Int((Double(d) * base.dx + curl + sin(wt * 0.8 + Double(d) * 0.7 + Double(k) * 2) * 2 * f).rounded())
                let y = base.y - 1 - (k == 2 ? d * 2 / 3 : d)
                c.px(x, y, vine)
                if d < len / 2 { c.px(x + 1, y, vine) }; if d < len - 2 { c.px(x - 1, y, vineL) }
                if d % 4 == 2 && d < len - 2 { c.px(x + 2, y + 1, vine) }   // a thorn
            }
        }
        return
    }

    // The near arm, long and thin, reaching forward; the hand's long bony fingers out straight with claws at the
    // ends, raised as far as he casts.
    let r = p.armRaise
    limb(c, 36, 25, 40, 30 - r, skin, skinD); limb(c, 40, 30 - r, 45, 30 - r, skin, skinD)
    c.px(38, 27 - r / 2, vine); c.px(42, 30 - r, vine); c.px(43, 31 - r, vine)
    c.rect(45, 29 - r, 2, 5, skin); c.rect(45, 29 - r, 2, 1, skinL); c.px(46, 33 - r, skinD)
    c.pattern(47, 27 - r, [
        "...ssCc",
        "sssC...",
        ".......",
        "sssssCc",
        ".......",
        "sssC...",
        "...ssCc",
    ], ["s": skin, "C": claw, "c": clawD])
}

/// A limb two pixels thick from one point to another, lit along its top, shaded underneath.
private func limb(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, _ shade: Px) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for k in 0...n {
        let x = x0 + (x1 - x0) * k / n, y = y0 + (y1 - y0) * k / n
        c.px(x, y, col); c.px(x + (abs(y1 - y0) > abs(x1 - x0) ? 1 : 0), y + (abs(y1 - y0) > abs(x1 - x0) ? 0 : 1), shade)
    }
}
