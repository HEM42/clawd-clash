import Foundation

// The wild places between the Shire and Rivendell: the Old Forest, the Barrow-downs and Weathertop.
let ringsScenes6: [Location: Place] = [
    .oldForest: Place(name: "The Withy-windows", panel: 0x16200E, still: Scenes.oldForest, moving: Scenes.oldForestLife),
    .barrowDowns: Place(name: "The Barrow-downtimes", panel: 0x181C1E, still: Scenes.barrowDowns,
                        moving: Scenes.barrowDownsLife),
    .weathertop: Place(name: "Weather-htop", panel: 0x14161E, still: Scenes.weathertop, moving: Scenes.weathertopLife),
]

// MARK: - Shared bits for these scenes

/// A straight line of `s`-pixel dots.
private func r6Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// The top of a band of rolling hills drawn by `dunes` with the same numbers, at column `x`.
private func r6Swell(_ x: Int, base: Int, amp: Double, freq: Double, phase: Double) -> Int {
    base - Int((sin(Double(x) * freq + phase) * 0.6 + sin(Double(x) * freq * 2.3 + phase * 1.7) * 0.4) * amp)
}

/// An old crack willow leaning over the water: a fissured grey trunk rising from (x, base) and bending `lean` pixels
/// sideways, a heavy grey-green crown, and long curtains of leaves trailing down toward row `hang`. `haze` fades it
/// into the golden afternoon air the further off it stands.
private func r6Willow(_ c: PixelCanvas, x: Int, base: Int, h: Int, lean: Int, hang: Int, s: Int, seed: Int,
                      haze: Double = 0) {
    guard h > 4 * s else { return }
    func tone(_ hex: UInt32, _ a: Double = 1) -> Px { lerp(C(hex), C(0xE2D49A), haze).alpha(a) }
    let trunkH = h * 11 / 20, top = base - trunkH
    let (cx, cy, rx, ry) = r6Crown(x: x, base: base, h: h, lean: lean, s: s)
    // the trunk, thick at the foot and bending over the river
    for y in top..<max(top, base) {
        let k = Double(base - y) / Double(max(1, trunkH))
        let tx = x + Int(Double(lean) * pow(k, 1.6))
        let flare = k < 0.15 ? Double(3 * s) * (0.15 - k) / 0.15 : 0
        let half = max(s, Int(Double(h) * (0.065 - 0.03 * k) + flare))
        c.rect(tx - half, y, half * 2, 1, tone(0x5E5644))
        c.rect(tx - half, y, max(1, half / 3), 1, tone(0x8E846A))
        c.rect(tx + half - s, y, s, 1, tone(0x3C362A))
        if noise(y / max(1, s) + seed * 131 + 7000) > 0.3 { c.rect(tx + half / 4, y, s, 1, tone(0x48412F)) }
    }
    // boughs up into the crown
    let bark = tone(0x5E5644)
    r6Line(c, cx, top + s, cx - rx / 2, cy + ry / 4, bark, s: 2 * s)
    r6Line(c, cx, top + s, cx + rx / 2, cy, bark, s: 2 * s)
    r6Line(c, cx, top + s, cx + rx / 8, cy - ry / 2, bark, s: 2 * s)
    // the crown: dark underneath, grey-green, silvery where the sun catches the leaves
    let blobs: [(Double, Double, Double, Double)] = [(-0.55, 0.15, 0.5, 0.6), (0.5, 0.2, 0.55, 0.6), (0, -0.25, 0.6, 0.7),
                                                     (-0.25, 0.3, 0.5, 0.5), (0.3, -0.1, 0.5, 0.6), (0, 0.35, 0.6, 0.45)]
    func blob(_ b: (Double, Double, Double, Double), dy: Int, shrink: Double, _ col: Px) {
        c.ellipse(cx + Int(b.0 * Double(rx)) - (shrink < 1 ? s * 2 : 0), cy + Int(b.1 * Double(ry)) + dy,
                  max(1, Int(b.2 * Double(rx) * shrink)), max(1, Int(b.3 * Double(ry) * shrink)), col)
    }
    for b in blobs { blob(b, dy: 2 * s, shrink: 1, tone(0x4E5A40)) }
    for b in blobs { blob(b, dy: 0, shrink: 1, tone(0x76845C)) }
    for b in blobs { blob(b, dy: -2 * s, shrink: 0.6, tone(0x98A47A)) }
    // the long curtains of leaves trailing down to the water
    for st in r6Strands(x: x, base: base, h: h, lean: lean, hang: hang, s: s, seed: seed) {
        let leaf = st.light ? tone(0xA6B282, 0.9) : tone(0x6E7C54, 0.9)
        c.rect(st.col, st.start, s, st.end - st.start, leaf)
        c.rect(st.col, st.end + s, s, s, leaf.alpha(0.5))
    }
}

/// A willow's crown: its middle, and how far it reaches each side and up and down.
private func r6Crown(x: Int, base: Int, h: Int, lean: Int, s: Int) -> (cx: Int, cy: Int, rx: Int, ry: Int) {
    let top = base - h * 11 / 20, ry = max(s, h / 5)
    return (x + lean, top - ry / 3, max(2 * s, h * 2 / 5), ry)
}

/// A willow's curtains of leaves: for each `s`-wide column under its crown, where the strand starts and ends, and
/// whether it's one of the silvery ones.
private func r6Strands(x: Int, base: Int, h: Int, lean: Int, hang: Int, s: Int,
                       seed: Int) -> [(col: Int, start: Int, end: Int, light: Bool)] {
    let (cx, cy, rx, ry) = r6Crown(x: x, base: base, h: h, lean: lean, s: s)
    var out: [(col: Int, start: Int, end: Int, light: Bool)] = [], i = 0
    for col in stride(from: cx - rx, to: cx + rx, by: s) {
        i += 1
        let dx = Double(col - cx) / Double(rx)
        let start = cy + Int(Double(ry) * (1 - dx * dx).squareRoot() * 0.5)
        let reach = Double(max(0, hang - start)) * (0.45 + 0.55 * noise(i + seed * 97 + 7100)) * (1 - 0.35 * abs(dx))
        out.append((col, start, start + Int(reach), noise(i + seed * 97 + 7200) > 0.6))
    }
    return out
}

/// Where a repeating motion of `period` seconds is, from 0 up to 1.
private func r6Phase(_ t: Double, _ period: Double, offset: Double = 0) -> Double {
    let v = (t + offset).truncatingRemainder(dividingBy: period) / period
    return v < 0 ? v + 1 : v
}

/// How strongly a now-and-then event is showing: 0 most of the time, rising and falling as sin² over the first `on`
/// of each cycle of `period` seconds.
private func r6Now(_ t: Double, _ period: Double, on: Double, offset: Double = 0) -> Double {
    let p = r6Phase(t, period, offset: offset)
    guard p < on else { return 0 }
    let v = sin(Double.pi * p / on)
    return v * v
}

/// A standing stone `h` rows tall and `w` wide on row `base`, its top leaning `lean` pixels, lit from the right.
private func r6Stone(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, lean: Int, s: Int,
                     body: Px, light: Px, dark: Px) {
    guard h > 0 else { return }
    for y in (base - h)..<base {
        let k = Double(base - y) / Double(h)
        let cx = x + Int(Double(lean) * k)
        var half = max(1, Int(Double(w) / 2 * (1 - 0.2 * k)))
        if k > 0.82 { half = max(1, Int(Double(half) * (1 - (k - 0.82) / 0.18 * 0.6))) }
        c.rect(cx - half, y, half * 2, 1, body)
        c.rect(cx - half, y, s, 1, dark)
        c.rect(cx + half - s, y, s, 1, light)
    }
}

/// A round barrow: a grassy dome `rx` each side and `ry` high, its foot on row `base`.
private func r6Barrow(_ c: PixelCanvas, x: Int, base: Int, rx: Int, ry: Int, s: Int, body: Px, top: Px) {
    guard rx > 0, ry > 0 else { return }
    for dx in -rx...rx {
        let k = Double(dx) / Double(rx)
        let t = base - Int(Double(ry) * (1 - k * k).squareRoot())
        if t < base { c.rect(x + dx, t, 1, base - t, body); c.rect(x + dx, t, 1, s, top) }
    }
}

// MARK: - The Withy-windows

extension Scenes {
    /// The Withywindle's first row: its far bank on the strip, the foot of the far trees on tall screens.
    static func oldForestRiverTop(_ c: PixelCanvas, _ g: Int) -> Int {
        isTall(c) ? Int(Double(g) * 0.56) : g - 12 * unit(g)
    }

    /// The river's left and right edges on row `y`: right across the strip, and on tall screens a brown ribbon
    /// winding down out of the trees, widening as it comes near.
    static func oldForestRiver(_ c: PixelCanvas, _ g: Int, _ y: Int) -> (Int, Int) {
        guard isTall(c) else { return (0, c.w) }
        let top = oldForestRiverTop(c, g), s = unit(g)
        let k = max(0, Double(y - top) / Double(max(1, g - top)))
        let mid = Double(c.w) * 0.5 + sin(k * 4.2 + 0.7) * Double(c.w) * 0.16 * (1 - k * 0.8)
        let half = Double(2 * s) + pow(k, 3) * Double(c.w) * 0.5
        return (Int(mid - half), Int(mid + half))
    }

