import Foundation

// Villains: Frankenweenie, Pee-wee's Big Adventure, and the agent-only small fry. From New Holland, in the film's
// greys: Edgar "E" Gorr, Nassorr, Toshiakki and Weird Gurl, the classmates who copy Victor's experiment, and the
// monsters it makes: Mr. Whiskerz the vampire cat, Shellee the kaiju turtle, Colossuss the mummy hamster and the
// Were-Rat. From Pee-wee's Big Adventure, in toy-box primaries: Francis Buxtun, the Bike Thief, Madam Rubee and Andee.
// And the small fry, only ever agents: Bob the shrunken head, an Oogie Bug, a Nut Squirrel and a Sea-Monkey.

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
    .wereRat: Persona(name: "The Were-Rat", weapon: .saber, headTop: 20, signature: 3.0, draw: drawWereRat),
    .francisBuxtun: Persona(name: "Francis Buxtun", weapon: .blaster, shot: .thrown(C(0xF0C820)), muzzle: (44, 27),
                            bulk: 1, headTop: 18, signature: 4.0, draw: drawFrancis),
    .bikeThief: Persona(name: "The Bike Thief", weapon: .saber, headTop: 19, signature: 4.0, draw: drawBikeThief),
    .madamRubee: Persona(name: "Madam Rubee", weapon: .none, headTop: 14, signature: 3.4,
                         callout: "The basement of the Alamo!", draw: drawMadamRubee),
    .andee: Persona(name: "Andee", weapon: .saber, pivot: andeeFist, bulk: 4, headTop: 20, signature: 3.6,
                    draw: drawAndee),
    .bob: Persona(name: "Bob", weapon: .none, headTop: 23, draw: drawBob),
    .oogieBug: Persona(name: "An Oogie Bug", weapon: .none, headTop: 27, draw: drawOogieBug),
    .nutSquirrel: Persona(name: "A Nut Squirrel", weapon: .none, headTop: 17, draw: drawNutSquirrel),
    .seaMonkey: Persona(name: "A Sea-Monkey", weapon: .none, headTop: 19, draw: drawSeaMonkey),
]

/// Mr. Whiskerz's jaws: he bites from there.
private let whiskerzMouth = (x: 41.5, y: 29.5)
/// Shellee's front foot: she stomps from there.
private let shelleeFoot = (x: 40.5, y: 40.5)
/// Colossuss's buck teeth: it bites from there.
private let colossussMouth = (x: 39.5, y: 31.5)
/// Andee's right fist: he punches from there.
private let andeeFist = (x: 42.5, y: 33.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Draws `art` on a layer of its own, positioned like `c`, and lays it over `c` at `alpha` (props fading in and out).
private func faded(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

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

/// The Were-Rat: a pet rat brought back wrong, now a rat-man, in greys: the Clawd block in grey fur with round
/// ears on top, beady eyes and a long pointed snout jutting out in front with whiskers and two big front teeth,
/// tattered dark rags, a long bare tail. Claws. Signature: it lifts its snout and sniffs the air, whiskers twitching.
private func drawWereRat(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x8C8C90), furD = C(0x6A6A70), furL = C(0xAAAAB0), skin = C(0xC8C8C8), rags = C(0x48484E)
    let ragsD = C(0x34343A)
    let sniffing = p.signature.map { $0 > 0.1 && $0 < 0.9 } ?? false
    let twitch = Int(p.t * (sniffing ? 14 : 3)) % 2

    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, skin) } }
    c.oy += p.breathe
    // The long bare tail, curving off behind.
    var prev = (x: 18.0, y: 35.0)
    for i in 1...8 {
        let f = Double(i) / 8, q = (x: 18 - f * 14, y: 35 + sin(f * 2.4) * 5 - f * 2)
        burtonLine(c, prev.x, prev.y, q.x, q.y, skin, 0.7 - f * 0.2)
        prev = q
    }
    // Round ears on top, the furry block.
    c.circle(21, 23, 3, fur); c.rect(20, 22, 2, 2, skin); c.circle(34, 23, 3, fur); c.rect(33, 22, 2, 2, skin)
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    c.rect(18, 26, 20, 1, furL); for x in stride(from: 20, to: 37, by: 3) { c.px(x, 27, furL) }
    c.rect(22, 29, 2, 2, burtonInk); c.px(22, 29, C(0xFFFFFF))
    c.rect(31, 29, 2, 2, burtonInk); c.px(31, 29, C(0xFFFFFF))
    // The snout: out in front, or lifted to sniff; whiskers and front teeth.
    let pal: [Character: Px] = ["F": furL, "N": burtonInk, "T": C(0xF4F4EC)]
    let wk = C(0xE0E0E0, 0.55)
    if sniffing {
        c.pattern(35, 22, ["....NN", "...FFN", "..FFFF", ".FFFF.", "FFFF..", "FFF...", "FTT..."], pal)
        for dy in [-1, 1] {
            c.glowLine(40, 24 + Double(dy), 45, 22 + Double(dy * 2 + twitch), core: wk, glow: C(0, 0), coreR: 0.4,
                       glowR: 0.5)
        }
        if frac(p.t * 2.5) < 0.5 { c.pattern(43, 17, ["W.W", ".W.", "W.."], ["W": C(0xFFFFFF, 0.5)]) }
    } else {
        c.pattern(36, 28, ["FFFF....", "FFFFFFF.", "FFFFFFFN", "FFFFFF..", ".TT....."], pal)
        for dy in [-1, 1] {
            c.glowLine(41, 30 + Double(dy), 46, 29.5 + Double(dy * 2 + twitch), core: wk, glow: C(0, 0), coreR: 0.4,
                       glowR: 0.5)
        }
    }
    // Tattered rags over the bottom of it, ragged at the hem.
    c.rect(18, 33, 20, 5, rags); c.rect(37, 33, 1, 5, ragsD)
    c.pattern(18, 38, ["RR.RRR..RR.RRR.RR.RR", "R....R...R..R....R.."], ["R": rags])
    c.pattern(21, 34, ["d...d", ".d.d."], ["d": ragsD])
    if let a = p.melee { claws(c, angle: a, trail: p.trail, arm: fur, claw: C(0xF0F0E8)) }
}

