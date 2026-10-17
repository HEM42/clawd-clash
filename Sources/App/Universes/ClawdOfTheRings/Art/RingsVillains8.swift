import Foundation

// Villains: the Hobbit's foes. Smaug and the Mirkwood spider are creatures, not Clawd: the dragon is half again a Man's
// height and width, crouched over his hoard (the size is drawn on the canvas, so his `headTop`, `muzzle` and `bulk` say
// so), the spider a little wider than a Man, high on banded legs. Azog and the Goblin King are Clawd underneath, the
// blocky body in their own skin: Azog a head taller, chalk-white and scarred, the King half again as wide, all belly.

let ringsVillains8: [RingsVillain: Persona] = [
    .smaug: Persona(name: "Smaug the Stashed", weapon: .blaster, shot: .fire, armoured: true, canSit: false,
                    muzzle: smaugJaws, handGun: false, bulk: 12, headTop: 10, signature: 3.4,
                    callout: "Thief! Who dared git stash pop my hoard?", draw: drawSmaug),
    .azog: Persona(name: "Azog the Profiler", weapon: .saber, pivot: azogHand, bulk: 2, headTop: 19, signature: 2.8,
                   callout: "Profiled you, dwarf: the call stack of Durin ends here.", draw: drawAzog),
    .goblinKing: Persona(name: "The Go-blin King", weapon: .saber, canSit: false, pivot: kingHand, bulk: 13, headTop: 17, signature: 3.0,
                         callout: "if err != nil { eat the dwarves }", draw: drawGoblinKing),
    .mirkwoodSpider: Persona(name: "The Mirkwood Web Crawler", weapon: .blaster, shot: .web, canSit: false,
                             muzzle: spiderJaws, handGun: false, bulk: 6, headTop: 22, signature: 3.2,
                             callout: "Crawled, indexed, wrapped: one juicy dwarf, cached for later.",
                             draw: drawMirkwoodSpider),
]

// MARK: - Smaug the Stashed

/// Where Smaug's fire leaves from: between his jaws.
private let smaugJaws: (x: Double, y: Double) = (60, 18)

