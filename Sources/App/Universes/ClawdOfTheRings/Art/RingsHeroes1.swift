import Foundation

// Heroes: the hobbits of the Shire. Every one of them is Clawd in costume, hobbit-sized: three quarters of a Clawd
// (head top on row 27, a 16 px body), with brown curls over the head top, a waistcoat over a shirt, a travelling cloak
// with the leaf brooch and big bare hairy feet (no boots), drawn over and around a small blocky body of their own. The
// face is Clawd's own orange.

let ringsHeroes1: [LOTRHero: Persona] = [
    .frodo: Persona(name: "Frodough Bagclawds", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                    callout: "I will take the Ring!", draw: drawFrodo),
    .sam: Persona(name: "Samwise Gamjee", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.2,
                  callout: "Po-tay-toes!", draw: drawSam),
    .pippin: Persona(name: "Pippin Tookmuch", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                     callout: "Second breakfast?", draw: drawPippin),
]

// MARK: - The hobbit

/// Where a hobbit's weapon hand is: just past the 2×2 fist at x 36…37, rows 36…37 (Clawd's is (41.5, 34.5)).
private let hobbitHand = (x: 38.5, y: 36.5)

/// What tells one hobbit from another: the colours of the curls, waistcoat, shirt, breeches and cloak, and what each
/// carries about him (the Ring on its chain, a pack with the pan on it, or nothing at all).
private struct HobbitKit {
    let curl: Px, curlLight: Px, curlDark: Px
    let waistcoat: Px, waistcoatDark: Px, shirt: Px, breeches: Px
    let cloak: Px, cloakEdge: Px
    let prop: HobbitProp
}

private enum HobbitProp { case ring, pack, none }

private let brass = C(0xC8A04A), leaf = C(0x7FBF5A), silver = C(0xC8D0D8)
private let ringGold = C(0xE8B33A), ringChain = C(0x9AA0A8)

/// The hobbit every one of them is, at three quarters of Clawd's size: the cloak hanging down the back, breeches to the
/// shin and the bare feet (a pixel wider than a leg, Clawd orange with dark hair on top), a small blocky body (x 20…35,
/// rows 31…39) with ink eyes and arm nubs, the waistcoat open over the shirt with two brass buttons, the cloak's front
/// edges and the leaf brooch, the curls over the head top (row 27), and what the kit carries (the pack behind, or the
/// Ring on its chain at the chest). `armRight` raises the right hand; `wince` squeezes the eyes shut; a sword still in
/// its sheath (`sheath`) hangs at the hip. Sitting, it sits 2 px less low than a Clawd, so its feet still show.
private func drawHobbit(_ c: PixelCanvas, _ p: Pose, _ k: HobbitKit, armRight: Int = 0, wince: Bool = false,
                        sheath: Bool = false) {
    if seatedPose { c.oy -= 2 }
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: k.cloak, edge: k.cloakEdge, hem: 42)
    if sheath { drawSheath(c) }
    drawHobbitFeet(c, k, step: p.step)
    c.oy += p.breathe
    if k.prop == .pack { drawPack(c, pan: p.melee == nil) }
    // The body, its arm nubs and the eyes (or the wince).
    c.rect(20, 31, 16, 9, clawdOrange)
    c.rect(20, 39, 16, 1, clawdShade)
    c.rect(35, 31, 1, 9, clawdShade)
    c.rect(18, 36, 2, 2, clawdOrange)
    c.rect(36, 36 - armRight, 2, 2, clawdOrange)
    if wince {
        c.rect(22, 34, 3, 1, ink); c.rect(31, 34, 3, 1, ink)
    } else {
        c.rect(23, 33, 2, 3, ink); c.rect(31, 33, 2, 3, ink)
    }
    // The waistcoat over the shirt, open at the neck, and its buttons.
    c.rect(20, 36, 16, 4, k.waistcoat)
    c.rect(35, 36, 1, 4, k.waistcoatDark)
    c.rect(20, 39, 16, 1, k.waistcoatDark)
    c.pattern(25, 36, ["SSSSSS", ".SSSS.", "..SS.."], ["S": k.shirt])
    c.px(28, 39, brass); c.px(30, 37, brass)
    // The cloak's front edges over the shoulders, and the leaf brooch that pins it.
    c.rect(20, 36, 2, 4, k.cloak); c.rect(20, 36, 1, 4, k.cloakEdge)
    c.rect(34, 36, 2, 4, k.cloak); c.rect(35, 36, 1, 4, k.cloakEdge)
    c.pattern(20, 35, [".SS.", "SLLS", ".SS."], ["S": silver, "L": leaf])
    // The curls.
    c.pattern(19, 27, [
        "...CCl.CCl.CCl.C..",
        ".CClCCCClCCCClCCl.",
        "CCdClCCdClCCdClCCC",
        "CClCCdClCCdClCCdCC",
        "CCd............dCC",
        "Cl..............lC",
        ".d..............d.",
    ], ["C": k.curl, "l": k.curlLight, "d": k.curlDark])
    // The Ring on its chain, at the chest (unless it's out for the signature).
    if k.prop == .ring, p.signature == nil {
        dots(c, 26, 36, 27, 37, ringChain); dots(c, 29, 36, 28, 37, ringChain)
        c.px(28, 38, ringGold)
    }
}