// MARK: - Francis Buxtun

/// The toy boat: a blue hull, a white sail, a yellow pennant, 7 wide from (x, y).
private func toyBoat(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, ["...Y...", "...SS..", "...SSS.", "BBBBBBB", ".BBBBB."],
              ["Y": C(0xF0C820), "S": C(0xF8F8F4), "B": C(0x2A5AC8)])
}

/// Francis on his own: big curly hair, a smug face, the striped bathrobe; `legs` false when he's in the bath.
private func francisFigure(_ c: PixelCanvas, _ p: Pose, legs: Bool) {
    let red = C(0xD8202A), redD = C(0xA81418), white = C(0xF8F4F0), hair = C(0x5A3A22), hairL = C(0x7A5232)
    if legs {
        drawLegs(c, Look(leg: clawdOrange), step: p.step)
        burtonBoots(c, step: p.step, red, height: 2)
    }
    c.oy += p.breathe
    // The bathrobe's skirts over his legs.
    if legs { burtonStripes(c, 17, 38, 22, seatedPose ? 1 : 2, alongX: true, width: 2, light: white, dark: red) }
    // A big Clawd, a little wider than most; smug, heavy-lidded eyes, a smirk.
    c.rect(17, 25, 22, 13, clawdOrange); c.rect(38, 25, 1, 13, clawdShade); c.rect(17, 37, 22, 1, clawdShade)
    c.rect(14, 33, 3, 3, red); c.rect(39, 33, 3, 3, red)
    c.rect(22, 29, 2, 3, burtonInk); c.rect(32, 29, 2, 3, burtonInk)
    c.rect(22, 29, 2, 1, clawdShade); c.rect(32, 29, 2, 1, clawdShade); c.rect(21, 28, 4, 1, C(0x8A3A20))
    c.rect(31, 28, 4, 1, C(0x8A3A20))
    c.pattern(26, 32, ["....K", "KKKK."], ["K": C(0x5A2A1A)])
    // The striped bathrobe, belted, its white lapels.
    burtonStripes(c, 17, 33, 22, 5, alongX: true, width: 2, light: white, dark: red)
    c.rect(17, 35, 22, 1, redD); c.rect(27, 35, 2, 2, redD)
    // Big curly hair over the top of him.
    c.pattern(16, 18, [
        "......o.o.o.o.o.o.......",
        "....oHoHoHoHoHoHoHo.....",
        "..oHHHHHHHHHHHHHHHHHo...",
        ".oHHHlHHHHlHHHHlHHHHHo..",
        "oHHHHHHHHHHHHHHHHHHHHHo.",
        "HHHlHHHHlHHHHlHHHHlHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHoHoHoHoHoHoHoHoHHHHH",
        "HHH..................HHH",
        "oH....................Ho",
    ], ["H": hair, "o": hairL, "l": hairL])
}

