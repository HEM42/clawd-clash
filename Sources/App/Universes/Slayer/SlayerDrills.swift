import Foundation

// Clawd Slayer's own solo practice (`UniverseModule.drills`): Buffy kicking a punch bag that swings back at her, Willow
// floating a pencil off a stack of books ("emotional control"), Giles reading a dusty tome and then polishing his
// glasses, Xander hammering nails into a plank, Anya counting the takings at the Magic Box counter, the Potentials
// staking a training dummy and Lorn singing karaoke into a mic on a stand. Only the witches (Willow, Tara and Jenny,
// `slayerWitches`) float cross-legged in meditation (`Cast.meditates`).
//
// These are practice, not the signature moves again: Willow's pencil, Giles's glasses and Anya's money are also their
// signatures, so the drills set them up as work done over and over, with a prop of its own (the books, the tome, the
// counter and till).

let slayerBespokeDrills: [Cast: BespokeDrill] = [
    .hero(SlayerHero.buffyClawmers): drawPunchBag,
    .hero(SlayerHero.willowRosenclaw): drawPencilFloat,
    .hero(SlayerHero.rupertGyles): drawTomeAndGlasses,
    .hero(SlayerHero.xanderHarrows): drawNailing,
    .hero(SlayerHero.anyaJinkins): drawCountingTakings,
    .hero(SlayerHero.kennedie): { c, who, d, t in drawStakingDummy(c, who, d, t, sleeve: C(0x7A3058)) },
    .hero(SlayerHero.vy): { c, who, d, t in drawStakingDummy(c, who, d, t, sleeve: C(0xC89A3A)) },
    .hero(SlayerHero.rhona): { c, who, d, t in drawStakingDummy(c, who, d, t, sleeve: C(0x2A56C8)) },
    .hero(SlayerHero.lorn): drawKaraokeStand,
]

// MARK: - Shared bits

/// The breathing bob `drawPersona` gives the upper body right now (-1 or 0), so a prop held in the hand moves with it.
private func breath(_ who: Cast, _ t: Double) -> Int {
    sin((t + Double(who.id) * 0.77) * 2 * .pi / 2.6) > 0.35 ? -1 : 0
}

/// Wipe what's drawn in `columns` × `rows` (a weapon the drill swaps for something else).
private func wipe(_ c: PixelCanvas, columns: Range<Int>, rows: Range<Int>) {
    c.move(columns: columns, rows: rows, dy: c.h)
}

/// Eased 0…1.
private func ease(_ k: Double) -> Double {
    let u = max(0, min(1, k))
    return u * u * (3 - 2 * u)
}

// MARK: - Buffy Clawmers

