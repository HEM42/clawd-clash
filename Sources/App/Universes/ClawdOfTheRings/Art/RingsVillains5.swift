import Foundation

// Villains: the small ones close to home, and the oldest thing in the Old Forest. Lotho is a hobbit, drawn with the
// hobbits' own `drawHobbit` (RingsHeroes1.swift) in his own kit; Bill Firmware is Clawd in costume at a Man's height.
// Old Man Pillow isn't Clawd at all: an old willow half again a Man's height (the size is drawn on the canvas, so his
// `headTop`, the root he grabs with and his `bulk` say so), drooping, grey-green and very, very sleepy.

let ringsVillains5: [RingsVillain: Persona] = [
    .lotho: Persona(name: "Lotho Sackville-Bagclawds", weapon: .saber, pivot: hobbitHand, headTop: 27, signature: 3.0,
                    callout: "I'm the Chief now. Every commit in the Shire needs my sign-off.", draw: drawLotho),
    .billFerny: Persona(name: "Bill Firmware", weapon: .saber, headTop: 21, signature: 2.6,
                        callout: "Want your pony back? That's a paid firmware upgrade.", draw: drawBillFerny),
    .oldManWillow: Persona(name: "Old Man Pillow", weapon: .saber, canSit: false, pivot: willowRoot, bulk: 14, headTop: 7,
                           signature: 3.6,
                           callout: "Rest your head on me… this Pillow never wakes a sleeping thread.", draw: drawWillow),
]

// MARK: - Lotho

private let lothoKit = HobbitKit(curl: C(0x241C1A), curlLight: C(0x4A3C36), curlDark: C(0x120E0C),
                                 waistcoat: C(0x2A2232), waistcoatDark: C(0x18121E),
                                 shirt: C(0xF4F0E4), breeches: C(0x3A3040), cloak: C(0x5A2A4A), cloakEdge: C(0xC8A040),
                                 prop: .none)

