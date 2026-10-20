import Foundation

// Places: the Upside Down and Starcourt Mall. The Upside Down is Hawkins gone cold and dead, all in blue-grey under a
// storm lit red from inside, vines over everything and spores drifting in the air; Starcourt is the summer of 1985 at
// its brightest, pastel and chrome and neon round a fountain. The floor and the band above it stay plain and mid-dark
// so the crew's outlines and names read.

let hawkinsScenes3: [Location: Place] = [
    .hawkinsUpsideDown: Place(name: "The Upside Down", panel: 0x12161E, still: Scenes.hawkinsUpsideDown,
                              moving: Scenes.hawkinsUpsideDownLife),
    .hawkinsStarcourt: Place(name: "Starcourt Mall", panel: 0x1A1420, still: Scenes.hawkinsStarcourt,
                             moving: Scenes.hawkinsStarcourtLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 5-row alphabet, only the letters the signs here need: three dots wide, but N is four so its diagonal reads.
private let hawkinsP3Glyphs: [Character: String] = [
    "A": "010101111101101", "C": "011100100100011", "H": "101101111101101", "K": "101101110101101",
    "N": "10011101101110011001", "O": "010101101101010", "P": "110101110100100", "R": "110101110101101",
    "S": "011100010001110", "T": "111010010010010", "U": "101101101101111", "W": "1000110001101011101110001",
    "Y": "101101010010010", "I": "111010010010111", "M": "1000111011101011000110001", "E": "111100110100111",
]

/// Lettering, `p` pixels a dot, from its top-left corner, its steps eased (`hawkinsSoftText`); a space is two dots.
private func hawkinsP3Sign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    hawkinsSoftText(c, x, y, text, hawkinsP3Glyphs, col, p)
}

/// How wide `text` comes out at `p` pixels a dot.
private func hawkinsP3SignWidth(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + ((hawkinsP3Glyphs[$1].map { $0.count / 5 } ?? 2) + 1) * p } - p
}

/// One of the Upside Down's vines: a thick dark stalk wandering from (x, y) in direction `a` (radians), thinning as it
/// goes, ridged with a lighter line along its top, a knot here and there; `seed` makes each one its own.
private func hawkinsP3Vine(_ c: PixelCanvas, _ x: Int, _ y: Int, _ a: Double, len: Int, s: Int, seed: Int,
                           bend: Double = 0.35, maxY: Int = Int.max) {
    var px = Double(x), py = Double(y), ang = a
    for st in 0..<len {
        let th = st < len / 3 ? 3 * s : st < len * 3 / 4 ? 2 * s : s
        c.rect(Int(px), Int(py), th, th, C(0x1A1E26)); c.rect(Int(px), Int(py), th, s, C(0x3A4250))
        if st % 9 == 4 && th > s { c.rect(Int(px) - s, Int(py) - s, th + 2 * s, th + s, C(0x222832)) }
        px += cos(ang) * Double(s); py += sin(ang) * Double(s)
        ang += (noise(seed * 131 + st) - 0.5) * bend
        if Int(py) > maxY { break }
    }
}

// MARK: - The Upside Down

extension Scenes {
    /// Where things stand in the Upside Down: the big house, the little one, the telephone pole, the street lamp, the
    /// station wagon, and the foot of the storm cloud (in the window's strip it's only the cloud's lit underside at the
    /// top; on the screen saver the whole storm hangs over the town, the Mind Flayer in it).
    static func hawkinsUpsideDownFrame(_ c: PixelCanvas, _ g: Int)
        -> (house: Int, cottage: Int, pole: Int, lamp: Int, car: Int, cloud: Int) {
        let s = unit(g)
        return (c.w * 82 / 100, c.w * 13 / 100, c.w * 44 / 100, c.w * 28 / 100, c.w * 58 / 100,
                isTall(c) ? max(30 * s, g - 150 * s) : g - 60 * s)
    }

