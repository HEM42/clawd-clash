import Foundation

// Stranger Clawds' own solo practice (`UniverseModule.drills`): Eleven crushing a soda can with her mind, as Hopper
// has her practise at the cabin; the Party rolling a big d20 across the floor, the way every campaign in the basement
// starts; and Steve taking practice swings with his nail bat at a stack of tin cans on a crate. Nobody floats
// cross-legged in meditation here (`Meditation(who: .never)`): Eleven's powers aren't a trance.

let hawkinsBespokeDrills: [Cast: BespokeDrill] = [
    .hero(HawkinsHero.eleven): drawCanCrush,
    .hero(HawkinsHero.mikeWheeler): drawD20,
    .hero(HawkinsHero.dustinHenderson): drawD20,
    .hero(HawkinsHero.lucasSinclawd): drawD20,
    .hero(HawkinsHero.willByers): drawD20,
    .hero(HawkinsHero.ericaSinclair): drawD20,
    .hero(HawkinsHero.steveHarringclawd): drawBatPractice,
]

/// Eased 0…1.
private func ease(_ k: Double) -> Double {
    let u = max(0, min(1, k))
    return u * u * (3 - 2 * u)
}

// MARK: - Eleven

/// Eleven at the cabin: a red soda can on the floor in front of her, her hand up, pale red waves rolling out of it,
/// and the can crumples in on itself, shaking, until it's a crushed little lump; a moment, then a fresh one.
private func drawCanCrush(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let period = 3.4, f = frac(d.e / period)
    let focusing = r > 0.4 && f > 0.08 && f < 0.82
    standing(c, who, t: t) { p in if focusing { p.armRaise = 4 } }
    guard r > 0.15 else { return }

    // How far crushed: in over the middle of the go, a shake while it gives.
    let crush = r > 0.4 ? ease((f - 0.3) / 0.3) : 0
    let gone = f > 0.9 ? (f - 0.9) / 0.1 : 0
    let shake = crush > 0 && crush < 1 ? (Int(t * 30) % 2 == 0 ? 1 : -1) : 0
    let h = Int((9 - 5 * crush).rounded()), w = crush > 0.6 ? 7 : 6
    let x0 = 51 + shake - (w - 6), top = 44 - h
    let a = 1 - gone
    let red = C(0xC8282E, a), redL = C(0xE85A50, a), redD = C(0x8A1A1E, a), tin = C(0xC8CCD4, a), band = C(0xF0EEE8, a)
    c.rect(x0, top, w, h, red)
    c.rect(x0, top, 1, h, redL); c.rect(x0 + w - 1, top, 1, h, redD)
    c.rect(x0, top, w, 1, tin)                                  // the top, its ring pull
    if crush < 0.5 { c.px(x0 + 3, top, C(0x8A8E98, a)) }
    c.rect(x0 + 1, top + h / 2, w - 2, 1, band)                 // a white band round it
    c.rect(x0, 43, w, 1, tin)
    if crush > 0.15 {                                           // the dents, more as it goes
        for i in 0..<Int(crush * 6) {
            c.px(x0 + 1 + Int(noise(i * 7 + 3) * Double(w - 2)), top + 1 + Int(noise(i * 11) * Double(max(1, h - 2))), redD)
        }
    }

    // Her waves: pale red rings rolling out of her raised hand to the can.
    guard focusing, f > 0.14, f < 0.66 else { return }
    let m = who.persona.magic
    for i in 0..<3 {
        let u = frac(t * 1.8 + Double(i) / 3)
        let x = 42 + u * 8, rr = 2 + u * 3
        for k in -3...3 {
            let ang = Double(k) / 3 * 1.1
            c.px(Int((x + cos(ang) * rr * 0.5).rounded()), Int((31 + sin(ang) * rr).rounded()), m.glow.alpha(0.55 * (1 - u)))
        }
    }
}

// MARK: - The Party's d20

