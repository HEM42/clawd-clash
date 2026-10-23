import Foundation

// Places: the Palace Arcade, Castle Byers, Eddie's trailer and Kamchatka. The arcade is a dark room lit by its own
// screens and neon; Castle Byers is Will's fort of boards and blankets in the autumn woods; Eddie's trailer stands in
// Forest Hills on a spring night under a string of lights; Kamchatka is a Soviet prison yard in the snow, guard towers
// over it and the pit in the middle. The floor and the band above it stay plain and mid-dark so the crew's outlines and
// names read.

let hawkinsScenes5: [Location: Place] = [
    .hawkinsArcade: Place(name: "The Palace Arcade", panel: 0x140F1E, still: Scenes.hawkinsArcade,
                          moving: Scenes.hawkinsArcadeLife),
    .hawkinsCastleByers: Place(name: "Castle Byers", panel: 0x1A140C, still: Scenes.hawkinsCastleByers,
                               moving: Scenes.hawkinsCastleByersLife),
    .hawkinsTrailer: Place(name: "Eddie's Trailer", panel: 0x0E1220, still: Scenes.hawkinsTrailer,
                           moving: Scenes.hawkinsTrailerLife),
    .hawkinsKamchatka: Place(name: "Kamchatka", panel: 0x141A22, still: Scenes.hawkinsKamchatka,
                             moving: Scenes.hawkinsKamchatkaLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 5-row alphabet with the digits: three dots wide, but M, N and W wider so their diagonals read, the
/// apostrophe one dot, and the Cyrillic letters for ОПАСНО ("danger") on the warning sign at Kamchatka: О, А, С and Н
/// drawn as their Latin twins, and П five dots wide, a flat bar over two legs, so it can't be taken for a Latin n.
private let hawkinsP5Glyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011", "D": "110101101101110",
    "E": "111100110100111", "F": "111100110100100", "G": "011100101101011", "H": "101101111101101",
    "I": "111010010010111", "K": "101101110101101", "L": "100100100100111", "M": "1000111011101011000110001",
    "N": "10011101101110011001", "O": "010101101101010", "P": "110101110100100", "R": "110101110101101",
    "S": "011100010001110", "T": "111010010010010", "U": "101101101101111", "W": "1000110001101011101110001",
    "X": "101101010101101", "Y": "101101010010010", "Z": "111001010100111", "'": "11000",
    "0": "111101101101111", "1": "010110010010111", "2": "111001111100111", "3": "111001011001111",
    "4": "101101111001001", "5": "111100111001111", "6": "111100111101111", "7": "111001010010010",
    "8": "111101111101111", "9": "111101111001111",
    "О": "010101101101010", "П": "1111110001100011000110001", "А": "010101111101101", "С": "011100100100011",
    "Н": "101101111101101",
]

/// Lettering, `p` pixels a dot, from its top-left corner, its steps eased (`hawkinsSoftText`).
private func hawkinsP5Sign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    hawkinsSoftText(c, x, y, text, hawkinsP5Glyphs, col, p)
}

/// How wide `text` comes out at `p` pixels a dot (a space is three dots).
private func hawkinsP5Width(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + (hawkinsP5Glyphs[$1].map { $0.count / 5 + 1 } ?? 3) } * p - p
}

/// Lettering centred on `x`.
private func hawkinsP5Centred(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    hawkinsP5Sign(c, x - hawkinsP5Width(text, p) / 2, y, text, col, p)
}

/// A tree trunk from the top of the canvas (or `top`) down to `base`, `w` wide: bark in two tones, lit on the left,
/// a few knots and furrows; `seed` makes each one its own.
private func hawkinsP5Trunk(_ c: PixelCanvas, _ x: Int, _ base: Int, _ w: Int, _ s: Int, top: Int = 0, bark: Px, barkD: Px,
                            barkL: Px, seed: Int) {
    c.rect(x - w / 2, top, w, base - top, bark)
    c.rect(x - w / 2, top, max(s, w / 5), base - top, barkL); c.rect(x + w / 2 - max(s, w / 4), top, max(s, w / 4), base - top, barkD)
    for k in 0..<((base - top) / (7 * s) + 1) {
        let fy = top + k * 7 * s + Int(noise(seed * 31 + k) * Double(5 * s)), fx = x - w / 4 + Int(noise(seed * 31 + k + 9) * Double(w / 2))
        c.rect(fx, fy, s, (3 + k % 3) * s, barkD)
    }
    // The roots spreading at its foot.
    c.rect(x - w / 2 - 2 * s, base - 2 * s, w + 4 * s, 2 * s, bark); c.rect(x - w / 2 - 3 * s, base - s, w + 6 * s, s, barkD)
}

// MARK: - The Palace Arcade

extension Scenes {
    /// Where things stand in the arcade: the doors, the change machine, the cabinets' middles, the cocktail table
    /// under the high-score screen, the screen itself, and the ARCADE neon.
    static func hawkinsArcadeFrame(_ c: PixelCanvas, _ g: Int)
        -> (door: Int, change: Int, cabinets: [Int], table: Int, board: (x: Int, y: Int, w: Int, h: Int), neon: (x: Int, y: Int)) {
        let s = unit(g), mid = c.w * 58 / 100, bw = 66 * s
        // The cabinets stand shoulder to shoulder, 24 units apart, on either side of the middle.
        var cabs: [Int] = []
        var x = mid - bw / 2 - 14 * s
        while x > c.w * 19 / 100 { cabs.append(x); x -= 24 * s }
        x = mid + bw / 2 + 14 * s
        while x < c.w - 12 * s { cabs.append(x); x += 24 * s }
        let by = isTall(c) ? g - 76 * s : max(3 * s, g - 64 * s)
        return (c.w * 5 / 100, c.w * 14 / 100, cabs.sorted(), mid, (x: mid - bw / 2, y: by, w: bw, h: 30 * s),
                (x: c.w * 90 / 100, y: isTall(c) ? g - 150 * s : 3 * s))
    }

    /// A cabinet's screen: where the moving layer draws its game.
    static func hawkinsArcadeScreen(_ x: Int, _ g: Int, _ s: Int) -> (x: Int, y: Int, w: Int, h: Int) {
        (x - 7 * s, g - 37 * s, 14 * s, 11 * s)
    }

