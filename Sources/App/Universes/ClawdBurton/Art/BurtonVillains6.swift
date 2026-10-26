import Foundation

// Villains: Frankenweenie. From New Holland, in the film's greys: Edgar "E" Gorr, Nassorr, Toshiakki and Weird Gurl,
// the classmates who copy Victor's experiment, and the monsters it makes: Mr. Whiskerz the vampire cat, Shellee the
// kaiju turtle, Colossuss the mummy hamster and the Were-Rat.

let burtonVillains6: [BurtonVillain: Persona] = [
    .edgarGorr: Persona(name: "Edgar \"E\" Gorr", weapon: .blaster, shot: .thrown(C(0xF4F4F4)), muzzle: (45, 27),
                        headTop: 21, signature: 3.4, draw: drawEdgar),
    .nassorr: Persona(name: "Nassorr", weapon: .blaster, shot: .thrown(C(0x9A9A9A)), muzzle: (45, 27), headTop: 15,
                      signature: 3.0, draw: drawNassorr),
    .toshiakki: Persona(name: "Toshiakki", weapon: .blaster, shot: .thrown(C(0xC8CCD4)), muzzle: (43, 22), headTop: 20,
                        signature: 3.6, draw: drawToshiakki),
    .weirdGurl: Persona(name: "Weird Gurl", weapon: .blaster, shot: .thrown(C(0x9A9A9A)), muzzle: (44, 27), headTop: 20,
                        signature: 3.2, draw: drawWeirdGurl),
    .mrWhiskerz: Persona(name: "Mr. Whiskerz", weapon: .saber, motion: .fly, pivot: whiskerzMouth, headTop: 18,
                         signature: 3.0, draw: drawMrWhiskerz),
    .shellee: Persona(name: "Shellee", weapon: .saber, armoured: true, canSit: false, pivot: shelleeFoot, bulk: 5,
                      headTop: 16, signature: 3.6, draw: drawShellee),
    .colossuss: Persona(name: "Colossuss", weapon: .saber, pivot: colossussMouth, headTop: 21, signature: 3.2,
                        draw: drawColossuss),
    .wereRat: Persona(name: "The Were-Rat", weapon: .saber, bulk: 4, headTop: 16, signature: 3.0, draw: drawWereRat),
]

