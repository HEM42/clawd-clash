import Foundation

// Villains: Angel's later foes. The Stone Beast and Skipp are big Clawds (a taller, broader block, their `bulk` and
// fists say so), shaped by what grows out of them rather than boxed: horns and shoulder spikes of dark rock, a swept
// bone crest and domed bone pauldrons. Holts, Sahjhann and Illyrya are Clawd at Clawd's own size, carried by a
// greatcoat and a crossbow, a red scarred face, and blue-streaked hair over red-and-black armour.

let slayerVillains8: [SlayerVillain: Persona] = [
    .stoneBeast: Persona(name: "The Stone Beast", weapon: .saber, armoured: true, canSit: false, pivot: v8BeastFist,
                         bulk: 6, headTop: 9, signature: 3.4, draw: drawStoneBeast),
    .holts: Persona(name: "Holts", weapon: .blaster, shot: .arrow, muzzle: (49, 32), handGun: false, headTop: 21,
                    draw: drawHolts),
    .sahjhann: Persona(name: "Sahjhann", weapon: .saber, headTop: 23, signature: 3.0, draw: drawSahjhann),
    .illyrya: Persona(name: "Illyrya", weapon: .saber, headTop: 19, signature: 3.6, draw: drawIllyrya),
    .skipp: Persona(name: "Skipp", weapon: .saber, armoured: true, canSit: false, pivot: v8SkippHand, bulk: 4,
                    headTop: 12, draw: drawSkipp),
]

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func v8Ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// 0 outside `a`…`b`, rising over the first `edge` of it and falling over the last.
private func v8Arc(_ s: Double, _ a: Double, _ b: Double, edge: Double = 0.1) -> Double {
    min(v8Ramp(s, a, a + edge), 1 - v8Ramp(s, b - edge, b))
}

/// A swing angle kept in front of the body, so a fist or a blade never sweeps back across the face (a flourish's
/// full turn jumps across the back instead).
private func v8Front(_ a: Double, lo: Double = -115, hi: Double = 80) -> Double {
    var x = a.truncatingRemainder(dividingBy: 360)
    if x > 180 { x -= 360 }
    if x <= -180 { x += 360 }
    return min(hi, max(lo, x))
}

/// A heavy punch along `angle` from the shoulder `s`: the arm thrown out `reach` pixels, a smear where a fast swing
/// just was, and `fist` drawing whatever is on the end, centred on the point it's given.
private func v8Punch(_ c: PixelCanvas, from s: (x: Double, y: Double), angle: Double, trail: [Double], reach: Double,
                     arm: Px, thick: Double, smear: Px, fist: (Int, Int) -> Void) {
    let a = v8Front(angle)
    slayerSmear(c, s, trail.map { v8Front($0) }, from: reach - 3, to: reach + 2, smear)
    let e = slayerReach(s, a, reach)
    slayerLine(c, s.x, s.y, e.x, e.y, arm, thick)
    fist(Int(e.x.rounded()), Int(e.y.rounded()))
}

// MARK: - The Stone Beast

/// Where the Stone Beast's fist swings from: out in front of its huge body.
private let v8BeastFist: (x: Double, y: Double) = (47.0, 34.0)