/// Lotho, the upstart "Chief", hobbit-sized: Clawd under slick, oiled black curls, with a smug face (heavy-lidded eyes,
/// one brow cocked, a smirk) and a few angry red pimples; a too-fine near-black waistcoat with gold buttons and a brass
/// watch chain looped across it, a frilled white shirt, a mulberry cloak edged in gold, bare hairy feet. He carries a
/// black cane with a gold knob, planted at his side at rest and swung like a stick to fight. Signature: counting his
/// takings: the cane leant against him, he holds out his palm and gold coins hop up out of his waistcoat pocket one by
/// one, each landing with a glint on a growing stack, his smirk widening and a greedy gleam in his eyes, until he
/// closes his hand on them and takes up the cane again.
private func drawLotho(_ c: PixelCanvas, _ p: Pose) {
    let k = lothoKit, gold = C(0xE0B840), pimple = C(0xB82A22), pimpleTip = C(0xF4C0A8)
    let sig = p.signature.flatMap { $0 > 0.06 && $0 < 0.94 ? $0 : nil }
    drawHobbit(c, p, k, armRight: sig == nil ? 0 : 2)
    // The smug face: heavy lids over the eyes, one brow cocked, a smirk; and the pimples.
    c.rect(23, 33, 2, 1, clawdShade); c.rect(31, 33, 2, 1, clawdShade)
    c.rect(22, 32, 3, 1, ink); c.px(31, 31, ink); c.px(32, 31, ink); c.px(33, 32, ink)
    c.rect(27, 35, 3, 1, C(0x7A3420)); c.px(30, 34, C(0x7A3420))
    for (x, y) in [(21, 34), (29, 32), (34, 35)] { c.px(x, y, pimple) }
    c.px(29, 31, pimpleTip)
    // The frilled shirt front, the gold buttons and the watch chain looped across the waistcoat.
    c.px(27, 36, C(0xD8D0C0)); c.px(28, 37, C(0xD8D0C0))
    c.px(29, 38, gold); c.px(29, 36, gold)
    for (x, y) in [(23, 37), (24, 38), (25, 38), (26, 39), (27, 39), (28, 38)] { c.px(x, y, gold) }
    c.px(22, 37, C(0xF4E08A))
    if let s = sig {
        drawTakings(c, s: s, t: p.t)
        return
    }
    // The cane: planted at his side at rest, swung like a stick to fight.
    let a = p.melee ?? 90
    for (i, ta) in (p.melee == nil ? [] : p.trail).enumerated() { drawCane(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
    drawCane(c, angle: a)
    c.rect(36, 36, 2, 2, clawdOrange)
}

/// Lotho's cane, gripped below its gold knob: a slim black stick with a gold ferrule at the tip. `at`: where it's held
/// (or leant).
private func drawCane(_ c: PixelCanvas, angle: Double, alpha: Double = 1, at: (x: Double, y: Double) = hobbitHand) {
    prop(c, at: at, angle: angle, alpha: alpha) { s in
        let gold = C(0xE0B840)
        s.rect(18, 19, 2, 3, gold); s.px(18, 19, C(0xF8E08A))
        s.rect(20, 20, 7, 1, C(0x1A1A20)); s.rect(21, 20, 4, 1, C(0x2E2E38))
        s.px(27, 20, gold)
    }
}

/// Lotho's signature at `s` (0.06…0.94): the cane leant against him, his palm held out (the hand already raised),
/// five coins hopping up one after another out of his waistcoat pocket and onto the stack in it (0.12…0.72), a glint
/// as each lands; a widening smirk and gold in his eyes; then the hand closing over them (0.8…).
private func drawTakings(_ c: PixelCanvas, s: Double, t: Double) {
    let gold = C(0xF0C440), goldLight = C(0xFFE88A), goldDark = C(0x9A6E18), glint = C(0xFFFFFF)
    drawCane(c, angle: 97, at: (15.5, 36.5))                                    // leant against his back, out of the way
    let greedy = s > 0.2 && s < 0.88
    if greedy {
        c.rect(26, 35, 5, 1, C(0x7A3420)); c.px(31, 34, C(0x7A3420)); c.px(28, 35, C(0xF4F0E4))   // the grin
        if Int(t * 4) % 3 != 0 { c.px(24, 34, gold); c.px(32, 34, gold) }                        // the gleam
    }
    // His palm held out in front of him, clear of the head and the cane: the forearm reaching out to it.
    let palm = (x: 40, y: 33)                                                   // the middle of the bottom coin
    c.rect(36, 34, 4, 2, clawdOrange); c.rect(37, 35, 3, 1, clawdShade)
    let closing = s > 0.8
    var stack = 0
    for i in 0..<5 {
        let start = 0.12 + Double(i) * 0.12, u = (s - start) / 0.1
        guard u > 0 else { continue }
        if u >= 1 { stack += 1; continue }
        // In the air: up out of the pocket in an arc and down onto the stack, flipping over as it goes.
        let from = (x: 32.0, y: 38.0), to = (x: Double(palm.x) + 0.5, y: Double(palm.y - 2 * stack))
        let x = from.x + (to.x - from.x) * u, y = from.y + (to.y - from.y) * u - 9 * 4 * u * (1 - u)
        let ix = Int(x.rounded()), iy = Int(y.rounded())
        if Int(u * 6) % 2 == 0 { c.rect(ix - 2, iy, 5, 2, gold); c.rect(ix - 1, iy, 3, 1, goldLight); c.px(ix + 2, iy + 1, goldDark) }
        else { c.rect(ix, iy - 1, 2, 3, goldDark); c.px(ix, iy - 1, goldLight) }
    }
    if !closing {
        // The stack on his palm: fat coins, a bright rim on each and a dark edge under it.
        for j in 0..<stack {
            let y = palm.y - 2 * j - 1
            c.rect(palm.x - 2, y, 5, 2, gold); c.rect(palm.x - 1, y, 3, 1, goldLight)
            c.rect(palm.x - 2, y + 1, 5, 1, j % 2 == 0 ? goldDark : C(0xB88A28)); c.px(palm.x - 2, y, gold)
        }
        // A sparkle on the coin that's just landed, and a twinkle now and then on the top one.
        for i in 0..<5 {
            let u = (s - 0.22 - Double(i) * 0.12) / 0.08
            guard u > 0, u < 1 else { continue }
            let gx = palm.x + 1, gy = palm.y - 2 * i - 1, a: Double = sin(u * .pi)
            c.px(gx, gy, glint.alpha(a)); c.px(gx, gy - 1, glint.alpha(a)); c.px(gx, gy - 2, glint.alpha(a * 0.6))
            c.px(gx - 1, gy - 1, glint.alpha(a * 0.7)); c.px(gx + 1, gy - 1, glint.alpha(a * 0.7))
            c.px(gx - 2, gy - 1, glint.alpha(a * 0.35)); c.px(gx + 2, gy - 1, glint.alpha(a * 0.35))
        }
        if stack > 0 && Int(t * 5) % 4 == 0 { c.px(palm.x - 1, palm.y - 2 * stack, glint) }
    }
    c.rect(palm.x - 2, palm.y + 1, 4, 2, clawdOrange); c.px(palm.x + 1, palm.y + 2, clawdShade)   // the palm under them
    if closing {                                                                // closed round the coins
        c.rect(palm.x - 2, palm.y - 1, 4, 2, clawdOrange); c.rect(palm.x - 2, palm.y, 4, 1, clawdShade)
        c.px(palm.x + 2, palm.y, gold)
    }
}

// MARK: - Bill Firmware

/// Bill Firmware, the Bree ruffian: a grubby, stained yellow-green coat to the thigh with a patch on it, tied with a
/// rope belt, over dark trousers and muddy boots; a mean squint under low, scowling brows, dark stubble along the jaw,
/// greasy black hair hanging lank from under a battered, drooping brown hat. He fights with a knotted cudgel, held low
/// at his side at rest and swung with a smear behind a fast stroke. Signature: the apple: he tosses one idly up and
/// down in his back hand, winds up and hurls it, hard, off to the right and out of sight, and sneers after it.
private func drawBillFerny(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x5A6430), coatShade = C(0x404A22), coatLight = C(0x707A3E), grime = C(0x4A4426)
    let hat = C(0x5A4430), hatDark = C(0x3E2E1E), hatLight = C(0x74583C)
    let hair = C(0x1E1A18), hairLight = C(0x38302A), stubble = C(0x9A4E34)
    let pitch = p.signature.flatMap { $0 > 0.04 && $0 < 0.88 ? billThrow($0) : nil }
    drawLegs(c, Look(leg: C(0x3A3228)), step: p.step)
    drawBoots(c, p.step, C(0x3A2C1C), rows: 3)
    c.oy += p.breathe
    if let th = pitch, !th.front { drawThrowingArm(c, th.hand, apple: th.apple, coat: coat) }
    drawBody(c, Look(arm: coat, eye: nil))
    // The squint, the scowl and the stubble.
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    c.px(22, 29, clawdShade); c.px(33, 29, clawdShade)                      // the lids, slanting in
    c.pattern(20, 26, ["BB...........BB", "..BBB.....BBB.."], ["B": C(0x2A1E18)])
    for (x, y) in [(20, 32), (22, 32), (24, 32), (27, 32), (29, 32), (31, 32), (34, 32), (21, 31), (33, 31), (36, 32)] {
        c.px(x, y, stubble)
    }
    // The coat: shoulders to mid-thigh, stained, patched, a rope round the waist.
    c.rect(18, 33, 20, 5, coat)
    c.rect(37, 33, 1, 5, coatShade)
    c.rect(18, 33, 20, 1, coatLight)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, coat); c.px(26, y, coatShade); c.px(37, y, coatShade) }
    for (x, y) in [(21, 34), (22, 35), (33, 38), (34, 37), (29, 34)] { c.px(x, y, grime) }
    c.rect(30, 37, 3, 2, C(0x8A7448)); c.px(30, 37, C(0x5A4A2A)); c.px(32, 38, C(0x5A4A2A))   // the patch
    c.rect(18, 36, 20, 1, C(0xA8946A)); c.px(25, 37, C(0xA8946A)); c.px(25, 38, C(0x8A7652))   // the rope belt
    c.rect(15, 33, 3, 3, coat)
    // The lank hair, hanging from under the hat.
    c.pattern(16, 25, ["HH....................HH", "Hl....................lH", "HH....................H.",
                       "H.....................H.", "l.......................", "H......................."],
              ["H": hair, "l": hairLight])
    // The battered hat: a dented crown and a wide brim drooping at the front.
    c.pattern(15, 19, [
        "........hHHHHHh.........",
        "......HHHdHHHHHHH.......",
        ".....HHHHHHHHdHHHH......",
        ".....dddddddddddddd.....",
        "..HHHHHHHHHHHHHHHHHHHL..",
        "HHHHlHHHHHHHHHlHHHHHHHHH",
        "d.......................",
    ], ["H": hat, "d": hatDark, "l": hatLight, "h": hatLight, "L": hatLight])
    c.px(39, 25, hat); c.px(40, 26, hatDark)
    // The cudgel: low at his side at rest, swung in a fight.
    let angle = p.melee ?? (seatedPose ? 10 : 55)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 12, Sprite.hand.y + u.y * 12,
                   core: C(0xC8B89A), glow: C(0x8A7A5A), coreR: 0.8, glowR: 1.9, strength: 0.32 / Double(i + 1))
    }
    drawCudgel(c, angle: angle)
    c.rect(38, 33, 3, 3, coat); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
    guard let th = pitch, let s = p.signature else { return }
    if th.front { drawThrowingArm(c, th.hand, apple: th.apple, coat: coat) }
    if s > 0.62 { c.pattern(26, 31, ["....I", "IIII."], ["I": ink]) }          // the sneer after it
    // Thrown: away to the right, fast, a streak behind it.
    let u = (s - 0.57) / 0.13
    guard u > 0, u < 1 else { return }
    let ax = 44 + 42 * u, ay = 29 - 4 * u
    for k in 1...4 { c.px(Int(ax) - 2 - k * 2, Int(ay.rounded()), C(0xF4E8D8, 0.5 - Double(k) * 0.1)) }
    drawApple(c, x: Int(ax), y: Int(ay.rounded()))
}