/// Smaug, the last great fire-drake, half again a Man's height and width: red scales with a gold-plated belly and throat,
/// crouched over his heap of gold coins (and a gem or two), a spiked ridge down his back, bat wings half open over it,
/// a long neck arching up to a horned head with burning eyes, and a fire glowing in his throat. His tail lies curled
/// round the hoard. He breathes fire: the jaws drop open on each shot and the throat flares. Walking, he leaves the
/// heap behind. Signature: "I am fire, I am death!" He rises over the hoard and throws his wings wide (…0.25), the
/// snap of them flicking coins off the heap to spin away and bounce over the floor, and the fire builds inside him
/// until his throat and the seams of his belly glow with it and he opens his jaws on the furnace (0.45…0.72); then
/// it dies down and he folds his wings again.
private func drawSmaug(_ c: PixelCanvas, _ p: Pose) {
    let scale = C(0xA8301E), scaleDark = C(0x7A1E14), scaleLight = C(0xCC4A2A), far = C(0x5E1810)
    let gold = C(0xE0A848), goldDark = C(0xB07A30)
    let membrane = C(0x8A2418), membraneFar = C(0x5A160E), bone = C(0x4A120A)
    let horn = C(0xE0D4B4), hornDark = C(0xA89878)
    let fire = C(0xFFB03A), ember = C(0xE8501E), hot = C(0xFFF0B0)
    let glow: Double = 0.7 + 0.3 * sin(p.lt * 2.1)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 ? $0 : nil }
    let spread: Double = sig.map { $0 < 0.25 ? smooth($0 / 0.25) : $0 < 0.8 ? 1 : 1 - smooth(($0 - 0.8) / 0.18) } ?? 0
    let blaze: Double = sig.map { $0 < 0.15 ? 0 : $0 < 0.45 ? smooth(($0 - 0.15) / 0.3) : $0 < 0.75 ? 1 : 1 - smooth(($0 - 0.75) / 0.2) } ?? 0
    let roar = sig.map { $0 > 0.45 && $0 < 0.72 } ?? false
    let breathing = roar || (p.fire.map { frac($0.t / p.firePeriod) < 0.2 } ?? false)   // jaws open while the fire leaves
    // The tail, round the front of the hoard to a spade tip on the floor.
    taper(c, [(13, 31), (8, 33), (5, 37), (5, 41), (9, 43), (13, 43)], r0: 2.6, r1: 1, scale)
    c.pattern(13, 41, ["S..", "SSS", "SS."], ["S": scaleDark])
    // The far legs, darker, behind the body.
    for (i, x) in [24.0, 35.0].enumerated() {
        let up: Double = p.step >= 0 && i == p.step ? 1 : 0
        line(c, x, 32, x + 1, 42 - up, far, 1.6)
        c.rect(Int(x) - 1, 42 - Int(up), 5, 2, far)
    }
    c.oy += p.breathe
    // The far wing, peeking over the near one.
    func mix(_ a: (Double, Double), _ b: (Double, Double)) -> (Double, Double) {
        (a.0 + (b.0 - a.0) * spread, a.1 + (b.1 - a.1) * spread)
    }
    drawDragonWing(c, wrist: mix((31, 4), (42, 4)), tips: [mix((17, 3), (65, 10)), mix((18, 11), (53, 3)), mix((23, 18), (28, 6))],
                   roots: [(26, 24), (34, 23)], membrane: lerp(membraneFar, C(0xA03018), 0.5 * blaze), bone: bone, arm: far)
    // The body: a crouched barrel, the gold belly plates under it, a spiked ridge along the back.
    c.ellipse(26, 31, 14, 8, scaleDark)
    c.ellipse(26, 30, 14, 8, scale)
    c.ellipse(27, 34, 10, 3, goldDark)
    c.ellipse(27, 33, 10, 3, gold)
    for x in stride(from: 19, through: 35, by: 3) { c.rect(x, 32, 1, 3, goldDark) }
    for (x, y) in [(16, 27), (22, 26), (31, 26), (20, 29), (34, 29), (14, 31)] { c.px(x, y, scaleLight) }
    for (x, y) in [(15, 23), (19, 22), (23, 21), (27, 21), (31, 21), (35, 23)] {
        c.px(x, y, scaleDark); c.px(x, y - 1, scaleDark); c.px(x + 1, y, scaleDark)
    }
    // The fire inside him, showing through the seams of his belly plates.
    if blaze > 0 {
        c.glowLine(20, 31, 35, 31, core: fire.alpha(0.9 * blaze), glow: ember.alpha(0.8 * blaze), coreR: 1.6, glowR: 4.6)
        for x in stride(from: 19, through: 35, by: 3) { c.rect(x, 32, 1, 3, hot.alpha(blaze)) }
    }
    // The near wing, half open over his back.
    drawDragonWing(c, wrist: mix((21, 5), (15, 4)), tips: [mix((4, 6), (2, 3)), mix((6, 14), (2, 11)), mix((10, 21), (3, 20))],
                   roots: [(16, 25), (28, 23)], membrane: lerp(membrane, C(0xD84A1E), 0.5 * blaze), bone: bone, arm: scale)
    // The neck, arching up and forward, gold underneath, the fire showing in the throat.
    let neck: [(x: Double, y: Double)] = [(35, 28), (39, 24), (42, 20), (46, 16)]
    taper(c, neck, r0: 4, r1: 2.6, scale)
    taper(c, neck.map { ($0.x + 1.5, $0.y + 2) }, r0: 1.6, r1: 1, gold)
    let throat: Double = breathing ? 1 : glow * 0.8
    c.glowLine(41, 24, 45, 20, core: fire.alpha(throat), glow: ember.alpha(throat * 0.8), coreR: 0.5, glowR: 1.6)
    if blaze > 0 {
        c.glowLine(37, 28, 46, 18, core: hot.alpha(blaze), glow: fire.alpha(blaze), coreR: 1.2, glowR: 3.6)
    }
    for (x, y) in [(37, 23), (40, 19), (43, 15)] { c.px(x, y, scaleDark) }
    // The head, a little higher while he's raised to fire (or rising in his signature).
    let rise = Int((3 * spread).rounded())
    c.oy += p.gunY - rise
    c.pattern(40, 6, [
        "hH.......",
        ".hHH.....",
        "..HHH....",
        "...HHH...",
        "....HHH..",
        ".....HH..",
    ], ["H": horn, "h": hornDark])
    c.pattern(42, 9, ["hh.....", ".hhh...", "..hhh..", "...hh.."], ["h": hornDark])
    c.rect(46, 11, 8, 7, scale)
    c.rect(47, 10, 6, 1, scale)
    c.rect(54, 13, 4, 1, scale)
    c.rect(54, 14, 6, 3, scale)
    c.rect(47, 10, 6, 1, scaleLight); c.rect(54, 13, 4, 1, scaleLight)
    c.rect(48, 12, 6, 1, scaleDark)                                               // the brow ridge
    c.px(58, 14, ink); c.px(59, 14, scaleDark)                                    // the nostril
    c.glowLine(51, 13.5, 52.5, 13.5, core: hot, glow: fire, coreR: 0.5, glowR: 1.4, strength: 0.8 + 0.2 * glow)
    c.px(52, 13, ink)
    // The jaws: shut, a row of teeth showing; firing, the lower jaw drops and the furnace shows.
    if breathing {
        c.rect(50, 17, 10, 2, ember)
        c.rect(52, 17, 7, 1, hot)
        c.rect(49, 19, 10, 2, scaleDark)
        c.rect(49, 20, 9, 1, gold)
        for x in [53, 55, 57] { c.px(x, 19, horn) }
    } else {
        c.rect(48, 17, 11, 2, scaleDark)
        c.rect(49, 18, 9, 1, gold)
        if glow > 0.9 { c.px(59, 17, ember.alpha(0.6)) }
    }
    for x in [55, 57, 59] { c.px(x, 17, horn) }
    c.pattern(46, 16, ["s.", "ss", ".s"], ["s": scaleDark])                       // the cheek spikes
    // Smoke curling from the nostrils now and then.
    if !breathing, sin(p.lt * 0.9) > 0.4 {
        let k = Int(p.lt * 6)
        for i in 0..<3 { c.px(60 + i, 13 - i - k % 2, C(0x9A9090, 0.5 - Double(i) * 0.15)) }
    }
    c.oy -= p.gunY - rise
    c.oy -= p.breathe
    // The near legs: a great haunch behind, a clawed foreleg in front.
    let rearUp = p.step == 0 ? 1 : 0, frontUp = p.step == 1 ? 1 : 0
    c.oy += p.breathe
    c.ellipse(18, 32, 6, 6, scale)
    c.ellipse(19, 34, 4, 3, scaleDark)
    c.oy -= p.breathe
    c.rect(15, 36, 5, 6 - rearUp, scale)
    c.rect(14, 41 - rearUp, 7, 3, scaleDark)
    line(c, 39, 29 + Double(p.breathe), 42, 36, scale, 2)
    line(c, 42, 36, 44, 41 - Double(frontUp), scale, 1.6)
    c.rect(42, 41 - frontUp, 6, 3, scaleDark)
    // The hoard, over his feet; his claws dug into it.
    if !p.walking { drawHoard(c, p) }
    let footY = p.walking ? 43 : 38
    for x in [43, 45, 47] { c.px(x, footY - frontUp, horn) }
    for x in [14, 16, 18] { c.px(x, (p.walking ? 43 : 37) - rearUp, horn) }
    if let s = sig, !p.walking { drawFlungCoins(c, s, length: 3.4) }
}