/// Mr. Whiskerz's jaws: he bites from there.
private let whiskerzMouth = (x: 41.5, y: 29.5)
/// Shellee's front foot: she stomps from there.
private let shelleeFoot = (x: 40.5, y: 40.5)
/// Colossuss's buck teeth: it bites from there.
private let colossussMouth = (x: 39.5, y: 31.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// A hand raised from the shoulder at (`sx`, 34) to (`hx`, `hy`): a sleeve and a 2×2 hand.
private func raisedHand(_ c: PixelCanvas, from sx: Double, _ hx: Int, _ hy: Int, sleeve: Px, hand: Px) {
    burtonLine(c, sx, 34, Double(hx) + 1, Double(hy) + 2, sleeve, 1.1)
    c.rect(hx, hy, 2, 2, hand)
}

/// Little pixel capitals, 3×5 each with a gap, in `col` from (x, y): "HEE", "AHH!".
private func shout(_ c: PixelCanvas, _ text: String, x: Int, y: Int, _ col: Px) {
    let glyphs: [Character: [String]] = [
        "H": ["H.H", "H.H", "HHH", "H.H", "H.H"], "E": ["HHH", "H..", "HH.", "H..", "HHH"],
        "A": [".H.", "H.H", "HHH", "H.H", "H.H"], "!": ["H", "H", "H", ".", "H"],
    ]
    var cx = x
    for ch in text {
        guard let g = glyphs[ch] else { cx += 4; continue }
        c.pattern(cx, y, g, ["H": col])
        cx += g[0].count + 1
    }
}

/// Claws at the end of an arm swung along `angle` from `Sprite.hand`, three of them, with slashes where a fast swing
/// just was.
private func claws(_ c: PixelCanvas, angle a: Double, trail: [Double], arm: Px, claw: Px) {
    for (i, ta) in trail.enumerated() {
        for o in [-1.5, 0, 1.5] {
            let s = burtonReach(Sprite.hand, ta, 6), e = burtonReach(Sprite.hand, ta + o * 6, 11)
            c.glowLine(s.x, s.y, e.x, e.y, core: claw, glow: claw, coreR: 0.3, glowR: 1, strength: 0.35 / Double(i + 1))
        }
    }
    let h = burtonReach(Sprite.hand, a, 5)
    burtonLine(c, Sprite.hand.x - 2, Sprite.hand.y, h.x, h.y, arm, 1.2)
    for o in [-1.0, 0, 1] {
        let e = burtonReach(h, a + o * 18, 3)
        burtonLine(c, h.x, h.y, e.x, e.y, claw, 0.45)
    }
}

/// Dust kicked up round (x, 43) as something lands heavily, `k` 0…1 through it.
private func dust(_ c: PixelCanvas, x: Double, _ k: Double) {
    guard k > 0, k < 1 else { return }
    for s in [-1.0, 1.0] {
        let d = 2 + k * 5
        c.glowLine(x + s * d, 42.5 - k * 2, x + s * d, 42.5 - k * 2, core: C(0xD8D8D0, 0.6 * (1 - k)),
                   glow: C(0xB8B8B0, 0.4 * (1 - k)), coreR: 1, glowR: 2)
    }
}

// MARK: - Edgar "E" Gorr

/// Edgar "E" Gorr: Victor's hunched classmate, in greys: a grey Clawd stooped under a hump on his back, lank black
/// hair, one eye bigger than the other and a crooked grin full of bad teeth, a dark sweater. He throws his
/// lightning-charged invisible goldfish, a crackling blob of water. Signature: he holds up its bowl to show it off:
/// an empty bowl of water, and a bubble rising in it.
private func drawEdgar(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xBDBDBD), skinD = C(0x959595), sweater = C(0x505056), sweaterD = C(0x3A3A40)
    let hair = C(0x1C1C20), hairL = C(0x44444C), tooth = C(0xE6E6DA), toothD = C(0xA8A898)
    let sig = p.signature
    let showing = sig.map { $0 > 0.08 && $0 < 0.88 } ?? false

    drawLegs(c, Look(leg: C(0x404046)), step: p.step)
    burtonBoots(c, step: p.step, C(0x141416), height: 1)
    c.oy += p.breathe + 1
    // The hump on his back, under the sweater.
    c.pattern(13, 25, ["...SSS", ".SSSSS", "SSSSSS", "SSSSSS", "SSSSSS", "SSSSSS", ".SSSSS", "..SSSS"], ["S": sweater])
    drawBody(c, Look(body: skin, shade: skinD, arm: sweater, eye: nil))
    // One eye small, the other big and staring; the crooked grin with its bad teeth.
    c.rect(22, 29, 2, 2, burtonInk); c.rect(31, 28, 3, 3, burtonInk); c.px(31, 28, C(0xFFFFFF))
    c.pattern(21, 31, ["K.........", ".KTKTTKTKK", "..KKKKKK.."], ["K": burtonInk, "T": tooth])
    c.px(25, 32, toothD)
    c.rect(18, 33, 20, 5, sweater); c.rect(37, 33, 1, 5, sweaterD); c.rect(18, 37, 20, 1, sweaterD)
    for x in stride(from: 19, to: 37, by: 2) { c.px(x, 36, sweaterD) }
    // Lank black hair, parted and flattened down over his brow.
    c.pattern(17, 21, [
        "...HHHHHHHHHHHHHHH....",
        ".HHHHHHHhHHHHHHHHHHH..",
        ".HHHHHHHhHHHHHHHHHHHH.",
        ".HHHH...HHHHHHHHHHHHH.",
        ".HH.......HHH....HHHH.",
        ".H.................HH.",
    ], ["H": hair, "h": hairL])
    if showing, let s = sig {
        // The goldfish bowl held up: water and glass, nothing in it, a bubble going up.
        raisedHand(c, from: 39.5, 42, 29, sleeve: sweater, hand: skin)
        c.pattern(38, 20, ["GGGGGGGGG", ".G.....G.", "G.......G", "GwwwwwwwG", "GwwwwwwwG", "GwwwwwwwG", ".GwwwwwG.",
                           "..GGGGG.."], ["G": C(0xD8D8DC), "w": C(0xB8C0C8, 0.45)])
        let b = frac((s - 0.08) * 3.4)
        c.pattern(42 + Int((sin(b * 9) * 1).rounded()), 26 - Int(b * 4), [".W.", "W.W", ".W."],
                  ["W": C(0xFFFFFF, 0.85)])
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // The crackling blob of charged water in his raised hand.
        c.oy += p.gunY
        raisedHand(c, from: 39.5, 41, 30, sleeve: sweater, hand: skin)
        c.glowLine(42.5, 27.5, 42.5, 27.5, core: C(0xF4F4F4, 0.85), glow: C(0xC0C0C8, 0.5), coreR: 2, glowR: 3.4)
        for i in 0..<2 {
            let n = Int(p.t * 14) * 3 + i, a = noise(n) * 360, e = burtonReach((42.5, 27.5), a, 4)
            c.glowLine(42.5, 27.5, e.x, e.y, core: C(0xFFFFFF, 0.9), glow: C(0xA8A8B0, 0.4), coreR: 0.35, glowR: 1)
        }
    }
}

