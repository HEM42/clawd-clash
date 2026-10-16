import Foundation

let ringsScenes1: [Location: Place] = [
    .bagEnd: Place(name: "Bag Endpoint", panel: 0x1C2A16, still: Scenes.bagEnd, moving: Scenes.bagEndLife),
    .prancingPony: Place(name: "The Prancing Ponytail", panel: 0x221810, still: Scenes.prancingPony,
                         moving: Scenes.prancingPonyLife),
]

// MARK: - Shared bits for these scenes

/// String art drawn with every character `s` pixels square.
private func r1Stamp(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], _ pal: [Character: Px], s: Int) {
    for (r, row) in rows.enumerated() {
        for (k, ch) in row.enumerated() { if let col = pal[ch] { c.rect(x + k * s, y + r * s, s, s, col) } }
    }
}

/// Where a repeating motion of `period` seconds is, from 0 up to 1.
private func r1Phase(_ t: Double, _ period: Double, offset: Double = 0) -> Double {
    let v = (t + offset).truncatingRemainder(dividingBy: period) / period
    return v < 0 ? v + 1 : v
}

/// A straight line of `s`-pixel dots.
private func r1Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// The inn sign's pony, rearing, its tail tied up in a ponytail with a red ribbon (18 rows by 26).
private let ringsPony: [String] = [
    "..................#.#.....",
    "..................###.....",
    ".................#####....",
    "................###.####..",
    "...ttt.........#########..",
    ".tttttt........######.###.",
    "tttttttt......#####....##.",
    "ttttt.ttt....#####........",
    "tttt...tt....####..##.....",
    "ttt.....t...######.###....",
    "ttt....r.r.#######..##....",
    "tt......r##########..#....",
    "tt.....r.r########........",
    "t........#########........",
    "t......#########..........",
    "......###....###..........",
    "......##......##..........",
    ".....###.....###..........",
]

// MARK: - Bag End

extension Scenes {
    /// The hobbit hole's hill: its middle, half-width and height above the ground row.
    static func bagEndHill(_ c: PixelCanvas, _ g: Int) -> (x: Int, rx: Int, h: Int) {
        let s = unit(g)
        return (c.w / 2, 92 * s, 44 * s)
    }