    /// The Upside Down: a Hawkins street the way it is on the other side, everything the same and everything wrong.
    /// The colour drained to blue-grey, the light from nowhere, the air thick with drifting spores. A two-storey
    /// clapboard house on the left with its porch and its windows black, a little house on the right, a telephone pole
    /// with its wires sagging, a dead street lamp with a bike leaning on it, a mailbox, a station wagon left in the
    /// road; and vines over all of it, climbing the walls, wrapping the pole, hanging from the wires and crawling over
    /// the ground behind. Bare trees beyond, and the storm overhead lit red from inside. On the screen saver the storm
    /// is the whole sky, and the Mind Flayer stands in it, a dark shape with its long legs reaching down.
    static func hawkinsUpsideDown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsUpsideDownFrame(c, g), tall = isTall(c)
        // The sky: dark blue-grey, a little lighter towards the horizon, and the storm's red underside above.
        c.gradient(0, g, C(0x141820), C(0x2C3644), bands: 7)
        if tall {
            // The storm: dark cloud filling the sky in long, heaped banks, each lit along its top and ragged underneath,
            // and a dull red light deep inside it where the lightning lives.
            let banks = max(4, f.cloud / (18 * s))
            for b in 0..<banks {
                let by = 6 * s + b * (f.cloud - 6 * s) / banks
                var x = -20 * s + Int(noise(b * 77) * Double(30 * s)), k = 0
                while x < c.w + 40 * s {
                    let rx = (26 + Int(noise(b * 31 + k + 7) * 34)) * s, ry = (8 + Int(noise(b * 31 + k + 9) * 9)) * s
                    let cy = by + Int((noise(b * 31 + k + 3) - 0.5) * Double(14 * s))
                    c.ellipse(x, cy, rx, ry, k % 3 == 0 ? C(0x1C1A22) : C(0x16151B))
                    c.ellipse(x - rx / 5, cy - ry / 2, rx * 3 / 5, max(s, ry / 3), C(0x24222C))
                    c.ellipse(x + rx / 6, cy + ry * 2 / 3, rx * 2 / 3, max(s, ry / 4), C(0x121116))
                    x += rx + Int(noise(b * 31 + k + 5) * Double(rx)) - rx / 3; k += 1
                }
            }
            for k in 0..<5 {
                let cx = c.w * (12 + k * 19) / 100, cy = f.cloud * (30 + Int(noise(k + 40) * 50)) / 100
                for (r, a) in [(46, 0.10), (30, 0.12), (16, 0.14)] { c.ellipse(cx, cy, r * s, r * s / 3, C(0x7A1A24, a)) }
            }
            for k in 0..<(c.w / (20 * s) + 1) {
                let cx = k * 20 * s + Int(noise(k + 600) * Double(10 * s)), cy = f.cloud - Int(noise(k + 610) * Double(10 * s))
                c.ellipse(cx, cy + 2 * s, (10 + k % 3 * 3) * s, (2 + k % 2) * s, C(0x3E1E28)); c.ellipse(cx, cy, (14 + k % 4 * 3) * s, (3 + k % 3) * s, C(0x221C24))
            }
            // The Mind Flayer: a vast shape of smoke in the storm, a hunched body high up, arms reaching up and out, and
            // long legs splayed like a spider's, out at the knee and then down towards the town. Edged dull red where
            // the storm lights it from below, and smoky round the edges.
            let mx = c.w * 52 / 100, my = max(f.cloud * 42 / 100, 44 * s)
            let flayer = C(0x08070A), smoke = C(0x08070A, 0.35), rim = C(0x5A1A24)
            func limb(_ pts: [(Double, Double)], _ th0: Double) {
                var prev = pts[0]
                let total = Double(pts.count - 1)
                for (i, q) in pts.dropFirst().enumerated() {
                    let n = max(1, Int(max(abs(q.0 - prev.0), abs(q.1 - prev.1)) / Double(s)))
                    for st in 0...n {
                        let u = Double(st) / Double(n), x = prev.0 + (q.0 - prev.0) * u, y = prev.1 + (q.1 - prev.1) * u
                        let th = max(Double(s), th0 * (1 - (Double(i) + u) / total * 0.85))
                        c.rect(Int(x - th / 2) - s, Int(y) - s, Int(th) + 2 * s, Int(th) + 2 * s, smoke)
                        c.rect(Int(x - th / 2), Int(y), Int(th), Int(th), flayer)
                        c.rect(Int(x - th / 2), Int(y + th), Int(th), s, rim)
                    }
                    prev = q
                }
            }
            let H = Double(g - 100 * s - my), W = Double(c.w), X = Double(mx), Y = Double(my)
            /// A curve through three points (a quadratic Bézier), sampled into the limb's points.
            func curve(_ a: (Double, Double), _ b: (Double, Double), _ e: (Double, Double)) -> [(Double, Double)] {
                (0...12).map { i in
                    let u = Double(i) / 12, v = 1 - u
                    return (v * v * a.0 + 2 * v * u * b.0 + u * u * e.0, v * v * a.1 + 2 * v * u * b.1 + u * u * e.1)
                }
            }
            for side in [-1.0, 1.0] {
                // Three legs a side: arching out and up to the knee, then curving down.
                for j in 0..<3 {
                    let out = (0.17 + Double(j) * 0.1) * W * side, foot = Y + H * (0.75 + Double(j) * 0.12)
                    let knee = (X + out * 0.75, Y - Double((8 + j * 5) * s))
                    limb(curve((X, Y), (X + out * 0.3, Y - Double((20 + j * 6) * s)), knee) +
                         curve(knee, (X + out * 1.05, Y + H * 0.1), (X + out * 1.15, foot)).dropFirst(), Double((7 - j) * s))
                }
                // Two arms a side, reaching up and out into the cloud, curling at the end.
                for j in 0..<2 {
                    let reach = (0.13 + Double(j) * 0.12) * W * side
                    limb(curve((X, Y - Double(8 * s)), (X + reach * 0.4, Y - Double((34 + j * 10) * s)),
                               (X + reach, Y - Double((18 + j * 14) * s))), Double(5 * s))
                }
            }
            // The body: hunched, taller than wide, a ridge of spines along its top.
            c.ellipse(mx, my - 6 * s, 17 * s, 26 * s, smoke)
            c.ellipse(mx, my - 6 * s, 15 * s, 24 * s, flayer); c.ellipse(mx + 2 * s, my + 10 * s, 18 * s, 10 * s, flayer)
            for k in 0..<7 { c.rect(mx - 12 * s + k * 4 * s, my - 34 * s + abs(k - 3) * 3 * s, 2 * s, 8 * s, flayer) }
            c.ellipse(mx + 2 * s, my + 19 * s, 14 * s, s, rim)
        } else {
            // In the strip only the storm's underside shows, along the top, red where it's lit.
            for k in 0..<24 {
                let cx = Int(noise(k * 11 + 5) * Double(c.w)), cy = f.cloud - Int(noise(k * 11 + 6) * Double(8 * s))
                c.ellipse(cx, cy + 2 * s, (12 + k % 5 * 2) * s, (2 + k % 2) * s, C(0x3A1E26))
                c.ellipse(cx, cy, (16 + Int(noise(k * 11 + 7) * 14)) * s, (4 + k % 3) * s, C(0x221C24))
            }
        }

        // Bare trees along the back, in the haze.
        for k in 0..<(c.w / (14 * s) + 1) {
            let tx = k * 14 * s + Int(noise(k + 300) * Double(8 * s)), th = (22 + Int(noise(k + 310) * 18)) * s
            let col = C(0x252D38)
            c.rect(tx, g - th, 2 * s, th, col)
            for b in 0..<4 {
                let by = g - th + (2 + b * 5) * s, dir = b % 2 == 0 ? 1 : -1
                for d in 0..<((6 - b) * s) { c.rect(tx + dir * d, by - d / 2, s, s, col) }
            }
        }
        c.rect(0, g - 8 * s, c.w, 8 * s, C(0x2A323E))

