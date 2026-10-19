import Foundation

// Back to the Future: Biff's Pleasure Paradise (the 1985 that went wrong) and Hill Valley, 1885.

let clawdbergScenes2: [Location: Place] = [
    .biffsParadise: Place(name: "Biff's Pleasure Paradise", panel: 0x1C0C14, still: Scenes.biffsParadise,
                          moving: Scenes.biffsParadiseLife),
    .hillValley1885: Place(name: "Hill Valley, 1885", panel: 0x2A1C12, still: Scenes.hillValley1885,
                           moving: Scenes.hillValley1885Life),
]

// MARK: - Shared bits for this file

/// Signwriting in a 3×5 pixel font (M and W five wide, N four), centred on `cx`.
private func cb2Text(_ c: PixelCanvas, _ text: String, cx: Int, y: Int, s: Int, col: Px) {
    let width = text.reduce(0) { $0 + (cb2Glyphs[$1]?[0].count ?? 3) + 1 } - 1
    var x = cx - width * s / 2
    for ch in text {
        let rows = cb2Glyphs[ch] ?? cb2Glyphs[" "]!
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" { c.rect(x + dx * s, y + dy * s, s, s, col) }
        }
        x += (rows[0].count + 1) * s
    }
}

private let cb2Glyphs: [Character: [String]] = [
    "A": [".#.", "#.#", "###", "#.#", "#.#"], "B": ["##.", "#.#", "##.", "#.#", "##."],
    "C": [".##", "#..", "#..", "#..", ".##"], "D": ["##.", "#.#", "#.#", "#.#", "##."],
    "E": ["###", "#..", "##.", "#..", "###"], "F": ["###", "#..", "##.", "#..", "#.."],
    "H": ["#.#", "#.#", "###", "#.#", "#.#"], "I": ["###", ".#.", ".#.", ".#.", "###"],
    "K": ["#.#", "#.#", "##.", "#.#", "#.#"], "L": ["#..", "#..", "#..", "#..", "###"],
    "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"], "N": ["#..#", "##.#", "#.##", "#..#", "#..#"],
    "O": [".#.", "#.#", "#.#", "#.#", ".#."], "P": ["##.", "#.#", "##.", "#..", "#.."],
    "Q": [".#.", "#.#", "#.#", "##.", ".##"], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
    "S": [".##", "#..", ".#.", "..#", "##."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "U": ["#.#", "#.#", "#.#", "#.#", "###"], "V": ["#.#", "#.#", "#.#", "#.#", ".#."],
    "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"], "Y": ["#.#", "#.#", ".#.", ".#.", ".#."],
    "'": ["#", "#", ".", ".", "."], " ": [".", ".", ".", ".", "."],
]

/// String art blown up to `u` pixels a cell.
private func cb2Blocks(_ c: PixelCanvas, _ x: Int, _ y: Int, _ u: Int, _ rows: [String], _ pal: [Character: Px]) {
    for (dy, row) in rows.enumerated() {
        for (dx, ch) in row.enumerated() {
            if let col = pal[ch] { c.rect(x + dx * u, y + dy * u, u, u, col) }
        }
    }
}

// MARK: - Biff's Pleasure Paradise

/// Biff's portrait on the tower: Clawd's orange block face under Biff's swept-up brown hair, the grin full of teeth,
/// a dark suit and a red tie at the bottom, all in a gold frame.
private let bpFace = [
    "GGGGGGGGGGGGGGGGGG",
    "G....HHHHHHHH....G",
    "G..HHHHHHHHHHHH..G",
    "G.HHHhhHHHHHHHHH.G",
    "G.OOOOOOOOOOOOOO.G",
    "G.OOOOOOOOOOOOOO.G",
    "G.OOOEOOOOOOEOOO.G",
    "G.OOOEOOOOOOEOOO.G",
    "G.OOOOOOOOOOOOOO.G",
    "G.OOOWWWWWWWWOOO.G",
    "G.OOOOMMMMMMOOOO.G",
    "G.ooooooooooooo..G",
    "G.SSSSSwRwSSSSSS.G",
    "GSSSSSSwRwSSSSSSSG",
    "GGGGGGGGGGGGGGGGGG",
]
private let bpFacePal: [Character: Px] = [
    "G": C(0xE8B84A), "H": C(0x5A341C), "h": C(0x8A5A30), "O": clawdOrange, "o": C(0xB85E44), "E": C(0x16161B),
    "W": C(0xF4EEDA), "M": C(0x6A1E1E), "S": C(0x2A2A3A), "w": C(0xEEEEF0), "R": C(0xC0202A), ".": C(0x3A1A2A),
]