    /// The Old Forest on a drowsy golden afternoon: hazy trees behind, the slow brown Withywindle right across the
    /// picture with water-lilies on it and reeds at its edges, and two old grey willows leaning over it from either
    /// side, their crowns overhead and their grey-green curtains trailing toward the water. Shafts of sun slant down
    /// full of dust motes, and the crew stands on the grassy near bank. On tall screens the river winds down out of
    /// the trees from a far green hill with Tom Bombadil's house on top, more willows line its banks, and the two
    /// great willows tower overhead.
    static func oldForest(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), rt = oldForestRiverTop(c, g)
        c.gradient(0, g, C(0xEEDFA2), C(0xD8C482), bands: tall ? 10 : 6)
        if tall {
            oldForestFar(c, g)
        } else {
            c.dunes(base: g - 30 * s, amp: Double(5 * s), freq: 0.03 / Double(s), phase: 0.7, bottom: g, C(0xBCB680),
                    shade: C(0xCEC892))
            c.dunes(base: g - 21 * s, amp: Double(4 * s), freq: 0.045 / Double(s), phase: 2.9, bottom: g, C(0xA2A26E),
                    shade: C(0xB6B47E))
            c.rect(0, rt - 2 * s, c.w, 2 * s, C(0x8E9852))
            r6Willow(c, x: Int(Double(c.w) * 0.33), base: rt - s, h: 30 * s, lean: 5 * s, hang: rt - s, s: s, seed: 4,
                     haze: 0.6)
            r6Willow(c, x: Int(Double(c.w) * 0.62), base: rt - s, h: 36 * s, lean: -6 * s, hang: rt - s, s: s, seed: 3,
                     haze: 0.55)
            for (k, f) in [0.15, 0.48, 0.8].enumerated() {
                oldForestReeds(c, Int(Double(c.w) * f), rt - s, s, seed: k + 10, scale: 0.5)
            }
        }
        oldForestWater(c, g)
        if tall { oldForestBankWillows(c, g) }
        // the two great willows leaning out over the river
        for w in oldForestGreatWillows(c, g) {
            r6Willow(c, x: w.x, base: g, h: w.h, lean: w.lean, hang: w.hang, s: s, seed: w.seed)
        }
        for (k, f) in [0.2, 0.71, 0.82].enumerated() { oldForestReeds(c, Int(Double(c.w) * f), g, s, seed: k + 20) }
        oldForestSunlight(c, g)
        c.ground(g, C(0x76863C), edge: C(0xA6B058), speck: C(0x5E6E2E), seed: 61)
        // grass tufts along the bank's lip
        for x in stride(from: 0, to: c.w, by: 3 * s) where noise(x / s + 7300) > 0.55 {
            c.rect(x, g - s, s, s, C(0x8E9E48))
        }
    }

    /// The two great willows leaning out over the river from either side: their foot, height, lean, how low their
    /// curtains hang, and their seed.
    static func oldForestGreatWillows(_ c: PixelCanvas, _ g: Int) -> [(x: Int, h: Int, lean: Int, hang: Int, seed: Int)] {
        let s = unit(g), tall = isTall(c)
        return [(Int(Double(c.w) * 0.07), tall ? g * 21 / 20 : g * 4 / 3, 14 * s, g - 4 * s, 1),
                (Int(Double(c.w) * 0.93), tall ? g * 9 / 10 : g * 6 / 5, -12 * s, g - 5 * s, 2)]
    }

    /// Tall screens: blue-gold hills far off, Tom's green hill with his white house on top, and the trees.
    static func oldForestFar(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), base = Int(Double(g) * 0.47)
        c.dunes(base: Int(Double(g) * 0.4), amp: Double(7 * s), freq: 0.012 / Double(s), phase: 2.0, bottom: g,
                C(0xCCCAA4), shade: C(0xDAD6B0))
        // Tom's hill
        let hx = Int(Double(c.w) * 0.56), hillTop = base - 16 * s
        c.ellipse(hx, base, 58 * s, 16 * s, C(0xB2B67E))
        c.ellipse(hx - 6 * s, base - s, 46 * s, 14 * s, C(0xBEC28A))
        for (k, dx) in [-44, -34, 30, 41].enumerated() {
            let tx = hx + dx * s, ty = base - 8 * s + (k % 2) * 3 * s
            c.rect(tx, ty, s, 3 * s, C(0x8A7E5E))
            c.circle(tx, ty - 2 * s, 3 * s, C(0x96A06A)); c.circle(tx - s, ty - 3 * s, 2 * s, C(0xA8B07A))
        }
        // the house: white walls, a thatched roof, a lit window and a thread of smoke
        c.rect(hx - 7 * s, hillTop - 5 * s, 14 * s, 6 * s, C(0xEEE6D0))
        c.rect(hx + 3 * s, hillTop - 11 * s, 2 * s, 4 * s, C(0x9A8E76))
        for j in 0..<4 { c.rect(hx - (5 + j) * s, hillTop - 9 * s + j * s, (10 + 2 * j) * s, s, C(0x9A8456)) }
        c.rect(hx - 8 * s, hillTop - 6 * s, 16 * s, s, C(0x7E6A44))
        c.rect(hx - 5 * s, hillTop - 3 * s, 2 * s, 2 * s, C(0xF6D45A))
        c.rect(hx + s, hillTop - 3 * s, 2 * s, 4 * s, C(0x6A8A4A))
        for j in 0..<6 {
            c.rect(hx + 4 * s + Int(sin(Double(j) * 1.3) * Double(s)), hillTop - 13 * s - j * 2 * s, s, 2 * s,
                   C(0xF4EEDC, 0.5 - Double(j) * 0.07))
        }
        // the forest below the hill, hazy, and the meadow down to the river
        c.dunes(base: base + 2 * s, amp: Double(5 * s), freq: 0.03 / Double(s), phase: 0.4, bottom: g, C(0xACAC78),
                shade: C(0xC0BE8A))
        c.dunes(base: base + 9 * s, amp: Double(5 * s), freq: 0.04 / Double(s), phase: 3.1, bottom: g, C(0x9A9E6A),
                shade: C(0xAEB07A))
        let meadow = oldForestRiverTop(c, g)
        c.gradient(meadow, g, C(0xA2A866), C(0x7E8C46), bands: 6)
        for i in 0..<(c.w / (14 * s)) {
            let y = meadow + 3 * s + Int(noise(i * 3 + 7400) * Double(max(0, g - meadow - 8 * s)))
            let k = Double(y - meadow) / Double(max(1, g - meadow))
            let r = max(s, Int(Double(4 * s) * (0.4 + k)))
            let x = Int(noise(i * 3 + 7401) * Double(c.w))
            c.ellipse(x, y, r * 2, r, lerp(C(0x6E7C44), C(0xA2A866), 0.5 - k * 0.5))
        }
    }

    /// The river itself, dull gold far off and brown near, with glints of sun and water-lilies.
    static func oldForestWater(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), rt = oldForestRiverTop(c, g)
        for y in rt..<max(rt, g) {
            let k = Double(y - rt) / Double(max(1, g - rt))
            let (x0, x1) = oldForestRiver(c, g, y)
            c.rect(x0, y, x1 - x0, 1, lerp(C(0xA88E58), C(0x5A4226), (k * 5).rounded(.down) / 5))
            if tall { c.rect(x0 - s, y, s, 1, C(0x5E5232)); c.rect(x1, y, s, 1, C(0x5E5232)) }
        }
        // slow glints of the sun on the water
        for i in 0..<(c.w * max(0, g - rt) / (110 * s * s)) {
            let y = rt + Int(noise(i * 3 + 7500) * Double(g - rt))
            let (x0, x1) = oldForestRiver(c, g, y)
            let len = (3 + Int(noise(i * 3 + 7502) * 9.0)) * s
            guard x1 - x0 > len + s else { continue }
            let x = x0 + Int(noise(i * 3 + 7501) * Double(x1 - x0 - len))
            c.rect(x, y, len, s, C(0xF2DC96, 0.3))
        }
        // water-lilies, some in flower
        for i in 0..<(c.w * max(0, g - rt) / ((tall ? 1100 : 420) * s * s)) {
            let y = rt + 2 * s + Int(noise(i * 3 + 7600) * Double(max(0, g - rt - 4 * s)))
            let k = Double(y - rt) / Double(max(1, g - rt))
            let (x0, x1) = oldForestRiver(c, g, y)
            let r = max(1, Int(Double(3 * s) * (tall ? 0.3 + 0.7 * k : 1)))
            guard x1 - x0 > 4 * r else { continue }
            let x = x0 + r * 2 + Int(noise(i * 3 + 7601) * Double(x1 - x0 - 4 * r))
            c.ellipse(x, y, r, max(1, r / 3), C(0x4E6E30))
            c.rect(x - r / 2, y - max(1, r / 3), r, 1, C(0x76944A))
            if noise(i * 3 + 7602) > 0.55 {
                c.rect(x, y - max(1, r / 3) - s, s, s, noise(i + 7603) > 0.5 ? C(0xF8F2E2) : C(0xF0B8C4))
            }
        }
    }

    /// Tall screens: smaller willows along both banks of the winding river, hazier the further off.
    static func oldForestBankWillows(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), rt = oldForestRiverTop(c, g)
        for (i, k) in [0.12, 0.3, 0.5].enumerated() {
            let y = rt + Int(Double(g - rt) * k)
            let (x0, x1) = oldForestRiver(c, g, y)
            let h = Int(Double(26 * s) + k * Double(70 * s)), left = i % 2 == 0
            let x = left ? x0 - 3 * s : x1 + 3 * s
            r6Willow(c, x: x, base: y, h: h, lean: (left ? 1 : -1) * h / 6, hang: y - s, s: s, seed: i + 30,
                     haze: 0.62 - k * 0.6)
            oldForestReeds(c, left ? x0 + 2 * s : x1 - 2 * s, y + s, s, seed: i + 40, scale: 0.4 + k)
        }
    }

    /// A clump of reeds and bulrushes standing on row `base`.
    static func oldForestReeds(_ c: PixelCanvas, _ x: Int, _ base: Int, _ s: Int, seed: Int, scale: Double = 1) {
        for j in 0..<7 {
            let n = seed * 41 + j * 3 + 7700
            let bx = x + Int(Double((j - 3) * 2 * s) * scale)
            let h = max(s, Int(Double((6 + Int(noise(n) * 10.0)) * s) * scale))
            let tip = bx + Int((noise(n + 1) - 0.5) * Double(4 * s) * scale)
            r6Line(c, bx, base - s, tip, base - h, j % 2 == 0 ? C(0x7A7E3A) : C(0x9C9C4C), s: s)
            if noise(n + 2) > 0.65 { c.rect(tip, base - h + s, s, max(s, Int(Double(3 * s) * scale)), C(0x5A3A20)) }
        }
    }

    /// The shafts of sun: where each one's left edge meets the top row (it slants right half a column a row), and
    /// its width.
    static func oldForestShafts(_ c: PixelCanvas, _ g: Int) -> [(x0: Int, wd: Int)] {
        let s = unit(g)
        return (0..<max(1, c.w / (120 * s))).map {
            (Int(noise($0 * 5 + 7800) * Double(c.w)) - g / 3, (8 + Int(noise($0 * 5 + 7801) * 14.0)) * s)
        }
    }

    /// Shafts of afternoon sun slanting down through the leaves, full of drifting dust.
    static func oldForestSunlight(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        for (i, (x0, wd)) in oldForestShafts(c, g).enumerated() {
            for y in 0..<g { c.rect(x0 + y / 2, y, wd, 1, C(0xFFEFB0, 0.09 - 0.04 * Double(y) / Double(g))) }
            for m in 0..<(g * wd / (70 * s * s)) {
                let y = Int(noise(i * 997 + m * 3 + 7900) * Double(max(0, g - 2 * s)))
                c.rect(x0 + y / 2 + Int(noise(i * 997 + m * 3 + 7901) * Double(wd)), y, s, s,
                       C(0xFFF6CC, 0.45 + 0.45 * noise(i * 997 + m * 3 + 7902)))
            }
        }
    }

    /// Glints of sun on the river sliding slowly downstream and winking out, the great willows' curtains swaying as
    /// a breath of air passes through them, and dust motes drifting down the shafts of sun.
    static func oldForestLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), rt = oldForestRiverTop(c, g), twoPi: Double = 2 * Double.pi
        // the glints: each one shows for a few seconds, drifting right, then turns up somewhere else
        let span = max(0, g - rt - 2 * s)
        for i in 0..<min(tall ? 60 : 24, c.w * span / (300 * s * s)) {
            let period = 3 + noise(i * 5 + 7950) * 3, off = noise(i * 5 + 7951) * period
            let p = r6Phase(t, period, offset: off), n = Int(floor((t + off) / period)) * 131 + i * 5 + 7960
            let y = rt + s + Int(noise(n) * Double(span))
            let (x0, x1) = oldForestRiver(c, g, y)
            let near = tall ? 0.4 + 0.6 * Double(y - rt) / Double(max(1, g - rt)) : 1
            let len = max(s, Int(Double((3 + Int(noise(n + 1) * 7.0)) * s) * near))
            guard x1 - x0 > len + 8 * s else { continue }
            let x = x0 + Int(noise(n + 2) * Double(x1 - x0 - len - 8 * s)) + Int(p * Double(6 * s))
            let a = sin(Double.pi * p)
            c.rect(x, y, len, s, C(0xFAE8AE, 0.45 * a * a))
        }
        // the curtains: every other strand's lower half swings out a little, most at its tip
        for w in oldForestGreatWillows(c, g) {
            let strands = r6Strands(x: w.x, base: g, h: w.h, lean: w.lean, hang: w.hang, s: s, seed: w.seed)
            for (j, st) in strands.enumerated() where j % 2 == 0 && st.end - st.start > 6 * s {
                let a: Double = t * twoPi / 6 - Double(st.col) / Double(28 * s)
                let sway = sin(a) * Double((tall ? 3 : 2) * s)
                let leaf = st.light ? C(0xA6B282, 0.9) : C(0x6E7C54, 0.9), from = (st.start + st.end) / 2
                for k in 0..<3 {
                    let dx = Int((sway * Double(k + 1) / 3).rounded())
                    let y0 = from + (st.end - from) * k / 3, y1 = from + (st.end - from) * (k + 1) / 3
                    if dx != 0 { c.rect(st.col + dx, y0, s, y1 - y0, leaf) }
                }
                c.rect(st.col + Int(sway.rounded()), st.end + s, s, s, leaf.alpha(0.5))
            }
        }
        // the motes, drifting slowly down each shaft and twinkling, fading out before the ground
        let range = Double(max(1, g - 10 * s)), fade = Double(8 * s)
        for (i, sh) in oldForestShafts(c, g).enumerated() {
            for m in 0..<(tall ? 10 : 4) {
                let n = i * 97 + m * 5 + 8900
                let fall = Double(s) * (1.5 + 2.5 * noise(n))
                let yy = (noise(n + 1) * range + t * fall).truncatingRemainder(dividingBy: range), y = Int(yy)
                let x = sh.x0 + y / 2 + Int(noise(n + 2) * Double(sh.wd)) + Int(sin(t * 0.6 + Double(m) * 2.1) * Double(2 * s))
                let tw = 0.5 + 0.5 * sin(t * (1 + noise(n + 3)) + Double(m))
                let edge = max(0, min(1, yy / fade, (range - yy) / fade))
                c.rect(x, y, s, s, C(0xFFF6CC, (0.25 + 0.6 * tw) * edge))
            }
        }
    }
}

