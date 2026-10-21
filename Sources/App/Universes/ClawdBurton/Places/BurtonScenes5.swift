import Foundation

// Sleepy Hollow's Tree of the Dead in the Western Woods; Mars Attacks!'s Perkinsville, Kansas, its Galaxy Hotel on the
// Las Vegas strip and the inside of a Martian saucer; and Charlie and the Chocolate Factory's Chocolate Room.

let burtonScenes5: [Location: Place] = [
    .treeOfTheDead: Place(name: "The Tree of the Dead", panel: 0x0C0E14, still: Scenes.treeOfTheDead,
                          moving: Scenes.treeOfTheDeadLife),
    .perkinsvilleKansas: Place(name: "Perkinsville, Kansas", panel: 0x3A2C12, still: Scenes.perkinsvilleKansas,
                               moving: Scenes.perkinsvilleKansasLife),
    .galaxyHotel: Place(name: "The Galaxy Hotel, Las Vegas", panel: 0x1A0A2C, still: Scenes.galaxyHotel,
                        moving: Scenes.galaxyHotelLife),
    .martianSaucerDeck: Place(name: "Inside the Martian Saucer", panel: 0x081A12, still: Scenes.martianSaucerDeck,
                              moving: Scenes.martianSaucerDeckLife),
    .chocolateRoom: Place(name: "The Chocolate Room", panel: 0x2A160A, still: Scenes.chocolateRoom,
                          moving: Scenes.chocolateRoomLife),
]

// MARK: - The Tree of the Dead

extension Scenes {
    private static let ttBlack = C(0x06070B), ttRim = C(0x283040), ttBark = C(0x11141B)

    /// Where the tree stands: its middle, the trunk's half-width and height, the hollow at its foot, and the moon.
    static func ttFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, half: Int, trunk: Int,
                                                        hollow: (x: Int, y: Int, rx: Int, ry: Int),
                                                        moon: (x: Int, y: Int, r: Int)) {
        let s = unit(g), tall = isTall(c), x = c.w * 54 / 100
        let half = (tall ? 20 : 12) * s, trunk = (tall ? 118 : 40) * s
        let hollow = (x, g - (tall ? 30 : 15) * s, (tall ? 6 : 4) * s, (tall ? 12 : 7) * s)
        let moon = tall ? (x - 96 * s, max(44 * s, g - 220 * s), 34 * s) : (x - 46 * s, 16 * s, 11 * s)
        return (x, half, trunk, hollow, moon)
    }

    /// The trunk's middle `k` of the way up: it twists as it rises.
    static func ttCentre(_ x: Int, _ half: Int, _ k: Double) -> Int {
        x + Int((sin(k * .pi * 1.5) * Double(half) * 0.45).rounded())
    }

    /// One gnarled limb and everything growing from it: a crooked stroke thinning as it goes, forking `depth` more
    /// times, each last twig hooked like a claw.
    static func ttLimb(_ c: PixelCanvas, _ x: Double, _ y: Double, angle: Double, len: Double, r: Double, depth: Int,
                       seed: Int, _ col: Px) {
        var p = (x: x, y: y), a = angle
        for k in 0..<3 {
            a = max(-200, min(20, a + (noise(seed * 7 + k) - 0.5) * 50))
            let q = burtonReach(p, a, len / 3)
            burtonLine(c, p.x, p.y, q.x, q.y, col, max(0.5, r * (1 - Double(k) * 0.15)))
            p = q
        }
        guard depth > 0 else {
            let q = burtonReach(p, a + (noise(seed + 5) > 0.5 ? 70 : -70), len * 0.3)
            burtonLine(c, p.x, p.y, q.x, q.y, col, 0.5)
            return
        }
        for (i, turn) in [-1.0, 1.0].enumerated() {
            let spread = 16 + noise(seed * 3 + i) * 28, l = len * (0.6 + noise(seed * 5 + i) * 0.2)
            ttLimb(c, p.x, p.y, angle: a + turn * spread, len: l, r: r * 0.62, depth: depth - 1, seed: seed * 2 + i + 1,
                   col)
        }
    }

    /// The roots, clawing out from the trunk's foot and curling down into the ground: each a list of points with the
    /// stroke's radius there.
    static func ttRoots(_ c: PixelCanvas, _ g: Int) -> [[(x: Double, y: Double, r: Double)]] {
        let s = Double(unit(g)), f = ttFrame(c, g), tall = isTall(c), n = tall ? 5 : 4
        let foot = Double(f.half) * 2.0
        var roots: [[(x: Double, y: Double, r: Double)]] = []
        for side in [-1.0, 1.0] {
            for j in 0..<n {
                let seed = j * 13 + (side > 0 ? 7 : 0), k = Double(j) / Double(n - 1)
                var p = (x: Double(f.x) + side * foot * (0.1 + 0.6 * k), y: Double(g) - s * (1 + Double(n - j) * 1.2))
                var a = -14 + 18 * k + (noise(seed + 400) - 0.5) * 16
                let len = Double(f.half) * (1.2 + 1.0 * k + noise(seed + 401) * 0.5)
                var r = s * (3.0 - 1.0 * k) * (tall ? 1.5 : 1)
                var pts = [(x: p.x, y: p.y, r: r)]
                for step in 0..<5 {
                    a += 8 + noise(seed + 402 + step) * 16
                    let q = burtonReach((0, 0), a, len / 5)
                    p = (p.x + side * q.x, p.y + q.y)
                    r = max(0.5, r * 0.78)
                    pts.append((p.x, p.y, r))
                }
                roots.append(pts)
            }
        }
        return roots
    }

    /// A drift of fog along row `y`: a soft band, thicker and thinner as it goes, denser in its middle.
    static func ttMist(_ c: PixelCanvas, y: Int, s: Int, seed: Int, alpha: Double = 0.1) {
        let ph = noise(seed) * 6
        for x in 0..<c.w {
            let u = Double(x) / Double(s)
            let th = Int((3 + 2 * sin(u * 0.045 + ph) + 1.2 * sin(u * 0.11 + ph * 2)) * Double(s))
            let mid = y + Int(sin(u * 0.03 + ph) * Double(2 * s))
            c.rect(x, mid - th, 1, th * 2, C(0x8A96AA, alpha * 0.5))
            c.rect(x, mid - th / 2, 1, th, C(0x8A96AA, alpha * 0.5))
        }
    }

    /// A bare tree of the misty woods: a trunk rising from row `base` and a few crooked limbs.
    static func ttFarTree(_ c: PixelCanvas, x: Int, base: Int, h: Int, r: Double, depth: Int, seed: Int, _ col: Px) {
        let top = (x: Double(x) + (noise(seed) - 0.5) * Double(h) * 0.15, y: Double(base - h))
        burtonLine(c, Double(x), Double(base), top.x, top.y, col, r)
        burtonLine(c, Double(x), Double(base), (top.x + Double(x)) / 2, Double(base - h / 2), col, r * 1.4)
        for k in 0..<3 {
            let a = -90 + (Double(k) - 1) * 48 + (noise(seed + k) - 0.5) * 30
            ttLimb(c, top.x, top.y + Double(h) * 0.12 * Double(k), angle: a, len: Double(h) * 0.34, r: r * 0.7,
                   depth: depth, seed: seed + k * 17, col)
        }
    }

    /// The Tree of the Dead in the Western Woods at night: a pale moon in the fog, bare trees fading back into the
    /// mist, and in front the great black tree, its trunk twisting up into gnarled limbs that claw at the dark, its
    /// black roots clawing at the earth over a red glow welling up round them, a dark hollow at its foot. On the
    /// screen saver the tree towers, its limbs reaching up and up.
    static func treeOfTheDead(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ttFrame(c, g)
        c.gradient(0, g, C(0x04060B), C(0x1E2634), bands: 12)
        // The moon behind the fog.
        let m = f.moon
        c.circle(m.x, m.y, m.r + 8 * s, C(0xA8B4C4, 0.05)); c.circle(m.x, m.y, m.r + 4 * s, C(0xA8B4C4, 0.08))
        c.circle(m.x, m.y, m.r, C(0x9CA6B4))
        c.circle(m.x - max(1, m.r / 12), m.y - max(1, m.r / 12), m.r - max(1, m.r / 10),
                                                     C(0xC4CCD6))
        c.circle(m.x + m.r / 3, m.y - m.r / 4, max(1, m.r / 5), C(0xA8B2BE))
        c.circle(m.x - m.r / 4, m.y + m.r / 3, max(1, m.r / 6), C(0xA8B2BE))
        ttMist(c, y: m.y + m.r / 2, s: s, seed: 30, alpha: 0.12)
        // Three rows of bare trees, fading back into the fog, mist between them.
        let layers: [(col: Px, gap: Int, r: Double)] = [(C(0x2C3442), 26, 0.7), (C(0x1B212B), 40, 1.1),
            (C(0x0F1218), 64, 1.6)]
        for (l, layer) in layers.enumerated() {
            ttMist(c, y: g - (tall ? 90 - l * 28 : 30 - l * 9) * s, s: s, seed: 60 + l * 50, alpha: 0.12)
            var x = Int(noise(l * 97) * Double(layer.gap)) * s, i = 0
            while x < c.w + 10 * s {
                let seed = 900 + l * 211 + i * 7
                if l < 2 || abs(x - f.x) > f.half * 4 {
                    let h = Int(Double(g) * (0.55 + noise(seed) * 0.4))
                    ttFarTree(c, x: x, base: g + s, h: h, r: layer.r * Double(s), depth: tall ? 3 : 2, seed: seed,
                        layer.col)
                }
                x += layer.gap * s + Int(noise(seed + 3) * Double(layer.gap * s)); i += 1
            }
        }
        ttMist(c, y: g - (tall ? 24 : 10) * s, s: s, seed: 200, alpha: 0.1)
        c.ground(g, C(0x262C36), edge: C(0x3E4656), speck: C(0x1C212A), seed: 501)
        // The limbs first, so the trunk's top covers where they join.
        let topY = Double(g - f.trunk), topX = Double(ttCentre(f.x, f.half, 1))
        let limbs: [(a: Double, l: Double)] = [(-168, 0.75), (-132, 1), (-100, 1.1), (-70, 1), (-38, 0.9), (-8, 0.7)]
        for (i, limb) in limbs.enumerated() {
            ttLimb(c, topX, topY + Double((i % 2) * 4 * s), angle: limb.a, len: Double(f.trunk) * 0.5 * limb.l,
                   r: Double(f.half) * 0.36, depth: tall ? 5 : 3, seed: 50 + i * 131, ttBlack)
        }
        for (i, side) in [-1.0, 1.0].enumerated() {   // two lower limbs, off the trunk's sides
            let k = 0.62, y = Double(g) - Double(f.trunk) * k, x = Double(ttCentre(f.x, f.half, k))
            ttLimb(c, x, y, angle: side > 0 ? -25 : -155, len: Double(f.trunk) * 0.42, r: Double(f.half) * 0.28,
                   depth: tall ? 4 : 2, seed: 700 + i * 77, ttBlack)
        }
        // The trunk: flaring at its foot, twisting as it rises, its bark twisting round it, its left edge moonlit.
        for r in 0..<f.trunk {
            let k = Double(r) / Double(f.trunk)
            let flare = Double(f.half) * 1.1 * pow(max(0, 1 - k * 4), 2)
            let half = Int((Double(f.half) * (1 - 0.5 * k) + flare).rounded()), cx = ttCentre(f.x, f.half, k)
            c.rect(cx - half, g - r - 1, half * 2 + 1, 1, ttBlack)
            c.rect(cx - half, g - r - 1, s, 1, ttRim)
            for j in 0..<3 {
                c.rect(cx + Int(sin(k * 9 + Double(j) * 2.1) * Double(half - s)), g - r - 1, s, 1, ttBark)
            }
        }
        // The red glow welling up round its foot, and the roots black against it.
        ttGlow(c, g, x: f.x, half: f.half, s: s, pulse: 0.5)
        ttRootStrokes(c, g)
        ttHollow(c, f.hollow, s: s, inner: C(0x3A0604))
    }

    /// The red light welling up out of the ground round the tree's foot, `pulse` 0…1 bright.
    static func ttGlow(_ c: PixelCanvas, _ g: Int, x: Int, half: Int, s: Int, pulse: Double) {
        let reach = half * 5, tall = isTall(c), f = (x: x, half: half)
        c.ellipse(f.x, g, reach, (tall ? 14 : 7) * s, C(0xC0180A, 0.10 + 0.08 * pulse))
        c.ellipse(f.x, g, reach * 3 / 4, (tall ? 9 : 5) * s, C(0xE0200C, 0.14 + 0.12 * pulse))
        c.ellipse(f.x, g + s, reach / 2, (tall ? 5 : 3) * s, C(0xFF4A1A, 0.2 + 0.25 * pulse))
    }

    /// The roots, black, their tops catching the moon.
    static func ttRootStrokes(_ c: PixelCanvas, _ g: Int) {
        for root in ttRoots(c, g) {
            for (p, q) in zip(root, root.dropFirst()) {
                burtonLine(c, p.x - 0.8, p.y - 1, q.x - 0.8, q.y - 1, ttRim, p.r)
            }
            for (p, q) in zip(root, root.dropFirst()) {
                burtonLine(c, p.x, p.y, q.x, q.y, ttBlack, p.r)
                c.circle(Int(p.x), Int(p.y), Int(p.r), ttBlack)
            }
        }
    }

    /// The hollow at the tree's foot: a tall, pointed black split in the trunk, something red deep inside.
    static func ttHollow(_ c: PixelCanvas, _ h: (x: Int, y: Int, rx: Int, ry: Int), s: Int, inner: Px) {
        c.ellipse(h.x, h.y + h.ry / 4, h.rx, h.ry * 3 / 4, C(0x010102))
        burtonTriangle(c, (Double(h.x - h.rx), Double(h.y + h.ry / 4)), (Double(h.x + h.rx + 1),
            Double(h.y + h.ry / 4)),
                       (Double(h.x + s), Double(h.y - h.ry)), C(0x010102))
        c.rect(h.x - h.rx, h.y + h.ry / 4, s, h.ry / 2, ttRim)
        c.ellipse(h.x, h.y + h.ry / 2, h.rx / 2, h.ry / 3, inner)
    }

    /// What moves at the tree: the red glow in its roots and hollow breathing, and bats leaving the hollow now and
    /// then, flapping off into the dark.
    static func treeOfTheDeadLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = ttFrame(c, g), h = f.hollow
        let pulse = 0.5 + 0.5 * sin(t * 2.1)
        c.ellipse(f.x, g, f.half * 4, (tall ? 8 : 5) * s, C(0xE0200C, 0.14 * pulse))
        c.ellipse(f.x, g + s, f.half * 5 / 2, (tall ? 5 : 3) * s, C(0xFF5A20, 0.3 * pulse))
        ttRootStrokes(c, g)
        ttHollow(c, h, s: s, inner: C(0x3A0604))
        c.ellipse(h.x, h.y + h.ry / 2, h.rx / 2, h.ry / 3, C(0xE02810, 0.3 + 0.4 * pulse))
        c.ellipse(h.x, h.y + h.ry / 2, max(s, h.rx / 4), max(s, h.ry / 6), C(0xFF7040, 0.4 * pulse))
        // Bats out of the hollow, each on its own loop.
        let k2 = tall ? 2 * s : s
        let up = ["K.....K", "KK.K.KK", ".KKKKK.", "...K..."], down = ["...K...", ".KKKKK.", "KK...KK", "K.....K"]
        for i in 0..<4 {
            let cycle = (t / 8 + Double(i) * 0.27).truncatingRemainder(dividingBy: 1)
            guard cycle < 0.55 else { continue }
            let q = cycle / 0.55, dir = i % 2 == 0 ? 1.0 : -1.0
            let bx = Double(h.x) + dir * q * Double(c.w) * (0.3 + 0.08 * Double(i))
                + sin(q * 9 + Double(i)) * Double(3 * s)
            let by = Double(h.y) - q * Double(h.y) * (0.75 + 0.1 * Double(i % 3)) + sin(q * 14) * Double(3 * s)
            let flap = Int(t * 10 + Double(i)) % 2 == 0
            let col = C(0x3A4254, min(1, q * 5))
            c.pattern(Int(bx) - 3 * k2, Int(by) - 2 * k2, bjScale(flap ? up : down, k2), ["K": col])
            c.rect(Int(bx) - k2, Int(by) + (flap ? 0 : -k2), k2, k2, C(0xFF3A18, min(1, q * 5)))
        }
    }
}

