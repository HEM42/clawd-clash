import Foundation

// Beetlejuice's places, and Corpse Bride's Land of the Dead: the Maitlands' house on its hill (remodelled by Delia), the
// model of Winter River on the attic table, the Afterlife's waiting room, and the Land of the Dead's crooked street by
// the Ball and Socket.

let burtonScenes3: [Location: Place] = [
    .maitlandHouse: Place(name: "The Maitlands' House", panel: 0x1A2A1A, still: Scenes.maitlandHouse,
                          moving: Scenes.maitlandHouseLife),
    .modelWinterRiver: Place(name: "The Model Town in the Attic", panel: 0x1A140E, still: Scenes.modelWinterRiver,
                             moving: Scenes.modelWinterRiverLife),
    .afterlifeWaitingRoom: Place(name: "The Afterlife Waiting Room", panel: 0x0E1E1A, still: Scenes.afterlifeWaitingRoom,
                                 moving: Scenes.afterlifeWaitingRoomLife),
    .landOfTheDead: Place(name: "The Land of the Dead", panel: 0x0C1410, still: Scenes.landOfTheDead,
                          moving: Scenes.landOfTheDeadLife),
]

// MARK: - Shared

extension Scenes {
    /// Capital letters and digits three pixels wide and five tall, for the signs in these places.
    private static let bjGlyphs: [Character: [String]] = [
        "A": [".X.", "X.X", "XXX", "X.X", "X.X"], "B": ["XX.", "X.X", "XX.", "X.X", "XX."], "C": [".XX", "X..", "X..", "X..", ".XX"],
        "D": ["XX.", "X.X", "X.X", "X.X", "XX."], "E": ["XXX", "X..", "XX.", "X..", "XXX"], "F": ["XXX", "X..", "XX.", "X..", "X.."],
        "G": [".XX", "X..", "X.X", "X.X", ".XX"], "I": ["XXX", ".X.", ".X.", ".X.", "XXX"], "K": ["X.X", "X.X", "XX.", "X.X", "X.X"],
        "L": ["X..", "X..", "X..", "X..", "XXX"], "M": ["X.X", "XXX", "XXX", "X.X", "X.X"], "N": ["X.X", "XXX", "XXX", "XXX", "X.X"],
        "O": [".X.", "X.X", "X.X", "X.X", ".X."], "R": ["XX.", "X.X", "XX.", "X.X", "X.X"], "S": [".XX", "X..", ".X.", "..X", "XX."],
        "T": ["XXX", ".X.", ".X.", ".X.", ".X."], "U": ["X.X", "X.X", "X.X", "X.X", "XXX"],
        "V": ["X.X", "X.X", "X.X", "X.X", ".X."], "W": ["X.X", "X.X", "XXX", "XXX", "X.X"],
        "X": ["X.X", "X.X", ".X.", "X.X", "X.X"], "&": [".X.", "X..", ".XX", "X.X", ".XX"], " ": ["...", "...", "...", "...", "..."],
        "0": ["XXX", "X.X", "X.X", "X.X", "XXX"], "1": [".X.", "XX.", ".X.", ".X.", "XXX"], "2": ["XX.", "..X", ".X.", "X..", "XXX"],
        "3": ["XX.", "..X", ".X.", "..X", "XX."], "4": ["X.X", "X.X", "XXX", "..X", "..X"], "5": ["XXX", "X..", "XX.", "..X", "XX."],
        "6": [".XX", "X..", "XXX", "X.X", "XXX"], "7": ["XXX", "..X", ".X.", ".X.", ".X."], "8": ["XXX", "X.X", "XXX", "X.X", "XXX"],
        "9": ["XXX", "X.X", "XXX", "..X", "XX."],
    ]

    /// `text` in the little sign letters from (x, y), each pixel `s` across; returns its width.
    @discardableResult
    static func bjText(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, _ col: Px) -> Int {
        var cx = x
        for ch in text {
            let rows = bjGlyphs[ch] ?? bjGlyphs[" "]!
            for (r, row) in rows.enumerated() {
                for (k, p) in row.enumerated() where p == "X" { c.rect(cx + k * s, y + r * s, s, s, col) }
            }
            cx += 4 * s
        }
        return cx - x - s
    }

    /// Pattern rows blown up `k` times both ways.
    static func bjScale(_ rows: [String], _ k: Int) -> [String] {
        rows.flatMap { r in Array(repeating: String(r.flatMap { Array(repeating: $0, count: k) }), count: k) }
    }

    /// How wide `text` is in the sign letters.
    static func bjTextWidth(_ text: String, s: Int) -> Int { text.count * 4 * s - s }
}

// MARK: - The Maitlands' house