/// The digits on the die's face, 3 dots by 5 (`hawkinsSoftText`'s glyph strings, row by row).
private let hawkinsDigits: [Character: String] = [
    "0": "111101101101111", "1": "010110010010111", "2": "111001111100111", "3": "111001111001111",
    "4": "101101111001001", "5": "111100111001111", "6": "111100111101111", "7": "111001010010010",
    "8": "111101111101111", "9": "111101111001111",
]

/// One of the Party with a big red d20: shaken in the hand, thrown, tumbling across the floor, bouncing, and settling
/// on a number, a natural 20 about one roll in five, with a little jump for joy and a sparkle; then picked up again.
private func drawD20(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let period = 3.8, f = frac(d.e / period), n = Int(floor(d.e / period))
    let roll = noise(d.seed &+ n * 31) < 0.2 ? 20 : 1 + Int(noise(d.seed &+ n * 17 + 5) * 19)
    let resting = f > 0.6 && f < 0.95
    let nat20 = roll == 20 && resting && r > 0.3
    let body = PixelCanvas(c.w, c.h)
    standing(body, who, t: t)
    c.paste(body, x: 0, y: nat20 && frac((f - 0.6) / 0.12) < 0.5 && f < 0.84 ? -1 : 0)
    guard r > 0.3, f < 0.95 else { return }

    var x: Double, y: Double, spin: Double
    if f < 0.15 {                                                // shaken in the hand
        x = 42; y = 30 + sin(t * 30) * 0.6; spin = t * 9
    } else if f < 0.6 {                                          // thrown: up, down, two bounces, rolling to a stop
        let u = (f - 0.15) / 0.45
        x = 42 + 16 * (1 - pow(1 - u, 2))
        let hops = [(0.0, 0.35, 8.0), (0.35, 0.7, 3.0), (0.7, 0.9, 1.0)]
        y = 38
        for (a, b, hgt) in hops where u >= a && u < b {
            let k = (u - a) / (b - a)
            y = 38 - hgt * 4 * k * (1 - k) - (a == 0 ? 8 * (1 - k) : 0)
        }
        spin = u < 0.9 ? u * 14 : 12.6
    } else {
        x = 58; y = 38; spin = 0
    }
    hawkinsDrawD20(c, cx: Int(x.rounded()), cy: Int(y.rounded()), spin: spin, number: resting ? roll : nil)
    if nat20 {
        // A sparkle off it.
        let s = frac(t * 2)
        for (dx, dy) in [(-7, -5), (7, -6), (0, -9)] {
            let k = frac(s + Double(dx) * 0.1)
            c.px(58 + dx, 38 + dy, C(0xFFF4B0, 1 - k)); c.px(58 + dx - 1, 38 + dy, C(0xFFF4B0, 0.5 * (1 - k)))
            c.px(58 + dx + 1, 38 + dy, C(0xFFF4B0, 0.5 * (1 - k)))
        }
    }
}