// MARK: - Shared signs

extension Scenes {
    /// Sign letters the shared set lacks.
    private static let pvGlyphs: [Character: [String]] = [
        "P": ["XX.", "X.X", "XX.", "X..", "X.."], "Y": ["X.X", "X.X", ".X.", ".X.", ".X."],
        "H": ["X.X", "X.X", "XXX", "X.X", "X.X"],
    ]

    /// `text` in the sign letters, with the few more these signs need; returns its width.
    @discardableResult
    static func pvText(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, _ col: Px) -> Int {
        var cx = x
        for ch in text {
            if let rows = pvGlyphs[ch] {
                for (r, row) in rows.enumerated() {
                    for (k, p) in row.enumerated() where p == "X" { c.rect(cx + k * s, y + r * s, s, s, col) }
                }
            } else {
                bjText(c, String(ch), x: cx, y: y, s: s, col)
            }
            cx += 4 * s
        }
        return cx - x - s
    }
}

// MARK: - Perkinsville, Kansas

extension Scenes {
    /// Where things stand: the doughnut shop's middle, half-width and height, the giant doughnut on its roof, and
    /// the horizon.
    static func pvFrame(_ c: PixelCanvas, _ g: Int) -> (shop: (x: Int, hw: Int, h: Int), ring: (x: Int, y: Int, r: Int),
                                                        horizon: Int) {
        let s = unit(g), tall = isTall(c)
        let x = c.w * 63 / 100, hw = (tall ? 34 : 24) * s, h = (tall ? 22 : 15) * s, r = (tall ? 20 : 14) * s
        return ((x, hw, h), (x, g - h - 3 * s - r, r), g - (tall ? 46 : 24) * s)
    }

    /// A trailer home on cinder blocks, its two-tone stripe, windows and door; standing on row `base`.
    static func pvTrailer(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, s: Int, body: Px, stripe: Px) {
        let block = C(0x8A8A86), shade = lerp(body, C(0x000000), 0.18)
        c.rect(x + 3 * s, base - 2 * s, 3 * s, 2 * s, block); c.rect(x + w - 6 * s, base - 2 * s, 3 * s, 2 * s, block)
        let y = base - 2 * s - h
        c.rect(x, y + s, w, h - s, body); c.rect(x + s, y, w - 2 * s, s, lerp(body, C(0xFFFFFF), 0.4))
        c.rect(x + w - 2 * s, y + s, 2 * s, h - s, shade); c.rect(x, y + h - s, w, s, shade)
        c.rect(x, y + h * 55 / 100, w, 2 * s, stripe)
        for wx in [x + 3 * s, x + 10 * s, x + w - 8 * s] {
            c.rect(wx, y + 2 * s, 4 * s, 3 * s, C(0x7AB8DA)); c.rect(wx, y + 2 * s, s, s, C(0xD8F0FF))
        }
        c.rect(x + w * 62 / 100, y + 2 * s, 4 * s, h - 3 * s, lerp(body, C(0x000000), 0.35))
        c.rect(x + w * 62 / 100 + 3 * s, y + h / 2, s, s, C(0xE8D070))
        c.rect(x + w / 4, y - 4 * s, s, 4 * s, C(0x6A6A70)); c.rect(x + w / 4 - 2 * s, y - 4 * s, 5 * s, s, C(0x6A6A70))
    }

    /// The giant doughnut standing on the shop's roof, seen face on: golden dough, pink icing with a dripping edge,
    /// sprinkles, the sky through its hole, and a ring of bulbs round it (dim; the moving layer lights them).
    static func pvDoughnut(_ c: PixelCanvas, _ f: (x: Int, y: Int, r: Int), s: Int) {
        let r = Double(f.r)
        for y in (f.y - f.r)...(f.y + f.r) {
            for x in (f.x - f.r)...(f.x + f.r) {
                let dx = Double(x - f.x) + 0.5, dy = Double(y - f.y) + 0.5, d = (dx * dx + dy * dy).squareRoot()
                guard d <= r, d > r * 0.38 else { continue }
                let a = atan2(dy, dx), lit = dx + dy < -r * 0.3
                let drip = r * (0.84 + 0.07 * sin(a * 7) + (sin(a * 7) > 0.6 ? 0.06 : 0))
                var col: Px
                if d > r * 0.5 && d < drip {
                    col = d < r * 0.66 && lit ? C(0xFFB4D2) : C(0xF27AAA)
                    let n = noise(x * 31 + y * 57)
                    if n > 0.88 { col = [C(0xFFFFFF), C(0x50C8F0), C(0xFFE040), C(0x6AD860)][Int(n * 1000) % 4] }
                } else {
                    col = dx + dy > r * 0.4 ? C(0xB4783A) : C(0xDDA45E)
                }
                c.px(x, y, col)
            }
        }
        let n = 16
        for i in 0..<n {
            let a = Double(i) / Double(n) * 2 * .pi
            let bx = f.x + Int((cos(a) * (r + Double(2 * s))).rounded()),
                by = f.y + Int((sin(a) * (r + Double(2 * s))).rounded())
            c.rect(bx, by, s, s, C(0x9A8450))
        }
    }

