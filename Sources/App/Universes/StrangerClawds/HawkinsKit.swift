import Foundation

// Stranger Clawds' shared drawing bits, used across its Art files: the geometry for things swung (Steve's bat, Joyce's
// axe, Billy's fists, the monsters' claws and tendrils) and the signature moves' timing. Everything here starts with
// `hawkins`, so nothing clashes with another universe's helpers in the tools that compile every universe together.

private let hawkinsNone = C(0, 0)

/// A point `d` pixels out from `h` at `angle` degrees (0 forward, -90 straight up).
func hawkinsReach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
func hawkinsLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: hawkinsNone, coreR: r, glowR: r + 0.1)
}

/// A solid bar along `angle`, from `a` to `b` pixels out from `h` (a bat, an axe's haft, an arm).
func hawkinsBar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, from a: Double, to b: Double, _ col: Px,
                r: Double = 0.8) {
    let p0 = hawkinsReach(h, angle, a), p1 = hawkinsReach(h, angle, b)
    hawkinsLine(c, p0.x, p0.y, p1.x, p1.y, col, r)
}

/// The fading smear a fast swing leaves behind it.
func hawkinsSmear(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ trail: [Double], from a: Double, to b: Double, _ col: Px) {
    for (i, angle) in trail.enumerated() {
        let p0 = hawkinsReach(h, angle, a), p1 = hawkinsReach(h, angle, b)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: col, glow: col, coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
}

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
func hawkinsSpan(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// How far into a move that eases in over its first `edge` and out over its last (0 outside it, 1 in the middle).
func hawkinsEase(_ k: Double, edge: Double = 0.2) -> Double {
    guard k >= 0 else { return 0 }
    return min(1, k / edge) * min(1, (1 - k) / edge)
}

/// Where a foot is this frame: the bottom row of leg `i` (0…3, back to front), a row higher while it's lifted.
func hawkinsFoot(_ p: Pose, _ i: Int) -> Int { p.step >= 0 && i % 2 == p.step ? 42 : 43 }

/// A revolver in the right hand (the arm, at (38, 33), is the caller's): a dark frame lit along the top, the cylinder
/// catching the light, a wooden grip; its muzzle at (47, 32), as `Persona.muzzle` has it.
func hawkinsRevolver(_ c: PixelCanvas, x: Int = 40, y: Int = 31) {
    c.pattern(x, y, ["KKKKKKK", "KCcKKK.", "WW.....", "WW....."],
              ["K": C(0x2A2A30), "C": C(0x9A9EA8), "c": C(0x5A5E68), "W": C(0x6A4424)])
    c.rect(x + 1, y, 5, 1, C(0x4E4E58))
}

/// Blocky lettering with its steps eased a little: `text` in `glyphs` (each a string of 0s and 1s, `rows` dots high,
/// read row by row), `p` pixels a dot, from its top-left corner, a dot's gap between letters and three dots for
/// anything not in `glyphs` (a space). Wherever two dots touch only at a corner (a diagonal, the turn of a curve) the
/// two empty dots beside that corner get a small triangle filled in, `ease` dots along each side, so the step reads
/// as a slope. The pixels it touches are worked out at 4×4 samples each and drawn at that coverage, but kept close to
/// pixel art: anything under a quarter covered stays clear and anything over 0.8 goes solid, so only the odd pixel
/// on a slope comes out in between. Straight edges, square ends and inside corners stay exactly as the blocks were.
func hawkinsSoftText(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ glyphs: [Character: String], _ col: Px,
                     _ p: Int, rows: Int = 5, ease: Double = 1) {
    // The word laid out as one grid of dots.
    var cols: [[Bool]] = []
    for ch in text {
        if let bits = glyphs[ch] {
            let w = bits.count / rows, b = Array(bits)
            for i in 0..<w { cols.append((0..<rows).map { b[$0 * w + i] == "1" }) }
            cols.append([Bool](repeating: false, count: rows))
        } else {
            cols += [[Bool]](repeating: [Bool](repeating: false, count: rows), count: 3)
        }
    }
    guard !cols.isEmpty, p > 0 else { return }
    let gw = cols.count
    func on(_ i: Int, _ j: Int) -> Bool { i >= 0 && j >= 0 && i < gw && j < rows && cols[i][j] }
    // Whether the point (u, v), in dots from the top-left, is ink.
    func ink(_ u: Double, _ v: Double) -> Bool {
        let i = Int(u.rounded(.down)), j = Int(v.rounded(.down))
        if on(i, j) { return true }
        let fu = u - Double(i), fv = v - Double(j)
        let dx = fu < 0.5 ? -1 : 1, dy = fv < 0.5 ? -1 : 1
        let du = dx < 0 ? fu : 1 - fu, dv = dy < 0 ? fv : 1 - fv
        // An empty dot's corner: filled only where the dots on both sides of it are ink and the one across it isn't.
        return du + dv < ease && on(i + dx, j) && on(i, j + dy) && !on(i + dx, j + dy)
    }
    let n = 4
    for py in 0..<(rows * p) {
        for px in 0..<(gw * p) {
            // A dot is whole pixels, so a pixel in an inked dot is simply solid.
            if cols[px / p][py / p] { c.px(x + px, y + py, col); continue }
            var hit = 0
            for sy in 0..<n {
                for sx in 0..<n {
                    let u = (Double(px) + (Double(sx) + 0.5) / Double(n)) / Double(p)
                    let v = (Double(py) + (Double(sy) + 0.5) / Double(n)) / Double(p)
                    if ink(u, v) { hit += 1 }
                }
            }
            let k = Double(hit) / Double(n * n)
            if k < 0.25 { continue }
            c.px(x + px, y + py, k > 0.8 ? col : col.alpha(k))
        }
    }
}
