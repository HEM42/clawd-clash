import Foundation

// Heroes: the hobbits of the Shire. Every one of them is Clawd in costume, hobbit-sized: three quarters of a Clawd
// (head top on row 27, a 16 px body), with brown curls over the head top, a waistcoat over a shirt, a travelling cloak
// with the leaf brooch and big bare hairy feet (no boots), drawn over and around a small blocky body of their own. The
// face is Clawd's own orange.

let ringsHeroes1: [RingsHero: Persona] = [
    .frodo: Persona(name: "Frodough Bagclawds", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                    callout: "I will take the Ring!", draw: drawFrodo),
    .sam: Persona(name: "Samwise Gamjee", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.2,
                  callout: "Po-tay-toes!", draw: drawSam),
    .pippin: Persona(name: "Pippin Tookmuch", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                     callout: "Second breakfast?", draw: drawPippin),
    .merry: Persona(name: "Merge-y Brandybranch", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                    callout: "Ride now, ride for main!", draw: drawMerry),
    .bilbo: Persona(name: "Bilbyte Bagclawds", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.4,
                    callout: "I'm going on a refactor!", draw: drawBilbo),
    .rosie: Persona(name: "Rosie Kotlin", weapon: .saber, pivot: hobbitHand, headTop: 26, signature: 3.0,
                    callout: "Samwise? He's my one non-nullable.", draw: drawRosie),
    .farmerMaggot: Persona(name: "Farmer Mag-git", weapon: .saber, pivot: hobbitHand, bulk: 1, headTop: 23,
                           signature: 3.2, callout: "Trespassers! Who's been cherry-picking my mushrooms?", draw: drawMaggot),
]

// MARK: - The hobbit

/// Where a hobbit's weapon hand is: just past the 2×2 fist at x 36…37, rows 36…37 (Clawd's is (41.5, 34.5)).
let hobbitHand = (x: 38.5, y: 36.5)

/// What tells one hobbit from another: the colours of the curls, waistcoat, shirt, breeches and cloak, and what each
/// carries about him (the Ring on its chain, a pack with the pan on it, or nothing at all).
struct HobbitKit {
    let curl: Px, curlLight: Px, curlDark: Px
    let waistcoat: Px, waistcoatDark: Px, shirt: Px, breeches: Px
    let cloak: Px, cloakEdge: Px
    let prop: HobbitProp
}

enum HobbitProp { case ring, pack, none }

private let brass = C(0xC8A04A), leaf = C(0x7FBF5A), silver = C(0xC8D0D8)
private let ringGold = C(0xE8B33A), ringChain = C(0x9AA0A8)