/// Coins flicked off the hoard by the snap of Smaug's wings `s` through his signature (`length` seconds long): each
/// flies up spinning, falls, bounces once along the floor and fades.
private func drawFlungCoins(_ c: PixelCanvas, _ s: Double, length: Double) {
    let coin = C(0xE8B840), coinLight = C(0xFFE07A), coinDark = C(0xB08424)
    let flung: [(x: Double, y: Double, vx: Double, vy: Double)] = [
        (24, 36, -14, 40), (33, 36, 17, 44), (20, 38, -22, 30), (38, 38, 24, 34),
        (28, 35, 5, 48), (14, 40, -16, 26), (44, 40, 20, 28), (30, 36, -7, 38),
    ]
    let g = 110.0
    for (i, f) in flung.enumerated() {
        let t0 = 0.2 + Double(i % 4) * 0.02
        guard s > t0 else { continue }
        var e = (s - t0) * length, x = f.x + f.vx * e, y = f.y - f.vy * e + 0.5 * g * e * e
        let land = (f.vy + (f.vy * f.vy + 2 * g * (42.5 - f.y)).squareRoot()) / g     // when it reaches the floor
        var fade = 1.0
        if e > land {                                                              // one low bounce, then lie there
            e -= land
            let vb = f.vy * 0.35
            x = f.x + f.vx * land + f.vx * 0.5 * e
            y = min(42.5, 42.5 - vb * e + 0.5 * g * e * e)
            fade = max(0, 1 - e / 0.9)
        }
        guard fade > 0, y > -2 else { continue }
        let ix = Int(x.rounded(.down)), iy = Int(y.rounded(.down))
        if Int(e * 14 + Double(i)) % 2 == 0 {
            c.px(ix, iy, coin.alpha(fade)); c.px(ix + 1, iy, coinLight.alpha(fade))
        } else {
            c.px(ix, iy, coinDark.alpha(fade)); c.px(ix, iy - 1, coin.alpha(fade))
        }
    }
}

/// A dragon's bat wing: the arm bone from the front root up to the `wrist`, finger bones out to the `tips`, and the
/// membrane stretched between them down to the `roots` on the back, scalloped between the fingers.
private func drawDragonWing(_ c: PixelCanvas, wrist w: (Double, Double), tips: [(Double, Double)], roots: [(Double, Double)],
                            membrane: Px, bone: Px, arm: Px) {
    // The edge: tip, a scallop pulled toward the wrist, the next tip… down to the back root, then the front root.
    var edge: [(Double, Double)] = []
    let ends = tips + [roots[0]]
    for i in 0..<ends.count {
        edge.append(ends[i])
        if i + 1 < ends.count {
            let m = ((ends[i].0 + ends[i + 1].0) / 2, (ends[i].1 + ends[i + 1].1) / 2)
            edge.append((m.0 + (w.0 - m.0) * 0.3, m.1 + (w.1 - m.1) * 0.3))
        }
    }
    edge.append(roots[1])
    for i in 1..<edge.count { fill(c, w, edge[i - 1], edge[i], membrane) }
    for t in tips { line(c, w.0, w.1, t.0, t.1, bone, 0.45) }
    line(c, roots[1].0, roots[1].1, w.0, w.1, arm, 1.2)
    c.px(Int(w.0), Int(w.1) - 1, C(0xE0D4B4))                                      // the wrist claw
}

/// Smaug's hoard: a mound of gold coins round his feet, glinting, with a red and a green gem and a goblet in it.
private func drawHoard(_ c: PixelCanvas, _ p: Pose) {
    let coin = C(0xE8B840), coinLight = C(0xFFE07A), coinDark = C(0xB08424)
    for y in 35...43 {
        let half = Int((25 * (Double(y - 34) / 9).squareRoot()).rounded())
        for x in (29 - half)...(29 + half) {
            let n = noise(x * 13 + y * 71)
            c.px(x, y, n < 0.22 ? coinDark : n > 0.8 ? coinLight : coin)
        }
    }
    for (x, y) in [(16, 41), (24, 39), (33, 38), (40, 41), (28, 42), (10, 42), (47, 42)] {
        c.px(x, y, coinDark); c.px(x + 1, y, coinLight)                           // coins lying on edge
    }
    c.rect(20, 38, 2, 2, C(0xC8202A)); c.px(20, 38, C(0xFF8A8A))
    c.rect(36, 40, 2, 2, C(0x2A9A4A)); c.px(36, 40, C(0x9AF0B0))
    c.pattern(50, 39, ["GGG", ".G.", ".G.", "GGG"], ["G": coinDark])               // the goblet
    c.px(50, 39, coinLight)
    for k in 0..<3 {
        let tw = sin(p.lt * 3 + Double(k) * 2.1)
        if tw > 0.6 {
            let (x, y) = [(26, 36), (14, 40), (42, 39)][k]
            c.px(x, y, white); c.px(x - 1, y, white.alpha(0.5)); c.px(x + 1, y, white.alpha(0.5)); c.px(x, y - 1, white.alpha(0.5))
        }
    }
}

// MARK: - Azog the Profiler

/// Where Azog's mace hand is: a little higher and further out than Clawd's, he's a head taller.
private let azogHand: (x: Double, y: Double) = (43.5, 32.5)