    /// The doughnut shop: a low cream building with big windows under a pink fascia that says DONUTS, the giant
    /// doughnut on two posts on its roof.
    static func pvShop(_ c: PixelCanvas, _ g: Int, _ f: (shop: (x: Int, hw: Int, h: Int), ring: (x: Int, y: Int,
        r: Int),
                                                         horizon: Int)) {
        let s = unit(g), sh = f.shop, top = g - sh.h
        for px in [sh.x - f.ring.r / 2, sh.x + f.ring.r / 2 - 2 * s] {
            c.rect(px, f.ring.y, 2 * s, top - f.ring.y, C(0x7A7A84))
            c.rect(px, f.ring.y, s, top - f.ring.y, C(0xA8A8B2))
        }
        pvDoughnut(c, f.ring, s: s)
        c.rect(sh.x - sh.hw, top, sh.hw * 2, sh.h, C(0xF6EEDA))
        c.rect(sh.x + sh.hw - 2 * s, top, 2 * s, sh.h, C(0xD8CCB0))
        c.rect(sh.x - sh.hw - 2 * s, top - 2 * s, sh.hw * 2 + 4 * s, 2 * s, C(0xC83A64))
        c.rect(sh.x - sh.hw, top, sh.hw * 2, 7 * s, C(0xE8507E))
        c.rect(sh.x - sh.hw, top + 7 * s, sh.hw * 2, s, C(0xB8305A))
        let word = "DONUTS", ww = bjTextWidth(word, s: s)
        bjText(c, word, x: sh.x - ww / 2, y: top + s, s: s, C(0xF8C4D6))
        let wy = top + 9 * s, wh = sh.h - 11 * s
        c.rect(sh.x - sh.hw + 3 * s, wy, sh.hw * 2 - 6 * s, wh, C(0x8CCFEA))
        for k in 0..<4 { c.rect(sh.x - sh.hw + 3 * s + k * (sh.hw * 2 - 6 * s) / 4, wy, s, wh, C(0xF6EEDA)) }
        c.rect(sh.x - 3 * s, wy, 6 * s, sh.h - 9 * s, C(0x4A7A98)); c.rect(sh.x + s, wy + wh / 2, s, s, C(0xE8D070))
        for k in 0..<3 { c.rect(sh.x - sh.hw + 6 * s + k * 3 * s, wy + k * s, s, max(s, wh - 3 * s), C(0xC8EAF8)) }
    }

    /// Perkinsville, Kansas, on a sunny day: a big blue sky with fair-weather clouds, wheat fields flat to the
    /// horizon with a grain elevator and a water tower far off, telephone poles across the fields, a trailer park on
    /// the left and the doughnut shop with its giant doughnut on the roof. On the screen saver the sky goes up and up
    /// (the moving layer fills it with Martian saucers) and a welcome sign stands out in the field.
    static func perkinsvilleKansas(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = pvFrame(c, g), hz = f.horizon
        c.gradient(0, hz, C(0x2C6CD0), C(0xB8DEF8), bands: 8)
        let clouds = tall ? 9 : 4
        for i in 0..<clouds {
            let y = tall ? Int(Double(hz) * (0.1 + 0.75 * noise(i + 70))) : (6 + Int(noise(i + 70) * 10)) * s
            cloud(c, Int(noise(i + 80) * Double(c.w)), y, (tall ? 5 : 3) * s + Int(noise(i + 90) * 3) * s, seed: i + 5)
        }
        // Far off on the horizon: a grain elevator and a water tower in the haze, a line of trees.
        for i in 0..<(c.w / (9 * s)) {
            let tx = i * 9 * s + Int(noise(i + 130) * Double(5 * s)), r = (2 + Int(noise(i + 140) * 2)) * s
            if noise(i + 150) > 0.4 { c.ellipse(tx, hz - r / 2, r + s, r, C(0x7A9A70)) }
        }
        let ex = c.w * 91 / 100, eh = (tall ? 30 : 18) * s
        for k in 0..<3 { c.rect(ex + k * 5 * s, hz - eh, 5 * s, eh, k == 2 ? C(0xA8B0BC) : C(0xC4CAD4)) }
        c.rect(ex + 3 * s, hz - eh - 6 * s, 9 * s, 6 * s, C(0xB4BCC8))
        c.rect(ex + 3 * s, hz - eh - 7 * s, 9 * s, s, C(0xD4DAE2))
        let wt = (x: c.w * 81 / 100, top: hz - (tall ? 34 : 20) * s, r: (tall ? 9 : 6) * s)
        for lx in [wt.x - wt.r + s, wt.x + wt.r - 2 * s] { c.rect(lx, wt.top + wt.r, s, hz - wt.top - wt.r,
            C(0x8A949E)) }
        c.rect(wt.x - wt.r, wt.top, wt.r * 2, wt.r * 3 / 2, C(0xE4EAF0))
        c.rect(wt.x + wt.r - 2 * s, wt.top, 2 * s, wt.r * 3 / 2, C(0xB8C2CC))
        c.ellipse(wt.x, wt.top, wt.r, max(s, wt.r / 3), C(0xC8D0D8))
        // The wheat fields, in bands that widen towards us.
        for y in hz..<g {
            let k = Double(y - hz) / Double(g - hz), band = Int((k.squareRoot() * 9).rounded(.down))
            c.rect(0, y, c.w, 1, band == 0 ? C(0xCBB66C) : band % 2 == 0 ? C(0xE8C24C) : C(0xDAAE3A))
        }
        for i in 0..<(c.w * (g - hz) / (14 * s * s)) {
            let x = Int(noise(i * 5 + 3) * Double(c.w)), y = hz + 2 * s + Int(noise(i * 5 + 4) * Double(g - hz - 2 * s))
            c.rect(x, y, s, s, noise(i * 5 + 5) > 0.5 ? C(0xF6DC7A) : C(0xB88A2A))
        }
        // Telephone poles across the fields, the wires sagging between them.
        let poleTop = hz - (tall ? 22 : 14) * s
        var prev: (Int, Int)?
        for i in 0..<12 {
            let x = c.w * 38 / 100 + i * (tall ? 46 : 40) * s
            guard x < c.w + 40 * s else { break }
            let base = hz + (tall ? 8 : 5) * s
            if abs(x - f.shop.x) > f.shop.hw + 4 * s {
                c.rect(x, poleTop, s, base - poleTop, C(0x6A5034))
                c.rect(x - 3 * s, poleTop + s, 7 * s, s, C(0x6A5034))
            }
            if let (px, py) = prev {
                for k in 0...20 {
                    let u = Double(k) / 20, wx = Double(px) + u * Double(x - px)
                    c.px(Int(wx), py + Int(sin(u * .pi) * Double(3 * s)), C(0x3A3436))
                }
            }
            prev = (x, poleTop + s)
        }
        // The trailer park, a picket fence along it, a couple of shade trees.
        let tw = (tall ? 44 : 30) * s, th = (tall ? 15 : 10) * s
        let bodies = [(C(0xF4F0E2), C(0x3AB8B0)), (C(0xD8F0E0), C(0xE8803A)), (C(0xF8E8B8), C(0x5A8AD8)),
            (C(0xF4F0E2), C(0xE85A6A))]
        let tx0 = c.w * 3 / 100
        for (i, b) in bodies.enumerated() {
            let x = tx0 + i * (tw + (tall ? 14 : 10) * s)
            guard x + tw < f.shop.x - f.shop.hw - 10 * s else { break }
            if i % 2 == 1 {
                c.ellipse(x - 5 * s, g - th - 6 * s, (tall ? 8 : 5) * s, (tall ? 7 : 5) * s, C(0x4A8A3A))
                c.ellipse(x - 6 * s, g - th - 7 * s, (tall ? 5 : 3) * s, (tall ? 4 : 3) * s, C(0x6AAA4A))
                c.rect(x - 5 * s, g - th - 2 * s, s, th + 2 * s, C(0x5A4028))
            }
            pvTrailer(c, x: x, base: g, w: tw, h: th, s: s, body: b.0, stripe: b.1)
        }
        for x in stride(from: 0, to: f.shop.x - f.shop.hw - 6 * s, by: 3 * s) {
            c.rect(x, g - 4 * s, s, 4 * s, C(0xF4F0E8))
        }
        c.rect(0, g - 3 * s, f.shop.x - f.shop.hw - 6 * s, s, C(0xDCD6CA))
        if tall {   // the welcome sign out in the field
            let word = "PERKINSVILLE", ww = bjTextWidth(word, s: s), bx = c.w * 74 / 100, by = hz + 2 * s
            for px in [bx + 4 * s, bx + ww - 2 * s] { c.rect(px, by + 9 * s, 2 * s, 8 * s, C(0x6A5034)) }
            c.rect(bx, by, ww + 6 * s, 10 * s, C(0xF6F2E6)); c.rect(bx, by + 9 * s, ww + 6 * s, s, C(0xC8C0AC))
            c.rect(bx, by, ww + 6 * s, s, C(0x3A6AC8))
            pvText(c, word, x: bx + 3 * s, y: by + 3 * s, s: s, C(0xD83A3A))
        }
        pvShop(c, g, f)
        c.ground(g, C(0xCDB088), edge: C(0xE6D2A8), speck: C(0xA88C62), seed: 611)
    }

    /// A Martian flying saucer, far off: a silver disc with a green glass dome and lights round its rim, `w` across.
    static func pvSaucer(_ c: PixelCanvas, _ x: Int, _ y: Int, w: Int, s: Int, blink: Int) {
        let ry = max(s, w / 8)
        c.ellipse(x, y + ry / 2, w / 2 - s, ry, C(0x6A7484))
        c.ellipse(x, y, w / 2, ry, C(0xB8C0CC)); c.ellipse(x - w / 10, y - ry / 3, w / 3, max(1, ry / 2), C(0xE4EAF0))
        c.ellipse(x, y - ry, w / 5, max(s, w / 7), C(0x8AE8B4))
        c.rect(x - w / 10, y - ry - w / 12, max(1, w / 12), max(1, w / 14), C(0xE0FFF0))
        let n = 5
        for k in 0..<n {
            let lx = x - w / 2 + s + k * (w - 2 * s) / (n - 1)
            c.rect(lx, y + ry / 2, s, s, (k + blink) % 2 == 0 ? C(0x7AFF9A) : C(0xFF5A4A))
        }
    }

