import Foundation

// Isengit, Minas Tiered and the Black Gate-way.
let ringsScenes5: [Location: Place] = [
    .isengard: Place(name: "Isengit", panel: 0x1A1A1E, still: Scenes.isengard, moving: Scenes.isengardLife),
    .minasTirith: Place(name: "Minas Tiered", panel: 0x20222A, still: Scenes.minasTirith, moving: Scenes.minasTirithLife),
    .blackGate: Place(name: "The Black Gate-way", panel: 0x180E0C, still: Scenes.blackGate, moving: Scenes.blackGateLife),
]

// MARK: - Shared bits for these scenes

/// `v` clamped into 0...1.
private func r5Clamp(_ v: Double) -> Double { max(0, min(1, v)) }

/// How far through a repeating `period` (in seconds) the clock `t` is, in 0..<1.
private func r5Phase(_ t: Double, _ period: Double, offset: Double = 0) -> Double {
    let v = (t + offset).truncatingRemainder(dividingBy: period) / period
    return v < 0 ? v + 1 : v
}

/// A one-row streak of cloud `len` long from (x, y), `h` rows thick, leaving out the columns in `skip` (something
/// it passes behind).
private func r5Streak(_ c: PixelCanvas, _ x: Int, _ y: Int, _ len: Int, _ h: Int, _ col: Px, skip: Range<Int>) {
    let x1 = x + len
    c.rect(x, y, min(x1, skip.lowerBound) - x, h, col)
    let x0 = max(x, skip.upperBound)
    c.rect(x0, y, x1 - x0, h, col)
}

/// String art drawn with every character `s` pixels square.
private func r5Stamp(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], _ pal: [Character: Px], s: Int) {
    for (r, row) in rows.enumerated() {
        for (k, ch) in row.enumerated() { if let col = pal[ch] { c.rect(x + k * s, y + r * s, s, s, col) } }
    }
}

/// Smooth noise in 0..<1 along `x`: straight runs between random knots `period` apart.
private func r5Wave(_ x: Int, _ period: Int, seed: Int) -> Double {
    let p = max(1, period), j = Int(floor(Double(x) / Double(p))), f = Double(x - j * p) / Double(p)
    return noise(j + seed) * (1 - f) + noise(j + 1 + seed) * f
}

/// A jagged ridge of peaks about `span` pixels apart, rising up to `h` above row `base` and filled down to `bottom`.
/// Each peak's left flank catches the light in a wedge of `lit`, and the skyline is drawn in `edge`.
private func r5Ridge(_ c: PixelCanvas, base: Int, h: Int, span: Int, bottom: Int, _ col: Px, lit: Px, edge: Px,
                     seed: Int) {
    let span = max(1, span)
    for x in 0..<c.w {
        var top = Int.max, peakX = x
        for j in (x / span - 2)...(x / span + 2) {
            let peak = j * span + Int(noise(j * 7 + seed) * Double(span) * 0.8)
            let hh: Double = Double(h) * (0.35 + 0.65 * noise(j * 7 + seed + 1))
            let slope: Double = 0.8 + noise(j * 7 + seed + 2) * 1.2
            let y = base - Int(hh - Double(abs(x - peak)) * slope)
            if y < top { top = y; peakX = peak }
        }
        // crags and notches along the slopes
        let crag = r5Wave(x, max(2, span / 9), seed: seed * 13) * 0.6 + r5Wave(x, max(2, span / 25), seed: seed * 17) * 0.4
        top = max(0, top + Int(crag * Double(h) * 0.14) + Int(noise(x / 2 + seed * 13) * 1.6))
        guard top < bottom else { continue }
        c.rect(x, top, 1, bottom - top, col)
        if x < peakX { c.rect(x, top, 1, min(bottom - top, Int(Double(peakX - x) * 1.2)), lit) }
        c.px(x, top, edge)
    }
}

/// A column of smoke rising from (x, y): `puffs` puffs swelling and thinning as they climb, drifting right.
private func r5Smoke(_ c: PixelCanvas, _ x: Int, _ y: Int, puffs: Int, s: Int, _ col: Px, seed: Int) {
    for k in 0..<max(0, puffs) {
        let r = (2 + k) * s
        let px = x + k * k * s / 3 + Int((noise(seed + k) - 0.5) * Double(2 * s))
        let py = y - 2 * s - k * 4 * s
        c.ellipse(px, py, r * 3 / 2, r, col.alpha(0.6 - Double(k) * 0.45 / Double(max(1, puffs))))
    }
}

/// One billow of smoke `r` across at (x, y): a shadow under it to the lower right, a lit rim at its upper left, and
/// its body between; `q` runs from 0 at the fire (warm-lit from below) to 1 high up (paler).
private func r5Billow(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, q: Double, _ a: Double) {
    let body = lerp(C(0x302E32), C(0x4C4A50), q), rim = lerp(C(0x5A5458), C(0x7E7C80), q)
    c.circle(x + r / 3, y + r / 3, max(1, r * 9 / 10), C(0x1E1C20, a * 0.8))
    c.circle(x - r / 6, y - r / 5, r, rim.alpha(a))
    c.circle(x + r / 8, y + r / 8, max(1, r * 5 / 6), body.alpha(a))
    if q < 0.3 { c.circle(x, y + r / 2, max(1, r / 2), C(0x7A4026, a * (0.3 - q))) }
}

/// A column of smoke climbing from (x, y) up to row `top`: thin at the fire, swelling into ever bigger billows as it
/// climbs, snaking from side to side and bending over with the wind toward the east, each column its own way.
private func r5Column(_ c: PixelCanvas, _ x: Int, _ y: Int, top: Int, s: Int, tall: Bool, seed: Int) {
    let rise = y - top
    guard rise > 2 * s else { return }
    let step = (tall ? 3 : 2) * s, n = max(2, rise / step)
    let lean = Double(rise) * (0.05 + noise(seed + 1700) * 0.45), grow = Double((tall ? 13 : 5) * s)
    let sway = Double((tall ? 6 : 2) * s) * (0.5 + noise(seed + 1703)), wave = 2 + noise(seed + 1704) * 3
    // top down, so each lower, smaller billow sits in front of the one above it
    for k in stride(from: n, through: 0, by: -1) {
        let q = Double(k) / Double(n)
        let swell = 0.65 + 0.7 * noise(seed + k * 3 + 1701)
        let r = max(s, Int((Double(s) * 1.2 + pow(q, 1.3) * grow) * swell))
        let snake = Int(sin(q * wave * Double.pi + Double(seed % 7)) * sway * q)
        // some billows bulge out sideways, the column ragged rather than a tube
        let bulge = noise(seed + k * 3 + 1702) > 0.7 ? Int((noise(seed + k * 3 + 1705) - 0.5) * Double(r)) : 0
        r5Billow(c, x + Int(q * q * lean) + snake + bulge, y - Int(q * Double(rise)), r, q: q, 0.5 + 0.35 * q)
    }
}

/// The low smog the columns spread into: a lumpy, uneven layer of billows across the whole sky, heaped up thick in
/// places and worn thin in others, a darker layer of it underneath and ragged wisps hanging off its underside.
private func r5Smog(_ c: PixelCanvas, _ y: Int, _ th: Int, s: Int, seed: Int) {
    guard th > 0 else { return }
    func depth(_ x: Int) -> Double { r5Wave(x, 37 * s, seed: seed) * 0.6 + r5Wave(x, 11 * s, seed: seed + 9) * 0.4 }
    // the haze the billows sit in, thicker where the smog is heaped
    for x in 0..<c.w {
        let d = depth(x), hgt = Int(Double(th) * (0.2 + 1.1 * d)), off = Int((d - 0.5) * Double(th) * 0.5)
        c.rect(x, y - hgt / 2 + off, 1, hgt, C(0x3A383E, 0.4 + 0.3 * d))
        c.rect(x, y + hgt / 2 + off, 1, max(1, hgt / 3), C(0x2C2A30, 0.25))
    }
    // two rows of billows: a darker lower row, then a paler upper one heaped on it
    for (row, q, dy) in [(0, 0.55, th / 4), (1, 0.9, -th / 5)] {
        var x = -th, i = 0
        while x < c.w + th {
            let d = depth(x), nn = seed + row * 1000 + i * 3
            let r = max(s, Int(Double(th) * (0.25 + 0.55 * d) * (0.6 + 0.8 * noise(nn + 20))))
            if d > 0.3 || noise(nn + 23) > 0.6 {
                let off = Int((d - 0.5) * Double(th) * 0.5) - Int(d * Double(th) * 0.3 * Double(row))
                r5Billow(c, x, y + dy + off + Int((noise(nn + 21) - 0.5) * Double(th) * 0.5), r, q: q, 0.75)
            }
            x += max(s, r * 2 / 3 + Int(noise(nn + 22) * Double(r))); i += 1
        }
    }
}

/// The White Hand of Saruman, for his banner (8 by 8).
private let r5Hand: [String] = [
    ".#.#.#.#",
    ".#.#.#.#",
    ".#######",
    "########",
    "########",
    ".#######",
    "..#####.",
    "...###..",
]

// MARK: - Isengit

