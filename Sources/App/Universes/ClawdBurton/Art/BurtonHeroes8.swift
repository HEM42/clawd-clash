import Foundation

// Heroes: Alice in Wonderland. From Underland: Alice Kingsclawd with the Vorpal sword, Tarrant Hightop the Hatter,
// Chessur the grinning cat, Mirana the White Queen, McTwisp the White Rabbit, Mally the Dormouse and Thackery Hare. The
// people are Clawd in costume; the animals keep their own shapes at Clawd's size.

let burtonHeroes8: [BurtonHero: Persona] = [
    .aliceKingsclawd: Persona(name: "Alice Kingsclawd", weapon: .saber, headTop: 20, signature: 3.6,
                              callout: "Six impossible things.", draw: drawAlice),
    .tarrantHightop: Persona(name: "Tarrant Hightop", weapon: .blaster, shot: .thrown(C(0x2AB8B0)), muzzle: (45, 27),
                             headTop: 10, signature: 3.4, callout: "Fairfarren!", draw: drawTarrant),
    .chessur: Persona(name: "Chessur", weapon: .none, motion: .hover, canSit: false, headTop: 19, signature: 3.6,
                      callout: "Lost, are we?", draw: drawChessur),
    .mirana: Persona(name: "Mirana the White Queen", weapon: .none, headTop: 17, signature: 3.4, draw: drawMirana),
    .mcTwisp: Persona(name: "McTwisp", weapon: .none, headTop: 12, signature: 3.4, draw: drawMcTwisp),
    .mally: Persona(name: "Mally the Dormouse", weapon: .saber, pivot: smallHand, headTop: 25, signature: 3.0,
                    draw: drawMally),
    .thackeryHare: Persona(name: "Thackery Hare", weapon: .blaster, shot: .thrown(C(0xF4F4F0)), muzzle: (43, 27),
                           headTop: 14, signature: 3.2, draw: drawThackery),
]

/// A small Clawd's hand (the Oompa-Loompah, Mally): Mally's hatpin swings from there.
private let smallHand = (x: 36.5, y: 34.5)

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

/// Pastes `art` (drawn on its own layer) over `c` with every pixel at `alpha`.
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

/// Draws `art` on its own layer and lays it over `c` shrunk to `k` of its size about the point between its feet.
private func shrunk(_ c: PixelCanvas, _ k: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let a = (x: 28.0, y: 44.0 + Double(c.baseY))
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<c.h {
        for x in 0..<c.w {
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

/// A small Clawd (a 14×9 block at (21, 30)) on short legs, its eyes on the block; applies the breathing bob.
private func smallClawd(_ c: PixelCanvas, _ p: Pose, body: Px, shade: Px, leg: Px, shoe: Px, step: Int? = nil) {
    let st = step ?? p.step
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = st >= 0 && i % 2 == st
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg); c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, body); c.rect(21, 38, 14, 1, shade); c.rect(34, 30, 1, 9, shade)
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
}

// MARK: - Alice Kingsclawd

/// Alice Kingsclawd: Clawd with long straight blonde hair falling down her sides, in a pale blue dress; when she
/// fights, silver armour, and the Vorpal sword, a long bright blade with a gold crossguard. Signature: she drinks from
/// a tiny bottle and shrinks, sparkling, to half her size for a moment, then grows back.
private func drawAlice(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.32, 0.42), 1 - ramp($0, 0.66, 0.78)) } ?? 0
    let drinking = sig.map { $0 > 0.06 && $0 < 0.34 } ?? false
    if k > 0 {
        shrunk(c, 1 - k * 0.5) { aliceFigure($0, p, drinking: false) }
        if k < 0.99 || Int(p.t * 8) % 3 == 0 {
            for i in 0..<5 {
                let a = Double(i) / 5 * 2 * .pi + p.t * 3, r = 6 + (1 - k) * 6
                let x = 28 + Int((cos(a) * r).rounded()), y = 36 + Int((sin(a) * r * 0.7).rounded())
                c.pattern(x - 1, y - 1, [".W.", "WWW", ".W."], ["W": C(0xFFF4C0, 0.6)])
            }
        }
        return
    }
    aliceFigure(c, p, drinking: drinking)
}