extension Scenes {
    /// Where the casino stands: the tower's middle, width and top, the podium's top and half-width, the portrait's
    /// corner and cell size, and the marquee's row.
    private static func bpFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, tw: Int, top: Int, podTop: Int, podHW: Int,
                                                                  face: (x: Int, y: Int, u: Int), marquee: Int) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w * 54 / 100
        let tw = (tall ? 84 : 46) * s
        let podTop = g - (tall ? 42 : 34) * s
        let top = tall ? g - 252 * s : -4
        let u = tall ? 3 * s : s
        let faceY = tall ? top + 22 * s : 2
        let face = (cx - 9 * u, faceY, u)
        return (cx, tw, top, podTop, (tall ? 104 : 80) * s, face, podTop + 4 * s)
    }

    /// The 1985 that Biff bought: a smoggy red-brown sky, the courthouse gone and in its place the Pleasure Paradise,
    /// a gold-banded glass tower with Biff's grinning portrait framed on its face, and the casino podium at its foot
    /// with the marquee spelling out BIFF'S PLEASURE PARADISE. Round it the burnt-out town: boarded shops, a pawn
    /// shop, bail bonds, a wrecked car and a trash fire. On the screen saver the whole tower stands up into the smog,
    /// BIFF'S across its crown and other dark towers behind.
    static func biffsParadise(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = bpFrame(c, g)
        c.gradient(0, g, C(0x1E0A16), C(0x6A2E1E), bands: 8)
        if tall {
            // Smoke drifting over, and more of the strip's towers in the haze.
            for i in 0..<12 {
                let x = Int(noise(i * 5 + 41) * Double(c.w)), y = Int(noise(i * 5 + 42) * Double(g / 2))
                c.ellipse(x, y, (34 + Int(noise(i * 5 + 43) * 40)) * s, (6 + Int(noise(i * 5 + 44) * 6)) * s,
                          C(0x2A1220, 0.7))
            }
            for i in 0..<7 {
                let bw = (22 + Int(noise(i + 60) * 18)) * s, bh = (90 + Int(noise(i + 70) * 90)) * s
                let bx = Int(noise(i + 80) * Double(c.w)) - bw / 2
                if abs(bx + bw / 2 - f.cx) < f.tw / 2 + bw / 2 + 6 * s { continue }
                c.rect(bx, g - bh, bw, bh, C(0x2E1622))
                for wy in stride(from: g - bh + 4 * s, to: g - 30 * s, by: 6 * s) {
                    for wx in stride(from: bx + 3 * s, to: bx + bw - 3 * s, by: 5 * s) where noise(wx * 7 + wy) > 0.55 {
                        c.rect(wx, wy, 2 * s, 2 * s, C(0xE89A4A, 0.6))
                    }
                }
            }
        }
        bpTown(c, g)
        // The tower: dark glass, gold bands each floor, the lit windows, the gold edges.
        let tl = f.cx - f.tw / 2, ty = max(f.top, -4)
        c.rect(tl, ty, f.tw, f.podTop - ty, C(0x24182E))
        c.rect(tl, ty, 2 * s, f.podTop - ty, C(0xE8B84A)); c.rect(tl + f.tw - 2 * s, ty, 2 * s, f.podTop - ty, C(0xB08A30))
        let faceBottom = f.face.y + bpFace.count * f.face.u
        for y in stride(from: faceBottom + 3 * s, to: f.podTop - 2 * s, by: 5 * s) {
            c.rect(tl + 2 * s, y, f.tw - 4 * s, s, C(0x8A6A2A))
            for wx in stride(from: tl + 4 * s, to: tl + f.tw - 5 * s, by: 4 * s) {
                let lit = noise(wx * 3 + y * 11) > 0.35
                c.rect(wx, y + 2 * s, 2 * s, 2 * s, lit ? C(0xF2C860, 0.9) : C(0x3A2A44))
            }
        }
        if tall {
            // The crown: a stepped gold top and BIFF'S in red neon.
            for i in 0..<4 {
                c.rect(f.cx - f.tw / 2 + i * 6 * s, f.top - (i + 1) * 4 * s, f.tw - i * 12 * s, 4 * s,
                       i % 2 == 0 ? C(0xE8B84A) : C(0x24182E))
            }
            c.rect(f.cx, f.top - 30 * s, s, 14 * s, C(0x8A6A2A))
            c.rect(tl + 4 * s, f.top + 4 * s, f.tw - 8 * s, 13 * s, C(0x16080E))
            cb2Text(c, "BIFF'S", cx: f.cx, y: f.top + 6 * s, s: 2 * s, col: C(0xFF3A4A))
        }
        cb2Blocks(c, f.face.x, f.face.y, f.face.u, bpFace, bpFacePal)
        // The casino podium: plum walls, gold trim, the marquee band and the doors.
        let pl = f.cx - f.podHW
        c.rect(pl, f.podTop, f.podHW * 2, g - f.podTop, C(0x4A1830))
        c.rect(pl, f.podTop, f.podHW * 2, 2 * s, C(0xE8B84A))
        c.rect(pl, f.marquee, f.podHW * 2, 9 * s, C(0x16080E))
        c.rect(pl, f.marquee + 9 * s, f.podHW * 2, s, C(0xB08A30))
        cb2Text(c, "BIFF'S PLEASURE PARADISE", cx: f.cx, y: f.marquee + 2 * s, s: s, col: C(0xFFD24A))
        for px in stride(from: pl + 4 * s, to: pl + f.podHW * 2 - 4 * s, by: 12 * s) {   // arched windows
            if abs(px + 3 * s - f.cx) < 14 * s { continue }
            c.rect(px, f.marquee + 14 * s, 6 * s, g - f.marquee - 18 * s, C(0x2A0E1C))
            c.rect(px + s, f.marquee + 15 * s, 4 * s, g - f.marquee - 20 * s, C(0xE85A8A, 0.35))
        }
        c.rect(f.cx - 10 * s, g - 14 * s, 20 * s, 14 * s, C(0x1A0A10))
        c.rect(f.cx - 9 * s, g - 13 * s, 8 * s, 13 * s, C(0xF2C860, 0.55)); c.rect(f.cx + s, g - 13 * s, 8 * s, 13 * s, C(0xF2C860, 0.55))
        c.rect(f.cx - 12 * s, g - 15 * s, 24 * s, 2 * s, C(0xE8B84A))
        // The street: cracked asphalt, litter.
        c.ground(g, C(0x1E1618), edge: C(0x4A3A34), speck: C(0x34282A), seed: 85)
        for i in 0..<8 {
            let px = Int(noise(i + 900) * Double(c.w)), py = g + 2 + Int(noise(i + 910) * Double(max(1, c.h - g - 3)))
            c.rect(px, py, (4 + Int(noise(i + 920) * 8)) * s, s, C(0x0E0A0C))
        }
    }

    /// The burnt-out shops either side of the casino, the wrecked car and the trash barrel.
    private static func bpTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = bpFrame(c, g)
        let signs = ["PAWN", "BAIL BONDS", "", "LIQUOR", "", "CASH", "", "BAR"]
        var x = -6 * s
        var k = 0, shop = 0
        while x < c.w {
            let w = (36 + Int(noise(k * 3 + 17) * 18)) * s
            let h = (20 + Int(noise(k * 3 + 18) * 10)) * s
            if abs(x + w / 2 - f.cx) > f.podHW + w / 2 {
                let col = [C(0x3A2226), C(0x2E2028), C(0x3E2A22)][k % 3]
                c.rect(x, g - h, w, h, col); c.rect(x, g - h, w, s, C(0x5A3A34))
                // Scorched tops: a ragged black edge.
                for bx in stride(from: x, to: x + w, by: s) where noise(bx + k * 50) > 0.6 {
                    c.rect(bx, g - h, s, (1 + Int(noise(bx + 7) * 3)) * s, C(0x140C10))
                }
                for wx in stride(from: x + 4 * s, to: x + w - 8 * s, by: 10 * s) {
                    let boarded = noise(wx + k * 13) > 0.5
                    c.rect(wx, g - h + 5 * s, 6 * s, 5 * s, boarded ? C(0x6A4A2E) : C(0x120A0E))
                    if boarded { c.rect(wx - s, g - h + 7 * s, 8 * s, s, C(0x8A643A)) }
                }
                let sign = signs[shop % signs.count]
                shop += 1
                if !sign.isEmpty {
                    let neon = [C(0x4AF2E8), C(0xFF4A8A), C(0x9AFF4A)][shop % 3]
                    c.rect(x + 3 * s, g - h - 8 * s, w - 6 * s, 7 * s, C(0x140A10))
                    cb2Text(c, sign, cx: x + w / 2, y: g - h - 7 * s, s: s, col: neon)
                }
                c.rect(x + 3 * s, g - 9 * s, w - 6 * s, 9 * s, C(0x140C10))
            }
            x += w + 3 * s; k += 1
        }
        // A wrecked car on the left, on its rims, and a trash barrel on the right.
        let carX = c.w * 14 / 100
        c.rect(carX, g - 6 * s, 26 * s, 4 * s, C(0x3A3A42)); c.rect(carX + 6 * s, g - 10 * s, 14 * s, 4 * s, C(0x2E2E36))
        c.rect(carX + 8 * s, g - 9 * s, 4 * s, 2 * s, C(0x101014)); c.rect(carX + 14 * s, g - 9 * s, 4 * s, 2 * s, C(0x101014))
        c.rect(carX + 3 * s, g - 2 * s, 4 * s, 2 * s, C(0x1A1A1E)); c.rect(carX + 19 * s, g - 2 * s, 4 * s, 2 * s, C(0x1A1A1E))
        c.rect(carX + 4 * s, g - 7 * s, 6 * s, s, C(0x5A2A1A))
        let barrel = c.w * 88 / 100
        c.rect(barrel, g - 8 * s, 7 * s, 8 * s, C(0x4A3A2A)); c.rect(barrel, g - 6 * s, 7 * s, s, C(0x2A2018))
        c.rect(barrel, g - 3 * s, 7 * s, s, C(0x2A2018))
    }

    /// What moves at the Paradise: two searchlights sweeping the smog from the podium's roof, the bulbs round the
    /// marquee chasing, the tower's gold edges pulsing pink, and the fire in the trash barrel.
    static func biffsParadiseLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = bpFrame(c, g)
        // The searchlights.
        for side in [-1.0, 1.0] {
            let ox = Double(f.cx) + side * Double(f.podHW - 12 * s), oy = Double(f.podTop)
            let swing = sin(t * 0.5 + (side > 0 ? 1.7 : 0)) * 0.35
            let a = side * (0.45 + swing)
            let lean = tan(a)
            for y in stride(from: 0, to: f.podTop, by: 1) {
                let d = oy - Double(y)
                let mid = ox + lean * d, half = 1 + d * 0.07
                let alpha = 0.16 * (1 - Double(f.podTop - y) / Double(f.podTop) * 0.6)
                c.rect(Int(mid - half), y, max(1, Int(half * 2)), 1, C(0xFFF2C8, alpha))
            }
            c.rect(Int(ox) - 2 * s, f.podTop - 3 * s, 4 * s, 3 * s, C(0xFFF6DA))
        }
        // The marquee bulbs, chasing round the band.
        let pl = f.cx - f.podHW, step = 4 * s
        let phase = Int(t * 6)
        var i = 0
        for bx in stride(from: pl + s, to: pl + f.podHW * 2 - s, by: step) {
            let on = (i + phase) % 3 == 0
            c.rect(bx, f.marquee, s, s, on ? C(0xFFF6B0) : C(0x8A5A2A))
            c.rect(bx, f.marquee + 8 * s, s, s, (i + phase) % 3 == 1 ? C(0xFFF6B0) : C(0x8A5A2A))
            i += 1
        }
        // The tower's edges in pink neon, pulsing.
        let pulse = 0.35 + 0.35 * (sin(t * 3) * 0.5 + 0.5)
        let tl = f.cx - f.tw / 2, ty = max(f.top, 0)
        c.rect(tl - s, ty, s, f.podTop - ty, C(0xFF4A9A, pulse)); c.rect(tl + f.tw, ty, s, f.podTop - ty, C(0xFF4A9A, pulse))
        // Flames over the barrel.
        let barrel = c.w * 88 / 100
        for k in 0..<5 {
            let h = (3 + Int(noise(Int(t * 10) * 7 + k) * 6)) * s
            c.rect(barrel + k * s + s, g - 8 * s - h, s, h, k % 2 == 0 ? C(0xFFB23A) : C(0xFF6A2A))
        }
        c.rect(barrel - 4 * s, g - 22 * s, 15 * s, 14 * s, C(0xFF8A3A, 0.06))
    }
}

