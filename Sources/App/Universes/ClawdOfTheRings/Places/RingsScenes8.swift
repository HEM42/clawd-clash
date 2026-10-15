import Foundation

// The Lonely Mount-point, Data Lake-town and the Green Dragon-and-Drop.
let ringsScenes8: [Location: Place] = [
    .erebor: Place(name: "The Lonely Mount-point", panel: 0x1E180E, still: Scenes.erebor),
    .laketown: Place(name: "Data Lake-town", panel: 0x141A20, still: Scenes.laketown),
    .greenDragon: Place(name: "The Green Dragon-and-Drop", panel: 0x1C2410, still: Scenes.greenDragon),
]

// MARK: - Shared bits for these scenes

/// String art drawn with every character `s` pixels square.
private func r8Stamp(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], _ pal: [Character: Px], s: Int) {
    for (r, row) in rows.enumerated() {
        for (k, ch) in row.enumerated() { if let col = pal[ch] { c.rect(x + k * s, y + r * s, s, s, col) } }
    }
}

/// A straight line of `s`-pixel dots.
private func r8Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// `v` clamped into 0...1.
private func r8Clamp(_ v: Double) -> Double { max(0, min(1, v)) }

/// A four-pointed glint: a bright middle and short arms `arm` pixels long.
private func r8Glint(_ c: PixelCanvas, _ x: Int, _ y: Int, arm: Int, s: Int, core: Px, ray: Px) {
    c.rect(x - arm, y, arm * 2 + s, s, ray)
    c.rect(x, y - arm, s, arm * 2 + s, ray)
    c.rect(x, y, s, s, core)
}

/// A lantern on a short hook: amber glass in an iron frame, with a soft glow round it.
private func r8Lantern(_ c: PixelCanvas, _ x: Int, _ y: Int, s: Int, glow: Double = 0.12) {
    let iron = C(0x1E1A16)
    c.circle(x, y, 8 * s, C(0xFFC060, glow * 0.6))
    c.circle(x, y, 4 * s, C(0xFFC060, glow))
    c.rect(x - s, y - s, 3 * s, 3 * s, C(0xF6C258))
    c.rect(x - 2 * s, y - 2 * s, 5 * s, s, iron); c.rect(x - 2 * s, y + 2 * s, 5 * s, s, iron)
    c.rect(x, y - 3 * s, s, s, iron)
}

// MARK: - The Lonely Mount-point

extension Scenes {
    /// How high the hoard is heaped in the middle: well up the strip, and half the hall on tall screens.
    static func ereborPeak(_ c: PixelCanvas, _ g: Int) -> Int {
        isTall(c) ? Int(Double(g) * 0.5) : min(32 * unit(g), g * 3 / 5)
    }