    /// The top of the hobbit hole's hill at column `x` (`g` off the hill).
    static func bagEndHillTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let hill = bagEndHill(c, g), k = Double(x - hill.x) / Double(hill.rx)
        guard abs(k) < 1 else { return g }
        let a: Double = k * Double.pi
        return g - Int(Double(hill.h) * pow(0.5 + 0.5 * cos(a), 0.7))
    }

    /// The chimney pot on the hill, right of the door: its middle and top row.
    static func bagEndChimney(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int) {
        let s = unit(g), x = bagEndHill(c, g).x + 30 * s
        return (x, bagEndHillTop(c, g, x) - 8 * s)
    }

    /// Bag End on a summer afternoon: a soft blue sky fading to cream, two bands of rolling green hills, and in the
    /// middle hill the hobbit hole: a round green door with its brass knob, a round window either side, a chimney on
    /// the turf. A low picket fence runs along the garden, the path comes down from the door, and the party tree
    /// stands at the right. Up high on tall screens, more hills and the Party Field with its pavilion and bunting.
    static func bagEnd(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x8FC3EA), C(0xF6EDD2), bands: 8)
        for i in 0..<(tall ? 9 : 4) {
            let x = Int(noise(i * 7 + 501) * Double(c.w))
            let y = tall ? g / 16 + Int(noise(i * 7 + 502) * Double(g / 4)) : (4 + Int(noise(i * 7 + 502) * 10.0)) * s
            let r = (tall ? 4 + Int(noise(i * 7 + 503) * 4.0) : 2 + Int(noise(i * 7 + 503) * 2.0)) * s
            cloud(c, x, y, r, seed: i + 70, top: C(0xFFFDF4), base: C(0xE6E2D2))
        }
        if tall { bagEndFar(c, g) }
        // the two bands of rolling hills
        c.dunes(base: g - 30 * s, amp: Double(6 * s), freq: 0.016 / Double(s), phase: 1.3, bottom: g, C(0x4E8A34),
                shade: C(0x64A044))
        c.dunes(base: g - 12 * s, amp: Double(3 * s), freq: 0.022 / Double(s), phase: 4.1, bottom: g, C(0x6FA84A),
                shade: C(0x8CC064))
        bagEndTree(c, g)
        bagEndHole(c, g)
        bagEndFence(c, g)
        c.ground(g, C(0x5A9A3C), edge: C(0x86BE5A), speck: C(0x4A8432), seed: 21)
        bagEndPath(c, g)
    }

    /// Tall screens: blue hills on the horizon, patchwork hills nearer, and the Party Field.
    static func bagEndFar(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g)
        c.dunes(base: Int(Double(g) * 0.44), amp: Double(10 * s), freq: 0.011 / Double(s), phase: 0.4, bottom: g,
                C(0xA9C6C4), shade: C(0xC4DAD2))
        c.dunes(base: Int(Double(g) * 0.54), amp: Double(9 * s), freq: 0.014 / Double(s), phase: 2.2, bottom: g,
                C(0x9CC47A), shade: C(0xB4D490))
        bagEndHedges(c, g, top: Int(Double(g) * 0.54), seed: 1)
        c.dunes(base: Int(Double(g) * 0.66), amp: Double(8 * s), freq: 0.012 / Double(s), phase: 5.0, bottom: g,
                C(0x86B860), shade: C(0xA0CC78))
        bagEndHedges(c, g, top: Int(Double(g) * 0.66), seed: 3, skip: (Int(Double(c.w) * 0.24) - 80 * s, Int(Double(c.w) * 0.24) + 80 * s))
        bagEndPartyField(c, g)
        c.dunes(base: Int(Double(g) * 0.78), amp: Double(7 * s), freq: 0.015 / Double(s), phase: 3.3, bottom: g,
                C(0x78B054), shade: C(0x92C46A))
        bagEndHedges(c, g, top: Int(Double(g) * 0.78), seed: 2)
        // the neighbours' holes, each in its own little mound
        let doors: [UInt32] = [0x3A5A9A, 0xB8402E, 0xE8B33A, 0x2E6A2E]
        for i in 0..<4 {
            let x = Int(Double(c.w) * (0.08 + Double(i) * 0.25 + noise(i + 640) * 0.06))
            let y = Int(Double(g) * 0.78) + (12 + Int(noise(i + 650) * 5.0)) * s
            c.ellipse(x, y + 2 * s, 14 * s, 8 * s, C(0x86BE5C)); c.ellipse(x, y + 3 * s, 14 * s, 7 * s, C(0x78B054))
            c.circle(x, y + s, 4 * s, C(0xB8AE98))
            c.circle(x, y + s, 3 * s, C(doors[i]))
            c.rect(x, y + s, s, s, C(0x1A1A14))
            c.circle(x + 8 * s, y, 2 * s, C(0xC8963E)); c.circle(x + 8 * s, y, s, C(0x2C3E48))
            c.rect(x - 9 * s, y - 6 * s, 2 * s, 3 * s, C(0x9A7A62))
            c.rect(x - 4 * s, y + 5 * s, 8 * s, 2 * s, C(0xD8BE88))
        }
    }

    /// Hedgerows and round trees along a band of far hills.
    static func bagEndHedges(_ c: PixelCanvas, _ g: Int, top: Int, seed: Int, skip: (Int, Int)? = nil) {
        let s = unit(g)
        for i in 0..<(c.w / (20 * s)) {
            let x = Int(noise(i * 5 + seed * 300 + 660) * Double(c.w))
            if let skip, x > skip.0, x < skip.1 { continue }
            let y = top + (6 + Int(noise(i * 5 + seed * 300 + 661) * 14.0)) * s
            if noise(i * 5 + seed * 300 + 662) > 0.45 {
                c.rect(x, y, (14 + Int(noise(i * 5 + seed * 300 + 663) * 20.0)) * s, s, C(0x4E8A34, 0.8))
            } else {
                c.rect(x, y, s, 2 * s, C(0x6A4A2C))
                c.circle(x, y - 2 * s, 3 * s, C(0x4E8A34)); c.circle(x - s, y - 3 * s, 2 * s, C(0x64A044))
            }
        }
    }

    /// The Party Field: a pavilion striped red and white, two small tents, and bunting strung between poles.
    static func bagEndPartyField(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), x = Int(Double(c.w) * 0.24), b = Int(Double(g) * 0.66) + 12 * s
        c.ellipse(x, b, 70 * s, 6 * s, C(0x9ED070))
        // small tents either side
        for (k, dx) in [-40, 38].enumerated() {
            let tx = x + dx * s, cloth = k == 0 ? C(0xF2D24A) : C(0xF4EEE0), shade = k == 0 ? C(0xC8A42E) : C(0xC8C0AE)
            for y in 0..<(9 * s) {
                let half = y * 7 / 9
                c.rect(tx - half, b - 9 * s + y, half * 2 + 1, 1, cloth)
                c.rect(tx, b - 9 * s + y, half + 1, 1, shade)
            }
            c.rect(tx - s, b - 4 * s, 2 * s, 4 * s, C(0x5A4A3A))
        }
        // the pavilion
        let wall = 9 * s, roof = 10 * s, half = 20 * s
        for xx in stride(from: x - half, to: x + half, by: 3 * s) {
            c.rect(xx, b - wall, 3 * s, wall, ((xx - x + half) / (3 * s)) % 2 == 0 ? C(0xF6F0E2) : C(0xD0443A))
        }
        c.rect(x - half, b - wall, s, wall, C(0xB8B0A0)); c.rect(x + half - s, b - wall, s, wall, C(0xB8B0A0))
        c.rect(x - 3 * s, b - 6 * s, 6 * s, 6 * s, C(0x6A5446))
        for y in 0..<roof {
            let hw = (half + 2 * s) * (y + 1) / roof
            for xx in (x - hw)..<(x + hw) {
                let stripe = ((xx - x + 40 * s) * roof / max(1, y + 1) / (5 * s)) % 2 == 0
                c.px(xx, b - wall - roof + y, stripe ? C(0xF6F0E2) : C(0xD0443A))
            }
        }
        for xx in stride(from: x - half - 2 * s, to: x + half + 2 * s, by: 3 * s) { c.rect(xx, b - wall, 2 * s, s, C(0xD0443A)) }
        let peak = b - wall - roof
        c.rect(x, peak - 6 * s, s, 6 * s, C(0x5A4A3A)); c.rect(x + s, peak - 6 * s, 4 * s, 2 * s, C(0xF2D24A))
        // bunting from the peak to a pole each side
        for dx in [-62, 62] {
            let px = x + dx * s, top = b - 16 * s
            c.rect(px, top, s, 16 * s, C(0x6A4A2C))
            bagEndBunting(c, x, peak, px, top, sag: 4 * s, s: s)
        }
    }

    /// A sagging string of little triangular flags.
    static func bagEndBunting(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, sag: Int, s: Int) {
        let flags: [UInt32] = [0xD0443A, 0xF2D24A, 0x3A6AC8, 0x4E9A3A, 0xF6F0E2]
        let n = abs(x1 - x0)
        guard n > 0 else { return }
        for i in 0...n {
            let k = Double(i) / Double(n)
            let a: Double = k * Double.pi
            let x = x0 + (x1 - x0) * i / n, y = y0 + Int(Double(y1 - y0) * k + Double(sag) * sin(a))
            c.px(x, y, C(0x6A5A4A))
            if i % (5 * s) == 2 * s, i > 2 * s, i < n - 2 * s {
                let col = C(flags[(i / (5 * s)) % flags.count])
                c.rect(x - s, y + 1, 3 * s, s, col); c.rect(x, y + 1 + s, s, s, col)
            }
        }
    }

    /// The party tree: a broad old tree with a spreading crown.
    static func bagEndTree(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), x = Int(Double(c.w) * 0.86), cy = g - 38 * s
        let bark = C(0x6A4A2C)
        for y in cy..<g {
            let k = Double(y - cy) / Double(g - cy)
            let half = Int(Double(3 * s) + k * k * Double(5 * s))
            c.rect(x - half, y, half * 2, 1, bark)
            c.rect(x - half, y, s, 1, C(0x8A6A44)); c.rect(x + half - s, y, s, 1, C(0x4A3220))
        }
        r1Line(c, x, cy + 10 * s, x - 18 * s, cy - 2 * s, bark, s: 2 * s)
        r1Line(c, x, cy + 8 * s, x + 17 * s, cy - 3 * s, bark, s: 2 * s)
        let blobs: [(Int, Int, Int, Int)] = [(-20, 2, 12, 9), (18, 3, 13, 9), (0, -9, 18, 11), (-9, 5, 13, 8),
                                             (10, -3, 13, 9), (0, 7, 15, 6)]
        for b in blobs { c.ellipse(x + b.0 * s, cy + b.1 * s + 2 * s, b.2 * s, b.3 * s, C(0x2F6422)) }
        for b in blobs { c.ellipse(x + b.0 * s, cy + b.1 * s, b.2 * s, b.3 * s, C(0x3E7A2C)) }
        for b in blobs {
            c.ellipse(x + b.0 * s - 2 * s, cy + b.1 * s - 2 * s, b.2 * s * 2 / 3, b.3 * s * 2 / 3, C(0x52943A))
        }
        for i in 0..<60 {
            let b = blobs[i % blobs.count]
            let a: Double = noise(i * 3 + 680) * 2 * Double.pi, rr = noise(i * 3 + 681) * 0.8
            let lx = x + b.0 * s + Int(cos(a) * rr * Double(b.2 * s)), ly = cy + b.1 * s + Int(sin(a) * rr * Double(b.3 * s))
            c.rect(lx, ly, s, s, sin(a) < 0.2 ? C(0x7AB850) : C(0x2F6422))
        }
    }

    /// The hill, its door, windows and chimney.
    static func bagEndHole(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), hill = bagEndHill(c, g)
        for x in (hill.x - hill.rx)...(hill.x + hill.rx) {
            let top = bagEndHillTop(c, g, x)
            guard top < g else { continue }
            c.rect(x, top, 1, g - top, C(0x6FA84A))
            c.rect(x, top, 1, s, C(0x8CC466))
        }
        for i in 0..<(hill.rx * hill.h / (10 * s * s)) {
            let x = hill.x - hill.rx + Int(noise(i * 3 + 610) * Double(hill.rx * 2))
            let top = bagEndHillTop(c, g, x)
            guard top < g - s else { continue }
            let y = top + s + Int(noise(i * 3 + 611) * Double(g - top - s))
            c.rect(x, y, s, s, noise(i * 3 + 612) > 0.5 ? C(0x5E9A3E) : C(0x86BE5C))
        }
        // the chimney
        let ch = bagEndChimney(c, g)
        c.rect(ch.x - 2 * s, ch.y, 4 * s, bagEndHillTop(c, g, ch.x) - ch.y + 2 * s, C(0x9A7A62))
        c.rect(ch.x + s, ch.y, s, bagEndHillTop(c, g, ch.x) - ch.y + 2 * s, C(0x7A5E4A))
        c.rect(ch.x - 3 * s, ch.y, 6 * s, 2 * s, C(0x7A5E4A)); c.rect(ch.x - 3 * s, ch.y, 6 * s, s, C(0xB89A80))
        // the door in its stone surround
        let dx = hill.x, dy = g - 10 * s, r = 10 * s
        c.circle(dx, dy, r + 3 * s, C(0x8A8070))
        c.circle(dx, dy, r + 2 * s, C(0xB8AE98))
        c.circle(dx, dy, r, C(0x2E6A2E))
        for x in stride(from: dx - r + 3 * s, to: dx + r - s, by: 4 * s) {
            let dd = Double(x - dx), hh = Int((Double(r * r) - dd * dd).squareRoot())
            c.rect(x, dy - hh + s, s, hh * 2 - s, C(0x245624))
        }
        for i in 0..<24 {
            let a: Double = Double.pi + Double(i) / 24 * Double.pi / 2
            c.px(dx + Int(cos(a) * Double(r - s)), dy + Int(sin(a) * Double(r - s)), C(0x4A8A44))
        }
        c.circle(dx, dy, s, C(0xE8B33A)); c.px(dx - s / 2, dy - s / 2 - (s == 1 ? 1 : 0), C(0xFFE49A))
        c.rect(dx - 9 * s, g - s, 18 * s, s, C(0xA89E88))
        // a round window either side, with a box of flowers
        let flowers: [UInt32] = [0xE85A7A, 0xF2D04A, 0xF4F0F0, 0xB06AD8]
        for side in [-1, 1] {
            let wx = dx + side * 26 * s, wy = g - 17 * s, wr = 5 * s
            c.circle(wx, wy, wr + 2 * s, C(0xB8AE98))
            c.circle(wx, wy, wr + s, C(0xC8963E))
            c.circle(wx, wy, wr, C(0x2C3E48))
            c.rect(wx - wr, wy, wr * 2 + 1, s, C(0xC8963E)); c.rect(wx, wy - wr, s, wr * 2 + 1, C(0xC8963E))
            c.rect(wx - 3 * s, wy - 3 * s, s, s, C(0x9AC0D0)); c.rect(wx - 2 * s, wy - 4 * s, s, s, C(0x9AC0D0, 0.6))
            c.rect(wx - 6 * s, wy + wr + 2 * s, 13 * s, 3 * s, C(0x7A5030)); c.rect(wx - 6 * s, wy + wr + 2 * s, 13 * s, s, C(0x9A6A40))
            for k in 0..<5 {
                let fx = wx - 5 * s + k * 3 * s
                c.rect(fx, wy + wr + s, s, s, C(flowers[(k + side + 2) % flowers.count]))
                c.px(fx + s, wy + wr + 2 * s - 1, C(0x3E7A2C))
            }
        }
    }

    /// The low picket fence along the garden, with a gap for the path, and flowers in the bed behind it.
    static func bagEndFence(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), mid = bagEndHill(c, g).x, x0 = mid - 84 * s, x1 = mid + 84 * s, top = g - 6 * s
        let wood = C(0xEDE2C4), shade = C(0xB9A886), gap = 10 * s
        let flowers: [UInt32] = [0xE85A7A, 0xF2D04A, 0xF4F0F0, 0xB06AD8, 0xF08A3A]
        for i in 0..<((x1 - x0) / (2 * s)) {
            let x = x0 + i * 2 * s
            guard abs(x - mid) > gap + s else { continue }
            let y = top - s - Int(noise(i + 700) * 3.0) * s
            c.rect(x, y + s, s, g - y - s, C(0x3E7A2C))
            if noise(i + 710) > 0.35 { c.rect(x, y, s, s, C(flowers[Int(noise(i + 720) * 5.0) % flowers.count])) }
        }
        for y in [top + 2 * s, g - 2 * s] {
            c.rect(x0, y, mid - gap - x0, s, shade); c.rect(mid + gap, y, x1 - mid - gap, s, shade)
        }
        for x in stride(from: x0, to: x1, by: 4 * s) where abs(x - mid) > gap || abs(x + 2 * s - mid) > gap {
            guard x + 2 * s <= mid - gap || x >= mid + gap else { continue }
            c.rect(x, top + s, 2 * s, 6 * s - s, wood)
            c.rect(x + s, top + s, s, 6 * s - s, shade)
            c.rect(x, top, s, s, wood)
        }
        for x in [mid - gap - 2 * s, mid + gap] {
            c.rect(x, top - 2 * s, 2 * s, 8 * s, C(0xD8CCAE)); c.rect(x, top - 2 * s, 2 * s, s, wood)
        }
    }

    /// The garden path, down from the door across the lawn the crew stands on.
    static func bagEndPath(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), x = bagEndHill(c, g).x, rows = c.h - g
        for y in g..<c.h {
            let k = Double(y - g) / Double(max(1, rows - 1))
            let half = Int(Double(8 * s) + k * Double(16 * s))
            c.rect(x - half, y, half * 2, 1, C(0xD8BE88))
            c.rect(x - half, y, s, 1, C(0xB89E6A)); c.rect(x + half - s, y, s, 1, C(0xB89E6A))
        }
        for i in 0..<(rows * 2) {
            let y = g + Int(noise(i * 2 + 730) * Double(rows))
            let k = Double(y - g) / Double(max(1, rows - 1)), half = Int(Double(7 * s) + k * Double(15 * s))
            c.rect(x - half + Int(noise(i * 2 + 731) * Double(half * 2)), y, s, s, C(0xB8A070))
        }
    }

    /// Smoke puffing from the chimney, and a butterfly over the garden.
    static func bagEndLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), ch = bagEndChimney(c, g), rise = (isTall(c) ? 40 : 26) * s
        for i in 0..<5 {
            let p = r1Phase(t, 4, offset: Double(i) * 0.8)
            let x = ch.x + Int(sin(p * 3 + Double(i)) * Double(2 * s) + p * Double(12 * s))
            let y = ch.y - s - Int(p * Double(rise))
            let r = s + Int(p * Double(4 * s))
            c.circle(x + s, y + s, r, C(0xC8C4BC, 0.45 * (1 - p)))
            c.circle(x, y, r, C(0xF4F2EC, 0.6 * (1 - p)))
        }
        // the butterfly, wandering over the flower beds
        let hill = bagEndHill(c, g)
        let bx = hill.x - 48 * s + Int(sin(t * 0.37) * Double(40 * s) + sin(t * 1.1) * Double(8 * s))
        let by = g - 20 * s + Int(sin(t * 0.9) * Double(6 * s) + cos(t * 2.3) * Double(2 * s))
        let open = Int(t * 9) % 2 == 0
        let wing = C(0xF0A030), tip = C(0x4A2A14)
        if open {
            c.rect(bx - 3 * s, by - s, 3 * s, 2 * s, wing); c.rect(bx + s, by - s, 3 * s, 2 * s, wing)
            c.rect(bx - 2 * s, by + s, 2 * s, s, wing); c.rect(bx + s, by + s, 2 * s, s, wing)
            c.rect(bx - 3 * s, by - s, s, s, tip); c.rect(bx + 3 * s, by - s, s, s, tip)
        } else {
            c.rect(bx - s, by - 3 * s, s, 3 * s, wing); c.rect(bx + s, by - 3 * s, s, 3 * s, wing)
        }
        c.rect(bx, by - s, s, 3 * s, tip)
    }
}