extension Scenes {
    /// Orthanc: its middle, the tips of its horns, its foot and the shaft's half-width.
    static func isengardTower(_ c: PixelCanvas, _ g: Int) -> (x: Int, top: Int, base: Int, half: Int) {
        let s = unit(g)
        if isTall(c) { return (Int(Double(c.w) * 0.56), Int(Double(g) * 0.07), Int(Double(g) * 0.66), 12 * s) }
        return (Int(Double(c.w) * 0.53), 2 * s, g - 8 * s, 9 * s)
    }

    /// The smoke columns: where each rises from, back to front. From the forges' chimneys and the bigger pits, away
    /// from the tower's middle so it stands clear.
    static func isengardPlumes(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, seed: Int)] {
        let s = unit(g), tall = isTall(c), o = isengardTower(c, g)
        var out: [(x: Int, y: Int, seed: Int)] = []
        for f in isengardSheds(c, g) { out.append((f.x - f.w / 2 + f.w - 3 * s, f.y - f.h - 6 * s, f.x)) }
        for (i, p) in isengardPits(c, g).enumerated() where tall ? p.rx >= 10 * s && i % 2 == 0 : i % 4 == 1 {
            out.append((p.x, p.y - p.ry, p.x + 7))
        }
        return out.filter { abs($0.x - o.x) > o.half * 2 }.sorted { $0.y < $1.y }
    }

    /// The low smog the columns feed: the row of its middle and its thickness.
    static func isengardSmog(_ c: PixelCanvas, _ g: Int) -> (y: Int, th: Int) {
        let s = unit(g)
        return isTall(c) ? (Int(Double(g) * 0.27), 24 * s) : (Int(Double(g) * 0.2), 7 * s)
    }

    /// The far side of the ring wall at column `x`: the row where the ring's floor begins. On tall screens the ring
    /// curves round towards the viewer at either side.
    static func isengardRim(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        guard isTall(c) else { return g - 13 * unit(g) }
        let k = min(0.99, abs(Double(x) - Double(c.w) / 2) / (Double(c.w) * 0.62))
        return g - Int(Double(g) * 0.42 * (1 - k * k).squareRoot())
    }

    /// The pits torn in the ring's floor, back to front: middle and radii.
    static func isengardPits(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, rx: Int, ry: Int)] {
        let s = unit(g), o = isengardTower(c, g)
        var out: [(x: Int, y: Int, rx: Int, ry: Int)] = []
        if isTall(c) {
            for i in 0..<max(1, c.w / (24 * s)) {
                let x = Int(noise(i * 4 + 1530) * Double(c.w)), rim = isengardRim(c, g, x)
                let room = g - 12 * s - rim
                guard room > 6 * s else { continue }
                let y = rim + 5 * s + Int(noise(i * 4 + 1531) * Double(room - 5 * s))
                let near: Double = Double(y - rim) / Double(max(1, g - rim))
                let rx = max(2 * s, Int((3 + 11 * near) * Double(s) * (0.7 + noise(i * 4 + 1532) * 0.6)))
                // keep the tower's foot and stair clear
                if abs(x - o.x) < o.half * 2 + rx, y > o.base - 24 * s, y < o.base + 10 * s { continue }
                out.append((x, y, rx, max(s, rx / 3)))
            }
        } else {
            var x = 8 * s, i = 0
            while x < c.w {
                let rx = (5 + Int(noise(i * 4 + 1540) * 6.0)) * s
                if abs(x - o.x) > o.half + rx + 4 * s { out.append((x, g - 5 * s, rx, 2 * s)) }
                x += rx * 2 + (16 + Int(noise(i * 4 + 1541) * 22.0)) * s
                i += 1
            }
        }
        return out.sorted { $0.y < $1.y }
    }

    /// Isengit: a grey sky choked with smoke over the last peaks of the Misty Mountains, the black rock ring of
    /// Isengard, and in its middle Orthanc: four black pillars fused into one tower, splitting into four horns at the
    /// top, one window lit. The ring's floor is torn up into pits with fires burning at their bottoms, billowing
    /// columns of smoke and sparks rising from them and from the forge chimneys into a low smog over the valley, and
    /// the crew stands on the blackened ground in front, among the stumps of the felled trees, under the White
    /// Hand's banner. Tall screens show Orthanc in full with its stair, the ring wall curving round towards the
    /// viewer, and many more pits and forges.
    static func isengard(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), o = isengardTower(c, g)
        c.gradient(0, g, C(0x46474D), C(0x8C8278), bands: tall ? 10 : 6)
        // high thin streaks of smoke that have drifted off east
        for i in 0..<(tall ? 7 : 3) {
            let x = Int(noise(i * 5 + 1500) * Double(c.w)), y = Int(noise(i * 5 + 1501) * Double(isengardSmog(c, g).y) * 0.8)
            wisp(c, x, y, (50 + Int(noise(i * 5 + 1502) * 90.0)) * s, C(0x3A3A40, 0.3), s: (tall ? 2 : 1) * s)
        }
        // the southern end of the Misty Mountains
        let farBase = tall ? Int(Double(g) * 0.56) : g - 14 * s
        r5Ridge(c, base: farBase, h: (tall ? 70 : 12) * s, span: (tall ? 70 : 40) * s, bottom: g, C(0x55575F),
                lit: C(0x6C6E76), edge: C(0x84868E), seed: 1510)
        isengardRing(c, g)
        // the ring's floor, churned and black, streaked with soot
        for x in 0..<c.w {
            let rim = isengardRim(c, g, x)
            if rim < g { c.rect(x, rim, 1, g - rim, C(0x24201E)) }
        }
        for i in 0..<(c.w * (tall ? 3 : 1) / (6 * s)) {
            let x = Int(noise(i * 3 + 1550) * Double(c.w)), rim = isengardRim(c, g, x)
            let y = rim + Int(noise(i * 3 + 1551) * Double(max(1, g - rim)))
            c.rect(x, y, (2 + Int(noise(i * 3 + 1552) * 6.0)) * s, s, C(noise(i * 3 + 1553) > 0.5 ? 0x1A1716 : 0x2E2824))
        }
        // the smoke: billowing columns climbing from the pits and forges into a low smog over the whole valley
        let smog = isengardSmog(c, g)
        for p in isengardPlumes(c, g) { r5Column(c, p.x, p.y, top: smog.y, s: s, tall: tall, seed: p.seed) }
        r5Smog(c, smog.y, smog.th, s: s, seed: 1505)
        let pits = isengardPits(c, g)
        for p in pits where p.y < o.base { isengardPit(c, g, p) }
        if tall { isengardForges(c, g, front: false) }
        isengardOrthanc(c, g)
        for p in pits where p.y >= o.base { isengardPit(c, g, p) }
        isengardForges(c, g, front: true)
        isengardStumps(c, g)
        // the blackened ground the crew stands on
        c.ground(g, C(0x1E1A18), edge: C(0x3E3632), speck: C(0x2C2624), seed: 37)
        for i in 0..<(c.w / (30 * s)) {
            let x = Int(noise(i * 3 + 1560) * Double(c.w)), y = g + 2 * s + Int(noise(i * 3 + 1561) * Double(max(1, c.h - g - 3 * s)))
            c.rect(x, y, s, s, C(0x6A5A4E))
        }
    }

    /// The ring of rock: a cliff all the way round, its far side behind the tower; on tall screens its sides come
    /// round towards the viewer, taller the nearer they are.
    static func isengardRing(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        for x in 0..<c.w {
            let rim = isengardRim(c, g, x)
            let k = r5Clamp(abs(Double(x) - Double(c.w) / 2) / Double(max(1, c.w / 2)))
            let wallH = tall ? Int((7 + 16 * k * k) * Double(s)) : 4 * s
            let top = rim - wallH - Int(noise(x / (3 * s) + 1520) * Double(2 * s))
            guard rim > top else { continue }
            c.rect(x, top, 1, rim - top, C(0x2E2E33))
            c.rect(x, top, 1, s, C(0x5C5C64))
            if noise(x / (2 * s) + 1521) > 0.78 { c.rect(x, top + 2 * s, 1, rim - top - 3 * s, C(0x222226)) }
        }
    }

    /// One pit: a rim of black spoil, the dark hole, a fire glowing at its bottom, and the smoke and sparks it sends
    /// up. Its glow reddens the ground round it.
    static func isengardPit(_ c: PixelCanvas, _ g: Int, _ p: (x: Int, y: Int, rx: Int, ry: Int)) {
        let s = unit(g), tall = isTall(c)
        c.ellipse(p.x, p.y, p.rx * 2, p.ry * 3, C(0xE8501E, 0.07))
        c.ellipse(p.x, p.y - s, p.rx + s, p.ry + s, C(0x100D0C))
        c.ellipse(p.x, p.y, p.rx, p.ry, C(0x1E0E0A))
        c.ellipse(p.x, p.y + p.ry / 3, max(1, p.rx * 2 / 3), max(1, p.ry / 2), C(0xC8401A))
        c.ellipse(p.x, p.y + p.ry / 3, max(1, p.rx / 3), max(1, p.ry / 4), C(0xFFB03A))
        c.rect(p.x - p.rx - s, p.y - s, 2 * (p.rx + s), s, C(0x5A2A1A, 0.6))
        let puffs = tall ? 3 + p.rx / (3 * s) : 3
        r5Smoke(c, p.x, p.y - p.ry, puffs: puffs, s: s, C(0x2E2C2E), seed: p.x + 1570)
        // sparks
        for k in 0..<(tall ? 5 + p.rx / s : 4) {
            let sx = p.x + Int((noise(p.x + k * 3 + 1580) - 0.5) * Double(p.rx * 2))
            let sy = p.y - p.ry - Int(noise(p.x + k * 3 + 1581) * Double(p.ry * 6 + 4 * s))
            c.rect(sx, sy, s, s, C(noise(p.x + k * 3 + 1582) > 0.5 ? 0xFFB03A : 0xE8701E, 0.9))
        }
    }

    /// The forge sheds: middle of the foot, width and height. Scattered over the ring on tall screens, two on the strip.
    static func isengardSheds(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, w: Int, h: Int)] {
        let s = unit(g), o = isengardTower(c, g)
        var sheds: [(x: Int, y: Int, w: Int, h: Int)] = []
        if isTall(c) {
            for i in 0..<max(1, c.w / (90 * s)) {
                let x = Int(noise(i * 4 + 1590) * Double(c.w)), rim = isengardRim(c, g, x)
                let room = g - 14 * s - rim
                guard room > 8 * s, abs(x - o.x) > o.half * 3 else { continue }
                let y = rim + 6 * s + Int(noise(i * 4 + 1591) * Double(room - 6 * s))
                let near: Double = Double(y - rim) / Double(max(1, g - rim))
                sheds.append((x, y, Int((10 + 10 * near) * Double(s)), Int((6 + 6 * near) * Double(s))))
            }
        } else {
            for k in [0.3, 0.86] { sheds.append((Int(Double(c.w) * k), g - 4 * s, 9 * s, 4 * s)) }
        }
        return sheds
    }

    /// The forges among the pits: dark sheds with a lit door and a smoking chimney. `front` picks those in front of
    /// the tower's foot (all of them on the window's strip).
    static func isengardForges(_ c: PixelCanvas, _ g: Int, front: Bool) {
        let s = unit(g), tall = isTall(c), o = isengardTower(c, g)
        let sheds = tall || front ? isengardSheds(c, g) : []
        for f in sheds where (f.y >= o.base) == front || !tall {
            let x0 = f.x - f.w / 2
            r5Smoke(c, x0 + f.w - 3 * s, f.y - f.h - 6 * s, puffs: tall ? 5 : 3, s: s, C(0x262426), seed: f.x + 1600)
            c.rect(x0 + f.w - 4 * s, f.y - f.h - 6 * s, 2 * s, 6 * s, C(0x161414))
            c.rect(x0 + f.w - 4 * s, f.y - f.h - 6 * s, 2 * s, s, C(0xE8701E, 0.7))
            c.rect(x0, f.y - f.h, f.w, f.h, C(0x181515))
            c.rect(x0 - s, f.y - f.h - s, f.w + 2 * s, s, C(0x3A3432))
            c.rect(x0, f.y - f.h, s, f.h, C(0x2A2624))
            // the open door, the forge fire inside
            let dw = max(s, f.w / 4), dh = max(s, f.h / 2)
            c.ellipse(x0 + f.w / 3, f.y - dh / 2, dw * 2, dh, C(0xE8701E, 0.12))
            c.rect(x0 + f.w / 3 - dw / 2, f.y - dh, dw, dh, C(0xE8701E))
            c.rect(x0 + f.w / 3 - dw / 2, f.y - max(s, dh / 2), dw, max(s, dh / 2), C(0xFFB03A))
        }
    }

    /// Orthanc: four fused pillars of black stone, faceted, flaring at the foot, a platform at the top with four
    /// sharp horns rising from it, the two in front bowing outwards. A window near the top is lit; on tall screens a
    /// stair climbs to the door at its foot.
    static func isengardOrthanc(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), o = isengardTower(c, g)
        let black = C(0x121216), facet = C(0x1E1E24), lit = C(0x3C3C46), groove = C(0x08080A), back = C(0x26262D)
        let hornH = max(s, (o.base - o.top) * (tall ? 2 : 1) / (tall ? 9 : 4))
        let deck = o.top + hornH
        // the two horns behind, a little shorter, then the two in front, bowing out; on the strip they spread wider
        // so all four tips show
        let bx = tall ? o.half / 3 : o.half / 2, fx = tall ? o.half - 2 * s : o.half - s
        for (dx, h, w, lean, col) in [(-bx, hornH * 3 / 4, (tall ? 5 : 3) * s, -s, back), (bx, hornH * 3 / 4, (tall ? 5 : 3) * s, s, back),
                                      (-fx, hornH, (tall ? 9 : 5) * s, -(tall ? 7 : 4) * s, black),
                                      (fx, hornH, (tall ? 9 : 5) * s, (tall ? 7 : 4) * s, black)] {
            for y in (deck - h)..<max(deck - h, deck) {
                let k = Double(deck - y) / Double(max(1, h))
                let hw = max(s, Int(Double(w) * (1 - k)))
                let cx = o.x + dx + Int(k * k * Double(lean))
                c.rect(cx - hw / 2, y, hw, 1, col)
                c.px(cx - hw / 2, y, lit)
            }
        }
        // the platform between the horns
        c.rect(o.x - o.half - s, deck, o.half * 2 + 2 * s, 2 * s, black)
        c.rect(o.x - o.half - s, deck, o.half * 2 + 2 * s, s, lit)
        // the shaft: four pillars side by side, each with a lit face and a groove between
        for y in (deck + 2 * s)..<max(deck + 2 * s, o.base) {
            let k = Double(y - deck) / Double(max(1, o.base - deck))
            let flare = k > 0.82 ? Int(pow((k - 0.82) / 0.18, 2) * Double(o.half) * 0.7) : 0
            let hw = o.half + flare, cw = max(1, (hw * 2) / 4)
            c.rect(o.x - hw, y, hw * 2, 1, black)
            for q in 0..<4 {
                let x0 = o.x - hw + q * cw
                c.rect(x0, y, max(1, cw / 3), 1, q == 0 ? lit : facet)
                c.px(x0 + cw - 1, y, groove)
            }
        }
        // the lit window high up, and the slits below it
        let wy = deck + (tall ? 8 : 4) * s
        c.ellipse(o.x, wy, 4 * s, 3 * s, C(0xE8A050, 0.12))
        c.rect(o.x - s, wy - s, 2 * s, (tall ? 3 : 2) * s, C(0xF0B060))
        for i in 0..<(tall ? 4 : 1) {
            let y = wy + (tall ? 30 : 12) * s * (i + 1)
            if y < o.base - 6 * s { c.rect(o.x + (i % 2 == 0 ? -o.half / 2 : o.half / 2), y, s, 2 * s, C(0x9A5A30, 0.7)) }
        }
        // the stair up to the door
        if tall {
            let steps = 6
            for k in 0..<steps {
                let w = (6 + k * 2) * s, y = o.base - (steps - k) * s
                c.rect(o.x - w, y, w * 2, s, C(k % 2 == 0 ? 0x34343C : 0x2A2A30))
            }
            c.rect(o.x - 2 * s, o.base - (steps + 5) * s, 4 * s, 5 * s, C(0x060608))
        } else {
            c.rect(o.x - 3 * s, o.base - s, 6 * s, s, C(0x34343C))
        }
    }

    /// The felled trees' stumps: left edge, width and height of each.
    static func isengardStumpSpots(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int, h: Int)] {
        let s = unit(g), tall = isTall(c)
        return (tall ? [0.05, 0.2, 0.42, 0.78, 0.95] : [0.08, 0.47, 0.95]).enumerated().map { (i: Int, k: Double) in
            (Int(Double(c.w) * k) + Int(noise(i + 1610) * Double(6 * s)), (tall ? 5 : 3) * s,
             (tall ? 4 : 2) * s + Int(noise(i + 1611) * Double(2 * s)))
        }
    }

    /// The White Hand's banner: its pole's column, the pole's top and the pixel size of the hand.
    static func isengardBanner(_ c: PixelCanvas, _ g: Int) -> (x: Int, top: Int, hs: Int) {
        let s = unit(g), tall = isTall(c)
        return (Int(Double(c.w) * 0.16), g - (tall ? 42 : 21) * s, tall ? 2 * s : s)
    }

    /// The stumps of the trees Saruman felled for his fires, and the White Hand on a black banner.
    static func isengardStumps(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        let wood = C(0x2E2219), ring = C(0x7A6448), shade = C(0x1E1610)
        for (x, w, h) in isengardStumpSpots(c, g) {
            c.rect(x - s, g - s, w + 2 * s, s, shade)
            c.rect(x, g - h, w, h, wood)
            c.rect(x + w - s, g - h, s, h, shade)
            c.rect(x, g - h - s, w, s, ring)
            c.px(x + w / 2, g - h - s, C(0x4E3E2C))
        }
        // the banner
        let (px, top, hs) = isengardBanner(c, g)
        c.rect(px, top, s, g - top, C(0x3A2E24))
        c.rect(px - s, top - s, 3 * s, s, C(0x6A6A70))
        let bw = 10 * hs, bh = 13 * hs
        c.rect(px + s, top + s, bw, bh, C(0x101012))
        for k in 0..<(bw / max(1, hs)) where k % 2 == 0 { c.rect(px + s + k * hs, top + s + bh, hs, hs, C(0x101012)) }
        r5Stamp(c, px + s + hs, top + s + 2 * hs, r5Hand, ["#": C(0xF2F0EA)], s: hs)
    }

    /// The pits' fires flickering and licking up over their rims, sparks rising from them, the forges' doors
    /// flaring and their chimneys puffing smoke.
    static func isengardLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), o = isengardTower(c, g), b = isengardBanner(c, g)
        let stumps = isengardStumpSpots(c, g)
        let fire = C(0xE8701E), red = C(0xC8401A)
        for (n, p) in isengardPits(c, g).enumerated() {
            // leave the pits alone where the tower, the banner or a stump stands in front of them
            if p.y < o.base, abs(p.x - o.x) < o.half * 2 + p.rx * 2 { continue }
            if abs(p.x - b.x - 5 * b.hs) < 5 * b.hs + p.rx + 5 * s { continue }
            if stumps.contains(where: { p.x + p.rx > $0.x - 2 * s && p.x - p.rx < $0.x + $0.w + 2 * s }),
               p.y + p.ry > g - 6 * s { continue }
            let ph = Double(n) * 1.7, fy = p.y + p.ry / 3, fw = max(s, p.rx * 2 / 3)
            let flick: Double = 0.5 + 0.25 * sin(t * 9 + ph) + 0.25 * sin(t * 13.7 + ph * 2)
            c.ellipse(p.x, p.y, p.rx * 2, p.ry * 3, C(0xE8501E, (tall ? 0.05 : 0.025) * flick))
            // tongues of flame, yellow at the root and red at the tip
            for x in stride(from: p.x - fw + s, to: p.x + fw, by: s) {
                let j = Double((x - p.x) / s)
                let n1: Double = 0.5 + 0.5 * sin(t * 8 + j * 1.3 + ph), n2: Double = 0.5 + 0.5 * sin(t * 5.3 - j * 0.9 + ph)
                let edge: Double = 1 - Double(abs(x - p.x)) / Double(fw)
                let lick = Int(n1 * n2 * edge * Double(p.ry + (tall ? 3 : 1) * s))
                guard lick > 0 else { continue }
                c.rect(x, fy - lick, s, lick, fire.alpha(0.75))
                c.rect(x, fy - lick, s, min(lick, s), red.alpha(0.8))
            }
            c.ellipse(p.x + Int(sin(t * 6 + ph) * Double(s)), fy, max(1, p.rx / 3), max(1, p.ry / 4),
                      C(0xFFE08A, 0.25 + 0.4 * flick))
            // sparks, cooling from yellow to red as they climb
            let rise = Double(tall ? p.ry * 6 + 14 * s : 13 * s)
            for k in 0..<(tall ? 2 + p.rx / (3 * s) : 2) {
                let period: Double = 1.4 + noise(n * 13 + k + 1900) * 1.6
                let q = r5Phase(t, period, offset: noise(n * 13 + k + 1910) * period)
                let x = p.x + Int((noise(n * 13 + k + 1920) - 0.5) * Double(p.rx)) + Int(q * Double(3 * s))
                    + Int(sin(q * 9 + Double(k)) * Double(s))
                let y = p.y - p.ry / 2 - Int(q * rise)
                c.rect(x, y, s, s, C(q < 0.4 ? 0xFFD070 : 0xE8701E, 1 - q * q))
            }
        }
        // the forges: the fire in each door flaring, smoke puffing from each chimney
        for f in isengardSheds(c, g) {
            let x0 = f.x - f.w / 2, dw = max(s, f.w / 4), dh = max(s, f.h / 2), seed = Double(f.x)
            let glow: Double = 0.5 + 0.3 * sin(t * 7 + seed) + 0.2 * sin(t * 11.3 + seed * 0.7)
            let gh = max(1, Int(Double(dh) * (0.3 + 0.5 * glow)))
            c.ellipse(x0 + f.w / 3, f.y - dh / 2, dw * 2, dh, C(0xE8701E, 0.06 * glow))
            c.rect(x0 + f.w / 3 - dw / 2, f.y - gh, dw, gh, C(0xFFD070, 0.2 + 0.4 * glow))
            let cx = x0 + f.w - 3 * s, cy = f.y - f.h - 6 * s, rise = (tall ? 34 : 12) * s
            for i in 0..<4 {
                let q = r5Phase(t, 5, offset: Double(i) * 1.25 + noise(f.x + 1930) * 5)
                let x = cx + Int(q * Double((tall ? 10 : 6) * s) + sin(q * 4 + Double(i)) * Double(s))
                let y = cy - s - Int(q * Double(rise)), r = s + Int(q * Double((tall ? 5 : 2) * s))
                c.circle(x + s, y + s, r, C(0x1E1C1E, 0.3 * (1 - q)))
                c.circle(x, y, r, C(0x3A3638, 0.5 * (1 - q)))
            }
        }
    }
}