extension Scenes {
    /// Where the house stands: its middle, the hilltop it stands on, and its size unit.
    static func mhFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, base: Int, k: Int) {
        let s = unit(g), tall = isTall(c)
        return (c.w * 56 / 100, g - (tall ? 60 : 12) * s, (tall ? 3 : 1) * s)
    }

    /// The Maitlands' house after Delia's remodel, on its green hill under a blue sky: white walls and steep gables, the
    /// tall square tower with a black mansard top, a porch, yellow blocks jutting from the gables, a deck jutting out on
    /// a post with a bare gable frame standing on it, and a black-and-white striped base. Fence posts down the hill,
    /// the red car parked, a little tree, and Delia's spiky sculptures on the lawn. On the screen saver, the hill town
    /// of Winter River on the slope behind and the covered bridge over the river below.
    static func maitlandHouse(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = mhFrame(c, g), k = f.k
        let white = C(0xF2F2EE), shade = C(0xC8CCD4), dark = C(0x3A4250), black = C(0x1E2028), yellow = C(0xF0C830)
        c.gradient(0, g, C(0x2E4E80), C(0x8AAAD0), bands: 7)
        for i in 0..<(tall ? 7 : 4) {   // a few white clouds
            let cx = Int(noise(i + 4000) * Double(c.w)), cy = Int(noise(i + 4010) * Double(g) * 0.45) + 4 * s
            let w = (14 + Int(noise(i + 4020) * 18)) * s
            c.ellipse(cx, cy, w / 2, 2 * s, C(0xF4F6FA, 0.85)); c.ellipse(cx - w / 5, cy - 2 * s, w / 4, 2 * s, C(0xF4F6FA, 0.85))
        }
        if tall {
            // Winter River on the slope behind: far hills, white houses and a church steeple, then the river and the
            // covered bridge across it.
            c.dunes(base: g - 130 * s, amp: 10 * Double(s), freq: 0.01, phase: 0.4, bottom: g, C(0x5A7A5A))
            for i in 0..<16 {
                let hx = Int(noise(i + 4030) * Double(c.w * 40 / 100)), hy = g - 118 * s + Int(noise(i + 4031) * Double(24 * s))
                let hw = (6 + Int(noise(i + 4032) * 5)) * s
                c.rect(hx, hy - 4 * s, hw, 4 * s, i % 4 == 1 ? C(0xA84A3A) : white)
                for r in 0..<(hw / 2) { c.rect(hx + r, hy - 4 * s - r, hw - 2 * r, 1, C(0x5A6070)) }
            }
            let ch = c.w * 18 / 100
            c.rect(ch, g - 128 * s, 6 * s, 12 * s, white); c.rect(ch + 2 * s, g - 140 * s, 2 * s, 12 * s, white)
            burtonTriangle(c, (Double(ch + 2 * s), Double(g - 140 * s)), (Double(ch + 4 * s), Double(g - 140 * s)),
                           (Double(ch + 3 * s), Double(g - 150 * s)), white)
            c.dunes(base: g - 84 * s, amp: 6 * Double(s), freq: 0.014, phase: 2.0, bottom: g, C(0x4A8A4A))
            c.rect(0, g - 70 * s, c.w * 34 / 100, 8 * s, C(0x3A6A9A)); c.rect(0, g - 70 * s, c.w * 34 / 100, s, C(0x8AB8E0))
            let bx = c.w * 8 / 100, bw = 40 * s, by = g - 70 * s
            c.rect(bx, by - 12 * s, bw, 12 * s, C(0x9A3A2A)); c.rect(bx + 4 * s, by - 9 * s, bw - 8 * s, 9 * s, C(0x2A1A14))
            for r in 0..<(6 * s) { c.rect(bx - 2 * s + r, by - 12 * s - r, bw + 4 * s - 2 * r, 1, C(0x4A4A52)) }
        }
        // The hill: green, rising in the middle to the house's hilltop.
        let hw = Double(c.w) * 0.5
        for x in 0..<c.w {
            let d = Double(x - f.x) / hw
            let top = f.base + Int(Double(g - f.base) * min(1, d * d))
            c.rect(x, top, 1, g - top, C(0x4A9A3A)); c.px(x, top, C(0x6ABA4A))
        }
        // The deck jutting out on its post at the left, a bare gable frame standing on it.
        let x0 = f.x - 18 * k, top = f.base - 16 * k
        c.rect(x0 - 12 * k, f.base - 6 * k, 14 * k, 2 * k, white); c.rect(x0 - 10 * k, f.base - 4 * k, 2 * k, 4 * k, shade)
        c.rect(x0 - 12 * k, f.base - 18 * k, 2 * k, 12 * k, white); c.rect(x0 - 4 * k, f.base - 18 * k, 2 * k, 12 * k, white)
        burtonTriangle(c, (Double(x0 - 12 * k), Double(f.base - 18 * k)), (Double(x0 - 2 * k), Double(f.base - 18 * k)),
                       (Double(x0 - 7 * k), Double(f.base - 24 * k)), white)
        c.rect(x0 - 9 * k, f.base - 16 * k, 3 * k, 4 * k, C(0x8AAAD0))
        // The main house: white walls, steep gables, a porch, the striped base.
        c.rect(x0, top, 36 * k, 16 * k, white); c.rect(x0 + 35 * k, top, k, 16 * k, shade)
        for (gx, gw, gh) in [(x0, 12 * k, 12 * k), (x0 + 22 * k, 14 * k, 18 * k)] {
            burtonTriangle(c, (Double(gx), Double(top)), (Double(gx + gw), Double(top)), (Double(gx + gw / 2), Double(top - gh)), white)
            burtonTriangle(c, (Double(gx + gw / 2), Double(top - gh)), (Double(gx + gw), Double(top)),
                           (Double(gx + gw - k), Double(top)), shade)
        }
        c.circle(x0 + 29 * k, top - 6 * k, max(1, 2 * k), dark)                                    // the round gable window
        c.rect(x0 + 32 * k, top - 10 * k, 5 * k, 3 * k, yellow); c.rect(x0 + 2 * k, top - 4 * k, 4 * k, 3 * k, yellow)
        for wx in [x0 + 3 * k, x0 + 8 * k, x0 + 25 * k, x0 + 30 * k] { c.rect(wx, top + 4 * k, 3 * k, 4 * k, dark) }
        c.rect(x0 + 12 * k, top + 8 * k, 12 * k, 8 * k, C(0xE4E8EC)); c.rect(x0 + 12 * k, top + 8 * k, 12 * k, k, shade)
        for px in stride(from: x0 + 12 * k, through: x0 + 24 * k, by: 4 * k) { c.rect(px, top + 8 * k, k, 8 * k, white) }
        c.rect(x0 + 17 * k, top + 10 * k, 3 * k, 6 * k, C(0x8A2A2A))
        burtonStripes(c, x0, f.base - 3 * k, 36 * k, 3 * k, alongX: false, width: k)
        // The tower: tall and square, its black mansard top with a railing.
        let tx = x0 + 13 * k, ttop = top - 22 * k
        c.rect(tx, ttop, 9 * k, 22 * k, white); c.rect(tx + 8 * k, ttop, k, 22 * k, shade)
        for wy in [ttop + 3 * k, ttop + 10 * k] { c.rect(tx + 2 * k, wy, 2 * k, 4 * k, dark); c.rect(tx + 5 * k, wy, 2 * k, 4 * k, dark) }
        for r in 0..<(5 * k) { c.rect(tx - k + r / 3, ttop - r - 1, 11 * k - 2 * (r / 3), 1, r < k ? C(0x4A4E5A) : black) }
        c.rect(tx + k, ttop - 6 * k, 7 * k, k, black)
        for rx in stride(from: tx + k, through: tx + 7 * k, by: 2 * k) { c.rect(rx, ttop - 7 * k, max(1, k / 2), k, black) }
        // Fence posts down the hill, the red car, the little tree.
        for i in 0..<9 {
            let fx = x0 - 24 * k + i * 10 * k
            guard fx > 0, fx < c.w else { continue }
            let d = Double(fx - f.x) / hw, fy = f.base + Int(Double(g - f.base) * min(1, d * d)) + 3 * k
            c.rect(fx, fy - 5 * k, max(1, k), 5 * k, C(0x6A5A42))
        }
        let carX = x0 + 44 * k, carY = f.base + 4 * k
        c.rect(carX, carY - 3 * k, 12 * k, 3 * k, C(0xD82A2A)); c.rect(carX + 3 * k, carY - 5 * k, 6 * k, 2 * k, C(0xB81E1E))
        c.rect(carX + 4 * k, carY - 5 * k, 2 * k, k, C(0x8AB8E0))
        c.rect(carX + 2 * k, carY, 2 * k, k, black); c.rect(carX + 8 * k, carY, 2 * k, k, black)
        let treeX = c.w * 86 / 100, treeY = g - 2 * s
        c.rect(treeX, treeY - 10 * s * (tall ? 2 : 1), max(1, s * (tall ? 2 : 1)), 10 * s * (tall ? 2 : 1), C(0x5A4430))
        // Delia's sculptures on the lawn: black spikes, one red.
        for (i, sx) in [c.w * 10 / 100, c.w * 26 / 100].enumerated() {
            let u = Double(s * (tall ? 2 : 1)), b = Double(g)
            burtonTriangle(c, (Double(sx), b), (Double(sx) + 4 * u, b), (Double(sx) - u, b - 14 * u), burtonInk)
            burtonTriangle(c, (Double(sx) + 2 * u, b), (Double(sx) + 6 * u, b), (Double(sx) + 5 * u, b - 10 * u),
                           i == 0 ? C(0xC8202A) : burtonInk)
            burtonTriangle(c, (Double(sx) + 4 * u, b), (Double(sx) + 8 * u, b), (Double(sx) + 9 * u, b - 7 * u), burtonInk)
        }
        // The lawn the crew stands on.
        c.ground(g, C(0x3A8A32), edge: C(0x6ABA4A), speck: C(0x2E7028), seed: 61)
    }

    /// What moves at the Maitlands' house: the clouds drifting, the little tree's leaves tossing in the wind, and the
    /// curtain flapping in the tower's top window.
    static func maitlandHouseLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = mhFrame(c, g), k = f.k
        let u = s * (tall ? 2 : 1), treeX = c.w * 86 / 100, treeY = g - 2 * s - 10 * u
        for i in 0..<9 {
            let a = Double(i) / 9 * 2 * .pi, sway = sin(t * 2.2 + Double(i)) * Double(u)
            c.ellipse(treeX + Int(cos(a) * Double(5 * u) + sway), treeY + Int(sin(a) * Double(3 * u)), 3 * u, 2 * u,
                      i % 2 == 0 ? C(0x4A8A3A) : C(0x6AAA4A))
        }
        let x0 = f.x - 18 * k, top = f.base - 16 * k, tx = x0 + 13 * k, ttop = top - 22 * k
        let flap = Int((sin(t * 3) * 0.5 + 0.5) * Double(k))
        c.rect(tx + 2 * k + flap, ttop + 3 * k, max(1, k), 4 * k, C(0xF4F0E4, 0.9))
        let drift = Int(t * 2) % (c.w + 60)
        c.ellipse(drift - 30, g / 5, 10 * s, 2 * s, C(0xF4F6FA, 0.6))
    }
}

