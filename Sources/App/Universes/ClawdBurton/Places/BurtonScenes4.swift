import Foundation

// Places: Saturn's dunes, the pastel cul-de-sac, the Inventor's castle, the village of the living, Sleepy Hollow.
// From Beetlejuice the sand dunes of Saturn, where the Sandwurm swims; from Edward Scissorhands the candy-coloured
// suburb and the Inventor's gothic castle on the hill above it; from Corpse Bride the grey Victorian village of the
// living; and Sleepy Hollow's misty Dutch village.

let burtonScenes4: [Location: Place] = [
    .sandwormSaturn: Place(name: "Saturn's Sand Dunes", panel: 0x221A2E, still: Scenes.sandwormSaturn,
                           moving: Scenes.sandwormSaturnLife),
    .pastelSuburbia: Place(name: "The Pastel Cul-de-sac", panel: 0x1E2E3A, still: Scenes.pastelSuburbia,
                           moving: Scenes.pastelSuburbiaLife),
    .inventorsCastle: Place(name: "The Inventor's Castle", panel: 0x14101A, still: Scenes.inventorsCastle,
                            moving: Scenes.inventorsCastleLife),
    .everglotVillage: Place(name: "The Village of the Living", panel: 0x161A22, still: Scenes.everglotVillage,
                            moving: Scenes.everglotVillageLife),
    .hollowVillage: Place(name: "Sleepy Hollow", panel: 0x1C1A16, still: Scenes.hollowVillage,
                          moving: Scenes.hollowVillageLife),
]

// MARK: - Saturn's sand dunes

extension Scenes {
    private static let saSand = C(0xEED28C), saSandLit = C(0xFAE6AE), saSandDark = C(0xC8A860)

    /// Saturn's layout: the near dune the Sandwurm swims under (its base row and swell), the size unit, and the
    /// rings' middle and radii.
    static func saFrame(_ c: PixelCanvas, _ g: Int) -> (dune: Int, amp: Double, k: Int,
                                                       rings: (x: Int, y: Int, rx: Int, ry: Int)) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        let rings = tall ? (c.w * 46 / 100, g + g / 5, c.w, g + g / 5 - 8 * s)
                         : (c.w * 40 / 100, g + 40 * s, c.w * 70 / 100, g + 36 * s)
        return (g - 6 * k, 3 * Double(k), k, rings)
    }

    /// The near dune's top at column x: the same wave `dunes` draws for it.
    static func saDuneTop(_ x: Int, base: Int, amp: Double) -> Int {
        let a = sin(Double(x) * 0.03 + 0.8) * 0.6 + sin(Double(x) * 0.069 + 1.36) * 0.4
        return base - Int(a * amp)
    }

    /// Saturn's rings seen from its surface: an arch of pale bands across the sky, tilted a little, with dark gaps
    /// between them. `bands` are (from, to, colour, opacity) in rows in from the outer edge.
    private static func saRings(_ c: PixelCanvas, _ g: Int, _ r: (x: Int, y: Int, rx: Int, ry: Int),
                                bands: [(Int, Int, UInt32, Double)]) {
        let tilt = 0.05
        func edge(_ x: Int, _ o: Int) -> Int? {
            let rx = Double(r.rx) - Double(o) * Double(r.rx) / Double(r.ry), ry = Double(r.ry - o)
            let d = Double(x - r.x) / rx
            guard abs(d) < 1 else { return nil }
            return r.y - Int((1 - d * d).squareRoot() * ry) + Int(Double(x - r.x) * tilt)
        }
        for x in 0..<c.w {
            for (o0, o1, col, a) in bands {
                guard let top = edge(x, o0) else { continue }
                let bottom = min(g, edge(x, o1) ?? g)
                if bottom > top { c.rect(x, top, 1, bottom - top, C(col, a)) }
            }
        }
    }

    /// A black rock spire standing on row `base`: jagged sides tapering to a point or a knob, leaning a little, its
    /// left side catching the sky's light.
    private static func saSpire(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, lean: Int, s: Int, seed: Int) {
        let rock = C(0x16121E), lit = C(0x4A3E62)
        for r in 0..<h {
            let k = Double(r) / Double(h)
            let jag = Int((noise(seed * 31 + r / (3 * s)) - 0.5) * Double(3 * s))
            let half = max(s, Int(Double(w) / 2 * (1 - pow(k, 2.2))) + jag)
            let cx = x + Int(Double(lean) * k * k)
            c.rect(cx - half, base - r - 1, half * 2, 1, rock); c.rect(cx - half, base - r - 1, s, 1, lit)
        }
        if seed % 2 == 0 {   // a knob balanced on the tip
            let tx = x + lean, ty = base - h
            c.ellipse(tx, ty, w / 3 + s, w / 5 + s, rock); c.rect(tx - w / 3 - s, ty - s, s, 2 * s, lit)
        }
    }

    /// Saturn's sand dunes, from Beetlejuice: pale yellow-ochre dunes rolling away under a strange sky going from
    /// purple to teal, the planet's rings arched across it and two little moons; black rock spires standing out of
    /// the sand, some with a knob of rock on top. On the screen saver the rings fill the whole sky, more spires stand
    /// on the far dunes and the dunes roll on for miles.
    static func sandwormSaturn(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = saFrame(c, g), k = f.k
        c.gradient(0, g, C(0x24164A), C(0x3E9C9A), bands: 8)
        c.stars(0, g / 2, density: 140, seed: 501)
        let o = tall ? 3 * s : s
        saRings(c, g, f.rings, bands: [(0, 3 * o, 0xF8ECC8, 0.7), (3 * o, 5 * o, 0xE0B878, 0.55),
                                       (6 * o, 11 * o, 0xF4E4B8, 0.6), (11 * o, 12 * o, 0xC0A8E8, 0.3),
                                       (13 * o, 17 * o, 0xD0B8EC, 0.4), (17 * o, (tall ? 26 : 19) * o, 0xE0D0F0, 0.12)])
        // Two little moons.
        let m1 = tall ? (c.w * 82 / 100, g * 44 / 100, 12 * s) : (c.w * 86 / 100, 32 * s, 5 * s)
        c.circle(m1.0, m1.1, m1.2 + 2 * s, C(0xE8B070, 0.15)); c.circle(m1.0, m1.1, m1.2, C(0xD8A060))
        c.circle(m1.0 - m1.2 / 4, m1.1 - m1.2 / 4, m1.2 * 3 / 4, C(0xF0C080))
        let m2 = tall ? (c.w * 14 / 100, g * 52 / 100, 6 * s) : (c.w * 62 / 100, 40 * s, 2 * s)
        c.circle(m2.0, m2.1, m2.2, C(0xB8B4D0))
        c.circle(m2.0 - m2.2 / 3, m2.1 - m2.2 / 3, max(1, m2.2 / 2), C(0xE0DCF0))
        if tall {
            // Far dunes rolling away, hazy with the teal of the sky, and far spires along them.
            c.dunes(base: g - 120 * s, amp: 6 * Double(s), freq: 0.012, phase: 0.3, bottom: g, C(0x9A9A82),
                    shade: C(0xB8B494))
            for i in 0..<9 {
                let sx = Int(noise(i + 5100) * Double(c.w)), sh = (16 + Int(noise(i + 5101) * 30)) * s
                saSpire(c, x: sx, base: g - 112 * s, w: (8 + Int(noise(i + 5102) * 6)) * s, h: sh,
                        lean: Int((noise(i + 5103) - 0.5) * Double(8 * s)), s: s, seed: i + 5104)
            }
            c.dunes(base: g - 80 * s, amp: 10 * Double(s), freq: 0.016, phase: 1.9, bottom: g, C(0xBCA472),
                    shade: C(0xD8C08A))
            c.dunes(base: g - 50 * s, amp: 8 * Double(s), freq: 0.021, phase: 3.1, bottom: g, C(0xCCB070),
                    shade: C(0xE4CA8A))
        }
        // The far dunes, then the spires, then the middle dune.
        c.dunes(base: g - (tall ? 30 : 20) * s, amp: 4 * Double(s), freq: 0.02, phase: 2.4, bottom: g, C(0xC8AE74),
                shade: C(0xE0C88E))
        let spires: [(Int, Int, Int, Int)] = [(6, 14, 36, 3), (21, 9, 24, -4), (33, 12, 30, 2), (68, 16, 46, -3),
                                             (79, 9, 22, 4), (93, 13, 34, -2)]
        for (i, sp) in spires.enumerated() {
            saSpire(c, x: c.w * sp.0 / 100, base: g - 8 * k, w: sp.1 * k, h: sp.2 * k, lean: sp.3 * k, s: s,
                    seed: i + 5120)
        }
        c.dunes(base: g - 11 * k, amp: 3 * Double(k), freq: 0.024, phase: 0.2, bottom: g, C(0xDCC07E),
                shade: C(0xF0D89C))
        // The near dune the Sandwurm swims under, its ridge lit, ripples combed into it by the wind.
        c.dunes(base: f.dune, amp: f.amp, freq: 0.03, phase: 0.8, bottom: g, saSand, shade: saSandLit)
        for i in 0..<(c.w / (14 * k)) {
            let x = Int(noise(i + 5140) * Double(c.w)), y = saDuneTop(x, base: f.dune, amp: f.amp) + 2 * k
            guard y < g - k else { continue }
            c.rect(x, y + Int(noise(i + 5141) * Double(max(1, g - y - k))), 4 * k, max(1, k / 2), saSandDark)
        }
        // The pale sand the crew stands on.
        c.ground(g, C(0xF0DA9C), edge: C(0xFAEAB8), speck: C(0xD8BC7C), seed: 513)
        for y in stride(from: g + 2 * s, to: c.h, by: 3 * s) {
            for x in stride(from: (y / 3) % 7, to: c.w, by: 9 * s) { c.rect(x, y, 4 * s, max(1, s / 2), C(0xE2C888)) }
        }
    }

    /// What moves on Saturn: something swimming under the near dune, its hump and the wake it combs into the sand
    /// moving along, and now and then the Sandwurm's striped back arching up out of the sand, spraying it, and going
    /// back under.
    static func sandwormSaturnLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let f = saFrame(c, g), k = f.k
        func top(_ x: Int) -> Int { saDuneTop(x, base: f.dune, amp: f.amp) }
        let ph = frac((t + 6.5) / 13), x = Int(ph * Double(c.w + 120 * k)) - 60 * k
        let rise = ph > 0.42 && ph < 0.72 ? sin((ph - 0.42) / 0.3 * .pi) : 0
        if rise < 0.2 {
            // The hump moving under the sand, and its wake fanning out behind.
            let hw = 7 * k
            for dx in -hw...hw {
                let q = Double(dx) / Double(hw), hh = Int((1 - q * q) * Double(2 * k) + 0.5)
                guard hh > 0 else { continue }
                let y = top(x + dx)
                c.rect(x + dx, y - hh, 1, hh + 1, saSand); c.px(x + dx, y - hh, dx < 0 ? saSandLit : saSand)
                if dx > 0 { c.px(x + dx, y + 1, saSandDark) }
            }
            for j in 1...5 {
                let wx = x - hw - j * 5 * k, y = top(wx)
                let a = 1 - Double(j) / 6
                c.rect(wx, y + 1 + j * k / 2, 3 * k, max(1, k / 2), saSandDark.alpha(a))
                c.rect(wx + k, y - 1, 3 * k, max(1, k / 2), saSandLit.alpha(a))
            }
        }
        guard rise > 0 else { return }
        // The Sandwurm's back: black and white bands arching out of the dune, clipped where it's still under.
        let len = 36 * k, r = 3 * k, h = Int(rise * Double(16 * k))
        for i in stride(from: 0, through: len, by: max(1, k)) {
            let u = Double(i) / Double(len), px = x - len + i
            let py = top(px) + r - Int(pow(sin(u * .pi), 0.6) * Double(h + r))
            let band = (i / (3 * k)) % 2 == 0
            for dy in -r...r {
                for dx in -r...r where dx * dx + dy * dy <= r * r {
                    let xx = px + dx, yy = py + dy
                    guard yy <= top(xx) else { continue }
                    let col = band ? (dy < -r / 2 ? C(0xFFFFFF) : burtonBone) : (dy < -r / 2 ? C(0x34343E) : burtonInk)
                    c.px(xx, yy, col)
                }
            }
        }
        // Sand spraying where it breaks through, at both ends.
        for (i, ex) in [x - len, x].enumerated() {
            for j in 0..<6 {
                let n = Int(t * 10) * 13 + j * 7 + i * 101
                let gx = ex + Int((noise(n) - 0.5) * Double(8 * k))
                let gy = top(ex) - Int(noise(n + 1) * Double(6 * k) * rise)
                c.rect(gx, gy, k, k, saSand.alpha(0.85))
            }
        }
    }
}

