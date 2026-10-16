import Foundation

// Jurassic Park: the park gates, the visitor centre and the T. rex paddock.

let clawdbergScenes8: [Location: Place] = [
    .parkGates: Place(name: "The Park Gates", panel: 0x141E18, still: Scenes.parkGates, moving: Scenes.parkGatesLife),
    .visitorCentre: Place(name: "The Visitor Centre", panel: 0x261E14, still: Scenes.visitorCentre,
                          moving: Scenes.visitorCentreLife),
    .rexPaddock: Place(name: "The T. Rex Paddock", panel: 0x0C1214, still: Scenes.rexPaddock, moving: Scenes.rexPaddockLife),
]

// MARK: - Shared bits for the park

/// A hard pixel line with no glow (bones, cables, poles).
private func jpLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px,
                    _ r: Double = 0.5) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.01)
}

/// The park's lettering, a 3×5 pixel font with only the letters its signs need.
private let jpGlyphs: [Character: [String]] = [
    "A": [".#.", "#.#", "###", "#.#", "#.#"], "C": [".##", "#..", "#..", "#..", ".##"],
    "D": ["##.", "#.#", "#.#", "#.#", "##."], "E": ["###", "#..", "##.", "#..", "###"],
    "G": [".##", "#..", "#.#", "#.#", ".##"], "H": ["#.#", "#.#", "###", "#.#", "#.#"],
    "I": ["###", ".#.", ".#.", ".#.", "###"], "J": ["..#", "..#", "..#", "#.#", ".#."],
    "K": ["#.#", "#.#", "##.", "#.#", "#.#"], "L": ["#..", "#..", "#..", "#..", "###"],
    "N": ["#.#", "###", "###", "#.#", "#.#"], "O": [".#.", "#.#", "#.#", "#.#", ".#."],
    "P": ["##.", "#.#", "##.", "#..", "#.."], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
    "S": [".##", "#..", ".#.", "..#", "##."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "U": ["#.#", "#.#", "#.#", "#.#", "###"], "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"],
    " ": ["..", "..", "..", "..", ".."],
]

/// How wide `text` comes out in the park's font, in units.
private func jpTextWidth(_ text: String) -> Int {
    text.reduce(0) { $0 + (jpGlyphs[$1]?[0].count ?? 3) + 1 } - 1
}

/// Text in the park's font, centred on `cx`, each font pixel `s` × `s`; `shade` adds a drop shadow down and right.
private func jpText(_ c: PixelCanvas, _ text: String, cx: Int, y: Int, s: Int, col: Px, shade: Px? = nil) {
    var x = cx - jpTextWidth(text) * s / 2
    for ch in text {
        let rows = jpGlyphs[ch] ?? jpGlyphs[" "]!
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" {
                if let shade { c.rect(x + dx * s + max(1, s / 2), y + dy * s + max(1, s / 2), s, s, shade) }
                c.rect(x + dx * s, y + dy * s, s, s, col)
            }
        }
        x += (rows[0].count + 1) * s
    }
}

/// A palm or tree fern: a leaning ringed trunk `h` rows tall from (`x`, `base`) and a crown of drooping fronds with
/// leaflets hanging off them.
private func jpPalm(_ c: PixelCanvas, x: Int, base: Int, h: Int, lean: Int, trunk: Px, leaf: Px, s: Int) {
    for i in 0..<h {
        let off = lean * i * i / max(1, h * h)
        c.rect(x + off, base - i, 2 * s, 1, trunk)
        if i % (3 * s) == 0 { c.rect(x + off - s / 2, base - i, 3 * s, 1, trunk.alpha(0.7)) }
    }
    let tx = Double(x + lean + s), ty = Double(base - h)
    let len = Double(h) * 0.3 + Double(8 * s)
    for k in 0..<8 {
        let dir = Double(k) / 7 * 2 - 1                       // -1 (left) … 1 (right)
        let reach = len * (0.55 + 0.45 * abs(dir))
        var px = tx, py = ty
        for step in 1...10 {
            let f = Double(step) / 10
            let nx = tx + dir * reach * f
            let lift = (1 - abs(dir)) * len * 0.45 * f
            let ny = ty - lift + f * f * len * 0.6
            jpLine(c, px, py, nx, ny, leaf, Double(s) * 0.9)
            if step % 2 == 0 && step < 10 {
                let drop = Double(s) * (2.5 - f)
                jpLine(c, nx, ny, nx - dir * Double(s), ny + drop, leaf, Double(s) * 0.6)
                jpLine(c, nx, ny, nx + dir * Double(s), ny + drop, leaf, Double(s) * 0.6)
            }
            px = nx; py = ny
        }
    }
}

/// A band of jungle: rounded crowns along a ragged line `top`, filled down to `bottom`.
private func jpJungle(_ c: PixelCanvas, top: Int, bottom: Int, col: Px, seed: Int, size: Int) {
    c.rect(0, top + size, c.w, max(0, bottom - top - size), col)
    var x = -size
    var k = 0
    while x < c.w + size {
        let r = size / 2 + Int(noise(seed * 97 + k) * Double(size))
        let y = top + size - Int(noise(seed * 97 + k + 50) * Double(size))
        c.ellipse(x, y + r / 2, r, max(1, r * 2 / 3), col)
        x += max(2, r * 3 / 2); k += 1
    }
}

// MARK: - The Park Gates