/// A big red d20, about eleven pixels across, centred on (`cx`, `cy`): its outline a hexagon turned by `spin`, the
/// facets lit top left and shaded bottom right, the triangle of its front face drawn in; the `number` on that face in
/// white once it's settled.
func hawkinsDrawD20(_ c: PixelCanvas, cx: Int, cy: Int, spin: Double, number: Int?) {
    let red = C(0xB8202A), redL = C(0xE0505A), redD = C(0x761018), edge = C(0x3A0A10)
    let rad = 5.6
    let corners = (0..<6).map { i -> (x: Double, y: Double) in
        let a = spin + Double(i) * .pi / 3 - .pi / 2
        return (Double(cx) + 0.5 + cos(a) * rad, Double(cy) + 0.5 + sin(a) * rad)
    }
    func inside(_ x: Double, _ y: Double) -> Bool {
        for i in 0..<6 {
            let a = corners[i], b = corners[(i + 1) % 6]
            if (b.x - a.x) * (y - a.y) - (b.y - a.y) * (x - a.x) < 0 { return false }
        }
        return true
    }
    for y in (cy - 7)...(cy + 7) {
        for x in (cx - 7)...(cx + 7) {
            let px = Double(x) + 0.5, py = Double(y) + 0.5
            guard inside(px, py) else { continue }
            let lx = px - Double(cx) - 0.5, ly = py - Double(cy) - 0.5
            c.px(x, y, lx + ly < -4 ? redL : lx + ly > 4 ? redD : red)
        }
    }
    for i in 0..<6 {
        let a = corners[i], b = corners[(i + 1) % 6]
        c.glowLine(a.x, a.y, b.x, b.y, core: edge, glow: C(0, 0), coreR: 0.45, glowR: 0.5)
    }
    // The front face: a triangle across the middle, its edges catching the light.
    let tri = [0, 2, 4].map { corners[$0] }
    for i in 0..<3 {
        let a = tri[i], b = tri[(i + 1) % 3]
        let mx = Double(cx) + 0.5, my = Double(cy) + 0.5
        c.glowLine(mx + (a.x - mx) * 0.62, my + (a.y - my) * 0.62, mx + (b.x - mx) * 0.62, my + (b.y - my) * 0.62,
                   core: redD, glow: C(0, 0), coreR: 0.35, glowR: 0.4)
    }
    guard let n = number else { return }
    let s = String(n)
    let w = s.count * 4 - 1
    var x0 = cx - w / 2
    for ch in s {
        let bits = Array(hawkinsDigits[ch] ?? "")
        for i in 0..<15 where bits.count == 15 && bits[i] == "1" { c.px(x0 + i % 3, cy - 2 + i / 3, C(0xFFF8F0)) }
        x0 += 4
    }
}

// MARK: - Steve Harringclawd

/// Steve's batting practice: a pyramid of three tin cans on a crate in front of him, the bat wound back over his
/// shoulder, a fast level swing that knocks the top can flying off out of sight, the follow-through, and a fresh can on
/// top for the next swing.
private func drawBatPractice(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let period = 2.6, f = frac(d.e / period)
    var angle = 48.0, trail: [Double] = []
    let swinging = r > 0.5
    if swinging {
        if f < 0.4 { angle = 48 + (-150 - 48) * ease(f / 0.4) }                     // wound back
        else if f < 0.47 { angle = -150 }
        else if f < 0.55 {                                                           // the swing, fast and level
            let k = (f - 0.47) / 0.08
            angle = -150 + 175 * k
            trail = [angle - 30, angle - 60, angle - 90]
        } else { angle = 25 + 23 * ease((f - 0.55) / 0.35) }                         // follow-through, and back down
    }
    standing(c, who, t: t) { p in p.melee = angle; p.trail = trail }
    guard r > 0.15 else { return }

    // The crate.
    let wood = C(0x9A6A3A), woodD = C(0x6A4424), woodL = C(0xC08A50)
    c.rect(50, 39, 12, 5, wood); c.rect(50, 39, 12, 1, woodL); c.rect(50, 43, 12, 1, woodD)
    c.rect(55, 40, 1, 3, woodD); c.px(51, 41, woodD); c.px(60, 41, woodD)
    // The cans: two on the crate, one on top of them, unless it's just been knocked off (and flying away).
    func can(_ x: Int, _ y: Int, _ a: Double = 1) {
        c.rect(x, y, 3, 4, C(0xB8BCC4, a)); c.px(x, y, C(0xE4E6EA, a)); c.rect(x + 2, y, 1, 4, C(0x7A7E88, a))
        c.rect(x, y + 1, 3, 1, C(0x3A7A4A, a))   // the label's stripe
    }
    can(52, 35); can(56, 35)
    let hit = swinging && f >= 0.52 && f < 0.92
    if !hit {
        can(54, 31, swinging && f >= 0.92 ? (f - 0.92) / 0.08 : 1)
    } else {
        let u = (f - 0.52) / 0.4
        let x = 54 + u * 24, y = 31 - 12 * sin(u * .pi * 0.8) + u * 4
        can(Int(x.rounded()), Int(y.rounded()))
        if u < 0.15 { c.px(56, 30, C(0xFFF4B0)); c.px(58, 32, C(0xFFF4B0)); c.px(57, 29, C(0xFFFFFF, 0.8)) }   // the clang
    }
}