/// The Stone Beast: the demon of living rock Jasmine's coming woke (Angel, season 4). A big Clawd, a third again as
/// tall and broad, in dark grey stone cracked all over: two black horns sweeping out and up from its brow, jagged
/// spikes on its hunched shoulders, a heavy rock brow over ember eyes; only Clawd's orange face shows through. Thick
/// stone legs on clawed feet. It fights with its fists of rock, and blows bounce off it. Signature: it raises its arms
/// and the sky darkens over it, cinders of the rain of fire drifting down, and the dark lifts as it lowers them.
private func drawStoneBeast(_ c: PixelCanvas, _ p: Pose) {
    let rock = C(0x585862), rockD = C(0x3E3E47), rockL = C(0x7A7A86), rockDD = C(0x2C2C33), crack = C(0x1C1C22)
    let horn = C(0x26221F), hornL = C(0x5C524A), hornT = C(0xA8A090)
    let ember = C(0xFF8A20), emberL = C(0xFFE070)
    let raise = p.signature.map { v8Arc($0, 0.08, 0.92, edge: 0.18) } ?? 0
    let up = raise > 0.45

    if raise > 0 { stoneBeastSky(c, p, raise) }

    // The back arm, raised to the sky or hanging, a great rock fist at the end.
    c.oy += p.breathe
    if up {
        slayerLine(c, 12, 24, 6, 15, rock, 2.0)
        stoneBeastFist(c, 5, 12, rock, rockL, rockD, crack)
    } else {
        c.rect(9, 24, 5, 10, rock); c.rect(9, 24, 1, 10, rockL); c.rect(13, 26, 1, 8, rockD); c.px(11, 28, crack)
        c.px(10, 29, crack)
        stoneBeastFist(c, 11, 35, rock, rockL, rockD, crack)
    }
    c.oy -= p.breathe
    // Four thick stone legs on clawed feet.
    for (i, lx) in [17, 22, 32, 37].enumerated() {
        let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
        c.rect(lx, 36, 3, bottom - 35, rock); c.rect(lx + 2, 36, 1, bottom - 35, rockD); c.px(lx, 36, rockL)
        c.px(lx + 1, bottom - 3, crack); c.px(lx + 3, bottom, horn)
    }
    c.oy += p.breathe
    // The body: a barrel of rock, broad in the chest and narrower at the hips, the shoulders hunched up in humps.
    c.rect(18, 18, 20, 4, rock); c.rect(16, 21, 24, 1, rock)
    c.rect(14, 22, 28, 11, rock); c.rect(15, 33, 26, 2, rock); c.rect(16, 35, 24, 2, rock); c.rect(17, 37, 22, 1, rockD)
    c.rect(41, 22, 1, 11, rockD); c.rect(40, 33, 1, 2, rockD); c.rect(39, 35, 1, 2, rockD)
    c.rect(14, 22, 1, 11, rockL); c.rect(18, 18, 20, 1, rockL)
    c.rect(11, 20, 3, 1, rock); c.rect(10, 21, 5, 8, rock); c.rect(11, 20, 3, 1, rockL); c.rect(10, 21, 1, 7, rockL)
    c.rect(42, 20, 3, 1, rock); c.rect(41, 21, 5, 8, rock); c.rect(45, 21, 1, 8, rockD); c.rect(42, 20, 3, 1, rockL)
    // Spikes off the shoulder humps, jagged, lit on their leading edge.
    c.pattern(7, 14, [
        "S.......",
        ".S......",
        ".SS..S..",
        "..SS.S..",
        "..SSSSS.",
        "...SSSSS",
    ], ["S": rockD])
    c.px(7, 14, rockL); c.px(8, 15, rockL); c.px(12, 16, rockL)
    c.pattern(41, 14, [
        ".......S",
        "......S.",
        "..S..SS.",
        "..S.SS..",
        ".SSSSS..",
        "SSSSS...",
    ], ["S": rockD])
    c.px(48, 14, rockL); c.px(43, 16, rockL)
    // The horns: black, thick at the brow, sweeping out and then up to pale tips.
    c.pattern(13, 9, [
        "T.......",
        "T.......",
        "HT......",
        "HH......",
        "HH......",
        "HHH.....",
        ".HHH....",
        ".HHHH...",
        "..HHHHH.",
        "...lHHHH",
    ], ["H": horn, "T": hornT, "l": hornL])
    c.pattern(35, 9, [
        ".......T",
        ".......T",
        "......TH",
        "......HH",
        "......HH",
        ".....HHH",
        "....HHH.",
        "...HHHH.",
        ".HHHHH..",
        "HHHHl...",
    ], ["H": horn, "T": hornT, "l": hornL])
    c.px(14, 12, hornL); c.px(14, 13, hornL); c.px(15, 15, hornL)
    // Cracks and slabs across the rock: the brow, the chest, the belly.
    c.pattern(15, 32, [
        "..CC.........CC...........",
        "....CCC....CC..C......CC..",
        ".......C...C.....CCCCC....",
        "..LLL..C..CLLL......C.....",
        ".......C....C.......C.....",
    ], ["C": crack, "L": rockL])
    c.px(20, 20, crack); c.px(21, 20, crack); c.px(33, 19, crack); c.px(34, 20, crack)
    c.px(16, 25, crack); c.px(16, 26, crack); c.px(39, 27, crack); c.px(40, 28, crack)
    // The face: Clawd's own orange in a window of rock, under a massive brow.
    c.rect(19, 23, 18, 9, clawdOrange); c.rect(36, 23, 1, 9, clawdShade)
    c.rect(19, 29, 1, 3, rock); c.rect(20, 31, 1, 1, rock); c.rect(36, 29, 1, 3, rock); c.rect(35, 31, 1, 1, rock)
    c.pattern(18, 22, [
        "RRRRRRRRRRRRRRRRRRRR",
        ".RRRRRRR....RRRRRRR.",
        "..DDDDD......DDDDD..",
    ], ["R": rock, "D": rockDD])
    c.px(19, 22, rockL); c.px(20, 22, rockL); c.px(21, 22, rockL)
    let glow = raise > 0.3
    c.rect(21, 25, 3, 2, ember); c.rect(32, 25, 3, 2, ember)
    c.px(21, 25, emberL); c.px(32, 25, emberL)
    if glow { c.px(22, 25, emberL); c.px(33, 25, emberL) }
    // A rough rock nose, and the wide mouth with stubby stone teeth.
    c.pattern(26, 25, [".RR.", "RRRR", "D..D"], ["R": rock, "D": rockDD])
    c.rect(22, 29, 12, 1, C(0x2A1410))
    if glow { c.rect(23, 30, 10, 1, C(0x6A2A10)); c.rect(22, 29, 12, 1, C(0x1A0A08)) }
    c.px(23, 28, hornT); c.px(32, 28, hornT); c.px(26, 30, hornT); c.px(29, 30, hornT)

    // The front arm: thick rock out to a fist, raised to the sky in the signature.
    let fist = { (x: Int, y: Int) in stoneBeastFist(c, x, y, rock, rockL, rockD, crack) }
    if up {
        slayerLine(c, 42.5, 25, 48, 16, rock, 2.0)
        fist(49, 13)
    } else if let a = p.melee {
        v8Punch(c, from: (42.5, 27), angle: a, trail: p.trail, reach: 8, arm: rock, thick: 2.0, smear: C(0xA0A0AC), fist: fist)
    } else {
        slayerLine(c, 42.5, 27, 46, 32, rock, 2.0)
        fist(47, 34)
    }
}