    /// The Palace Arcade, autumn 1984: a dark room, its walls near black with a band of pink, orange and teal stripes
    /// running along them, and the cabinets shoulder to shoulder, each with its lit marquee, its screen, its control
    /// panel with a stick and buttons and its coin door glowing orange. In the middle a sit-down cocktail table with two
    /// stools, and over it on the wall the big high-score screen, MADMAX at the top. Glass doors onto the night on the
    /// left, the change machine beside them. A dark carpet with faint confetti. On the screen saver the wall goes up
    /// to a ceiling of black tiles and spotlights, the PALACE ARCADE sign in pink and teal neon with a crown, a
    /// lightning bolt and a ringed planet in neon round it, and posters for made-up games.
    static func hawkinsArcade(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsArcadeFrame(c, g), tall = isTall(c)
        // The wall: near black, faint vertical panels, the band of stripes.
        c.rect(0, 0, c.w, g, C(0x15111E))
        for x in stride(from: 0, to: c.w, by: 32 * s) { c.rect(x, 0, s, g, C(0x1C1728)) }
        let band = g - 50 * s
        for (k, col) in [C(0xD84A8A), C(0xE88A3A), C(0x3AB8B0)].enumerated() { c.rect(0, band + k * 2 * s, c.w, s, col.alpha(0.75)) }
        c.rect(0, g - 6 * s, c.w, 6 * s, C(0x100C18))

        if tall {
            // The ceiling: black tiles in a grid, a track of spotlights pointing down, their pools of light faint.
            c.rect(0, 0, c.w, 14 * s, C(0x0C0A12))
            for x in stride(from: 0, to: c.w, by: 20 * s) { c.rect(x, 0, s, 14 * s, C(0x1A1624)) }
            c.rect(0, 7 * s, c.w, s, C(0x1A1624)); c.rect(0, 14 * s, c.w, s, C(0x2A2438))
            c.rect(0, 16 * s, c.w, 2 * s, C(0x2E2A36))
            for k in 0..<(c.w / (60 * s) + 1) {
                let lx = k * 60 * s + 30 * s
                c.rect(lx - s, 18 * s, 2 * s, 3 * s, C(0x4A4652)); c.rect(lx - 3 * s, 21 * s, 6 * s, 4 * s, C(0x2A2830)); c.rect(lx - 2 * s, 25 * s, 4 * s, s, C(0xE8E0C8))
                for d in 0..<8 { c.rect(lx - (3 + d) * s, (26 + d * 4) * s, (6 + 2 * d) * s, 4 * s, C(0xE8E0C8, 0.025)) }
            }
            // The PALACE ARCADE sign: a crown over the words, the words on a dark backing, all in neon tube.
            let sx = c.w / 2, sy = f.neon.y - 6 * s
            let w = hawkinsP5Width("PALACE", 4 * s)
            c.rect(sx - w / 2 - 10 * s, sy - 4 * s, w + 20 * s, 48 * s, C(0x0E0A14)); c.rect(sx - w / 2 - 10 * s, sy - 4 * s, w + 20 * s, s, C(0x2A2438))
            hawkinsP5Centred(c, sx, sy, "PALACE", C(0x8A3A6A), 4 * s)
            hawkinsP5Centred(c, sx, sy + 26 * s, "ARCADE", C(0x2A7A78), 2 * s)
            // The crown, the bolt and the planet in dim tube (lit by the moving layer).
            hawkinsArcadeNeonShapes(c, g, lit: false)
            // Posters for made-up games: a rocket, a dragon's eye, a racing stripe, each under a title band.
            for (k, px) in [c.w * 10 / 100, c.w * 26 / 100, c.w * 76 / 100].enumerated() {
                let py = band - 40 * s
                c.rect(px - 11 * s, py, 22 * s, 30 * s, [C(0x1A2A5A), C(0x3A0E14), C(0x14141A)][k])
                c.rect(px - 11 * s, py, 22 * s, 5 * s, [C(0xF0D040), C(0xE84A2A), C(0x3AB8F0)][k]); c.rect(px - 9 * s, py + 2 * s, 18 * s, s, C(0x15111E))
                switch k {
                case 0: c.rect(px - s, py + 9 * s, 3 * s, 12 * s, C(0xE8E8F0)); c.rect(px - 3 * s, py + 19 * s, 7 * s, 3 * s, C(0xD84A4A)); c.rect(px, py + 22 * s, s, 4 * s, C(0xF0A030))
                    for k2 in 0..<6 { c.px(px - 8 * s + Int(noise(k2 + 30) * Double(16 * s)), py + 8 * s + Int(noise(k2 + 40) * Double(18 * s)), C(0xFFFFFF)) }
                case 1: c.ellipse(px, py + 17 * s, 8 * s, 5 * s, C(0xF0C030)); c.ellipse(px, py + 17 * s, 2 * s, 5 * s, C(0x1A0A0A))
                default: for d in 0..<5 { c.rect(px - 9 * s + d * 4 * s, py + 22 * s - d * 3 * s, 4 * s, 2 * s, C(0xF04A9A)) }
                    c.rect(px - 9 * s, py + 25 * s, 18 * s, s, C(0x3AB8F0))
                }
                c.rect(px - 11 * s, py, s, 30 * s, C(0x2A2438))
            }
        }

        // The doors: glass in a steel frame onto the dark street, a lit lamp post out there, the push bars.
        let dx = f.door, dh = 36 * s
        c.rect(dx - 13 * s, g - dh - 2 * s, 26 * s, dh + 2 * s, C(0x4A4A56))
        for (k, gx) in [dx - 11 * s, dx + s].enumerated() {
            c.rect(gx, g - dh, 10 * s, dh - 2 * s, C(0x101A2E)); c.rect(gx, g - dh, 10 * s, 10 * s, C(0x0C1424))
            c.rect(gx + (k == 0 ? 6 : 2) * s, g - dh + 8 * s, s, 6 * s, C(0x9AB0C8, 0.35))
            c.rect(gx, g - 18 * s, 10 * s, 2 * s, C(0x8A8A96))
        }
        c.rect(dx - 5 * s, g - dh + 4 * s, s, 18 * s, C(0x3A3A44)); c.circle(dx - 4 * s, g - dh + 4 * s, 2 * s, C(0xF0D890, 0.8))
        c.rect(dx - 13 * s, g - 2 * s, 26 * s, 2 * s, C(0x3A3A44))
        // The change machine: a grey box with its slot and its tray.
        let cm = f.change
        c.rect(cm - 7 * s, g - 30 * s, 14 * s, 30 * s, C(0x6A6E7A)); c.rect(cm - 7 * s, g - 30 * s, 14 * s, s, C(0x9A9EAA))
        c.rect(cm + 6 * s, g - 30 * s, s, 30 * s, C(0x4A4E5A))
        c.rect(cm - 5 * s, g - 27 * s, 10 * s, 5 * s, C(0x1A1A22)); c.rect(cm - 4 * s, g - 26 * s, 8 * s, 3 * s, C(0x3AB86A, 0.6))
        c.rect(cm - 3 * s, g - 19 * s, 6 * s, s, C(0x1A1A22)); c.rect(cm - 4 * s, g - 12 * s, 8 * s, 4 * s, C(0x3A3E48)); c.rect(cm - 3 * s, g - 11 * s, 6 * s, 2 * s, C(0x1A1A22))

        // The cabinets.
        let bodies = [C(0x1E1E2A), C(0x2A1A1E), C(0x1A2228), C(0x241A2A)]
        let sides = [C(0xD84A4A), C(0x3A8AE0), C(0xF0C040), C(0x4AC07A), C(0xC85AD8), C(0xF08A3A)]
        for (k, x) in f.cabinets.enumerated() {
            let body = bodies[k % 4], side = sides[(k * 5 + 1) % 6], top = g - 46 * s
            c.rect(x - 10 * s, top, 20 * s, 46 * s, body)
            c.rect(x - 10 * s, top, 2 * s, 46 * s, side); c.rect(x + 8 * s, top, 2 * s, 46 * s, side.alpha(0.6))
            // The marquee, lit, with a stripe of the game's colours for its name.
            c.rect(x - 9 * s, top + s, 18 * s, 6 * s, C(0xF0E8D8)); c.rect(x - 7 * s, top + 3 * s, 14 * s, 2 * s, side)
            c.rect(x - 9 * s, top + 7 * s, 18 * s, s, C(0x0C0A10))
            // The bezel and the screen (the moving layer runs the game on it).
            let sc = hawkinsArcadeScreen(x, g, s)
            c.rect(sc.x - s, sc.y - s, sc.w + 2 * s, sc.h + 2 * s, C(0x0A0A0E)); c.rect(sc.x, sc.y, sc.w, sc.h, C(0x101418))
            // The control panel jutting out: a stick and two buttons.
            c.rect(x - 10 * s, g - 25 * s, 20 * s, 4 * s, side.alpha(0.85)); c.rect(x - 10 * s, g - 25 * s, 20 * s, s, C(0xFFFFFF, 0.35))
            c.rect(x - 5 * s, g - 28 * s, s, 3 * s, C(0x1A1A1A)); c.circle(x - 5 * s, g - 28 * s, s, C(0xD82A2A))
            c.rect(x + 2 * s, g - 24 * s, 2 * s, s, C(0xF0F0F0)); c.rect(x + 5 * s, g - 24 * s, 2 * s, s, C(0xF0F0F0))
            // The coin door: a steel plate with the two coin slots side by side, lit orange, and a vent under it.
            c.rect(x - 6 * s, g - 17 * s, 12 * s, 10 * s, C(0x3A3A44)); c.rect(x - 6 * s, g - 17 * s, 12 * s, s, C(0x5A5A66))
            for cx in [x - 4 * s, x + s] {
                c.rect(cx, g - 15 * s, 3 * s, 4 * s, C(0x8A8A96)); c.rect(cx + s, g - 15 * s, s, 3 * s, C(0xF08A2A))
            }
            for y in stride(from: g - 9 * s, to: g - 3 * s, by: 2 * s) { c.rect(x - 7 * s, y, 14 * s, s, C(0x0C0A10)) }
            c.rect(x - 10 * s, g - 3 * s, 20 * s, 3 * s, C(0x0C0A10))
        }

        // The high-score screen on the wall: a big monitor in a black case on a bracket, HIGH SCORE in teal, MADMAX
        // in yellow at the top of the table, her score under it, and two names under that.
        let b = f.board
        c.rect(b.x + b.w / 2 - 2 * s, b.y + b.h + 2 * s, 4 * s, 4 * s, C(0x3A3A44))
        c.rect(b.x - 3 * s, b.y - 3 * s, b.w + 6 * s, b.h + 6 * s, C(0x2A2830)); c.rect(b.x - 3 * s, b.y - 3 * s, b.w + 6 * s, s, C(0x4A4652))
        c.rect(b.x - s, b.y - s, b.w + 2 * s, b.h + 2 * s, C(0x0A0A0E)); c.rect(b.x, b.y, b.w, b.h, C(0x06080C))
        hawkinsP5Centred(c, b.x + b.w / 2, b.y + 2 * s, "HIGH SCORE", C(0x3AE0D0), s)
        hawkinsP5Sign(c, b.x + 4 * s, b.y + 9 * s, "1", C(0xF0F0F0), 2 * s)
        hawkinsP5Sign(c, b.x + 12 * s, b.y + 9 * s, "MADMAX", C(0xF8D838), 2 * s)
        hawkinsP5Sign(c, b.x + 12 * s, b.y + 20 * s, "751300", C(0xF0F0F0), s)
        hawkinsP5Sign(c, b.x + 40 * s, b.y + 20 * s, "2 DUS", C(0x9AA0B0), s)

        // The cocktail table under it: a low box with a screen set in its glass top, a stool either side.
        let tx = f.table
        c.rect(tx - 13 * s, g - 17 * s, 26 * s, 3 * s, C(0x3A3A48)); c.rect(tx - 13 * s, g - 17 * s, 26 * s, s, C(0x6A6A7A))
        c.rect(tx - 9 * s, g - 16 * s, 18 * s, s, C(0x1A3A5A))
        c.rect(tx - 10 * s, g - 14 * s, 20 * s, 14 * s, C(0x2A1A3A)); c.rect(tx - 10 * s, g - 14 * s, 20 * s, s, C(0x4A3A5A))
        c.rect(tx - 6 * s, g - 10 * s, 12 * s, 6 * s, C(0x1E1430)); c.rect(tx - 4 * s, g - 8 * s, 8 * s, 2 * s, C(0xF0C040, 0.6))
        for sx in [tx - 22 * s, tx + 22 * s] {
            c.rect(sx - 4 * s, g - 11 * s, 8 * s, 3 * s, C(0xC82A4A)); c.rect(sx - 4 * s, g - 11 * s, 8 * s, s, C(0xE85A7A))
            c.rect(sx - s, g - 8 * s, 2 * s, 8 * s, C(0x8A8A96)); c.rect(sx - 3 * s, g - s, 6 * s, s, C(0x6A6A76))
        }

        // The ARCADE neon in the strip, dim tube (the moving layer lights it).
        if !tall { hawkinsArcadeNeonShapes(c, g, lit: false) }

        // The carpet: dark, with faint confetti in it.
        c.ground(g, C(0x1C1828), edge: C(0x2E2840), speck: C(0x241E34), seed: 91)
        for k in 0..<(c.w * (c.h - g) / (40 * s * s)) {
            c.rect(Int(noise(k * 3 + 700) * Double(c.w)), g + 2 * s + Int(noise(k * 3 + 701) * Double(max(1, c.h - g - 3 * s))), s, s,
                   [C(0x8A3A6A), C(0x2A6A7A), C(0x8A6A2A)][k % 3].alpha(0.5))
        }
    }