        // The two-storey house: clapboard in blue-grey, a gabled roof, two windows up and two down, a porch with posts
        // and steps, and its windows black.
        let hx = f.house, hw = 70 * s, wallTop = g - 44 * s
        let clap = C(0x4A5666), clapD = C(0x3E4858), clapL = C(0x5A6878)
        c.rect(hx - hw / 2, wallTop, hw, 44 * s, clap)
        for y in stride(from: wallTop, to: g, by: 3 * s) { c.rect(hx - hw / 2, y + 2 * s, hw, s, clapD) }
        c.rect(hx + hw / 2 - 6 * s, wallTop, 6 * s, 44 * s, clapD)
        for y in 0..<(22 * s) {
            let half = hw / 2 + 4 * s - y * (hw / 2 + 4 * s) / (22 * s)
            c.rect(hx - half, wallTop - y - s, half * 2, 1, y < s ? C(0x2A303A) : C(0x323A46))
            if half > 2 * s { c.rect(hx - half, wallTop - y - s, s, 1, C(0x4A5462)) }
        }
        for (wx, wy) in [(hx - 22 * s, wallTop + 4 * s), (hx + 12 * s, wallTop + 4 * s), (hx + 12 * s, wallTop + 24 * s)] {
            c.rect(wx - s, wy - s, 12 * s, 14 * s, C(0x8A96A4)); c.rect(wx, wy, 10 * s, 12 * s, C(0x0C0E14))
            c.rect(wx + 5 * s, wy, s, 12 * s, C(0x6A7684)); c.rect(wx, wy + 6 * s, 10 * s, s, C(0x6A7684))
            c.rect(wx - 2 * s, wy + 12 * s, 14 * s, s, C(0x8A96A4))
        }
        c.rect(hx - 8 * s, wallTop - 14 * s, 8 * s, 8 * s, C(0x8A96A4)); c.rect(hx - 7 * s, wallTop - 13 * s, 6 * s, 6 * s, C(0x0C0E14))
        // The porch: a roof on posts, the door in its shade, steps.
        let porch = hx - 30 * s
        c.rect(porch - 4 * s, g - 22 * s, 32 * s, 3 * s, C(0x323A46)); c.rect(porch - 4 * s, g - 22 * s, 32 * s, s, C(0x5A6878))
        for px0 in [porch - 3 * s, porch + 12 * s, porch + 25 * s] { c.rect(px0, g - 19 * s, 2 * s, 16 * s, C(0x6A7686)) }
        c.rect(porch + 3 * s, g - 18 * s, 8 * s, 15 * s, C(0x14181E)); c.rect(porch + 9 * s, g - 10 * s, s, s, C(0x6A7686))
        c.rect(porch - 4 * s, g - 3 * s, 32 * s, 3 * s, C(0x3A4452)); c.rect(porch - 4 * s, g - 3 * s, 32 * s, s, C(0x5A6878))
        for x in stride(from: porch - 3 * s, to: porch + 27 * s, by: 3 * s) { c.rect(x, g - 9 * s, s, 6 * s, C(0x5A6676)) }
        c.rect(porch - 4 * s, g - 10 * s, 31 * s, s, C(0x6A7686))
        // Vines up the house: from the ground, over the porch, across the wall and up the roof.
        for k in 0..<7 {
            hawkinsP3Vine(c, hx - hw / 2 + k * 11 * s, g - 2 * s, -.pi / 2 + (noise(k + 20) - 0.5) * 0.9, len: 30 + k * 4 % 20, s: s, seed: k + 20)
        }
        hawkinsP3Vine(c, hx - hw / 2 - 4 * s, wallTop - 2 * s, -0.5, len: 40, s: s, seed: 77)

        // The little house on the right: one storey, a low roof, a picture window and a carport.
        let ch = f.cottage, cw = 60 * s, ct = g - 28 * s
        c.rect(ch - cw / 2, ct, cw, 28 * s, clap)
        for y in stride(from: ct, to: g, by: 3 * s) { c.rect(ch - cw / 2, y + 2 * s, cw, s, clapD) }
        for y in 0..<(10 * s) {
            let half = cw / 2 + 5 * s - y * 3
            if half > 0 { c.rect(ch - half, ct - y - s, half * 2, 1, C(0x323A46)) }
        }
        c.rect(ch - cw / 2 - 5 * s, ct - s, cw + 10 * s, s, C(0x5A6878))
        c.rect(ch - 22 * s, ct + 6 * s, 24 * s, 12 * s, C(0x8A96A4)); c.rect(ch - 21 * s, ct + 7 * s, 22 * s, 10 * s, C(0x0C0E14))
        c.rect(ch - 13 * s, ct + 7 * s, s, 10 * s, C(0x6A7684)); c.rect(ch - 5 * s, ct + 7 * s, s, 10 * s, C(0x6A7684))
        c.rect(ch + 8 * s, ct + 6 * s, 9 * s, 22 * s, C(0x14181E)); c.rect(ch + 8 * s, ct + 6 * s, 9 * s, s, C(0x6A7686))
        c.rect(ch - cw / 2, ct, s, 28 * s, clapL); c.rect(hx - hw / 2, wallTop, s, 44 * s, clapL)
        for k in 0..<5 { hawkinsP3Vine(c, ch - cw / 2 + k * 13 * s, g - 2 * s, -.pi / 2 + (noise(k + 60) - 0.5) * 1.0, len: 22 + k * 5 % 14, s: s, seed: k + 60) }

        // The telephone pole: a crossbar and insulators, the wires sagging off along the street and across to the house,
        // vines wound round it and hanging from the wires.
        let px = f.pole, ptop = tall ? g - 96 * s : g - 62 * s
        c.rect(px - 2 * s, ptop, 4 * s, g - ptop, C(0x3A3A40)); c.rect(px - 2 * s, ptop, s, g - ptop, C(0x52525A))
        c.rect(px - 14 * s, ptop + 4 * s, 28 * s, 2 * s, C(0x3A3A40))
        for ix in [px - 12 * s, px - 6 * s, px + 5 * s, px + 11 * s] { c.rect(ix, ptop + 2 * s, s, 2 * s, C(0x7A8A9A)) }
        for (k, ix) in [px + 5 * s, px + 11 * s].enumerated() {
            for x in ix..<c.w { let u = Double(x - ix) / Double(c.w - ix); c.rect(x, ptop + 3 * s + Int(sin(u * .pi) * Double((10 + k * 4) * s)), 1, s, C(0x14161C)) }
        }
        for (k, ix) in [px + 5 * s, px + 11 * s].enumerated() {
            let ex = hx - hw / 2 - 2 * s, ey = wallTop + (2 + k * 4) * s, y0 = ptop + 3 * s
            for x in ix..<ex { let u = Double(x - ix) / Double(ex - ix); c.rect(x, y0 + Int(Double(ey - y0) * u + sin(u * .pi) * Double(6 * s)), 1, s, C(0x14161C)) }
        }
        for k in 0..<5 {
            let vy = ptop + 8 * s + k * (g - ptop - 10 * s) / 5
            c.rect(px - 3 * s, vy, 6 * s, 2 * s, C(0x1A1E26)); c.rect(px - 3 * s, vy, 6 * s, s, C(0x3A4250))
        }
        for k in 0..<4 {
            let vx = px + (20 + k * 34) * s
            if vx < c.w { let u = Double(vx - px - 5 * s) / Double(c.w - px - 5 * s); let wy = ptop + 3 * s + Int(sin(u * .pi) * Double(10 * s))
                for d in 0..<((6 + k * 3) * s) { c.rect(vx + Int(sin(Double(d) / Double(3 * s))) * s, wy + d, s, s, C(0x1E242C)) } }
        }