// MARK: - The Prancing Pony

extension Scenes {
    /// The top of the ground floor's ceiling beam: the top of the strip, or the gallery's floor on tall screens.
    static func prancingPonyCeiling(_ c: PixelCanvas, _ g: Int) -> Int { isTall(c) ? g - 80 * unit(g) : 0 }

    /// The hearth's opening: left edge, width and top row.
    static func prancingPonyHearth(_ c: PixelCanvas, _ g: Int) -> (x: Int, w: Int, top: Int) {
        let s = unit(g)
        return (22 * s, 36 * s, g - 22 * s)
    }

    /// The timber posts' middles, evenly spaced between the hearth and the bar.
    static func prancingPonyPosts(_ c: PixelCanvas, _ g: Int) -> [Int] {
        let s = unit(g), h = prancingPonyHearth(c, g), bar = prancingPonyBarFrame(c, g)
        return Array(stride(from: h.x + h.w + 32 * s, to: bar.x0 - 8 * s, by: 96 * s))
    }

    /// The bar counter: left and right edges and the top of its front (shorter in a narrow window).
    static func prancingPonyBarFrame(_ c: PixelCanvas, _ g: Int) -> (x0: Int, x1: Int, top: Int) {
        let s = unit(g), x1 = c.w - 46 * s
        return (x1 - max(50 * s, min(124 * s, x1 - 140 * s)), x1, g - 17 * s)
    }

