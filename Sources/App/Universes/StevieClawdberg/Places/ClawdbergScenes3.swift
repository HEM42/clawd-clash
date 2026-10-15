import Foundation

// Jaws: Amity Island's beach on the Fourth of July, and the deck of the Orca out at sea.

let clawdbergScenes3: [Location: Place] = [
    .amityBeach: Place(name: "Amity Island", panel: 0x0E2434, still: Scenes.amityBeach, moving: Scenes.amityBeachLife),
    .orca: Place(name: "The Orca", panel: 0x142028, still: Scenes.orca, moving: Scenes.orcaLife),
]

// MARK: - Shared bits for this file

/// Signwriting in a 3×5 pixel font (M and W five wide, N four), centred on `cx`.
private func cb3Text(_ c: PixelCanvas, _ text: String, cx: Int, y: Int, s: Int, col: Px) {
    let width = text.reduce(0) { $0 + (cb3Glyphs[$1]?[0].count ?? 3) + 1 } - 1
    var x = cx - width * s / 2
    for ch in text {
        let rows = cb3Glyphs[ch] ?? cb3Glyphs[" "]!
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" { c.rect(x + dx * s, y + dy * s, s, s, col) }
        }
        x += (rows[0].count + 1) * s
    }
}

private let cb3Glyphs: [Character: [String]] = [
    "A": [".#.", "#.#", "###", "#.#", "#.#"], "C": [".##", "#..", "#..", "#..", ".##"],
    "D": ["##.", "#.#", "#.#", "#.#", "##."], "E": ["###", "#..", "##.", "#..", "###"],
    "I": ["###", ".#.", ".#.", ".#.", "###"], "L": ["#..", "#..", "#..", "#..", "###"],
    "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"], "N": ["#..#", "##.#", "#.##", "#..#", "#..#"],
    "O": [".#.", "#.#", "#.#", "#.#", ".#."], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
    "S": [".##", "#..", ".#.", "..#", "##."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "U": ["#.#", "#.#", "#.#", "#.#", "###"], "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"],
    "Y": ["#.#", "#.#", ".#.", ".#.", ".#."], " ": [".", ".", ".", ".", "."],
]

/// A shark's dorsal fin, `h` rows tall, its back edge straight and its front swept, tip at (`x`, `y`) facing left.
private func cb3Fin(_ c: PixelCanvas, x: Int, y: Int, h: Int, s: Int, col: Px, shade: Px) {
    for k in 0..<h {
        let front = k * 3 / 4, back = k / 4
        c.rect(x - front, y + k, front + back + s, 1, col)
        c.rect(x + back, y + k, s, 1, shade)
    }
}

// MARK: - Amity Island