private func aliceFigure(_ c: PixelCanvas, _ p: Pose, drinking: Bool) {
    let dress = C(0x7AA8E0), dressD = C(0x5A86C0), hair = C(0xF0D070), hairL = C(0xFFF0A8), hairD = C(0xC8A040)
    let steel = C(0xA8B0BC), steelD = C(0x6A7280), steelL = C(0xDCE2EA)
    let armour = p.mode == .working

    drawLegs(c, Look(leg: armour ? steelD : clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, armour ? steel : C(0x3A3040), height: armour ? 3 : 1)
    c.oy += p.breathe
    if armour {
        drawBody(c, Look(arm: steel))
        clothes(c, steel, steelD)
        c.rect(18, 33, 20, 1, steelL); c.rect(27, 34, 2, 3, steelL); c.rect(18, 36, 20, 1, steelD)
        c.rect(14, 32, 4, 2, steelL); c.rect(38, 32, 4, 2, steel)
    } else {
        // The dress: its skirt over her legs, the bodice over the bottom of Clawd, a white collar.
        c.rect(17, 38, 22, seatedPose ? 1 : 2, dress); c.rect(17, seatedPose ? 38 : 39, 22, 1, dressD)
        drawBody(c, Look(arm: dress))
        clothes(c, dress, dressD)
        c.pattern(24, 33, ["WWWWWWWW", ".WW..WW."], ["W": C(0xF4F4F8)])
    }
    // Long straight blonde hair over the top of her and down her sides.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHlHHHHHHHHHH....",
        "..HHHHHlHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHH.....HHHHHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHd................dHH.", count: 7) + [
        "..Hd................dH..",
    ], ["H": hair, "l": hairL, "d": hairD])
    if drinking {
        // The tiny bottle tipped up to her lips.
        burtonLine(c, 39.5, 34, 35.5, 31.5, armour ? steel : dress, 1.1); c.rect(33, 30, 3, 3, clawdOrange)
        c.pattern(29, 29, [".CC.", "BBBB", "BLBB", "BBBB"], ["C": C(0xC8A070), "B": C(0x5AB0E8), "L": C(0xF4F0E0)])
        return
    }
    if let a = p.melee {
        // The Vorpal sword along its swing, a faint silver smear behind a fast one.
        let h = Sprite.hand
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 15)
            c.glowLine(h.x, h.y, e.x, e.y, core: steelL, glow: steelL, coreR: 0.4, glowR: 1.6,
                strength: 0.3 / Double(i + 1))
        }
        let g0 = burtonReach(h, a + 90, 2), g1 = burtonReach(h, a - 90, 2)
        let b0 = burtonReach(h, a, 2), b1 = burtonReach(h, a, 14), tip = burtonReach(h, a, 16.5)
        let s0 = burtonReach(h, a, -2.5)
        burtonLine(c, s0.x, s0.y, h.x, h.y, C(0x5A3A2A), 0.6)
        burtonLine(c, b0.x, b0.y, b1.x, b1.y, steelL, 0.8)
        burtonTriangle(c, (b1.x + cos((a + 90) * .pi / 180), b1.y + sin((a + 90) * .pi / 180)),
                       (b1.x - cos((a + 90) * .pi / 180), b1.y - sin((a + 90) * .pi / 180)), (tip.x, tip.y), steelL)
        burtonLine(c, g0.x, g0.y, g1.x, g1.y, C(0xD8B040), 0.6)
        c.rect(40, 33, 3, 3, clawdOrange)
    } else if armour {
        c.pattern(38, 36, ["G", "GG", ".S", ".S", ".S"], ["G": C(0xD8B040), "S": steelD])
    }
}

// MARK: - Tarrant Hightop