// MARK: - Nassorr

/// Nassorr: the tall, gloomy classmate, in greys: a grey Clawd under a tall black flat-top, a heavy dark brow over
/// deep-set eyes, a down-turned mouth and a black turtleneck. He throws a sparking hamster ball. Signature: "Ahh!",
/// both arms flung up dramatically, his mouth wide open.
private func drawNassorr(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xB2B2B2), skinD = C(0x8C8C8C), hair = C(0x18181C), hairL = C(0x3A3A42), neck = C(0x2A2A30)
    let neckL = C(0x44444C)
    let sig = p.signature
    let ahh = sig.map { $0 > 0.12 && $0 < 0.86 } ?? false

    drawLegs(c, Look(leg: C(0x34343A)), step: p.step)
    burtonBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: neck, eye: nil))
    // The heavy brow and deep-set eyes; the mouth turned down, or wide open.
    c.rect(20, 27, 16, 2, C(0x3A3A40))
    c.rect(22, 29, 2, 3, burtonInk); c.rect(32, 29, 2, 3, burtonInk)
    if ahh { c.pattern(25, 30, [".KKKKK.", "KKKKKKK", "KKKKKKK"], ["K": C(0x1E1012)]) }
    else { c.pattern(24, 31, [".KKKKKK.", "K......K"], ["K": C(0x404046)]) }
    // The black turtleneck, its rolled collar.
    c.rect(18, 33, 20, 5, neck); c.rect(18, 33, 20, 1, neckL); c.rect(37, 34, 1, 4, C(0x1E1E22))
    // The tall flat-top: dead flat on top, straight down the sides.
    c.rect(19, 17, 18, 8, hair); c.rect(19, 17, 18, 1, hairL); c.rect(18, 24, 20, 3, C(0x4A4A52))
    c.rect(18, 25, 1, 3, C(0x4A4A52)); c.rect(37, 25, 1, 3, C(0x4A4A52))
    if ahh, let s = sig {
        raisedHand(c, from: 16.5, 12, 20, sleeve: neck, hand: skin)
        raisedHand(c, from: 39.5, 42, 20, sleeve: neck, hand: skin)
        let a = min(ramp(s, 0.18, 0.26), 1 - ramp(s, 0.78, 0.86))
        shout(c, "AHH!", x: 46, y: 9, C(0xFFFFFF, 0.85 * a))
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // The hamster ball held up: a see-through ball, a grey hamster in it, sparks crackling round it.
        c.oy += p.gunY
        raisedHand(c, from: 39.5, 41, 30, sleeve: neck, hand: skin)
        for k in 0..<28 {
            let a = Double(k) / 28 * 2 * .pi
            c.px(43 + Int((cos(a) * 3.6).rounded()), 26 + Int((sin(a) * 3.6).rounded()), C(0xE0E0E8, 0.7))
        }
        c.pattern(41, 26, [".HH.", "HHHH"], ["H": C(0x8A8A8E)]); c.px(43, 26, burtonInk)
        if Int(p.t * 10) % 2 == 0 { c.pattern(46, 21, ["W.", ".W"], ["W": C(0xFFFFFF, 0.9)]) }
    }
}

// MARK: - Toshiakki