// MARK: - The model town in the attic

extension Scenes {
    /// The attic table's top seen from the front: its front edge (row and ends) and its far edge, and the model's unit.
    static func mtFrame(_ c: PixelCanvas, _ g: Int) -> (front: Int, back: Int, fx0: Int, fx1: Int, bx0: Int, bx1: Int, k: Int) {
        let s = unit(g), tall = isTall(c)
        return (g - (tall ? 34 : 10) * s, g - (tall ? 150 : 34) * s, c.w * 6 / 100, c.w * 94 / 100, c.w * 20 / 100,
                c.w * 82 / 100, (tall ? 3 : 1) * s)
    }

    /// A point on the model: `u` across (0 left, 1 right) and `d` deep (0 the far edge, 1 the front), and how big
    /// things are drawn there (smaller towards the back).
    static func mtAt(_ f: (front: Int, back: Int, fx0: Int, fx1: Int, bx0: Int, bx1: Int, k: Int), _ u: Double, _ d: Double)
        -> (x: Int, y: Int, z: Double) {
        let x0 = Double(f.bx0) + Double(f.fx0 - f.bx0) * d, x1 = Double(f.bx1) + Double(f.fx1 - f.bx1) * d
        return (Int(x0 + (x1 - x0) * u), Int(Double(f.back) + Double(f.front - f.back) * d), 0.55 + 0.45 * d)
    }

    /// A little model house at (x, y) (its front's bottom), `z` its scale: walls, a grey roof, a lit window or two.
    private static func mtHouse(_ c: PixelCanvas, x: Int, y: Int, z: Double, k: Int, barn: Bool, seed: Int) {
        let u = max(1, Int((Double(k) * z).rounded())), w = (barn ? 7 : 5) * u, h = (barn ? 4 : 3) * u
        let wall = barn ? C(0x8A3A2A) : (noise(seed) > 0.3 ? C(0xE4E4DC) : C(0xC8C8C0))
        c.rect(x, y - h, w, h, wall); c.rect(x + w - u, y - h, u, h, lerp(wall, C(0x000000), 0.25))
        for r in 0..<(2 * u) { c.rect(x - u + r / 2, y - h - r - 1, w + 2 * u - r, 1, r < u ? C(0x8A8A90) : C(0x6A6A72)) }
        c.rect(x + u, y - h + u, u, u, C(0xFFE08A)); if !barn { c.rect(x + 3 * u, y - h + u, u, u, C(0xFFE08A)) }
    }