/// Francis Buxtun: the big spoilt rich boy: a big Clawd with a mop of curly hair, smug heavy-lidded eyes and a smirk,
/// in a red-and-white striped bathrobe, his toy boat under his arm. He throws rubber bath toys: yellow ducks.
/// Signature: a bathtub appears round him and he lolls in a bubble bath with his boat, smug, then sinks out of sight
/// under the bubbles; the tub goes, and he's back.
private func drawFrancis(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    if let s = sig, s > 0.03, s < 0.97 {
        let tubA = min(ramp(s, 0.03, 0.15), 1 - ramp(s, 0.84, 0.95))
        let inTub = s >= 0.15 && s < 0.84
        let sink = inTub ? Int((ramp(s, 0.48, 0.66) * 17).rounded()) : 0
        let enamel = C(0xF4F4F0), enamelD = C(0xC8C8C4), gold = C(0xE0B030)
        if inTub {
            // Him, low in the water: only what's above the rim shows.
            let fig = PixelCanvas(c.w, c.h)
            fig.ox = c.ox; fig.oy = c.oy + sink; fig.baseY = c.baseY
            francisFigure(fig, p, legs: false)
            let rim = 35 + c.oy + c.baseY
            let (ox, oy, by) = (c.ox, c.oy, c.baseY)
            c.ox = 0; c.oy = 0; c.baseY = 0
            c.paste(fig.onlyRows(0..<rim))
            c.ox = ox; c.oy = oy; c.baseY = by
        } else {
            faded(c, s < 0.5 ? 1 : ramp(s, 0.84, 0.95)) { francisFigure($0, p, legs: true) }
        }
        faded(c, tubA) { t in
            // The clawfoot tub, and the bubbles heaped on it.
            t.rect(12, 35, 33, 2, enamel); t.rect(11, 35, 1, 1, enamel); t.rect(45, 35, 1, 1, enamel)
            t.rect(13, 37, 31, 3, enamel); t.rect(14, 40, 29, 1, enamel); t.rect(16, 41, 25, 1, enamelD)
            t.rect(13, 39, 31, 1, enamelD); t.rect(43, 37, 1, 3, enamelD)
            t.rect(15, 42, 3, 2, gold); t.rect(39, 42, 3, 2, gold)
            for i in 0..<9 {
                let bx = 14 + i * 3 + (i % 2), by = 34 - (i % 3 == 1 ? 1 : 0)
                t.circle(bx, by, i % 2 == 0 ? 2 : 1, C(0xFFFFFF))
            }
            toyBoat(t, x: 34, y: 29 + Int((sin(p.t * 3) * 1).rounded()))
        }
        if sink > 16, frac(p.t * 1.5) < 0.6 {
            let b = frac(p.t * 1.5) / 0.6
            c.pattern(27, 32 - Int(b * 6), [".W.", "W.W", ".W."], ["W": C(0xFFFFFF, 0.8)])
        }
        return
    }
    francisFigure(c, p, legs: true)
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // A rubber duck raised to throw.
        c.oy += p.gunY
        c.rect(40, 31, 2, 2, clawdOrange)
        c.pattern(39, 25, [".YY..", "YKYO.", ".YYY.", "YYYYY", ".YYY."],
                  ["Y": C(0xF0C820), "K": burtonInk, "O": C(0xF07A1A)])
        return
    }
    toyBoat(c, x: 39, y: 30)
}

// MARK: - The Bike Thief