    /// The neon shapes: in the strip the ARCADE sign at the top right with its bolt; on the screen saver the crown
    /// over PALACE, a lightning bolt either side and a ringed planet. Dim when unlit; the moving layer draws them lit.
    static func hawkinsArcadeNeonShapes(_ c: PixelCanvas, _ g: Int, lit: Bool) {
        let s = unit(g), f = hawkinsArcadeFrame(c, g)
        let pink = lit ? C(0xFF8AC8) : C(0x6A2A4E), teal = lit ? C(0x8AFFF0) : C(0x22605E), gold = lit ? C(0xFFE07A) : C(0x6A5A2A)
        func bolt(_ x: Int, _ y: Int, _ col: Px) {
            for k in 0..<6 { c.rect(x + (5 - k) * s, y + k * s, 2 * s, s, col) }
            c.rect(x, y + 6 * s, 6 * s, s, col)
            for k in 0..<6 { c.rect(x + (5 - k) * s, y + (7 + k) * s, 2 * s, s, col) }
        }
        if isTall(c) {
            let sx = c.w / 2, sy = f.neon.y - 6 * s, w = hawkinsP5Width("PALACE", 4 * s)
            if lit {
                c.rect(sx - w / 2 - 4 * s, sy - 2 * s, w + 8 * s, 24 * s, C(0xFF6AB0, 0.08))
                hawkinsP5Centred(c, sx, sy, "PALACE", C(0xFF9ACC), 4 * s)
                hawkinsP5Centred(c, sx, sy + 26 * s, "ARCADE", C(0x8AFFF0), 2 * s)
            }
            // The crown: a band with three points, a dot on each.
            let cy = sy - 18 * s
            c.rect(sx - 12 * s, cy + 10 * s, 24 * s, s, gold)
            for (k, px) in [sx - 12 * s, sx, sx + 11 * s].enumerated() {
                let h = k == 1 ? 10 : 7
                for d in 0..<h { c.rect(px + (k == 0 ? d * s / 2 : k == 2 ? -d * s / 2 : 0), cy + (10 - d) * s, s, s, gold) }
                c.rect(px - s, cy + (9 - h) * s, 2 * s, 2 * s, pink)
            }
            bolt(sx - w / 2 - 26 * s, sy + 4 * s, teal); bolt(sx + w / 2 + 18 * s, sy + 4 * s, teal)
            // A star high on the left, its five points in tube.
            let stx = c.w * 16 / 100, sty = sy + 8 * s
            for k in 0..<10 {
                let a0 = Double(k) * .pi / 5 - .pi / 2, a1 = Double(k + 1) * .pi / 5 - .pi / 2
                let r0 = Double(k % 2 == 0 ? 12 : 5) * Double(s), r1 = Double(k % 2 == 0 ? 5 : 12) * Double(s)
                hawkinsLine(c, Double(stx) + cos(a0) * r0, Double(sty) + sin(a0) * r0, Double(stx) + cos(a1) * r1, Double(sty) + sin(a1) * r1, gold, 0.5 * Double(s))
            }
            // The ringed planet, off to the right.
            let px = c.w * 86 / 100, py = sy + 10 * s
            for a in 0..<40 { let r = Double(a) * .pi / 20; c.rect(px + Int(cos(r) * Double(7 * s)), py + Int(sin(r) * Double(7 * s)), s, s, pink) }
            for x in stride(from: -14 * s, through: 14 * s, by: s) where abs(x) > 6 * s { c.rect(px + x, py + x / 5, s, s, teal) }
        } else {
            // ARCADE at the top right, with a bolt beside it.
            let x = f.neon.x, y = f.neon.y + 2 * s, w = hawkinsP5Width("ARCADE", 2 * s)
            if lit { c.rect(x - w / 2 - 3 * s, y - 2 * s, w + 6 * s, 14 * s, C(0xFF6AB0, 0.08)) }
            hawkinsP5Centred(c, x, y, "ARCADE", pink, 2 * s)
            bolt(x - w / 2 - 12 * s, y - 2 * s, teal)
        }
    }

    /// The arcade's life: every screen running its own game in blocky colours, the attract mode flashing now and then,
    /// MADMAX blinking between yellow and white on the high-score screen, and the neon lit, stuttering now and again.
    static func hawkinsArcadeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsArcadeFrame(c, g)
        let frame = Int(t * 6)
        for (k, x) in f.cabinets.enumerated() {
            let sc = hawkinsArcadeScreen(x, g, s)
            let flash = noise(k * 17 + frame / 4) < 0.08
            c.rect(sc.x, sc.y, sc.w, sc.h, flash ? C(0xE8E8F0) : C(0x0A0E18))
            if flash { continue }
            switch k % 4 {
            case 0:   // a maze: dots in rows, a yellow chomper going round, a ghost after it
                for y in stride(from: sc.y + s, to: sc.y + sc.h, by: 3 * s) { for xx in stride(from: sc.x + s, to: sc.x + sc.w, by: 2 * s) { c.rect(xx, y, s, s, C(0xF0D0A0, 0.7)) } }
                let p = (frame + k) % (sc.w / s)
                c.rect(sc.x + p * s, sc.y + 3 * s, 2 * s, 2 * s, C(0xF8E030))
                c.rect(sc.x + ((p + 8) % (sc.w / s)) * s, sc.y + 3 * s, 2 * s, 2 * s, C(0xF04A6A))
            case 1:   // invaders marching over the guns
                let off = (frame % 4) * s
                for r in 0..<2 { for i in 0..<3 { c.rect(sc.x + s + off + i * 4 * s, sc.y + s + r * 3 * s, 2 * s, 2 * s, r == 0 ? C(0x7AF07A) : C(0xF07AF0)) } }
                c.rect(sc.x + 5 * s, sc.y + sc.h - 2 * s, 3 * s, s, C(0x3AE0F0))
                if frame % 3 == 0 { c.rect(sc.x + 6 * s, sc.y + 5 * s, s, 3 * s, C(0xFFFFFF)) }
            case 2:   // a racing game: the road rushing at you
                c.rect(sc.x, sc.y, sc.w, 4 * s, C(0x3A7AE0))
                c.rect(sc.x, sc.y + 4 * s, sc.w, sc.h - 4 * s, C(0x3A9A3A))
                for r in 0..<(sc.h / s - 4) { let half = (r + 1) * s / 2 + s; c.rect(sc.x + sc.w / 2 - half, sc.y + (4 + r) * s, half * 2, s, C(0x5A5A62)) }
                if (frame + 1) % 2 == 0 { c.rect(sc.x + sc.w / 2, sc.y + 6 * s, s, 2 * s, C(0xF0F0F0)) }
                c.rect(sc.x + sc.w / 2 - 2 * s, sc.y + sc.h - 2 * s, 4 * s, 2 * s, C(0xE84A3A))
            default:  // a digger's tunnels in the dirt
                for r in 0..<3 { c.rect(sc.x, sc.y + (2 + r * 3) * s, sc.w, 3 * s, [C(0xC88A3A), C(0xA86A2A), C(0x8A4A1A)][r]) }
                c.rect(sc.x, sc.y, sc.w, 2 * s, C(0x1A2A5A))
                let p = (frame * 2 + k) % (sc.w / s)
                c.rect(sc.x, sc.y + 5 * s, p * s, s, C(0x0A0A0A)); c.rect(sc.x + p * s, sc.y + 4 * s, 2 * s, 2 * s, C(0xF0F0F0))
            }
            c.rect(sc.x, sc.y, sc.w, s, C(0xFFFFFF, 0.08))
        }
        // MADMAX blinking on the high-score screen.
        let b = f.board
        if Int(t * 2.4) % 2 == 0 { hawkinsP5Sign(c, b.x + 12 * s, b.y + 9 * s, "MADMAX", C(0xFFFFFF), 2 * s) }
        // The cocktail table's screen.
        c.rect(f.table - 4 * s + (frame % 3) * 2 * s, g - 8 * s, 2 * s, 2 * s, C(0x8AF0F0))
        // The neon, lit, unless it's stuttering.
        if noise(Int(t * 7) + 160) > 0.06 { hawkinsArcadeNeonShapes(c, g, lit: true) }
    }
}

// MARK: - Castle Byers

extension Scenes {
    /// Where things stand at Castle Byers: the fort's middle and its doorway, the trunks of the near trees, the creek.
    static func hawkinsCastleByersFrame(_ c: PixelCanvas, _ g: Int) -> (fort: Int, trunks: [Int], creek: Int) {
        (c.w * 60 / 100, [c.w * 9 / 100, c.w * 29 / 100, c.w * 85 / 100, c.w * 97 / 100], c.w * 18 / 100)
    }