    /// What moves in Perkinsville: the bulbs chasing round the giant doughnut, the DONUTS sign blinking, a tumbleweed
    /// rolling and bouncing across now and then; on the screen saver Martian saucers hang in the sky, bobbing.
    static func perkinsvilleKansasLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = pvFrame(c, g), r = Double(f.ring.r)
        let n = 16, step = Int(t * 6)
        for i in 0..<n where (i + step) % 3 == 0 {
            let a = Double(i) / Double(n) * 2 * .pi
            let bx = f.ring.x + Int((cos(a) * (r + Double(2 * s))).rounded())
            let by = f.ring.y + Int((sin(a) * (r + Double(2 * s))).rounded())
            c.rect(bx - s, by - s, 3 * s, 3 * s, C(0xFFF0A0, 0.25)); c.rect(bx, by, s, s, C(0xFFFAD0))
        }
        if t.truncatingRemainder(dividingBy: 2.4) < 1.6 {
            let word = "DONUTS", ww = bjTextWidth(word, s: s), top = g - f.shop.h
            c.rect(f.shop.x - ww / 2 - s, top, ww + 2 * s, 7 * s, C(0xFF8AB0, 0.35))
            bjText(c, word, x: f.shop.x - ww / 2, y: top + s, s: s, C(0xFFFFFF))
        }
        // The tumbleweed.
        let cycle = t.truncatingRemainder(dividingBy: 13) / 13
        if cycle < 0.6 {
            let q = cycle / 0.6, tr = Double((tall ? 6 : 4) * s)
            let x = -tr * 2 + q * (Double(c.w) + tr * 4), y = Double(g) - tr - abs(sin(q * .pi * 9)) * Double(5 * s)
            let spin = x / tr
            for k in 0..<5 {
                let a = spin + Double(k) * .pi / 5
                burtonLine(c, x - cos(a) * tr, y - sin(a) * tr, x + cos(a) * tr, y + sin(a) * tr,
                           k % 2 == 0 ? C(0xA8824C) : C(0x8A6634), 0.5)
            }
            for k in 0..<14 {
                let a = spin * 0.7 + Double(k) / 14 * 2 * .pi, rr = tr * (0.8 + 0.25 * sin(Double(k) * 2.3))
                c.rect(Int(x + cos(a) * rr), Int(y + sin(a) * rr), s, s, C(0xB8925A))
            }
        }
        guard tall else { return }
        // The saucers, far off over the fields.
        for i in 0..<14 {
            let w = (14 + Int(noise(i + 950) * 20)) * s
            let x = Int(noise(i + 960) * Double(c.w - 20 * s)) + 10 * s
            let y = 10 * s + Int(noise(i + 970) * Double(f.horizon - 80 * s))
                + Int(sin(t * 1.4 + Double(i)) * Double(s))
            pvSaucer(c, x, y, w: w, s: s, blink: Int(t * 3) + i)
        }
    }
}

// MARK: - The Galaxy Hotel