/// The hobbit every one of them is, at three quarters of Clawd's size: the cloak hanging down the back, breeches to the
/// shin and the bare feet (a pixel wider than a leg, Clawd orange with dark hair on top), a small blocky body (x 20…35,
/// rows 31…39) with ink eyes and arm nubs, the waistcoat open over the shirt with two brass buttons, the cloak's front
/// edges and the leaf brooch, the curls over the head top (row 27), and what the kit carries (the pack behind, or the
/// Ring on its chain at the chest). `armRight` raises the right hand; `wince` squeezes the eyes shut; a sword still in
/// its sheath (`sheath`) hangs at the hip. Sitting, it sits 2 px less low than a Clawd, so its feet still show. Shared
/// with the hobbits drawn in other files (Lotho), along with `HobbitKit` and `hobbitHand`.
func drawHobbit(_ c: PixelCanvas, _ p: Pose, _ k: HobbitKit, armRight: Int = 0, wince: Bool = false,
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
    // (…0.35); on the finger until he takes it off and tucks it back on its chain at his chest (0.9…1).
    let lift: Double = sig.map { smooth(min(1, $0 / 0.15)) } ?? 0
    let slip: Double = sig.map { smooth(min(1, max(0, ($0 - 0.15) / 0.2))) } ?? 0
    let back: Double = sig.map { smooth(max(0, ($0 - 0.9) / 0.1)) } ?? 0
    let raise = sig == nil ? 0 : Int(((4 * lift - 2 * slip) * (1 - back)).rounded())
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
    if back > 0 {
        // Off the finger and down on its chain to his chest again.
        let x = Int((hand.x + (28 - hand.x) * back).rounded()), y = Int((hand.y - 1 + (38 - (hand.y - 1)) * back).rounded())
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
        drawBucket(c, x: 45 + 5 * smooth(u), y: 40, angle: u > 0.75 ? 70 * (u - 0.75) / 0.25 : 0,
                   alpha: min(1, s / 0.05))                                // fading in with the well
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
/// tipped `angle` degrees, faded to `alpha`.
private func drawBucket(_ c: PixelCanvas, x: Double, y: Double, angle: Double, alpha: Double = 1) {
    prop(c, at: (x, y - 1), angle: angle, alpha: alpha) { s in
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

// MARK: - Merge-y

private let merryKit = HobbitKit(curl: C(0xA8782E), curlLight: C(0xD4A456), curlDark: C(0x74501C),
                                 waistcoat: C(0x8E4A26), waistcoatDark: C(0x683418),
                                 shirt: C(0xE8E0C8), breeches: C(0x5A4A32), cloak: C(0x2E6A3A), cloakEdge: C(0xD4AE4A),
                                 prop: .none)

/// Merge-y, hobbit-sized: Clawd under golden-brown curls, a russet waistcoat, the deep green cloak of the Mark with
/// its gold edge, bare hairy feet, and a little horn of the Mark, ivory banded with gold, slung at his hip. Like Pippin
/// he has a short sword at his side that he fights with. Signature: the horn-call that roused the Shire: he lifts the
/// horn from his hip to his lips and blows it, eyes squeezed shut and cheeks flushed, the call ringing out of its bell
/// and a stream of gold notes rising up and away, then hangs it back at his hip.
private func drawMerry(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.06 && $0 < 0.94 ? $0 : nil }
    // 0.06…0.13 and 0.86…0.94 on the way up and back down; at his lips in between, blowing 0.18…0.8.
    let atLips = sig.map { $0 > 0.13 && $0 < 0.86 } ?? false
    let blowing = sig.map { $0 > 0.18 && $0 < 0.8 } ?? false
    drawHobbit(c, p, merryKit, armRight: sig == nil ? 0 : atLips ? 1 : 0, wince: blowing, sheath: p.melee == nil)
    guard let s = sig else {
        drawHornOfTheMark(c)
        if let a = p.melee {
            for (i, ta) in p.trail.enumerated() { drawShortSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
            drawShortSword(c, angle: a)
            c.rect(36, 36, 2, 2, clawdOrange)
        }
        return
    }
    guard atLips else {
        drawHornOfTheMark(c, dx: 5, dy: -3)                                   // half way, in his hand
        c.rect(36, 36, 2, 2, clawdOrange)
        return
    }
    drawRaisedHorn(c)
    c.rect(36, 35, 2, 2, clawdOrange)
    guard blowing else { return }
    c.rect(33, 35, 2, 1, C(0xF08A78))                                         // cheeks puffed and flushed
    // The call ringing out of the bell.
    let ring = C(0xFFF4C8)
    for (i, (dx, dy)) in [(1, -2), (2, 0), (1, 2)].enumerated() where Int(p.t * 9 + Double(i)) % 3 != 0 {
        c.px(45 + dx, 31 + dy, ring.alpha(0.75)); c.px(46 + dx, 31 + dy + (dy > 0 ? 1 : dy < 0 ? -1 : 0), ring.alpha(0.45))
    }
    // The notes, one after another, rising out of the bell and drifting off.
    let note = C(0xF8DC6A)
    for (i, start) in [0.2, 0.31, 0.42, 0.53, 0.64].enumerated() {
        let u = (s - start) / 0.3
        guard u > 0, u < 1 else { continue }
        let a: Double = min(1, u * 6) * (1 - pow(u, 3))
        let x = 43 + Int((u * 9 + sin(u * 7 + Double(i)) * 1.5).rounded()), y = 27 - Int((u * 16).rounded())
        let shape = i % 2 == 0 ? [".NN", ".N.", ".N.", "NN.", "NN."] : [".NNNN", ".N..N", ".N..N", "NN.NN", "NN.NN"]
        c.pattern(x, y, shape, ["N": note.alpha(a)])
    }
}

/// The horn of the Mark at his hip on a leather strap: a small curved ivory horn, its bell forward, two gold bands.
/// `dx`, `dy` move the horn (not the strap) off his hip, on its way up to his lips.
private func drawHornOfTheMark(_ c: PixelCanvas, dx: Int = 0, dy: Int = 0) {
    let ivory = C(0xEDE4C8), ivoryDark = C(0xB8AA88), gold = C(0xE0B840), strap = C(0x5A3A22)
    c.px(27, 38, strap); c.px(28, 39, strap)
    c.pattern(26 + dx, 39 + dy, [
        "i.....",
        "IIGIIG",
        ".IIIGI",
    ], ["I": ivory, "i": ivoryDark, "G": gold])
    c.px(31 + dx, 41 + dy, ivoryDark)
}

/// The horn of the Mark at his lips, blown: the mouthpiece at his face, curving out and up to the bell.
private func drawRaisedHorn(_ c: PixelCanvas) {
    let ivory = C(0xEDE4C8), ivoryDark = C(0xB8AA88), gold = C(0xE0B840)
    c.pattern(35, 30, [
        ".......iI",
        "......IIIi",
        ".....GIIIi",
        "...IIGIIi.",
        "iIIIIIi...",
        ".ii.......",
    ], ["I": ivory, "i": ivoryDark, "G": gold])
}

// MARK: - Bilbyte

private let bilboKit = HobbitKit(curl: C(0xC8C8C2), curlLight: C(0xEDEDE8), curlDark: C(0x96968E),
                                 waistcoat: C(0x8A2232), waistcoatDark: C(0x621624),
                                 shirt: C(0xEEE6D0), breeches: C(0x6A5A40), cloak: C(0x6E4E30), cloakEdge: C(0x4E3620),
                                 prop: .none)

/// Bilbyte, an old hobbit, hobbit-sized: Clawd under grey-white curls, a burgundy waistcoat over a cream shirt, a
/// brown travelling cloak and bare hairy feet, with his little red book (the one he's writing, a gold mark on the
/// cover) tucked under his arm. He fights with a small blade, a letter-opener of a sword, kept at his hip. Signature:
/// "I'm going on an adventure!": he holds up the Dwarves' contract and lets it drop; it unrolls down to the floor and
/// keeps on going, spilling across the floor to a red seal at the very end, and then rolls itself back up into his hand.
private func drawBilbo(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    // The hand up by 0.1 and down again from 0.88; unrolled 0.12…0.42, held, rolled back up 0.6…0.86.
    let raise = sig.map { smooth(($0 - 0.03) / 0.07) * (1 - smooth(($0 - 0.88) / 0.08)) } ?? 0
    let up = Int((5 * raise).rounded())
    drawHobbit(c, p, bilboKit, armRight: up, sheath: p.melee == nil)
    // The book, under the back arm.
    let red = C(0xA82A2A), redDark = C(0x6E1A1A), pages = C(0xF0E8D0)
    c.rect(14, 34, 5, 5, red)
    c.rect(14, 34, 5, 1, pages); c.rect(14, 38, 5, 1, redDark); c.rect(14, 34, 1, 5, redDark)
    c.px(16, 36, C(0xE0B840))
    c.rect(18, 36, 2, 2, clawdOrange)                                       // his arm over it
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawSmallBlade(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawSmallBlade(c, angle: a)
        c.rect(36, 36, 2, 2, clawdOrange)
    }
    guard let s = sig else { return }
    let unrolled: Double = s < 0.42 ? pow(min(1, max(0, (s - 0.12) / 0.3)), 1.4)
        : s < 0.6 ? 1 : 1 - smooth((s - 0.6) / 0.26)
    let fade = min(1, (s - 0.03) / 0.05, (0.97 - s) / 0.05)
    drawContract(c, top: 36 - up, floor: 43 - c.oy, unrolled: unrolled, alpha: fade)
    c.rect(36, 36 - up, 2, 2, clawdOrange)                                  // his fist round the top
}

/// The contract, its top rolled round a rod in his hand at row `top`: as it `unrolled` (0…1) the paper drops down to
/// the `floor` row, the roll at its foot, and runs on along the floor to the right, two dozen pixels more, with the red
/// seal at the very end. Lines of small print run all the way down it.
private func drawContract(_ c: PixelCanvas, top: Int, floor: Int, unrolled: Double, alpha: Double) {
    let paper = C(0xF2E8CC, alpha), paperDark = C(0xC8B48A, alpha), writing = C(0x7A6A52, alpha)
    let hang = top + 2, drop = floor - hang + 1, run = 24
    let length = Int((Double(drop + run) * unrolled).rounded())
    c.rect(36, top, 7, 2, paper); c.rect(36, top + 1, 7, 1, paperDark); c.px(43, top, paperDark)    // the rod
    // Hanging down in front of him, small print on every other row.
    let down = min(length, drop)
    for y in hang..<(hang + down) {
        c.rect(38, y, 5, 1, paper); c.px(42, y, paperDark)
        if (y - hang) % 2 == 1 { for x in 38...41 where noise(y * 5 + x) > 0.3 { c.px(x, y, writing) } }
    }
    guard length > drop else {
        let y = hang + down                                                 // the roll at its foot, dropping
        c.rect(37, y, 7, 2, paper); c.rect(37, y + 1, 7, 1, paperDark)
        return
    }
    // Along the floor, then the seal and the roll at the far end.
    let end = 43 + length - drop
    c.rect(38, floor - 1, end - 38, 2, paper); c.rect(38, floor, end - 38, 1, paperDark)
    for x in 44..<end where x % 3 != 0 { c.px(x, floor - 1, writing) }
    if length - drop > run - 2 { c.rect(end - 3, floor - 1, 2, 2, C(0xB0262A, alpha)) }
    c.pattern(end - 1, floor - 3, [".PP.", "PPdP", "PdPP", ".PP."], ["P": paper, "d": paperDark])
}

/// Bilbyte's small blade, gripped at the hand: a wooden grip, a little brass guard and a short (5 px) bright blade.
private func drawSmallBlade(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    prop(c, at: hobbitHand, angle: angle, alpha: alpha) { s in
        let blade = C(0xD0D4DC), edge = C(0x8E94A0)
        s.rect(18, 20, 3, 1, C(0x6A4A2A))
        s.rect(21, 19, 1, 3, brass)
        s.rect(22, 20, 5, 1, blade)
        s.rect(22, 21, 4, 1, edge)
        s.px(23, 20, C(0xF2F6FA))
        s.px(27, 20, edge)
    }
}

// MARK: - Rosie

private let rosieKit = HobbitKit(curl: C(0x9A4626), curlLight: C(0xC8683A), curlDark: C(0x6A2C16),
                                 waistcoat: C(0xE8C04A), waistcoatDark: C(0xB8902A),
                                 shirt: C(0xF2EADA), breeches: C(0xE8C04A), cloak: C(0xC8607A), cloakEdge: C(0x9A4058),
                                 prop: .none)

/// Rosie, a hobbit lass, hobbit-sized: Clawd under auburn curls that tumble down past her shoulders, a pink flower
/// tucked in them, a bright yellow bodice and a short full skirt to the shin trimmed with lace, a rose shawl
/// round her shoulders and bare hairy feet. On her back arm a wicker basket of bread and flowers; she fights with a
/// rolling pin, swung like a club. Signature: she plucks the flower from her hair and tosses it high, watching it
/// spin up and tumble back down; she catches it, holds it to her face with her eyes shut happily while a little heart
/// floats up, and tucks it back in her curls.
private func drawRosie(_ c: PixelCanvas, _ p: Pose) {
    let k = rosieKit, white = C(0xF4F0E6)
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let up = sig.map { rosieReach($0) } ?? 0
    let flower = sig.map { rosieFlower($0, up: up) }
    drawHobbit(c, p, k, armRight: up)
    // The skirt, flaring a little to the shin, a lace trim at its hem.
    c.rect(20, 38, 16, 1, k.waistcoat)
    c.rect(19, 39, 18, 1, k.waistcoat)
    c.rect(18, 40, 20, 1, k.waistcoatDark)
    c.px(36, 39, k.waistcoatDark); c.px(25, 39, k.waistcoatDark); c.px(30, 39, k.waistcoatDark)
    for x in stride(from: 19, through: 37, by: 2) { c.px(x, 40, white) }
    // The curls tumbling down behind the shoulders and over the shawl.
    c.pattern(17, 31, ["CCl", "CdC", "lCC", "CCd", ".Cl", ".d."], ["C": k.curl, "l": k.curlLight, "d": k.curlDark])
    c.px(36, 33, k.curl); c.px(36, 34, k.curlDark)
    // The flower in her hair.
    let petal = C(0xF4A0C0), middle = C(0xF8D84A), stem = C(0x5A9A3A)
    if flower == nil {
        c.pattern(31, 26, [".P.", "PYP", ".P."], ["P": petal, "Y": middle])
        c.px(30, 28, stem)
    }
    // The basket on her back arm, the bread and a flower peeping out.
    let wicker = C(0xB88A4A), wickerDark = C(0x8A6230)
    c.pattern(12, 33, [
        "..wwww..",
        ".w....w.",
        "BBFpBBB.",
        "WWWWWWW.",
        "WdWdWdW.",
        "WWWWWWW.",
        ".WdWdW..",
    ], ["w": wickerDark, "W": wicker, "d": wickerDark, "B": C(0xD8A860), "F": C(0xF4A0C0), "p": C(0x5A9A3A)])
    c.rect(18, 36, 2, 2, clawdOrange)                                       // her arm through the handle
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawRollingPin(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawRollingPin(c, angle: a)
        c.rect(36, 36, 2, 2, clawdOrange)
    }
    guard let s = sig, let f = flower else { return }
    // Her eyes: up after the flower while it's in the air, shut happily while she smells it.
    if s > 0.27 && s < 0.6 {
        c.rect(23, 35, 2, 1, clawdOrange); c.rect(31, 35, 2, 1, clawdOrange)
        c.rect(23, 32, 2, 1, ink); c.rect(31, 32, 2, 1, ink)
    } else if s > 0.63 && s < 0.84 {
        c.rect(23, 33, 2, 3, clawdOrange); c.rect(31, 33, 2, 3, clawdOrange)
        for ex in [22, 30] { c.pattern(ex, 33, [".II.", "I..I"], ["I": ink]) }
    }
    c.rect(36, 36 - up, 2, 2, clawdOrange)                                  // her hand, over the curls
    if f.spin {
        c.pattern(f.x - 1, f.y - 1, ["P.P", ".Y.", "P.P"], ["P": petal, "Y": middle])
    } else {
        c.pattern(f.x - 1, f.y - 1, [".P.", "PYP", ".P."], ["P": petal, "Y": middle])
        c.px(f.x - 2, f.y + 1, stem)
    }
    // The little heart, floating up while she smells it.
    let u = (s - 0.64) / 0.26
    if u > 0, u < 1 {
        let a: Double = min(1, u * 5) * (1 - u * u)
        c.pattern(40 + Int((u * 3).rounded()), 27 - Int((u * 10).rounded()), [".H.H.", "HHHHH", ".HHH.", "..H.."],
                  ["H": C(0xF06A8A, a)])
    }
}

/// How far Rosie's front hand is raised at `s` through her signature: up to her hair to pluck the flower, down to toss
/// it, a little higher to catch it, down at her face to smell it, back up to her hair and down again.
private func rosieReach(_ s: Double) -> Int {
    let keys: [(s: Double, up: Double)] = [(0.03, 0), (0.12, 7), (0.2, 7), (0.26, 4), (0.27, 5), (0.32, 3), (0.58, 4),
                                           (0.62, 3), (0.8, 3), (0.86, 7), (0.9, 7), (0.97, 0)]
    for (a, b) in zip(keys, keys.dropFirst()) where s < b.s {
        return Int((a.up + (b.up - a.up) * smooth((s - a.s) / (b.s - a.s))).rounded())
    }
    return 0
}

/// Where Rosie's flower is at `s` through her signature, its hand raised `up`: in her hair, slid into her hand,
/// tossed up spinning (0.27…0.6) and caught again, then slid back into her hair at the end.
private func rosieFlower(_ s: Double, up: Int) -> (x: Int, y: Int, spin: Bool) {
    let hair = (x: 32.0, y: 27.0), hand = (x: 37.0, y: Double(34 - up))
    func slide(_ u: Double) -> (x: Int, y: Int, spin: Bool) {
        let v = smooth(u)
        return (Int((hair.x + (hand.x - hair.x) * v).rounded()), Int((hair.y + (hand.y - hair.y) * v).rounded()), false)
    }
    if s < 0.12 { return (Int(hair.x), Int(hair.y), false) }
    if s < 0.2 { return slide((s - 0.12) / 0.08) }
    if s > 0.86 { return slide(1 - (s - 0.86) / 0.04) }
    guard s > 0.27 && s < 0.6 else { return (Int(hand.x), Int(hand.y), false) }
    let u = (s - 0.27) / 0.33
    let y = 31 - 19 * 4 * u * (1 - u)
    return (37 + Int((sin(u * .pi) * 2).rounded()), Int(y.rounded()), Int(u * 9) % 2 == 0)
}

/// Rosie's rolling pin, gripped by one handle: a fat pale-wood roller between two turned handles.
private func drawRollingPin(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    prop(c, at: hobbitHand, angle: angle, alpha: alpha) { s in
        let wood = C(0xE0C090), woodDark = C(0xB0905A), handle = C(0xA87A44)
        s.rect(17, 20, 3, 1, handle)
        s.rect(20, 19, 9, 3, wood)
        s.rect(20, 21, 9, 1, woodDark); s.rect(21, 19, 6, 1, C(0xF0DAB0))
        s.rect(29, 20, 2, 1, handle)
    }
}

// MARK: - Farmer Mag-git

private let maggotKit = HobbitKit(curl: C(0x8A8274), curlLight: C(0xB0A898), curlDark: C(0x605A4E),
                                  waistcoat: C(0x5A6A3A), waistcoatDark: C(0x424E2A),
                                  shirt: C(0xDCD4BC), breeches: C(0x6A4A2A), cloak: C(0x6A5E4A), cloakEdge: C(0x4E4434),
                                  prop: .none)

/// Farmer Mag-git, an old hobbit farmer, hobbit-sized but stout: Clawd under grizzled grey curls and a wide, frayed
/// straw hat with a red band, a heavy leather apron bulging over his belly, a dull brown coat and bare hairy feet. A
/// brass dog whistle hangs on a cord at his chest (his dogs are never far off), and a basket of mushrooms rides on his
/// back arm. His pitchfork stands upright in his fist at rest; he fights with it, prongs first. Signature: trespassers!
/// Brows down, he shakes his pitchfork high over his head at them, and his dog Fang pops up out of the long grass in
/// front of him, barking his head off, then ducks back down again as the farmer lowers the fork.
private func drawMaggot(_ c: PixelCanvas, _ p: Pose) {
    let k = maggotKit, leather = C(0x7A5232), leatherDark = C(0x5A3A22), leatherLight = C(0x96683E)
    let sig = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? $0 : nil }
    // Raised by 0.12 and shaken, lowered 0.62…0.74.
    let shake: Double = sig.map { smooth(($0 - 0.02) / 0.1) * (1 - smooth(($0 - 0.62) / 0.12)) } ?? 0
    let lift = Int((3 * shake).rounded()) + (shake > 0.6 && Int(p.t * 14) % 2 == 0 ? 1 : 0)
    drawHobbit(c, p, k, armRight: lift)
    let floor = 43 - c.oy
    // The leather apron, bulging out over his belly, with a pocket.
    c.rect(22, 36, 14, 5, leather)
    c.rect(36, 37, 1, 3, leather); c.px(37, 38, leatherDark); c.px(36, 40, leatherDark)
    c.rect(22, 40, 15, 1, leatherDark); c.rect(22, 36, 14, 1, leatherLight)
    c.rect(27, 38, 4, 2, leatherDark); c.rect(27, 38, 4, 1, leatherLight)
    // The dog whistle on its cord.
    dots(c, 23, 35, 25, 37, C(0x3A2A1C)); c.rect(25, 37, 2, 1, brass); c.px(26, 38, C(0x8A6A2A))
    // The straw hat: a low crown with a red band, and a wide, frayed brim.
    let straw = C(0xE0C070), strawDark = C(0xB8984A), strawLight = C(0xF4DC98)
    c.pattern(15, 23, [
        ".......SSSSlSSSS.........",
        "......SSlSSSSSSdS........",
        "......RRRRRRRRRRR........",
        "...dSSSSSlSSSSSSSSSSd....",
        "SSlSSSSSSSSSSSdSSSSSlSSSS",
        ".d.S.dS.S..dS.S.d.S.dS.d.",
    ], ["S": straw, "d": strawDark, "l": strawLight, "R": C(0xA83A2A)])
    // The basket of mushrooms on his back arm.
    let wicker = C(0xA8804A), wickerDark = C(0x7A5A30), cap = C(0xE8DCC4), capDark = C(0xA88A6A), stalk = C(0xF4EEE0)
    c.pattern(12, 33, [
        ".cC..Cc.",
        "CCCsCCCC",
        "CsCkCCsC",
        "WWWWWWW.",
        "WdWdWdW.",
        "WWWWWWW.",
        ".WdWdW..",
    ], ["C": cap, "c": capDark, "s": stalk, "k": capDark, "W": wicker, "d": wickerDark])
    c.rect(18, 36, 2, 2, clawdOrange)
    if let s = sig {
        if s > 0.06 && s < 0.8 {                                              // brows down, glaring
            c.pattern(22, 31, ["II...", "..I.."], ["I": ink]); c.pattern(30, 31, ["..II", ".I.."], ["I": ink])
        }
        drawFang(c, s: s, t: p.t, floor: floor)
    }
    // The pitchfork: upright at rest (shaken over his head in the signature), swung prongs first in a fight.
    let a = p.melee ?? -90 + 12 * shake * sin(p.t * 19)
    for (i, ta) in (p.melee == nil ? [] : p.trail).enumerated() { drawPitchfork(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
    drawPitchfork(c, angle: a, lift: lift)
    c.rect(36, 36 - lift, 2, 2, clawdOrange)
}

/// Mag-git's pitchfork, gripped two thirds down its long ash shaft (the butt sticks out behind the hand): an iron
/// crossbar and three long prongs. `lift` raises the hand holding it.
private func drawPitchfork(_ c: PixelCanvas, angle: Double, alpha: Double = 1, lift: Int = 0) {
    prop(c, at: (hobbitHand.x, hobbitHand.y - Double(lift)), angle: angle, alpha: alpha) { s in
        let ash = C(0xA8865A), ashDark = C(0x7A5E3A), iron = C(0x8A8E94), ironLight = C(0xB8BCC4)
        s.rect(14, 20, 18, 1, ash); s.rect(14, 21, 18, 1, ashDark)
        s.rect(32, 18, 1, 5, iron)
        for y in [18, 20, 22] { s.rect(33, y, 5, 1, iron); s.px(38, y, ironLight) }
    }
}

/// Fang, Mag-git's dog, in Mag-git's signature at `s`: a clump of long grass in front of the farmer, the dog's head
/// popping up out of it (0.2…0.28), barking at the trespassers (the jaw snapping open and shut on `t`, the barks
/// flying off its nose), and ducking back down (0.76…0.84). Nothing of him shows below the grass, or the `floor` row.
private func drawFang(_ c: PixelCanvas, s: Double, t: Double, floor: Int) {
    let grass: Double = smooth((s - 0.12) / 0.07) * (1 - smooth((s - 0.86) / 0.07))
    let rise: Double = smooth((s - 0.2) / 0.08) * (1 - smooth((s - 0.76) / 0.08))
    let barking = rise > 0.95 && Int(t * 8) % 2 == 0
    if rise > 0 {
        let x0 = 44, y0 = floor - 2 - Int((13 * rise).rounded())
        let face = barking ? [".BBBBBBoooo", ".BBBBBotto.", ".BBBBBmmm..", ".BBBB......"]
                           : [".BBBBBMMMM.", ".BBBBBmmm..", ".BBBBB.....", ".BBBB......"]
        let rows = [".E.........", "EEE........", "EBBBB......", "BBBBBBB....", "BBBkBBBMM..", "BBBBBBMMMMn"] + face
        let pal: [Character: Px] = ["B": C(0x8A5A30), "E": C(0x4A2E18), "M": C(0xD8B07A), "m": C(0xA8804A), "n": ink,
                                    "k": ink, "o": C(0x3A1A14), "t": C(0xE0607A)]
        for (r, row) in rows.enumerated() where y0 + r <= floor {
            for (i, ch) in row.enumerated() { if let col = pal[ch] { c.px(x0 + i, y0 + r, col) } }
        }
        if y0 + 10 <= floor { c.rect(x0 + 1, y0 + 10, 4, floor - y0 - 9, pal["B"]!) }       // his neck
        if barking {                                                          // the barks, flying off his nose
            let bark = C(0xFFF4D8, 0.85)
            c.px(x0 + 12, y0 + 3, bark); c.px(x0 + 13, y0 + 2, bark)
            c.px(x0 + 13, y0 + 5, bark); c.px(x0 + 14, y0 + 5, bark)
            c.px(x0 + 12, y0 + 7, bark); c.px(x0 + 13, y0 + 8, bark)
        }
    }
    // The long grass in front of him.
    guard grass > 0 else { return }
    let blade = C(0x6A9A3A, grass), bladeDark = C(0x4A7A2A, grass), seed = C(0xD8C070, grass)
    for (i, x) in [41, 42, 44, 45, 47, 48, 49, 51, 52, 54, 55, 57].enumerated() {
        let h = 4 + Int(noise(i * 7 + 3) * 4), lean = i % 3 == 0 ? 1 : 0
        for k in 0..<h { c.px(x + (k > h / 2 ? lean : 0), floor - k, k % 2 == 0 ? blade : bladeDark) }
        if i % 2 == 0 { c.px(x + lean, floor - h, seed) }
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