/// Where Bill's back hand is at `s` through his signature, whether it's in front of him (the throw) or behind, and the
/// apple in it until he lets go (0.57): up beside his head and tossing it twice, winding back, hurled forward across
/// him, followed through, and back down behind him.
private func billThrow(_ s: Double) -> (hand: (x: Double, y: Double), front: Bool, apple: (x: Double, y: Double)?) {
    func lerp(_ a: (x: Double, y: Double), _ b: (x: Double, y: Double), _ u: Double) -> (x: Double, y: Double) {
        let v = smooth(u)
        return (a.x + (b.x - a.x) * v, a.y + (b.y - a.y) * v)
    }
    let rest = (x: 16.0, y: 34.0), toss = (x: 12.0, y: 31.0), back = (x: 8.0, y: 28.0), out = (x: 44.0, y: 30.0)
    if s < 0.12 { let h = lerp(rest, toss, (s - 0.04) / 0.08); return (h, false, (h.x, h.y - 1)) }
    if s < 0.42 {
        let u = frac((s - 0.12) / 0.15), dip = u < 0.15 ? sin(u / 0.15 * .pi) : 0
        return ((toss.x, toss.y + dip), false, (toss.x, toss.y - 1 - 8 * 4 * u * (1 - u)))
    }
    if s < 0.52 { let h = lerp(toss, back, (s - 0.42) / 0.1); return (h, false, (h.x, h.y - 1)) }
    if s < 0.57 { let h = lerp(back, out, (s - 0.52) / 0.05); return (h, true, (h.x, h.y - 1)) }
    if s < 0.72 { return (lerp(out, (42, 33), (s - 0.57) / 0.15), true, nil) }
    return (lerp((42, 33), rest, (s - 0.72) / 0.14), false, nil)
}