// MARK: - The Barrow-downtimes

extension Scenes {
    /// The Barrow-downs in a cold fog: grey-green downs rolling away in bands, each fainter than the one before, with
    /// mist lying in the hollows, round barrows and standing stones on their crests, and a pale sun hanging low in
    /// the murk. Nearest, a great barrow with a dark doorway under a stone lintel, and a lone leaning stone across
    /// the turf where the crew stands. On tall screens the downs fade away much further into the fog, with a ring of
    /// stones on a far crest.
    static func barrowDowns(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), fog = C(0xC4CCC2)
        c.gradient(0, g, C(0x7C8886), fog, bands: tall ? 10 : 6)
        // the pale sun, low in the fog
        let (sx, sy, sr) = barrowDownsSun(c, g)
        c.circle(sx, sy, sr * 4, C(0xE6EAE0, 0.07))
        c.circle(sx, sy, sr * 2, C(0xE6EAE0, 0.12))
        c.circle(sx, sy, sr, C(0xF0F2E8, 0.75))
        wisp(c, sx - sr, sy + sr / 3, sr * 5, C(0xAEB8B0, 0.55), s: s)
        for i in 0..<(tall ? 8 : 3) {
            let y = Int(noise(i * 3 + 8000) * Double(tall ? g / 3 : max(1, g - 30 * s)))
            wisp(c, Int(noise(i * 3 + 8001) * Double(c.w)), y, (40 + Int(noise(i * 3 + 8002) * 80.0)) * s,
                 C(0xD2D8D0, 0.35), s: s)
        }
        // the downs, far to near
        let horizon = barrowDownsHorizon(c, g), n = tall ? 6 : 3
        for i in 0..<n {
            let k = Double(i) / Double(max(1, n - 1))
            let base = horizon + (g - 6 * s - horizon) * i / n
            let amp = Double((tall ? 3 + Int(6 * k) : 2 + Int(3 * k)) * s)
            let freq = (0.03 - 0.016 * k) / Double(s), phase = Double(i) * 1.9 + 0.5
            let col = lerp(C(0xA6B0A4), C(0x52603F), k), edge = lerp(C(0xB6C0B4), C(0x76845E), k)
            c.dunes(base: base, amp: amp, freq: freq, phase: phase, bottom: g, col, shade: edge)
            if tall && i == 1 { barrowDownsRing(c, g, base: base, amp: amp, freq: freq, phase: phase) }
            barrowDownsMounds(c, g, layer: i, k: k, base: base, amp: amp, freq: freq, phase: phase, col: col, edge: edge)
            // mist lying in the hollow at the foot of this swell
            let mh = (tall ? 12 : 5) * s
            for y in 0..<mh {
                let a: Double = Double(y) / Double(mh) * Double.pi
                c.rect(0, base - mh / 3 + y, c.w, 1, fog.alpha(0.3 * sin(a)))
            }
        }
        // drifting streaks of fog across the downs
        for i in 0..<(tall ? 6 : 2) {
            let y = horizon + Int(noise(i * 3 + 8100) * Double(max(0, g - horizon - 8 * s)))
            wisp(c, Int(noise(i * 3 + 8101) * Double(c.w)), y, (50 + Int(noise(i * 3 + 8102) * 70.0)) * s,
                 C(0xD6DCD4, 0.3), s: s)
        }
        barrowDownsTomb(c, g)
        c.ground(g, C(0x4E5A42), edge: C(0x6E7C5A), speck: C(0x3E4834), seed: 71)
        c.rect(0, g - 2 * s, c.w, 2 * s, fog.alpha(0.16))
    }

    /// The pale sun low in the fog: its middle and radius.
    static func barrowDownsSun(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, r: Int) {
        let s = unit(g), tall = isTall(c)
        return (Int(Double(c.w) * 0.7), tall ? Int(Double(g) * 0.28) : 11 * s, (tall ? 10 : 5) * s)
    }

    /// The row of the furthest downs.
    static func barrowDownsHorizon(_ c: PixelCanvas, _ g: Int) -> Int {
        isTall(c) ? Int(Double(g) * 0.42) : g - 28 * unit(g)
    }

    /// Round barrows and lone standing stones along the crest of one band of downs; `k` is how near it is.
    static func barrowDownsMounds(_ c: PixelCanvas, _ g: Int, layer: Int, k: Double, base: Int, amp: Double,
                                  freq: Double, phase: Double, col: Px, edge: Px) {
        let s = unit(g), stone = lerp(C(0x8A8E88), C(0xA8B0A8), 0.7 - k * 0.7)
        let light = lerp(C(0xB4B8B0), C(0xC0C8C0), 0.7 - k * 0.7), dark = lerp(C(0x5A5E5A), C(0x98A098), 0.7 - k * 0.7)
        let size = 0.55 + 1.1 * k
        for j in 0..<max(1, c.w / (70 * s)) {
            let nn = layer * 211 + j * 5 + 8200
            guard noise(nn) > 0.35 else { continue }
            let x = Int(noise(nn + 1) * Double(c.w)), top = r6Swell(x, base: base, amp: amp, freq: freq, phase: phase)
            if noise(nn + 2) > 0.3 {
                let rx = Int(Double((8 + Int(noise(nn + 3) * 10.0)) * s) * size), ry = max(s, rx * 2 / 5)
                r6Barrow(c, x: x, base: top + ry / 3, rx: rx, ry: ry, s: s, body: lerp(col, C(0x9AA88A), 0.2), top: edge)
                if noise(nn + 4) > 0.5 {
                    let h = max(2 * s, Int(Double((3 + Int(noise(nn + 5) * 4.0)) * s) * size))
                    r6Stone(c, x: x + rx / 4, base: top - ry * 2 / 3 + s, w: max(2 * s, h * 2 / 5), h: h, lean: 0, s: s,
                            body: stone, light: light, dark: dark)
                }
            } else {
                let h = max(2 * s, Int(Double((5 + Int(noise(nn + 5) * 5.0)) * s) * size))
                r6Stone(c, x: x, base: top + s, w: max(2 * s, h * 2 / 5), h: h, lean: Int((noise(nn + 6) - 0.5) * 4) * s,
                        s: s, body: stone, light: light, dark: dark)
            }
        }
    }

    /// Tall screens: a ring of standing stones on a far crest.
    static func barrowDownsRing(_ c: PixelCanvas, _ g: Int, base: Int, amp: Double, freq: Double, phase: Double) {
        let s = unit(g), x = Int(Double(c.w) * 0.32), y = r6Swell(x, base: base, amp: amp, freq: freq, phase: phase) + 2 * s
        let r = 16 * s
        // the far side of the ring first, then the near side
        for near in [false, true] {
            for j in 0..<10 {
                let a: Double = Double(j) / 10 * 2 * Double.pi
                guard (sin(a) > 0) == near else { continue }
                let h = (3 + Int(noise(j + 8300) * 3.0)) * s
                r6Stone(c, x: x + Int(cos(a) * Double(r)), base: y + Int(sin(a) * Double(r) / 4), w: 2 * s, h: h, lean: 0,
                        s: s, body: C(0x9EA6A0), light: C(0xBCC4BC), dark: C(0x8A928C))
            }
        }
    }

    /// The great barrow nearest the crew: its middle, and how far it reaches each side and up.
    static func barrowDownsMound(_ c: PixelCanvas, _ g: Int) -> (x: Int, rx: Int, ry: Int) {
        let s = unit(g), tall = isTall(c)
        return (Int(Double(c.w) * (tall ? 0.2 : 0.14)), (tall ? 72 : 38) * s, (tall ? 38 : 20) * s)
    }

    /// The great barrow's doorway, standing on the ground row: its middle, height and width.
    static func barrowDownsDoor(_ c: PixelCanvas, _ g: Int) -> (x: Int, h: Int, w: Int) {
        let (x, rx, ry) = barrowDownsMound(c, g)
        return (x + rx / 5, ry * 11 / 20, max(2 * unit(g), ry * 2 / 5))
    }

    /// The great barrow nearest the crew with its dark doorway, and a lone leaning stone across the turf.
    static func barrowDownsTomb(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), d = tall ? 2 : 1
        let (x, rx, ry) = barrowDownsMound(c, g)
        r6Barrow(c, x: x, base: g, rx: rx, ry: ry, s: s, body: C(0x56644A), top: C(0x76865E))
        // the shadowed side and a scatter of tussocks
        for dx in stride(from: -rx, to: -rx / 4, by: 1) {
            let k = Double(dx) / Double(rx), t = g - Int(Double(ry) * (1 - k * k).squareRoot())
            if t + s < g { c.rect(x + dx, t + s, 1, g - t - s, C(0x2E382A, 0.18 + 0.2 * abs(k))) }
        }
        for i in 0..<(rx * ry / (14 * s * s)) {
            let k = noise(i * 3 + 8400) * 2 - 1, t = g - Int(Double(ry) * (1 - k * k).squareRoot())
            guard t + 2 * s < g else { continue }
            let y = t + 2 * s + Int(noise(i * 3 + 8401) * Double(g - t - 2 * s))
            c.rect(x + Int(k * Double(rx)), y, s, s, noise(i * 3 + 8402) > 0.5 ? C(0x6A7A56) : C(0x46523C))
        }
        // the doorway, a little right of the middle: a dark passage between two jamb stones under a lintel
        let (dx0, dh, dw) = barrowDownsDoor(c, g), j = 3 * s * d
        c.rect(dx0 - dw / 2, g - dh, dw, dh, C(0x0C0E10))
        c.rect(dx0 - dw / 2, g - dh, dw, 2 * s * d, C(0x1C201E))
        c.rect(dx0 - dw / 2 - j, g - dh, j, dh, C(0x7A7E78))
        c.rect(dx0 - dw / 2 - j, g - dh, s, dh, C(0x5A5E5A))
        c.rect(dx0 + dw / 2, g - dh, j, dh, C(0x6E726C))
        c.rect(dx0 + dw / 2 + j - s, g - dh, s, dh, C(0x9EA29A))
        let lt = 2 * s * d
        c.rect(dx0 - dw / 2 - j - 2 * s, g - dh - lt, dw + 2 * j + 4 * s, lt, C(0x868A82))
        c.rect(dx0 - dw / 2 - j - 2 * s, g - dh - lt, dw + 2 * j + 4 * s, s, C(0xA8ACA4))
        // a stone on the barrow's crown
        let sx = x - rx / 3, st = g - Int(Double(ry) * (1 - 1.0 / 9).squareRoot())
        r6Stone(c, x: sx, base: st + 2 * s, w: 5 * s * d, h: 12 * s * d, lean: -s, s: s,
                body: C(0x80847E), light: C(0xA6AAA2), dark: C(0x5E625C))
        // the lone leaning stone
        r6Stone(c, x: Int(Double(c.w) * 0.87), base: g + s, w: 7 * s * d, h: 22 * s * d, lean: 3 * s * d, s: s,
                body: C(0x7A7E78), light: C(0xA2A69E), dark: C(0x52564F))
        for i in 0..<5 {
            c.rect(Int(Double(c.w) * 0.87) + (i * 2 - 4) * s * d, g - s - (i % 2) * s, s, 2 * s, C(0x8A9A6A))
        }
    }

    /// Banks of fog drifting slowly across the downs (one of them over the sun), and now and then a faint cold
    /// light welling up deep in the barrow's doorway and dying away.
    static func barrowDownsLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), horizon = barrowDownsHorizon(c, g), sun = barrowDownsSun(c, g)
        let th = tall ? 2 * s : s
        for i in 0..<(tall ? 7 : 3) {
            let n = i * 5 + 8500
            let len = (tall ? 120 + Int(noise(n) * 140.0) : 70 + Int(noise(n) * 80.0)) * s
            let y = i == 0 ? sun.y + sun.r / 2
                : horizon - 4 * s + Int(noise(n + 1) * Double(max(0, g - horizon - 8 * s)))
            let v = Double(s) * (2 + 4 * noise(n + 2)) * (i % 2 == 0 ? 1 : -1)
            let range = Double(c.w + 2 * len)
            var at = (noise(n + 3) * range + t * v).truncatingRemainder(dividingBy: range)
            if at < 0 { at += range }
            r6Fog(c, Int(at) - len, y, len, th, C(0xD6DCD4), i == 0 ? 0.3 : 0.22)
        }
        // the cold light in the doorway
        let e = r6Now(t, 11, on: 0.4, offset: 3) * (0.85 + 0.15 * sin(t * 7))
        guard e > 0.01 else { return }
        let d = barrowDownsDoor(c, g), lintel = 2 * s * (tall ? 2 : 1), top = g - d.h + lintel
        c.ellipse(d.x, g - d.h / 2, d.w + 6 * s, d.h / 2, C(0x9EE8D0, 0.06 * e))
        c.rect(d.x - d.w / 2, top, d.w, g - top, C(0x7ED8C0, 0.16 * e))
        c.ellipse(d.x, g - d.h / 3, max(1, d.w / 4), max(1, d.h / 5), C(0xB8F4E4, 0.35 * e))
    }
}

