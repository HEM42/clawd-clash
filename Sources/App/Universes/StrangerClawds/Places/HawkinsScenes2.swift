import Foundation

// Places: the Byers' house and Hawkins National Laboratory, 1983. The Byers' living room is warm and worn, khaki
// wallpaper over dark panelling, with Joyce's painted alphabet and its Christmas lights the one bright thing in it; the
// Lab is cold, grey concrete and green-grey tiles under strip lights, with the Gate's red-orange the only warmth. The
// floor and the band above it stay plain and mid-dark so the crew's outlines and names read.

let hawkinsScenes2: [Location: Place] = [
    .hawkinsByers: Place(name: "The Byers' Living Room", panel: 0x1C1610, still: Scenes.hawkinsByers,
                         moving: Scenes.hawkinsByersLife),
    .hawkinsLab: Place(name: "Hawkins National Laboratory", panel: 0x12161A, still: Scenes.hawkinsLab,
                       moving: Scenes.hawkinsLabLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 5-row alphabet, all 26 letters (Joyce paints every one). Three dots wide, but M and W are five and N is
/// four, so their diagonals read.
private let hawkinsP2Glyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011", "D": "110101101101110",
    "E": "111100110100111", "F": "111100110100100", "G": "011100101101011", "H": "101101111101101",
    "I": "111010010010111", "J": "001001001101010", "K": "101101110101101", "L": "100100100100111",
    "M": "1000111011101011000110001", "N": "10011101101110011001", "O": "010101101101010", "P": "110101110100100",
    "Q": "010101101110011", "R": "110101110101101", "S": "011100010001110", "T": "111010010010010",
    "U": "101101101101111", "V": "101101101101010", "W": "1000110001101011101110001", "X": "101101010101101",
    "Y": "101101010010010", "Z": "111001010100111",
]

/// How many dots wide a letter is.
private func hawkinsP2Width(_ ch: Character) -> Int { (hawkinsP2Glyphs[ch]?.count ?? 15) / 5 }

/// One letter, `p` pixels a dot, from its top-left corner.
private func hawkinsP2Letter(_ c: PixelCanvas, _ x: Int, _ y: Int, _ ch: Character, _ col: Px, _ p: Int) {
    guard let bits = hawkinsP2Glyphs[ch] else { return }
    let w = bits.count / 5
    for (i, b) in bits.enumerated() where b == "1" { c.rect(x + (i % w) * p, y + (i / w) * p, p, p, col) }
}

/// Lettering, `p` pixels a dot, from its top-left corner; a space is three dots.
private func hawkinsP2Sign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    var cx = x
    for ch in text {
        if ch != " " { hawkinsP2Letter(c, cx, y, ch, col, p) }
        cx += ((ch == " " ? 2 : hawkinsP2Width(ch)) + 1) * p
    }
}

/// How wide `text` comes out at `p` pixels a dot.
private func hawkinsP2SignWidth(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + (($1 == " " ? 2 : hawkinsP2Width($1)) + 1) * p } - p
}

// MARK: - The Byers' living room

extension Scenes {
    /// The colours of the Christmas bulbs, round and round the string: red, green, blue, orange, yellow, pink. Unlit
    /// they're dull glass; the moving layer lights them.
    private static let hawkinsBulbs: [(dim: UInt32, lit: UInt32)] = [
        (0x6A2A26, 0xFF5A48), (0x2A5A32, 0x6AF07A), (0x2A3A6A, 0x6A9AFF), (0x7A4A22, 0xFFA040),
        (0x7A6A2A, 0xFFE860), (0x6A2E52, 0xFF80C8),
    ]

    /// Where things stand in the living room: the top of the panelling, the alphabet (each letter's bulb at x, the
    /// string at y, the letter's top under it, and the dot size), the front door, the wall phone, the couch, the TV, the
    /// armchair and the window. In the window's strip the alphabet runs in one line above the crew; on the screen saver
    /// it's in Joyce's three rows, A to H, I to Q and R to Z.
    static func hawkinsByersFrame(_ c: PixelCanvas, _ g: Int)
        -> (rail: Int, letters: [(ch: Character, x: Int, cord: Int, top: Int)], p: Int, door: Int, phone: Int,
            couch: Int, tv: Int, chair: Int, window: Int) {
        let s = unit(g), p = 2 * s, pitch = 11 * s
        let rows = isTall(c) ? ["ABCDEFGH", "IJKLMNOPQ", "RSTUVWXYZ"] : ["ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
        let mid = isTall(c) ? c.w * 55 / 100 : c.w * 58 / 100
        var letters: [(ch: Character, x: Int, cord: Int, top: Int)] = []
        for (r, row) in rows.enumerated() {
            let cord = g - (rows.count == 1 ? 62 : 104 - r * 20) * s
            let x0 = mid - row.count * pitch / 2 + pitch / 2
            for (i, ch) in row.enumerated() {
                // Painted by hand: each letter sits a little off the line.
                let wob = Int(noise(i * 17 + r * 5 + 3) * 3) - 1
                letters.append((ch, x0 + i * pitch, cord, cord + 7 * s + (wob > 0 ? s : 0)))
            }
        }
        return (g - 22 * s, letters, p, c.w * 8 / 100, c.w * 19 / 100, isTall(c) ? c.w * 55 / 100 : c.w * 46 / 100,
                c.w * 72 / 100, c.w * 82 / 100, c.w * 93 / 100)
    }

    /// The Byers' living room at night, November 1983: khaki wallpaper in faint stripes over dark wood panelling, and
    /// Joyce's alphabet painted across it in black house paint, a Christmas bulb hanging over every letter on a string
    /// that sags between them. The front door on the left with its chain, the beige phone on the wall with its long
    /// curly cord, a lamp on a side table, the olive corduroy couch under the letters, the old television in its wooden
    /// cabinet with rabbit ears, Joyce's armchair and the window on the dark woods with its curtains. A brown carpet
    /// along the front. On the screen saver the wall goes up: Will's drawings taped to it, a family photo, more string
    /// swagged along the ceiling and the light in the middle of it.
    static func hawkinsByers(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsByersFrame(c, g), tall = isTall(c)
        // The wallpaper: khaki, in faint stripes with a small dotted figure between them.
        let paper = C(0x8E7C5E), paperD = C(0x84724F), paperL = C(0x9A8868)
        c.rect(0, 0, c.w, f.rail, paper)
        for x in stride(from: 0, to: c.w, by: 8 * s) {
            c.rect(x, 0, s, f.rail, paperD)
            for y in stride(from: 3 * s + (x / (8 * s)) % 2 * 4 * s, to: f.rail - 2 * s, by: 8 * s) { c.rect(x + 4 * s, y, s, s, paperL) }
        }
        // A frieze under the ceiling on the screen saver: a border paper of brown and rust diamonds.
        if tall {
            c.rect(0, 11 * s, c.w, 7 * s, C(0x6A5034)); c.rect(0, 11 * s, c.w, s, C(0x4A3624)); c.rect(0, 17 * s, c.w, s, C(0x4A3624))
            for x in stride(from: 0, to: c.w, by: 8 * s) {
                for d in 0..<3 { c.rect(x + (3 - d) * s, 13 * s + d * s, (2 * d + 2) * s, s, C(0xA05A34)) }
                c.rect(x + 3 * s, 15 * s, 2 * s, s, C(0xC8945A))
            }
        }

        // The panelling: dark boards with grooves, a lit chair rail on top and the skirting at the bottom.
        let wood = C(0x5A3E2A), woodD = C(0x4A3220), groove = C(0x2E1E14)
        c.rect(0, f.rail, c.w, g - f.rail, wood)
        for (i, x) in stride(from: 0, to: c.w, by: 6 * s).enumerated() {
            if i % 4 == 2 { c.rect(x, f.rail, 6 * s, g - f.rail, woodD) }
            c.rect(x, f.rail, s, g - f.rail, groove)
            let gy = f.rail + 4 * s + Int(noise(i * 7 + 2) * Double(max(1, g - f.rail - 12 * s)))
            c.rect(x + 3 * s, gy, s, 4 * s, C(0x664834))
        }
        c.rect(0, f.rail - 2 * s, c.w, 2 * s, C(0x7A563A)); c.rect(0, f.rail - 2 * s, c.w, s, C(0x9A7250)); c.rect(0, f.rail, c.w, s, groove)
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0x3A2818)); c.rect(0, g - 3 * s, c.w, s, C(0x5A402A))