/// Tarrant Hightop: the Hatter, a chalk-white Clawd with wild green eyes ringed in pink, a gap-toothed grin, frizzy
/// orange hair bursting out at his sides and, on top, his tall patched hat with a peach ribbon, pins and the 10/6
/// card in its band; a plum coat and a big floppy bow. He throws hats. Signature: the Futterwacken, a wild little jig,
/// jerking side to side, legs flying and arms flailing.
private func drawTarrant(_ c: PixelCanvas, _ p: Pose) {
    let face = C(0xF4F2EC), faceD = C(0xD4D0C8), frizz = C(0xE8702A), frizzL = C(0xFFA050), frizzD = C(0xB84A18)
    let coat = C(0x5A3A5A), coatD = C(0x3E2840), hat = C(0x5E4E42), hatL = C(0x7E6C5A), hatD = C(0x3E322A)
    let sig = p.signature
    let jig = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false
    let beat = Int(p.t * 10) % 2
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)

    if jig { c.ox += beat == 0 ? -1 : 1; c.oy -= Int((abs(sin(p.t * 5 * .pi)) * 2).rounded()) }
    drawLegs(c, Look(leg: C(0x6A4A7A)), step: jig ? beat : p.step)
    burtonBoots(c, step: jig ? beat : p.step, C(0x7A4A2A), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: face, shade: faceD, arm: coat, eye: nil))
    clothes(c, coat, coatD)
    // The big floppy bow at his neck.
    c.pattern(22, 33, ["BBB....BBB", "BBBBKKBBBB", "BBB....BBB"], ["B": C(0xE88A6A), "K": C(0xC8604A)])
    // Wild green eyes ringed in pink, and the gap-toothed grin.
    for ex in [21, 31] {
        c.rect(ex, 28, 4, 1, C(0xE87AA0)); c.rect(ex, 29, 4, 3, C(0x4AC070)); c.rect(ex + 1, 29, 2, 2, ink)
    }
    let grin = jig ? ["K........K", ".WWWW.WWW.", "..KKKKKK.."] : ["K........K", ".WWWW.WWW."]
    c.pattern(23, 31, grin, ["K": ink, "W": C(0xFFFFFF)])
    // The frizzy orange hair bursting out at his sides under the hat.
    c.pattern(12, 23, [
        "..FFFFFFFFFFFFFFFFFFFFFFFFFFF..",
        ".FFLFFF..................FFLFF.",
        "FFFFFF....................FFFFF",
        ".FLFF......................FLFF",
        "FFFDF......................FDFF",
        ".FFFF......................FFF.",
        "FFDF........................FDF",
        ".FFF........................FF.",
        "..FF........................F..",
        "...F...........................",
    ], ["F": frizz, "L": frizzL, "D": frizzD])
    // The tall patched hat, leaning a little and widening towards its top; the ribbon, the 10/6 card, pins.
    for y in 10...23 {
        let w = 12 + (23 - y) * 6 / 13 / 2 * 2, x0 = 28 - w / 2 + (23 - y) / 7
        c.rect(x0, y, w, 1, hat); c.px(x0 + 1, y, hatL); c.px(x0 + w - 1, y, hatD)
    }
    c.rect(22, 19, 13, 3, C(0xF0A07A)); c.rect(22, 21, 13, 1, C(0xC8785A))
    c.pattern(30, 15, ["WWWW", "WKKW", "WWWW"], ["W": C(0xF4F0E0), "K": C(0x4A3A2A)])
    c.rect(24, 12, 3, 3, C(0x6A5A8A)); c.rect(32, 11, 2, 2, C(0x8A6A3A)); c.px(26, 17, C(0xE84040));
    c.px(25, 16, C(0x40C0E8))
    c.rect(16, 24, 25, 1, hat); c.rect(17, 25, 23, 1, hatD)
    // Arms: flailing in the jig, a spare teal hat raised to throw, or down.
    if jig {
        let ly = beat == 0 ? 26.0 : 37, ry = beat == 0 ? 37.0 : 26
        burtonLine(c, 16.5, 34, 12.5, ly, coat, 1.1); burtonLine(c, 39.5, 34, 43.5, ry, coat, 1.1)
        c.rect(11, Int(ly) - 1, 2, 2, face); c.rect(43, Int(ry) - 1, 2, 2, face)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, coat, 1.2); c.rect(40, 30, 3, 2, face)
        c.pattern(39, 25, [".TTT.", ".TTT.", ".tTT.", "TTTTT"], ["T": C(0x2AB8B0), "t": C(0x7AE0D8)])
        c.oy -= p.gunY
    }
}

// MARK: - Chessur