extension Scenes {
    /// Where things are on the beach: the horizon, the shoreline, and the billboard on the screen saver.
    private static func amityFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, shore: Int,
                                                                   board: (x: Int, y: Int, w: Int, h: Int)) {
        let s = unit(g), tall = isTall(c)
        let horizon = g - (tall ? 64 : 32) * s
        let shore = g - (tall ? 16 : 10) * s
        let bw = 150 * s, bh = 62 * s
        return (horizon, shore, (c.w * 30 / 100 - bw / 2, g - 230 * s, bw, bh))
    }

    /// Amity's beach on the Fourth of July: a high summer sky, the bunting strung between flagpoles along the top,
    /// a blue sea with swimmers' heads and a yellow raft, the striped umbrellas and the lifeguard's chair on the
    /// sand. On the screen saver the AMITY ISLAND WELCOMES YOU billboard stands over the beach, the swimmer on her
    /// float painted on it and the shark fin and teeth somebody added.
    static func amityBeach(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = amityFrame(c, g)
        c.gradient(0, f.horizon, C(0x3A8AD8), C(0xC4E6F6), bands: 7)
        for i in 0..<(tall ? 7 : 3) {
            let y = tall ? Int(noise(i + 210) * Double(f.horizon - 40 * s)) + 20 * s : (6 + i * 5) * s
            cloud(c, Int(noise(i + 200) * Double(c.w)), y, (tall ? 6 : 3) * s, seed: i + 20)
        }
        if tall { amityBillboard(c, g) }
        // The sea: deep blue to the horizon, paler bands in, the swell's lines.
        c.gradient(f.horizon, f.shore, C(0x1E5A98), C(0x3AA0C8), bands: 5)
        c.rect(0, f.horizon, c.w, s, C(0x16467A))
        for i in 0..<(c.w * (f.shore - f.horizon) / 220) {
            let x = Int(noise(i * 3 + 500) * Double(c.w)), y = f.horizon + 2 * s + Int(noise(i * 3 + 501) * Double(f.shore - f.horizon - 4 * s))
            c.rect(x, y, (3 + Int(noise(i * 3 + 502) * 5)) * s, s, C(0xBFE6F2, 0.45))
        }
        // The bunting: red, white and blue pennants hung between poles, each pole with its flag.
        let poleTop = f.horizon - (tall ? 40 : 30) * s
        let poles = stride(from: c.w * 6 / 100, to: c.w, by: c.w * 22 / 100).map { $0 }
        for (i, px) in poles.enumerated() {
            c.rect(px, poleTop, s, f.shore - poleTop, C(0xEDEDE8))
            c.rect(px, poleTop, 7 * s, 5 * s, C(0xC8202A))
            for r in stride(from: s, to: 5 * s, by: 2 * s) { c.rect(px, poleTop + r, 7 * s, s, C(0xF4F4F0)) }
            c.rect(px, poleTop, 3 * s, 3 * s, C(0x1E2E78))
            if i + 1 < poles.count {
                let next = poles[i + 1], span = next - px
                for k in stride(from: 2 * s, to: span - s, by: 4 * s) {
                    let sag = Int(sin(Double(k) / Double(span) * .pi) * Double(6 * s))
                    let col = [C(0xC8202A), C(0xF4F4F0), C(0x1E3A9A)][(k / (4 * s)) % 3]
                    let y = poleTop + 7 * s + sag
                    c.rect(px + k, y, 3 * s, s, col); c.rect(px + k + s, y + s, s, s, col)
                    c.rect(px + k, y - s, 4 * s, s, C(0x6A6A6A, 0.5))
                }
            }
        }
        // Swimmers' heads in coloured caps and the yellow raft.
        let swimY = f.shore - (f.shore - f.horizon) / 3
        for i in 0..<9 {
            let x = Int(noise(i + 610) * Double(c.w)), y = swimY + Int(noise(i + 620) * 5) * s
            c.rect(x, y, 3 * s, 2 * s, clawdOrange)
            c.rect(x, y - s, 3 * s, s, [C(0xF2F2F2), C(0xE84A6A), C(0xF2D23A)][i % 3])
            c.rect(x - s, y + 2 * s, 5 * s, s, C(0xE4F6FA, 0.6))
        }
        let raftX = c.w * 64 / 100
        c.rect(raftX, swimY - s, 12 * s, 3 * s, C(0xF2C83A)); c.rect(raftX, swimY - s, 12 * s, s, C(0xFFE68A))
        // The sand: wet and dark by the water, the foam line, dry and pale above.
        c.rect(0, f.shore, c.w, g - f.shore, C(0xE8D2A0))
        c.rect(0, f.shore, c.w, 2 * s, C(0xF4FAFA)); c.rect(0, f.shore + 2 * s, c.w, 2 * s, C(0xC8B080))
        // Striped umbrellas and towels.
        for (i, ux) in [c.w * 12 / 100, c.w * 47 / 100, c.w * 82 / 100].enumerated() {
            let top = g - 16 * s
            c.rect(ux, top, s, 16 * s, C(0xE8E8E2))
            for k in 0..<5 {
                let w = (2 + k * 2) * s
                for sx in stride(from: ux - w, to: ux + w + s, by: s) {
                    let stripe = ((sx - ux) / (2 * s) + 20) % 2 == 0
                    let colA = [C(0xE84A3A), C(0x2A7AD8), C(0x2AA86A)][i]
                    c.rect(sx, top + k * s, s, s, stripe ? colA : C(0xF6F2E8))
                }
            }
            c.rect(ux + 3 * s, g - 2 * s, 10 * s, 2 * s, [C(0xF2D23A), C(0xE84A6A), C(0x4AB8E8)][i])
        }
        // The lifeguard's chair, white and tall.
        let lg = c.w * 30 / 100
        c.rect(lg, g - 22 * s, s, 22 * s, C(0xF4F4F0)); c.rect(lg + 8 * s, g - 22 * s, s, 22 * s, C(0xF4F4F0))
        for y in stride(from: g - 18 * s, to: g, by: 5 * s) { c.rect(lg, y, 9 * s, s, C(0xE0E0D8)) }
        c.rect(lg - s, g - 23 * s, 11 * s, 2 * s, C(0xC8202A)); c.rect(lg + s, g - 28 * s, 7 * s, 5 * s, C(0xF4F4F0))
        c.ground(g, C(0xE2C890), edge: C(0xF0DCAA), speck: C(0xC8AE78), seed: 31)
    }

    /// The billboard over the beach: AMITY ISLAND WELCOMES YOU over a swimmer on her float, and painted under her,
    /// big, a grey fin and a mouth full of teeth.
    private static func amityBillboard(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), b = amityFrame(c, g).board
        for px in [b.x + b.w / 5, b.x + b.w * 4 / 5] {
            c.rect(px, b.y + b.h, 3 * s, amityFrame(c, g).horizon - b.y - b.h, C(0x6A5A44))
        }
        c.rect(b.x - 2 * s, b.y - 2 * s, b.w + 4 * s, b.h + 4 * s, C(0xF4F2EA))
        c.rect(b.x, b.y, b.w, b.h, C(0x8AD0EE))
        c.rect(b.x, b.y + b.h * 2 / 3, b.w, b.h / 3, C(0x2A78C0))
        c.rect(b.x, b.y, b.w, 14 * s, C(0xF4F2EA))
        cb3Text(c, "AMITY ISLAND", cx: b.x + b.w / 2, y: b.y + 2 * s, s: s, col: C(0xC8202A))
        cb3Text(c, "WELCOMES YOU", cx: b.x + b.w / 2, y: b.y + 8 * s, s: s, col: C(0x1E3A9A))
        // The swimmer on her float (Clawd in a swimming cap) and the painted shark rising under her.
        let fx = b.x + b.w * 62 / 100, fy = b.y + b.h * 2 / 3
        c.rect(fx - 10 * s, fy - 2 * s, 20 * s, 3 * s, C(0xF2C83A))
        c.rect(fx - 4 * s, fy - 8 * s, 8 * s, 6 * s, clawdOrange); c.rect(fx - 4 * s, fy - 9 * s, 8 * s, 2 * s, C(0xF4F4F4))
        c.rect(fx - 2 * s, fy - 6 * s, s, 2 * s, C(0x16161B)); c.rect(fx + 2 * s, fy - 6 * s, s, 2 * s, C(0x16161B))
        cb3Fin(c, x: b.x + b.w * 28 / 100, y: b.y + 18 * s, h: 24 * s, s: s, col: C(0x5A6670), shade: C(0x3A444C))
        let jx = b.x + b.w * 22 / 100, jy = fy + 2 * s
        c.ellipse(jx + 16 * s, jy + 7 * s, 26 * s, 9 * s, C(0x5A6670))
        c.ellipse(jx + 22 * s, jy + 7 * s, 12 * s, 5 * s, C(0x7A1A22))
        for k in 0..<7 {
            c.rect(jx + 12 * s + k * 3 * s, jy + 2 * s, s, 2 * s, C(0xF4F4F0))
            c.rect(jx + 13 * s + k * 3 * s, jy + 10 * s, s, 2 * s, C(0xF4F4F0))
        }
    }

    /// What moves at Amity: the surf running in along the shore, the swimmers bobbing, the flags lifting in the
    /// breeze, gulls, and every so often a fin cruising along offshore, behind the swimmers.
    static func amityBeachLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = amityFrame(c, g)
        // The surf: two white lines running in and fading on the sand.
        for k in 0..<2 {
            let ph = (t * 0.35 + Double(k) * 0.5).truncatingRemainder(dividingBy: 1)
            let y = f.shore - 6 * s + Int(ph * 7) * s
            let a = 0.75 * (1 - ph)
            for x in stride(from: 0, to: c.w, by: 6 * s) {
                let wob = Int(sin(Double(x) * 0.05 + t) * 1.5) * s
                c.rect(x, y + wob, 5 * s, s, C(0xFFFFFF, a))
            }
        }
        // The swimmers' arms splashing now and then.
        let swimY = f.shore - (f.shore - f.horizon) / 3
        for i in 0..<9 where noise(i * 31 + Int(t * 2)) > 0.7 {
            let x = Int(noise(i + 610) * Double(c.w)), y = swimY + Int(noise(i + 620) * 5) * s
            c.rect(x + 3 * s, y - s, s, s, C(0xFFFFFF, 0.8)); c.rect(x - s, y, s, s, C(0xFFFFFF, 0.6))
        }
        // The fin: every 18 seconds it cruises right to left past the swimmers.
        let run = (t / 18).truncatingRemainder(dividingBy: 1)
        let finX = c.w + 20 * s - Int(run * Double(c.w + 40 * s))
        let finY = swimY - 7 * s
        cb3Fin(c, x: finX, y: finY, h: 7 * s, s: s, col: C(0x4A5660), shade: C(0x2E363E))
        c.rect(finX - 6 * s, finY + 7 * s, 12 * s, s, C(0xFFFFFF, 0.7))
        c.rect(finX + 6 * s, finY + 7 * s, 8 * s, s, C(0xFFFFFF, 0.35))
        // Flags lifting: a red tip flicking off each flag.
        for px in stride(from: c.w * 6 / 100, to: c.w, by: c.w * 22 / 100) {
            let lift = Int(sin(t * 4 + Double(px)) * 1.5)
            c.rect(px + 7 * s, f.horizon - (isTall(c) ? 40 : 30) * s + lift * s, s, 3 * s, C(0xC8202A))
        }
        // Gulls.
        for i in 0..<3 {
            let gx = Int((noise(i + 700) * Double(c.w) + t * (12 + Double(i) * 5)).truncatingRemainder(dividingBy: Double(c.w)))
            let gy = Int(noise(i + 710) * Double(max(1, f.horizon - 50 * s))) + 4 * s
            let up = Int(t * 3 + Double(i)) % 2
            c.rect(gx - 2 * s, gy - up * s, 2 * s, s, C(0xF4F4F0)); c.rect(gx + s, gy - up * s, 2 * s, s, C(0xF4F4F0))
            c.rect(gx, gy, s, s, C(0xC8C8C0))
        }
    }
}