/// A rock fist centred on (`x`, `y`): a 5×5 knuckled lump, lit on top, a crack across the knuckles.
private func stoneBeastFist(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rock: Px, _ rockL: Px, _ rockD: Px, _ crack: Px) {
    c.rect(x - 2, y - 2, 5, 5, rock); c.rect(x - 2, y - 2, 5, 1, rockL); c.rect(x + 2, y - 1, 1, 4, rockD)
    c.px(x - 1, y + 1, crack); c.px(x, y, crack); c.px(x + 1, y - 1, crack)
}

/// The sky over the Stone Beast darkening while its arms are up: a faint pall of cloud above it (kept faint, so it
/// never dots the outline where it meets the horns) and a few cinders of the rain of fire drifting down at the sides.
private func stoneBeastSky(_ c: PixelCanvas, _ p: Pose, _ k: Double) {
    let pall = PixelCanvas(Sprite.width, Sprite.height)
    let drift = p.t * 1.5
    for i in 0..<9 {
        let fi = Double(i)
        let x = 8 + fi * 7 + sin(drift + fi) * 1.5
        let y = 5 + Double(i % 3) * 2
        pall.circle(Int(x.rounded()), Int(y.rounded()), 3 + i % 2, C(0x120A16))
    }
    c.paste(pall, alpha: 0.22 * k)
    guard k > 0.5 else { return }
    for i in 0..<5 {
        let fi = Double(i)
        let fall = frac(p.t * 0.45 + fi * 0.37)
        let x = (i % 2 == 0 ? 54.0 : 4.0) + fi * 2.5
        let y = 6 + fall * 18
        let a = 0.75 * (1 - fall) * min(1, (k - 0.5) * 3)
        c.px(Int(x.rounded()), Int(y.rounded()), C(0xFF7A20).alpha(a))
        c.px(Int(x.rounded()), Int(y.rounded()) - 1, C(0xFFC060).alpha(a * 0.4))
    }
}

// MARK: - Holts