        if tall {
            // The ceiling and its cornice, the light in the middle (lit by the moving layer), and a second string of
            // bulbs swagged along under the cornice, unlit.
            c.rect(0, 0, c.w, 8 * s, C(0x6E6250)); c.rect(0, 8 * s, c.w, 2 * s, C(0xA89878)); c.rect(0, 10 * s, c.w, s, C(0x5E5240))
            let lx = c.w / 2
            c.rect(lx - 9 * s, 8 * s, 18 * s, s, C(0x8A7A5A)); c.ellipse(lx, 11 * s, 8 * s, 3 * s, C(0xD8C8A0))
            c.rect(lx - 8 * s, 8 * s, 16 * s, 2 * s, C(0xB8A880)); c.rect(lx - s, 14 * s, 2 * s, s, C(0x8A7A5A))
            var k = 0
            for x in stride(from: 4 * s, to: c.w - 4 * s, by: 3 * s) {
                let u = (x / s) % 36, sag = Int(sin(Double(u) / 36 * .pi) * 6) * s
                c.rect(x, 12 * s + sag, 3 * s, s, C(0x1E3A22))
                if u % 6 == 0 {
                    let b = hawkinsBulbs[k % hawkinsBulbs.count]
                    c.rect(x, 13 * s + sag, s, s, C(0x1E3A22)); c.rect(x, 14 * s + sag, 2 * s, 3 * s, C(b.dim)); k += 1
                }
            }
            // Will's drawings, taped up: crayon on paper, a monster with its petal face, a house, the vines, a stick-
            // figure Party; a strip of tape at the top of each.
            let drawings: [(x: Int, y: Int, kind: Int)] = [(c.w * 6 / 100, g - 150 * s, 0), (c.w * 15 / 100, g - 136 * s, 1),
                                                           (c.w * 8 / 100, g - 120 * s, 2), (c.w * 88 / 100, g - 146 * s, 3),
                                                           (c.w * 79 / 100, g - 160 * s, 2)]
            for d in drawings where d.y > 22 * s {
                c.rect(d.x, d.y, 16 * s, 12 * s, C(0xE8E2D0)); c.rect(d.x + 15 * s, d.y + s, s, 11 * s, C(0xC8C0AC))
                c.rect(d.x + 5 * s, d.y - s, 6 * s, 2 * s, C(0xD8D0A8, 0.9))
                switch d.kind {
                case 0:   // the monster, its face opened like a flower
                    c.rect(d.x + 7 * s, d.y + 5 * s, 2 * s, 6 * s, C(0x3A3A3A)); c.rect(d.x + 5 * s, d.y + 7 * s, 6 * s, s, C(0x3A3A3A))
                    for (dx, dy) in [(-2, -1), (2, -1), (0, -3), (-2, 1), (2, 1)] { c.rect(d.x + (7 + dx) * s, d.y + (3 + dy) * s, 2 * s, 2 * s, C(0xC03A3A)) }
                case 1:   // the house with smoke
                    c.rect(d.x + 4 * s, d.y + 6 * s, 8 * s, 5 * s, C(0x3A6AC0)); c.rect(d.x + 3 * s, d.y + 4 * s, 10 * s, 2 * s, C(0xC03A3A))
                    c.rect(d.x + 7 * s, d.y + 8 * s, 2 * s, 3 * s, C(0x6A4A2A)); c.rect(d.x + 10 * s, d.y + 2 * s, s, 2 * s, C(0x7A7A7A))
                case 2:   // the vines, all over the page
                    for k in 0..<5 { c.rect(d.x + (1 + k * 3) * s, d.y + (2 + k % 3 * 3) * s, 3 * s, s, C(0x2A2A2E)); c.rect(d.x + (2 + k * 3) * s, d.y + (3 + k % 2 * 4) * s, s, 3 * s, C(0x2A2A2E)) }
                default:  // the Party, four stick figures and the sun
                    for k in 0..<4 { c.rect(d.x + (2 + k * 3) * s, d.y + 6 * s, s, 4 * s, C(0x2A2A2E)); c.rect(d.x + (2 + k * 3) * s, d.y + 5 * s, s, s, [C(0xC03A3A), C(0x3A6AC0), C(0x3A9A4A), C(0xD8A030)][k]) }
                    c.rect(d.x + 12 * s, d.y + 2 * s, 2 * s, 2 * s, C(0xF0C030))
                }
            }
            // Where Joyce took the axe to the wall: a ragged hole through the paper and plaster, the laths showing,
            // and only dark behind.
            let hx0 = c.w * 13 / 100, hy0 = g - 196 * s
            if hy0 > 30 * s {
                for y in -14..<15 {
                    let half = Int((1 - Double(y * y) / 225).squareRoot() * 11 + (noise(y + 90) - 0.5) * 4)
                    c.rect(hx0 - (half + 2) * s, hy0 + y * s, (2 * half + 4) * s, s, C(0xC8BCA0))
                    c.rect(hx0 - half * s, hy0 + y * s, 2 * half * s, s, C(0x0E0C0C))
                }
                for k in 0..<4 { c.rect(hx0 - 11 * s, hy0 + (-9 + k * 6) * s, 22 * s, 2 * s, C(0x7A5A3A)); c.rect(hx0 - 11 * s, hy0 + (-9 + k * 6) * s, 22 * s, s, C(0x9A7650)) }
                for y in -12..<13 where abs(y) > 0 {
                    let half = Int((1 - Double(y * y) / 225).squareRoot() * 11 + (noise(y + 90) - 0.5) * 4)
                    if y % 6 != 0 { c.rect(hx0 - half * s + 2 * s, hy0 + y * s, s, s, C(0x0E0C0C)); c.rect(hx0 + half * s - 3 * s, hy0 + y * s, s, s, C(0x0E0C0C)) }
                }
            }
            // A family photo in a frame, a mirror, a little shelf with a vase and a plant, and the clock.
            let px0 = c.w * 22 / 100, py = g - 96 * s
            c.rect(px0, py, 16 * s, 12 * s, C(0x5A3A22)); c.rect(px0 + 2 * s, py + 2 * s, 12 * s, 8 * s, C(0x6A8AA0))
            c.rect(px0 + 2 * s, py + 7 * s, 12 * s, 3 * s, C(0x5A7A4A))
            for (k, col) in [C(0x6A4A3A), C(0x3A3A4A), C(0x8A6A4A)].enumerated() { c.rect(px0 + (4 + k * 3) * s, py + 4 * s + (k == 1 ? s : 0), 2 * s, 5 * s - (k == 1 ? s : 0), col) }
            c.rect(px0, py, 16 * s, s, C(0x7A5A3A))
            let mx = c.w * 30 / 100, my = g - 130 * s
            c.ellipse(mx, my, 9 * s, 12 * s, C(0xB89A50)); c.ellipse(mx, my, 7 * s, 10 * s, C(0x9AAAB0))
            c.rect(mx - 4 * s, my - 6 * s, 2 * s, 7 * s, C(0xC8D4DA)); c.ellipse(mx, my + 7 * s, 6 * s, 2 * s, C(0x8A9AA0))
            let shx = c.w * 86 / 100, shy = g - 104 * s
            c.rect(shx - 14 * s, shy, 28 * s, 2 * s, C(0x7A563A)); c.rect(shx - 14 * s, shy, 28 * s, s, C(0x9A7250))
            c.rect(shx - 12 * s, shy + 2 * s, s, 3 * s, C(0x5A3A22)); c.rect(shx + 11 * s, shy + 2 * s, s, 3 * s, C(0x5A3A22))
            c.rect(shx - 8 * s, shy - 6 * s, 4 * s, 6 * s, C(0x3A6A8A)); c.rect(shx - 7 * s, shy - 9 * s, 2 * s, 3 * s, C(0x3A6A8A))
            c.rect(shx - 8 * s, shy - 6 * s, s, 6 * s, C(0x5A8AAA))
            c.rect(shx + 2 * s, shy - 4 * s, 6 * s, 4 * s, C(0xA85A3A)); c.rect(shx + 2 * s, shy - 4 * s, 6 * s, s, C(0xC87A50))
            for (dx, dy) in [(1, -6), (4, -8), (7, -6), (3, -5), (6, -9)] { c.rect(shx + (2 + dx) * s, shy + dy * s, s, 3 * s, C(0x3A7A3A)) }
            let clx = c.w * 70 / 100, cly = g - 142 * s
            c.circle(clx, cly, 7 * s, C(0x6A4628)); c.circle(clx, cly, 6 * s, C(0xE8E0C8))
            for k in 0..<12 { let r = Double(k) * .pi / 6; c.px(clx + Int(cos(r) * 5 * Double(s)), cly + Int(sin(r) * 5 * Double(s)), C(0x3A3A3A)) }
            c.rect(clx, cly - 4 * s, s, 4 * s, C(0x1E1E1E)); c.rect(clx, cly, 3 * s, s, C(0x1E1E1E))
            // Strings dropped straight down from the ceiling swag here and there, a bulb every few pixels.
            for (k, dx) in [c.w * 3 / 100, c.w * 40 / 100, c.w * 64 / 100, c.w * 98 / 100].enumerated() {
                let len = (40 + k % 2 * 30) * s
                for y in stride(from: 18 * s, to: min(18 * s + len, g - 120 * s), by: s) {
                    c.rect(dx, y, s, s, C(0x1E3A22))
                    if (y / s) % 7 == 0 { c.rect(dx + s, y, 2 * s, 3 * s, C(hawkinsBulbs[(y / s / 7 + k) % hawkinsBulbs.count].dim)) }
                }
            }
            // More strings of lights, swagged across the wall the way Joyce strung them all over the house, unlit.
            for (k, run) in [(y: g - 170 * s, x0: c.w * 4 / 100, x1: c.w * 48 / 100), (y: g - 122 * s, x0: c.w * 62 / 100, x1: c.w * 97 / 100),
                             (y: g - 186 * s, x0: c.w * 54 / 100, x1: c.w * 96 / 100), (y: g - 76 * s, x0: c.w * 2 / 100, x1: c.w * 20 / 100)].enumerated()
                where run.y > 20 * s {
                var n = 0
                for x in stride(from: run.x0, to: run.x1, by: s) {
                    let u = Double((x - run.x0) % (30 * s)) / Double(30 * s), sag = Int(sin(u * .pi) * 5) * s
                    c.rect(x, run.y + sag, s, s, C(0x1E3A22))
                    if (x - run.x0) % (6 * s) == 0 {
                        c.rect(x, run.y + sag + s, 2 * s, 3 * s, C(hawkinsBulbs[(n + k) % hawkinsBulbs.count].dim)); n += 1
                    }
                }
            }
        }