    /// Castle Byers in the woods behind the Byers' house, November 1983: Will's fort, walls of odd planks and boards
    /// nailed upright with their tops ragged, branches leaning in against it, a sheet of rusty tin for a roof with a
    /// green tarp and two blankets thrown over it (a red plaid, a faded blue), stones holding it down, a pennant on a
    /// stick at the top, a sheet hung for its door, CASTLE BYERS painted over the doorway and a board nailed beside it,
    /// FRIENDS ONLY. Round it the forest in autumn: tree after tree going back into the haze, their leaves gone rust
    /// and gold, a grey sky through the gaps, dark trunks near; a creek, a fallen log, ferns, a rusted bucket and a
    /// lantern by the door. Brown earth along the front with a few leaves on it. On the screen saver the trunks go up
    /// into the canopy, branches reaching out with clumps of leaves on them.
    static func hawkinsCastleByers(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsCastleByersFrame(c, g), tall = isTall(c)
        // The sky through the trees: overcast, pale grey-blue, warmer low down.
        c.gradient(0, g, C(0x9AA4B0), C(0xC8BCA4), bands: 6)
        // The far woods: tree after tree in the haze, thin pale trunks, each with crowns of leaves up it gone rust and
        // gold, faded by the distance; then a nearer row, richer and darker, lower down. The sky shows between them.
        let woods = g - 20 * s
        func crown(_ x: Int, _ y: Int, _ r: Int, _ seed: Int, _ cols: [Px], shade: Px?) {
            for j in 0..<9 {
                let a = Double(j) * 0.7 + noise(seed * 13 + j) * 2, d = Double(r) * (0.2 + noise(seed * 13 + j + 5) * 0.6)
                let bx = x + Int(cos(a) * d * 1.3), by = y + Int(sin(a) * d * 0.8), br = r * (40 + Int(noise(seed * 13 + j + 9) * 30)) / 100
                if let shade { c.ellipse(bx, by + s, br, br * 2 / 3, shade) }
                c.ellipse(bx, by, br, br * 2 / 3, cols[(seed + j) % cols.count])
            }
        }
        for k in 0..<(c.w / (11 * s) + 2) {
            let tx = k * 11 * s + Int(noise(k + 110) * Double(6 * s))
            c.rect(tx, 0, k % 3 == 0 ? 2 * s : s, woods, C(0x8E867A))
            for (j, y) in stride(from: woods - 10 * s - Int(noise(k + 115) * Double(30 * s)), to: -10 * s, by: -34 * s).enumerated()
                where noise(k * 9 + j + 117) < 0.7 {
                let jy = y + Int((noise(k * 9 + j + 119) - 0.5) * Double(16 * s))
                crown(tx, jy, (8 + Int(noise(k * 5 + j + 118) * 7)) * s, k * 7 + j, [C(0xB8A48A), C(0xAE967A), C(0xC0AE94)], shade: nil)
            }
        }
        for k in 0..<(c.w / (26 * s) + 2) {
            let tx = k * 26 * s + Int(noise(k + 130) * Double(12 * s))
            c.rect(tx, 0, 2 * s, woods, C(0x6E6050))
            for (j, y) in stride(from: woods - 18 * s - Int(noise(k + 135) * Double(30 * s)), to: -10 * s, by: -50 * s).enumerated()
                where noise(k * 9 + j + 137) < 0.75 {
                let jy = y + Int((noise(k * 9 + j + 139) - 0.5) * Double(20 * s))
                crown(tx, jy, (11 + Int(noise(k * 5 + j + 138) * 7)) * s, k * 11 + j + 400, [C(0xB8742E), C(0xA85E2A), C(0xC8963A)], shade: C(0x7A4A2A))
            }
        }
        // The undergrowth at the back: low bushes gone brown, the slope of the ground.
        c.rect(0, g - 18 * s, c.w, 18 * s, C(0x6A5440))
        for k in 0..<(c.w / (5 * s) + 1) { c.ellipse(k * 5 * s, g - 18 * s, 4 * s, 3 * s, k % 2 == 0 ? C(0x7A5A3A) : C(0x6A4E34)) }
        if tall {
            // The canopy overhead: big masses of leaves in rust and gold, darker underneath, the sky in the gaps.
            for k in 0..<(c.w / (14 * s) + 2) {
                for r in 0..<2 {
                    let x = k * 14 * s + Int(noise(k * 3 + r + 140) * Double(10 * s)), y = r * 18 * s + Int(noise(k * 3 + r + 150) * Double(12 * s))
                    let rx = (14 + Int(noise(k * 3 + r + 160) * 10)) * s
                    c.ellipse(x, y + 3 * s, rx, rx * 2 / 3, C(0x6A3A1E))
                    c.ellipse(x - 2 * s, y, rx, rx * 2 / 3, [C(0xB86A2A), C(0xC8902E), C(0x9A4A22)][(k + r) % 3])
                    c.ellipse(x - 4 * s, y - 3 * s, rx / 2, rx / 4, C(0xE0A848))
                }
            }
            // Branches reaching out from the near trunks, with clumps of leaves along them.
            for (k, tx) in f.trunks.enumerated() {
                for b in 0..<4 {
                    let by = 40 * s + b * 30 * s + k * 6 * s, dir = (b + k) % 2 == 0 ? 1 : -1
                    guard by < g - 60 * s else { continue }
                    for d in 0..<(26 * s) { c.rect(tx + dir * d, by - d / 3, 2 * s - (d > 14 * s ? s : 0), 2 * s, C(0x3A2A1E)) }
                    for j in 0..<3 {
                        let lx = tx + dir * (10 + j * 7) * s, ly = by - (4 + j * 2) * s
                        c.ellipse(lx, ly + s, 6 * s, 4 * s, C(0x7A3E1E)); c.ellipse(lx, ly, 6 * s, 4 * s, [C(0xC8762A), C(0xA84A22), C(0xD8A040)][(j + b) % 3])
                    }
                }
            }
        }

        // The near trees: dark trunks, lit on the left.
        for (k, tx) in f.trunks.enumerated() {
            hawkinsP5Trunk(c, tx, g, (k % 2 == 0 ? 10 : 7) * s, s, bark: C(0x4A3A2C), barkD: C(0x30251C), barkL: C(0x6A5644), seed: k + 10)
        }
        if !tall {
            // In the strip the near trees' lowest leaves hang in at the top.
            for k in 0..<(c.w / (10 * s) + 1) {
                let x = k * 10 * s + Int(noise(k + 170) * Double(6 * s))
                if x > c.w / 4 { c.ellipse(x, Int(noise(k + 180) * Double(4 * s)), (7 + k % 3 * 2) * s, (4 + k % 2) * s, [C(0xA85A26), C(0xC8862A), C(0x8A4220)][k % 3]) }
            }
        }

        // The creek on the left, catching the light, its stones; a fallen log beside it with a fern.
        let ck = f.creek
        c.ellipse(ck, g - 4 * s, 26 * s, 3 * s, C(0x5A6A78)); c.ellipse(ck, g - 4 * s, 22 * s, 2 * s, C(0x7A8A98))
        for k in 0..<5 { c.ellipse(ck - 20 * s + k * 10 * s, g - 3 * s, 2 * s, s, C(0x8A8478)) }
        let lg = c.w * 38 / 100
        c.rect(lg - 16 * s, g - 7 * s, 32 * s, 6 * s, C(0x5A4430)); c.rect(lg - 16 * s, g - 7 * s, 32 * s, s, C(0x7A6048))
        c.ellipse(lg + 16 * s, g - 4 * s, 2 * s, 3 * s, C(0xA88A62)); c.ellipse(lg + 16 * s, g - 4 * s, s, 2 * s, C(0x7A6048))
        for k in 0..<5 { c.rect(lg - 12 * s + k * 6 * s, g - 7 * s, 2 * s, s, C(0x3A6A2A)) }
        for (k, fx) in [lg - 20 * s, c.w * 76 / 100, c.w * 3 / 100].enumerated() {
            for a in 0..<5 {
                let r = -2.6 + Double(a) * 0.45
                for d in 0..<(7 + k) { c.rect(fx + Int(cos(r) * Double(d * s)), g - s + Int(sin(r) * Double(d * s)) + d * d * s / 20, s, s, C(0x4A6A2E)) }
            }
        }

        // The fort. Behind it, branches leaning in against it, crossing above the roof.
        let fx = f.fort, fw = 78 * s, left = fx - fw / 2
        for (k, (x0, lean)) in [(left - 4 * s, 1), (left + 10 * s, 1), (fx + 20 * s, -1), (left + fw + 2 * s, -1)].enumerated() {
            for d in 0..<(50 * s) { c.rect(x0 + lean * d * (3 + k % 2) / 10, g - d, 2 * s, 1, C(0x4E3C2A)) }
        }
        // The walls: planks and boards of every length and colour, nailed upright, their tops ragged.
        let planks = [C(0x8A6A48), C(0x7A5C3C), C(0x9A7A54), C(0x6E5236), C(0x8A7458), C(0x7E6650)]
        var x = left, k = 0
        while x < left + fw {
            let pw = (4 + Int(noise(k + 205) * 3)) * s, h = (30 + Int(noise(k + 200) * 8)) * s
            c.rect(x, g - h, pw, h, planks[k % 6]); c.rect(x, g - h, s, h, C(0x5A4230))
            c.rect(x + pw / 2, g - h + 3 * s, s, s, C(0x3A3A3A)); c.rect(x + pw / 2, g - 6 * s, s, s, C(0x3A3A3A))
            if noise(k + 210) > 0.6 { c.rect(x + s, g - h + (8 + k % 5 * 3) * s, pw - s, s, C(0x4A3628)) }   // a split
            x += pw; k += 1
        }
        // Boards nailed across the walls, a little crooked.
        for (j, y) in [g - 22 * s, g - 10 * s].enumerated() {
            for xx in stride(from: left, to: left + fw, by: s) {
                let yy = y + (xx - left) * (j == 0 ? 2 : -1) / fw * s
                c.rect(xx, yy, s, 3 * s, C(0x9A8060)); c.px(xx, yy, C(0xB89A76))
            }
        }
        // The roof: a sheet of corrugated tin, rusty, sloping, a tarp over half of it, and the blankets thrown over
        // the lot: a red plaid hanging down the left, a faded blue over the right.
        let top = g - 40 * s
        for y in 0..<(8 * s) {
            let x0 = left - 6 * s, x1 = left + fw + 6 * s
            c.rect(x0, top - 4 * s + y, x1 - x0, 1, y < s ? C(0xA8A090) : (y / s) % 2 == 0 ? C(0x8A6A50) : C(0x7A5A44))
        }
        for xx in stride(from: left - 6 * s, to: left + fw + 6 * s, by: 4 * s) { c.rect(xx, top - 4 * s, s, 8 * s, C(0x6A4A34)) }
        c.rect(fx - 2 * s, top - 6 * s, 26 * s, 10 * s, C(0x4A6A3A)); c.rect(fx - 2 * s, top - 6 * s, 26 * s, s, C(0x6A8A52))
        for xx in stride(from: fx, to: fx + 24 * s, by: 6 * s) { c.rect(xx, top - 5 * s, s, 9 * s, C(0x3A5430)) }
        let bl = left - 3 * s
        c.rect(bl, top - 7 * s, 30 * s, 24 * s, C(0xA83A2E))
        for xx in stride(from: bl, to: bl + 30 * s, by: 6 * s) { c.rect(xx, top - 7 * s, 2 * s, 24 * s, C(0x7A2A22)) }
        for y in stride(from: top - 5 * s, to: top + 17 * s, by: 6 * s) { c.rect(bl, y, 30 * s, s, C(0x5A1A1A)); c.rect(bl, y + 2 * s, 30 * s, s, C(0xD8C890, 0.5)) }
        for k in 0..<5 { c.rect(bl + k * 6 * s + 2 * s, top + 17 * s, 3 * s, (2 + k % 2) * s, C(0xA83A2E)) }   // the fringe
        let bb = left + fw - 22 * s
        c.rect(bb, top - 6 * s, 26 * s, 18 * s, C(0x5A7A9A)); c.rect(bb, top - 6 * s, 26 * s, s, C(0x7A9AB8))
        for k in 0..<4 { c.rect(bb + k * 7 * s, top - 4 * s, s, 16 * s, C(0x4A6684)) }
        c.rect(bb, top + 12 * s, 26 * s, s, C(0x3E5670))
        // A stone on each corner of the roof to hold it down, and the pennant on a stick at the top.
        for sx in [left + 30 * s, left + fw - 26 * s] { c.ellipse(sx, top - 6 * s, 3 * s, 2 * s, C(0x8A8A84)); c.ellipse(sx - s, top - 7 * s, 2 * s, s, C(0xA8A8A0)) }
        let pole = fx - 6 * s
        c.rect(pole, top - 22 * s, s, 18 * s, C(0x4A3A2A))
        for k in 0..<8 { c.rect(pole + s, top - 22 * s + k / 2 * s, (8 - k) * s, s, C(0xE8D040)) }
        // The doorway: a dark opening with a sheet hung across half of it, CASTLE BYERS painted over it.
        let dx = fx - 12 * s, dw = 18 * s, dtop = g - 24 * s
        c.rect(dx - 2 * s, dtop - 2 * s, dw + 4 * s, 26 * s, C(0x5A4230))
        c.rect(dx, dtop, dw, 24 * s, C(0x1A140E))
        c.rect(dx, dtop, dw / 2 + 2 * s, 24 * s, C(0xD8D0B8)); for k in 0..<3 { c.rect(dx + (2 + k * 3) * s, dtop, s, 24 * s, C(0xB8AE96)) }
        c.rect(dx, dtop, dw, s, C(0x3A2A1E))
        let nm = "CASTLE BYERS", nw = hawkinsP5Width(nm, s)
        c.rect(dx + dw / 2 - nw / 2 - 2 * s, dtop - 11 * s, nw + 4 * s, 8 * s, C(0xC8B48A)); c.rect(dx + dw / 2 - nw / 2 - 2 * s, dtop - 11 * s, nw + 4 * s, s, C(0xE0D0A8))
        c.rect(dx + dw / 2 - nw / 2 - 2 * s, dtop - 4 * s, nw + 4 * s, s, C(0x8A7656))
        hawkinsP5Centred(c, dx + dw / 2, dtop - 9 * s, nm, C(0x2A3A6A), s)
        // FRIENDS ONLY, on a board nailed beside the door, in red paint.
        let ft = "FRIENDS", fbw = hawkinsP5Width(ft, s) + 6 * s
        let bx = dx + dw + 5 * s, by = g - 27 * s
        c.rect(bx, by, fbw, 15 * s, C(0xE0D4B0)); c.rect(bx, by, fbw, s, C(0xF0E8D0)); c.rect(bx + fbw - s, by, s, 15 * s, C(0xA89A78))
        c.rect(bx + s, by + s, s, s, C(0x5A5A5A)); c.rect(bx + fbw - 2 * s, by + 13 * s, s, s, C(0x5A5A5A))
        hawkinsP5Centred(c, bx + fbw / 2, by + 2 * s, ft, C(0xB82A22), s)
        hawkinsP5Centred(c, bx + fbw / 2, by + 8 * s, "ONLY", C(0xB82A22), s)
        // The lantern by the door and a rusted bucket.
        let lx = dx - 9 * s
        c.rect(lx - 3 * s, g - 9 * s, 6 * s, 8 * s, C(0x3A3A3A)); c.rect(lx - 2 * s, g - 8 * s, 4 * s, 5 * s, C(0xC8A048))
        c.rect(lx - 3 * s, g - s, 6 * s, s, C(0x2A2A2A)); c.rect(lx - s, g - 11 * s, 2 * s, 2 * s, C(0x3A3A3A))
        let bu = left + fw + 12 * s
        c.rect(bu - 4 * s, g - 7 * s, 8 * s, 7 * s, C(0x7A5A44)); c.rect(bu - 4 * s, g - 7 * s, 8 * s, s, C(0x9A7A5A)); c.rect(bu + 3 * s, g - 7 * s, s, 7 * s, C(0x5A4030))
        for k in 0..<5 { c.px(bu - 4 * s + k * 2 * s, g - 9 * s - (k == 2 ? s : 0), C(0x6A5A44)) }

        // Leaves fallen on the ground at the back, against the plain earth.
        for k in 0..<(c.w / (4 * s)) {
            let x = Int(noise(k * 3 + 300) * Double(c.w)), y = g - Int(noise(k * 3 + 301) * Double(3 * s)) - s
            c.rect(x, y, 2 * s, s, [C(0xC8762A), C(0xA84A22), C(0xD8A040)][k % 3])
        }

        // The earth: dark brown, plain, a few leaves on it.
        c.ground(g, C(0x3E3024), edge: C(0x5A4634), speck: C(0x362A20), seed: 101)
        for k in 0..<(c.w / (18 * s)) {
            c.rect(Int(noise(k * 3 + 330) * Double(c.w)), g + 2 * s + Int(noise(k * 3 + 331) * Double(max(1, c.h - g - 4 * s))), 2 * s, s,
                   [C(0x8A4A22), C(0x9A6A2A)][k % 2])
        }
    }

