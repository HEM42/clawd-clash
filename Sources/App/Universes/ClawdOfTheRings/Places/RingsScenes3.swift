import Foundation

// Rivendev, Lothlorem and Thrandual's Halls: the elves' places.
let ringsScenes3: [Location: Place] = [
    .rivendell: Place(name: "Rivendev", panel: 0x1C2026, still: Scenes.rivendell, moving: Scenes.rivendellLife),
    .lothlorien: Place(name: "Lothlorem", panel: 0x241E10, still: Scenes.lothlorien, moving: Scenes.lothlorienLife),
    .mirkwood: Place(name: "Thrandual's Halls", panel: 0x0E140E, still: Scenes.mirkwood, moving: Scenes.mirkwoodLife),
]

// MARK: - Shared bits for these scenes

/// Where a repeating motion of `period` seconds is, from 0 up to 1.
private func r3Phase(_ t: Double, _ period: Double, offset: Double = 0) -> Double {
    let v = (t + offset).truncatingRemainder(dividingBy: period) / period
    return v < 0 ? v + 1 : v
}

/// `v` wrapped into 0..<`m` (an offset that keeps moving, coming round again).
private func r3Wrap(_ v: Double, _ m: Int) -> Int {
    let mm = Double(max(1, m))
    let r = v.truncatingRemainder(dividingBy: mm)
    return Int(r < 0 ? r + mm : r)
}

/// A falling leaf as it tumbles: lying flat (two pixels wide) or turned on its edge (two tall).
private func r3Leaf(_ c: PixelCanvas, _ x: Int, _ y: Int, flat: Bool, _ col: Px, s: Int) {
    if flat { c.rect(x, y, 2 * s, s, col) } else { c.rect(x, y, s, 2 * s, col) }
}

/// A straight line of `s`-pixel dots.
private func r3Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// A line of `s`-pixel dots sagging `sag` rows in the middle (a rope bridge), or bowing up when `sag` is negative.
private func r3Sag(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, sag: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), 1)
    for i in stride(from: 0, through: n, by: max(1, s)) {
        let k = Double(i) / Double(n)
        let a: Double = k * Double.pi
        let y = y0 + Int(Double(y1 - y0) * k + Double(sag) * sin(a))
        c.rect(x0 + (x1 - x0) * i / n, y, s, s, col)
    }
}

/// `v` clamped into 0...1.
private func r3Clamp(_ v: Double) -> Double { max(0, min(1, v)) }

/// A thick root or bough bending between two points, `t` pixels thick, its upper edge lit.
/// `bend` bows it down (up when negative) and `bow` sideways, both most in the middle.
private func r3Root(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, bend: Int, bow: Int = 0, t: Int, _ col: Px,
                    lit: Px) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        let a: Double = k * Double.pi
        let x = x0 + Int(Double(x1 - x0) * k + Double(bow) * sin(a)), y = y0 + Int(Double(y1 - y0) * k + Double(bend) * sin(a))
        let tt = max(1, Int(Double(t) * (1 - 0.5 * k)))
        c.rect(x - tt / 2, y - tt / 2, tt, tt, col)
        c.rect(x - tt / 2, y - tt / 2, tt, max(1, tt / 4), lit)
    }
}

/// One wall of Rivendev's valley: a V round the valley's middle, lowest at `floor` and rising `rise` rows towards the
/// sides of a V `half` wide, the steeper the bigger `steep`, with a ragged crest.
private struct R3Wall {
    let floor: Int, rise: Int, steep: Double, half: Int, seed: Int

    func top(_ x: Int, cx: Int, s: Int) -> Int {
        let d = min(1.6, abs(Double(x - cx)) / Double(max(1, half)))
        let crag = Int(noise(x / (3 * s) + seed * 97) * 2.0) * s + Int(sin(Double(x) / Double(11 * s) + Double(seed)) * Double(2 * s))
        return floor - Int(Double(rise) * pow(d, steep)) - crag
    }
}

// MARK: - Rivendev

extension Scenes {
    /// The valley's middle, where its far end opens between the walls.
    static func rivendellMid(_ c: PixelCanvas) -> Int { c.w * 52 / 100 }

    /// The valley's walls, far to near (three on tall screens, two in the strip).
    fileprivate static func rivendellWalls(_ c: PixelCanvas, _ g: Int) -> [R3Wall] {
        let s = unit(g)
        if isTall(c) {
            return [R3Wall(floor: g * 50 / 100, rise: g * 42 / 100, steep: 1.5, half: c.w / 2, seed: 11),
                    R3Wall(floor: g * 76 / 100, rise: g * 72 / 100, steep: 1.8, half: c.w * 46 / 100, seed: 23),
                    R3Wall(floor: g + 4 * s, rise: g * 125 / 100, steep: 2.4, half: c.w * 44 / 100, seed: 37)]
        }
        return [R3Wall(floor: g - 24 * s, rise: 34 * s, steep: 1.5, half: c.w / 2, seed: 11),
                R3Wall(floor: g + 2 * s, rise: g + 24 * s, steep: 2.2, half: c.w * 42 / 100, seed: 37)]
    }

    /// The evening star.
    static func rivendellStar(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int) {
        (c.w * 70 / 100, isTall(c) ? g / 9 : 5 * unit(g))
    }

    /// The waterfalls: the wall each pours down (its index, far to near), its left edge, lip, foot, width and seed.
    static func rivendellFallSpots(_ c: PixelCanvas, _ g: Int)
        -> [(wall: Int, x: Int, top: Int, bottom: Int, width: Int, seed: Int)] {
        let s = unit(g), cx = rivendellMid(c), walls = rivendellWalls(c, g)
        // where each wall's falls are (share of the V's half-width)
        let shares: [[Double]] = isTall(c) ? [[-0.22, 0.28], [-0.62, 0.52, 0.8], [-0.88, -0.72, 0.76, 0.92]]
                                           : [[-0.2, 0.3], [-0.86, -0.66, 0.74, 0.9]]
        var out: [(wall: Int, x: Int, top: Int, bottom: Int, width: Int, seed: Int)] = []
        for (i, wl) in walls.enumerated() {
            let near = i == walls.count - 1
            for (k, d) in shares[i].enumerated() {
                let x = cx + Int(d * Double(wl.half))
                out.append((i, x, wl.top(x, cx: cx, s: s) + s, near ? g - 4 * s : min(g, wl.floor + (g - wl.floor) / 2),
                            (near ? 4 : 3 - i) * s + (k % 2) * s, i * 10 + k))
            }
        }
        return out
    }

