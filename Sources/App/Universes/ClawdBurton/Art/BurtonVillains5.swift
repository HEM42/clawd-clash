import Foundation

// Villains: Charlie and the Chocolate Factory and Alice in Wonderland. The factory's troublemakers: greedy Augustus
// Gloopp, spoilt Veruca Saltt, gum-chewing Violet Bluregarde and Mike Teevee with his game controller (nobody gets
// hurt: their silly weapons only splat), and Slugwurth, the rival chocolatier after the recipes. From Underland: the
// Red Queen with her enormous head and her flamingo, Stayne the Knave of Hearts, the Jabberclawdky, the Bandersnatch
// and a Red Card Knight. The people are Clawd in costume; the beasts keep their own shapes at Clawd's size, a boss at
// most a size up.

let burtonVillains5: [BurtonVillain: Persona] = [
    .augustusGloopp: Persona(name: "Augustus Gloopp", weapon: .blaster, shot: .thrown(C(0x6A3A1E)), muzzle: (44, 28),
                             bulk: 1, headTop: 20, signature: 3.4, draw: drawAugustus),
    .verucaSaltt: Persona(name: "Veruca Saltt", weapon: .blaster, shot: .thrown(C(0xC8A070)), muzzle: (44, 29),
                          headTop: 21, signature: 3.0, callout: "I want it now!", draw: drawVeruca),
    .violetBluregarde: Persona(name: "Violet Bluregarde", weapon: .blaster, shot: .thrown(C(0x3A6AE0)),
                               muzzle: (44, 29), headTop: 21, signature: 3.8, draw: drawViolet),
    .mikeTeevee: Persona(name: "Mike Teevee", weapon: .blaster, shot: .energy(core: C(0xFFFFFF), glow: C(0x9AC8FF)),
                         muzzle: (47, 30), headTop: 20, signature: 3.4, draw: drawMikeTeevee),
    .slugwurth: Persona(name: "Slugwurth", weapon: .none, headTop: 22, signature: 3.6, draw: drawSlugwurth),
    .redQueen: Persona(name: "The Red Queen", weapon: .saber, pivot: queenHand, bulk: 3, headTop: 9, signature: 3.6,
                       callout: "Off with their heads!", draw: drawRedQueen),
    .stayne: Persona(name: "Stayne", weapon: .saber, pivot: stayneHand, headTop: 14, signature: 3.4,
                     draw: drawStayne),
    .jabberclawdky: Persona(name: "The Jabberclawdky", weapon: .lightning,
                            magic: Magic(core: C(0xF0D6FF), glow: C(0x7A2BD1), jagged: true), armoured: true,
                            canSit: false, pivot: jabberMouth, bulk: 8, headTop: 9, signature: 3.6,
                            draw: drawJabberclawdky),
    .bandersnatch: Persona(name: "The Bandersnatch", weapon: .saber, canSit: false, pivot: snatchJaws, bulk: 7,
                           headTop: 23, signature: 3.2, draw: drawBandersnatch),
    .redCardKnight: Persona(name: "A Red Card Knight", weapon: .saber, armoured: true, headTop: 19, signature: 3.2,
                            draw: drawRedCardKnight),
]