    /// Castle Byers' life: leaves coming down through the air, each turning over as it falls, drifting sideways.
    static func hawkinsCastleByersLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), n = max(10, c.w * g / (1800 * s * s))
        for k in 0..<n {
            let sp = 4.0 + noise(k * 5 + 1) * 5, span = Double(g)
            var y = noise(k * 5 + 2) * span + t * sp * Double(s)
            y = y.truncatingRemainder(dividingBy: span)
            let x = Int(noise(k * 5 + 3) * Double(c.w) + sin(t * 1.3 + Double(k)) * Double(5 * s) + t * Double(s))
                % max(1, c.w)
            let col = [C(0xD8862A), C(0xB8502A), C(0xE8B040), C(0x9A4A22)][k % 4]
            if sin(t * 3 + Double(k)) > 0 { c.rect(x, Int(y), 2 * s, s, col) } else { c.rect(x, Int(y), s, 2 * s, col) }
        }
    }
}

// MARK: - Eddie's trailer

extension Scenes {
    /// Where things stand at the trailer: the trailer's left end and length, its door, the big window (the guitar
    /// behind it), the light pole the string of lights runs to, the van, and the neighbours' trailer.
    static func hawkinsTrailerFrame(_ c: PixelCanvas, _ g: Int)
        -> (trailer: (x: Int, w: Int), door: Int, window: (x: Int, y: Int), pole: Int, van: Int, neighbour: Int) {
        let s = unit(g), tx = c.w * 30 / 100
        return ((x: tx, w: 120 * s), tx + 22 * s, (x: tx + 58 * s, y: g - 33 * s), c.w * 90 / 100, c.w * 8 / 100, c.w * 82 / 100)
    }

    /// The string of lights: where each bulb hangs, sagging between the trailer's awning and the pole; `sway` moves
    /// the middle of the sag.
    static func hawkinsTrailerBulbs(_ c: PixelCanvas, _ g: Int, sway: Double) -> [(x: Int, y: Int)] {
        let s = unit(g), f = hawkinsTrailerFrame(c, g)
        let x0 = f.trailer.x + f.trailer.w - 4 * s, y0 = g - 42 * s, x1 = f.pole, y1 = g - 50 * s
        let n = max(2, (x1 - x0) / (7 * s))
        return (0...n).map { i in
            let u = Double(i) / Double(n)
            return (x0 + Int(Double(x1 - x0) * u), y0 + Int(Double(y1 - y0) * u + sin(u * .pi) * Double(10 * s) * (1 + sway * 0.25)))
        }
    }