// MARK: - The pastel cul-de-sac

extension Scenes {
    private static let psWalls: [UInt32] = [0xA8E8C8, 0xF6B8CC, 0xF8E68A, 0xA8D2F4, 0xCCB4EC]
    private static let psCar = C(0x5EBCC0)

    /// The houses along the street, left to right: where each starts, its width and wall height, its colour, and
    /// whether its garage is on the left; and the size unit and the row the houses stand on.
    static func psFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, base: Int,
                                                       houses: [(x: Int, w: Int, h: Int, col: Int, left: Bool)]) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        var out: [(x: Int, w: Int, h: Int, col: Int, left: Bool)] = []
        var x = -8 * k, i = 0
        while x < c.w {
            let w = (46 + Int(noise(i + 5200) * 12)) * k, h = (14 + Int(noise(i + 5201) * 3)) * k
            out.append((x, w, h, i % psWalls.count, i % 2 == 1))
            x += w + (18 + Int(noise(i + 5202) * 8)) * k; i += 1
        }
        return (k, g - 9 * k, out)
    }

    /// Where a house's garage door starts, and how wide it is.
    private static func psGarage(_ h: (x: Int, w: Int, h: Int, col: Int, left: Bool), k: Int) -> (x: Int, w: Int) {
        (h.left ? h.x + 4 * k : h.x + h.w - 20 * k, 16 * k)
    }

    /// One of the street's identical cars seen from the front (or back): rounded roof, wide windscreen, headlights and
    /// chrome bumper; its bottom on row `y`, middle at x.
    private static func psCarFront(_ c: PixelCanvas, x: Int, y: Int, k: Int) {
        c.pattern(x - 8 * k, y - 8 * k, bjScale(["....RRRRRRRR....", "...BWWWWWWWWB...", "..BWWWWWWWWWWB..",
                                                  ".BBBBBBBBBBBBBB.", "BLLBBBBBBBBBBLLB", "BBBBBBBBBBBBBBBB",
                                                  "CCCCCCCCCCCCCCCC", "TT............TT"], k),
                  ["R": C(0xF4F4F0), "W": C(0x9ACCE8), "B": psCar, "L": C(0xFFF4C0), "C": C(0xD8DCE0),
                   "T": C(0x1E1E24)])
    }

    /// The same car side-on, facing right (or left), with its tail fins; its bottom on row `y`, middle at x.
    private static func psCarSide(_ c: PixelCanvas, x: Int, y: Int, k: Int, left: Bool) {
        let rows = [".......RRRRRRRR.......", "......RWWWRWWWWR......", ".....RWWWWRWWWWWR.....",
                    "BB...BBBBBBBBBBBBBBBBB", "BBBBBBBBBBBBBBBBBBBBBL", "CCCCCCCCCCCCCCCCCCCCCC",
                    "..TTT...........TTT...", "..TTT...........TTT..."]
        let art = left ? rows.map { String($0.reversed()) } : rows
        c.pattern(x - 11 * k, y - 8 * k, bjScale(art, k), ["R": C(0xF4F4F0), "W": C(0x9ACCE8), "B": psCar,
                                                          "L": C(0xFFF4C0), "C": C(0xD8DCE0), "T": C(0x1E1E24)])
    }

    /// A topiary clipped from a hedge: the shape in mid green, lit where its top or left edge meets the air and shaded
    /// where its right or bottom edge does.
    private static func psTopiary(_ c: PixelCanvas, x: Int, base: Int, _ rows: [String], k: Int) {
        let mid = C(0x2A7A38), lit = C(0x4AA444), dark = C(0x1A5228)
        func on(_ r: Int, _ q: Int) -> Bool {
            guard r >= 0, r < rows.count else { return false }
            let row = Array(rows[r]); return q >= 0 && q < row.count && row[q] == "G"
        }
        let y0 = base - rows.count * k
        for r in 0..<rows.count {
            for q in 0..<rows[r].count where on(r, q) {
                let col = !on(r - 1, q) || !on(r, q - 1) ? lit : (!on(r + 1, q) || !on(r, q + 1) ? dark : mid)
                c.rect(x + q * k, y0 + r * k, k, k, col)
            }
        }
    }

    private static let psDinosaur = [
        ".GGGG.........", "GGGGGG........", "GGGGGGG.......", "...GGGG.......", "...GGGGG......",
        "..GGGGGGG.....", ".GG.GGGGGG....", "...GGGGGGGG...", "...GGGGGGGGGG.", "....GGGGG..GGG",
        "....GG.GG.....", "....GG.GG.....", "...GGG.GGG....",
    ]
    private static let psHand = [
        "...G.G....", ".G.G.G.G..", ".G.G.G.G..", ".G.G.G.G..", ".GGGGGGG.G", ".GGGGGGGGG", ".GGGGGGGG.",
        "..GGGGGG..", "...GGGG...", "...GGGG...", "....GG....", "....GG....", "...GGGG...",
    ]
    private static let psDeer = [
        "......G.G.G.", ".......GGG..", "........GGG.", "........GGGG", ".......GGG..", "..GGGGGGGG..",
        ".GGGGGGGGG..", "GGGGGGGGG...", ".G.G...G.G..", ".G.G...G.G..", ".G.G...G.G..", ".G.G...G.G..",
    ]

    /// The Inventor's castle: a dark gothic pile, a long hall between slim towers with steep spires, the tall keep in
    /// the middle, crooked battlements, one window lit; `u` the unit, its middle at x, standing on row `base`.
    private static func psCastle(_ c: PixelCanvas, x: Int, base: Int, u: Int) {
        let dark = C(0x1E1C26), lit = C(0x3A3848)
        func box(_ a: Int, _ b: Int, _ w: Int, _ h: Int) {
            c.rect(x + a * u, base + b * u, w * u, h * u, dark); c.rect(x + a * u, base + b * u, u, h * u, lit)
        }
        func spire(_ a: Int, _ b: Int, _ w: Int, _ h: Int) {
            let l = Double(x + a * u - u), r = Double(x + (a + w) * u + u), y = Double(base + b * u)
            let tip = (Double(x) + (Double(a) + Double(w) / 2) * Double(u), Double(base + (b - h) * u))
            burtonTriangle(c, (l, y), (r, y), tip, dark)
            burtonTriangle(c, (l, y), (l + Double(u), y), tip, lit)
        }
        box(-13, -10, 26, 10)
        for (a, b, w, h) in [(-17, -13, 3, 8), (-12, -17, 4, 9), (8, -19, 4, 11), (14, -14, 3, 9), (-3, -22, 6, 12)] {
            box(a, b, w, -b); spire(a, b, w, h)
        }
        for a in stride(from: -6, through: 6, by: 3) {   // the battlements' crooked teeth
            c.rect(x + a * u, base - (11 + (a + 6) % 2) * u, 2 * u, 2 * u, dark)
        }
        c.rect(x, base - 18 * u, u, 2 * u, C(0xF8D878))   // the one lit window, high in the keep
        c.rect(x - 2 * u, base - 4 * u, 4 * u, 4 * u, C(0x0C0A10)); c.rect(x - u, base - 5 * u, 2 * u, u, C(0x0C0A10))
        for a in [-10, -6, 5, 9] { c.rect(x + a * u, base - 7 * u, u, 3 * u, C(0x0C0A10)) }
    }

    /// The dark hill at the end of the street: a craggy dome, a road winding up it, the
    /// castle on top. `peak` is the hill's top row, at column `px`.
    private static func psHill(_ c: PixelCanvas, px: Int, peak: Int, base: Int, w: Int, u: Int) {
        let hill = C(0x34303E), slope = C(0x46425A)
        for x in max(0, px - w)..<min(c.w, px + w) {
            let d = max(0, Double(abs(x - px) - 10 * u) / Double(w - 10 * u))
            let crag = Int(noise(x / max(1, 2 * u) + 5240) * Double(2 * u))
            let top = peak + Int(Double(base - peak) * pow(d, 1.5)) + (d > 0 ? crag : 0)
            c.rect(x, top, 1, base - top, hill); c.rect(x, top, 1, u, x < px ? slope : hill)
        }
        // The road winding up.
        for i in 0..<5 {
            let y0 = peak + (base - peak) * (i + 1) / 6, dir = i % 2 == 0 ? 1 : -1
            let along = pow(Double(y0 - peak) / Double(base - peak), 1 / 1.5)
            let half = (10 * u + Int(Double(w - 10 * u) * along)) * 2 / 3
            burtonLine(c, Double(px - dir * half), Double(y0), Double(px + dir * half), Double(y0 + (base - peak) / 7),
                       slope, Double(u) * 0.5)
        }
        psCastle(c, x: px, base: peak + 3 * u, u: u)
    }

    /// The pastel cul-de-sac from Edward Scissorhands, on a bright day: a row of low ranch houses in candy colours
    /// (mint, pink, lemon, sky blue, lilac), each with its picture window and white garage door, its driveway and the
    /// same pale aqua car parked in it; green lawns with Edward's topiary on them (a dinosaur, a hand, a deer), and
    /// at the end of the street the black castle on its dark hill above the rooftops. On the screen saver the hill
    /// rises high over the town, the castle on top, and a second row of pastel roofs shows behind.
    static func pastelSuburbia(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = psFrame(c, g), k = f.k
        c.gradient(0, g, C(0x6AB4EC), C(0xD8F0FA), bands: 7)
        for i in 0..<(tall ? 7 : 4) {
            let cx = Int(noise(i + 5210) * Double(c.w))
            let cy = (tall ? g / 8 : 6 * s) + Int(noise(i + 5211) * Double(g / 5))
            guard abs(cx - c.w * (tall ? 70 : 84) / 100) > c.w * (tall ? 22 : 10) / 100 else { continue }
            cloud(c, cx, cy, (tall ? 6 : 3) * s, seed: i + 5212)
        }
        // The hill and the castle at the end of the street.
        if tall {
            psHill(c, px: c.w * 70 / 100, peak: g - 150 * s, base: f.base, w: c.w * 36 / 100, u: 3 * s)
            // A second row of pastel roofs behind the street.
            var x = -4 * s, i = 0
            while x < c.w {
                let w = (34 + Int(noise(i + 5220) * 16)) * s, base = f.base - 8 * s
                let wall = C(psWalls[(i + 2) % psWalls.count])
                c.rect(x, base - 12 * s, w, 12 * s, lerp(wall, C(0x8AA8C8), 0.25))
                for r in 0..<(6 * s) {
                    c.rect(x - 2 * s + r * 2, base - 12 * s - r - 1, w + 4 * s - r * 4, 1,
                           lerp(wall, C(0x5A6A80), 0.45))
                }
                x += w + (6 + Int(noise(i + 5221) * 10)) * s; i += 1
            }
        } else {
            psHill(c, px: c.w * 84 / 100, peak: g - 26 * s, base: f.base, w: c.w * 18 / 100, u: s)
        }
        // The lawns, then the houses with their garages and windows.
        c.rect(0, f.base - 2 * k, c.w, g - f.base + 2 * k, C(0x5AB84A))
        for i in 0..<(c.w * (g - f.base) / (12 * k)) {
            let y = f.base + Int(noise(i + 5231) * Double(g - f.base))
            c.rect(Int(noise(i + 5230) * Double(c.w)), y, k, k, C(0x4AA03E))
        }
        for (i, h) in f.houses.enumerated() {
            let wall = C(psWalls[h.col]), shade = lerp(wall, C(0x5A5A7A), 0.2), roof = lerp(wall, C(0x4A4A60), 0.4)
            let top = f.base - h.h
            c.rect(h.x, top, h.w, h.h, wall); c.rect(h.x + h.w - k, top, k, h.h, shade)
            // A low hipped roof overhanging the walls.
            let rh = 7 * k
            for r in 0..<rh {
                let inset = r * 2
                c.rect(h.x - 3 * k + inset, top - r - 1, h.w + 6 * k - inset * 2, 1, r == 0 ? shade : roof)
            }
            c.rect(h.x - 3 * k, top - k, h.w + 6 * k, k, lerp(roof, C(0xFFFFFF), 0.25))
            // The garage door, the picture window and the front door.
            let gd = psGarage(h, k: k)
            c.rect(gd.x, f.base - 11 * k, gd.w, 11 * k, C(0xF6F6F0))
            for y in stride(from: f.base - 9 * k, to: f.base, by: 3 * k) {
                c.rect(gd.x, y, gd.w, max(1, k / 2), C(0xD0D0CC))
            }
            let wx = h.left ? h.x + 24 * k : h.x + 6 * k
            c.rect(wx - k, top + 3 * k, 14 * k, 7 * k, C(0xFFFFFF)); c.rect(wx, top + 4 * k, 12 * k, 5 * k, C(0xA8D4EC))
            c.rect(wx + 6 * k, top + 4 * k, max(1, k / 2 + k / 2), 5 * k, C(0xFFFFFF))
            c.rect(wx, top + 4 * k, 4 * k, 2 * k, C(0xD8F0FA))
            let dx = h.left ? h.x + h.w - 9 * k : h.x + h.w - 25 * k
            c.rect(dx, f.base - 10 * k, 5 * k, 10 * k, lerp(wall, C(0xC8306A), 0.55))
            c.px(dx + 4 * k - 1, f.base - 5 * k, C(0xF8D848))
            // The driveway down to the street, and the car parked on it (not the one that pulls out).
            for y in f.base..<g {
                let grow = (y - f.base) / 3
                c.rect(gd.x - grow, y, gd.w + grow * 2, 1, C(0xD8D8D2))
            }
            if i != psMovingCar(f) { psCarFront(c, x: gd.x + gd.w / 2, y: g - k, k: k) }
            // A neat round shrub by the front door.
            c.ellipse(dx + (h.left ? 8 : -4) * k, f.base - 2 * k, 3 * k, 3 * k, C(0x3E9E4A))
            c.ellipse(dx + (h.left ? 7 : -5) * k, f.base - 3 * k, 2 * k, 2 * k, C(0x7ACC6A))
        }
        // Edward's topiary on the lawns between the houses.
        let shapes = [psDinosaur, psHand, psDeer]
        for (i, h) in f.houses.enumerated() where i > 0 {
            let prev = f.houses[i - 1], gap = h.x - (prev.x + prev.w), art = shapes[i % shapes.count]
            let tx = prev.x + prev.w + gap / 2 - art[0].count * k / 2
            psTopiary(c, x: tx, base: g - 2 * k, art, k: k)
        }
        // The pavement and the street.
        c.rect(0, g, c.w, c.h - g, C(0x9A9AA0))
        c.rect(0, g, c.w, 2 * s, C(0xE8E8E2))
        c.rect(0, g + 2 * s, c.w, s, C(0xB8B8BC))
        for x in stride(from: 0, to: c.w, by: 16 * s) { c.rect(x, g + 6 * s, 8 * s, s, C(0xE8E0B0)) }
    }

    /// Which house's car pulls out (the one nearest the middle of the street).
    private static func psMovingCar(_ f: (k: Int, base: Int, houses: [(x: Int, w: Int, h: Int, col: Int, left: Bool)]))
        -> Int {
        guard let last = f.houses.last else { return 0 }
        let mid = (last.x + last.w) / 2
        func off(_ i: Int) -> Int { abs(f.houses[i].x + f.houses[i].w / 2 - mid) }
        return f.houses.indices.min { off($0) < off($1) } ?? 0
    }

    /// What moves in the cul-de-sac: lawn sprinklers ticking round, throwing their arcs of water, and one of the cars
    /// backing out of its driveway, driving off down the street, and coming home again.
    static func pastelSuburbiaLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = psFrame(c, g), k = f.k
        // Sprinklers on the lawns in front of the houses, ticking across and back.
        for (i, h) in f.houses.enumerated() where i % 2 == 0 {
            let sx = h.left ? h.x + h.w - 18 * k : h.x + 18 * k, sy = g - 3 * k
            let sweep = abs(frac(t * 0.12 + Double(i) * 0.37) * 2 - 1)
            let a = (-160 + (Double(Int(sweep * 14)) / 14) * 140) * .pi / 180
            let reach = 22.0 * Double(k)
            for j in 1...12 {
                let d = Double(j) / 12 * reach
                let x = Double(sx) + cos(a) * d, y = Double(sy) - d * 0.9 + d * d * 0.9 / reach
                c.rect(Int(x), Int(y), k, k, C(0xF0FAFF, 0.95 - Double(j) * 0.04))
                if j % 3 == 0 { c.rect(Int(x) + k, Int(y) + 2 * k, k, k, C(0xD8F0FF, 0.6)) }
            }
            c.ellipse(sx + Int(cos(a) * reach), sy + k, 3 * k, k, C(0xC8ECFF, 0.4))
        }
        // The car: drives in from the left, turns up the driveway, sits, backs out and drives off to the right.
        let i = psMovingCar(f)
        guard i < f.houses.count else { return }
        let gd = psGarage(f.houses[i], k: k), cx = gd.x + gd.w / 2, street = g + 8 * s
        let ph = frac(t / 18)
        let parkedY = g - k
        if ph < 0.12 {
            let x = Int(Double(-24 * k) + Double(cx + 24 * k) * (ph / 0.12))
            psCarSide(c, x: x, y: street, k: k, left: false)
        } else if ph < 0.18 {
            let y = street + Int(Double(parkedY - street) * ((ph - 0.12) / 0.06))
            psCarFront(c, x: cx, y: y, k: k)
        } else if ph < 0.6 {
            psCarFront(c, x: cx, y: parkedY, k: k)
        } else if ph < 0.66 {
            let y = parkedY + Int(Double(street - parkedY) * ((ph - 0.6) / 0.06))
            psCarFront(c, x: cx, y: y, k: k)
        } else if ph < 0.86 {
            let x = cx + Int(Double(c.w - cx + 30 * k) * ((ph - 0.66) / 0.2))
            psCarSide(c, x: x, y: street, k: k, left: false)
        }
    }
}

