import Foundation

// Places: Eleven's void, Hawkins Community Pool, the Snow Ball and Benny's Burgers. The void is black, a thin sheet of
// water underfoot and a few pale memories hanging in the dark; the pool is the summer of 1985 at noon, all blue and
// white; the Snow Ball is the middle school gym in December 1984, lit blue, paper snowflakes and a mirror ball; Benny's
// is a small-town diner in 1983, red vinyl and wood, the grill going. The floor and the band above it stay plain and
// mid-dark so the crew's outlines and names read.

let hawkinsScenes6: [Location: Place] = [
    .hawkinsVoid: Place(name: "Eleven's Void", panel: 0x06070A, still: Scenes.hawkinsVoid, moving: Scenes.hawkinsVoidLife),
    .hawkinsPool: Place(name: "Hawkins Community Pool", panel: 0x123044, still: Scenes.hawkinsPool,
                        moving: Scenes.hawkinsPoolLife),
    .hawkinsSnowBall: Place(name: "The Snow Ball", panel: 0x101630, still: Scenes.hawkinsSnowBall,
                            moving: Scenes.hawkinsSnowBallLife),
    .hawkinsBennys: Place(name: "Benny's Burgers", panel: 0x200E0C, still: Scenes.hawkinsBennys,
                          moving: Scenes.hawkinsBennysLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 5-row alphabet with the digits: three dots wide, but M, N and W wider so their diagonals read; the
/// apostrophe and the full stop one dot.
private let hawkinsP6Glyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011", "D": "110101101101110",
    "E": "111100110100111", "F": "111100110100100", "G": "011100101101011", "H": "101101111101101",
    "I": "111010010010111", "K": "101101110101101", "L": "100100100100111", "M": "1000111011101011000110001",
    "N": "10011101101110011001", "O": "010101101101010", "P": "110101110100100", "R": "110101110101101",
    "S": "011100010001110", "T": "111010010010010", "U": "101101101101111", "W": "1000110001101011101110001",
    "Y": "101101010010010", "'": "11000", ".": "00001",
    "0": "111101101101111", "1": "010110010010111", "2": "111001111100111", "3": "111001011001111",
    "4": "101101111001001", "5": "111100111001111", "6": "111100111101111", "7": "111001010010010",
    "8": "111101111101111", "9": "111101111001111",
]

/// Lettering, `p` pixels a dot, from its top-left corner, its steps eased (`hawkinsSoftText`).
private func hawkinsP6Sign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    hawkinsSoftText(c, x, y, text, hawkinsP6Glyphs, col, p)
}

/// How wide `text` comes out at `p` pixels a dot (a space is three dots).
private func hawkinsP6Width(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + (hawkinsP6Glyphs[$1].map { $0.count / 5 + 1 } ?? 3) } * p - p
}

/// Lettering centred on `x`.
private func hawkinsP6Centred(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    hawkinsP6Sign(c, x - hawkinsP6Width(text, p) / 2, y, text, col, p)
}

/// A ring on a flat surface seen from low down: an ellipse of dots `r` across, a quarter as deep.
private func hawkinsP6Ring(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, _ s: Int, _ col: Px) {
    let n = max(12, r / s * 5)
    for k in 0..<n {
        let a = Double(k) * 2 * .pi / Double(n)
        c.rect(x + Int(cos(a) * Double(r)), y + Int(sin(a) * Double(r) / 4), s, s, col)
    }
}

// MARK: - Eleven's void

extension Scenes {
    /// Where things stand in the void: the far edge of the water, the door standing on it, and the memories hanging
    /// in the dark (each where it floats, and what it is).
    static func hawkinsVoidFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, door: Int, memories: [(x: Int, y: Int, kind: Int)]) {
        let s = unit(g), tall = isTall(c)
        var mem = [(c.w * 44 / 100, g - 50 * s, 0), (c.w * 72 / 100, g - 42 * s, 1), (c.w * 90 / 100, g - 54 * s, 2)]
        if tall { mem += [(c.w * 30 / 100, g - 120 * s, 3), (c.w * 62 / 100, g - 150 * s, 2), (c.w * 82 / 100, g - 100 * s, 0), (c.w * 14 / 100, g - 170 * s, 4)] }
        return (tall ? g - 40 * s : g - 22 * s, c.w * 20 / 100, mem)
    }

    /// Eleven's void: nothing but black, and underfoot a thin sheet of still water running away to a far, faint line
    /// of light where it ends. A door stands on the water off to the left, alone, a strip of light under it, its
    /// reflection hanging below it; a few memories float in the dark, pale and sparse, like things half remembered: a
    /// walkie-talkie, a TV with its screen glowing, a photograph, a chair. The water is plain black along the front.
    /// On the screen saver the black goes up and up, endless, with a few more memories hanging far off.
    static func hawkinsVoid(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsVoidFrame(c, g)
        c.rect(0, 0, c.w, c.h, C(0x030305))
        // The far edge of the water: a thin line of cold light, a glow above it fading into the black.
        for i in 0..<(14 * s) { c.rect(0, f.horizon - i, c.w, 1, C(0x2A3A5A, 0.16 * (1 - Double(i) / Double(14 * s)))) }
        c.rect(0, f.horizon, c.w, 1, C(0x5A6A8A, 0.7))
        // The water: black, with faint streaks of light on it, closer together far off.
        var y = f.horizon + s, k = 0
        while y < g {
            for j in 0..<(c.w / (40 * s) + 1) {
                let x = j * 40 * s + Int(noise(k * 17 + j + 50) * Double(30 * s)), len = (6 + Int(noise(k * 17 + j + 60) * 20)) * s
                c.rect(x, y, len, 1, C(0x3A4A6A, 0.25 + 0.15 * Double(k % 2)))
            }
            k += 1; y += max(s, k * k * s / 3)
        }
        // A few motes far off in the dark, very faint.
        for k in 0..<(c.w * f.horizon / (5000 * s * s)) {
            c.rect(Int(noise(k * 3 + 80) * Double(c.w)), Int(noise(k * 3 + 81) * Double(f.horizon - 10 * s)), s, s, C(0x8A9AB8, 0.18))
        }

        // The door, standing on the water: a pale frame, the door shut in it, its knob, light under it; then the same
        // upside down in the water below, fainter.
        let dx = f.door, base = f.horizon + 6 * s
        func door(_ flip: Bool, _ a: Double) {
            func r(_ x: Int, _ y0: Int, _ w: Int, _ h: Int, _ col: Px) {
                let y = flip ? base + y0 : base - y0 - h
                let top = max(y, flip ? base : 0), bottom = min(y + h, flip ? g : base)
                if bottom > top { c.rect(x, top, w, bottom - top, col.alpha(a)) }
            }
            r(dx - 9 * s, 0, 18 * s, 30 * s, C(0x7A8AA0)); r(dx - 8 * s, 0, 16 * s, 29 * s, C(0x2A3244))
            for py in [4, 16] { r(dx - 6 * s, py * s, 12 * s, 10 * s, C(0x343E52)); r(dx - 6 * s, (py + 9) * s, 12 * s, s, C(0x22293A)) }
            r(dx + 5 * s, 13 * s, 2 * s, 2 * s, C(0xA8B4C4))
            r(dx - 8 * s, 0, 16 * s, s, C(0xE8F0FF))
        }
        door(false, 0.9); door(true, 0.3)
        for (r0, a) in [(14, 0.05), (8, 0.08)] { c.ellipse(dx, base, r0 * s, 2 * s, C(0xC8D8F8, a)) }

        // The memories: pale, see-through, each with a faint smear of light on the water under it.
        let ghost = C(0x9AAAC4, 0.55), ghostL = C(0xC8D4E8, 0.7), ghostD = C(0x4A5670, 0.55)
        for (k, m) in f.memories.enumerated() {
            switch m.kind {
            case 0:   // a walkie-talkie: the body, the aerial, the grille, the button
                c.rect(m.x - 3 * s, m.y, 7 * s, 12 * s, ghost); c.rect(m.x - 3 * s, m.y, 7 * s, s, ghostL)
                c.rect(m.x + 2 * s, m.y - 8 * s, s, 8 * s, ghostL)
                for gy in 0..<3 { c.rect(m.x - 2 * s, m.y + (3 + gy * 2) * s, 5 * s, s, ghostD) }
                c.rect(m.x - 4 * s, m.y + 2 * s, s, 3 * s, ghostL)
            case 1:   // a TV, its screen glowing (the moving layer fills it with static)
                c.rect(m.x - 9 * s, m.y, 18 * s, 13 * s, ghost); c.rect(m.x - 9 * s, m.y, 18 * s, s, ghostL)
                c.rect(m.x - 7 * s, m.y + 2 * s, 11 * s, 9 * s, C(0x1A2234, 0.8))
                c.rect(m.x + 6 * s, m.y + 3 * s, s, s, ghostL); c.rect(m.x + 6 * s, m.y + 6 * s, s, s, ghostL)
                for d in 0..<6 { c.px(m.x - 2 * s - d * s, m.y - s - d * s, ghostL); c.px(m.x + 2 * s + d * s, m.y - s - d * s, ghostL) }
                c.rect(m.x - 6 * s, m.y + 13 * s, 2 * s, 2 * s, ghost); c.rect(m.x + 4 * s, m.y + 13 * s, 2 * s, 2 * s, ghost)
            case 2:   // a photograph, a little tilted: the white border and two faces in it
                for r in 0..<(10 * s) { c.rect(m.x - 5 * s + r / 5, m.y + r, 10 * s, 1, C(0xE0E8F4, 0.6)) }
                for r in 0..<(6 * s) { c.rect(m.x - 4 * s + r / 5, m.y + s + r, 8 * s, 1, C(0x5A6A84, 0.6)) }
                c.circle(m.x - s, m.y + 3 * s, s, C(0xC8D4E8, 0.6)); c.circle(m.x + 2 * s, m.y + 4 * s, s, C(0xC8D4E8, 0.6))
            case 4:   // a bike, tipped a little: two wheels, the frame between, the handlebars
                for wx in [m.x - 8 * s, m.x + 8 * s] { for a in 0..<16 { let r = Double(a) * .pi / 8; c.rect(wx + Int(cos(r) * Double(5 * s)), m.y + 4 * s + Int(sin(r) * Double(5 * s)), s, s, ghost) } }
                for d in 0..<(8 * s) { c.rect(m.x - 8 * s + d, m.y + 4 * s - d / 2, s, s, ghostL); c.rect(m.x + d, m.y, s, s, ghostL) }
                c.rect(m.x + 6 * s, m.y - 4 * s, s, 4 * s, ghostL); c.rect(m.x + 4 * s, m.y - 4 * s, 5 * s, s, ghostL); c.rect(m.x - 2 * s, m.y - 2 * s, 4 * s, s, ghostL)
            default:  // a kitchen chair, on its side
                c.rect(m.x - 6 * s, m.y, 12 * s, 2 * s, ghost); c.rect(m.x - 6 * s, m.y, 12 * s, s, ghostL)
                c.rect(m.x - 6 * s, m.y + 2 * s, 2 * s, 8 * s, ghost); c.rect(m.x + 4 * s, m.y + 2 * s, 2 * s, 8 * s, ghost)
                c.rect(m.x - 6 * s, m.y - 9 * s, 2 * s, 9 * s, ghost)
                for by in [m.y - 8 * s, m.y - 4 * s] { c.rect(m.x - 6 * s, by, 7 * s, s, ghostD) }
            }
            c.rect(m.x - 4 * s, f.horizon + 3 * s + (k % 3) * 2 * s, 8 * s, 1, C(0x9AAAC4, 0.25))
        }

        // The water along the front: black, the faint line where it meets the far sheet.
        c.ground(g, C(0x050608), edge: C(0x1E2636), speck: C(0x0A0C12), seed: 131)
    }

    /// The void's life: ripples spreading slowly out across the water from where something touched it, one after
    /// another, fading as they go; and the floating TV's screen full of faint static.
    static func hawkinsVoidLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsVoidFrame(c, g)
        // Ripples from three places on the water, each on its own beat, spreading on the sheet and the front alike.
        for (k, rx) in [c.w * 34 / 100, c.w * 62 / 100, c.w * 86 / 100].enumerated() {
            let ry = k == 1 ? g + 3 * s : (f.horizon + g) / 2 + k * s
            for j in 0..<3 {
                let ph = (t * 0.22 + Double(k) * 0.37 + Double(j) / 3).truncatingRemainder(dividingBy: 1)
                let r = Int(ph * Double(44 * s)) + 2 * s
                hawkinsP6Ring(c, rx, ry, r, s, C(0xA8B8D8, 0.26 * (1 - ph) * (1 - ph)))
            }
        }
        // The TV's static.
        let frame = Int(t * 12)
        for m in f.memories where m.kind == 1 {
            for y in stride(from: m.y + 2 * s, to: m.y + 11 * s, by: s) {
                for x in stride(from: m.x - 7 * s, to: m.x + 4 * s, by: s) {
                    let v = noise(frame * 3001 + y * 131 + x * 7)
                    c.rect(x, y, s, s, v > 0.6 ? C(0xC8D4E8, 0.55) : v > 0.3 ? C(0x6A7A94, 0.5) : C(0x1A2234, 0.5))
                }
            }
            c.circle(m.x - s, m.y + 6 * s, 10 * s, C(0x8AA0D0, 0.04))
        }
    }
}