/// Holts: the vampire hunter out of 1764, brought forward by Sahjhann to hunt Angstel. A long dark-brown greatcoat
/// with a shoulder cape, brass buttons and a high collar, a white stock at his throat; dark hair going grey at the
/// temples, tied back in a queue with a black ribbon; heavy brows and a stubbled jaw; buff breeches into tall black
/// boots. He shoots a heavy wooden crossbow with an iron bow. No signature: Holts doesn't show off.
private func drawHolts(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x4A3426), coatD = C(0x2E2018), coatL = C(0x6C503A), brass = C(0xD0A850)
    let stock = C(0xEEE8DC), stockD = C(0xBEB6A8), breeches = C(0xC4AE84), boot = C(0x1A1614), cuff = C(0x7A5634)
    let hair = C(0x3A2C22), hairD = C(0x261C16), grey = C(0x9A948A), stubble = C(0x9A5A40)

    drawLegs(c, Look(leg: breeches), step: p.step)
    slayerBoots(c, step: p.step, boot, height: 3)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let top = (p.step >= 0 && i % 2 == p.step ? 40 : 41)
            c.rect(lx, top, 2, 1, cuff)   // the boot tops turned down
        }
    }
    c.oy += p.breathe
    // The queue of hair down his back, tied with a black ribbon.
    c.rect(15, 27, 2, 7, hair); c.rect(15, 33, 2, 1, hairD); c.rect(15, 29, 2, 1, ink)
    drawBody(c, Look(arm: coat, eye: ink))
    // The greatcoat: the body to the knees, the tails at the back flaring a little.
    let hem = seatedPose ? 38 : 40
    c.rect(17, 33, 22, hem - 33, coat); c.rect(38, 33, 1, hem - 33, coatD); c.rect(17, 33, 1, hem - 33, coatL)
    if !seatedPose { c.rect(16, 37, 2, 4, coat); c.px(16, 37, coatL); c.rect(17, 40, 2, 1, coatD) }
    c.rect(27, 34, 1, hem - 34, coatD)
    for y in [35, 37] { c.px(29, y, brass) }
    if !seatedPose { c.px(29, 39, brass) }
    // The shoulder cape over it, a little wider than him, and the high collar standing up behind his jaw.
    c.rect(16, 32, 24, 3, coat); c.rect(16, 32, 24, 1, coatL); c.rect(16, 34, 24, 1, coatD)
    c.rect(19, 30, 3, 2, coat); c.rect(34, 30, 3, 2, coat); c.px(19, 30, coatL)
    // The white stock tied at his throat.
    c.rect(25, 32, 6, 2, stock); c.rect(27, 34, 2, 2, stock); c.px(28, 35, stockD); c.px(30, 33, stockD)
    // Heavy brows and a stubbled jaw.
    c.rect(21, 27, 4, 1, hairD); c.rect(31, 27, 4, 1, hairD)
    for x in stride(from: 21, through: 34, by: 2) { c.px(x, 32, stubble) }
    c.px(20, 31, stubble); c.px(35, 31, stubble)
    // Dark hair swept back off the brow, grey at the temples, a few strands loose.
    c.pattern(17, 21, [
        "......H..H.H.......",
        "....HHHHHHHHHHH....",
        "..HHHHHHlHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHH",
        "GHHHHHHHHHHHHHHHHHG",
        "GG.H.............GG",
        "G..................G",
    ], ["H": hair, "l": C(0x5A4636), "G": grey])

    c.oy += p.gunY
    let firing = p.fire.map { frac($0.t / p.firePeriod) < 0.4 } ?? false
    holtsCrossbow(c, cocked: !firing)
    c.rect(38, 33, 3, 3, coat)
}

/// Holts' crossbow, gripped at the hand: a heavy dark wooden stock, an iron bow across its nose, a bolt on top when
/// `cocked`.
private func holtsCrossbow(_ c: PixelCanvas, cocked: Bool) {
    let wood = C(0x6A4628), woodD = C(0x442C18), iron = C(0x6A6E7A), ironD = C(0x464A54), string = C(0xE8E4DC)
    c.rect(37, 33, 12, 2, wood); c.rect(37, 34, 12, 1, woodD); c.rect(38, 35, 2, 2, woodD)
    slayerLine(c, 47.5, 33.5, 45.5, 28.5, iron, 0.9); slayerLine(c, 47.5, 33.5, 45.5, 38.5, ironD, 0.9)
    let back = cocked ? 42.5 : 45.5
    slayerLine(c, 45.5, 28.5, back, 33.5, string, 0.35); slayerLine(c, 45.5, 38.5, back, 33.5, string, 0.35)
    if cocked {
        c.rect(42, 32, 7, 1, slayerStakeWood); c.px(49, 32, slayerStakePoint)
        c.px(42, 31, C(0x8A2A20))
    }
}