// MARK: - Minas Tiered

extension Scenes {
    /// The city: its middle, the foot of the first wall, the Citadel's level, the tip of the White Tower's banner
    /// pole, and the half-widths of the first wall and the Citadel's.
    static func minasTirithCity(_ c: PixelCanvas, _ g: Int)
        -> (x: Int, foot: Int, citadel: Int, tip: Int, half: Int, citHalf: Int) {
        let s = unit(g)
        if isTall(c) {
            return (c.w / 2, g, Int(Double(g) * 0.3), Int(Double(g) * 0.07), min(c.w * 2 / 5, 190 * s), min(c.w / 9, 32 * s))
        }
        return (c.w / 2, g, 17 * s, 2 * s, min(c.w * 3 / 8, 160 * s), min(c.w / 14, 16 * s))
    }

    /// Tier `i` (0 the lowest, 6 the Citadel's): its wall's top in the middle, its half-width and how far its top
    /// bows down towards the viewer in the middle.
    static func minasTirithTier(_ c: PixelCanvas, _ g: Int, _ i: Int) -> (top: Int, half: Int, bow: Int) {
        let m = minasTirithCity(c, g)
        let top = m.foot - Int(Double(m.foot - m.citadel) * Double(i + 1) / 7)
        let half = m.half - Int(Double(m.half - m.citHalf) * Double(i) / 6)
        return (top, max(0, half), max(0, (m.foot - m.citadel) / 35))
    }