extension Scenes {
    /// Where the Galaxy's rocket tower stands: its middle and half-width, the roof of the casino it rises from, where
    /// its nose cone starts, its tip, and the casino's half-width.
    static func gxFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, hw: Int, base: Int, nose: Int, tip: Int, pw: Int) {
        let s = unit(g), tall = isTall(c), x = c.w * 55 / 100, hw = (tall ? 15 : 8) * s
        let base = g - (tall ? 24 : 12) * s, tip = tall ? max(10 * s, g - 262 * s) : 2 * s
        return (x, hw, base, tip + (base - tip) * 33 / 100, tip, hw * 5)
    }

    /// A neon colour as drawn: dim in the still picture (`t` nil), lit by the moving layer, which cuts each tube out
    /// for a moment now and then (nil: not drawn this frame).
    static func gxNeon(_ col: Px, _ t: Double?, id: Int) -> Px? {
        guard let t else { return lerp(col, C(0x180A2C), 0.55) }
        return noise(Int(t * 7) * 31 + id * 7) < 0.05 ? nil : col
    }

    /// The Galaxy's orbit ring round the rocket, the half behind it (`front` false) or in front.
    static func gxRing(_ c: PixelCanvas, _ f: (x: Int, hw: Int, base: Int, nose: Int, tip: Int, pw: Int), s: Int,
                       front: Bool, _ col: Px, skipBody: Bool = false) {
        let cy = f.nose + (f.base - f.nose) * 28 / 100, rx = f.hw * 27 / 10, ry = max(2 * s, f.hw * 45 / 100)
        let n = rx * 8
        for i in 0..<n {
            let a = Double(i) / Double(n) * 2 * .pi
            guard (sin(a) >= 0) == front else { continue }
            let x = f.x + Int((cos(a) * Double(rx)).rounded()), y = cy + Int((sin(a) * Double(ry)).rounded())
            if skipBody, abs(x - f.x) <= f.hw { continue }
            c.rect(x, y, s, s + s / 2, col)
        }
    }

    /// The bulbs up the rocket's sides, bottom first: where each is.
    static func gxBulbs(_ f: (x: Int, hw: Int, base: Int, nose: Int, tip: Int, pw: Int), s: Int) -> [(x: Int,
        y: Int, i: Int)] {
        var out: [(x: Int, y: Int, i: Int)] = []
        var i = 0
        for y in stride(from: f.base - 2 * s, to: f.nose, by: -3 * s) {
            out.append((f.x - f.hw + s, y, i)); out.append((f.x + f.hw - 2 * s, y, i)); i += 1
        }
        return out
    }

    /// One casino or hotel of the strip: a block with rows of lit windows, neon along its roof and one corner, and on
    /// some a rooftop sign or an atomic starburst; with a clock `t`, only its neon, lit.
    static func gxBuilding(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, near: Bool, seed: Int, s: Int,
        t: Double?) {
        let neon = [C(0xFF3AC8), C(0x30F0FF), C(0xFFC830), C(0xA070FF)]
        let col = neon[Int(noise(seed + 5) * 4) % 4], top = base - h
        if t == nil {
            c.rect(x, top, w, h, near ? C(0x24133C) : C(0x170C2C))
            c.rect(x, top, s, h, near ? C(0x3A2458) : C(0x24163E))
            for wy in stride(from: top + 3 * s, to: base - 2 * s, by: 3 * s) {
                for wx in stride(from: x + 2 * s, to: x + w - 2 * s, by: 3 * s) {
                    let lit = noise(seed * 13 + wx * 7 + wy * 3) > (near ? 0.5 : 0.6)
                    c.rect(wx, wy, s, s, lit ? (noise(wx + wy * 5) > 0.3 ? C(0xFFD27A) : C(0xE8E0FF)) : C(0x2E1C48))
                }
            }
        }
        if let k = gxNeon(col, t, id: seed) {
            c.rect(x, top, w, s, k); c.rect(x + w - s, top, s, h * 2 / 3, k)
        }
        guard near else { return }
        if noise(seed + 6) > 0.45 {
            let words = ["CASINO", "MOTEL", "SLOTS", "BINGO", "COMET", "LOUNGE"]
            let word = words[Int(noise(seed + 7) * 60) % words.count], ww = bjTextWidth(word, s: s)
            let bx = x + w / 2 - ww / 2 - 2 * s, by = top - 9 * s
            if t == nil {
                c.rect(x + w / 2 - s, by + 8 * s, 2 * s, s, C(0x4A3A5A))
                c.rect(bx, by, ww + 4 * s, 8 * s, C(0x10061E))
            }
            let wc = neon[(Int(noise(seed + 5) * 4) + 1) % 4]
            if let k = gxNeon(wc, t, id: seed + 1) { bjText(c, word, x: bx + 2 * s, y: by + 2 * s - s / 2, s: s, k) }
            if let k = gxNeon(col, t, id: seed + 2) {
                c.rect(bx, by, ww + 4 * s, s, k); c.rect(bx, by + 7 * s, ww + 4 * s, s, k)
            }
        } else if noise(seed + 8) > 0.4 {
            let sx = x + w * 3 / 4, sy = top - 10 * s, r = 5 * s
            if t == nil { c.rect(sx, sy, s, 10 * s, C(0x4A3A5A)) }
            if let k = gxNeon(C(0xFFC830), t, id: seed + 3) {
                for a in 0..<8 {
                    let ang = Double(a) / 8 * 2 * .pi + 0.2
                    let ex = Double(sx) + cos(ang) * Double(r), ey = Double(sy) + sin(ang) * Double(r)
                    burtonLine(c, Double(sx), Double(sy), ex, ey, k, 0.5)
                    c.rect(Int(ex), Int(ey), s, s, k)
                }
            }
        }
    }

    /// The strip either side of the Galaxy, a far row of towers and a near row of casinos, with palm trees; with a
    /// clock `t`, only their neon, lit.
    static func gxStrip(_ c: PixelCanvas, _ g: Int, t: Double?) {
        let s = unit(g), tall = isTall(c), f = gxFrame(c, g)
        for row in 0..<2 {
            var x = -8 * s + row * 13 * s, i = 0
            while x < c.w {
                let seed = 2000 + row * 300 + i * 9
                let w = (row == 0 ? 20 : 18) * s + Int(noise(seed) * 16) * s
                let lo = row == 0 ? (tall ? 70 : 28) : (tall ? 34 : 15),
                    span = row == 0 ? (tall ? 110 : 18) : (tall ? 40 : 9)
                let h = lo * s + Int(noise(seed + 1) * Double(span)) * s
                if row == 0 || abs(x + w / 2 - f.x) > f.pw + w / 2 + 4 * s {
                    gxBuilding(c, x: x, base: g, w: w, h: h, near: row == 1, seed: seed, s: s, t: t)
                }
                x += w + (row == 0 ? 3 + Int(noise(seed + 2) * 6) : 10 + Int(noise(seed + 2) * 16)) * s; i += 1
            }
            if row == 0 && t == nil {   // palms between the rows
                for p in 0..<(c.w / (34 * s)) {
                    let px = p * 34 * s + Int(noise(p + 2500) * Double(12 * s)), ph = (tall ? 30 : 16) * s
                    guard abs(px - f.x) > f.pw + 4 * s else { continue }
                    burtonLine(c, Double(px), Double(g), Double(px + 2 * s), Double(g - ph), C(0x10081C),
                        Double(s) * 0.6)
                    for a in [-160.0, -125, -55, -20] {
                        let e = burtonReach((Double(px + 2 * s), Double(g - ph)), a, Double((tall ? 10 : 6) * s))
                        burtonLine(c, Double(px + 2 * s), Double(g - ph), e.x, e.y + Double(2 * s), C(0x10081C),
                            Double(s) * 0.7)
                    }
                }
            }
        }
    }

    /// The Galaxy itself: a silver rocket standing on its fins on the casino's roof, magenta nose cone and stripes, a
    /// spire with a gold star on top, portholes and rows of lit rooms up its body, a cyan orbit ring round it, bulbs up
    /// its sides; the casino under it, its marquee saying GALAXY.
    static func gxTower(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = gxFrame(c, g)
        let ringDim = lerp(C(0x30F0FF), C(0x180A2C), 0.55)
        gxRing(c, f, s: s, front: false, ringDim)
        // The side fins, swept back down onto the roof.
        let finH = (f.base - f.nose) * 30 / 100, finW = f.hw * 11 / 10
        for side in [-1.0, 1.0] {
            let bx = Double(f.x) + side * Double(f.hw)
            burtonTriangle(c, (bx, Double(f.base - finH)), (bx + side * Double(finW), Double(f.base)), (bx,
                Double(f.base)),
                           side < 0 ? C(0xE8389C) : C(0xA81A72))
            burtonTriangle(c, (bx, Double(f.base - finH)), (bx + side * Double(finW) * 0.4, Double(f.base - finH / 2)),
                           (bx, Double(f.base - finH / 2)), side < 0 ? C(0xFF70C8) : C(0xC82A88))
        }
        // The body, lit from the left.
        for x in (f.x - f.hw)..<(f.x + f.hw) {
            let u = Double(x - (f.x - f.hw)) / Double(f.hw * 2)
            let col = u < 0.15 ? C(0xFFFFFF) : u < 0.6 ? C(0xE4E6F2) : u < 0.9 ? C(0xB0B4CC) : C(0x8A8EAA)
            c.rect(x, f.nose, 1, f.base - f.nose, col)
        }
        for y in [f.nose + 2 * s, f.base - 7 * s] {
            c.rect(f.x - f.hw, y, f.hw * 2, 2 * s, C(0xE0309A))
            c.rect(f.x + f.hw * 6 / 10, y, f.hw * 4 / 10, 2 * s, C(0xA01870))
        }
        // Rows of rooms, and portholes down the middle.
        for y in stride(from: f.nose + 6 * s, to: f.base - 9 * s, by: (tall ? 4 : 3) * s) {
            for x in stride(from: f.x - f.hw + 3 * s, to: f.x + f.hw - 3 * s, by: (tall ? 4 : 3) * s)
                where abs(x - f.x) > (tall ? 5 : 2) * s {
                let lit = noise(x * 7 + y * 13) > 0.35
                c.rect(x, y, s, s, lit ? C(0xFFC85A) : C(0x9A9CB8))
            }
        }
        let pr = (tall ? 4 : 2) * s
        for y in stride(from: f.nose + 8 * s, to: f.base - 10 * s, by: (tall ? 18 : 9) * s) {
            c.circle(f.x, y, pr + s, C(0x8A8EAA))
            c.circle(f.x, y, pr, C(0x1A8AA8)); c.rect(f.x - pr / 2, y - pr / 2, s, s, C(0xB0F8FF))
        }
        // The nose cone and the spire.
        let spire = f.tip + (f.base - f.tip) * 9 / 100
        for y in spire..<f.nose {
            let u = Double(f.nose - y) / Double(f.nose - spire), half = Int(Double(f.hw) * pow(1 - u, 0.55))
            c.rect(f.x - half, y, half * 2, 1, C(0xE0309A))
            c.rect(f.x - half, y, max(s, half / 3), 1, C(0xFF78C8))
            c.rect(f.x + half * 6 / 10, y, half * 4 / 10, 1, C(0xA01870))
        }
        c.rect(f.x - s / 2 - (s == 1 ? 0 : 0), f.tip + 2 * s, s, spire - f.tip, C(0xC8CCE0))
        c.pattern(f.x - 2 * s, f.tip - s, bjScale(["..Y..", ".YYY.", "YYYYY", ".YYY.", "..Y.."], s), ["Y": C(0xFFD040)])
        // The front fin.
        c.rect(f.x - s, f.base - finH * 8 / 10, 2 * s, finH * 8 / 10, C(0xC8288A))
        for b in gxBulbs(f, s: s) { c.rect(b.x, b.y, s, s, C(0x7A5A2A)) }
        gxRing(c, f, s: s, front: true, ringDim)
        // The casino it stands on, and its marquee.
        let ph = g - f.base
        c.rect(f.x - f.pw, f.base, f.pw * 2, ph, C(0x2A1648)); c.rect(f.x - f.pw, f.base, f.pw * 2, s, C(0x8A6A2A))
        for x in stride(from: f.x - f.pw + 3 * s, to: f.x + f.pw - 2 * s, by: 4 * s) {
            c.rect(x, f.base + 3 * s, 2 * s, ph - 4 * s, C(0x4A2A6A))
        }
        let ls = tall ? 2 * s : s, word = "GALAXY", ww = 6 * 4 * ls - ls
        let bw = ww + 6 * ls, bh = 9 * ls, bx = f.x - bw / 2, by = f.base + (ph - bh) / 2
        c.rect(bx, by, bw, bh, C(0x10061E))
        pvText(c, word, x: bx + 3 * ls, y: by + 2 * ls, s: ls, lerp(C(0xFFC830), C(0x180A2C), 0.45))
        for b in gxMarquee(bx, by, bw, bh, s: s) { c.rect(b.x, b.y, s, s, C(0x7A5A2A)) }
    }

    /// The bulbs round the GALAXY marquee, in order round its border.
    static func gxMarquee(_ x: Int, _ y: Int, _ w: Int, _ h: Int, s: Int) -> [(x: Int, y: Int)] {
        var out: [(x: Int, y: Int)] = []
        for bx in stride(from: x + s, to: x + w - s, by: 2 * s) { out.append((bx, y + s)) }
        for by in stride(from: y + 3 * s, to: y + h - s, by: 2 * s) { out.append((x + w - 2 * s, by)) }
        for bx in stride(from: x + w - 2 * s, to: x, by: -2 * s) { out.append((bx, y + h - 2 * s)) }
        for by in stride(from: y + h - 4 * s, to: y + s, by: -2 * s) { out.append((x + s, by)) }
        return out
    }

    /// The Galaxy Hotel on the Las Vegas strip at night: a violet sky over the desert's mountains, a far row of
    /// lit towers, palms, a near row of casinos with neon signs and starbursts, and in the middle the Galaxy's rocket
    /// tower on its casino. On the screen saver the strip climbs high and the desert night opens over it, the lights of
    /// the city glittering away to the mountains.
    static func galaxyHotel(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        let hz = g - (tall ? 150 : 30) * s
        c.gradient(0, hz, C(0x05031A), C(0x4A1A62), bands: 8)
        c.stars(0, hz - (tall ? 30 : 6) * s, density: tall ? 70 : 110, seed: 47)
        if tall {
            let m = (x: c.w * 18 / 100, y: g * 18 / 100, r: 12 * s)
            c.circle(m.x, m.y, m.r + 4 * s, C(0xFFE0F0, 0.08)); c.circle(m.x, m.y, m.r, C(0xF4E4F0))
            c.circle(m.x + m.r / 3, m.y - m.r / 5, m.r, C(0x05031A, 0))
        }
        c.dunes(base: hz, amp: Double((tall ? 10 : 4) * s), freq: 0.025, phase: 1.2, bottom: g, C(0x2A1244))
        c.dunes(base: hz + (tall ? 8 : 3) * s, amp: Double((tall ? 5 : 2) * s), freq: 0.06, phase: 0.3, bottom: g,
                C(0x1E0C34))
        if tall {   // the city's lights glittering out across the desert floor
            for i in 0..<(c.w * 3 / s) {
                let x = Int(noise(i * 3 + 7000) * Double(c.w)), y = hz + 12 * s + Int(pow(noise(i * 3 + 7001),
                    0.6) * Double(60 * s))
                let k = noise(i * 3 + 7002)
                c.rect(x, y, s, s, k > 0.8 ? C(0xFF6AD0) : k > 0.55 ? C(0x7AF0FF) : C(0xFFD27A))
            }
        }
        gxStrip(c, g, t: nil)
        gxTower(c, g)
        c.ground(g, C(0x1C1228), edge: C(0x5A3A7A), speck: C(0x2A1C3A), seed: 733)
        for x in stride(from: 4 * s, to: c.w, by: 16 * s) { c.rect(x, g + (c.h - g) / 2, 7 * s, s, C(0xC8A040)) }
    }

    /// What moves on the strip: the neon tubes and signs flickering, the bulbs chasing up the rocket's sides and round
    /// the GALAXY marquee, its orbit ring glowing; on the screen saver two searchlights sweep the sky.
    static func galaxyHotelLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = gxFrame(c, g)
        if tall {
            for (i, bx) in [c.w * 30 / 100, c.w * 78 / 100].enumerated() {
                let a = -90 + sin(t * 0.35 + Double(i) * 2.2) * 30, len = Double(g)
                let e1 = burtonReach((Double(bx), Double(g - 40 * s)), a - 3, len)
                let e2 = burtonReach((Double(bx), Double(g - 40 * s)), a + 3, len)
                burtonTriangle(c, (Double(bx), Double(g - 40 * s)), e1, e2, C(0xD8ECFF, 0.07))
            }
        }
        gxStrip(c, g, t: t)
        if let k = gxNeon(C(0x30F0FF), t, id: 5) { gxRing(c, f, s: s, front: false, k, skipBody: true); gxRing(c, f,
            s: s, front: true, k) }
        let step = Int(t * 12)
        for b in gxBulbs(f, s: s) where ((b.i - step) % 5 + 5) % 5 == 0 {
            c.rect(b.x - s, b.y - s, 3 * s, 3 * s, C(0xFFF0A0, 0.3)); c.rect(b.x, b.y, s, s, C(0xFFF8D0))
        }
        let ph = g - f.base, ls = tall ? 2 * s : s, ww = 6 * 4 * ls - ls
        let bw = ww + 6 * ls, bh = 9 * ls, bx = f.x - bw / 2, by = f.base + (ph - bh) / 2
        if let k = gxNeon(C(0xFFC830), t, id: 9) { pvText(c, "GALAXY", x: bx + 3 * ls, y: by + 2 * ls, s: ls, k) }
        for (i, b) in gxMarquee(bx, by, bw, bh, s: s).enumerated() where (i + step) % 3 == 0 {
            c.rect(b.x, b.y, s, s, C(0xFFF8D0))
        }
    }
}

// MARK: - Inside the Martian saucer

extension Scenes {
    /// Where things are on the deck: the porthole, the top of the straight wall (the ceiling in the strip, the dome's
    /// foot when tall), the brain jars' middles and the console's span.
    static func sdFrame(_ c: PixelCanvas, _ g: Int) -> (port: (x: Int, y: Int, r: Int), wall: Int, jars: [Int],
                                                        jar: (w: Int, h: Int), desk: (x0: Int, x1: Int)) {
        let s = unit(g), tall = isTall(c)
        let wall = tall ? g - 100 * s : 0
        let port = (c.w / 2, tall ? g - 62 * s : 26 * s, (tall ? 24 : 15) * s)
        let jars = [17, 28, 72, 83].map { c.w * $0 / 100 }
        return (port, wall, jars, ((tall ? 16 : 12) * s, (tall ? 30 : 22) * s), (c.w * 37 / 100, c.w * 63 / 100))
    }