/// Bolt cutters held at the hand along `angle`: long red handles and steel jaws, `open` or snapped shut.
private func boltCutters(_ c: PixelCanvas, angle a: Double, open: Bool) {
    let h = Sprite.hand, side = burtonReach((0, 0), a + 90, 1)
    let j = burtonReach(h, a, 8), tip = burtonReach(h, a, 13)
    let spread = open ? 1.6 : 0.5
    for s in [-1.0, 1.0] {
        let b = burtonReach(h, a, -3)
        burtonLine(c, b.x + side.x * s * 0.8, b.y + side.y * s * 0.8, j.x + side.x * s * 0.6, j.y + side.y * s * 0.6,
                   C(0xC8202A), 0.6)
        burtonTriangle(c, (j.x + side.x * s * 0.2, j.y + side.y * s * 0.2),
                       (j.x + side.x * s * 1.6, j.y + side.y * s * 1.6),
                       (tip.x + side.x * s * spread, tip.y + side.y * s * spread), C(0xA8ACB4))
    }
}

/// The Bike Thief: a shadowy figure: a dark Clawd in a trench coat, its collar turned up, a hat pulled down low over
/// eyes that glint out of the shadow, and a pair of bolt cutters. He fights with the bolt cutters. Signature: he
/// tiptoes up to a chained post, snips the chain, and sneaks off a little way with a cartoon "tee-hee", then creeps
/// back.
private func drawBikeThief(_ c: PixelCanvas, _ p: Pose) {
    let shadow = C(0x3A3A46), shadowD = C(0x2A2A34), coat = C(0x2C2C36), coatD = C(0x1E1E26), coatL = C(0x44444F)
    let hat = C(0x1A1A20), band = C(0x4A4A56), glint = C(0xF0E8A0)
    let sig = p.signature
    var sneak = 0, tiptoe = false
    var cut: Double?, open = true
    if let s = sig {
        tiptoe = s > 0.04 && s < 0.92
        sneak = -Int((sin(ramp(s, 0.5, 0.9) * .pi) * 8).rounded())
        if s > 0.28 && s < 0.5 { cut = -8; open = s < 0.4 }
        // The post and its chain, fading in, cut, the ends dropping away; the post fading out again.
        let postA = min(ramp(s, 0.06, 0.2), 1 - ramp(s, 0.86, 0.96))
        faded(c, postA) { k in
            k.rect(55, 24, 3, 20, C(0x7A7E88)); k.rect(55, 24, 1, 20, C(0xA8ACB4)); k.rect(54, 23, 5, 1, C(0x5A5E68))
            let drop = s < 0.4 ? 0 : Int(ramp(s, 0.4, 0.55) * 8)
            for i in 0..<4 {
                k.rect(51 + i * 2, 31 + (i < 2 ? drop : drop / 2), 2, 2, C(0xC8CCD4))
                k.px(51 + i * 2, 31 + (i < 2 ? drop : drop / 2), C(0x6A6E78))
            }
        }
    }
    c.ox += sneak
    let step = tiptoe ? Int(p.t * 6) % 2 : p.step
    drawLegs(c, Look(leg: coatD), step: step)
    burtonBoots(c, step: step, C(0x0E0E12), height: 1)
    c.oy += p.breathe - (tiptoe ? 1 : 0)
    // The coat: its tails over his legs, the bottom of him belted, the collar turned up at his sides.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(body: shadow, shade: shadowD, arm: coat, eye: nil))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 35, 20, 1, coatD)
    c.pattern(15, 27, ["CC..................CCC", "CCC................CCC.", "CCC................CCC.",
                       "CCC................CCC.", "CCC................CCC.", ".CC................CC.."], ["C": coatL])
    // Eyes glinting out of the shadow under the hat.
    c.rect(18, 26, 20, 2, shadowD)
    c.rect(22, 29, 2, 1, glint); c.rect(32, 29, 2, 1, glint)
    // The hat pulled down low.
    c.pattern(15, 19, [
        ".......HHHHHHHHHH.......",
        "......HHHHHHHHHHHH......",
        "......HHHHHHHHHHHH......",
        "......HHHHHHHHHHHH......",
        "......BBBBBBBBBBBB......",
        ".HHHHHHHHHHHHHHHHHHHHHHH",
        "..hhhhhhhhhhhhhhhhhhhhh.",
    ], ["H": hat, "B": band, "h": C(0x0C0C10)])
    // The bolt cutters: snipping, swinging, or held down at his side.
    if let a = cut ?? p.melee {
        for (i, ta) in p.trail.enumerated() where cut == nil {
            let e = burtonReach(Sprite.hand, ta, 13)
            c.glowLine(Sprite.hand.x, Sprite.hand.y, e.x, e.y, core: C(0xC8CCD4), glow: C(0xC8CCD4), coreR: 0.4,
                       glowR: 1.4, strength: 0.25 / Double(i + 1))
        }
        boltCutters(c, angle: a, open: open)
    } else {
        boltCutters(c, angle: 82, open: false)
    }
    if let s = sig, s > 0.55, s < 0.85 {
        let a = min(ramp(s, 0.55, 0.6), 1 - ramp(s, 0.8, 0.85))
        shout(c, "HEE", x: 6, y: 11 - (Int(p.t * 6) % 2), C(0xFFFFFF, 0.85 * a))
        shout(c, "HEE", x: 18, y: 6 + (Int(p.t * 6) % 2), C(0xFFFFFF, 0.85 * a))
    }
}