// MARK: - The Inventor's castle

extension Scenes {
    /// The hall's layout: the size unit, the arched window (middle, top, width), the conveyor belt (ends and row), the
    /// cookie machine (left edge, width, height), and the gears on the walls (middle, radius, teeth, which way round).
    static func icFrame(_ c: PixelCanvas, _ g: Int)
        -> (k: Int, window: (x: Int, y: Int, w: Int), belt: (x0: Int, x1: Int, y: Int),
            machine: (x: Int, w: Int, h: Int), gears: [(x: Int, y: Int, r: Int, n: Int, dir: Double)]) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        let mx = c.w * 70 / 100, mw = 40 * k, mh = 34 * k
        let window = (c.w * 34 / 100, g - (tall ? 50 : 58) * k, (tall ? 16 : 24) * k)
        let gears: [(x: Int, y: Int, r: Int, n: Int, dir: Double)] = [
            (c.w * 8 / 100, g - 40 * k, 10 * k, 12, 1), (c.w * 8 / 100 + 15 * k, g - 28 * k, 6 * k, 8, -1.66),
            (mx + mw + 12 * k, g - 40 * k, 8 * k, 10, 1), (mx + mw + 22 * k, g - 50 * k, 5 * k, 7, -1.6),
            (c.w * 52 / 100, g - 46 * k, 7 * k, 9, 0.8),
        ]
        return (k, window, (c.w * 40 / 100, mx, g - 16 * k), (mx, mw, mh), gears)
    }

    /// A gear wheel: a rim with square teeth, spokes and a hub, turned to `angle` (radians).
    private static func icGear(_ c: PixelCanvas, x: Int, y: Int, r: Int, n: Int, angle: Double, k: Int) {
        let metal = C(0x7A6440), lit = C(0xA88A58), dark = C(0x4A3C28)
        for i in 0..<n {
            let a = angle + Double(i) / Double(n) * 2 * .pi
            let tx = x + Int((cos(a) * Double(r)).rounded()), ty = y + Int((sin(a) * Double(r)).rounded())
            c.rect(tx - k, ty - k, 2 * k + 1, 2 * k + 1, metal)
        }
        c.circle(x, y, r - k, metal); c.circle(x - k / 2, y - k / 2, r - 2 * k, lit); c.circle(x, y, r - 2 * k, metal)
        c.circle(x, y, max(k, r - 4 * k), dark)
        for i in 0..<4 {
            let a = angle + Double(i) / 4 * 2 * .pi
            let len = Double(r - 3 * k)
            burtonLine(c, Double(x), Double(y), Double(x) + cos(a) * len, Double(y) + sin(a) * len, metal,
                       max(0.6, Double(k) * 0.7))
        }
        c.circle(x, y, max(1, 2 * k), lit); c.circle(x, y, max(1, k), dark)
    }

    /// A tall pointed gothic window: its arch's top at (x, y), `w` wide, down to row `bottom`. `inside` fills each row
    /// between the given ends.
    private static func icArch(x: Int, y: Int, w: Int, bottom: Int, _ fill: (Int, Int, Int) -> Void) {
        let ah = w * 3 / 4
        for row in y..<bottom {
            let r = row - y
            let half = r >= ah ? w / 2 : Int(Double(w) / 2 * pow(Double(r) / Double(ah), 0.55))
            if half > 0 { fill(row, x - half, x + half) }
        }
    }

    /// A heart-shaped biscuit, `k` to its pixel, its top left at (x, y).
    private static func icHeart(_ c: PixelCanvas, x: Int, y: Int, k: Int, a: Double = 1) {
        c.pattern(x, y, bjScale([".BB.BB.", "BLBBBBD", "BBBBBBD", ".BBBBD.", "..BBD..", "...D..."], k),
                  ["B": C(0xD8A060, a), "L": C(0xF4C890, a), "D": C(0xA8743C, a)])
    }

    /// The Inventor's castle from Edward Scissorhands: the great hall up on the hill, dark stone by candlelight, a tall
    /// pointed window onto the night, cogs on the walls, and the cookie machine: a big contraption with a hopper and
    /// dials feeding heart-shaped biscuits out along a conveyor belt; candelabras, and an ice angel half carved on its
    /// block. On the screen saver the hall rises into a broken roof, the night sky and the stars showing through it.
    static func inventorsCastle(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = icFrame(c, g), k = f.k
        let stone = C(0x2E2A36), joint = C(0x201C28), stoneL = C(0x3C3846), wood = C(0x2A1E18), woodL = C(0x4A3628)
        let wallTop = tall ? g - 130 * s : 0
        // The broken roof on the screen saver: the night through a jagged hole between timbers.
        if tall {
            // The night sky, only seen through the hole: stars and the moon.
            let hx = c.w * 56 / 100, hy = wallTop * 48 / 100, hr = Double(min(c.w * 30 / 100, wallTop * 3 / 4))
            c.gradient(0, wallTop, C(0x080C1C), C(0x1C2648), bands: 6)
            c.stars(0, wallTop, density: 60, seed: 521)
            let mx = hx + Int(hr * 0.35), my = hy - Int(hr * 0.2)
            c.circle(mx, my, 16 * s, C(0xE8ECF4, 0.12)); c.circle(mx, my, 11 * s, C(0xE8ECF4))
            c.circle(mx + 4 * s, my - 2 * s, 9 * s, C(0xC8D0E0))
            // The roof's boards all round a ragged hole, splintered at its edge.
            func inHole(_ x: Int, _ y: Int) -> Bool {
                let dx = Double(x - hx), dy = Double(y - hy) * 1.7, d = (dx * dx + dy * dy).squareRoot()
                let a = atan2(dy, dx) + .pi
                let edge = hr * (0.7 + 0.3 * noise(Int(a * 3) + 5300)) - noise(Int(a * 24) + 5310) * Double(10 * s)
                return d < edge
            }
            for y in 0..<wallTop {
                let board = (y / (5 * s)) % 2 == 0 ? wood : C(0x22180F)
                for x in 0..<c.w where !inHole(x, y) {
                    let joint = (x + (y / (5 * s)) * 17 * s) % (40 * s) < s
                    c.px(x, y, joint ? C(0x140E0A) : board)
                }
            }
            // Rafters sloping up to the ridge, snapped off where the hole is.
            for i in 0..<9 {
                let x0 = Double(c.w * i / 8), x1 = Double(c.w / 2) + (x0 - Double(c.w / 2)) / 5
                for j in 0...200 {
                    let q = Double(j) / 200, x = x0 + (x1 - x0) * q, y = Double(wallTop) * (1 - q)
                    if !inHole(Int(x), Int(y)) { c.rect(Int(x) - s, Int(y), 3 * s, max(1, s), woodL) }
                }
            }
            c.rect(0, wallTop - 4 * s, c.w, 6 * s, woodL); c.rect(0, wallTop + 2 * s, c.w, 2 * s, wood)
        }
        // The stone walls in blocks.
        c.rect(0, wallTop, c.w, g - wallTop, stone)
        let bh = 6 * k, bw = 12 * k
        for (r, y) in stride(from: g, to: wallTop, by: -bh).enumerated() {
            c.rect(0, y - 1, c.w, max(1, k / 2), joint)
            for x in stride(from: (r % 2) * bw / 2, to: c.w, by: bw) {
                c.rect(x, y - bh, max(1, k / 2), bh, joint)
                if noise(x * 3 + r * 17 + 5330) > 0.7 { c.rect(x + k, y - bh + k, bw - 2 * k, bh - 2 * k, stoneL) }
            }
        }
        // The tall pointed window: its deep reveal, the night outside, a sliver of moon and its leading.
        let w = f.window
        let wh = (tall ? 40 : 44) * k, ww = w.w
        icArch(x: w.x, y: w.y - 2 * k, w: ww + 4 * k, bottom: w.y + wh + k) { row, a, b in
            c.rect(a, row, b - a, 1, C(0x18141E))
        }
        icArch(x: w.x, y: w.y, w: ww, bottom: w.y + wh) { row, a, b in
            c.rect(a, row, b - a, 1, lerp(C(0x0C1430), C(0x26346A), Double(row - w.y) / Double(wh)))
        }
        c.stars(w.y, w.y + wh, density: 18, seed: 523, x0: w.x - ww / 2 + k, x1: w.x + ww / 2 - k)
        c.circle(w.x + ww / 5, w.y + ww / 2 + 2 * k, 3 * k, C(0xE8ECF4))
        c.circle(w.x + ww / 5 + 2 * k, w.y + ww / 2 + k, 3 * k, C(0x141C3C))
        c.rect(w.x, w.y + k, max(1, k), wh - k, C(0x18141E))
        for y in stride(from: w.y + ww * 3 / 4, to: w.y + wh, by: 9 * k) {
            c.rect(w.x - ww / 2, y, ww, max(1, k), C(0x18141E))
        }
        c.rect(w.x - ww / 2 - 4 * k, w.y + wh, ww + 8 * k, 2 * k, stoneL)
        // Candle glow pooled on the walls by the candelabras.
        let candles = [c.w * 4 / 100, c.w * 27 / 100, c.w * 96 / 100]
        for cx in candles {
            c.ellipse(cx, g - 28 * k, 12 * k, 9 * k, C(0xFFC060, 0.06))
            c.ellipse(cx, g - 28 * k, 7 * k, 5 * k, C(0xFFC060, 0.08))
        }
        // Pipes running along the wall into the machine.
        let m = f.machine
        c.rect(c.w * 44 / 100, g - 50 * k, m.x - c.w * 44 / 100, 3 * k, C(0x4A3C30))
        c.rect(c.w * 44 / 100, g - 50 * k, m.x - c.w * 44 / 100, k, C(0x6A5440))
        c.rect(c.w * 44 / 100, g - 50 * k, 3 * k, 18 * k, C(0x4A3C30))
        // The cookie machine: the cabinet, its dials and levers, the hopper on top and the chute onto the belt.
        let mtop = g - m.h, cab = C(0x5A3A2E), cabL = C(0x7A5038), cabD = C(0x3A2620), brass = C(0xC8A048)
        c.rect(m.x, mtop, m.w, m.h, cab)
        c.rect(m.x, mtop, k, m.h, cabL)
        c.rect(m.x + m.w - 2 * k, mtop, 2 * k, m.h, cabD)
        c.rect(m.x - 2 * k, mtop - 2 * k, m.w + 4 * k, 2 * k, brass)
        for (dx, dy, r) in [(8, 8, 4), (19, 11, 3)] {
            c.circle(m.x + dx * k, mtop + dy * k, r * k, brass)
            c.circle(m.x + dx * k, mtop + dy * k, (r - 1) * k, C(0xF0E8D0))
            burtonLine(c, Double(m.x + dx * k), Double(mtop + dy * k), Double(m.x + (dx + r - 2) * k),
                       Double(mtop + (dy - r + 1) * k), C(0x2A1A14), 0.5)
        }
        for i in 0..<3 {
            c.rect(m.x + 30 * k + i * 3 * k, mtop + 6 * k, k, 6 * k, cabD)
            c.rect(m.x + 29 * k + i * 3 * k, mtop + 5 * k, 3 * k, 2 * k, C(0xC8202A))
        }
        c.rect(m.x + 4 * k, mtop + 17 * k, m.w - 8 * k, 10 * k, cabD)
        for x in stride(from: m.x + 6 * k, to: m.x + m.w - 6 * k, by: 4 * k) {
            c.rect(x, mtop + 19 * k, 2 * k, 6 * k, C(0x4A2E24))
        }
        let hx = m.x + m.w / 2
        for r in 0..<(10 * k) {
            let half = 6 * k + r * 3 / 4
            c.rect(hx - half, mtop - 2 * k - r - 1, half * 2, 1, r % (3 * k) == 0 ? C(0x8A8A90) : C(0x6A6A72))
        }
        c.rect(m.x - 6 * k, f.belt.y - 4 * k, 6 * k, 4 * k, cabD)   // the chute
        // The conveyor belt on its legs, rollers at both ends.
        let b = f.belt
        c.rect(b.x0, b.y, b.x1 - b.x0, 3 * k, C(0x24201E)); c.rect(b.x0, b.y + 3 * k, b.x1 - b.x0, k, C(0x4A4440))
        for x in [b.x0 + 2 * k, b.x1 - 4 * k, (b.x0 + b.x1) / 2] {
            c.rect(x, b.y + 4 * k, 2 * k, g - b.y - 4 * k, C(0x3A3430))
        }
        c.circle(b.x0, b.y + 2 * k, 2 * k, C(0x6A6460)); c.circle(b.x1, b.y + 2 * k, 2 * k, C(0x6A6460))
        // The stamping press over the belt: its frame (the stamp itself is in the moving layer).
        let px = (b.x0 + b.x1) / 2 + 8 * k
        c.rect(px - 6 * k, b.y - 22 * k, 2 * k, 22 * k, C(0x4A3C30))
        c.rect(px + 6 * k, b.y - 22 * k, 2 * k, 22 * k, C(0x4A3C30))
        c.rect(px - 7 * k, b.y - 24 * k, 16 * k, 3 * k, cab); c.rect(px - 7 * k, b.y - 24 * k, 16 * k, k, cabL)
        // A tray of biscuits already cut, at the belt's end.
        c.rect(b.x0 - 14 * k, g - 6 * k, 14 * k, 6 * k, C(0x3A2A20)); c.rect(b.x0 - 14 * k, g - 6 * k, 14 * k, k, woodL)
        icHeart(c, x: b.x0 - 12 * k, y: g - 12 * k, k: max(1, k))
        icHeart(c, x: b.x0 - 6 * k, y: g - 11 * k, k: max(1, k))
        // The ice angel, half carved, on its block of ice.
        let ax = c.w * 20 / 100, ice = C(0xC8E8F4), iceL = C(0xF4FCFF), iceD = C(0x8ABCD8)
        c.rect(ax - 7 * k, g - 6 * k, 14 * k, 6 * k, iceD); c.rect(ax - 7 * k, g - 6 * k, 13 * k, 5 * k, ice)
        c.rect(ax - 7 * k, g - 6 * k, 13 * k, k, iceL)
        c.pattern(ax - 8 * k, g - 25 * k, bjScale(["......LL........", ".....LIIL.......", ".....IIID.......",
                                                    "LL....ID.....LL.", "LIL..LIID...LID.", ".LIL.LIIID.LID..",
                                                    "..LIIIIIIIIID...", "...LIIIIIIID....", "....LIIIIID.....",
                                                    ".....LIIIID.....", ".....LIIIID.....", ".....LIIIIID....",
                                                    "....LIIIIIID....", "....LIIIIIIID...", "...LIIIIIIIID...",
                                                    "...LIIIIIIIIID..", "...IIIIIIIIIIID.", "..LIIIIIIIIIIID.",
                                                    "..IIIIIIIIIIIIID"], k), ["I": ice, "L": iceL, "D": iceD])
        // The stone floor in big flags.
        c.rect(0, g, c.w, c.h - g, C(0x241F2A)); c.rect(0, g, c.w, s, C(0x4A4456))
        for y in stride(from: g + 4 * s, to: c.h, by: 4 * s) { c.rect(0, y, c.w, max(1, s / 2), C(0x1A1620)) }
        for (r, y) in stride(from: g, to: c.h, by: 4 * s).enumerated() {
            for x in stride(from: (r % 2) * 9 * s, to: c.w, by: 18 * s) {
                c.rect(x, y, max(1, s / 2), 4 * s, C(0x1A1620))
            }
        }
        // Candelabras: a stand, three arms, three white candles (their flames are in the moving layer).
        for cx in candles {
            let top = g - 24 * k
            c.rect(cx - k / 2, top, max(1, k), 24 * k, C(0x1A1418)); c.rect(cx - 3 * k, g - k, 7 * k, k, C(0x1A1418))
            c.rect(cx - 5 * k, top, 11 * k, k, C(0x1A1418))
            for dx in [-5, 0, 5] {
                c.rect(cx + dx * k - k / 2, top - 4 * k, max(1, k), 4 * k, C(0xF0E8D8))
                c.rect(cx + dx * k - k, top - k, 2 * k + 1, k, C(0x2A2028))
            }
        }
    }

    /// What moves in the Inventor's hall: every gear turning (meshed pairs the opposite way), heart biscuits riding the
    /// belt from the machine under the stamping press, the candle flames flickering, and ice shavings drifting down
    /// like snow, thickest round the ice angel.
    static func inventorsCastleLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = icFrame(c, g), k = f.k
        for gr in f.gears { icGear(c, x: gr.x, y: gr.y, r: gr.r, n: gr.n, angle: t * 0.6 * gr.dir, k: k) }
        // The belt's slats sliding, and the biscuits riding along it.
        let b = f.belt, speed = 6.0 * Double(k)
        let off = Int(t * speed) % (4 * k)
        for x in stride(from: b.x1 - off, to: b.x0, by: -4 * k) { c.rect(x, b.y, max(1, k / 2), 2 * k, C(0x3A3430)) }
        let span = Double(b.x1 - b.x0), gap = 14.0 * Double(k)
        let n = Int(span / gap)
        for i in 0...n {
            let d = (Double(i) * gap + t * speed).truncatingRemainder(dividingBy: span + gap)
            let x = b.x1 - 4 * k - Int(d)
            guard x > b.x0 - 2 * k, x < b.x1 - 6 * k else { continue }
            icHeart(c, x: x, y: b.y - 6 * k, k: max(1, k))
        }
        // The stamp coming down and up again.
        let px = (b.x0 + b.x1) / 2 + 8 * k, press = frac(t * 0.43)
        let drop = press < 0.15 ? Int(sin(press / 0.15 * .pi) * Double(14 * k)) : 0
        c.rect(px - k / 2, b.y - 21 * k, 2 * k, 6 * k + drop, C(0x8A8A92))
        c.rect(px - 4 * k, b.y - 15 * k + drop, 10 * k, 3 * k, C(0xA8A8B0))
        c.rect(px - 4 * k, b.y - 15 * k + drop, 10 * k, k, C(0xD0D0D8))
        // The candle flames.
        for cx in [c.w * 4 / 100, c.w * 27 / 100, c.w * 96 / 100] {
            for (j, dx) in [-5, 0, 5].enumerated() {
                let fl = noise(Int(t * 9) * 7 + j + cx) > 0.5 ? k : 0, fx = cx + dx * k - k / 2, fy = g - 24 * k - 4 * k
                c.circle(fx, fy - 2 * k, 3 * k, C(0xFFC860, 0.14))
                c.rect(fx, fy - 3 * k - fl, max(1, k), 3 * k + fl, C(0xFFB040))
                c.rect(fx, fy - 2 * k, max(1, k), k, C(0xFFF4C0))
            }
        }
        // Ice shavings drifting down like snow, more of them round the angel.
        let ax = c.w * 20 / 100
        for i in 0..<(c.w * g / 420) {
            let x0 = noise(i * 3 + 5400) * Double(c.w), speed = 5 + noise(i * 3 + 5401) * 7
            let y = (noise(i * 3 + 5402) * Double(g) + t * speed).truncatingRemainder(dividingBy: Double(g))
            c.rect(Int(x0 + sin(t * 0.8 + Double(i)) * 4), Int(y), s, s, C(0xF0FAFF, 0.75))
        }
        for i in 0..<14 {
            let k2 = frac(t * 0.35 + Double(i) / 14)
            let x = ax + Int((noise(i + 5410) - 0.5) * Double(30 * k) + sin(t + Double(i)) * Double(3 * k))
            let y = g - 30 * k + Int(k2 * Double(30 * k))
            c.rect(x, y, s, s, C(0xFFFFFF, 0.9 * (1 - k2)))
        }
    }
}