/// Toshiakki: the competitive classmate, in greys: a grey Clawd with neat black hair, a sharp side parting and a dead
/// straight fringe, narrowed eyes under slanted brows in a competitive glare, a dark school blazer over a white
/// collar. He fires bottle rockets. Signature: he holds up a bottle with a rocket in it; it fizzes, shoots up into
/// the sky on a smoke trail and pops.
private func drawToshiakki(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xBABABA), skinD = C(0x929292), hair = C(0x141418), hairL = C(0x46464E), blazer = C(0x34343A)
    let blazerD = C(0x24242A), silver = C(0xC8CCD4), silverD = C(0x8A8E98), glass = C(0x9AA0A8)
    let sig = p.signature
    let holding = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: C(0x2E2E34)), step: p.step)
    burtonBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: blazer, eye: nil))
    // The glare: narrowed eyes, brows slanting down to his nose, a set mouth.
    c.rect(22, 29, 2, 2, burtonInk); c.rect(32, 29, 2, 2, burtonInk)
    c.pattern(20, 27, ["KK..........KK", "..KK......KK.."], ["K": hair])
    c.rect(26, 32, 4, 1, C(0x5A5A5E))
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD)
    c.rect(23, 33, 10, 1, C(0xF0F0F0)); c.px(28, 35, silverD)
    // Neat black hair, the parting sharp, the fringe dead straight.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHHhhHHHHHHHHHHH..",
        ".HHHHHHH.HHHHHHHHHHHH.",
        ".HHHHHHH.hHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairL])
    if holding, let s = sig {
        // The bottle held up, the rocket in it fizzing, then away up into the sky and popping.
        raisedHand(c, from: 39.5, 41, 30, sleeve: blazer, hand: skin)
        c.pattern(41, 24, [".G.", ".G.", "GGG", "GGG", "GGG", "GGG"], ["G": glass])
        let up = ramp(s, 0.42, 0.66), ry = 17 - up * 14
        if s < 0.42 && frac(p.t * 8) < 0.5 { c.px(41, 25, C(0xFFFFFF, 0.9)); c.px(43, 24, C(0xFFFFFF, 0.9)) }
        if up < 1 {
            if up > 0 {
                for i in 0..<6 {   // the smoke trail
                    let y = ry + 6 + Double(i) * 2
                    guard y < 24 else { break }
                    c.glowLine(42.5, y, 42.5, y, core: C(0xD8D8D8, 0.4 * (1 - Double(i) / 6)), glow: C(0, 0),
                               coreR: 1 + Double(i) * 0.2, glowR: 1.1 + Double(i) * 0.2)
                }
            }
            c.pattern(41, Int(ry.rounded()), [".T.", "SSS", "SSS", "SSS", ".K.", ".K.", ".K."],
                      ["T": silverD, "S": silver, "K": C(0x6A6A70)])
        } else if s < 0.82 {
            let k = ramp(s, 0.66, 0.82)
            for i in 0..<8 {
                let a = Double(i) / 8 * 2 * .pi, d = 1 + k * 5
                c.glowLine(42.5 + cos(a) * d, 4 + sin(a) * d * 0.8, 42.5 + cos(a) * d, 4 + sin(a) * d * 0.8,
                           core: C(0xFFFFFF, 0.9 * (1 - k)), glow: C(0xB8B8C0, 0.5 * (1 - k)), coreR: 0.5, glowR: 1.4)
            }
        }
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // A bottle rocket raised to fire.
        c.oy += p.gunY
        raisedHand(c, from: 39.5, 41, 30, sleeve: blazer, hand: skin)
        c.pattern(41, 21, [".T.", "SSS", "SSS", "SSS", ".K.", ".K.", ".K."],
                  ["T": silverD, "S": silver, "K": C(0x6A6A70)])
    }
}

// MARK: - Weird Gurl

/// A white fluffy cat curled in someone's arms, 16 wide and 7 tall from (x, y), its head on the right; `stare`: eyes
/// wide open and unblinking.
private func heldCat(_ c: PixelCanvas, x: Int, y: Int, stare: Bool) {
    c.pattern(x, y, [
        "...........W..W.",
        "..........WWWWWW",
        stare ? ".WWWWWWWWWWKKWKK" : ".WWWWWWWWWWKWWKW",
        stare ? "WWWWWWWWWWWKKWKK" : "WWWWWWWWWWWWWWWW",
        "WWWWWWWWWWWWWNWW",
        "WWWWWWWWWWWWWWW.",
        ".SSSSSSSSSSSSS..",
    ], ["W": C(0xF2F2F2), "S": C(0xC4C4C4), "K": burtonInk, "N": C(0x8A8A8E)])
}