extension Scenes {
    /// Where the gates stand: the middle, the opening's half-width, a pylon's width, the pylons' top row, the beam's
    /// top row and depth, the sign lettering's pixel size, how high the torch baskets sit over the pylons' tops and
    /// how tall their flames burn. In the window's strip the whole gate sits low enough for the flames to fit under
    /// the top edge and the board stays above the crew's heads.
    private static func jpGatesFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, gap: Int, pw: Int, top: Int, beam: Int,
                                                                      beamH: Int, k: Int, lift: Int, flame: Int) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w / 2
        if tall { return (cx, 78 * s, 40 * s, g - 250 * s, g - 226 * s, 28 * s, 2 * s, 8 * s, 5 * s) }
        let top = max(9 * s, g - 56 * s)
        return (cx, 46 * s, 22 * s, top, top + s, 9 * s, s, 5 * s, 3 * s)
    }

    /// The gates of the park: a grey-green misty sky over layered jungle and tree ferns, a log palisade running off
    /// both ways, and in the middle the two huge timber pylons with iron bands and a torch basket on each, the doors
    /// swung open inwards and the great beam across the top with JURASSIC PARK in red and gold on its board. A muddy
    /// track runs through. On the screen saver the gates stand in full: the pylons climbing high out of the mist,
    /// the red disc with the skeleton over the lettering, more jungle and ferns above.
    static func parkGates(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = jpGatesFrame(c, g)
        c.gradient(0, g, C(0x46564C), C(0x9AA89A), bands: 7)
        if tall {
            // The island's peaks, green and craggy, half lost in cloud.
            c.dunes(base: g - 190 * s, amp: Double(26 * s), freq: 0.021, phase: 1.3, bottom: g, C(0x64786A))
            c.dunes(base: g - 168 * s, amp: Double(18 * s), freq: 0.034, phase: 4.1, bottom: g, C(0x5A6E60))
            for i in 0..<10 {
                let x = Int(noise(i * 3 + 480) * Double(c.w)), y = g - 230 * s + Int(noise(i * 3 + 481) * 70) * s
                c.ellipse(x, y, (40 + Int(noise(i * 3 + 482) * 50)) * s, 7 * s, C(0xB4C2B4, 0.45))
            }
        }
        // Jungle: three bands, the far one pale with mist, the near one dark, with tree ferns sticking up.
        let farTop = tall ? g - 150 * s : g - 40 * s
        jpJungle(c, top: farTop, bottom: g, col: C(0x6E8270), seed: 1, size: (tall ? 22 : 10) * s)
        for i in 0..<(tall ? 9 : 6) {
            let x = Int(noise(i * 7 + 400) * Double(c.w)), h = (tall ? 150 : 40) * s + Int(noise(i * 7 + 401) * 14) * s
            jpPalm(c, x: x, base: g, h: h, lean: Int((noise(i * 7 + 402) - 0.5) * 16) * s,
                   trunk: C(0x46483A), leaf: C(0x3A5A40), s: s)
        }
        c.rect(0, farTop + 6 * s, c.w, (tall ? 30 : 10) * s, C(0xB8C4B4, 0.25))
        let midTop = tall ? g - 90 * s : g - 30 * s
        jpJungle(c, top: midTop, bottom: g, col: C(0x3A5040), seed: 2, size: (tall ? 16 : 8) * s)
        // The palisade: sharpened logs either side of the gates.
        let wallTop = tall ? g - 84 * s : g - 22 * s
        let logW = (tall ? 7 : 5) * s
        var lx = 0
        while lx < c.w {
            let left = lx + logW <= f.cx - f.gap - f.pw, right = lx >= f.cx + f.gap + f.pw
            if left || right {
                let jag = Int(noise(lx / max(1, logW) + 90) * 4) * s
                let top = wallTop + jag
                c.rect(lx, top + 2 * s, logW - s, g - top - 2 * s, C(0x5A4430))
                c.rect(lx, top + 2 * s, s, g - top - 2 * s, C(0x76583C))
                c.rect(lx + logW - 2 * s, top + 2 * s, s, g - top - 2 * s, C(0x42301E))
                c.rect(lx + s, top, max(1, logW - 3 * s), 2 * s, C(0x6A5038))
                c.rect(lx + logW / 2 - s / 2, top - s, s, s, C(0x6A5038))
            }
            lx += logW
        }
        let rail = wallTop + (tall ? 24 : 7) * s
        c.rect(0, rail, f.cx - f.gap - f.pw, 2 * s, C(0x3A2A1A))
        c.rect(f.cx + f.gap + f.pw, rail, c.w, 2 * s, C(0x3A2A1A))
        // Vines down the palisade.
        for i in 0..<(tall ? 14 : 8) {
            let vx = Int(noise(i * 5 + 600) * Double(c.w))
            if abs(vx - f.cx) < f.gap + f.pw + 4 * s { continue }
            let len = (8 + Int(noise(i * 5 + 601) * 20)) * s * (tall ? 3 : 1)
            for y in stride(from: wallTop, to: min(g, wallTop + len), by: s) {
                c.rect(vx + Int(sin(Double(y) * 0.4) * 1.2), y, s, s, C(0x3E6A3A))
            }
        }
        // The track through the opening, between the doors.
        for y in g..<c.h {
            let k = Double(y - g) / Double(max(1, c.h - g))
            let half = Int(Double(f.gap) * (0.5 + 0.5 * k))
            c.rect(f.cx - half, y, half * 2, 1, C(0x5A4A36))
        }
        // The doors, swung open inwards: dark plank leaves narrowing away from the pylons.
        let doorTop = f.beam + f.beamH
        let dw = f.gap * 2 / 5
        for i in 0..<dw {
            let drop = i * (tall ? 10 : 4) / max(1, dw / 2)
            let y0 = doorTop + drop, y1 = g - i / 3
            let shade = (i / max(1, 3 * s)) % 2 == 0 ? C(0x3A2C1E) : C(0x32261A)
            c.rect(f.cx - f.gap + i, y0, 1, max(0, y1 - y0), shade)
            c.rect(f.cx + f.gap - 1 - i, y0, 1, max(0, y1 - y0), shade)
        }
        // The pylons: stacked logs, iron bands, a capped top.
        for side in [-1, 1] {
            let px = side < 0 ? f.cx - f.gap - f.pw : f.cx + f.gap
            for x in stride(from: px, to: px + f.pw, by: 3 * s) {
                let w = min(3 * s, px + f.pw - x)
                c.rect(x, f.top, w, g - f.top, C(0x6E5236))
                c.rect(x, f.top, s, g - f.top, C(0x8A6A48))
                c.rect(x + w - s, f.top, s, g - f.top, C(0x4A3624))
            }
            for i in 0..<(tall ? 70 : 20) {
                let bx = px + Int(noise(i * 3 + 700 + side) * Double(f.pw)), by = f.top + Int(noise(i * 3 + 701) * Double(g - f.top))
                c.rect(bx, by, s, 2 * s, C(0x4A3624, 0.7))
            }
            for band in stride(from: f.top + (tall ? 70 : 20) * s, to: g - 4 * s, by: (tall ? 46 : 16) * s) {
                c.rect(px - s, band, f.pw + 2 * s, 2 * s, C(0x2E2C2A)); c.rect(px - s, band, f.pw + 2 * s, s, C(0x5A5650))
            }
            c.rect(px - 2 * s, f.top - 2 * s, f.pw + 4 * s, 3 * s, C(0x4A3624))
            c.rect(px - 2 * s, f.top - 2 * s, f.pw + 4 * s, s, C(0x7A5E40))
            // The torch basket on its bracket.
            let tx = px + f.pw / 2, bt = f.top - f.lift
            c.circle(tx, bt - s, 2 * f.flame, C(0xF0A040, 0.08)); c.circle(tx, bt - s, f.flame + s, C(0xF0A040, 0.1))
            c.rect(tx - s / 2, bt + 3 * s, s, f.lift - 4 * s, C(0x2A2420))
            c.rect(tx - 3 * s, bt + s, 6 * s, 2 * s, C(0x3A322A)); c.rect(tx - 2 * s, bt + 3 * s, 4 * s, s, C(0x2A2420))
            c.rect(tx - 2 * s, bt, 4 * s, s, C(0xE89A3A))
        }
        // The beam and its board.
        let bl = f.cx - f.gap - f.pw - 4 * s, bw = (f.gap + f.pw + 4 * s) * 2
        c.rect(bl, f.beam, bw, f.beamH, C(0x5A422C))
        c.rect(bl, f.beam, bw, s, C(0x8A6A48)); c.rect(bl, f.beam + f.beamH - s, bw, s, C(0x3A2A1A))
        let text = "JURASSIC PARK"
        let tw = jpTextWidth(text) * f.k
        let board = (x: f.cx - tw / 2 - 3 * f.k, y: f.beam + (f.beamH - 7 * f.k) / 2, w: tw + 6 * f.k, h: 7 * f.k)
        c.rect(board.x, board.y, board.w, board.h, C(0x2A1E14))
        c.rect(board.x, board.y, board.w, max(1, f.k / 2), C(0x6A4E32))
        jpText(c, text, cx: f.cx, y: board.y + f.k, s: f.k, col: C(0xF0B832), shade: C(0xB02A1A))
        if tall {
            // The red disc with the skeleton, over the lettering.
            let dy = f.beam - 14 * s
            c.circle(f.cx, dy, 16 * s, C(0x2A1E14)); c.circle(f.cx, dy, 14 * s, C(0xD8341E)); c.circle(f.cx, dy, 12 * s, C(0xE8D8B0))
            c.circle(f.cx, dy, 10 * s, C(0xD8341E))
            let rex: [String] = [
                "......####..",
                ".....##.###.",
                "....######..",
                "...###......",
                ".#####......",
                "######......",
                "..####......",
                "..#..#......",
                ".##.##......",
            ]
            for (ry, row) in rex.enumerated() {
                for (rx, p) in row.enumerated() where p == "#" {
                    c.rect(f.cx - 7 * s + rx * s * 5 / 4, dy - 6 * s + ry * s * 4 / 3, s * 2, s * 2, C(0x16120E))
                }
            }
        }
        // The track's mud, rutted.
        c.ground(g, C(0x4A3C2C), edge: C(0x6A5840), speck: C(0x3A2E22), seed: 81)
        for y in stride(from: g + 2, to: c.h, by: 3) {
            let k = Double(y - g) / Double(max(1, c.h - g))
            let half = Int(Double(f.gap) * (0.3 + 0.3 * k))
            c.rect(f.cx - half, y, 2 * s, 1, C(0x2E241A)); c.rect(f.cx + half - 2 * s, y, 2 * s, 1, C(0x2E241A))
        }
    }

    /// What moves at the gates: the torches burning in their baskets, sparks lifting off them, and banks of mist
    /// drifting slowly across the jungle.
    static func parkGatesLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = jpGatesFrame(c, g)
        // Mist.
        let mistY = tall ? g - 140 * s : g - 34 * s
        for i in 0..<5 {
            let speed = 4 + noise(i + 900) * 5
            let span = Double(c.w + 200)
            let x = Int((noise(i + 910) * span + t * speed).truncatingRemainder(dividingBy: span)) - 100
            let y = mistY + Int(noise(i + 920) * Double((tall ? 100 : 24) * s))
            c.ellipse(x, y, (60 + Int(noise(i + 930) * 50)) * s, (tall ? 8 : 3) * s, C(0xD8E0D4, 0.14))
        }
        // The torches.
        for side in [-1, 1] {
            let px = side < 0 ? f.cx - f.gap - f.pw : f.cx + f.gap
            let tx = Double(px + f.pw / 2), base = Double(f.top - f.lift)
            let flick = sin(t * 13 + Double(side) * 2) * 0.5 + sin(t * 7.3 + Double(side)) * 0.5
            let height = Double(f.flame) + flick * Double(s) * (tall ? 1.5 : 0.8)
            let lean = sin(t * 3 + Double(side)) * Double(s)
            c.glowLine(tx, base, tx + lean, base - height, core: C(0xFFE08A), glow: C(0xF0782A),
                       coreR: Double(s) * 1.1, glowR: Double(s) * (tall ? 3.2 : 2.4))
            c.glowLine(tx - Double(s), base, tx + lean * 1.5, base - height * 0.6, core: C(0xFFF4C8), glow: C(0, 0),
                       coreR: Double(s) * 0.6, glowR: Double(s) * 0.61)
            for k in 0..<3 {
                let life = (t * 0.9 + Double(k) / 3 + Double(side) * 0.17).truncatingRemainder(dividingBy: 1)
                let sx = Int(tx + sin(t * 2 + Double(k * 3)) * Double(3 * s))
                let sy = Int(base - height - life * Double((tall ? 16 : 4) * s))
                c.rect(sx, sy, s, s, C(0xFFB050, 1 - life))
            }
        }
    }
}

