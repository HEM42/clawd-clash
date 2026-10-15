import Foundation

// The Golden Hall of Edit-oras, Helm Chart's Deep and Fangorn Fork.
let ringsScenes4: [Location: Place] = [
    .edoras: Place(name: "The Golden Hall of Edit-oras", panel: 0x241E12, still: Scenes.edoras),
    .helmsDeep: Place(name: "Helm Chart's Deep", panel: 0x1A1C20, still: Scenes.helmsDeep),
    .fangorn: Place(name: "Fangorn Fork", panel: 0x16200E, still: Scenes.fangorn),
]

// MARK: - Shared bits for these scenes

/// String art drawn with every character `s` pixels square, mirrored left to right when `flip` is set.
private func r4Stamp(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], _ pal: [Character: Px], s: Int,
                     flip: Bool = false) {
    for (r, row) in rows.enumerated() {
        let n = row.count
        for (k, ch) in row.enumerated() {
            guard let col = pal[ch] else { continue }
            c.rect(x + (flip ? n - 1 - k : k) * s, y + r * s, s, s, col)
        }
    }
}

/// A straight line of `s`-pixel dots.
private func r4Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// A range of snowy peaks standing on row `base`, up to `height` rows tall: each column is as high as the tallest
/// peak's slope there, the faces turned to the sun (the left ones) paler, and snow over the upper part of each.
private func r4Peaks(_ c: PixelCanvas, base: Int, height: Int, count: Int, seed: Int, s: Int,
                     lit: Px, shade: Px, snow: Px, snowShade: Px) {
    guard height > 0, c.w > 0 else { return }
    let n = max(1, count)
    var peaks: [(x: Double, h: Double, half: Double)] = []
    for i in 0..<n {
        let h = Double(height) * (0.5 + 0.5 * noise(i * 3 + seed))
        let x = (Double(i) + 0.2 + 0.6 * noise(i * 3 + 1 + seed)) / Double(n) * Double(c.w)
        peaks.append((x, h, h * (1.0 + noise(i * 3 + 2 + seed) * 0.8)))
    }
    for x in 0..<c.w {
        var best = 0.0, right = false, ph = 0.0
        for p in peaks {
            let v = p.h - abs(Double(x) - p.x) * p.h / max(1, p.half)
            if v > best { best = v; right = Double(x) > p.x; ph = p.h }
        }
        let top = base - Int(best) + Int(noise(x / max(1, 2 * s) + seed * 7 + 40) * Double(2 * s))
        guard top < base else { continue }
        c.rect(x, top, 1, base - top, right ? shade : lit)
        // the snow lies thickest on the summits and thins out down the flanks
        let depth = Int((best - ph * 0.5) * 0.9) + Int(noise(x / max(1, s) + seed * 5) * Double(3 * s))
        if depth > 0 { c.rect(x, top, 1, min(base - top, depth), right ? snowShade : snow) }
        c.rect(x, top, 1, min(s, base - top), depth > 0 ? snowShade : shade)
    }
}

/// A burning torch: a halo of warm light, the flame with its bright heart, and the stick under it. `u` is its size,
/// 1 far off to 3 close by.
private func r4Torch(_ c: PixelCanvas, _ x: Int, _ y: Int, _ u: Int, s: Int) {
    c.circle(x, y, 6 * u * s, C(0xE8802A, 0.06))
    c.circle(x, y, 3 * u * s, C(0xF0A040, 0.12))
    c.rect(x, y + s, s, (1 + 2 * u) * s, C(0x2A2018))
    if u <= 1 {
        c.rect(x, y - s, s, 2 * s, C(0xE8702A)); c.rect(x, y, s, s, C(0xFFD070))
    } else {
        c.ellipse(x, y - u * s / 2, max(1, u * s / 2), u * s, C(0xE8702A))
        c.ellipse(x, y - u * s / 4, max(1, u * s / 4), max(1, u * s / 2), C(0xFFD070))
    }
}

/// The white horse of Rohan, galloping right (12 by 7).
private let r4Horse: [String] = [
    "..........#.",
    ".........###",
    "#.......###.",
    ".#######.#..",
    "..######....",
    "..#.#..#.#..",
    ".#..#...#..#",
]

/// A carved horse's head, facing right (4 by 4).
private let r4HorseHead: [String] = [
    ".#..",
    "###.",
    "####",
    "##..",
]

// MARK: - The Golden Hall of Edit-oras

extension Scenes {
    /// Meduseld: the middle of its front gable, the gable's half-width, the row its walls stand on, the eaves' and the
    /// peak's rows, and how far its long side runs back (to the right, and up).
    static func edorasHall(_ c: PixelCanvas, _ g: Int) -> (x: Int, half: Int, floor: Int, eave: Int, peak: Int, dx: Int,
                                                          dy: Int) {
        let s = unit(g), tall = isTall(c)
        let floor = g - (tall ? 6 : 4) * s, eave = floor - (tall ? 22 : 16) * s
        return (Int(Double(c.w) * 0.3), (tall ? 42 : 32) * s, floor, eave, eave - (tall ? 32 : 24) * s,
                (tall ? 112 : 80) * s, (tall ? 10 : 7) * s)
    }

    /// The horizon, where the plains meet the mountains.
    static func edorasHorizon(_ c: PixelCanvas, _ g: Int) -> Int { isTall(c) ? Int(Double(g) * 0.42) : g - 22 * unit(g) }