/// Buffy kicking a heavy bag: it hangs from a bracket in front of her, she snaps a front kick into it (every third one
/// a high kick), it swings away on its chain and back, and she kicks it again as it comes back to her.
private func drawPunchBag(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let period = 1.5, f = frac(d.e / period), n = Int(floor(d.e / period))
    let kicking = r > 0.6
    standing(c, who, t: t)

    // The kick: the front leg chambers, snaps out to the bag at the top of the swing, and comes back down.
    let out: Double = !kicking ? 0 : f > 0.8 ? ease((f - 0.8) / 0.14) : f < 0.14 ? 1 - ease((f - 0.05) / 0.09) : 0
    let high = (f > 0.5 ? n + 1 : n) % 3 == 2
    if out > 0.05 {
        let leg = C(0x2E3550), legL = C(0x46507A), boot = C(0x1A1618)
        wipe(c, columns: 35..<37, rows: 38..<44)
        let hip = (x: 35.5, y: 38.5)
        let target = high ? (x: 44.5, y: 27.5) : (x: 44.5, y: 33.5)
        let foot = (x: hip.x + (target.x - hip.x) * out, y: hip.y + 4 * (1 - out) + (target.y - hip.y) * out)
        slayerLine(c, hip.x, hip.y, foot.x, foot.y, leg, 1.4)
        slayerLine(c, hip.x, hip.y - 1, foot.x, foot.y - 1, legL, 0.35)
        c.rect(Int(foot.x.rounded()) - 1, Int(foot.y.rounded()) - 1, 3, 3, boot)
    }

    // The bag, swinging on its chain from a bracket: away from her after a kick, a little way back past the middle.
    let swing = sin(2 * .pi * f)
    let amp = (n == 0 && f < 0.5 && d.e < 0.8) ? 0 : (high ? 13.0 : 10.0) * r
    let angle = (swing > 0 ? swing : 0.25 * swing) * amp * .pi / 180
    let pivot = (x: 49.5, y: 2.0)
    let red = C(0xA82C2C), redD = C(0x6E1A1C), redL = C(0xD0504A), strap = C(0x2A2226), chain = C(0x9AA0AA)
    c.rect(45, 1, 9, 1, C(0x5A5E66)); c.rect(48, 2, 3, 1, C(0x5A5E66))   // the bracket on the ceiling
    for y in 3...37 {
        let off = Int(((Double(y) - pivot.y) * tan(angle)).rounded())
        let x = Int(pivot.x) + off
        if y < 15 {
            c.px(x, y, y % 2 == 0 ? chain : C(0x6A707A))
        } else if y < 17 {
            c.rect(x - 2, y, 5, 1, strap)                                   // the straps over the top
        } else {
            let w = y < 19 || y > 35 ? 7 : 8, left = x - 3
            c.rect(left, y, w, 1, y > 35 ? strap : red)
            if y <= 35 {
                c.px(left, y, redL); c.px(left + w - 1, y, redD)
                if y == 26 || y == 27 { c.rect(left, y, w, 1, C(0xE8E4D8)) }   // a band of tape round the middle
            }
        }
    }
    // A puff where the kick lands.
    if kicking, f < 0.12 {
        let y = high ? 27 : 33, a = 1 - f / 0.12
        for (dx, dy) in [(1, -2), (2, 0), (1, 2)] { c.px(45 + dx, y + dy, C(0xFFF4D8, 0.9 * a)) }
    }
}

// MARK: - Willow Rosenclaw

/// Willow practising "emotional control" ("Doppelgangland"): a pencil on a stack of books in front of her, her hand
/// up, and it lifts, hovers wobbling, and settles back down; now and then her focus slips and it drops with a clatter.
private func drawPencilFloat(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let focusing = r > 0.3
    standing(c, who, t: t) { p in if focusing { p.armRaise = 3 } }

    // The books: a fat red one with a thinner green one on top.
    c.rect(45, 40, 13, 4, C(0x8A2A2A)); c.rect(45, 40, 13, 1, C(0xB04A40)); c.rect(46, 41, 11, 2, C(0xEEE6D0))
    c.rect(45, 41, 1, 2, C(0x8A2A2A))
    c.rect(47, 37, 10, 3, C(0x3A6A3A)); c.rect(47, 37, 10, 1, C(0x5A8A54)); c.rect(48, 38, 9, 1, C(0xEEE6D0))

    let period = 3.6, n = Int(floor(d.e / period)), f = frac(d.e / period)
    let slips = noise(d.seed &+ n * 17) < 0.35
    var lift: Double
    if !focusing || f < 0.12 { lift = 0 }
    else if f < 0.42 { lift = ease((f - 0.12) / 0.3) }
    else if slips && f > 0.62 { lift = max(0, 1 - (f - 0.62) / 0.05) }   // she loses it: straight down
    else if f < 0.8 { lift = 1 }
    else { lift = 1 - ease((f - 0.8) / 0.15) }
    let bounce = slips && f > 0.67 && f < 0.74 ? 1.0 : 0
    let aloft = lift > 0.05
    let cx = 51.5 + (aloft ? sin(t * 2.3) * 0.8 * lift : 0)
    let cy = 35.5 - lift * 9 + (aloft ? sin(t * 4.1) * 0.6 : 0) - bounce
    let tilt = aloft ? sin(t * 3.1) * 0.25 * lift : (bounce > 0 ? -0.3 : 0)
    let ux = cos(tilt), uy = sin(tilt)
    for k in -3...2 {
        let col = k == 2 ? C(0x2A2A2A) : k == 1 ? C(0xE8C8A0) : k == -3 ? C(0xE88AA0) : k == -2 ? C(0xB8BCC4) : C(0xF0C838)
        c.px(Int((cx + ux * Double(k)).rounded()), Int((cy + uy * Double(k)).rounded()), col)
    }
    guard aloft else { return }
    // A faint green glow round it, and motes drifting over to it from her raised hand.
    let glow = C(0x9CF0A0)
    for k in 0..<3 {
        let g = Double(k) * 2.1 + t * 2.5
        c.px(Int((cx + cos(g) * 5).rounded()), Int((cy + sin(g) * 2.5).rounded()), glow.alpha(0.35 + 0.3 * sin(t * 7 + Double(k))))
    }
    for k in 0..<2 {
        let u = frac(t * 0.9 + Double(k) * 0.5)
        let x = 41 + (cx - 41) * u, y = 29 + (cy - 29) * u - sin(u * .pi) * 3
        c.px(Int(x.rounded()), Int(y.rounded()), glow.alpha(0.6 * sin(u * .pi)))
    }
}