/// A long bank of fog `len` wide centred on x and row y, `th` rows to a layer: thickest in the middle, thinning and
/// fading toward its ends and its top and bottom, a little slanted.
private func r6Fog(_ c: PixelCanvas, _ x: Int, _ y: Int, _ len: Int, _ th: Int, _ col: Px, _ a: Double) {
    for (k, f) in [0.45, 0.75, 1, 0.8, 0.5].enumerated() {
        let w = Int(Double(len) * f), dk = abs(k - 2)
        c.rect(x - w / 2 + (k - 2) * len / 14, y + (k - 2) * th, w, th, col.alpha(a * (1 - 0.3 * Double(dk))))
    }
}

// MARK: - Weather-htop

/// Smooth noise in 0..<1 along x: one value per whole step, eased between them.
private func r6Smooth(_ x: Double, seed: Int) -> Double {
    let f = x - floor(x), i = Int(floor(x)), u = f * f * (3 - 2 * f)
    return noise(i + seed) * (1 - u) + noise(i + 1 + seed) * u
}

/// The tones of one kind of stone in the dusk: its face, its lit side, its shadowed side and its cracks.
private struct R6Tones {
    let body: Px, lit: Px, shade: Px, crack: Px

    /// Half way from its face to its lit side.
    var face: Px { lerp(body, lit, 0.35) }

    /// The same stone further off, sinking into the dusk air by `k`.
    func far(_ k: Double) -> R6Tones {
        R6Tones(body: lerp(body, r6Air, k), lit: lerp(lit, r6Air, k), shade: lerp(shade, r6Air, k),
                crack: lerp(crack, r6Air, k))
    }
}

/// The hill's dark grey-brown rock, the old tower's weathered masonry, and the dusk air things fade into.
private let r6Rock = R6Tones(body: C(0x36332F), lit: C(0x7A7062), shade: C(0x221F1C), crack: C(0x141210))
private let r6Masonry = R6Tones(body: C(0x46464C), lit: C(0x9A9282), shade: C(0x2A2A30), crack: C(0x18181C))
private let r6Air = C(0x2A2A32)

/// The pale sky seen through the window holes, and the fire seen through one; the dead trees and their lit edge.
private let r6Hole = C(0x8A806A), r6FireHole = C(0xF08A3A), r6Tree = C(0x121214), r6TreeRim = C(0x7A7262)

/// A great weathered block, `w` wide and `h` tall on row `base`: worn round shoulders, a chipped top falling away by
/// `slope` of its height toward the right (or the left, if negative), cracks and a bedding seam, lit on the right.
private func r6Block(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, slope: Double = 0, s: Int, seed: Int,
                     _ t: R6Tones) {
    guard w > 0, h > 0 else { return }
    let edge = max(s, w / 6), litW = max(s, w / 5)
    var tops = [Int](repeating: base, count: w)
    for col in 0..<w {
        let u = (Double(col) + 0.5) / Double(w)
        let round = Double(min(w, h)) * 0.15 * pow(abs(2 * u - 1), 3)
        let fall = Double(h) * abs(slope) * (slope > 0 ? u : 1 - u)
        let chip = Int(noise(seed * 53 + col / max(1, 2 * s) + 9000) * 3.0) * s
        let top = base - h + Int(round + fall) + chip
        tops[col] = top
        guard top < base else { continue }
        c.rect(x + col, top, 1, base - top, col < edge ? t.shade : col >= w - litW ? t.lit : t.body)
        c.rect(x + col, top, 1, s, col < edge ? t.body : t.lit)
    }
    // a bedding seam, where it hasn't crumbled away
    let seam = base - h * 2 / 5, from = edge + Int(noise(seed + 9049) * Double(w / 3))
    for col in from..<max(from, min(w - litW, from + w / 2)) where tops[col] + 2 * s < seam && noise(seed + col / max(1, 3 * s) + 9050) > 0.25 {
        c.rect(x + col, seam, 1, max(1, s / 2), t.crack)
    }
    // cracks running down the face
    for j in 0..<max(1, w / (8 * s)) {
        let n = seed * 61 + j * 4 + 9100
        let col = min(w - 1, edge + Int(noise(n) * Double(max(1, w - edge - litW))))
        guard tops[col] + 4 * s < base else { continue }
        let y0 = tops[col] + s + Int(noise(n + 1) * Double((base - tops[col]) / 3))
        let len = max(s, Int(Double(base - y0) * (0.3 + 0.5 * noise(n + 2))))
        r6Line(c, x + col, y0, x + col + Int((noise(n + 3) - 0.5) * 4) * s, y0 + len - s, t.crack, s: s)
    }
}

/// A broken column `w` wide on a low plinth on row `base`, `h` tall at its highest: round-shaded drums with worn
/// seams, and a jagged break slanting down to the right (or to the left when `leftHigh` is false).
private func r6Pillar(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, leftHigh: Bool, s: Int, seed: Int,
                      _ t: R6Tones) {
    guard w > 0, h > 4 * s else { return }
    let plinth = 2 * s, foot = base - plinth, drum = max(3 * s, w)
    c.rect(x - s, foot, w + 2 * s, plinth, t.body)
    c.rect(x - s, foot, w + 2 * s, s, t.lit)
    c.rect(x - s, foot, s, plinth, t.shade)
    for col in 0..<w {
        let u = (Double(col) + 0.5) / Double(w)
        let fall = Int(Double(min(h / 2, w * 3 / 2)) * (leftHigh ? u : 1 - u))
        let chip = Int(noise(seed * 37 + col / max(1, s) + 9200) * 3.0) * s
        let top = min(foot - s, base - h + fall + chip)
        c.rect(x + col, top, 1, foot - top, u < 0.25 ? t.shade : u > 0.5 && u < 0.85 ? t.lit : t.body)
        c.rect(x + col, top, 1, s, t.lit)
        for y in stride(from: foot - drum, to: top + s, by: -drum) { c.rect(x + col, y, 1, max(1, s / 2), t.crack) }
    }
}

/// A crumbled arch on row `base`: two jambs `th` thick, `span` apart outside to outside, springing at height `h`.
/// Its ring still stands from the left jamb to a little past the crown, then breaks off raggedly; the right jamb is
/// a broken stump.
private func r6Arch(_ c: PixelCanvas, x: Int, base: Int, span: Int, h: Int, th: Int, s: Int, seed: Int,
                    _ t: R6Tones) {
    guard th > 0, span > 3 * th, h > 2 * th else { return }
    let spring = base - h, big = span / 2, small = max(1, big - th), cx = x + big
    r6Block(c, x: x, base: base, w: th, h: h + th / 2, s: s, seed: seed, t)
    r6Block(c, x: x + span - th, base: base, w: th, h: h * 3 / 4, slope: 0.4, s: s, seed: seed + 1, t)
    let end = big / 2 + Int(noise(seed + 9300) * Double(max(1, big / 4)))
    for dx in -big..<max(-big, end) {
        let outer = spring - Int(Double(big * big - dx * dx).squareRoot())
        let inner = abs(dx) < small ? spring - Int(Double(small * small - dx * dx).squareRoot()) : spring + th / 2
        let ragged = dx > end - 3 * s ? Int(noise(dx + seed * 7 + 9301) * Double(th)) : 0
        let y0 = outer + ragged
        guard y0 < inner else { continue }
        c.rect(cx + dx, y0, 1, inner - y0, dx > big / 3 ? t.lit : t.body)
        c.rect(cx + dx, y0, 1, s, t.lit)
        c.rect(cx + dx, inner - s, 1, s, t.shade)
    }
}