        // The street lamp, dead, its head dark; a bike leaning against it, tangled; the mailbox on its post.
        let lx = f.lamp
        c.rect(lx, g - 46 * s, 2 * s, 44 * s, C(0x4A5462)); c.rect(lx, g - 46 * s, s, 44 * s, C(0x6A7686))
        c.rect(lx, g - 46 * s, 10 * s, 2 * s, C(0x4A5462)); c.rect(lx + 6 * s, g - 45 * s, 6 * s, 3 * s, C(0x3A4250)); c.rect(lx + 7 * s, g - 42 * s, 4 * s, s, C(0x6A7A8A))
        c.rect(lx - 2 * s, g - 3 * s, 6 * s, 3 * s, C(0x3A4250))
        let bx = lx + 4 * s, by = g - 5 * s
        for wx in [bx, bx + 14 * s] { c.circle(wx, by, 5 * s, C(0x1E242C)); c.circle(wx, by, 4 * s, C(0x2C3440)); c.rect(wx, by, s, s, C(0x6A7686)) }
        for k in 0..<(7 * s) { c.rect(bx + k, by - k / 2, s, s, C(0x6A3A44)); c.rect(bx + 7 * s + k, by - 3 * s, s, s, C(0x6A3A44)); c.rect(bx + 14 * s - k / 3, by - k, s, s, C(0x6A3A44)) }
        c.rect(bx + 5 * s, by - 5 * s, 4 * s, s, C(0x1E1E22)); c.rect(bx + 11 * s, by - 8 * s, 5 * s, s, C(0x6A7686))
        hawkinsP3Vine(c, lx - 4 * s, g - 2 * s, -1.2, len: 34, s: s, seed: 90)
        let mb = c.w * 22 / 100
        c.rect(mb, g - 12 * s, 2 * s, 12 * s, C(0x3A3A40)); c.rect(mb - 4 * s, g - 17 * s, 10 * s, 6 * s, C(0x5A6676))
        c.rect(mb - 4 * s, g - 17 * s, 10 * s, s, C(0x7A8696)); c.rect(mb + 5 * s, g - 20 * s, s, 4 * s, C(0x7A3A3A))

        // The station wagon left in the road: long and boxy, wood panelling down its side, its windows dark, a tyre
        // flat, vines over its bonnet.
        let cx0 = f.car - 30 * s, cy0 = g - 15 * s
        c.rect(cx0 + 10 * s, cy0 - 7 * s, 40 * s, 8 * s, C(0x4E5A6A)); c.rect(cx0 + 10 * s, cy0 - 7 * s, 40 * s, s, C(0x6A7686))
        for (wx, ww) in [(cx0 + 13 * s, 10 * s), (cx0 + 25 * s, 11 * s), (cx0 + 38 * s, 10 * s)] { c.rect(wx, cy0 - 5 * s, ww, 5 * s, C(0x0E1218)) }
        c.rect(cx0, cy0, 60 * s, 10 * s, C(0x5A6676)); c.rect(cx0, cy0, 60 * s, s, C(0x7A8696))
        c.rect(cx0 + 12 * s, cy0 + 3 * s, 40 * s, 4 * s, C(0x4A4440)); c.rect(cx0 + 12 * s, cy0 + 3 * s, 40 * s, s, C(0x5E5650))
        c.rect(cx0, cy0 + 2 * s, 3 * s, 3 * s, C(0x8A96A4)); c.rect(cx0 + 57 * s, cy0 + 2 * s, 3 * s, 3 * s, C(0x6A3A44))
        for wx in [cx0 + 12 * s, cx0 + 48 * s] { c.circle(wx, cy0 + 10 * s, 4 * s, C(0x14161C)); c.circle(wx, cy0 + 10 * s, 2 * s, C(0x4A5462)) }
        c.rect(cx0 + 44 * s, cy0 + 12 * s, 9 * s, 2 * s, C(0x14161C))
        for k in 0..<3 { hawkinsP3Vine(c, cx0 - 2 * s + k * 4 * s, g - 2 * s, -0.6 + Double(k) * 0.2, len: 20 + k * 6, s: s, seed: 140 + k, maxY: g - 2 * s) }

        // Vines crawling along the ground at the back, and spores hanging in the still air.
        for k in 0..<(c.w / (30 * s) + 1) {
            hawkinsP3Vine(c, k * 30 * s, g - 3 * s, (noise(k + 200) - 0.5) * 0.6, len: 26, s: s, seed: k + 200, bend: 0.25, maxY: g - 2 * s)
        }
        for k in 0..<(c.w * g / (500 * s * s)) {
            let x = Int(noise(k * 3 + 900) * Double(c.w)), y = Int(noise(k * 3 + 901) * Double(g - 14 * s))
            c.rect(x, y, s, s, C(0xB8C4D0, 0.35 + noise(k * 3 + 902) * 0.3))
        }

        // The ground: the road gone grey-blue, plain, a lit edge and the odd root.
        c.ground(g, C(0x2E3640), edge: C(0x46505C), speck: C(0x262C34), seed: 41)
    }

    /// The Upside Down's life: spores drifting slowly up and sideways through the air, and every few seconds red
    /// lightning forking through the storm overhead, its glow on the cloud for a moment.
    static func hawkinsUpsideDownLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsUpsideDownFrame(c, g)
        // The spores: each on its own slow path, wrapping round.
        let n = c.w * g / (900 * s * s)
        for k in 0..<n {
            let sp = 2.0 + noise(k * 5 + 1) * 4
            let x = (noise(k * 5 + 2) * Double(c.w) + sin(t * 0.4 + Double(k)) * Double(6 * s) + t * sp * 0.6)
                .truncatingRemainder(dividingBy: Double(c.w))
            let span = Double(g - 6 * s)
            var y = noise(k * 5 + 3) * span - t * sp
            y = y.truncatingRemainder(dividingBy: span); if y < 0 { y += span }
            let a = 0.35 + noise(k * 5 + 4) * 0.45
            c.rect(Int(x), Int(y), s, s, C(0xD0DCE8, a))
            if k % 4 == 0 { c.rect(Int(x) + s, Int(y), s, s, C(0xD0DCE8, a * 0.5)) }
        }
        // The lightning: about once every six seconds, for a fifth of a second, a forked red bolt in the cloud.
        let period = 6.3, phase = t.truncatingRemainder(dividingBy: period)
        guard phase < 0.22 else { return }
        let n0 = Int(t / period)
        let bx = Int(noise(n0 * 3 + 500) * Double(c.w - 80 * s)) + 40 * s
        let top = isTall(c) ? f.cloud / 3 : 0, bottom = isTall(c) ? f.cloud + 10 * s : f.cloud + 4 * s
        for (r, a) in [(40, 0.05), (24, 0.07)] { c.ellipse(bx, (top + bottom) / 2, r * s * 2, r * s / 2 + (bottom - top) / 3, C(0xE02838, a)) }
        var x = bx, y = top
        while y < bottom {
            let nx = x + Int((noise(n0 * 97 + y) - 0.5) * Double(8 * s))
            c.rect(min(x, nx), y, abs(nx - x) + s, 2 * s, C(0xFF4A50)); c.rect(min(x, nx), y, abs(nx - x) + s, s, C(0xFFB0B0))
            if (y / s) % 11 == 5 {
                var fx = nx, fy = y
                for _ in 0..<6 { fx += (noise(fy + n0) > 0.5 ? 1 : -1) * 2 * s; fy += s; c.rect(fx, fy, s, s, C(0xFF4A50)) }
            }
            x = nx; y += 2 * s
        }
    }
}