// MARK: - The village of the living

extension Scenes {
    private static let evSky = C(0x8A929C), evSlate = C(0x2C323C), evWin = C(0x9AA098), evWinLit = C(0xC0B890)

    /// The village's layout: the size unit, the clock tower (middle, top row, width), the clock's middle and radius,
    /// the church (middle, width) and the bridge (its ends and its hump's height).
    static func evFrame(_ c: PixelCanvas, _ g: Int)
        -> (k: Int, tower: (x: Int, top: Int, w: Int), clock: (x: Int, y: Int, r: Int), church: (x: Int, w: Int),
            bridge: (x0: Int, x1: Int, h: Int)) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        let tx = c.w * 47 / 100, ttop = g - 50 * k, tw = 14 * k, bx = c.w * 30 / 100
        return (k, (tx, ttop, tw), (tx, ttop + 8 * k, 5 * k), (c.w * 70 / 100, 46 * k), (bx, bx + 64 * k, 11 * k))
    }

    /// Rows of slate roofs climbing the hill behind the village on the screen saver, nearest first: each roof's left
    /// edge, ridge row, width and row number, and whether it has a chimney (and where).
    static func evRoofs(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, w: Int, row: Int, chimney: Int?)] {
        let s = unit(g)
        var out: [(x: Int, y: Int, w: Int, row: Int, chimney: Int?)] = []
        for row in 0..<6 {
            var x = -10 * s + row * 7 * s, i = 0
            let base = g - 66 * s - row * 22 * s
            while x < c.w {
                let w = (20 + Int(noise(row * 50 + i + 5500) * 18)) * s
                let y = base - Int(noise(row * 50 + i + 5501) * Double(8 * s))
                let at = x + w / 4 + Int(noise(row * 50 + i + 5503) * Double(w / 2))
                let ch: Int? = noise(row * 50 + i + 5502) > 0.4 ? at : nil
                out.append((x, y, w, row, ch))
                x += w + Int(noise(row * 50 + i + 5504) * Double(4 * s)); i += 1
            }
        }
        return out
    }

    /// A bare tree: a trunk forking into crooked branches, `h` rows tall, standing on row `base`.
    private static func hvTree(_ c: PixelCanvas, x: Int, base: Int, h: Int, col: Px, seed: Int, width: Double) {
        func branch(_ p: (x: Double, y: Double), _ a: Double, _ len: Double, _ w: Double, _ depth: Int, _ id: Int) {
            let bend = (noise(seed * 97 + id) - 0.5) * 24
            let mid = burtonReach(p, a + bend, len * 0.5), end = burtonReach(mid, a - bend * 0.6, len * 0.5)
            burtonLine(c, p.x, p.y, mid.x, mid.y, col, w); burtonLine(c, mid.x, mid.y, end.x, end.y, col, w * 0.85)
            guard depth > 0 else { return }
            let kids = 2 + (noise(seed * 31 + id) > 0.6 ? 1 : 0)
            for j in 0..<kids {
                let spread = (Double(j) - Double(kids - 1) / 2) * 38 + (noise(seed * 13 + id * 3 + j) - 0.5) * 20
                branch(end, a + spread, len * (0.62 + noise(seed + id * 5 + j) * 0.18), max(0.45, w * 0.68), depth - 1,
                       id * 4 + j + 1)
            }
        }
        branch((Double(x), Double(base)), -90 + (noise(seed) - 0.5) * 10, Double(h) * 0.42, width, h >= 80 ? 4 : 3, 0)
    }

    /// A tall narrow Victorian house: grey walls, a steep slate roof, two chimneys, rows of dim windows; `k` the unit.
    private static func evHouse(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, k: Int, wall: Px, seed: Int) {
        let shade = lerp(wall, C(0x10141C), 0.3), trim = lerp(wall, C(0xC8CCD4), 0.25)
        c.rect(x, base - h, w, h, wall); c.rect(x + w - k, base - h, k, h, shade); c.rect(x, base - h, k, h, trim)
        let rh = w * 2 / 3
        for r in 0..<rh {
            let half = (w / 2 + k) * (rh - r) / rh
            c.rect(x + w / 2 - half, base - h - r - 1, half * 2, 1, (r / max(1, k)) % 3 == 0 ? C(0x3A404C) : evSlate)
        }
        for cx in [x + k, x + w - 3 * k] where noise(seed + cx) > 0.3 {
            c.rect(cx, base - h - rh / 2 - 3 * k, 2 * k, rh / 2 + 3 * k, shade)
            c.rect(cx - k / 2, base - h - rh / 2 - 3 * k, 3 * k, k, evSlate)
        }
        for (i, wy) in stride(from: base - h + 3 * k, to: base - 6 * k, by: 7 * k).enumerated() {
            for wx in stride(from: x + 2 * k, to: x + w - 4 * k, by: 5 * k) {
                let lit = noise(seed * 7 + i * 13 + wx) > 0.85
                c.rect(wx, wy, 3 * k, 4 * k, lit ? evWinLit : evWin)
                c.rect(wx, wy + 2 * k, 3 * k, max(1, k / 2), shade)
            }
        }
        c.rect(x + w / 2 - k, base - 5 * k, 3 * k, 5 * k, C(0x1A1E26))
    }

    /// The village of the living, from Corpse Bride: a grey-blue Victorian street under a dull sky, almost without
    /// colour. Tall narrow houses with slate roofs and chimneys; the Everglot mansion, grand and grim, with its columns
    /// and rows of windows; the square clock tower; the church with its two towers and its round rose window; the
    /// humped stone bridge over the canal; bare trees, gas lamps, cobbles. On the screen saver rows of slate roofs
    /// climb the hill behind, chimneys smoking, a pale moon over them.
    static func everglotVillage(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = evFrame(c, g), k = f.k
        c.gradient(0, g, C(0x323A48), evSky, bands: 7)
        if tall {
            // The pale moon behind thin cloud, and the roofs climbing the hill.
            let mx = c.w * 80 / 100, my = g * 16 / 100, mr = 18 * s
            c.circle(mx, my, mr + 10 * s, C(0xD8DCE4, 0.06)); c.circle(mx, my, mr + 5 * s, C(0xD8DCE4, 0.1))
            c.circle(mx, my, mr, C(0xD0D4DA)); c.circle(mx - 4 * s, my - 3 * s, mr / 3, C(0xB8BEC6))
            c.circle(mx + 6 * s, my + 5 * s, mr / 4, C(0xB8BEC6))
            for i in 0..<5 { c.rect(0, my - 10 * s + i * 7 * s, c.w, 2 * s, C(0x5A6270, 0.25)) }
            for roof in evRoofs(c, g).reversed() {
                let fog = Double(roof.row) * 0.13
                let col = lerp(C(0x262C36), evSky, fog), lit = lerp(C(0x4A525E), evSky, fog)
                let rh = roof.w / 3
                c.rect(roof.x, roof.y + rh, roof.w, 14 * s, lerp(C(0x3A4250), evSky, fog))
                for r in 0..<rh {
                    let inset = r * roof.w / 2 / rh
                    c.rect(roof.x + inset, roof.y + rh - r, roof.w - inset * 2, 1, r == rh - 1 ? lit : col)
                }
                for wx in stride(from: roof.x + 3 * s, to: roof.x + roof.w - 3 * s, by: 6 * s) {
                    let pane = noise(wx + roof.row) > 0.8 ? evWinLit : evWin
                    c.rect(wx, roof.y + rh + 4 * s, 2 * s, 3 * s, lerp(pane, evSky, fog))
                }
                if let ch = roof.chimney {
                    c.rect(ch, roof.y - 2 * s, 3 * s, rh + 2 * s, col); c.rect(ch - s, roof.y - 3 * s, 5 * s, s, lit)
                }
            }
        }
        // The Everglot mansion on the left: wide and symmetrical, columns, two rows of windows, a pediment.
        let mx = c.w * 2 / 100, mw = 96 * k, mh = 30 * k, mtop = g - mh, wall = C(0x4E5664), shade = C(0x3A414E)
        c.rect(mx, mtop, mw, mh, wall); c.rect(mx + mw - k, mtop, k, mh, shade)
        for r in 0..<(8 * k) {
            c.rect(mx - 2 * k + r, mtop - r - 1, mw + 4 * k - 2 * r, 1, r < k ? C(0x6A7280) : evSlate)
        }
        for cx in [mx + 8 * k, mx + mw - 10 * k] {
            c.rect(cx, mtop - 15 * k, 3 * k, 8 * k, shade); c.rect(cx - k, mtop - 16 * k, 5 * k, k, evSlate)
        }
        let pc = mx + mw / 2
        burtonTriangle(c, (Double(pc - 18 * k), Double(mtop + 2 * k)), (Double(pc + 18 * k), Double(mtop + 2 * k)),
                       (Double(pc), Double(mtop - 9 * k)), C(0x5E6674))
        c.circle(pc, mtop - 2 * k, 2 * k, C(0x3A414E))
        for row in 0..<2 {
            for i in 0..<10 where !(row == 1 && (i == 4 || i == 5)) {
                let wx = mx + 5 * k + i * 9 * k, wy = mtop + 5 * k + row * 12 * k
                c.rect(wx, wy, 4 * k, 7 * k, noise(row * 10 + i + 5600) > 0.8 ? evWinLit : evWin)
                c.rect(wx - k, wy - k, 6 * k, k, C(0x6A7280)); c.rect(wx, wy + 3 * k, 4 * k, max(1, k / 2), shade)
            }
        }
        for i in 0..<4 { c.rect(pc - 13 * k + i * 8 * k, mtop + 2 * k, 3 * k, mh - 2 * k, C(0x6A7280)) }
        c.rect(pc - 4 * k, g - 9 * k, 8 * k, 9 * k, C(0x1A1E26))
        // Tall narrow houses along the street (round the tower and the church).
        let walls = [C(0x4A5262), C(0x565E6C), C(0x3E4654), C(0x5A606A)]
        var x = mx + mw + 2 * k, i = 0
        while x < c.w {
            let w = (14 + Int(noise(i + 5610) * 6)) * k, h = (24 + Int(noise(i + 5611) * 12)) * k
            let clearTower = abs(x + w / 2 - f.tower.x) > f.tower.w / 2 + w / 2
            let clearChurch = abs(x + w / 2 - f.church.x) > f.church.w / 2 + 8 * k + w / 2
            if clearTower && clearChurch {
                evHouse(c, x: x, base: g, w: w, h: h, k: k, wall: walls[i % walls.count], seed: i + 5620)
            }
            x += w + k; i += 1
        }
        // The clock tower: square, a ledge, the clock face, a pyramid roof and a finial.
        let t = f.tower, tw = t.w
        c.rect(t.x - tw / 2, t.top, tw, g - t.top, C(0x505866))
        c.rect(t.x + tw / 2 - 2 * k, t.top, 2 * k, g - t.top, C(0x3A414E))
        c.rect(t.x - tw / 2, t.top, k, g - t.top, C(0x6A7280))
        c.rect(t.x - tw / 2 - k, t.top + 15 * k, tw + 2 * k, k, C(0x6A7280))
        for wy in [t.top + 20 * k, t.top + 30 * k] {
            c.rect(t.x - k, wy, 3 * k, 5 * k, evWin)
            c.rect(t.x - k, wy, 3 * k, k, C(0x3A414E))
        }
        burtonTriangle(c, (Double(t.x - tw / 2 - k), Double(t.top)), (Double(t.x + tw / 2 + k), Double(t.top)),
                       (Double(t.x), Double(t.top - 13 * k)), evSlate)
        burtonTriangle(c, (Double(t.x), Double(t.top - 13 * k)), (Double(t.x + tw / 2 + k), Double(t.top)),
                       (Double(t.x + 2 * k), Double(t.top)), C(0x22272F))
        c.rect(t.x, t.top - 16 * k, max(1, k), 3 * k, C(0x22272F))
        let cl = f.clock
        c.circle(cl.x, cl.y, cl.r + k, C(0x3A414E)); c.circle(cl.x, cl.y, cl.r, C(0xD8DCD8))
        for h in 0..<4 {
            let a = Double(h) * .pi / 2
            c.px(cl.x + Int(cos(a) * Double(cl.r - k)), cl.y + Int(sin(a) * Double(cl.r - k)), C(0x2A2E36))
        }
        // The church: a gabled front between two towers, the rose window, a pointed door; the towers' little domes.
        let ch = f.church, cw = ch.w, ctop = g - 34 * k, cwall = C(0x46505E), cshade = C(0x343C48), clit = C(0x5E6878)
        burtonTriangle(c, (Double(ch.x - cw / 2 + 6 * k), Double(ctop)), (Double(ch.x + cw / 2 - 6 * k), Double(ctop)),
                       (Double(ch.x), Double(ctop - 12 * k)), cwall)
        for side in [-1.0, 1.0] {   // the gable's coping
            let foot = Double(ch.x) + side * Double(cw / 2 - 6 * k)
            burtonLine(c, foot, Double(ctop), Double(ch.x), Double(ctop - 12 * k), side < 0 ? clit : cshade,
                       max(0.5, Double(k) * 0.7))
        }
        c.rect(ch.x - cw / 2 + 6 * k, ctop, cw - 12 * k, g - ctop, cwall)
        for tx in [ch.x - cw / 2, ch.x + cw / 2 - 9 * k] {
            let top = g - 50 * k
            c.rect(tx, top, 9 * k, g - top, tx < ch.x ? clit : cwall); c.rect(tx + 8 * k, top, k, g - top, cshade)
            c.rect(tx - k, top, 11 * k, k, C(0x6A7280)); c.rect(tx - k, top + 16 * k, 11 * k, k, C(0x6A7280))
            c.rect(tx + 3 * k, top + 4 * k, 3 * k, 8 * k, C(0x1E232C))
            c.ellipse(tx + 4 * k + k / 2, top + 4 * k, k + k / 2, k, C(0x1E232C))
            c.ellipse(tx + 4 * k + k / 2, top - 3 * k, 4 * k, 3 * k, cshade)
            c.ellipse(tx + 4 * k, top - 4 * k, 3 * k, 2 * k, clit)
            c.rect(tx + 4 * k, top - 9 * k, max(1, k), 4 * k, C(0x22272F))
            for wy in stride(from: top + 20 * k, to: g - 6 * k, by: 9 * k) {
                c.rect(tx + 3 * k, wy, 3 * k, 5 * k, evWin)
            }
        }
        let rw = (x: ch.x, y: ctop + 3 * k, r: 7 * k)
        c.circle(rw.x, rw.y, rw.r + k, cshade); c.circle(rw.x, rw.y, rw.r, C(0xC8CCD2))
        for j in 0..<8 {
            let a = Double(j) / 8 * 2 * .pi
            let r = Double(rw.r)
            burtonLine(c, Double(rw.x), Double(rw.y), Double(rw.x) + cos(a) * r, Double(rw.y) + sin(a) * r, cshade,
                       max(0.45, Double(k) * 0.4))
        }
        c.circle(rw.x, rw.y, max(1, 2 * k), cshade)
        for wx in [ch.x - 12 * k, ch.x + 8 * k] {
            c.rect(wx, ctop + 14 * k, 4 * k, 12 * k, evWin)
            c.ellipse(wx + 2 * k, ctop + 14 * k, 2 * k, 2 * k, evWin)
        }
        c.rect(ch.x - 4 * k, g - 13 * k, 8 * k, 13 * k, C(0x1A1E26))
        c.ellipse(ch.x, g - 13 * k, 4 * k, 4 * k, C(0x1A1E26))
        // Bare trees and gas lamps.
        for (tx, th) in [(c.w * 27 / 100, 40 * k), (c.w * 97 / 100, 46 * k), (c.w * 57 / 100, 30 * k)] {
            hvTree(c, x: tx, base: g, h: th, col: C(0x1C2028), seed: tx, width: Double(k) * 1.4)
        }
        for lx in [c.w * 23 / 100, c.w * 87 / 100] {
            c.rect(lx, g - 18 * k, max(1, k), 18 * k, C(0x1C2028))
            c.rect(lx - k, g - 21 * k, 3 * k, 3 * k, C(0xA8A898))
            c.rect(lx - k, g - 22 * k, 3 * k, k, C(0x1C2028))
        }
        // The canal along the street, and the humped stone bridge over it.
        let b = f.bridge
        c.rect(0, g - 3 * k, c.w, 3 * k, C(0x2A303A)); c.rect(0, g - 3 * k, c.w, max(1, k / 2), C(0x6A7484))
        let stone = C(0x6A7280), stoneD = C(0x4A515E), stoneL = C(0x8A92A0)
        for x in b.x0..<b.x1 {
            let u = Double(x - b.x0) / Double(b.x1 - b.x0), hump = Int(sin(u * .pi) * Double(b.h))
            let top = g - 4 * k - hump
            c.rect(x, top, 1, g - top, stone); c.rect(x, top, 1, k, stoneL)
            // The arch's dark opening over the water.
            let au = (u - 0.5) / 0.32
            if abs(au) < 1 {
                let ah = Int((1 - au * au).squareRoot() * Double(b.h - 2 * k))
                c.rect(x, g - ah, 1, ah, C(0x14181E))
            }
        }
        for x in stride(from: b.x0 + 2 * k, to: b.x1 - 2 * k, by: 5 * k) {   // the parapet's stones
            let u = Double(x - b.x0) / Double(b.x1 - b.x0), top = g - 4 * k - Int(sin(u * .pi) * Double(b.h))
            c.rect(x, top + k, max(1, k / 2), 2 * k, stoneD)
        }
        // The cobbles.
        c.rect(0, g, c.w, c.h - g, C(0x3E4450)); c.rect(0, g, c.w, s, C(0x6A7280))
        for y in stride(from: g + 2 * s, to: c.h, by: 3 * s) {
            for cx in stride(from: ((y - g) / (3 * s) % 2) * 2 * s, to: c.w, by: 5 * s) {
                c.rect(cx, y, 4 * s, 2 * s, C(0x4A505C))
            }
        }
    }

    /// What moves in the village: the clock's hands going round, crows perched on the church towers and the bare
    /// trees flapping now and then and a few more flying over, a fine grey drizzle; on the screen saver smoke rising
    /// from the chimneys.
    static func everglotVillageLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = evFrame(c, g), k = f.k
        if tall {
            for roof in evRoofs(c, g) {
                guard let ch = roof.chimney else { continue }
                let fog = Double(roof.row) * 0.13
                for j in 0..<4 {
                    let p = frac(t * 0.12 + Double(j) / 4 + noise(ch + roof.row))
                    let x = ch + s + Int(p * Double(10 * s) + sin(t + Double(j)) * Double(s))
                    let y = roof.y - 3 * s - Int(p * Double(20 * s))
                    c.circle(x, y, s + Int(p * Double(3 * s)), C(0xA8AEB8, (1 - p) * 0.35 * (1 - fog)))
                }
            }
        }
        // The clock's hands.
        let cl = f.clock
        let mins = t / 60 * 2 * .pi - .pi / 2, hours = t / 720 * 2 * .pi - .pi / 2 + 2.2
        let long = Double(cl.r - k), short = Double(cl.r - 2 * k)
        burtonLine(c, Double(cl.x), Double(cl.y), Double(cl.x) + cos(mins) * long, Double(cl.y) + sin(mins) * long,
                   C(0x1A1E26), max(0.45, Double(k) * 0.45))
        burtonLine(c, Double(cl.x), Double(cl.y), Double(cl.x) + cos(hours) * short, Double(cl.y) + sin(hours) * short,
                   C(0x1A1E26), max(0.5, Double(k) * 0.6))
        // Crows perched up high, flapping now and then.
        let ch = f.church, top = g - 50 * k
        let perches = [(ch.x - ch.w / 2 + 2 * k, top - 9 * k), (ch.x + ch.w / 2 - 6 * k, top - 9 * k),
                       (ch.x - 3 * k, g - 46 * k - k), (f.tower.x - 6 * k, f.tower.top + 15 * k)]
        let crow = C(0x101218)
        for (i, p) in perches.enumerated() {
            let flap = noise(Int(t * 3) * 5 + i * 11) > 0.8
            let art = flap ? ["K.....K", "KK.K.KK", "..KKK..", "...K..."] : ["..KK...", ".KKKK..", "..KKKK.", "...K..."]
            c.pattern(p.0, p.1 - 4 * s, bjScale(art, s), ["K": crow])
        }
        // Crows flying over now and then.
        let cyc = frac(t / 11)
        if cyc < 0.6 {
            for j in 0..<3 {
                let x = c.w + 20 * s - Int(cyc / 0.6 * Double(c.w + 60 * s)) + j * 12 * s
                let y = g / 5 + j * 4 * s + Int(sin(t * 3 + Double(j)) * Double(2 * s))
                let up = Int(t * 7 + Double(j)) % 2 == 0
                c.pattern(x, y, bjScale(up ? ["K...K", ".KKK.", "..K.."] : [".KKK.", "K.K.K", "....."], s), ["K": crow])
            }
        }
        // The drizzle.
        for i in 0..<(c.w * g / 140) {
            let x0 = noise(i * 3 + 5700) * Double(c.w + g / 3), speed = 60 + noise(i * 3 + 5701) * 30
            let y = (noise(i * 3 + 5702) * Double(g) + t * speed).truncatingRemainder(dividingBy: Double(g))
            let x = Int(x0) - Int(y / 3)
            for j in 0..<3 { c.px(x - j, y.isFinite ? Int(y) + j * 2 : 0, C(0xC8D0DA, 0.22)) }
        }
    }
}