        // The alphabet: the string sagging between the bulbs, each bulb on its socket, and the letter painted under it,
        // black house paint with a drip or two.
        let paint = C(0x18140F), cordC = C(0x1E3A22)
        for (i, l) in f.letters.enumerated() {
            let next = i + 1 < f.letters.count && f.letters[i + 1].cord == l.cord ? f.letters[i + 1].x : nil
            if let nx = next {
                for x in l.x..<nx {
                    let u = Double(x - l.x) / Double(nx - l.x)
                    c.rect(x, l.cord + Int(sin(u * .pi) * 2.4) * s, 1, s, cordC)
                }
            }
            let b = hawkinsBulbs[i % hawkinsBulbs.count]
            c.rect(l.x - s / 2, l.cord, s, 2 * s, C(0x14281A))
            c.rect(l.x - s, l.cord + 2 * s, 2 * s, 3 * s, C(b.dim)); c.px(l.x - s, l.cord + 2 * s, lerp(C(b.dim), C(0xFFFFFF), 0.25))
            let w = hawkinsP2Width(l.ch) * f.p
            hawkinsP2Letter(c, l.x - w / 2, l.top, l.ch, paint, f.p)
            if noise(i * 29 + 7) > 0.82 { c.rect(l.x - w / 2 + (i % 3) * f.p, l.top + 5 * f.p, s, (1 + i % 3) * s, paint) }
        }
        // Each row's string trails off to the left, drooping, as if it ran on round the room.
        for (i, l) in f.letters.enumerated() where i == 0 || f.letters[i - 1].cord != l.cord {
            for k in 0..<(14 * s) { c.rect(l.x - k - s, l.cord + Int(sin(Double(k) / Double(14 * s) * .pi * 0.8) * 3) * s, 1, s, cordC) }
        }

        // The front door: four panels, a brass knob, the chain, a coat on a hook beside it.
        let dx = f.door, dw = 18 * s, dh = 34 * s
        c.rect(dx - s, g - dh - s, dw + 2 * s, dh + s, C(0x3A2818))
        c.rect(dx, g - dh, dw, dh, C(0x6A4A30)); c.rect(dx, g - dh, s, dh, C(0x8A6444)); c.rect(dx + dw - s, g - dh, s, dh, C(0x4A3220))
        for (py, ph) in [(g - dh + 3 * s, 12 * s), (g - dh + 18 * s, 13 * s)] {
            for px0 in [dx + 2 * s, dx + 10 * s] {
                c.rect(px0, py, 6 * s, ph, C(0x5A3E28)); c.rect(px0, py, 6 * s, s, C(0x4A3220)); c.rect(px0, py + ph - s, 6 * s, s, C(0x7A583C))
            }
        }
        c.rect(dx + 14 * s, g - 17 * s, 2 * s, 2 * s, C(0xD8B048)); c.px(dx + 14 * s, g - 17 * s, C(0xF8E080))
        for k in 0..<4 { c.rect(dx + 11 * s + k * s, g - 22 * s + (k % 2) * s, s, s, C(0xB8B8C0)) }
        let hx = dx + dw + 5 * s
        c.rect(hx, g - 31 * s, 2 * s, s, C(0x8A8A90))
        c.rect(hx - 2 * s, g - 30 * s, 6 * s, 14 * s, C(0x5A6A3A)); c.rect(hx - 2 * s, g - 30 * s, s, 14 * s, C(0x6E8048))
        c.rect(hx + 3 * s, g - 28 * s, s, 12 * s, C(0x44522C)); c.rect(hx - s, g - 30 * s, 4 * s, 2 * s, C(0x8A7A5A))

        // The wall phone: almond plastic, the handset hung down its left side, the dial in the middle, and the long
        // curly cord looping down from the handset almost to the floor.
        let ph = f.phone, py0 = g - 34 * s
        let almond = C(0xD8C8A0), almondD = C(0xA89870), almondL = C(0xEEE2C2)
        c.rect(ph - 2 * s, py0, 8 * s, 13 * s, almond); c.rect(ph - 2 * s, py0, 8 * s, s, almondL); c.rect(ph + 5 * s, py0, s, 13 * s, almondD)
        c.rect(ph - 2 * s, py0 + 12 * s, 8 * s, s, almondD)
        c.circle(ph + 2 * s, py0 + 6 * s, 3 * s, C(0xC0B088)); c.circle(ph + 2 * s, py0 + 6 * s, s, C(0x8A7A58))
        for a2 in 0..<8 { let r = Double(a2) * .pi / 4.5 - 1; c.px(ph + 2 * s + Int(cos(r) * 2.4 * Double(s)), py0 + 6 * s + Int(sin(r) * 2.4 * Double(s)), C(0x6A5E44)) }
        c.rect(ph - 5 * s, py0 - s, 3 * s, 4 * s, almond); c.rect(ph - 5 * s, py0 - s, s, 4 * s, almondL)
        c.rect(ph - 4 * s, py0 + 3 * s, 2 * s, 8 * s, almond); c.rect(ph - 5 * s, py0 + 11 * s, 3 * s, 4 * s, almond)
        c.rect(ph - 5 * s, py0 + 11 * s, s, 4 * s, almondL); c.rect(ph - 3 * s, py0 - s, s, 16 * s, almondD)
        for k in 0..<16 {
            let cx = ph - 4 * s + Int(sin(Double(k) * 1.9) * 1.6 * Double(s)) + k * s / 4, cy = py0 + 15 * s + k * s
            if cy < g - 4 * s { c.rect(cx, cy, 2 * s, s, k % 2 == 0 ? C(0xC8B890) : C(0xA89870)) }
        }