// MARK: - Hawkins Community Pool

extension Scenes {
    /// Where things stand at the pool: the bathhouse, the lifeguard's chair, the high board, the near and far edges of
    /// the water, and the sun loungers.
    static func hawkinsPoolFrame(_ c: PixelCanvas, _ g: Int)
        -> (house: Int, chair: Int, board: Int, water: (top: Int, bottom: Int), loungers: [Int]) {
        let s = unit(g)
        return (c.w * 15 / 100, c.w * 56 / 100, c.w * 88 / 100, (top: g - 16 * s, bottom: g - 3 * s),
                [c.w * 30 / 100, c.w * 67 / 100, c.w * 77 / 100])
    }

    /// Hawkins Community Pool on a bright day in the summer of 1985: a clear blue sky; trees in full leaf behind a
    /// chain-link fence; on the left the bathhouse, painted cream with a teal band, HAWKINS POOL over its two doors;
    /// along the far side of the water the sun loungers in stripes, a towel on one, an umbrella; the lifeguard's tall
    /// white chair with its red umbrella; a life ring and a NO RUNNING sign on the fence; and on the right the high
    /// board, its ladder going up and the board reaching out over the deep end. The pool across the middle, bright
    /// turquoise with two lane ropes, a chrome ladder at the near edge, white coping. The deck along the front plain. On
    /// the screen saver the sky goes up clear and blue to the sun, the trees grow tall, and the town's water tower
    /// stands over them.
    static func hawkinsPool(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsPoolFrame(c, g), tall = isTall(c)
        // The sky, deep blue overhead and paler down by the trees.
        c.gradient(0, g, C(0x2A7AD8), C(0xA8D8F4), bands: 8)
        if tall {
            // The sun, high on the right, its glow round it.
            let sx = c.w * 84 / 100, sy = max(36 * s, g - 230 * s)
            for (r, a) in [(30, 0.10), (20, 0.14), (13, 0.2)] { c.circle(sx, sy, r * s, C(0xFFF8D8, a)) }
            c.circle(sx, sy, 9 * s, C(0xFFFCE8))
            // The water tower, far off over the trees: its legs braced, the tank with HAWKINS on it.
            let wx = c.w * 32 / 100, wt = g - 110 * s
            for lx in [wx - 12 * s, wx - 4 * s, wx + 4 * s, wx + 12 * s] { c.rect(lx, wt + 14 * s, s, 70 * s, C(0x8AA0B8)) }
            for y in stride(from: wt + 22 * s, to: wt + 80 * s, by: 14 * s) {
                for d in 0..<(24 * s) { c.px(wx - 12 * s + d, y + d * 10 / 24, C(0x8AA0B8)); c.px(wx + 12 * s - d, y + d * 10 / 24, C(0x8AA0B8)) }
            }
            c.rect(wx - 18 * s, wt, 36 * s, 16 * s, C(0xC8D4E0)); c.rect(wx - 18 * s, wt, 36 * s, 2 * s, C(0xE0E8F0)); c.rect(wx + 12 * s, wt, 6 * s, 16 * s, C(0xA8B4C4))
            for y in 0..<(8 * s) { let half = 18 * s - y * 2; if half > 0 { c.rect(wx - half, wt - y - s, half * 2, 1, C(0xB8C4D0)) } }
            c.rect(wx - 20 * s, wt + 16 * s, 40 * s, s, C(0x8AA0B8))
            hawkinsP6Centred(c, wx - 2 * s, wt + 5 * s, "HAWKINS", C(0x2A5A8A), s)
        }
        // The trees behind the fence: round crowns in summer greens, lit on top, trunks under them.
        let treeTop = tall ? g - 76 * s : g - 46 * s
        if tall {
            // A far row of trees, hazy blue-green, and a few birds high up.
            for k in 0..<(c.w / (12 * s) + 2) {
                let tx = k * 12 * s + Int(noise(k + 540) * Double(6 * s)), r = (9 + Int(noise(k + 550) * 5)) * s, ty = treeTop - 14 * s + Int(noise(k + 560) * Double(10 * s))
                c.ellipse(tx, ty, r, r * 3 / 4, C(0x5A9A8A)); c.ellipse(tx - 2 * s, ty - 2 * s, r / 2, r / 4, C(0x7AB4A4))
            }
            for k in 0..<5 {
                let bx = c.w * (20 + k * 13) / 100 + Int(noise(k + 570) * Double(20 * s)), by = g - 150 * s - Int(noise(k + 580) * Double(50 * s))
                c.rect(bx - 2 * s, by, 2 * s, s, C(0x2A3A5A)); c.rect(bx + s, by, 2 * s, s, C(0x2A3A5A)); c.rect(bx, by + s, s, s, C(0x2A3A5A))
            }
        }
        for k in 0..<(c.w / (16 * s) + 2) {
            let tx = k * 16 * s + Int(noise(k + 500) * Double(8 * s)), r = (10 + Int(noise(k + 510) * 6)) * s
            let ty = treeTop + Int(noise(k + 520) * Double(8 * s)) + (tall ? Int(noise(k + 530) * Double(20 * s)) : 0)
            c.rect(tx - s, ty, 3 * s, g - ty, C(0x5A4A3A))
            c.ellipse(tx, ty + 2 * s, r, r * 3 / 4, C(0x2E6A30)); c.ellipse(tx - 2 * s, ty, r - 2 * s, r * 3 / 4 - s, C(0x3E8A3A))
            c.ellipse(tx - 4 * s, ty - 3 * s, r / 2, r / 4, C(0x6AAE4A))
        }
        c.rect(0, g - 27 * s, c.w, 10 * s, C(0x3E7A36))

        // The bathhouse: cream block walls, a teal band, a flat roof, two dark doorways, HAWKINS POOL over them.
        let hx = f.house, hw = 60 * s, ht = g - 42 * s, hb = g - 18 * s
        c.rect(hx - hw / 2, ht, hw, hb - ht, C(0xE8DCC0))
        for y in stride(from: ht + 3 * s, to: hb, by: 3 * s) { c.rect(hx - hw / 2, y, hw, 1, C(0xD4C8AC)) }
        c.rect(hx + hw / 2 - 4 * s, ht, 4 * s, hb - ht, C(0xC8BCA0))
        c.rect(hx - hw / 2 - 2 * s, ht - 3 * s, hw + 4 * s, 3 * s, C(0x8A8A8A)); c.rect(hx - hw / 2 - 2 * s, ht - 3 * s, hw + 4 * s, s, C(0xB0B0B0))
        c.rect(hx - hw / 2, ht + 2 * s, hw, 8 * s, C(0x2A9A9A)); c.rect(hx - hw / 2, ht + 2 * s, hw, s, C(0x5AC8C8))
        hawkinsP6Centred(c, hx, ht + 4 * s, "HAWKINS POOL", C(0xFFFFFF), s)
        for (k, dx) in [hx - 16 * s, hx + 8 * s].enumerated() {
            c.rect(dx - 5 * s, hb - 15 * s, 10 * s, 15 * s, C(0x1A2430)); c.rect(dx - 5 * s, hb - 15 * s, 10 * s, s, C(0x2A3440))
            c.rect(dx - 2 * s, hb - 13 * s, 4 * s, 3 * s, k == 0 ? C(0x3A6AC8) : C(0xD85A8A))
        }

        // The fence: a top rail, the mesh, posts; a life ring and the NO RUNNING sign on it.
        let ft = g - 27 * s
        c.rect(hx + hw / 2, ft, c.w, s, C(0xB8C0C8))
        for x in stride(from: hx + hw / 2, to: c.w, by: 3 * s) { c.rect(x, ft + s, s, 9 * s, C(0x8A949E, 0.5)) }
        for y in stride(from: ft + 2 * s, to: g - 18 * s, by: 3 * s) { c.rect(hx + hw / 2, y, c.w, 1, C(0x8A949E, 0.4)) }
        for x in stride(from: hx + hw / 2 + 10 * s, to: c.w, by: 34 * s) { c.rect(x, ft - s, s, 11 * s, C(0xC8D0D8)) }
        let lr = c.w * 36 / 100
        c.circle(lr, ft + 4 * s, 4 * s, C(0xF8F8F0)); c.circle(lr, ft + 4 * s, 2 * s, C(0x3E7A36))
        for (dx, dy) in [(-4, 0), (3, 0), (0, -4), (0, 3)] { c.rect(lr + dx * s, ft + 4 * s + dy * s, s, s, C(0xD83A2A)) }
        let ns = "NO RUNNING", nsw = hawkinsP6Width(ns, s) + 4 * s, nx = c.w * 40 / 100
        c.rect(nx, ft - 2 * s, nsw, 9 * s, C(0xF8F8F0)); c.rect(nx, ft - 2 * s, nsw, s, C(0xD83A2A)); c.rect(nx, ft + 6 * s, nsw, s, C(0xD83A2A))
        hawkinsP6Sign(c, nx + 2 * s, ft, ns, C(0xC82A22), s)

        // The far deck: pale concrete, a strip of it between the fence and the water.
        c.rect(0, g - 18 * s, c.w, 2 * s, C(0xD8D0C0)); c.rect(0, g - 18 * s, c.w, s, C(0xE8E0D0))

        // The sun loungers: white frames, striped cushions, a towel on one, an umbrella over another.
        for (k, lx) in f.loungers.enumerated() {
            let lt = g - 23 * s
            c.rect(lx - 10 * s, lt + 2 * s, 20 * s, 2 * s, k % 2 == 0 ? C(0x3A8AD8) : C(0xF0C040))
            for x in stride(from: lx - 10 * s, to: lx + 10 * s, by: 4 * s) { c.rect(x, lt + 2 * s, 2 * s, 2 * s, C(0xF8F8F0)) }
            for d in 0..<(6 * s) { c.rect(lx + 8 * s + d / 3, lt + 2 * s - d, 2 * s, 1, k % 2 == 0 ? C(0x3A8AD8) : C(0xF0C040)) }
            c.rect(lx - 9 * s, lt + 4 * s, s, 3 * s, C(0xE8E8E8)); c.rect(lx + 8 * s, lt + 4 * s, s, 3 * s, C(0xE8E8E8))
            if k == 0 { c.rect(lx - 6 * s, lt + s, 8 * s, 2 * s, C(0xE84A6A)); c.rect(lx - 6 * s, lt + s, 8 * s, s, C(0xF87A9A)) }
            if k == 1 {
                c.rect(lx - 14 * s, lt - 22 * s, s, 26 * s, C(0xD8D8D8))
                for y in 0..<(7 * s) { let half = 3 * s + y * 2; c.rect(lx - 14 * s - half, lt - 26 * s + y, half * 2 + s, 1, (y / s) % 2 == 0 ? C(0xF8F0D8) : C(0x2A9A9A)) }
            }
        }

        // The lifeguard's chair: tall white legs braced, a seat with arms and a back, its own red umbrella, the
        // whistle hanging off it.
        let cx = f.chair, seat = g - 40 * s, w0 = f.water
        for lx in [cx - 6 * s, cx + 5 * s] { c.rect(lx, seat, 2 * s, w0.top - seat, C(0xF0F0F0)); c.rect(lx + s, seat, s, w0.top - seat, C(0xC8C8C8)) }
        for y in stride(from: seat + 6 * s, to: w0.top, by: 6 * s) { c.rect(cx - 6 * s, y, 13 * s, s, C(0xE0E0E0)) }
        c.rect(cx - 7 * s, seat, 15 * s, 2 * s, C(0xF8F8F8)); c.rect(cx - 7 * s, seat - 8 * s, 2 * s, 8 * s, C(0xF8F8F8)); c.rect(cx + 6 * s, seat - 5 * s, 2 * s, 5 * s, C(0xF8F8F8))
        c.rect(cx - 7 * s, seat - 8 * s, 2 * s, s, C(0xFFFFFF))
        c.rect(cx - 2 * s, seat - 18 * s, s, 18 * s, C(0xC8C8C8))
        for y in 0..<(6 * s) { let half = 3 * s + y * 2; c.rect(cx - 2 * s - half, seat - 22 * s + y, half * 2 + s, 1, (y / s) % 2 == 0 ? C(0xE83A2A) : C(0xF8F8F0)) }
        c.rect(cx + 7 * s, seat + 2 * s, s, 4 * s, C(0xE83A2A)); c.rect(cx + 6 * s, seat + 6 * s, 3 * s, 2 * s, C(0xC8C8D0))

        // The high board on the right: two posts and a ladder up, a rail, the board out over the deep end.
        let bx = f.board, bt = g - 58 * s
        for px in [bx, bx + 10 * s] { c.rect(px, bt, 2 * s, w0.top - bt, C(0xD8DCE0)); c.rect(px + s, bt, s, w0.top - bt, C(0xA8ACB4)) }
        for y in stride(from: bt + 4 * s, to: w0.top, by: 4 * s) { c.rect(bx + 2 * s, y, 8 * s, s, C(0xB8BCC4)) }
        c.rect(bx - 2 * s, bt - 6 * s, s, 6 * s, C(0xC8CCD4)); c.rect(bx - 2 * s, bt - 6 * s, 14 * s, s, C(0xC8CCD4))
        c.rect(bx - 34 * s, bt, 46 * s, 2 * s, C(0x3A8AC8)); c.rect(bx - 34 * s, bt, 46 * s, s, C(0x6AB0E0))
        c.rect(bx - 2 * s, bt + 2 * s, 14 * s, 2 * s, C(0x8A8E96))

        // The water: bright turquoise in bands, a darker band at the far edge, two lane ropes of red and white floats.
        let w = f.water
        c.rect(0, w.top, c.w, w.bottom - w.top, C(0x3AB8D8))
        c.rect(0, w.top, c.w, s, C(0x1A7A9A)); c.rect(0, w.top + s, c.w, s, C(0x2A98B8))
        for y in stride(from: w.top + 3 * s, to: w.bottom, by: 3 * s) {
            for k in 0..<(c.w / (30 * s) + 1) { c.rect(k * 30 * s + Int(noise(y / s * 7 + k + 600) * Double(16 * s)), y, (6 + k % 3 * 3) * s, s, C(0x5ACCE8)) }
        }
        let ly = w.top + 6 * s
        for x in stride(from: 0, to: c.w, by: 3 * s) { c.rect(x, ly + ((x / (3 * s)) % 6 == 0 ? s : 0), 2 * s, s, (x / (24 * s)) % 2 == 0 ? C(0xD84A4A) : C(0xE8F0F0)) }
        // The chrome ladder at the near edge, rails curving over the coping.
        let lx = c.w * 28 / 100
        for px in [lx, lx + 6 * s] {
            c.rect(px, w.top + 2 * s, s, w.bottom - w.top, C(0xD8E0E8)); c.rect(px + s, w.bottom - 2 * s, s, 2 * s, C(0xD8E0E8))
            c.rect(px, w.top, 2 * s, 2 * s, C(0xE8F0F8))
        }
        for y in stride(from: w.top + 4 * s, to: w.bottom, by: 3 * s) { c.rect(lx, y, 7 * s, s, C(0xB8C4D0, 0.8)) }
        // The near coping: white, with the gutter's shadow under its lip.
        c.rect(0, w.bottom, c.w, 2 * s, C(0xF0ECE4)); c.rect(0, w.bottom + 2 * s, c.w, s, C(0x8A8478))

        // The deck along the front: warm grey concrete, plain, a lit edge.
        c.ground(g, C(0x7A7266), edge: C(0x9A9284), speck: C(0x706858), seed: 141)
    }