    /// The middle of the inn sign: between the two posts nearest the middle of the room, clear of hearth and bar.
    static func prancingPonySignX(_ c: PixelCanvas, _ g: Int) -> Int {
        let s = unit(g), posts = prancingPonyPosts(c, g), h = prancingPonyHearth(c, g), bar = prancingPonyBarFrame(c, g)
        let target = Int(Double(c.w) * 0.47)
        var x = target
        if posts.count >= 2 {
            let mids: [Int] = zip(posts, posts.dropFirst()).map { (a: Int, b: Int) -> Int in (a + b) / 2 }
            x = mids.min { (a: Int, b: Int) -> Bool in abs(a - target) < abs(b - target) } ?? target
        }
        let lo = h.x + h.w + 29 * s, hi = bar.x0 - 21 * s
        return hi > lo ? min(hi, max(lo, x)) : (lo + hi) / 2
    }

    /// Where the roof's lanterns hang on tall screens: between the king posts.
    static func prancingPonyRoof(_ c: PixelCanvas, _ g: Int) -> (tie: Int, bay: Int) {
        let s = unit(g)
        return (prancingPonyCeiling(c, g) - 74 * s, 130 * s)
    }

    /// Every lamp's middle: lanterns on the posts, and on tall screens the gallery's and the roof's.
    static func prancingPonyLamps(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int)] {
        let s = unit(g), posts = prancingPonyPosts(c, g)
        var out: [(x: Int, y: Int)] = []
        if let first = posts.first { out.append((first, g - 42 * s)) }
        if let last = posts.last, posts.count > 1 { out.append((last, g - 42 * s)) }
        if isTall(c) {
            let ceil = prancingPonyCeiling(c, g), roof = prancingPonyRoof(c, g)
            for p in posts { out.append((p, ceil - 24 * s)) }
            out.append((c.w - 60 * s, ceil - 24 * s))
            for x in stride(from: roof.bay / 2, to: c.w, by: roof.bay) { out.append((x, roof.tie - 18 * s)) }
        }
        return out
    }

    /// The Prancing Pony's common room: smoke-darkened plaster between dark timber posts and braces, the hearth with
    /// its fire at the left, the bar at the right with tankards on the counter, bottles on the shelves and kegs stacked
    /// at its end, and in the middle the inn sign: a prancing pony with its tail done up in a ponytail. Lanterns on
    /// the posts. Up high on tall screens, the gallery with its railing, the rooms' doors and lamps, and the roof.
    static func prancingPony(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), ceil = prancingPonyCeiling(c, g)
        let beam = C(0x2A1A10)
        c.gradient(0, g, C(0x5E4430), C(0x8A6A4A), bands: 6)
        for i in 0..<(c.w * g / 30) {
            let n = noise(i * 3 + 802)
            c.rect(Int(noise(i * 3 + 800) * Double(c.w)), Int(noise(i * 3 + 801) * Double(g)), s, s,
                   n > 0.5 ? C(0x9A7A58, 0.5) : C(0x4A3424, 0.4))
        }
        if tall { prancingPonyUpper(c, g) }
        // the ground floor's timbers
        if !tall { c.rect(0, ceil, c.w, 5 * s, beam); c.rect(0, ceil + 5 * s, c.w, s, C(0x1A100A)) }
        for x in prancingPonyPosts(c, g) {
            c.rect(x - 2 * s, ceil + 5 * s, 5 * s, g - ceil - 5 * s, beam)
            c.rect(x - 2 * s, ceil + 5 * s, s, g - ceil - 5 * s, C(0x3E2A1C))
            for side in [-1, 1] {
                r1Line(c, x + side * 2 * s, ceil + 22 * s, x + side * 16 * s, ceil + 5 * s, beam, s: 3 * s)
            }
        }
        // the wainscot
        c.rect(0, g - 12 * s, c.w, 12 * s, C(0x4A3020))
        for x in stride(from: 0, to: c.w, by: 8 * s) { c.rect(x, g - 10 * s, s, 10 * s, C(0x3A2416)) }
        c.rect(0, g - 13 * s, c.w, 2 * s, beam); c.rect(0, g - 13 * s, c.w, s, C(0x4A3020))
        prancingPonyFireplace(c, g)
        prancingPonyBar(c, g)
        prancingPonyKegs(c, g)
        prancingPonySign(c, g)
        for l in prancingPonyLamps(c, g) { prancingPonyLantern(c, l.x, l.y, s: s) }
        c.ground(g, C(0x4A3020), edge: C(0x6E4C30), speck: C(0x3A2416), seed: 31)
        for x in stride(from: 0, to: c.w, by: 18 * s) { c.rect(x, g + 1, s, c.h - g - 1, C(0x3A2416)) }
        // the hearthstone, and the fire's warmth on the boards
        let h = prancingPonyHearth(c, g)
        c.rect(h.x - 10 * s, g, h.w + 20 * s, 2 * s, C(0x6A6058)); c.rect(h.x - 10 * s, g, h.w + 20 * s, s, C(0x8A8070))
        c.ellipse(h.x + h.w / 2, g + 3 * s, h.w, 4 * s, C(0xFF9A40, 0.10))
    }

    /// Tall screens: the gallery and its railing, the rooms' doors and lamps, and the roof's trusses.
    static func prancingPonyUpper(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), ceil = prancingPonyCeiling(c, g), roof = prancingPonyRoof(c, g), beam = C(0x2A1A10)
        // the roof: boards, the tie beam, king posts and struts, and a purlin (above the top on a just-tall canvas)
        c.rect(0, 0, c.w, roof.tie, C(0x3A2818))
        for y in stride(from: 3 * s, to: roof.tie, by: 7 * s) { c.rect(0, y, c.w, s, C(0x2A1C10)) }
        for i in 0..<max(0, c.w * roof.tie / (60 * s * s)) {
            c.rect(Int(noise(i * 2 + 820) * Double(c.w)), Int(noise(i * 2 + 821) * Double(roof.tie)), 3 * s, s, C(0x4A3420, 0.6))
        }
        let purlin = roof.tie / 2
        c.rect(0, purlin, c.w, 4 * s, beam); c.rect(0, purlin, c.w, s, C(0x3E2A1C))
        for x in stride(from: 0, to: c.w + roof.bay, by: roof.bay) {
            c.rect(x - 3 * s, 0, 6 * s, roof.tie, beam); c.rect(x - 3 * s, 0, s, roof.tie, C(0x3E2A1C))
            for side in [-1, 1] {
                r1Line(c, x + side * 3 * s, roof.tie - 4 * s, x + side * (roof.bay / 2 - 8 * s), purlin + 4 * s, beam, s: 3 * s)
            }
        }
        // lanterns hang on chains from the purlin
        for x in stride(from: roof.bay / 2, to: c.w, by: roof.bay) {
            for y in stride(from: purlin + 4 * s, to: roof.tie - 22 * s, by: 2 * s) {
                c.rect(x + (y / (2 * s)) % 2 * s - s / 2, y, s, s, C(0x1A1410))
            }
        }
        c.rect(0, roof.tie, c.w, 6 * s, beam); c.rect(0, roof.tie, c.w, s, C(0x4A3020))
        c.rect(0, roof.tie + 6 * s, c.w, s, C(0x1A100A))
        // the upper wall: posts, small leaded windows onto the night, and the rooms' doors
        let posts = prancingPonyPosts(c, g)
        for x in posts { c.rect(x - 2 * s, roof.tie + 6 * s, 5 * s, ceil - roof.tie - 6 * s, beam) }
        var mids: [Int] = []
        for (k, p) in posts.enumerated() { mids.append(k + 1 < posts.count ? (p + posts[k + 1]) / 2 : (p + c.w) / 2) }
        for (k, x) in mids.enumerated() {
            // the window
            let wy = roof.tie + 12 * s, ww = 14 * s, wh = 12 * s
            c.rect(x - ww / 2 - s, wy - s, ww + 2 * s, wh + 2 * s, beam)
            c.rect(x - ww / 2, wy, ww, wh, C(0x14203A))
            c.stars(wy, wy + wh, density: 18, seed: 40 + k, x0: x - ww / 2, x1: x + ww / 2)
            for d in stride(from: -ww, to: ww + wh, by: 4 * s) {
                for j in 0..<wh where (d + j) >= 0 && (d + j) < ww {
                    c.px(x - ww / 2 + d + j, wy + j, C(0x5A5040, 0.8))
                    if ww - 1 - (d + j) >= 0 { c.px(x - ww / 2 + ww - 1 - (d + j), wy + j, C(0x5A5040, 0.8)) }
                }
            }
            // the door
            let dw = 14 * s, dh = 30 * s, dx = x - dw / 2, dtop = ceil - dh
            c.rect(dx - 2 * s, dtop - 2 * s, dw + 4 * s, dh + 2 * s, beam)
            c.rect(dx, dtop, dw, dh, C(0x5A3A22))
            for xx in stride(from: dx + 3 * s, to: dx + dw, by: 4 * s) { c.rect(xx, dtop, s, dh, C(0x4A2E1A)) }
            c.rect(dx, dtop + 6 * s, dw, s, C(0x3A2416)); c.rect(dx, dtop + 20 * s, dw, s, C(0x3A2416))
            c.circle(dx + dw - 4 * s, dtop + 15 * s, s, C(0xC8A04A))
        }
        // the gallery's floor beam with its joist ends, and the railing
        c.rect(0, ceil, c.w, 5 * s, beam); c.rect(0, ceil, c.w, s, C(0x4A3020))
        c.rect(0, ceil + 5 * s, c.w, s, C(0x1A100A))
        for x in stride(from: 4 * s, to: c.w, by: 12 * s) { c.rect(x, ceil + 5 * s, 3 * s, 3 * s, beam) }
        let rail = C(0x5A3A22)
        c.rect(0, ceil - 2 * s, c.w, 2 * s, rail)
        for x in stride(from: s, to: c.w, by: 4 * s) {
            c.rect(x, ceil - 11 * s, 2 * s, 9 * s, C(0x4A2E1A))
            c.rect(x, ceil - 7 * s, 2 * s, s, C(0x6A4A2E))
        }
        c.rect(0, ceil - 13 * s, c.w, 3 * s, rail); c.rect(0, ceil - 13 * s, c.w, s, C(0x7A5434))
    }

    /// The hearth: its stone chimney breast, the mantel, the arched opening with the logs and the ember bed.
    static func prancingPonyFireplace(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), h = prancingPonyHearth(c, g), tall = isTall(c), ceil = prancingPonyCeiling(c, g)
        let stone = C(0x7A6E62), mortar = C(0x4A4038), hi = C(0x9A8E80)
        func masonry(_ x: Int, _ y: Int, _ w: Int, _ hh: Int, seed: Int) {
            c.rect(x, y, w, hh, stone)
            for (row, yy) in stride(from: y, to: y + hh, by: 4 * s).enumerated() {
                c.rect(x, yy, w, s, mortar)
                for (k, xx) in stride(from: x + (row % 2) * 4 * s, to: x + w, by: 8 * s).enumerated() {
                    c.rect(xx, yy, s, 4 * s, mortar)
                    if noise(row * 31 + k + seed) > 0.6 { c.rect(xx + s, yy + s, 6 * s, 3 * s, hi.alpha(0.5)) }
                    if noise(row * 31 + k + seed + 500) > 0.75 { c.rect(xx + s, yy + s, 6 * s, 3 * s, mortar.alpha(0.35)) }
                }
            }
        }
        let breastTop = tall ? 0 : ceil + 5 * s
        masonry(h.x - 4 * s, breastTop, h.w + 8 * s, g - breastTop, seed: 900)
        masonry(h.x - 8 * s, h.top - 8 * s, h.w + 16 * s, g - h.top + 8 * s, seed: 950)
        // the mantel shelf and what's on it
        c.rect(h.x - 11 * s, h.top - 11 * s, h.w + 22 * s, 4 * s, C(0x2A1A10))
        c.rect(h.x - 11 * s, h.top - 11 * s, h.w + 22 * s, s, C(0x5A3A22))
        let m = h.top - 11 * s
        c.rect(h.x - 4 * s, m - 6 * s, 2 * s, 6 * s, C(0xEEE4C8)); c.px(h.x - 3 * s, m - 7 * s, C(0xFFD860))
        c.rect(h.x + 4 * s, m - 5 * s, 5 * s, 5 * s, C(0x8A5A30)); c.rect(h.x + 9 * s, m - 4 * s, s, 3 * s, C(0x8A5A30))
        c.rect(h.x + h.w / 2 - 3 * s, m - 7 * s, 6 * s, 7 * s, C(0x9AA0A8)); c.rect(h.x + h.w / 2 - 2 * s, m - 8 * s, 4 * s, s, C(0x9AA0A8))
        c.rect(h.x + h.w - 6 * s, m - 6 * s, 2 * s, 6 * s, C(0xEEE4C8)); c.px(h.x + h.w - 5 * s, m - 7 * s, C(0xFFD860))
        c.rect(h.x + h.w + 2 * s, m - 4 * s, 4 * s, 4 * s, C(0x6A3A2A))
        // the opening, arched, soot-black, a red glow at the back
        c.rect(h.x, h.top + 4 * s, h.w, g - h.top - 4 * s, C(0x140C08))
        c.ellipse(h.x + h.w / 2, h.top + 4 * s, h.w / 2, 4 * s, C(0x140C08))
        c.ellipse(h.x + h.w / 2, g - 4 * s, h.w / 2 - 2 * s, 7 * s, C(0x6A2010, 0.6))
        // the logs on their irons, and the embers under them
        c.rect(h.x + 3 * s, g - 3 * s, h.w - 6 * s, 3 * s, C(0x2A1A10))
        c.rect(h.x + 4 * s, g - 2 * s, h.w - 8 * s, s, C(0xC84A1A))
        c.rect(h.x + 6 * s, g - 6 * s, h.w - 12 * s, 3 * s, C(0x4A2A14)); c.rect(h.x + 6 * s, g - 6 * s, h.w - 12 * s, s, C(0x6A4020))
        r1Line(c, h.x + 9 * s, g - 3 * s, h.x + h.w - 12 * s, g - 9 * s, C(0x5A3418), s: 2 * s)
        for x in [h.x + 4 * s, h.x + h.w - 6 * s] { c.rect(x, g - 7 * s, 2 * s, 7 * s, C(0x2A2A2A)) }
    }

    /// The bar: shelves of bottles and mugs on the wall behind, the panelled counter and the tankards on it.
    static func prancingPonyBar(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = prancingPonyBarFrame(c, g)
        let bottles: [UInt32] = [0x3A6A3A, 0x6A3A1A, 0x8A6A2A, 0x2E4A6A]
        for (k, y) in [g - 32 * s, g - 46 * s].enumerated() {
            c.rect(f.x0 + 6 * s, y, f.x1 - f.x0 - 12 * s, 2 * s, C(0x4A2E1A)); c.rect(f.x0 + 6 * s, y, f.x1 - f.x0 - 12 * s, s, C(0x6A4428))
            for bx in stride(from: f.x0 + 10 * s, to: f.x1 - 10 * s, by: 22 * s) { c.rect(bx, y + 2 * s, s, 3 * s, C(0x3A2416)) }
            var i = 0
            for x in stride(from: f.x0 + 9 * s + k * 3 * s, to: f.x1 - 10 * s, by: 6 * s) {
                let n = noise(i * 3 + k * 50 + 860)
                if n < 0.55 {
                    let col = C(bottles[i % bottles.count]), bh = (5 + Int(n * 4.0)) * s
                    c.rect(x, y - bh, 3 * s, bh, col); c.rect(x + s, y - bh - 2 * s, s, 2 * s, col)
                    c.rect(x, y - bh + s, s, bh - 2 * s, C(0xFFFFFF, 0.25))
                } else if n < 0.8 {
                    c.rect(x, y - 4 * s, 4 * s, 4 * s, C(0x9AA0A8)); c.rect(x, y - 4 * s, s, 4 * s, C(0xC8D0D8))
                }
                i += 1
            }
        }
        // the counter
        c.rect(f.x0, f.top, f.x1 - f.x0, g - f.top, C(0x4A2E1A))
        for px in stride(from: f.x0 + 4 * s, to: f.x1 - 14 * s, by: 16 * s) {
            c.rect(px, f.top + 5 * s, 12 * s, g - f.top - 8 * s, C(0x3A2414))
            c.rect(px, f.top + 5 * s, 12 * s, s, C(0x2A1A10)); c.rect(px, g - 4 * s, 12 * s, s, C(0x6A4428))
        }
        c.rect(f.x0 - 3 * s, f.top - 3 * s, f.x1 - f.x0 + 6 * s, 3 * s, C(0x7A5030))
        c.rect(f.x0 - 3 * s, f.top - 3 * s, f.x1 - f.x0 + 6 * s, s, C(0xA07040))
        c.rect(f.x0 - 3 * s, f.top, f.x1 - f.x0 + 6 * s, s, C(0x2A1A10))
        let spots: [Double] = [0.08, 0.2, 0.28, 0.52, 0.74, 0.86]
        for (i, k) in spots.enumerated() {
            prancingPonyTankard(c, f.x0 + Int(Double(f.x1 - f.x0) * k), f.top - 3 * s, s: s, pewter: i % 3 == 1)
        }
    }

    /// A tankard with a head of foam: wooden with iron hoops, or pewter.
    static func prancingPonyTankard(_ c: PixelCanvas, _ x: Int, _ base: Int, s: Int, pewter: Bool) {
        let body = pewter ? C(0x9AA0A8) : C(0x8A5A30), hoop = pewter ? C(0x6A7078) : C(0x3A3A3A)
        c.rect(x, base - 6 * s, 5 * s, 6 * s, body)
        c.rect(x, base - 6 * s, s, 6 * s, pewter ? C(0xD0D6DC) : C(0xA87440))
        if !pewter { c.rect(x, base - 5 * s, 5 * s, s, hoop); c.rect(x, base - 2 * s, 5 * s, s, hoop) }
        c.rect(x + 5 * s, base - 5 * s, 2 * s, s, hoop); c.rect(x + 6 * s, base - 5 * s, s, 4 * s, hoop)
        c.rect(x + 5 * s, base - 2 * s, 2 * s, s, hoop)
        c.rect(x, base - 7 * s, 5 * s, s, C(0xF4ECD8)); c.rect(x + s, base - 8 * s, 3 * s, s, C(0xF4ECD8))
        c.rect(x - s, base - 6 * s, s, 2 * s, C(0xF4ECD8, 0.9))
    }

    /// Kegs stacked at the end of the bar, round ends out, on a low rack.
    static func prancingPonyKegs(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), x0 = prancingPonyBarFrame(c, g).x1 + 4 * s, r = 8 * s
        c.rect(x0, g - 2 * s, 38 * s, 2 * s, C(0x2A1A10))
        let kegs: [(Int, Int)] = [(10, 9), (28, 9), (19, 24)]
        for (k, p) in kegs.enumerated() {
            let cx = x0 + p.0 * s, cy = g - p.1 * s
            c.circle(cx, cy, r, C(0x3A3A3A))
            c.circle(cx, cy, r - s, C(0x8A5A30))
            c.circle(cx, cy, r - 3 * s, C(0x7A4E28))
            c.circle(cx, cy, r - 4 * s, C(0x9A6A3A))
            c.rect(cx - r + 2 * s, cy - s, 2 * r - 4 * s, s, C(0x6A4020, 0.6))
            c.rect(cx - 2 * s, cy - r + s, 3 * s, s, C(0xB88A50))
            if k < 2 { c.rect(cx - s, cy + 2 * s, 2 * s, 3 * s, C(0xC8A04A)); c.rect(cx - s, cy + 5 * s, s, s, C(0xC8A04A)) }
        }
    }

    /// The inn sign hanging on its chains: a painted board with the pony and its ponytail.
    static func prancingPonySign(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), ceil = prancingPonyCeiling(c, g), x = prancingPonySignX(c, g), top = ceil + 9 * s
        let bw = 34 * s, bh = 24 * s, bx = x - bw / 2
        for cx in [bx + 5 * s, bx + bw - 6 * s] {
            for y in stride(from: ceil + 5 * s, to: top, by: s) { c.rect(cx + (y / s) % 2 * s, y, s, s, C(0x7A7068)) }
        }
        c.rect(bx + s, top + s, bw, bh, C(0x1A100A, 0.6))
        c.rect(bx, top, bw, bh, C(0x3A2414))
        c.rect(bx + 2 * s, top + 2 * s, bw - 4 * s, bh - 4 * s, C(0xE2CFA2))
        c.rect(bx, top, bw, s, C(0x5A3A22))
        for i in 0..<10 {
            c.px(bx + 2 * s + Int(noise(i * 2 + 880) * Double(bw - 4 * s)), top + 2 * s + Int(noise(i * 2 + 881) * Double(bh - 4 * s)),
                 C(0xB8A478))
        }
        r1Stamp(c, bx + 4 * s, top + 3 * s, ringsPony, ["#": C(0x2A1A10), "t": C(0x6A3A1A), "r": C(0xD8302A)], s: s)
    }

    /// A lantern: iron cap and frame round amber glass, on a little bracket.
    static func prancingPonyLantern(_ c: PixelCanvas, _ x: Int, _ y: Int, s: Int) {
        let iron = C(0x1E1A16)
        c.circle(x, y, 12 * s, C(0xFFC060, 0.06))
        c.rect(x - 2 * s, y - 3 * s, 5 * s, 5 * s, C(0xF2B850))
        c.rect(x - 3 * s, y - 4 * s, 7 * s, s, iron); c.rect(x - s, y - 5 * s, 3 * s, s, iron)
        c.rect(x - 2 * s, y - 3 * s, s, 5 * s, iron); c.rect(x + 2 * s, y - 3 * s, s, 5 * s, iron)
        c.rect(x - 3 * s, y + 2 * s, 7 * s, s, iron)
        c.rect(x, y + 3 * s, s, 2 * s, iron)
    }

    /// The fire flickering in the hearth, and the lanterns' glow swelling and fading.
    static func prancingPonyLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), h = prancingPonyHearth(c, g), f = Int(t * 10)
        let flick = noise(f * 3 + 7)
        c.ellipse(h.x + h.w / 2, g - 8 * s, h.w / 2 + 12 * s + Int(flick * Double(4 * s)), 16 * s, C(0xFF8A30, 0.06 + flick * 0.06))
        let n = (h.w - 10 * s) / (3 * s)
        for k in 0..<n {
            let x = h.x + 4 * s + k * 3 * s
            let mid = 1 - abs(Double(k) - Double(n - 1) / 2) / Double(max(1, n)) * 1.4
            let ht = Int((0.45 + 0.55 * noise(f * 17 + k * 5)) * mid * Double(14 * s))
            guard ht > 0 else { continue }
            for y in 0..<ht {
                let k2 = Double(y) / Double(ht)
                let a: Double = Double(y) / Double(s) * 0.55 + t * 9 + Double(k) * 1.3
                let wob = Int((sin(a) * k2 * 1.6).rounded()) * s
                let wdt = max(s, Int((1 - k2) * Double(5 * s)))
                c.rect(x + wob + (5 * s - wdt) / 2, g - 5 * s - y, wdt, 1, k2 < 0.4 ? C(0xE84A1A) : C(0xF8902A))
                if k2 < 0.6, wdt > 2 * s {
                    c.rect(x + wob + (5 * s - wdt) / 2 + s, g - 5 * s - y, wdt - 2 * s, 1, k2 < 0.25 ? C(0xFFF0A0) : C(0xFFD860))
                }
            }
        }
        for i in 0..<4 {
            let p = r1Phase(t, 1.6, offset: Double(i) * 0.4)
            let x = h.x + h.w / 2 + Int((noise(i + 890) - 0.5) * Double(h.w - 8 * s)) + Int(sin(p * 6 + Double(i)) * Double(2 * s))
            c.rect(x, g - 10 * s - Int(p * Double(14 * s)), s, s, C(0xFFC860, 1 - p))
        }
        // the lanterns
        for (i, l) in prancingPonyLamps(c, g).enumerated() {
            let a: Double = t * 2 * Double.pi / 2.6 + Double(i) * 1.7
            let p = 0.5 + 0.5 * sin(a)
            c.circle(l.x, l.y - s, 7 * s + Int(p * Double(3 * s)), C(0xFFC860, 0.06 + 0.10 * p))
            c.rect(l.x - s, l.y - 2 * s, 3 * s, 3 * s, C(0xFFF0B0, 0.4 + 0.5 * p))
        }
    }
}