// MARK: - The Visitor Centre

extension Scenes {
    /// Where the rotunda's things are: the skeletons' feet, their size, the fan's hub and the banner's top row.
    private static func jpCentreFrame(_ c: PixelCanvas, _ g: Int) -> (brachX: Int, rexX: Int, k: Double,
                                                                       fan: (x: Int, y: Int, r: Int), banner: Int) {
        let s = unit(g), tall = isTall(c)
        if tall {
            return (c.w * 30 / 100, c.w * 70 / 100, 3.6 * Double(s), (c.w * 86 / 100, g - 236 * s, 22 * s), g - 270 * s)
        }
        return (c.w * 26 / 100, c.w * 72 / 100, Double(s), (c.w * 88 / 100, 3 * s, 10 * s), s)
    }

    /// One skeleton from a list of bone chains, each chain a run of points in units scaled by `k` from the feet at
    /// (`x`, `g`), with a knuckle on every joint.
    private static func jpBones(_ c: PixelCanvas, x: Int, g: Int, k: Double, chains: [[(Double, Double)]], bone: Px,
                                joint: Px) {
        let r = max(0.65, k * 0.55)
        for chain in chains {
            for (a, b) in zip(chain, chain.dropFirst()) {
                jpLine(c, Double(x) + a.0 * k, Double(g) + a.1 * k, Double(x) + b.0 * k, Double(g) + b.1 * k, bone, r)
            }
            for p in chain {
                let jx = Int(Double(x) + p.0 * k), jy = Int(Double(g) + p.1 * k)
                c.rect(jx, jy, max(1, Int(k)), max(1, Int(k)), joint)
            }
        }
    }