    /// Adam's model of Winter River in the dark wooden attic: a brick wall on the left and bare boards on the right,
    /// a big sloping beam, bare globe bulbs hanging on their cords, a louvred window, dust sheets draped down the
    /// sides; and the long table, its top seen from the front with the whole model on it: rolling fields, rows of
    /// tiny white houses and red barns with lit windows, the white church and its steeple, a little graveyard, a
    /// stream and its red covered bridge, and at the back on its own hill, the Maitlands' white house. Plank floor. On
    /// the screen saver, the rafters up into the roof and a dusty skylight.
    static func modelWinterRiver(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = mtFrame(c, g), k = f.k
        let wood = C(0x3A2A1E), woodD = C(0x281C14), woodL = C(0x5A4430), sheet = C(0xC8B89A), sheetD = C(0x9A8A6E)
        c.gradient(0, g, C(0x140E0A), C(0x2E2218), bands: 5)
        // The back wall: brick on the left, boards on the right.
        let brickR = c.w * 32 / 100
        for y in stride(from: 0, to: g, by: 3 * s) {
            for x in stride(from: ((y / (3 * s)) % 2) * 3 * s, to: brickR, by: 6 * s) {
                c.rect(x, y, 5 * s, 2 * s, noise(x * 7 + y) > 0.5 ? C(0x4A2A20) : C(0x3E241C))
            }
        }
        for x in stride(from: brickR, to: c.w, by: 6 * s) { c.rect(x, 0, 6 * s, g, noise(x + 4100) > 0.5 ? wood : C(0x342418)); c.rect(x, 0, s, g, woodD) }
        // The big sloping beam, and the rafters and skylight on the screen saver.
        burtonLine(c, Double(c.w * 36 / 100), 0, Double(c.w * 74 / 100), Double(f.back), woodL, Double(3 * s))
        if tall {
            for i in 0..<6 { burtonLine(c, Double(c.w * i / 5), Double(g / 4), Double(c.w / 2), 0, woodD, Double(2 * s)) }
            c.rect(0, g / 4, c.w, 3 * s, woodD)
            let sx = c.w * 58 / 100, sw = 46 * s
            c.rect(sx, 6 * s, sw, 26 * s, C(0x5A6A78)); c.rect(sx + sw / 2 - s, 6 * s, 2 * s, 26 * s, woodD); c.rect(sx, 18 * s, sw, 2 * s, woodD)
        }
        // The louvred window on the right, light through its slats.
        let wx = c.w * 84 / 100, ww = 16 * s, wy = f.back - (tall ? 90 : 22) * s, wh = (tall ? 80 : 20) * s
        c.rect(wx, wy, ww, wh, woodD)
        for y in stride(from: wy + s, to: wy + wh - s, by: 2 * s) { c.rect(wx + s, y, ww - 2 * s, s, C(0xC8C4B0)) }
        // Bare globe bulbs hanging on their cords.
        for (bx, col) in [(c.w * 46 / 100, C(0xF4F4F0)), (c.w * 66 / 100, C(0xF8E080))] {
            let by = f.back - (tall ? 60 : 16) * s
            c.rect(bx, 0, s, by, C(0x14100C))
            c.circle(bx, by + 3 * s, 5 * s, col.alpha(0.18)); c.circle(bx, by + 3 * s, 2 * s + s / 2, col)
        }
        // The table's top: the model's land, fields in two greens, the far edge lit.
        for y in f.back..<f.front {
            let d = Double(y - f.back) / Double(f.front - f.back)
            let a = mtAt(f, 0, d), b = mtAt(f, 1, d)
            for x in a.x..<b.x {
                let field = Int(Double(x) / (18 * Double(k)) + Double(y) / (6 * Double(k))) % 3
                c.px(x, y, field == 0 ? C(0x7A7A48) : field == 1 ? C(0x6A6A3E) : C(0x5E6438))
            }
        }
        c.rect(f.bx0, f.back, f.bx1 - f.bx0, s, C(0x8A8A5A))
        // The stream winding across, its red covered bridge.
        for i in 0..<60 {
            let d = Double(i) / 59, p = mtAt(f, 0.3 + sin(d * 3) * 0.06, d)
            c.rect(p.x, p.y, max(1, Int(3 * Double(k) * p.z)), max(1, Int(Double(k) * p.z)), C(0x4A6A8A))
        }
        let bp = mtAt(f, 0.3 + sin(0.55 * 3) * 0.06, 0.55)
        c.rect(bp.x - 3 * k, bp.y - 3 * k, 8 * k, 3 * k, C(0x9A3A2A)); c.rect(bp.x - 4 * k, bp.y - 4 * k, 10 * k, k, C(0x5A5A62))
        // The Maitlands' house on its own hill at the back right.
        let hp = mtAt(f, 0.86, 0.06)
        c.ellipse(hp.x, hp.y, 20 * k, 7 * k, C(0x6A6A3E)); c.ellipse(hp.x, hp.y - k, 18 * k, 6 * k, C(0x7A7A48))
        c.rect(hp.x - 3 * k, hp.y - 9 * k, 7 * k, 4 * k, C(0xF4F4F0)); c.rect(hp.x - k, hp.y - 13 * k, 2 * k, 4 * k, C(0xF4F4F0))
        c.rect(hp.x - k, hp.y - 14 * k, 2 * k, k, C(0x1E2028)); c.rect(hp.x + 2 * k, hp.y - 8 * k, k, k, C(0xFFE08A))
        // Rows of houses and barns, the church and its steeple, the graveyard, back to front so the near ones overlap.
        for row in 0..<5 {
            let d = 0.12 + Double(row) * 0.2
            for i in 0..<6 {
                let u = 0.04 + Double(i) * 0.15 + (noise(row * 9 + i + 4200) - 0.5) * 0.06
                guard abs(u - 0.31) > 0.06, !(row == 2 && i == 3), !(row == 0 && u > 0.66) else { continue }
                let p = mtAt(f, u, d)
                mtHouse(c, x: p.x, y: p.y, z: p.z, k: k, barn: (row + i) % 4 == 1, seed: row * 9 + i + 4220)
            }
        }
        let cp = mtAt(f, 0.53, 0.5), cu = max(1, Int(Double(k) * cp.z))
        c.rect(cp.x, cp.y - 5 * cu, 6 * cu, 5 * cu, C(0xF4F4F0)); c.rect(cp.x + 2 * cu, cp.y - 10 * cu, 2 * cu, 5 * cu, C(0xF4F4F0))
        c.rect(cp.x + 2 * cu, cp.y - 13 * cu, cu, 3 * cu, C(0xF4F4F0)); c.rect(cp.x + 2 * cu, cp.y - 3 * cu, 2 * cu, 3 * cu, C(0xFFE08A))
        for i in 0..<6 { c.rect(cp.x + 8 * cu + (i % 3) * 2 * cu, cp.y - (i / 3) * 2 * cu - cu, cu, cu + cu / 2, C(0xA8A8B0)) }
        // The table's front edge and its dark face, down to the floor.
        c.rect(f.fx0, f.front, f.fx1 - f.fx0, 2 * s, woodL); c.rect(f.fx0, f.front + 2 * s, f.fx1 - f.fx0, g - f.front - 2 * s, woodD)
        // Dust sheets draped down the edges.
        for (sx, w) in [(0, c.w * 5 / 100), (c.w * 96 / 100, c.w * 4 / 100)] {
            for x in sx..<(sx + w) {
                let fold = Int(sin(Double(x) * 0.5) * 2)
                c.rect(x, g / 5 + fold, 1, g - g / 5 - fold, (x / 2) % 3 == 0 ? sheetD : sheet)
            }
        }
        // The plank floor the crew stands on.
        c.rect(0, g, c.w, c.h - g, C(0x4A3A2C)); c.rect(0, g, c.w, s, C(0x6A5440))
        for y in stride(from: g + 3 * s, to: c.h, by: 3 * s) { c.rect(0, y, c.w, s, C(0x3A2C20)) }
    }