/// Weird Gurl: the strange girl, in greys: a grey Clawd with huge round staring eyes, long straight hair and a heavy
/// fringe, a dark dress, and Mr. Whiskerz, her white cat, always in her arms. She throws static-charged fur-balls.
/// Signature: she holds Mr. Whiskerz up high, and he stares.
private func drawWeirdGurl(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8C8C8), skinD = C(0xA0A0A0), hair = C(0x8E8E92), hairD = C(0x6E6E72), dress = C(0x2C2C32)
    let dressD = C(0x1E1E24)
    let sig = p.signature
    let up = sig.map { min(ramp($0, 0.08, 0.22), 1 - ramp($0, 0.8, 0.94)) } ?? 0

    drawLegs(c, Look(leg: C(0x3A3A40)), step: p.step)
    burtonBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    c.rect(17, 38, 22, seatedPose ? 1 : 2, dress)
    drawBody(c, Look(body: skin, shade: skinD, arm: dress, eye: nil))
    // The huge round eyes.
    for ex in [19, 31] {
        c.pattern(ex, 27, [".WWWW.", "WWWWWW", "WWKKWW", "WWKKWW", "WWWWWW", ".WWWW."],
                  ["W": C(0xF8F8F8), "K": burtonInk])
    }
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD)
    // Long straight hair, the fringe down to her eyes.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHdHdHdHdHdHdHdHdHHHH.",
    ] + Array(repeating: ".HHH................HHH.", count: 8) + [
        ".HHd................dHH.",
    ], ["H": hair, "d": hairD])
    if up > 0 {
        // Mr. Whiskerz held up high in both hands, staring.
        let cy = 33 - Int((up * 20).rounded())
        raisedHand(c, from: 16.5, 18, cy + 5, sleeve: dress, hand: skin)
        raisedHand(c, from: 39.5, 36, cy + 5, sleeve: dress, hand: skin)
        heldCat(c, x: 20, y: cy, stare: up > 0.9)
        return
    }
    heldCat(c, x: 25, y: 32, stare: false)
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // A fur-ball in her raised hand, crackling with static.
        c.oy += p.gunY
        raisedHand(c, from: 39.5, 41, 30, sleeve: dress, hand: skin)
        c.circle(42, 27, 2, C(0xA8A8AC)); c.px(41, 26, C(0xD0D0D4))
        if Int(p.t * 12) % 2 == 0 { c.pattern(45, 23, ["W.W", ".W."], ["W": C(0xFFFFFF, 0.9)]) }
    }
}

// MARK: - Mr. Whiskerz

/// Mr. Whiskerz: Weird Gurl's cat, brought back as a vampire with bat wings, in greys: a white fluffy cat the size of
/// Clawd on four legs, pointed ears, dark rings round his eyes, two fangs, and black bat wings folded on his back. He
/// flies, and bites. Signature: he spreads his wings, flaps them, and hisses, fangs bared.
private func drawMrWhiskerz(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xEEEEEE), furD = C(0xC2C2C2), wing = C(0x34343C), wingL = C(0x56565F), fang = C(0xFFFFFF)
    let sig = p.signature
    let flapping = p.flying || (sig.map { $0 > 0.1 && $0 < 0.9 } ?? false)
    let hiss = (sig.map { $0 > 0.25 && $0 < 0.85 } ?? false) || (p.melee.map { $0 < -25 } ?? false)

    if p.flying {
        if !seatedPose { for lx in [20, 24, 30, 34] { c.rect(lx, 38, 3, 2, fur) } }
    } else {
        drawLegs(c, Look(leg: fur), step: p.step)
    }
    c.oy += p.breathe
    // The wings: folded on his back, or spread and flapping.
    if flapping {
        let th = -125 - 35 * sin(p.t * 16)
        for (s, col, d) in [((29.0, 29.0), wingL, 0.8), ((26.0, 30.0), wing, 1.0)] {
            let t = burtonReach(s, th + 8, 19 * d), m1 = burtonReach(s, th - 22, 15 * d)
            let m2 = burtonReach(s, th - 50, 12 * d)
            let root = (s.0 - 5, s.1 + 1)
            burtonTriangle(c, s, (t.x, t.y), (m1.x, m1.y), col); burtonTriangle(c, s, (m1.x, m1.y), (m2.x, m2.y), col)
            burtonTriangle(c, s, (m2.x, m2.y), root, col)
        }
    } else {
        burtonTriangle(c, (20, 30), (31, 30), (17, 21), wing); burtonTriangle(c, (17, 21), (20, 30), (14, 27), wing)
        burtonLine(c, 18, 23, 24, 29, wingL, 0.4)
    }
    // The tail curling up behind; the fluffy body.
    burtonLine(c, 18, 33, 13, 30, fur, 1.0); burtonLine(c, 13, 30, 13, 25, fur, 1.0)
    c.rect(17, 30, 19, 8, fur); c.rect(17, 37, 19, 1, furD); c.rect(19, 29, 13, 1, fur)
    // The head: pointed ears, dark-ringed eyes, a little nose, fangs.
    c.pattern(30, 20, [
        ".EE......EE.",
        ".EEE....EEE.",
        "FFFFFFFFFFFF",
        "FFFFFFFFFFFFF",
        "FRRRFFFFRRRF.",
        "FRKRFFFFRKRF.",
        "FRRRFFFFRRRF.",
        "FFFFFNNFFFFF.",
        "FFFFFFFFFFFF.",
        ".FFFFFFFFFF..",
    ], ["F": fur, "E": furD, "R": C(0x6A6A72), "K": burtonInk, "N": C(0x8A8A90)])
    if hiss {
        c.pattern(33, 28, ["KKKKKK", "WKKKKW", ".KKKK."], ["K": C(0x2A1E20), "W": fang])
    } else {
        c.pattern(33, 28, ["W....W"], ["W": fang])
    }
}