    /// The Golden Hall of Edit-oras: Meduseld on the crown of its hill under a wide summer sky. The hall shows its
    /// gable end, with crossed horse-head bargeboards over a carved gable and great doors at the top of its steps, and
    /// its long golden thatched roof running back to the right. Banners of Rohan, green with the white horse, stream
    /// out in the wind from tall poles; behind, the plains roll away to the snowy White Mountains, and the town's roofs
    /// show over the terrace's low wall. The crew stands on the flagstones of the terrace. On tall screens the view
    /// opens out over the hillside below: the wooden houses stepping down it, the road winding to the gate in the
    /// palisade round the hill's foot, and the river across the plains beyond.
    static func edoras(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = edorasHorizon(c, g)
        c.gradient(0, hz, C(0x6FA4D4), C(0xD8E2DC), bands: tall ? 10 : 6)
        c.rect(0, hz, c.w, min(g, hz + 8 * s) - hz, C(0xD8E2DC))
        for i in 0..<(tall ? 8 : 4) {
            let x = Int(noise(i * 7 + 901) * Double(c.w))
            let y = tall ? g / 24 + Int(noise(i * 7 + 902) * Double(hz / 3)) : (3 + Int(noise(i * 7 + 902) * 7.0)) * s
            let r = (tall ? 4 + Int(noise(i * 7 + 903) * 5.0) : 2 + Int(noise(i * 7 + 903) * 2.0)) * s
            cloud(c, x, y, r, seed: i + 90, top: C(0xFFFBF0), base: C(0xD8DCE2))
        }
        if tall {
            for i in 0..<6 {
                let x = Int(noise(i * 5 + 911) * Double(c.w)), y = hz / 2 + Int(noise(i * 5 + 912) * Double(hz / 3))
                wisp(c, x, y, (40 + Int(noise(i * 5 + 913) * 60.0)) * s, C(0xF4F2E8, 0.6), s: s)
            }
        }
        // the White Mountains, far off and blue, with the snow on them
        r4Peaks(c, base: hz, height: tall ? Int(Double(g) * 0.22) : 16 * s, count: max(3, c.w / ((tall ? 64 : 48) * s)),
                seed: 920, s: s, lit: C(0x8C9EBA), shade: C(0x71809E), snow: C(0xF4F6FA), snowShade: C(0xC6D0E0))
        c.dunes(base: hz - s, amp: Double((tall ? 4 : 2) * s), freq: 0.03 / Double(s), phase: 0.6, bottom: g,
                C(0x8EA08C), shade: C(0xA6B49E))
        edorasPlains(c, g)
        edorasTown(c, g)
        // the terrace's low wall
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0xA89C80)); c.rect(0, g - 3 * s, c.w, s, C(0xCEC2A4))
        for x in stride(from: 5 * s, to: c.w, by: 14 * s) { c.rect(x, g - 2 * s, s, 2 * s, C(0x8E8268)) }
        let hall = edorasHall(c, g)
        // the banners, either side of the hall and one more along the terrace on tall screens
        let up = (tall ? 20 : 6) * s, len = (tall ? 40 : 30) * s
        edorasBanner(c, g, x: hall.x - hall.half - 24 * s, top: hall.peak - up, len: len, seed: 1)
        edorasBanner(c, g, x: hall.x + hall.half + hall.dx + 18 * s, top: hall.peak - hall.dy - up + 2 * s, len: len,
                     seed: 2)
        if tall { edorasBanner(c, g, x: Int(Double(c.w) * 0.86), top: hall.peak + 6 * s, len: len, seed: 3) }
        edorasHallDraw(c, g)
        // the flagstones of the terrace
        c.ground(g, C(0xA89A7C), edge: C(0xD6CAAA), speck: C(0x948870), seed: 31)
        for (j, y) in stride(from: g + 4 * s, to: c.h, by: 5 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x8E826A, 0.5))
            for x in stride(from: (j % 2) * 11 * s, to: c.w, by: 22 * s) { c.rect(x, y - 4 * s, s, 4 * s, C(0x8E826A, 0.5)) }
        }
    }

    /// The plains of Rohan: bands of grass, golden and green, paling into the haze, and on tall screens the river
    /// winding across them.
    static func edorasPlains(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = edorasHorizon(c, g), d = Double(g - hz)
        c.dunes(base: hz + Int(d * 0.12), amp: Double(s), freq: 0.02 / Double(s), phase: 2.0, bottom: g,
                C(0xA4AE72), shade: C(0xB8C088))
        c.dunes(base: hz + Int(d * (tall ? 0.24 : 0.35)), amp: Double((tall ? 3 : 2) * s), freq: 0.014 / Double(s),
                phase: 4.4, bottom: g, C(0xB8AC5E), shade: C(0xCCC07A))
        if tall {
            // the river, glinting
            let ry = hz + Int(d * 0.3)
            for x in 0..<c.w {
                let y = ry + Int(sin(Double(x) * 0.021 / Double(s)) * Double(5 * s) + sin(Double(x) * 0.006 / Double(s) + 1)
                                 * Double(8 * s))
                c.rect(x, y, 1, 2 * s, C(0x9CBCD0)); c.px(x, y, C(0xD8E8F0))
                if noise(x + 930) > 0.9 { c.px(x, y + s, C(0xF4FAFC)) }
            }
            c.dunes(base: hz + Int(d * 0.42), amp: Double(3 * s), freq: 0.011 / Double(s), phase: 1.1, bottom: g,
                    C(0xA6A450), shade: C(0xBEB866))
        }
        c.dunes(base: hz + Int(d * (tall ? 0.52 : 0.6)), amp: Double((tall ? 3 : 2) * s), freq: 0.017 / Double(s),
                phase: 5.2, bottom: g, C(0x9AA04C), shade: C(0xB0B460))
    }

    /// The town on the hill below the hall: the hillside, the palisade round its foot with its gate, the road climbing
    /// from the gate, and the thatched wooden houses, smaller the farther down the hill they stand.
    static func edorasTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        let top = tall ? Int(Double(g) * 0.6) : g - 12 * s, bottom = g - 2 * s
        guard bottom > top + 2 * s, c.w > 0 else { return }
        let mid = Int(Double(c.w) * 0.62), span = Double(c.w) * 0.7
        // the palisade's row at column x: the ring round the hill's foot, bowed towards us at the sides
        func ring(_ x: Int) -> Int {
            let d = Double(x - mid) / span
            return top + Int(d * d * Double(bottom - top) * 0.9)
        }
        // the hillside inside the ring
        for x in 0..<c.w {
            let y = ring(x)
            guard y < g else { continue }
            c.rect(x, y, 1, g - y, C(0x8C9846))
            for k in stride(from: y + 3 * s, to: g, by: 7 * s) where noise(x / max(1, 9 * s) + k + 940) > 0.5 {
                c.px(x, k, C(0x7E8A3E))
            }
        }
        // the road, from the gate up the hill towards us
        if tall {
            let d = bottom - top
            let pts: [(Int, Int)] = [(mid, ring(mid)), (mid - 50 * s, top + d / 3), (mid + 40 * s, top + d * 2 / 3),
                                     (mid - 10 * s, bottom + 4 * s)]
            for (i, (a, b)) in zip(pts, pts.dropFirst()).enumerated() {
                r4Line(c, a.0, a.1, b.0, b.1, C(0xCDBE8E), s: (2 + i) * s)
            }
        }
        // the houses, sorted so the nearer ones (lower down) overlap the farther
        var houses: [(x: Int, y: Int)] = []
        for i in 0..<max(0, c.w * (bottom - top) / ((tall ? 900 : 420) * s * s)) {
            let x = Int(noise(i * 3 + 950) * Double(c.w))
            let y = top + Int(noise(i * 3 + 951) * Double(bottom - top))
            if y > ring(x) + 4 * s { houses.append((x, y)) }
        }
        houses.sort { $0.y < $1.y }
        for (i, h) in houses.enumerated() {
            let k = Double(h.y - top) / Double(bottom - top), z = tall ? 1.0 + k * 1.6 : 0.8
            let half = max(1, Int(3.0 * z) * s), wall = max(1, Int(2.5 * z) * s), roof = max(1, Int(3.5 * z) * s)
            let dx = max(1, Int(6.0 * z) * s)
            let dark = noise(i + 960) > 0.5
            edorasBuilding(c, x: h.x, half: half, floor: h.y, eave: h.y - wall, peak: h.y - wall - roof, dx: dx,
                           dy: max(1, dx / 5), s: s, board: s,
                           thatch: dark ? C(0xA88438) : C(0xC09A44), course: dark ? C(0x846628) : C(0x9A7A30),
                           ridge: C(0xD8B45A), wall: C(0x7A5634), side: C(0x5A3E24), gable: C(0x684A2C),
                           edge: C(0x5A4024))
            if tall, k > 0.3 { c.rect(h.x - s / 2, h.y - wall * 2 / 3, s, wall * 2 / 3, C(0x2E2014)) }
        }
        // the palisade, with the gate and its two little towers
        for x in stride(from: 0, to: c.w, by: max(1, 2 * s)) where abs(x - mid) > 5 * s {
            let y = ring(x), k = Double(y - top) / Double(bottom - top)
            let hgt = (tall ? Int(3 + k * 4) : 2) * s
            c.rect(x, y - hgt, s, hgt, C(0x6A4A2C)); c.px(x, y - hgt - 1, C(0x8A6A44))
        }
        for side in [-1, 1] {
            let tx = mid + side * 6 * s - (side < 0 ? 3 * s : 0), ty = ring(mid)
            c.rect(tx, ty - (tall ? 9 : 4) * s, 3 * s, (tall ? 9 : 4) * s, C(0x5A3E24))
            c.rect(tx - s, ty - (tall ? 10 : 5) * s, 5 * s, s, C(0xB8903E))
        }
    }

    /// A gabled building with its gable end towards us and its long side running back to the right: the side wall,
    /// the sunlit slope of its thatch, the front wall, and the gable under its bargeboards.
    static func edorasBuilding(_ c: PixelCanvas, x: Int, half: Int, floor: Int, eave: Int, peak: Int, dx: Int, dy: Int,
                               s: Int, board: Int, thatch: Px, course: Px, ridge: Px, wall: Px, side: Px, gable: Px,
                               edge: Px) {
        guard half > 0, dx > 0, eave > peak, floor > eave else { return }
        let xr = x + half, rise = eave - peak
        // the long side wall
        for col in xr..<(xr + dx) {
            let up = (col - xr) * dy / dx
            c.rect(col, eave - up, 1, floor - eave, side)
        }
        // the roof's right slope, from its ridge down to its eaves
        for col in x..<(xr + dx) {
            let top = col <= x + dx ? peak - (col - x) * dy / dx : peak - dy + (col - x - dx) * rise / half
            let bot = col <= xr ? peak + (col - x) * rise / half : eave - (col - xr) * dy / dx
            guard bot > top else { continue }
            for y in top..<bot {
                let v = y + (col - x) * dy / dx - peak
                c.px(col, y, v % max(2, 3 * s) == 0 ? course : thatch)
            }
            c.rect(col, top, 1, min(s, bot - top), ridge)
        }
        // the front wall and the gable
        c.rect(x - half, eave, half * 2, floor - eave, wall)
        for r in 0..<rise {
            let hw = half * r / rise
            c.rect(x - hw, peak + r, hw * 2 + 1, 1, gable)
        }
        // the bargeboards along the gable's edges
        r4Line(c, x - half - board, eave + board / 2, x, peak, edge, s: board)
        r4Line(c, x + half + board / 2, eave + board / 2, x, peak, edge, s: board)
    }

    /// Meduseld itself, on its stone platform: the building, then its carved and gilded details, the crossed horse
    /// heads, the doors and their steps.
    static func edorasHallDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), h = edorasHall(c, g), rise = h.eave - h.peak, xr = h.x + h.half
        let gold = C(0xE0B040), green = C(0x2E5A32), dark = C(0x3A2414)
        guard h.half > 0, h.dx > 0, rise > 0 else { return }
        // the platform: its top running back along the hall, and its stone face down to the terrace
        for col in (h.x - h.half - 6 * s)..<(xr + h.dx + 6 * s) {
            let up = col <= xr ? 0 : min(h.dy, (col - xr) * h.dy / h.dx)
            c.rect(col, h.floor - up - s, 1, up + s, C(0xC8BC9C))
            c.rect(col, h.floor, 1, g - h.floor, C(0x9A8E74))
        }
        c.rect(h.x - h.half - 6 * s, h.floor, xr + h.dx - h.x + h.half + 12 * s, s, C(0xB4A88A))
        edorasBuilding(c, x: h.x, half: h.half, floor: h.floor, eave: h.eave, peak: h.peak, dx: h.dx, dy: h.dy, s: s,
                       board: 2 * s, thatch: C(0xE2B23E), course: C(0xBC8C2C), ridge: C(0xFAE08A), wall: C(0x7A5030),
                       side: C(0x5C3A20), gable: C(0x553620), edge: C(0xB07A34))
        // the thatch glints
        for i in 0..<(h.dx / max(1, 3 * s)) {
            let col = h.x + Int(noise(i * 2 + 970) * Double(h.half + h.dx))
            let top = col <= h.x + h.dx ? h.peak - (col - h.x) * h.dy / h.dx : h.peak - h.dy
            c.px(col, top + 2 * s + Int(noise(i * 2 + 971) * Double(rise)), C(0xFFF0A8))
        }
        // the side wall's posts, its frieze under the eaves and its small shuttered windows
        for col in stride(from: xr + 6 * s, to: xr + h.dx - 2 * s, by: 12 * s) {
            let up = (col - xr) * h.dy / h.dx
            c.rect(col, h.eave - up, s, h.floor - h.eave, C(0x40281A))
            c.rect(col + 4 * s, h.eave - up + (h.floor - h.eave) / 3, 3 * s, 4 * s, C(0x2A1A10))
            c.rect(col + 4 * s, h.eave - up + (h.floor - h.eave) / 3, 3 * s, s, gold)
        }
        for col in xr..<(xr + h.dx) {
            let up = (col - xr) * h.dy / h.dx
            c.rect(col, h.eave - up, 1, 2 * s, green); if (col - xr) % (4 * s) == 0 { c.px(col, h.eave - up + s, gold) }
        }
        // the front: planking, a green and gold frieze, the doors between two carved pillars
        for xx in stride(from: h.x - h.half + 2 * s, to: h.x + h.half, by: 4 * s) {
            c.rect(xx, h.eave, s, h.floor - h.eave, C(0x643F24))
        }
        c.rect(h.x - h.half, h.eave, h.half * 2, 2 * s, green)
        for xx in stride(from: h.x - h.half + s, to: h.x + h.half, by: 4 * s) { c.rect(xx, h.eave + s / 2, s, s, gold) }
        let dw = (tall ? 9 : 7) * s, dh = (h.floor - h.eave) * 3 / 4
        c.rect(h.x - dw, h.floor - dh, dw * 2, dh, dark)
        c.rect(h.x - s / 2, h.floor - dh, max(1, s), dh, C(0x24160C))
        for yy in stride(from: h.floor - dh + 2 * s, to: h.floor - s, by: 3 * s) {
            c.rect(h.x - dw + 2 * s, yy, s, s, gold); c.rect(h.x + dw - 3 * s, yy, s, s, gold)
        }
        c.rect(h.x - dw, h.floor - dh, dw * 2, s, gold)
        for px in [h.x - dw - 4 * s, h.x + dw + s] {
            c.rect(px, h.eave + 2 * s, 3 * s, h.floor - h.eave - 2 * s, green)
            c.rect(px, h.eave + 2 * s, s, h.floor - h.eave - 2 * s, C(0x3E7442))
            for yy in stride(from: h.eave + 4 * s, to: h.floor, by: 4 * s) { c.rect(px, yy, 3 * s, s, gold) }
        }
        // the gable: upright boards and a golden sun
        for xx in stride(from: h.x - h.half + 3 * s, to: h.x + h.half, by: 3 * s) {
            let edgeY = h.peak + abs(xx - h.x) * rise / h.half + 2 * s
            if edgeY < h.eave { c.rect(xx, edgeY, s, h.eave - edgeY, C(0x462C18)) }
        }
        let sunY = h.peak + rise * 3 / 5, sunR = max(1, rise / 6)
        c.circle(h.x, sunY, sunR + s, C(0x8A5A24)); c.circle(h.x, sunY, sunR, gold); c.circle(h.x, sunY, max(1, sunR / 2), C(0xF6D870))
        // the crossed horse heads: the bargeboards run on past the peak and cross, and the same at the far gable
        let ext = (tall ? 9 : 7) * s, lift = ext * rise / h.half
        for (bx, by) in [(h.x, h.peak), (h.x + h.dx, h.peak - h.dy)] {
            r4Line(c, bx, by, bx + ext, by - lift, C(0xB07A34), s: 2 * s)
            r4Line(c, bx, by, bx - ext, by - lift, C(0xB07A34), s: 2 * s)
            let pal: [Character: Px] = ["#": C(0xC8903C)]
            r4Stamp(c, bx + ext - s, by - lift - 3 * s, r4HorseHead, pal, s: s)
            r4Stamp(c, bx - ext - 2 * s, by - lift - 3 * s, r4HorseHead, pal, s: s, flip: true)
        }
        // the steps down from the doors to the terrace
        let steps = max(0, (g - h.floor) / max(1, s))
        for i in 0..<steps {
            let y = h.floor + i * s, hw = dw + 4 * s + i * 3 * s
            c.rect(h.x - hw, y, hw * 2, s, C(0xBCB094)); c.rect(h.x - hw, y, hw * 2, max(1, s / 2), C(0xDCD0B2))
        }
    }

    /// A banner of Rohan on its tall pole, streaming out to the right in the wind: green, edged in gold, forked at
    /// its tail, with the white horse on it.
    static func edorasBanner(_ c: PixelCanvas, _ g: Int, x: Int, top: Int, len: Int, seed: Int) {
        let s = unit(g), tall = isTall(c), ht = (tall ? 13 : 11) * s
        c.rect(x, top, s, g - top, C(0x5A3E24)); c.rect(x, top, max(1, s / 2), g - top, C(0x7A5A38))
        c.rect(x - s, top - 2 * s, 3 * s, 2 * s, C(0xE0B040))
        guard len > 0 else { return }
        // the cloth's top row and height at column u along it
        func cloth(_ u: Int) -> (y: Int, h: Int) {
            let k = Double(u) / Double(len)
            let wave = sin(Double(u) / Double(5 * s) + Double(seed) * 1.7) * Double(2 * s) * k
            return (top + s + Int(wave - k * Double(2 * s)), ht - Int(k * Double(ht) * 0.2))
        }
        let fork = 5 * s
        for u in 0..<len {
            let cl = cloth(u), slope = cos(Double(u) / Double(5 * s) + Double(seed) * 1.7)
            let col = slope < -0.3 ? C(0x235028) : C(0x2E6A34)
            let notch = u > len - fork ? (u - (len - fork)) * cl.h / (2 * fork) : 0
            let mid = cl.y + cl.h / 2
            c.rect(x + s + u, cl.y, 1, mid - notch - cl.y, col)
            c.rect(x + s + u, mid + notch, 1, cl.y + cl.h - mid - notch, col)
            c.px(x + s + u, cl.y, C(0xD8B040)); c.px(x + s + u, cl.y + cl.h - 1, C(0xD8B040))
        }
        // the horse, following the cloth's wave
        let u0 = len / 5
        for (r, row) in r4Horse.enumerated() {
            for (k, ch) in row.enumerated() where ch == "#" {
                let u = u0 + k * s
                guard u < len else { continue }
                let cl = cloth(u)
                c.rect(x + s + u, cl.y + (cl.h - 7 * s) / 2 + r * s, s, s, C(0xF4F2EA))
            }
        }
    }
}

