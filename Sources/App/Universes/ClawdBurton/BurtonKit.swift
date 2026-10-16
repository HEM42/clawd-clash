import Foundation

// Clawd Burton's shared drawing bits, used across its Art and Places files: black-and-white stripes, the spiral (on a
// lollipop, a hat band, Spiral Hill), stitches, HEM's crooked top hat and his lollipop. Everything here is prefixed
// `burton` so it can't clash with another universe's private helpers in the tools that compile every universe together.

let burtonBone = C(0xF2EEE3), burtonInk = C(0x16161B), burtonViolet = C(0x6B5BD6)
private let burtonNone = C(0, 0)

/// A point `d` pixels out from `h` at `angle` degrees.
func burtonReach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
func burtonLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: burtonNone, coreR: r, glowR: r + 0.1)
}

/// Black-and-white stripes over a box, `width` pixels each, changing along x (`alongX`, upright stripes) or along y.
func burtonStripes(_ c: PixelCanvas, _ x: Int, _ y: Int, _ w: Int, _ h: Int, alongX: Bool, width: Int = 2,
                   light: Px = burtonBone, dark: Px = burtonInk) {
    for yy in y..<(y + h) {
        for xx in x..<(x + w) {
            let k = alongX ? xx - x : yy - y
            c.px(xx, yy, (k / width) % 2 == 0 ? dark : light)
        }
    }
}

/// A row of cross-stitches from (x, y), `n` of them `gap` pixels apart, along x or down y.
func burtonStitches(_ c: PixelCanvas, _ x: Int, _ y: Int, n: Int, gap: Int = 2, down: Bool = false, _ col: Px) {
    for i in 0..<n {
        let sx = down ? x : x + i * gap, sy = down ? y + i * gap : y
        if down { c.px(sx - 1, sy, col); c.px(sx + 1, sy, col); c.px(sx, sy, col) } else { c.px(sx, sy - 1, col); c.px(sx, sy + 1, col); c.px(sx, sy, col) }
    }
}

/// A disc of radius `r` round (cx, cy) with two spiral arms in `a` and `b` winding into the middle (a lollipop, a
/// hypnotic swirl); `turn` spins it (one whole turn per 1).
func burtonSpiralDisc(_ c: PixelCanvas, _ cx: Double, _ cy: Double, r: Double, _ a: Px, _ b: Px, turn: Double = 0) {
    for y in Int((cy - r - 1).rounded(.down))...Int((cy + r + 1).rounded(.up)) {
        for x in Int((cx - r - 1).rounded(.down))...Int((cx + r + 1).rounded(.up)) {
            let dx = Double(x) + 0.5 - cx, dy = Double(y) + 0.5 - cy
            let d = (dx * dx + dy * dy).squareRoot()
            guard d <= r else { continue }
            let arm = (atan2(dy, dx) / (2 * .pi) + turn + d / r * 1.1) * 2
            c.px(x, y, (Int(arm.rounded(.down)) % 2 + 2) % 2 == 0 ? a : b)
        }
    }
}

/// Spiral Hill's shape, in one colour: a slope rising from the ground on the left, standing `h` rows tall over
/// `w` columns from `x`, its tip curling up and back over itself into a spiral (the hill Jack sings on).
func burtonSpiralHill(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, _ col: Px) {
    let hh = Double(h), ww = Double(w)
    let rad = hh * 0.29, cx = Double(x) + ww * 0.6, cy = Double(base) - hh + rad
    let rampTop = cy + rad
    // The hill under the curl: up from the left in a ski-jump curve, down again on the right.
    for k in 0..<w {
        let y0 = burtonSpiralHillTop(x: x, base: base, w: w, h: h, at: x + k)
        if y0 < base { c.rect(x + k, y0, 1, base - y0, col) }
    }
    // The curl: one and a third turns, tightening, thinner as it winds in.
    let turns = 2.6 * Double.pi, thick = max(1.2, hh * 0.11)
    let n = max(24, Int(rad * 10))
    var prev = (x: cx, y: rampTop)
    for i in 1...n {
        let f = Double(i) / Double(n), phi = -Double.pi / 2 + f * turns
        let r = rad * (1 - 0.78 * f)
        let q = (x: cx + r * cos(phi), y: cy - r * sin(phi))
        burtonLine(c, prev.x, prev.y, q.x, q.y, col, max(0.6, thick * (1 - 0.7 * f) / 2))
        prev = q
    }
}