// MARK: - Hill Valley, 1885

extension Scenes {
    /// Where things stand in 1885: the end of the town (open desert and the railway beyond), the courthouse frame's
    /// middle and roof, the clock tower's top, and the railway's row.
    private static func hv85Frame(_ c: PixelCanvas, _ g: Int) -> (townEnd: Int, cx: Int, roof: Int, towerTop: Int,
                                                                  rail: Int) {
        let s = unit(g), tall = isTall(c)
        let townEnd = c.w * 66 / 100
        let cx = c.w * 40 / 100
        let roof = g - (tall ? 34 : 26) * s
        let towerTop = roof - (tall ? 56 : 30) * s
        return (townEnd, cx, roof, max(towerTop, 0), g - 12 * s)
    }

    /// Hill Valley as a frontier town: a pale hot sky, red mesas on the horizon, a row of plank false fronts (the
    /// Palace Saloon, the livery, the hotel, the blacksmith), and in the middle the new courthouse still going up,
    /// its brick half laid and the clock tower a frame of scaffold with the clock face waiting on it. Past the last
    /// building the desert opens out: the railway on its bank, telegraph poles and a water tower. On the screen
    /// saver the sky climbs high over big mesas.
    static func hillValley1885(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hv85Frame(c, g)
        c.gradient(0, g, C(0x6AA8D8), C(0xF2DCA8), bands: 7)
        if tall {
            c.circle(c.w * 82 / 100, g / 6, 9 * s, C(0xFFF6D8))
            for i in 0..<5 {
                wisp(c, Int(noise(i + 140) * Double(c.w)), Int(noise(i + 150) * Double(g / 3)) + 10 * s,
                     (40 + Int(noise(i + 160) * 50)) * s, C(0xFFFFFF, 0.5), s: s)
            }
            // Thunderheads building over the desert, away from the top left, and the Sierra far off in the haze.
            for (i, cl) in [(x: 48, y: 30, w: 90), (x: 66, y: 22, w: 70), (x: 94, y: 36, w: 110), (x: 34, y: 46, w: 54),
                            (x: 78, y: 48, w: 60)].enumerated() {
                hv85Cloud(c, c.w * cl.x / 100, g * cl.y / 100, cl.w * s, s, seed: 170 + i * 7)
            }
            hv85Sierra(c, g)
            // A far range in the haze, then the big mesas with their layered cliffs.
            mesa(c, x: -20 * s, width: 200 * s, h: 50 * s, base: g - 16 * s, C(0xD8A890), seed: 2)
            mesa(c, x: c.w * 50 / 100, width: 240 * s, h: 40 * s, base: g - 16 * s, C(0xDCB094), seed: 6)
            for m in [(x: c.w * 6 / 100, w: 110, h: 80, seed: 3), (x: c.w * 62 / 100, w: 130, h: 104, seed: 4),
                      (x: c.w * 38 / 100, w: 26, h: 70, seed: 5)] {
                mesa(c, x: m.x, width: m.w * s, h: m.h * s, base: g - 16 * s, C(0x9A4E3A), seed: m.seed)
                mesa(c, x: m.x + m.w * s / 6, width: m.w * s * 2 / 3, h: (m.h - 3) * s, base: g - 16 * s, C(0xBC6A4C),
                     seed: m.seed)
                for k in 1..<5 {   // strata
                    let y = g - 16 * s - m.h * s + (m.h * k / 5) * s
                    c.rect(m.x + m.w * s / 6 + k * s, y, m.w * s * 2 / 3 - 2 * k * s, s, C(0xA85A40))
                }
            }
        }
        // Low mesas on the horizon and the desert floor up to them.
        mesa(c, x: c.w * 2 / 100, width: 60 * s, h: 16 * s, base: g - 14 * s, C(0xC8846A), seed: 11)
        mesa(c, x: c.w * 70 / 100, width: 90 * s, h: 22 * s, base: g - 14 * s, C(0xC07A5E), seed: 12)
        mesa(c, x: c.w * 46 / 100, width: 40 * s, h: 12 * s, base: g - 14 * s, C(0xD09478), seed: 13)
        c.rect(0, g - 14 * s, c.w, 14 * s, C(0xE2BE88))
        hv85Desert(c, g)
        // The railway on its bank, the telegraph poles and the water tower.
        c.rect(f.townEnd, f.rail, c.w - f.townEnd, 2 * s, C(0xB8946A))
        c.rect(f.townEnd, f.rail, c.w - f.townEnd, s, C(0x5A4A3A))
        for x in stride(from: f.townEnd + 4 * s, to: c.w, by: 30 * s) {
            c.rect(x, f.rail - 18 * s, s, 18 * s, C(0x6A4A30)); c.rect(x - 2 * s, f.rail - 17 * s, 5 * s, s, C(0x6A4A30))
        }
        let wt = c.w * 92 / 100
        c.rect(wt - 6 * s, f.rail - 26 * s, 12 * s, 10 * s, C(0x8A5A34)); c.rect(wt - 7 * s, f.rail - 27 * s, 14 * s, 2 * s, C(0x5A3A22))
        for lx in [wt - 5 * s, wt + 4 * s] { c.rect(lx, f.rail - 16 * s, s, 16 * s, C(0x5A3A22)) }
        // The courthouse going up: brick to the first floor, scaffold above, the tower a frame with the clock on it.
        let hw = (tall ? 40 : 30) * s
        let towerW = (tall ? 22 : 16) * s
        c.rect(f.cx - towerW / 2, f.towerTop, s, f.roof - f.towerTop, C(0x8A6A44))
        c.rect(f.cx + towerW / 2 - s, f.towerTop, s, f.roof - f.towerTop, C(0x8A6A44))
        for y in stride(from: f.towerTop, to: f.roof, by: 7 * s) {
            c.rect(f.cx - towerW / 2, y, towerW, s, C(0x9A7A50))
        }
        let span = max(1, f.roof - f.towerTop)
        for k in 0...span / s where k % 2 == 0 {   // a diagonal brace up the frame
            let y = f.towerTop + k * s
            c.rect(f.cx - towerW / 2 + (k * s) * towerW / span, y, s, s, C(0x7A5A3A))
        }
        let clockY = f.towerTop + (tall ? 18 : 9) * s, r = (tall ? 8 : 5) * s
        c.circle(f.cx, clockY, r + s, C(0x3A2A1E)); c.circle(f.cx, clockY, r, C(0xF2ECD8))
        for h in 0..<12 {
            let a = Double(h) / 12 * 2 * .pi
            let rr = Double(r - s)
            c.rect(f.cx + Int(sin(a) * rr), clockY - Int(cos(a) * rr), s, s, C(0x2A2420))
        }
        c.rect(f.cx, clockY - r + 2 * s, s, r - 2 * s, C(0x1A1614)); c.rect(f.cx, clockY, r - 2 * s, s, C(0x1A1614))
        c.rect(f.cx - hw, f.roof, hw * 2, g - f.roof, C(0x9A5A3E))
        for by in stride(from: f.roof, to: g, by: 3 * s) {
            for bx in stride(from: f.cx - hw + ((by / s) % 2) * 2 * s, to: f.cx + hw, by: 4 * s) {
                c.rect(bx, by, s, s, C(0x7E4630))
            }
        }
        for i in 0..<(hw * 2 / s) where noise(i + 444) > 0.5 {   // the unfinished top course
            c.rect(f.cx - hw + i * s, f.roof - s, s, s, C(0x9A5A3E))
        }
        for x in stride(from: f.cx - hw - 2 * s, through: f.cx + hw + 2 * s, by: 12 * s) {   // the scaffold poles
            c.rect(x, f.roof - 10 * s, s, g - f.roof + 10 * s, C(0x8A6A44))
        }
        c.rect(f.cx - hw - 3 * s, f.roof - 10 * s, hw * 2 + 6 * s, s, C(0x9A7A50))
        c.rect(f.cx - hw - 3 * s, f.roof + 10 * s, hw * 2 + 6 * s, s, C(0x9A7A50))
        c.rect(f.cx - 5 * s, g - 12 * s, 10 * s, 12 * s, C(0x3A2216))
        // The plank false fronts down the street.
        let names = ["SALOON", "HOTEL", "", "SMITHY", "LIVERY"]
        var x = -4 * s
        var k = 0, shop = 0
        while x < f.townEnd {
            let w = (38 + Int(noise(k * 3 + 27) * 14)) * s
            let h = (tall ? 30 : 22) * s + Int(noise(k * 3 + 28) * 6) * s
            if abs(x + w / 2 - f.cx) > hw + w / 2 + 2 * s {
                let wood = [C(0x8A5E3A), C(0xA07048), C(0x7A5234)][k % 3]
                c.rect(x, g - h, w, h, wood)
                for px in stride(from: x, to: x + w, by: 3 * s) { c.rect(px, g - h, s, h, C(0x000000, 0.08)) }
                c.rect(x - s, g - h, w + 2 * s, 2 * s, C(0x5A3A22))
                let name = names[shop % names.count]
                shop += 1
                if !name.isEmpty {
                    c.rect(x + 4 * s, g - h + 3 * s, w - 8 * s, 7 * s, C(0xEAD8B0))
                    cb2Text(c, name, cx: x + w / 2, y: g - h + 4 * s, s: s, col: C(0x5A1E14))
                }
                // The porch roof on posts, the windows and the door.
                c.rect(x, g - 13 * s, w, 2 * s, C(0x5A3A22))
                for post in [x + s, x + w - 2 * s] { c.rect(post, g - 11 * s, s, 11 * s, C(0x5A3A22)) }
                c.rect(x + 5 * s, g - 9 * s, 6 * s, 5 * s, C(0x2A1E16)); c.rect(x + w - 11 * s, g - 9 * s, 6 * s, 5 * s, C(0x2A1E16))
                c.rect(x + w / 2 - 3 * s, g - 9 * s, 6 * s, 9 * s, C(0x3A2416))
                if name == "SALOON" {   // the swing doors
                    c.rect(x + w / 2 - 3 * s, g - 7 * s, 6 * s, 4 * s, C(0xB08050))
                    c.rect(x + w / 2, g - 7 * s, s, 4 * s, C(0x3A2416))
                }
            }
            x += w + 2 * s; k += 1
        }
        // The dirt street, wheel ruts and hoof prints.
        c.ground(g, C(0xC8A070), edge: C(0xE2C090), speck: C(0xA88458), seed: 18)
        c.rect(0, g + 3, c.w, s, C(0xB08A5E)); c.rect(0, g + 6, c.w, s, C(0xB08A5E))
    }