        // The side table and its lamp, the shade lit by the moving layer.
        let tx = f.couch - 40 * s
        c.rect(tx - 7 * s, g - 12 * s, 14 * s, 2 * s, C(0x7A5232)); c.rect(tx - 7 * s, g - 12 * s, 14 * s, s, C(0x9A6E44))
        c.rect(tx - 6 * s, g - 10 * s, s, 10 * s, C(0x5A3A22)); c.rect(tx + 5 * s, g - 10 * s, s, 10 * s, C(0x5A3A22))
        c.rect(tx - 6 * s, g - 5 * s, 12 * s, s, C(0x5A3A22))
        c.rect(tx - 2 * s, g - 17 * s, 4 * s, 5 * s, C(0x8A6A3A)); c.rect(tx - 2 * s, g - 17 * s, s, 5 * s, C(0xA88A50))
        c.rect(tx - s / 2, g - 19 * s, s, 2 * s, C(0x6A5A3A))

        // The couch: olive corduroy in ribs, two back cushions and two seat cushions, square arms, a crocheted cushion.
        let cw = 50 * s, cx = f.couch - cw / 2
        let fab = C(0x6A6A3A), fabD = C(0x52522C), fabL = C(0x828248)
        c.rect(cx - 2 * s, g - 10 * s, cw + 4 * s, 8 * s, fabD)
        for k in 0..<2 {
            let bx = cx + k * cw / 2
            c.rect(bx + s, g - 20 * s, cw / 2 - 2 * s, 11 * s, fab); c.rect(bx + 2 * s, g - 20 * s, cw / 2 - 4 * s, s, fabL)
            for x in stride(from: bx + 3 * s, to: bx + cw / 2 - 2 * s, by: 3 * s) { c.rect(x, g - 18 * s, s, 8 * s, fabD) }
            c.rect(bx + s, g - 9 * s, cw / 2 - 2 * s, 5 * s, fab); c.rect(bx + s, g - 9 * s, cw / 2 - 2 * s, s, fabL)
            c.rect(bx + s, g - 5 * s, cw / 2 - 2 * s, s, fabD)
        }
        for (ax, lit) in [(cx - 6 * s, true), (cx + cw, false)] {
            c.rect(ax, g - 14 * s, 6 * s, 12 * s, fab); c.rect(ax, g - 14 * s, 6 * s, s, fabL)
            c.rect(lit ? ax : ax + 5 * s, g - 13 * s, s, 11 * s, lit ? fabL : fabD)
        }
        c.rect(cx - 6 * s, g - 2 * s, cw + 12 * s, s, C(0x2E2414))
        for fx in [cx - 5 * s, cx + cw + 3 * s] { c.rect(fx, g - s, 2 * s, s, C(0x2A1A10)) }
        let pil = cx + 4 * s
        c.rect(pil, g - 14 * s, 8 * s, 6 * s, C(0xC86A3A)); c.rect(pil, g - 14 * s, 8 * s, s, C(0xE08A50))
        for k in 0..<3 { c.rect(pil + (1 + k * 3) * s, g - 12 * s, s, s, C(0xF0C060)) }

        // The television: a wooden cabinet on short legs, the dark screen with its glare, the knobs and the speaker
        // cloth, rabbit ears on top and a framed photo beside them.
        let tvx = f.tv, tw = 30 * s, tvTop = g - 26 * s
        c.rect(tvx - tw / 2, tvTop, tw, 23 * s, C(0x6A4628)); c.rect(tvx - tw / 2, tvTop, tw, s, C(0x8A603A)); c.rect(tvx + tw / 2 - s, tvTop, s, 23 * s, C(0x4A3018))
        c.rect(tvx - tw / 2 + 2 * s, tvTop + 3 * s, 18 * s, 14 * s, C(0x1A1E1C)); c.rect(tvx - tw / 2 + 3 * s, tvTop + 4 * s, 16 * s, 12 * s, C(0x2A3430))
        c.rect(tvx - tw / 2 + 4 * s, tvTop + 5 * s, 4 * s, s, C(0x4A5A54)); c.rect(tvx - tw / 2 + 4 * s, tvTop + 6 * s, s, 3 * s, C(0x4A5A54))
        for k in 0..<2 { c.circle(tvx + 9 * s, tvTop + (6 + k * 5) * s, s, C(0xC8C0A8)) }
        for y in stride(from: tvTop + 14 * s, to: tvTop + 18 * s, by: s) { c.rect(tvx + 6 * s, y, 7 * s, s, y / s % 2 == 0 ? C(0x3A2A1A) : C(0x5A4228)) }
        c.rect(tvx - tw / 2 + 2 * s, g - 3 * s, 2 * s, 3 * s, C(0x3A2818)); c.rect(tvx + tw / 2 - 4 * s, g - 3 * s, 2 * s, 3 * s, C(0x3A2818))
        c.rect(tvx - 4 * s, tvTop - 2 * s, 8 * s, 2 * s, C(0x2A2A2E))
        for k in 0..<9 { c.px(tvx - 2 * s - k * s, tvTop - 3 * s - k * s, C(0xB8B8C0)); c.px(tvx + 2 * s + k * s * 2 / 3, tvTop - 3 * s - k * s, C(0xB8B8C0)) }
        c.rect(tvx + 7 * s, tvTop - 7 * s, 6 * s, 7 * s, C(0xC8A84A)); c.rect(tvx + 8 * s, tvTop - 6 * s, 4 * s, 5 * s, C(0x7A9AB0))
        c.rect(tvx + 9 * s, tvTop - 4 * s, 2 * s, 3 * s, C(0x6A4A3A))

        // Joyce's armchair: worn brown velour, a high back, turned to the room.
        let ax = f.chair
        c.rect(ax - 8 * s, g - 24 * s, 16 * s, 16 * s, C(0x7A4A30)); c.rect(ax - 8 * s, g - 24 * s, 16 * s, s, C(0x9A6444))
        c.rect(ax - 7 * s, g - 23 * s, 2 * s, 14 * s, C(0x8A5838)); c.rect(ax + 6 * s, g - 23 * s, 2 * s, 14 * s, C(0x5E3622))
        c.rect(ax - 10 * s, g - 12 * s, 20 * s, 9 * s, C(0x7A4A30)); c.rect(ax - 10 * s, g - 12 * s, 20 * s, s, C(0x9A6444))
        c.rect(ax - 10 * s, g - 12 * s, 3 * s, 9 * s, C(0x8A5838)); c.rect(ax + 7 * s, g - 12 * s, 3 * s, 9 * s, C(0x5E3622))
        c.rect(ax - 10 * s, g - 3 * s, 20 * s, s, C(0x3A2214))
        c.rect(ax - 9 * s, g - 2 * s, 2 * s, 2 * s, C(0x2A1A10)); c.rect(ax + 7 * s, g - 2 * s, 2 * s, 2 * s, C(0x2A1A10))

        // The window on the woods at night: the frame, the dark trees and a little moonlight, curtains either side.
        let wx = f.window, wy = g - 48 * s, ww = 22 * s, wh = 24 * s
        c.rect(wx - ww / 2 - 2 * s, wy - 2 * s, ww + 4 * s, wh + 4 * s, C(0xC8BCA0))
        c.rect(wx - ww / 2, wy, ww, wh, C(0x141C2C)); c.rect(wx - ww / 2, wy, ww, 6 * s, C(0x1C2840))
        for k in 0..<(ww / (3 * s)) {
            let th = (8 + Int(noise(k * 5 + 41) * 10)) * s, tx2 = wx - ww / 2 + k * 3 * s + s
            for r in 0..<(th / s) { let half = r / 3; c.rect(tx2 - half * s / 2, wy + wh - th + r * s, max(s, half * s + s), s, C(0x0E1A14)) }
        }
        c.circle(wx + 6 * s, wy + 4 * s, s, C(0xC8D0D8))
        c.rect(wx - s / 2, wy, max(1, s), wh, C(0xC8BCA0)); c.rect(wx - ww / 2, wy + wh / 2, ww, s, C(0xC8BCA0))
        c.rect(wx - ww / 2 - 3 * s, wy + wh + 2 * s, ww + 6 * s, 2 * s, C(0xD8CCB0)); c.rect(wx - ww / 2 - 3 * s, wy + wh + 3 * s, ww + 6 * s, s, C(0x8A7E64))
        for (cx0, dir) in [(wx - ww / 2 - 4 * s, 1), (wx + ww / 2 - 2 * s, -1)] {
            c.rect(cx0, wy - 3 * s, 6 * s, wh + 9 * s, C(0x8A3A2A))
            for k in 0..<3 { c.rect(cx0 + (dir > 0 ? k * 2 : 4 - k * 2) * s, wy - 3 * s, s, wh + 9 * s, k == 1 ? C(0xA84A36) : C(0x6A2A1E)) }
        }
        c.rect(wx - ww / 2 - 6 * s, wy - 4 * s, ww + 12 * s, s, C(0x6A5A3A))
        // Lights strung round the window too, unlit.
        for k in 0..<7 {
            let bx = wx - ww / 2 - 2 * s + k * (ww + 4 * s) / 6, by = wy - 3 * s + (k % 2) * s
            c.rect(bx, by, 2 * s, 2 * s, C(hawkinsBulbs[(k + 2) % hawkinsBulbs.count].dim))
        }