/// The Red Queen's hand, at the side of her bigger block: the flamingo swings from there.
private let queenHand = (x: 42.5, y: 34.5)
/// How far Stayne's long legs raise everything above them while he stands.
private let stayneLift = 5
/// Stayne's sword hand, raised with the rest of him: his sword swings from there.
private let stayneHand = (x: Sprite.hand.x, y: Sprite.hand.y - Double(stayneLift))
/// The front of the Jabberclawdky's mouth: its lightning leaves from there (raised by `armRaise`, head and all).
private let jabberMouth = (x: 57.5, y: 20.5)
/// The Bandersnatch's jaws: its bite snaps from there.
private let snatchJaws = (x: 48.5, y: 32.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Up, held, and back down again over a signature: 0 → 1 between `a` and `b`, 1 → 0 between `c` and `d`.
private func held(_ sig: Double?, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    guard let s = sig else { return 0 }
    return min(ramp(s, a, b), 1 - ramp(s, c, d))
}

/// Clothes over the bottom rows of the Clawd block (y 33…37), shaded down the right and along the hem.
private func clothes(_ c: PixelCanvas, _ col: Px, _ shade: Px) {
    c.rect(18, 33, 20, 5, col); c.rect(37, 33, 1, 5, shade); c.rect(18, 37, 20, 1, shade)
}

/// Whether a ranged character has its weapon up: firing, waiting, or checking it.
private func armed(_ p: Pose) -> Bool { p.signature == nil && (p.fire != nil || p.ready || p.gunLift > 0) }

/// `a` blended `k` of the way to `b`.
private func mix(_ a: Px, _ b: Px, _ k: Double) -> Px {
    let f = { (x: UInt8, y: UInt8) -> UInt8 in UInt8((Double(x) + (Double(y) - Double(x)) * k).rounded()) }
    return Px(r: f(a.r, b.r), g: f(a.g, b.g), b: f(a.b, b.b), a: 255)
}

/// Draws `art` on a layer of its own and pastes it over `c`, faded to `alpha`.
private func fadeIn(_ c: PixelCanvas, alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// Draws `art` on its own layer and lays it over `c` shrunk to `k` of its size about the point between its feet,
/// keeping only `keep` (0…1) of its pixels: breaking up into pixels as it goes.
private func shrunk(_ c: PixelCanvas, _ k: Double, keep: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let a = (x: 28.0, y: 44.0 + Double(c.baseY))
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<c.h {
        for x in 0..<c.w where keep >= 1 || noise(x * 37 + y * 101) < keep {
            let sx = Int(floor(a.x + (Double(x) + 0.5 - a.x) / k)), sy = Int(floor(a.y + (Double(y) + 0.5 - a.y) / k))
            guard sx >= 0, sy >= 0, sx < s.w, sy < s.h else { continue }
            let i = (sy * s.w + sx) * 4, al = s.buf[i + 3]
            guard al > 0 else { continue }
            let m = 255 / Double(al)
            let r = UInt8(min(255, Double(s.buf[i]) * m)), g = UInt8(min(255, Double(s.buf[i + 1]) * m))
            let b = UInt8(min(255, Double(s.buf[i + 2]) * m))
            c.px(x, y, Px(r: r, g: g, b: b, a: al))
        }
    }
}

// MARK: - Augustus Gloopp

/// Augustus Gloopp: a big boy, the Clawd block a little wider and taller than usual, rosy cheeks and chocolate smeared
/// round his mouth, neat light-brown hair, a white shirt under green leather lederhosen with braces, and white knee
/// socks. He throws candy bars. Signature: he stuffs a whole chocolate bar into his mouth, bite after bite, his
/// cheeks bulging, and the smears grow.
private func drawAugustus(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xF0EEE6), shirtD = C(0xC8C4BA), leather = C(0x4A5A2E), leatherD = C(0x34401E)
    let hair = C(0xA8784A), hairL = C(0xC89868), choc = C(0x5A321E), chocL = C(0x7A4A2A)
    let sig = p.signature
    let up = held(sig, 0.06, 0.18, 0.78, 0.9)
    let eaten = sig.map { ramp($0, 0.2, 0.72) } ?? 0
    let chomp = up > 0.9 && Int(p.t * 8) % 2 == 0
    let cheeks = up > 0.9 ? 1 : 0

    drawLegs(c, Look(leg: shirt), step: p.step)
    burtonBoots(c, step: p.step, C(0x4A3020), height: 1)
    c.oy += p.breathe
    // The lederhosen's legs over the tops of his.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, leather); c.rect(28, 38, 1, seatedPose ? 1 : 2, leatherD)
    // The bigger block: two columns wider, a row taller, cheeks bulging out at its sides as he chews.
    c.rect(17, 25, 22, 13, clawdOrange); c.rect(38, 25, 1, 13, clawdShade)
    if cheeks > 0 { c.rect(16, 29, 1, 4, clawdOrange); c.rect(39, 29, 1, 4, clawdShade) }
    c.rect(14, 33, 3, 3, shirt); c.rect(39, 33, 3, 3, shirt)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(19, 31, 2, 1, C(0xE87A7A)); c.rect(35, 31, 2, 1, C(0xE87A7A))
    // The mouth, chomping, and the chocolate smeared round it.
    c.rect(26, 32, 4, chomp ? 1 : 1, chomp ? choc : C(0x7A2A1A))
    c.px(25, 31, choc); c.px(30, 33, choc); if eaten > 0.3 { c.px(24, 32, choc); c.px(31, 31, chocL) }
    if eaten > 0.7 { c.rect(25, 33, 2, 1, choc); c.px(29, 30, chocL) }
    // The shirt and the lederhosen bib with its braces.
    c.rect(17, 33, 22, 5, shirt); c.rect(38, 33, 1, 5, shirtD)
    c.rect(21, 33, 2, 5, leather); c.rect(33, 33, 2, 5, leather); c.rect(21, 35, 14, 3, leather);
    c.rect(17, 37, 22, 1, leatherD)
    c.pattern(26, 35, [".W.", "WYW", ".W."], ["W": C(0xF4F4F0), "Y": C(0xE8C040)])
    // Neat light-brown hair, parted.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHhHHHHHHHHH...",
        "..HHHHHHHHHhHHHHHHHHHH..",
        ".HHHHHHHHHH.HHHHHHHHHHH.",
        ".HHHHHHHHHHH.HHHHHHHHHH.",
        ".HHH..............HHHHH.",
        ".HH................HHH..",
    ], ["H": hair, "h": hairL])
    // The right hand: the chocolate bar going into his mouth, a candy bar raised to throw, or down.
    if up > 0 {
        let hx = 40 - up * 8, hy = 34 - up * 2
        burtonLine(c, 40, 34, hx + 1, hy, shirt, 1.2)
        let bar = Int(((1 - eaten) * 7).rounded())
        if bar > 0 {
            c.rect(Int(hx.rounded()) - bar + 1, Int(hy.rounded()) - 3, bar, 3, choc)
            c.rect(Int(hx.rounded()) - bar + 1, Int(hy.rounded()) - 3, bar, 1, chocL)
        }
        c.rect(Int(hx.rounded()), Int(hy.rounded()) - 3, 3, 4, C(0x8A3ACA));
        c.rect(Int(hx.rounded()) + 2, Int(hy.rounded()) - 2, 2, 2, clawdOrange)
    } else if armed(p) {
        c.oy += p.gunY
        burtonLine(c, 40, 34, 41.5, 31, shirt, 1.2); c.rect(40, 29, 3, 3, clawdOrange)
        c.pattern(41, 25, ["CC", "Cc", "CC", "SS"], ["C": choc, "c": chocL, "S": C(0xC8A03A)])
        c.oy -= p.gunY
    }
}

// MARK: - Veruca Saltt

/// Veruca Saltt: Clawd with dark ringlets hanging down her sides under a pink hairband, a frown, and a posh rose-pink
/// coat with a white fur collar and black buttons, black shoes. She throws walnuts. Signature: she stamps her foot,
/// twice, fists clenched.
private func drawVeruca(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xD86A8A), coatD = C(0xA84A68), fur = C(0xF6F2EA), hair = C(0x5A3420), hairL = C(0x8A5A34)
    let hairD = C(0x3A2014), shoe = C(0x16141A)
    let sig = p.signature
    let stamping = sig.map { $0 > 0.1 && $0 < 0.8 } ?? false
    let ph = sig.map { frac(ramp($0, 0.1, 0.8) * 2) } ?? 0
    let lift = stamping ? (ph < 0.6 ? Int((ramp(ph, 0, 0.4) * 4).rounded()) : 0) : 0
    let slam = stamping && ph >= 0.6 && ph < 0.85

    // Legs, the front one lifted to stamp.
    if seatedPose {
        drawLegs(c, Look(leg: clawdOrange), step: p.step)
    } else {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let walkUp = p.step >= 0 && i % 2 == p.step ? 1 : 0
            let up = i == 3 ? max(lift, walkUp) : walkUp
            c.rect(lx, 36, 2, 8 - up, clawdOrange); c.rect(lx, 42 - up, 2, 2, shoe)
            c.rect(lx, 41 - up, 2, 1, C(0xF4F4F0))
        }
    }
    if slam {
        c.pattern(37, 42, ["D...D", ".D.D.", "....."], ["D": C(0xC8B8A0, 0.8)])
        c.oy += 1
    }
    c.oy += p.breathe
    // The coat: its skirt over her legs, over the bottom of Clawd, the fur collar, buttons.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, coat); c.rect(17, seatedPose ? 38 : 39, 22, 1, coatD)
    drawBody(c, Look(arm: coat))
    clothes(c, coat, coatD)
    c.rect(18, 33, 20, 1, fur); c.pattern(22, 33, ["FFF......FFF", ".FF......FF."], ["F": fur])
    c.px(28, 35, ink); c.px(28, 37, ink)
    // The frown: brows slanting down to her nose, the mouth turned down.
    c.pattern(21, 27, ["KK........KK", "..K......K.."], ["K": hairD])
    c.pattern(26, 31, [".KK.", "K..K"], ["K": C(0x7A2A2A)])
    // Dark ringlets down her sides, a pink hairband over the top.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..PPPPPPPPPPPPPPPPPPPP..",
        ".HHHHHHlHHHHHHHHHlHHHHH.",
        ".HHHHH............HHHHH.",
        ".HHH................HHH.",
    ], ["H": hair, "l": hairL, "P": C(0xF08AB0)])
    for x in [15, 38] {
        c.pattern(x, 27, ["HH.", "HlH", ".HH", "HH.", "HlH", ".HH", "HH.", "HdH", ".d."], ["H": hair, "l": hairL,
            "d": hairD])
    }
    // Fists clenched up while she stamps, a walnut raised to throw, or arms down.
    if stamping {
        c.rect(14, 30, 3, 3, coat); c.rect(14, 29, 2, 2, clawdOrange); c.rect(39, 30, 3, 3, coat);
        c.rect(40, 29, 2, 2, clawdOrange)
    } else if armed(p) {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, coat, 1.2); c.rect(40, 29, 3, 3, clawdOrange)
        c.pattern(41, 25, [".NN.", "NnNN", "NNnN", ".NN."], ["N": C(0xC8A070), "n": C(0x8A6A40)])
        c.oy -= p.gunY
    }
}