    /// A heaped thunderhead on a flat base at (`x`, `base`), `w` wide: white puffs lit from the sun, a warm grey
    /// shade under them, and the top piled higher in the middle.
    private static func hv85Cloud(_ c: PixelCanvas, _ x: Int, _ base: Int, _ w: Int, _ s: Int, seed: Int) {
        let n = max(3, w / (9 * s))
        var puffs: [(x: Int, y: Int, r: Int)] = []
        for k in 0..<n {
            let mid = 1 - abs(Double(k) / Double(n - 1) - 0.5) * 2
            let r = Int((0.3 + 0.7 * mid) * Double(w) / 5 * (0.7 + 0.5 * noise(seed + k))) / s * s + 2 * s
            puffs.append((x - w / 2 + w * k / (n - 1), base - r, r))
            if mid > 0.5 { puffs.append((x - w / 2 + w * k / (n - 1) + 2 * s, base - r * 2, r * 2 / 3)) }
        }
        for p in puffs { c.circle(p.x, p.y, p.r, C(0xD8CCC0)) }
        for p in puffs { c.circle(p.x + s, p.y - s, p.r - s, C(0xFFFCF4)) }
        c.rect(x - w / 2 - 2 * s, base - 3 * s, w + 4 * s, 3 * s, C(0xD8CCC0))
    }