    /// The tall sauropod, facing right, its long neck reaching up and its tail sweeping down to the floor behind.
    private static func jpBrachio(_ c: PixelCanvas, x: Int, g: Int, k: Double) {
        let spine: [(Double, Double)] = [(-44, -2), (-36, -9), (-26, -17), (-14, -23), (-4, -26), (8, -28)]
        let neck: [(Double, Double)] = [(8, -28), (13, -36), (17, -46), (20, -56), (22, -62)]
        let head: [(Double, Double)] = [(21, -63), (25, -65), (29, -63), (25, -61), (21, -63)]
        let legs: [[(Double, Double)]] = [
            [(8, -28), (10, -15), (9, 0), (12, 0)], [(4, -27), (3, -14), (4, 0), (7, 0)],
            [(-14, -23), (-11, -12), (-13, 0), (-10, 0)], [(-17, -22), (-19, -11), (-17, 0), (-14, 0)],
        ]
        var chains = [spine, neck, head] + legs
        for i in 0..<7 {
            let rx = -12 + Double(i) * 3, top = -23.5 - Double(i) * 0.6
            let depth = 9 - abs(Double(i) - 3) * 1.2
            chains.append([(rx, top), (rx + 1.5, top + depth * 0.6), (rx + 1, top + depth)])
        }
        jpBones(c, x: x, g: g, k: k, chains: chains, bone: C(0xEFE6CE), joint: C(0xB8A888))
        c.rect(x + Int(26 * k), g - Int(64 * k), max(1, Int(k)), max(1, Int(k)), C(0x3A2A1E))
    }