// MARK: - Madam Rubee

/// Madam Rubee: the phoney fortune-teller: an orange Clawd in a red silk turban with a gold jewel and a white plume,
/// blue eye shadow, red lips, gold hoop earrings, strings of coloured beads over a blue shawl with a gold fringe; her
/// crystal ball on its draped stand beside her. She doesn't fight. Signature: she waves her hand over the crystal
/// ball, the other at her temple, and the ball glows.
private func drawMadamRubee(_ c: PixelCanvas, _ p: Pose) {
    let turban = C(0xC8202A), turbanD = C(0x981418), turbanL = C(0xE84A4A), gold = C(0xE8B830), shawl = C(0x2A4AB0)
    let shawlD = C(0x1E3488), cloth = C(0x6A2A9A), clothD = C(0x4A1A70)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.08, 0.2), 1 - ramp($0, 0.82, 0.94)) } ?? 0

    // The crystal ball on its draped stand.
    let standY = seatedPose ? -4 : 0
    c.pattern(42, 36 + standY, [".CCCCCCCCC.", "CCCCCCCCCCC", "CcCcCcCcCcC", ".C.......C.",
                                ".C.......C.", ".C.......C.",
                                ".D.......D.", "DD.......DD"], ["C": cloth, "c": clothD, "D": C(0x3A1A10)])
    c.rect(45, 34 + standY, 5, 2, gold)
    c.circle(47, 30 + standY, 4, C(0xA8C8F0))
    c.circle(46, 29 + standY, 1, C(0xE8F4FF)); c.px(45, 28 + standY, C(0xFFFFFF))
    for y in 29...33 { c.px(50 - abs(y - 31) / 2, y + standY, C(0x7AA0D8)) }
    if k > 0 {
        let g = k * (0.7 + 0.3 * sin(p.t * 6))
        c.glowLine(47.5, 30.5 + Double(standY), 47.5, 30.5 + Double(standY), core: C(0xFFFFFF, g),
                   glow: C(0xB070FF, g * 0.8), coreR: 2.5, glowR: 4 + 3 * g)
    }
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, gold, height: 1)
    c.oy += p.breathe
    // The shawl over the bottom of her and over her legs, its gold fringe.
    let tails = seatedPose ? 1 : 2
    c.rect(17, 38, 22, tails, shawl)
    for x in stride(from: 17, to: 39, by: 2) { c.px(x, 38 + tails, gold) }
    drawBody(c, Look(arm: shawl))
    c.rect(22, 28, 2, 1, C(0x4A7AE8)); c.rect(32, 28, 2, 1, C(0x4A7AE8))
    c.pattern(26, 31, ["RRRR", ".RR."], ["R": C(0xC0202A)])
    c.rect(18, 33, 20, 5, shawl); c.rect(37, 33, 1, 5, shawlD)
    // Strings of beads in every colour.
    let beads = [C(0xD8202A), C(0xF0C820), C(0x2AA84A), C(0xF8F8F8)]
    for (i, x) in stride(from: 21, through: 35, by: 2).enumerated() {
        let y = 33 + (x < 25 || x > 31 ? 0 : 1) + (x == 27 || x == 29 ? 1 : 0)
        c.px(x, y, beads[i % 4]); c.px(x + 1, y + 2 - (x > 27 ? 1 : 0), beads[(i + 2) % 4])
    }
    // Gold hoops; the turban, its jewel and plume.
    for x in [15, 39] { c.pattern(x - 1, 30, [".G.", "G.G", "G.G", ".G."], ["G": gold]) }
    c.pattern(16, 17, [
        ".......TTTTTTTTTT.......",
        ".....TTTTTTTTTTTTTT.....",
        "...TTTTlllTTTTTTTTTTT...",
        "..TTTTTTTTlllTTTTTTTTT..",
        ".TTTTTTTTTTTTTlllTTTTTT.",
        ".TTTlllTTTTTTTTTTTlllTT.",
        "TTTTTTTlllTTTTTTTTTTTTTT",
        "TTTTTTTTTTTlllTTTTTTTTTd",
        ".dddddddddddddddddddddd.",
    ], ["T": turban, "l": turbanL, "d": turbanD])
    c.pattern(26, 19, [".GGG.", "GGBGG", ".GGG."], ["G": gold, "B": C(0x2A6AE8)])
    c.pattern(28, 13, [".W", "WW", "W.", "W."], ["W": C(0xF4F0E8)])
    // Hands: one circling over the ball, the other at her temple.
    if k > 0 {
        let hx = 45 + Int((cos(p.t * 5) * 3).rounded()), hy = 22 + standY + Int((sin(p.t * 5) * 1.5).rounded())
        raisedHand(c, from: 39.5, hx, hy, sleeve: shawl, hand: clawdOrange)
        raisedHand(c, from: 16.5, 14, 25, sleeve: shawl, hand: clawdOrange)
    }
}