/// Breeches to the shin, then bare hobbit feet: a pixel wider than the leg, toes forward, with tufts of hair on top.
/// Folded forward when sitting, the feet sticking out in front.
private func drawHobbitFeet(_ c: PixelCanvas, _ k: HobbitKit, step: Int) {
    if seatedPose {
        for lx in [20, 24, 29, 33] {
            c.rect(lx - 1, 40, 2, 2, k.breeches)
            c.rect(lx + 1, 40, 2, 2, clawdOrange)
            c.px(lx + 1, 40, k.curl)
        }
        return
    }
    for (i, lx) in [20, 24, 29, 33].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, 38, 2, bottom - 40, k.breeches)
        c.rect(lx, bottom - 2, 2, 1, clawdOrange)
        c.rect(lx, bottom - 1, 3, 2, clawdOrange)
        c.px(lx + 2, bottom, clawdShade)
        c.px(lx, bottom - 2, k.curl); c.px(lx + 1, bottom - 1, k.curl.alpha(0.7))
    }
}

/// A short sword in its leather sheath, hanging at the left hip and sloping back behind the legs.
private func drawSheath(_ c: PixelCanvas) {
    let drop: Double = seatedPose ? 1 : 3                                  // sitting: laid back along the ground
    bar(c, 21, 38.5, 14.5, 38.5 + drop, C(0x4A3420), 0.6)
    c.px(14, 38 + Int(drop), silver)
}

/// Samwise's pack on his back: a bulging canvas sack with a bedroll on top and, unless it's in his hand, the frying
/// pan strapped to the back of it.
private func drawPack(_ c: PixelCanvas, pan: Bool) {
    let sack = C(0x7A6844), sackDark = C(0x5A4C30), roll = C(0x8A3A2A)
    c.rect(13, 32, 7, 7, sack)
    c.rect(14, 31, 5, 1, sack)
    c.rect(13, 38, 7, 1, sackDark); c.rect(13, 32, 1, 7, sackDark)
    c.rect(13, 35, 7, 1, sackDark)
    c.rect(12, 29, 8, 2, roll); c.rect(12, 29, 8, 1, C(0xA85A44)); c.px(12, 30, C(0x5A2418))
    if pan {
        bar(c, 14.5, 29.0, 12.5, 25.5, C(0x6A4A2A), 0.6)
        c.circle(15, 34, 2, C(0x2A2A30))
        c.px(14, 33, C(0x4A4A54))
    }
}

// MARK: - Frodough