/// Chessur: the Cheshire cat, his own shape at Clawd's size: a round grey-blue block with dark teal stripes, pointed
/// ears, glowing yellow-green eyes and an enormous white grin, floating off the ground on stubby striped legs, his
/// striped tail curling up behind. He doesn't fight. Signature: he fades away until only the grin is left hanging in
/// the air, then comes back.
private func drawChessur(_ c: PixelCanvas, _ p: Pose) {
    let fade = held(p.signature, 0.08, 0.34, 0.64, 0.86)
    fadeIn(c, alpha: 1 - fade) { chessurBody($0, p) }
    // The grin, which never fades.
    c.oy += p.breathe
    c.pattern(19, 31, [
        "W.................W",
        "WWWWWWWWWWWWWWWWWWW",
        ".WWgWWgWWgWWgWWgWW.",
        "..WWWWWWWWWWWWWWW..",
        "....WWWWWWWWWWW....",
    ], ["W": C(0xFAFAF4), "g": C(0xA8B0C0)])
    c.oy -= p.breathe
}

private func chessurBody(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x7A8CAC), furL = C(0x9AACCB), stripe = C(0x3A6A80), eye = C(0xD8F04A)
    // The tail curling up behind him, striped, swaying.
    for i in 0..<16 {
        let f = Double(i) / 15
        let x = 18 - f * 11 + sin(f * 2.5 + p.t * 2) * 1.5, y = 34 - f * 12 + sin(f * .pi) * -2
        burtonLine(c, x, y, x, y, i % 4 < 2 ? fur : stripe, 1.2)
    }
    // Stubby striped legs, dangling as he floats.
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 38, 2, lifted ? 3 : 4, fur); c.rect(lx, 39, 2, 1, stripe)
    }
    c.oy += p.breathe
    // Pointed ears.
    burtonTriangle(c, (18, 28), (25, 28), (19, 19), fur); burtonTriangle(c, (20, 27), (23, 27), (20.5, 22), C(0xC890A8))
    burtonTriangle(c, (31, 28), (38, 28), (37, 19), fur); burtonTriangle(c, (33, 27), (36, 27), (36.5, 22), C(0xC890A8))
    // The round striped block.
    for y in 25...37 {
        let inset = y == 25 ? 2 : y == 26 ? 1 : 0
        c.rect(18 + inset, y, 20 - inset * 2, 1, fur)
    }
    c.rect(19, 26, 8, 1, furL)
    for x in stride(from: 20, to: 37, by: 4) {
        c.rect(x, 25 + (x % 3), 2, 3, stripe); c.rect(x - 1, 35, 2, 3, stripe)
    }
    c.rect(37, 27, 1, 11, C(0x5A6C8A)); c.rect(15, 32, 3, 3, fur); c.rect(38, 32, 3, 3, fur)
    // Glowing eyes with slit pupils.
    for ex in [21, 31] {
        c.glowLine(Double(ex) + 1.5, 29.5, Double(ex) + 1.5, 29.5, core: eye, glow: eye.alpha(0.3), coreR: 0.5,
                   glowR: 3)
        c.rect(ex, 28, 4, 3, eye); c.rect(ex + 1, 28, 1, 3, ink)
    }
    c.pattern(26, 30, ["PPP", ".P."], ["P": C(0xE87AA0)])
}

// MARK: - Mirana