// MARK: - Sleepy Hollow

extension Scenes {
    /// Sleepy Hollow's layout: the size unit, the covered bridge (left edge, width), the manor (left edge, width),
    /// and the lantern's hook.
    static func hvFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, bridge: (x: Int, w: Int), manor: (x: Int, w: Int),
                                                       lantern: (x: Int, y: Int)) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        return (k, (c.w * 3 / 100, 64 * k), (c.w * 74 / 100, 70 * k), (c.w * 3 / 100 + 64 * k + 10 * k, g - 26 * k))
    }

    /// A Dutch house: walls and a stepped gable facing the street, a door, lit windows; `k` the unit.
    private static func hvHouse(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, k: Int, wall: Px, seed: Int) {
        let shade = lerp(wall, C(0x201C18), 0.3), lamp = C(0xE0B868), dark = C(0x2A241E)
        c.rect(x, base - h, w, h, wall); c.rect(x + w - k, base - h, k, h, shade)
        // The stepped gable: steps of `st` across and up, to a little chimney-like top.
        let steps = 4, st = max(k, w / (2 * steps + 1)), sh = 3 * k
        for i in 0..<steps {
            let inset = i * st
            c.rect(x + inset, base - h - (i + 1) * sh, w - inset * 2, sh, wall)
            c.rect(x + w - inset - k, base - h - (i + 1) * sh, k, sh, shade)
            c.rect(x + inset, base - h - (i + 1) * sh, st, k, lerp(wall, C(0xF0EEE8), 0.3))
        }
        c.rect(x + w / 2 - k, base - h - (steps + 1) * sh, 2 * k, sh, shade)
        // A window up in the gable and two below, some lit; the door.
        c.rect(x + w / 2 - k, base - h - 2 * sh, 2 * k, 3 * k, noise(seed) > 0.5 ? lamp : dark)
        for wx in [x + 2 * k, x + w - 5 * k] {
            c.rect(wx, base - h + 3 * k, 3 * k, 4 * k, noise(seed + wx) > 0.4 ? lamp : dark)
            c.rect(wx + k, base - h + 3 * k, max(1, k / 2), 4 * k, shade)
        }
        c.rect(x + w / 2 - k, base - 6 * k, 3 * k, 6 * k, dark)
    }

    /// Sleepy Hollow: a misty Dutch village in sepia and grey under a white sky. Bare trees fade into the mist behind;
    /// the dark covered bridge crosses the stream on the left; a row of stepped-gable houses with warm windows; the Van
    /// Tassel manor on its rise to the right, every window lit; black bare trees at the edges, a lantern hanging from
    /// its post by the bridge. On the screen saver the church spire stands on its hill against the white sky among big
    /// bare trees.
    static func hollowVillage(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hvFrame(c, g), k = f.k
        let sky = C(0xEEECE6), haze = C(0xD2CEC4)
        c.gradient(0, g, sky, haze, bands: 6)
        if tall {
            // The church on its hill, and big bare trees reaching up into the white sky.
            let hx = c.w * 56 / 100, hb = g - 40 * s
            c.ellipse(hx, hb, c.w * 30 / 100, 46 * s, C(0xB4AEA2))
            let cx = hx - 8 * s, ctop = hb - 74 * s
            c.rect(cx - 18 * s, ctop + 20 * s, 36 * s, 34 * s, C(0x8A8478))
            let eaves = Double(ctop + 20 * s)
            burtonTriangle(c, (Double(cx - 20 * s), eaves), (Double(cx + 20 * s), eaves),
                           (Double(cx), Double(ctop + 6 * s)), C(0x4A443C))
            c.rect(cx - 5 * s, ctop - 4 * s, 10 * s, 24 * s, C(0x9A9488))
            c.rect(cx + 3 * s, ctop - 4 * s, 2 * s, 24 * s, C(0x7A746A))
            c.rect(cx - 2 * s, ctop + 2 * s, 4 * s, 6 * s, C(0x3A342E))
            burtonTriangle(c, (Double(cx - 6 * s), Double(ctop - 4 * s)), (Double(cx + 6 * s), Double(ctop - 4 * s)),
                           (Double(cx), Double(ctop - 50 * s)), C(0x3A342E))
            c.rect(cx, ctop - 56 * s, s, 6 * s, C(0x3A342E))
            for i in 0..<3 { c.rect(cx - 12 * s + i * 9 * s, ctop + 30 * s, 4 * s, 8 * s, C(0x5A544A)) }
            c.rect(0, g - 120 * s, c.w, 30 * s, sky.alpha(0.25))
            let trees = [(c.w * 8 / 100, 200), (c.w * 24 / 100, 150), (c.w * 86 / 100, 210), (c.w * 72 / 100, 130)]
            for (i, (tx, th)) in trees.enumerated() {
                hvTree(c, x: tx, base: g, h: th * s, col: i % 2 == 0 ? C(0x2A2622) : C(0x6A645A), seed: tx + 5800,
                       width: Double(s) * (i % 2 == 0 ? 3.5 : 2.2))
            }
        }
        // Far trees fading into the mist, then the mist itself.
        for i in 0..<16 {
            let tx = Int(noise(i + 5810) * Double(c.w)), th = (20 + Int(noise(i + 5811) * 16)) * k
            hvTree(c, x: tx, base: g - 8 * k, h: th, col: C(0xB2ACA0), seed: i + 5812, width: Double(k) * 0.9)
        }
        c.dunes(base: g - 12 * k, amp: 3 * Double(k), freq: 0.02, phase: 0.9, bottom: g, C(0xA8A296))
        c.rect(0, g - 20 * k, c.w, 10 * k, sky.alpha(0.35))
        // The stream on the left.
        let b = f.bridge
        c.rect(0, g - 4 * k, b.x + b.w + 6 * k, 4 * k, C(0x7A7C78))
        c.rect(0, g - 4 * k, b.x + b.w + 6 * k, max(1, k / 2), C(0xC8C8C2))
        // The covered bridge: stone abutments, a long dark wooden barn of a span, a pitched roof, little windows.
        let wood = C(0x4A3E34), woodD = C(0x342A22), roof = C(0x2A241E), bb = g - 4 * k
        c.rect(b.x - 2 * k, bb - 2 * k, 6 * k, 6 * k, C(0x8A8478))
        c.rect(b.x + b.w - 4 * k, bb - 2 * k, 6 * k, 6 * k, C(0x8A8478))
        c.rect(b.x, bb - 14 * k, b.w, 12 * k, wood)
        for x in stride(from: b.x, to: b.x + b.w, by: 3 * k) { c.rect(x, bb - 14 * k, max(1, k / 2), 12 * k, woodD) }
        for x in stride(from: b.x + 6 * k, to: b.x + b.w - 8 * k, by: 12 * k) {
            c.rect(x, bb - 10 * k, 4 * k, 2 * k, C(0x1A1612))
        }
        for r in 0..<(6 * k) {
            c.rect(b.x - 3 * k + r / 2, bb - 14 * k - r - 1, b.w + 6 * k - r, 1, r < k ? C(0x4A423A) : roof)
        }
        c.rect(b.x - 2 * k, bb - 12 * k, 3 * k, 10 * k, C(0x14100C))
        c.rect(b.x + b.w - k, bb - 12 * k, 3 * k, 10 * k, C(0x14100C))
        // The lantern's post (the lantern swings in the moving layer).
        let l = f.lantern
        c.rect(l.x - 6 * k, l.y - 2 * k, max(1, k), g - l.y + 2 * k, C(0x2A2420))
        c.rect(l.x - 6 * k, l.y - 2 * k, 7 * k, k, C(0x2A2420))
        // The village: stepped-gable Dutch houses.
        let walls = [C(0x8A7E6C), C(0x6E6456), C(0x9A9080), C(0x7A6A58)]
        var x = b.x + b.w + 16 * k, i = 0
        while x < f.manor.x - 14 * k {
            let w = (16 + Int(noise(i + 5820) * 6)) * k, h = (12 + Int(noise(i + 5821) * 8)) * k
            hvHouse(c, x: x, base: g, w: w, h: h, k: k, wall: walls[i % walls.count], seed: i * 7 + 5822)
            x += w + (3 + Int(noise(i + 5823) * 6)) * k; i += 1
        }
        // The Van Tassel manor on its rise: two storeys, a gambrel roof, a central gable, every window lit, a fence.
        let m = f.manor, mb = g - 4 * k, mh = 22 * k, mwall = C(0xA49A88), mshade = C(0x7A7062), lamp = C(0xF0C870)
        c.ellipse(m.x + m.w / 2, g, m.w / 2 + 20 * k, 6 * k, C(0x8E887C))
        c.rect(m.x, mb - mh, m.w, mh, mwall); c.rect(m.x + m.w - 2 * k, mb - mh, 2 * k, mh, mshade)
        for r in 0..<(10 * k) {
            let inset = r < 5 * k ? r / 2 : 5 * k / 2 + (r - 5 * k) * 2
            c.rect(m.x - 2 * k + inset, mb - mh - r - 1, m.w + 4 * k - inset * 2, 1, r < k ? C(0x5A5248) : C(0x3A342E))
        }
        let mid = Double(m.x + m.w / 2), eaves = Double(mb - mh)
        burtonTriangle(c, (mid - Double(12 * k), eaves), (mid + Double(12 * k), eaves), (mid, eaves - Double(14 * k)),
                       mwall)
        c.rect(m.x + m.w / 2 - 2 * k, mb - mh - 8 * k, 4 * k, 4 * k, lamp)
        for cx in [m.x + 6 * k, m.x + m.w - 9 * k] { c.rect(cx, mb - mh - 14 * k, 3 * k, 8 * k, mshade) }
        for row in 0..<2 {
            for wx in stride(from: m.x + 4 * k, to: m.x + m.w - 6 * k, by: 9 * k) {
                let wy = mb - mh + 3 * k + row * 10 * k
                guard !(row == 1 && abs(wx + 2 * k - (m.x + m.w / 2)) < 6 * k) else { continue }
                c.rect(wx, wy, 4 * k, 6 * k, lamp); c.rect(wx + 2 * k, wy, max(1, k / 2), 6 * k, mshade)
                c.circle(wx + 2 * k, wy + 3 * k, 4 * k, lamp.alpha(0.12))
            }
        }
        c.rect(m.x + m.w / 2 - 3 * k, mb - 9 * k, 6 * k, 9 * k, C(0x2A241E))
        c.rect(m.x + m.w / 2 - 2 * k, mb - 8 * k, 4 * k, 3 * k, lamp)
        for fx in stride(from: m.x - 16 * k, to: m.x + m.w + 16 * k, by: 3 * k) {
            c.rect(fx, g - 5 * k, max(1, k), 5 * k, C(0xE8E4DA))
        }
        c.rect(m.x - 16 * k, g - 4 * k, m.w + 32 * k, max(1, k), C(0xE8E4DA))
        // Black bare trees at the edges, close.
        hvTree(c, x: c.w * 1 / 100, base: g + 2 * s, h: 64 * k, col: C(0x1E1A16), seed: 5830, width: Double(k) * 2.4)
        hvTree(c, x: c.w * 99 / 100, base: g + 2 * s, h: 60 * k, col: C(0x1E1A16), seed: 5831, width: Double(k) * 2.4)
        hvTree(c, x: c.w * 66 / 100, base: g, h: 38 * k, col: C(0x2E2A24), seed: 5832, width: Double(k) * 1.4)
        // The muddy lane, fallen leaves on it.
        c.ground(g, C(0x5A5248), edge: C(0x8A8274), speck: C(0x4A4238), seed: 583)
        for i in 0..<(c.w / 6) {
            c.rect(Int(noise(i + 5840) * Double(c.w)), g + 1 + Int(noise(i + 5841) * Double(max(1, c.h - g - 2))), s, s,
                   noise(i + 5842) > 0.5 ? C(0x8A5A2A) : C(0x6A4A2A))
        }
    }

    /// What moves in Sleepy Hollow: banks of mist drifting slowly through the village and along the lane, and the
    /// lantern by the bridge swinging on its hook, its glow swinging with it.
    static func hollowVillageLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hvFrame(c, g), k = f.k
        for i in 0..<10 {
            let span = Double(c.w + 300 * s)
            let drift = noise(i + 5900) * span + t * (4 + noise(i + 5901) * 5)
            let x = drift.truncatingRemainder(dividingBy: span) - Double(150 * s)
            let y = g - Int(noise(i + 5902) * Double(16 * k)), rx = (40 + Int(noise(i + 5903) * 50)) * s
            c.ellipse(Int(x), y, rx, (2 + Int(noise(i + 5904) * 3)) * k, C(0xF4F2EC, 0.22))
        }
        // The lantern swinging.
        let l = f.lantern, a = sin(t * 1.8) * 0.35
        let len = 5.0 * Double(k), hx = Double(l.x - 6 * k + 6 * k), hy = Double(l.y - k)
        let lx = hx + sin(a) * len, ly = hy + cos(a) * len
        burtonLine(c, hx, hy, lx, ly, C(0x2A2420), max(0.4, Double(k) * 0.35))
        let bx = Int(lx) - k, by = Int(ly)
        c.circle(bx + k, by + 3 * k, 7 * k, C(0xF0C060, 0.12)); c.circle(bx + k, by + 3 * k, 4 * k, C(0xF0C060, 0.16))
        c.rect(bx - k / 2, by, 3 * k, k, C(0x2A2420)); c.rect(bx - k / 2, by + k, 3 * k, 4 * k, C(0xF4C860))
        c.rect(bx + k / 2, by + k, max(1, k / 2), 4 * k, C(0xFFF0C0))
        c.rect(bx - k / 2, by + 5 * k, 3 * k, k, C(0x2A2420))
    }
}