/// A craggy outcrop or boulder `rx` each side of x and up to `h` tall on row `base`: a fractured top, a shadowed
/// left face and a lit right one meeting at a ridge, and a crack down the middle.
private func r6Crag(_ c: PixelCanvas, x: Int, base: Int, rx: Int, h: Int, s: Int, seed: Int, _ t: R6Tones) {
    guard rx > 0, h > 0 else { return }
    let ridge = Int((noise(seed * 13 + 9400) - 0.3) * Double(rx) * 0.6)
    var ridgeTop = base
    for dx in -rx..<rx {
        let u = Double(dx) / Double(rx)
        let block = Double(Int(noise(seed * 13 + (dx + rx) / max(1, 2 * s) + 9401) * 3.0)) / 3
        let top = base - Int(Double(h) * pow(max(0, 1 - u * u), 0.5) * (0.7 + 0.3 * block))
        guard top < base else { continue }
        if dx == ridge { ridgeTop = top }
        c.rect(x + dx, top, 1, base - top, dx < -rx * 3 / 5 ? t.shade : dx > ridge ? t.lit : t.body)
        c.rect(x + dx, top, 1, s, dx > ridge ? lerp(t.lit, C(0xB4B4BC), 0.25) : t.lit)
    }
    if ridgeTop + 3 * s < base {
        r6Line(c, x + ridge, ridgeTop + 2 * s, x + ridge - s, base - s, t.crack, s: s)
    }
}

/// A broken tower stub (or a stretch of broken wall), `w` wide and up to `h` tall on row `base`: coursed masonry, a
/// ragged top of broken teeth falling away by `fall` of its height to the right (left, if negative), lit on the
/// right, and window holes at (across, up) fractions of it, showing their own colour through.
private func r6Tower(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, fall: Double, s: Int, seed: Int,
                     _ t: R6Tones, windows: [(Double, Double, Px)]) {
    guard w > 2 * s, h > 3 * s else { return }
    let edge = max(s, w / 6), litW = max(s, w / 4)
    var tops = [Int](repeating: base, count: w)
    for col in 0..<w {
        let u = (Double(col) + 0.5) / Double(w)
        let drop = Double(h) * abs(fall) * (fall > 0 ? u : 1 - u)
        let tooth = Int(noise(seed * 29 + col / max(1, 2 * s) + 11000) * 4.0) * s
        let top = min(base - s, base - h + Int(drop) + tooth)
        tops[col] = top
        c.rect(x + col, top, 1, base - top, col < edge ? t.shade : col >= w - litW ? t.lit : t.body)
        c.rect(x + col, top, 1, s, col < edge ? t.body : lerp(t.lit, C(0xB0B4C0), 0.2))
    }
    // the courses of masonry, worn away here and there, and a joint between two stones in each
    let course = 4 * s
    for (j, y) in stride(from: base - course, to: base - h, by: -course).enumerated() {
        for col in stride(from: edge, to: w - litW, by: s) where tops[col] + s < y && noise(seed * 7 + j * 31 + col / max(1, s) + 11100) > 0.35 {
            c.rect(x + col, y, s, max(1, s / 2), t.crack.alpha(0.6))
        }
        let jx = Int(noise(seed + j * 3 + 11200) * Double(w))
        if tops[jx] + s < y - course { c.rect(x + jx, y - course + s, max(1, s / 2), course - s, t.crack.alpha(0.5)) }
    }
    // the window holes: tall, narrow, round-headed, with a lit sill
    for win in windows {
        let ww = max(s, w / 5 / s * s), wh = 2 * ww + s
        let wx = x + Int(win.0 * Double(w)) - ww / 2, wy = base - Int(win.1 * Double(h)) - wh / 2
        let mid = min(w - 1, max(0, wx - x + ww / 2))
        guard tops[mid] + s < wy else { continue }
        c.rect(wx, wy, ww, wh, win.2)
        if ww >= 3 * s {
            c.rect(wx, wy, s, s, t.body)
            c.rect(wx + ww - s, wy, s, s, t.body)
            c.rect(wx + ww - s, wy + s, s, wh - s, t.shade.alpha(0.7))
        }
        c.rect(wx - s, wy + wh, ww + 2 * s, s, t.lit)
    }
}

/// A dead, twisted tree `h` tall from (x, base), leaning by `lean` radians: a gnarled trunk forking into crooked bare
/// limbs, each kinked half way, with a thin lit edge on its right.
private func r6DeadTree(_ c: PixelCanvas, x: Int, base: Int, h: Int, lean: Double, s: Int, seed: Int) {
    guard h > 6 * s else { return }
    var limbs: [(Int, Int, Int, Int, Int)] = []
    func grow(_ x0: Int, _ y0: Int, _ a: Double, _ len: Double, _ depth: Int, _ n: Int) {
        guard len >= Double(s) else { return }
        let bend = a + (noise(n + 11300) - 0.5) * 1.1
        let mx = x0 + Int(cos(bend) * len * 0.5), my = y0 - Int(sin(bend) * len * 0.5)
        let ex = mx + Int(cos(a) * len * 0.5), ey = my - Int(sin(a) * len * 0.5)
        let th = depth >= 4 ? 3 * s : depth >= 3 ? 2 * s : s
        limbs.append((x0, y0, mx, my, th)); limbs.append((mx, my, ex, ey, th))
        guard depth > 0 else { return }
        let spread = 0.35 + 0.4 * noise(n + 11301)
        grow(ex, ey, a + spread, len * (0.55 + 0.2 * noise(n + 11302)), depth - 1, n * 3 + 1)
        grow(ex, ey, a - spread * (0.6 + 0.6 * noise(n + 11303)), len * (0.5 + 0.25 * noise(n + 11304)), depth - 1,
             n * 3 + 2)
        if depth >= 2, noise(n + 11305) > 0.4 {
            grow(mx, my, a + (noise(n + 11306) > 0.5 ? 1.1 : -1.1), len * 0.4, depth - 2, n * 3 + 3)
        }
    }
    grow(x, base - 3 * s, Double.pi / 2 - lean, Double(h) * 0.42, 4, seed)
    for l in limbs { r6Line(c, l.0 + s, l.1, l.2 + s, l.3, r6TreeRim, s: l.4) }
    for l in limbs { r6Line(c, l.0, l.1, l.2, l.3, r6Tree, s: l.4) }
    // its roots gripping the stones
    c.rect(x - 2 * s, base - 2 * s, 7 * s, 2 * s, r6Tree)
}

/// A small campfire on row `y` among a ring of stones: crossed logs, low flames, and its warm glow `glow` across,
/// bright against the dusk.
private func r6Fire(_ c: PixelCanvas, x: Int, y: Int, s: Int, glow: Int) {
    c.circle(x, y - 4 * s, glow, C(0xFF8A3A, 0.1))
    c.circle(x, y - 4 * s, glow * 3 / 5, C(0xFF8A3A, 0.14))
    c.circle(x, y - 4 * s, glow * 3 / 10, C(0xFFA040, 0.2))
    for (k, dx) in [-4, -2, 2, 4].enumerated() { c.rect(x + dx * s, y - s - (k % 2) * s, 2 * s, s, C(0x5A5048)) }
    r6Line(c, x - 5 * s, y - s, x + 4 * s, y - 2 * s, C(0x4A3424), s: s)
    r6Line(c, x - 4 * s, y - 2 * s, x + 5 * s, y - s, C(0x5E4430), s: s)
    for f in r6Flames { c.rect(x + f.0 * s, y - 2 * s - f.1 * s, s, f.1 * s, C(f.2)) }
}

/// The campfire's flames, back to front: each one's column off the middle, its height in units, and its colour.
private let r6Flames: [(Int, Int, UInt32)] = [(-2, 4, 0xD0461E), (-1, 6, 0xE8661E), (0, 7, 0xF08A2A), (1, 5, 0xE8661E),
                                               (2, 3, 0xD0461E), (-1, 4, 0xF6C24A), (0, 5, 0xF6C24A), (0, 2, 0xFFF0B0)]

/// A long bank of cloud from x0 to x1 around row y: a lumpy top up to `thick` high, a flatter underside, its top edge
/// catching the light toward column `lightX` (fading out `reach` away) by up to `rimK`. With `only`, it draws just
/// the columns from `only.x0` to `only.x1`, each faded by the alpha `only.a` gives it (a flash lighting part of it).
private func r6Bank(_ c: PixelCanvas, x0: Int, x1: Int, y: Int, thick: Int, s: Int, seed: Int, body: Px, rim: Px,
                    lightX: Int, reach: Int, rimK: Double,
                    only: (x0: Int, x1: Int, a: (Int) -> Double)? = nil) {
    guard x1 > x0, thick > 0 else { return }
    let span = Double(x1 - x0), under = lerp(body, C(0x0A0C12), 0.3)
    for col in stride(from: x0, to: x1, by: s) {
        var body = body, rim = rim, under = under
        if let only {
            guard col >= only.x0, col < only.x1 else { continue }
            let a = only.a(col)
            guard a > 0 else { continue }
            body = body.alpha(a); rim = rim.alpha(a); under = under.alpha(a)
        }
        let u = Double(col - x0) / span
        let env = pow(max(0, sin(Double.pi * u)), 0.6)
        let lump = r6Smooth(Double(col) / Double(9 * s), seed: seed) * 0.65
            + r6Smooth(Double(col) / Double(3 * s), seed: seed + 50) * 0.35
        let up = Int(Double(thick) * env * (0.3 + 0.7 * lump)) / s * s
        let down = Int(Double(thick) * env * 0.3 * r6Smooth(Double(col) / Double(12 * s), seed: seed + 90)) / s * s
        guard up + down > 0 else { continue }
        let near = max(0, 1 - Double(abs(col - lightX)) / Double(max(1, reach)))
        c.rect(col, y - up, s, up + down, body)
        c.rect(col, y - up, s, s, lerp(body, rim, rimK * (0.25 + 0.75 * near)))
        if up > 3 * s { c.rect(col, y - up + s, s, s, lerp(body, rim, rimK * near * 0.45)) }
        c.rect(col, y + down - s, s, s, under)
    }
}

/// The tor on tall screens: its middle, the summit's row, the half-width of the summit and of the slabs' foot, the
/// row where the slabs end and the slope begins, the slope's half-width at its foot, and its foot's row.
private struct R6Tor {
    let x: Int, top: Int, crown: Int, waist: Int, base: Int, foot: Int, ground: Int, s: Int

    /// The slope's half-width on row `y` below the slabs, to the left or right: a shoulder at the slabs' foot,
    /// spreading out toward its own foot, its edge broken by rocks.
    func half(_ y: Int, right: Bool) -> Int {
        let k = max(0, min(1, Double(y - base) / Double(max(1, ground - base))))
        let jag = Int(r6Smooth(Double(y - base) / Double(5 * s), seed: right ? 11600 : 11700) * 4.0) * s
        return waist + 3 * s + Int(Double(max(0, foot - waist - 3 * s)) * pow(k, 1.5)) + jag
    }
}

/// One slab of the tor, rows y0..<y1, `l` and `r` out from its middle at its foot, its sides drawn in by `inL` and
/// `inR` at its top (out, if negative).
private struct R6Slab { let y0: Int, y1: Int, l: Int, r: Int, inL: Int, inR: Int }