/// Mirana the White Queen: a pale white Clawd with dark arched brows and black lips, long flowing white hair and a
/// little silver crown, in a white gown with silver trim, sweeping wide over her legs. She harms no living thing, so
/// she doesn't fight. Signature: she floats both hands up into a graceful pose, little sparkles at her fingertips.
private func drawMirana(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF6ECEA), skinD = C(0xD8CCCC), gown = C(0xE6E4F2), gownD = C(0xB4B0CC), trim = C(0x9A9AB8)
    let hair = C(0xFCFCFE), hairD = C(0xC0C0D6), lips = C(0x1A1418)
    let lift = held(p.signature, 0.08, 0.36, 0.76, 0.94)

    drawLegs(c, Look(leg: skinD), step: p.step)
    burtonBoots(c, step: p.step, trim, height: 1)
    c.oy += p.breathe
    // The gown sweeping wide over her legs.
    let skirt = seatedPose ? 1 : 3
    for y in 38..<(38 + skirt) { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, y == 37 + skirt ? gownD : gown) }
    drawBody(c, Look(body: skin, shade: skinD, arm: gown))
    clothes(c, gown, gownD)
    c.rect(18, 33, 20, 1, trim); c.pattern(25, 34, ["T....T", ".TTTT."], ["T": trim])
    // Dark arched brows, black lips.
    c.pattern(21, 27, ["KKK.......KKK"], ["K": C(0x3A3040)])
    c.pattern(26, 31, ["KKKK", ".KK."], ["K": lips])
    // Long flowing white hair and the little silver crown.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHdHHHHHHHHHHdHHHHH.",
        ".HHHHHHHH......HHHHHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHd................dHH.", count: 6) + [
        ".HHd................dHH.",
        "..Hd................dH..",
    ], ["H": hair, "d": hairD])
    c.pattern(24, 17, ["S..S..S", "SSSSSSS", ".SSBSS."], ["S": C(0xC8CCDC), "B": C(0x8AB8E8)])
    guard lift > 0 else { return }
    // Hands floating up and out, wrists bent; sparkles twinkling at her fingertips.
    let ly = 34 - lift * 10, lx = 16.5 - lift * 4, rx = 39.5 + lift * 4
    burtonLine(c, 16.5, 34, lx, ly, gown, 1.0); burtonLine(c, 39.5, 34, rx, ly, gown, 1.0)
    c.rect(Int(lx.rounded()) - 2, Int(ly.rounded()) - 1, 2, 2, skin);
    c.rect(Int(rx.rounded()) + 1, Int(ly.rounded()) - 1, 2, 2, skin)
    if lift > 0.9 {
        for (i, sx) in [lx - 3, rx + 3].enumerated() {
            let k = 0.5 + 0.5 * sin(p.t * 6 + Double(i) * 2)
            let x = Int(sx.rounded()), y = Int(ly.rounded()) - 4
            c.pattern(x - 1, y - 1, [".W.", "WWW", ".W."], ["W": C(0xFFFFFF, k * 0.9)])
        }
    }
}

// MARK: - McTwisp

/// McTwisp: the White Rabbit, his own shape at Clawd's size: a white furry block for a head, tall ears with pink
/// insides standing up on top, a pink nose and whiskers, a red waistcoat with gold buttons and the chain of his pocket
/// watch, on four white legs. He doesn't fight. Signature: he pulls out the pocket watch and checks it, then hops
/// anxiously on the spot.
private func drawMcTwisp(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xF6F4F0), furD = C(0xD6D0C8), pink = C(0xF0A8B0), vest = C(0xA8282A), vestD = C(0x7A1A1C)
    let gold = C(0xE0B030)
    let sig = p.signature
    let watch = held(sig, 0.06, 0.16, 0.4, 0.48)
    let hopping = sig.map { $0 > 0.48 && $0 < 0.92 } ?? false
    let hop = hopping ? -Int((abs(sin(ramp(sig ?? 0, 0.48, 0.92) * .pi * 3)) * 3).rounded()) : 0

    c.oy += hop
    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, furD) } }
    c.oy += p.breathe
    // The tall ears, standing up; flicking back while he hops.
    let flick = hopping && hop < -1 ? 1 : 0
    c.rect(20 - flick, 13 + flick, 4, 14, fur); c.rect(21 - flick, 15 + flick, 2, 10, pink)
    c.rect(31, 12 + flick, 4, 15, fur); c.rect(32, 14 + flick, 2, 11, pink); c.rect(34, 12 + flick, 1, 15, furD)
    drawBody(c, Look(body: fur, shade: furD, arm: fur))
    // The nose, whiskers and buck teeth.
    c.rect(27, 31, 2, 1, C(0xE8788A)); c.rect(27, 32, 2, 1, C(0xFFFFFF))
    c.pattern(23, 30, ["GG........GG", "..G......G.."], ["G": C(0xA8A8B0)])
    // The waistcoat and the watch chain.
    clothes(c, vest, vestD)
    c.pattern(25, 33, ["WWWWWW", ".WWWW."], ["W": C(0xF4F4F8)]); c.px(28, 35, gold); c.px(28, 37, gold)
    c.pattern(29, 35, ["GG..", "..GG"], ["G": gold])
    guard watch > 0 else { return }
    // The pocket watch held up to his face, its hand ticking round.
    let wy = 34 - watch * 6
    burtonLine(c, 39.5, 34, 41, wy + 1, fur, 1.1)
    let cx = 42, cy = Int(wy.rounded()) - 2
    c.circle(cx, cy, 3, gold); c.circle(cx, cy, 2, C(0xFAF8F0)); c.px(cx, cy - 4, gold)
    let a = p.t * 4
    c.px(cx, cy, ink); c.px(cx + Int((cos(a) * 1.6).rounded()), cy + Int((sin(a) * 1.6).rounded()), ink)
}