    /// Rivendev at evening: a clear sky going from deep blue to peach, the evening star out, and the valley's rock walls
    /// closing in from both sides, the east wall catching the last of the sun. Waterfalls pour down the walls. In the
    /// middle, the Last Homely House: pale halls with slender arcades lit warm inside and roofs whose eaves sweep up,
    /// a round pavilion, all on terraces among autumn trees in gold and rust. The crew stands on a pale stone terrace
    /// with a slender balustrade. On tall screens: the Misty Mountains' snowy peaks beyond the valley's end, a third
    /// wall, more falls, and the halls stacked up the valley in tiers joined by stairs.
    static func rivendell(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, tall ? C(0x34457A) : C(0x6A84B4), C(0xF6D2A2), bands: tall ? 12 : 8)
        if tall { c.stars(0, g / 4, density: 90, seed: 31) }
        // Eärendil, the evening star
        let (ex, ey) = rivendellStar(c, g)
        c.rect(ex - 2 * s, ey, 5 * s, s, C(0xFFFFFF, 0.45)); c.rect(ex, ey - 2 * s, s, 5 * s, C(0xFFFFFF, 0.45))
        c.rect(ex, ey, s, s, white)
        if tall { rivendellPeaks(c, g) }
        let walls = rivendellWalls(c, g)
        // far to near: the wall's rock (body, sunlit, seams), then its falls
        let tones: [(Px, Px, Px)] = tall
            ? [(C(0x9294B0), C(0xE2BEAA), C(0x7E809C)), (C(0x707C88), C(0xC8A088), C(0x5A646E)),
               (C(0x4C5A52), C(0xA88A68), C(0x38443E))]
            : [(C(0x9294B0), C(0xE2BEAA), C(0x7E809C)), (C(0x4C5A52), C(0xA88A68), C(0x38443E))]
        let falls = rivendellFallSpots(c, g)
        for (i, wl) in walls.enumerated() {
            let near = i == walls.count - 1
            rivendellWall(c, g, wl, body: tones[i].0, lit: tones[i].1, shade: tones[i].2)
            for f in falls where f.wall == i {
                rivendellFalls(c, g, x: f.x, top: f.top, bottom: f.bottom, width: f.width, seed: f.seed)
            }
            if !near { rivendellWoods(c, g, wl, seed: i * 50 + 900, far: i == 0) }
            if tall && i == 1 { rivendellUpperTiers(c, g) }
        }
        rivendellWoods(c, g, walls[walls.count - 1], seed: 990, far: false)
        rivendellHouse(c, g)
        rivendellTerrace(c, g)
    }

    /// Tall screens: the Misty Mountains beyond the valley's end, sharp-peaked, snow lit pink by the sunset on their
    /// western faces.
    static func rivendellPeaks(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), base = g * 44 / 100, amp = Double(g) * 0.15
        func tri(_ v: Double) -> Double {
            let m = v.truncatingRemainder(dividingBy: 2)
            return 1 - abs((m < 0 ? m + 2 : m) - 1)
        }
        func top(_ x: Int) -> Int {
            let t = Double(x) / Double(46 * s)
            return base - Int((0.65 * tri(t + 0.3) + 0.35 * tri(t * 2.7 + 1.1)) * amp)
        }
        let snow = base - Int(amp * 0.5)
        for x in 0..<c.w {
            let y = top(x)
            c.rect(x, y, 1, max(0, g - y), C(0xA6A8C6))
            guard y < snow else { continue }
            let west = top(x + 1) <= y
            c.rect(x, y, 1, snow - y + Int(noise(x / s + 77) * 3.0) * s, west ? C(0xF6E2DC) : C(0xC4C6DC))
        }
    }

    /// One of the valley's rock walls, with seams and ledges; east of the middle, warmed by the setting sun.
    fileprivate static func rivendellWall(_ c: PixelCanvas, _ g: Int, _ wl: R3Wall, body: Px, lit: Px, shade: Px) {
        let s = unit(g), cx = rivendellMid(c), warm = lerp(body, lit, 0.3)
        for x in 0..<c.w {
            let top = max(0, wl.top(x, cx: cx, s: s))
            guard top < g else { continue }
            let east = x > cx
            c.rect(x, top, 1, g - top, east ? warm : body)
            if noise(x / s + wl.seed * 131) > 0.8 { c.rect(x, top + 2 * s, 1, max(0, g - top - 2 * s), shade.alpha(0.6)) }
            c.rect(x, top, 1, s, east ? lit : lerp(body, white, 0.18))
        }
        // short ledges across the rock
        for i in 0..<max(0, c.w * g / (500 * s * s)) {
            let x = Int(noise(i * 3 + wl.seed * 7 + 300) * Double(c.w)), len = (4 + Int(noise(i * 3 + wl.seed * 7 + 302) * 10.0)) * s
            let top = max(wl.top(x, cx: cx, s: s), wl.top(x + len, cx: cx, s: s))
            guard top < g - 6 * s else { continue }
            let y = top + 3 * s + Int(noise(i * 3 + wl.seed * 7 + 301) * Double(g - top - 6 * s))
            c.rect(x, y, len, s, shade)
            c.rect(x, y - s, len, s, lerp(x > cx ? warm : body, white, 0.12))
        }
    }

    /// A ribbon of falling water from the lip of a wall, streaked, with spray where it lands.
    static func rivendellFalls(_ c: PixelCanvas, _ g: Int, x: Int, top: Int, bottom: Int, width: Int, seed: Int) {
        let s = unit(g), t = max(0, top)
        guard bottom > t + 2 * s, width > 0 else { return }
        let waters: [Px] = [C(0xF4F8FA), C(0xCCDEE8), C(0xE2EEF4)]
        for (k, xx) in stride(from: x, to: x + width, by: s).enumerated() {
            c.rect(xx, t, s, bottom - t, waters[Int(noise(k + seed * 13 + 40) * 3.0) % 3])
        }
        for j in 0..<max(0, (bottom - t) * width / (30 * s * s)) {
            let y = t + Int(noise(j * 2 + seed * 17 + 60) * Double(bottom - t))
            let xx = x + Int(noise(j * 2 + seed * 17 + 61) * Double(max(1, width / s))) * s
            c.rect(xx, y, s, 3 * s, C(0x8EAEC4, 0.55))
        }
        c.rect(x - s, t, width + 2 * s, s, C(0xF6FBFC))
        c.ellipse(x + width / 2, bottom, width + 3 * s, 2 * s, C(0xFFFFFF, 0.35))
        c.ellipse(x + width / 2, bottom - s, width / 2 + 2 * s, 2 * s, C(0xFFFFFF, 0.6))
    }

    /// Trees on a wall's slopes: autumn crowns in gold and rust among dark pines; small and hazy on the far wall.
    fileprivate static func rivendellWoods(_ c: PixelCanvas, _ g: Int, _ wl: R3Wall, seed: Int, far: Bool) {
        let s = unit(g), cx = rivendellMid(c), tall = isTall(c)
        let n = max(0, c.w / ((far ? 9 : 7) * s))
        for i in 0..<n {
            let x = Int(noise(i * 4 + seed) * Double(c.w))
            let top = max(0, wl.top(x, cx: cx, s: s))
            guard top < g - 4 * s else { continue }
            // most stand low down, near the foot of the wall
            let k = pow(noise(i * 4 + seed + 1), 0.45)
            let base = top + 4 * s + Int(k * Double(min(g, wl.floor) - top - 4 * s))
            guard base > top + 3 * s, base <= g else { continue }
            let size = far ? 1 + Int(noise(i * 4 + seed + 2) * 2.0) : (tall ? 3 : 2) + Int(noise(i * 4 + seed + 2) * 3.0)
            if noise(i * 4 + seed + 3) > 0.7 {
                rivendellPine(c, x, base, (size * 4 + 2) * s, s: s, haze: far)
            } else {
                rivendellTree(c, x, base, size * s, s: s, seed: i + seed, haze: far)
            }
        }
    }

    /// An autumn tree: a thin trunk under a crown of gold, amber or rust, lit from the west.
    static func rivendellTree(_ c: PixelCanvas, _ x: Int, _ base: Int, _ r: Int, s: Int, seed: Int, haze: Bool = false) {
        let crowns: [(UInt32, UInt32, UInt32)] = [(0xE0A83A, 0xB07A24, 0xF4CE68), (0xC8702A, 0x96481C, 0xE8984A),
                                                  (0xA8442A, 0x76281A, 0xCC6A40), (0xE8C04E, 0xB8902E, 0xF8E08A)]
        let pick = crowns[Int(noise(seed * 7 + 5) * 4.0) % 4]
        let mist = C(0xB8A8B4)
        func tone(_ v: UInt32) -> Px { haze ? lerp(C(v), mist, 0.45) : C(v) }
        c.rect(x, base - r, s, r, haze ? mist : C(0x4A3628))
        let cy = base - r - r / 2
        c.ellipse(x, cy + s, r, max(1, r * 3 / 4), tone(pick.1))
        c.ellipse(x, cy, r, max(1, r * 3 / 4), tone(pick.0))
        if r >= 2 * s { c.ellipse(x - r / 3, cy - r / 4, r / 2, max(1, r / 3), tone(pick.2)) }
    }

    /// A dark pine, in tiers.
    static func rivendellPine(_ c: PixelCanvas, _ x: Int, _ base: Int, _ h: Int, s: Int, haze: Bool = false) {
        let body = haze ? C(0x7A8494) : C(0x2C4638), lit = haze ? C(0x8A92A0) : C(0x3E5A48)
        c.rect(x, base - h / 4, s, h / 4, haze ? body : C(0x3A2C22))
        let tiers = 3, th = max(1, h / tiers)
        for t in 0..<tiers {
            let y0 = base - h / 4 - (t + 1) * th * 3 / 4 - th / 4
            for y in 0..<th {
                let half = (y + 1) * (tiers - t + 2) * s / max(1, th * 2) + s / 2
                c.rect(x - half, y0 + y, half * 2 + s, 1, body)
                c.rect(x - half, y0 + y, s, 1, lit)
            }
        }
        c.rect(x, base - h - s, s, 2 * s, body)
    }

    /// An elven hall: pale walls opened by an arcade of slender arches (some lit warm within), on a plinth, under a
    /// shallow roof whose eaves sweep up at the ends. `x` is its left edge, `base` the row it stands on.
    static func rivendellHall(_ c: PixelCanvas, _ x: Int, _ base: Int, _ w: Int, _ h: Int, s: Int, seed: Int) {
        let wall = C(0xEEE6D6), shade = C(0xC8BCA8), cornice = C(0xFAF4EA)
        let roof = C(0x6A8A80), roofLit = C(0x9CB6A8), roofDark = C(0x46605A)
        let top = base - h
        c.rect(x, top, w, h, wall)
        c.rect(x + w - 2 * s, top, 2 * s, h, shade)
        // the arcade
        let bay = 4 * s, n = max(0, (w - 4 * s) / bay), x0 = x + (w - n * bay) / 2 + s / 2
        for i in 0..<n {
            let bx = x0 + i * bay, lit = noise(i * 3 + seed * 29) > 0.45
            let inside = lit ? C(0xFFD27A) : C(0x7A6656)
            c.rect(bx, top + 4 * s, 3 * s, max(0, h - 6 * s), inside)
            c.rect(bx + s, top + 3 * s, s, s, inside)
            if lit { c.rect(bx + s, base - 4 * s, s, 2 * s, C(0xFFEAB4)) }
        }
        c.rect(x - s, top + s, w + 2 * s, s, cornice)
        c.rect(x - s, base - 2 * s, w + 2 * s, s, cornice)
        c.rect(x - s, base - s, w + 2 * s, s, shade)
        // the roof
        let o = 3 * s, rh = max(3 * s, w / 7), mid = x + w / 2, half = w / 2 + o
        for xx in (x - o)..<max(x - o, x + w + o) {
            let u = abs(Double(xx - mid)) / Double(max(1, half))
            let curl = u > 0.7 ? Int(pow((u - 0.7) / 0.3, 2) * Double(2 * s)) : 0
            let bot = top + s - curl
            let ry = min(bot - 2 * s, top - Int(Double(rh) * (1 - u)) - curl)
            c.rect(xx, ry, 1, bot - ry, roof)
            c.rect(xx, ry, 1, s, xx < mid ? roofLit : roof)
            c.rect(xx, bot - s, 1, s, roofDark)
        }
        c.rect(mid, top - rh - 2 * s, s, 2 * s, roofLit)
    }

    /// A round pavilion: slender pillars on a plinth under a cupola whose eaves flare out, with a finial.
    static func rivendellPavilion(_ c: PixelCanvas, _ cx: Int, _ base: Int, s: Int) {
        let wall = C(0xEEE6D6), shade = C(0xC8BCA8), roof = C(0x6A8A80), roofLit = C(0x9CB6A8)
        let ph = 11 * s, ring = base - 2 * s - ph
        c.rect(cx - 7 * s, ring, 14 * s, ph, C(0x5A4A40, 0.45))
        for dx in [-7, -3, 2, 6] { c.rect(cx + dx * s, ring, s, ph, dx > 0 ? shade : wall) }
        c.rect(cx - 9 * s, base - 2 * s, 18 * s, 2 * s, shade); c.rect(cx - 9 * s, base - 2 * s, 18 * s, s, wall)
        c.rect(cx - 8 * s, ring - 2 * s, 16 * s, 2 * s, wall); c.rect(cx + 4 * s, ring - 2 * s, 4 * s, 2 * s, shade)
        let rh = 9 * s
        for k in 0..<rh {
            let half = Int(Double(10 * s) * pow(1 - Double(k) / Double(rh), 1.7))
            c.rect(cx - half, ring - 2 * s - k, half * 2 + s, 1, roof)
            c.rect(cx - half, ring - 2 * s - k, max(s, half / 2), 1, roofLit)
        }
        c.rect(cx, ring - 2 * s - rh - 3 * s, s, 3 * s, roofLit)
    }

    /// A pale retaining wall of dressed stone holding up a terrace, from `top` down to `bottom`.
    static func rivendellTerraceWall(_ c: PixelCanvas, _ x: Int, _ w: Int, _ top: Int, _ bottom: Int, s: Int) {
        guard bottom > top, w > 0 else { return }
        c.rect(x, top, w, bottom - top, C(0xB0A48E))
        for (row, y) in stride(from: top + 3 * s, to: bottom, by: 4 * s).enumerated() {
            c.rect(x, y, w, s, C(0xA2967F))
            for xx in stride(from: x + (row % 2) * 5 * s, to: x + w, by: 10 * s) { c.rect(xx, y - 3 * s, s, 3 * s, C(0xA2967F)) }
        }
        c.rect(x, top, w, s, C(0xE2D8C6))
    }

    /// Tall screens: the upper tiers of the house, against the middle wall, with a stair down to the next.
    static func rivendellUpperTiers(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), cx = rivendellMid(c)
        let b1 = g * 56 / 100, b2 = g * 70 / 100
        rivendellTerraceWall(c, cx - 66 * s, 112 * s, b1, b2, s: s)
        rivendellHall(c, cx - 56 * s, b1, 52 * s, 14 * s, s: s, seed: 3)
        rivendellPavilion(c, cx + 28 * s, b1, s: s)
        rivendellTree(c, cx - 64 * s, b1, 5 * s, s: s, seed: 41)
        rivendellTerraceWall(c, cx - 110 * s, 220 * s, b2, b2 + 14 * s, s: s)
        // trees along the foot of the lower terrace, softening its wall
        for i in 0..<12 {
            let x = cx - 112 * s + i * 20 * s + Int(noise(i + 950) * Double(8 * s))
            rivendellTree(c, x, b2 + 16 * s, (4 + Int(noise(i + 951) * 3.0)) * s, s: s, seed: i + 80)
        }
        rivendellStair(c, cx + 44 * s, b1, cx + 70 * s, b2, s: s)
        rivendellHall(c, cx - 100 * s, b2, 40 * s, 12 * s, s: s, seed: 5)
        rivendellHall(c, cx - 40 * s, b2, 70 * s, 16 * s, s: s, seed: 7)
        rivendellPine(c, cx + 46 * s, b2, 20 * s, s: s)
        rivendellTree(c, cx + 60 * s, b2, 6 * s, s: s, seed: 43)
        rivendellTree(c, cx + 94 * s, b2, 5 * s, s: s, seed: 44)
    }

    /// A pale stair stepping down from one terrace to the next.
    static func rivendellStair(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, s: Int) {
        let steps = max(1, (y1 - y0) / (2 * s))
        for i in 0..<steps {
            let x = x0 + (x1 - x0) * i / steps, y = y0 + (y1 - y0) * i / steps
            c.rect(x, y, 6 * s, 2 * s, C(0xD8CEBC)); c.rect(x, y, 6 * s, s, C(0xF2EADA))
        }
        r3Line(c, x0 + 6 * s, y0 - 3 * s, x1 + 6 * s, y1 - 3 * s, C(0xEEE6D6), s: s)
    }

    /// The Last Homely House at the front: its main hall on a terrace, a round pavilion, a second hall higher up the
    /// slope, and autumn trees about them.
    static func rivendellHouse(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), cx = rivendellMid(c), tall = isTall(c)
        let b = g - (tall ? 12 : 9) * s, bR = g - (tall ? 24 : 18) * s, bL = g - (tall ? 18 : 13) * s
        rivendellTerraceWall(c, cx + 22 * s, 64 * s, bR, g, s: s)
        rivendellHall(c, cx + 28 * s, bR, (tall ? 50 : 40) * s, (tall ? 13 : 11) * s, s: s, seed: 9)
        rivendellTerraceWall(c, cx - 96 * s, 28 * s, bL, g, s: s)
        rivendellPavilion(c, cx - 82 * s, bL, s: s)
        rivendellTerraceWall(c, cx - 62 * s, 92 * s, b, g, s: s)
        rivendellHall(c, cx - 54 * s, b, (tall ? 74 : 62) * s, (tall ? 18 : 14) * s, s: s, seed: 11)
        // trees in front of the terraces
        let trees: [(Int, Int)] = [(-104, 6), (-66, 5), (24, 5), (14, 4), (92, 6), (-122, 7), (118, 5)]
        for (k, t) in trees.enumerated() {
            rivendellTree(c, cx + t.0 * s, g - 2 * s, (tall ? t.1 + 2 : t.1) * s, s: s, seed: k + 60)
        }
        rivendellPine(c, cx + 104 * s, g - 2 * s, (tall ? 30 : 22) * s, s: s)
    }

    /// The terrace the crew stands on: pale flagstones, and a slender balustrade along its far edge.
    static func rivendellTerrace(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), stone = C(0xE6DECE), shade = C(0xB8AE9C)
        // the balustrade: plinth, balusters, rail, and a post every so often
        c.rect(0, g - s, c.w, s, shade)
        for x in stride(from: s, to: c.w, by: 4 * s) {
            c.rect(x, g - 6 * s, s, 5 * s, stone); c.rect(x + s, g - 6 * s, s, 5 * s, shade.alpha(0.5))
        }
        c.rect(0, g - 8 * s, c.w, 2 * s, stone); c.rect(0, g - 7 * s, c.w, s, shade)
        for x in stride(from: 20 * s, to: c.w, by: 60 * s) {
            c.rect(x, g - 10 * s, 3 * s, 10 * s, stone); c.rect(x + 2 * s, g - 10 * s, s, 10 * s, shade)
            c.rect(x - s, g - 11 * s, 5 * s, s, C(0xF6F0E4))
        }
        c.ground(g, C(0xDAD0BE), edge: C(0xF4ECDC), speck: C(0xC8BCA8), seed: 41)
        for (row, y) in stride(from: g + 3 * s, to: c.h, by: 4 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0xC4B8A4))
            for x in stride(from: (row % 2) * 9 * s, to: c.w, by: 18 * s) { c.rect(x, y - 3 * s, s, 3 * s, C(0xC4B8A4)) }
        }
        // a few fallen leaves on the flagstones
        for i in 0..<max(0, c.w / (24 * s)) {
            let x = Int(noise(i * 2 + 940) * Double(c.w)), y = g + s + Int(noise(i * 2 + 941) * Double(max(1, c.h - g - s)))
            c.rect(x, y, s, s, noise(i + 945) > 0.5 ? C(0xD89A3A) : C(0xB0542A))
        }
    }

    /// Roughly the highest row the house, its terraces and their trees reach at column `x` (erring high), or `g` where
    /// they don't stand: below it, a fall behind them is hidden.
    static func rivendellHouseTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let s = unit(g), d = x - rivendellMid(c)
        var top = g
        if isTall(c) {
            let b1 = g * 56 / 100, b2 = g * 70 / 100
            if d >= -68 * s && d <= 48 * s { top = min(top, b1 - 28 * s) }
            if d >= 44 * s && d <= 84 * s { top = min(top, b1 - 4 * s) }
            if abs(d) <= 114 * s { top = min(top, b2 - 22 * s) }
            if d >= -130 * s && d <= 128 * s { top = min(top, g - 48 * s) }
        } else if d >= -130 * s && d <= 126 * s {
            top = g - 42 * s
        }
        return top
    }

    /// The waterfalls pouring down, the evening star twinkling (and on tall screens a few stars with it), and autumn
    /// leaves drifting off the valley's walls.
    static func rivendellLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), cx = rivendellMid(c), walls = rivendellWalls(c, g)
        let twoPi: Double = 2 * Double.pi
        // the falls: pale streaks running down each ribbon, only down to where a nearer wall, the house or the
        // balustrade hides it
        for f in rivendellFallSpots(c, g) {
            let top = max(0, f.top), last = f.wall == walls.count - 1
            var foot = true
            for (k, xx) in stride(from: f.x, to: f.x + f.width, by: s).enumerated() {
                var bot = min(last ? min(f.bottom, g - 8 * s) : f.bottom, rivendellHouseTop(c, g, xx))
                for wl in walls[(f.wall + 1)...] { bot = min(bot, wl.top(xx, cx: cx, s: s)) }
                if bot < f.bottom { foot = false }
                let h = bot - top
                guard h > 3 * s else { continue }
                let n = max(1, h / (9 * s)), speed = Double(36 * s) * (0.85 + 0.3 * noise(k + f.seed * 13 + 71))
                for j in 0..<n {
                    let y = top + r3Wrap(Double(j * h) / Double(n) + noise(k + f.seed * 13 + 70) * Double(h) + t * speed, h)
                    c.rect(xx, y, s, min(3 * s, bot - y), j % 2 == 0 ? C(0xFFFFFF, 0.75) : C(0x8EAEC4, 0.45))
                }
            }
            // spray breathing where a fall lands in sight
            if foot && !last {
                let p: Double = 0.5 + 0.5 * sin(t * twoPi / 1.7 + Double(f.seed))
                c.ellipse(f.x + f.width / 2, f.bottom - s, f.width / 2 + 2 * s + Int(p * Double(s)), 2 * s, C(0xFFFFFF, 0.1 + 0.2 * p))
            }
        }
        // Eärendil twinkling: its rays lengthening and brightening, and fading back
        let st = rivendellStar(c, g)
        let tw: Double = 0.5 + 0.5 * sin(t * twoPi / 2.8)
        let ray = 2 * s + Int(tw * Double(2 * s))
        c.rect(st.x - ray, st.y, ray * 2 + s, s, C(0xFFFFFF, 0.1 + 0.3 * tw))
        c.rect(st.x, st.y - ray, s, ray * 2 + s, C(0xFFFFFF, 0.1 + 0.3 * tw))
        c.circle(st.x, st.y, 2 * s + Int(tw * Double(2 * s)), C(0xFFF4E0, 0.12 * tw))
        // on tall screens, a few more stars coming and going, only in the open sky above the walls
        if tall {
            for i in 0..<8 {
                let x = Int(noise(i * 3 + 1400) * Double(c.w)), y = Int(noise(i * 3 + 1401) * Double(max(1, g / 4)))
                let sky = walls.map { $0.top(x, cx: cx, s: s) }.min() ?? g
                guard y < sky - 3 * s else { continue }
                let period = 3 + noise(i * 3 + 1402) * 3
                let a = pow(max(0, sin(r3Phase(t, period, offset: noise(i * 3 + 1403) * period) * twoPi)), 3)
                guard a > 0.02 else { continue }
                c.rect(x, y, s, s, C(0xFFFFFF, a))
                c.rect(x - s, y, 3 * s, s, C(0xFFFFFF, 0.3 * a)); c.rect(x, y - s, s, 3 * s, C(0xFFFFFF, 0.3 * a))
            }
        }
        // leaves blowing off the trees on the walls and drifting down across the valley, never down among the crew
        let golds: [UInt32] = [0xE0A83A, 0xC8702A, 0xA8442A, 0xE8C04E]
        for i in 0..<(tall ? 7 : 3) {
            let period = 9 + noise(i * 3 + 960) * 6
            let p = r3Phase(t, period, offset: noise(i * 3 + 961) * period)
            let left = i % 2 == 0
            let y0 = tall ? g * (20 + Int(noise(i * 3 + 962) * 30.0)) / 100 : 2 * s + Int(noise(i * 3 + 962) * Double(max(1, g / 3)))
            let x0 = c.w * (left ? 6 + Int(noise(i * 3 + 963) * 24.0) : 70 + Int(noise(i * 3 + 963) * 24.0)) / 100
            let x = x0 + (left ? 1 : -1) * Int(p * Double(c.w / 4)) + Int(sin(p * twoPi * 3 + Double(i)) * Double(4 * s))
            let y = y0 + Int(p * Double(g / 2))
            guard y < g - 14 * s else { continue }
            let a: Double = min(1, p / 0.1, (1 - p) / 0.15)
            r3Leaf(c, x, y, flat: sin(p * twoPi * 7 + Double(i)) > 0, C(golds[i % 4], a), s: s)
        }
    }
}