/// Bill's back arm, from the shoulder to `hand` in his coat sleeve, his fist, and the apple held in it.
private func drawThrowingArm(_ c: PixelCanvas, _ hand: (x: Double, y: Double), apple: (x: Double, y: Double)?, coat: Px) {
    line(c, 16.5, 34, hand.x, hand.y, coat, 1.1)
    c.rect(Int(hand.x.rounded()) - 1, Int(hand.y.rounded()), 2, 2, clawdOrange)
    if let a = apple { drawApple(c, x: Int(a.x.rounded()), y: Int(a.y.rounded())) }
}

/// A red apple, its bottom middle on (`x`, `y`): a shine on it, a stalk and a leaf.
private func drawApple(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x - 1, y - 3, [".sl", "RLR", "RRr", ".r."],
              ["R": C(0xC8302A), "r": C(0x8A1E1A), "L": C(0xF07A6A), "s": C(0x5A3A1E), "l": C(0x5A9A3A)])
}

/// Bill's cudgel, gripped at the hand: a short handle swelling into a thick, knotted club head.
private func drawCudgel(_ c: PixelCanvas, angle: Double) {
    prop(c, at: Sprite.hand, angle: angle) { s in
        let wood = C(0x6A4A2A), dark = C(0x4A321C), light = C(0x8A6A44)
        s.rect(17, 20, 6, 1, wood); s.rect(17, 21, 6, 1, dark)
        s.rect(23, 19, 4, 3, wood); s.rect(27, 18, 5, 5, wood)
        s.rect(23, 21, 9, 1, dark); s.rect(27, 22, 5, 1, dark)
        s.rect(24, 19, 7, 1, light)
        s.px(25, 18, dark); s.px(29, 17, dark); s.px(32, 20, dark); s.px(30, 23, dark)   // the knots
    }
}

// MARK: - Old Man Pillow

/// Where Old Man Pillow's grabbing root reaches out from: low at the front of his trunk, just above the ground.
private let willowRoot: (x: Double, y: Double) = (40.5, 40.5)

/// The tip of his front branch, drooping out in front of him.
private let willowTip: (x: Double, y: Double) = (49.5, 29.5)