    /// What moves in the attic: strings of little lights twinkling on their wires, a spider picking its way across the
    /// model on its long legs, and a tiny gravestone in the model's graveyard wobbling.
    static func modelWinterRiverLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = mtFrame(c, g), k = f.k
        for strand in 0..<3 {
            let y0 = f.back * (20 + strand * 22) / 100
            for i in 0..<18 {
                let x = c.w * (18 + i * 4) / 100 + strand * 5 * s, y = y0 + Int(sin(Double(i) / 17 * .pi) * Double(6 * s))
                let on = noise(Int(t * 2) + i * 7 + strand * 31) > 0.3
                c.rect(x, y, s, s, C(0xFFF0C0, on ? 0.95 : 0.35))
            }
        }
        // The spider, crossing the model and back.
        let p = mtAt(f, 0.15 + (sin(t * 0.2) * 0.5 + 0.5) * 0.7, 0.62 + sin(t * 0.13) * 0.2)
        let step = Int(t * 6) % 2 == 0, ink = C(0x0C0A08)
        c.rect(p.x - k, p.y - 2 * k, 3 * k, 2 * k, ink); c.rect(p.x + 2 * k, p.y - 2 * k, k, k, ink)
        for leg in 0..<4 {
            let lx = p.x - 3 * k + leg * 2 * k, up = (leg % 2 == 0) == step
            c.rect(lx, p.y - (up ? 3 : 1) * k, k, k, ink); c.rect(lx, p.y, k, k, ink)
        }
        // A tiny gravestone wobbling.
        let cp = mtAt(f, 0.53, 0.5), cu = max(1, Int(Double(k) * cp.z))
        let wob = sin(t * 6) > 0.6 ? cu : 0
        c.rect(cp.x + 12 * cu + wob, cp.y - 3 * cu, cu, cu + cu / 2, C(0xC8C8D0))
    }
}

// MARK: - The Afterlife waiting room