    /// Eddie's trailer in Forest Hills, a spring night in 1986: a long, low single-wide in cream with a brown stripe,
    /// up on blocks with its skirting, an awning over the door and steps up to it; through the big window the warm
    /// light of his room, wood panelling, a poster and his red guitar hanging on the wall; a string of lights running
    /// from the awning to a pole, a lawn chair and a cooler under it, a barbecue, a mailbox. His van parked on the
    /// left, the neighbours' trailer dark on the right, a chain-link fence and pines behind, and the night sky full of
    /// stars with the moon up. Gravel along the front. On the screen saver the pines rise tall into the stars.
    static func hawkinsTrailer(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsTrailerFrame(c, g), tall = isTall(c)
        // The sky: deep blue, a little lighter near the treeline, stars, the moon.
        c.gradient(0, g, C(0x0A0E22), C(0x1E2A48), bands: 7)
        c.stars(0, g - 30 * s, density: 50 * s * s, seed: 11)
        let mx = c.w * 66 / 100, my = tall ? g - 160 * s : 10 * s
        for (r, a) in [(14, 0.05), (9, 0.08)] { c.circle(mx, my, r * s, C(0xE8ECD8, a)) }
        c.circle(mx, my, 5 * s, C(0xF0F0E0)); c.circle(mx + 2 * s, my - s, 4 * s, C(0xD8DCC8)); c.circle(mx - 2 * s, my + s, s, C(0xC8CCB8))
        // The pines: a far row, low and blue, then taller near ones, darker.
        func pine(_ x: Int, _ base: Int, _ h: Int, _ col: Px, _ lit: Px) {
            // Tiers of boughs: each widens downwards, then steps back in, lit along its top on the moon's side.
            let tier = max(5, h / s / 9)
            for r in 0..<(h / s) {
                let half = (r / 3 + 1) * s / 2 + (r % tier) * s / 2
                c.rect(x - half, base - h + r * s, half * 2 + s, s, col)
                if r % tier == 0 && r > 2 { c.rect(x, base - h + r * s, half, s, lit) }
                if r % tier == tier - 1 { c.rect(x - half, base - h + r * s, s, s, lit) }
            }
            c.rect(x, base - 4 * s, s, 4 * s, C(0x1A1410))
        }
        for k in 0..<(c.w / (8 * s) + 2) {
            pine(k * 8 * s + Int(noise(k + 50) * Double(5 * s)), g - 10 * s, (18 + Int(noise(k + 60) * 14)) * s, C(0x14223A), C(0x1E3048))
        }
        let near = tall ? 6 : 4
        for k in 0..<near {
            let x = c.w * (4 + k * 96 / near) / 100 + Int(noise(k + 70) * Double(20 * s))
            pine(x, g - 8 * s, (tall ? 110 + Int(noise(k + 80) * 60) : 56 + Int(noise(k + 80) * 12)) * s, C(0x0C1820), C(0x16283A))
        }
        // The chain-link fence along the back.
        let fy = g - 16 * s
        c.rect(0, fy, c.w, s, C(0x6A7484))
        for x in stride(from: 0, to: c.w, by: 3 * s) { c.rect(x, fy + s, s, 10 * s, C(0x3A4454, 0.6)) }
        for y in stride(from: fy + 2 * s, to: g - 6 * s, by: 3 * s) { c.rect(0, y, c.w, 1, C(0x3A4454, 0.4)) }
        for x in stride(from: 10 * s, to: c.w, by: 40 * s) { c.rect(x, fy - s, s, 12 * s, C(0x7A8494)) }
        c.rect(0, g - 6 * s, c.w, 6 * s, C(0x1E2430))

        // The park's sign on two posts: FOREST HILLS in white on brown, a pine painted beside it.
        let fsx = f.van + 30 * s, fst = "FOREST HILLS", fsw = hawkinsP5Width(fst, s) + 12 * s
        for px in [fsx + 3 * s, fsx + fsw - 4 * s] { c.rect(px, g - 22 * s, s * 2, 22 * s, C(0x4A3A2C)) }
        c.rect(fsx, g - 30 * s, fsw, 10 * s, C(0x5A3E26)); c.rect(fsx, g - 30 * s, fsw, s, C(0x8A6A48)); c.rect(fsx + s, g - 29 * s, fsw - 2 * s, 8 * s, C(0x6A4A2E))
        hawkinsP5Sign(c, fsx + 9 * s, g - 28 * s, fst, C(0xE8E0C8), s)
        for r in 0..<6 { c.rect(fsx + 5 * s - r * s / 2, g - 28 * s + r * s, r * s + s, s, C(0x3A8A4A)) }
        // The neighbours' trailer, dark, one window lit by a TV.
        let nx = f.neighbour
        c.rect(nx - 10 * s, g - 26 * s, 80 * s, 22 * s, C(0x3A4250)); c.rect(nx - 10 * s, g - 26 * s, 80 * s, s, C(0x4E5666))
        c.rect(nx - 10 * s, g - 16 * s, 80 * s, 2 * s, C(0x2A3240)); c.rect(nx - 8 * s, g - 4 * s, 76 * s, 4 * s, C(0x1A1E26))
        c.rect(nx + 4 * s, g - 22 * s, 10 * s, 5 * s, C(0x5A7AB0, 0.7)); c.rect(nx + 24 * s, g - 22 * s, 10 * s, 5 * s, C(0x14181E))

        // Eddie's van: a dark boxy van with a stripe, its windows dark, parked side-on at the left.
        let vx = f.van
        c.rect(vx - 22 * s, g - 22 * s, 44 * s, 16 * s, C(0x2A2A32)); c.rect(vx - 22 * s, g - 22 * s, 44 * s, s, C(0x4A4A56))
        c.rect(vx + 12 * s, g - 20 * s, 10 * s, 6 * s, C(0x10141C)); c.rect(vx - 18 * s, g - 20 * s, 8 * s, 5 * s, C(0x10141C))
        c.rect(vx - 22 * s, g - 13 * s, 44 * s, 2 * s, C(0x8A3A2A))
        for wx in [vx - 13 * s, vx + 13 * s] { c.circle(wx, g - 5 * s, 4 * s, C(0x0C0C10)); c.circle(wx, g - 5 * s, 2 * s, C(0x6A6A74)) }
        c.rect(vx + 21 * s, g - 12 * s, 2 * s, 2 * s, C(0xC8A858))

        // The trailer: cream siding in ribs, a brown stripe along its middle, the skirting and the blocks, a low
        // rounded roof edge; the windows; the door under its awning with the steps.
        let tr = f.trailer, ttop = g - 40 * s
        c.rect(tr.x, ttop, tr.w, 34 * s, C(0xD8CCAA))
        for x in stride(from: tr.x, to: tr.x + tr.w, by: 3 * s) { c.rect(x, ttop + 2 * s, s, 32 * s, C(0xC8BC9A)) }
        c.rect(tr.x, ttop, tr.w, 2 * s, C(0xE8DCC0)); c.rect(tr.x - s, ttop - s, tr.w + 2 * s, s, C(0xB8AC8C))
        c.rect(tr.x, ttop + 16 * s, tr.w, 4 * s, C(0x7A4A2A)); c.rect(tr.x, ttop + 16 * s, tr.w, s, C(0x9A6A3A))
        c.rect(tr.x, g - 6 * s, tr.w, 6 * s, C(0x5A5448))
        for x in stride(from: tr.x, to: tr.x + tr.w, by: 4 * s) { c.rect(x, g - 6 * s, s, 6 * s, C(0x4A4438)) }
        c.rect(tr.x + tr.w - s, ttop, s, 34 * s, C(0xA89C7C))
        // A small window left of the door, dark with a curtain.
        c.rect(tr.x + 5 * s, ttop + 5 * s, 10 * s, 9 * s, C(0x8A8070)); c.rect(tr.x + 6 * s, ttop + 6 * s, 8 * s, 7 * s, C(0x1A1E2A))
        c.rect(tr.x + 6 * s, ttop + 6 * s, 3 * s, 7 * s, C(0x6A3A3A))
        // The big window: his room lit warm, panelling, a poster, the guitar on the wall (a red body with sharp horns).
        let w0 = f.window, ww = 36 * s, wh = 16 * s
        c.rect(w0.x - 2 * s, w0.y - 2 * s, ww + 4 * s, wh + 4 * s, C(0x8A8070))
        c.rect(w0.x, w0.y, ww, wh, C(0xB87A3A))
        for x in stride(from: w0.x, to: w0.x + ww, by: 4 * s) { c.rect(x, w0.y, s, wh, C(0x9A6230)) }
        c.rect(w0.x + 2 * s, w0.y + 2 * s, 9 * s, 11 * s, C(0x1A1A22)); c.circle(w0.x + 6 * s, w0.y + 6 * s, 2 * s, C(0xD8D0B8))
        c.rect(w0.x + 4 * s, w0.y + 9 * s, 5 * s, 2 * s, C(0xC83A2A))
        let gx = w0.x + 22 * s, gy = w0.y + 2 * s
        c.rect(gx + 3 * s, gy, 2 * s, 6 * s, C(0x2A1A10)); c.rect(gx + 3 * s, gy - s, 2 * s, s, C(0x1A1A1A))
        c.rect(gx, gy + 6 * s, 8 * s, 5 * s, C(0xC8202A)); c.rect(gx - 2 * s, gy + 5 * s, 3 * s, 2 * s, C(0xC8202A)); c.rect(gx + 7 * s, gy + 4 * s, 3 * s, 2 * s, C(0xC8202A))
        c.rect(gx + 2 * s, gy + 11 * s, 4 * s, 2 * s, C(0xC8202A)); c.rect(gx + 3 * s, gy + 7 * s, 2 * s, 4 * s, C(0x1A1A1A))
        c.rect(gx, gy + 6 * s, 8 * s, s, C(0xF05A5A))
        c.rect(w0.x + ww / 2, w0.y, s, wh, C(0x8A8070))
        // The door: a metal door with a small window, under its awning, the steps down to the ground.
        let dx = f.door
        c.rect(dx - 7 * s, ttop + 4 * s, 14 * s, 30 * s, C(0xC8BC9A)); c.rect(dx - 7 * s, ttop + 4 * s, 14 * s, 30 * s, C(0xB8AC8A))
        c.rect(dx - 6 * s, ttop + 5 * s, 12 * s, 29 * s, C(0xD8D0B8)); c.rect(dx - 4 * s, ttop + 8 * s, 8 * s, 6 * s, C(0x1A1E2A))
        c.rect(dx + 3 * s, ttop + 20 * s, 2 * s, s, C(0x8A8A92))
        c.rect(dx - 14 * s, ttop - 2 * s, 28 * s, 3 * s, C(0x3A6A5A)); for x in stride(from: dx - 14 * s, to: dx + 14 * s, by: 4 * s) { c.rect(x, ttop - 2 * s, 2 * s, 3 * s, C(0xD8D8C8)) }
        c.rect(dx - 13 * s, ttop + s, s, 39 * s, C(0x8A8A92)); c.rect(dx + 12 * s, ttop + s, s, 39 * s, C(0x8A8A92))
        for k in 0..<3 { c.rect(dx - 8 * s, ttop + 34 * s + k * 2 * s, 16 * s, 2 * s, k == 0 ? C(0x6A6A70) : C(0x5A5A60)); c.rect(dx - 8 * s, ttop + 34 * s + k * 2 * s, 16 * s, s, C(0x8A8A92)) }

        // The pole for the lights, the lawn chair and the cooler, the barbecue, the mailbox.
        let pl = f.pole
        c.rect(pl - s, g - 54 * s, 2 * s, 54 * s, C(0x4A3A2C)); c.rect(pl - s, g - 54 * s, s, 54 * s, C(0x6A5644))
        let lc = tr.x + tr.w + 14 * s
        c.rect(lc - 5 * s, g - 9 * s, 10 * s, 2 * s, C(0x3AA8A0)); for x in stride(from: lc - 5 * s, to: lc + 5 * s, by: 2 * s) { c.rect(x, g - 9 * s, s, 2 * s, C(0xE8E8D8)) }
        c.rect(lc - 6 * s, g - 17 * s, 2 * s, 8 * s, C(0x3AA8A0)); c.rect(lc - 6 * s, g - 17 * s, s, 8 * s, C(0xE8E8D8))
        c.rect(lc - 5 * s, g - 7 * s, s, 7 * s, C(0xB8B8C0)); c.rect(lc + 4 * s, g - 7 * s, s, 7 * s, C(0xB8B8C0))
        c.rect(lc + 8 * s, g - 7 * s, 10 * s, 7 * s, C(0xC83A2A)); c.rect(lc + 8 * s, g - 7 * s, 10 * s, 2 * s, C(0xE8E8E0))
        let bq = pl - 18 * s
        c.ellipse(bq, g - 13 * s, 6 * s, 3 * s, C(0x1A1A1E)); c.rect(bq - 6 * s, g - 13 * s, 12 * s, s, C(0x3A3A40))
        for dx2 in [-4, 0, 4] { c.rect(bq + dx2 * s, g - 11 * s, s, 11 * s, C(0x2A2A30)) }
        c.rect(nx - 20 * s, g - 14 * s, 2 * s, 14 * s, C(0x4A3A2C)); c.rect(nx - 23 * s, g - 19 * s, 8 * s, 5 * s, C(0x5A6A7A)); c.rect(nx - 23 * s, g - 19 * s, 8 * s, s, C(0x7A8A9A))

        // The string of lights' wire (the bulbs are lit by the moving layer).
        let bulbs = hawkinsTrailerBulbs(c, g, sway: 0)
        for (a, b) in zip(bulbs, bulbs.dropFirst()) { hawkinsLine(c, Double(a.x), Double(a.y), Double(b.x), Double(b.y), C(0x1A1A1E), 0.5) }

        // Gravel: dark and plain, grey specks.
        c.ground(g, C(0x2E2C30), edge: C(0x46444A), speck: C(0x3A383E), seed: 111)
    }