/// Old Man Pillow, the ancient willow of the Old Forest, half again a Man's height: a gnarled, leaning grey trunk split
/// by a great dark hollow, on a tangle of roots that shuffle along for feet; a crown of grey-green leaves weeping down
/// in long fronds on every side, swaying; and a face in the bark, sleepy and sly, one eye closed, the other a pale-green
/// slit, a crooked smile. His front branch droops out in front of him, fronds trailing. He fights with a gnarled root
/// (not his grey bark: near-black earthy brown, mossy along its length, paling to a raw fresh tip and rootlet fingers)
/// that lies coiled at his base at rest and, swung, snakes forward along the floor and up, its tip curling like a
/// grasping hand and lagging behind the swing, with a smear behind a fast grab. When he's idle a little "z" drifts up
/// from him now and then. Signature: a huge, slow yawn: he stretches up tall, branch raised, eyes screwed shut, and the
/// great crack in his trunk gapes wider and wider into a yawning maw that swallows his smile; then it SNAPS shut to a
/// thin black crack (as it did on Merry and Pippin), his eye flies open, and a burst of "z"s puffs up out of his crown
/// before the hollow eases open again and he nods back off.
private func drawWillow(_ c: PixelCanvas, _ p: Pose) {
    let bark = C(0x7A7C68), barkDark = C(0x56584A), barkLight = C(0x9A9C86), furrow = C(0x3A3C30), hollow = C(0x1A1C16)
    let frond = C(0x8A9A6A), frondDark = C(0x66764E), frondLight = C(0xB0C08C)
    let sway: Double = sin(p.lt * 1.1)
    let yawn = p.signature.map { willowYawn($0) }
    let stretch = Int(((yawn?.stretch ?? 0) * 2).rounded())
    // The fronds hanging behind the trunk (the back of the crown).
    drawFronds(c, p, xs: [12, 14, 16, 18, 20, 23], top: 14, length: 22, col: frondDark, light: frond, phase: 0.5)
    // The roots: a tangle spreading over the ground, its tips shuffling as he moves.
    for (i, lx) in [14, 20, 27, 33, 39].enumerated() {
        let up = p.step >= 0 && i % 2 == p.step ? 1 : 0
        let col = i % 2 == 0 ? barkDark : bark
        line(c, Double(lx + 6 - i), 37, Double(lx), Double(43 - up), col, 1)
        line(c, Double(lx), Double(43 - up), Double(lx - 2), Double(43 - up), col, 0.5)
        c.px(lx + 1, 41 - up, furrow)
    }
    c.oy += p.breathe - stretch
    // The trunk: wide at the root, leaning a little forward as it rises, the bark grain running up it.
    for y in 13...(39 + stretch) {
        let k = Double(39 - y) / 26
        let l = Int((17 + k * 6 + 1.2 * sin(Double(y) * 0.45)).rounded())
        let r = Int((38 + k * 3 - 1.0 * sin(Double(y) * 0.3)).rounded())
        c.rect(l, y, r - l + 1, 1, bark)
        c.px(l, y, barkLight); c.px(r, y, barkDark)
        for fx in [l + 3, l + 8, r - 4] where (y * 3 + fx) % 5 != 0 { c.px(fx, y, barkDark) }
    }
    // The great hollow, low in the trunk (in the signature, drawn over the face below).
    if yawn == nil {
        c.pattern(24, 29, [
            "...FF...",
            "..FHHF..",
            ".FHHHHF.",
            ".FHHHHHF",
            "FHHHHHHF",
            "FHHHHHHF",
            "FHHHHHF.",
            ".FHHHF..",
        ], ["F": furrow, "H": hollow])
    }
    // The sleepy, sly face: heavy brows, one eye closed in a droop, the other a pale-green slit; a crooked smile.
    let glint: Double = 0.65 + 0.35 * sin(p.lt * 0.9)
    c.rect(26, 18, 5, 1, barkLight); c.rect(34, 18, 5, 1, barkLight)
    c.pattern(26, 19, ["F...F", ".FFF."], ["F": furrow])
    c.rect(34, 19, 5, 1, furrow); c.rect(35, 20, 3, 1, C(0xC8F0A8).alpha(glint)); c.px(34, 20, furrow); c.px(38, 20, furrow)
    c.rect(34, 21, 5, 1, furrow)
    c.pattern(31, 21, [".B..", "BBb.", ".bb."], ["B": barkLight, "b": barkDark])     // the knobbly nose
    c.pattern(27, 25, ["F.........F", ".FF.....FF.", "...FFFFF..."], ["F": furrow])
    c.px(38, 24, furrow)
    // The crown, grey-green and weeping, swaying a little.
    c.pattern(13, 5, [
        "..........LlLLl.lLL.......",
        "......lLLLLLLLLLLLLLLl....",
        "...lLLLLmLLLLLmLLLLLLLLl..",
        "..LLmLLLLLLmLLLLLLmLLLLLL.",
        ".LLLLLLdLLLLLLdLLLLLLLmLLL",
        "LLmLLLLLLLLmLLLLLmLLLLLLLL",
        "LLLLdLLmLLLLLLLLLLLLdLLLmL",
        "LdLLLLLLLLdLLLLmLLLLLLLLLL",
        "LLL.dLL.LLL.dLL.LdL.LLd.Ld",
    ], ["L": frond, "l": frondLight, "m": frondLight, "d": frondDark])
    // The fronds hanging in front, either side of his face, and from the branch.
    drawFronds(c, p, xs: [13, 15, 21, 24, 40, 42], top: 14, length: 18, col: frond, light: frondLight, phase: 0)
    drawFronds(c, p, xs: [17, 19, 44], top: 14, length: 25, col: frondDark, light: frond, phase: 1.3)
    // The front branch, drooping out in front of him.
    let lift = Double(p.armRaise) + 4 * (yawn?.stretch ?? 0)
    let tip = (x: willowTip.x, y: willowTip.y - lift + sway * 0.4)
    line(c, 38, 22, 44, 23 - lift * 0.5, bark, 1.3)
    line(c, 44, 23 - lift * 0.5, tip.x, tip.y, barkDark, 0.8)
    c.px(Int(tip.x), Int(tip.y) + 1, furrow)
    for (i, fx) in [43.0, 46.0, 48.0].enumerated() {
        let top = 24 - lift * (fx - 38) / 12 + (i == 2 ? 2 : 0)
        let len = 9.0 - Double(i) * 2
        for k in 0..<Int(len) {
            let x = fx + sin(p.lt * 1.1 + Double(k) * 0.4 + Double(i)) * Double(k) / len * 1.2
            c.px(Int(x.rounded()), Int(top) + k, k % 3 == 1 ? frondLight : frond)
        }
    }
    // Idle and dozing: a little "z" drifting up now and then.
    if p.resting, yawn == nil {
        let f = frac(p.lt / 3.2)
        if f < 0.7 {
            let a: Double = sin(f / 0.7 * .pi) * 0.85, y = 14 - Int(f * 10), x = 41 + Int(f * 5)
            c.pattern(x, y, ["ZZZ", ".Z.", "ZZZ"], ["Z": C(0xE8F4DC, a)])
        }
    }
    // The grabbing root, from the base of the trunk (on the ground, so it doesn't breathe): coiled at rest; swung, out
    // along the floor and up along the swing, its grasping tip curling over and lagging behind.
    if let y = yawn, let s = p.signature { drawYawn(c, y, s: s, t: p.t) }
    c.oy -= p.breathe - stretch
    // Not his bark: an old root, near-black earthy brown and mossy along its length, paling to a raw fresh tip.
    let root = C(0x4A3F2E), rootDark = C(0x2A241A), moss = C(0x6E9440), rootTip = C(0xD8CCA4)
    guard let a = p.melee else {
        drawRoot(c, angle: 6, rise: -30 + 4 * sway, curl: -280, col: root, dark: rootDark, moss: moss, tipCol: rootTip)
        return
    }
    func reach(_ a: Double) -> Double { min(30, max(-120, wrapped(a))) }
    let now = reach(a)
    for (i, ta) in p.trail.enumerated() {
        drawRoot(c, angle: 4, rise: reach(ta) - 4, curl: 100, col: C(0xA8AC94), dark: nil, moss: nil,
                 alpha: 0.32 / Double(i + 1))
    }
    let lag: Double = p.trail.first.map { reach($0) - now } ?? 0
    drawRoot(c, angle: 4, rise: now - 4, curl: min(200, max(40, 100 + lag * 2)), col: root, dark: rootDark, moss: moss,
             tipCol: rootTip)
}