// MARK: - Rupert Gyles

private let gilesWire = C(0xD4D8E0)

/// Giles at his books: a fat, dusty tome held open in front of him, a page turned every second and a half with a puff
/// of dust, his glasses on; then he shuts it with a cloud of dust, puts it down at his feet, and takes the glasses off
/// to polish them before the next one.
private func drawTomeAndGlasses(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let e = d.e - 0.5
    guard e > 0, d.length - d.e > 0.5 else { standing(c, who, t: t); return }
    let cycle = 6.6, reading = 4.6
    let k = e.truncatingRemainder(dividingBy: cycle)
    let leather = C(0x5A3A22), leatherD = C(0x3A2414), leatherL = C(0x7A5232), gilt = C(0xC8A040)
    let dust = C(0xC8BCA4)

    if k > reading {
        // Polishing: the signature's own handkerchief round the lens, the tome down by his feet.
        let s = 0.1 + 0.78 * min(0.98, max(0.02, (k - reading) / (cycle - reading)))
        standing(c, who, t: t) { $0.signature = s }
        c.rect(46, 40, 11, 4, leather); c.rect(46, 40, 11, 1, leatherL); c.rect(46, 43, 11, 1, leatherD)
        c.rect(47, 41, 9, 2, C(0xE0D2B0)); c.rect(49, 40, 4, 1, gilt)
        if k - reading < 0.5 {   // the dust it kicked up, settling
            let a = 1 - (k - reading) / 0.5
            for i in 0..<5 { c.px(45 + i * 3, 38 - i % 2 - Int((1 - a) * 3), dust.alpha(0.6 * a)) }
        }
        return
    }
    // Reading: glasses on, the tome open in his raised hand (it hides the handkerchief the pose holds).
    standing(c, who, t: t) { $0.signature = 0.5 }
    let b = breath(who, t)
    c.oy = b
    let ring = [".GG.", "G..G", "G..G", "G..G", ".GG."]
    c.pattern(21, 28, ring, ["G": gilesWire]); c.pattern(31, 28, ring, ["G": gilesWire])
    c.rect(25, 29, 6, 1, gilesWire); c.px(19, 29, gilesWire); c.px(20, 29, gilesWire); c.px(35, 29, gilesWire)
    // The tome: closing at the end of the read, a page turning over every 1.5 s.
    let shut = k > reading - 0.3 ? ease((k - (reading - 0.3)) / 0.3) : 0
    let half = Int((7 * (1 - shut)).rounded())
    let spine = 47, top = 22, h = 10
    c.rect(spine - half - 1, top, half * 2 + 3, h, leather)
    c.rect(spine - half - 1, top + h - 1, half * 2 + 3, 1, leatherD)
    c.rect(spine, top, 1, h, leatherD)
    if half > 1 {
        let page = C(0xE8DCB8), line = C(0x9A8A6A)
        c.rect(spine - half, top + 1, half, h - 3, page); c.rect(spine + 1, top + 1, half, h - 3, page)
        for y in stride(from: top + 2, to: top + h - 2, by: 2) {
            c.rect(spine - half + 1, y, max(1, half - 2), 1, line); c.rect(spine + 2, y, max(1, half - 2), 1, line)
        }
        c.px(spine - half + 1, top + 2, C(0x8A2A2A))   // an illuminated capital
        let turn = frac(k / 1.5)
        if turn < 0.25 {
            let w = max(1, Int((Double(half) * (1 - turn / 0.25)).rounded()))
            c.rect(spine + 1, top, w, h - 2, page)
            for i in 0..<3 {   // dust off the old pages
                let u = turn / 0.25
                c.px(spine + 2 + i * 2, top - 1 - Int(u * 3) - i % 2, dust.alpha(0.7 * (1 - u)))
            }
        }
    } else {
        c.rect(spine - 1, top + 1, 3, 1, gilt)
    }
    c.rect(38, 30, 3, 3, clawdOrange)   // his hand round the bottom of it
    c.oy = 0
    if shut > 0.9 {
        for i in 0..<6 {
            let a = Double(i) / 6 * 2 * .pi
            c.px(spine + Int((cos(a) * 6).rounded()), top + 4 + b + Int((sin(a) * 4).rounded()), dust.alpha(0.6))
        }
    }
}