/// The tor's stack of slabs from the summit down: each `minH`…`maxH` units thick, the stack widening toward its
/// foot, each slab jutting or tucked in by up to `jitter` units.
private func r6Slabs(_ t: R6Tor, seed: Int, minH: Int, maxH: Int, jitter: Int) -> [R6Slab] {
    let s = t.s, span = max(1, t.base - t.top)
    var out: [R6Slab] = [], y = t.top, i = 0
    while y < t.base {
        let n = seed + i * 5
        let h = max(2 * s, (minH + Int(noise(n) * Double(max(0, maxH - minH) + 1))) * s)
        let y1 = min(t.base, y + h)
        let k = Double((y + y1) / 2 - t.top) / Double(span)
        let bulge = (r6Smooth(Double(i) / 2.5, seed: seed + 7) - 0.5) * Double(6 * s)
        let w = Double(t.crown) + Double(t.waist - t.crown) * pow(max(0, k), 1.5) + bulge
        let l = Int(w) + Int((noise(n + 1) - 0.5) * Double(2 * jitter)) * s
        let r = Int(w) + Int((noise(n + 2) - 0.5) * Double(2 * jitter)) * s
        let inL = (Int(noise(n + 3) * 5.0) - 1) * s, inR = (Int(noise(n + 4) * 5.0) - 1) * s
        out.append(R6Slab(y0: y, y1: y1, l: max(s, l), r: max(s, r), inL: inL, inR: inR))
        y = y1; i += 1
    }
    return out
}

/// The slabs drawn: weathered round at their corners, shadowed on the left and lit on the right, a dark joint under
/// each, a lit top where one juts out beyond the slab above and a shadow where it's tucked in under it, a few joints
/// splitting it into blocks, and dry grass on the ledges.
private func r6DrawSlabs(_ c: PixelCanvas, _ t: R6Tor, _ slabs: [R6Slab], seed: Int) {
    let s = t.s, rock = r6Rock, face = rock.face, ledgeTop = lerp(rock.lit, C(0xB4B4BC), 0.15)
    for (i, sl) in slabs.enumerated() {
        let h = sl.y1 - sl.y0
        guard h > 0 else { continue }
        let above: R6Slab? = i > 0 ? slabs[i - 1] : nil
        let litW = max(s, sl.r / 3 + Int(noise(seed + i * 7) * Double(max(1, sl.r / 5))))
        let shadeW = max(s, sl.l / 4)
        let round = min(h / 2, 3 * s)
        for y in sl.y0..<sl.y1 {
            let d = (Double(y - sl.y0) + 0.5) / (Double(h) / 2) - 1
            let curve = 1 - max(0, 1 - d * d).squareRoot(), up = Double(sl.y1 - y) / Double(h)
            let x0 = t.x - sl.l + Int(Double(round) * curve) + Int(Double(sl.inL) * up)
            let x1 = t.x + sl.r - Int(Double(round) * curve) - Int(Double(sl.inR) * up)
            guard x1 > x0 else { continue }
            c.rect(x0, y, x1 - x0, 1, rock.body)
            c.rect(x0, y, min(shadeW, x1 - x0), 1, rock.shade)
            c.rect(max(x0, x1 - litW), y, min(litW, x1 - x0), 1, face)
            c.rect(x1 - s, y, s, 1, rock.lit)
            if y >= sl.y1 - s {
                for jx in stride(from: x0, to: x1, by: s) where noise(jx / s + i * 97 + seed) > 0.2 {
                    c.rect(jx, y, s, 1, rock.crack)
                }
            } else if y < sl.y0 + s {
                if let a = above {
                    if t.x + a.r < x1 { c.rect(t.x + a.r, y, x1 - t.x - a.r, 1, ledgeTop) }
                    if t.x - a.l > x0 { c.rect(x0, y, t.x - a.l - x0, 1, face) }
                } else {
                    c.rect(x0, y, x1 - x0, 1, face)
                }
            } else if y < sl.y0 + 3 * s, let a = above {
                // under the overhang of the slab above
                if a.r > sl.r + s { c.rect(t.x + sl.r / 3, y, max(0, x1 - t.x - sl.r / 3), 1, rock.crack.alpha(0.55)) }
                if a.l > sl.l + s { c.rect(x0, y, max(0, t.x - sl.l / 3 - x0), 1, rock.crack.alpha(0.55)) }
            }
        }
        // joints splitting it into blocks
        for j in 0..<((sl.l + sl.r) / (26 * s)) {
            let n = seed + i * 13 + j * 3
            let jx = t.x - sl.l + 7 * s + Int(noise(n) * Double(max(1, sl.l + sl.r - 14 * s)))
            let top = sl.y0 + Int(noise(n + 1) * Double(h / 2))
            c.rect(jx, top, s, max(0, sl.y1 - s - top), rock.crack.alpha(0.75))
            if jx > t.x { c.rect(jx + s, top, s, max(0, sl.y1 - s - top), rock.lit.alpha(0.25)) }
        }
        // a faint bedding line along a thick slab
        if h >= 8 * s {
            let y = sl.y0 + h / 2, from = t.x - sl.l / 2 + Int(noise(seed + i * 5 + 3) * Double(sl.l / 2))
            c.rect(from, y, (sl.l + sl.r) / 3, max(1, s / 2), rock.crack.alpha(0.35))
        }
        // dry grass and heather on the ledge where it juts out
        if let a = above {
            for (lo, hi) in [(t.x + a.r, t.x + sl.r - round), (t.x - sl.l + round, t.x - a.l)] where hi - lo > 3 * s {
                for tx in stride(from: lo + s, to: hi - s, by: s) where noise(tx / s + seed + i * 17) > 0.55 {
                    let hh = (1 + Int(noise(tx / s + seed + i * 17 + 1) * 2.0)) * s
                    c.rect(tx, sl.y0 - hh, s, hh, noise(tx / s + seed + 3) > 0.3 ? C(0x585A3A) : C(0x503E4E))
                }
            }
        }
    }
}

/// The slope under the slabs: rubble rock shadowed left and lit right, fallen slabs lying on it, and tufts of dry
/// grass and heather.
private func r6Slope(_ c: PixelCanvas, _ t: R6Tor, seed: Int) {
    let s = t.s, rock = r6Rock, span = max(1, t.ground - t.base)
    for y in t.base..<max(t.base, t.ground) {
        let hl = t.half(y, right: false), hr = t.half(y, right: true), x0 = t.x - hl, x1 = t.x + hr
        c.rect(x0, y, x1 - x0, 1, rock.body)
        c.rect(x0, y, max(s, hl / 4), 1, rock.shade)
        c.rect(x1 - hr / 3, y, hr / 3, 1, rock.face)
        c.rect(x1 - s, y, s, 1, rock.lit)
    }
    // fallen slabs lying on it
    for i in 0..<(c.w * span / (900 * s * s)) {
        let n = seed + i * 6
        let y = t.base + 3 * s + Int(noise(n) * Double(max(1, span - 5 * s)))
        let hl = t.half(y, right: false), hr = t.half(y, right: true)
        let bw = (5 + Int(noise(n + 2) * 10.0)) * s, bh = (2 + Int(noise(n + 3) * 3.0)) * s
        guard hl + hr > bw + 6 * s else { continue }
        let x = t.x - hl + 3 * s + Int(noise(n + 1) * Double(hl + hr - bw - 6 * s)), east = x > t.x + hr / 3
        c.rect(x, y - bh, bw, bh, east ? rock.face : rock.body)
        c.rect(x, y - bh, bw, s, east ? rock.lit : rock.face)
        c.rect(x, y - bh, s, bh, rock.shade)
        c.rect(x, y, bw, s, rock.crack)
    }
    // tufts of dry grass and heather
    for i in 0..<(c.w * span / (700 * s * s)) {
        let n = seed + i * 6 + 3000
        let y = t.base + 4 * s + Int(noise(n) * Double(max(1, span - 6 * s)))
        let hl = t.half(y, right: false), hr = t.half(y, right: true)
        guard hl + hr > 12 * s else { continue }
        let x = t.x - hl + 6 * s + Int(noise(n + 1) * Double(hl + hr - 12 * s)), heather = noise(n + 2) > 0.65
        for k in 0..<5 {
            c.rect(x + Int((noise(n * 3 + k) - 0.5) * 8) * s, y + Int((noise(n * 3 + k + 7) - 0.5) * 3) * s, s, s,
                   heather ? C(0x54405A) : k % 2 == 0 ? C(0x4E5236) : C(0x626040))
        }
    }
}

/// Boulders strewn over the slope.
private func r6Boulders(_ c: PixelCanvas, _ t: R6Tor, seed: Int) {
    let s = t.s, span = max(1, t.ground - t.base)
    for i in 0..<(c.w / (45 * s)) {
        let n = seed + i * 5
        let y = t.base + span / 6 + Int(noise(n) * Double(span * 5 / 6))
        let hl = t.half(y, right: false), hr = t.half(y, right: true)
        let r = (2 + Int(noise(n + 2) * 4.0)) * s
        guard hl + hr > 4 * r else { continue }
        let x = t.x - hl + 2 * r + Int(noise(n + 1) * Double(hl + hr - 4 * r))
        r6Crag(c, x: x, base: y, rx: r, h: r * 3 / 4 + s, s: s, seed: n, r6Rock)
    }
}

/// The path wandering up the slope, now this way, now that, not always turning, with boulders by the way, to the
/// foot of a ramp cut slantwise up the slabs on the right to the summit.
private func r6Path(_ c: PixelCanvas, _ t: R6Tor, seed: Int) {
    let s = t.s, rock = r6Rock, col = C(0x5A5246)
    let rampFoot = (t.x + t.waist * 2 / 3, t.base - s), rampTop = (t.x + t.crown / 4, t.top + 3 * s)
    var at = (t.x - t.half(t.ground - s, right: false) / 6, t.ground), side = false
    for j in 1...5 {
        let y1 = j == 5 ? rampFoot.1 : at.1 - Int(Double(at.1 - rampFoot.1) * (0.2 + 0.25 * noise(seed + j)))
        if noise(seed + j * 3 + 1) > 0.3 { side.toggle() }
        let reach = 0.15 + 0.5 * noise(seed + j * 3 + 2)
        let x1 = j == 5 ? rampFoot.0 : side ? t.x + Int(Double(t.half(y1, right: true)) * reach)
            : t.x - Int(Double(t.half(y1, right: false)) * reach)
        let mid = ((at.0 + x1) / 2 + Int((noise(seed + j * 3 + 5) - 0.5) * 16) * s, (at.1 + y1) / 2)
        let th = j < 3 ? 2 * s : s
        for (p, q) in [(at, mid), (mid, (x1, y1))] {
            r6Line(c, p.0, p.1 + s, q.0, q.1 + s, rock.crack, s: th)
            r6Line(c, p.0, p.1, q.0, q.1, col, s: th)
        }
        // a boulder by the way
        let r = (j < 3 ? 5 : 3) * s
        r6Crag(c, x: mid.0 + (side ? -1 : 1) * 2 * r, base: mid.1, rx: r, h: r, s: s, seed: seed + j + 40, rock)
        at = (x1, y1)
    }
    r6Line(c, rampFoot.0, rampFoot.1 + s, rampTop.0, rampTop.1 + s, rock.crack, s: s)
    r6Line(c, rampFoot.0, rampFoot.1, rampTop.0, rampTop.1, col, s: s)
}