// MARK: - Lothlorem

extension Scenes {
    /// The wood's trunks, far to near: middle, half-width, and depth (0 far in the haze, 1 middle, 2 near).
    static func lothlorienTrunks(_ c: PixelCanvas, _ g: Int) -> [(x: Int, half: Int, depth: Int)] {
        let s = unit(g), tall = isTall(c)
        var out: [(x: Int, half: Int, depth: Int)] = []
        var x = -4 * s, i = 0
        while x < c.w + 4 * s {
            out.append((x, (2 + Int(noise(i * 3 + 400) * 2.0)) * s, 0))
            x += (18 + Int(noise(i * 3 + 401) * 16.0)) * s; i += 1
        }
        x = 30 * s; i = 0
        while x < c.w + 6 * s {
            out.append((x, (5 + Int(noise(i * 3 + 410) * 3.0)) * s, 1))
            x += (78 + Int(noise(i * 3 + 411) * 40.0)) * s; i += 1
        }
        for k in tall ? [0.1, 0.46, 0.84] : [0.12, 0.8] {
            out.append((Int(Double(c.w) * k), (tall ? 17 : 13) * s, 2))
        }
        return out
    }

    /// The colours of a trunk at a depth: bark, lit side, shaded side, the lines in the bark.
    static func lothlorienBark(_ depth: Int) -> (Px, Px, Px, Px) {
        let haze = C(0xE6D8A0), k = depth == 0 ? 0.62 : depth == 1 ? 0.3 : 0
        return (lerp(C(0xB4B8B6), haze, k), lerp(C(0xE6E8E2), haze, k), lerp(C(0x7E8488), haze, k),
                lerp(C(0x969C9E), haze, k))
    }