        // The carpet: brown and plain, a lit edge where it meets the skirting.
        c.ground(g, C(0x4E3C2E), edge: C(0x6A5240), speck: C(0x44342A), seed: 21)
    }

    /// When each letter lights: the lights spell RIGHT HERE, then RUN, a letter at a time, each held a moment with a
    /// short dark gap between letters and a longer one between the words, then a rest before it starts again.
    static func hawkinsByersLit(_ t: Double) -> Character? {
        let words = ["RIGHT", "HERE", "RUN"]
        let on = 0.55, off = 0.2, word = 1.4, rest = 3.5
        let length = words.reduce(0) { $0 + Double($1.count) * (on + off) + word } + rest
        var u = t.truncatingRemainder(dividingBy: length)
        for w in words {
            for ch in w {
                if u < on { return ch }
                if u < on + off { return nil }
                u -= on + off
            }
            if u < word { return nil }
            u -= word
        }
        return nil
    }

    /// The living room's life: the bulb over each letter of the message lighting up in turn, with a soft glow on the
    /// wallpaper round it, and the lamp on the side table burning steady. On the screen saver the ceiling light glows.
    static func hawkinsByersLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsByersFrame(c, g)
        if let ch = hawkinsByersLit(t), let i = f.letters.firstIndex(where: { $0.ch == ch }) {
            let l = f.letters[i], b = hawkinsBulbs[i % hawkinsBulbs.count]
            for (r, a) in [(10, 0.08), (7, 0.13), (4, 0.2)] { c.circle(l.x, l.cord + 3 * s, r * s, C(b.lit, a)) }
            c.rect(l.x - s, l.cord + 2 * s, 2 * s, 3 * s, C(b.lit)); c.px(l.x - s, l.cord + 2 * s, C(0xFFFFFF))
            c.px(l.x, l.cord + 3 * s, lerp(C(b.lit), C(0xFFFFFF), 0.5))
        }
        let tx = f.couch - 40 * s
        for (r, a) in [(10, 0.04), (6, 0.06)] { c.circle(tx, g - 20 * s, r * s, C(0xFFD890, a)) }
        for k in 0..<4 { let half = 3 * s + k * s / 2; c.rect(tx - half, g - 23 * s + k * s, 2 * half, s, k == 3 ? C(0xE0C890) : C(0xF4E4BC)) }
        if isTall(c) {
            for (r, a) in [(16, 0.04), (10, 0.06)] { c.circle(c.w / 2, 12 * s, r * s, C(0xFFE8B0, a)) }
        }
    }
}

// MARK: - Hawkins National Laboratory

extension Scenes {
    /// Where things stand in the Lab: the corridor's mouth (left edge, width, height), the RESTRICTED sign's middle and
    /// top, the steel door, the Gate's middle and its top (it reaches well above the window's strip), and the wall lamps.
    static func hawkinsLabFrame(_ c: PixelCanvas, _ g: Int)
        -> (corridor: (x: Int, w: Int, h: Int), sign: (x: Int, y: Int), door: Int, gate: (x: Int, top: Int), lamps: [Int]) {
        let s = unit(g)
        return ((x: c.w * 15 / 100, w: 52 * s, h: 42 * s), (x: c.w * 47 / 100, y: g - 58 * s), c.w * 5 / 100,
                (x: c.w * 77 / 100, top: isTall(c) ? max(56 * s, g - 200 * s) : g - 92 * s), [c.w * 38 / 100, c.w * 57 / 100, c.w * 95 / 100])
    }