extension Scenes {
    /// The Afterlife's waiting room for the recently deceased: mottled sea-green walls, a "NO EXIT" sign over a door
    /// of frosted glass, a fish mounted on a plaque, a long lumpy sofa and a row of plastic chairs, a lamp with a huge
    /// glowing shade, a two-tier oval coffee table piled with magazines, a red ticket dispenser on its stand, the
    /// "NOW SERVING" board, and the information window with its blind half down; a black-and-white chequered floor.
    /// On the screen saver, the room's walls run up into a mile of filing cabinets disappearing into the dark.
    static func afterlifeWaitingRoom(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        let wall = C(0x3A6A5E), wallD = C(0x2A5248), wallL = C(0x4E8070), cream = C(0xE8E4D4)
        let roomTop = tall ? g - 110 * s : 0
        if tall {
            // A mile of filing cabinets, tall and grey-green, rank behind rank up into the dark, the ceiling's edge
            // under them.
            c.gradient(0, roomTop, C(0x05080A), C(0x1A2A26), bands: 6)
            let cw = 12 * s, drawer = 6 * s, unitH = 4 * drawer + 2 * s
            for rank in 0..<(roomTop / unitH + 1) {
                let y = roomTop - (rank + 1) * unitH, fade = max(0.12, 1 - Double(rank) * 0.12)
                let body = lerp(C(0x05080A), C(0x5A6A62), fade), edge = lerp(C(0x05080A), C(0x8A9A90), fade)
                let handle = lerp(C(0x05080A), C(0xC8D0C0), fade)
                for x in stride(from: (rank % 2) * cw / 2 - cw, to: c.w, by: cw + 2 * s) {
                    for d in 0..<4 {
                        let dy = y + d * drawer
                        c.rect(x, dy, cw, drawer - s, body); c.rect(x, dy, cw, s, edge)
                        c.rect(x + cw / 2 - 2 * s, dy + drawer / 2, 4 * s, s, handle); c.rect(x + cw / 2 - s, dy + 2 * s, 2 * s, s, edge)
                    }
                }
            }
            c.rect(0, roomTop - 2 * s, c.w, 2 * s, C(0x2A4A40))
        }
        // The mottled sea-green walls.
        c.rect(0, roomTop, c.w, g - roomTop, wall)
        for i in 0..<(c.w * (g - roomTop) / 30) {
            let x = Int(noise(i * 3 + 4300) * Double(c.w)), y = roomTop + Int(noise(i * 3 + 4301) * Double(g - roomTop))
            c.rect(x, y, s, s, noise(i * 3 + 4302) > 0.5 ? wallD : wallL)
        }
        c.rect(0, g - 10 * k, c.w, s, wallD)
        // The door on the left under its "NO EXIT" sign.
        let dx = c.w * 4 / 100, dw = 14 * k, dh = 30 * k
        c.rect(dx - s, g - dh - s, dw + 2 * s, dh + s, C(0x1E2E2A)); c.rect(dx, g - dh, dw, dh, C(0x5A7A6E))
        c.rect(dx + 2 * k, g - dh + 2 * k, dw - 4 * k, dh / 2, C(0xB8D8C8)); c.rect(dx + dw - 3 * k, g - dh / 2, k, k, C(0xD8C870))
        let ne = "NO EXIT", nw = bjTextWidth(ne, s: s)
        c.rect(dx + dw / 2 - nw / 2 - 2 * s, g - dh - 10 * s, nw + 4 * s, 9 * s, C(0x101814))
        bjText(c, ne, x: dx + dw / 2 - nw / 2, y: g - dh - 8 * s, s: s, C(0xE8F4E8))
        // The fish on its plaque, and a picture of a far city.
        let fx = c.w * 22 / 100, fy = g - 34 * k
        c.rect(fx, fy, 16 * k, 8 * k, C(0x6A4A2A)); c.rect(fx + s, fy + s, 16 * k - 2 * s, 8 * k - 2 * s, C(0x8AA87A))
        c.pattern(fx + 3 * k, fy + 2 * k, bjScale(["..FFFFFF.F", ".FFFFFFFFF", "FKFFFFFF.F", ".FFFFFF..."], k),
                  ["F": C(0x5A6A4A), "K": C(0x14140E)])
        let px = c.w * 74 / 100
        c.rect(px, g - 36 * k, 18 * k, 12 * k, C(0x4A3A22)); c.rect(px + s, g - 36 * k + s, 18 * k - 2 * s, 12 * k - 2 * s, C(0x7A8A80))
        for i in 0..<6 { let bh = (3 + Int(noise(i + 4310) * 6)) * k; c.rect(px + 2 * k + i * 2 * k + k, g - 25 * k - bh, 2 * k, bh, C(0x3A4440)) }
        // The "NOW SERVING" board high on the wall.
        let bx = c.w * 52 / 100, by = g - 40 * k
        let ns = "NOW SERVING", nsw = bjTextWidth(ns, s: s)
        c.rect(bx - 2 * s, by - 9 * s, max(nsw, 14 * k) + 4 * s, 9 * s + 10 * k, C(0x14100E))
        bjText(c, ns, x: bx, y: by - 7 * s, s: s, cream)
        // The information window, its blind half down.
        let ix = c.w * 84 / 100, iw = 22 * k, ih = 16 * k, iy = g - 28 * k
        c.rect(ix - s, iy - s, iw + 2 * s, ih + 2 * s, C(0x1E2E2A)); c.rect(ix, iy, iw, ih, C(0x8A6A8A))
        for y in stride(from: iy, to: iy + ih / 2, by: 2 * s) { c.rect(ix, y, iw, s, C(0xC8C4A8)) }
        c.rect(ix - 2 * s, iy + ih + s, iw + 4 * s, 4 * s, C(0x5A4A32))
        let inf = "INFORMATION", infw = bjTextWidth(inf, s: s)
        if infw < iw + 4 * s { bjText(c, inf, x: ix + iw / 2 - infw / 2, y: iy + ih, s: s, cream) }
        // The ticket dispenser on its stand.
        let tx = c.w * 66 / 100
        c.rect(tx, g - 16 * k, k, 16 * k, C(0x2A2A30)); c.rect(tx - 2 * k, g - 22 * k, 5 * k, 6 * k, C(0xC8202A))
        c.rect(tx - k, g - 19 * k, 3 * k, k, C(0xF4F0E4))
        let tn = "TAKE A NUMBER", tw = bjTextWidth(tn, s: s)
        c.rect(tx - tw / 2 - 2 * s, g - 22 * k - 10 * s, tw + 4 * s, 9 * s, C(0x14100E))
        bjText(c, tn, x: tx - tw / 2, y: g - 22 * k - 8 * s, s: s, C(0xF8D848))
        // The long lumpy sofa, the plastic chairs, the lamp.
        let sx = c.w * 18 / 100, sw = 40 * k
        c.rect(sx, g - 12 * k, sw, 7 * k, C(0x8AA890)); c.rect(sx - 2 * k, g - 9 * k, 3 * k, 6 * k, C(0x7A9880))
        c.rect(sx + sw - k, g - 9 * k, 3 * k, 6 * k, C(0x7A9880)); c.rect(sx, g - 6 * k, sw, 3 * k, C(0x9AB8A0))
        for i in 0..<3 { c.rect(sx + i * sw / 3, g - 12 * k, k, 6 * k, C(0x7A9880)) }
        for i in 0..<3 {
            let chx = c.w * 70 / 100 + i * 10 * k
            c.rect(chx, g - 11 * k, 6 * k, 5 * k, C(0xA8C8B8)); c.rect(chx, g - 6 * k, 6 * k, k, C(0x8AA898))
            c.rect(chx, g - 5 * k, max(1, k / 2 + k / 2), 5 * k, C(0x3A3A40)); c.rect(chx + 5 * k, g - 5 * k, max(1, k / 2 + k / 2), 5 * k, C(0x3A3A40))
        }
        let lx = c.w * 57 / 100
        c.rect(lx - 2 * k, g - 6 * k, 4 * k, 6 * k, C(0x3A8A5A)); c.rect(lx, g - 18 * k, max(1, k / 2 + k / 2), 12 * k, C(0x3A3A30))
        for r in 0..<(8 * k) { c.rect(lx - 4 * k - r / 3, g - 26 * k + r, 9 * k + 2 * (r / 3), 1, C(0xE8D8A8)) }
        // The two-tier oval coffee table with its magazines.
        let cx = c.w * 44 / 100
        c.ellipse(cx, g - 6 * k, 14 * k, 2 * k, C(0x9A8A6A)); c.ellipse(cx, g - 3 * k, 12 * k, 2 * k, C(0x8A7A5A))
        c.rect(cx - 10 * k, g - 5 * k, max(1, k / 2 + k / 2), 5 * k, C(0x1A1A1A)); c.rect(cx + 10 * k, g - 5 * k, max(1, k / 2 + k / 2), 5 * k, C(0x1A1A1A))
        c.rect(cx - 8 * k, g - 8 * k, 6 * k, k, C(0xF0ECE0)); c.rect(cx + 2 * k, g - 8 * k, 5 * k, k, C(0xC8303A))
        // The black-and-white chequered floor.
        let tile = 4 * k
        c.rect(0, g, c.w, c.h - g, C(0x1A1C1C))
        for y in stride(from: g, to: c.h, by: tile) {
            for x in stride(from: ((y - g) / tile % 2) * tile, to: c.w, by: tile * 2) { c.rect(x, y, tile, tile, C(0xD8D8CC)) }
        }
    }