/// The ruin crowning the tor: a low broken wall behind with the fire inside it, a dead tree growing up between the
/// stones, and in front broken tower stubs with the pale sky through their window holes, a stretch of broken wall
/// with the fire glowing through its window, the crumbled arch, a broken pillar, and the summit's rock heaped about
/// their feet.
private func r6Ruin(_ c: PixelCanvas, _ t: R6Tor) {
    let s = t.s, x = t.x, b = t.top + s, stone = r6Masonry, far = stone.far(0.35), hole = r6Hole
    r6Tower(c, x: x - 40 * s, base: b - 2 * s, w: 32 * s, h: 10 * s, fall: 0.1, s: s, seed: 12000, far, windows: [])
    r6Tower(c, x: x + 2 * s, base: b - 2 * s, w: 36 * s, h: 13 * s, fall: -0.2, s: s, seed: 12001, far,
            windows: [(0.3, 0.45, hole)])
    let f = Scenes.weathertopFire(c, t.ground)
    c.circle(f.x, b - 4 * s, 46 * s, C(0xFF8A3A, 0.1))
    c.circle(f.x, b - 4 * s, 26 * s, C(0xFF8A3A, 0.14))
    r6Fire(c, x: f.x, y: f.y, s: s, glow: f.glow)
    r6DeadTree(c, x: x + 25 * s, base: b, h: 36 * s, lean: 0.3, s: s, seed: 12010)
    r6Tower(c, x: x - 46 * s, base: b + 2 * s, w: 12 * s, h: 34 * s, fall: 0.35, s: s, seed: 12020, stone,
            windows: [(0.5, 0.6, hole), (0.5, 0.3, hole)])
    r6Tower(c, x: x - 34 * s, base: b + s, w: 13 * s, h: 16 * s, fall: -0.4, s: s, seed: 12021, stone,
            windows: [(0.55, 0.45, r6FireHole)])
    r6Arch(c, x: x - 21 * s, base: b + s, span: 24 * s, h: 18 * s, th: 5 * s, s: s, seed: 12022, stone)
    r6Tower(c, x: x + 4 * s, base: b + s, w: 13 * s, h: 46 * s, fall: -0.2, s: s, seed: 12023, stone,
            windows: [(0.5, 0.7, hole), (0.5, 0.4, hole)])
    r6Tower(c, x: x + 17 * s, base: b + 2 * s, w: 15 * s, h: 20 * s, fall: 0.55, s: s, seed: 12024, stone,
            windows: [(0.4, 0.4, hole)])
    r6Tower(c, x: x + 33 * s, base: b + 2 * s, w: 9 * s, h: 26 * s, fall: 0.6, s: s, seed: 12025, stone,
            windows: [(0.5, 0.45, hole)])
    r6Pillar(c, x: x + 43 * s, base: b + 2 * s, w: 5 * s, h: 12 * s, leftHigh: true, s: s, seed: 12026, stone)
    for (k, dx) in [-48, -38, -26, 16, 30, 45].enumerated() {
        r6Crag(c, x: x + dx * s, base: b + 4 * s, rx: (4 + k % 3 * 2) * s, h: (3 + k % 2 * 3) * s, s: s,
               seed: k + 12030, r6Rock)
    }
}