// MARK: - Andee

/// Andee: Dottie's enormous, short-tempered boyfriend: a Clawd a size bigger than most, a flat crew cut, angry brows
/// and a scowl, a red plaid shirt over a white T-shirt, jeans, and big fists. He punches. Signature: he cracks his
/// knuckles, then stomps forward after someone, the ground shaking, and back.
private func drawAndee(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0x3A2A1E), hairL = C(0x5A4430), red = C(0xC8202A), redD = C(0x7A0E14), line = C(0x2A0A0E)
    let sig = p.signature
    let cracking = sig.map { $0 > 0.06 && $0 < 0.42 } ?? false
    let stomp = sig.map { $0 >= 0.46 && $0 < 0.92 } ?? false
    var landed = -1.0, step = p.step
    if stomp, let s = sig {
        let k = ramp(s, 0.46, 0.92), ph = k * 6, f = ph - floor(ph)
        c.ox += Int((sin(k * .pi) * 4).rounded())
        step = Int(ph) % 2
        if f < 0.35 { landed = f / 0.35; c.ox += Int(p.t * 30) % 2 == 0 ? 1 : 0 }
    }
    drawLegs(c, Look(leg: C(0x3A4A7A)), step: step)
    burtonBoots(c, step: step, C(0x2A1E14), height: 2)
    if landed >= 0 { dust(c, x: 20, landed); dust(c, x: 36, landed) }
    c.oy += p.breathe
    // The big block, his scowl.
    c.rect(16, 23, 24, 15, clawdOrange); c.rect(39, 23, 1, 15, clawdShade); c.rect(16, 37, 24, 1, clawdShade)
    c.rect(21, 27, 2, 3, burtonInk); c.rect(33, 27, 2, 3, burtonInk)
    c.pattern(19, 25, ["KK..............KK", "..KKK........KKK..", "....K........K...."], ["K": C(0x5A2A1A)])
    c.pattern(24, 31, ["..KKKKKK..", ".K......K.", "K........K"], ["K": C(0x5A2A1A)])
    // The plaid shirt over the bottom of him, open on a white T-shirt.
    for y in 33...37 {
        for x in 16...39 {
            let v = (x - 16) % 4 == 3, h = y == 35
            c.px(x, y, v && h ? line : (v || h ? redD : red))
        }
    }
    c.pattern(25, 33, ["WWWWWW", ".WWWW.", "..WW.."], ["W": C(0xF4F4F0)])
    // The crew cut: short and flat across the top.
    c.pattern(16, 20, [
        "...HHHHHHHHHHHHHHHHHH...",
        ".HHhHHhHHhHHhHHhHHhHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HH....................HH",
    ], ["H": hair, "h": hairL])
    // Fists: cracking his knuckles, punching, or at his sides.
    let fist = { (x: Int, y: Int) in c.rect(x, y, 4, 4, clawdOrange); c.rect(x, y + 3, 4, 1, clawdShade) }
    if cracking {
        burtonLine(c, 14, 34, 38, 31, red, 1.3); burtonLine(c, 40, 34, 41, 31, red, 1.3)
        let j = Int(p.t * 8) % 2
        fist(37 + j, 29); fist(41, 29)
        if j == 0 { c.pattern(43, 24, ["W.W", ".W.", "W.W"], ["W": C(0xFFFFFF, 0.85)]) }
        return
    }
    c.rect(12, 32, 4, 4, red); fist(11, 33)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(andeeFist, ta, 4)
            c.glowLine(e.x, e.y, e.x, e.y, core: clawdOrange, glow: clawdOrange, coreR: 1.5, glowR: 2.5,
                       strength: 0.3 / Double(i + 1))
        }
        let e = burtonReach(andeeFist, a, 4)
        burtonLine(c, 40, 34, e.x, e.y, red, 1.4)
        fist(Int(e.x.rounded()) - 2, Int(e.y.rounded()) - 2)
    } else {
        c.rect(40, 32, 3, 4, red); fist(40, 33)
    }
}