// MARK: - The Orca

extension Scenes {
    /// Where things stand on the Orca: the horizon, the bulwark's top, the wheelhouse's left, right and roof, the
    /// mast, and the cage on the screen saver.
    private static func orcaFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, rail: Int, cabin: (l: Int, r: Int, top: Int),
                                                                  mast: Int, cage: Int) {
        let s = unit(g), tall = isTall(c)
        let horizon = g - (tall ? 70 : 34) * s
        let rail = g - (tall ? 16 : 12) * s
        let cabin = (c.w * 6 / 100, c.w * 6 / 100 + (tall ? 92 : 70) * s, g - (tall ? 54 : 36) * s)
        return (horizon, rail, cabin, cabin.0 + (tall ? 46 : 35) * s, c.w * 70 / 100)
    }

    /// Out at sea on the Orca: a hazy late-afternoon sky, a slate-green sea to the horizon, the white wheelhouse
    /// with its windows on the left and the mast up from its roof, the bulwark with its rail along the deck, yellow
    /// barrels roped by the stern and a coil of line on the planks. On the screen saver the mast climbs with its
    /// crow's nest and rigging, the stern's transom reads ORCA, and the shark cage sits on deck.
    static func orca(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = orcaFrame(c, g)
        c.gradient(0, f.horizon, C(0x6A8698), C(0xF0D6A4), bands: 7)
        c.circle(c.w * 78 / 100, f.horizon - (tall ? 40 : 14) * s, (tall ? 10 : 5) * s, C(0xFFF0C8, 0.85))
        if tall {
            for i in 0..<6 {
                wisp(c, Int(noise(i + 340) * Double(c.w)), Int(noise(i + 350) * Double(f.horizon / 2)) + 20 * s,
                     (50 + Int(noise(i + 360) * 60)) * s, C(0xF6E6C8, 0.5), s: s)
            }
        }
        c.gradient(f.horizon, f.rail, C(0x3E6A74), C(0x1E3E4A), bands: 4)
        c.rect(0, f.horizon, c.w, s, C(0x8AA8A8))
        for i in 0..<(c.w * (f.rail - f.horizon) / 160) {
            let x = Int(noise(i * 3 + 800) * Double(c.w)), y = f.horizon + 2 * s + Int(noise(i * 3 + 801) * Double(max(1, f.rail - f.horizon - 2 * s)))
            c.rect(x, y, (3 + Int(noise(i * 3 + 802) * 6)) * s, s, C(0x6A9AA0, 0.5))
        }
        let sunX = c.w * 78 / 100
        for k in 0..<4 { c.rect(sunX - (6 - k) * s, f.horizon + (2 + k * 3) * s, (12 - 2 * k) * s, s, C(0xFFE8B0, 0.4)) }
        if tall { orcaRigging(c, g) }
        // The mast, up from the wheelhouse roof.
        c.rect(f.mast, 0, 3 * s, f.cabin.top, C(0xB8AE9A)); c.rect(f.mast + 2 * s, 0, s, f.cabin.top, C(0x8A8270))
        // The wheelhouse: white planks, a dark trim, its windows.
        let cw = f.cabin.r - f.cabin.l
        c.rect(f.cabin.l, f.cabin.top, cw, f.rail - f.cabin.top, C(0xEAE6DA))
        for y in stride(from: f.cabin.top + 3 * s, to: f.rail, by: 3 * s) { c.rect(f.cabin.l, y, cw, s, C(0xD4CFC0)) }
        c.rect(f.cabin.l - 2 * s, f.cabin.top - 2 * s, cw + 4 * s, 3 * s, C(0x5A4A3A))
        for wx in stride(from: f.cabin.l + 4 * s, to: f.cabin.r - 9 * s, by: 12 * s) {
            c.rect(wx, f.cabin.top + 5 * s, 9 * s, 7 * s, C(0x3A4A52)); c.rect(wx + s, f.cabin.top + 6 * s, 3 * s, 2 * s, C(0xC8DCE0, 0.6))
        }
        c.rect(f.cabin.r - 12 * s, f.cabin.top + 14 * s, 8 * s, f.rail - f.cabin.top - 14 * s, C(0x6A5A44))
        // The bulwark and its rail, the full width of the deck.
        c.rect(0, f.rail, c.w, g - f.rail, C(0xE4DED0))
        c.rect(0, f.rail, c.w, 2 * s, C(0x6A4E34)); c.rect(0, g - 2 * s, c.w, 2 * s, C(0xB8B0A0))
        for x in stride(from: 4 * s, to: c.w, by: 24 * s) { c.rect(x, f.rail, 2 * s, g - f.rail, C(0xC8C0B0)) }
        // The yellow barrels, roped by the stern, and a coil of line.
        let bx = c.w * 86 / 100
        for k in 0..<3 {
            let x = bx + (k - 1) * 9 * s, y = g - 11 * s
            c.rect(x, y, 8 * s, 11 * s, C(0xF2C230)); c.rect(x, y, 2 * s, 11 * s, C(0xFFE07A))
            c.rect(x + 6 * s, y, 2 * s, 11 * s, C(0xC89A1E))
            c.rect(x, y + 3 * s, 8 * s, s, C(0x8A6A1A)); c.rect(x, y + 8 * s, 8 * s, s, C(0x8A6A1A))
        }
        let coil = c.w * 58 / 100
        c.ellipse(coil, g - 2 * s, 7 * s, 2 * s, C(0xD8C49A)); c.ellipse(coil, g - 2 * s, 4 * s, s, C(0xA89068))
        // The deck: worn planks.
        c.ground(g, C(0x9A7A54), edge: C(0xB89A6A), speck: C(0x7A5E3E), seed: 41)
        for y in stride(from: g + 3, to: c.h, by: 3) { c.rect(0, y, c.w, 1, C(0x7A5E3E, 0.6)) }
        if tall { orcaDeckGear(c, g) }
    }

    /// The screen saver's sky gear on the Orca: rigging from the mast and the crow's nest.
    private static func orcaRigging(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = orcaFrame(c, g)
        let nestY = f.horizon - 120 * s
        for (ax, ay) in [(f.cabin.l, f.cabin.top), (f.cabin.r + 60 * s, f.rail)] {
            let n = max(abs(ax - f.mast), abs(ay - nestY)) / s
            for k in 0...n {
                let x = f.mast + s + (ax - f.mast) * k / n, y = nestY + 4 * s + (ay - nestY) * k / n
                c.rect(x, y, s, s, C(0x3A3A36, 0.8))
            }
        }
        c.rect(f.mast - 8 * s, nestY, 19 * s, 10 * s, C(0xEAE6DA)); c.rect(f.mast - 8 * s, nestY, 19 * s, 2 * s, C(0x6A4E34))
        c.rect(f.mast - 9 * s, nestY + 9 * s, 21 * s, 2 * s, C(0x5A4A3A))
        c.rect(f.mast - 2 * s, nestY - 20 * s, s, 20 * s, C(0x8A8270)); c.rect(f.mast - 12 * s, nestY - 18 * s, 23 * s, s, C(0x8A8270))
    }

    /// The screen saver's deck gear, in front of the bulwark: the shark cage and the stern's name board.
    private static func orcaDeckGear(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = orcaFrame(c, g)
        // The cage: galvanised bars, a lid, standing on deck in front of the rail.
        let cx = f.cage, top = g - 40 * s, w = 34 * s
        c.rect(cx, top, w, g - top, C(0x1E3E4A, 0.25))
        for x in stride(from: cx, through: cx + w, by: 4 * s) { c.rect(x, top, s, g - top, C(0xAEB6B8)) }
        for y in [top, top + 13 * s, top + 26 * s, g - 2 * s] { c.rect(cx - s, y, w + 3 * s, 2 * s, C(0xC8D0D2)) }
        c.rect(cx + 8 * s, top - 3 * s, 18 * s, 3 * s, C(0x8A9496))
        // The stern's name board on the bulwark.
        let tx = c.w * 40 / 100
        c.rect(tx, f.rail + 4 * s, 30 * s, 9 * s, C(0x1E2A3A)); c.rect(tx + s, f.rail + 5 * s, 28 * s, 7 * s, C(0xF4F2EA))
        cb3Text(c, "ORCA", cx: tx + 15 * s, y: f.rail + 6 * s, s: s, col: C(0x1E2A3A))
    }

    /// What moves out on the Orca: the sea rising and falling against the rail as the boat rolls, a yellow barrel
    /// riding the swell (and now and then yanked under and away), and gulls wheeling over.
    static func orcaLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = orcaFrame(c, g)
        // The roll: the horizon creeps up and down behind the wheelhouse and mast.
        let bob = Int((sin(t * 1.1) * 2.4).rounded()) * s
        func band(_ y: Int, _ h: Int, _ col: Px) {
            c.rect(0, y, f.cabin.l, h, col)
            c.rect(f.cabin.r, y, c.w - f.cabin.r, h, col)
        }
        if bob > 0 {
            band(f.horizon - bob, bob, C(0x3E6A74)); band(f.horizon - bob, s, C(0x8AA8A8))
        } else if bob < 0 {
            band(f.horizon, -bob, C(0xF0D6A4)); band(f.horizon - bob, s, C(0x8AA8A8))
        }
        // The barrel on the swell: drifts along, then every 16 seconds it's dragged off fast and goes under.
        let cyc = t.truncatingRemainder(dividingBy: 16)
        let span = Double(c.w - f.cabin.r)
        var bx = f.cabin.r + Int((cyc / 16) * span * 0.6)
        var sink = 0
        if cyc > 12 {
            let k = (cyc - 12) / 4
            bx += Int(k * k * span * 0.8)
            sink = Int(k * 6) * s
        }
        let by = f.horizon + (f.rail - f.horizon) / 2 + Int(sin(t * 1.6) * 2) * s - bob + sink
        let behindCage = isTall(c) && bx > f.cage - 8 * s && bx < f.cage + 36 * s
        if bx < c.w && sink < 5 * s && !behindCage {
            c.rect(bx, by - 4 * s + sink, 6 * s, 4 * s - min(sink, 3 * s), C(0xF2C230))
            c.rect(bx, by - 4 * s + sink, 2 * s, max(s, 4 * s - min(sink, 3 * s)), C(0xFFE07A))
            c.rect(bx - 2 * s, by, 10 * s, s, C(0xE8F2F2, 0.7))
        }
        if cyc > 12 && !behindCage { c.rect(bx - 12 * s, by, 12 * s, s, C(0xFFFFFF, 0.6)) }
        // Gulls.
        for i in 0..<3 {
            let r = Double((30 + i * 18) * s)
            let gx = c.w / 2 + Int(cos(t * 0.5 + Double(i) * 2) * r * 2), gy = f.horizon / 2 + Int(sin(t * 0.5 + Double(i) * 2) * r * 0.4)
            let up = Int(t * 3 + Double(i)) % 2
            c.rect(gx - 2 * s, gy - up * s, 2 * s, s, C(0xF4F4F0)); c.rect(gx + s, gy - up * s, 2 * s, s, C(0xF4F4F0))
            c.rect(gx, gy, s, s, C(0xB8B8B0))
        }
    }
}