    /// The lights on the console and the wall cabinets: where each is, its colour, its id.
    static func sdLights(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, col: Px, id: Int)] {
        let s = unit(g), tall = isTall(c), f = sdFrame(c, g)
        let cols = [C(0x6AFF9A), C(0x6AFF9A), C(0xF0E060), C(0xFF5A50), C(0x6AFFE0)]
        var out: [(x: Int, y: Int, col: Px, id: Int)] = []
        var id = 0
        let top = g - (tall ? 22 : 16) * s
        for row in 0..<2 {
            for x in stride(from: f.desk.x0 + 4 * s + row * s, to: f.desk.x1 - 4 * s, by: 4 * s) {
                let mid = (f.desk.x0 + f.desk.x1) / 2
                if abs(x - mid) < (tall ? 10 : 7) * s { continue }
                out.append((x, top + 2 * s + row * 3 * s, cols[Int(noise(id + 3100) * 5) % 5], id)); id += 1
            }
        }
        for cx in [c.w * 5 / 100, c.w * 95 / 100] {
            for row in 0..<3 {
                for k in 0..<3 {
                    out.append((cx - 5 * s + k * 4 * s, g - (tall ? 22 : 14) * s + row * 3 * s,
                                cols[Int(noise(id + 3100) * 5) % 5], id)); id += 1
                }
            }
        }
        return out
    }

    /// A chrome rib up the wall from row `y0` to the floor.
    static func sdRib(_ c: PixelCanvas, x: Int, y0: Int, g: Int, s: Int) {
        c.rect(x, y0, 5 * s, g - y0, C(0x8AA49A)); c.rect(x, y0, s, g - y0, C(0xD8ECE2))
        c.rect(x + 4 * s, y0, s, g - y0, C(0x4A625A))
        for y in stride(from: y0 + 4 * s, to: g, by: 10 * s) { c.rect(x + 2 * s, y, s, s, C(0x3A4E46)) }
    }

    /// The Earth through the glass: blue seas, green land, white cloud, its night side in shadow.
    static func sdEarth(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int) {
        for py in (y - r)...(y + r) {
            for px in (x - r)...(x + r) {
                let dx = Double(px - x) + 0.5, dy = Double(py - y) + 0.5, d = (dx * dx + dy * dy).squareRoot()
                guard d <= Double(r) else { continue }
                let u = dx / Double(r), v = dy / Double(r)
                let land = sin(u * 3.1 + 0.7) * cos(v * 2.7 - 0.4) + 0.45 * sin(u * 6.3 + v * 4.1 + 1) > 0.42
                let cloud = sin(u * 4 + v * 1.5 + 2) * sin(v * 8 + u) > 0.72
                var col = cloud ? C(0xF4F8FF) : land ? C(0x4AA84A) : C(0x2A6ED8)
                if u * 0.7 + v * 0.5 > 0.45 { col = lerp(col, C(0x061030), 0.65) }
                else if d > Double(r) * 0.85 { col = lerp(col, C(0x9ADCFF), 0.35) }
                c.px(px, py, col)
            }
        }
    }

    /// A brain in its jar: a chrome pedestal and lid, the glass full of green liquid, the pink brain floating in it.
    static func sdJar(_ c: PixelCanvas, x: Int, g: Int, w: Int, h: Int, s: Int) {
        let foot = g - 5 * s, top = foot - h
        c.rect(x - w / 2 - 2 * s, foot, w + 4 * s, 5 * s, C(0x4A5E56))
        c.rect(x - w / 2 - 2 * s, foot, w + 4 * s, s, C(0xA8C2B8))
        c.rect(x - w / 2 + 2 * s, foot + 2 * s, w - 4 * s, s, C(0x6AFF9A))
        c.rect(x - w / 2, top, w, h, C(0x3ACB7A, 0.35)); c.rect(x - w / 2, top, w, 3 * s, C(0x9AFFC8, 0.25))
        let bw = w / 2 - 2 * s, bh = h * 26 / 100, by = top + h * 55 / 100
        c.ellipse(x, by, bw, bh, C(0xE68AA6)); c.ellipse(x - s, by - s, bw - s, bh - s, C(0xF4A8BE))
        for k in 0..<3 {
            let fy = by - bh / 2 + k * bh / 2
            for fx in stride(from: x - bw + 2 * s, to: x + bw - s, by: 2 * s) {
                c.rect(fx, fy + ((fx / (2 * s)) % 2) * s, s, s, C(0xC8607E))
            }
        }
        c.rect(x - bw / 2, by - bh + s, 2 * s, s, C(0xFFD8E4))
        c.rect(x - s, by + bh, 2 * s, foot - by - bh, C(0xC8607E))
        c.rect(x - w / 2, top, s, h, C(0xD8FFE8, 0.55)); c.rect(x + w / 2 - s, top, s, h, C(0xD8FFE8, 0.3))
        c.rect(x - w / 2 + 2 * s, top + 3 * s, s, h / 2, C(0xFFFFFF, 0.35))
        c.rect(x - w / 2 - s, top - 3 * s, w + 2 * s, 3 * s, C(0x98B0A8))
        c.rect(x - w / 2 - s, top - 3 * s, w + 2 * s, s, C(0xD8ECE2))
        c.rect(x - 2 * s, top - 5 * s, 4 * s, 2 * s, C(0x6A847A))
    }

    /// Inside the Martian saucer: a green-lit wall ribbed in chrome, a round porthole full of stars, the big glowing
    /// console under it with its radar screens and rows of lights, cabinets of lights at the ends, and the Martians'
    /// brains floating in jars of green liquid. On the screen saver the saucer's dome arches over it all, its ribs
    /// meeting at the top, and through the great window in it the Earth.
    static func martianSaucerDeck(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = sdFrame(c, g)
        c.gradient(f.wall, g, C(0x05120C), C(0x103826), bands: 6)
        for y in stride(from: f.wall + 12 * s, to: g, by: 14 * s) { c.rect(0, y, c.w, s, C(0x0A2418)) }
        if tall {
            // The dome: ribs from its crown down to the wall, the great window at the top with the Earth in it.
            c.rect(0, 0, c.w, f.wall, C(0x020805))
            let cx = c.w / 2, rx = c.w * 62 / 100, ry = f.wall
            for y in 0..<f.wall {
                let k = 1 - pow(Double(f.wall - y) / Double(ry), 2)
                guard k > 0 else { continue }
                let half = Int(Double(rx) * k.squareRoot())
                c.rect(cx - half, y, half * 2, 1, lerp(C(0x05120C), C(0x0C2C1E), Double(y) / Double(f.wall)))
            }
            let win = (x: cx, y: f.wall * 40 / 100, r: min(f.wall * 34 / 100, c.w * 22 / 100))
            // Ribs out from the window's rim, every way, to the dome's edge or the wall's top.
            for k in 0..<16 {
                let a = Double(k) / 16 * 2 * .pi + 0.2
                let from = burtonReach((Double(win.x), Double(win.y)), a * 180 / .pi, Double(win.r + 4 * s))
                var to = from
                while true {
                    let n = burtonReach(to, a * 180 / .pi, Double(s))
                    let ex = (n.x - Double(cx)) / Double(rx), ey = (n.y - Double(f.wall)) / Double(ry)
                    if ex * ex + ey * ey > 1 || n.y >= Double(f.wall - 3 * s) || n.y < 0 { break }
                    to = n
                }
                burtonLine(c, from.x, from.y, to.x, to.y, C(0x3E5A50), Double(2 * s))
                burtonLine(c, from.x - Double(s), from.y - Double(s), to.x - Double(s), to.y - Double(s),
                    C(0x7A9A8E), Double(s) * 0.6)
            }
            // The dome's rim, a band of green light round it.
            for y in 0..<f.wall {
                let k = 1 - pow(Double(f.wall - y) / Double(ry), 2)
                guard k > 0 else { continue }
                let half = Int(Double(rx) * k.squareRoot())
                c.rect(cx - half, y, 2 * s, 1, C(0x6AFF9A, 0.5))
                c.rect(cx + half - 2 * s, y, 2 * s, 1, C(0x6AFF9A, 0.5))
            }
            c.circle(win.x, win.y, win.r + 5 * s, C(0x5A7A6E)); c.circle(win.x, win.y, win.r + 3 * s, C(0xA8C8BC))
            c.circle(win.x, win.y, win.r, C(0x01030A))
            c.stars(win.y - win.r, win.y + win.r, density: 30, seed: 88, x0: win.x - win.r, x1: win.x + win.r) { x, y in
                (x - win.x) * (x - win.x) + (y - win.y) * (y - win.y) < (win.r - s) * (win.r - s)
            }
            sdEarth(c, win.x - win.r / 5, win.y + win.r / 6, win.r * 55 / 100)
            c.rect(0, f.wall - 3 * s, c.w, 4 * s, C(0x8AA49A)); c.rect(0, f.wall - 3 * s, c.w, s, C(0xD8ECE2))
            c.rect(0, f.wall + s, c.w, s, C(0x6AFF9A, 0.6))
        } else {
            c.rect(0, 0, c.w, 4 * s, C(0x7A948A))
            c.rect(0, 3 * s, c.w, s, C(0x4A625A)); c.rect(0, s, c.w, s, C(0xC8DCD2))
            c.rect(0, 4 * s, c.w, s, C(0x6AFF9A, 0.55)); c.rect(0, 5 * s, c.w, 2 * s, C(0x6AFF9A, 0.12))
        }
        // Chrome ribs, clear of the porthole.
        for k in 0..<9 {
            let x = c.w * (k * 2 + 1) / 18 - 2 * s
            guard abs(x + 2 * s - f.port.x) > f.port.r + 8 * s else { continue }
            sdRib(c, x: x, y0: f.wall + (tall ? s : 4 * s), g: g, s: s)
        }
        // The porthole.
        let p = f.port
        c.circle(p.x, p.y, p.r + 4 * s, C(0x4A625A)); c.circle(p.x, p.y, p.r + 3 * s, C(0x8AA49A))
        c.circle(p.x - s, p.y - s, p.r + s, C(0xD8ECE2)); c.circle(p.x, p.y, p.r + s, C(0x8AA49A))
        c.circle(p.x, p.y, p.r, C(0x01040A))
        c.stars(p.y - p.r, p.y + p.r, density: 18, seed: 61, x0: p.x - p.r, x1: p.x + p.r) { x, y in
            (x - p.x) * (x - p.x) + (y - p.y) * (y - p.y) < (p.r - s) * (p.r - s)
        }
        for k in 0..<8 {
            let a = Double(k) / 8 * 2 * .pi
            c.rect(p.x + Int(cos(a) * Double(p.r + 2 * s)), p.y + Int(sin(a) * Double(p.r + 2 * s)), s, s, C(0x2A3A34))
        }
        for k in 0..<(p.r / 2) { c.rect(p.x - p.r / 2 + k, p.y - p.r / 3 - k, s, s, C(0xFFFFFF, 0.3)) }
        // The cabinets at the ends of the wall.
        for cx in [c.w * 5 / 100, c.w * 95 / 100] {
            let ch = (tall ? 46 : 34) * s, cw = 16 * s
            c.rect(cx - cw / 2, g - ch, cw, ch, C(0x1E2E28)); c.rect(cx - cw / 2, g - ch, cw, s, C(0xA8C2B8))
            c.rect(cx - cw / 2, g - ch, s, ch, C(0x4A5E56))
            c.rect(cx - 6 * s, g - ch + 3 * s, 12 * s, (tall ? 16 : 11) * s, C(0x0A3A1E))
            c.rect(cx - 6 * s, g - ch + 3 * s, 12 * s, s, C(0x2A6A44))
        }
        // The console: a slanted panel of lights over a chrome-edged desk, radar screens in the middle.
        let d = f.desk, dh = (tall ? 22 : 16) * s, top = g - dh
        c.rect(d.x0, top + 7 * s, d.x1 - d.x0, dh - 7 * s, C(0x22322C))
        for r in 0..<(7 * s) {
            let inset = (7 * s - r) / 2
            c.rect(d.x0 + inset, top + r, d.x1 - d.x0 - inset * 2, 1, r < s ? C(0xA8C2B8) : C(0x14603A))
        }
        c.rect(d.x0, top + 7 * s, d.x1 - d.x0, s, C(0xD8ECE2)); c.rect(d.x0, top + 8 * s, d.x1 - d.x0, s, C(0x6A847A))
        for x in stride(from: d.x0 + 6 * s, to: d.x1 - 4 * s, by: 12 * s) { c.rect(x, top + 10 * s, 6 * s, 2 * s,
            C(0x1A7A44)) }
        for l in sdLights(c, g) { c.rect(l.x, l.y, 2 * s, s, lerp(l.col, C(0x05120C), 0.6)) }
        let mid = (d.x0 + d.x1) / 2, rr = (tall ? 8 : 5) * s
        c.circle(mid, top + 2 * s, rr + s, C(0x6A847A)); c.circle(mid, top + 2 * s, rr, C(0x04240F))
        c.rect(mid - rr, top + 2 * s, rr * 2, s / 2 + (s == 1 ? 1 : 0), C(0x1A7A44))
        c.rect(mid, top + 2 * s - rr, s, rr * 2, C(0x1A7A44))
        // The brains in their jars.
        for x in f.jars { sdJar(c, x: x, g: g, w: f.jar.w, h: f.jar.h, s: s) }
        // The deck: dark metal plates, a glowing green strip along its edge.
        c.ground(g, C(0x14221C), edge: C(0x6AFF9A), speck: C(0x0C1612), seed: 811)
        for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, g + s, s, c.h - g, C(0x0C1612)) }
    }

    /// What moves in the saucer: the console's lights blinking, the radar sweeping, the cabinets' screens tracing a
    /// wave, and bubbles rising through the brains' jars.
    static func martianSaucerDeckLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = sdFrame(c, g)
        for l in sdLights(c, g) where noise(Int(t * 3) * 97 + l.id) > 0.45 {
            c.rect(l.x - s, l.y - s, 4 * s, 3 * s, l.col.alpha(0.2)); c.rect(l.x, l.y, 2 * s, s, l.col)
        }
        let d = f.desk, top = g - (tall ? 22 : 16) * s, mid = (d.x0 + d.x1) / 2, rr = Double((tall ? 8 : 5) * s)
        let a = t * 2.5
        burtonLine(c, Double(mid), Double(top + 2 * s), Double(mid) + cos(a) * rr, Double(top + 2 * s) + sin(a) * rr,
                   C(0x9AFFB8), 0.5)
        if noise(Int(t * 1.5) + 4000) > 0.4 { c.rect(mid + 2 * s, top, s, s, C(0xFF5A50)) }
        for cx in [c.w * 5 / 100, c.w * 95 / 100] {
            let ch = (tall ? 46 : 34) * s, sh = (tall ? 16 : 11) * s, y0 = g - ch + 3 * s + sh / 2
            for k in 0..<(12 * s) {
                let y = y0 + Int(sin(Double(k) * 0.9 / Double(s) + t * 4 + Double(cx)) * Double(sh / 3))
                c.rect(cx - 6 * s + k, y, 1, s, C(0x7AFFA8))
            }
        }
        for (j, x) in f.jars.enumerated() {
            let foot = g - 5 * s, h = f.jar.h
            for i in 0..<5 {
                let k = (t * 0.45 + noise(j * 10 + i + 4100)).truncatingRemainder(dividingBy: 1)
                let bx = x - f.jar.w / 2 + 2 * s + Int(noise(j * 10 + i + 4200) * Double(f.jar.w - 5 * s))
                    + Int(sin(t * 3 + Double(i)) * Double(s))
                let by = foot - s - Int(k * Double(h - 4 * s))
                c.rect(bx, by, s, s, C(0xD8FFE8, 0.8))
                if tall { c.rect(bx + s, by - s, s, s, C(0xD8FFE8, 0.4)) }
            }
            let bh = h * 26 / 100, by = foot - h + h * 55 / 100
            c.ellipse(x, by, f.jar.w / 2 - s, bh + s, C(0xFF9ABA, 0.08 + 0.08 * sin(t * 2 + Double(j))))
        }
    }
}