// MARK: - Sahjhann

/// Sahjhann: the time-shifting demon who rewrote the prophecy, trapped out of phase with the world. Clawd with his skin
/// gone a deep demon red, bald, his whole face cut with ridged scars, raised and pale along their edges; a black suit
/// over a dark red shirt open at the collar, slate trousers. He fights with his fists. Signature: he flickers, out of
/// phase, see-through and solid again, a few fast stutters either side of a longer fade, and ends solid.
private func drawSahjhann(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0.06, s < 0.94 else { drawSahjhannBody(c, p); return }
    var q = p
    q.signature = nil
    let fig = PixelCanvas(Sprite.width, Sprite.height)
    drawSahjhannBody(fig, q)
    // Short stutters going out, a long see-through hold, short stutters coming back.
    let stutters: [(Double, Double)] = [(0.1, 0.14), (0.18, 0.21), (0.26, 0.74), (0.79, 0.82), (0.86, 0.9)]
    let out = stutters.contains { s >= $0.0 && s < $0.1 }
    guard out else { c.paste(fig, alpha: 1); return }
    let jitter = Int(frac(p.t * 9) * 3) - 1
    c.paste(fig, x: s > 0.3 && s < 0.7 ? 0 : jitter, alpha: 0.32)
    // A faint shimmer of scan lines across him while he's out of phase.
    if s > 0.3 && s < 0.7 {
        let row = 18 + Int(frac(p.t * 1.7) * 24)
        c.rect(17, row, 22, 1, C(0xF4C8C0).alpha(0.18))
    }
}

/// Sahjhann himself (drawn into a canvas of its own and faded for his signature).
private func drawSahjhannBody(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC2402E), skinD = C(0x962C22), scar = C(0x761A14), scarL = C(0xE0806A)
    let suit = C(0x24222A), suitD = C(0x121116), suitL = C(0x403C48), shirt = C(0x7A1A22), slate = C(0x5C5C6C)

    drawLegs(c, Look(leg: slate), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let top = 36, bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx + 1, top, 1, bottom - top, C(0x484856))   // the trouser leg in shadow on its far side
        }
    }
    slayerBoots(c, step: p.step, C(0x0E0D10), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: suit, eye: ink))
    // The bald dome rising above the block.
    c.rect(20, 24, 16, 2, skin); c.rect(22, 23, 12, 1, skin); c.rect(35, 24, 1, 2, skinD)
    c.rect(22, 23, 5, 1, C(0xD85A44))
    // The black suit: jacket over the dark red shirt, lapels lit along their edge.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(25, 33, 6, 5, shirt); c.px(27, 33, skin); c.px(28, 33, skin)
    c.pattern(23, 33, ["LL......LL", ".LL....LL.", "..L....L..", "..L....L.."], ["L": suitL])
    c.px(28, 36, suitD)
    // The scars: ridges down the brow and the dome, curling round the eyes and along the cheeks, pale on their edges.
    c.pattern(19, 23, [
        "......S...S.......",
        ".....LS..LS..L....",
        "....LS..LS..LS....",
        "....S...S...S.....",
    ], ["S": scar, "L": scarL])
    c.pattern(19, 30, ["S...............S.", ".S.............S..", "..S...........S..."], ["S": scar])
    c.px(20, 29, scarL); c.px(35, 29, scarL)
    // Heavy brows over the eyes, and a thin, cruel mouth.
    c.rect(21, 28, 4, 1, scar); c.rect(31, 28, 4, 1, scar); c.px(24, 28, ink); c.px(31, 28, ink)
    c.rect(25, 32, 6, 1, C(0x4A0E0C))

    if let a = p.melee {
        v8Punch(c, from: (39.5, 34), angle: a, trail: p.trail, reach: 6, arm: suit, thick: 1.2, smear: C(0xF0A090)) { x, y in
            c.rect(x - 1, y - 1, 3, 3, skin); c.px(x + 1, y + 1, skinD)
        }
    } else {
        c.rect(38, 36, 2, 1, skin)   // his hand out of the sleeve
    }
}