/// Azog, the pale orc chieftain, a head taller than a Man: chalk-white skin crossed with scars (some stitched), a bald
/// domed head with a heavy brow, ice-blue eyes and a tusked underbite, bare to the waist, a leather belt hung with
/// trophies (a skull, teeth, a braided dwarf beard) over a dark kilt, and for a left arm an iron claw, a hooked prong
/// riveted to a cuff on the stump. In his right fist a spiked iron mace, hanging forward at rest; a fast swing smears
/// its head a long way behind it. Signature: the Defiler's roar. He swings his iron claw up over his head, high and
/// hooked against the sky (…0.25), and roars, jaws wide, eyes blazing, shaking with it and the roar rolling off him
/// (0.3…0.72), then lowers the claw again.
private func drawAzog(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE6E4DC), skinShade = C(0xC4C0B6), skinLight = C(0xF8F8F4), scar = C(0xB4989A), scarDeep = C(0x8A6E70)
    let leather = C(0x3A2C22), leatherDark = C(0x241A14), bone = C(0xD8CC9A), beard = C(0xA8582A)
    let iron = C(0x5A5E66), ironLight = C(0x8E929A), ironDark = C(0x34383E), eye = C(0x8AD0F0)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 && !seatedPose ? $0 : nil }
    let raise: Double = sig.map { $0 < 0.25 ? smooth($0 / 0.25) : $0 < 0.75 ? 1 : 1 - smooth(($0 - 0.75) / 0.2) } ?? 0
    let roar = sig.map { $0 > 0.3 && $0 < 0.72 } ?? false
    let ox = c.ox
    if roar, Int(p.lt * 24) % 2 == 0 { c.ox += 1 }                                 // shaking with it
    defer { c.ox = ox }
    // Bare pale legs, leather wraps round the shins and feet.
    for (i, lx) in [18, 23, 31, 36].enumerated() {
        if seatedPose { c.rect(lx - 1, 38, 4, 2, skin); c.rect(lx + 1, 38, 2, 2, leather); continue }
        let up = p.step >= 0 && i % 2 == p.step ? 1 : 0
        c.rect(lx, 36, 3, 8 - up, i % 2 == 0 ? skinShade : skin)
        c.rect(lx, 39 - up, 3, 1, leather)
        c.rect(lx, 42 - up, 3, 2, leatherDark)
    }
    c.oy += p.breathe
    // The iron claw on the back arm: a cuff on the stump, a long hooked prong and a short spur.
    if raise > 0 {
        drawRaisedClaw(c, raise, skin: skin, iron: iron, ironLight: ironLight, ironDark: ironDark)
    } else {
        c.rect(13, 28, 3, 3, skin)
        line(c, 12, 32, 9, 38, iron, 0.9)
        line(c, 9, 38, 10, 40.5, iron, 0.7)
        line(c, 10, 40.5, 13, 40.5, ironLight, 0.5)
        line(c, 12, 31.5, 7.5, 34, iron, 0.6)
        c.px(7, 34, ironLight)
        c.rect(11, 30, 5, 3, ironDark)
        c.rect(11, 30, 5, 1, ironLight)
        c.px(12, 31, ironLight); c.px(14, 31, ironLight)                           // the rivets
    }
    // The body, tall, the head domed and bald.
    c.rect(18, 19, 20, 1, skin)
    c.rect(17, 20, 22, 1, skin)
    c.rect(16, 21, 24, 17, skin)
    c.rect(39, 21, 1, 17, skinShade); c.px(38, 20, skinShade)
    c.rect(19, 20, 4, 1, skinLight); c.px(18, 21, skinLight)
    c.rect(16, 37, 24, 1, skinShade)
    // The face: a heavy brow, ice-blue eyes, a jutting jaw with two tusks.
    c.rect(21, 24, 17, 1, skinShade)
    c.rect(23, 25, 2, 3, ink); c.rect(33, 25, 2, 3, ink)
    c.px(24, 25, eye); c.px(34, 25, eye)
    c.rect(27, 29, 11, 1, C(0x5A4448))
    c.px(29, 28, bone); c.px(36, 28, bone)
    c.rect(30, 30, 7, 1, skinShade)
    // The scars: across the dome, the face, the chest; two of them stitched.
    let cuts: [((Double, Double), (Double, Double))] = [
        ((20, 21), (26, 26)), ((30, 20), (37, 23)), ((35, 26), (38, 30)), ((18, 27), (21, 30)),
        ((19, 31), (28, 34)), ((30, 32), (37, 31)), ((25, 30), (24, 33)),
    ]
    for (k, cut) in cuts.enumerated() { line(c, cut.0.0, cut.0.1, cut.1.0, cut.1.1, k % 3 == 0 ? scarDeep : scar, 0.4) }
    for (x, y) in [(21, 23), (23, 24), (21, 32), (25, 33)] { c.px(x, y, scarDeep); c.px(x + 1, y - 1, scarDeep) }
    // Roaring: the jaws gape on the tusks, the eyes blaze, and the roar rolls off him.
    if roar, let s = sig {
        c.rect(27, 29, 11, 3, C(0x3A2A2E)); c.rect(29, 31, 7, 1, C(0x8A3A3A))
        c.px(29, 28, bone); c.px(29, 29, bone); c.px(36, 28, bone); c.px(36, 29, bone)
        c.rect(27, 32, 11, 1, skinShade)
        for ex in [24.5, 34.5] {
            c.glowLine(ex, 25.5, ex, 25.5, core: eye, glow: C(0x4AA8E0), coreR: 0.4, glowR: 2.2, strength: 0.7)
        }
        for j in 0..<3 {
            let f = frac((s - 0.3) * 5 + Double(j) / 3), r = 3 + f * 10
            for a in stride(from: -50.0, through: 50, by: 10) {
                let u = unit(a)
                c.px(Int((38 + u.x * r).rounded(.down)), Int((30 + u.y * r).rounded(.down)), C(0xE8ECF0, 0.8 * (1 - f)))
            }
        }
    }
    // The belt and its trophies, over a dark kilt.
    c.rect(16, 34, 24, 4, leatherDark)
    for x in stride(from: 17, through: 39, by: 3) { c.px(x, 37, leather) }
    c.rect(16, 33, 24, 2, leather)
    c.rect(27, 33, 3, 2, ironLight); c.px(28, 33, ironDark)
    c.pattern(19, 34, [".BBB.", "BKBKB", ".BBB.", ".B.B."], ["B": bone, "K": ink])     // a skull
    c.rect(33, 35, 1, 4, beard); c.rect(34, 35, 1, 3, beard); c.px(33, 39, C(0x7A3A1A))  // a dwarf's braid
    for x in [25, 31, 37] { c.px(x, 35, bone); c.px(x, 36, bone) }                // teeth on thongs
    // The mace, and a long smear of its head behind a fast swing.
    let mace = p.melee ?? (seatedPose ? 8 : 45)
    let trail = p.melee == nil ? [] : p.trail
    for (i, a) in heavySmear(mace, trail).enumerated() {
        let fade: Double = 0.32 * (1 - Double(i) / 10)
        guard fade > 0.03 else { break }
        let u = unit(a)
        c.glowLine(azogHand.x + u.x * 10.5, azogHand.y + u.y * 10.5, azogHand.x + u.x * 10.5, azogHand.y + u.y * 10.5,
                   core: ironLight, glow: ironDark, coreR: 2, glowR: 2.6, strength: fade)
    }
    drawMace(c, angle: mace)
    // The mace arm and fist.
    c.rect(40, 30, 2, 4, skin)
    c.rect(42, 31, 3, 3, skin); c.px(44, 33, skinShade)
}