// MARK: - Violet Bluregarde

/// Violet Bluregarde: Clawd with a sleek blonde bob, chewing gum all the time, in a sky-blue tracksuit with white
/// stripes down its sleeves and legs. She throws blue gum. Signature: she swells up into a huge round blueberry, her
/// face and bob on top of it, little arms and legs sticking out, then shrinks back.
private func drawViolet(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5AA0E8), suitD = C(0x3A78C0), hair = C(0xF0D070), hairL = C(0xFFF0A8), hairD = C(0xC8A040)
    let berry = C(0x4A3AB8), berryD = C(0x2E2488), berryL = C(0x7A6AE0)
    let k = held(p.signature, 0.08, 0.4, 0.68, 0.9)
    let chew = Int(p.t * 4) % 2 == 0

    if k > 0.3 {
        // The blueberry: a round ball, swelling, her face and bob on top, little limbs sticking out.
        let f = ramp(k, 0.3, 1), r = 9 + f * 5
        let cx = 28.0, cy = 43 - r
        for (i, lx) in [21, 25, 30, 34].enumerated() { c.rect(lx, 41 + i % 2, 2, 3 - i % 2, suit) }
        c.oy += p.breathe
        for y in Int(cy - r)...Int(cy + r) {
            for x in Int(cx - r)...Int(cx + r) {
                let dx = Double(x) + 0.5 - cx, dy = Double(y) + 0.5 - cy, d = (dx * dx + dy * dy).squareRoot()
                guard d <= r else { continue }
                let lit = (dx + dy) / r
                c.px(x, y, lit < -0.75 ? berryL : lit > 0.55 ? berryD : berry)
            }
        }
        let top = Int(cy - r)
        c.rect(Int(cx - r) - 2, Int(cy), 3, 3, suit); c.rect(Int(cx + r), Int(cy), 3, 3, suit)
        c.rect(23, top + 7, 2, 3, ink); c.rect(31, top + 7, 2, 3, ink);
        c.pattern(26, top + 11, ["KKK", ".K."], ["K": ink])
        c.pattern(20, top - 1, ["...HHHHHHHHHHH...", ".HHHHHHlHHHHHHHH.", "HHHHHHHHHHHHHHHHH", "HHH...........HHH",
                                "HH.............HH"], ["H": hair, "l": hairL])
        return
    }
    let tint = k / 0.3
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx + 1, 37, 1, 5, C(0xF4F4F0)) } }
    burtonBoots(c, step: p.step, C(0xF4F4F0), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(body: mix(clawdOrange, berry, tint), shade: mix(clawdShade, berryD, tint), arm: suit))
    clothes(c, suit, suitD)
    c.rect(18, 33, 20, 1, C(0xF4F4F0)); c.rect(28, 34, 1, 4, C(0xF4F4F0)); c.px(15, 34, C(0xF4F4F0));
    c.px(40, 34, C(0xF4F4F0))
    // The chewing mouth.
    c.pattern(26, 31, chew ? ["KKKK", ".KK."] : ["KKKK"], ["K": C(0x7A2A2A)])
    // The sleek blonde bob, a straight fringe.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHlHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        "..Hd................dH..",
    ], ["H": hair, "l": hairL, "d": hairD])
    if armed(p) {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, suit, 1.2); c.rect(40, 29, 3, 3, clawdOrange)
        c.pattern(41, 26, [".GG.", "GgGG", "GGGG", ".GG."], ["G": C(0x3A6AE0), "g": C(0x9AB8FF)])
        c.oy -= p.gunY
    }
}

// MARK: - Mike Teevee

/// Mike Teevee: Clawd with spiky brown hair and a scowl, in a grey hoodie with its hood down at his back, a video-game
/// controller in his hands. He fires a game zapper. Signature: the TV picture flickers through him, he shrinks down to
/// a few pixels and vanishes, then pops back to full size in a flash.
private func drawMikeTeevee(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    if let s = sig, s > 0.1 && s < 0.78 {
        let k = s < 0.48 ? 1 - ramp(s, 0.22, 0.48) * 0.88 : s < 0.62 ? 0.12 : 0.12 + ramp(s, 0.62, 0.72) * 0.88
        let keep = s < 0.48 ? 1 - ramp(s, 0.3, 0.48) * 0.5 : s < 0.62 ? 0.5 : 0.5 + ramp(s, 0.62, 0.72) * 0.5
        let glitch = s < 0.22 && Int(p.t * 14) % 3 == 0
        shrunk(c, k, keep: keep) { m in
            mikeFigure(m, p)
            if glitch { m.shift(dx: 1, dy: 0) }
        }
        if s >= 0.7 && s < 0.78 {
            let f = ramp(s, 0.7, 0.78)
            c.glowLine(28, 32, 28, 32, core: C(0xFFFFFF, 1 - f), glow: C(0x9AC8FF, 0.6 * (1 - f)), coreR: 2 + f * 6,
                       glowR: 4 + f * 9)
        }
        return
    }
    mikeFigure(c, p)
}