    /// The top of the hoard at column `x`: a drift of gold right across the hall and mounds heaped on it, the highest
    /// in the middle. Coins make its edge a little lumpy.
    static func ereborHoardTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let s = unit(g), peak = Double(ereborPeak(c, g)), w = Double(max(1, c.w))
        // each mound's middle and half-width (shares of the width) and height (share of the peak)
        let mounds: [(Double, Double, Double)] = [(0.5, 0.3, 1), (0.2, 0.2, 0.6), (0.8, 0.22, 0.66), (0.36, 0.1, 0.62),
                                                   (0.64, 0.12, 0.58), (0.02, 0.14, 0.42), (0.98, 0.12, 0.38)]
        var h = Double(min(7 * s, g / 6))
        for m in mounds {
            let u = (Double(x) - w * m.0) / max(1, w * m.1)
            let a: Double = u * Double.pi
            if abs(u) < 1 { h = max(h, peak * m.2 * (0.5 + 0.5 * cos(a))) }
        }
        return g - Int(h) + Int(noise(x / (2 * s) + 900) * 1.6) * s
    }

    /// The great pillars: their left edges and width, evenly spaced either side of the middle (none behind the peak).
    static func ereborPillars(_ c: PixelCanvas, _ g: Int) -> (xs: [Int], w: Int, pitch: Int) {
        let s = unit(g), tall = isTall(c)
        let w = (tall ? 30 : 22) * s, pitch = (tall ? 120 : 100) * s
        let n = c.w / pitch / 2 + 2
        var xs: [Int] = []
        for k in -n..<n { xs.append(c.w / 2 + k * pitch + pitch / 2 - w / 2) }
        return (xs, w, pitch)
    }

    /// The row the pillars' capitals sit on, on tall screens.
    static func ereborCapital(_ c: PixelCanvas, _ g: Int) -> Int { Int(Double(g) * 0.18) }

    /// The colour of `p` at row `y` in the hall: lost in the dark high up, warmed by the gold's glow low down.
    static func ereborTone(_ c: PixelCanvas, _ g: Int, _ p: Px, _ y: Int) -> Px {
        let tall = isTall(c)
        let y0: Double = tall ? Double(g) * 0.0 : -Double(g) * 0.6
        let y1: Double = tall ? Double(g) * 0.6 : Double(g) * 0.7
        let k = (r8Clamp((Double(y) - y0) / (y1 - y0)) * 8).rounded(.down) / 8
        let lo: Double = Double(g) * (tall ? 0.35 : 0.2)
        let warm = (r8Clamp((Double(y) - lo) / max(1, Double(g) - lo)) * 6).rounded(.down) / 6 * 0.45
        return lerp(lerp(C(0x090C0B), p, 0.12 + 0.88 * k), C(0xB8862E), warm)
    }

    /// The Lonely Mount-point: Erebor's treasure hall. Massive square pillars of the dwarves' green stone, carved with
    /// stacked chevrons and banded with stepped patterns, stand before a far wall of huge blocks, and in front of it
    /// all lies Smaug's hoard: mountains of gold coin with cups, gems, a shield and a crown in it, glinting, its warm
    /// glow lighting the hall from below. The crew stands on the flagged floor in front of the gold. On tall screens
    /// the hall soars up into the dark: stepped capitals and pointed dwarf arches, two carved dwarf kings standing
    /// guard with their hammers, and high up on the heap the Arkenstone, gleaming white.
    static func erebor(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        // the far wall: huge blocks, fading into the dark
        for y in 0..<g { c.rect(0, y, c.w, 1, ereborTone(c, g, C(0x22302A), y)) }
        let course = (tall ? 16 : 11) * s
        for (row, y) in stride(from: g - course, to: -course, by: -course).enumerated() {
            let joint = ereborTone(c, g, C(0x151E1A), y)
            c.rect(0, y, c.w, s, joint)
            for x in stride(from: (row % 2) * course, to: c.w, by: course * 2) { c.rect(x, y, s, course, joint) }
        }
        if tall { ereborVaults(c, g) }
        let p = ereborPillars(c, g)
        for x in p.xs { ereborPillar(c, g, x, p.w) }
        // the dwarf kings, in the bays either side of the middle, when there's height for them
        let feet = Int(Double(g) * 0.62)
        if tall, feet - 104 * s >= g / 10 {
            for side in [-1, 1] { ereborStatue(c, g, c.w / 2 + side * p.pitch, feet) }
        }
        ereborHoard(c, g)
        // the flagged floor, the gold's glow on it and a few coins spilled across it
        let rows = c.h - g
        c.ground(g, C(0x2A3630), edge: C(0x8A7440), speck: C(0x222C27), seed: 81)
        c.rect(0, g + s, c.w, s, C(0xFFB040, 0.10))
        if rows > 5 * s {
            c.rect(0, g + rows / 2, c.w, s, C(0x1C2620))
            for (k, x) in stride(from: 0, to: c.w, by: 34 * s).enumerated() {
                c.rect(x + (k % 2) * 11 * s, g + 2 * s, s, rows / 2 - 2 * s, C(0x1C2620))
            }
        }
        for i in 0..<(c.w / (11 * s)) {
            let x = Int(noise(i * 3 + 960) * Double(c.w))
            let y = g + s + Int(noise(i * 3 + 961) * Double(max(1, min(rows - s, 4 * s))))
            c.rect(x, y, 2 * s, s, noise(i * 3 + 962) > 0.3 ? C(0xE0AE40) : C(0xFCE07A))
        }
    }

    /// Tall screens: pointed dwarf arches of straight stone springing from capital to capital, lost in the dark.
    static func ereborVaults(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), p = ereborPillars(c, g), spring = ereborCapital(c, g) - 9 * s
        for (a, b) in zip(p.xs, p.xs.dropFirst()) {
            let x0 = a + p.w + 4 * s, x1 = b - 4 * s, mid = (x0 + x1) / 2, rise = (x1 - x0) * 2 / 3
            for k in 0..<6 {
                let col = ereborTone(c, g, k == 5 ? C(0x5A8A6E) : C(0x2E4A3C), spring - rise / 2)
                r8Line(c, x0, spring - k * s, mid, spring - rise - k * s, col, s: s)
                r8Line(c, mid, spring - rise - k * s, x1, spring - k * s, col, s: s)
            }
            // a carved keystone at the point
            c.rect(mid - 3 * s, spring - rise - 8 * s, 7 * s, 6 * s, ereborTone(c, g, C(0x3A5E4C), spring - rise))
            c.rect(mid - s, spring - rise - 6 * s, 3 * s, 2 * s, ereborTone(c, g, C(0x1E3428), spring - rise))
        }
    }

    /// One great pillar of green stone, square-edged, a sunk panel of chevrons running up its face and carved bands
    /// across it. It fades into the dark above and catches the gold's glow below. On tall screens it has a stepped
    /// capital.
    static func ereborPillar(_ c: PixelCanvas, _ g: Int, _ x: Int, _ w: Int) {
        let s = unit(g), tall = isTall(c)
        let body = C(0x3A5E4C), lit = C(0x5A8A6E), shade = C(0x26402F), groove = C(0x1A2E24)
        let top = tall ? ereborCapital(c, g) : 0
        let px0 = x + 6 * s, px1 = x + w - 7 * s
        for y in top..<max(top, g) {
            c.rect(x, y, w, 1, ereborTone(c, g, body, y))
            c.rect(x, y, 2 * s, 1, ereborTone(c, g, lit, y))
            c.rect(x + w - 4 * s, y, 4 * s, 1, ereborTone(c, g, shade, y))
            if px1 > px0 + 2 * s {
                c.rect(px0, y, s, 1, ereborTone(c, g, groove, y))
                c.rect(px1, y, s, 1, ereborTone(c, g, lit, y))
                c.rect(px0 + s, y, px1 - px0 - s, 1, ereborTone(c, g, C(0x31503F), y))
            }
        }
        // the chevrons stacked up the panel
        let mid = (px0 + px1) / 2, half = (px1 - px0) / 2
        if half > 2 * s {
            for cy in stride(from: g - 3 * s, to: top + half, by: -(half + 3 * s)) {
                let col = ereborTone(c, g, groove, cy)
                r8Line(c, px0 + s, cy, mid, cy - half + s, col, s: s)
                r8Line(c, mid, cy - half + s, px1 - s, cy, col, s: s)
            }
        }
        // the carved bands
        for by in stride(from: g - (tall ? 40 : 30) * s, to: top + 8 * s, by: -(tall ? 56 : 40) * s) {
            c.rect(x - s, by, w + 2 * s, 5 * s, ereborTone(c, g, body, by))
            c.rect(x - s, by, w + 2 * s, s, ereborTone(c, g, lit, by))
            c.rect(x - s, by + 4 * s, w + 2 * s, s, ereborTone(c, g, shade, by))
            for dx in stride(from: s, to: w, by: 4 * s) {
                c.rect(x + dx, by + 2 * s, 2 * s, s, ereborTone(c, g, groove, by))
                c.rect(x + dx + s, by + s, s, s, ereborTone(c, g, groove, by))
            }
        }
        // the stepped capital
        if tall {
            for (k, grow) in [1, 3, 5].enumerated() {
                let y = top - (k + 1) * 3 * s
                c.rect(x - grow * s, y, w + 2 * grow * s, 3 * s, ereborTone(c, g, body, y))
                c.rect(x - grow * s, y, w + 2 * grow * s, s, ereborTone(c, g, lit, y))
                c.rect(x + w + (grow - 2) * s, y, 2 * s, 3 * s, ereborTone(c, g, shade, y))
            }
        }
    }

    /// A carved dwarf king as tall as a house, standing guard on his pedestal with both hands on the haft of the war
    /// hammer at his feet: helm with its nose guard and cheek plates, a great braided beard over his chest, pauldrons,
    /// belt and robe. `x` is his middle and `feet` the top of the pedestal, which runs on down into the gold.
    static func ereborStatue(_ c: PixelCanvas, _ g: Int, _ x: Int, _ feet: Int) {
        let s = unit(g)
        let body = C(0x44685A), lit = C(0x6A9480), shade = C(0x2A4438), dark = C(0x14201A)
        func tone(_ p: Px, _ v: Int) -> Px { ereborTone(c, g, p, feet + v * s) }
        // a block in units up from the feet, with its lit left edge and shaded right
        func block(_ u: Int, _ v: Int, _ w: Int, _ h: Int) {
            let y = feet + v * s, m = v + h / 2
            c.rect(x + u * s, y, w * s, h * s, tone(body, m))
            c.rect(x + u * s, y, s, h * s, tone(lit, m))
            c.rect(x + (u + w - 2) * s, y, 2 * s, h * s, tone(shade, m))
        }
        // a run of rows whose half-width goes from `h0` to `h1`
        func taper(_ v0: Int, _ v1: Int, _ h0: Int, _ h1: Int) {
            for v in v0..<max(v0, v1) {
                let half = h0 + (h1 - h0) * (v - v0) / max(1, v1 - v0)
                c.rect(x - half * s, feet + v * s, half * 2 * s, s, tone(body, v))
                c.rect(x - half * s, feet + v * s, s, s, tone(lit, v))
                c.rect(x + (half - 2) * s, feet + v * s, 2 * s, s, tone(shade, v))
            }
        }
        // the pedestal, its moulding, and its foot lost in the gold
        for y in feet..<max(feet, g) {
            c.rect(x - 22 * s, y, 44 * s, 1, ereborTone(c, g, body, y))
            c.rect(x - 22 * s, y, s, 1, ereborTone(c, g, lit, y))
            c.rect(x + 19 * s, y, 3 * s, 1, ereborTone(c, g, shade, y))
        }
        block(-24, 0, 48, 3)
        for dx in stride(from: -18, to: 18, by: 6) { c.rect(x + dx * s, feet + 6 * s, 3 * s, 2 * s, tone(dark, 7)) }
        // robe and boots, the hammer's head resting between them
        taper(-40, -4, 12, 16)
        c.rect(x, feet - 38 * s, s, 34 * s, tone(shade, -20))
        block(-15, -5, 12, 5); block(3, -5, 12, 5)
        block(-7, -13, 14, 9)
        c.rect(x - 7 * s, feet - 10 * s, 14 * s, s, tone(dark, -10))
        block(-1, -52, 3, 39)
        // chest and shoulders, arms, the beard, and the hands on the haft
        taper(-72, -44, 17, 13)
        block(-13, -46, 26, 4)
        block(-21, -74, 9, 4); block(12, -74, 9, 4)
        block(-20, -70, 6, 16); block(14, -70, 6, 16)
        taper(-80, -55, 9, 3)
        for bx in [-4, 3] {
            for v in stride(from: -66, to: -50, by: 3) { c.rect(x + bx * s, feet + v * s, s, 2 * s, tone(shade, v)) }
        }
        block(-18, -57, 14, 5); block(4, -57, 14, 5)
        block(-5, -59, 10, 7)
        c.rect(x - 4 * s, feet - 57 * s, 8 * s, s, tone(shade, -57))
        // the face and the helm
        block(-7, -88, 14, 9)
        c.rect(x - 5 * s, feet - 84 * s, 3 * s, s, tone(dark, -84)); c.rect(x + 2 * s, feet - 84 * s, 3 * s, s, tone(dark, -84))
        block(-1, -85, 3, 5)
        taper(-99, -89, 4, 9)
        block(-10, -90, 20, 2)
        block(-10, -88, 3, 8); block(7, -88, 3, 8)
        c.rect(x - s, feet - 90 * s, 2 * s, 6 * s, tone(lit, -88))
        block(-1, -103, 3, 4)
    }

    /// Smaug's hoard: heaped gold down to the floor, lit from within, its slopes shaded, speckled with coins, set with
    /// cups, gems, a shield and a crown, and glinting all over. On tall screens the Arkenstone crowns the heap.
    static func ereborHoard(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), peak = ereborPeak(c, g)
        guard c.w > 0 else { return }
        let tops = (0..<c.w).map { ereborHoardTop(c, g, $0) }
        // the glow the gold throws on the hall
        for k in 0..<6 {
            c.ellipse(c.w / 2, g, c.w * (8 - k) / 12, peak * (12 - k) / 6, C(0xFFB040, 0.03))
        }
        for x in 0..<c.w {
            let top = tops[x], d = g - top
            guard d > 0 else { continue }
            c.rect(x, top, 1, d, C(0xD8A23A))
            // deeper down the heap darkens, the surface catches the light
            let low = max(top, g - peak / 3)
            c.rect(x, low, 1, g - low, C(0xC08A30))
            c.rect(x, max(low, g - 3 * s), 1, g - max(low, g - 3 * s), C(0xA8742A))
            c.rect(x, top, 1, min(d, 3 * s), C(0xF0C455))
            c.rect(x, top, 1, min(d, s), C(0xFFF0A8))
            // slopes facing right fall into shade
            let ahead = tops[min(c.w - 1, x + 2 * s)]
            if ahead > top { c.rect(x, top + s, 1, min(d - s, 10 * s), C(0x8A5A1A, 0.28)) }
        }
        func at(_ k: Double) -> (x: Int, y: Int) {
            let x = min(c.w - 1, max(0, Int(Double(c.w) * k)))
            return (x, tops[x])
        }
        // a round shield, half sunk in the coins
        let sh = at(0.29)
        c.circle(sh.x, sh.y + 4 * s, 7 * s, C(0x8A5A1A)); c.circle(sh.x, sh.y + 4 * s, 6 * s, C(0xE0AC40))
        c.circle(sh.x, sh.y + 4 * s, 4 * s, C(0xC8922E)); c.circle(sh.x, sh.y + 4 * s, 2 * s, C(0xFCE07A))
        c.rect(sh.x - 8 * s, sh.y + 7 * s, 17 * s, 5 * s, C(0xD8A23A))
        // goblets, gold and silver, with a gem set in each
        for (i, k) in [0.12, 0.43, 0.71, 0.9].enumerated() {
            let p = at(k), y = p.y + 2 * s, silver = i == 2
            let cup = silver ? C(0xC8D0D8) : C(0xF0C850), cupLit = silver ? C(0xF4F8FC) : C(0xFFF0A0)
            let cupShade = silver ? C(0x8A929A) : C(0xB07C28)
            c.rect(p.x - 3 * s, y - 9 * s, 7 * s, 4 * s, cup); c.rect(p.x - 2 * s, y - 5 * s, 5 * s, s, cup)
            c.rect(p.x - 3 * s, y - 9 * s, 7 * s, s, cupLit); c.rect(p.x + 2 * s, y - 8 * s, 2 * s, 3 * s, cupShade)
            c.rect(p.x, y - 4 * s, s, 3 * s, cupShade); c.rect(p.x - 2 * s, y - s, 5 * s, s, cup)
            c.rect(p.x - s, y - 7 * s, s, s, i % 2 == 0 ? C(0xD8283A) : C(0x2AB86A))
        }
        // a crown lying on the slope
        let cr = at(0.58), cy = cr.y + s
        c.rect(cr.x - 4 * s, cy - 3 * s, 9 * s, 3 * s, C(0xF0C850)); c.rect(cr.x - 4 * s, cy - s, 9 * s, s, C(0xB07C28))
        for dx in [-4, 0, 4] { c.rect(cr.x + dx * s, cy - 5 * s, s, 2 * s, C(0xF0C850)); c.rect(cr.x + dx * s, cy - 6 * s, s, s, C(0xFFF0A8)) }
        c.rect(cr.x - 2 * s, cy - 2 * s, s, s, C(0x3A6AE8)); c.rect(cr.x + 2 * s, cy - 2 * s, s, s, C(0xD8283A))
        // the coins, each a bright face with a dark rim under it
        let n = c.w * max(1, peak) / (14 * s * s)
        for i in 0..<n {
            let x = Int(noise(i * 4 + 920) * Double(c.w)), top = tops[min(c.w - 1, x)]
            guard top < g - 2 * s else { continue }
            let y = top + s + Int(pow(noise(i * 4 + 921), 1.6) * Double(g - top - 2 * s))
            if noise(i * 4 + 922) > 0.4 {
                c.rect(x, y, 2 * s, s, C(0xFFE48A)); c.rect(x, y + s, 2 * s, s, C(0x9A6A20, 0.55))
            } else {
                c.rect(x, y, s, s, C(0x8A5A1A, 0.5))
            }
        }
        // gems scattered in the gold
        let gems: [UInt32] = [0xD8283A, 0x2AB86A, 0x3A6AE8, 0xF4F4FF, 0xB04AD8]
        for i in 0..<(c.w / (16 * s)) {
            let x = Int(noise(i * 3 + 940) * Double(c.w)), top = tops[min(c.w - 1, x)]
            guard top < g - 3 * s else { continue }
            let y = top + s + Int(noise(i * 3 + 941) * Double(min(g - top - 3 * s, 18 * s)))
            c.rect(x, y, 2 * s, 2 * s, C(gems[i % gems.count])); c.rect(x, y, s, s, C(0xFFFFFF, 0.7))
        }
        // glints all over
        for i in 0..<(c.w / (12 * s)) {
            let x = Int(noise(i * 3 + 950) * Double(c.w)), top = tops[min(c.w - 1, x)]
            guard top < g - 2 * s else { continue }
            let y = top + Int(noise(i * 3 + 951) * Double(min(g - top - 2 * s, 24 * s)))
            r8Glint(c, x, y, arm: (noise(i * 3 + 952) > 0.7 ? 3 : 2) * s, s: s, core: C(0xFFFFFF), ray: C(0xFFF4C0, 0.75))
        }
        // the Arkenstone, high on the heap
        if tall {
            let x = c.w / 2, y = tops[min(c.w - 1, x)] - 3 * s
            c.circle(x, y, 30 * s, C(0xDDEEFF, 0.05))
            c.circle(x, y, 16 * s, C(0xDDEEFF, 0.08))
            c.circle(x, y, 8 * s, C(0xE8F4FF, 0.14))
            r8Glint(c, x, y - 2 * s, arm: 10 * s, s: s, core: C(0xFFFFFF), ray: C(0xE8F4FF, 0.55))
            r8Stamp(c, x - 2 * s, y - 5 * s, ["..w..", ".wbw.", "wwbww", "bwwwb", ".bwb.", "..b.."],
                    ["w": C(0xFFFFFF), "b": C(0xBCD8F0)], s: s)
        }
    }
}