// MARK: - Mally the Dormouse

/// Mally the Dormouse: a small Clawd as a dormouse, sandy fur, big round ears with pink insides, a pink nose and
/// whiskers, a red tunic with a belt, and her hatpin for a sword, a long silver pin with a pearl on its end. Fierce.
/// Signature: she brandishes the hatpin, high, thrust, thrust, high again.
private func drawMally(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xD8C4A0), furD = C(0xB09A78), pink = C(0xF0A0A8), tunic = C(0xB8282A), tunicD = C(0x8A1A1C)
    let sig = p.signature
    var angle = p.melee
    if let s = sig, s > 0.06 && s < 0.92 {
        let keys: [(Double, Double)] = [(0.06, -60), (0.22, -95), (0.36, 0), (0.46, -30), (0.58, 0), (0.7, -100),
                                        (0.92, -60)]
        for i in 0..<(keys.count - 1) where s >= keys[i].0 && s < keys[i + 1].0 {
            let f = (s - keys[i].0) / (keys[i + 1].0 - keys[i].0), e = f * f * (3 - 2 * f)
            angle = keys[i].1 + (keys[i + 1].1 - keys[i].1) * e
        }
    }
    // The tail curling behind her.
    burtonLine(c, 20, 37, 16, 35, pink, 0.5); burtonLine(c, 16, 35, 15, 32, pink, 0.5)
    c.circle(23, 28, 3, fur); c.rect(22, 27, 2, 2, pink); c.circle(32, 28, 3, fur); c.rect(32, 27, 2, 2, pink)
    smallClawd(c, p, body: fur, shade: furD, leg: fur, shoe: furD)
    // The snout, nose and whiskers.
    c.rect(35, 33, 2, 2, fur); c.px(36, 33, pink)
    c.pattern(33, 32, ["...GG", ".....", "...GG"], ["G": C(0x8A7A6A)])
    // The tunic and its belt.
    c.rect(21, 35, 14, 4, tunic); c.rect(34, 35, 1, 4, tunicD); c.rect(21, 37, 14, 1, C(0x5A3A22))
    c.px(27, 37, C(0xD8B040)); c.rect(18, 35, 3, 2, fur)
    // The hatpin: swung along its angle, or tucked in her belt.
    if let a = angle {
        let h = smallHand
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 13)
            c.glowLine(h.x, h.y, e.x, e.y, core: C(0xE8ECF4), glow: C(0xE8ECF4), coreR: 0.4, glowR: 1.4,
                       strength: 0.25 / Double(i + 1))
        }
        let s0 = burtonReach(h, a, -2), e = burtonReach(h, a, 13)
        burtonLine(c, h.x, h.y, e.x, e.y, C(0xD8DCE4), 0.55)
        c.circle(Int(s0.x.rounded()), Int(s0.y.rounded()), 1, C(0xF8F4F0))
        c.rect(35, 34, 3, 2, fur)
    } else {
        c.rect(35, 35, 3, 2, fur)
        burtonLine(c, 22, 39, 33, 35, C(0xD8DCE4), 0.5); c.circle(21, 39, 1, C(0xF8F4F0))
    }
}

// MARK: - Thackery Hare