// MARK: - Shellee

/// Shellee: a pet turtle grown into a kaiju, in greys: a domed grey shell a size bigger than Clawd, plated and
/// ridged with spikes, her head reaching out in front with a heavy brow and a toothy mouth, four stumpy elephant legs,
/// a stub of a tail. Shots bounce off her shell. She stomps. Signature: she roars at the sky, then stomps, left,
/// right, the ground shaking.
private func drawShellee(_ c: PixelCanvas, _ p: Pose) {
    let shell = C(0x7A7A80), shellD = C(0x5A5A60), shellL = C(0x9A9AA0), plate = C(0x48484E), skin = C(0xA8A8A8)
    let skinD = C(0x868686), spike = C(0x34343A), belly = C(0xC8C8C0)
    let sig = p.signature
    let roaring = sig.map { $0 > 0.08 && $0 < 0.46 } ?? false
    let stomping = sig.map { $0 >= 0.5 && $0 < 0.92 } ?? false
    // Which foot is up, and how high: a stomp swung on `p.melee`, or her signature's left-right stomping.
    var lift = [0, 0, 0, 0], landed = -1.0
    if let a = p.melee { lift[3] = Int((max(0, min(1, -a / 70)) * 5).rounded()); if a > -10 { landed = 0.5 } }
    if stomping, let s = sig {
        let ph = ramp(s, 0.5, 0.92) * 4, beat = Int(ph), f = ph - Double(beat)
        lift[beat % 2 == 0 ? 3 : 0] = Int((sin(min(1, f / 0.6) * .pi) * 5).rounded())
        if f > 0.6 { landed = (f - 0.6) / 0.4; c.ox += Int(p.t * 30) % 2 == 0 ? 1 : -1 }
    }
    // The four stumpy legs, toenails at their feet.
    for (i, lx) in [16, 22, 30, 36].enumerated() {
        let walkLift = p.step >= 0 && i % 2 == p.step ? 1 : 0
        let up = max(lift[i], walkLift)
        c.rect(lx, 35 - up, 5, 9, skin); c.rect(lx + 4, 35 - up, 1, 9, skinD)
        c.rect(lx, 43 - up, 5, 1, skinD); c.px(lx + 1, 43 - up, belly); c.px(lx + 3, 43 - up, belly)
    }
    c.oy += p.breathe
    // The tail; the head and neck reaching out in front, raised to roar.
    burtonTriangle(c, (15, 32), (15, 36), (9, 37), skin)
    let hy = roaring ? -3 : 0
    c.rect(36, 27 + hy, 6, 7, skin)
    c.pattern(39, 21 + hy, [
        "...SSSSSS...",
        ".SSSSSSSSSS.",
        "BBBBBBBBSSSS",
        "SSSKWSSSSSSS",
        "SSSKKSSSSSSN",
        "SSSSSSSSSSSS",
        "SSSSSSSSSSSS",
        roaring ? "SKKKKKKKKKKK" : "SSSSSSSSSSSS",
        roaring ? "STKTKTKTKTKK" : "SKKKKKKKKKKK",
        roaring ? "SKKKKKKKKKK." : "STSTSTSTSTS.",
        roaring ? ".KKKKKKKKK.." : ".SSSSSSSSS..",
        roaring ? "SSSSSSSSSS.." : "............",
    ], ["S": skin, "B": skinD, "K": C(0x2A1A1A), "W": C(0xFFFFFF), "T": C(0xF0F0E8), "N": burtonInk])
    if roaring {
        for k in 0..<3 {
            let f = frac(p.t * 1.6 + Double(k) / 3), r = 3 + f * 8
            for s in -3...3 {
                let a = -0.5 + Double(s) * 0.2
                c.px(51 + Int((cos(a) * r).rounded()), 26 + hy + Int((sin(a) * r).rounded()), C(0xF0F0F0, 1 - f))
            }
        }
    }
    // The domed shell, plated, its rim along the bottom, spikes along its ridge.
    for (k, sx) in [18, 23, 28, 33].enumerated() {
        let h = k == 1 || k == 2 ? 6.0 : 5.0
        burtonTriangle(c, (Double(sx), 23), (Double(sx) + 4, 23), (Double(sx) + 1.5, 23 - h), spike)
    }
    for y in 21...36 {
        let inset = [6, 4, 3, 2, 1, 1][min(y - 21, 5)] * (y - 21 < 6 ? 1 : 0)
        c.rect(14 + inset, y, 24 - inset * 2, 1, y > 34 ? belly : shell)
        c.px(37 - inset, y, y > 34 ? C(0xA8A8A0) : shellD)
    }
    c.rect(18, 22, 12, 1, shellL); c.rect(16, 23, 4, 1, shellL)
    for y in [27, 31] { c.rect(15, y, 22, 1, plate) }
    for (y0, y1, xs) in [(22, 26, [21, 27, 33]), (28, 30, [18, 24, 30]), (32, 34, [21, 27, 33])] {
        for x in xs { c.rect(x, y0, 1, y1 - y0 + 1, plate) }
    }
    if landed >= 0 { dust(c, x: 18.5, landed); dust(c, x: 38.5, landed) }
}