    /// The pool's life: the sun glinting off the water, points of light winking on and off along the ripples.
    static func hawkinsPoolLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), w = hawkinsPoolFrame(c, g).water
        let frame = Int(t * 5)
        for k in 0..<(c.w / (10 * s)) {
            let ph = noise(k * 7 + frame * 31)
            guard ph > 0.7 else { continue }
            let x = Int(noise(k * 7 + 1 + frame * 13) * Double(c.w)), y = w.top + 2 * s + Int(noise(k * 7 + 2) * Double(w.bottom - w.top - 3 * s))
            c.rect(x, y, 2 * s, s, C(0xFFFFFF, 0.9)); if ph > 0.85 { c.rect(x + s / 2, y - s, s, 3 * s, C(0xFFFFFF, 0.5)) }
        }
    }
}

// MARK: - The Snow Ball

extension Scenes {
    /// Where things stand at the Snow Ball: the mirror ball, the banner, the paper snowflakes, the punch table, the
    /// DJ's table, the bleachers and the balloons.
    static func hawkinsSnowBallFrame(_ c: PixelCanvas, _ g: Int)
        -> (ball: (x: Int, y: Int, r: Int), banner: (x: Int, y: Int), flakes: [(x: Int, y: Int)], punch: Int, dj: Int, bleachers: Int, balloons: [Int]) {
        let s = unit(g), tall = isTall(c)
        let flakes = (0..<(tall ? 16 : 7)).map { k in
            (c.w * (28 + k * 70 / (tall ? 16 : 7)) / 100 + Int(noise(k + 700) * Double(10 * s)),
             (tall ? g - 150 * s : 12 * s) + Int(noise(k + 710) * Double((tall ? 90 : 14) * s)))
        }
        return ((x: c.w * 48 / 100, y: tall ? g - 96 * s : 9 * s, r: 6 * s), (x: c.w * 76 / 100, y: tall ? g - 70 * s : 4 * s), flakes,
                c.w * 32 / 100, c.w * 84 / 100, c.w * 8 / 100, [c.w * 22 / 100, c.w * 60 / 100, c.w * 97 / 100])
    }