// MARK: - Helm Chart's Deep

extension Scenes {
    /// The Hornburg: the middle of its rock, the rock's top row and half-width, and its tower's top row and half-width.
    static func helmsDeepBurg(_ c: PixelCanvas, _ g: Int) -> (x: Int, rockTop: Int, rockHalf: Int, top: Int, half: Int) {
        let s = unit(g)
        if isTall(c) { return (Int(Double(c.w) * 0.76), Int(Double(g) * 0.58), 64 * s, Int(Double(g) * 0.14), 13 * s) }
        return (Int(Double(c.w) * 0.8), g - 24 * s, 40 * s, g - 62 * s, 8 * s)
    }

    /// The Deeping Wall at column `x`: its top row, its face's height and how far along it is (0 at the near end, at
    /// the left edge, to 1 at the foot of the Hornburg's rock). Nil past its far end.
    static func helmsDeepWall(_ c: PixelCanvas, _ g: Int, _ x: Int) -> (top: Int, face: Int, k: Double)? {
        let s = unit(g), tall = isTall(c), b = helmsDeepBurg(c, g), x1 = b.x - b.rockHalf / 2
        guard x >= 0, x < x1 else { return nil }
        let k = Double(x) / Double(max(1, x1)), e = k.squareRoot()
        let far = b.rockTop + (tall ? 26 : 6) * s
        let near = Double((tall ? 60 : 20) * s), farFace = Double((tall ? 16 : 6) * s)
        return (g - Int(Double(g - far) * e), Int(near + (farFace - near) * e), k)
    }