    /// The trailer's life: the string of lights swaying a little in the night air, each bulb in its own colour with a
    /// soft glow, and the light in his window flickering warm now and then like a lava lamp's.
    static func hawkinsTrailerLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsTrailerFrame(c, g)
        let bulbs = hawkinsTrailerBulbs(c, g, sway: sin(t * 1.1))
        for (a, b) in zip(bulbs, bulbs.dropFirst()) { hawkinsLine(c, Double(a.x), Double(a.y), Double(b.x), Double(b.y), C(0x1A1A1E), 0.5) }
        let cols = [C(0xFF5A4A), C(0xFFD050), C(0x5AE07A), C(0x5AA8FF), C(0xFF8AD0)]
        for (k, b) in bulbs.enumerated().dropFirst().dropLast() {
            let col = cols[k % cols.count]
            c.circle(b.x, b.y + 2 * s, 3 * s, col.alpha(0.12)); c.rect(b.x - s / 2, b.y + s, max(1, s), 2 * s, col)
        }
        let w0 = f.window, glow = noise(Int(t * 3) + 70)
        c.rect(w0.x, w0.y, 36 * s, 16 * s, C(0xFF9A40, 0.04 + glow * 0.05))
    }
}

// MARK: - Kamchatka

extension Scenes {
    /// Where things stand at Kamchatka: the two guard towers, the cell block, the pit and its gantry, the gate.
    static func hawkinsKamchatkaFrame(_ c: PixelCanvas, _ g: Int) -> (towers: [Int], block: Int, pit: Int, gate: Int) {
        ([c.w * 12 / 100, c.w * 90 / 100], c.w * 28 / 100, c.w * 62 / 100, c.w * 44 / 100)
    }