private func mikeFigure(_ c: PixelCanvas, _ p: Pose) {
    let hood = C(0x8A8C94), hoodD = C(0x666870), hoodL = C(0xA8AAB2), hair = C(0x4A2E1E), hairL = C(0x6A4630)
    let pad = C(0x2A2A32), padL = C(0x4A4A56)
    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    burtonBoots(c, step: p.step, C(0xE8E8E8), height: 2)
    c.oy += p.breathe
    // The hood down at his back.
    c.pattern(14, 29, ["..HH", ".HHH", "HHHH", "HHHH", ".HHh"], ["H": hood, "h": hoodD])
    drawBody(c, Look(arm: hood))
    clothes(c, hood, hoodD)
    c.rect(18, 33, 20, 1, hoodL); c.px(25, 34, C(0xE8E8E8)); c.px(30, 34, C(0xE8E8E8))
    c.rect(22, 36, 12, 1, hoodD)
    // A scowl.
    c.pattern(21, 28, ["KK........KK"], ["K": hair]); c.rect(26, 32, 4, 1, C(0x7A2A2A))
    // Spiky brown hair.
    c.pattern(17, 20, [
        "....H...H....H...H....",
        "...HH..HHH..HHH.HH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHlHHHHlHHHHHlHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH.HH..HHH..HH.HHHH.",
        ".HH................HH.",
    ], ["H": hair, "l": hairL])
    if armed(p) {
        // The game zapper, raised to fire.
        c.oy += p.gunY
        c.rect(38, 31, 3, 3, hood)
        c.pattern(40, 28, ["..OOOOOO", "WWWWWWWO", "WWWWWWWW", "WWK.....", "WW......"],
                  ["W": C(0xD8DCE4), "O": C(0xFF8A2A), "K": pad])
        return
    }
    // The controller in both hands at his chest, its buttons.
    c.rect(15, 33, 3, 3, hood); c.rect(38, 33, 3, 3, hood)
    c.pattern(23, 33, [".PPPPPPPPPP.", "PPpPPPPPrPgP", "PpppPPPPPPPP", ".PP......PP."],
              ["P": pad, "p": padL, "r": C(0xE84040), "g": C(0x40C060)])
}

// MARK: - Slugwurth

/// Slugwurth: the rival chocolatier, Clawd with sly narrowed eyes, a thin moustache and black hair slicked flat, in a
/// long charcoal overcoat with its collar turned up. He doesn't fight. Signature: a stolen recipe appears in his hand;
/// he glances one way, then the other, slips it inside his coat and pats it.
private func drawSlugwurth(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x34323C), coatD = C(0x22202A), coatL = C(0x55525F), hair = C(0x121014), hairL = C(0x3A3A48)
    let sig = p.signature
    let paper = held(sig, 0.06, 0.16, 0.6, 0.7)
    let tuck = sig.map { ramp($0, 0.5, 0.68) } ?? 0
    let look = sig.map { $0 > 0.18 && $0 < 0.32 ? -1 : $0 >= 0.32 && $0 < 0.48 ? 1 : 0 } ?? 0
    let pat = sig.map { $0 > 0.7 && $0 < 0.9 && Int(p.t * 8) % 2 == 0 } ?? false

    drawLegs(c, Look(leg: C(0x26242C)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0E0C10), height: 2)
    c.oy += p.breathe
    // The long overcoat: tails over his legs, over the bottom of Clawd, the collar turned up at his sides.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat, eye: nil))
    clothes(c, coat, coatD)
    c.pattern(23, 33, ["LL......LL", ".LL....LL.", "..L....L.."], ["L": coatL])
    c.pattern(16, 29, ["CC..................CC", "CCC................CCC", "CCC................CCC",
        "CCC................CCC"],
              ["C": coat])
    // Sly narrowed eyes, glancing; the thin moustache.
    for ex in [22, 32] {
        c.rect(ex - 1, 29, 4, 1, C(0x8E4A30)); c.rect(ex, 30, 2, 2, C(0xF0E8DC)); c.px(ex + (look < 0 ? 0 : 1), 30, ink)
        c.px(ex + (look < 0 ? 0 : 1), 31, ink)
    }
    c.pattern(24, 32, ["KKK..KKK"], ["K": hair])
    // Black hair slicked flat with a sheen.
    c.pattern(17, 22, [
        "...HHHHHHHHHHHHHHHH...",
        ".HHHhhhhhhhhhhhhhHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        ".HHH..............HHHH",
        "..H................HH.",
    ], ["H": hair, "h": hairL])
    // The recipe: held up in his hand, then slipped in under the coat; the hand patting it.
    if paper > 0 {
        let x = 40 - tuck * 12, y = 27 + tuck * 7
        fadeIn(c, alpha: paper) { r in
            r.pattern(Int(x.rounded()), Int(y.rounded()), ["PPPPP", "PLLLP", "PPPPP", "PLLPP", "PPPRP", "PPPPP"],
                      ["P": C(0xF0E4C4), "L": C(0x8A7A5A), "R": C(0xC8202A)])
        }
        burtonLine(c, 39.5, 34, x + 1, y + 4, coat, 1.2)
    } else if pat {
        burtonLine(c, 39.5, 34, 32, 34, coat, 1.2); c.rect(30, 33, 3, 2, clawdOrange)
    }
}

// MARK: - The Red Queen