// MARK: - Colossuss

/// Colossuss: Toshiakki's dead hamster, brought back as a mummy, in greys: a round hamster the size of Clawd wrapped
/// in bandages, little round ears, dark eyes peering out between the wraps, buck teeth, a loose end trailing, its
/// stubby arms held straight out in front. It bites. Signature: it waddles from side to side, arms out.
private func drawColossuss(_ c: PixelCanvas, _ p: Pose) {
    let band = C(0xDCDCD4), bandD = C(0xA8A8A0), bandL = C(0xF2F2EC), gap = C(0x5A5A5A)
    let sig = p.signature
    let waddling = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let ph = p.t * 5
    let sway = waddling ? Int((sin(ph) * 2).rounded()) : 0
    let biting = p.melee.map { $0 < -25 } ?? false

    c.ox += sway
    drawLegs(c, Look(leg: band), step: waddling ? (sin(ph) > 0 ? 0 : 1) : p.step)
    c.oy += p.breathe
    // The loose end of a bandage trailing off behind.
    for i in 0..<6 {
        let x = 18 - Double(i) * 1.2, y = 31 + Double(i) + sin(p.t * 4 + Double(i)) * 0.8
        c.rect(Int(x.rounded()), Int(y.rounded()), 2, 1, i % 2 == 0 ? band : bandD)
    }
    // The round body, wrapped: the bandages winding round it on a slant.
    c.ellipse(28, 30, 10, 8, band)
    for y in 22...38 {
        for x in 18...38 where c.isDrawn(x + c.ox, y + c.oy + c.baseY) && (y * 2 + x / 3) % 5 == 0 {
            c.px(x, y, bandD)
        }
    }
    for y in 23...37 { c.px(37 - abs(y - 30) / 3, y, bandD) }
    c.circle(21, 22, 2, band); c.circle(34, 22, 2, band); c.px(21, 22, bandD); c.px(34, 22, bandD)
    // The eyes in a gap between the wraps, the nose and buck teeth.
    c.rect(21, 26, 15, 3, gap); c.rect(23, 26, 3, 3, burtonInk); c.rect(31, 26, 3, 3, burtonInk)
    c.px(23, 26, bandL); c.px(31, 26, bandL)
    c.rect(27, 29, 3, 1, C(0x3A3A3A))
    if biting {
        c.rect(25, 30, 7, 4, C(0x2A1A1A)); c.rect(27, 30, 3, 2, bandL)
    } else {
        c.rect(27, 30, 3, 2, bandL); c.px(28, 30, bandD)
    }
    // The stubby arms held straight out in front.
    let bob = waddling ? Int((cos(ph) * 1).rounded()) : 0
    for ay in [29, 33] {
        c.rect(37, ay + bob, 6, 2, band); c.px(39, ay + bob, bandD); c.rect(43, ay + bob, 1, 2, bandD)
    }
}

// MARK: - The Were-Rat