    /// Helm Chart's Deep on the night of the storm: the crew is up on the Deeping Wall's walkway, with the
    /// battlements' tops low along the front. Ahead the wall curves away across the gorge to the Hornburg, its tower
    /// standing on its rock with lit windows, torches burning all along; the cliffs of the Deep close in on either side,
    /// its far end lost in the rain, and the rain slants over everything. On tall screens the whole keep and gorge
    /// rise to a storm sky with lightning forking out of the clouds.
    static func helmsDeep(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x0C0E16), C(0x2A3040), bands: tall ? 10 : 6)
        // the storm clouds
        for i in 0..<(tall ? 12 : 6) {
            let x = Int(noise(i * 7 + 1001) * Double(c.w))
            let y = tall ? Int(noise(i * 7 + 1002) * Double(g) * 0.16) : Int(noise(i * 7 + 1002) * 6.0) * s
            let r = (tall ? 6 + Int(noise(i * 7 + 1003) * 6.0) : 3 + Int(noise(i * 7 + 1003) * 2.0)) * s
            cloud(c, x, y, r, seed: i + 110, top: C(0x2C3242), base: C(0x1C202A))
        }
        helmsDeepLightning(c, g)
        helmsDeepCliffs(c, g)
        helmsDeepBurgDraw(c, g)
        helmsDeepWallDraw(c, g)
        // torches on posts at the back of the walkway, out at the ends
        for x in [Int(Double(c.w) * 0.05), Int(Double(c.w) * 0.95)] {
            c.rect(x - s, g - 12 * s, 3 * s, 12 * s, C(0x2A2420))
            r4Torch(c, x, g - 14 * s, 3, s: s)
        }
        helmsDeepRain(c, g)
        // the wet walkway: torchlight caught in the puddles
        c.ground(g, C(0x2E3034), edge: C(0x5C6068), speck: C(0x3A3C42), seed: 41)
        let fr = c.h - g
        for x in [Int(Double(c.w) * 0.05), Int(Double(c.w) * 0.95)] {
            for y in stride(from: g + 2 * s, to: c.h, by: 2 * s) { c.rect(x - s, y, 3 * s, s, C(0xE8902E, 0.25)) }
        }
        for i in 0..<(c.w / max(1, 60 * s)) where fr > 4 * s {
            let x = Int(noise(i * 3 + 1010) * Double(c.w)), y = g + 2 * s + Int(noise(i * 3 + 1011) * Double(fr / 2))
            c.ellipse(x, y, (6 + Int(noise(i * 3 + 1012) * 8.0)) * s, max(1, s / 2), C(0x46505E, 0.6))
        }
        // the battlements' tops, low along the front
        if fr >= 6 * s {
            let mh = min(fr / 2, (tall ? 12 : 5) * s), band = max(1, mh / 2)
            c.rect(0, c.h - band, c.w, band, C(0x202226)); c.rect(0, c.h - band, c.w, max(1, s / 2), C(0x3A3C44))
            for x in stride(from: -3 * s, to: c.w, by: 16 * s) {
                c.rect(x, c.h - mh, 9 * s, mh - band, C(0x202226))
                c.rect(x, c.h - mh, 9 * s, s, C(0x44464E)); c.rect(x + 8 * s, c.h - mh, s, mh - band, C(0x18191C))
            }
        }
    }

    /// The storm's lightning: a jagged fork from the cloud base down towards the right-hand cliffs, the cloud lit
    /// around where it leaves.
    static func helmsDeepLightning(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        let x0 = Int(Double(c.w) * 0.47), y0 = tall ? Int(Double(g) * 0.08) : 3 * s
        let y1 = tall ? Int(Double(g) * 0.36) : g - 48 * s
        guard y1 > y0 else { return }
        c.ellipse(x0, y0, (tall ? 50 : 24) * s, (tall ? 14 : 5) * s, C(0x8A9AC8, 0.12))
        c.ellipse(x0, y0, (tall ? 24 : 12) * s, (tall ? 6 : 3) * s, C(0xB8C8F0, 0.14))
        func bolt(_ xs: Int, _ ys: Int, _ ye: Int, drift: Double, seed: Int) {
            var x = Double(xs), y = ys, i = 0
            while y < ye {
                let step = (2 + Int(noise(seed + i * 2) * 4.0)) * s
                let nx = x + (noise(seed + i * 2 + 1) - 0.5) * Double(5 * s) + drift * Double(step)
                r4Line(c, Int(x) - s, y, Int(nx) - s, y + step, C(0x9AB0E8, 0.35), s: 3 * s)
                r4Line(c, Int(x), y, Int(nx), y + step, C(0xF0F4FF), s: s)
                x = nx; y += step; i += 1
            }
        }
        bolt(x0, y0, y1, drift: 0.35, seed: 1020)
        bolt(x0 + Int(Double(y1 - y0) * 0.14), y0 + (y1 - y0) * 2 / 5, y0 + (y1 - y0) * 3 / 4, drift: -0.3, seed: 1060)
    }

    /// The gorge: the far end of the Deep hazed in the rain, the cliff on the left, and the one on the right that the
    /// Hornburg backs onto, both ragged, streaked, with ledges.
    static func helmsDeepCliffs(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        // beyond the far end, the three peaks of the Thrihyrne, hazed by the rain
        let farTop = tall ? Int(Double(g) * 0.2) : g - 52 * s
        r4Peaks(c, base: g, height: g - farTop, count: 3, seed: 1100, s: s, lit: C(0x282E3A), shade: C(0x20242E),
                snow: C(0x3C4456), snowShade: C(0x30374A))
        let rock = C(0x1C1E25), streak = C(0x16181E), ledge = C(0x2C303A), rim = C(0x3A404C)
        // one cliff's top row at column x, falling from `edge` at the canvas side to `inner` at its inner edge
        func cliff(_ x0: Int, _ x1: Int, fromLeft: Bool, edge: Double, inner: Double, seed: Int) {
            guard x1 > x0 else { return }
            for x in x0..<x1 {
                let k = Double(fromLeft ? x - x0 : x1 - 1 - x) / Double(x1 - x0)
                let top = Int(edge + (inner - edge) * pow(k, 2.4)) + Int(noise(x / max(1, 2 * s) + seed) * Double(3 * s))
                guard top < g else { continue }
                c.rect(x, max(0, top), 1, g - max(0, top), noise(x / max(1, 2 * s) + seed + 7) > 0.7 ? streak : rock)
                if top >= 0 { c.rect(x, top, 1, s, rim) }
            }
            // ledges
            for i in 0..<((x1 - x0) * g / max(1, 900 * s * s)) {
                let x = x0 + Int(noise(i * 3 + seed + 20) * Double(x1 - x0))
                let k = Double(fromLeft ? x - x0 : x1 - 1 - x) / Double(x1 - x0)
                let top = Int(edge + (inner - edge) * pow(k, 2.4)) + 3 * s
                guard top < g else { continue }
                let y = top + Int(noise(i * 3 + seed + 21) * Double(g - top))
                c.rect(x, y, (3 + Int(noise(i * 3 + seed + 22) * 8.0)) * s, s, ledge)
            }
            // the inner edge, catching a little light
            let ex = fromLeft ? x1 - 1 : x0
            let et = Int(inner) + Int(noise(ex / max(1, 2 * s) + seed) * Double(3 * s))
            if et < g { c.rect(ex, max(0, et), s, g - max(0, et), rim) }
        }
        let lw = Int(Double(c.w) * (tall ? 0.34 : 0.27)), rx = Int(Double(c.w) * (tall ? 0.6 : 0.64))
        cliff(0, lw, fromLeft: true, edge: tall ? Double(g) * 0.04 : -Double(10 * s),
              inner: tall ? Double(g) * 0.56 : Double(g - 24 * s), seed: 1110)
        cliff(rx, c.w, fromLeft: false, edge: tall ? Double(g) * 0.02 : -Double(12 * s),
              inner: tall ? Double(g) * 0.4 : Double(g - 40 * s), seed: 1150)
        // the floor of the Deep, in deep shadow behind the wall
        let floor = tall ? Int(Double(g) * 0.62) : g - 18 * s
        if floor < g { c.gradient(floor, g, C(0x15171C), C(0x101114), bands: 3) }
    }

    /// The Hornburg: its rock, the keep's battlemented wall round the summit, and the tower rising from it with its
    /// lit windows and a torch at its top.
    static func helmsDeepBurgDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), b = helmsDeepBurg(c, g)
        guard b.rockHalf > 0 else { return }
        for x in (b.x - b.rockHalf)..<(b.x + b.rockHalf) {
            let d = Double(abs(x - b.x)) / Double(b.rockHalf)
            let top = b.rockTop + Int(max(0, d - 0.5) * Double(g - b.rockTop) * 1.8)
                + Int(noise(x / max(1, 2 * s) + 1200) * Double(2 * s))
            guard top < g else { continue }
            c.rect(x, top, 1, g - top, x < b.x - b.rockHalf / 4 ? C(0x2A2D35) : C(0x22242B))
            c.rect(x, top, 1, s, C(0x3C414C))
        }
        let warm = C(0xF0B050), stone = C(0x3E4048), lit = C(0x52555E), shade = C(0x2E3036)
        // the keep's wall round the summit
        let kw = b.rockHalf * 3 / 5, kh = (tall ? 18 : 7) * s, ky = b.rockTop - kh
        c.rect(b.x - kw, ky, kw * 2, kh + 2 * s, stone)
        c.rect(b.x - kw, ky, s, kh + 2 * s, lit); c.rect(b.x + kw - 2 * s, ky, 2 * s, kh + 2 * s, shade)
        for x in stride(from: b.x - kw, to: b.x + kw - s, by: 4 * s) { c.rect(x, ky - 2 * s, 2 * s, 2 * s, stone) }
        for x in stride(from: b.x - kw + 5 * s, to: b.x + kw - 4 * s, by: (tall ? 14 : 11) * s) {
            c.rect(x, ky + kh / 3, s, max(s, kh / 4), warm)
        }
        if tall { c.rect(b.x - kw + 12 * s, ky + kh - 10 * s, 8 * s, 10 * s, C(0x16171B)) }
        // the tower, a little wider at its foot
        let tb = ky + s
        for y in b.top..<max(b.top, tb) {
            let hw = b.half + (y - b.top) * 2 * s / max(1, tb - b.top)
            c.rect(b.x - hw, y, hw * 2, 1, stone)
            c.rect(b.x - hw, y, s, 1, lit); c.rect(b.x + hw - hw * 2 / 3, y, hw * 2 / 3, 1, shade)
        }
        c.rect(b.x - b.half - s, b.top - s, (b.half + s) * 2, 2 * s, lit)
        for x in stride(from: b.x - b.half - s, to: b.x + b.half + s, by: 4 * s) {
            c.rect(x, b.top - 3 * s, 2 * s, 2 * s, stone)
        }
        for (i, y) in stride(from: b.top + 5 * s, to: tb - 3 * s, by: (tall ? 16 : 9) * s).enumerated() {
            c.rect(b.x - s + (i % 2 == 0 ? -2 * s : 2 * s), y, s, 2 * s, warm)
        }
        r4Torch(c, b.x - b.half, b.top - 5 * s, tall ? 2 : 1, s: s)
        r4Torch(c, b.x + b.half, b.top - 5 * s, tall ? 2 : 1, s: s)
        r4Torch(c, b.x - kw + 3 * s, ky - 4 * s, 1, s: s)
    }

    /// The Deeping Wall curving away from the walkway to the Hornburg: its face with courses of stone, battlements
    /// along its top, torches along it, and on tall screens the culvert where the stream runs out under it.
    static func helmsDeepWallDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        let face = C(0x3A3C44), course = C(0x30323A), top = C(0x5A5C66)
        for x in 0..<c.w {
            guard let w = helmsDeepWall(c, g, x) else { continue }
            let shade = lerp(face, C(0x2C303A), w.k)
            c.rect(x, w.top, 1, w.face, shade)
            let step = max(2, Int(4.0 - 2.0 * w.k) * s)
            for y in stride(from: w.top + step, to: w.top + w.face, by: step) { c.px(x, y, course) }
            c.rect(x, w.top, 1, max(1, s), top)
        }
        // the battlements, smaller as the wall goes away
        var x = 0
        while let w = helmsDeepWall(c, g, x) {
            let per = max(2, Int((7.0 - 4.5 * w.k.squareRoot()) * Double(s)))
            let mh = max(1, Int((3.0 - 1.8 * w.k) * Double(s)))
            c.rect(x, w.top - mh, max(1, per / 2), mh, face)
            c.rect(x, w.top - mh, max(1, per / 2), max(1, s / 2), top)
            x += per
        }
        // the culvert
        if tall, let w = helmsDeepWall(c, g, Int(Double(c.w) * 0.36)) {
            let cx = Int(Double(c.w) * 0.36), r = max(2, w.face / 4), by = w.top + w.face
            c.ellipse(cx, by, r, r, C(0x0E0F12))
            c.rect(cx - r, by - s, r * 2, s, C(0x5A6A80, 0.5))
        }
        // torches along the top
        var tx = (tall ? 40 : 30) * s, i = 0
        while let w = helmsDeepWall(c, g, tx) {
            let u = w.k < 0.25 ? 3 : w.k < 0.6 ? 2 : 1
            if w.k > 0.08 { r4Torch(c, tx, w.top - (2 + u) * s, u, s: s) }
            tx += Int(Double((tall ? 70 : 46) * s) * (1.1 - w.k * 0.7)) + Int(noise(i + 1250) * Double(8 * s)) + s
            i += 1
        }
    }

    /// Rain slanting down across the whole picture.
    static func helmsDeepRain(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        for i in 0..<(c.w * g / max(1, (tall ? 70 : 50) * s * s)) {
            let x = Int(noise(i * 3 + 1300) * Double(c.w + g / 3)), y = Int(noise(i * 3 + 1301) * Double(g))
            let len = (3 + Int(noise(i * 3 + 1302) * 6.0)) * s
            let col = C(0xA8B8D0, noise(i * 3 + 1302) > 0.7 ? 0.32 : 0.18)
            for k in 0..<len { c.rect(x - k / 3, y + k, s, 1, col) }
        }
    }
}