    /// The T. rex, facing left, head up and jaws wide, its tail held out straight behind.
    private static func jpRexBones(_ c: PixelCanvas, x: Int, g: Int, k: Double) {
        let jaw: [(Double, Double)] = [(-22, -31), (-28, -27), (-35, -25)]
        let spine: [(Double, Double)] = [(-21, -34), (-16, -32), (-11, -29), (-3, -27), (5, -26), (13, -25), (21, -22),
                                         (29, -18), (37, -13)]
        let arms: [[(Double, Double)]] = [[(-10, -24), (-8, -20), (-10, -18)]]
        let legs: [[(Double, Double)]] = [
            [(4, -25), (-1, -14), (3, -5), (-3, 0), (1, 0)], [(7, -25), (9, -13), (6, -5), (10, 0), (13, 0)],
        ]
        var chains = [jaw, spine] + arms + legs
        for i in 0..<6 {
            let rx = -9 + Double(i) * 2.6, top = -28.5 + Double(i) * 0.4
            let depth = 10 - abs(Double(i) - 2) * 1.4
            chains.append([(rx, top), (rx - 1.5, top + depth * 0.6), (rx, top + depth)])
        }
        jpBones(c, x: x, g: g, k: k, chains: chains, bone: C(0xEFE6CE), joint: C(0xB8A888))
        // The skull: a long deep wedge, filled, with its eye socket and the window behind it.
        for i in 0..<6 {
            let dy = Double(i) * 1.1
            let back = (-20.0, -38 + dy), snout = (-36.0, -35 + dy * 0.6)
            jpLine(c, Double(x) + back.0 * k, Double(g) + back.1 * k, Double(x) + snout.0 * k, Double(g) + snout.1 * k,
                   C(0xEFE6CE), max(0.6, k * 0.6))
        }
        c.rect(x - Int(25 * k), g - Int(37 * k), max(1, Int(k * 1.5)), max(1, Int(k * 1.5)), C(0x3A2A1E))
        c.rect(x - Int(30 * k), g - Int(35 * k), max(1, Int(k * 2)), max(1, Int(k)), C(0x6A5038))
        for i in 0..<5 {   // teeth along both jaws
            let tx = x - Int((34 - Double(i) * 2.6) * k)
            c.rect(tx, g - Int(31 * k), max(1, Int(k / 2)), max(1, Int(k)), C(0xFFFFF4))
            c.rect(tx, g - Int((27.5 - Double(i) * 0.6) * k), max(1, Int(k / 2)), max(1, Int(k)), C(0xFFFFF4))
        }
    }

    /// The rotunda of the visitor centre: warm sandstone walls with tall windows full of bright jungle, a cornice
    /// running round, the polished floor, and the two skeletons, the sauropod with scaffolding still round its neck
    /// and the T. rex roaring at it from across the hall. A ceiling fan hangs in the corner. On the screen saver the
    /// skeletons stand in full, huge, under the rotunda's ribbed ceiling and a balcony.
    static func visitorCentre(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = jpCentreFrame(c, g)
        c.gradient(0, g, C(0x7A5E3E), C(0xA0825A), bands: 5)
        // The tall windows: bright jungle behind mullions, round-headed.
        let winTop = tall ? g - 200 * s : 7 * s
        let winW = (tall ? 34 : 20) * s, pitch = (tall ? 62 : 58) * s
        for wx in stride(from: 10 * s, to: c.w - winW, by: pitch) {
            let wy = winTop + winW / 2
            c.ellipse(wx + winW / 2, wy, winW / 2 + s, winW / 2 + s, C(0x8A7050))
            c.rect(wx - s, wy, winW + 2 * s, g - wy - 4 * s, C(0x8A7050))
            c.ellipse(wx + winW / 2, wy, winW / 2, winW / 2, C(0x9EB884))
            c.rect(wx, wy, winW, g - wy - 5 * s, C(0x8AA874))
            for i in 0..<5 {   // leaves pressing on the glass
                let lx = wx + Int(noise(wx + i * 7) * Double(winW)), ly = wy + Int(noise(wx + i * 7 + 3) * Double(g - wy))
                c.ellipse(lx, ly, 4 * s, 2 * s, C(0x5E8450, 0.7))
            }
            c.rect(wx + winW / 2, winTop, s, g - winTop - 5 * s, C(0x5A4430))
            for y in stride(from: wy + 6 * s, to: g - 6 * s, by: (tall ? 22 : 10) * s) { c.rect(wx, y, winW, s, C(0x5A4430)) }
        }
        // The cornice.
        let cornice = tall ? g - 222 * s : 3 * s
        c.rect(0, cornice, c.w, 3 * s, C(0x5A4430)); c.rect(0, cornice, c.w, s, C(0xC8AE80))
        if tall {
            // The rotunda's ceiling: ribs fanning up from the cornice, and a balcony rail.
            c.rect(0, 0, c.w, cornice, C(0x6E5436))
            for i in 0..<13 {
                let bx = Double(c.w) * Double(i) / 12
                jpLine(c, bx, Double(cornice), Double(c.w / 2) + (bx - Double(c.w / 2)) * 0.3, 0, C(0x4E3A26), Double(s) * 1.2)
            }
            c.ellipse(c.w / 2, 0, 40 * s, 14 * s, C(0xE8DCB8))
            let bal = cornice + 20 * s
            c.rect(0, bal, c.w, 3 * s, C(0x5A4430))
            for bx in stride(from: 0, to: c.w, by: 6 * s) { c.rect(bx, bal + 3 * s, s, 9 * s, C(0x5A4430)) }
            c.rect(0, bal + 12 * s, c.w, 2 * s, C(0x5A4430))
        }
        // The scaffolding round the sauropod's neck.
        let scX = f.brachX + Int(14 * f.k), scTop = g - Int(60 * f.k)
        for px in [scX - Int(5 * f.k), scX + Int(12 * f.k)] { c.rect(px, scTop, s, g - scTop, C(0x7A7A7A)) }
        for y in stride(from: scTop + 2 * s, to: g, by: Int(12 * f.k)) {
            c.rect(scX - Int(5 * f.k), y, Int(17 * f.k) + s, s, C(0x7A7A7A))
            c.rect(scX - Int(5 * f.k), y - s, Int(17 * f.k) + s, s, C(0x9A7A50))
        }
        jpBrachio(c, x: f.brachX, g: g, k: f.k)
        jpRexBones(c, x: f.rexX, g: g, k: f.k)
        // The fan's rod and hub.
        let fan = f.fan
        c.rect(fan.x, 0, s, fan.y, C(0x3A2E22)); c.rect(fan.x - s, fan.y, 3 * s, 2 * s, C(0x3A2E22))
        // The floor: polished stone with the windows' light lying on it.
        c.ground(g, C(0x6A5038), edge: C(0xA88A62), speck: C(0x7A5E42), seed: 23)
        for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, g + 1, s, c.h - g - 1, C(0x5A422C)) }
        for wx in stride(from: 10 * s, to: c.w - winW, by: pitch) { c.rect(wx + 4 * s, g + 2, winW - 4 * s, 2, C(0xC8D8A0, 0.3)) }
    }

    /// What moves in the rotunda: the ceiling fan turning, and the banner that comes down. It hangs over the hall,
    /// WHEN DINOSAURS RULED THE EARTH, then lets go and flutters down to the floor, lies there a moment, and is back.
    static func visitorCentreLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = jpCentreFrame(c, g)
        // The fan's blades, seen from below at a slant.
        let fan = f.fan
        for b in 0..<4 {
            let a = t * 5 + Double(b) * .pi / 2
            let ex = Double(fan.x) + cos(a) * Double(fan.r), ey = Double(fan.y + s) + sin(a) * Double(fan.r) * 0.22
            c.glowLine(Double(fan.x), Double(fan.y + s), ex, ey, core: C(0x4A3A28), glow: C(0, 0),
                       coreR: Double(s) * 0.9, glowR: Double(s) * 0.91)
        }
        // The banner.
        let text = "WHEN DINOSAURS RULED THE EARTH"
        let k = tall ? 2 * s : s
        let bw = jpTextWidth(text) * k + 8 * k, bh = 9 * k
        let cycle = t.truncatingRemainder(dividingBy: 14)
        let bx = c.w / 2 - bw / 2
        if cycle < 8 {
            let wave = cycle
            for x in 0..<bw {
                let dy = Int(sin(Double(x) * 0.08 + wave * 2) * Double(k))
                c.rect(bx + x, f.banner + dy, 1, bh, C(0x8A2418))
                c.rect(bx + x, f.banner + dy + bh, 1, k, C(0x5A160E))
            }
            jpText(c, text, cx: c.w / 2, y: f.banner + 2 * k, s: k, col: C(0xF2E2B8))
            c.rect(bx, f.banner - k, bw, k, C(0x3A2A1E))
        } else if cycle < 10.5 {
            let k2 = (cycle - 8) / 2.5
            let fall = Int(k2 * k2 * Double(g - f.banner - bh))
            for x in 0..<bw {
                let dy = Int(sin(Double(x) * 0.1 + cycle * 9) * Double(2 * k) * (0.3 + k2))
                let droop = Int(Double(abs(x - bw / 2)) * 0.15 * k2)
                c.rect(bx + x, f.banner + fall + dy + droop, 1, bh, C(0x8A2418))
            }
        } else if cycle < 13 {
            let a = cycle < 12.5 ? 1 : (13 - cycle) * 2
            c.rect(bx, g - 2 * k, bw, 2 * k, C(0x8A2418, a))
            for i in 0..<12 { c.rect(bx + i * bw / 12, g - 3 * k, bw / 20, k, C(0x8A2418, a)) }
        }
    }
}