// MARK: - Xander Harrows

/// Xander's building-site years: a plank across two sawhorses, a claw hammer instead of his 2×4, four blows to drive
/// each nail flush, then a step along to the next one.
private func drawNailing(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let blow = 0.55, blows = 4, stepTime = 0.45
    let perNail = Double(blows) * blow + stepTime
    let u = d.e - 0.7
    let working = u > 0 && r > 0.3
    let nail = working ? min(3, Int(u / perNail)) : 0
    let w = working ? u - Double(nail) * perNail : 0
    let done = !working || nail == 3 && w > Double(blows) * blow
    var shift = Double(nail) * 3
    var height = 4, angle = -10.0, trail: [Double] = []
    if working, !done {
        let b = min(blows - 1, Int(w / blow)), bf = frac(w / blow)
        if w >= Double(blows) * blow {
            height = 0
            shift += 3 * ease((w - Double(blows) * blow) / stepTime)
            angle = -10
        } else {
            let struck = b + (bf >= 0.6 ? 1 : 0)
            height = max(0, 4 - struck)
            let before = -6.25 * Double(4 - b), now = -6.25 * Double(height)
            if bf < 0.4 { angle = before + (-80 - before) * ease(bf / 0.4) }
            else if bf < 0.53 { angle = -80 }
            else if bf < 0.6 {
                angle = -80 + (now + 80) * ((bf - 0.53) / 0.07)
                trail = [angle - 25, angle - 50]
            } else { angle = now }
        }
    } else if done, working {
        height = 0
    }

    standing(c, who, t: t)
    guard r > 0.3 else { drawSawhorsePlank(c, nails: 0, current: nil); return }
    // The 2×4 put away; his arm and the hammer instead.
    wipe(c, columns: 38..<43, rows: 32..<44)
    let b = breath(who, t)
    c.rect(38, 33 + b, 3, 3, C(0x2A8C9C)); c.px(39, 33 + b, C(0xE2503A))
    let hand = slayerHand
    slayerSmear(c, hand, trail, from: 4, to: 11, C(0xF4E8D0))
    slayerBar(c, hand, angle, from: -2, to: 8, C(0x6A4424), r: 0.9)
    slayerBar(c, hand, angle, from: -2, to: 7.5, C(0xA8743C), r: 0.5)
    let head = slayerReach(hand, angle, 9)
    let face = slayerReach(head, angle + 90, 2.5), claw = slayerReach(head, angle - 90, 2)
    slayerLine(c, claw.x, claw.y, face.x, face.y, C(0x6A707A), 1.1)
    slayerLine(c, head.x, head.y, face.x, face.y, C(0xB8BEC8), 0.5)
    c.rect(Int(hand.x.rounded()) - 1, Int(hand.y.rounded()) - 1, 3, 3, clawdOrange)
    c.shift(dx: Int(shift.rounded()), dy: 0)

    let finished = done ? 4 : nail + (height == 0 ? 1 : 0)
    drawSawhorsePlank(c, nails: finished, current: done || height == 0 ? nil : (50 + nail * 3, height))
    if working, !done, height < 4, frac(w / blow) >= 0.6, frac(w / blow) < 0.7, w < Double(blows) * blow {
        let x = 50 + nail * 3, y = 37 - height
        c.px(x - 2, y, C(0xFFF0A0)); c.px(x + 2, y - 1, C(0xFFF0A0)); c.px(x - 1, y - 2, C(0xFFFFFF, 0.8))
    }
}