// MARK: - The Chocolate Room

extension Scenes {
    /// Where the waterfall falls (its middle, width and top) and the river's banks.
    static func chFrame(_ c: PixelCanvas, _ g: Int) -> (fall: (x: Int, w: Int, top: Int), river: (top: Int,
        bottom: Int),
                                                        roof: Int) {
        let s = unit(g), tall = isTall(c)
        let roof = tall ? max(16 * s, g * 11 / 100) : 0
        let fall = (c.w * 22 / 100, (tall ? 24 : 14) * s, tall ? roof + 4 * s : 0)
        return (fall, (g - (tall ? 30 : 13) * s, g - (tall ? 6 : 3) * s), roof)
    }

    /// How far the waterfall reaches either side of its middle on row `y`: it spreads as it falls.
    static func chFallHalf(_ fl: (x: Int, w: Int, top: Int), _ bottom: Int, _ y: Int) -> Int {
        fl.w / 2 + (y - fl.top) * fl.w / 3 / max(1, bottom - fl.top)
    }

    /// A candy tree on row `base`: a striped candy-stick trunk and a round, fluffy crown in a sweet colour.
    static func chTree(_ c: PixelCanvas, x: Int, base: Int, h: Int, r: Int, s: Int, crown: (Px, Px, Px)) {
        for y in (base - h)..<base {
            for k in 0..<(3 * s) {
                c.px(x - s + k, y, ((y + k) / (2 * s)) % 2 == 0 ? C(0xE83A4A) : C(0xFFF4F0))
            }
        }
        let cy = base - h - r / 2
        c.circle(x - r / 2, cy + r / 3, r * 2 / 3, crown.2); c.circle(x + r / 2, cy + r / 3, r * 2 / 3, crown.2)
        c.circle(x, cy, r, crown.1); c.circle(x - r / 3, cy - r / 3, r / 2, crown.0)
        c.circle(x - r / 2, cy + r / 4, r / 2, crown.1); c.circle(x + r / 2 - s, cy + r / 4, r / 2, crown.1)
        c.rect(x - r / 2, cy - r / 2, max(s, r / 4), max(s, r / 4), C(0xFFFFFF, 0.7))
    }

    /// A giant lollipop on row `base`: a white stick and a spiral disc.
    static func chLollipop(_ c: PixelCanvas, x: Int, base: Int, h: Int, r: Int, s: Int, _ a: Px, _ b: Px,
        turn: Double) {
        c.rect(x - s, base - h, 2 * s, h, C(0xF4F0EA)); c.rect(x, base - h, s, h, C(0xC8C2BA))
        c.circle(x, base - h - r + s, r + s, lerp(a, C(0x000000), 0.25))
        burtonSpiralDisc(c, Double(x) + 0.5, Double(base - h - r + s), r: Double(r), a, b, turn: turn)
        c.rect(x - r / 2, base - h - r * 3 / 2 + s, max(s, r / 4), max(s, r / 4), C(0xFFFFFF, 0.8))
    }

    /// A big spotted mushroom on row `base`: a cream stem under a domed cap.
    static func chMushroom(_ c: PixelCanvas, x: Int, base: Int, r: Int, s: Int, cap: Px) {
        c.rect(x - r / 3, base - r, r * 2 / 3, r, C(0xFFF0D8)); c.rect(x + r / 3 - s, base - r, s, r, C(0xE0CCAA))
        for y in 0..<(r * 2 / 3) {
            let half = Int(Double(r) * (1 - pow(Double(y) / Double(r * 2 / 3), 2)).squareRoot())
            c.rect(x - half, base - r - y, half * 2 + 1, 1, y == 0 ? lerp(cap, C(0x000000), 0.25) : cap)
        }
        for (dx, dy) in [(-r / 2, r / 4), (r / 6, r / 2), (r / 2, r / 5), (-r / 6, r / 6)] {
            c.rect(x + dx, base - r - dy, max(s, r / 5), max(s, r / 5), C(0xFFFFFF))
        }
    }

    /// A tuft of sugar grass on row `base`.
    static func chTuft(_ c: PixelCanvas, x: Int, base: Int, s: Int) {
        for (dx, h) in [(-2, 3), (0, 5), (2, 4)] {
            c.rect(x + dx * s, base - h * s, s, h * s, C(0x7AE84A)); c.rect(x + dx * s, base - h * s, s, s, C(0xC8FF8A))
        }
    }