/// Azog's iron claw swung `k` of the way up (0 hanging at his side, 1 raised high over his head): the hanging claw
/// turned up about his shoulder, the arm stretched out to its full reach, except while it sweeps out behind him, where
/// it reaches only as far as the frame's left edge leaves room for (two pixels clear, so its outline isn't cut).
private func drawRaisedClaw(_ c: PixelCanvas, _ k: Double, skin: Px, iron: Px, ironLight: Px, ironDark: Px) {
    let sh: (x: Double, y: Double) = (14.5, 29.5), a: Double = 144 * k * .pi / 180
    var reach = 1 + 0.7 * k
    let rim: [(Double, Double)] = [(9, 38), (10, 40.5), (13, 40.5), (7.5, 34), (12, 32)]
    let back = rim.map { sh.x + (($0.0 - sh.x) * cos(a) - ($0.1 - sh.y) * sin(a)) * reach }.min() ?? sh.x
    let edge = 2 - Double(c.ox)                                                     // canvas x 2, in drawing units
    if back < edge { reach *= (sh.x - edge) / (sh.x - back) }
    func at(_ x: Double, _ y: Double) -> (x: Double, y: Double) {
        let dx = (x - sh.x) * reach, dy = (y - sh.y) * reach
        return (sh.x + dx * cos(a) - dy * sin(a), sh.y + dx * sin(a) + dy * cos(a))
    }
    func seg(_ p: (x: Double, y: Double), _ q: (x: Double, y: Double), _ col: Px, _ r: Double) {
        line(c, p.x, p.y, q.x, q.y, col, r)
    }
    func dot(_ q: (x: Double, y: Double), _ col: Px) { c.px(Int(q.x.rounded(.down)), Int(q.y.rounded(.down)), col) }
    seg(sh, at(13.5, 31.5), skin, 1.5)                                              // the arm, up to the cuff
    seg(at(12, 32), at(9, 38), iron, 0.9)
    seg(at(9, 38), at(10, 40.5), iron, 0.7)
    seg(at(10, 40.5), at(13, 40.5), ironLight, 0.5)
    seg(at(12, 31.5), at(7.5, 34), iron, 0.6)
    dot(at(7.5, 34.5), ironLight)
    seg(at(11.5, 31.5), at(15.5, 31.5), ironDark, 1.4)                             // the cuff
    seg(at(11.5, 30.5), at(15.5, 30.5), ironLight, 0.5)
    dot(at(12.5, 31.5), ironLight); dot(at(14.5, 31.5), ironLight)                 // the rivets
}

/// Azog's mace: an iron-shod wooden haft and a spiked iron ball.
private func drawMace(_ c: PixelCanvas, angle: Double) {
    let h = azogHand, u = unit(angle)
    func at(_ d: Double) -> (x: Double, y: Double) { (h.x + u.x * d, h.y + u.y * d) }
    let g0 = at(-2), g1 = at(8.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x4A3424), 0.6)
    let b = at(10.5)
    for k in 0..<8 {
        let s = unit(Double(k) * 45 + angle)
        c.px(Int((b.x + s.x * 3.3).rounded(.down)), Int((b.y + s.y * 3.3).rounded(.down)), C(0xB4B8C0))
    }
    c.glowLine(b.x, b.y, b.x, b.y, core: C(0x5A5E66), glow: clear, coreR: 2.3, glowR: 2.4)
    c.px(Int(b.x) - 1, Int(b.y) - 1, C(0x8E929A))
}

// MARK: - The Go-blin King

/// Where the Goblin King holds his staff: out in front of his belly.
private let kingHand: (x: Double, y: Double) = (45.5, 32.5)