// MARK: - Data Lake-town

extension Scenes {
    /// The horizon, where the far shore meets the lake.
    static func laketownHorizon(_ c: PixelCanvas, _ g: Int) -> Int {
        isTall(c) ? Int(Double(g) * 0.6) : g - 22 * unit(g)
    }

    /// The Lonely Mountain: its middle, its height above the horizon, and its half-width at the horizon.
    static func laketownPeak(_ c: PixelCanvas, _ g: Int) -> (x: Int, h: Int, half: Int) {
        let s = unit(g), hz = laketownHorizon(c, g)
        let h = isTall(c) ? Int(Double(hz) * 0.46) : max(0, min(18 * s, hz * 2 / 3))
        return (Int(Double(c.w) * 0.6), h, h * 2)
    }

    /// The mountain's top at column `x` (the horizon off the mountain): a broad peak and a lower shoulder to its left.
    static func laketownMountainTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let s = unit(g), hz = laketownHorizon(c, g), m = laketownPeak(c, g)
        guard m.h > 0 else { return hz }
        let k = abs(Double(x - m.x)) / Double(m.half)
        let k2 = abs(Double(x - (m.x - m.half * 2 / 3))) / Double(max(1, m.half * 2 / 3))
        let h = max(Double(m.h) * pow(max(0, 1 - k), 1.35), Double(m.h) * 0.45 * pow(max(0, 1 - k2), 1.1))
        guard h > 0 else { return hz }
        return min(hz, hz - Int(h) + Int(noise(x / (2 * s) + 320) * 1.6) * s)
    }

    /// Data Lake-town: Esgaroth on its stilts in the Long Lake, on a grey evening. Wooden houses with steep gables and
    /// crossed gable boards stand in the water left and right, linked by plank walkways with lanterns, and a second row
    /// of them stands hazy behind. Between them the grey-blue lake opens out with boats and a few of Bilbo's barrels
    /// afloat, and far off on the horizon stands the Lonely Mountain. The crew stands on the wooden quay. On tall
    /// screens the town is stacked three rows deep and the mountain stands in full, a faint red glow at its peak.
    static func laketown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = laketownHorizon(c, g)
        c.gradient(0, hz, C(0x687C94), C(0xCCC8BE), bands: tall ? 10 : 6)
        for i in 0..<(tall ? 9 : 4) {
            let x = Int(noise(i * 5 + 300) * Double(c.w)), y = s + Int(noise(i * 5 + 301) * Double(max(1, hz * 2 / 3)))
            wisp(c, x, y, (30 + Int(noise(i * 5 + 302) * 50.0)) * s, C(0xB8BEC6, 0.7), s: s)
        }
        laketownMountain(c, g)
        // the far shore, low and blue
        c.dunes(base: hz, amp: Double(2 * s), freq: 0.03 / Double(s), phase: 0.7, bottom: hz + s, C(0x66768A))
        // the lake, and the mountain's reflection in it
        c.gradient(hz + s, g, C(0x8E9EAC), C(0x4C6072), bands: tall ? 8 : 4)
        let m = laketownPeak(c, g)
        for x in max(0, m.x - m.half * 2)..<max(0, min(c.w, m.x + m.half * 2)) {
            let len = (hz - laketownMountainTop(c, g, x)) / 2
            for y in stride(from: hz + 2 * s, to: min(g, hz + len), by: 2 * s) { c.rect(x, y, 1, s, C(0x6A7A90, 0.35)) }
        }
        for i in 0..<(c.w * max(0, g - hz) / (70 * s * s)) {
            let y = hz + 2 * s + Int(noise(i * 3 + 340) * Double(max(1, g - hz - 3 * s)))
            let k = Double(y - hz) / Double(max(1, g - hz)), len = Int((2 + k * 10) * Double(s))
            let x = Int(noise(i * 3 + 341) * Double(c.w))
            c.rect(x, y, len, s, noise(i * 3 + 342) > 0.45 ? C(0xB8C4CE, 0.45) : C(0x3A4C5E, 0.4))
        }
        // the houses, row behind row
        if tall {
            let d = Double(g - hz)
            laketownRow(c, g, water: hz + Int(d * 0.28), sc: 55, haze: 0.55, gap: (0.5, 0.7), seed: 1)
            laketownRow(c, g, water: hz + Int(d * 0.58), sc: 80, haze: 0.3, gap: (0.46, 0.73), seed: 2)
            laketownWater(c, g)
            laketownRow(c, g, water: g - 6 * s, sc: 125, haze: 0, gap: (0.4, 0.78), seed: 3)
        } else {
            laketownRow(c, g, water: g - 13 * s, sc: 60, haze: 0.45, gap: (0.48, 0.7), seed: 4)
            laketownWater(c, g)
            laketownRow(c, g, water: g - 5 * s, sc: 100, haze: 0, gap: (0.42, 0.76), seed: 5)
        }
        // the wooden quay: planks, their butt joints, and a mooring post at either end
        let rows = c.h - g
        c.ground(g, C(0x5A4636), edge: C(0x8E7258), speck: C(0x4A382A), seed: 83)
        for (k, y) in stride(from: g + 3 * s, to: c.h, by: 3 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x46362A))
            for x in stride(from: (k * 37 * s) % (40 * s), to: c.w, by: 40 * s) { c.rect(x, y - 2 * s, s, 2 * s, C(0x46362A)) }
        }
        c.rect(0, g - s, c.w, s, C(0x2E3C4A))
        if rows > 0 {
            for x in [5 * s, c.w - 9 * s] {
                c.rect(x, g - 8 * s, 4 * s, 8 * s + min(rows, 3 * s), C(0x4A3628))
                c.rect(x, g - 8 * s, s, 8 * s, C(0x6E5440)); c.rect(x, g - 9 * s, 4 * s, s, C(0x5E4A38))
                c.rect(x - s, g - 5 * s, 6 * s, s, C(0xA89068)); c.rect(x - s, g - 3 * s, 6 * s, s, C(0x8A7454))
            }
        }
    }

    /// The boats and barrels out in the open water between the houses.
    static func laketownWater(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = laketownHorizon(c, g)
        let mid = hz + (g - hz) / 2
        laketownBoat(c, Int(Double(c.w) * 0.64), tall ? mid + 6 * s : g - 10 * s, len: 16 * s, s: s, lantern: false)
        laketownBoat(c, Int(Double(c.w) * 0.55), g - 3 * s, len: (tall ? 32 : 26) * s, s: s, lantern: true)
        // Bilbo's barrels, bobbing
        let barrels: [(Double, Int)] = tall ? [(0.47, 14), (0.5, 18), (0.69, 12)] : [(0.47, 7), (0.5, 9)]
        for b in barrels {
            let x = Int(Double(c.w) * b.0), y = g - b.1 * s
            c.ellipse(x, y, 3 * s, 2 * s, C(0x7A5030)); c.rect(x - 3 * s, y - s, 7 * s, s, C(0x9A6A3A))
            c.rect(x - s, y - 2 * s, s, 4 * s, C(0x3A3A3A)); c.rect(x + 2 * s, y - 2 * s, s, 4 * s, C(0x3A3A3A))
            c.rect(x - 3 * s, y + 2 * s, 7 * s, s, C(0x2A3A48, 0.5))
        }
    }

    /// A rowing boat on the water: dark hull with a lighter strake, its prow turned up, oars shipped, and a lantern on
    /// a pole at the stern if `lantern`. `x` is its middle, `y` the waterline.
    static func laketownBoat(_ c: PixelCanvas, _ x: Int, _ y: Int, len: Int, s: Int, lantern: Bool) {
        let x0 = x - len / 2
        c.rect(x0 + 2 * s, y, len - 4 * s, s, C(0x2A3A48, 0.5))
        c.rect(x0, y - 4 * s, len, 2 * s, C(0x5A4232)); c.rect(x0, y - 4 * s, len, s, C(0x8A6A4A))
        c.rect(x0 + s, y - 2 * s, len - 2 * s, s, C(0x4A3426)); c.rect(x0 + 3 * s, y - s, len - 6 * s, s, C(0x34261C))
        c.rect(x0 - s, y - 7 * s, 2 * s, 4 * s, C(0x5A4232)); c.rect(x0 - 2 * s, y - 8 * s, 2 * s, s, C(0x5A4232))
        r8Line(c, x0 + len / 3, y - 5 * s, x0 + len * 2 / 3, y - 6 * s, C(0x9A7A58), s: s)
        if lantern {
            c.rect(x0 + len - 3 * s, y - 14 * s, s, 10 * s, C(0x3A2A1E))
            r8Lantern(c, x0 + len - 3 * s, y - 15 * s, s: s)
            for yy in stride(from: y + s, to: y + 7 * s, by: 2 * s) { c.rect(x0 + len - 4 * s, yy, 3 * s, s, C(0xF2B04A, 0.3)) }
        }
    }

    /// The Lonely Mountain alone on the horizon, blue with distance: a lit west face, a shadowed east one with a ridge
    /// between, gullies running down, a shoulder to the left, a little snow at the top and the faint red glow of the
    /// dragon at its peak, stronger on tall screens.
    static func laketownMountain(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = laketownHorizon(c, g), m = laketownPeak(c, g)
        guard m.h > 0 else { return }
        let top = hz - m.h
        for x in max(0, m.x - m.half * 2)..<max(0, min(c.w, m.x + m.half * 2)) {
            let ty = laketownMountainTop(c, g, x)
            guard ty < hz else { continue }
            c.rect(x, ty, 1, hz - ty, C(0x8A98AC))
            // east of the ridge running down from the peak lies in shadow
            if x > m.x {
                let ys = min(hz, top + Int(Double(x - m.x) / 0.4))
                if ys > ty { c.rect(x, ty, 1, ys - ty, C(0x6C7A90)) }
            }
            if abs(x - m.x) < m.half / 5 { c.rect(x, ty, 1, min(hz - ty, 2 * s), C(0xC8D0DA)) }
        }
        // gullies
        for i in 0..<5 {
            let dx = Int((noise(i * 4 + 330) - 0.5) * Double(m.half)), x0 = m.x + dx
            let y0 = laketownMountainTop(c, g, x0) + 2 * s, len = Int(Double(hz - y0) * (0.4 + noise(i * 4 + 331) * 0.4))
            for j in stride(from: 0, to: max(0, len), by: s) {
                let x = x0 + (dx > 0 ? j / 3 : -j / 3)
                if y0 + j > laketownMountainTop(c, g, x) { c.rect(x, y0 + j, s, s, C(0x5E6C82, 0.6)) }
            }
        }
        // the dragon's glow
        let r = (tall ? 14 : 5) * s
        c.circle(m.x, top + s, r, C(0xE0502A, 0.10))
        c.circle(m.x, top + s, r / 2, C(0xE0502A, 0.14))
        c.rect(m.x - s, top, 3 * s, s, C(0xC8442A, tall ? 0.6 : 0.35))
    }

    /// A row of houses on stilts standing in the water at row `water`, `sc` their size in percent and `haze` how far
    /// they've faded into the evening mist, leaving open water in the `gap` (shares of the width). Plank walkways with
    /// railings join neighbours, a lantern on some of them.
    static func laketownRow(_ c: PixelCanvas, _ g: Int, water: Int, sc: Int, haze: Double, gap: (Double, Double), seed: Int) {
        let s = unit(g), mist = C(0xA8B2BA)
        let gx0 = Int(Double(c.w) * gap.0), gx1 = Int(Double(c.w) * gap.1)
        var x = -Int(noise(seed * 50 + 360) * Double(16 * s)), i = 0
        var prev: (right: Int, base: Int)? = nil
        while x < c.w {
            let w = max(4 * s, (24 + Int(noise(seed * 50 + i * 3 + 361) * 12.0)) * sc / 100 * s)
            let spacing = (5 + Int(noise(seed * 50 + i * 3 + 362) * 10.0)) * sc / 100 * s
            if x + w > gx0 && x < gx1 {
                prev = nil
                x = max(x + s, gx1 + spacing)
                i += 1
                continue
            }
            let base = laketownHouse(c, g, x: x, w: w, water: water, sc: sc, haze: haze, seed: seed * 50 + i)
            if let p = prev, x - p.right > 2 * s {
                // the walkway from the last house
                let deck = lerp(C(0x4A3A2C), mist, haze), post = lerp(C(0x2A221C), mist, haze)
                c.rect(p.right, base - s, x - p.right, 2 * s, deck)
                c.rect(p.right, base - s, x - p.right, max(1, s / 2), lerp(C(0x7A644E), mist, haze))
                let rail = base - max(2 * s, 5 * sc / 100 * s)
                c.rect(p.right, rail, x - p.right, max(1, s * sc / 100), post)
                for px in stride(from: p.right + s, to: x, by: max(2 * s, 6 * sc / 100 * s)) {
                    c.rect(px, rail, s, base - rail, post)
                    c.rect(px, base + s, s, water - base - s, post)
                }
                if noise(seed * 50 + i * 3 + 363) > 0.4, sc >= 60 {
                    let lx = (p.right + x) / 2, ly = rail - 5 * sc / 100 * s
                    c.rect(lx, ly, s, base - ly, post)
                    r8Lantern(c, lx, ly - s, s: s, glow: 0.12 * (1 - haze))
                }
            }
            prev = (x + w, base)
            x += w + spacing
            i += 1
        }
    }

    /// One house on stilts: its reflection, the stilts down into the water, the plank floor, plank walls with
    /// shuttered windows (a lamp lit in some), a door, and the steep gable with its crossed boards at the peak. `x` is
    /// its left edge and `water` the row its stilts stand in. Returns its floor row.
    @discardableResult
    static func laketownHouse(_ c: PixelCanvas, _ g: Int, x: Int, w: Int, water: Int, sc: Int, haze: Double, seed: Int) -> Int {
        let s = unit(g), mist = C(0xA8B2BA)
        func t(_ hex: UInt32) -> Px { lerp(C(hex), mist, haze) }
        let walls: [UInt32] = [0x6A5442, 0x5E4A3A, 0x76604A, 0x5A5048]
        let roofs: [UInt32] = [0x3E3430, 0x4A3A2E, 0x3A4038]
        let wallCol = t(walls[seed % walls.count]), roofCol = t(roofs[seed % roofs.count])
        let stilt = max(s, 6 * sc / 100 * s), wall = max(2 * s, (12 + Int(noise(seed * 7 + 380) * 7.0)) * sc / 100 * s)
        let base = water - stilt, roofH = w * 3 / 5 + 2 * s, over = max(s, 3 * sc / 100 * s), e = max(s, s * sc / 100)
        let lit = C(0xF2B04A)
        // the reflection
        for y in stride(from: water + s, to: min(g, water + wall), by: 2 * s) {
            let wob = Int(noise(y / max(1, s) + seed * 13) * 3.0) * s - s
            c.rect(x + wob, y, w, s, C(0x34465A, 0.35 * (1 - haze)))
        }
        // stilts, braced
        let sw = max(s, 2 * s * sc / 100)
        for sx in stride(from: x + s, to: x + w - s, by: max(3 * s, w / 4)) {
            c.rect(sx, base, sw, stilt + s, t(0x2A221C))
        }
        if stilt > 2 * s { r8Line(c, x + s, water - s, x + w - 2 * s, base + s, t(0x2A221C), s: max(1, s / 2)) }
        // the floor and the walls
        c.rect(x - over, base - s, w + 2 * over, 2 * s, t(0x3A2E24))
        c.rect(x - over, base - s, w + 2 * over, max(1, s / 2), t(0x6A5640))
        c.rect(x, base - wall - s, w, wall, wallCol)
        if sc >= 70 {
            for px in stride(from: x + 3 * s, to: x + w - s, by: 3 * s) { c.rect(px, base - wall - s, max(1, s / 2), wall, C(0x000000, 0.12)) }
        }
        c.rect(x + w - 2 * s, base - wall - s, 2 * s, wall, C(0x000000, 0.15))
        // windows and a door
        let ww = max(s, 4 * sc / 100 * s), wh = max(s, 5 * sc / 100 * s), wy = base - wall * 3 / 4
        var k = 0
        for wx in stride(from: x + 4 * sc / 100 * s, to: x + w - ww - 2 * s, by: max(2 * s, 10 * sc / 100 * s)) {
            let on = noise(seed * 7 + k + 390) > 0.4
            c.rect(wx, wy, ww, wh, on ? lerp(lit, mist, haze * 0.4) : t(0x241C16))
            if on, sc >= 60 {
                c.rect(wx + ww / 2, wy, max(1, s / 2), wh, C(0x8A5A2A, 0.6))
                for yy in stride(from: water + s, to: min(g, water + 5 * s), by: 2 * s) { c.rect(wx, yy, ww, s, C(0xF2B04A, 0.25 * (1 - haze))) }
            }
            if sc >= 90 { c.rect(wx - s, wy, s, wh, t(0x3A2A1E)); c.rect(wx + ww, wy, s, wh, t(0x3A2A1E)) }
            k += 1
        }
        if sc >= 90, wall > 10 * s {
            let dx = x + w - 9 * s
            c.rect(dx, base - 9 * s, 5 * s, 8 * s, t(0x2E221A)); c.rect(dx, base - 9 * s, 5 * s, s, t(0x4A3A2C))
        }
        // the roof: shingled verges round the gable, the gable's planks, its little window, and the crossed boards
        let cx = x + w / 2, top = base - wall - s - roofH
        for j in 0..<max(0, roofH) {
            let half = (w / 2 + over) * (j + 1) / max(1, roofH)
            c.rect(cx - half, top + j, half * 2, 1, roofCol)
            if (j / max(1, s)) % 2 == 0, sc >= 60 { c.rect(cx - half, top + j, half * 2, 1, C(0x000000, 0.12)) }
        }
        let inset = 3 * e
        for j in inset..<max(inset, roofH) {
            let half = (w / 2 - e) * (j + 1 - inset) / max(1, roofH - inset)
            if half > 0 { c.rect(cx - half, top + j, half * 2, 1, lerp(wallCol, C(0x000000), 0.12)) }
        }
        c.rect(x - over, base - wall - s, w + 2 * over, e, t(0x2A2018))
        if roofH > 8 * e {
            let gy = top + roofH * 3 / 5
            c.rect(cx - e, gy, 2 * e, 2 * e, noise(seed * 7 + 395) > 0.5 ? lerp(lit, mist, haze * 0.4) : t(0x241C16))
        }
        let dark = t(0x2A2018)
        r8Line(c, cx - 3 * e, top + 3 * e, cx + 2 * e, top - 2 * e, dark, s: e)
        r8Line(c, cx + 2 * e, top + 3 * e, cx - 3 * e, top - 2 * e, dark, s: e)
        // a chimney on some
        if noise(seed * 7 + 397) > 0.5 {
            let chx = cx + w / 4, chy = top + roofH / 2 - 4 * e
            c.rect(chx, chy, 2 * e, 4 * e, t(0x4A4440)); c.rect(chx - e / 2, chy, 3 * e, e, t(0x3A3430))
        }
        return base
    }
}