/// Old Man Pillow's yawn at a moment of his signature: how far he's stretched up (0…1), and the hollow in his trunk,
/// an oval centred on (`x`, `y`), `rx` across and `ry` up and down from there (4 and 4 as it is at rest).
private struct WillowYawn {
    let stretch: Double, x: Double, y: Double, rx: Double, ry: Double
}

/// The yawn at `s`: opening slowly (…0.4), held wide, snapped shut to a crack (0.5…0.54), shut, then easing back open
/// to the hollow as it was (0.8…1).
private func willowYawn(_ s: Double) -> WillowYawn {
    if s < 0.5 {
        let o = smooth(s / 0.4)
        return WillowYawn(stretch: o, x: 28 + 1.5 * o, y: 33 - 2.5 * o, rx: 4 + 2.5 * o, ry: 4 + 3.5 * o)
    }
    if s < 0.54 {
        let u = smooth((s - 0.5) / 0.04)
        return WillowYawn(stretch: 1 - u, x: 29.5 - 1.5 * u, y: 30.5 + 2.5 * u, rx: 6.5 - 6 * u, ry: 7.5 - 3 * u)
    }
    let u = smooth((s - 0.8) / 0.2)
    return WillowYawn(stretch: 0, x: 28, y: 33, rx: 0.5 + 3.5 * u, ry: 4.5 - 0.5 * u)
}