private let frodoKit = HobbitKit(curl: C(0x3A2414), curlLight: C(0x6A4428), curlDark: C(0x24160A),
                                 waistcoat: C(0x6A5A3A), waistcoatDark: C(0x4E4228),
                                 shirt: C(0xE8E0C8), breeches: C(0x4A4232), cloak: C(0x4A6A3A), cloakEdge: C(0x34502A),
                                 prop: .ring)

/// Frodough, hobbit-sized: Clawd under dark curls, an earth-brown waistcoat over a cream shirt, the green elven cloak
/// and its leaf brooch, bare hairy feet, and the Ring on its chain, a gold glint at his chest. He fights with Sting, a
/// short elven blade. Signature: he lifts the chain out from his shirt, slips the Ring onto his finger and is gone:
/// only a quarter-strength ghost with a shimmering silver outline is left, and a few sparkles in the air, until he
/// takes it off and fades back in.
private func drawFrodo(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawFrodoBody(c, p, sig: nil); return }
    // 0.35…0.45 fading out, gone until 0.8, back by 1.
    let gone: Double = s < 0.35 ? 0 : s < 0.45 ? smooth((s - 0.35) / 0.1) : s < 0.8 ? 1 : 1 - smooth((s - 0.8) / 0.2)
    guard gone > 0 else { drawFrodoBody(c, p, sig: s); return }
    layer(c, alpha: 1 - 0.75 * gone, shimmer: gone, t: p.t) { drawFrodoBody($0, p, sig: s) }
    for i in 0..<3 {
        let f = frac(p.t * 0.9 + Double(i) / 3)
        let x = 21 + Int(noise(i * 31 + Int(p.t * 0.9 + Double(i) / 3)) * 14), y = 29 + i * 4 - Int(f * 3)
        let a = gone * (0.5 + 0.45 * sin(f * .pi))
        c.px(x, y, C(0xF4F8FF, a))
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(x + dx, y + dy, C(0xF4F8FF, a * 0.45)) }
    }
}

private func drawFrodoBody(_ c: PixelCanvas, _ p: Pose, sig: Double?) {
    let k = frodoKit, gold = ringGold, chain = ringChain
    // The Ring: on its chain at the chest; lifted on the chain up to the hand (…0.15); off the chain and slipped on
    // (…0.35); on the finger from then on.
    let lift: Double = sig.map { smooth(min(1, $0 / 0.15)) } ?? 0
    let slip: Double = sig.map { smooth(min(1, max(0, ($0 - 0.15) / 0.2))) } ?? 0
    let raise = sig == nil ? 0 : Int((4 * lift - 2 * slip).rounded())
    drawHobbit(c, p, k, armRight: raise, sheath: p.melee == nil)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawSting(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawSting(c, angle: a)
        c.rect(36, 36, 2, 2, clawdOrange)
        return
    }
    guard let s = sig else { return }
    let hand = (x: 37.0, y: 36.0 - Double(raise))
    if s < 0.15 {
        // Up on the chain, out of the shirt, into his hand.
        let rx = 28 + (hand.x - 28) * lift, ry = 38 + (hand.y - 1 - 38) * lift
        let x = Int(rx.rounded()), y = Int(ry.rounded())
        dots(c, 26, 36, x, y, chain); dots(c, 29, 36, x, y, chain)
        c.px(x, y, gold)
        return
    }
    // In his hand, then on the finger: a glint as it goes on.
    let rx = Int(hand.x.rounded()), ry = Int((hand.y - 1).rounded())
    c.px(rx, ry, gold)
    if s > 0.18 && s < 0.36 {
        let g = sin((s - 0.18) / 0.18 * .pi)
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(rx + dx, ry + dy, C(0xFFF0B0, 0.8 * g)) }
        c.px(rx - 2, ry, C(0xFFF0B0, 0.4 * g)); c.px(rx + 2, ry, C(0xFFF0B0, 0.4 * g)); c.px(rx, ry - 2, C(0xFFF0B0, 0.4 * g))
    }
}