extension Scenes {
    /// Amon Sûl at a stormy dusk: heavy dark cloud banks with a pale glowing break in them lighting their edges, a
    /// few stars in a rift high on the left, the dark lands lying far below, and the crew on the bare rock of the
    /// summit inside what is left of the old watch-tower: a broken ring of weathered blocks, broken pillars, tower
    /// stubs with the pale sky through their window holes, a crumbled arch and dead twisted trees, dark against the
    /// dusk. A small campfire glows out of it among the rocks at the left. On tall screens the hill's slope rises to
    /// a steep tor of stacked grey-brown slabs, a path wandering up the slope to a ramp cut up the tor, and the ruin
    /// crowning it against the break in the cloud, with the fire glowing through one of its windows.
    static func weathertop(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), gg = Double(g), t = weathertopTor(c, g)
        weathertopSky(c, g)
        if tall {
            weathertopLands(c, g, horizon: Int(gg * 0.64))
            r6Slope(c, t, seed: 11900)
            r6DrawSlabs(c, t, r6Slabs(t, seed: 11910, minH: 4, maxH: 11, jitter: 4), seed: 11920)
            r6Path(c, t, seed: 11930)
            r6Boulders(c, t, seed: 11940)
            r6Ruin(c, t)
            weathertopFloor(c, g)
            // boulders at the hill's foot, either side of the crew
            for (k, f) in [0.05, 0.93].enumerated() {
                r6Crag(c, x: Int(Double(c.w) * f), base: g + s, rx: (12 + k * 4) * s, h: (10 + k * 3) * s, s: s,
                       seed: k + 9960, r6Rock)
            }
        } else {
            weathertopLands(c, g, horizon: g - 18 * s)
            weathertopRing(c, g)
            weathertopFloor(c, g)
            let f = weathertopFire(c, g)
            r6Crag(c, x: f.x - 13 * s, base: g + s, rx: 6 * s, h: 5 * s, s: s, seed: 9970, r6Rock)
            r6Crag(c, x: f.x + 12 * s, base: g + s, rx: 5 * s, h: 4 * s, s: s, seed: 9971, r6Rock)
            r6Fire(c, x: f.x, y: f.y, s: s, glow: f.glow)
        }
    }

    /// The tor on tall screens (the strip doesn't draw it, but the break in the cloud is placed from it).
    fileprivate static func weathertopTor(_ c: PixelCanvas, _ g: Int) -> R6Tor {
        let s = unit(g), top = Int(Double(g) * 0.3)
        return R6Tor(x: Int(Double(c.w) * 0.46), top: top, crown: 46 * s, waist: 66 * s,
                     base: top + Int(Double(g - top) * 0.42), foot: max(60 * s, Int(Double(c.w) * 0.48)), ground: g, s: s)
    }

    /// The campfire: its middle, the row its stones sit on, and how far its glow reaches. On the strip it burns among
    /// the rocks at the left; on tall screens inside the ruin on the summit, under the crumbled arch.
    static func weathertopFire(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, glow: Int) {
        let s = unit(g)
        guard isTall(c) else { return (Int(Double(c.w) * 0.1), g, Int(Double(34 * s) * 1.5)) }
        let t = weathertopTor(c, g)
        return (t.x - 6 * s, t.top, 12 * s)
    }

    /// The pale break in the cloud: its middle and how far it reaches each side and up and down.
    static func weathertopBreak(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, rx: Int, ry: Int) {
        let s = unit(g), tall = isTall(c), w = Double(c.w), gg = Double(g)
        let bx = tall ? weathertopTor(c, g).x + Int(w * 0.1) : Int(w * 0.6)
        return (bx, Int(gg * (tall ? 0.2 : 0.4)), max(2 * s, Int(w * 0.24)), max(2 * s, Int(gg * (tall ? 0.13 : 0.3))))
    }

    /// The stormy dusk: heavy dark cloud banks, and a pale glowing break in them, lighting their edges. A few stars
    /// in a rift high on the left.
    static func weathertopSky(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), w = Double(c.w), gg = Double(g)
        c.gradient(0, g, C(0x1C1E26), C(0x3E3E44), bands: tall ? 10 : 7)
        c.stars(0, Int(gg * 0.18), density: 700, seed: 67, x1: c.w / 4)
        // the break: a ragged pool of pale light, brightest low in it, made of lumps off one another
        let (bx, by, rx, ry) = weathertopBreak(c, g)
        for k in 0..<8 {
            let f = 1 - Double(k) / 9, col = lerp(C(0x6A6458), C(0xFAF2D8), Double(k) / 7)
            for j in 0..<3 {
                let n = 11400 + k * 7 + j * 2
                let dx = Int((noise(n) - 0.5) * Double(rx) * 0.8 * f), dy = Int((noise(n + 1) - 0.3) * Double(ry) * 0.5 * f)
                c.ellipse(bx + dx, by + dy, max(1, Int(Double(rx) * f * (0.6 + 0.3 * Double(j % 2)))),
                          max(1, Int(Double(ry) * f * 0.7)), col.alpha(0.16))
            }
        }
        for (i, b) in weathertopBanks(c).enumerated() {
            r6Bank(c, x0: Int(w * b.0), x1: Int(w * b.1), y: Int(gg * b.2), thick: max(s, Int(gg * b.3)), s: s,
                   seed: 11500 + i * 37, body: C(b.4), rim: C(0xE0D2AC), lightX: bx, reach: rx, rimK: b.5)
        }
    }

    /// The cloud banks: x from, x to, row and height (of g), their tone and how strongly their top edge catches the
    /// light.
    static func weathertopBanks(_ c: PixelCanvas) -> [(Double, Double, Double, Double, UInt32, Double)] {
        isTall(c) ? [
            (-0.2, 0.52, 0.1, 0.16, 0x111318, 0.4), (0.7, 1.2, 0.08, 0.18, 0x111318, 0.5),
            (0.28, 0.86, 0.02, 0.08, 0x16181E, 0.75), (-0.1, 0.5, 0.31, 0.08, 0x46464C, 0.95),
            (0.7, 1.15, 0.34, 0.12, 0x1A1C22, 0.8), (0.42, 0.9, 0.36, 0.03, 0x54524A, 1),
            (-0.15, 0.4, 0.5, 0.07, 0x1C1E24, 0.35), (0.6, 1.15, 0.53, 0.06, 0x1C1E24, 0.45),
        ] : [
            (-0.15, 0.48, 0.16, 0.26, 0x111318, 0.45), (0.78, 1.2, 0.12, 0.28, 0x111318, 0.55),
            (0.3, 0.88, 0.04, 0.14, 0x16181E, 0.75), (0.02, 0.42, 0.5, 0.12, 0x46464C, 0.95),
            (0.74, 1.12, 0.58, 0.16, 0x1A1C22, 0.8), (0.44, 0.84, 0.68, 0.05, 0x54524A, 1),
        ]
    }

    /// The dark lands far below: two ranges of low hills, a pale band of dusk light along the horizon.
    static func weathertopLands(_ c: PixelCanvas, _ g: Int, horizon: Int) {
        let s = unit(g), tall = isTall(c)
        c.rect(0, horizon - 3 * s, c.w, 2 * s, C(0xB0A488, 0.25))
        c.dunes(base: horizon - s, amp: Double((tall ? 4 : 2) * s), freq: 0.014 / Double(s), phase: 1.1, bottom: g,
                C(0x24242A), shade: C(0x3A3830))
        c.dunes(base: horizon + (tall ? 18 : 3) * s, amp: Double((tall ? 6 : 2) * s), freq: 0.02 / Double(s), phase: 4.0,
                bottom: g, C(0x18181C), shade: C(0x26262A))
    }

    /// The bare rock where the crew stands: smoothed grey-brown stone with a few wandering cracks, and dry grass and
    /// heather in the cracks along its edge.
    static func weathertopFloor(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        c.ground(g, C(0x38332E), edge: C(0x5E574C), speck: C(0x2C2824), seed: 81)
        for i in 0..<(c.w / (30 * s)) {
            let n = i * 5 + 9900
            let y = g + 2 * s + Int(noise(n) * Double(max(0, c.h - g - 4 * s)))
            let x = Int(noise(n + 1) * Double(c.w)), len = (6 + Int(noise(n + 2) * 14.0)) * s
            r6Line(c, x, y, x + len, y + Int((noise(n + 3) - 0.5) * 3) * s, C(0x26221E), s: s)
        }
        for x in stride(from: 0, to: c.w, by: 3 * s) where noise(x / s + 9950) > 0.8 {
            c.rect(x, g - s, s, s, noise(x / s + 9951) > 0.4 ? C(0x5E5C3A) : C(0x5A4656))
        }
    }

    /// The strip: the broken ring around the crew. A craggy crest of the summit behind, the far side of the ring low
    /// and dim on it, and nearer, huge weathered blocks, broken pillars, low wall stubs, tower stubs with window
    /// holes, dead trees growing up between the stones and a crumbled arch on a worn threshold, rock heaped at their
    /// feet.
    static func weathertopRing(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), big = Double(max(10, g)), stone = r6Masonry
        // the summit's crest behind the ring
        var x = -Int(noise(9800) * Double(20 * s)), i = 0
        while x < c.w {
            let rx = (9 + Int(noise(i * 3 + 9801) * 12.0)) * s
            r6Crag(c, x: x, base: g, rx: rx, h: (5 + Int(noise(i * 3 + 9802) * 5.0)) * s, s: s, seed: i + 9803,
                   r6Rock.far(0.4))
            x += rx + (2 + Int(noise(i * 3 + 9804) * 8.0)) * s; i += 1
        }
        // the far side of the ring
        x = -Int(noise(9810) * Double(20 * s)); i = 0
        while x < c.w {
            let n = i * 7 + 9820
            let w = max(2 * s, Int(big * (0.1 + 0.12 * noise(n))))
            r6Block(c, x: x, base: g - 4 * s, w: w, h: max(2 * s, Int(big * (0.1 + 0.14 * noise(n + 1)))),
                    slope: (noise(n + 2) - 0.5) * 0.8, s: s, seed: n, stone.far(0.45))
            x += w + Int(big * (0.15 + 0.4 * noise(n + 3))); i += 1
        }
        // the near side: blocks, pillars, wall stubs, towers, trees and the arch, in a broken run
        enum Ruin { case block, pillar, stub, arch, tower, tree }
        let run: [Ruin] = [.block, .tower, .pillar, .stub, .tree, .arch, .block, .tower, .stub, .pillar, .tree, .block]
        x = Int(big * (0.05 + 0.3 * noise(9830))); i = 0
        while x < c.w {
            let n = i * 11 + 9840
            var w = 0
            switch run[i % run.count] {
            case .block:
                w = max(3 * s, Int(big * (0.36 + 0.2 * noise(n))))
                r6Block(c, x: x, base: g + s, w: w, h: Int(big * (0.3 + 0.18 * noise(n + 1))),
                        slope: (noise(n + 2) - 0.5) * 0.9, s: s, seed: n, stone)
            case .pillar:
                w = max(2 * s, Int(big * 0.13))
                r6Pillar(c, x: x, base: g + s, w: w, h: Int(big * (0.3 + 0.3 * noise(n + 1))),
                         leftHigh: noise(n + 2) > 0.5, s: s, seed: n, stone)
            case .stub:
                w = max(3 * s, Int(big * (0.4 + 0.3 * noise(n))))
                r6Block(c, x: x, base: g + s, w: w, h: Int(big * (0.12 + 0.12 * noise(n + 1))),
                        slope: (noise(n + 2) - 0.5) * 1.2, s: s, seed: n, stone)
            case .arch:
                // a worn threshold, and the arch standing on it
                let rise = 3 * s, lift = 2 * rise - s
                w = max(8 * s, Int(big * 0.62))
                c.rect(x, g - lift, w, lift + s, stone.body)
                c.rect(x, g - lift, w, s, stone.lit)
                r6Arch(c, x: x, base: g - lift, span: w, h: Int(big * 0.36), th: max(2 * s, Int(big * 0.11)), s: s,
                       seed: n, stone)
            case .tower:
                w = max(4 * s, Int(big * (0.2 + 0.06 * noise(n))))
                r6Tower(c, x: x, base: g + s, w: w, h: Int(big * (0.58 + 0.22 * noise(n + 1))),
                        fall: (noise(n + 2) - 0.5) * 0.9, s: s, seed: n, stone,
                        windows: [(0.5, 0.62, r6Hole), (0.5, 0.3, r6Hole)])
            case .tree:
                // a dead tree growing up behind a low block
                r6DeadTree(c, x: x + Int(big * 0.1), base: g + s, h: Int(big * (0.62 + 0.2 * noise(n + 1))),
                           lean: (noise(n + 2) - 0.5) * 0.7, s: s, seed: n)
                w = max(3 * s, Int(big * (0.24 + 0.08 * noise(n))))
                r6Block(c, x: x, base: g + s, w: w, h: Int(big * (0.12 + 0.06 * noise(n + 3))),
                        slope: (noise(n + 4) - 0.5) * 0.8, s: s, seed: n + 1, stone)
            }
            // rock heaped against its foot
            if noise(n + 5) > 0.3 {
                r6Crag(c, x: x + Int(noise(n + 6) * Double(w)), base: g + s, rx: (3 + Int(noise(n + 7) * 4.0)) * s,
                       h: (2 + Int(noise(n + 8) * 3.0)) * s, s: s, seed: n + 9, r6Rock)
            }
            x += w + Int(big * (0.1 + 0.35 * noise(n + 10))); i += 1
        }
    }

    /// The pale break in the cloud breathing, ragged scud drifting slowly across high up, now and then lightning
    /// flickering in the cloud far off (and on tall screens a bolt down to the dark lands), and the campfire
    /// flickering with sparks going up.
    static func weathertopLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), gg = Double(g), w = Double(c.w), twoPi: Double = 2 * Double.pi
        let br = weathertopBreak(c, g)
        let breath: Double = 0.5 + 0.5 * sin(t * twoPi / 7)
        c.ellipse(br.x, br.y + br.ry / 6, br.rx * 2 / 5, br.ry * 2 / 5, C(0xFAF2D8, 0.02 + 0.05 * breath))
        c.ellipse(br.x, br.y + br.ry / 5, br.rx / 5, br.ry / 4, C(0xFFF8E4, 0.03 + 0.07 * breath))
        // the scud: row and thickness (of g), length (of the width), and speed in units a second
        let scud: [(Double, Double, Double, Double)] = tall ? [(0.07, 0.055, 0.3, 6), (0.14, 0.045, 0.22, 9)]
            : [(0.08, 0.1, 0.28, 5), (0.15, 0.06, 0.2, 8)]
        for (i, sc) in scud.enumerated() {
            let len = max(4 * s, Int(w * sc.2)), range = Double(c.w + len)
            let x0 = Int((noise(i + 9600) * range + t * sc.3 * Double(s)).truncatingRemainder(dividingBy: range)) - len
            r6Scud(c, x0: x0, len: len, y: Int(gg * sc.0), thick: max(s, Int(gg * sc.1)), s: s, seed: 9610 + i * 37,
                   lightX: br.x, reach: br.rx)
        }
        weathertopLightning(c, g, t)
        // the fire: its glow swelling and shrinking, its flames leaping, sparks rising
        let f = weathertopFire(c, g), fr = Int(t * 12), flick = noise(fr * 3 + 9500)
        c.circle(f.x, f.y - 4 * s, f.glow * 3 / 5 + Int(flick * Double(2 * s)), C(0xFF8A3A, 0.03 + 0.07 * flick))
        for (k, fl) in r6Flames.enumerated() {
            let h = max(s, Int(Double(fl.1 * s) * (0.7 + 0.65 * noise(fr * 11 + k * 3 + 9510))))
            let lean = noise(fr * 11 + k * 3 + 9511) > 0.75 ? (k % 2 == 0 ? s : -s) : 0
            c.rect(f.x + fl.0 * s, f.y - 2 * s - h / 2, s, h / 2, C(fl.2))
            c.rect(f.x + fl.0 * s + lean, f.y - 2 * s - h, s, h - h / 2, C(fl.2))
        }
        let rise = (tall ? 12 : 22) * s
        for i in 0..<(tall ? 3 : 5) {
            let p = r6Phase(t, 1.7 + noise(i + 9520) * 0.8, offset: noise(i + 9521) * 3)
            let x = f.x + Int((noise(i + 9522) - 0.5) * Double(5 * s)) + Int(sin(p * 5 + Double(i)) * Double(2 * s))
            c.rect(x, f.y - 9 * s - Int(p * Double(rise)), s, s, C(0xFFC860, 1 - p))
        }
    }

    /// Now and then lightning far off: a double flicker lighting up part of a cloud bank low on the left or the
    /// right from inside, and on tall screens a jagged bolt from it down to the dark lands, beside the hill.
    static func weathertopLightning(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), gg = Double(g), w = Double(c.w), period = 9.0
        let lt = r6Phase(t, period, offset: 2) * period
        let flash: Double = lt < 0.08 ? 1 : lt < 0.16 ? 0.15 : lt < 0.3 ? 0.75 : lt < 0.6 ? 2.5 * (0.6 - lt) : 0
        guard flash > 0 else { return }
        let n = abs(Int(floor((t + 2) / period))) * 7 + 9700, left = noise(n) > 0.5
        let fx = Int(w * (left ? 0.06 + 0.18 * noise(n + 1) : 0.76 + 0.18 * noise(n + 1)))
        // the bank it flickers in, lit most around the flash and fading out either side
        let bi = (tall ? 6 : 0) + (left ? 0 : 1), b = weathertopBanks(c)[bi], reach = max(1, Int(w * 0.14))
        let fy = Int(gg * b.2)
        r6Bank(c, x0: Int(w * b.0), x1: Int(w * b.1), y: fy, thick: max(s, Int(gg * b.3)), s: s, seed: 11500 + bi * 37,
               body: C(0x9AA2BC), rim: C(0xF0F2FF), lightX: fx, reach: reach, rimK: 1,
               only: (fx - reach, fx + reach, { col in
                   let k = 1 - Double(abs(col - fx)) / Double(reach)
                   return k > 0 ? 0.55 * flash * k * k : 0
               }))
        guard tall, flash > 0.5 else { return }
        let bottom = Int(gg * 0.64) - s, steps = 6
        var x = fx, y = fy + Int(gg * b.3 * 0.2)
        let dy = max(s, (bottom - y) / steps)
        for k in 0..<steps {
            let nx = x + Int((noise(n + 10 + k) - 0.5) * 8) * s
            r6Line(c, x, y, nx, y + dy, C(0xF0F2FF, flash), s: s)
            if k == 2 {
                r6Line(c, nx, y + dy, nx + (left ? 5 : -5) * s, y + dy + dy * 2 / 3, C(0xD8DEF4, 0.6 * flash), s: s)
            }
            x = nx; y += dy
        }
    }
}

/// A ragged scrap of dark scud `len` wide from x0 around row y: a lumpy top up to `thick` high and a flatter
/// underside, its lumps riding along with it, its top edge catching the light near column `lightX`.
private func r6Scud(_ c: PixelCanvas, x0: Int, len: Int, y: Int, thick: Int, s: Int, seed: Int, lightX: Int,
                    reach: Int) {
    guard len > 0, thick > 0 else { return }
    let body = C(0x0E1016, 0.8)
    for col in stride(from: 0, to: len, by: s) {
        let x = x0 + col
        guard x > -s, x < c.w else { continue }
        let u = Double(col) / Double(len)
        let env = pow(max(0, sin(Double.pi * u)), 0.6)
        let lump = r6Smooth(Double(col) / Double(6 * s), seed: seed) * 0.7 + r6Smooth(Double(col) / Double(2 * s), seed: seed + 50) * 0.3
        let up = Int(Double(thick) * env * (0.25 + 0.75 * lump)) / s * s
        let down = Int(Double(thick) * env * 0.25) / s * s
        guard up + down > 0 else { continue }
        let near = max(0, 1 - Double(abs(x - lightX)) / Double(max(1, reach)))
        c.rect(x, y - up, s, up + down, body)
        c.rect(x, y - up, s, s, lerp(body, C(0xE0D2AC, 0.9), 0.15 + 0.5 * near))
    }
}