    /// Kamchatka, winter 1986: a Soviet prison yard in the snow at dusk. A grey concrete wall right across the back with
    /// coils of barbed wire along its top, a guard tower at either end on tall legs with a hut and a searchlight; the
    /// cell block on the left, small barred windows, a red star over its door, snow on its roof; the gate in the wall,
    /// iron, shut. In the middle of the yard the pit: a round concrete rim with a rail round it and a warning sign (a
    /// skull and crossbones and ОПАСНО, "danger"), dark inside with a dull red glow coming up, and a steel gantry over it
    /// with the chain and hook hanging down into it. Snowy volcanoes far off, under a cold grey sky. Trampled snow along the front, plain. On the
    /// screen saver the towers stand tall over the wall and the mountains rise behind under heavy snow cloud.
    static func hawkinsKamchatka(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsKamchatkaFrame(c, g), tall = isTall(c)
        // The sky: heavy grey-blue cloud, lighter low down.
        c.gradient(0, g, C(0x2A3442), C(0x6A7686), bands: 7)
        if tall {
            for k in 0..<(g / (16 * s)) {
                let y = k * 16 * s + Int(noise(k + 400) * Double(8 * s))
                for j in 0..<(c.w / (50 * s) + 2) {
                    let x = j * 50 * s + Int(noise(k * 9 + j + 410) * Double(30 * s))
                    c.ellipse(x, y, (30 + Int(noise(k * 9 + j + 420) * 20)) * s, (5 + k % 3) * s, C(0x3A4454, 0.6))
                }
            }
        }
        // The volcanoes far off: a low range in the haze, then three cones, snow on their upper slopes, gullies of dark
        // rock running down through it, the dark lower slopes; on the screen saver steam rising off the tallest.
        let wallTop = g - 34 * s
        c.dunes(base: wallTop - 4 * s, amp: Double(4 * s), freq: 0.03 / Double(s), phase: 2, bottom: wallTop + 2 * s, C(0x5A6676), shade: C(0x7A8696))
        for (k, vx) in [c.w * 22 / 100, c.w * 60 / 100, c.w * 92 / 100].enumerated() {
            let h = (tall ? 70 + k % 2 * 30 : 30 + k % 2 * 10) * s, base = wallTop + 6 * s, w = h * 2
            for dx in -w...w {
                let top = base - h + abs(dx) * h / w + Int(noise(k * 300 + dx / max(1, s)) * Double(s))
                guard top < base else { continue }
                // The snowline ragged, in teeth where the gullies cut up into it.
                let u = Double(dx + w) / Double(6 * s), col = Int(u), fr = u - Double(col)
                let jag = noise(k * 310 + col) * (1 - fr) + noise(k * 310 + col + 1) * fr
                let cap = h / 3 - abs(dx) * h / (4 * w) + Int((jag - 0.5) * Double(10 * s))
                c.rect(vx + dx, top, 1, base - top, dx > 0 ? C(0x343E4C) : C(0x46505E))
                c.rect(vx + dx, top, 1, max(0, min(base - top, cap)), dx > 0 ? C(0xB8C4D0) : C(0xE0E8EE))
                if dx % (6 * s) == 0 && noise(k * 320 + col) > 0.6 && abs(dx) > 4 * s {
                    let g0 = top + cap / 3 + Int(noise(k * 330 + col) * Double(cap / 3))
                    c.rect(vx + dx, g0, 1, max(0, min(base, top + cap + 4 * s) - g0), dx > 0 ? C(0x4A5464) : C(0x6A7484))
                }
            }
            if tall && k == 1 {
                for j in 0..<10 { c.ellipse(vx + j * 5 * s, base - h - 6 * s - j * 7 * s, (6 + j * 2) * s, (3 + j / 2) * s, C(0xC8D0D8, 0.18 - Double(j) * 0.012)) }
            }
        }
        // On the screen saver the searchlights' beams reach up into the falling snow, faint.
        if tall {
            for (k, tx) in f.towers.enumerated() {
                let lx = Double(tx + (k == 0 ? 12 : -12) * s), ly = Double(g - 90 * s), dir = k == 0 ? 1.0 : -1.0
                for d in stride(from: 0, to: Double(g), by: Double(s)) {
                    let w = Int(d * 0.16) + s
                    c.rect(Int(lx + dir * d * 0.55) - w / 2, Int(ly - d), w, s, C(0xE8F0F8, 0.07))
                }
            }
        }
        // The concrete wall: slabs, stained, a lip along the top, posts with barbed wire in coils.
        c.rect(0, wallTop, c.w, g - wallTop, C(0x7A7E84))
        for x in stride(from: 0, to: c.w, by: 22 * s) { c.rect(x, wallTop, s, g - wallTop, C(0x5E6268)); c.rect(x + s, wallTop, s, g - wallTop, C(0x8E9298)) }
        for k in 0..<(c.w / (30 * s) + 1) { c.rect(k * 30 * s + Int(noise(k + 430) * Double(10 * s)), wallTop + 4 * s, 3 * s, 14 * s, C(0x6A6E74, 0.7)) }
        c.rect(0, wallTop, c.w, 2 * s, C(0x9A9EA4)); c.rect(0, wallTop - s, c.w, s, C(0xE8EEF2))
        for x in stride(from: 6 * s, to: c.w, by: 30 * s) { c.rect(x, wallTop - 9 * s, s, 9 * s, C(0x3A3E44)) }
        for x in stride(from: 0, to: c.w, by: s) {
            let a = Double(x) / Double(3 * s)
            c.px(x, wallTop - 5 * s + Int(sin(a) * Double(3 * s)), C(0x2A2E34)); c.px(x, wallTop - 5 * s - Int(sin(a) * Double(3 * s)), C(0x4A4E54))
        }

        // The gate: two iron leaves, ribbed, a red band across.
        let gx = f.gate
        c.rect(gx - 18 * s, g - 30 * s, 36 * s, 30 * s, C(0x3A4048))
        for x in stride(from: gx - 18 * s, to: gx + 18 * s, by: 4 * s) { c.rect(x, g - 30 * s, s, 30 * s, C(0x4E545C)) }
        c.rect(gx, g - 30 * s, s, 30 * s, C(0x22262C)); c.rect(gx - 18 * s, g - 18 * s, 36 * s, 3 * s, C(0x8A2A22))
        c.rect(gx - 20 * s, g - 32 * s, 3 * s, 32 * s, C(0x5A5E64)); c.rect(gx + 17 * s, g - 32 * s, 3 * s, 32 * s, C(0x5A5E64))

        // The cell block: grey, flat-roofed with snow on it, barred windows, the door under a red star.
        let bx = f.block, bw = 64 * s, btop = g - 44 * s
        c.rect(bx - bw / 2, btop, bw, 44 * s, C(0x8A8A86)); c.rect(bx - bw / 2, btop, bw, s, C(0xA8A8A4))
        c.rect(bx + bw / 2 - 5 * s, btop, 5 * s, 44 * s, C(0x6E6E6A))
        for y in stride(from: btop + 8 * s, to: g, by: 8 * s) { c.rect(bx - bw / 2, y, bw, s, C(0x7A7A76)) }
        c.rect(bx - bw / 2 - 2 * s, btop - 3 * s, bw + 4 * s, 3 * s, C(0xE8EEF2)); c.rect(bx - bw / 2 - 2 * s, btop, bw + 4 * s, s, C(0xB8C0C8))
        for (r, wy) in [btop + 5 * s, btop + 18 * s].enumerated() {
            for k in 0..<5 where !(r == 1 && k == 2) {
                let wx = bx - bw / 2 + 5 * s + k * 12 * s
                c.rect(wx, wy, 6 * s, 5 * s, C(0x1A1E24)); for b in 0..<3 { c.rect(wx + s + b * 2 * s, wy, s, 5 * s, C(0x6A6E74)) }
                c.rect(wx - s, wy + 5 * s, 8 * s, s, C(0xE0E6EA))
            }
        }
        let dx = bx - bw / 2 + 29 * s
        c.rect(dx - 6 * s, g - 22 * s, 12 * s, 22 * s, C(0x3A4A3A)); c.rect(dx - 6 * s, g - 22 * s, 12 * s, s, C(0x5A6A5A))
        c.rect(dx + 3 * s, g - 12 * s, s, 2 * s, C(0xA8A8A0)); c.rect(dx - 7 * s, g - 23 * s, 14 * s, s, C(0x5A5A56))
        let stx = dx, sty = g - 28 * s
        for d in -3...3 { c.rect(stx - (3 - abs(d)) * s / 2 - s / 2, sty + d * s / 2, (3 - abs(d)) * s + s, s, C(0xC82A22)) }
        c.rect(stx - 4 * s, sty - s, 9 * s, s, C(0xC82A22))
        c.rect(bx + bw / 2 - 12 * s, btop + 30 * s, 6 * s, 3 * s, C(0x3A3E44)); c.rect(bx + bw / 2 - 11 * s, btop + 33 * s, 4 * s, s, C(0xF0E8B0, 0.8))

        // The guard towers: four legs braced, a hut on top with dark windows and a roof, a searchlight, a ladder.
        for (k, tx) in f.towers.enumerated() {
            let legH = tall ? 70 * s : 30 * s, hutTop = g - legH - 16 * s
            for lx in [tx - 10 * s, tx + 9 * s] { c.rect(lx, g - legH, 2 * s, legH, C(0x3A3A3E)); c.rect(lx, g - legH, s, legH, C(0x5A5A60)) }
            for y in stride(from: g - legH + 4 * s, to: g - 4 * s, by: 12 * s) {
                for d in 0..<(19 * s) { c.px(tx - 9 * s + d, y + d * 10 / 19, C(0x3A3A3E)); c.px(tx + 9 * s - d, y + d * 10 / 19, C(0x3A3A3E)) }
            }
            for y in stride(from: g - legH + 2 * s, to: g, by: 3 * s) { c.rect(tx - 3 * s, y, 4 * s, s, C(0x4A4A50)) }
            c.rect(tx - 3 * s, g - legH, s, legH, C(0x4A4A50)); c.rect(tx, g - legH, s, legH, C(0x4A4A50))
            c.rect(tx - 13 * s, hutTop, 26 * s, 16 * s, C(0x5A5E54)); c.rect(tx - 13 * s, hutTop, 26 * s, s, C(0x7A7E74))
            c.rect(tx - 11 * s, hutTop + 3 * s, 22 * s, 6 * s, C(0x14181E)); c.rect(tx - s, hutTop + 3 * s, s, 6 * s, C(0x5A5E54))
            c.rect(tx - 15 * s, g - legH, 30 * s, 2 * s, C(0x4A4E44))
            for y in 0..<(6 * s) { let half = 17 * s - y * 3; if half > 0 { c.rect(tx - half, hutTop - y - s, half * 2, 1, y < 2 * s ? C(0xE8EEF2) : C(0x3A3E3A)) } }
            let lx = tx + (k == 0 ? 10 : -14) * s
            c.rect(lx, hutTop - 4 * s, 5 * s, 4 * s, C(0x2A2A2E)); c.rect(lx + (k == 0 ? 4 : 0) * s, hutTop - 3 * s, s, 2 * s, C(0xF8F0C8))
        }

        // The pit: the gantry first (behind the rim), its chain down into the dark, then the rim, the rail, the sign.
        let px = f.pit, rx = 34 * s
        let gTop = g - 52 * s
        for side in [-1, 1] {
            let lx = px + side * (rx - 4 * s)
            for d in 0..<(46 * s) { c.rect(lx - side * d / 8, gTop + d, 2 * s, 1, C(0x5A4A3A)) }
        }
        c.rect(px - rx, gTop - 3 * s, rx * 2, 4 * s, C(0x6A5A44)); c.rect(px - rx, gTop - 3 * s, rx * 2, s, C(0x8A7A5E))
        for x in stride(from: px - rx + 2 * s, to: px + rx - 2 * s, by: 5 * s) { c.rect(x, gTop - 3 * s, s, 4 * s, C(0x4A3E30)) }
        c.rect(px - rx, gTop - 4 * s, rx * 2, s, C(0xE8EEF2))
        c.rect(px - 3 * s, gTop + s, 6 * s, 4 * s, C(0x3A3A40))
        // The chain, and the cage hanging from it, half lowered: a box of bars with a roof plate.
        let cageTop = g - 28 * s
        for y in stride(from: gTop + 5 * s, to: cageTop - 2 * s, by: 2 * s) { c.rect(px - (y / (2 * s)) % 2 * s, y, 2 * s, s, C(0x7A7A82)) }
        for d in 0..<(4 * s) { c.px(px - d * 2, cageTop - 2 * s + d / 2, C(0x7A7A82)); c.px(px + d * 2, cageTop - 2 * s + d / 2, C(0x7A7A82)) }
        c.rect(px - 9 * s, cageTop, 18 * s, 2 * s, C(0x4A4E54)); c.rect(px - 9 * s, cageTop, 18 * s, s, C(0xE8EEF2))
        c.rect(px - 9 * s, cageTop + 2 * s, 18 * s, 14 * s, C(0x1A1416, 0.55))
        for xx in stride(from: px - 9 * s, through: px + 8 * s, by: 3 * s) { c.rect(xx, cageTop + 2 * s, s, 14 * s, C(0x5A5E64)) }
        c.rect(px - 9 * s, cageTop + 15 * s, 18 * s, s, C(0x4A4E54))
        // The rim: concrete round the dark hole, its far wall going down into the dark, the red glow coming up.
        let py = g - 8 * s
        c.ellipse(px, py + s, rx + 3 * s, 8 * s, C(0x8A8E92)); c.ellipse(px, py, rx + 3 * s, 7 * s, C(0xC8CCD0))
        c.ellipse(px, py, rx, 6 * s, C(0x1A1416))
        for y in 0..<(6 * s) { c.rect(px - rx + 4 * s, py - 5 * s + y, rx * 2 - 8 * s, 1, lerp(C(0x4A4A4E), C(0x0C0808), Double(y) / Double(6 * s))) }
        c.ellipse(px, py + 3 * s, rx - 4 * s, 3 * s, C(0x0C0808)); c.ellipse(px, py + 4 * s, rx - 10 * s, 2 * s, C(0x4A1412))
        c.rect(px - rx - 3 * s, py + s, (rx + 3 * s) * 2 + s, g - py - s, C(0x8A8E92)); c.rect(px - rx - 3 * s, py + s, (rx + 3 * s) * 2 + s, s, C(0xC8CCD0))
        c.rect(px - rx - 3 * s, g - 2 * s, (rx + 3 * s) * 2 + s, s, C(0x6A6E72))
        // The rail round it, posts and a top bar, and the warning sign hung on it.
        c.rect(px - rx - 3 * s, g - 17 * s, (rx + 3 * s) * 2 + s, s, C(0xC8B030))
        for x in stride(from: px - rx - 3 * s, through: px + rx + 3 * s, by: 10 * s) { c.rect(x, g - 17 * s, s, 10 * s, C(0xA8902A)) }
        // The sign: white with a red band along the top, a skull and crossbones and ОПАСНО in red.
        let sw = hawkinsP5Width("ОПАСНО", s), sx = px - rx + 4 * s
        c.rect(sx, g - 18 * s, sw + 13 * s, 8 * s, C(0xE8E8E0)); c.rect(sx, g - 18 * s, sw + 13 * s, s, C(0xC82A22))
        let skull = ["X.XXX.X", ".XXXXX.", ".X.X.X.", ".XXXXX.", "..X.X..", ".X...X.", "X.....X"]
        for (j, row) in skull.enumerated() {
            for (i, ch) in row.enumerated() where ch == "X" { c.rect(sx + (2 + i) * s, g - (17 - j) * s, s, s, C(0x1E1E22)) }
        }
        hawkinsP5Sign(c, sx + 11 * s, g - 16 * s, "ОПАСНО", C(0xC82A22), s)

        // Snow drifted against the foot of the wall and the buildings.
        for k in 0..<(c.w / (12 * s) + 1) { c.ellipse(k * 12 * s, g - s, (8 + k % 3 * 3) * s, 2 * s, C(0xD8E0E6)) }

        // The yard: trampled snow, grey and plain, a lit edge.
        c.ground(g, C(0x5A626C), edge: C(0x8A949E), speck: C(0x525A64), seed: 121)
    }

    /// Kamchatka's life: snow falling slowly, drifting with the wind, and the pit's red glow breathing.
    static func hawkinsKamchatkaLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsKamchatkaFrame(c, g)
        let n = c.w * g / (500 * s * s)
        for k in 0..<n {
            let sp = 5.0 + noise(k * 5 + 1) * 6, span = Double(g)
            var y = noise(k * 5 + 2) * span + t * sp * Double(s)
            y = y.truncatingRemainder(dividingBy: span)
            var x = noise(k * 5 + 3) * Double(c.w) + sin(t * 0.7 + Double(k)) * Double(4 * s) - t * 3 * Double(s)
            x = x.truncatingRemainder(dividingBy: Double(c.w)); if x < 0 { x += Double(c.w) }
            c.rect(Int(x), Int(y), s, s, C(0xF4F8FC, 0.55 + noise(k * 5 + 4) * 0.4))
        }
        let breathe = 0.5 + 0.5 * sin(t * 1.4)
        c.ellipse(f.pit, g - 5 * s, 20 * s, 2 * s, C(0xC8301E, 0.14 + breathe * 0.14))
    }
}