    /// A trunk's half-width at row `y`: straight, flaring into roots near the ground.
    static func lothlorienHalf(_ half: Int, _ g: Int, _ y: Int) -> Int {
        let flare = half * 2
        let k = r3Clamp(Double(y - (g - flare)) / Double(max(1, flare)))
        return half + Int(pow(k, 2.2) * Double(half) * 1.1)
    }

    /// The shafts of light: each one's left edge at the top, and its width (it slants two rows right in five down).
    static func lothlorienShafts(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int)] {
        let s = unit(g)
        return (0..<max(1, c.w / (90 * s))).map { i in
            (Int(noise(i * 2 + 420) * Double(c.w + g / 2)) - g / 3, (6 + Int(noise(i * 2 + 421) * 14.0)) * s)
        }
    }

    /// The flets on the middle rank of trunks: the trunk's middle and half-width, the platform's row, and a seed.
    static func lothlorienMidFlets(_ c: PixelCanvas, _ g: Int, _ trunks: [(x: Int, half: Int, depth: Int)])
        -> [(x: Int, y: Int, half: Int, seed: Int)] {
        let s = unit(g), tall = isTall(c)
        var out: [(x: Int, y: Int, half: Int, seed: Int)] = []
        for (k, t) in trunks.enumerated() where t.depth == 1 {
            let y = tall ? g * (36 + Int(noise(k + 430) * 24.0)) / 100 : g - (34 + Int(noise(k + 430) * 8.0)) * s
            if y > 6 * s { out.append((t.x, y, t.half, k)) }
        }
        return out
    }

    /// Tall screens: the flets on the `i`th near trunk, in the order they're drawn: their rows, reach, and so on.
    static func lothlorienCityFlets(_ g: Int, _ i: Int) -> [(y: Int, reach: Int, pavilion: Bool, seed: Int)] {
        let s = unit(g)
        let levels = [g * 30 / 100, g * 52 / 100]
        var out: [(y: Int, reach: Int, pavilion: Bool, seed: Int)] = []
        for (k, y) in levels.enumerated() {
            out.append((y + (k == 0 ? (i % 2) * 8 * s : -(i % 2) * 8 * s), 18 * s, true, i + k))
        }
        // a smaller flet near the top, in the canopy
        out.append((g * 16 / 100 + (i % 2) * 6 * s, 10 * s, false, i + 7))
        return out
    }

    /// The two lanterns under a flet: where each thread hangs from, and how long it is.
    static func lothlorienFletLanterns(_ x: Int, _ y: Int, _ half: Int, reach: Int, s: Int) -> [(x: Int, y: Int, drop: Int)] {
        let hw = half + reach
        return [(x + hw - 4 * s, y + 3 * s, 4 * s), (x - hw + 3 * s, y + 3 * s, 2 * s)]
    }

    /// Lothlorem: the Golden Wood. Golden haze between ranks of mallorn trunks, silver-grey, smooth, the nearer ones
    /// huge and flaring into roots; golden leaves in great clusters overhead, shafts of light slanting down, and white
    /// lanterns hanging under the flets up in the trees. The crew stands on a carpet of fallen golden leaves. On tall
    /// screens: the trunks rise into the canopy with their boughs, and Caras Galadhon is up among them, flets with
    /// little pavilions at several heights, stairs winding round the great trunks and rope bridges between.
    static func lothlorien(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0xD8C070), C(0xF4ECC6), bands: tall ? 10 : 6)
        // shafts of light slanting down through the canopy
        for sh in lothlorienShafts(c, g) {
            for y in stride(from: 0, to: g, by: 1) { c.rect(sh.x + y * 2 / 5, y, sh.w, 1, C(0xFFF8DC, 0.16)) }
        }
        let trunks = lothlorienTrunks(c, g)
        // the far canopy, hazy, then each rank of trunks, nearer and nearer
        lothlorienCanopy(c, g, depth: 0)
        for d in 0...2 {
            if d == 2 { lothlorienCanopy(c, g, depth: 1) }
            for t in trunks where t.depth == d { lothlorienTrunk(c, g, t.x, t.half, depth: d) }
            if d == 1 {
                for f in lothlorienMidFlets(c, g, trunks) {
                    lothlorienFlet(c, g, f.x, f.y, f.half, reach: 12 * s, pavilion: tall, seed: f.seed)
                }
            }
        }
        if tall { lothlorienCity(c, g, trunks.filter { $0.depth == 2 }) }
        lothlorienCanopy(c, g, depth: 2)
        lothlorienFloor(c, g)
    }

    /// One mallorn trunk standing from the top down to the ground, lit from the left, with lines in its bark.
    static func lothlorienTrunk(_ c: PixelCanvas, _ g: Int, _ x: Int, _ half: Int, depth: Int) {
        let s = unit(g), bark = lothlorienBark(depth)
        for y in 0..<g {
            let hw = lothlorienHalf(half, g, y)
            c.rect(x - hw, y, hw * 2, 1, bark.0)
            c.rect(x - hw, y, max(s, hw / 3), 1, bark.1)
            c.rect(x + hw - max(s, hw / 4), y, max(s, hw / 4), 1, bark.2)
        }
        guard depth > 0 else { return }
        // lines in the bark, running down and spreading into the roots
        for j in 0..<max(0, half * 2 / (6 * s)) {
            let off = -half + 3 * s + j * 6 * s + Int(noise(j + x + 440) * 2.0) * s
            let len = Int(Double(g) * (0.3 + noise(j + x + 441) * 0.5))
            let y0 = Int(noise(j + x + 442) * Double(max(1, g - len)))
            for y in y0..<max(y0, min(g, y0 + len)) {
                let spread = Double(lothlorienHalf(half, g, y)) / Double(max(1, half))
                c.rect(x + Int(Double(off) * spread), y, s, 1, bark.3.alpha(0.7))
            }
        }
    }

    /// Clusters of golden leaves: a hazy far layer, a middle one, and the near canopy across the top.
    static func lothlorienCanopy(_ c: PixelCanvas, _ g: Int, depth: Int) {
        let s = unit(g), tall = isTall(c)
        let haze = C(0xE6D8A0), k = depth == 0 ? 0.55 : depth == 1 ? 0.25 : 0
        let band = tall ? g * (depth == 0 ? 30 : depth == 1 ? 24 : 16) / 100 : (depth == 0 ? 16 : depth == 1 ? 12 : 9) * s
        let r = (tall ? 14 : 8) * s + depth * 2 * s
        for i in 0..<max(1, c.w / max(1, r)) {
            let x = Int(noise(i * 3 + depth * 100 + 450) * Double(c.w))
            let y = Int(noise(i * 3 + depth * 100 + 451) * Double(band)) - r / 3
            let rr = r / 2 + Int(noise(i * 3 + depth * 100 + 452) * Double(r))
            c.ellipse(x, y + rr / 3, rr * 3 / 2, max(1, rr * 2 / 3), lerp(C(0xA8781E), haze, k))
            c.ellipse(x, y, rr * 3 / 2, max(1, rr * 2 / 3), lerp(C(0xE0AC34), haze, k))
            c.ellipse(x - rr / 2, y - rr / 4, rr * 2 / 3, max(1, rr / 3), lerp(C(0xF6D866), haze, k))
            for j in 0..<6 {
                let lx = x + Int((noise(i * 7 + j + depth * 300 + 460) - 0.5) * Double(rr * 3))
                let ly = y + rr / 2 + Int(noise(i * 7 + j + depth * 300 + 461) * Double(rr))
                c.rect(lx, ly, s, s, lerp(noise(j + i) > 0.5 ? C(0xF6D866) : C(0xC88A24), haze, k))
            }
        }
        // on tall screens, leafy boughs hanging down between the trunks
        if tall && depth == 2 {
            for i in 0..<max(1, c.w / (50 * s)) {
                let x = Int(noise(i * 2 + 470) * Double(c.w)), y = band + Int(noise(i * 2 + 471) * Double(g / 8))
                c.ellipse(x, y + 2 * s, 12 * s, 5 * s, C(0xA8781E))
                c.ellipse(x, y, 12 * s, 5 * s, C(0xE0AC34))
                c.ellipse(x - 4 * s, y - 2 * s, 6 * s, 2 * s, C(0xF6D866))
            }
        }
    }

    /// A flet round a trunk: a pale platform on struts, a slender rail, maybe a little pavilion, a lantern beneath.
    static func lothlorienFlet(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, _ half: Int, reach: Int, pavilion: Bool,
                               seed: Int) {
        let s = unit(g), hw = half + reach
        let wood = C(0xE2D6B0), lit = C(0xF6EED4), dark = C(0x8A7A56)
        r3Line(c, x - half, y + 8 * s, x - hw + 2 * s, y + 2 * s, dark, s: s)
        r3Line(c, x + half - s, y + 8 * s, x + hw - 3 * s, y + 2 * s, dark, s: s)
        if pavilion {
            // a little tent-roofed talan, white, on the platform
            let px = x + (seed % 2 == 0 ? -1 : 1) * half / 2
            c.rect(px - 6 * s, y - 8 * s, 12 * s, 8 * s, C(0xF4F0E4)); c.rect(px + 3 * s, y - 8 * s, 3 * s, 8 * s, C(0xD4CCB8))
            c.rect(px - s, y - 6 * s, 2 * s, 6 * s, C(0xFFE8A0))
            for k in 0..<(5 * s) {
                let rw = 7 * s * (5 * s - k) / (5 * s)
                c.rect(px - rw, y - 8 * s - k, rw * 2 + s, 1, C(0xC8B888))
            }
        }
        c.rect(x - hw, y, hw * 2, 2 * s, wood); c.rect(x - hw, y, hw * 2, s, lit); c.rect(x - hw, y + 2 * s, hw * 2, s, dark)
        for px in stride(from: x - hw, to: x + hw, by: 3 * s) { c.rect(px, y - 4 * s, s, 4 * s, wood.alpha(0.9)) }
        c.rect(x - hw, y - 4 * s, hw * 2, s, lit)
        for l in lothlorienFletLanterns(x, y, half, reach: reach, s: s) { lothlorienLantern(c, l.x, l.y, drop: l.drop, s: s) }
    }

    /// A white lantern hanging on a thread, glowing softly.
    static func lothlorienLantern(_ c: PixelCanvas, _ x: Int, _ y: Int, drop: Int, s: Int) {
        c.rect(x, y, s, drop, C(0x8A7A56, 0.7))
        let ly = y + drop
        c.circle(x, ly + 2 * s, 7 * s, C(0xFFF8DC, 0.14))
        c.circle(x, ly + 2 * s, 4 * s, C(0xFFFBEA, 0.2))
        c.rect(x - s, ly, 3 * s, 4 * s, C(0xFFFCF0)); c.rect(x - s, ly, 3 * s, s, C(0xC8B888))
        c.rect(x, ly + 4 * s, s, s, C(0xC8B888))
    }

    /// Tall screens: Caras Galadhon on the near trunks: flets at several heights with pavilions, stairs winding round
    /// each trunk from the ground to the lowest flet, and rope bridges from flet to flet.
    static func lothlorienCity(_ c: PixelCanvas, _ g: Int, _ near: [(x: Int, half: Int, depth: Int)]) {
        let s = unit(g)
        let levels = [g * 30 / 100, g * 52 / 100]
        // rope bridges first, so the flets cover their ends
        for (a, b) in zip(near, near.dropFirst()) {
            for (k, y) in levels.enumerated() {
                let ya = y + (k == 0 ? 0 : 6 * s), yb = y - (k == 0 ? 8 * s : 0)
                let x0 = a.x + a.half + 20 * s, x1 = b.x - b.half - 20 * s
                guard x1 > x0 else { continue }
                r3Sag(c, x0, ya, x1, yb, sag: 10 * s, C(0xC8B888), s: s)
                r3Sag(c, x0, ya - 5 * s, x1, yb - 5 * s, sag: 9 * s, C(0xE2D6B0, 0.8), s: s)
                for i in 0..<max(0, (x1 - x0) / (8 * s)) {
                    let k = Double(i * 8 * s) / Double(max(1, x1 - x0)), a: Double = k * Double.pi
                    let x = x0 + i * 8 * s, yy = ya + Int(Double(yb - ya) * k + Double(10 * s) * sin(a))
                    c.rect(x, yy - 5 * s, s, 5 * s, C(0xC8B888, 0.8))
                }
            }
        }
        for (i, t) in near.enumerated() {
            lothlorienStair(c, g, t.x, t.half, from: g - 4 * s, to: levels[1] + 4 * s, seed: i)
            for f in lothlorienCityFlets(g, i) {
                lothlorienFlet(c, g, t.x, f.y, t.half, reach: f.reach, pavilion: f.pavilion, seed: f.seed)
            }
        }
    }

    /// A stair winding round a trunk: the treads on the near side, with a rail.
    static func lothlorienStair(_ c: PixelCanvas, _ g: Int, _ x: Int, _ half: Int, from y0: Int, to y1: Int, seed: Int) {
        let s = unit(g)
        var y = y0, i = 0
        while y > y1 {
            let a: Double = Double(i) * 0.2 + Double(seed) * 1.7
            let r = lothlorienHalf(half, g, y) + 2 * s
            if cos(a) > -0.15 {
                let sx = x + Int(sin(a) * Double(r))
                c.rect(sx - 2 * s, y, 4 * s, s, C(0xE2D6B0)); c.rect(sx - 2 * s, y + s, 4 * s, s, C(0x8A7A56, 0.6))
                if i % 3 == 0 { c.rect(sx, y - 4 * s, s, 4 * s, C(0xD4C8A0)) }
                c.rect(sx, y - 4 * s, s, s, C(0xF6EED4))
            }
            y -= s; i += 1
        }
    }

    /// The woodland floor: a carpet of fallen golden leaves, a few small white and gold flowers in it.
    static func lothlorienFloor(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        c.ground(g, C(0xCC9C34), edge: C(0xF0CC5A), speck: C(0xA87024), seed: 51)
        for i in 0..<max(0, c.w * (c.h - g) / (14 * s * s)) {
            let x = Int(noise(i * 3 + 480) * Double(c.w)), y = g + s + Int(noise(i * 3 + 481) * Double(max(1, c.h - g - s)))
            let n = noise(i * 3 + 482)
            c.rect(x, y, 2 * s, s, n > 0.6 ? C(0xF0C850) : n > 0.3 ? C(0xB8782A) : C(0xDDB040))
        }
        for i in 0..<max(0, c.w / (40 * s)) {
            let x = Int(noise(i * 2 + 490) * Double(c.w)), y = g + s + Int(noise(i * 2 + 491) * Double(max(1, c.h - g - 2 * s)))
            c.rect(x, y, s, s, noise(i + 495) > 0.5 ? C(0xFFFFF0) : C(0xFFE060))
        }
        // and leaves drifting down
        for i in 0..<max(0, c.w * g / (2200 * s * s)) {
            let x = Int(noise(i * 2 + 500) * Double(c.w)), y = Int(noise(i * 2 + 501) * Double(g))
            c.rect(x, y, s, s, noise(i + 505) > 0.5 ? C(0xF0C440) : C(0xD89A2A))
        }
    }

    /// Where the lanterns glow (the middle of each glow), leaving out those hidden behind a near trunk.
    static func lothlorienLanternGlows(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int)] {
        let s = unit(g), trunks = lothlorienTrunks(c, g), near = trunks.filter { $0.depth == 2 }
        var out: [(x: Int, y: Int)] = []
        for f in lothlorienMidFlets(c, g, trunks) {
            for l in lothlorienFletLanterns(f.x, f.y, f.half, reach: 12 * s, s: s) {
                let y = l.y + l.drop + 2 * s
                guard !near.contains(where: { abs(l.x - $0.x) < lothlorienHalf($0.half, g, y) + 2 * s }) else { continue }
                out.append((l.x, y))
            }
        }
        guard isTall(c) else { return out }
        for (i, t) in near.enumerated() {
            for f in lothlorienCityFlets(g, i) {
                for l in lothlorienFletLanterns(t.x, f.y, t.half, reach: f.reach, s: s) { out.append((l.x, l.y + l.drop + 2 * s)) }
            }
        }
        return out
    }

    /// Golden leaves drifting down, motes turning in the shafts of light as the light swells and fades, and the
    /// lanterns' glow pulsing softly.
    static func lothlorienLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c)
        let twoPi: Double = 2 * Double.pi
        let canopy = tall ? g * 16 / 100 : 9 * s
        // the shafts: each brightening and dimming slowly, with motes drifting down it
        for (i, sh) in lothlorienShafts(c, g).enumerated() {
            let a: Double = 0.06 * (0.5 + 0.5 * sin(t * twoPi / 7 + Double(i) * 2.1))
            if a > 0.006 {
                for y in canopy..<max(canopy, g - 10 * s) { c.rect(sh.x + y * 2 / 5, y, sh.w, 1, C(0xFFF8DC, a)) }
            }
            for j in 0..<(tall ? 6 : 3) {
                let n = i * 11 + j, period = 14 + noise(n * 3 + 1000) * 10
                let p = r3Phase(t, period, offset: noise(n * 3 + 1001) * period)
                let y = canopy + Int(p * Double(max(0, g - 14 * s - canopy)))
                let x = sh.x + y * 2 / 5 + Int(noise(n * 3 + 1002) * Double(sh.w)) + Int(sin(t * 0.7 + Double(n)) * Double(2 * s))
                let glint: Double = sin(p * Double.pi) * (0.55 + 0.45 * sin(t * 3 + Double(n)))
                c.rect(x, y, s, s, C(0xFFFBE8, 0.85 * glint))
            }
        }
        // leaves drifting down from the canopy, fading as they come down by the crew
        let golds: [UInt32] = [0xF0C440, 0xD89A2A, 0xF6D866, 0xC88A24]
        let bottom = g - 10 * s
        if bottom > canopy {
            for i in 0..<(tall ? 22 : 8) {
                let period = 8 + noise(i * 4 + 1100) * 7
                let p = r3Phase(t, period, offset: noise(i * 4 + 1101) * period)
                let y = canopy + Int(p * Double(bottom - canopy))
                let x = Int(noise(i * 4 + 1102) * Double(c.w)) + Int(p * Double(30 * s)) + Int(sin(p * twoPi * 2.5 + Double(i)) * Double(5 * s))
                let a: Double = min(1, p / 0.08, (1 - p) / 0.15)
                r3Leaf(c, x, y, flat: sin(t * 5 + Double(i) * 1.7) > -0.2, C(golds[i % 4], a), s: s)
            }
        }
        // the lanterns' glow
        for (i, l) in lothlorienLanternGlows(c, g).enumerated() {
            let p: Double = 0.5 + 0.5 * sin(t * twoPi / 3.2 + Double(i) * 1.3)
            c.circle(l.x, l.y, 5 * s + Int(p * Double(3 * s)), C(0xFFF8DC, 0.04 + 0.12 * p))
        }
    }
}