    /// Hawkins National Laboratory, deep inside: a high concrete hall in cast panels with green-grey tiles round its
    /// foot, the steel door with its wired window, and the mouth of a long cold corridor going back under its
    /// fluorescent tubes to a door at the far end. A RESTRICTED sign over the way through, a camera on its bracket, a
    /// fire extinguisher, a trolley with a monitor and an oscilloscope; and on the right the Gate: a tall glowing rip
    /// in the wall, red-orange at its heart, its fleshy lips ringed with tendrils that creep across the concrete, a
    /// railing and floodlights on stands in front of it. Dark grey linoleum along the front. On the screen saver the
    /// hall goes higher: the Gate climbs the wall, a steel gantry crosses it and the observation room's window looks
    /// down from the left.
    static func hawkinsLab(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsLabFrame(c, g), tall = isTall(c)
        // The hall's concrete, cast in panels with a seam and tie holes, a little stained.
        let conc = C(0x6A7072), concD = C(0x5E6466), concL = C(0x767C7E)
        c.rect(0, 0, c.w, g, conc)
        let pw = 40 * s, phh = 30 * s
        for y in stride(from: g - 22 * s, to: -phh, by: -phh) {
            c.rect(0, y, c.w, s, concD)
            for x in stride(from: (y / phh) % 2 * pw / 2, to: c.w, by: pw) {
                c.rect(x, y - phh, s, phh, concD)
                for (hx, hy) in [(8, 8), (pw / s - 8, 8), (8, phh / s - 8), (pw / s - 8, phh / s - 8)] { c.rect(x + hx * s, y - hy * s, s, s, C(0x4E5456)) }
                c.rect(x + s, y - phh + s, pw - 2 * s, s, concL)
                if noise(x / s + y) > 0.6 { c.rect(x + 14 * s, y - phh + 2 * s, s, Int(noise(x + 3) * 14 + 4) * s, C(0x62686A)) }
            }
        }
        // The tiles round the foot of the walls: green-grey squares, the grout between them, a darker cove at the floor.
        let tileTop = g - 22 * s
        c.rect(0, tileTop, c.w, 22 * s, C(0x7A8A80))
        for y in stride(from: tileTop, to: g, by: 4 * s) { c.rect(0, y, c.w, s, C(0x5E6A62)) }
        for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, tileTop, s, 22 * s, C(0x5E6A62)) }
        c.rect(0, tileTop - s, c.w, 2 * s, C(0x8A9A90)); c.rect(0, g - 2 * s, c.w, 2 * s, C(0x3A4440))
        // A pair of pipes along the wall, on brackets, with a valve wheel.
        let pipeY = g - 50 * s
        c.rect(0, pipeY, c.w, 2 * s, C(0x7A8088)); c.rect(0, pipeY, c.w, s, C(0x9AA0A8)); c.rect(0, pipeY + 2 * s, c.w, s, C(0x4A4E54))
        c.rect(0, pipeY + 4 * s, c.w, s, C(0x8A6A3A)); c.rect(0, pipeY + 5 * s, c.w, s, C(0x5A4428))
        for x in stride(from: 26 * s, to: c.w, by: 44 * s) { c.rect(x, pipeY - s, 2 * s, 7 * s, C(0x4A4E54)) }
        c.circle(c.w * 62 / 100, pipeY + s, 3 * s, C(0xA8302A)); c.circle(c.w * 62 / 100, pipeY + s, 2 * s, C(0x7A8088)); c.rect(c.w * 62 / 100, pipeY + s, s, s, C(0xA8302A))

        // The wall lamps: caged bulkhead lights (lit by the moving layer).
        for lx in f.lamps {
            c.rect(lx - 4 * s, g - 44 * s, 8 * s, 5 * s, C(0x3A3E42)); c.rect(lx - 3 * s, g - 43 * s, 6 * s, 3 * s, C(0x8A9090))
            for k in 0..<3 { c.rect(lx - 3 * s + k * 2 * s, g - 43 * s, s, 3 * s, C(0x2A2E32)) }
        }

        // The steel door: grey, a wired-glass window, a push bar, B-4 stencilled over it.
        let dx = f.door, dw = 18 * s, dh = 34 * s
        c.rect(dx - 2 * s, g - dh - 2 * s, dw + 4 * s, dh + 2 * s, C(0x3A4044))
        c.rect(dx, g - dh, dw, dh, C(0x7A8490)); c.rect(dx, g - dh, s, dh, C(0x9AA4B0)); c.rect(dx + dw - s, g - dh, s, dh, C(0x5A646E))
        c.rect(dx + 4 * s, g - dh + 4 * s, 10 * s, 8 * s, C(0x2A3A44)); c.rect(dx + 4 * s, g - dh + 4 * s, 10 * s, s, C(0x3A4E5A))
        for k in 1..<4 { c.rect(dx + 4 * s + k * 5 * s / 2, g - dh + 4 * s, 1, 8 * s, C(0x6A7A84, 0.6)); c.rect(dx + 4 * s, g - dh + 4 * s + k * 2 * s, 10 * s, 1, C(0x6A7A84, 0.6)) }
        c.rect(dx + 2 * s, g - 17 * s, 14 * s, 2 * s, C(0xB8C0C8)); c.rect(dx + 2 * s, g - 15 * s, 14 * s, s, C(0x4A545E))
        hawkinsP2Sign(c, dx + 3 * s, g - dh - 9 * s, "B", C(0x2A2E32), s)
        c.rect(dx + 7 * s, g - dh - 7 * s, 2 * s, s, C(0x2A2E32))
        c.rect(dx + 10 * s, g - dh - 9 * s, s, 3 * s, C(0x2A2E32)); c.rect(dx + 10 * s, g - dh - 7 * s, 3 * s, s, C(0x2A2E32)); c.rect(dx + 12 * s, g - dh - 9 * s, s, 5 * s, C(0x2A2E32))

        // The corridor going back: its walls, ceiling and floor drawn closing in towards the far door, darker with
        // distance, its tubes along the ceiling and doors along the walls.
        let o = f.corridor, ox = o.x, ow = o.w, oy = g - o.h
        let ix = ox + ow * 40 / 100, iw = ow * 20 / 100, iy = oy + o.h * 34 / 100, ih = o.h * 30 / 100
        for y in oy..<g {
            for x in ox..<(ox + ow) {
                var plane = 4, d = 1.0
                if x < ix { let k = Double(x - ox) / Double(ix - ox); if k < d { d = k; plane = 0 } }
                if x >= ix + iw { let k = Double(ox + ow - 1 - x) / Double(ox + ow - ix - iw); if k < d { d = k; plane = 1 } }
                if y < iy { let k = Double(y - oy) / Double(iy - oy); if k < d { d = k; plane = 2 } }
                if y >= iy + ih { let k = Double(g - 1 - y) / Double(g - iy - ih); if k < d { d = k; plane = 3 } }
                let far = d * 0.55
                var col: Px
                switch plane {
                case 0: col = lerp(C(0x8A9A90), C(0x3A4440), far)
                case 1: col = lerp(C(0x6E7E74), C(0x2E3834), far)
                case 2: col = lerp(C(0xA8B0AC), C(0x4A5250), far)
                case 3: col = lerp(C(0x4E5456), C(0x262A2C), far)
                default: col = C(0x3A4248)
                }
                // Doors set into the side walls, a stretch each, the lower part of the wall.
                if plane < 2, [0.18, 0.5].contains(where: { d > $0 && d < $0 + 0.14 }), y > oy + Int(Double(o.h) * (0.2 + d * 0.25)) {
                    col = lerp(C(0x5A6A78), C(0x2A323A), far)
                }
                // The tubes down the middle of the ceiling.
                if plane == 2, [0.12, 0.38, 0.62, 0.84].contains(where: { abs(d - $0) < 0.045 }), abs(x - (ix + iw / 2)) < Int(Double(iw) * 0.4 + Double(ow) * 0.2 * (1 - d)) {
                    col = lerp(C(0xC8D4CC), C(0x8A948E), far)
                }
                // A dark strip along the foot of each wall.
                if plane == 3, x < ix + iw / 2 ? Double(x - ox) / Double(ix - ox) - d < 0.06 : Double(ox + ow - 1 - x) / Double(ox + ow - ix - iw) - d < 0.06 {
                    col = lerp(col, C(0x1A1E20), 0.4)
                }
                c.px(x, y, col)
            }
        }
        // The far door, and the frame round the corridor's mouth.
        c.rect(ix + iw / 4, iy + ih / 4, iw / 2, ih * 3 / 4, C(0x5A6A78)); c.rect(ix + iw / 4, iy + ih / 4, iw / 2, max(1, s), C(0x7A8A98))
        c.rect(ix + iw / 4 + iw / 6, iy + ih / 3, iw / 6, max(1, ih / 6), C(0x8AA0A8))
        c.rect(ox - 3 * s, oy - 3 * s, ow + 6 * s, 3 * s, C(0x4E5456)); c.rect(ox - 3 * s, oy - 3 * s, ow + 6 * s, s, C(0x7A8082))
        c.rect(ox - 3 * s, oy, 3 * s, o.h, C(0x4E5456)); c.rect(ox + ow, oy, 3 * s, o.h, C(0x3A4042)); c.rect(ox - 3 * s, oy, s, o.h, C(0x7A8082))
        // Yellow and black hazard stripes up the mouth's sides.
        for y in stride(from: oy, to: g, by: 4 * s) {
            c.rect(ox - 2 * s, y, 2 * s, 2 * s, C(0xD8B030)); c.rect(ox + ow + s, y + 2 * s, 2 * s, 2 * s, C(0xD8B030))
        }

        // The RESTRICTED sign: white, a red band along the top, red lettering, screwed to the concrete.
        let text = "RESTRICTED", p = 2 * s, tw = hawkinsP2SignWidth(text, p)
        let sx = f.sign.x - tw / 2 - 5 * s, sy = f.sign.y, sw = tw + 10 * s
        c.rect(sx + s, sy + s, sw, 18 * s, C(0x4A5052))
        c.rect(sx, sy, sw, 18 * s, C(0xE8E8E2)); c.rect(sx, sy, sw, 3 * s, C(0xB82A26)); c.rect(sx, sy + 17 * s, sw, s, C(0xB8B8B0))
        hawkinsP2Sign(c, sx + 5 * s, sy + 5 * s, text, C(0xB82A26), p)
        for (k, bx) in [sx + s, sx + sw - 2 * s].enumerated() { c.rect(bx, sy + 4 * s + k * 0, s, s, C(0x8A8A84)); c.rect(bx, sy + 15 * s, s, s, C(0x8A8A84)) }

        // The camera on its bracket, high by the sign, looking down at the hall.
        let camX = f.sign.x + tw / 2 + 16 * s, camY = g - 60 * s
        c.rect(camX, camY, 2 * s, 6 * s, C(0x3A3E42)); c.rect(camX - 8 * s, camY + 4 * s, 10 * s, 5 * s, C(0xC8CCD0))
        c.rect(camX - 8 * s, camY + 4 * s, 10 * s, s, C(0xE0E4E8)); c.rect(camX - 10 * s, camY + 5 * s, 2 * s, 3 * s, C(0x1A1E22))
        c.rect(camX - 8 * s, camY + 8 * s, 10 * s, s, C(0x8A8E92))

        // The fire extinguisher on the tiles, and the trolley with its monitor and oscilloscope.
        let ex = c.w * 39 / 100
        c.rect(ex, g - 13 * s, 5 * s, 10 * s, C(0xB82A26)); c.rect(ex, g - 13 * s, s, 10 * s, C(0xD84A3E)); c.rect(ex + 4 * s, g - 13 * s, s, 10 * s, C(0x8A1E1A))
        c.rect(ex + s, g - 15 * s, 3 * s, 2 * s, C(0x2A2A2E)); c.rect(ex + 4 * s, g - 15 * s, 3 * s, s, C(0x2A2A2E)); c.rect(ex + 6 * s, g - 15 * s, s, 6 * s, C(0x2A2A2E))
        c.rect(ex - s, g - 3 * s, 7 * s, s, C(0x4A4E54))
        let tx = c.w * 53 / 100
        c.rect(tx - 12 * s, g - 14 * s, 24 * s, 2 * s, C(0xA8B0B8)); c.rect(tx - 12 * s, g - 14 * s, 24 * s, s, C(0xC8D0D8))
        c.rect(tx - 12 * s, g - 6 * s, 24 * s, s, C(0x8A9098))
        for lx in [tx - 11 * s, tx + 10 * s] { c.rect(lx, g - 12 * s, s, 10 * s, C(0x8A9098)) }
        for wx in [tx - 11 * s, tx + 10 * s] { c.rect(wx - s, g - 2 * s, 3 * s, 2 * s, C(0x1E2226)) }
        c.rect(tx - 11 * s, g - 25 * s, 12 * s, 11 * s, C(0xC8C0A8)); c.rect(tx - 11 * s, g - 25 * s, 12 * s, s, C(0xE0D8C0)); c.rect(tx, g - 25 * s, s, 11 * s, C(0x9A9278))
        c.rect(tx - 10 * s, g - 24 * s, 9 * s, 7 * s, C(0x14201A)); c.rect(tx - 9 * s, g - 23 * s, 7 * s, 5 * s, C(0x1E3A28))
        c.rect(tx + 2 * s, g - 20 * s, 9 * s, 6 * s, C(0x5A6066)); c.rect(tx + 2 * s, g - 20 * s, 9 * s, s, C(0x7A8088))
        c.rect(tx + 3 * s, g - 19 * s, 5 * s, 4 * s, C(0x0E1E14))
        for k in 0..<2 { c.rect(tx + 9 * s, g - (18 - k * 2) * s, s, s, C(0xC8C8C8)) }
        for k in 0..<3 { c.rect(tx - 10 * s + k * 3 * s, g - 10 * s, 2 * s, 4 * s, [C(0xE8E4D8), C(0x3A5A8A), C(0xE8E4D8)][k]) }   // binders on the shelf

        // The Gate: a tall rip in the concrete, glowing from the inside, its edges ragged and fleshy; the membrane round
        // it ridged and dark red, veined, and thick tendrils spreading out over the wall from it, forking as they go.
        let gx = f.gate.x, gTop = f.gate.top, gBot = g - 3 * s, gH = gBot - gTop
        let maxW = 11 * s
        // The tendrils first, so the membrane lies over their roots.
        for k in 0..<(gH / (5 * s)) {
            var x = Double(gx), y = Double(gTop + gH * (k + 1) / (gH / (5 * s) + 1))
            let right = k % 2 == 0
            var a = (right ? 0 : Double.pi) + (noise(k * 7) - 0.5) * 1.2
            let len = 18 + Int(noise(k * 3 + 1) * 34)
            for st in 0..<len {
                x += cos(a) * Double(s); y += sin(a) * Double(s)
                a += (noise(k * 101 + st) - 0.5) * 0.45
                let th = st < len / 3 ? 3 * s : st < len * 2 / 3 ? 2 * s : s
                c.rect(Int(x), Int(y), th, th, C(0x3A161A)); c.rect(Int(x), Int(y), th, s, C(0x5E2628))
                if Int(y) >= g - 3 * s || Int(y) < 0 { break }
                // A fork now and then, thinner.
                if st == len / 2, noise(k * 13) > 0.4 {
                    var fx = x, fy = y, fa = a + (noise(k) > 0.5 ? 0.8 : -0.8)
                    for _ in 0..<(len / 3) {
                        fx += cos(fa) * Double(s); fy += sin(fa) * Double(s); fa += 0.05
                        c.rect(Int(fx), Int(fy), s, s, C(0x3A161A))
                    }
                }
            }
        }
        for y in gTop..<gBot {
            let k = Double(y - gTop) / Double(gH)
            let base = pow(sin(k * .pi), 0.5) * Double(maxW)
            let rag = (noise(y / s * 7 + 3) - 0.5) * Double(4 * s) + sin(Double(y) / Double(9 * s)) * Double(2 * s)
            let half = max(0, Int(base * 0.75 + rag * 0.6)), rim = Int(base) + 7 * s + Int(noise(y / s * 5) * Double(3 * s))
            let lean = Int(sin(k * 3.1) * Double(3 * s))   // the rip isn't quite straight
            // The membrane: dark flesh, ribbed across, lit down its left side.
            c.rect(gx + lean - rim, y, rim * 2, 1, C(0x4A161C))
            if (y / s) % 4 == 0 { c.rect(gx + lean - rim + 2 * s, y, rim * 2 - 4 * s, 1, C(0x3A1016)) }
            c.rect(gx + lean - rim, y, 2 * s, 1, C(0x6E2A2C))
            c.rect(gx + lean - half - 2 * s, y, 2 * s, 1, C(0x8A3030)); c.rect(gx + lean + half, y, 2 * s, 1, C(0x5A1E22))
            if half > 0 {
                c.rect(gx + lean - half, y, half * 2, 1, C(0xB8381E))
                let mid = half * 3 / 5, core = half / 4
                if mid > 0 { c.rect(gx + lean - mid, y, mid * 2, 1, C(0xE8682A)) }
                if core > 0 { c.rect(gx + lean - core, y, core * 2, 1, C(0xFFB868)) }
            }
        }
        // Veins in the membrane, a brighter red.
        for k in 0..<(gH / (7 * s)) {
            let y = gTop + 4 * s + k * 7 * s, side = k % 2 == 0 ? -1 : 1
            let kk = Double(y - gTop) / Double(gH), w0 = Int(pow(sin(kk * .pi), 0.5) * Double(maxW)) + 4 * s
            for d in 0..<(4 * s) { c.px(gx + side * (w0 - d) + Int(sin(kk * 3.1) * Double(3 * s)), y + d / 2, C(0x8A2A2A)) }
        }

        // The railing round it: a steel rail on posts, a warning plate hung on it; and two floodlights on tripods
        // either side, aimed at the Gate.
        let rx0 = gx - 30 * s, rx1 = gx + 30 * s
        c.rect(rx0, g - 13 * s, rx1 - rx0, 2 * s, C(0xD8B030)); c.rect(rx0, g - 13 * s, rx1 - rx0, s, C(0xF0D060))
        for x in stride(from: rx0, through: rx1, by: 15 * s) { c.rect(x, g - 12 * s, 2 * s, 12 * s, C(0x8A9098)); c.rect(x, g - 12 * s, s, 12 * s, C(0xB0B8C0)) }
        c.rect(rx0, g - 7 * s, rx1 - rx0, s, C(0x8A9098))
        c.rect(gx - 6 * s, g - 11 * s, 12 * s, 6 * s, C(0xE8E8E2)); c.rect(gx - 6 * s, g - 11 * s, 12 * s, 2 * s, C(0xB82A26))
        c.rect(gx - 4 * s, g - 8 * s, 8 * s, s, C(0x2A2A2A))
        for (fx, dir) in [(gx - 44 * s, 1), (gx + 44 * s, -1)] {
            c.rect(fx, g - 26 * s, s, 23 * s, C(0x3A3E42))
            for k in 0..<10 { c.rect(fx - k * s / 2 - s, g - 10 * s + k * s, s, s, C(0x3A3E42)); c.rect(fx + k * s / 2 + s, g - 10 * s + k * s, s, s, C(0x3A3E42)) }
            c.rect(fx - 5 * s, g - 32 * s, 10 * s, 7 * s, C(0x4A4E54)); c.rect(fx - 5 * s, g - 32 * s, 10 * s, s, C(0x6A7076))
            c.rect(dir > 0 ? fx + 4 * s : fx - 6 * s, g - 31 * s, 2 * s, 5 * s, C(0xF0F0E0))
        }

        if tall {
            // The roof's girders in the dark, a big duct crossing the hall on its hangers, a steel gantry with its
            // railing and a ladder down from it, cable trays running to the Gate with the cables sagging, a panel of
            // breakers and dials, B-4 stencilled big on the concrete, and the observation room's window looking down
            // from the left, blinds half down, men in white coats behind them.
            c.rect(0, 0, c.w, 10 * s, C(0x2A2E32)); c.rect(0, 10 * s, c.w, s, C(0x1A1E20))
            for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, 0, 3 * s, 12 * s, C(0x3A4044)) }
            for lx in [c.w * 25 / 100, c.w * 50 / 100, c.w * 75 / 100] {
                c.rect(lx, 11 * s, s, 12 * s, C(0x1A1E20)); c.rect(lx - 6 * s, 23 * s, 13 * s, 4 * s, C(0x4A5054))
                c.rect(lx - 6 * s, 23 * s, 13 * s, s, C(0x6A7076)); c.rect(lx - 5 * s, 27 * s, 11 * s, s, C(0xE8F0E8))
            }
            let dy = 34 * s
            c.rect(0, dy, c.w, 14 * s, C(0x8A9098)); c.rect(0, dy, c.w, 2 * s, C(0xB0B8C0)); c.rect(0, dy + 12 * s, c.w, 2 * s, C(0x5A6066))
            for x in stride(from: 10 * s, to: c.w, by: 30 * s) {
                c.rect(x, dy - s, 2 * s, 16 * s, C(0x6A7076)); c.rect(x, 11 * s, s, dy - 11 * s, C(0x3A4044))
            }
            let gy = g - 112 * s
            if gy > dy + 30 * s {
                c.rect(0, gy, c.w * 62 / 100, 4 * s, C(0x5A6066)); c.rect(0, gy, c.w * 62 / 100, s, C(0x8A9098)); c.rect(0, gy + 4 * s, c.w * 62 / 100, s, C(0x2A2E32))
                for x in stride(from: 0, to: c.w * 62 / 100, by: 10 * s) {
                    c.rect(x, gy + 5 * s, s, 6 * s, C(0x4A5054)); c.rect(x, gy + 10 * s, 10 * s, s, C(0x4A5054))
                    for d in 0..<5 { c.rect(x + d * 2 * s, gy + 5 * s + d * s, s, s, C(0x4A5054)) }
                }
                c.rect(0, gy - 10 * s, c.w * 62 / 100, s, C(0xD8B030)); c.rect(0, gy - 5 * s, c.w * 62 / 100, s, C(0x8A9098))
                for x in stride(from: 0, to: c.w * 62 / 100, by: 12 * s) { c.rect(x, gy - 10 * s, s, 10 * s, C(0x8A9098)) }
                let lad = c.w * 60 / 100
                c.rect(lad, gy + 4 * s, s, g - 52 * s - gy, C(0x8A9098)); c.rect(lad + 6 * s, gy + 4 * s, s, g - 52 * s - gy, C(0x8A9098))
                for y in stride(from: gy + 8 * s, to: g - 52 * s, by: 4 * s) { c.rect(lad, y, 7 * s, s, C(0xA8B0B8)) }
                // The observation window, set in the wall above the gantry.
                let ox2 = c.w * 8 / 100, oyw = gy - 40 * s
                c.rect(ox2 - 3 * s, oyw - 3 * s, 80 * s, 26 * s, C(0x3A4044)); c.rect(ox2 - 3 * s, oyw - 3 * s, 80 * s, s, C(0x7A8082))
                c.rect(ox2, oyw, 74 * s, 20 * s, C(0x3A4A50))
                for y in stride(from: oyw, to: oyw + 8 * s, by: 2 * s) { c.rect(ox2, y, 74 * s, s, C(0xA8A898)) }
                c.rect(ox2 + 8 * s, oyw + 12 * s, 8 * s, 4 * s, C(0xE8D8A0)); c.rect(ox2 + 6 * s, oyw + 16 * s, 66 * s, 4 * s, C(0x2A3034))
                for k in 0..<3 {
                    let mx = ox2 + (30 + k * 12) * s
                    c.rect(mx - 3 * s, oyw + 12 * s, 6 * s, 6 * s, C(0xE0E4E8)); c.circle(mx, oyw + 10 * s, 2 * s, k == 1 ? C(0xD8D8D8) : C(0xC89A7A))
                }
                c.rect(ox2 - 3 * s, oyw + 20 * s, 80 * s, 3 * s, C(0x4E5456))
            }
            // B-4, big, stencilled on the wall above the corridor.
            let by = g - 92 * s
            if by > dy + 20 * s {
                hawkinsP2Sign(c, c.w * 18 / 100, by, "B", C(0x4A5052), 4 * s)
                c.rect(c.w * 18 / 100 + 16 * s, by + 8 * s, 8 * s, 4 * s, C(0x4A5052))
                hawkinsP2Sign(c, c.w * 18 / 100 + 28 * s, by, "A", C(0x6A7072), 4 * s)
                let fx = c.w * 18 / 100 + 28 * s
                c.rect(fx, by, 12 * s, 20 * s, C(0x6A7072))
                c.rect(fx, by, 4 * s, 12 * s, C(0x4A5052)); c.rect(fx + 8 * s, by, 4 * s, 20 * s, C(0x4A5052)); c.rect(fx, by + 8 * s, 12 * s, 4 * s, C(0x4A5052))
            }
            // The breaker panel on the right wall, dials and switches.
            let bx = c.w * 90 / 100, byp = g - 100 * s
            c.rect(bx - 14 * s, byp, 28 * s, 34 * s, C(0x5A6A5E)); c.rect(bx - 14 * s, byp, 28 * s, s, C(0x7A8A7E)); c.rect(bx + 13 * s, byp, s, 34 * s, C(0x3A4A3E))
            for k in 0..<3 { c.circle(bx - 8 * s + k * 8 * s, byp + 7 * s, 3 * s, C(0xE8E8DC)); c.rect(bx - 8 * s + k * 8 * s, byp + 5 * s, s, 2 * s, C(0x1A1A1A)) }
            for r in 0..<3 { for k in 0..<5 { c.rect(bx - 10 * s + k * 5 * s, byp + (15 + r * 6) * s, 3 * s, 4 * s, C(0x2A2E32)); c.rect(bx - 10 * s + k * 5 * s + s, byp + (15 + r * 6 + ((k + r) % 2) * 2) * s, s, 2 * s, C(0xC8C8C0)) } }
            // Cable trays from the panel to the Gate, the cables sagging below.
            let ty = g - 104 * s
            c.rect(f.gate.x + 20 * s, ty, bx - f.gate.x - 34 * s, 2 * s, C(0x6A7076))
            for k in 0..<3 {
                let x0 = f.gate.x + 14 * s, x1 = bx - 14 * s
                for x in x0..<x1 {
                    let u = Double(x - x0) / Double(x1 - x0)
                    c.rect(x, ty + 3 * s + k * 2 * s + Int(sin(u * .pi) * Double((6 + k * 3) * s)), 1, s, [C(0x1E2226), C(0x3A2A1E), C(0x1E2A3A)][k])
                }
            }
        }

        // The linoleum: dark grey, a lit edge, a few scuffs.
        c.ground(g, C(0x3E4246), edge: C(0x5A6064), speck: C(0x363A3E), seed: 33)
    }

    /// The Lab's life: the corridor's tubes and the wall lamps humming, one now and then flickering off and on; the
    /// Gate's glow breathing slowly in and out, a soft light on the concrete round it.
    static func hawkinsLabLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsLabFrame(c, g)
        // The wall lamps: each lit, unless it's the one flickering.
        for (k, lx) in f.lamps.enumerated() {
            let bad = k == 1 && (noise(Int(t * 9)) < 0.25 || Int(t * 24) % 7 == 0 && noise(Int(t * 2) + 70) < 0.5)
            guard !bad else { continue }
            for (r, a) in [(9, 0.04), (6, 0.07)] { c.circle(lx, g - 41 * s, r * s, C(0xE0F0E0, a)) }
            c.rect(lx - 3 * s, g - 43 * s, 6 * s, 3 * s, C(0xF0FFF0))
            for k2 in 0..<3 { c.rect(lx - 3 * s + k2 * 2 * s, g - 43 * s, s, 3 * s, C(0x6A7470)) }
        }
        // The corridor's nearest tube flickering: a dark band over it while it's out.
        let o = f.corridor
        if noise(Int(t * 11) + 300) < 0.18 {
            let oy = g - o.h, ih = o.h * 34 / 100
            c.rect(o.x + o.w / 5, oy, o.w * 3 / 5, ih / 4, C(0x1A2020, 0.55))
        }
        // The Gate breathing.
        let gx = f.gate.x, pulse = 0.5 + 0.5 * sin(t * 1.3)
        let midY = (f.gate.top + g) / 2
        for (r, a) in [(40, 0.04), (28, 0.05), (18, 0.06)] { c.ellipse(gx, max(midY, g - 40 * s), r * s * 2 / 3, r * s, C(0xFF7040, a * (0.6 + 0.6 * pulse))) }
        let gTop = f.gate.top, gH = g - 3 * s - gTop
        for y in stride(from: gTop, to: g - 3 * s, by: 1) {
            let k = Double(y - gTop) / Double(gH)
            let half = Int(pow(sin(k * .pi), 0.6) * Double(16 * s) / 3 * pulse)
            if half > 0 { c.rect(gx - half, y, half * 2, 1, C(0xFFE0A0, 0.5)) }
        }
    }
}