/// Thackery Hare: the March Hare, his own shape at Clawd's size: a ragged tan furry block for a head, long tatty ears
/// (one bent over), wild staring eyes that don't match, buck teeth, a frayed olive jacket, and a teapot always in his
/// hand. He twitches. He throws teacups. Signature: he flings a teacup over his shoulder without looking, and it sails
/// away behind him and smashes.
private func drawThackery(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xB0926A), furD = C(0x7E6444), furL = C(0xCCB088), jacket = C(0x6A6A3E), jacketD = C(0x4A4A2A)
    let china = C(0xF4F4F0), blue = C(0x5A7AC8)
    let sig = p.signature
    let fling = sig.map { ramp($0, 0.12, 0.34) } ?? 0
    let flying = sig.map { ramp($0, 0.3, 0.72) } ?? 0
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)
    let twitch = noise(Int(p.lt * 5)) > 0.82

    if let s = sig, s >= 0.72 && s < 0.9 {
        let k = ramp(s, 0.72, 0.9)
        for i in 0..<5 {
            let dx = (Double(i) - 2) * (1 + k * 2), x = 9 + Int(dx.rounded()),
                y = 42 - Int((sin(k * .pi) * Double(3 - abs(i - 2))).rounded())
            c.px(x, y, china.alpha(1 - k)); if i % 2 == 0 { c.px(x, y - 1, blue.alpha(1 - k)) }
        }
    }
    if twitch && sig == nil { c.ox += 1 }
    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, furD) } }
    c.oy += p.breathe
    // Long tatty ears: one upright, one bent over at the top; a notch out of it.
    c.rect(20, 14, 4, 13, fur); c.rect(21, 16, 2, 9, C(0xD89090)); c.px(20, 18, C(0, 0))
    c.rect(31, 18, 4, 9, fur); c.rect(32, 20, 2, 6, C(0xD89090))
    c.pattern(31, 14, ["FFFFFF.", "FFFFFFF", "...PPFF", ".....FF"], ["F": fur, "P": C(0xD89090)])
    if twitch { c.rect(31, 14, 4, 4, fur); c.rect(32, 15, 2, 3, C(0xD89090)) }
    // The ragged block, tufts sticking out at its edges.
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    for y in stride(from: 26, through: 32, by: 3) { c.px(17, y, fur); c.px(38, y + 1, furD) }
    c.pattern(20, 26, ["L.L..L...L.L..L.L"], ["L": furL])
    // Wild mismatched eyes, buck teeth.
    c.rect(21, 28, 4, 4, C(0xFAF6E8)); c.rect(23, 29, 1, 1, ink)
    c.rect(31, 29, 3, 3, C(0xFAF6E8)); c.px(31, 30, ink)
    c.rect(26, 32, 4, 1, C(0x5A3A2A)); c.rect(27, 33, 2, 1, C(0xFFFFFF))
    // The frayed jacket.
    clothes(c, jacket, jacketD)
    c.rect(27, 33, 2, 1, C(0xFFFFFF)); c.rect(21, 34, 3, 2, C(0x8A5A3A))
    c.pattern(18, 38, ["J.JJ.J..JJ.J.JJ..J.J"], ["J": jacket])
    // The right hand: the arm flinging back over his head, a teacup raised to throw, or holding the teapot.
    if fling > 0 && fling < 1 {
        let a = -10 - fling * 160, e = burtonReach((39.5, 33.0), a, 9)
        burtonLine(c, 39.5, 33, e.x, e.y, jacket, 1.1);
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fur)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, jacket, 1.1); c.rect(40, 29, 3, 3, fur)
        c.pattern(41, 25, ["WWWW", "WBBWW", "WWWW.", ".WW.."], ["W": china, "B": blue])
        c.oy -= p.gunY
    } else {
        c.rect(38, 33, 3, 3, fur)
        c.pattern(39, 34, ["..WW...", ".WWWW..", "WWBBWWW", "WBWWBW.", "WWWWWW.", ".WWWW.."], ["W": china, "B": blue])
    }
    // The teacup sailing over his shoulder behind him, spinning, before it smashes.
    if flying > 0 && flying < 1 {
        let x = 36 - flying * 27, y = 22 - sin(flying * .pi) * 10 + flying * flying * 18
        let cup = Int(p.t * 12) % 2 == 0 ? ["WWWW.", "WBBWW", ".WW.."] : [".WW..", "WBBWW", "WWWW."]
        c.pattern(Int(x.rounded()) - 2, Int(y.rounded()) - 1, cup, ["W": china, "B": blue])
    }
}