// MARK: - Starcourt Mall

extension Scenes {
    /// Where things stand in Starcourt: the gallery slab's top, Scoops Ahoy's left edge and width, the fountain's middle,
    /// the clothes shop, the record shop, the STARCOURT sign's middle and the neon strips along the shop fronts.
    static func hawkinsStarcourtFrame(_ c: PixelCanvas, _ g: Int)
        -> (slab: Int, scoops: (x: Int, w: Int), fountain: Int, clothes: Int, records: Int, sign: (x: Int, y: Int)) {
        let s = unit(g)
        return (g - 44 * s, (x: c.w * 24 / 100, w: 96 * s), c.w * 63 / 100, c.w * 9 / 100, c.w * 84 / 100,
                (x: c.w * 73 / 100, y: g - 64 * s))
    }

    /// The atrium's half-round window on the screen saver: its middle at the foot and its radius.
    static func hawkinsStarcourtArch(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, r: Int) {
        let s = unit(g), springY = hawkinsStarcourtFrame(c, g).slab - 58 * s
        return (c.w / 2, springY, max(10 * s, min(c.w * 40 / 100, springY - 12 * s)))
    }

    /// Starcourt Mall in the summer of 1985, by day: two floors of shops round the atrium, white and pastel with
    /// chrome. On the ground floor a clothes shop with two mannequins in the window, Scoops Ahoy in its sailor
    /// stripes with the tubs under the counter's glass, a ship's wheel and a lifebuoy, the round fountain with its
    /// jet, and a record shop with sleeves in the window; palms in planters between them. Above, the gallery's white
    /// slab with a pink stripe, its glass balustrade and chrome rail, the upper shops, and the STARCOURT sign in pink
    /// neon. On the screen saver the upper floor shows whole and the atrium's vaulted skylights rise over it, the sky
    /// blue through the glass, a SUMMER banner hanging from the ribs.
    static func hawkinsStarcourt(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsStarcourtFrame(c, g), tall = isTall(c)
        let wall = C(0xE8E0D8), pink = C(0xE87AA8), teal = C(0x4AC0C0), chrome = C(0xC8D0D8)
        // The upper floor first: its shop wall, pale, with the shop fronts in a row (glass, a fascia each).
        let upperFloor = f.slab - 40 * s
        c.rect(0, 0, c.w, f.slab, C(0xD8D0CC))
        if tall {
            // The atrium's end wall: white, and in it the great half-round window, its glazing bars fanning out from
            // the middle and two rings round, the summer sky and a cloud or two through the glass, a pink neon ring
            // round its frame (lit by the moving layer), globe lamps hanging on long stems, and the SUMMER banner.
            let springY = upperFloor - 18 * s, R = hawkinsStarcourtArch(c, g).r, ax = c.w / 2
            c.gradient(0, springY, C(0x5AA0E0), C(0xA8D8F4), bands: 6)
            Scenes.cloud(c, ax - R / 2, springY - R * 2 / 3, 6 * s, seed: 3)
            Scenes.cloud(c, ax + R / 3, springY - R / 3, 5 * s, seed: 8)
            for y in 0..<springY {
                let dy = Double(springY - y), half = dy < Double(R) ? Int((Double(R * R) - dy * dy).squareRoot()) : 0
                let tone = (springY - y) / s % 24 == 0 ? C(0xDCD6D2) : C(0xF0ECE8)
                c.rect(0, y, ax - half, 1, tone); c.rect(ax + half, y, c.w - ax - half, 1, tone)
            }
            for k in 0...14 {
                let a = Double.pi * Double(k) / 14
                for d in stride(from: R * 35 / 100, to: R, by: s) { c.rect(ax + Int(cos(a) * Double(d)) - s / 2, springY - Int(sin(a) * Double(d)), 2 * s, s, C(0xF8F8F8)) }
            }
            for (r, w) in [(R * 35 / 100, 2), (R * 70 / 100, 2), (R, 4)] {
                for k in 0...(r / s * 4) {
                    let a = Double.pi * Double(k) / Double(r / s * 4)
                    c.rect(ax + Int(cos(a) * Double(r)) - s, springY - Int(sin(a) * Double(r)) - s, w * s, w * s, C(0xF8F8F8))
                }
            }
            c.ellipse(ax, springY, R * 35 / 100, R * 35 / 100, C(0xF8F8F8, 0.25))
            for k in 0...(R / s * 4) {
                let a = Double.pi * Double(k) / Double(R / s * 4), r = Double(R + 7 * s)
                c.rect(ax + Int(cos(a) * r), springY - Int(sin(a) * r), s, s, C(0xB86A8A))
            }
            for lx in [c.w * 8 / 100, c.w * 92 / 100] {
                let ly = springY - 30 * s
                if ly > 10 * s {
                    c.rect(lx, 0, s, ly, C(0x9A9AA0)); c.circle(lx, ly + 4 * s, 4 * s, C(0xF8F4E8)); c.circle(lx - s, ly + 3 * s, 2 * s, C(0xFFFFFF))
                }
            }
            c.rect(0, springY, c.w, 6 * s, C(0xF0ECE8)); c.rect(0, springY + 6 * s, c.w, 2 * s, pink); c.rect(0, springY + 8 * s, c.w, s, C(0xA89AA0))
            let bnx = ax, bny = springY - 34 * s
            if bny > 30 * s {
                c.rect(bnx - 30 * s, bny - 30 * s, s, 30 * s, C(0x8A8A90)); c.rect(bnx + 30 * s, bny - 30 * s, s, 30 * s, C(0x8A8A90))
                c.rect(bnx - 32 * s, bny, 64 * s, 16 * s, C(0x3AA8C0)); c.rect(bnx - 32 * s, bny, 64 * s, 2 * s, C(0xF0D040))
                c.rect(bnx - 32 * s, bny + 14 * s, 64 * s, 2 * s, C(0xF0D040))
                let w = hawkinsP3SignWidth("SUMMER", 2 * s)
                hawkinsP3Sign(c, bnx - w / 2, bny + 4 * s, "SUMMER", C(0xFFFFFF), 2 * s)
                for k in 0..<4 { c.rect(bnx - 32 * s + k * 16 * s + 6 * s, bny + 16 * s, 4 * s, 4 * s, k % 2 == 0 ? pink : C(0xF0D040)) }
            }
            // The upper floor's shops, whole: a pastel fascia with stripes for its name, the glass front with its
            // displays, chrome mullions.
            c.rect(0, springY + 9 * s, c.w, f.slab - springY - 9 * s, C(0xD8D0CC))
            for (k, x) in stride(from: 10 * s, to: c.w, by: 74 * s).enumerated() {
                let fy = upperFloor + 2 * s
                c.rect(x, fy, 64 * s, 8 * s, [C(0x7AC8D8), C(0xF0A0C0), C(0xF0D070), C(0xA8D8A0)][k % 4])
                c.rect(x + 10 * s, fy + 3 * s, 44 * s, 2 * s, C(0xFFFFFF))
                c.rect(x, fy + 8 * s, 64 * s, f.slab - fy - 8 * s, C(0x9AB0C0)); c.rect(x, fy + 8 * s, 64 * s, s, C(0xB8CCD8))
                for gx in stride(from: x + 16 * s, to: x + 64 * s, by: 16 * s) { c.rect(gx, fy + 8 * s, s, f.slab - fy - 8 * s, chrome) }
                for m in 0..<3 {
                    let mx = x + (8 + m * 20) * s
                    c.rect(mx, fy + 14 * s, 8 * s, 10 * s, [C(0xE85A7A), C(0x4A8AD0), C(0xF0C040)][(m + k) % 3])
                    c.rect(mx, fy + 14 * s, 8 * s, s, C(0xFFFFFF, 0.6))
                }
            }
        } else {
            // In the strip only the upper shop fronts' lower half shows, above the balustrade.
            for (k, x) in stride(from: 10 * s, to: c.w, by: 74 * s).enumerated() {
                c.rect(x, f.slab - 22 * s, 64 * s, 22 * s, C(0x9AB0C0)); c.rect(x, f.slab - 22 * s, 64 * s, s, C(0xB8CCD8))
                for gx in stride(from: x + 16 * s, to: x + 64 * s, by: 16 * s) { c.rect(gx, f.slab - 22 * s, s, 22 * s, chrome) }
                c.rect(x, f.slab - 24 * s, 64 * s, 2 * s, [C(0x7AC8D8), C(0xF0A0C0), C(0xF0D070), C(0xA8D8A0)][k % 4])
            }
        }
        // The STARCOURT sign up on the gallery's front: a dark panel with the name in pink neon and a star.
        let text = "STARCOURT", p = 2 * s, tw = hawkinsP3SignWidth(text, p)
        let sx = f.sign.x - tw / 2, sy = f.sign.y + 3 * s
        c.rect(sx - 16 * s, sy - 3 * s, tw + 22 * s, 16 * s, C(0x2A2240)); c.rect(sx - 16 * s, sy - 3 * s, tw + 22 * s, s, C(0x4A4060))
        hawkinsP3Sign(c, sx, sy, text, C(0xC85A88), p)
        let stx = sx - 9 * s, sty = sy + 4 * s
        for d in -4...4 { c.rect(stx - (4 - abs(d)) * s / 2, sty + d * s / 2, (4 - abs(d)) * s + s, s, C(0x5AD0D0)) }
        c.rect(stx - 4 * s, sty - s, 9 * s, s, C(0x5AD0D0))

        // The balustrade: glass panes with a chrome rail and posts.
        let rail = f.slab - 12 * s
        c.rect(0, rail, c.w, 12 * s, C(0xA8C8D4, 0.55))
        c.rect(0, rail, c.w, 2 * s, chrome); c.rect(0, rail, c.w, s, C(0xF0F4F8))
        for x in stride(from: 4 * s, to: c.w, by: 24 * s) { c.rect(x, rail, 2 * s, 12 * s, chrome) }
        // The gallery's slab: white, a pink stripe, its shadow under it.
        c.rect(0, f.slab, c.w, 6 * s, wall); c.rect(0, f.slab + 2 * s, c.w, 2 * s, pink); c.rect(0, f.slab + 6 * s, c.w, 2 * s, C(0x9A9098))

        // The ground floor's back wall, and the shops along it.
        c.rect(0, f.slab + 8 * s, c.w, g - f.slab - 8 * s, C(0x7A6E84))
        c.rect(0, f.slab + 8 * s, c.w, s, C(0x5E5468))
        for x in stride(from: 0, to: c.w, by: 20 * s) { c.rect(x, f.slab + 9 * s, s, g - f.slab - 9 * s, C(0x72667C)) }

        // The clothes shop: a teal fascia with stripes for its name, the window with two mannequins in the year's
        // colours, and its doors open.
        let cl = f.clothes, ctop = f.slab + 10 * s
        c.rect(cl - 30 * s, ctop, 62 * s, 7 * s, teal); c.rect(cl - 30 * s, ctop, 62 * s, s, C(0x8AE0E0))
        for k in 0..<5 { c.rect(cl - 20 * s + k * 9 * s, ctop + 3 * s, 6 * s, 2 * s, C(0xFFFFFF)) }
        c.rect(cl - 30 * s, ctop + 7 * s, 62 * s, g - ctop - 7 * s, C(0x5E7486)); c.rect(cl - 30 * s, ctop + 7 * s, 62 * s, 2 * s, C(0x7A90A0))
        for (k, mx) in [cl - 20 * s, cl - 6 * s].enumerated() {
            c.circle(mx, ctop + 13 * s, 2 * s, C(0xE8E0D8))
            c.rect(mx - 3 * s, ctop + 15 * s, 6 * s, 9 * s, k == 0 ? C(0xE85A9A) : C(0xF0D040))
            c.rect(mx - 4 * s, ctop + 15 * s, 8 * s, 2 * s, k == 0 ? C(0xF08AB8) : C(0xF8E070))
            c.rect(mx - 3 * s, ctop + 24 * s, 6 * s, 6 * s, k == 0 ? C(0x3A5AA0) : C(0x4AB0B0))
            c.rect(mx - s, ctop + 30 * s, 2 * s, g - ctop - 31 * s, C(0xC8C8C8))
        }
        c.rect(cl + 8 * s, ctop + 9 * s, 22 * s, g - ctop - 9 * s, C(0x5A6A78)); c.rect(cl + 19 * s, ctop + 9 * s, s, g - ctop - 9 * s, chrome)
        c.rect(cl - 30 * s, g - 3 * s, 62 * s, 3 * s, C(0x8A8088))

        // Scoops Ahoy: a white fascia with the name in red, sailor stripes on the awning, the counter with the tubs
        // behind the glass, the menu board, a ship's wheel and a lifebuoy on the wall.
        let sc = f.scoops, stop = f.slab + 10 * s
        c.rect(sc.x, stop, sc.w, 12 * s, C(0xF8F8F4)); c.rect(sc.x, stop, sc.w, s, C(0xFFFFFF)); c.rect(sc.x, stop + 11 * s, sc.w, s, C(0x2A3A7A))
        let name = "SCOOPS AHOY", nw = hawkinsP3SignWidth(name, 2 * s)
        hawkinsP3Sign(c, sc.x + (sc.w - nw) / 2, stop + s, name, C(0xD02A3A), 2 * s)
        for x in stride(from: sc.x, to: sc.x + sc.w, by: 6 * s) {
            c.rect(x, stop + 12 * s, 3 * s, 5 * s, C(0x2A3A8A)); c.rect(x + 3 * s, stop + 12 * s, 3 * s, 5 * s, C(0xF8F8F4))
            c.rect(x, stop + 17 * s, 6 * s, s, C(0xD02A3A))
        }
        let inside = stop + 18 * s
        c.rect(sc.x, inside, sc.w, g - inside, C(0x7894AA))
        for y in stride(from: inside, to: g - 12 * s, by: 4 * s) { c.rect(sc.x, y, sc.w, s, C(0x6E889E)) }
        // The menu board.
        c.rect(sc.x + 30 * s, inside + 2 * s, 36 * s, 9 * s, C(0x2A3A7A))
        for r in 0..<3 { for k in 0..<4 { c.rect(sc.x + (33 + k * 8) * s, inside + (3 + r * 2) * s, 6 * s, s, k == 0 ? C(0xF0D040) : C(0xF0F0F0)) } }
        // The ship's wheel and the lifebuoy.
        let whx = sc.x + 12 * s, why = inside + 7 * s
        c.circle(whx, why, 6 * s, C(0xA86A2E)); c.circle(whx, why, 4 * s, C(0x7894AA)); c.circle(whx, why, s, C(0x8A5A2A))
        for a in 0..<8 { let r = Double(a) * .pi / 4; for d in 1..<8 { c.rect(whx + Int(cos(r) * Double(d * s)), why + Int(sin(r) * Double(d * s)), s, s, C(0xA86A2E)) } }
        let lbx = sc.x + sc.w - 12 * s
        c.circle(lbx, why, 5 * s, C(0xF8F8F4)); c.circle(lbx, why, 2 * s, C(0x7894AA))
        for (dx, dy) in [(-5, 0), (4, 0), (0, -5), (0, 4)] { c.rect(lbx + dx * s, why + dy * s, s * (dx == 0 ? 3 : 1) + (dx == 0 ? 0 : s), s * (dy == 0 ? 3 : 1), C(0xD02A3A)) }
        // The counter: the glass front with the tubs inside, a red top edge, the panel below in navy and white.
        let cy0 = g - 13 * s
        c.rect(sc.x + 4 * s, cy0, sc.w - 8 * s, 2 * s, C(0xD02A3A))
        c.rect(sc.x + 4 * s, cy0 + 2 * s, sc.w - 8 * s, 5 * s, C(0xC8E4F0))
        for (k, x) in stride(from: sc.x + 7 * s, to: sc.x + sc.w - 10 * s, by: 7 * s).enumerated() {
            c.rect(x, cy0 + 4 * s, 5 * s, 3 * s, [C(0xF4D8E0), C(0x7A4A2A), C(0xF8F0D0), C(0x9AD8A8), C(0xE87A9A)][k % 5])
        }
        c.rect(sc.x + 4 * s, cy0 + 7 * s, sc.w - 8 * s, 6 * s, C(0x2A3A7A))
        for x in stride(from: sc.x + 6 * s, to: sc.x + sc.w - 6 * s, by: 8 * s) { c.rect(x, cy0 + 9 * s, 4 * s, 2 * s, C(0xF8F8F4)) }

        // The record shop: a purple fascia with stripes for its name, sleeves in the window and the doors.
        let rx = f.records, rtop = f.slab + 10 * s
        c.rect(rx - 30 * s, rtop, 64 * s, 7 * s, C(0x6A3A9A)); c.rect(rx - 30 * s, rtop, 64 * s, s, C(0x9A6ACA))
        for k in 0..<4 { c.rect(rx - 20 * s + k * 11 * s, rtop + 3 * s, 7 * s, 2 * s, C(0xF0D040)) }
        c.rect(rx - 30 * s, rtop + 7 * s, 64 * s, g - rtop - 7 * s, C(0x5A6A80)); c.rect(rx - 30 * s, rtop + 7 * s, 64 * s, 2 * s, C(0x7A8AA0))
        let sleeves = [C(0xE84A3A), C(0x3A8AD0), C(0xF0D040), C(0x2A2A2A), C(0xE87AB8), C(0x5AC07A)]
        for r in 0..<2 { for k in 0..<3 {
            let x = rx - 26 * s + k * 9 * s, y = rtop + (11 + r * 9) * s
            c.rect(x, y, 7 * s, 7 * s, sleeves[(k + r * 3) % 6]); c.circle(x + 3 * s, y + 3 * s, s, C(0x1A1A1A))
        } }
        c.rect(rx + 6 * s, rtop + 9 * s, 26 * s, g - rtop - 9 * s, C(0x4A5A68)); c.rect(rx + 19 * s, rtop + 9 * s, s, g - rtop - 9 * s, chrome)
        c.rect(rx - 30 * s, g - 3 * s, 64 * s, 3 * s, C(0x8A8088))

        // The neon strips along the fascias' undersides (lit in the moving layer).
        for (a, b) in [(cl - 30 * s, cl + 32 * s), (rx - 30 * s, rx + 34 * s)] { c.rect(a, f.slab + 17 * s, b - a, s, C(0x7A4A6A)) }

        // Palms in planters between the shops, white planters with a pink band.
        for px in [c.w * 18 / 100, c.w * 47 / 100 + 26 * s, c.w * 96 / 100] {
            c.rect(px - 6 * s, g - 9 * s, 12 * s, 9 * s, C(0xF0ECE8)); c.rect(px - 6 * s, g - 9 * s, 12 * s, s, C(0xFFFFFF))
            c.rect(px + 5 * s, g - 9 * s, s, 9 * s, C(0xC8C0BC)); c.rect(px - 6 * s, g - 6 * s, 12 * s, s, pink)
            c.rect(px, g - 26 * s, 2 * s, 17 * s, C(0x8A6A42)); for y in stride(from: g - 26 * s, to: g - 9 * s, by: 3 * s) { c.rect(px, y, 2 * s, s, C(0x6A4E30)) }
            for (k, a) in [-2.6, -2.0, -1.4, -0.9, -0.4].enumerated() {
                for d in 0..<12 {
                    let x = px + Int(cos(a) * Double(d * s)), y = g - 27 * s + Int(sin(a) * Double(d * s)) + d * d * s / 24
                    c.rect(x, y, 2 * s, s, k % 2 == 0 ? C(0x3A8A4A) : C(0x2E7040))
                }
            }
        }

        // The fountain: a round basin in white tile, its rim lit, the water in it, a fluted pedestal with its bowl and
        // a jet (drawn by the moving layer).
        let fx = f.fountain
        c.ellipse(fx, g - 5 * s, 34 * s, 4 * s, C(0xD8D4D0)); c.rect(fx - 34 * s, g - 5 * s, 69 * s, 5 * s, C(0xD8D4D0))
        c.ellipse(fx, g - 6 * s, 34 * s, 4 * s, C(0xF4F0EC)); c.ellipse(fx, g - 6 * s, 31 * s, 3 * s, C(0x5AAAC8))
        c.ellipse(fx, g - 6 * s, 24 * s, 2 * s, C(0x7AC4DC))
        c.rect(fx - 34 * s, g - 2 * s, 69 * s, s, C(0xB0A8A8))
        c.rect(fx - 3 * s, g - 20 * s, 6 * s, 14 * s, C(0xF0ECE8)); c.rect(fx - 3 * s, g - 20 * s, s, 14 * s, C(0xFFFFFF)); c.rect(fx + 2 * s, g - 20 * s, s, 14 * s, C(0xC8C0BC))
        c.ellipse(fx, g - 20 * s, 10 * s, 2 * s, C(0xF4F0EC)); c.ellipse(fx, g - 20 * s, 8 * s, s, C(0x5AAAC8))

        // The floor: warm grey tiles, plain, a lit edge where it meets the shops.
        c.ground(g, C(0x6A6470), edge: C(0x8A8490), speck: C(0x625C68), seed: 51)
    }