// MARK: - The T. Rex Paddock

extension Scenes {
    /// Where the paddock's things are: the fence's top row and its posts' spacing, the broken gap's posts, the tour
    /// jeep's left edge, and on the screen saver the tree with the other jeep in it.
    private static func jpPaddockFrame(_ c: PixelCanvas, _ g: Int) -> (top: Int, pitch: Int, gap: (Int, Int), jeep: Int,
                                                                        tree: Int) {
        let s = unit(g), tall = isTall(c)
        let pitch = (tall ? 60 : 44) * s
        let gapPost = (c.w * 58 / 100) / pitch * pitch + pitch / 2
        return (tall ? g - 180 * s : 5 * s, pitch, (gapPost, gapPost + pitch), c.w * 10 / 100, c.w * 82 / 100)
    }

    /// A tour jeep in the park's livery (sand body, green, yellow and red stripes, the clear bubble roof) facing
    /// right, its wheels on row `base`, with a glass of water on the dashboard.
    private static func jpJeep(_ c: PixelCanvas, x: Int, base: Int, s: Int) {
        c.rect(x + 2 * s, base - 14 * s, 38 * s, 9 * s, C(0xD8CCA8))           // body
        c.rect(x, base - 10 * s, 44 * s, 5 * s, C(0xD8CCA8))
        c.rect(x + 2 * s, base - 14 * s, 38 * s, s, C(0xEEE4C4))
        c.rect(x, base - 9 * s, 44 * s, s, C(0x3A7A3A))                         // the stripes
        c.rect(x, base - 8 * s, 44 * s, s, C(0xE8C032))
        c.rect(x, base - 7 * s, 44 * s, s, C(0xC8341E))
        c.rect(x + 6 * s, base - 21 * s, 24 * s, 7 * s, C(0x3A4A4A, 0.85))      // the bubble
        c.rect(x + 7 * s, base - 22 * s, 22 * s, s, C(0x5A6A6A, 0.85))
        c.rect(x + 30 * s, base - 19 * s, 6 * s, 5 * s, C(0x2A3A3A))            // the windscreen
        c.rect(x + 31 * s, base - 18 * s, 2 * s, 3 * s, C(0xA8D4E8, 0.9))       // the glass of water
        c.rect(x + 31 * s, base - 17 * s, 2 * s, s, C(0xD8F0FF))
        c.rect(x + 18 * s, base - 21 * s, s, 7 * s, C(0x2A2A2A))
        c.rect(x + 41 * s, base - 10 * s, 3 * s, 2 * s, C(0xF4F0C8))            // headlamp
        c.rect(x, base - 10 * s, 2 * s, 2 * s, C(0xC8241A))                     // tail lamp
        for wx in [x + 9 * s, x + 34 * s] {
            c.circle(wx, base - 3 * s, 3 * s, C(0x1A1A1A)); c.rect(wx - s, base - 4 * s, 2 * s, 2 * s, C(0x8A8A8A))
        }
        c.rect(x + 11 * s, base - 13 * s, 12 * s, 4 * s, C(0xB02A1A))           // the door's logo
        c.circle(x + 17 * s, base - 11 * s, 2 * s, C(0xE8C032))
    }