/// Sting, gripped at the hand: a leather grip, a curved silver guard and a short (8 px) leaf-shaped elven blade.
private func drawSting(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    prop(c, at: hobbitHand, angle: angle, alpha: alpha) { s in
        let blade = C(0xD8E0E8), edge = C(0x9AA4B0), guardSilver = C(0xB8C0C8)
        s.px(17, 20, edge)
        s.rect(18, 20, 3, 1, C(0x5A3A22))
        s.rect(21, 19, 1, 3, guardSilver); s.px(20, 19, guardSilver); s.px(20, 21, guardSilver)
        s.rect(22, 20, 7, 1, blade)
        s.rect(22, 21, 6, 1, edge)
        s.rect(24, 19, 3, 1, C(0xF2F6FA))
        s.px(29, 20, edge)
    }
}

// MARK: - Samwise

private let samKit = HobbitKit(curl: C(0x5A3A1E), curlLight: C(0x8A6238), curlDark: C(0x3E2812),
                               waistcoat: C(0x8A6A3A), waistcoatDark: C(0x6A4E28),
                               shirt: C(0xE8E0C8), breeches: C(0x5A4630), cloak: C(0x5E4A2A), cloakEdge: C(0x44361E),
                               prop: .pack)

/// Samwise, hobbit-sized: Clawd under sandy-brown curls, a tan waistcoat, a brown cloak and bare hairy feet, his pack
/// on his back with a bedroll on top and the frying pan strapped on behind. He takes the pan off the pack to fight
/// with, swung like a club. Signature: supper: a little pot held at his belly, stirred round and round with a spoon,
/// steam rising, and halfway through he holds up a potato for everyone to see.
private func drawSam(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.04 && $0 < 0.96 ? $0 : nil }
    let potato = sig.map { $0 > 0.42 && $0 < 0.62 } ?? false
    let th: Double = p.t * 6
    let stirHand = Int((1 + sin(th)).rounded())
    drawHobbit(c, p, samKit, armRight: sig == nil ? 0 : potato ? 6 : stirHand)
    c.px(20, 37, C(0x4A3A22)); c.px(21, 38, C(0x4A3A22))                     // the pack's strap at the shoulder
    if let s = sig {
        // The pot at his belly, the spoon going round in it, steam rising.
        let pot = C(0x3A3A40), potLight = C(0x5A5A62), wood = C(0xB8946A)
        let bx: Double = potato ? 40 : 39.5 + 1.5 * cos(th), by: Double = potato ? 37.5 : 38 + 0.5 * sin(th)
        let hx: Double = potato ? 42 : 37.5 + cos(th), hy: Double = potato ? 34.5 : 36 - Double(stirHand) + 0.4 * sin(th)
        c.rect(36, 37, 7, 1, potLight)
        bar(c, hx, hy, bx, by, wood, 0.6)
        c.rect(36, 38, 7, 3, pot); c.rect(37, 41, 5, 1, pot)
        c.rect(36, 38, 7, 1, potLight); c.px(35, 38, pot); c.px(43, 38, pot)
        c.px(41, 39, potLight)
        for i in 0..<3 {
            let f = frac(p.t * 0.7 + Double(i) / 3)
            let x = 37 + i * 2 + Int((sin(f * 9 + Double(i)) * 1.2).rounded()), y = 35 - Int(f * 8)
            let a: Double = 1 - 0.85 * f
            c.px(x, y, C(0xFFFFFF, 0.95 * a)); c.px(x + 1, y, C(0xFFFFFF, 0.6 * a))
            c.px(x, y + 1, C(0xFFFFFF, 0.45 * a))
        }
        if potato {
            let u = ((s - 0.42) / 0.2)
            let lift = Int((sin(min(1, u * 3) * .pi / 2) * 2).rounded())
            c.pattern(35, 26 - lift, [".PPP.", "PPpPP", "PPPpP", ".PPP."], ["P": C(0xC8A060), "p": C(0x9A7A40)])
            c.rect(36, 30 - lift, 2, 2, clawdOrange)
        }
        return
    }
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawPan(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawPan(c, angle: a)
        c.rect(36, 36, 2, 2, clawdOrange)
    }
}