    /// What moves in the waiting room: the number board ticking over now and then (with a flash), the lamp and the
    /// strip light buzzing and flickering.
    static func afterlifeWaitingRoomLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        let bx = c.w * 52 / 100, by = g - 40 * k
        let n = 3 + Int(t / 6) % 97, justTicked = frac(t / 6) < 0.08
        bjText(c, String(format: "%02d", n), x: bx + 2 * k, y: by + 2 * s, s: 2 * k, C(0xFF3A2A, justTicked ? 1 : 0.9))
        if justTicked { c.rect(bx - 2 * s, by, 14 * k, 10 * k, C(0xFF3A2A, 0.15)) }
        let buzz = noise(Int(t * 12)) > 0.9 ? 0.0 : 1.0
        let lx = c.w * 57 / 100
        c.ellipse(lx, g - 22 * k, 10 * k, 6 * k, C(0xFFF0B0, 0.12 * buzz))
        c.rect(0, 0, c.w, g, C(0xC8FFE0, 0.03 * buzz))
    }
}

// MARK: - The Land of the Dead

extension Scenes {
    /// Where the Ball and Socket stands, its width and height, and the size unit.
    static func ldFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, w: Int, h: Int, k: Int) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s
        return (c.w * 50 / 100, 52 * k, (tall ? 34 : 30) * k, k)
    }

    /// A crooked house of the dead: a tall narrow front leaning over as it rises, a steep shingled roof, a crooked
    /// chimney, one or two little windows glowing green, now and then a balcony; its door at the bottom.
    private static func ldHouse(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, lean: Int, k: Int, wall: Px, seed: Int) {
        let glow = C(0x8AF0A0), roof = C(0x2A2620), roofL = C(0x3E3830), dark = lerp(wall, C(0x000000), 0.4)
        func offset(_ r: Int) -> Int { Int(Double(lean) * pow(Double(r) / Double(max(1, h)), 1.8)) }
        for r in 0..<h { c.rect(x + offset(r), base - r - 1, w, 1, wall); c.px(x + offset(r) + w - 1, base - r - 1, dark) }
        // The roof: steep, shingled, overhanging a little, tipping the way the house leans.
        let topX = x + offset(h), top = base - h, roofH = w * (10 + Int(noise(seed) * 8)) / 10
        for r in 0..<roofH {
            let half = Double(w / 2 + k) * (1 - Double(r) / Double(roofH))
            let cx = Double(topX) + Double(w) / 2 + Double(lean) * 0.5 * Double(r) / Double(roofH)
            c.rect(Int(cx - half), top - r - 1, max(1, Int(half * 2)), 1, (r / k) % 2 == 0 ? roofL : roof)
        }
        if noise(seed + 2) > 0.4 {
            let chx = topX + w * 3 / 4
            c.rect(chx, top - roofH / 2 - 3 * k, k, roofH / 2 + 3 * k, dark); c.rect(chx - k / 2, top - roofH / 2 - 3 * k, 2 * k, k, roof)
        }
        // Little windows glowing green, one or two, oval or square; a balcony now and then.
        let n = noise(seed + 3) > 0.5 ? 2 : 1
        for i in 0..<n {
            let r = h * (i == 0 ? 60 : 30) / 100, wx = x + offset(r) + w / 2 - k
            if noise(seed + 4 + i) > 0.5 { c.ellipse(wx + k / 2, base - r, k, k + k / 2, glow) }
            else { c.rect(wx - k / 2, base - r - k, 2 * k, 3 * k, glow); c.rect(wx, base - r - k, max(1, k / 2), 3 * k, roof) }
        }
        if noise(seed + 6) > 0.6 {
            let r = h * 45 / 100
            c.rect(x + offset(r) - k, base - r, w + 2 * k, k, roof)
            for bx in stride(from: x + offset(r) - k, to: x + offset(r) + w + k, by: 2 * k) { c.rect(bx, base - r - 2 * k, max(1, k / 2), 2 * k, roof) }
        }
        c.rect(x + w / 3, base - 4 * k, max(1, w / 3), 4 * k, C(0x14100C))
    }

    /// The Land of the Dead: a dark street of crooked houses, every height, leaning over each other under a murky
    /// green-purple sky, their little windows glowing green, gas lamps along the cobbles; in the middle, the Ball and
    /// Socket, the pub, its upper floor overhanging the street, warm light at its door and in its bay windows, its name
    /// on a board, and its round sign hanging out on a bracket: a grinning skull. On the screen saver, crooked spires up
    /// into the swirling murk.
    static func landOfTheDead(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ldFrame(c, g), k = f.k
        c.gradient(0, g, C(0x0A0812), C(0x1E3A2A), bands: 7)
        if tall {
            // Swirls of murk in the sky, and crooked spires far off.
            for i in 0..<40 {
                let a = Double(i) * 0.6, r = Double(i) * 4 * Double(s)
                c.ellipse(c.w / 2 + Int(cos(a) * r), g / 4 + Int(sin(a) * r * 0.4), 14 * s, 3 * s, C(0x5A3A7A, 0.08))
            }
            for i in 0..<12 {
                let sx = Int(noise(i + 4400) * Double(c.w)), sh = (40 + Int(noise(i + 4401) * 60)) * s
                ldHouse(c, x: sx, base: g - 60 * s, w: 8 * s, h: sh, lean: Int((noise(i + 4402) - 0.5) * Double(16 * s)), k: s,
                        wall: C(0x1A1E1A), seed: i + 4403)
            }
        }
        // The crooked houses along the street: every height and width, leaning, a lilac one here and there.
        let walls = [C(0x4A3A2E), C(0x3A4230), C(0x6A4A62), C(0x5A4636), C(0x3A3A42), C(0x4A4A2E)]
        var x = -6 * k, i = 0
        while x < c.w {
            let w = (8 + Int(noise(i + 4410) * 9)) * k
            let h = (tall ? 30 : 16) * k + Int(noise(i + 4411) * Double((tall ? 26 : 22) * k))
            if abs(x + w / 2 - f.x) > f.w / 2 + w / 2 + 2 * k {
                ldHouse(c, x: x, base: g, w: w, h: h, lean: Int((noise(i + 4412) - 0.5) * Double(14 * k)), k: k,
                        wall: walls[i % walls.count], seed: i * 7 + 4413)
            }
            x += w + Int(noise(i + 4414) * 2) * k; i += 1
        }
        // The Ball and Socket: the ground floor, the upper floor overhanging it, two gables.
        let px = f.x - f.w / 2, low = f.h / 2
        c.rect(px, g - low, f.w, low, C(0x3A2A3A)); c.rect(px + f.w - k, g - low, k, low, C(0x241A24))
        c.rect(px - 2 * k, g - f.h, f.w + 4 * k, f.h - low, C(0x4A3448)); c.rect(px - 2 * k, g - low - k, f.w + 4 * k, k, C(0x241A24))
        for gx in [px - 2 * k, px + f.w / 2] {
            let gw = f.w / 2 + 2 * k
            for r in 0..<(gw * 3 / 4) {
                let half = gw / 2 * (gw * 3 / 4 - r) / (gw * 3 / 4)
                c.rect(gx + gw / 2 - half, g - f.h - r - 1, half * 2, 1, (r / k) % 2 == 0 ? C(0x3E3830) : C(0x2A2620))
            }
            c.ellipse(gx + gw / 2, g - f.h - gw / 4, k, k + k / 2, C(0x8AF0A0))
        }
        for wx in [px + 4 * k, px + f.w - 14 * k] {
            c.rect(wx, g - low + 3 * k, 10 * k, low - 7 * k, C(0xF0A040)); c.rect(wx + k, g - low + 4 * k, 8 * k, low - 9 * k, C(0xFFC860))
            for mx in stride(from: wx + 3 * k, to: wx + 10 * k, by: 3 * k) { c.rect(mx, g - low + 3 * k, max(1, k / 2), low - 7 * k, C(0x2A1A14)) }
        }
        for wx in stride(from: px + 3 * k, to: px + f.w - 4 * k, by: 9 * k) { c.rect(wx, g - f.h + 4 * k, 4 * k, 6 * k, C(0x8AF0A0)) }
        c.rect(f.x - 4 * k, g - 11 * k, 8 * k, 11 * k, C(0xF0A040)); c.rect(f.x - 3 * k, g - 10 * k, 6 * k, 10 * k, C(0xFFC860))
        // Its name on a board over the door.
        let name = "BALL & SOCKET", nw = bjTextWidth(name, s: s)
        c.rect(f.x - nw / 2 - 2 * s, g - low - 8 * s, nw + 4 * s, 7 * s, C(0x2A1A14))
        bjText(c, name, x: f.x - nw / 2, y: g - low - 7 * s, s: s, C(0xF0E6C8))
        // The round sign on its bracket: a grinning skull.
        let sx = px + f.w + 9 * k, sy = g - f.h + 8 * k
        c.rect(px + f.w + 2 * k, sy - 8 * k, 9 * k, k, C(0x1A1410)); c.rect(sx, sy - 8 * k, max(1, k / 2), 2 * k, C(0x1A1410))
        c.circle(sx, sy, 6 * k, C(0x6A4A2E)); c.circle(sx, sy, 5 * k, C(0xB8946A))
        c.pattern(sx - 3 * k, sy - 3 * k, bjScale([".WWWW..", "WKWWKW.", "WKWWKWW", "WWWWWWW", ".WKWKWW", "..WWW.."], k),
                  ["W": C(0xF0E6C8), "K": C(0x2A1E14)])
        // Gas lamps along the street.
        for lx in stride(from: c.w / 12, to: c.w, by: c.w / 4) where abs(lx - f.x) > f.w / 2 + 12 * k {
            c.rect(lx, g - 18 * k, max(1, k), 18 * k, C(0x14140E)); c.rect(lx - k, g - 21 * k, 3 * k, 3 * k, C(0x2A2A22))
            c.circle(lx, g - 20 * k, 4 * k, C(0x8AF0A0, 0.18)); c.rect(lx, g - 20 * k, max(1, k), k, C(0xC8FFD0))
        }
        // The dark cobbled street.
        c.rect(0, g, c.w, c.h - g, C(0x1A1C1A)); c.rect(0, g, c.w, s, C(0x3A4A3A))
        for y in stride(from: g + 2 * s, to: c.h, by: 3 * s) {
            for cx in stride(from: ((y - g) / (3 * s) % 2) * 2 * s, to: c.w, by: 5 * s) { c.rect(cx, y, 4 * s, 2 * s, C(0x262A26)) }
        }
    }

    /// What moves in the Land of the Dead: lanterns strung across the street on sagging wires, swaying and glowing, the
    /// gas lamps flickering, the pub's windows pulsing to the band, and a skeleton's head bobbing in one of them.
    static func landOfTheDeadLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = ldFrame(c, g), k = f.k
        let cols = [C(0x8AF0A0), C(0xF0A040), C(0xB87AF0), C(0xF0E070)]
        for strand in 0..<(tall ? 2 : 1) {
            let y0 = g - (tall ? 70 + strand * 30 : 34) * k / (tall ? 2 : 1), span = c.w / 2
            for x in 0..<c.w {
                let u = Double(x % span) / Double(span), y = y0 + Int(sin(u * .pi) * Double(8 * s) + sin(t * 1.5) * Double(s))
                c.px(x, y, C(0x0C0A08, 0.8))
            }
            for i in 0..<12 {
                let x = (i * c.w / 12 + strand * c.w / 24) % c.w + c.w / 48, u = Double(x % span) / Double(span)
                let y = y0 + Int(sin(u * .pi) * Double(8 * s) + sin(t * 1.5) * Double(s)) + k
                let col = cols[(i + strand) % cols.count], a = 0.7 + 0.3 * sin(t * 2 + Double(i * 3))
                c.circle(x, y + k, 3 * k, col.alpha(0.15 * a)); c.rect(x - k, y, 2 * k, 3 * k, col.alpha(a))
            }
        }
        for lx in stride(from: c.w / 12, to: c.w, by: c.w / 4) where abs(lx - f.x) > f.w / 2 + 12 * k {
            c.rect(lx, g - 20 * k, max(1, k), k, C(0xE8FFE8, 0.6 + 0.4 * noise(Int(t * 8) + lx)))
        }
        // The band thumping inside: the bay windows pulsing, a skeleton's head bobbing in the right one.
        let px = f.x - f.w / 2, low = f.h / 2, beat = frac(t * 2) < 0.3
        c.rect(px + 5 * k, g - low + 4 * k, 8 * k, low - 9 * k, C(0xFFF0C0, beat ? 0.35 : 0.08))
        let bob = beat ? 0 : k
        c.pattern(px + f.w - 11 * k, g - low + 4 * k + bob, bjScale([".WWW.", "WKWKW", ".WWW.", ".W.W."], k),
                  ["W": C(0xF0E6C8), "K": C(0x14100C)])
    }
}