/// The top row of Spiral Hill's slope (not its curl) at column `px`, for things standing on it: graves, pumpkins.
func burtonSpiralHillTop(x: Int, base: Int, w: Int, h: Int, at px: Int) -> Int {
    let hh = Double(h), ww = Double(w)
    let rad = hh * 0.29, cx = Double(x) + ww * 0.6, rampTop = Double(base) - hh + 2 * rad
    let p = Double(px) + 0.5
    guard p > Double(x), p < Double(x) + ww else { return base }
    let top = p <= cx ? Double(base) - (Double(base) - rampTop) * pow((p - Double(x)) / (cx - Double(x)), 1.7)
                      : rampTop + (Double(base) - rampTop) * pow((p - cx) / (Double(x) + ww - cx), 1.4)
    return Int(top.rounded())
}

/// HEM's crooked black top hat, its crown leaning off true as it rises, a violet band with a little bone-white
/// spiral on it, the brim on row `brimY`.
func burtonTopHat(_ c: PixelCanvas, x: Int = 22, brimY: Int = 21) {
    let felt = C(0x1A181E), shine = C(0x3A3644), under = C(0x0C0B10)
    for r in 0..<9 {   // the crown, from the top down
        let y = brimY - 9 + r, lean = (8 - r) / 3
        c.rect(x + lean, y, 12, 1, felt); c.px(x + lean + 2, y, shine)
    }
    c.rect(x, brimY - 3, 12, 3, burtonViolet)
    c.pattern(x + 7, brimY - 3, ["BBB", "..B", "B.B"], ["B": burtonBone])
    c.rect(x - 4, brimY, 20, 1, felt); c.rect(x - 5, brimY + 1, 22, 1, under)
}

/// HEM's big spiral lollipop, held from `from` along `angle`: a white stick and the swirl on its end, with faint
/// copies where a fast swing just was.
func burtonLollipop(_ c: PixelCanvas, angle: Double, trail: [Double], from h: (x: Double, y: Double) = Sprite.hand) {
    for (i, a) in trail.enumerated() {
        let e = burtonReach(h, a, 13)
        c.circle(Int(e.x.rounded()), Int(e.y.rounded()), 4, burtonViolet.alpha(0.3 / Double(i + 1)))
    }
    let s0 = burtonReach(h, angle, -1), s1 = burtonReach(h, angle, 9)
    burtonLine(c, s0.x, s0.y, s1.x, s1.y, C(0xE8E4DA), 0.6)
    let e = burtonReach(h, angle, 13)
    burtonSpiralDisc(c, e.x, e.y, r: 4.5, burtonViolet, burtonBone)
}

/// A filled triangle between three points (spikes, bat wings, pennants).
func burtonTriangle(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double), _ col: Px) {
    let x0 = Int(min(a.0, b.0, d.0).rounded(.down)), x1 = Int(max(a.0, b.0, d.0).rounded(.up))
    let y0 = Int(min(a.1, b.1, d.1).rounded(.down)), y1 = Int(max(a.1, b.1, d.1).rounded(.up))
    func side(_ p: (Double, Double), _ q: (Double, Double), _ r: (Double, Double)) -> Double {
        (p.0 - r.0) * (q.1 - r.1) - (q.0 - r.0) * (p.1 - r.1)
    }
    for y in y0...y1 {
        for x in x0...x1 {
            let p = (Double(x) + 0.5, Double(y) + 0.5)
            let s1 = side(p, a, b), s2 = side(p, b, d), s3 = side(p, d, a)
            if (s1 >= 0 && s2 >= 0 && s3 >= 0) || (s1 <= 0 && s2 <= 0 && s3 <= 0) { c.px(x, y, col) }
        }
    }
}