    /// The T. rex paddock on the night of the storm: a black-green sky, the dark jungle beyond, the high fence of
    /// concrete posts strung with cables and a yellow DANGER sign, and a gap where the cables have snapped and hang
    /// curled down. The tour jeep waits on the muddy track with its headlamps on and a glass of water on the
    /// dashboard. On the screen saver the fence climbs into the rain and, off to the side, the other jeep hangs nose
    /// down in a great tree.
    static func rexPaddock(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = jpPaddockFrame(c, g)
        c.gradient(0, g, C(0x070C10), C(0x18262A), bands: 6)
        // Storm clouds.
        for i in 0..<(tall ? 16 : 8) {
            let x = Int(noise(i * 5 + 1200) * Double(c.w)), y = Int(noise(i * 5 + 1201) * Double(tall ? g / 3 : 10 * s))
            c.ellipse(x, y, (30 + Int(noise(i * 5 + 1202) * 40)) * s, (5 + Int(noise(i * 5 + 1203) * 6)) * s, C(0x1C2A30, 0.8))
        }
        // The jungle beyond the fence.
        jpJungle(c, top: tall ? g - 150 * s : g - 46 * s, bottom: g, col: C(0x0E1C18), seed: 5, size: (tall ? 22 : 12) * s)
        for i in 0..<(tall ? 8 : 5) {
            let x = Int(noise(i * 9 + 1300) * Double(c.w)), h = (tall ? 150 : 44) * s + Int(noise(i * 9 + 1301) * 10) * s
            jpPalm(c, x: x, base: g, h: h, lean: Int((noise(i * 9 + 1302) - 0.5) * 14) * s,
                   trunk: C(0x0C1814), leaf: C(0x10201A), s: s)
        }
        jpJungle(c, top: tall ? g - 70 * s : g - 26 * s, bottom: g, col: C(0x0A1612), seed: 6, size: (tall ? 14 : 8) * s)
        // The fence: posts, insulators and cables. In the gap the far post is snapped off halfway, its cables torn
        // loose and slumped down to the mud, and the near post's cables end in curled, broken stubs.
        let cables = tall ? 14 : 7
        let span = g - 6 * s - f.top
        let breakY = f.top + span * 11 / 20
        let wire = C(0x7A8480)
        for i in 0..<cables {
            let y = f.top + 3 * s + i * span / cables
            c.rect(0, y, f.gap.0, 1, wire)
            let hang = (4 + i % 3 * 3) * s
            jpLine(c, Double(f.gap.0), Double(y), Double(f.gap.0 + 6 * s), Double(y + hang), wire, 0.5)
            jpLine(c, Double(f.gap.0 + 6 * s), Double(y + hang), Double(f.gap.0 + 4 * s), Double(y + hang + 3 * s), wire, 0.5)
            if y >= breakY {
                c.rect(f.gap.1, y, c.w - f.gap.1, 1, wire)
            } else {
                c.rect(f.gap.1 + f.pitch, y, c.w - f.gap.1 - f.pitch, 1, wire)
                // Slack from the next post down to the ground in the gap.
                let ax = Double(f.gap.1 + f.pitch), ay = Double(y)
                let bx = Double(f.gap.1 - (i % 4) * 6 * s), by = Double(g - s)
                var prev = (ax, ay)
                for step in 1...12 {
                    let q = Double(step) / 12
                    let sag = sin(q * .pi) * Double(10 * s)
                    let nx = ax + (bx - ax) * q, ny = ay + (by - ay) * q * q + sag * 0.3
                    jpLine(c, prev.0, prev.1, nx, ny, wire, 0.5)
                    prev = (nx, ny)
                }
            }
        }
        let pw = (tall ? 5 : 3) * s
        for px in stride(from: f.pitch / 2, to: c.w + f.pitch, by: f.pitch) {
            let broken = px == f.gap.1
            let top = broken ? breakY : f.top
            c.rect(px - pw / 2, top, pw, g - top, C(0x5A605C)); c.rect(px - pw / 2, top, s, g - top, C(0x7A807C))
            if broken {
                for j in 0..<pw { c.rect(px - pw / 2 + j, top - (j % 2 + 1) * 2 * s, 1, (j % 2 + 1) * 2 * s, C(0x5A605C)) }
                jpLine(c, Double(px), Double(top), Double(px + 3 * s), Double(top - 5 * s), C(0x6A4A3A), 0.5)
                jpLine(c, Double(px - s), Double(top), Double(px - 3 * s), Double(top - 4 * s), C(0x6A4A3A), 0.5)
            } else {
                c.rect(px - pw / 2 - s, f.top - s, pw + 2 * s, 2 * s, C(0x6A706C))
            }
            for i in 0..<cables {
                let y = f.top + 3 * s + i * span / cables
                if y >= top { c.rect(px - pw / 2 - s, y - s / 2, s, max(1, s), C(0xC8A82A)) }
            }
        }
        // Trampled ferns in the gap.
        for i in 0..<6 {
            let fx = f.gap.0 + Int(noise(i + 1600) * Double(f.gap.1 - f.gap.0)), fy = g - Int(noise(i + 1610) * 4) * s
            c.ellipse(fx, fy, 6 * s, 2 * s, C(0x16261E))
        }
        // The DANGER sign on the post by the gap.
        let sx = f.gap.0 - f.pitch, sy = f.top + (tall ? 30 : 4) * s
        let k = tall ? 2 * s : s
        let sw = jpTextWidth("DANGER") * k + 4 * k
        c.rect(sx - sw / 2, sy, sw, 9 * k, C(0xE8C42A)); c.rect(sx - sw / 2, sy, sw, k, C(0x1A1A1A))
        c.rect(sx - sw / 2, sy + 8 * k, sw, k, C(0x1A1A1A))
        jpText(c, "DANGER", cx: sx, y: sy + 2 * k, s: k, col: C(0x1A1A1A))
        if tall {
            // The great tree with the other jeep stuck nose down in its branches.
            let tx = f.tree
            c.rect(tx - 6 * s, g - 200 * s, 12 * s, 200 * s, C(0x1E1A14)); c.rect(tx - 6 * s, g - 200 * s, 2 * s, 200 * s, C(0x2E281E))
            for i in 0..<7 {
                let by = Double(g - 60 * s - i * 22 * s), dir = i % 2 == 0 ? 1.0 : -1.0
                let len = Double((26 + i * 3) * s)
                jpLine(c, Double(tx), by, Double(tx) + dir * len, by - len * 0.5, C(0x1E1A14), Double(s) * 1.6)
            }
            for i in 0..<9 {
                let lx = tx + Int((noise(i + 1400) - 0.5) * 120) * s, ly = g - 140 * s - Int(noise(i + 1410) * 90) * s
                c.ellipse(lx, ly, 26 * s, 12 * s, C(0x10221A))
            }
            let k = 2 * s
            let car = PixelCanvas(48 * k, 26 * k)
            jpJeep(car, x: 2 * k, base: 25 * k, s: k)
            let turned = car.rotated(64, about: (Double(24 * k), Double(13 * k)), into: 60 * k, 60 * k, at: (Double(30 * k), Double(30 * k)))
            c.paste(turned, x: tx - 30 * k, y: g - 175 * s)
            for i in 0..<6 {   // branches over the car
                let lx = tx + Int((noise(i + 1420) - 0.5) * 70) * s, ly = g - 175 * s + Int(noise(i + 1430) * 110) * s
                c.ellipse(lx, ly, 7 * s, 3 * s, C(0x12261C))
            }
        }
        // The jeep on the track, its headlamps throwing light ahead.
        let jx = f.jeep
        for i in 0..<30 {
            let w = i * s
            c.rect(jx + 44 * s + i * 2 * s, g - 10 * s - w / 3, 2 * s, 2 * w / 3 + 4 * s, C(0xF4F0C8, 0.06))
        }
        jpJeep(c, x: jx, base: g, s: s)
        // The mud.
        c.ground(g, C(0x1E1A14), edge: C(0x3A342A), speck: C(0x2A241C), seed: 61)
        for i in 0..<7 {
            let px = Int(noise(i + 1500) * Double(c.w)), py = g + 2 + Int(noise(i + 1510) * Double(max(1, c.h - g - 3)))
            c.rect(px, py, (6 + Int(noise(i + 1520) * 10)) * s, s, C(0x5A6A70, 0.5))
        }
    }