    /// Starcourt's life: the neon strips glowing pink and teal, the STARCOURT sign's letters lit and now and then
    /// stuttering, and the fountain's jet rising and falling with drops splashing back into the basin.
    static func hawkinsStarcourtLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsStarcourtFrame(c, g)
        // The sign: lit pink, unless it's stuttering.
        let text = "STARCOURT", p = 2 * s, tw = hawkinsP3SignWidth(text, p)
        let sx = f.sign.x - tw / 2, sy = f.sign.y + 3 * s
        let stutter = noise(Int(t * 10) + 40) < 0.12
        if !stutter {
            for (r, a) in [(4, 0.08)] { c.rect(sx - r * s, sy - r * s / 2, tw + 2 * r * s, 5 * p + r * s, C(0xFF6AB0, a)) }
            hawkinsP3Sign(c, sx, sy, text, C(0xFF9ACC), p)
        }
        // The neon strips under the fascias.
        let cl = f.clothes, rx = f.records
        for (a, b, col) in [(cl - 30 * s, cl + 32 * s, C(0x6AF0F0)), (rx - 30 * s, rx + 34 * s, C(0xFF7AC0))] {
            c.rect(a, f.slab + 16 * s, b - a, 3 * s, col.alpha(0.12)); c.rect(a, f.slab + 17 * s, b - a, s, col)
        }
        // On the screen saver, the pink neon ring round the half-round window.
        if isTall(c) {
            let a0 = hawkinsStarcourtArch(c, g), r = Double(a0.r + 7 * s), n = a0.r / s * 4
            for k in 0...n {
                let a = Double.pi * Double(k) / Double(n)
                c.rect(a0.x + Int(cos(a) * r) - s, a0.y - Int(sin(a) * r) - s, 3 * s, 3 * s, C(0xFF6AB0, 0.12))
                c.rect(a0.x + Int(cos(a) * r), a0.y - Int(sin(a) * r), s, s, C(0xFFA8D8))
            }
        }
        // The jet: a column of water rising, its top bobbing, drops falling back either side, sparkles on the basin.
        let fx = f.fountain, h = (12 + Int(2 * sin(t * 3.1))) * s, top = g - 20 * s - h
        c.rect(fx - s, top, 2 * s, h, C(0xD8F0FA, 0.85)); c.rect(fx - s, top, s, h, C(0xFFFFFF, 0.9))
        for k in 0..<10 {
            let ph = (t * 0.9 + Double(k) * 0.1).truncatingRemainder(dividingBy: 1.0)
            let side = k % 2 == 0 ? 1.0 : -1.0
            let x = fx + Int(side * ph * Double((6 + k % 3 * 2) * s)), y = top + Int((ph * ph * 2.2 - ph * 0.6) * Double(h))
            if y < g - 20 * s { c.rect(x, y, s, s, C(0xE8F8FF, 0.85)) }
        }
        for k in 0..<4 {
            let ph = (t * 0.7 + Double(k) * 0.25).truncatingRemainder(dividingBy: 1.0)
            let x = fx + Int((noise(k + Int(t * 0.7)) - 0.5) * Double(50 * s))
            if ph < 0.5 { c.rect(x, g - 6 * s, s, s, C(0xFFFFFF, 0.8)) }
        }
    }
}