/// The plank on its sawhorses, with `nails` driven flush along it and the `current` one (x, how far it still sticks up).
private func drawSawhorsePlank(_ c: PixelCanvas, nails: Int, current: (x: Int, h: Int)?) {
    let wood = C(0xC8A070), woodD = C(0x8E6A40), woodL = C(0xE0C090), horse = C(0x7A5A34)
    for x in [49, 63] {
        slayerLine(c, Double(x), 39.5, Double(x) - 2, 43.5, horse, 0.6)
        slayerLine(c, Double(x) + 1, 39.5, Double(x) + 3, 43.5, horse, 0.6)
    }
    c.rect(47, 38, 21, 2, wood); c.rect(47, 38, 21, 1, woodL); c.rect(47, 39, 21, 1, woodD); c.px(67, 38, woodD)
    for i in 0..<nails { c.px(50 + i * 3, 38, C(0x5A5E66)) }
    if let n = current {
        c.rect(n.x, 38 - n.h, 1, n.h, C(0x9AA0A8))
        c.rect(n.x - 1, 37 - n.h, 3, 1, C(0x6A707A))
    }
}

// MARK: - Anya Jinkins

/// Anya counting the takings at the Magic Box counter: notes dealt one at a time off the wad in her hand onto a pile,
/// and every eighth one the pile goes into the till's drawer, which springs open with a ding.
private func drawCountingTakings(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    standing(c, who, t: t)
    // The counter, with the till on it.
    let wood = C(0x7A4E2E), woodD = C(0x5A3620), woodL = C(0xA0703E)
    c.rect(46, 37, 22, 2, woodL); c.rect(46, 38, 22, 1, wood); c.rect(47, 39, 20, 5, wood)
    c.rect(47, 39, 20, 1, woodD); c.rect(56, 40, 1, 4, woodD)
    let till = C(0x4A5A4E), tillD = C(0x2E3A32), tillL = C(0x6E8070)
    c.rect(59, 29, 8, 8, till); c.rect(59, 29, 8, 1, tillL); c.rect(66, 29, 1, 8, tillD)
    c.rect(60, 27, 5, 2, tillD); c.rect(61, 27, 3, 1, C(0x8AE07A))          // the little display
    for y in [31, 33] { for x in [60, 62, 64] { c.px(x, y, C(0xE0DCD0)) } }  // keys
    guard r > 0.3 else { return }

    // The sword put away; her arm up, the wad in her hand.
    wipe(c, columns: 38..<43, rows: 33..<44)
    let b = breath(who, t)
    let note = C(0x8AC47A), noteD = C(0x4E8A44)
    c.rect(38, 31 + b, 3, 3, C(0xE88EAE))
    c.rect(41, 29 + b, 5, 3, note); c.rect(41, 31 + b, 5, 1, noteD); c.px(43, 30 + b, noteD)
    c.rect(40, 31 + b, 2, 2, clawdOrange)

    let deal = 0.6, batch = 8
    let count = max(0, Int((d.e - 0.8) / deal)), f = frac(max(0, d.e - 0.8) / deal)
    let k = count % batch
    let banking = k == batch - 1
    let onPile = banking ? (f < 0.5 ? batch - 1 : 0) : k
    let rows = (onPile + 1) / 2
    for i in 0..<rows {
        let y = 36 - i
        c.rect(48 + (i % 2), y, 6, 1, i % 2 == 0 ? note : C(0x9AD08A)); c.px(48 + (i % 2), y, noteD)
    }
    if banking {
        // The drawer springs open, the pile goes in, ding.
        let open = f < 0.5 ? ease(f / 0.2) : 1 - ease((f - 0.6) / 0.3)
        let out = Int((open * 4).rounded())
        c.rect(59 - out, 35, 8, 2, tillD); c.rect(59 - out, 35, out, 1, note)
        if f > 0.1, f < 0.5 {
            let a = 1 - (f - 0.1) / 0.4
            c.px(62, 25, C(0xFFF0A0, a)); c.px(60, 24, C(0xFFF0A0, 0.7 * a)); c.px(64, 24, C(0xFFF0A0, 0.7 * a))
        }
    } else if f < 0.4 {
        // A note flicked off the top of the wad, landing on the pile.
        let u = f / 0.4
        let x = 44 + (50 - 44) * u, y = 29 + Double(b) + (36 - Double(rows) - 29 - Double(b)) * u - sin(u * .pi) * 4
        c.rect(Int(x.rounded()) - 1, Int(y.rounded()), 4, 1, note)
        c.px(Int(x.rounded()) + 2, Int(y.rounded()), noteD)
    }
}