// MARK: - Illyrya

/// Illyrya: the Old One who hollowed out Fred and wore her shell. Clawd with skin gone pale as marble (only her hair is
/// blue): a choppy chin-length bob, dark at the roots and streaked bright blue, strands breaking loose; a flat,
/// unblinking stare; tight red-and-black armour, segmented, with red shoulder plates and a high black collar; red
/// leggings into black boots. She fights hand to hand. Signature: she slows time round her, a palm held out, a
/// silvery shimmer rippling slowly out from her while specks of dust hang still in the air, and lets it go.
private func drawIllyrya(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE8E4EA), skinD = C(0xBEB8C6), black = C(0x1A1418), blackL = C(0x3A2E36)
    let red = C(0xA01C2A), redD = C(0x6A101A), redL = C(0xD03A44)
    let hair = C(0x2E1A22), blue = C(0x2C78E0), blueL = C(0x6AB4FF)
    let slow = p.signature.map { v8Arc($0, 0.08, 0.92, edge: 0.15) } ?? 0

    if slow > 0, let s = p.signature { illyryaShimmer(c, s, slow) }

    drawLegs(c, Look(leg: red), step: p.step)
    slayerBoots(c, step: p.step, black, height: 3)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let top = p.step >= 0 && i % 2 == p.step ? 39 : 40
            c.px(lx, top - 2, redL)   // a gleam on the leather
        }
    }
    c.oy += p.breathe
    let palm = slow > 0.3
    drawBody(c, Look(body: skin, shade: skinD, arm: black, eye: ink), armRight: palm ? 6 : 0)
    // The armour: a red cuirass in segments edged black, black at the sides, red plates on the shoulders.
    c.rect(18, 33, 20, 5, black); c.rect(18, 37, 20, 1, C(0x0E0A0C))
    c.rect(21, 33, 14, 5, red); c.rect(21, 33, 14, 1, redL); c.rect(34, 34, 1, 4, redD)
    c.rect(21, 35, 14, 1, black); c.rect(27, 33, 2, 5, black); c.px(21, 36, redL)
    c.rect(15, 32, 4, 2, red); c.rect(15, 32, 4, 1, redL); c.rect(37, 32, 4, 2, red); c.rect(37, 32, 3, 1, redL)
    c.rect(40, 32, 1, 2, redD)
    // The high black collar.
    c.rect(24, 32, 8, 1, black); c.px(24, 31, blackL); c.px(31, 31, blackL)
    // A flat stare and a thin, unsmiling mouth.
    c.rect(22, 28, 2, 1, skinD); c.rect(32, 28, 2, 1, skinD)
    c.rect(26, 32, 4, 1, C(0x9A8A98))
    if palm { c.px(23, 29, white); c.px(33, 29, white) }
    // The choppy bob: dark roots, bright blue streaks, jagged ends at her jaw and strands breaking loose on top.
    c.pattern(16, 19, [
        "......B.....H..b........",
        "....HHBHHHHHHHHbHHB.....",
        "...HHHBbHHHHHHHbBHHBH...",
        "..HHHHHbBHHHHHHHbBHHHH..",
        ".HHBHHHHbBHHHHHHHbHHBHH.",
        ".HHBHHHHHbHHHHHHHHbHBHH.",
        ".HBBHH.H.....H.....HBBH.",
        ".HBbH..............HbBH.",
        ".HBbH...............bBH.",
        ".HBb................bB..",
        ".HB.................BH..",
        "..B..................B..",
    ], ["H": hair, "B": blue, "b": blueL])
    if palm {
        // A hand held up, palm out, where the shimmer starts.
        c.rect(38, 28, 3, 3, black)
        c.pattern(40, 24, [".S.S", ".SSS", "SSSS", ".SS."], ["S": skin])
        if slow > 0.6 { c.px(43, 23, white.alpha(0.7 * slow)) }
        return
    }
    if let a = p.melee {
        v8Punch(c, from: (39.5, 34), angle: a, trail: p.trail, reach: 6, arm: black, thick: 1.2, smear: C(0xE8E4F0)) { x, y in
            c.rect(x - 1, y - 1, 3, 3, skin); c.px(x + 1, y + 1, skinD)
        }
    } else {
        c.rect(38, 36, 2, 1, skin)
    }
}