// MARK: - The small fry

/// A small fry's four short legs under a 14×9 body at (21, 30), the size of Halloween Town's trick-or-treaters, and
/// the breathing bob.
private func smallLegs(_ c: PixelCanvas, _ p: Pose, _ leg: Px, foot: Px? = nil) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg)
            if let foot { c.rect(lx, lifted ? 41 : 42, 2, 1, foot) }
        }
    }
    c.oy += p.breathe
}

/// Bob: one of Beetlejooce's shrunken-head workers: a small dark suit with a white shirt and a thin black tie, and on
/// top of it, a tiny dark shrunken head, white pinprick eyes, its lips stitched shut, black hair combed flat.
private func drawBob(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x2E2E3A), suitD = C(0x20202A), head = C(0x5A4232), headD = C(0x3E2C20)
    smallLegs(c, p, suit, foot: C(0x101012))
    c.rect(21, 30, 14, 9, suit); c.rect(21, 38, 14, 1, suitD); c.rect(34, 30, 1, 9, suitD)
    c.rect(19, 33, 2, 2, suit); c.rect(35, 33, 2, 2, suit)
    c.pattern(25, 30, ["WWWWWW", ".WWKW.", "..WK..", "...K.."], ["W": C(0xF0F0EC), "K": burtonInk])
    c.pattern(25, 23, [
        ".HHHHH.",
        "HHHHHHH",
        "SSSSSSS",
        "SWSSSWS",
        "SSShSSS",
        "SKKKKKS",
        ".SSSSS.",
    ], ["H": C(0x16161A), "S": head, "h": headD, "W": C(0xF4F0E0), "K": C(0xC8B890)])
}

/// An Oogie Bug: a beetle fallen out of Ooogie Boogie's seams, grown to a small fry's size: a dark green shell with a
/// lime shine, a black head with white eyes and two feelers, six scuttling legs.
private func drawOogieBug(_ c: PixelCanvas, _ p: Pose) {
    let shell = C(0x1E2A16), shellM = C(0x2E4224), shine = C(0x9ADB2E), leg = C(0x101410)
    let scuttle = p.step >= 0 ? p.step : (p.walking ? Int(p.t * 8) % 2 : 0)
    if !seatedPose {
        for (i, lx) in [22, 27, 32].enumerated() {
            let up = (i + scuttle) % 2 == 0 ? 0 : 1
            c.rect(lx, 38, 2, 4 - up, leg); c.rect(lx + 1, 41 - up, 2, 1, leg)
        }
    }
    c.oy += p.breathe
    c.pattern(20, 30, [
        "...SSSSSSSSS...",
        ".SSSMMMMMMMSSS.",
        "SSGGSSSSSSSSSSS",
        "SGGSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSS",
        "SMMMMMMMMMMMMMS",
        ".SSSSSSSSSSSSS.",
        "...SSSSSSSSS...",
    ], ["S": shell, "M": shellM, "G": shine])
    c.rect(27, 30, 1, 8, C(0x0E140A))
    c.pattern(35, 32, ["..HHH", ".HHHH", "HHWHH", "HHHHH", ".HHH."], ["H": leg, "W": C(0xFFFFFF)])
    c.rect(38, 29, 1, 3, leg); c.rect(39, 28, 2, 1, leg); c.rect(36, 30, 1, 2, leg); c.rect(36, 29, 2, 1, leg)
}