/// The Red Queen: her enormous head is the Clawd block a size bigger, pale, its top rounded, with blue eyeshadow, tiny
/// heart-shaped red lips, red hair swept up into a heart with a heart-shaped fringe, and a little gold crown; a red
/// gown trimmed in gold with black hearts. She fights with a flamingo for a mallet. Signature: a hedgehog rolls up in
/// front of her, she swings the flamingo right round and whacks it away.
private func drawRedQueen(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF4EAE8), skinD = C(0xD4C4C4), red = C(0xC8202A), redD = C(0x8E1418), redL = C(0xE84050)
    let gold = C(0xE0B030), gown = C(0xB81A24), gownD = C(0x7E1018)
    let sig = p.signature
    var angle = p.melee
    var trail = p.trail
    if let s = sig, s > 0.18 && s < 0.9 {
        let keys: [(Double, Double)] = [(0.18, -75), (0.42, -165), (0.5, 35), (0.68, 25), (0.9, -75)]
        for i in 0..<(keys.count - 1) where s >= keys[i].0 && s < keys[i + 1].0 {
            let f = (s - keys[i].0) / (keys[i + 1].0 - keys[i].0), e = i == 1 ? 1 - pow(1 - f, 3) : f * f * (3 - 2 * f)
            angle = keys[i].1 + (keys[i + 1].1 - keys[i].1) * e
            if i == 1 && f > 0.1 { trail = [keys[i].1 + (keys[i + 1].1 - keys[i].1) * max(0, e - 0.25)] }
        }
    }
    // The hedgehog, curled up on the floor in front of her, then whacked away rolling.
    let hog = held(sig, 0.04, 0.16, 0.55, 0.72)
    if hog > 0, let s = sig {
        let hx = 51 + Int((ramp(s, 0.5, 0.72) * 10).rounded())
        let rows = Int(p.t * 12) % 2 == 0 || s < 0.5 ? [".K.K.K..", "KKKKKKFF", "KKKKKFFN", ".KKKKFF."]
                                                     : ["..K.K.K.", "FFKKKKKK", "NFFKKKKK", ".FFKKKK."]
        fadeIn(c, alpha: hog) { h in h.pattern(hx, 40, rows, ["K": C(0x5A3A22), "F": C(0xD8B888), "N": ink]) }
    }
    drawLegs(c, Look(leg: C(0x2A1A1E)), step: p.step)
    burtonBoots(c, step: p.step, C(0x14100E), height: 1)
    c.oy += p.breathe
    // The gown: wide over her legs, over the bottom of the block, gold at its neckline, black hearts.
    let skirt = seatedPose ? 1 : 3
    for y in 38..<(38 + skirt) { let hw = 12 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, y == 37 + skirt ? gownD : gown) }
    // The enormous head: the block a size up, its top corners rounded.
    for y in 23...37 {
        let inset = max(0, 3 - (y - 23))
        c.rect(16 + inset, y, 24 - inset * 2, 1, skin); c.px(39 - inset, y, skinD)
    }
    c.rect(16, 33, 24, 5, gown); c.rect(39, 33, 1, 5, gownD); c.rect(16, 33, 24, 1, gold)
    for x in [19, 27, 35] { c.pattern(x, 35, ["K.K", ".K."], ["K": burtonInk]) }
    c.rect(13, 33, 3, 3, gown); c.rect(40, 33, 3, 3, gown)
    // Blue eyeshadow, the eyes, a red cheek each side, the tiny heart lips.
    c.rect(20, 27, 4, 1, C(0x5A8AD8)); c.rect(32, 27, 4, 1, C(0x5A8AD8))
    c.rect(21, 28, 2, 3, ink); c.rect(33, 28, 2, 3, ink)
    c.pattern(26, 30, ["RR.RR", "RRRRR", ".RRR.", "..R.."], ["R": C(0xD81A2A)])
    // The red hair swept up into a heart, the fringe dipping in the middle; the little crown in the heart's dip.
    c.pattern(14, 11, [
        "....HHHHH........HHHHH....",
        "..HHHHHHHHH....HHHHHHHHH..",
        ".HHHHHlHHHHH..HHHHHlHHHHH.",
        "HHHHHlHHHHHH..HHHHlHHHHHHH",
        "HHHHlHHHHHHHHHHHHlHHHHHHHd",
        "HHHHHHHHHHHHHHHHHHHHHHHHHd",
        "HHHHHHHHHHHHHHHHHHHHHHHHHd",
        "HHHHHHHHHHHHHHHHHHHHHHHHHd",
        ".HHHHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHHHd.",
        "..HHHHHHHHHHHHHHHHHHHHHd..",
        "..HHHH....HHHHHH....HHHd..",
        "..HHH......HHHH......HHd..",
        "..HH........HH........Hd..",
        "..H....................d..",
    ], ["H": red, "l": redL, "d": redD])
    c.pattern(24, 9, ["Y..Y..Y", "YYYYYYY", "YRYYYRY"], ["Y": gold, "R": C(0xD81A2A)])
    // The flamingo: held by its legs, its body, the long neck and its head for the mallet's end.
    let a = angle ?? -75
    let h = queenHand
    for (i, ta) in trail.enumerated() {
        let e = burtonReach(h, ta, 15)
        c.glowLine(h.x, h.y, e.x, e.y, core: C(0xFFA8C0), glow: C(0xFFA8C0), coreR: 0.5, glowR: 2,
            strength: 0.3 / Double(i + 1))
    }
    let pink = C(0xF07A9A), pinkL = C(0xFFA8C0)
    let l0 = burtonReach(h, a, -1), l1 = burtonReach(h, a, 4), body = burtonReach(h, a, 7)
    let n1 = burtonReach(h, a, 14), head = burtonReach(h, a, 16)
    burtonLine(c, l0.x, l0.y, l1.x, l1.y, C(0xE8607A), 0.5)
    c.circle(Int(body.x.rounded()), Int(body.y.rounded()), 2, pink);
    c.px(Int(body.x.rounded()) - 1, Int(body.y.rounded()) - 1, pinkL)
    burtonLine(c, body.x, body.y, n1.x, n1.y, pink, 0.6)
    c.circle(Int(head.x.rounded()), Int(head.y.rounded()), 1, pink)
    let beak = burtonReach(head, a + 90, 2.5)
    burtonLine(c, head.x, head.y, beak.x, beak.y, burtonInk, 0.5)
    c.rect(41, 33, 3, 3, skin)
}

// MARK: - Stayne

/// Stayne: the Knave of Hearts, very tall: the Clawd block two rows taller, raised high on long thin legs with
/// plated knees and tall black boots, so he towers over the court. Long black hair down his sides, a black heart
/// patch over one eye on its strap, black armour with red hearts and heart-studded shoulder plates, and a long sword.
/// Signature: a slow, mocking bow, one hand on his sword's hilt and the other swept out.
private func drawStayne(_ c: PixelCanvas, _ p: Pose) {
    let bow = held(p.signature, 0.1, 0.32, 0.68, 0.9)
    let leg = C(0x1E1E26), lift = seatedPose ? 0 : stayneLift
    if seatedPose {
        drawLegs(c, Look(leg: leg), step: p.step)
    } else {
        // Long legs from under the raised armour skirt to the ground, a plate on each knee, tall boots.
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 36 - lift, 2, (lifted ? 7 : 8) + lift, leg)
            c.rect(lx, lifted ? 37 : 38, 2, 1, C(0x5A5A6E))
        }
    }
    burtonBoots(c, step: p.step, C(0x0C0C10), height: 4)
    c.oy += p.breathe - lift
    guard bow > 0 else { stayneFigure(c, p, bowing: false); return }
    // The bow: the upper body drawn on a layer and tipped forward about his hips.
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    stayneFigure(s, p, bowing: true)
    let hip = (x: 28.0 + Double(c.ox), y: 39.0 + Double(c.oy + c.baseY))
    let r = s.rotated(22 * bow, about: hip, into: c.w, c.h, at: hip)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(r)
    c.ox = ox; c.oy = oy; c.baseY = by
}