/// Time slowing round Illyrya, `s` through her signature, `k` how strong: faint silver rings rippling slowly outwards
/// from her raised palm, and specks of dust hanging still in the air.
private func illyryaShimmer(_ c: PixelCanvas, _ s: Double, _ k: Double) {
    let silver = C(0xE8ECF4)
    let centre = (x: 32.0, y: 30.0)
    for i in 0..<3 {
        let r = frac(s * 1.4 + Double(i) / 3)
        let rx = 6 + r * 22, ry = 4 + r * 13
        let a = 0.22 * (1 - r) * k
        var t = 0.0
        while t < 2 * .pi {
            let x = Int((centre.x + cos(t) * rx).rounded()), y = Int((centre.y + sin(t) * ry).rounded())
            if x >= 2 && x <= 69 && y >= 2 && y <= 44 { c.px(x, y, silver.alpha(a)) }
            t += .pi / 48
        }
    }
    // The dust, frozen where it was.
    for (x, y) in [(8, 14), (13, 7), (52, 9), (60, 18), (57, 30), (6, 26), (47, 41), (11, 40)] {
        c.px(x, y, silver.alpha(0.55 * k))
    }
}

// MARK: - Skipp

/// Where Skipp's blade arm swings from: his hand, out in front of his big body.
private let v8SkippHand: (x: Double, y: Double) = (45.0, 33.0)