// MARK: - Thrandual's Halls

extension Scenes {
    /// The hill the halls are dug into: its middle and half-width.
    static func mirkwoodHill(_ c: PixelCanvas, _ g: Int) -> (x: Int, half: Int) {
        (c.w * 58 / 100, isTall(c) ? c.w * 46 / 100 : 150 * unit(g))
    }

    /// The top of the hill at column `x` (`g` off it).
    static func mirkwoodHillTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let s = unit(g), hill = mirkwoodHill(c, g), u = Double(x - hill.x) / Double(max(1, hill.half))
        guard abs(u) < 1 else { return g }
        let tall = isTall(c), height = tall ? Double(g) * 0.84 : Double(max(0, g - 6 * s))
        let a: Double = u * Double.pi / 2
        return g - Int(height * pow(cos(a), tall ? 0.3 : 0.55)) - Int(noise(x / (4 * s) + 520) * 2.0) * s
    }

    /// The carved stone face round the gate: its half-width and the row where its rounded top starts.
    static func mirkwoodFace(_ c: PixelCanvas, _ g: Int) -> (half: Int, top: Int, rise: Int) {
        let s = unit(g)
        if isTall(c) { return (c.w * 30 / 100, g * 26 / 100, g * 8 / 100) }
        return (34 * s, g - 36 * s, 8 * s)
    }

    /// The gate's opening: half-width, the height of its straight sides, and the threshold row (on top of the steps).
    static func mirkwoodGate(_ c: PixelCanvas, _ g: Int) -> (half: Int, side: Int, sill: Int) {
        let s = unit(g)
        return isTall(c) ? (16 * s, 30 * s, g - 4 * s) : (11 * s, 18 * s, g - 3 * s)
    }

    /// The bridge over the river, on the left: its ends and its deck's row at the ends.
    static func mirkwoodBridge(_ c: PixelCanvas, _ g: Int) -> (x0: Int, x1: Int, deck: Int) {
        let s = unit(g), x0 = max(8 * s, c.w * 4 / 100)
        return (x0, x0 + (isTall(c) ? 130 : 104) * s, g - (isTall(c) ? 16 : 13) * s)
    }

    /// Thrandual's Halls: deep in Mirkwood, dark tangled trees, moss hanging from their boughs, a few flecks of
    /// green-gold light getting through. Ahead a hill, gripped by great roots, and cut into it a carved stone face
    /// with the Elvenking's gate: tall doors under an arch held up by pillars carved as trees, their branches meeting
    /// overhead, steps up to it and green-gold lanterns either side. On the left a wooden bridge crosses the dark
    /// river. The crew stands on the flagstones before the gate. On tall screens the hill rises into a cliff and the
    /// carved face goes up with it, opened by great arches into the halls within: pillars like trees branching into
    /// the vaults, walkways without rails, roots hanging from the roof, and lanterns glowing deep inside.
    static func mirkwood(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x08100A), C(0x1C2818), bands: tall ? 10 : 6)
        mirkwoodForest(c, g, depth: 0)
        mirkwoodForest(c, g, depth: 1)
        // the hill, mossy earth, with stones in it
        let hill = mirkwoodHill(c, g)
        for x in max(0, hill.x - hill.half)..<max(max(0, hill.x - hill.half), min(c.w, hill.x + hill.half)) {
            let top = mirkwoodHillTop(c, g, x)
            guard top < g else { continue }
            c.rect(x, top, 1, g - top, C(0x222C1C))
            c.rect(x, top, 1, s, C(0x34421E))
        }
        for i in 0..<max(0, hill.half * g / (60 * s * s)) {
            let x = hill.x - hill.half + Int(noise(i * 3 + 530) * Double(hill.half * 2)), top = mirkwoodHillTop(c, g, x)
            guard top < g - 2 * s else { continue }
            let y = top + s + Int(noise(i * 3 + 531) * Double(g - top - 2 * s))
            c.rect(x, y, s * (1 + Int(noise(i * 3 + 532) * 3.0)), s, noise(i + 533) > 0.5 ? C(0x34421E) : C(0x1A2216))
        }
        if tall { mirkwoodHillTrees(c, g) }
        mirkwoodFaceDraw(c, g)
        mirkwoodRoots(c, g)
        mirkwoodGateDraw(c, g)
        mirkwoodRiver(c, g)
        mirkwoodForest(c, g, depth: 2)
        mirkwoodCourt(c, g)
    }

    /// Ranks of Mirkwood's trees: dark twisted trunks with crooked boughs, moss hanging, under a black canopy flecked
    /// with green-gold. Rank 0 is far and dim, 1 nearer; 2 is a couple of great gnarled trees at the edges.
    static func mirkwoodForest(_ c: PixelCanvas, _ g: Int, depth: Int) {
        let s = unit(g), tall = isTall(c)
        let trunk = depth == 0 ? C(0x16201A) : depth == 1 ? C(0x1A1A12) : C(0x161410)
        let lit = depth == 0 ? C(0x1E2A20) : depth == 1 ? C(0x2C2C1C) : C(0x2E2A1C)
        var xs: [(Int, Int)] = []
        if depth == 2 {
            xs = [(c.w - 14 * s, (tall ? 14 : 9) * s)]
            if c.w > 300 * s { xs.append((c.w * 34 / 100, (tall ? 10 : 7) * s)) }
        } else {
            var x = Int(noise(depth + 540) * Double(20 * s)), i = 0
            while x < c.w + 10 * s {
                xs.append((x, (depth == 0 ? 2 + Int(noise(i + 541) * 2.0) : 3 + Int(noise(i + 542) * 3.0)) * s))
                x += (depth == 0 ? 16 + Int(noise(i + 543) * 14.0) : 34 + Int(noise(i + 544) * 30.0)) * s; i += 1
            }
        }
        for (i, t) in xs.enumerated() {
            let (x, half) = t
            let f = Double(9 * s + Int(noise(i + depth * 50 + 550) * Double(12 * s)))
            for y in 0..<g {
                let flare = r3Clamp(Double(y - (g - 6 * half)) / Double(max(1, 6 * half)))
                let hw = half + Int(flare * flare * Double(half * 2))
                let sway = Int(sin(Double(y) / f + Double(i)) * Double(2 * s))
                c.rect(x + sway - hw, y, hw * 2, 1, trunk)
                c.rect(x + sway - hw, y, s, 1, lit)
            }
            // crooked boughs
            for b in 0..<(depth == 2 ? 4 : 2) {
                let by = Int(Double(g) * (0.08 + noise(i * 5 + b + depth * 70 + 560) * (tall ? 0.5 : 0.4)))
                let dir = b % 2 == 0 ? -1 : 1, len = (12 + Int(noise(i * 5 + b + 561) * 20.0)) * s * (depth == 2 ? 2 : 1)
                r3Root(c, x, by, x + dir * len, by - len / 3, bend: -len / 4, t: max(s, half * 2 / 3), trunk, lit: lit)
                // moss hanging from the bough
                for m in 0..<3 {
                    let mx = x + dir * len * (m + 1) / 4, my = by - len * (m + 1) / 12 - len / 6
                    let ml = (4 + Int(noise(i * 9 + b * 3 + m + 570) * 10.0)) * s
                    c.rect(mx, my, s, ml, C(0x2E3E22, 0.8)); c.rect(mx + s, my, s, ml * 2 / 3, C(0x243218, 0.7))
                }
            }
        }
        // the canopy over this rank
        let band = tall ? g * (depth == 0 ? 16 : 10) / 100 : (depth == 0 ? 8 : 5) * s
        guard depth < 2 else { return }
        for i in 0..<max(1, c.w / (10 * s)) {
            let x = Int(noise(i * 3 + depth * 100 + 580) * Double(c.w)), y = Int(noise(i * 3 + depth * 100 + 581) * Double(band))
            let r = (6 + Int(noise(i * 3 + depth * 100 + 582) * 8.0)) * s
            c.ellipse(x, y, r * 3 / 2, r, depth == 0 ? C(0x0E1A10) : C(0x0A120A))
            if noise(i + depth * 40 + 585) > 0.6 { c.rect(x - r / 2, y + r / 2, s, s, C(0x8A9A3A, 0.7)) }
        }
    }

    /// Tall screens: trees standing on top of the hill.
    static func mirkwoodHillTrees(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), hill = mirkwoodHill(c, g)
        for i in 0..<max(0, hill.half / (16 * s)) {
            let x = hill.x - hill.half + Int(noise(i * 2 + 590) * Double(hill.half * 2))
            let top = mirkwoodHillTop(c, g, x)
            guard top < g else { continue }
            let half = (2 + Int(noise(i * 2 + 591) * 3.0)) * s
            for y in 0..<max(0, top + 2 * s) {
                let sway = Int(sin(Double(y) / Double(14 * s) + Double(i)) * Double(2 * s))
                c.rect(x + sway - half, y, half * 2, 1, C(0x161810)); c.rect(x + sway - half, y, s, 1, C(0x262818))
            }
        }
    }

    /// The carved stone face: a wall of dressed blocks with a rounded top and a carved rim, and on tall screens the
    /// arches opening into the halls.
    static func mirkwoodFaceDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = mirkwoodFace(c, g), cx = mirkwoodHill(c, g).x, tall = isTall(c)
        let stone = C(0x3C4434), joint = C(0x2C3226), rim = C(0x5A6448)
        func top(_ x: Int) -> Int {
            let u = Double(x - cx) / Double(max(1, f.half))
            return f.top - Int(Double(f.rise) * (max(0, 1 - u * u)).squareRoot())
        }
        for x in (cx - f.half)..<max(cx - f.half, cx + f.half) {
            let t = top(x)
            c.rect(x, t, 1, max(0, g - t), stone)
            c.rect(x, t, 1, 2 * s, rim)
        }
        for (row, y) in stride(from: f.top - f.rise + 6 * s, to: g, by: 6 * s).enumerated() {
            for x in stride(from: cx - f.half, to: cx + f.half, by: s) where top(x) < y - 2 * s {
                c.px(x, y, joint)
                if (x - cx + f.half + (row % 2) * 7 * s) % (14 * s) < s { c.rect(x, y - 6 * s, 1, 6 * s, joint) }
            }
        }
        c.rect(cx - f.half - 2 * s, f.top, 2 * s, g - f.top, rim)
        c.rect(cx + f.half, f.top, 2 * s, g - f.top, joint)
        guard tall else { return }
        // the arches into the halls, with a ledge under them
        let arches = mirkwoodArches(c, g), bottom = arches.first?.bottom ?? g
        c.rect(cx - f.half, bottom, f.half * 2, 3 * s, rim); c.rect(cx - f.half, bottom + 3 * s, f.half * 2, s, joint)
        for a in arches { mirkwoodHallView(c, g, x0: a.x0, x1: a.x1, top: a.top, bottom: a.bottom, seed: a.seed) }
    }

    /// Tall screens: the great arches into the halls (two side ones, then the main one): their sides, top and bottom.
    static func mirkwoodArches(_ c: PixelCanvas, _ g: Int) -> [(x0: Int, x1: Int, top: Int, bottom: Int, seed: Int)] {
        guard isTall(c) else { return [] }
        let s = unit(g), f = mirkwoodFace(c, g), cx = mirkwoodHill(c, g).x
        let gate = mirkwoodGate(c, g), bottom = gate.sill - gate.side - gate.half - 18 * s
        let mainHalf = f.half * 26 / 100, sideHalf = f.half * 17 / 100
        return [(cx - f.half * 62 / 100, sideHalf), (cx + f.half * 62 / 100, sideHalf), (cx, mainHalf)].enumerated().map { k, a in
            (a.0 - a.1, a.0 + a.1, k == 2 ? f.top + 6 * s : f.top + 22 * s, bottom, k)
        }
    }

    /// The lanterns in a view into the halls: those along the walkway (behind the near pillars), and the one hanging
    /// in the middle, in front.
    static func mirkwoodHallLanterns(x0: Int, x1: Int, top: Int, bottom: Int, s: Int)
        -> (walk: [(x: Int, y: Int)], front: (x: Int, y: Int)) {
        let walk = top + (bottom - top) * 58 / 100
        return (stride(from: x0 + 9 * s, to: x1 - 4 * s, by: 22 * s).map { ($0, walk - 5 * s) },
                (x0 + (x1 - x0) / 2, top + (bottom - top) / 3))
    }

    /// The lanterns by the gate: on the posts either side of the steps, and the one hanging in the arch.
    static func mirkwoodGateLanterns(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int)] {
        let s = unit(g), cx = mirkwoodHill(c, g).x, gate = mirkwoodGate(c, g)
        let spring = gate.sill - gate.side, rise = gate.half * 3 / 4
        return [(cx - gate.half - 16 * s, g - 14 * s), (cx + gate.half + 16 * s, g - 14 * s), (cx, spring - rise / 3)]
    }

    /// The lantern at the bridge's far end.
    static func mirkwoodBridgeLantern(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int) {
        let s = unit(g), b = mirkwoodBridge(c, g)
        return (b.x1 - 2 * s, b.deck - 9 * s)
    }

    /// Tall screens: a view through one of the great arches into the halls: trunk-pillars rank behind rank,
    /// branching into the vaults, a walkway without rails, lanterns, and roots hanging from the roof.
    static func mirkwoodHallView(_ c: PixelCanvas, _ g: Int, x0: Int, x1: Int, top: Int, bottom: Int, seed: Int) {
        let s = unit(g), w = x1 - x0, h = bottom - top
        guard w > 8 * s, h > 8 * s else { return }
        c.rect(x0, top, w, h, C(0x0A100A))
        c.ellipse(x0 + w / 2, bottom - h / 4, w / 2, h / 3, C(0x5A6A28, 0.2))
        c.ellipse(x0 + w / 2, bottom - h / 4, w / 3, h / 5, C(0xA8B848, 0.12))
        let walk = top + h * 58 / 100, lamps = mirkwoodHallLanterns(x0: x0, x1: x1, top: top, bottom: bottom, s: s)
        for rank in [1, 0] {
            let step = (rank == 1 ? 14 : 26) * s, pw = (rank == 1 ? 3 : 5) * s
            let col = rank == 1 ? C(0x1C2618) : C(0x303A28), lit = rank == 1 ? C(0x2A3820) : C(0x5A6A3A)
            if rank == 0 {
                // the walkway, between the far rank and the near
                c.rect(x0, walk, w, 2 * s, C(0x2C3424)); c.rect(x0, walk, w, s, C(0x6A7A44))
                for l in lamps.walk { mirkwoodLantern(c, l.x, l.y, s: s) }
            }
            for (i, px) in stride(from: x0 + step / 2 + (rank == 1 ? 0 : step / 4), to: x1, by: step).enumerated() {
                let f = Double(9 * s)
                for y in top..<bottom {
                    let sway = Int(sin(Double(y) / f + Double(i + seed)) * Double(s))
                    c.rect(px + sway - pw / 2, y, pw, 1, col); c.rect(px + sway - pw / 2, y, s, 1, lit)
                }
                let fork = top + h / 4
                r3Line(c, px, fork, max(x0, px - step / 2), top, col, s: rank == 1 ? s : 2 * s)
                r3Line(c, px, fork, min(x1 - 2 * s, px + step / 2), top, col, s: rank == 1 ? s : 2 * s)
                c.rect(px - pw / 2 - s, bottom - 3 * s, pw + 2 * s, 3 * s, col)
            }
        }
        // roots hanging down from the roof
        for i in 0..<max(0, w / (7 * s)) {
            let x = x0 + Int(noise(i * 2 + seed * 40 + 600) * Double(w)), len = Int(noise(i * 2 + seed * 40 + 601) * Double(h) * 0.35)
            for y in stride(from: top, to: top + len, by: s) {
                c.rect(x + Int(sin(Double(y) / Double(5 * s) + Double(i)) * Double(s)), y, s, s, C(0x2A2218))
            }
        }
        mirkwoodLantern(c, lamps.front.x, lamps.front.y, s: s)
        // the arch: stone over the top corners, and a carved rim round it
        let arch = min(h / 2, w / 2), mid = x0 + w / 2
        for y in top..<(top + arch) {
            let k = Double(top + arch - y) / Double(max(1, arch))
            let half = Int(Double(w / 2) * (max(0, 1 - k * k)).squareRoot())
            c.rect(x0 - s, y, mid - half - x0 + s, 1, C(0x3C4434))
            c.rect(mid + half, y, x1 - mid - half + s, 1, C(0x3C4434))
            c.rect(mid - half - 2 * s, y, 2 * s, 1, C(0x5A6448)); c.rect(mid + half, y, 2 * s, 1, C(0x4A5440))
        }
        c.rect(x0 - 2 * s, top + arch, 2 * s, max(0, bottom - top - arch), C(0x5A6448))
        c.rect(x1, top + arch, 2 * s, max(0, bottom - top - arch), C(0x4A5440))
    }

    /// A green-gold lantern hanging from a little bracket, with its glow.
    static func mirkwoodLantern(_ c: PixelCanvas, _ x: Int, _ y: Int, s: Int) {
        c.circle(x, y, 10 * s, C(0xB8D060, 0.08))
        c.circle(x, y, 5 * s, C(0xD8E880, 0.14))
        c.rect(x - s, y - 2 * s, 3 * s, 4 * s, C(0xE4F0A0))
        c.rect(x - s, y - 3 * s, 3 * s, s, C(0x2A2A1C)); c.rect(x - s, y + 2 * s, 3 * s, s, C(0x2A2A1C))
        c.rect(x, y - 5 * s, s, 2 * s, C(0x2A2A1C))
    }

    /// Great roots gripping the hill and the carved face's shoulders.
    static func mirkwoodRoots(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = mirkwoodFace(c, g), cx = mirkwoodHill(c, g).x, tall = isTall(c)
        let root = C(0x241C14), lit = C(0x3E3222)
        let reach = tall ? 3 : 1
        for side in [-1, 1] {
            for k in 0..<(reach + 1) {
                // each starts a little lower down the face's shoulder and bows out over the hill on its way down
                let x0 = cx + side * (f.half - (6 + k * 8) * s), y0 = f.top - f.rise / 2 + k * (tall ? (g - f.top) / 6 : 4 * s)
                let x1 = cx + side * (f.half + (18 + k * 14) * s), y1 = g - (k * 7 + 2) * s
                let bow = side * (tall ? (14 + k * 6) : 4) * s
                r3Root(c, x0, y0, x1, y1, bend: -(8 + k * 4) * s, bow: bow, t: (tall ? 7 : 5) * s - k * s, root, lit: lit)
            }
        }
        if tall {
            // roots draping over the top of the face
            for i in 0..<max(0, f.half / (12 * s)) {
                let x = cx - f.half + Int(noise(i * 2 + 610) * Double(f.half * 2))
                let len = (10 + Int(noise(i * 2 + 611) * 30.0)) * s, y = f.top - f.rise - 4 * s
                r3Root(c, x, y, x + Int((noise(i + 612) - 0.5) * Double(16 * s)), y + len, bend: 3 * s, t: 3 * s, root, lit: lit)
            }
        }
    }

    /// The gate: carved tree-pillars either side whose branches meet over the arch, the tall doors with their carving,
    /// the steps up, and the lanterns.
    static func mirkwoodGateDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), cx = mirkwoodHill(c, g).x, gate = mirkwoodGate(c, g)
        let spring = gate.sill - gate.side, rise = gate.half * 3 / 4
        let pillar = C(0x56604A), pLit = C(0x76805E), pDark = C(0x3A4232)
        // the steps
        for k in 0..<3 {
            let y = g - (k + 1) * (g - gate.sill) / 3, half = gate.half + (10 - k * 3) * s
            c.rect(cx - half, y, half * 2, g - y, C(0x4A5240)); c.rect(cx - half, y, half * 2, s, C(0x6A7458))
        }
        // the doors, under a pointed-round arch
        c.ellipse(cx, spring, gate.half + 3 * s, rise + 3 * s, C(0x5A6448))
        c.rect(cx - gate.half - 3 * s, spring, gate.half * 2 + 6 * s, gate.sill - spring, C(0x5A6448))
        c.ellipse(cx, spring, gate.half, rise, C(0x1E1A12))
        c.rect(cx - gate.half, spring, gate.half * 2, gate.sill - spring, C(0x1E1A12))
        c.rect(cx, spring - rise, s, rise + gate.sill - spring, C(0x0E0C08))
        for side in [-1, 1] {
            // carving on each door: a stem with leafy branches off it
            let dx = cx + side * gate.half / 2
            c.rect(dx, spring - rise / 2, s, gate.sill - spring + rise / 2 - 2 * s, C(0x3A3424))
            for y in stride(from: spring - rise / 3, to: gate.sill - 4 * s, by: 5 * s) {
                c.rect(dx - 2 * s, y, 2 * s, s, C(0x3A3424)); c.rect(dx + s, y + 2 * s, 2 * s, s, C(0x3A3424))
            }
            c.rect(cx + side * 2 * s, spring + gate.side / 2, s, 2 * s, C(0x8A8A5A))
        }
        // the tree-pillars, their branches arching over and meeting at the top
        let pw = max(3 * s, gate.half / 3)
        for side in [-1, 1] {
            let px = cx + side * (gate.half + 3 * s + pw / 2) - pw / 2
            c.rect(px, spring - 2 * s, pw, gate.sill - spring + 2 * s, pillar)
            c.rect(px, spring - 2 * s, s, gate.sill - spring + 2 * s, pLit); c.rect(px + pw - s, spring - 2 * s, s, gate.sill - spring + 2 * s, pDark)
            c.rect(px - s, gate.sill - 3 * s, pw + 2 * s, 3 * s, pillar)
            let top = spring - rise - 4 * s
            r3Root(c, px + pw / 2, spring - s, cx, top, bend: -rise / 2, t: pw * 2 / 3, pillar, lit: pLit)
            r3Root(c, px + pw / 2, spring - 2 * s, px + pw / 2 + side * 6 * s, spring - rise - 2 * s, bend: -2 * s, t: max(s, pw / 3), pillar, lit: pLit)
            r3Root(c, px + pw / 2, spring + 2 * s, cx + side * 4 * s, top + 3 * s, bend: -rise / 3, t: max(s, pw / 3), pillar, lit: pLit)
        }
        c.ellipse(cx, spring - rise - 4 * s, 3 * s, 2 * s, pLit)
        // lanterns on posts by the steps, and one hanging in the arch
        for (k, l) in mirkwoodGateLanterns(c, g).enumerated() {
            if k < 2 { c.rect(l.x, g - 12 * s, s, 12 * s, C(0x1E1A12)) }
            mirkwoodLantern(c, l.x, l.y, s: s)
        }
    }

    /// The dark river on the left, flowing out between rocky banks, and the wooden bridge arching over it.
    static func mirkwoodRiver(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), b = mirkwoodBridge(c, g), rock = C(0x262C20), rockLit = C(0x3A4430)
        let w0 = b.x0 + 12 * s, w1 = b.x1 - 12 * s, surface = g - 6 * s
        // the gap the river runs through: far bank in shadow, then the water
        c.rect(w0, b.deck, w1 - w0, surface - b.deck, C(0x0C140E))
        c.rect(w0, surface, w1 - w0, g - surface, C(0x0A1414))
        for i in 0..<max(0, (w1 - w0) / (5 * s)) {
            let x = w0 + Int(noise(i * 2 + 620) * Double(w1 - w0)), y = surface + s + Int(noise(i * 2 + 621) * Double(4 * s))
            c.rect(x, y, (2 + Int(noise(i + 622) * 4.0)) * s, s, noise(i + 623) > 0.6 ? C(0x5A7040, 0.7) : C(0x24403A, 0.8))
        }
        // the banks
        for (x, wd) in [(0, w0), (w1, max(0, b.x1 + 8 * s - w1))] {
            c.rect(x, b.deck + 2 * s, wd, g - b.deck - 2 * s, rock)
            c.rect(x, b.deck + 2 * s, wd, s, rockLit)
            for i in 0..<max(0, wd / (6 * s)) {
                c.rect(x + Int(noise(i + x + 630) * Double(wd)), b.deck + 4 * s + Int(noise(i + x + 631) * Double(g - b.deck - 6 * s)),
                       3 * s, s, C(0x1A2016))
            }
        }
        // the bridge: an arched beam under the deck, planks, posts and a rail of twisting branches
        let wood = C(0x4A3622), woodLit = C(0x7A5C38), dark = C(0x2A1E12), arch = 5 * s
        r3Sag(c, w0 - 2 * s, b.deck + 5 * s, w1 + 2 * s, b.deck + 5 * s, sag: -arch - 3 * s, dark, s: 2 * s)
        for x in b.x0..<max(b.x0, b.x1) {
            let k = Double(x - b.x0) / Double(max(1, b.x1 - b.x0))
            let a: Double = k * Double.pi
            let y = b.deck - Int(Double(arch) * sin(a))
            c.rect(x, y, 1, 3 * s, wood)
            c.rect(x, y, 1, s, (x - b.x0) % (3 * s) == 0 ? dark : woodLit)
        }
        for x in stride(from: b.x0 + s, to: b.x1, by: 9 * s) {
            let k = Double(x - b.x0) / Double(max(1, b.x1 - b.x0))
            let a: Double = k * Double.pi
            let y = b.deck - Int(Double(arch) * sin(a))
            c.rect(x, y - 6 * s, s, 6 * s, wood)
        }
        r3Sag(c, b.x0 + s, b.deck - 6 * s, b.x1 - s, b.deck - 6 * s, sag: -arch, woodLit, s: s)
        r3Sag(c, b.x0 + s, b.deck - 5 * s, b.x1 - s, b.deck - 5 * s, sag: -arch + s, wood, s: s)
        let bl = mirkwoodBridgeLantern(c, g)
        mirkwoodLantern(c, bl.x, bl.y, s: s)
    }

    /// The flagstones before the gate, mossy between the stones, the gate's light falling on them.
    static func mirkwoodCourt(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), cx = mirkwoodHill(c, g).x
        c.ground(g, C(0x383C30), edge: C(0x5A6250), speck: C(0x2A2E24), seed: 61)
        for (row, y) in stride(from: g + 3 * s, to: c.h, by: 4 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x2A3020))
            for x in stride(from: (row % 2) * 8 * s, to: c.w, by: 16 * s) { c.rect(x, y - 3 * s, s, 3 * s, C(0x2A3020)) }
        }
        for i in 0..<max(0, c.w * (c.h - g) / (40 * s * s)) {
            let x = Int(noise(i * 2 + 640) * Double(c.w)), y = g + s + Int(noise(i * 2 + 641) * Double(max(1, c.h - g - s)))
            c.rect(x, y, s, s, C(0x4A5A2A))
        }
        c.ellipse(cx, g + 2 * s, 40 * s, 4 * s, C(0xC8D870, 0.08))
    }

    /// Mist curling slowly through the trees, the dark river's slow shimmer, and the green-gold lanterns flickering.
    static func mirkwoodLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c)
        // mist: long pale wisps drifting along, each with a curl rising off it, coming round again past the edges
        let bands: [Int] = tall ? [g * 55 / 100, g * 78 / 100] : [g - 28 * s]
        let margin = 70 * s, span = c.w + 2 * margin
        for (bi, by) in bands.enumerated() {
            for i in 0..<(tall ? 5 : 3) {
                let n = bi * 10 + i
                let speed = Double(2 * s) + noise(n * 3 + 1300) * Double(3 * s)
                let x = r3Wrap(noise(n * 3 + 1301) * Double(span) + t * speed, span) - margin
                let y = by + Int(sin(t * 0.4 + Double(n) * 1.3) * Double(3 * s))
                let rx = (30 + Int(noise(n * 3 + 1302) * 30.0)) * s, ry = (3 + Int(noise(n * 3 + 1303) * 3.0)) * s
                c.ellipse(x, y, rx, ry, C(0x8A9A88, 0.07))
                let curl = Int(sin(t * 0.6 + Double(n)) * Double(6 * s))
                c.ellipse(x + rx / 3 + curl, y - ry, rx / 2, max(1, ry * 2 / 3), C(0xA0B0A0, 0.06))
            }
        }
        // the river: glints sliding slowly along its dark water, swelling and fading
        let b = mirkwoodBridge(c, g), w0 = b.x0 + 12 * s, w1 = b.x1 - 12 * s, surface = g - 6 * s
        if w1 > w0 + 8 * s {
            for i in 0..<max(0, (w1 - w0) / (6 * s)) {
                let period = 4 + noise(i * 3 + 1200) * 4
                let p = r3Phase(t, period, offset: noise(i * 3 + 1201) * period)
                let len = (2 + Int(noise(i * 3 + 1202) * 4.0)) * s
                let x = w0 + r3Wrap(noise(i * 3 + 1203) * Double(w1 - w0) + t * Double(3 * s), w1 - w0 - len)
                let y = surface + s + Int(noise(i * 3 + 1204) * 4.0) * s
                let a: Double = sin(p * Double.pi)
                c.rect(x, y, len, s, noise(i + 1205) > 0.7 ? C(0x9AB060, 0.45 * a) : C(0x3A6A5A, 0.6 * a))
            }
        }
        // the lanterns flickering: the glow everywhere, and the flame itself where nothing stands in front of it
        var lamps: [(x: Int, y: Int, front: Bool)] = mirkwoodGateLanterns(c, g).map { ($0.x, $0.y, true) }
        let bl = mirkwoodBridgeLantern(c, g)
        lamps.append((bl.x, bl.y, true))
        // the great trees at the front stand before the halls' lanterns
        var trees = [(c.w - 14 * s, (tall ? 14 : 9) * s)]
        if c.w > 300 * s { trees.append((c.w * 34 / 100, (tall ? 10 : 7) * s)) }
        for a in mirkwoodArches(c, g) {
            let l = mirkwoodHallLanterns(x0: a.x0, x1: a.x1, top: a.top, bottom: a.bottom, s: s)
            for w in l.walk { lamps.append((w.x, w.y, false)) }
            lamps.append((l.front.x, l.front.y, true))
        }
        for (i, l) in lamps.enumerated() {
            guard !trees.contains(where: { abs(l.x - $0.0) < $0.1 + 8 * s }) else { continue }
            let f: Double = 0.6 + 0.25 * sin(t * 5.1 + Double(i) * 1.9) + 0.15 * sin(t * 11.7 + Double(i) * 3.3)
            c.circle(l.x, l.y, 6 * s + Int(f * Double(3 * s)), C(0xC8E070, 0.03 + 0.08 * f))
            guard l.front else { continue }
            c.rect(l.x - s, l.y - 2 * s, 3 * s, 4 * s, f > 0.6 ? C(0xF8FFD8, (f - 0.6) * 1.4) : C(0x6A7A30, (0.6 - f) * 0.9))
        }
    }
}