// MARK: - The Green Dragon-and-Drop

/// The inn sign's green dragon, rearing, wings up and tail curled (12 rows by 20).
private let r8Dragon: [String] = [
    "...........d..d.....",
    "..........dd.dd.....",
    "..ggg....ddddd......",
    ".gegg...dddddd......",
    "gggggg.gggddd.......",
    "r...ggggggggg.......",
    "......gggggggg......",
    ".....gggggggggg..gg.",
    ".....gg.gggg.gggg..g",
    "....gg..gg....gggg..",
    "....g...g......gg...",
    "...gg..gg...........",
]

extension Scenes {
    /// The inn: its left edge, width, the row it stands on, its wall height and its roof height.
    static func greenDragonInn(_ c: PixelCanvas, _ g: Int) -> (x: Int, w: Int, base: Int, wall: Int, roof: Int) {
        let s = unit(g), w = max(60 * s, min(150 * s, c.w * 2 / 5))
        return (Int(Double(c.w) * 0.6) - w / 2, w, g - 5 * s, 18 * s, 17 * s)
    }

    /// The millpond: its right edge at the front and its far shore's row.
    static func greenDragonPond(_ c: PixelCanvas, _ g: Int) -> (x1: Int, top: Int) {
        let s = unit(g), tall = isTall(c)
        return (Int(Double(c.w) * (tall ? 0.34 : 0.27)), g - (tall ? 30 : 9) * s)
    }