/// The Goblin King, half again as wide as a Man and a head taller: a vast sagging belly in pale grey-yellow skin,
/// warty, on stubby legs, no neck, a pointed ear with a gold ring, small mean eyes over a drooping bulb of a nose, a
/// wide snaggle-toothed grin, chins hanging in folds and a great goitre wobbling under them (it bounces as he walks),
/// a ragged loincloth, and a tiny gold crown perched on top. He fights with his staff, a crooked stick topped with a
/// skull: held upright at rest, swung like a club, the skull smearing behind a fast swing. Signature: "Down, down to
/// Goblin-town!" He sings, beating time: four times (0.05…0.85) he lifts his staff and thumps it on the floor, a puff of
/// dust at its foot, bobbing on each beat with his mouth wide on the note, his goitre jiggling, and a note floating up
/// off each one.
private func drawGoblinKing(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xCFC69A), skinShade = C(0xADA47A), skinDark = C(0x8C845E), skinLight = C(0xE2DCB8), wart = C(0x9A8A56)
    let goitre = C(0xD8C096), goitreShade = C(0xB49C74)
    let rag = C(0x5A4630), ragDark = C(0x3E3020), gold = C(0xE0B040), goldLight = C(0xFFE07A)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 ? $0 : nil }
    // Where he is in the song: the beat (0 as the staff lands, 0…1 to the next) and how far into the four beats.
    let beat: Double? = sig.flatMap { $0 > 0.05 && $0 < 0.85 ? frac(($0 - 0.05) / 0.2) : nil }
    // Stubby legs under the belly.
    for (i, lx) in [18, 23, 31, 36].enumerated() {
        let up = p.step >= 0 && i % 2 == p.step ? 1 : 0
        c.rect(lx, 38, 4, 6 - up, i % 2 == 0 ? skinShade : skin)
        c.rect(lx, 43 - up, 4, 1, skinDark)
    }
    c.oy += p.breathe
    let bob = beat.map { $0 < 0.25 ? 1 : 0 } ?? 0                                  // a bob on the beat
    c.oy += bob
    var wobble = p.walking ? (p.step == 0 ? 1 : 0) : (sin(p.lt * 2.6) > 0.5 ? 1 : 0)
    if let s = sig, s > 0.05, s < 0.9 { wobble = [0, 2, 1, -1, 1, 2][Int(s * 40) % 6] }   // jiggling
    // The back arm, hanging flabby.
    c.rect(10, 29, 4, 7, skinShade)
    c.rect(9, 35, 4, 3, skinShade)
    // The belly: a great sagging round, shaded underneath, with a fold and a navel.
    c.ellipse(28, 33, 16, 8, skinDark)
    c.ellipse(28, 32, 16, 8, skinShade)
    c.ellipse(27, 31, 15, 7, skin)
    c.ellipse(24, 28, 8, 3, skinLight)
    c.rect(17, 36, 22, 1, skinShade)
    c.px(31, 34, skinDark); c.px(31, 35, skinDark)
    for (x, y) in [(15, 31), (21, 33), (36, 29), (40, 34), (26, 37), (18, 27)] { c.px(x, y, wart) }
    // The ragged loincloth.
    c.rect(18, 37, 20, 2, rag)
    for x in stride(from: 18, through: 37, by: 2) { c.px(x, 39, rag); if x % 4 == 0 { c.px(x, 40, ragDark) } }
    c.rect(18, 37, 20, 1, ragDark)
    // The head on top, no neck: a pointed ear with a ring, mean little eyes, a drooping nose, a wide grin.
    c.rect(19, 19, 18, 1, skin)
    c.rect(18, 20, 20, 8, skin)
    c.rect(37, 20, 1, 7, skinShade)
    c.pattern(12, 19, ["SS.....", ".SSSS..", "..SSSSS", "...SSS."], ["S": skin])
    c.px(12, 19, skinDark); c.px(15, 22, gold); c.px(15, 23, goldLight)
    c.rect(22, 21, 6, 1, skinShade); c.rect(31, 21, 5, 1, skinShade)                // the frowning brows
    c.rect(24, 22, 2, 2, ink); c.rect(32, 22, 2, 2, ink)
    c.px(25, 22, C(0xE8D84A)); c.px(33, 22, C(0xE8D84A))
    c.pattern(35, 22, [".NN..", "NNNN.", "NNNNN", ".NnN."], ["N": skin, "n": skinShade])
    c.px(39, 24, skinShade)
    c.rect(24, 26, 13, 1, C(0x4A3A2A))
    for x in [25, 29, 34] { c.px(x, 25, C(0xF0E8C8)) }
    c.px(31, 27, C(0xF0E8C8))
    if let f = beat, f < 0.6 {                                                    // singing out the note
        c.rect(28, 25, 6, 3, C(0x4A3A2A)); c.rect(29, 27, 4, 1, C(0x8A3A3A))
        c.px(28, 25, C(0xF0E8C8)); c.px(33, 25, C(0xF0E8C8))
    }
    // The chins in folds, and the goitre hanging under them, wobbling.
    c.rect(21, 28, 17, 2, skin)
    c.rect(22, 28, 15, 1, skinShade)
    c.rect(24, 30, 13, 1, skinShade)
    c.rect(32, 29, 5, 1, skinDark)
    c.ellipse(34, 32 + wobble, 5, 4, skinDark)
    c.ellipse(34, 31 + wobble, 4, 3, goitreShade)
    c.ellipse(33, 31 + wobble, 3, 2, goitre)
    c.px(32, 30 + wobble, skinLight); c.px(37, 33 + wobble, wart)
    // The tiny crown.
    c.pattern(25, 16, ["G.G.G", "GGGGG", "GgRgG"], ["G": gold, "g": goldLight, "R": C(0xC8202A)])
    // Singing: a note floating up off each beat, and the staff lifted and thumped down on it, dust puffing at its foot.
    if let s = sig, let f = beat {
        let n = Int((s - 0.05) / 0.2), x = Int((33 + f * 5).rounded()), y = Int((16 - f * 12).rounded())
        let col = (n % 2 == 0 ? goldLight : C(0xF0E8C8)).alpha(1 - f * f)
        c.rect(x, y, 2, 1, col); c.rect(x + 1, y - 3, 1, 3, col); c.px(x + 2, y - 3, col); c.px(x + 3, y - 2, col)
        if f < 0.2 {
            let dust = C(0xA89878, 0.8 * (1 - f / 0.2)), up = p.breathe + bob, spread = Int(f * 15)
            for (dx, dy) in [(-2, 0), (2, 0), (-3, -1), (3, -1)] { c.px(44 + dx + dx.signum() * spread, 43 + dy - up, dust) }
        }
    }
    let tap = beat.map { Int((1 - 3 * sin(.pi * $0)).rounded()) } ?? 0
    c.oy += tap
    defer { c.oy -= tap }
    // The staff, and a ghost of its skull behind a fast swing.
    let staff = p.melee ?? -80
    if p.melee != nil {
        for (i, a) in p.trail.enumerated() {
            let u = unit(a)
            drawSkull(c, at: (kingHand.x + u.x * 15, kingHand.y + u.y * 15), alpha: 0.3 / Double(i + 1))
        }
    }
    let u = unit(staff)
    line(c, kingHand.x - u.x * 8, kingHand.y - u.y * 8, kingHand.x + u.x * 13, kingHand.y + u.y * 13, C(0x6A4A2A), 0.6)
    let knot = (kingHand.x + u.x * 6, kingHand.y + u.y * 6)
    c.px(Int(knot.0), Int(knot.1), C(0x4A3220))
    drawSkull(c, at: (kingHand.x + u.x * 15, kingHand.y + u.y * 15))
    // The staff arm and fist.
    c.rect(40, 29, 4, 4, skin)
    c.rect(44, 31, 3, 3, skin); c.px(46, 33, skinShade)
}

/// The skull on the Goblin King's staff, centred on `at`: bone-white, two dark eye holes and a jaw of teeth.
private func drawSkull(_ c: PixelCanvas, at: (Double, Double), alpha: Double = 1) {
    let x = Int(at.0.rounded(.down)) - 2, y = Int(at.1.rounded(.down)) - 2
    c.pattern(x, y, [".BBB.", "BBBBB", "BKBKB", "BBBBB", ".BzB."],
              ["B": C(0xE8E0C4, alpha), "K": ink.alpha(alpha), "z": C(0xA89A78, alpha)])
}

// MARK: - The Mirkwood Web Crawler

/// Where the spider spits its webs from: its jaws, under the eyes.
private let spiderJaws: (x: Double, y: Double) = (45, 35)