    /// On the screen saver, where the wall stops and the roof's trusses start.
    static func hawkinsSnowBallRoof(_ c: PixelCanvas, _ g: Int) -> Int {
        let s = unit(g)
        return max(24 * s, g - 200 * s)
    }

    /// The Snow Ball, Hawkins Middle School's gym in December 1984, lit blue for the night: the block walls painted
    /// and washed in blue light, a dark band along the bottom; the bleachers folded back against the wall on the
    /// left; swags of crepe paper in blue and white along the top of the wall; paper snowflakes hanging on threads; a
    /// white banner, SNOW BALL in blue; the mirror ball hanging in the middle; clusters of balloons in blue, white and
    /// silver tied to weights; the punch table with its white cloth, the bowl and the cups; the DJ's table with the
    /// record player and the speakers. The gym floor dark in the low light. On the screen saver the walls go up to the
    /// steel trusses of the roof, streamers hanging down from them, the high windows dark, the scoreboard and a
    /// basketball hoop wound up out of the way, and more snowflakes hanging, the mirror ball on its long cable.
    static func hawkinsSnowBall(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsSnowBallFrame(c, g), tall = isTall(c)
        let blue = C(0x6AA8F0), white = C(0xF0F4FF), silver = C(0xB8C4D8)
        // The walls: painted block in the blue light, the joints darker, a band along the bottom.
        c.rect(0, 0, c.w, g, C(0x28325C))
        for (r, y) in stride(from: g - 14 * s, to: -4 * s, by: -4 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x202A50))
            for x in stride(from: (r % 2) * 8 * s, to: c.w, by: 16 * s) { c.rect(x, y, s, 4 * s, C(0x222C52)) }
        }
        c.rect(0, g - 14 * s, c.w, 14 * s, C(0x1A2044)); c.rect(0, g - 14 * s, c.w, s, C(0xC8A030))

        if tall {
            // The roof: steel trusses across under a dark ceiling, the high windows along the top of the wall.
            let rt = hawkinsSnowBallRoof(c, g)
            if rt > 20 * s {
                // The deck overhead in ribs, then the trusses: a top and bottom chord with the web zigzagging between,
                // and caged lamps hanging from them, turned down low.
                c.rect(0, 0, c.w, rt, C(0x10142A))
                for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, 0, s, rt, C(0x161C36)) }
                // Further trusses going back into the dark, each thinner and dimmer than the one in front of it.
                var ty = rt - 30 * s, depth = 1
                while ty > 0 {
                    let col = lerp(C(0x3A4466), C(0x161C36), Double(depth) / 5), h = max(3 * s, (12 - depth * 2) * s)
                    c.rect(0, ty, c.w, s, col); c.rect(0, ty + h, c.w, s, col)
                    for x in stride(from: 0, to: c.w, by: h) { for d in 0..<h { c.px(x + d / 2 + ((x / h) % 2 == 0 ? 0 : h / 2 - d), ty + d, col) } }
                    ty -= h + (10 - min(depth, 6)) * s; depth += 1
                }
                let tt = rt - 18 * s
                c.rect(0, tt, c.w, 2 * s, C(0x4A5478)); c.rect(0, rt, c.w, 2 * s, C(0x4A5478)); c.rect(0, tt, c.w, s, C(0x6A7498))
                for k in 0..<(c.w / (16 * s) + 1) {
                    let tx = k * 16 * s
                    for d in 0..<(16 * s) { c.rect(tx + d / 2 + (k % 2 == 0 ? 0 : 8 * s - d), tt + 2 * s + d, s, 1, C(0x3A4466)) }
                    c.rect(tx, tt, s, 18 * s, C(0x3A4466))
                }
                for k in 0..<(c.w / (70 * s) + 1) {
                    let lx = k * 70 * s + 35 * s
                    c.rect(lx, rt + 2 * s, s, 6 * s, C(0x5A6488)); c.rect(lx - 4 * s, rt + 8 * s, 9 * s, 5 * s, C(0x3A4466))
                    for b in 0..<3 { c.rect(lx - 3 * s + b * 3 * s, rt + 9 * s, s, 4 * s, C(0x6A7498)) }
                    c.rect(lx - 2 * s, rt + 12 * s, 5 * s, s, C(0xC8D0F0, 0.6))
                }
                for k in 0..<(c.w / (40 * s) + 1) {
                    let wx = k * 40 * s + 8 * s
                    c.rect(wx, rt + 20 * s, 24 * s, 14 * s, C(0x0A1024)); c.rect(wx, rt + 20 * s, 24 * s, s, C(0x3A4466))
                    for b in 1..<3 { c.rect(wx + b * 8 * s, rt + 20 * s, s, 14 * s, C(0x3A4466)) }
                    c.rect(wx + 3 * s, rt + 23 * s, s, s, C(0xE8F0FF, 0.6))
                }
                // Streamers hanging from the trusses in long curling strands, blue and white.
                for k in 0..<(c.w / (16 * s) + 1) {
                    let sx = k * 16 * s + Int(noise(k + 720) * Double(8 * s)), len = (30 + Int(noise(k + 730) * 40)) * s
                    for d in stride(from: 0, to: len, by: s) {
                        // A twisted ribbon: wide where its face turns to us, a thin edge where it turns away.
                        let tw = sin(Double(d) / Double(4 * s) + Double(k))
                        let face = k % 2 == 0 ? blue : white, back = k % 2 == 0 ? C(0x3A6AB0) : C(0xA8B8D8)
                        c.rect(sx + Int(sin(Double(d) / Double(9 * s) + Double(k)) * Double(2 * s)) - (abs(tw) > 0.4 ? s : 0), rt + 2 * s + d,
                               abs(tw) > 0.4 ? 3 * s : s, s, tw > 0 ? face : back)
                    }
                }
            }
            // The scoreboard: HOME and GUEST over two scores in red bulbs.
            let sbx = c.w * 20 / 100, sby = g - 112 * s
            c.rect(sbx - 22 * s, sby, 44 * s, 24 * s, C(0x14141C)); c.rect(sbx - 22 * s, sby, 44 * s, s, C(0x3A3A4A))
            hawkinsP6Centred(c, sbx - 11 * s, sby + 3 * s, "HOME", C(0xE8E8E8), s)
            hawkinsP6Centred(c, sbx + 11 * s, sby + 3 * s, "GUEST", C(0xE8E8E8), s)
            hawkinsP6Centred(c, sbx - 11 * s, sby + 11 * s, "00", C(0xE84A3A), 2 * s)
            hawkinsP6Centred(c, sbx + 11 * s, sby + 11 * s, "00", C(0xE84A3A), 2 * s)
            // The basketball hoop wound up: the backboard tilted up, its orange rim.
            let hx = c.w * 90 / 100, hy = g - 130 * s
            c.rect(hx - 2 * s, hy - 20 * s, 2 * s, 20 * s, C(0x3A4466))
            c.rect(hx - 14 * s, hy, 28 * s, 16 * s, C(0xD8E0F0)); c.rect(hx - 12 * s, hy + 2 * s, 24 * s, 12 * s, C(0x9AA8C8))
            c.rect(hx - 6 * s, hy + 6 * s, 12 * s, 8 * s, C(0xD8E0F0)); c.rect(hx - 5 * s, hy + 7 * s, 10 * s, 7 * s, C(0x9AA8C8))
            c.rect(hx - 6 * s, hy + 16 * s, 12 * s, s, C(0xE8742A))
            for k in 0..<5 { c.rect(hx - 5 * s + k * 2 * s + k / 2, hy + 17 * s, s, 6 * s - abs(k - 2) * s, C(0xE8F0FF, 0.8)) }
            // The mirror ball's long cable.
            c.rect(f.ball.x, 0, s, f.ball.y - f.ball.r, C(0x6A7494))
        } else {
            c.rect(f.ball.x, 0, s, f.ball.y - f.ball.r, C(0x6A7494))
        }

        // The swags of crepe paper along the top of the wall, blue and white, scalloped, twisted.
        let swagY = tall ? g - 80 * s : 2 * s
        for (j, col) in [(0, blue), (1, white)] {
            var x = c.w * 24 / 100 + j * 10 * s
            while x < c.w {
                for d in 0..<(20 * s) {
                    let u = Double(d) / Double(20 * s)
                    c.rect(x + d, swagY + Int(sin(u * .pi) * Double(6 * s)) + j * s, 1, (d / s) % 3 == 0 ? s : 2 * s, col)
                }
                c.rect(x - s, swagY - s, 3 * s, 3 * s, j == 0 ? blue : white)
                x += 20 * s
            }
        }

        // The banner: white, swagged a little, SNOW BALL in blue.
        let bn = "SNOW BALL", bnw = hawkinsP6Width(bn, 2 * s) + 12 * s, bx = f.banner.x - bnw / 2, by = f.banner.y + 4 * s
        c.rect(bx, by, bnw, 16 * s, C(0xF4F6FF)); c.rect(bx, by + 15 * s, bnw, s, C(0xC8D0E8))
        for k in 0..<4 { c.rect(bx + k * (bnw - 2 * s) / 3, by - s, 2 * s, 2 * s, C(0x8A94B4)) }
        hawkinsP6Centred(c, f.banner.x, by + 3 * s, bn, C(0x2A5AC8), 2 * s)
        for x in stride(from: bx + 2 * s, to: bx + bnw - 2 * s, by: 6 * s) { c.rect(x, by + 13 * s, 3 * s, s, C(0x8AB8F0)) }

        // The paper snowflakes on their threads: six arms, each with a little fork.
        for (k, fl) in f.flakes.enumerated() {
            c.rect(fl.x, tall ? fl.y - 30 * s : 0, s, tall ? 30 * s : fl.y, C(0xC8D0E8, 0.5))
            let r = (k % 3 == 0 ? 5 : 4) * s
            for a in 0..<6 {
                let ang = Double(a) * .pi / 3 + Double(k)
                for d in 0..<(r / s + 1) { c.rect(fl.x + Int(cos(ang) * Double(d * s)), fl.y + r + Int(sin(ang) * Double(d * s)), s, s, white) }
                let mx = fl.x + Int(cos(ang) * Double(r) * 0.6), my = fl.y + r + Int(sin(ang) * Double(r) * 0.6)
                c.rect(mx + Int(cos(ang + 1) * Double(s)), my + Int(sin(ang + 1) * Double(s)), s, s, white)
                c.rect(mx + Int(cos(ang - 1) * Double(s)), my + Int(sin(ang - 1) * Double(s)), s, s, white)
            }
        }

        // The bleachers, folded back: rows of wooden seat edges stacked up the wall, the end frame.
        let bl = f.bleachers
        c.rect(bl - 20 * s, g - 34 * s, 44 * s, 34 * s, C(0x3A2E48))
        for y in stride(from: g - 34 * s, to: g, by: 4 * s) { c.rect(bl - 20 * s, y, 44 * s, 2 * s, C(0x6A5468)); c.rect(bl - 20 * s, y, 44 * s, s, C(0x8A7088)) }
        c.rect(bl + 22 * s, g - 34 * s, 2 * s, 34 * s, C(0x5A6280)); c.rect(bl - 20 * s, g - 34 * s, 2 * s, 34 * s, C(0x5A6280))

        // The punch table: a white cloth to the floor, the bowl of red punch, paper cups, a plate of cookies.
        let pt = f.punch
        c.rect(pt - 16 * s, g - 14 * s, 32 * s, 14 * s, C(0xE8ECF8)); c.rect(pt - 16 * s, g - 14 * s, 32 * s, s, C(0xFFFFFF))
        for x in stride(from: pt - 14 * s, to: pt + 16 * s, by: 5 * s) { c.rect(x, g - 11 * s, s, 11 * s, C(0xC8D0E4)) }
        c.ellipse(pt - 4 * s, g - 17 * s, 7 * s, 3 * s, C(0xC8D8F0, 0.8)); c.ellipse(pt - 4 * s, g - 18 * s, 6 * s, s, C(0xC83A4A))
        for k in 0..<4 { c.rect(pt + 6 * s + k * 2 * s, g - 17 * s + (k % 2) * s, s, 3 * s - (k % 2) * s, C(0xF8F8F8)) }
        c.ellipse(pt - 12 * s, g - 15 * s, 3 * s, s, C(0xF8F8F8)); c.rect(pt - 14 * s, g - 16 * s, 4 * s, s, C(0xB88A4A))

        // The DJ's table: a dark cloth, the record player with a record on it, two speakers on stands, a cable.
        let dj = f.dj
        c.rect(dj - 14 * s, g - 14 * s, 28 * s, 14 * s, C(0x14182C)); c.rect(dj - 14 * s, g - 14 * s, 28 * s, s, C(0x3A4466))
        c.rect(dj - 10 * s, g - 17 * s, 16 * s, 3 * s, C(0x5A4A3A)); c.rect(dj - 10 * s, g - 17 * s, 16 * s, s, C(0x7A6A54))
        c.ellipse(dj - 3 * s, g - 17 * s, 5 * s, s, C(0x1A1A1A)); c.px(dj - 3 * s, g - 17 * s, C(0xE84A3A))
        c.rect(dj + 3 * s, g - 19 * s, s, 2 * s, C(0xB8B8C0))
        for sx in [dj - 22 * s, dj + 18 * s] {
            c.rect(sx - s, g - 14 * s, 2 * s, 14 * s, C(0x3A3A44))
            c.rect(sx - 5 * s, g - 28 * s, 10 * s, 14 * s, C(0x1A1A22)); c.rect(sx - 5 * s, g - 28 * s, 10 * s, s, C(0x3A3A48))
            c.circle(sx, g - 19 * s, 3 * s, C(0x2A2A34)); c.circle(sx, g - 25 * s, s, C(0x2A2A34))
        }

        // The balloons: clusters tied to weights on the floor, blue, white and silver, a highlight on each.
        for (k, bx0) in f.balloons.enumerated() {
            let cols = [blue, white, silver, C(0x3A6AD0)]
            for j in 0..<5 {
                let ax = bx0 + (j - 2) * 4 * s + Int(noise(k * 9 + j + 740) * Double(2 * s)), ay = g - (30 + abs(j - 2) * -2 + Int(noise(k * 9 + j + 750) * 6)) * s
                for d in stride(from: ay + 4 * s, to: g - 2 * s, by: s) { c.px(bx0 + (ax - bx0) * (g - d) / (g - ay), d, C(0xC8D0E8, 0.6)) }
                c.ellipse(ax, ay, 3 * s, 4 * s, cols[(j + k) % 4]); c.rect(ax - s, ay - 2 * s, s, s, C(0xFFFFFF, 0.8))
                c.rect(ax, ay + 4 * s, s, s, cols[(j + k) % 4])
            }
            c.rect(bx0 - 2 * s, g - 2 * s, 4 * s, 2 * s, C(0x8A94B4))
        }

        // The mirror ball, dark here (the moving layer lights its facets as it turns).
        c.circle(f.ball.x, f.ball.y, f.ball.r, C(0x5A6888))

        // The gym floor: dark boards in the blue light, plain, a lit edge.
        c.ground(g, C(0x342E44), edge: C(0x5A5070), speck: C(0x2E2A3E), seed: 151)
    }

    /// The Snow Ball's life: the mirror ball turning, its little square mirrors catching the light one after another,
    /// and the specks of light it throws sliding slowly round the walls.
    static func hawkinsSnowBallLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), b = hawkinsSnowBallFrame(c, g).ball
        let turn = t * 0.6
        // The specks of light: drifting round the walls in rows, wrapping.
        let top = isTall(c) ? hawkinsSnowBallRoof(c, g) + 2 * s : 0
        let n = max(18, c.w * (g - top) / (2200 * s * s))
        for k in 0..<n {
            let x = (noise(k * 3 + 800) * Double(c.w) + turn * Double(30 * s)).truncatingRemainder(dividingBy: Double(c.w))
            let y = top + Int(noise(k * 3 + 801) * Double(g - 10 * s - top))
            c.rect(Int(x), y, s, s, C(k % 3 == 0 ? 0xFFFFFF : 0xA8D0FF, 0.35 + noise(k * 3 + 802) * 0.3))
        }
        // The ball: a soft glow round it, then a grid of facets, each lit or dim as the ball turns.
        for (r, a) in [(16, 0.05), (10, 0.08)] { c.circle(b.x, b.y, r * s, C(0xC8E0FF, a)) }
        c.circle(b.x, b.y, b.r, C(0x8A98B8))
        for dy in stride(from: -b.r, to: b.r, by: 2 * s) {
            let half = Int((Double(b.r * b.r - dy * dy)).squareRoot())
            for dx in stride(from: -half, to: half, by: 2 * s) {
                let lit = noise((dx / (2 * s) + Int(turn * 4)) * 37 + dy / (2 * s) * 11 + 900)
                c.rect(b.x + dx, b.y + dy, s, s, lit > 0.55 ? C(0xFFFFFF) : lit > 0.25 ? C(0xC8D8F4) : C(0x5A6888))
            }
        }
        c.rect(b.x - b.r / 2, b.y - b.r / 2, s, s, C(0xFFFFFF))
    }
}