// MARK: - The Potentials

/// The Potentials staking a training dummy: a burlap dummy on a post with a red heart painted on it, a stake in the
/// fist (whatever they fight with otherwise), a lunge into the heart, straw puffing out as it rocks back, and back to
/// guard.
private func drawStakingDummy(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double, sleeve: Px) {
    let r = setRamp(d)
    let period = 1.3, f = frac(d.e / period)
    let lunging = r > 0.5
    var angle = 35.0, lunge = 0.0
    if lunging {
        if f < 0.3 { angle = 35 - 50 * ease(f / 0.3); lunge = -1 * ease(f / 0.3) }
        else if f < 0.4 { let k = (f - 0.3) / 0.1; angle = -15 + 20 * k; lunge = -1 + 4 * k }
        else if f < 0.6 { angle = 5; lunge = 3 }
        else { let k = ease((f - 0.6) / 0.4); angle = 5 + 30 * k; lunge = 3 * (1 - k) }
    }
    // The rock of the dummy after each hit.
    let since = f - 0.4
    let tilt = lunging && since > 0 ? 0.09 * sin(since * 14) * exp(-since * 4) : 0
    drawTrainingDummy(c, tilt: tilt, hit: lunging && since > 0 && since < 0.2 ? since / 0.2 : nil)

    let body = PixelCanvas(c.w, c.h)
    standing(body, who, t: t)
    guard r > 0.2 else { c.paste(body); return }
    wipe(body, columns: 38..<45, rows: 14..<44)
    let b = Double(breath(who, t))
    body.rect(38, 33 + Int(b), 3, 3, sleeve)
    slayerStake(body, angle: angle, trail: [], from: (slayerHand.x, slayerHand.y + b))
    if lunging, f > 0.3, f < 0.42 {
        for y in [32, 37] { body.rect(30, y, 5, 1, C(0xF4E8D0, 0.35)) }   // speed lines
    }
    c.paste(body, x: Int(lunge.rounded()))
}

/// The dummy: a burlap sack on a post, crossbar arms with straw sticking out, a stitched face and a red heart to aim
/// at; leaning back by `tilt` (per row, from the base), straw puffing out while `hit` runs 0…1.
private func drawTrainingDummy(_ c: PixelCanvas, tilt: Double, hit: Double?) {
    let sack = C(0xC4A26A), sackD = C(0x9A7A48), sackL = C(0xDCC08A), post = C(0x6A4A2A), straw = C(0xE8D068)
    let heart = C(0xC8202A), stitch = C(0x4A3420)
    let lean = { (y: Int) in Int((Double(43 - y) * tilt).rounded()) }
    c.rect(54, 42, 9, 2, post); c.rect(54, 42, 9, 1, C(0x8A6A40))
    for y in 30...41 { c.rect(58 + lean(y), y, 2, 1, post) }
    for y in 24...36 {
        let x = 53 + lean(y)
        c.rect(x, y, 10, 1, sack); c.px(x, y, sackL); c.px(x + 9, y, sackD)
    }
    c.rect(53 + lean(31), 31, 10, 1, C(0x8A6A40))   // the rope round its middle
    for y in 26...27 { c.rect(51 + lean(y), y, 14, 1, post) }
    c.px(50 + lean(26), 26, straw); c.px(50 + lean(27), 27, straw); c.px(65 + lean(26), 26, straw); c.px(65 + lean(27), 27, straw)
    for y in 17...23 {
        let x = 55 + lean(y), w = y == 17 || y == 23 ? 5 : 7
        c.rect(x + (7 - w) / 2, y, w, 1, sack); c.px(x + (7 - w) / 2, y, sackL)
    }
    c.px(57 + lean(16), 16, straw); c.px(59 + lean(15), 15, straw); c.px(60 + lean(16), 16, straw)
    for (x, y) in [(56, 19), (57, 20), (56, 21), (58, 19), (58, 21)] where !(x == 58 && y == 20) { c.px(x + lean(y), y, stitch) }
    c.pattern(53 + lean(33), 32, ["XX.XX", "XXXXX", ".XXX.", "..X.."], ["X": heart])
    if let h = hit {
        for i in 0..<5 {
            let a = -2.6 + Double(i) * 0.45
            let rr = 2 + h * 6
            c.px(Int(54 + cos(a) * rr), Int(34 + sin(a) * rr), straw.alpha(1 - h))
        }
    }
}