    /// The top of tier `i`'s wall at column `x`.
    static func minasTirithWallTop(_ c: PixelCanvas, _ g: Int, _ i: Int, _ x: Int) -> Int {
        let m = minasTirithCity(c, g), t = minasTirithTier(c, g, i)
        let k = Double(x - m.x) / Double(max(1, t.half))
        return t.top + Int(Double(t.bow) * max(0, 1 - k * k))
    }

    /// Minas Tiered at dawn: a blue sky warming to gold at the horizon with pink-lit clouds, the White Mountains
    /// hazy behind and Mount Mindolluin's snowy peak towering over the city. The city climbs in seven white tiers,
    /// each wall's top bowing round, houses and towers crowded on every terrace, and the great prow of rock splitting
    /// it from the Citadel down to the first tier. At the top the White Tower with its banner. The crew stands on a
    /// flagged white courtyard at the foot of the first wall. Tall screens have room for all seven tiers, each with
    /// its bastions and pennants, the Citadel with its hall and the White Tree in flower.
    static func minasTirith(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        if tall {
            let mid = Int(Double(g) * 0.68)
            c.gradient(0, mid, C(0x4E6EA8), C(0xD8B8C0), bands: 8)
            c.gradient(mid, g, C(0xD8B8C0), C(0xFAE0B0), bands: 5)
        } else {
            c.gradient(0, g, C(0x7C9AC8), C(0xF8DCB0), bands: 6)
        }
        for i in 0..<(tall ? 8 : 4) {
            let x = Int(noise(i * 5 + 1700) * Double(c.w))
            let y = Int(noise(i * 5 + 1701) * Double(g) * (tall ? 0.35 : 0.3)) + 2 * s
            let len = (tall ? 30 + Int(noise(i * 5 + 1702) * 50.0) : 20 + Int(noise(i * 5 + 1702) * 30.0)) * s
            wisp(c, x, y, len, C(0xFCD8C8, 0.85), s: s)
            wisp(c, x + s, y + s, len * 2 / 3, C(0xE8A8A0, 0.5), s: s)
        }
        // the White Mountains, hazy in the dawn
        r5Ridge(c, base: tall ? Int(Double(g) * 0.5) : g - 20 * s, h: (tall ? 60 : 14) * s, span: (tall ? 60 : 36) * s,
                bottom: g, C(0xA4A6C0), lit: C(0xC8B8C8), edge: C(0xE0D0DC), seed: 1710)
        minasTirithMountain(c, g)
        // the city, from the Citadel down: each terrace's houses, then the wall in front of them
        minasTirithCitadel(c, g)
        minasTirithWall(c, g, 6)
        for i in stride(from: 5, through: 1, by: -1) {
            minasTirithHouses(c, g, i)
            minasTirithWall(c, g, i)
        }
        minasTirithProw(c, g)
        minasTirithHouses(c, g, 0)
        minasTirithWall(c, g, 0)
        // the courtyard: pale flagstones, their joints in staggered courses
        c.ground(g, C(0xDCD8CE), edge: C(0xF6F4EE), speck: C(0xCCC8BC), seed: 43)
        for (r, y) in stride(from: g + 3 * s, to: c.h, by: 4 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0xC6C2B6))
            for x in stride(from: (r % 2) * 7 * s, to: c.w, by: 14 * s) { c.rect(x, y - 3 * s, s, 3 * s, C(0xC6C2B6)) }
        }
    }

    /// Mount Mindolluin behind the city: a great grey peak, its left faces lit pink by the dawn in facets fanning
    /// down from the summit, snow on its crown.
    static func minasTirithMountain(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g)
        let peak = m.x + Int(Double(c.w) * (tall ? 0.16 : 0.2))
        let top = tall ? Int(Double(g) * 0.02) : -18 * s
        let ratio = Double(g) / Double(max(1, c.w))
        let slopeL: Double = tall ? 0.95 * ratio : 0.32, slopeR: Double = tall ? 1.25 * ratio : 0.42
        let snowLine = tall ? Int(Double(g) * 0.2) : 6 * s
        let rock = C(0x737A94), lit = C(0xA898A8), crag = C(0x626882), snow = C(0xFAF0EC), snowShade = C(0xCFD0E2)
        for x in 0..<c.w {
            let d = x - peak
            var y = top + Int(Double(abs(d)) * (d < 0 ? slopeL : slopeR))
            y += Int(r5Wave(x, 9 * s, seed: 1720) * Double((tall ? 10 : 4) * s)) + Int(noise(x / (2 * s) + 1724) * Double(s))
            y = max(0, y)
            guard y < g else { continue }
            c.rect(x, y, 1, g - y, rock)
            // the dawn on the left flank, in facets
            if d < 0 {
                let depth = Int(Double(-d) * (0.3 + 0.3 * noise(x / (9 * s) + 1721)))
                c.rect(x, y, 1, min(g - y, depth), lit)
            } else if noise(x / (6 * s) + 1722) > 0.6 {
                c.rect(x, y + s, 1, min(g - y, (tall ? 6 : 3) * s + Int(noise(x / (6 * s) + 1725) * Double(6 * s))), crag)
            }
            // snow on the crown, ragged at its edge
            let line = snowLine + Int(noise(x / (2 * s) + 1723) * Double(5 * s)) - abs(d) / 6
            if line > y { c.rect(x, y, 1, min(g, line) - y, d < 0 ? snow : snowShade) }
            c.px(x, y, d < 0 ? C(0xFFF6F0) : C(0x8E94AA))
        }
    }

    /// The middles of tier `i`'s bastions: one at each end, and two more along it on tall screens.
    static func minasTirithBastions(_ c: PixelCanvas, _ g: Int, _ i: Int) -> [Int] {
        let s = unit(g), m = minasTirithCity(c, g), t = minasTirithTier(c, g, i)
        var towers = [m.x - t.half, m.x + t.half - 3 * s]
        if isTall(c), i < 6 { towers += [m.x - t.half * 11 / 20, m.x + t.half * 11 / 20] }
        return towers
    }

    /// Every pennant: its pole's foot, its length and its colour. The bastions' on tall screens, and always the
    /// White Tower's banner.
    static func minasTirithPennants(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, len: Int, col: Px)] {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g)
        var out: [(x: Int, y: Int, len: Int, col: Px)] = []
        if tall {
            for i in 0...6 {
                for x in minasTirithBastions(c, g, i) {
                    let top = minasTirithWallTop(c, g, i, x) - 6 * s
                    let bottom = i == 0 ? m.foot : minasTirithWallTop(c, g, i - 1, x)
                    guard bottom > top else { continue }
                    out.append((x, top - s, 6 * s, i % 2 == 0 ? C(0x1C1C26) : C(0xF6F4EE)))
                }
            }
        }
        out.append((m.x - s / 2, m.tip + (tall ? 8 : 3) * s, (tall ? 12 : 5) * s, C(0x1C1C26)))
        return out
    }

    /// One tier's wall: white stone, shading off round its curve at either end, crenellated along its top, with a
    /// bastion at each end (and more along it on tall screens) flying a pennant.
    static func minasTirithWall(_ c: PixelCanvas, _ g: Int, _ i: Int) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g), t = minasTirithTier(c, g, i)
        let face = C(0xEEEAE0), shade = C(0xC6C0B2), cap = C(0xFCFAF4), course = C(0xDCD6CA)
        for x in (m.x - t.half)..<max(m.x - t.half, m.x + t.half) {
            let top = minasTirithWallTop(c, g, i, x)
            let bottom = i == 0 ? m.foot : minasTirithWallTop(c, g, i - 1, x)
            guard bottom > top else { continue }
            let k = Double(abs(x - m.x)) / Double(max(1, t.half))
            let band = (k * k * 4).rounded(.down) / 4
            c.rect(x, top, 1, bottom - top, lerp(face, shade, band * 0.7))
            if tall { for y in stride(from: top + 4 * s, to: bottom, by: 4 * s) { c.px(x, y, lerp(course, shade, band * 0.7)) } }
            c.px(x, top, cap)
            if ((x - m.x) % (3 * s) + 3 * s) % (3 * s) < s { c.rect(x, top - s, 1, s, lerp(face, shade, band * 0.5)) }
        }
        // bastions
        let tw = (tall ? 6 : 3) * s, rise = (tall ? 6 : 2) * s
        for x in minasTirithBastions(c, g, i) {
            let top = minasTirithWallTop(c, g, i, x) - rise
            let bottom = i == 0 ? m.foot : minasTirithWallTop(c, g, i - 1, x)
            guard bottom > top else { continue }
            c.rect(x - tw / 2, top, tw, bottom - top, face)
            c.rect(x + tw / 2 - max(s, tw / 3), top, max(s, tw / 3), bottom - top, shade)
            c.rect(x - tw / 2, top, tw, s, cap)
            for mx in stride(from: x - tw / 2, to: x + tw / 2, by: 2 * s) { c.rect(mx, top - s, s, s, face) }
            if tall {
                c.rect(x - s, top + 3 * s, s, 2 * s, C(0x5A6276))
                minasTirithPennant(c, g, x, top - s, len: 6 * s, i % 2 == 0 ? C(0x1C1C26) : C(0xF6F4EE))
            }
        }
    }

    /// A pennant on a pole whose foot is at (x, y): `len` long, streaming right and tapering.
    static func minasTirithPennant(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, len: Int, _ col: Px) {
        let s = unit(g), pole = max(2 * s, len * 2 / 3), h = max(s, len / 3)
        c.rect(x, y - pole, s, pole, C(0x5A5A62))
        for j in 0..<max(0, len) {
            let hh = max(1, h * (len - j) / max(1, len))
            let wave = Int(sin(Double(j) / Double(max(1, 2 * s))) * Double(s) * 0.6)
            c.rect(x + s + j, y - pole + wave + (h - hh) / 2, 1, hh, col)
        }
    }

    /// The houses crowded on terrace `i`, behind the parapet of its wall and in front of the next wall up: white and
    /// cream with slate or flat roofs and dark windows, now and then a slim tower with a pointed cap.
    static func minasTirithHouses(_ c: PixelCanvas, _ g: Int, _ i: Int) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g), t = minasTirithTier(c, g, i)
        let step = max(1, (m.foot - m.citadel) / 7)
        let walls: [Px] = [C(0xF6F2EA), C(0xEAE4D6), C(0xF2EADC)]
        let side = C(0xCEC8BA), slate = C(0x7E8CA6), slateLit = C(0x98A6BE), window = C(0x4A5266)
        var x = m.x - t.half + s, n = i * 97
        while x < m.x + t.half - 2 * s {
            n += 1
            let w = (tall ? 5 + Int(noise(n * 3 + 1740) * 9.0) : 3 + Int(noise(n * 3 + 1740) * 5.0)) * s
            let towerHere = noise(n * 3 + 1741) > (tall ? 0.85 : 0.88)
            let bw = towerHere ? (tall ? 4 : 2) * s : w
            let base = minasTirithWallTop(c, g, i, x + bw / 2)
            let h = towerHere ? step * 4 / 5 : max(s, Int(Double(step) * (0.25 + noise(n * 3 + 1742) * 0.35)))
            let col = walls[n % 3]
            c.rect(x, base - h, bw, h, col)
            c.rect(x + bw - max(s, bw / 4), base - h, max(s, bw / 4), h, side)
            if towerHere {
                let capH = (tall ? 6 : 2) * s
                for k in 0..<capH {
                    let hw = bw * (capH - k) / max(1, capH * 2)
                    c.rect(x + bw / 2 - hw, base - h - k - 1, hw * 2, 1, k % 2 == 0 ? slate : slateLit)
                }
                if tall { c.rect(x + bw / 2 - s / 2, base - h + 3 * s, s, 2 * s, window) }
            } else if noise(n * 3 + 1742) > 0.45 {
                // a slate roof
                let rh = max(s, min(bw / 3, (tall ? 4 : 2) * s))
                for k in 0..<rh { c.rect(x + k, base - h - k - 1, max(0, bw - 2 * k), 1, k == rh - 1 ? slateLit : slate) }
            } else {
                c.rect(x, base - h, bw, s, C(0xFCFAF4))
            }
            // windows
            if h > 3 * s {
                for wx in stride(from: x + s, to: x + bw - 2 * s, by: (tall ? 3 : 2) * s) where !towerHere {
                    c.rect(wx, base - h + 2 * s, s, s, window)
                    if tall, h > 7 * s { c.rect(wx, base - h + 5 * s, s, s, window) }
                }
            }
            x += bw + (tall ? 1 + Int(noise(n * 3 + 1743) * 2.0) : Int(noise(n * 3 + 1743) * 2.0)) * s
        }
    }

    /// The great prow of rock that splits the city: a blade of pale stone from the Citadel down to the first tier,
    /// lit on its left face, shaded on its right, its keel catching the light, with the lookout at its tip.
    static func minasTirithProw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g)
        let bottom = minasTirithTier(c, g, 0).top
        let topW = Double((tall ? 16 : 6) * s)
        let lit = C(0xEEE8DA), shade = C(0xBEB6A6), keel = C(0xFFFFFF), joint = C(0xD6CEBE)
        for y in m.citadel..<max(m.citadel, bottom) {
            let k = Double(y - m.citadel) / Double(max(1, bottom - m.citadel))
            let hw = Int(topW * pow(1 - k, 0.8)) + s
            c.rect(m.x - hw, y, hw, 1, lit)
            c.rect(m.x, y, hw, 1, shade)
            c.px(m.x - hw, y, joint)
            c.rect(m.x, y, s, 1, keel)
            if tall, (y / s) % 6 == 0 { c.rect(m.x - hw + s, y, max(0, hw - 2 * s), 1, joint) }
        }
        // the lookout: a parapet at the tip, level with the Citadel
        let pw = Int(topW) + 3 * s
        c.rect(m.x - pw, m.citadel - s, pw * 2, 2 * s, C(0xF6F4EE))
        c.rect(m.x - pw, m.citadel - s, pw * 2, s, C(0xFFFFFF))
    }

    /// The Citadel on the topmost terrace: the hall's long roof and columns, the White Tower rising from the middle
    /// to its pointed cap and its black banner, and at its foot the White Tree in flower.
    static func minasTirithCitadel(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g)
        let white = C(0xF8F6F0), shade = C(0xD2CEC4), slate = C(0x7E8CA6), dark = C(0x4A5266)
        let lvl = m.citadel
        // the hall to the left of the tower, a lesser house to the right
        let hallH = (tall ? 10 : 4) * s
        let hx0 = m.x - m.citHalf + 2 * s, hx1 = m.x - (tall ? 6 : 3) * s
        if hx1 > hx0 {
            c.rect(hx0, lvl - hallH, hx1 - hx0, hallH, white)
            c.rect(hx0 - s, lvl - hallH - s, hx1 - hx0 + 2 * s, s, slate)
            for x in stride(from: hx0 + s, to: hx1 - s, by: (tall ? 3 : 2) * s) { c.rect(x, lvl - hallH + s, s, hallH - s, shade) }
        }
        let rx0 = m.x + (tall ? 6 : 3) * s, rx1 = m.x + m.citHalf / 2
        if rx1 > rx0 {
            c.rect(rx0, lvl - hallH * 2 / 3, rx1 - rx0, hallH * 2 / 3, white)
            c.rect(rx1 - s, lvl - hallH * 2 / 3, s, hallH * 2 / 3, shade)
            c.rect(rx0, lvl - hallH * 2 / 3 - s, rx1 - rx0, s, slate)
        }
        // the White Tree in the court
        let tx = m.x + m.citHalf * 3 / 4, trunk = C(0xE4E0D6), bloom = C(0xFFFFFF)
        if tall {
            c.rect(tx, lvl - 8 * s, s, 8 * s, trunk)
            for (dx, dy) in [(-3, -9), (-2, -10), (2, -10), (3, -11), (-1, -12), (1, -12), (0, -13)] {
                c.rect(tx + dx * s, lvl + dy * s, s, s, trunk)
            }
            c.ellipse(tx, lvl - 12 * s, 6 * s, 3 * s, bloom.alpha(0.85))
            c.ellipse(tx - 2 * s, lvl - 11 * s, 3 * s, 2 * s, C(0xF2EEF6))
        } else {
            c.rect(tx, lvl - 3 * s, s, 3 * s, trunk)
            c.rect(tx - s, lvl - 4 * s, 3 * s, s, bloom)
        }
        // the White Tower: its shaft, a gallery near the top, slit windows, the pointed cap and the banner
        let tw = (tall ? 4 : 2) * s, pole = (tall ? 8 : 3) * s, capH = (tall ? 12 : 4) * s
        let bodyTop = m.tip + pole + capH
        for y in bodyTop..<max(bodyTop, lvl) {
            let k = Double(y - bodyTop) / Double(max(1, lvl - bodyTop))
            let hw = tw + (tall ? Int(k * Double(2 * s)) : 0)
            c.rect(m.x - hw, y, hw * 2, 1, white)
            c.rect(m.x + hw - max(s, hw / 2), y, max(s, hw / 2), 1, shade)
        }
        c.rect(m.x - tw - s, bodyTop + (tall ? 3 : 1) * s, tw * 2 + 2 * s, s, shade)
        if tall {
            for y in stride(from: bodyTop + 8 * s, to: lvl - 6 * s, by: 12 * s) { c.rect(m.x - s, y, s, 3 * s, dark) }
        }
        for k in 0..<capH {
            let hw = tw * (capH - k) / max(1, capH)
            c.rect(m.x - hw, bodyTop - k - 1, max(s, hw * 2), 1, k < capH / 2 ? white : shade)
        }
        minasTirithPennant(c, g, m.x - s / 2, m.tip + pole, len: (tall ? 12 : 5) * s, C(0x1C1C26))
    }

    /// A pennant as `minasTirithPennant` draws it, rippling in the wind: each column of the cloth lifted or dropped
    /// by a wave running out along it, the fold it leaves behind showing in `fold`, the tip flicking out further.
    static func minasTirithFlutter(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, len: Int, _ col: Px, fold: Px,
                                   t: Double, seed: Double) {
        let s = unit(g), pole = max(2 * s, len * 2 / 3), h = max(s, len / 3)
        let flick = Int((0.5 + 0.5 * sin(t * 3.1 + seed)) * Double(2 * s))
        for j in 0..<max(0, len + flick) {
            let hh = max(1, h * max(0, len - j) / max(1, len))
            let at: Double = Double(j) / Double(max(1, 2 * s))
            let y0 = y - pole + Int(sin(at) * Double(s) * 0.6) + (h - hh) / 2
            let reach: Double = Double(j + s) / Double(max(1, len))
            let d = Int((sin(at * 1.4 - t * 7 + seed) * Double(s) * (0.5 + reach)).rounded())
            if j < len { for yy in y0..<(y0 + hh) where yy < y0 + d || yy >= y0 + d + hh { c.px(x + s + j, yy, fold) } }
            c.rect(x + s + j, y0 + d, 1, hh, col)
        }
    }

    /// The pennants and the White Tower's banner rippling, thin clouds drifting by behind the tower, and now and then
    /// a bird flying in to circle the tower's top before flying on.
    static func minasTirithLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), m = minasTirithCity(c, g)
        let twoPi: Double = 2 * Double.pi
        // clouds, high up, passing behind the tower and its banner
        let skip = (m.x - (tall ? 8 : 4) * s)..<(m.x + (tall ? 18 : 9) * s)
        let yMax = max(3 * s, m.citadel - (tall ? 16 : 10) * s)
        for i in 0..<(tall ? 5 : 3) {
            let len = (tall ? 40 + Int(noise(i * 5 + 1950) * 40.0) : 24 + Int(noise(i * 5 + 1950) * 20.0)) * s
            let speed: Double = (1.5 + noise(i * 5 + 1951) * 2.5) * Double(s), span = Double(c.w + len * 2)
            let x = Int((noise(i * 5 + 1952) * span + t * speed).truncatingRemainder(dividingBy: span)) - len
            let y = 2 * s + Int(noise(i * 5 + 1953) * Double(max(1, yMax - 2 * s)))
            r5Streak(c, x, y, len, s, C(0xFFF2EA, 0.4), skip: skip)
            r5Streak(c, x + len / 5, y - s, len / 2, s, C(0xFFF2EA, 0.3), skip: skip)
            r5Streak(c, x + len / 8, y + s, len * 3 / 4, s, C(0xE8B0A8, 0.3), skip: skip)
        }
        for (k, p) in minasTirithPennants(c, g).enumerated() {
            let dark = p.col.r < 0x80
            minasTirithFlutter(c, g, p.x, p.y, len: p.len, p.col, fold: dark ? C(0x4A5068) : C(0xBCB8B0), t: t,
                               seed: Double(k) * 2.3)
        }
        // the bird: in from the left, once round the tower's top, and away to the right
        let fly: Double = 12, u = r5Phase(t, 22, offset: 3) * 22 / fly
        guard u < 1 else { return }
        let rx = Double((tall ? 22 : 9) * s), ry = Double((tall ? 8 : 3) * s)
        let cy = Double(m.tip + (tall ? 6 : 3) * s)
        let along: Double = u < 0.4 ? u / 0.4 * 0.5 : u < 0.6 ? 0.5 : 0.5 + (u - 0.6) / 0.4 * 0.5
        let a: Double = u < 0.4 || u >= 0.6 ? 0 : (u - 0.4) / 0.2 * twoPi
        let bx = Int(Double(-8 * s) + along * Double(c.w + 16 * s) + rx * sin(a))
        let by = Int(cy + ry * cos(a) + sin(t * 2) * Double(s))
        let bs = tall ? 2 * s : s
        let wings = Int(t * 5) % 2 == 0 ? ["#...#", ".#.#.", "..#.."] : [".....", "##.##", "..#.."]
        r5Stamp(c, bx - 2 * bs, by - bs, wings, ["#": C(0x3A3E4E)], s: bs)
    }
}