// MARK: - Benny's Burgers

extension Scenes {
    /// Where things stand at Benny's: the window and the booths under it, the counter, its stools, the back shelf, the
    /// menu board, the grill and its hood, the register.
    static func hawkinsBennysFrame(_ c: PixelCanvas, _ g: Int)
        -> (window: Int, booths: [Int], counter: (a: Int, b: Int), stools: [Int], menu: (x: Int, y: Int, w: Int), grill: Int) {
        let s = unit(g), a = c.w * 34 / 100, b = c.w * 74 / 100
        return (c.w * 15 / 100, [c.w * 8 / 100, c.w * 22 / 100], (a: a, b: b),
                Array(stride(from: a + 10 * s, to: b - 4 * s, by: 18 * s)), (x: (a + b) / 2, y: g - 61 * s, w: 112 * s), c.w * 87 / 100)
    }

    /// On the screen saver, where the ceiling fan hangs.
    static func hawkinsBennysFan(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int) {
        let s = unit(g)
        return (c.w * 38 / 100, max(22 * s, g - 170 * s) + 12 * s)
    }

    /// Benny's Burgers on a grey afternoon in 1983: a small diner, the walls cream above wood panelling with a red
    /// stripe between. On the left the booths in red vinyl under the window, its blinds half down on the woods and
    /// the lot outside, OPEN in red neon hanging in it; a clock on the wall. The counter along the middle, white top
    /// and chrome edge, red stools in front, a pie under a glass dome, the napkins, ketchup and mustard, the
    /// milkshake mixer, coffee pots on the burner behind; mugs on the back shelf, and over it the menu board, BENNY'S
    /// in yellow and the prices in white. On the right the kitchen end: the flat-top grill on its legs with burgers on
    /// it, the steel hood over it, the fryer beside it, the register at the end of the counter. A dark tiled floor. On
    /// the screen saver the room goes up to a tin ceiling with a fan turning and lamps hanging, a big BENNY'S BURGERS
    /// sign on the wall, a mounted fish and old photos of the town.
    static func hawkinsBennys(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsBennysFrame(c, g), tall = isTall(c)
        // The walls: cream, a red stripe, panelling below.
        let rail = g - 22 * s
        c.rect(0, 0, c.w, rail, C(0xD8C8A0))
        for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, 0, s, rail, C(0xD0C098)) }
        c.rect(0, rail, c.w, 3 * s, C(0xB8302A)); c.rect(0, rail, c.w, s, C(0xD84A3A))
        c.rect(0, rail + 3 * s, c.w, g - rail - 3 * s, C(0x6A4428))
        for x in stride(from: 0, to: c.w, by: 6 * s) { c.rect(x, rail + 3 * s, s, g - rail - 3 * s, C(0x5A3820)); c.rect(x + s, rail + 3 * s, s, g - rail - 3 * s, C(0x7A5232)) }

        if tall {
            // The tin ceiling, painted cream like the walls: pressed squares lit along the top and shaded underneath, a
            // cornice; the fan and the hanging lamps.
            let ct = max(22 * s, g - 170 * s)
            c.rect(0, 0, c.w, ct, C(0xB4A47C))
            // The pressed tin in rows, each row shallower than the one below it as the ceiling goes back, until they're
            // too shallow to read; the far ceiling beyond them plain, in shadow.
            var ry = ct - 4 * s, rh = 8 * s, row = 0
            while ry > 0 && rh >= 4 * s {
                let top = ry - rh
                c.rect(0, top, c.w, max(1, rh / 8), C(0x9A8A66))
                for x in stride(from: (row % 2) * 4 * s, to: c.w, by: 8 * s) {
                    c.rect(x + 2 * s, top + rh / 4, 4 * s, max(1, rh / 2), C(0xD8CAA2))
                    c.rect(x + 2 * s, top + rh / 4, 4 * s, max(1, rh / 8), C(0xF0E4C4))
                    c.rect(x + 2 * s, top + rh / 4 + max(1, rh / 2) - max(1, rh / 8), 4 * s, max(1, rh / 8), C(0xA89670))
                }
                ry = top; rh = max(2, rh * 7 / 8); row += 1
            }
            c.rect(0, ct - 4 * s, c.w, 4 * s, C(0x8A6A48)); c.rect(0, ct - 4 * s, c.w, s, C(0xA88A62))
            // A frieze of red and cream checks under the cornice.
            for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, ct + (x / (4 * s)) % 2 * 2 * s, 4 * s, 2 * s, C(0xB8302A)) }
            c.rect(0, ct + 4 * s, c.w, s, C(0x8A6A48))
            // A Hawkins Tigers pennant, orange on black.
            let pnx = c.w * 6 / 100, pny = g - 128 * s
            for y in 0..<(15 * s) { c.rect(pnx, pny + y, 54 * s - y * 54 / 15, 1, C(0x1A1A1A)) }
            c.rect(pnx, pny, 2 * s, 15 * s, C(0xE87A2A))
            hawkinsP6Sign(c, pnx + 4 * s, pny + 4 * s, "TIGERS", C(0xF08A2A), s)
            for lx in [c.w * 20 / 100, c.w * 56 / 100, c.w * 84 / 100] {
                c.rect(lx, ct, s, 30 * s, C(0x3A3A3A))
                for y in 0..<(6 * s) { let half = 2 * s + y; c.rect(lx - half, ct + 30 * s + y, half * 2 + s, 1, C(0x2A6A3A)) }
                c.rect(lx - 7 * s, ct + 36 * s, 15 * s, s, C(0x1A4A2A)); c.circle(lx, ct + 38 * s, 2 * s, C(0xFFF0C0))
            }
            let fx = hawkinsBennysFan(c, g)
            c.rect(fx.x, ct, s, fx.y - ct, C(0x3A3A3A)); c.rect(fx.x - 2 * s, fx.y, 5 * s, 4 * s, C(0x5A4A3A))
            // The BENNY'S BURGERS sign: painted boards, red letters on cream, a burger at each end.
            let sy = g - 120 * s, bw = hawkinsP6Width("BENNY'S BURGERS", 3 * s) + 40 * s, sx = c.w / 2
            c.rect(sx - bw / 2, sy, bw, 24 * s, C(0x5A3820)); c.rect(sx - bw / 2 + 2 * s, sy + 2 * s, bw - 4 * s, 20 * s, C(0xF0E4C4))
            hawkinsP6Centred(c, sx, sy + 5 * s, "BENNY'S BURGERS", C(0xB8302A), 3 * s)
            for bx0 in [sx - bw / 2 + 10 * s, sx + bw / 2 - 10 * s] {
                c.ellipse(bx0, sy + 9 * s, 6 * s, 3 * s, C(0xD89A4A)); c.rect(bx0 - 6 * s, sy + 11 * s, 12 * s, 2 * s, C(0x4AA03A))
                c.rect(bx0 - 6 * s, sy + 13 * s, 12 * s, 2 * s, C(0x5A3020)); c.rect(bx0 - 6 * s, sy + 15 * s, 12 * s, 2 * s, C(0xD89A4A))
            }
            // A mounted fish on a plaque, and old photos of the town in frames.
            let mx = c.w * 14 / 100, my = g - 84 * s
            c.rect(mx - 14 * s, my, 28 * s, 14 * s, C(0x6A4428)); c.rect(mx - 14 * s, my, 28 * s, s, C(0x8A6038))
            c.ellipse(mx, my + 7 * s, 10 * s, 4 * s, C(0x5A8A6A)); c.ellipse(mx - 2 * s, my + 6 * s, 8 * s, 2 * s, C(0x8AB89A))
            for d in 0..<(4 * s) { c.rect(mx + 10 * s + d, my + 7 * s - d, s, d * 2 + s, C(0x5A8A6A)) }
            c.rect(mx - 7 * s, my + 6 * s, s, s, C(0x1A1A1A))
            for (k, px) in [c.w * 70 / 100, c.w * 80 / 100, c.w * 90 / 100].enumerated() {
                let py = g - 86 * s + (k % 2) * 4 * s
                c.rect(px - 6 * s, py, 12 * s, 14 * s, C(0x2A2A2A)); c.rect(px - 5 * s, py + s, 10 * s, 12 * s, C(0xC8BCA0))
                c.rect(px - 4 * s, py + 7 * s, 8 * s, 5 * s, C(0x8A7A60)); c.circle(px, py + 5 * s, 2 * s, C(0x7A6A52))
            }
        }

        // The window over the booths: the frame, the woods and the lot outside, the blinds half down, OPEN in neon.
        let wx = f.window, wy = g - 48 * s, ww = 52 * s, wh = 24 * s
        c.rect(wx - ww / 2 - 2 * s, wy - 2 * s, ww + 4 * s, wh + 4 * s, C(0x6A4428))
        c.gradient(wy, wy + wh / 2, C(0xA8B8C8), C(0xC8D0D8), bands: 2)
        c.rect(0, wy, wx - ww / 2, wh, C(0xD8C8A0)); c.rect(wx + ww / 2, wy, c.w, wh, C(0xD8C8A0))
        for x in stride(from: 0, to: c.w, by: 4 * s) where x < wx - ww / 2 - 2 * s || x > wx + ww / 2 + 2 * s { c.rect(x, wy - 2 * s, s, wh + 4 * s, C(0xD0C098)) }
        for k in 0..<7 { let tx = wx - ww / 2 + 3 * s + k * 8 * s; c.ellipse(tx, wy + 12 * s, 5 * s, 6 * s, k % 2 == 0 ? C(0x3A5A3A) : C(0x4A6A42)) }
        c.rect(wx - ww / 2, wy + 16 * s, ww, 8 * s, C(0x6A6A6A)); c.rect(wx - ww / 2, wy + 16 * s, ww, s, C(0x8A8A8A))
        c.rect(wx + 6 * s, wy + 17 * s, 16 * s, 5 * s, C(0x7A3A2A)); c.rect(wx + 9 * s, wy + 15 * s, 9 * s, 3 * s, C(0x6A2A22))
        c.rect(wx - ww / 2, wy, ww, 9 * s, C(0xE8DCC0))
        for y in stride(from: wy + s, to: wy + 9 * s, by: 2 * s) { c.rect(wx - ww / 2, y, ww, s, C(0xC8BCA0)) }
        c.rect(wx - s / 2, wy, max(1, s), wh, C(0x6A4428))
        let op = "OPEN", opw = hawkinsP6Width(op, s) + 4 * s
        c.rect(wx - ww / 4 - opw / 2, wy + 11 * s, opw, 9 * s, C(0x1A1A1A, 0.7))
        hawkinsP6Centred(c, wx - ww / 4, wy + 13 * s, op, C(0xFF4A3A), s)

        // A clock on the wall between the window and the counter.
        let clx = c.w * 32 / 100, cly = g - 42 * s
        c.circle(clx, cly, 6 * s, C(0x2A2A2A)); c.circle(clx, cly, 5 * s, C(0xF4F0E4))
        c.rect(clx, cly - 4 * s, s, 4 * s, C(0x1A1A1A)); c.rect(clx, cly, 3 * s, s, C(0x1A1A1A))

        // The booths: high red backs, seats, a table between with the sugar and the salt.
        for (k, bx) in f.booths.enumerated() {
            for side in [-1, 1] {
                let backX = bx + side * 12 * s - (side < 0 ? 0 : 5 * s)
                c.rect(backX, g - 26 * s, 5 * s, 26 * s, C(0xA82A26)); c.rect(backX, g - 26 * s, 5 * s, s, C(0xD84A3A))
                c.rect(backX + (side < 0 ? 4 : 0) * s, g - 26 * s, s, 26 * s, C(0x7A1E1A))
                let seatX = side < 0 ? backX + 5 * s : backX - 6 * s
                c.rect(seatX, g - 11 * s, 6 * s, 3 * s, C(0xC83A30)); c.rect(seatX, g - 11 * s, 6 * s, s, C(0xE85A4A))
                c.rect(seatX, g - 8 * s, 6 * s, 8 * s, C(0x6A3420))
            }
            c.rect(bx - 6 * s, g - 16 * s, 12 * s, 2 * s, C(0xE8E4D8)); c.rect(bx - 6 * s, g - 14 * s, 12 * s, s, C(0xA8A8A8))
            c.rect(bx - s, g - 13 * s, 2 * s, 13 * s, C(0x8A8A92)); c.rect(bx - 4 * s, g - s, 8 * s, s, C(0x6A6A72))
            c.rect(bx - 3 * s, g - 19 * s, 2 * s, 3 * s, C(0xE8E8F0)); c.rect(bx + s, g - 18 * s, s, 2 * s, C(0xE8E8F0)); c.rect(bx + 3 * s, g - 18 * s, s, 2 * s, C(0x3A3A3A))
            if k == 1 { c.rect(bx - 5 * s, g - 17 * s, 4 * s, s, C(0xF8F8F8)) }
        }

        // The back shelf with its mugs, and the menu board over it.
        let ct = f.counter, m = f.menu
        c.rect(ct.a, g - 34 * s, ct.b - ct.a, 2 * s, C(0x6A4428)); c.rect(ct.a, g - 34 * s, ct.b - ct.a, s, C(0x8A6038))
        for x in stride(from: ct.a + 4 * s, to: ct.b - 4 * s, by: 6 * s) { c.rect(x, g - 38 * s, 3 * s, 4 * s, x / (6 * s) % 3 == 0 ? C(0xC83A30) : C(0xF0ECE0)); c.rect(x + 3 * s, g - 37 * s, s, 2 * s, C(0xD8D4C8)) }
        c.rect(m.x - m.w / 2, m.y, m.w, 25 * s, C(0x5A3820)); c.rect(m.x - m.w / 2 + 2 * s, m.y + 2 * s, m.w - 4 * s, 21 * s, C(0x1A1A1C))
        hawkinsP6Centred(c, m.x, m.y + 4 * s, "BENNY'S", C(0xF8D040), 2 * s)
        // The prices: an item on the left of each half, its price at the right of it.
        for (k, (item, price)) in [("BURGER", "1.25"), ("SHAKE", ".90")].enumerated() {
            let x0 = m.x - m.w / 2 + 5 * s + k * m.w / 2, x1 = m.x + (k == 0 ? -4 * s : m.w / 2 - 5 * s)
            hawkinsP6Sign(c, x0, m.y + 15 * s, item, C(0xF0F0F0), s)
            hawkinsP6Sign(c, x1 - hawkinsP6Width(price, s), m.y + 15 * s, price, C(0xF8D040), s)
        }

        // The coffee pots on their burner, the milkshake mixer.
        let cpx = ct.b - 18 * s
        c.rect(cpx - 8 * s, g - 24 * s, 16 * s, 3 * s, C(0x2A2A2E))
        for dx in [-5, 2] { c.rect(cpx + dx * s, g - 29 * s, 4 * s, 5 * s, C(0x4A2A1A, 0.85)); c.rect(cpx + dx * s, g - 30 * s, 4 * s, s, C(0x1A1A1A)); c.rect(cpx + (dx + 4) * s, g - 28 * s, s, 2 * s, C(0x1A1A1A)) }

        // The counter: the front in wood with a red band, a white top with a chrome edge; on it the pie under its
        // dome, the napkins, the ketchup and mustard, the mixer.
        c.rect(ct.a, g - 18 * s, ct.b - ct.a, 18 * s, C(0x7A4A2A))
        for x in stride(from: ct.a, to: ct.b, by: 8 * s) { c.rect(x, g - 15 * s, s, 15 * s, C(0x5A3820)) }
        c.rect(ct.a, g - 12 * s, ct.b - ct.a, 2 * s, C(0xB8302A))
        c.rect(ct.a - 2 * s, g - 20 * s, ct.b - ct.a + 4 * s, 3 * s, C(0xF0ECE0)); c.rect(ct.a - 2 * s, g - 17 * s, ct.b - ct.a + 4 * s, s, C(0xB8BCC4))
        let pie = ct.a + 14 * s
        c.rect(pie - 6 * s, g - 21 * s, 12 * s, s, C(0xB8BCC4)); c.ellipse(pie, g - 23 * s, 5 * s, 2 * s, C(0xD8A050)); c.rect(pie - 5 * s, g - 23 * s, 10 * s, 2 * s, C(0xC8803A))
        c.ellipse(pie, g - 24 * s, 6 * s, 5 * s, C(0xE8F0F8, 0.3)); c.rect(pie - s, g - 30 * s, 2 * s, s, C(0xC8D0D8))
        let nap = ct.a + 40 * s
        c.rect(nap - 3 * s, g - 25 * s, 6 * s, 5 * s, C(0xB8BCC4)); c.rect(nap - 2 * s, g - 25 * s, 4 * s, 2 * s, C(0xF8F8F8))
        c.rect(nap + 5 * s, g - 26 * s, 2 * s, 6 * s, C(0xC82A22)); c.rect(nap + 8 * s, g - 26 * s, 2 * s, 6 * s, C(0xE8C030))
        let mix = ct.a + (ct.b - ct.a) * 2 / 3
        c.rect(mix - 3 * s, g - 21 * s, 6 * s, s, C(0x6AA88A)); c.rect(mix - 2 * s, g - 32 * s, 4 * s, 11 * s, C(0x6AA88A)); c.rect(mix - 3 * s, g - 33 * s, 6 * s, 3 * s, C(0x6AA88A))
        c.rect(mix + 2 * s, g - 30 * s, 3 * s, 8 * s, C(0xC8D0D8)); c.rect(mix - 2 * s, g - 32 * s, s, 11 * s, C(0x8AC8A8))

        // The stools: red seats on chrome posts.
        for sx in f.stools {
            c.rect(sx - 4 * s, g - 11 * s, 8 * s, 2 * s, C(0xC83A30)); c.rect(sx - 4 * s, g - 11 * s, 8 * s, s, C(0xE85A4A))
            c.rect(sx - s, g - 9 * s, 2 * s, 8 * s, C(0xC8CCD4)); c.rect(sx - 3 * s, g - s, 6 * s, s, C(0x9A9EA6))
        }

        // The kitchen end: the hood, the grill on its legs (its top hot, the burgers on it), the fryer, the register.
        let gx = f.grill
        c.rect(gx - 20 * s, g - 50 * s, 40 * s, 10 * s, C(0xA8ACB4)); c.rect(gx - 20 * s, g - 50 * s, 40 * s, s, C(0xC8CCD4))
        for y in 0..<(4 * s) { c.rect(gx - 20 * s - y / 2, g - 40 * s + y, 40 * s + y, 1, C(0x8A8E96)) }
        c.rect(gx - 4 * s, 0, 8 * s, g - 50 * s, C(0x9A9EA6)); c.rect(gx - 4 * s, 0, s, g - 50 * s, C(0xB8BCC4))
        c.rect(gx - 18 * s, g - 22 * s, 30 * s, 3 * s, C(0x2A2A2E)); c.rect(gx - 18 * s, g - 22 * s, 30 * s, s, C(0x4A4A50))
        c.rect(gx - 18 * s, g - 19 * s, 30 * s, 8 * s, C(0xA8ACB4)); for k in 0..<4 { c.circle(gx - 14 * s + k * 7 * s, g - 15 * s, s, C(0x2A2A2E)) }
        c.rect(gx - 17 * s, g - 11 * s, 2 * s, 11 * s, C(0x8A8E96)); c.rect(gx + 9 * s, g - 11 * s, 2 * s, 11 * s, C(0x8A8E96))
        for k in 0..<3 { c.ellipse(gx - 12 * s + k * 8 * s, g - 23 * s, 3 * s, s, C(0x5A2E1A)) }
        c.rect(gx + 2 * s, g - 30 * s, s, 8 * s, C(0x4A4A50)); c.rect(gx + s, g - 24 * s, 4 * s, s, C(0xC8CCD4))   // the spatula hanging
        let fr = gx + 18 * s
        c.rect(fr - 5 * s, g - 22 * s, 10 * s, 22 * s, C(0x9A9EA6)); c.rect(fr - 5 * s, g - 22 * s, 10 * s, s, C(0xC8CCD4))
        c.rect(fr - 4 * s, g - 24 * s, 8 * s, 2 * s, C(0xD8B040)); c.rect(fr - 3 * s, g - 28 * s, s, 4 * s, C(0x5A5A60))
        let rg = ct.b - 6 * s
        c.rect(rg - 6 * s, g - 28 * s, 12 * s, 8 * s, C(0x8A8A82)); c.rect(rg - 6 * s, g - 28 * s, 12 * s, s, C(0xB8B8B0))
        c.rect(rg - 4 * s, g - 32 * s, 8 * s, 4 * s, C(0x6A6A62)); c.rect(rg - 3 * s, g - 31 * s, 6 * s, 2 * s, C(0x3AC86A, 0.8))
        for k in 0..<3 { c.rect(rg - 5 * s + k * 4 * s, g - 25 * s, 2 * s, s, C(0xE8E8E0)) }

        // The floor: dark tiles, plain, a lit edge.
        c.ground(g, C(0x3E2422), edge: C(0x5E3A32), speck: C(0x36201E), seed: 161)
    }

    /// Benny's life: the burgers sizzling on the grill, fat spitting up in little bright specks, steam curling up
    /// into the hood and thinning out; the OPEN sign's glow.
    static func hawkinsBennysLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsBennysFrame(c, g), gx = f.grill
        let frame = Int(t * 14)
        for k in 0..<3 {
            let bx = gx - 12 * s + k * 8 * s
            for j in 0..<3 where noise(frame * 7 + k * 3 + j) > 0.55 {
                c.rect(bx - 3 * s + Int(noise(frame * 11 + k * 5 + j) * Double(6 * s)), g - 24 * s - Int(noise(frame * 13 + k + j) * Double(3 * s)), s, s, C(0xFFE8A0, 0.9))
            }
            for j in 0..<5 {
                let ph = (t * 0.5 + Double(j) * 0.2 + Double(k) * 0.33).truncatingRemainder(dividingBy: 1)
                let y = g - 24 * s - Int(ph * Double(15 * s)), x = bx + Int(sin(ph * 6 + Double(k)) * Double(2 * s))
                c.rect(x, y, 2 * s, s, C(0xF0F0F0, 0.35 * (1 - ph)))
            }
        }
        let wx = f.window, wy = g - 48 * s
        c.rect(wx - 52 * s / 4 - 7 * s, wy + 10 * s, 14 * s, 11 * s, C(0xFF4A3A, 0.08 + 0.03 * sin(t * 2)))
        // On the screen saver the fan turning: two blades, foreshortened as they go round.
        if isTall(c) {
            let fan = hawkinsBennysFan(c, g), a = t * 3
            for k in 0..<2 {
                let len = Int(abs(cos(a + Double(k) * .pi / 2)) * Double(16 * s)) + 2 * s
                c.rect(fan.x - len, fan.y + 3 * s + k * s, len * 2 + s, s, C(0x5A3A22))
            }
        }
    }
}