private func stayneFigure(_ c: PixelCanvas, _ p: Pose, bowing: Bool) {
    let armour = C(0x2E2E3A), armourD = C(0x1C1C24), armourL = C(0x5A5A6E), red = C(0xC8202A)
    let hair = C(0x16141A), hairL = C(0x3A3446)
    // The armour skirt over his legs, plated.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, armourD);
    for x in stride(from: 18, to: 38, by: 4) { c.rect(x, 38, 1, 2, armourL) }
    // The taller block, its forehead showing under the parting of his fringe.
    c.rect(18, 24, 20, 2, clawdOrange); c.rect(37, 24, 1, 2, clawdShade); c.rect(27, 23, 4, 1, clawdOrange)
    drawBody(c, Look(arm: armour, eye: nil))
    c.rect(22, 29, 2, 3, ink)
    // The heart-shaped eye patch over his other eye, its strap, a scar under it.
    c.pattern(31, 28, ["KK.KK", "KKKKK", ".KKK.", "..K.."], ["K": burtonInk])
    burtonLine(c, 31, 28.5, 18, 26, burtonInk, 0.5)
    c.rect(34, 32, 1, 2, C(0xA84A3A))
    c.rect(25, 32, 5, 1, C(0x7A2A2A))
    // The armour over the bottom of the block, red hearts on it, shoulder plates.
    clothes(c, armour, armourD)
    c.rect(18, 33, 20, 1, armourL)
    for x in [21, 27, 33] { c.pattern(x, 34, ["R.R", "RRR", ".R."], ["R": red]) }
    c.pattern(14, 31, ["PPPP", "PRRP", "PPPP"], ["P": armourL, "R": red]);
    c.pattern(38, 31, ["PPPP", "PRRP", "PPPP"], ["P": armour, "R": red])
    // Long black hair down his sides.
    c.pattern(16, 19, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHlHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHH....HHHHHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHH................HHH.", count: 6) + [
        "..HH................HH..",
    ], ["H": hair, "l": hairL])
    // The sword: swung, or in its black scabbard at his hip, his hand on the hilt as he bows.
    if let a = p.melee, !bowing {
        let h = Sprite.hand, blade = C(0xD8DCE4)
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 18)
            c.glowLine(h.x, h.y, e.x, e.y, core: blade, glow: blade, coreR: 0.4, glowR: 1.6,
                strength: 0.3 / Double(i + 1))
        }
        let b0 = burtonReach(h, a, 2), b1 = burtonReach(h, a, 16), tip = burtonReach(h, a, 18.5)
        let side = (x: cos((a + 90) * .pi / 180), y: sin((a + 90) * .pi / 180))
        burtonLine(c, b0.x, b0.y, b1.x, b1.y, blade, 0.8)
        burtonTriangle(c, (b1.x + side.x, b1.y + side.y), (b1.x - side.x, b1.y - side.y), (tip.x, tip.y), blade)
        let g0 = burtonReach(h, a + 90, 2.5), g1 = burtonReach(h, a - 90, 2.5), pom = burtonReach(h, a, -2.5)
        burtonLine(c, g0.x, g0.y, g1.x, g1.y, burtonInk, 0.6)
        c.rect(Int(pom.x.rounded()) - 1, Int(pom.y.rounded()) - 1, 2, 2, red)
        c.rect(40, 33, 3, 3, armour)
    } else {
        burtonLine(c, 37, 37, 43, 43, burtonInk, 0.9)
        c.rect(35, 35, 3, 1, burtonInk); c.rect(34, 34, 2, 2, red)
        if bowing {
            c.rect(36, 34, 3, 3, armour)
            burtonLine(c, 16.5, 34, 11, 37, armour, 1.1); c.rect(9, 37, 2, 2, clawdOrange)
        }
    }
}

// MARK: - The Jabberclawdky