    /// What moves in the paddock: the rain driving down, sparks spitting off the snapped cables, the jeep's hazard
    /// lamps blinking, and every so often lightning lighting up the whole sky.
    static func rexPaddockLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = jpPaddockFrame(c, g)
        let cycle = t.truncatingRemainder(dividingBy: 9)
        if cycle < 0.1 || (cycle > 0.22 && cycle < 0.3) { c.rect(0, 0, c.w, g, C(0xD8E8F0, 0.28)) }
        for i in 0..<(c.w * g / 140) {
            let x0 = noise(i * 7 + 31) * Double(c.w + 40), speed = 90 + noise(i * 7 + 32) * 40
            let y = (noise(i * 7 + 33) * Double(g) + t * speed).truncatingRemainder(dividingBy: Double(g))
            let x = Int(x0 - y * 0.2) - 10
            c.rect(x, Int(y), 1, 3 * s, C(0xA8C0C8, 0.3))
        }
        // Sparks at the snapped ends.
        let cables = isTall(c) ? 14 : 7
        let span = g - 6 * s - f.top
        for i in 0..<cables where noise(i * 17 + Int(t * 12)) > 0.86 {
            let hang = (4 + i % 3 * 3) * s
            let y = f.top + 3 * s + i * span / cables + hang + 3 * s
            let x = Double(f.gap.0 + 4 * s)
            c.glowLine(x, Double(y), x + Double(s), Double(y + s), core: C(0xFFFFFF), glow: C(0x8AD0FF),
                       coreR: Double(s) * 0.7, glowR: Double(s) * 2.5)
            c.rect(Int(x) + 2 * s, y + 2 * s, s, s, C(0xFFF0A0))
        }
        // The hazard lamps.
        if Int(t * 2) % 2 == 0 {
            c.rect(f.jeep, g - 10 * s, 2 * s, 2 * s, C(0xFF8A2A)); c.rect(f.jeep - s, g - 11 * s, 4 * s, 4 * s, C(0xFF8A2A, 0.3))
        }
    }
}