/// A spider of Mirkwood, a little wider than a Man and nothing like Shellob's size: a raised, bristly dark-green abdomen
/// with yellow chevrons along its back, high on eight hairy legs banded green and yellow (the far four duller), a cluster
/// of eight glowing red eyes, and two hooked fangs under them that spread as it spits. A silk thread trails from its
/// spinnerets up into the trees, swaying. It spits webs. Signature: crawled, indexed, wrapped. In front of its jaws
/// sits a little dwarf (a red hood, a ginger beard); it spits silk over him and rolls him round under its front foot
/// (0.08…0.62), the silk thickening until he's a white bundle with only the beard sticking out, its eyes glint with
/// satisfaction (…0.78), and a thread from the trees whisks the bundle up and away, cached for later.
private func drawMirkwoodSpider(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x34462A), greenDark = C(0x1E2A16), greenLight = C(0x4E6436), band = C(0xD8B830)
    let far = C(0x2A3820), farBand = C(0x8A7A2A), hair = C(0x6A7A42)
    let eye = C(0xFF4A2A), eyeHot = C(0xFFC0A0)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 ? $0 : nil }
    let wrapping = sig.map { $0 > 0.1 && $0 < 0.62 } ?? false
    let holding: Double = sig.map { $0 < 0.06 ? 0 : $0 < 0.12 ? smooth(($0 - 0.06) / 0.06) : $0 < 0.7 ? 1 : 1 - smooth(($0 - 0.7) / 0.1) } ?? 0
    let spitting = (wrapping && Int((sig ?? 0) * 30) % 3 == 0) || (p.fire.map { frac($0.t / p.firePeriod) < 0.2 } ?? false)
    // The silk thread, from the spinnerets up and away behind it.
    let sway: Double = 1.5 * sin(p.lt * 1.1)
    for (a, b) in [((8.0, 30.0), (4.5 + sway * 0.4, 20.0)), ((4.5 + sway * 0.4, 20.0), (1.5 + sway, 6.0))] {
        c.glowLine(a.0, a.1 + Double(p.breathe), b.0, b.1, core: C(0xE8ECF0, 0.75), glow: clear, coreR: 0.35, glowR: 0.4)
    }
    typealias Leg = (a: (Double, Double), k: (Double, Double), t: (Double, Double))
    let nearLegs: [Leg] = [
        ((33, 32), (43, 23), (51, 43)), ((31, 32), (37, 21), (43, 43)), ((28, 33), (22, 21), (17, 43)), ((26, 33), (12, 23), (5, 43)),
    ]
    let farLegs: [Leg] = [
        ((33, 33), (41, 27), (47, 43)), ((31, 33), (34, 26), (37, 43)), ((28, 34), (25, 26), (23, 43)), ((26, 34), (17, 27), (11, 43)),
    ]
    func leg(_ l: Leg, _ i: Int, near: Bool) {
        let lifted = p.step >= 0 && (i + (near ? 0 : 1)) % 2 == p.step
        let knee = (l.k.0, l.k.1 - (lifted ? 1 : 0))
        var tip = (l.t.0 + (lifted ? 1 : 0), l.t.1 - (lifted ? 2 : 0))
        if near, i == 0, holding > 0 {                                              // the front foot on the bundle, rolling it
            let roll: Double = wrapping ? 1.5 * sin((sig ?? 0) * 40) : 0
            tip = (tip.0 + (53 + roll - tip.0) * holding, tip.1 + (37 - tip.1) * holding)
        }
        hairyLeg(c, l.a, knee, near ? green : far, near ? band : farBand, hair: near ? hair : nil, r: 1.1)
        hairyLeg(c, knee, tip, near ? green : far, near ? band : farBand, hair: near ? hair : nil, r: 0.8)
        c.px(Int(knee.0), Int(knee.1), near ? band : farBand)
    }
    for (i, l) in farLegs.enumerated() { leg(l, i, near: false) }
    c.oy += p.breathe
    // The abdomen, raised behind: shaded, yellow chevrons along its back, bristles round its edge.
    c.ellipse(18, 29, 10, 7, greenDark)
    c.ellipse(18, 28, 10, 7, green)
    c.ellipse(16, 25, 5, 2, greenLight)
    for x0 in [12, 17, 22] {
        for y in 22...33 {
            let x = x0 + Int((abs(Double(y - 27)) * 0.5).rounded())
            let dx = Double(x - 18) / 10, dy = Double(y - 28) / 7
            if dx * dx + dy * dy < 0.75 { c.rect(x, y, 2, 1, band) }
        }
    }
    for k in 0..<10 {
        let a: Double = 140 + Double(k) * 22, u = unit(a)
        c.px(Int((18 + u.x * 11).rounded()), Int((28 + u.y * 8).rounded()), hair)
    }
    // The front body; the near legs on it; the head over their roots.
    c.ellipse(31, 33, 6, 4, green)
    c.rect(27, 30, 8, 1, greenLight)
    c.oy -= p.breathe
    if let s = sig { drawWrappedDwarf(c, s) }
    for (i, l) in nearLegs.enumerated() { leg(l, i, near: true) }
    c.oy += p.breathe
    c.ellipse(39, 33, 4, 3, greenDark)
    c.ellipse(39, 32, 4, 3, green)
    // The fangs, spreading as it spits.
    let spread = spitting ? 1 : 0
    c.pattern(41, 35, ["F..F", "F..F", "T..T"], ["F": greenDark, "T": C(0xC8C0A8)])
    if spread == 1 { c.px(40, 37, C(0xC8C0A8)); c.px(45, 37, C(0xC8C0A8)) }
    // The eyes: eight, glowing red, two big ones in front.
    let flick: Double = 0.75 + 0.25 * sin(p.lt * 3.1)
    c.rect(40, 31, 2, 2, eye); c.rect(43, 31, 2, 2, eye)
    for (x, y) in [(38, 30), (40, 29), (42, 29), (44, 30), (39, 33), (42, 33)] { c.px(x, y, eye.alpha(0.9)) }
    c.px(40, 31, eyeHot.alpha(flick)); c.px(43, 31, eyeHot.alpha(flick))
    guard let s = sig else { return }
    // The signature: silk spat from the fangs over the bundle, and a glint of satisfaction in the eyes when it's done.
    if wrapping {
        let y = 39.5 + 1.5 * sin(s * 40)
        for x0 in [41.5, 44.5] { c.glowLine(x0, 37.5, 49.5, y, core: C(0xE8ECF0, 0.75), glow: clear, coreR: 0.3, glowR: 0.4) }
    }
    if s > 0.62, s < 0.8 {
        let k = (s - 0.62) / 0.18, star = white.alpha(1 - abs(2 * k - 1))
        c.px(40, 31, white); c.px(43, 31, white)
        for (dx, dy) in [(0, -1), (-1, 0), (1, 0), (0, 1), (0, 0)] { c.px(45 + dx, 30 + dy, star) }
    }
}