/// What the yawn changes on Old Man Pillow (drawn over his face and trunk): the hollow as the yawn has it, splinters
/// round the rim when it gapes; his open eye screwed shut while he yawns and flying wide when the crack snaps shut,
/// the snap's lines either side of it, and the burst of "z"s puffing up out of his crown afterwards.
private func drawYawn(_ c: PixelCanvas, _ y: WillowYawn, s: Double, t: Double) {
    let bark = C(0x7A7C68), barkLight = C(0x9A9C86), furrow = C(0x3A3C30), hollow = C(0x1A1C16)
    // The hollow: a furrowed rim round a dark oval, a little crooked, down to a one-pixel crack.
    for (r, col) in [(1.0, furrow), (0.0, hollow)] {
        let rx = y.rx + r, ry = y.ry + r
        for row in Int((y.y - ry).rounded(.down))...Int((y.y + ry).rounded(.up)) {
            let dy = (Double(row) + 0.5 - y.y) / ry
            guard abs(dy) < 1 else { continue }
            let hw = rx * (1 - dy * dy).squareRoot(), cx = y.x + 0.6 * sin(Double(row) * 0.9)
            let x0 = Int((cx - hw).rounded()), x1 = Int((cx + hw).rounded())
            c.rect(x0, row, x1 - x0 + 1, 1, col)
        }
    }
    if y.rx > 3 {
        let top = Int(y.y - y.ry), bottom = Int(y.y + y.ry), x = Int(y.x)
        for (dx, dy) in [(-2, 1), (1, 1), (3, 2)] { c.px(x + dx, top + dy, barkLight) }
        for (dx, dy) in [(-3, -1), (0, -1), (2, -2)] { c.px(x + dx, bottom + dy, barkLight) }
    }
    // His open eye: shut while he yawns, wide when the crack snaps shut.
    if s > 0.06 && s < 0.5 {
        c.rect(34, 19, 5, 3, bark)
        c.pattern(34, 19, ["F...F", ".FFF."], ["F": furrow])
    } else if s > 0.52 && s < 0.72 {
        c.rect(34, 18, 5, 1, furrow); c.rect(34, 22, 5, 1, furrow)
        c.rect(34, 19, 1, 3, furrow); c.rect(38, 19, 1, 3, furrow)
        c.rect(35, 19, 3, 3, C(0xC8F0A8)); c.px(36, 20, furrow)
    }
    // SNAP.
    if s > 0.5 && s < 0.62 {
        let a: Double = 1 - (s - 0.5) / 0.12, snap = C(0xF4F8E8, a)
        for side in [-1.0, 1.0] {
            for (dy, len) in [(-3.0, 2.0), (0.0, 3.0), (3.0, 2.0)] {
                let x0 = 28 + side * 4, y0 = 32.5 + dy
                line(c, x0, y0, x0 + side * len, y0 + dy * 0.4, snap, 0.45)
            }
        }
    }
    // The "z"s, puffing up out of his crown and away.
    let u = (s - 0.55) / 0.42
    guard u > 0, u < 1 else { return }
    let big = ["ZZZZ", "..Z.", ".Z..", "ZZZZ"], small = ["ZZZ", ".Z.", "ZZZ"]
    for (i, d) in [(x: 0.9, y: -1.0), (x: 0.3, y: -1.2), (x: 1.4, y: -0.5), (x: -0.5, y: -1.0)].enumerated() {
        let v = min(1, max(0, u * 1.3 - Double(i) * 0.1))
        guard v > 0 else { continue }
        let go = 1 - (1 - v) * (1 - v), a: Double = min(1, v * 5) * (1 - v * v)
        let x = 34 + Int((d.x * go * 18 + sin(v * 6 + Double(i)) * 1.2).rounded())
        let y = 13 + Int((d.y * go * 10).rounded())
        c.pattern(x, y, i % 2 == 0 ? big : small, ["Z": C(0xE8F4DC, a * 0.95)])
    }
}