/// The Were-Rat: Edgar's dead rat brought back wrong, a hulking rat-monster, in greys: a hunched back a size bigger
/// than Clawd, bristling, its fur in dark strokes and ragged tufts along the spine, tall pointed ears laid back, a
/// glaring eye under a heavy brow, a long snout with its jaws open on long fangs, whiskers, four clawed legs and a long
/// bald tail. Claws. Signature: it lifts its snout and sniffs the air, whiskers twitching.
private func drawWereRat(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x7C7C82), furD = C(0x56565C), furL = C(0x9E9EA4), skin = C(0xC4BCBC), skinD = C(0xA09898)
    let claw = C(0xECECE4)
    let sniffing = p.signature.map { $0 > 0.1 && $0 < 0.9 } ?? false
    let twitch = Int(p.t * (sniffing ? 14 : 3)) % 2

    // Four clawed legs, thick and dark-sided, the claws out.
    if seatedPose {
        drawLegs(c, Look(leg: fur), step: p.step)
    } else {
        for (i, lx) in [17, 22, 31, 36].enumerated() {
            let h = p.step >= 0 && i % 2 == p.step ? 7 : 8
            c.rect(lx, 36, 3, h, fur); c.rect(lx + 2, 36, 1, h, furD)
            c.px(lx, 35 + h, claw); c.px(lx + 2, 35 + h, claw)
        }
    }
    c.oy += p.breathe
    // The long bald tail, thick at the root, ringed, curving off behind.
    var prev = (x: 15.0, y: 33.0)
    for i in 1...10 {
        let f = Double(i) / 10, q = (x: 15 - f * 13, y: 33 + sin(f * 2.6) * 5 - f * 3)
        burtonLine(c, prev.x, prev.y, q.x, q.y, i % 3 == 0 ? skinD : skin, 1.1 - f * 0.6)
        prev = q
    }
    // The hunched back, dark underneath, its fur in strokes, ragged tufts bristling back along the spine.
    let top = [30, 28, 27, 26, 25, 24, 23, 23, 22, 22, 21, 21, 20, 20, 20, 20, 20, 21, 21, 22, 22, 23, 23, 24, 25, 25]
    for (i, t) in top.enumerated() {
        let bottom = i == 0 ? 34 : i == 1 ? 35 : 37
        c.rect(13 + i, t, 1, bottom - t + 1, fur); c.px(13 + i, bottom, furD)
    }
    for (i, h) in [(4, 1.0), (7, 2), (10, 1.5), (13, 2.5), (16, 1.5), (19, 2)] {
        let x = Double(13 + i), t = Double(top[i])
        burtonTriangle(c, (x - 1, t + 1), (x + 2, t + 1), (x - 2, t - 1 - h), fur)
        c.px(13 + i, top[i], furD); c.px(14 + i, top[i], furL)
    }
    for (x, y, n) in [(24, 23, 2), (30, 23, 3), (19, 26, 2), (23, 26, 3), (28, 26, 2), (33, 25, 2), (16, 29, 2),
                      (21, 29, 3), (26, 29, 2), (31, 28, 3), (18, 32, 3), (24, 32, 2), (29, 31, 3), (34, 32, 2),
                      (21, 35, 2), (27, 34, 2)] {
        for k in 0..<n { c.px(x - k, y + k, furD) }
    }
    // Tall pointed ears laid back, the far one darker.
    burtonTriangle(c, (37, 24), (41, 24), (39, 16), furD)
    burtonTriangle(c, (33, 25), (38, 23), (32, 15), fur)
    burtonTriangle(c, (34.5, 23.5), (36.5, 23), (33, 18), skin)
    // The head: a heavy brow over a glaring eye, the long snout out in front, jaws open on its fangs; lifted to sniff
    // the air, jaws shut and the nose twitching.
    let pal: [Character: Px] = ["F": fur, "D": furD, "L": furL, "B": C(0x303036), "W": C(0xF4F4EC),
                                "K": burtonInk, "M": C(0x2A1A1A)]
    let wk = C(0xE0E0E0, 0.55), hy = sniffing ? -3 : 0
    c.pattern(32, 22 + hy, [
        "...FFFFF.........",
        "..FFFFFFFF.......",
        ".FFFFFFFFFF......",
        "FFBBBFFFFFFFL....",
        "FFFFBBBFLLLLLLL..",
        "FFFWWWKFFFFFFFFF.",
        "FFFWWKKFFFFFFFFF" + (sniffing && twitch == 1 ? "." : "K"),
        "FFFFFFFFFFFFFFFKK",
        sniffing ? "FFFFFFFMMMMMMMM.." : "FFFFFFMMMMMMMMMM.",
        sniffing ? "FFFFFFWFFFWFFF..." : "FFFFFMWMMMWMMM...",
        sniffing ? "FFFFFFWFFFWF....." : "FFFFFFWFFFWFF....",
        "DFFFFFFFFFFF.....",
        ".DDDDDDD.........",
    ], pal)
    for dy in [-1, 1] {
        c.glowLine(45, 28.5 + Double(hy + dy), 50, 28 + Double(hy + dy * 2 + twitch), core: wk, glow: C(0, 0),
                   coreR: 0.4, glowR: 0.5)
    }
    if sniffing && frac(p.t * 2.5) < 0.5 { c.pattern(48, 19, ["W.W", ".W.", "W.."], ["W": C(0xFFFFFF, 0.5)]) }
    if let a = p.melee { claws(c, angle: a, trail: p.trail, arm: fur, claw: claw) }
}