    /// The Sierra far off behind the mesas on the screen saver: a jagged range, pale lilac in the haze, with a
    /// lighter face on the sunny side of each peak.
    private static func hv85Sierra(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), base = g - 16 * s
        for x in stride(from: 0, to: c.w, by: s) {
            let k = Double(x / s)
            let ridge = 0.5 + 0.3 * sin(k * 0.021 + 0.7) + 0.2 * abs(sin(k * 0.067 + 2.1)) + 0.08 * sin(k * 0.23)
            let h = Int(ridge * Double(120 * s)) / s * s
            c.rect(x, base - h, s, h, C(0xC4AEB4))
            let slope = sin(k * 0.067 + 2.1) * cos(k * 0.067 + 2.1)
            if slope > 0 { c.rect(x, base - h, s, min(h, 10 * s), C(0xD4C0C0)) }
        }
    }

    /// The open desert past the town: a few saguaros behind the railway, and a windmill pump between the telegraph
    /// poles with its wheel of blades and its tail vane.
    private static func hv85Desert(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hv85Frame(c, g)
        for (i, px) in [74, 83, 97].enumerated() {
            let x = c.w * px / 100, h = (6 + i % 2 * 3) * s, base = f.rail - s
            c.rect(x, base - h, 2 * s, h, C(0x5A7A3A)); c.rect(x, base - h, s, h, C(0x6E8E48))
            c.rect(x - 2 * s, base - h * 2 / 3, 2 * s, s, C(0x5A7A3A)); c.rect(x - 2 * s, base - h + s, s, h / 3, C(0x5A7A3A))
            c.rect(x + 2 * s, base - h / 2, 2 * s, s, C(0x5A7A3A)); c.rect(x + 3 * s, base - h * 3 / 4, s, h / 4, C(0x5A7A3A))
        }
        let k = max(0, (c.w * 79 / 100 - f.townEnd) / (30 * s))
        let wx = f.townEnd + 4 * s + k * 30 * s + 15 * s, top = f.rail - 26 * s
        for y in stride(from: top, to: f.rail, by: s) {   // the tower, tapering up
            let half = 2 * s + (y - top) * 4 / 26 / s * s
            c.rect(wx - half, y, s, s, C(0x6A4A30)); c.rect(wx + half, y, s, s, C(0x6A4A30))
            if ((y - top) / s) % 6 == 0 { c.rect(wx - half, y, 2 * half + s, s, C(0x7A5A3A)) }
        }
        for a in 0..<12 {   // the wheel of blades, and its hub
            let ang = Double(a) / 12 * 2 * .pi
            for r in 2...7 {
                c.rect(wx + Int(cos(ang) * Double(r * s)), top + Int(sin(ang) * Double(r * s)), s, s, C(0x8A8A86))
            }
        }
        c.rect(wx - s, top - s, 2 * s, 2 * s, C(0x3A3A36))
        c.rect(wx, top, 9 * s, s, C(0x5A4A3A)); c.rect(wx + 7 * s, top - 3 * s, 3 * s, 5 * s, C(0xB8463A))
    }

    /// What moves in 1885: the steam train puffing along the railway (it comes in from the right and goes behind the
    /// town), its smoke rising and drifting, a hawk wheeling high on the screen saver, and a tumbleweed bowling
    /// down the street.
    static func hillValley1885Life(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hv85Frame(c, g)
        // The train: a dark engine with its cowcatcher, a red cab, the tender and two yellow cars.
        let period = 26.0
        let run = t.truncatingRemainder(dividingBy: period)
        let speed = Double(c.w - f.townEnd + 120 * s) / (period * 0.8)
        let front = c.w + 4 * s - Int(run * speed)
        func part(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ col: Px) {
            let x0 = max(x, f.townEnd)
            if x + w > x0 { c.rect(x0, y, x + w - x0, h, col) }
        }
        let base = f.rail
        part(front - 2 * s, base - 3 * s, 3 * s, 2 * s, C(0x8A2A1A))          // cowcatcher
        part(front, base - 8 * s, 12 * s, 6 * s, C(0x22222A))                 // boiler
        part(front + 2 * s, base - 13 * s, 3 * s, 5 * s, C(0x22222A))         // the funnel, flared
        part(front + s, base - 14 * s, 5 * s, 2 * s, C(0x2E2E36))
        part(front, base - 9 * s, s, 2 * s, C(0xF2D86A))                      // the lamp
        part(front + 10 * s, base - 12 * s, 7 * s, 10 * s, C(0x8A2A1A))       // the cab
        part(front + 11 * s, base - 11 * s, 3 * s, 3 * s, C(0xF2D86A, 0.7))
        part(front + 18 * s, base - 7 * s, 9 * s, 5 * s, C(0x3A2A22))         // the tender
        for k in 0..<2 {
            let cx = front + (29 + k * 18) * s
            part(cx, base - 10 * s, 16 * s, 8 * s, C(0xC8962E)); part(cx, base - 11 * s, 16 * s, s, C(0x5A3A22))
            for w in 0..<3 { part(cx + (2 + w * 5) * s, base - 8 * s, 3 * s, 3 * s, C(0x3A2A1E)) }
        }
        for wx in stride(from: front + s, to: front + 64 * s, by: 5 * s) {     // wheels, turning
            let up = (Int(t * 8) + wx / s) % 2
            part(wx, base - 2 * s - up * s, 3 * s, 2 * s + up * s, C(0x16161B))
        }
        // Smoke puffs from the funnel, rising and drifting back.
        for k in 0..<6 {
            let age = (t * 1.5 + Double(k) / 6).truncatingRemainder(dividingBy: 1)
            let born = run - age / 1.5
            let bx = c.w + 4 * s - Int(born * speed) + 3 * s
            let px = bx + Int(age * 18) * s
            let py = base - 15 * s - Int(age * 22) * s
            let r = (2 + Int(age * 5)) * s
            if px - r >= f.townEnd { c.circle(px, py, r, C(0xF2F0EA, 0.75 * (1 - age))) }
        }
        // A hawk wheeling high over the screen saver.
        if isTall(c) {
            let hx = c.w / 3 + Int(cos(t * 0.4) * 60) * s, hy = g / 4 + Int(sin(t * 0.4) * 20) * s
            let flap = Int(t * 3) % 2
            c.rect(hx - 4 * s, hy - flap * s, 4 * s, s, C(0x3A2A22)); c.rect(hx + s, hy - flap * s, 4 * s, s, C(0x3A2A22))
            c.rect(hx, hy, s, s, C(0x3A2A22))
        }
        // The tumbleweed: bowls across every 15 seconds, bouncing.
        let tw = (t / 15).truncatingRemainder(dividingBy: 1)
        let tx = -10 * s + Int(tw * Double(c.w + 20 * s))
        let hop = abs(sin(t * 4)) * 4
        let ty = g - 5 * s - Int(hop) * s
        let spin = t * 5
        c.circle(tx, ty, 4 * s, C(0x9A7444, 0.45))
        for k in 0..<10 {
            let a = spin + Double(k) * 0.63
            let rr = Double(4 * s)
            c.rect(tx + Int(cos(a) * rr), ty + Int(sin(a) * rr), s, s, C(0x6A4A26))
            c.rect(tx + Int(cos(a + 2) * rr * 0.55), ty + Int(sin(a + 2) * rr * 0.55), s, s, C(0x7A5A30))
        }
    }
}