/// The little dwarf the Mirkwood spider wraps up `s` through its signature, in front of its jaws: let down on a thread
/// from the trees (…0.1), wrapped in more and more silk as it spins him (0.1…0.6) until only his beard sticks out of
/// the bundle, then hauled back up out of sight (0.8…0.98).
private func drawWrappedDwarf(_ c: PixelCanvas, _ s: Double) {
    let silk = C(0xE8ECF0), silkShade = C(0xB4BCC6)
    let wrap: Double = min(1, max(0, (s - 0.1) / 0.5))
    let away: Double = s < 0.1 ? pow(1 - s / 0.1, 2) : s < 0.8 ? 0 : pow(min(1, (s - 0.8) / 0.18), 2)
    let top = 34 - Int((away * 56).rounded())
    if away > 0 {                                                                  // the thread up into the trees
        c.glowLine(51.5, -2, 51.5, Double(top), core: C(0xE8ECF0, 0.8), glow: clear, coreR: 0.35, glowR: 0.4)
    }
    // The dwarf: a red hood, a big ginger beard down to his boots; wrapped, the beard still sticks out of the bundle
    // ("b": always beard, poking out below it).
    let dwarf: [Character: Px] = ["H": C(0xC02A24), "h": C(0x8A1C18), "F": C(0xF0C098), "E": C(0x2A2420),
                                  "B": C(0xE8862A), "b": C(0xB8601C), "T": C(0x5A4A3A), "K": C(0x2A2420)]
    let rows = [
        "..HHHH..",
        ".HHHHHH.",
        ".hFFFFh.",
        ".FEFFEF.",
        ".FBBBBF.",
        "TBBBBBBT",
        "TTBBBBTT",
        "TTBbBBTT",
        ".TBBbB..",
        "..KBBK..",
    ]
    let cocoon = [
        "..SSSS..",
        ".SSSSSS.",
        "SSSSSSSS",
        "SSSSSSSS",
        "SSSSSSSS",
        "SSSBBSSS",
        "SSSBBSSS",
        "SSSbBSSS",
        ".SSBbSS.",
        "..bBBb..",
    ]
    let spin = Int(s * 24)
    for (y, (row, wrapped)) in zip(rows, cocoon).enumerated() {
        for (x, (d, w)) in zip(row, wrapped).enumerated() {
            let covered = w == "S" && noise(x * 7 + y * 13 + 3) < wrap * 1.15
            let col: Px?
            if covered { col = (x + y + spin) % 3 == 0 ? silkShade : silk }
            else if wrap > 0.5, w == "B" || w == "b" { col = dwarf[w] } else if wrap > 0.5, w == "." { col = nil }
            else { col = dwarf[d] }
            if let col { c.px(47 + x, top + y, col) }
        }
    }
    // Wrapped tight: the bundle's silk banded round, the beard bristling out of the gap below.
    if wrap >= 1 {
        for y in [top + 2, top + 5, top + 8] { c.px(47 + (y % 2), y, silkShade); c.px(53 - (y % 2), y, silkShade) }
    }
}

/// A spider's leg segment: `col` with a yellow band every few pixels, and bristles sticking out to alternate sides.
private func hairyLeg(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ col: Px, _ bandCol: Px, hair: Px?,
                      r: Double) {
    line(c, a.0, a.1, b.0, b.1, col, r)
    let len = max(hypot(b.0 - a.0, b.1 - a.1), 0.01)
    let ux = (b.0 - a.0) / len, uy = (b.1 - a.1) / len
    for f in [0.35, 0.7] {                                                       // two bands across each segment
        let q = (a.0 + ux * len * f, a.1 + uy * len * f)
        line(c, q.0 - ux * 0.5, q.1 - uy * 0.5, q.0 + ux * 0.5, q.1 + uy * 0.5, bandCol, r)
    }
    guard let hair else { return }
    for f in [0.2, 0.55, 0.9] {                                                  // bristles, on the upper side
        let q = (a.0 + ux * len * f, a.1 + uy * len * f), s: Double = uy * ux >= 0 ? 1 : -1
        c.px(Int((q.0 + uy * s * (r + 1)).rounded(.down)), Int((q.1 - abs(ux) * (r + 1)).rounded(.down)), hair)
    }
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a light blade's. Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// A filled triangle.
private func fill(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double), _ col: Px) {
    func side(_ p: (Double, Double), _ q: (Double, Double), _ r: (Double, Double)) -> Double {
        (p.0 - r.0) * (q.1 - r.1) - (q.0 - r.0) * (p.1 - r.1)
    }
    for y in Int(min(a.1, b.1, d.1))...Int(max(a.1, b.1, d.1)) {
        for x in Int(min(a.0, b.0, d.0))...Int(max(a.0, b.0, d.0)) {
            let pt = (Double(x) + 0.5, Double(y) + 0.5)
            let s1 = side(pt, a, b), s2 = side(pt, b, d), s3 = side(pt, d, a)
            if (s1 >= 0 && s2 >= 0 && s3 >= 0) || (s1 <= 0 && s2 <= 0 && s3 <= 0) { c.px(x, y, col) }
        }
    }
}

/// Draws `pts` as a limb tapering from half-width `r0` at the root to `r1` at the tip, never through the floor.
private func taper(_ c: PixelCanvas, _ pts: [(x: Double, y: Double)], r0: Double, r1: Double, _ col: Px) {
    let floor = Double(43 - c.oy) + 0.5
    for i in 1..<pts.count {
        let a = pts[i - 1], b = pts[i], f = Double(i) / Double(pts.count - 1)
        line(c, a.x, min(a.y, floor), b.x, min(b.y, floor), col, r0 + (r1 - r0) * f)
    }
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}