// MARK: - The Black Gate-way

extension Scenes {
    /// The Morannon: its middle, the top of its leaves, its foot and its half-width.
    static func blackGateGate(_ c: PixelCanvas, _ g: Int) -> (x: Int, top: Int, base: Int, half: Int) {
        let s = unit(g)
        if isTall(c) { return (c.w / 2, Int(Double(g) * 0.44), Int(Double(g) * 0.74), min(c.w * 7 / 25, 110 * s)) }
        return (c.w / 2, 24 * s, g - 9 * s, min(c.w / 6, 60 * s))
    }

    /// The Teeth of Mordor: how far each tower stands from the gate's middle, its tip, foot and half-width.
    static func blackGateTeeth(_ c: PixelCanvas, _ g: Int) -> (dx: Int, tip: Int, base: Int, half: Int) {
        let s = unit(g), gt = blackGateGate(c, g)
        if isTall(c) { return (gt.half + 24 * s, Int(Double(g) * 0.06), gt.base + 6 * s, 15 * s) }
        return (gt.half + 12 * s, 2 * s, gt.base + 2 * s, 7 * s)
    }

    /// The Black Gate-way: an ash-brown sky, a red glow far off over the pass into Mordor, the black mountains rising
    /// jagged on either side, and between them the Morannon: a colossal gate of black iron plates, ribbed and
    /// riveted, under a spiked rampart, walled across to the two Teeth, fang-like towers leaning in over the gate
    /// with red-lit windows. Before it the dusty plain where the crew stands. Tall screens show the towers in full,
    /// the glow over the far mountains, and slag heaps and broken spears strewn over the plain.
    static func blackGate(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), gt = blackGateGate(c, g), th = blackGateTeeth(c, g)
        c.gradient(0, g, tall ? C(0x1E1412) : C(0x2A1A16), C(0x6E3C2A), bands: tall ? 10 : 6)
        // the far glow over Mordor
        let gy = gt.top
        for (k, a) in [(1.0, 0.08), (0.7, 0.1), (0.45, 0.12)] {
            c.ellipse(gt.x, gy, Int(Double(gt.half) * 1.8 * k), max(1, Int(Double(gy) * 0.9 * k)), C(0xD0481E, a))
        }
        // drifting ash
        for i in 0..<(tall ? 10 : 5) {
            let x = Int(noise(i * 5 + 1800) * Double(c.w)), y = Int(noise(i * 5 + 1801) * Double(gt.top) * 0.8)
            wisp(c, x, y, (40 + Int(noise(i * 5 + 1802) * 60.0)) * s, C(0x1A100E, 0.4), s: s)
        }
        // the mountains of Mordor beyond the gate, low in the glow
        r5Ridge(c, base: gt.top + (tall ? 12 : 5) * s, h: (tall ? 26 : 8) * s, span: (tall ? 34 : 22) * s, bottom: g,
                C(0x3A1C16), lit: C(0x4E2418), edge: C(0x7A341E), seed: 1810)
        blackGateMountains(c, g)
        // the walls from the gate out to the towers
        let wallTop = gt.top + (tall ? 4 : 2) * s
        for side in [-1, 1] {
            let x0 = side < 0 ? gt.x - th.dx : gt.x + gt.half, x1 = side < 0 ? gt.x - gt.half : gt.x + th.dx
            c.rect(x0, wallTop, x1 - x0, gt.base - wallTop, C(0x140E0C))
            c.rect(x0, wallTop, x1 - x0, s, C(0x3E2018))
            for x in stride(from: x0, to: x1, by: 3 * s) { c.rect(x, wallTop - 2 * s, s * 2, 2 * s, C(0x140E0C)) }
            for y in stride(from: wallTop + 4 * s, to: gt.base, by: (tall ? 6 : 4) * s) { c.rect(x0, y, x1 - x0, s, C(0x0E0A09)) }
        }
        blackGateTooth(c, g, side: -1)
        blackGateTooth(c, g, side: 1)
        blackGateDoors(c, g)
        // the plain of Dagorlad, dust hanging over it
        c.dunes(base: gt.base + (tall ? 4 : 2) * s, amp: Double(s), freq: 0.05 / Double(s), phase: 0.7, bottom: g,
                C(0x3A2C25), shade: C(0x56423A))
        for k in 0..<(tall ? 4 : 2) {
            let y = gt.base + k * (tall ? 6 : 3) * s
            c.rect(0, y, c.w, (tall ? 4 : 2) * s, C(0x8A5A42, 0.1))
        }
        if tall { blackGatePlain(c, g) }
        c.ground(g, C(0x3A2E28), edge: C(0x5E4C40), speck: C(0x2C221E), seed: 51)
        for i in 0..<(c.w / (40 * s)) {
            let x = Int(noise(i * 3 + 1820) * Double(c.w)), y = g + 2 * s + Int(noise(i * 3 + 1821) * Double(max(1, c.h - g - 3 * s)))
            c.rect(x, y, 2 * s, s, C(0x4A3C34))
        }
    }

    /// The black mountains closing in on either side of the gate, rising jagged towards the edges, their faces
    /// towards the gate catching the red glow.
    static func blackGateMountains(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), gt = blackGateGate(c, g)
        let slope: Double = tall ? 1.5 * Double(g) / Double(max(1, c.w)) : 0.11
        let rock = C(0x110C0B), lit = C(0x2E1612), edge = C(0x5A2A1C)
        for x in 0..<c.w {
            let d = abs(x - gt.x) - gt.half + 2 * s
            guard d > 0 else { continue }
            let crag = Int(r5Wave(x, (tall ? 11 : 6) * s, seed: 1830) * Double((tall ? 16 : 6) * s)) + Int(noise(x / s + 1831) * Double(s))
            let top = max(0, gt.top - Int(Double(d) * slope) - crag)
            guard top < g else { continue }
            c.rect(x, top, 1, g - top, rock)
            // the facets that face the gate
            if noise(x / (4 * s) + 1832) > 0.45 {
                c.rect(x, top, 1, min(g - top, (tall ? 12 : 4) * s + Int(noise(x / (4 * s) + 1833) * Double(8 * s))), lit)
            }
            c.px(x, top, edge)
        }
    }

    /// Tooth `side` (-1 left, 1 right) `k` of the way down from its tip to its foot: its middle, leaning in over the
    /// gate towards the tip, and its half-width, spreading at the foot.
    static func blackGateToothAt(_ c: PixelCanvas, _ g: Int, side: Int, _ k: Double) -> (cx: Int, hw: Int) {
        let gt = blackGateGate(c, g), th = blackGateTeeth(c, g)
        var hw = Int(Double(th.half) * pow(k, 0.55))
        if k > 0.85 { hw += Int((k - 0.85) * 3 * Double(th.half)) }
        return (gt.x + side * th.dx - side * Int(pow(1 - k, 2) * (Double(th.half) * 0.9)), hw)
    }

    /// Tooth `side`'s red windows: the big one under its crown first, then the slits further down.
    static func blackGateWindows(_ c: PixelCanvas, _ g: Int, side: Int) -> [(x: Int, y: Int, w: Int, h: Int)] {
        let s = unit(g), tall = isTall(c), th = blackGateTeeth(c, g)
        let span = max(1, th.base - th.tip), cy = th.tip + span / 3
        let wy = cy + (tall ? 6 : 3) * s
        let crown = blackGateToothAt(c, g, side: side, Double(cy - th.tip) / Double(span))
        var out: [(x: Int, y: Int, w: Int, h: Int)] = [(crown.cx - s, wy, 2 * s, (tall ? 3 : 2) * s)]
        for i in 0..<(tall ? 5 : 2) {
            let y = wy + (tall ? 18 : 9) * s * (i + 1)
            guard y < th.base - 4 * s else { continue }
            let a = blackGateToothAt(c, g, side: side, Double(y - th.tip) / Double(span))
            out.append((a.cx + Int((noise(i + side * 7 + 1840) - 0.5) * Double(a.hw)), y, s, 2 * s))
        }
        return out
    }

    /// One of the Teeth: a fang-like tower tapering to a point and leaning in over the gate, a spiked crown a third
    /// of the way down, spurs along its flanks, red slit windows, and its foot spreading into the rock.
    static func blackGateTooth(_ c: PixelCanvas, _ g: Int, side: Int) {
        let s = unit(g), tall = isTall(c), th = blackGateTeeth(c, g)
        let black = C(0x0B0808), lit = C(0x6A2C1A), rim = C(0x241210)
        func centre(_ k: Double) -> Int { blackGateToothAt(c, g, side: side, k).cx }
        func halfAt(_ k: Double) -> Int { blackGateToothAt(c, g, side: side, k).hw }
        let span = max(1, th.base - th.tip)
        for y in th.tip..<max(th.tip, th.base) {
            let k = Double(y - th.tip) / Double(span), cx = centre(k), hw = halfAt(k)
            c.rect(cx - hw, y, hw * 2 + 1, 1, black)
            // the face towards the gate catches the glow
            c.px(side < 0 ? cx + hw : cx - hw, y, lit)
            c.px(side < 0 ? cx - hw : cx + hw, y, rim)
        }
        // spurs up the flanks, pointing up and out
        let spurLen = (tall ? 5 : 2) * s
        for y in stride(from: th.base - (tall ? 14 : 6) * s, to: th.tip + span / 3, by: -(tall ? 20 : 9) * s) {
            let k = Double(y - th.tip) / Double(span), cx = centre(k), hw = halfAt(k)
            for dir in [-1, 1] {
                for j in 0..<max(1, spurLen / s) {
                    c.rect(cx + dir * (hw + j * s) - (dir < 0 ? s : 0), y - j * s, s, 2 * s, black)
                }
            }
        }
        // the crown: a jutting band with spikes
        let cy = th.tip + span / 3, ck = Double(cy - th.tip) / Double(span)
        let ccx = centre(ck), chw = halfAt(ck) + (tall ? 4 : 2) * s
        c.rect(ccx - chw, cy, chw * 2 + 1, (tall ? 3 : 2) * s, black)
        c.rect(ccx - chw, cy, chw * 2 + 1, s, rim)
        let spike = (tall ? 6 : 3) * s
        for sx in stride(from: ccx - chw, through: ccx + chw, by: max(s, chw / 2)) {
            for j in 0..<max(1, spike / s) { c.rect(sx, cy - (j + 1) * s, max(s, (spike / s - j) * s / 2), s, black) }
        }
        // the red window under the crown, and slits further down
        for (i, w) in blackGateWindows(c, g, side: side).enumerated() {
            if i == 0 { c.ellipse(ccx, w.y + s, 4 * s, 3 * s, C(0xC8401A, 0.18)) }
            c.rect(w.x, w.y, w.w, w.h, i == 0 ? C(0xE8501E) : C(0xC8401A, 0.85))
        }
    }

    /// The gate itself: two leaves of black iron plate, ribbed and riveted, banded across, with the dark seam where
    /// they meet, framed by black posts and a rampart bristling with spikes.
    static func blackGateDoors(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), gt = blackGateGate(c, g)
        let frame = C(0x120D0C), plate = C(0x1C1513), rib = C(0x2A201B), ribLit = C(0x4E342A), rivet = C(0x7A5442)
        let x0 = gt.x - gt.half, x1 = gt.x + gt.half
        guard gt.base > gt.top else { return }
        // the leaves
        c.rect(x0, gt.top, x1 - x0, gt.base - gt.top, plate)
        let ribGap = (tall ? 9 : 6) * s
        for x in stride(from: x0 + ribGap / 2, to: x1, by: ribGap) {
            c.rect(x, gt.top, s, gt.base - gt.top, rib)
            c.rect(x - s, gt.top, s, gt.base - gt.top, C(0x120E0C))
            c.px(x, gt.top, ribLit)
        }
        for k in [0.18, 0.5, 0.82] {
            let y = gt.top + Int(Double(gt.base - gt.top) * k), bh = (tall ? 3 : 2) * s
            c.rect(x0, y, x1 - x0, bh, rib)
            c.rect(x0, y, x1 - x0, s, ribLit)
            for x in stride(from: x0 + 2 * s, to: x1, by: (tall ? 5 : 4) * s) { c.rect(x, y + bh - s, s, s, rivet) }
            if tall {
                // short spikes jutting from the middle band
                if k == 0.5 { for x in stride(from: x0 + 4 * s, to: x1 - 2 * s, by: 8 * s) { c.rect(x, y - 2 * s, s, 2 * s, ribLit) } }
            }
        }
        // the seam between the leaves, and the great bar across it
        c.rect(gt.x - s, gt.top, 2 * s, gt.base - gt.top, C(0x050303))
        let barY = gt.top + Int(Double(gt.base - gt.top) * 0.5) - s
        c.rect(gt.x - (tall ? 10 : 5) * s, barY, (tall ? 20 : 10) * s, (tall ? 4 : 3) * s, frame)
        c.rect(gt.x - (tall ? 10 : 5) * s, barY, (tall ? 20 : 10) * s, s, ribLit)
        // the posts at either side, and the foot's shadow
        for px in [x0 - 3 * s, x1 - s] {
            c.rect(px, gt.top, 4 * s, gt.base - gt.top, frame)
            c.rect(px, gt.top, s, gt.base - gt.top, C(0x2E1C16))
        }
        c.rect(x0, gt.base - s, x1 - x0, s, C(0x080505))
        // the rampart over the gate, bristling with spikes
        let ramp = (tall ? 8 : 4) * s, ry = gt.top - ramp
        c.rect(x0 - 4 * s, ry, x1 - x0 + 8 * s, ramp, frame)
        c.rect(x0 - 4 * s, ry, x1 - x0 + 8 * s, s, C(0x4A2418))
        c.rect(x0 - 4 * s, gt.top - s, x1 - x0 + 8 * s, s, C(0x080505))
        let spike = (tall ? 7 : 4) * s
        for sx in stride(from: x0 - 3 * s, to: x1 + 4 * s, by: (tall ? 6 : 4) * s) {
            for j in 0..<max(1, spike / s) {
                let w = max(s, (2 * s) - j * 2 * s / max(1, spike / s))
                c.rect(sx, ry - (j + 1) * s, w, s, frame)
            }
        }
    }

    /// The plain before the gate on tall screens: slag heaps, pools of black water, and broken spears stuck in the
    /// dust from old battles.
    static func blackGatePlain(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), gt = blackGateGate(c, g)
        let y0 = gt.base + 6 * s, room = g - 10 * s - y0
        guard room > 4 * s else { return }
        for i in 0..<max(1, c.w / (70 * s)) {
            let x = Int(noise(i * 4 + 1850) * Double(c.w)), y = y0 + Int(noise(i * 4 + 1851) * Double(room))
            let near: Double = Double(y - y0) / Double(max(1, room))
            let rx = Int((8 + 14 * near) * Double(s)), ry = max(s, rx / 3)
            if noise(i * 4 + 1852) > 0.5 {
                // a slag heap
                c.ellipse(x, y, rx, ry, C(0x241A16))
                c.ellipse(x - rx / 4, y - ry / 2, rx / 2, max(1, ry / 2), C(0x342620))
                c.rect(x - rx, y, rx * 2 + 1, ry + 1, C(0x3A2C25))
            } else {
                // a pool of black water with the sky's red in it
                c.ellipse(x, y, rx, max(1, ry / 2), C(0x0E0A0A))
                c.rect(x - rx / 2, y, rx / 2, s, C(0x7A3422, 0.6))
            }
        }
        // broken spears, leaning
        for i in 0..<max(1, c.w / (50 * s)) {
            let x = Int(noise(i * 3 + 1860) * Double(c.w)), y = y0 + Int(noise(i * 3 + 1861) * Double(room + 6 * s))
            let len = (6 + Int(noise(i * 3 + 1862) * 8.0)) * s, lean = noise(i * 3 + 1863) > 0.5 ? 1 : -1
            for k in 0..<max(0, len / s) { c.rect(x + lean * (k / 3) * s, y - k * s, s, s, C(0x2A1E18)) }
        }
    }

    /// The red glow over the pass breathing, the Teeth's windows pulsing, and ash drifting down.
    static func blackGateLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), gt = blackGateGate(c, g)
        let twoPi: Double = 2 * Double.pi
        // the glow: only in the sky over the gate, between the mountains and above the rampart's spikes
        let breath: Double = 0.5 + 0.5 * sin(t * twoPi / 6)
        let clip = gt.top - (tall ? 16 : 9) * s
        for (k, a) in [(1.0, 0.025), (0.75, 0.025), (0.5, 0.03)] {
            let rx = Double(gt.half - 2 * s) * k, ry = max(1, Int(Double(gt.top) * 0.9 * k))
            let y0 = max(0, gt.top - ry)
            for y in y0..<max(y0, clip) {
                let dy = Double(gt.top - y) / Double(ry), w = Int(rx * max(0, 1 - dy * dy).squareRoot())
                c.rect(gt.x - w, y, w * 2, 1, C(0xE0581E, a * breath))
            }
        }
        // the windows, each pulsing in its own time
        for side in [-1, 1] {
            for (i, w) in blackGateWindows(c, g, side: side).enumerated() {
                let p: Double = 0.5 + 0.5 * sin(t * twoPi / 3.5 + Double(i) * 1.9 + Double(side) * 0.8)
                if i == 0 {
                    c.ellipse(w.x + w.w / 2, w.y + s, 5 * s, 4 * s, C(0xE8501E, 0.06 + 0.14 * p))
                    c.rect(w.x, w.y, w.w, w.h, C(0xFFB03A, 0.15 + 0.6 * p))
                } else {
                    c.rect(w.x, w.y, w.w, w.h, C(0xFF7A30, 0.1 + 0.5 * p))
                }
            }
        }
        // ash, settling out of the air well above the crew's heads
        let low = max(1, tall ? g - 14 * s : gt.base - s)
        for i in 0..<(tall ? 60 : 22) {
            let fall: Double = (4 + noise(i * 4 + 1960) * 6) * Double(s), drift: Double = (2 + noise(i * 4 + 1961) * 4) * Double(s)
            let x = Int((noise(i * 4 + 1962) * Double(c.w) + t * drift).truncatingRemainder(dividingBy: Double(max(1, c.w))))
            let y = Int((noise(i * 4 + 1963) * Double(low) + t * fall).truncatingRemainder(dividingBy: Double(low)))
            c.rect(x + Int(sin(t * 1.5 + Double(i)) * Double(s)), y, s, s, C(noise(i * 4 + 1964) > 0.7 ? 0xB8A090 : 0x5A4A44, 0.55))
        }
    }
}