/// Old Man Pillow's grabbing root, from `willowRoot`: setting off along `angle` over the floor, turning `rise` degrees
/// more as it lifts, then curling `curl` degrees more at its tapering tip, where three rootlet fingers splay out like a
/// grasping hand; a darker underside, tufts of `moss` along its top, and (given `tipCol`) paling toward its tip into
/// fresh, raw rootlet fingers.
private func drawRoot(_ c: PixelCanvas, angle: Double, rise: Double, curl: Double, col: Px, dark: Px?, moss: Px?,
                      tipCol: Px? = nil, alpha: Double = 1) {
    let body = curve(willowRoot, angle: angle, bend: rise, n: 6, step: 2, power: 1)
    let tip = curve(body[body.count - 1], angle: angle + rise, bend: curl, n: 6, step: 1.6, power: 2)
    let pts = body + tip.dropFirst()
    let floor = Double(43 - c.oy) + 0.5
    /// The root's colour `f` along it: its own colour, paling into `tipCol` over the last part.
    func shade(_ f: Double) -> Px {
        guard let tipCol, f > 0.5 else { return col }
        let k = min(1, (f - 0.5) / 0.4)
        func mix(_ a: UInt8, _ b: UInt8) -> UInt8 { UInt8((Double(a) + (Double(b) - Double(a)) * k).rounded()) }
        return Px(r: mix(col.r, tipCol.r), g: mix(col.g, tipCol.g), b: mix(col.b, tipCol.b), a: col.a)
    }
    for i in 1..<pts.count {
        let a = pts[i - 1], b = pts[i], f = Double(i) / Double(pts.count - 1)
        let r: Double = 1.9 + (0.45 - 1.9) * f
        if let dark { line(c, a.x, min(a.y + 0.6, floor), b.x, min(b.y + 0.6, floor), dark.alpha(alpha), r) }
        line(c, a.x, min(a.y, floor), b.x, min(b.y, floor), shade(f).alpha(alpha), r * (dark == nil ? 1 : 0.8))
    }
    // The rootlet fingers, splaying from just behind the tip, the palest part of it.
    let hand = pts[pts.count - 3], end = angle + rise + curl
    for spread in [-55.0, -15.0, 25.0] {
        let u = unit(end + spread)
        line(c, hand.x, min(hand.y, floor), hand.x + u.x * 3.5, min(hand.y + u.y * 3.5, floor), shade(1).alpha(alpha), 0.4)
    }
    // Moss in tufts along its old, thick part, on whichever side is up.
    guard let moss else { return }
    for i in [1, 2, 4, 5, 7] where i + 1 < pts.count {
        let a = pts[i], b = pts[i + 1], f = Double(i) / Double(pts.count - 1)
        let len = max(hypot(b.x - a.x, b.y - a.y), 0.01), r: Double = (1.9 + (0.45 - 1.9) * f) * 0.8
        var n = (x: (b.y - a.y) / len, y: -(b.x - a.x) / len)
        if n.y > 0 { n = (-n.x, -n.y) }
        let x = a.x + n.x * r, y = a.y + n.y * r
        guard y < floor else { continue }
        c.px(Int(x.rounded(.down)), Int(y.rounded(.down)), moss.alpha(alpha))
        if i % 2 == 1 { c.px(Int(x.rounded(.down)) + 1, Int(y.rounded(.down)), moss.alpha(alpha * 0.8)) }
    }
}

/// The points along a curving limb: from `root`, setting off along `angle` (degrees, 0 forward, -90 up) and turning
/// `bend` degrees more by its tip, the turn tightening toward the tip with `power`; `n` steps of `step`.
private func curve(_ root: (x: Double, y: Double), angle: Double, bend: Double, n: Int, step: Double, power: Double) -> [(x: Double, y: Double)] {
    var pts = [root]
    for i in 1...n {
        let f = Double(i) / Double(n)
        let u = unit(angle + bend * pow(f, power)), q = pts[pts.count - 1]
        pts.append((q.x + u.x * step, q.y + u.y * step))
    }
    return pts
}

/// An angle in degrees brought into -180…180.
private func wrapped(_ a: Double) -> Double {
    var w: Double = a.truncatingRemainder(dividingBy: 360)
    if w > 180 { w -= 360 } else if w <= -180 { w += 360 }
    return w
}

/// Long, thin willow fronds hanging from row `top` at each of `xs`, `length` rows, their ends swaying more than their
/// tops, a lighter leaf every few pixels.
private func drawFronds(_ c: PixelCanvas, _ p: Pose, xs: [Int], top: Int, length: Int, col: Px, light: Px, phase: Double) {
    for (i, fx) in xs.enumerated() {
        let len = length - (i * 3) % 7
        for k in 0..<len {
            let y = top + k
            guard y + c.oy <= 43 else { break }
            let x = Double(fx) + sin(p.lt * 1.1 + phase + Double(i) * 0.7 + Double(k) * 0.15) * Double(k) / Double(len) * 1.5
            c.px(Int(x.rounded()), y, (k + i) % 4 == 2 ? light : col)
        }
    }
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// Boots over the bottom `rows` of each leg (a bit of the folded foot when sitting).
private func drawBoots(_ c: PixelCanvas, _ step: Int, _ col: Px, rows: Int = 2) {
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 2, 2, col) }
        return
    }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - rows + 1, 2, rows, col)
    }
}

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
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