/// The Jabberclawdky: a dragon at most a size up from Clawd: a dark slate body on four clawed legs, a long neck
/// curving up and forward to a narrow horned head with glowing violet eyes, its tail curling up behind ending in a
/// barb, and leathery bat wings folded along its back. It fights with jagged purple lightning from its jaws.
/// Signature: it rears its head, spreads its wings wide and roars, the roar rippling out.
private func drawJabberclawdky(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x3A3644), hideD = C(0x26222E), hideL = C(0x5A5466), belly = C(0x6A6276), claw = C(0xD8D0C0)
    let wing = C(0x4A3A5C), wingD = C(0x34283F), bone = C(0x6E5E80)
    let sig = p.signature
    let spread = held(sig, 0.08, 0.3, 0.75, 0.93)
    let roaring = sig.map { $0 > 0.3 && $0 < 0.75 } ?? false
    let casting = p.zap != nil || p.armRaise > 0
    let lift = Double(p.armRaise) + (roaring ? 2 : 0)

    // The wings: folded along its back, or spread wide, the far one behind.
    let shoulder = (x: 29.0, y: 27.0)
    let folded: [(Double, Double)] = [(15, 22), (20, 16), (26, 15)]
    let far: [(Double, Double)] = [(4, 14), (12, 5), (22, 3)]
    let near: [(Double, Double)] = [(7, 20), (17, 9), (30, 5)]
    func wingAt(_ open: [(Double, Double)], _ col: Px, _ dark: Px, dy: Double) {
        var tips: [(Double, Double)] = []
        for i in 0..<3 {
            let f = folded[i], o = open[i]
            tips.append((f.0 + (o.0 - f.0) * spread, f.1 + (o.1 - f.1) * spread + dy))
        }
        let root = (shoulder.x, shoulder.y + dy), back = (shoulder.x - 9, shoulder.y + 1 + dy)
        burtonTriangle(c, root, tips[0], back, dark)
        burtonTriangle(c, root, tips[0], tips[1], col)
        burtonTriangle(c, root, tips[1], tips[2], col)
        for t in tips { burtonLine(c, root.0, root.1, t.0, t.1, bone, 0.5) }
    }
    if spread > 0.05 { wingAt(far, wingD, C(0x281E30), dy: -1) }
    // The tail, curling up behind it, the barb on its end.
    for i in 0..<14 {
        let f = Double(i) / 13
        let x = 16 - f * 11 + sin(p.lt * 2 + f * 3) * 0.8, y = 35 - f * 9 + sin(f * .pi) * 1.5
        burtonLine(c, x, y, x, y, i % 3 == 0 ? hideL : hide, 1.9 - f * 0.8)
    }
    burtonTriangle(c, (5, 26), (2, 22), (8, 23), hideD)
    // Four clawed legs.
    for (i, lx) in [17, 22, 31, 36].enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 36, 3, lifted ? 6 : 7, i % 2 == 0 ? hide : hideD)
        c.pattern(lx - 1, lifted ? 42 : 43, ["C.C.C"], ["C": claw])
    }
    c.oy += p.breathe
    // The body: a block a size up, rounded at the top, belly plates underneath, scales on its back.
    for y in 26...38 {
        let inset = y == 26 ? 3 : y == 27 ? 1 : 0
        c.rect(15 + inset, y, 24 - inset * 2, 1, hide); c.px(38 - inset, y, hideD)
    }
    for y in [34, 36] { c.rect(19, y, 16, 1, belly) }
    c.rect(19, 38, 16, 1, hideD)
    for x in stride(from: 19, to: 36, by: 4) { c.px(x, 29, hideL); c.px(x + 2, 31, hideL) }
    for x in stride(from: 19, to: 31, by: 4) { burtonTriangle(c, (Double(x), 26.5), (Double(x) + 3, 26.5),
        (Double(x) + 1, 23.5), hideD) }
    if spread <= 0.05 { wingAt(near, wing, wingD, dy: 0) }
    // The long neck curving up and forward, spines along it.
    let head = (x: 49.0, y: 17.0 - lift)
    var prev = (x: 35.0, y: 30.0)
    for i in 1...8 {
        let f = Double(i) / 8
        let q = (x: 35 + (head.x - 35) * f, y: 30 + (head.y + 2 - 30) * (1 - (1 - f) * (1 - f)))
        burtonLine(c, prev.x, prev.y, q.x, q.y, hide, 2.4 - f * 0.9)
        if i % 2 == 0 { burtonTriangle(c, (q.x - 2, q.y - 1.5), (q.x, q.y - 1.5), (q.x - 2.5, q.y - 4), hideD) }
        prev = q
    }
    // The head: a long narrow snout, two swept-back horns, a glowing eye; the jaw open while it roars or casts.
    let open = roaring || p.zap == true ? 2 : 0
    let hx = Int(head.x.rounded()) - 4, hy = Int(head.y.rounded()) - 3
    c.pattern(hx - 3, hy - 5, ["dd...HH..", ".dd...HH.", "..dd.HHH.", "...ddHHH."], ["H": hide, "d": hideD])
    c.pattern(hx, hy, [
        ".HHHHHHH......",
        "HHHHEEHHHHHH..",
        "HHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHH",
    ], ["H": hide, "E": C(0xC88AFF)])
    c.pattern(hx + 1, hy + 4 + open, ["HHHHHHHHHHHH", ".HHHHHHHHHH."], ["H": hideD])
    if open > 0 {
        c.rect(hx + 4, hy + 4, 9, open, C(0x3A1028))
        for x in stride(from: hx + 5, to: hx + 13, by: 2) { c.px(x, hy + 4, claw); c.px(x + 1, hy + 4 + open, claw) }
    } else {
        for x in stride(from: hx + 6, to: hx + 13, by: 3) { c.px(x, hy + 4, claw) }
    }
    c.glowLine(Double(hx) + 5, Double(hy) + 1.5, Double(hx) + 5, Double(hy) + 1.5, core: C(0xE8C8FF),
        glow: C(0x7A2BD1, 0.6),
               coreR: 0.5, glowR: casting ? 3 : 2)
    if spread > 0.05 { wingAt(near, wing, wingD, dy: 0) }
    // The roar rippling out of its jaws.
    if roaring {
        for k in 0..<3 {
            let f = (p.t * 1.6 + Double(k) / 3).truncatingRemainder(dividingBy: 1), r = 3 + f * 8
            for s in -3...3 {
                let a = -0.3 + Double(s) * 0.2
                c.px(hx + 14 + Int((cos(a) * r).rounded()), hy + 4 + Int((sin(a) * r).rounded()), C(0xE8C8FF,
                    0.8 * (1 - f)))
            }
        }
    }
}

// MARK: - The Bandersnatch

/// The Bandersnatch: a huge shaggy white beast, its own shape at Clawd's size: a ragged white furry body with black
/// spots on four thick legs, and a big flat-faced head jutting out in front with small fierce eyes, a dark nose and an
/// enormous underbite of fangs. It fights with its jaws. Signature: it shakes its shaggy head from side to side,
/// tufts of fur flying.
private func drawBandersnatch(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xEEECE6), furD = C(0xC4C0B8), spot = C(0x2A2830), mouth = C(0x4A1A22), fang = C(0xFFFCF0)
    let sig = p.signature
    let shaking = sig.map { $0 > 0.1 && $0 < 0.85 } ?? false
    let shake = shaking ? (Int(p.t * 12) % 2 == 0 ? -2 : 2) : 0
    // The bite: wide open with the weapon raised, snapping shut as it swings down.
    var open = 0
    if let a = p.melee { open = Int(((0.5 - 0.5 * sin(a * .pi / 180)) * 4).rounded()) }

    // Four thick shaggy legs.
    for (i, lx) in [17, 22, 30, 35].enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 37, 4, lifted ? 5 : 6, i % 2 == 0 ? fur : furD)
        c.rect(lx, lifted ? 41 : 42, 4, 1, furD); c.px(lx + 1, lifted ? 42 : 43, spot);
        c.px(lx + 3, lifted ? 42 : 43, spot)
    }
    c.oy += p.breathe
    // The shaggy body, ragged along its top and hanging in tufts at its belly; black spots.
    for x in 14...38 {
        let top = 25 + Int(noise(x * 13 + 5) * 2.5), bottom = 38 + Int(noise(x * 7 + 1) * 2)
        c.rect(x, top, 1, bottom - top, x >= 37 ? furD : fur)
    }
    c.rect(14, 37, 25, 1, furD)
    for (sx, sy) in [(17, 29), (24, 27), (21, 34), (30, 31), (27, 36), (34, 27)] {
        c.rect(sx, sy, 2, 2, spot); c.px(sx + 2, sy, spot)
    }
    // The head jutting out in front, shaking: the brow, the eyes, the nose, the huge jaws.
    c.ox += shake
    let hy = 23
    c.pattern(33, hy, [
        "...FFFFFFFFF....",
        ".FFFFFFFFFFFFF..",
        "FFFFFFFFFFFFFFF.",
        "FFFFKKFFFFKKFFF.",
        "FFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFNNN",
        "FFFFFFFFFFFFFNNN",
    ], ["F": fur, "K": C(0x6A9AC8), "N": spot])
    c.rect(37, hy + 3, 1, 1, spot); c.rect(43, hy + 3, 1, 1, spot)
    c.rect(36, hy + 2, 3, 1, furD); c.rect(42, hy + 2, 3, 1, furD)
    // Upper jaw, the open mouth, the jutting lower jaw with its fangs pointing up.
    c.rect(36, hy + 7, 13, 1, fur)
    c.rect(37, hy + 8, 12, open, mouth)
    let jy = hy + 8 + open
    for x in stride(from: 38, through: 48, by: 2) { c.px(x, hy + 8, fang) }
    c.pattern(35, jy, ["JJJJJJJJJJJJJJJ", ".JJJJJJJJJJJJJJ", "..JJJJJJJJJJJJ."], ["J": furD])
    for x in [38, 41, 44, 47] { c.rect(x, jy - 2, 1, 2, fang) }
    // Fur tufts flying off as it shakes.
    if shaking {
        for i in 0..<4 {
            let f = (p.t * 2 + Double(i) / 4).truncatingRemainder(dividingBy: 1)
            let side = i % 2 == 0 ? -1.0 : 1.0
            let x = 41 + side * (4 + f * 10), y = Double(hy) - f * 6 + Double(i)
            c.px(Int(x.rounded()), Int(y.rounded()), fur.alpha(1 - f));
            c.px(Int(x.rounded()) + 1, Int(y.rounded()), fur.alpha(0.6 * (1 - f)))
        }
    }
    c.ox -= shake
    // A bite's smear: pale arcs where the jaws just snapped.
    if !p.trail.isEmpty, p.melee != nil {
        for k in 0..<3 { c.px(51 + k, 28 + k * 3, fang.alpha(0.5)); c.px(52 + k, 29 + k * 3, fang.alpha(0.3)) }
    }
}