// MARK: - Fangorn Fork

extension Scenes {
    /// The middle rank of trunks: each one's left edge and width. The one nearest two-thirds across is wide enough
    /// to carry the face.
    static func fangornMids(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int, face: Bool)] {
        let s = unit(g), tall = isTall(c)
        var out: [(x: Int, w: Int, face: Bool)] = []
        var x = (tall ? 30 : 24) * s, i = 0
        while x < c.w {
            let w = Int(Double((12 + Int(noise(i * 5 + 1400) * 9.0)) * s) * (tall ? 1.5 : 1))
            out.append((x, w, false))
            x += w + Int(Double((50 + Int(noise(i * 5 + 1401) * 40.0)) * s) * (tall ? 1.3 : 1))
            i += 1
        }
        let target = Int(Double(c.w) * 0.68)
        if let k = out.indices.min(by: { abs(out[$0].x - target) < abs(out[$1].x - target) }) {
            out[k].w = max(out[k].w, (tall ? 34 : 24) * s); out[k].face = true
        }
        return out
    }

    /// Fangorn Fork: deep in the old forest, where huge trunks rise out of sight. A green-gold haze hangs between them,
    /// shafts of sunlight slant down through gaps in the canopy, and moss climbs every trunk and hangs in beards from
    /// the boughs. The far trees are faint in the haze; the middle rank is mossy and close, and one of them, if you
    /// look, has a face: a brow, two deep eyes, a long nose and a mossy beard. Two great trunks stand at the edges,
    /// their roots spreading over the mossy floor where the crew stands among ferns. On tall screens the trunks climb
    /// far up into the dark of the canopy, the shafts of light fall the whole way down, and the boughs hang with more
    /// moss.
    static func fangorn(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x18220F), C(0x627040), bands: tall ? 12 : 7)
        // the far trees, faint in the haze, standing on the far floor
        let farBase = g - (tall ? 44 : 12) * s
        for i in 0..<max(0, c.w / ((tall ? 24 : 18) * s)) {
            let x = Int(noise(i * 5 + 1500) * Double(c.w)), w = (3 + Int(noise(i * 5 + 1501) * 5.0)) * s * (tall ? 2 : 1)
            let near = noise(i * 5 + 1502) > 0.5
            fangornTrunk(c, g, x: x, w: w, base: farBase + (near ? 3 : 0) * s, flare: w,
                         bark: near ? C(0x3E4A28) : C(0x4A5830), dark: near ? C(0x36422A) : C(0x42502C),
                         light: C(0x58683A), moss: nil, seed: i)
        }
        c.dunes(base: farBase + 2 * s, amp: Double(2 * s), freq: 0.03 / Double(s), phase: 0.7, bottom: g, C(0x4A5A2E),
                shade: C(0x5E7038))
        fangornShafts(c, g, alpha: 0.09)
        // the middle rank
        let midBase = g - (tall ? 14 : 4) * s
        c.dunes(base: midBase, amp: Double(s), freq: 0.02 / Double(s), phase: 2.1, bottom: g, C(0x3C4C22),
                shade: C(0x5A722E))
        let mids = fangornMids(c, g)
        for (i, m) in mids.enumerated() {
            fangornTrunk(c, g, x: m.x, w: m.w, base: midBase + 2 * s, flare: m.w + (tall ? 12 : 4) * s,
                         bark: C(0x4A3E2C), dark: C(0x382E20), light: C(0x66583E), moss: C(0x5E7A2C), seed: i + 20)
            if tall {
                let y = Int(Double(g) * (0.2 + noise(i + 1510) * 0.3)), right = noise(i + 1511) > 0.5
                let x0 = right ? m.x + m.w : m.x, x1 = x0 + (right ? 1 : -1) * (30 + Int(noise(i + 1512) * 30.0)) * s
                fangornBough(c, g, x0, y, x1, y - 8 * s, seed: i + 30, bark: C(0x3E3424), maxLen: 26 * s)
            }
            if m.face { fangornFace(c, g, m.x, m.w) }
        }
        // the canopy, dark overhead
        let roof = (tall ? Int(Double(g) * 0.06) : 3 * s)
        for x in 0..<c.w {
            let b = roof + Int((sin(Double(x) * 0.04 / Double(s)) * 0.5 + noise(x / max(1, 4 * s) + 1520) * 0.5)
                               * Double((tall ? 18 : 5) * s))
            c.rect(x, 0, 1, b, C(0x121A0C))
            c.px(x, b, C(0x2A3A18))
        }
        fangornShafts(c, g, alpha: 0.06)
        // the floor, and pools of light where the shafts reach it
        c.ground(g, C(0x34461C), edge: C(0x5E7A30), speck: C(0x46602A), seed: 51)
        for i in 0..<(c.w * max(0, c.h - g) / max(1, 40 * s)) {
            c.px(Int(noise(i * 2 + 1530) * Double(c.w)), g + s + Int(noise(i * 2 + 1531) * Double(max(1, c.h - g - s))),
                 C(0x8A7A3A, 0.6))
        }
        for e in fangornShaftEnds(c, g) {
            c.ellipse(e.x, g + s, e.w, max(1, s), C(0xE8D890, 0.22))
        }
        // ferns along the back of the floor
        for i in 0..<(c.w / max(1, 26 * s)) {
            let x = Int(noise(i * 3 + 1540) * Double(c.w)), hgt = (3 + Int(noise(i * 3 + 1541) * 3.0)) * s
            let col = noise(i * 3 + 1542) > 0.5 ? C(0x5E8A34) : C(0x4A7228)
            for leaf in -2...2 {
                r4Line(c, x, g, x + leaf * 2 * s, g - hgt + abs(leaf) * s, col, s: s)
            }
            c.px(x, g - hgt, C(0x8AB050))
        }
        // the two great trunks at the edges, their roots spreading over the floor
        let gw = (tall ? 70 : 34) * s, foot = g + min(max(0, c.h - g), 4 * s)
        for (i, x) in [-(tall ? 34 : 16) * s, c.w - gw + (tall ? 34 : 16) * s].enumerated() {
            fangornTrunk(c, g, x: x, w: gw, base: foot, flare: (tall ? 64 : 22) * s, bark: C(0x2E2618),
                         dark: C(0x211B11), light: C(0x4A3E28), moss: C(0x4E6A26), seed: i + 60)
            let y = tall ? Int(Double(g) * 0.16) : 8 * s
            let x0 = i == 0 ? x + gw : x, x1 = x0 + (i == 0 ? 1 : -1) * (tall ? 140 : 72) * s
            fangornBough(c, g, x0, y, x1, y + (tall ? 12 : 4) * s, seed: i + 70, bark: C(0x2E2618),
                         maxLen: (tall ? 40 : 12) * s)
        }
    }

    /// The shafts of light: where each one starts along the top, and its width. They all slant the same way.
    static func fangornShaftEnds(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int)] {
        let s = unit(g), tall = isTall(c), slope = 0.45
        var out: [(x: Int, w: Int)] = []
        for i in 0..<max(1, c.w / ((tall ? 110 : 120) * s)) {
            let x0 = Int(noise(i * 3 + 1600) * Double(c.w)) - Int(Double(g) * slope * 0.6)
            let w = (4 + Int(noise(i * 3 + 1601) * 9.0)) * s * (tall ? 2 : 1)
            out.append((x0 + Int(Double(g) * slope) + w / 2, w))
        }
        return out
    }

    /// Shafts of sunlight slanting down through gaps in the canopy, soft at their edges, with a few motes in them.
    static func fangornShafts(_ c: PixelCanvas, _ g: Int, alpha: Double) {
        let s = unit(g), slope = 0.45, light = C(0xF4E4A0)
        for (i, e) in fangornShaftEnds(c, g).enumerated() {
            let x0 = e.x - e.w / 2 - Int(Double(g) * slope)
            for y in 0..<g {
                let x = x0 + Int(Double(y) * slope)
                c.rect(x - 2 * s, y, 2 * s, 1, light.alpha(alpha * 0.5)); c.rect(x + e.w, y, 2 * s, 1, light.alpha(alpha * 0.5))
                c.rect(x, y, e.w, 1, light.alpha(alpha))
            }
            for k in 0..<(g / max(1, 12 * s)) {
                let y = Int(noise(i * 50 + k * 2 + 1610) * Double(g))
                c.rect(x0 + Int(Double(y) * slope) + Int(noise(i * 50 + k * 2 + 1611) * Double(e.w)), y, s, s,
                       C(0xFFF4C0, alpha * 5))
            }
        }
    }

    /// One trunk rising out of sight from its foot on row `base`, `w` wide: bark with wandering grooves, lit on its
    /// left and shaded on its right, flaring into buttress roots over its last `flare` rows, with moss climbing it.
    static func fangornTrunk(_ c: PixelCanvas, _ g: Int, x: Int, w: Int, base: Int, flare: Int, bark: Px, dark: Px,
                             light: Px, moss: Px?, seed: Int) {
        let s = unit(g), fl = max(1, flare)
        guard w > 0 else { return }
        for y in 0..<max(0, base) {
            let f = Double(max(0, y - (base - fl))) / Double(fl), spread = Int(f * f * Double(w) * 0.9)
            let x0 = x - spread, x1 = x + w + spread
            c.rect(x0, y, x1 - x0, 1, bark)
            c.rect(x1 - (w / 3 + spread / 2), y, w / 3 + spread / 2, 1, dark)
            c.rect(x0, y, max(1, w / 7), 1, light)
            for (j, gx) in stride(from: x + 2 * s, to: x + w - 2 * s, by: max(2, 4 * s)).enumerated() {
                let wob = Int(sin(Double(y) / Double(6 * s) + Double(j * 3 + seed)) * Double(s))
                let fx = gx + wob + Int(Double(gx - x - w / 2) * f * 1.6)
                if fx > x0, fx < x1 - s { c.rect(fx, y, max(1, s / 2 + s % 2), 1, dark) }
            }
        }
        guard let moss else { return }
        // moss over the roots, and patches climbing the lit side
        for y in max(0, base - fl)..<max(0, base) {
            let f = Double(y - (base - fl)) / Double(fl), spread = Int(f * f * Double(w) * 0.9)
            let mw = Int(Double(w + spread / 2) * (0.35 + 0.1 * sin(Double(y) / Double(5 * s) + Double(seed))))
            c.rect(x - spread, y, mw, 1, moss.alpha(0.6))
        }
        let pale = lerp(moss, C(0xB8C070), 0.4)
        for i in 0..<max(1, base / max(1, 9 * s)) {
            let up = pow(noise(i * 3 + seed * 97 + 1700), 2.2)
            let y = base - Int(up * Double(max(1, base)))
            let px = x + Int(noise(i * 3 + seed * 97 + 1701) * Double(w) * 0.4)
            let rx = max(1, Int(Double((1 + Int(noise(i * 3 + seed * 97 + 1702) * 3.0)) * s) * (1 - up * 0.6)))
            let ry = rx * 3
            c.ellipse(px, y, rx, ry, moss.alpha(0.75))
            c.rect(px - rx / 2, y - ry + s, s, s, pale)
        }
    }

    /// A bough reaching out from a trunk, with old-man's-beard moss hanging from it in strands.
    static func fangornBough(_ c: PixelCanvas, _ g: Int, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, seed: Int,
                             bark: Px, maxLen: Int) {
        let s = unit(g)
        r4Line(c, x0, y0, x1, y1, bark, s: 3 * s)
        r4Line(c, x0, y0, x1, y1, lerp(bark, C(0x6A5A3E), 0.5), s: s)
        let n = max(1, abs(x1 - x0) / (2 * s))
        for i in 0..<n {
            let k = Double(i) / Double(n)
            let x = x0 + Int(Double(x1 - x0) * k), y = y0 + Int(Double(y1 - y0) * k) + 2 * s
            let len = Int(noise(seed * 31 + i + 1800) * Double(maxLen) * (0.4 + 0.6 * k))
            let col = i % 3 == 0 ? C(0xA8B470) : C(0x7A9040)
            for yy in 0..<len {
                let sway = Int(sin(Double(yy) / Double(3 * s) + Double(i)) * Double(s) * 0.8)
                c.rect(x + sway, y + yy, s, 1, col.alpha(0.9 - 0.5 * Double(yy) / Double(max(1, len))))
            }
        }
    }

    /// The face in the old tree, kept quiet in the bark's own colours: a heavy brow, two deep eyes with a faint gleam,
    /// a long nose ending in a knot, a crack of a mouth and a beard of moss.
    static func fangornFace(_ c: PixelCanvas, _ g: Int, _ x: Int, _ w: Int) {
        let s = unit(g), tall = isTall(c)
        let cx = x + w * 2 / 5, cy = g - (tall ? 72 : 40) * s
        let hollow = C(0x1E180E), ridge = C(0x6E5E42), shade = C(0x2E261A)
        r4Line(c, cx - 7 * s, cy - 2 * s, cx - 2 * s, cy - 3 * s, ridge, s: s)
        r4Line(c, cx + 2 * s, cy - 3 * s, cx + 7 * s, cy - 2 * s, ridge, s: s)
        for ex in [cx - 4 * s, cx + 4 * s] {
            c.ellipse(ex, cy, 2 * s, max(1, s), hollow)
            c.rect(ex - s, cy, s, s, C(0xC8B060, 0.55))
        }
        c.rect(cx, cy - s, s, 7 * s, ridge); c.rect(cx + s, cy, s, 6 * s, shade)
        c.ellipse(cx, cy + 6 * s, max(1, s), max(1, s), ridge)
        c.rect(cx - 3 * s, cy + 9 * s, 7 * s, s, hollow); c.rect(cx - 2 * s, cy + 10 * s, 5 * s, max(1, s / 2), shade)
        for i in 0..<7 {
            let bx = cx - 3 * s + i * s, len = (tall ? 14 : 8) * s + Int(noise(i + 1900) * Double(6 * s))
            for yy in 0..<len {
                let sway = Int(sin(Double(yy) / Double(3 * s) + Double(i)) * Double(s) * 0.6)
                c.rect(bx + sway, cy + 11 * s + yy, s, 1, (i % 2 == 0 ? C(0x7A9040) : C(0x5E7A2C)).alpha(0.9 - 0.4 * Double(yy) / Double(len)))
            }
        }
    }
}