/// Sam's frying pan, gripped by the end of the handle: a wooden handle and a heavy black pan, swung like a club.
private func drawPan(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    prop(c, at: hobbitHand, angle: angle, alpha: alpha) { s in
        s.rect(17, 20, 7, 1, C(0x6A4A2A)); s.rect(17, 21, 6, 1, C(0x4E3420))
        s.circle(27, 20, 3, C(0x2A2A30))
        s.circle(27, 20, 2, C(0x3A3A42))
        s.px(26, 18, C(0x6A6A74)); s.px(25, 19, C(0x5A5A64))
    }
}

// MARK: - Pippin

private let pippinKit = HobbitKit(curl: C(0x6A4424), curlLight: C(0x9A6A3A), curlDark: C(0x4A2E16),
                                  waistcoat: C(0x3A5A7A), waistcoatDark: C(0x2A4258),
                                  shirt: C(0xE8E0C8), breeches: C(0x5A4E3A), cloak: C(0x4A5A6A), cloakEdge: C(0x36424E),
                                  prop: .none)

/// Pippin, hobbit-sized: Clawd under chestnut curls, a blue waistcoat, a grey-blue cloak and bare hairy feet, a short
/// sword at his hip that he fights with. Signature: the well in the mines: he can't help giving the little bucket on
/// its rim a nudge; it tips over the edge and drops out of sight, he squeezes his eyes shut, and a "!!" pops up over
/// his head.
private func drawPippin(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let wince = sig.map { $0 > 0.3 && $0 < 0.95 } ?? false
    let reach = sig.map { $0 > 0.05 && $0 < 0.17 } ?? false
    let ground = c.oy - (p.seated ? 4 : 0)                                  // the rim and bucket stand on the floor
    drawHobbit(c, p, pippinKit, armRight: reach ? 1 : 0, wince: wince, sheath: p.melee == nil)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawShortSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawShortSword(c, angle: a)
        c.rect(36, 36, 2, 2, clawdOrange)
        return
    }
    guard let s = sig else { return }
    if reach { c.rect(38, 35, 2, 2, clawdOrange) }                         // reaching out for it
    // 0…0.3 nudged along the rim and over the edge; then down out of the canvas.
    let body = c.oy
    c.oy = ground
    if s < 0.3 {
        let u = max(0, (s - 0.12) / 0.18)
        drawBucket(c, x: 45 + 5 * smooth(u), y: 40, angle: u > 0.75 ? 70 * (u - 0.75) / 0.25 : 0)
    } else {
        let u = (s - 0.3) / 0.7
        drawBucket(c, x: 51 + 4 * u, y: 40 + 60 * pow(u, 1.5), angle: 70 + 300 * u)
    }
    drawWell(c, alpha: min(1, min(s, 1 - s) / 0.05))   // the rim in front of the falling bucket
    c.oy = body
    if s > 0.52 && s < 0.78 {
        let pop = s < 0.56 ? 1 : 0
        let bang = C(0xFFE14A)
        c.rect(27, 19 - pop, 2, 4, bang); c.rect(27, 24 - pop, 2, 1, bang)
        c.rect(30, 20 - pop, 1, 3, bang); c.px(30, 24 - pop, bang)
    }
}

/// The rim of the old well in front of him: a low wall of grey stones, faded in by `alpha`.
private func drawWell(_ c: PixelCanvas, alpha: Double) {
    let stone = C(0x7A7C82, alpha), dark = C(0x4E5056, alpha), light = C(0x9A9CA2, alpha)
    c.rect(40, 40, 9, 4, stone)
    c.rect(40, 40, 9, 1, light)
    for (x, y) in [(42, 41), (45, 42), (47, 41), (41, 43), (44, 43)] { c.px(x, y, dark) }
    c.rect(40, 42, 9, 1, dark.alpha(0.6))
}