// MARK: - A Red Card Knight

/// A Red Card Knight: one of the Red Queen's soldiers, armour made of playing cards: the Clawd block a white card face
/// with a red border, a red helmet on top with a heart crest, red card-plate shoulders, a skirt of fanned cards with
/// red hearts over its legs, and a spear with a red tassel. Signature: it snaps to attention, stamping the spear's butt
/// down, clank, clank.
private func drawRedCardKnight(_ c: PixelCanvas, _ p: Pose) {
    let card = C(0xF6F2EA), cardD = C(0xD8D0C4), red = C(0xC8202A), redD = C(0x8E1418), redL = C(0xE84050)
    let sig = p.signature
    let attention = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false
    let clank = sig.map { ($0 > 0.3 && $0 < 0.4) || ($0 > 0.6 && $0 < 0.7) } ?? false
    let stamp = sig.map { ($0 > 0.2 && $0 < 0.3) || ($0 > 0.5 && $0 < 0.6) } ?? false

    drawLegs(c, Look(leg: redD), step: attention ? -1 : p.step)
    burtonBoots(c, step: attention ? -1 : p.step, burtonInk, height: 2)
    c.oy += p.breathe + (attention ? -1 : 0)
    // The skirt of fanned cards over its legs.
    if !seatedPose {
        for (i, x) in [17, 22, 27, 32].enumerated() {
            c.rect(x, 37, 6, 4, card); c.rect(x, 37, 1, 4, cardD)
            c.pattern(x + 2, 38, ["R.R", "RRR", ".R."], ["R": i % 2 == 0 ? red : redD])
        }
    }
    // The card face: a red border round the block.
    drawBody(c, Look(body: card, shade: cardD, arm: red))
    c.rect(18, 26, 1, 12, red); c.rect(37, 26, 1, 12, redD); c.rect(18, 37, 20, 1, redD)
    c.pattern(25, 33, ["RR.RR.", "RRRRR.", ".RRR..", "..R..."], ["R": red])
    c.rect(26, 33, 1, 1, redL)
    // Red card-plate shoulders.
    c.pattern(13, 31, ["RRRRR", ".RRRR", "..RRR"], ["R": red]);
    c.pattern(38, 31, ["RRRRR", "RRRR.", "RRR.."], ["R": redD])
    // The red helmet, its rim over its brow, the heart crest on top.
    c.pattern(17, 19, [
        "........R..R..........",
        ".......RRRRRR.........",
        "........RRRR..........",
        ".....RRRRRRRRRRRR.....",
        "...RRRRLLRRRRRRRRRR...",
        "..RRRLLRRRRRRRRRRRRR..",
        ".RRRRRRRRRRRRRRRRRRRd.",
        "RRRRRRRRRRRRRRRRRRRRRd",
        "dddddddddddddddddddddd",
    ], ["R": red, "L": redL, "d": redD])
    // The spear: levelled along its thrust, or held upright, stamped down at attention.
    let shaft = C(0x6A4A2E), steel = C(0xD8DCE4)
    if let a = p.melee, !attention {
        let h = Sprite.hand
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 18)
            c.glowLine(h.x, h.y, e.x, e.y, core: steel, glow: steel, coreR: 0.4, glowR: 1.5,
                strength: 0.3 / Double(i + 1))
        }
        let s0 = burtonReach(h, a, -6), s1 = burtonReach(h, a, 15), tip = burtonReach(h, a, 20)
        let side = (x: cos((a + 90) * .pi / 180) * 1.8, y: sin((a + 90) * .pi / 180) * 1.8)
        burtonLine(c, s0.x, s0.y, s1.x, s1.y, shaft, 0.6)
        burtonTriangle(c, (s1.x + side.x, s1.y + side.y), (s1.x - side.x, s1.y - side.y), (tip.x, tip.y), steel)
        c.rect(Int(s1.x.rounded()) - 1, Int(s1.y.rounded()), 2, 2, red)
        c.rect(40, 33, 3, 3, red)
    } else {
        let up = stamp ? 2 : 0
        let bottom = seatedPose ? 39 : 43
        c.rect(41, 14 - up, 1, bottom - 14, shaft)
        burtonTriangle(c, (39, 15 - Double(up)), (44, 15 - Double(up)), (41.5, 9 - Double(up)), steel)
        c.rect(40, 15 - up, 3, 2, red); c.px(40, 17 - up, redD); c.px(42, 17 - up, redD)
        c.rect(39, 33, 3, 3, red)
        if clank {
            c.pattern(42, 39, ["W...W", ".W.W.", "W...W"], ["W": C(0xFFF4C0, 0.9)])
        }
    }
}