// MARK: - Lorn

/// Lorn rehearsing at Caritas: a mic on a stand in front of him, his hand on it, a little monitor on the floor
/// scrolling the lyrics with the words lighting up as he goes, a bounce on every beat and a note floating up off each.
private func drawKaraokeStand(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let singing = r > 0.4
    let beat = 0.6, bf = frac(d.e / beat), nb = Int(floor(d.e / beat))
    standing(c, who, t: t)
    if singing, bf < 0.25 { c.shift(dx: 0, dy: -1) }

    // The mic stand: a tripod base, the pole, a short boom up to the mic by his mouth.
    let steel = C(0x8A8F9C), steelD = C(0x4A4E58), mic = C(0x5A5E68), grille = C(0xC8CCD4)
    c.rect(46, 30, 1, 13, steel); c.rect(47, 30, 1, 13, steelD)
    slayerLine(c, 46.5, 42.5, 43.5, 43.5, steelD, 0.5); slayerLine(c, 46.5, 42.5, 49.5, 43.5, steelD, 0.5)
    slayerLine(c, 46.5, 30.5, 42.5, 28.5, steel, 0.5)
    c.pattern(39, 25, [".MM.", "MSSM", "MMMM", ".MM."], ["M": mic, "S": grille])
    let b = breath(who, t) + (singing && bf < 0.25 ? -1 : 0)
    c.rect(41, 33 + b, 4, 2, C(0xC2369E)); c.rect(44, 33 + b, 3, 3, C(0x62B45A))   // his hand on the pole

    // The monitor, the lines of the song on it.
    let box = C(0x22222A), boxL = C(0x3A3A46), screen = C(0x1A2A5A)
    c.rect(52, 35, 15, 9, box); c.rect(52, 35, 15, 1, boxL)
    c.rect(54, 37, 11, 5, screen)
    guard r > 0.2 else { return }
    let line = nb / 6, word = nb % 6
    for row in 0..<2 {
        let y = 38 + row * 2
        for i in 0..<5 where noise((line + row) * 11 + i) > 0.2 {
            let lit = row == 0 && singing && i * 6 / 5 <= word
            c.rect(55 + i * 2, y, 1, 1, lit ? C(0xFF6AC8) : C(0xE0E4F0))
        }
    }
    if singing, bf > 0.3 { c.px(55 + min(4, word * 5 / 6) * 2, 37, C(0xFFD84A)) }   // the bouncing ball
    guard singing else { return }
    // A note off the mic on every beat, floating up and away.
    let cols = [C(0xFF6AC8), C(0xFFD84A), C(0x6AE0FF)]
    for k in 0..<3 {
        let age = (Double(k) + bf) * beat
        let n = nb - k
        guard n >= 0 else { continue }
        let u = age / (3 * beat)
        let x = 43 + Int(u * 9 + sin(u * 7 + Double(n)) * 1.5), y = 23 - Int(u * 17)
        let a = u < 0.7 ? 1 : max(0, 1 - (u - 0.7) / 0.3)
        let col = cols[n % 3].alpha(a < 1 ? a * 0.2 : 1)
        c.pattern(x, y, [".X", ".X", "XX"], ["X": col])
    }
}