/// A Nut Squirrel: one of the squirrels who sort nuts in Wonka's factory: a little brown squirrel with a cream belly,
/// tufted ears and a huge bushy tail curling up behind it, a walnut held in its paws.
private func drawNutSquirrel(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xA8683A), furD = C(0x7E4A26), furL = C(0xC88A54), belly = C(0xF0D8B0), nut = C(0xC8A070)
    let nutD = C(0x8A6A40)
    smallLegs(c, p, fur)
    // The bushy tail curling up behind it.
    c.pattern(12, 17, [
        "...TTTT....",
        ".TTTTTTTT..",
        "TTTLLTTTTT.",
        "TTL...TTTT.",
        "TT.....TTT.",
        "........TTT",
        "........TTT",
        "........TTT",
        ".......TTTT",
        "......TTTTT",
        ".....TTTTTT",
        "....TTTTTTT",
        "...TTTTTTTT",
        "....TTTTTTT",
        "......TTTTT",
    ], ["T": furD, "L": furL])
    c.rect(21, 30, 14, 9, fur); c.rect(34, 30, 1, 9, furD); c.rect(26, 32, 7, 6, belly)
    // The head, its ears, eyes and nose.
    c.pattern(25, 22, ["E.....E.", "EE...EE.", "FFFFFFF.", "FKFFFKFF", "FFFFFFFN", ".FFFFFF."],
              ["E": furD, "F": fur, "K": burtonInk, "N": C(0x3A2010)])
    c.rect(26, 28, 7, 2, fur)
    // The walnut in its paws.
    c.pattern(33, 30, [".NNN.", "NnNnN", "NNnNN", ".NNN."], ["N": nut, "n": nutD])
    c.rect(31, 33, 2, 1, fur); c.rect(37, 33, 2, 1, fur)
}

/// A Sea-Monkey: one of Frankenweenie's brine shrimp, grown monstrous, in greys: a little grey creature with a big
/// round head, a finned crest and fin-ears, huge round eyes and a wide toothy grin, a small pale belly and a fish's
/// tail.
private func drawSeaMonkey(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9A9AA0), skinD = C(0x76767C), skinL = C(0xBCBCC2), belly = C(0xD0D0D4), fin = C(0x5E5E66)
    smallLegs(c, p, skinD)
    burtonTriangle(c, (22, 34), (22, 38), (15, 32), fin); burtonTriangle(c, (22, 34), (22, 38), (16, 40), fin)
    c.rect(22, 32, 12, 7, skin); c.rect(33, 32, 1, 7, skinD); c.rect(25, 33, 6, 5, belly)
    c.rect(20, 34, 2, 2, skin); c.rect(34, 34, 2, 2, skin)
    // The fins: a crest on top and an ear-fin either side.
    for (k, x) in [24, 28, 32].enumerated() {
        burtonTriangle(c, (Double(x) - 1.5, 23), (Double(x) + 1.5, 23), (Double(x) - 1, Double(k == 1 ? 18 : 19)), fin)
    }
    burtonTriangle(c, (21, 25), (21, 29), (16, 24), fin); burtonTriangle(c, (35, 25), (35, 29), (40, 24), fin)
    // The big round head: huge eyes and a wide grin full of little teeth.
    c.ellipse(28, 27, 7, 5, skin); c.rect(23, 23, 6, 1, skinL)
    c.pattern(23, 24, ["WWW..WWW.", "WKW..WKW.", "WWW..WWW."], ["W": C(0xF8F8F8), "K": burtonInk])
    c.rect(32, 24, 1, 3, skin)
    c.pattern(23, 28, ["KKKKKKKKKK", "KWKWKWKWKK", ".KKKKKKKK."], ["K": C(0x2A2A30), "W": C(0xF8F8F8)])
}