/// Skipp: the cheerful demon guide of the Powers That Be, bones on the outside. A big Clawd in deep plum hide under an
/// ivory exoskeleton: a crest of bone spikes swept back over his head, domed bone plates on his shoulders, banded
/// bone across his chest and on his shins; Clawd's own orange face shows in a bone mask. His front forearm ends in a
/// long curved bone blade, always there, at rest pointed at the ground. Blows bounce off him. No signature.
private func drawSkipp(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x6E2E54), hideD = C(0x4A1C38), hideL = C(0x8E4A72)
    let bone = C(0xE2D6BA), boneD = C(0xAE9E80), boneL = C(0xF8F0DE), boneDD = C(0x7E6E56)

    // The back arm: plum hide, a bone bracer, a three-clawed hand.
    c.oy += p.breathe
    c.rect(11, 26, 4, 10, hide); c.rect(11, 26, 1, 10, hideL); c.rect(14, 28, 1, 8, hideD)
    c.rect(10, 30, 5, 3, bone); c.rect(10, 30, 5, 1, boneL); c.rect(14, 31, 1, 2, boneD)
    c.pattern(10, 36, ["B.B.B"], ["B": bone])
    c.oy -= p.breathe
    // Four plum legs with bone shin plates and bone toes.
    for (i, lx) in [17, 22, 32, 37].enumerated() {
        let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
        c.rect(lx, 36, 3, bottom - 35, hide); c.rect(lx + 2, 36, 1, bottom - 35, hideD)
        c.rect(lx, bottom - 4, 3, 2, bone); c.px(lx, bottom - 4, boneL); c.px(lx + 2, bottom - 3, boneD)
        c.px(lx + 3, bottom, bone)
    }
    c.oy += p.breathe
    // The body: big, plum, a little narrower at the hips.
    c.rect(17, 20, 22, 2, hide); c.rect(15, 22, 26, 15, hide); c.rect(17, 37, 22, 1, hideD)
    c.rect(40, 22, 1, 15, hideD); c.rect(15, 22, 1, 14, hideL)
    // His ribs in bone: a breastbone down the middle, short curved ribs off it either side.
    c.rect(27, 32, 2, 5, bone); c.px(27, 32, boneL)
    c.pattern(19, 32, [
        "RRRRRRRR..RRRRRRRR",
        "R................R",
        ".RRRRRRR..RRRRRRR.",
        ".R..............R.",
        "..RRRRRR..RRRRRR..",
    ], ["R": bone])
    c.px(19, 32, boneL); c.px(35, 34, boneD); c.px(34, 36, boneD)
    // The crest: bone spikes rising off the head and swept back.
    c.pattern(16, 12, [
        "BB............",
        ".BBB...BB.....",
        "..BBB...BBB...BB",
        "..BBBB..BBBB..BBB",
        "...BBBBB.BBBB.BBBB",
        "....BBBBBBBBBBBBBB",
        ".....LLLLLLLLLLLLLL",
        "......BBBBBBBBBBBBB",
    ], ["B": bone, "L": boneL])
    c.px(16, 12, boneL); c.px(23, 13, boneL); c.px(30, 14, boneL)
    for x in [21, 25, 29, 33] { c.px(x, 17, boneD) }
    // Clawd's orange face, under a bone brow that dips to a point over the nose, bone plates on the cheeks.
    c.rect(19, 22, 18, 10, clawdOrange); c.rect(36, 22, 1, 10, clawdShade)
    c.pattern(18, 21, [
        "BBBBBBBBBBBBBBBBBBBB",
        "BLLLLLLLLLLLLLLLLLLB",
        ".BBDDB...BB...BDDBB.",
        "..B.......D.......B.",
    ], ["B": bone, "L": boneL, "D": boneD])
    c.rect(22, 26, 2, 3, ink); c.rect(32, 26, 2, 3, ink); c.px(22, 26, white); c.px(32, 26, white)
    c.rect(24, 30, 8, 1, C(0x5A2418)); c.px(23, 29, C(0x5A2418)); c.px(32, 29, C(0x5A2418))
    c.pattern(18, 28, ["B.................B", "BB...............BB", "BBB.............BBD", "BBBB...........BBDD"],
              ["B": bone, "D": boneD])
    // Domed bone plates on the shoulders, each with a short spike.
    c.pattern(11, 20, [".....B", "..BBBB", ".BLLBBB", "BLBBBBB", "BBBBBBD", "BBBBBDD", ".DDDDD."],
              ["B": bone, "L": boneL, "D": boneD])
    c.pattern(38, 20, ["B.....", "BBBB..", "BLBBBB.", "LBBBBBB", "BBBBBBD", "BBBBBDD", ".DDDDD."],
              ["B": bone, "L": boneL, "D": boneD])
    c.px(11, 26, boneDD); c.px(44, 25, boneDD)

    // The front arm and its blade.
    let shoulder = (x: 40.5, y: 28.0)
    if let m = p.melee {
        let a = v8Front(m, lo: -110, hi: 75)
        slayerSmear(c, shoulder, p.trail.map { v8Front($0, lo: -110, hi: 75) }, from: 6, to: 16, C(0xFFF6E4))
        let hand = slayerReach(shoulder, a, 4.5)
        slayerLine(c, shoulder.x, shoulder.y, hand.x, hand.y, hide, 1.4)
        skippBlade(c, hand, a, bone: bone, boneD: boneD, boneL: boneL, boneDD: boneDD)
    } else {
        let hand = (x: 44.0, y: 32.0)
        slayerLine(c, shoulder.x, shoulder.y, hand.x, hand.y, hide, 1.4)
        skippBlade(c, hand, 55, bone: bone, boneD: boneD, boneL: boneL, boneDD: boneDD)
    }
}

/// Skipp's bone blade growing out of his forearm at `h`, along `angle`: a bracer where it grows from, a long blade
/// with a dark spine, a hook curling back near its base, and a sharp pale point.
private func skippBlade(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, bone: Px, boneD: Px, boneL: Px,
                        boneDD: Px) {
    slayerBar(c, h, angle, from: 0, to: 9.5, boneD, r: 1.2)
    slayerBar(c, h, angle, from: 0, to: 9, bone, r: 0.8)
    slayerBar(c, h, angle, from: 1, to: 8, boneL, r: 0.3)
    let hook0 = slayerReach(h, angle, 2.5), hook1 = slayerReach(hook0, angle - 130, 3)
    slayerLine(c, hook0.x, hook0.y, hook1.x, hook1.y, boneD, 0.6)
    let tip = slayerReach(h, angle, 11)
    c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), boneL)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, bone)
    c.px(Int(h.x.rounded()) + 1, Int(h.y.rounded()) + 1, boneDD)
}