    /// The Green Dragon-and-Drop: the inn at Bywater from outside on a warm summer evening. A peach and blue sky over
    /// the Shire's green hills with a round hobbit door or two in them, the millpond at the left reflecting the sky,
    /// and the inn itself: long and low, cream plaster over a stone footing under a deep mossy thatch, round windows
    /// glowing with lamplight, the round door open on the warm taproom, and the green dragon on its sign by the
    /// garden. Tables with tankards and a stack of barrels stand in the garden; the crew stands on the path in front.
    /// On tall screens a big summer sky with the low sun and pink-lit clouds, more hills with hedgerows and holes, and
    /// the mill with its waterwheel at the far end of the pond.
    static func greenDragon(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, tall ? C(0x5A84C4) : C(0x7AA4D6), C(0xF8D49A), bands: tall ? 12 : 7)
        // the low sun and its glow
        let sun = (x: Int(Double(c.w) * 0.84), y: tall ? Int(Double(g) * 0.45) : g - 36 * s)
        c.circle(sun.x, sun.y, (tall ? 30 : 14) * s, C(0xFFE8B0, 0.16))
        c.circle(sun.x, sun.y, (tall ? 15 : 8) * s, C(0xFFF0C8, 0.25))
        c.circle(sun.x, sun.y, (tall ? 7 : 4) * s, C(0xFFF6DC))
        for i in 0..<(tall ? 9 : 3) {
            let x = Int(noise(i * 7 + 401) * Double(c.w))
            let y = tall ? g / 14 + Int(noise(i * 7 + 402) * Double(g / 3)) : (3 + Int(noise(i * 7 + 402) * 8.0)) * s
            let r = (tall ? 4 + Int(noise(i * 7 + 403) * 4.0) : 2 + Int(noise(i * 7 + 403) * 2.0)) * s
            cloud(c, x, y, r, seed: i + 90, top: C(0xFFEAD6), base: C(0xF0B8A0))
        }
        if tall { greenDragonFar(c, g) }
        // the hills behind the inn, a hobbit hole or two in them
        c.dunes(base: g - 30 * s, amp: Double(5 * s), freq: 0.014 / Double(s), phase: 2.4, bottom: g, C(0x84AC66),
                shade: C(0x9CC07A))
        greenDragonHole(c, g, Int(Double(c.w) * 0.36), g - 24 * s, door: 0xE8B33A, small: true)
        c.dunes(base: g - 16 * s, amp: Double(3 * s), freq: 0.02 / Double(s), phase: 0.9, bottom: g, C(0x6EA04A),
                shade: C(0x88BC5E))
        greenDragonHole(c, g, Int(Double(c.w) * 0.93), g - 12 * s, door: 0x3A5A9A, small: false)
        // the lawn the inn stands on
        c.dunes(base: g - 7 * s, amp: Double(s), freq: 0.03 / Double(s), phase: 3.1, bottom: g, C(0x66A044), shade: C(0x84B85A))
        greenDragonPondDraw(c, g)
        greenDragonInnDraw(c, g)
        greenDragonGarden(c, g)
        greenDragonSign(c, g)
        // the garden path
        c.ground(g, C(0xCDB283), edge: C(0x5E9A3E), speck: C(0xAE9466), seed: 85)
        if c.h - g > 2 * s { c.rect(0, g + s, c.w, s, C(0xB89C6C)) }
        for i in 0..<(c.w / (6 * s)) {
            let x = Int(noise(i * 2 + 470) * Double(c.w))
            c.rect(x, g - s, s, 2 * s, noise(i * 2 + 471) > 0.5 ? C(0x4E8A34) : C(0x7AB050))
        }
    }

    /// Tall screens: blue hills on the horizon, patchwork hills nearer with hedgerows and round trees, and hobbit holes
    /// dug into them.
    static func greenDragonFar(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        c.dunes(base: Int(Double(g) * 0.5), amp: Double(10 * s), freq: 0.01 / Double(s), phase: 1.1, bottom: g,
                C(0xA8BCA8), shade: C(0xC0D0B4))
        c.dunes(base: Int(Double(g) * 0.6), amp: Double(9 * s), freq: 0.013 / Double(s), phase: 3.0, bottom: g,
                C(0x98BC74), shade: C(0xB0CC88))
        greenDragonHedges(c, g, top: Int(Double(g) * 0.6), seed: 1)
        c.dunes(base: Int(Double(g) * 0.72), amp: Double(8 * s), freq: 0.012 / Double(s), phase: 5.2, bottom: g,
                C(0x86B460), shade: C(0xA0C876))
        greenDragonHedges(c, g, top: Int(Double(g) * 0.72), seed: 2)
        let doors: [UInt32] = [0xB8402E, 0x2E6A2E, 0xE8B33A]
        for (i, k) in [0.44, 0.66, 0.9].enumerated() {
            let y = Int(Double(g) * 0.72) + (12 + Int(noise(i + 420) * 6.0)) * s
            greenDragonHole(c, g, Int(Double(c.w) * k), y, door: doors[i], small: true)
        }
        c.dunes(base: Int(Double(g) * 0.84), amp: Double(6 * s), freq: 0.016 / Double(s), phase: 0.4, bottom: g,
                C(0x78AC54), shade: C(0x92C46A))
        greenDragonHedges(c, g, top: Int(Double(g) * 0.84), seed: 3)
    }

    /// Hedgerows and round trees along a band of hills.
    static func greenDragonHedges(_ c: PixelCanvas, _ g: Int, top: Int, seed: Int) {
        let s = unit(g)
        for i in 0..<(c.w / (22 * s)) {
            let x = Int(noise(i * 5 + seed * 300 + 430) * Double(c.w))
            let y = top + (6 + Int(noise(i * 5 + seed * 300 + 431) * 12.0)) * s
            if noise(i * 5 + seed * 300 + 432) > 0.45 {
                c.rect(x, y, (14 + Int(noise(i * 5 + seed * 300 + 433) * 20.0)) * s, s, C(0x4E8A34, 0.8))
            } else {
                c.rect(x, y, s, 2 * s, C(0x6A4A2C))
                c.circle(x, y - 2 * s, 3 * s, C(0x4E8A34)); c.circle(x - s, y - 3 * s, 2 * s, C(0x6AA448))
                c.rect(x + 2 * s, y - 3 * s, s, s, C(0xF0C870, 0.5))
            }
        }
    }

    /// A hobbit hole in a hillside: a grassy mound, a stone ring round a round door with its knob, a round window and
    /// a chimney pot. `x`, `y` is the door's middle.
    static func greenDragonHole(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, door: UInt32, small: Bool) {
        let s = unit(g), r = (small ? 3 : 5) * s
        c.ellipse(x, y + 2 * s, r * 4, r * 2 + 2 * s, C(0x86BE5C)); c.ellipse(x, y + 3 * s, r * 4, r * 2 + s, C(0x74AC50))
        c.circle(x, y + s, r + s, C(0xB8AE98))
        c.circle(x, y + s, r, C(door))
        c.rect(x, y + s, s, s, C(0x1A1A14))
        let wx = x + r * 2 + 2 * s
        c.circle(wx, y, max(s, r / 2) + s, C(0xC8963E)); c.circle(wx, y, max(s, r / 2), C(0xF6C258))
        c.rect(x - r * 2 - s, y - r * 2, 2 * s, 3 * s, C(0x9A7A62))
        c.rect(x - r, y + r + s, r * 2, s, C(0xD8BE88))
    }

    /// The millpond, its water mirroring the evening sky with ripples, a reedy bank, and on tall screens the mill on
    /// its far shore with the waterwheel dipping into the pond.
    static func greenDragonPondDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), pond = greenDragonPond(c, g), bottom = g - 2 * s
        guard bottom > pond.top else { return }
        let skyTop = tall ? C(0x5A84C4) : C(0x7AA4D6), skyLow = C(0xF8D49A)
        // the right edge at row `y`: the far shore curves away
        func edge(_ y: Int) -> Int {
            let k = Double(y - pond.top) / Double(max(1, bottom - pond.top))
            return Int(Double(pond.x1) * (0.6 + 0.4 * k.squareRoot()))
        }
        if tall { greenDragonMill(c, g) }
        for y in pond.top..<bottom {
            let k = (Double(y - pond.top) / Double(max(1, bottom - pond.top)) * 5).rounded(.down) / 5
            let e = edge(y)
            c.rect(0, y, e, 1, lerp(lerp(skyLow, skyTop, 0.2 + 0.6 * k), C(0x4A7A8A), 0.25))
            c.rect(e, y, s, 1, C(0x4E7A34))
        }
        c.rect(0, pond.top, edge(pond.top), s, C(0x5E8A44, 0.6))
        for i in 0..<(pond.x1 * (bottom - pond.top) / (40 * s * s)) {
            let y = pond.top + s + Int(noise(i * 3 + 440) * Double(max(1, bottom - pond.top - s)))
            let x = Int(noise(i * 3 + 441) * Double(max(1, edge(y) - 6 * s)))
            c.rect(x, y, (3 + Int(noise(i * 3 + 442) * 5.0)) * s, s, noise(i * 3 + 443) > 0.4 ? C(0xFFF0D0, 0.45) : C(0x3E6A7A, 0.3))
        }
        // lily pads, and reeds along the bank at the front
        for i in 0..<max(0, pond.x1 / (30 * s)) {
            let x = Int(noise(i * 2 + 450) * Double(max(1, pond.x1 - 10 * s))), y = bottom - (2 + Int(noise(i * 2 + 451) * 4.0)) * s
            c.ellipse(x, y, 2 * s, s, C(0x4E8A34)); c.rect(x - s, y - s, s, s, C(0xF4D0E0))
        }
        let ex = edge(bottom - s)
        for k in 0..<7 {
            let x = ex - 9 * s + k * 2 * s, h = (6 + Int(noise(k + 460) * 6.0)) * s
            c.rect(x, bottom - h, s, h + 2 * s, C(0x5A8A3A))
            if k % 2 == 0 { c.rect(x, bottom - h - s, s, 3 * s, C(0x6A4428)) }
        }
        c.rect(0, bottom, ex, s, C(0x6E9A48))
    }

    /// Tall screens: the mill at the pond's far end, stone walls under a steep roof, its door and window, and the big
    /// wooden waterwheel turning in the water at its side.
    static func greenDragonMill(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), pond = greenDragonPond(c, g)
        let x = Int(Double(pond.x1) * 0.2), base = pond.top + 2 * s, w = 34 * s, wall = 20 * s, roof = 15 * s
        c.rect(x, base - wall, w, wall, C(0xB8AA90))
        for (row, y) in stride(from: base - wall, to: base, by: 4 * s).enumerated() {
            c.rect(x, y, w, s, C(0x8A7E6A))
            for xx in stride(from: x + (row % 2) * 4 * s, to: x + w, by: 8 * s) { c.rect(xx, y, s, 4 * s, C(0x8A7E6A)) }
        }
        c.rect(x + w - 4 * s, base - wall, 4 * s, wall, C(0x000000, 0.12))
        c.rect(x + 6 * s, base - 11 * s, 6 * s, 11 * s, C(0x5A3A22)); c.rect(x + 6 * s, base - 11 * s, 6 * s, s, C(0x3A2416))
        c.rect(x + 20 * s, base - 15 * s, 5 * s, 5 * s, C(0xF6C258)); c.rect(x + 22 * s, base - 15 * s, s, 5 * s, C(0x5A3A22))
        for j in 0..<roof {
            let half = (w / 2 + 3 * s) * (j + 1) / roof
            c.rect(x + w / 2 - half, base - wall - roof + j, half * 2, 1, (j / s) % 3 == 0 ? C(0x6A4A3A) : C(0x7E5A44))
        }
        c.rect(x + w / 2 + 6 * s, base - wall - roof, 4 * s, 9 * s, C(0x9A8A72))
        // the waterwheel
        let wx = x + w + 9 * s, wy = base - 5 * s, r = 11 * s
        c.circle(wx, wy, r, C(0x5A4030));
        c.circle(wx, wy, r - 2 * s, lerp(C(0xB8AA90), C(0xF8D49A), 0.5))
        for i in 0..<8 {
            let a: Double = Double(i) * Double.pi / 4
            let ex = wx + Int(cos(a) * Double(r)), ey = wy + Int(sin(a) * Double(r))
            r8Line(c, wx, wy, ex, ey, C(0x5A4030), s: s)
            c.rect(ex - s, ey - s, 3 * s, 3 * s, C(0x4A3426))
        }
        c.circle(wx, wy, 2 * s, C(0x3A2A1E))
    }

    /// The inn: a long low building of cream plaster with dark timbers over a stone footing, under a deep thatch with
    /// moss on it, a decorated ridge, two stone chimneys and a round dormer. Round windows glow with lamplight above
    /// boxes of flowers, the round door stands open on the warm taproom, and a lantern hangs by it.
    static func greenDragonInnDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), inn = greenDragonInn(c, g)
        let x0 = inn.x, base = inn.base, eave = base - inn.wall, cx = inn.x + inn.w / 2
        let timber = C(0x5A3E28)
        c.rect(x0 - 3 * s, base - s, inn.w + 8 * s, 2 * s, C(0x4E8034))
        // the walls
        c.rect(x0, eave, inn.w, inn.wall, C(0xEDE0BE))
        for x in stride(from: x0, to: x0 + inn.w, by: 26 * s) { c.rect(x, eave, 2 * s, inn.wall, timber) }
        c.rect(x0 + inn.w - 2 * s, eave, 2 * s, inn.wall, timber)
        c.rect(x0, base - 5 * s, inn.w, 5 * s, C(0xA8987A))
        for (row, y) in stride(from: base - 5 * s, to: base, by: 3 * s).enumerated() {
            c.rect(x0, y, inn.w, s, C(0x7E705A))
            for x in stride(from: x0 + (row % 2) * 3 * s, to: x0 + inn.w, by: 6 * s) { c.rect(x, y, s, 3 * s, C(0x7E705A)) }
        }
        c.rect(x0, base - 6 * s, inn.w, s, timber)
        // windows, round and glowing, with flower boxes
        let flowers: [UInt32] = [0xE85A7A, 0xF2D04A, 0xF4F0F0, 0xB06AD8, 0xF08A3A]
        let doorX = x0 + inn.w * 2 / 5
        var spots: [Int] = [x0 + inn.w / 7, x0 + inn.w * 17 / 25, x0 + inn.w * 6 / 7]
        if inn.w >= 110 * s { spots.append(x0 + inn.w * 27 / 100) }
        for (i, wx) in spots.enumerated() {
            let wy = base - 12 * s, r = 4 * s
            c.circle(wx, wy, r + 4 * s, C(0xFFC860, 0.10))
            c.circle(wx, wy, r + s, timber)
            c.circle(wx, wy, r, C(0xF8C860))
            c.circle(wx, wy, max(0, r - 2 * s), C(0xFFE8A0))
            c.rect(wx - r, wy, r * 2 + 1, s, C(0x8A5A2A)); c.rect(wx, wy - r, s, r * 2 + 1, C(0x8A5A2A))
            c.rect(wx - 5 * s, wy + r + 2 * s, 11 * s, 2 * s, C(0x7A5030))
            for k in 0..<5 { c.rect(wx - 4 * s + k * 2 * s, wy + r + s, s, s, C(flowers[(k + i * 2) % flowers.count])) }
        }
        // the round door, open on the taproom
        let dr = 7 * s, dy = base - dr
        c.circle(doorX, dy, dr + 2 * s, C(0x9A8E78))
        c.circle(doorX, dy, dr, C(0xF2B850))
        c.rect(doorX - dr, dy + 2 * s, dr * 2 + 1, dr - 2 * s, C(0xC88A3A))
        c.circle(doorX + 2 * s, dy + s, 2 * s, C(0x6A4428, 0.6))
        c.rect(doorX - dr + s, dy - 4 * s, 3 * s, dr + 4 * s, C(0x2E6A2E)); c.rect(doorX - dr + 3 * s, dy - 3 * s, s, dr + 2 * s, C(0x245624))
        c.rect(doorX - dr - 2 * s, base - s, dr * 2 + 5 * s, 2 * s, C(0xA89E88))
        c.rect(doorX + dr + 3 * s, base - 15 * s, 3 * s, s, timber)
        r8Lantern(c, doorX + dr + 5 * s, base - 13 * s, s: s, glow: 0.14)
        // the thatch, bulging over the eaves
        let over = 5 * s, ridgeHalf = max(s, inn.w / 2 + over - inn.roof * 3 / 2), top = eave - inn.roof
        func halfAt(_ j: Int) -> Int {
            let k = Double(j + 1) / Double(max(1, inn.roof))
            return ridgeHalf + Int(Double(inn.w / 2 + over - ridgeHalf) * k.squareRoot())
        }
        for j in 0..<inn.roof {
            let half = halfAt(j) - (j >= inn.roof - s ? s : 0)
            c.rect(cx - half, top + j, half * 2, 1, C(0xB8925A))
        }
        for i in 0..<(inn.w * inn.roof / (5 * s * s)) {
            let j = Int(noise(i * 3 + 480) * Double(max(1, inn.roof - 2 * s))), half = halfAt(j)
            let x = cx - half + Int(noise(i * 3 + 481) * Double(half * 2))
            c.rect(x, top + j, s, 2 * s, noise(i * 3 + 482) > 0.5 ? C(0x9A764A) : C(0xD0AC70))
        }
        for i in 0..<4 {
            let j = inn.roof / 3 + Int(noise(i * 2 + 490) * Double(inn.roof / 2)), half = halfAt(j)
            c.ellipse(cx - half + Int(noise(i * 2 + 491) * Double(half * 2)), top + j, 6 * s, 2 * s, C(0x7A8A44, 0.6))
        }
        c.rect(cx - ridgeHalf, top - s, ridgeHalf * 2, 2 * s, C(0x8A6A3A))
        for x in stride(from: cx - ridgeHalf, to: cx + ridgeHalf - s, by: 4 * s) { c.rect(x, top + s, 2 * s, s, C(0x8A6A3A)) }
        c.rect(x0 - over + s, eave, inn.w + 2 * over - 2 * s, s, C(0x6A4A2A))
        c.rect(x0, eave + s, inn.w, 2 * s, C(0x000000, 0.12))
        // a round dormer in the thatch
        let dmx = cx + inn.w / 8, dmy = top + inn.roof / 2
        c.ellipse(dmx, dmy - s, 6 * s, 4 * s, C(0xC8A066))
        c.circle(dmx, dmy, 3 * s, timber); c.circle(dmx, dmy, 2 * s, C(0xF8C860))
        // the chimneys
        for chx in [cx - inn.w / 3, cx + inn.w / 4] {
            c.rect(chx - 3 * s, top - 8 * s, 6 * s, 10 * s, C(0x9A8A72))
            c.rect(chx + s, top - 8 * s, 2 * s, 10 * s, C(0x7A6C58))
            c.rect(chx - 4 * s, top - 9 * s, 8 * s, 2 * s, C(0x7A6C58)); c.rect(chx - 4 * s, top - 9 * s, 8 * s, s, C(0xB8A890))
            c.rect(chx - s, top - 11 * s, 2 * s, 2 * s, C(0x8A5A3A))
        }
    }

    /// The beer garden: tables with benches and tankards in front of the inn, and barrels stacked at its end.
    static func greenDragonGarden(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), inn = greenDragonInn(c, g), y = g - 2 * s
        let wood = C(0x8A6038), woodLit = C(0xA87A48), woodDark = C(0x5A3E24)
        for k in [0.16, 0.74] {
            let x = inn.x + Int(Double(inn.w) * k)
            for side in [-1, 1] {
                let bx = x + side * 15 * s - 2 * s
                c.rect(bx, y - 4 * s, 5 * s, s, wood); c.rect(bx, y - 3 * s, s, 3 * s, woodDark); c.rect(bx + 4 * s, y - 3 * s, s, 3 * s, woodDark)
            }
            c.rect(x - 8 * s, y - 6 * s, 2 * s, 6 * s, woodDark); c.rect(x + 6 * s, y - 6 * s, 2 * s, 6 * s, woodDark)
            c.rect(x - 10 * s, y - 8 * s, 20 * s, 2 * s, wood); c.rect(x - 10 * s, y - 8 * s, 20 * s, s, woodLit)
            for (i, tx) in [x - 6 * s, x + 3 * s].enumerated() {
                c.rect(tx, y - 11 * s, 3 * s, 3 * s, i == 0 ? C(0x8A5A30) : C(0x9AA0A8))
                c.rect(tx + 3 * s, y - 10 * s, s, 2 * s, C(0x3A3A3A))
                c.rect(tx, y - 12 * s, 3 * s, s, C(0xF4ECD8))
            }
        }
        // the barrels at the inn's end
        let bx = inn.x + inn.w + 5 * s
        for (dx, dy) in [(0, 0), (9, 0), (4, 10)] {
            let x = bx + dx * s, by = y - dy * s
            c.rect(x, by - 9 * s, 8 * s, 9 * s, C(0x8A5A30))
            c.rect(x, by - 9 * s, 2 * s, 9 * s, C(0xA87440)); c.rect(x + 6 * s, by - 9 * s, 2 * s, 9 * s, C(0x6A4020))
            c.rect(x, by - 8 * s, 8 * s, s, C(0x3A3A3A)); c.rect(x, by - 3 * s, 8 * s, s, C(0x3A3A3A))
            c.rect(x + s, by - 10 * s, 6 * s, s, C(0x6A4020))
        }
    }

    /// The inn sign on its post by the garden: a painted board hanging from an arm, the green dragon on it.
    static func greenDragonSign(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), inn = greenDragonInn(c, g), post = inn.x - 10 * s, top = g - 40 * s
        c.rect(post, top, 3 * s, g - top - s, C(0x4A3020)); c.rect(post, top, s, g - top - s, C(0x6A4A2E))
        c.rect(post - 26 * s, top + 2 * s, 29 * s, 2 * s, C(0x4A3020))
        r8Line(c, post - 8 * s, top + 4 * s, post, top + 12 * s, C(0x4A3020), s: s)
        let bw = 24 * s, bh = 16 * s, bx = post - 25 * s, by = top + 7 * s
        for chx in [bx + 3 * s, bx + bw - 4 * s] { c.rect(chx, top + 4 * s, s, 3 * s, C(0x5A5048)) }
        c.rect(bx + s, by + s, bw, bh, C(0x1A100A, 0.4))
        c.rect(bx, by, bw, bh, C(0x2E5A2A))
        c.rect(bx + s, by + s, bw - 2 * s, bh - 2 * s, C(0xE8D8A8))
        r8Stamp(c, bx + 2 * s, by + 2 * s, r8Dragon, ["g": C(0x2E8A3A), "d": C(0x1E5A28), "e": C(0xF2D04A), "r": C(0xE0502A)], s: s)
    }
}