    /// The Chocolate Room: a warm, candy-pink cavern, mint and green hills of sugar grass under it, the caramel cliff
    /// with the chocolate waterfall pouring down it into the chocolate river, candy trees, giant lollipops and spotted
    /// mushrooms along the far bank, and sugar grass in front. On the screen saver the cavern's roof hangs over it all,
    /// candy stalactites dripping from it.
    static func chocolateRoom(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = chFrame(c, g), rv = f.river
        c.gradient(f.roof, g, C(0xF6B8D2), C(0xFDEACC), bands: 7)
        if tall {
            // The roof, its edge sagging and dripping, and the stalactites of candy hanging from it.
            func edge(_ x: Int) -> Int {
                let u = Double(x / s)
                return f.roof + Int((sin(u * 0.05 + 0.9) * 0.6 + sin(u * 0.13) * 0.4 + 1) * Double(5 * s))
            }
            for x in 0..<c.w {
                c.rect(x, 0, 1, edge(x), C(0x5A2C1A))
                c.rect(x, edge(x) - 2 * s, 1, 2 * s, C(0x7A4428))
                if Int(noise(x / s + 5200) * 9) == 0 { c.rect(x, edge(x), s, 2 * s, C(0x7A4428)) }
            }
            for k in 0..<(f.roof / (9 * s)) {
                c.rect(Int(noise(k + 5210) * Double(c.w)), Int(noise(k + 5220) * Double(f.roof - 4 * s)), 6 * s, s,
                    C(0x6A3820))
            }
            var x = 2 * s, i = 0
            let stripes = [(C(0xFF7AB8), C(0xFFF4F8)), (C(0x7AE8C8), C(0xFFFFFF)), (C(0xFFD040), C(0xFF7A3A)),
                           (C(0xB89AFF), C(0xFFF4F8))]
            while x < c.w {
                let w = (8 + Int(noise(i + 5100) * 10)) * s, len = (20 + Int(noise(i + 5110) * 46)) * s
                let st = stripes[i % stripes.count], y0 = edge(x + w / 2) - s
                for r in 0..<len {
                    let half = Double(w) / 2 * pow(1 - Double(r) / Double(len), 0.8)
                    let col = ((r + Int(half)) / (4 * s)) % 2 == 0 ? st.0 : st.1
                    c.rect(x + w / 2 - Int(half), y0 + r, max(s, Int(half * 2)), 1, col)
                    c.rect(x + w / 2 - Int(half), y0 + r, s, 1, lerp(col, C(0xFFFFFF), 0.4))
                }
                c.rect(x + w / 2, y0 + len, s, 2 * s, st.0)
                x += w + Int(noise(i + 5120) * 8) * s; i += 1
            }
        }
        // The hills of sugar grass, far then near.
        let far = rv.top - (tall ? 70 : 22) * s, farAmp = Double((tall ? 12 : 4) * s)
        c.dunes(base: far, amp: farAmp, freq: 0.03, phase: 0.5, bottom: g, C(0x9AE89A))
        if tall {   // little candy trees far off along the hilltops
            for i in 0..<(c.w / (22 * s)) {
                let x = i * 22 * s + Int(noise(i + 5600) * Double(10 * s))
                let top = far - Int((sin(Double(x) * 0.03 + 0.5) * 0.6 + sin(Double(x) * 0.069 + 0.85) * 0.4) * farAmp)
                let pale = [(C(0xFFE0F0), C(0xFFB8DC), C(0xF09AC8)), (C(0xE0FFF0), C(0xB0F0D8), C(0x8AD8B8)),
                            (C(0xFFF6D0), C(0xFFE8A0), C(0xF0D080))][i % 3]
                chTree(c, x: x, base: top + 2 * s, h: (8 + Int(noise(i + 5610) * 6)) * s, r: 5 * s, s: s, crown: pale)
            }
        }
        c.dunes(base: rv.top - (tall ? 26 : 9) * s, amp: Double((tall ? 6 : 3) * s), freq: 0.05, phase: 2.0, bottom: g,
                C(0x5ACC48), shade: C(0x9AF070))
        // The cliff, a heap of caramel boulders, and its waterfall.
        let fl = f.fall, hh = rv.top - fl.top, flat = fl.w / 2 + 4 * s, slope = fl.w + (tall ? 34 : 14) * s
        let cl = fl.x - flat - slope, cr = fl.x + flat + slope
        for y in fl.top..<rv.top {
            let half = flat + (y - fl.top) * slope * 8 / (hh * 10)
            c.rect(fl.x - half, y, half * 2, 1, C(0xB87050))
        }
        var rocks: [(x: Int, y: Int, r: Int)] = []
        for (k, side) in [-1, 1].enumerated() {
            let r = fl.w / 2 + 2 * s
            rocks.append((fl.x + side * (fl.w / 2 + r * 2 / 3), fl.top + r / 3, r + k * s))
        }
        for i in 0..<(tall ? 44 : 16) {
            let v = noise(i + 5300), y = fl.top + Int(v * Double(hh))
            let half = Double(flat) + v * Double(slope) * 0.8
            let x = fl.x + Int((noise(i + 5310) - 0.5) * 2 * half)
            rocks.append((x, y, max(3 * s, min(fl.w * (5 + 4 * Int(v * 2)) / 8,
                Int((0.22 + 0.18 * noise(i + 5320)) * Double(hh) * (0.35 + 0.4 * v))))))
        }
        for b in rocks.sorted(by: { $0.y < $1.y }) {
            c.ellipse(b.x, b.y, b.r, b.r * 4 / 5, C(0xA05E40))
            c.ellipse(b.x - b.r / 6, b.y - b.r / 6, b.r * 4 / 5, b.r * 3 / 5, C(0xD08C64))
            c.rect(b.x - b.r / 2, b.y - b.r / 2, max(s, b.r / 3), max(s, b.r / 5), C(0xF0BC90))
        }
        // The chocolate pouring down past the rocks in a smooth sheet, spreading as it falls.
        for y in fl.top..<(rv.top + 2 * s) {
            let half = chFallHalf(fl, rv.top, y), w = half * 2
            c.rect(fl.x - half, y, w, 1, C(0x74401E))
            c.rect(fl.x - half + w / 8, y, w / 4, 1, C(0x8E5228))
            c.rect(fl.x - half + w / 6, y, max(s, w / 12), 1, C(0xB27A48))
            c.rect(fl.x + half - w / 6, y, w / 6, 1, C(0x5E3216))
        }
        // Candy trees, lollipops and mushrooms along the far bank.
        let crowns = [(C(0xFFC8E4), C(0xFF8AC8), C(0xE060A0)), (C(0xC8FFE8), C(0x7AE8C0), C(0x40B890)),
                      (C(0xFFF0A0), C(0xFFD050), C(0xE0A030)), (C(0xE8D8FF), C(0xB89AFF), C(0x8A6AE0))]
        let bank = rv.top + s
        let items: [(Int, Int)] = [(4, 0), (9, 2), (35, 1), (41, 0), (47, 3), (53, 2), (59, 1), (66, 0), (72, 3),
                                   (78, 2), (84, 0), (90, 1), (96, 3)]
        for (i, item) in items.enumerated() {
            let x = c.w * item.0 / 100
            guard x < cl - 6 * s || x > cr + 6 * s else { continue }
            let jig = Int(noise(i + 5400) * 6) * s
            switch item.1 {
            case 0: chTree(c, x: x, base: bank - jig / 3, h: (tall ? 34 : 14) * s + jig, r: (tall ? 14 : 7) * s, s: s,
                           crown: crowns[i % crowns.count])
            case 1: chLollipop(c, x: x, base: bank, h: (tall ? 30 : 12) * s + jig, r: (tall ? 12 : 7) * s, s: s,
                               [C(0xFF4A9A), C(0x4AC8FF), C(0xFFB020)][i % 3], C(0xFFF6FA), turn: noise(i + 5410))
            case 2: chMushroom(c, x: x, base: bank, r: (tall ? 14 : 8) * s, s: s,
                               cap: [C(0xE83A4A), C(0xFF8AC8), C(0x8AD8FF)][i % 3])
            default: chTree(c, x: x, base: bank, h: (tall ? 22 : 9) * s + jig, r: (tall ? 10 : 6) * s, s: s,
                            crown: crowns[(i + 1) % crowns.count])
            }
        }
        // The river: chocolate, glossy on top.
        for x in 0..<c.w {
            let top = rv.top + Int((sin(Double(x) * 0.08) * 0.5 + 0.5) * Double(s))
            c.rect(x, top, 1, rv.bottom - top, C(0x6A3A1A))
            c.rect(x, top, 1, s, C(0x9A6034))
            c.rect(x, rv.bottom - s, 1, s, C(0x4A2610))
        }
        let foam = chFallHalf(fl, rv.top, rv.top) + 4 * s
        c.ellipse(fl.x, rv.top + s, foam, 3 * s, C(0xD8B48A))
        for k in 0..<5 {
            let fx = fl.x - foam + s + k * (foam * 2 - 2 * s) / 4, r = (k % 2 == 0 ? 3 : 4) * s
            c.ellipse(fx, rv.top - s, r + s, r, C(0xF2DEC4)); c.rect(fx - r / 2, rv.top - r, r / 2 + s, s, C(0xFFFFFF))
        }
        // The near bank of sugar grass.
        c.ground(g, C(0x4AC838), edge: C(0x9AF070), speck: C(0x38A028), seed: 911)
        c.rect(0, rv.bottom, c.w, g - rv.bottom, C(0x5ACC48))
        for i in 0..<(c.w / (7 * s)) {
            chTuft(c, x: i * 7 * s + Int(noise(i + 5500) * Double(4 * s)),
                base: g + s + Int(noise(i + 5510) * 3) * s, s: s)
        }
        for (i, x) in [c.w * 2 / 100, c.w * 97 / 100].enumerated() {
            chMushroom(c, x: x, base: g + 2 * s, r: (tall ? 10 : 6) * s, s: s, cap: i == 0 ? C(0xFF8AC8) : C(0xE83A4A))
        }
    }

    /// What moves in the Chocolate Room: the waterfall's streaks pouring down and churning into foam where it meets
    /// the river, and the river's gloss flowing along.
    static func chocolateRoomLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = chFrame(c, g), fl = f.fall, rv = f.river
        let fh = rv.top - fl.top
        let lanes = 5
        for i in 0..<lanes {
            let u = (Double(i) + 0.5) / Double(lanes)
            for j in 0..<2 {
                let k = (t * 0.9 + noise(i * 2 + j + 6000)).truncatingRemainder(dividingBy: 1)
                let len = (4 + Int(noise(i + 6100) * 6)) * s, y = fl.top + Int(k * Double(fh + len)) - len
                let y0 = max(fl.top + s, y), y1 = min(rv.top, y + len)
                guard y1 > y0 else { continue }
                for yy in y0..<y1 {
                    let half = chFallHalf(fl, rv.top, yy)
                    c.rect(fl.x - half + Int(u * Double(half * 2)), yy, s, 1,
                        (i + j) % 2 == 0 ? C(0xC08A56) : C(0x9A5E30))
                }
            }
        }
        for i in 0..<7 {
            let ph = t * 5 + Double(i) * 1.7
            let bh = chFallHalf(fl, rv.top, rv.top), fx = fl.x - bh - 2 * s + i * (bh * 2 + 4 * s) / 6,
                r = Int(2 + 1.5 * sin(ph)) * s
            c.ellipse(fx, rv.top - Int(abs(sin(ph * 0.7)) * Double(2 * s)), r + s, max(s, r),
                i % 2 == 0 ? C(0xE8C8A0) : C(0xB07A48))
        }
        for row in 0..<3 {
            let y = rv.top + 2 * s + row * (rv.bottom - rv.top - 3 * s) / 3
            let gap = 38 * s + row * 9 * s, speed = 10.0 * Double(s) * (1 + Double(row) * 0.4)
            var x = Int((t * speed).truncatingRemainder(dividingBy: Double(gap))) - gap + row * 11 * s
            while x < c.w {
                c.rect(x, y, (5 + row * 2) * s, s, C(0x9A6034))
                x += gap
            }
        }
    }
}