/// A little wooden bucket with an iron band and a handle, standing on (`x`, `y`) (its bottom sits on the row above),
/// tipped `angle` degrees.
private func drawBucket(_ c: PixelCanvas, x: Double, y: Double, angle: Double) {
    prop(c, at: (x, y - 1), angle: angle) { s in
        let wood = C(0x6A4A2A), dark = C(0x4A3220), band = C(0x8A8E94)
        s.rect(18, 20, 4, 2, wood); s.rect(17, 19, 6, 1, wood)
        s.rect(18, 20, 4, 1, band)
        s.px(18, 21, dark)
        s.pattern(17, 17, [".BBBB.", "B....B"], ["B": dark])
    }
}

/// Pippin's short sword, gripped at the hand: a dark grip and gold pommel, a gold guard and a plain bright blade.
private func drawShortSword(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    prop(c, at: hobbitHand, angle: angle, alpha: alpha) { s in
        let blade = C(0xC8CCD4), edge = C(0x8A8F9C), gold = C(0xC8A040)
        s.rect(18, 20, 3, 1, C(0x3A2A1C)); s.px(17, 20, gold)
        s.rect(21, 18, 1, 5, gold)
        s.rect(22, 20, 8, 1, blade)
        s.rect(22, 21, 8, 1, edge)
        s.rect(23, 20, 5, 1, C(0xF0F2F6))
        s.px(30, 20, blade); s.px(31, 20, edge)
    }
}

// MARK: - Shared helpers

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// A one-pixel line of dots from (x0, y0) to (x1, y1): a chain.
private func dots(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px) {
    let n = max(abs(x1 - x0), abs(y1 - y0))
    guard n > 0 else { c.px(x0, y0, col); return }
    for i in 0...n {
        let f = Double(i) / Double(n)
        c.px(x0 + Int((Double(x1 - x0) * f).rounded()), y0 + Int((Double(y1 - y0) * f).rounded()), col)
    }
}

/// A hobbit-sized cape hanging down the back from row 32, seen from the side: it shows past the shoulder blade and
/// between the back legs, so the legs still read in front of it. Its hem sways at `speed` and ends on row `hem`.
private func drawBackCape(_ c: PixelCanvas, t: Double, speed: Double, color: Px, edge: Px, hem: Int = 43) {
    let top = 32
    let last = min(hem, 43 - c.oy)
    guard last >= top else { return }
    for y in top...last {
        let k = Double(y - top) / Double(max(1, hem - top))
        let sway = sin(t * speed + k * 2.2) * k * 1.3
        let l = Int((17.5 - k * 3 + sway).rounded())
        let r = 26 + Int((k * 1.5).rounded())
        c.rect(l, y, r - l + 1, 1, color)
        c.px(l, y, edge)
    }
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
private func bar(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.1)
}

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c` faded to `alpha`. With `shimmer` (0…1)
/// its outline (every pixel with an empty neighbour) also glimmers in a pale silver, flickering on `t`:
/// what's left of someone wearing the Ring.
private func layer(_ c: PixelCanvas, alpha: Double = 1, shimmer: Double = 0, t: Double = 0, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let tick = Int(t * 10)
    for y in 0..<s.h {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            guard s.buf[i + 3] > 0 else { continue }
            c.px(x, y, unpremultiplied(s, i).alpha(alpha))
            guard shimmer > 0 else { continue }
            let edge = !s.isDrawn(x - 1, y) || !s.isDrawn(x + 1, y) || !s.isDrawn(x, y - 1) || !s.isDrawn(x, y + 1)
            guard edge else { continue }
            let f = 0.55 + 0.45 * noise(x * 7 + y * 13 + tick * 5)
            c.px(x, y, C(0xE8EEF6, 0.55 * f * shimmer))
        }
    }
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}
