import Foundation

// The edges of the map: the "Welcome to Sunnydale" sign by night, the crater it falls into at the end, the First
// Slayer's dream desert, and Los Angeles (the Hyperion, Caritas, Wolfram & Hart). Each has its own key colour, none of
// them the navy of a plain night: the sign's sodium-orange street lamp, the crater's rose-gold dawn, the desert's red
// rock under a bleached sky, the Hyperion's jade and brass, Caritas's teal velvet and coral spotlights, and Wolfram &
// Hart's icy glass over the city's gold lights.
let slayerScenes4: [Location: Place] = [
    .slayerTownSign: Place(name: "Welcome to Sunnydale", panel: 0x1A120C, still: Scenes.slayerTownSign,
                           moving: Scenes.slayerTownSignLife),
    .slayerCrater: Place(name: "The Sunnydale Crater", panel: 0x2A1C14, still: Scenes.slayerCrater,
                         moving: Scenes.slayerCraterLife),
    .slayerDreamDesert: Place(name: "The Dream Desert", panel: 0x2A120A, still: Scenes.slayerDreamDesert,
                              moving: Scenes.slayerDreamDesertLife),
    .slayerHyperion: Place(name: "The Hyperion Hotel", panel: 0x0E1E1A, still: Scenes.slayerHyperion,
                           moving: Scenes.slayerHyperionLife),
    .slayerCaritas: Place(name: "Caritas", panel: 0x081818, still: Scenes.slayerCaritas, moving: Scenes.slayerCaritasLife),
    .slayerWolframHart: Place(name: "Wolfram & Hart", panel: 0x101418, still: Scenes.slayerWolframHart,
                              moving: Scenes.slayerWolframHartLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 3×5 alphabet, only the letters the signs here need.
private let slayerLetters4: [Character: String] = [
    "A": "010101111101101", "C": "011100100100011", "D": "110101101101110", "E": "111100110100111",
    "H": "101101111101101", "I": "111010010010111", "L": "100100100100111", "M": "101111111101101",
    "N": "110101101101101", "O": "010101101101010", "P": "110101110100100", "R": "110101110101101",
    "S": "011100010001110", "T": "111010010010010", "U": "101101101101111", "W": "101101111111101",
    "Y": "101101010010010",
]

/// How wide `text` comes out at `p` pixels a dot.
private func slayerTextWidth4(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + ($1 == " " ? 3 : 4) * p } - p
}

/// Lettering in the blocky alphabet, `p` pixels a dot, from its top-left corner.
private func slayerText4(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    var cx = x
    for ch in text {
        guard let bits = slayerLetters4[ch] else { cx += 3 * p; continue }
        for (i, b) in bits.enumerated() where b == "1" { c.rect(cx + (i % 3) * p, y + (i / 3) * p, p, p, col) }
        cx += 4 * p
    }
}

/// A wedge of light from row `top` (half-width `h0`, centred on x) down to row `bottom` (half-width `h1`), its centre
/// drifting `lean` pixels a row.
private func slayerWedge4(_ c: PixelCanvas, _ x: Int, _ top: Int, _ bottom: Int, _ h0: Int, _ h1: Int, _ col: Px,
                          lean: Double = 0) {
    guard bottom > top else { return }
    let n = Double(bottom - top)
    for y in top..<bottom {
        let k = Double(y - top) / n
        let half = Int(Double(h0) + Double(h1 - h0) * k), cx = x + Int(lean * Double(y - top))
        c.rect(cx - half, y, 2 * half + 1, 1, col)
    }
}

/// A circle drawn only on the rows above `limit` (a sun behind a horizon).
private func slayerDiscAbove4(_ c: PixelCanvas, _ cx: Int, _ cy: Int, _ r: Int, _ limit: Int, _ col: Px) {
    guard r > 0 else { return }
    for dy in -r...r where cy + dy < limit {
        let half = Int((Double(r * r - dy * dy)).squareRoot().rounded())
        c.rect(cx - half, cy + dy, half * 2 + 1, 1, col)
    }
}

/// A desert butte standing on `base`: scree slopes either side up to a sheer cliff with a ragged top, the right side in
/// shade and a few broken ledges across its face.
private func slayerButte4(_ c: PixelCanvas, x: Int, w: Int, h: Int, base: Int, _ col: Px, _ shade: Px, seed: Int, _ s: Int) {
    guard w > 4, h > 2 else { return }

    for i in 0..<w {
        let u = Double(i) / Double(w)
        let lift: Double
        if u < 0.22 { lift = u / 0.22 * 0.5 } else if u > 0.8 { lift = (1 - u) / 0.2 * 0.5 } else { lift = 1 }
        let ragged = lift >= 1 ? Int(noise(i / s + seed * 31) * 3) * s : 0
        let top = base - Int(Double(h) * lift) + ragged
        guard top < base else { continue }
        c.rect(x + i, top, 1, base - top, u > 0.66 && lift >= 1 ? shade : col)
        if lift < 1 { c.rect(x + i, top, 1, max(1, s), shade) }
    }
    for k in 0..<3 {   // ledges, broken off here and there
        let y = base - h + h * (2 + k * 3) / 12
        for i in stride(from: Int(Double(w) * 0.24), to: Int(Double(w) * 0.78), by: 3 * s) where noise(i + k * 53 + seed) > 0.35 {
            c.rect(x + i, y + Int(noise(i + seed + k) * 2) * s, 3 * s, max(1, s / 2 + s % 2), shade.alpha(0.8))
        }
    }
}

/// The "Welcome to Sunnydale" sign's board, `p` pixels a dot for the town's name, its top-left at (x, y). Returns its
/// size.
@discardableResult
private func slayerWelcomeBoard4(_ c: PixelCanvas, _ x: Int, _ y: Int, _ p: Int, small: Int, _ s: Int,
                                 lit: Bool = true) -> (w: Int, h: Int) {
    let big = "SUNNYDALE", top = "WELCOME TO"
    let w = slayerTextWidth4(big, p) + 12 * s, h = 4 * s + 5 * small + 3 * s + 5 * p + 4 * s
    let frame = C(0x3A2416), face = lit ? C(0xEEE2C4) : C(0xC8B898), ink = C(0x2A4A30), fine = C(0x6A4A2A)
    c.rect(x - 2 * s, y - 2 * s, w + 4 * s, h + 4 * s, frame)
    c.rect(x - 2 * s, y - 2 * s, w + 4 * s, s, C(0x5A3A22))
    c.rect(x, y, w, h, face)
    c.rect(x, y + h - s, w, s, face.alpha(0.8)); c.rect(x + w - s, y, s, h, C(0xB8A880))
    c.rect(x + 2 * s, y + 2 * s, w - 4 * s, s, ink.alpha(0.35)); c.rect(x + 2 * s, y + h - 3 * s, w - 4 * s, s, ink.alpha(0.35))
    slayerText4(c, x + (w - slayerTextWidth4(top, small)) / 2, y + 4 * s, top, fine, small)
    slayerText4(c, x + (w - slayerTextWidth4(big, p)) / 2, y + 4 * s + 5 * small + 3 * s, big, ink, p)
    return (w, h)
}

/// How big the welcome board comes out.
private func slayerWelcomeSize4(_ p: Int, small: Int, _ s: Int) -> (w: Int, h: Int) {
    (slayerTextWidth4("SUNNYDALE", p) + 12 * s, 4 * s + 5 * small + 3 * s + 5 * p + 4 * s)
}

// MARK: - "Welcome to Sunnydale"

extension Scenes {
    /// Where things stand at the town sign: the horizon, the sign's board, the street lamp, the far road.
    static func slayerTownSignFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, board: (x: Int, y: Int, w: Int, h: Int, p: Int, small: Int),
                                                                     lamp: (x: Int, y: Int), road: Int) {
        let s = unit(g), tall = isTall(c)
        let p = tall ? 3 * s : 2 * s, small = tall ? 2 * s : s
        let size = slayerWelcomeSize4(p, small: small, s)
        let bx = c.w * 63 / 100 - size.w / 2, by = tall ? g - 86 * s : g - 47 * s
        let horizon = tall ? g - 66 * s : g - 26 * s
        let lamp = (x: c.w * 34 / 100, y: tall ? g - 128 * s : 9 * s)
        return (horizon, (bx, by, size.w, size.h, p, small), lamp, horizon + 5 * s)
    }

    /// The sign at the edge of town by night: dry hills under a dark sky that glows orange low down from the town
    /// beyond, a far road winding along the hills, a wire fence and scrub, a sodium street lamp pouring orange light
    /// over the cream "WELCOME TO SUNNYDALE" board on its two posts, and the road the crew stands on. On the screen saver
    /// the stars thicken into a band across the sky, and a far-off hill carries a radio mast.
    static func slayerTownSign(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerTownSignFrame(c, g), hz = f.horizon
        c.gradient(0, hz + 4 * s, C(0x0A080E), C(0x5A3420), bands: tall ? 12 : 6)
        c.stars(0, hz - 12 * s, density: tall ? 60 : 50, seed: 41)
        if tall {
            // A band of thicker stars sloping across the sky.
            for i in 0..<(c.w * 3) {
                let u = noise(i * 5 + 700), v = noise(i * 5 + 701) + noise(i * 5 + 702) - 1
                let x = Int(u * Double(c.w)), y = Int(Double(hz) * (0.15 + 0.5 * u * 0.9) + v * Double(26 * s))
                guard y > 0, y < hz - 30 * s else { continue }
                c.px(x, y, C(0xF0E8FF, noise(i + 703) > 0.85 ? 0.9 : 0.35))
            }
            for k in 0..<5 {
                let x = c.w * (8 + k * 21) / 100
                c.ellipse(x, Int(Double(hz) * (0.15 + 0.45 * Double(x) / Double(c.w))), 34 * s, 9 * s, C(0xB8A8D8, 0.05))
            }
            // The far-off hill with its radio mast.
            let hx = c.w * 16 / 100, top = hz - 52 * s
            for x in 0..<(c.w * 3 / 4) {
                let d = Double(x - hx) / Double(x < hx ? 80 * s : 150 * s)
                let rise = max(0, 1 - d * d) * Double(hz - top) + noise(x / max(1, s) + 720) * Double(s)
                let y = hz - Int(rise) + s
                guard y < hz + 2 * s else { continue }
                c.rect(x, y, 1, hz + 2 * s - y, C(0x22161C)); c.px(x, y, C(0x4A2E2A))
            }
            c.rect(hx - s, top - 34 * s, 2 * s, 34 * s, C(0x1A1014))
            slayerLine(c, Double(hx), Double(top - 34 * s), Double(hx - 10 * s), Double(top), C(0x1A1014), Double(s) * 0.5)
            slayerLine(c, Double(hx), Double(top - 34 * s), Double(hx + 10 * s), Double(top), C(0x1A1014), Double(s) * 0.5)
            for y in stride(from: top - 30 * s, to: top, by: 6 * s) { c.rect(hx - 3 * s, y, 6 * s, max(1, s / 2), C(0x1A1014)) }
        }
        // Two lines of dry hills, the town's lights twinkling at their feet.
        c.dunes(base: hz, amp: Double(5 * s), freq: 0.017, phase: 0.6, bottom: g, C(0x2A1A18))
        for i in 0..<(c.w / 5) {
            let x = Int(noise(i * 3 + 90) * Double(c.w)), y = hz + Int(noise(i * 3 + 91) * 3) * s
            c.px(x, y, noise(i * 3 + 92) > 0.6 ? C(0xFFD890) : C(0xFFA850, 0.8))
        }
        c.dunes(base: hz + 7 * s, amp: Double(3 * s), freq: 0.029, phase: 2.1, bottom: g, C(0x1E1612))
        c.gradient(hz + 9 * s, g, C(0x1E1612), C(0x2E2218), bands: 4)
        // The far road along the hills.
        c.rect(0, f.road, c.w, s, C(0x3A2C22))
        // Scrub, and a wire fence on short posts.
        for k in 0..<(c.w / (9 * s)) {
            let x = Int(noise(k * 7 + 140) * Double(c.w)), y = hz + 12 * s + Int(noise(k * 7 + 141) * Double(g - hz - 16 * s))
            let r = (2 + Int(noise(k * 7 + 142) * 3)) * s
            c.ellipse(x, y, r + s, r / 2 + s, C(0x14100C)); c.rect(x - r / 2, y - r / 2, s, s, C(0x3A3420))
        }
        let fy = g - 9 * s
        for x in stride(from: 0, to: c.w, by: 18 * s) { c.rect(x, fy - 6 * s, s, 7 * s, C(0x3A2A1E)) }
        c.rect(0, fy - 5 * s, c.w, max(1, s / 2), C(0x5A4A3E, 0.7)); c.rect(0, fy - 2 * s, c.w, max(1, s / 2), C(0x5A4A3E, 0.7))
        // The street lamp: a pole, a curved arm, a hood, and its orange cone of light.
        let lx = f.lamp.x, ly = f.lamp.y, head = lx + 10 * s
        slayerWedge4(c, head, ly + 3 * s, g, 2 * s, (g - ly) / 2, C(0xFF9A3A, 0.08))
        slayerWedge4(c, head, ly + 3 * s, g, s, (g - ly) / 4, C(0xFFB050, 0.06))
        c.ellipse(head, g + 3 * s, (g - ly) / 2 + 8 * s, 4 * s, C(0xFFA040, 0.12))
        c.rect(lx - s, ly, 3 * s, g - ly, C(0x2A2420)); c.rect(lx - s, ly, s, g - ly, C(0x4A3E34))
        c.rect(lx - 2 * s, g - 4 * s, 5 * s, 4 * s, C(0x2A2420))
        c.rect(lx, ly - s, 7 * s, 2 * s, C(0x2A2420)); c.rect(lx + 6 * s, ly, 2 * s, s, C(0x2A2420))
        c.rect(head - 4 * s, ly, 8 * s, 2 * s, C(0x3A322C)); c.rect(head - 3 * s, ly + 2 * s, 6 * s, s, C(0xFFD890))
        c.circle(head, ly + 2 * s, 5 * s, C(0xFFB050, 0.15))
        // The sign: two posts, the board, rocks and a few flowers at the foot.
        let b = f.board
        for px in [b.x + b.w / 6, b.x + b.w * 5 / 6 - 3 * s] {
            c.rect(px, b.y + b.h, 4 * s, g - b.y - b.h, C(0x4A3020)); c.rect(px, b.y + b.h, s, g - b.y - b.h, C(0x6A4A30))
            c.rect(px + 3 * s, b.y + b.h, s, g - b.y - b.h, C(0x2A1A10))
        }
        slayerWelcomeBoard4(c, b.x, b.y, b.p, small: b.small, s)
        c.rect(b.x, b.y, b.w * 2 / 5, b.h, C(0xFFA040, 0.12))   // lamplight falls on its left side
        for k in 0..<9 {
            let x = b.x + Int(noise(k + 160) * Double(b.w)), r = (2 + Int(noise(k + 161) * 2)) * s
            c.ellipse(x, g - s, r, r / 2 + s, C(0x4A4038)); c.rect(x - r / 2, g - r / 2 - s, s, s, C(0x6A5E50))
        }
        for k in 0..<6 { c.rect(b.x + Int(noise(k + 170) * Double(b.w)), g - 4 * s, s, s, [C(0xE8C04A), C(0xD86A4A)][k % 2]) }
        // The road: asphalt, a pale edge line and a dashed yellow middle.
        c.ground(g, C(0x24221F), edge: C(0x6A645A), speck: C(0x302E2A), seed: 23)
        c.ellipse(head, g + 2 * s, (g - ly) / 2, 3 * s, C(0xFFA040, 0.10))
        let mid = g + (c.h - g) / 2
        for x in stride(from: 4 * s, to: c.w, by: 22 * s) { c.rect(x, mid, 11 * s, s, C(0xB89A3A, 0.55)) }
    }

    /// The sign's life: a car's headlights crawling along the far road, then sweeping across the board as it passes,
    /// moths round the street lamp, and on the screen saver the radio mast's red light blinking.
    static func slayerTownSignLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerTownSignFrame(c, g)
        let k = frac(t / 12)
        if k < 0.55 {
            // Far off: a car coming along the hill road, headlights first.
            let u = k / 0.55, x = Int(u * Double(c.w + 40 * s)) - 20 * s, y = f.road
            c.rect(x, y - s, 2 * s, s, C(0xFFF4D0)); c.rect(x - 3 * s, y - s, s, s, C(0xFFF4D0, 0.7))
            slayerWedge4(c, x + 10 * s, y - 2 * s, y + s, s, 2 * s, C(0xFFF0C0, 0.07))
            c.rect(x + 2 * s, y - s, 14 * s, s, C(0xFFF0C0, 0.12))
        } else if k < 0.75 {
            // Close by: the beam sweeps across the board from left to right.
            let u = (k - 0.55) / 0.2, b = f.board
            let bx = b.x - 30 * s + Int(u * Double(b.w + 60 * s))
            for d in 0..<3 {
                let w = (14 - d * 4) * s
                c.rect(bx - w / 2, b.y - 2 * s, w, b.h + 4 * s, C(0xFFFCF0, 0.22 + Double(d) * 0.12))
            }
            c.rect(bx - 18 * s, g - 3 * s, 36 * s, 3 * s, C(0xFFF8E0, 0.15))
        }
        // Moths round the lamp.
        let head = f.lamp.x + 10 * s, ly = f.lamp.y + 4 * s
        for m in 0..<3 {
            let a = t * (2.2 + Double(m) * 0.7) + Double(m) * 2
            let x = head + Int(cos(a) * Double((4 + m * 2) * s)), y = ly + Int(sin(a * 1.3) * Double((2 + m) * s))
            c.px(x, y, C(0xFFE8B0, 0.8))
        }
        if isTall(c), Int(t * 1.2) % 2 == 0 {
            let hx = c.w * 16 / 100, top = f.horizon - 52 * s - 34 * s
            c.rect(hx - s, top - 2 * s, 2 * s, 2 * s, C(0xFF3A2A)); c.circle(hx, top - s, 4 * s, C(0xFF3A2A, 0.2))
        }
    }
}

// MARK: - The crater

extension Scenes {
    /// Where things stand at the crater: the horizon, the crater's centre and size, the sun's path, the bus.
    static func slayerCraterFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, cx: Int, cy: Int, rx: Int, ry: Int,
                                                                   sun: (x: Int, r: Int, rise: Int), bus: Int) {
        let s = unit(g), tall = isTall(c)
        let horizon = tall ? g - 96 * s : g - 32 * s
        let rx = c.w * 33 / 100, ry = (g - horizon) / 2 - 2 * s
        let cy = horizon + 2 * s + ry
        let sun = (x: c.w * 52 / 100, r: tall ? 16 * s : 7 * s, rise: tall ? 90 * s : 14 * s)
        return (horizon, c.w * 52 / 100, cy, rx, ry, sun, c.w * 86 / 100)
    }

    /// The crater where Sunnydale was, at sunrise ("Chosen"): a rose-and-gold dawn sky over hazy hills, a vast bowl
    /// sunk into the dusty plain with shadowed inner walls and the wreck of the town (girders, a broken roof, a
    /// tilted lamp post) on its floor, the "WELCOME TO SUNNYDALE" sign tipping in over its lip, and the yellow school
    /// bus they escaped in, battered, parked at the edge. On the screen saver the dawn sky opens up wide, with
    /// clouds lit pink and gold from beneath.
    static func slayerCrater(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerCraterFrame(c, g), hz = f.horizon
        if tall {
            c.gradient(0, hz / 2, C(0x5A6E9A), C(0xC890A8), bands: 8)
            c.gradient(hz / 2, hz + 2 * s, C(0xC890A8), C(0xFFD49A), bands: 8)
            // Clouds lit from below, and long thin bars of cloud near the horizon.
            let clouds: [(x: Int, y: Int, r: Int)] = [(14, 22, 9), (40, 12, 7), (70, 26, 10), (90, 14, 6), (28, 44, 6), (82, 46, 7)]
            for (i, cl) in clouds.enumerated() {
                let x = c.w * cl.x / 100, y = hz * cl.y / 100
                cloud(c, x, y, cl.r * s, seed: 30 + i, top: C(0xE8B8C0), base: C(0xFFC890))
                c.ellipse(x, y + cl.r * s / 2 + s, cl.r * s * 3 - 2 * s, s, C(0xFFE0A0, 0.8))
            }
            for k in 0..<5 {
                wisp(c, c.w * (10 + k * 19) / 100, hz - (12 + k % 3 * 9) * s, (50 + k * 9) * s, C(0xFFE0B8, 0.6), s: s)
            }
            for k in 0..<4 {   // birds, far off
                let x = c.w * (20 + k * 9) / 100, y = hz * (30 + k * 4) / 100
                c.rect(x - 2 * s, y, 2 * s, s, C(0x4A3A4A)); c.rect(x + s, y, 2 * s, s, C(0x4A3A4A)); c.px(x, y + s, C(0x4A3A4A))
            }
        } else {
            c.gradient(0, hz + 2 * s, C(0xB88AA8), C(0xFFD49A), bands: 6)
            wisp(c, c.w * 18 / 100, 8 * s, 44 * s, C(0xFFE0C0, 0.6), s: s)
            wisp(c, c.w * 80 / 100, 12 * s, 54 * s, C(0xFFE0C0, 0.5), s: s)
        }
        // Hazy hills beyond, then the dusty plain.
        c.dunes(base: hz, amp: Double(3 * s), freq: 0.021, phase: 1.4, bottom: g, C(0xA8786A))
        c.gradient(hz + 2 * s, g, C(0xC0946A), C(0x8A6444), bands: 5)
        for i in 0..<(c.w * (g - hz) / 60) {
            let x = Int(noise(i * 3 + 200) * Double(c.w)), y = hz + 3 * s + Int(noise(i * 3 + 201) * Double(g - hz - 3 * s))
            c.px(x, y, noise(i * 3 + 202) > 0.5 ? C(0xD8B080) : C(0x7A5838))
        }
        // The crater: a lit lip, the shadowed far wall, the dusty floor, and wreckage.
        let cx = f.cx, cy = f.cy, rx = f.rx, ry = f.ry
        c.ellipse(cx, cy, rx + 3 * s, ry + s, C(0xD8AE7E))
        c.ellipse(cx, cy + s, rx, ry, C(0x3E2A22))
        c.ellipse(cx, cy + ry / 4, rx * 9 / 10, ry * 3 / 4, C(0x543A2C))
        c.ellipse(cx, cy + ry / 2, rx * 3 / 4, ry / 2, C(0x6E5038))
        c.ellipse(cx, cy + ry * 2 / 3, rx * 11 / 20, ry / 3, C(0x86644A))
        // Ledges down the far wall.
        for k in 1...3 {
            let yy = cy - ry + k * ry / 4
            for x in stride(from: cx - rx * (5 - k) / 5, to: cx + rx * (5 - k) / 5, by: 2 * s) where noise(x + k * 77) > 0.3 {
                c.rect(x, yy + Int(noise(x + k * 99) * 2) * s, 2 * s, s, C(0x6A4A36))
            }
        }
        // Wreckage on the floor: girders, a sunken roof, the top of a building with its windows, a lamp post at an
        // angle, rubble.
        let fy = cy + ry * 2 / 3, z = tall ? 2 : 1
        slayerLine(c, Double(cx - rx / 3), Double(fy), Double(cx - rx / 3 + 12 * s * z), Double(fy - 8 * s * z), C(0x3A2A24), Double(s * z) * 0.8)
        slayerLine(c, Double(cx - rx / 3 + 6 * s * z), Double(fy + s), Double(cx - rx / 3 + 16 * s * z), Double(fy - 5 * s * z), C(0x3A2A24), Double(s * z) * 0.6)
        for k in 0..<6 {   // a roof, sunk at a tilt
            let x = cx + rx / 8 + k * 3 * s * z
            c.rect(x, fy - (7 - k) * s * z, 3 * s * z, (7 - k) * s * z + 2 * s, C(0x5A3A30))
            c.rect(x, fy - (7 - k) * s * z, 3 * s * z, s, C(0x9A6448))
        }
        let bx0 = cx - rx * 2 / 3, bh0 = 9 * s * z, bw0 = 16 * s * z   // a building's top storeys, half buried
        c.rect(bx0, fy - bh0, bw0, bh0, C(0x7A6A5E)); c.rect(bx0, fy - bh0, bw0, s, C(0xA8988A))
        for q in 0..<3 { for r in 0..<2 { c.rect(bx0 + 2 * s * z + q * 5 * s * z, fy - bh0 + 2 * s * z + r * 4 * s * z, 3 * s * z, 2 * s * z, C(0x2A2420)) } }
        c.rect(bx0 + bw0 - 4 * s * z, fy - bh0, 4 * s * z, 3 * s * z, C(0x543A2C))
        slayerLine(c, Double(cx + rx / 2), Double(fy + 2 * s), Double(cx + rx / 2 - 6 * s * z), Double(fy - 10 * s * z), C(0x2A2420), Double(s * z) * 0.6)
        c.rect(cx + rx / 2 - 8 * s * z, fy - 11 * s * z, 3 * s * z, 2 * s * z, C(0x2A2420))
        for k in 0..<18 {
            let x = cx - rx * 2 / 3 + Int(noise(k * 3 + 300) * Double(rx * 4 / 3))
            let y = fy - 3 * s + Int(noise(k * 3 + 301) * Double(ry / 2))
            c.rect(x, y, (1 + Int(noise(k * 3 + 302) * 3)) * s, s, k % 2 == 0 ? C(0x4A3428) : C(0xA07A58))
        }
        c.ellipse(cx, fy, rx * 2 / 3, ry / 5, C(0xE8C8A0, 0.12))   // dust hanging low in the bowl
        // Broken ground at the near lip.
        for x in stride(from: cx - rx, to: cx + rx, by: 3 * s) {
            let dy = Int(noise(x / s + 500) * 3) * s
            c.rect(x, g - 2 * s - dy, 3 * s, 2 * s + dy, C(0x8A6444))
        }
        // The sign, tipping over the lip on the left.
        let p = tall ? 2 * s : s, small = s
        let size = slayerWelcomeSize4(p, small: small, s)
        let post = tall ? 14 * s : 6 * s
        let sc = PixelCanvas(size.w + 8 * s, size.h + post + 8 * s)
        for px in [size.w / 6 + 4 * s, size.w * 5 / 6] {
            sc.rect(px, size.h + 4 * s, 3 * s, post, C(0x9A6A40)); sc.rect(px, size.h + 4 * s, s, post, C(0xC8945A))
            sc.rect(px + 2 * s, size.h + 4 * s, s, post, C(0x5A3A22))
        }
        slayerWelcomeBoard4(sc, 4 * s, 4 * s, p, small: small, s)
        // Its feet on the crater's left-hand lip, leaning out over the drop.
        let sx = cx - rx + size.w / 3
        let du = Double(sx - cx) / Double(rx), sy = cy + Int(Double(ry) * (1 - du * du).squareRoot())
        let pad = 40 * s
        let turned = sc.rotated(14, about: (Double(sc.w) / 2, Double(sc.h - 4 * s)), into: sc.w + 2 * pad, sc.h + pad,
                                at: (Double(sc.w / 2 + pad), Double(sc.h + pad / 2)))
        c.paste(turned, x: sx - sc.w / 2 - pad, y: sy - sc.h - pad / 2)
        c.ellipse(sx - 2 * s, sy, size.w / 3, 2 * s, C(0xA07A54))   // the ground giving way under it
        for k in 0..<6 { c.rect(sx + Int(noise(k + 330) * Double(size.w / 2)), sy + Int(noise(k + 331) * 6) * s, 2 * s, s, C(0xA07A54)) }
        // The school bus at the edge, on the right.
        let bw = tall ? 70 * s : 50 * s, bh = tall ? 24 * s : 17 * s, bx = f.bus - bw / 2, by = g - bh - 3 * s
        let yellow = C(0xE8B830), yd = C(0xB88A20)
        c.rect(bx, by, bw, bh, yellow); c.rect(bx, by, bw, s, C(0xF8D870)); c.rect(bx, by + bh - 3 * s, bw, 3 * s, yd)
        c.rect(bx + bw, by + bh / 3, 5 * s, bh * 2 / 3, yellow); c.rect(bx + bw, by + bh / 3, 5 * s, s, C(0xF8D870))
        c.rect(bx, by + bh / 2 + s, bw, s, C(0x2A2420))
        let win = bh / 3
        for x in stride(from: bx + 3 * s, to: bx + bw - win, by: win + 2 * s) {
            c.rect(x, by + 2 * s, win, win, C(0x3A4250)); c.rect(x, by + 2 * s, win, s, C(0xFFE0B0, 0.5))
        }
        c.rect(bx + 6 * s, by + 4 * s, 2 * s, s, C(0x2A2420)); c.rect(bx + bw * 2 / 3, by + bh / 2 + 3 * s, 4 * s, 2 * s, C(0x8A6A2A))   // dents
        c.rect(bx - s, by + bh - 3 * s, 2 * s, 2 * s, C(0xD84A2A))
        for wx in [bx + bw / 5, bx + bw * 4 / 5] {
            c.circle(wx, by + bh, bh / 5 + s, C(0x1A1614)); c.circle(wx, by + bh, s, C(0x6A625A))
        }
        // The ground at the crew's feet.
        c.ground(g, C(0x6A4E36), edge: C(0x9A7650), speck: C(0x54402C), seed: 37)
    }

    /// The crater's life: the sun coming slowly up over the far rim and sinking again, its glow on the sky, and dust
    /// settling over the bowl.
    static func slayerCraterLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerCraterFrame(c, g)
        let u = abs(frac(t / 90) * 2 - 1)            // 1 → 0 → 1: up, then slowly down again
        let rise = 1 - u
        let sy = f.horizon + f.sun.r - Int(Double(f.sun.rise) * (0.35 + 0.65 * rise))
        let limit = f.horizon + s
        slayerDiscAbove4(c, f.sun.x, sy, f.sun.r * 3, limit, C(0xFFE0A0, 0.10))
        slayerDiscAbove4(c, f.sun.x, sy, f.sun.r * 2, limit, C(0xFFE8B0, 0.14))
        slayerDiscAbove4(c, f.sun.x, sy, f.sun.r, limit, C(0xFFF4D8))
        slayerDiscAbove4(c, f.sun.x, sy, f.sun.r - 2 * s, limit, C(0xFFFCF0))
        if isTall(c) {
            for k in 0..<6 {   // rays
                let a = (Double(k) - 2.5) * 0.32 + sin(t * 0.1) * 0.03
                let len = Double(f.sun.r * 7)
                slayerLine(c, Double(f.sun.x), Double(sy), Double(f.sun.x) + sin(a) * len, Double(sy) - cos(a) * len,
                           C(0xFFF0C8, 0.07), Double(3 * s))
            }
        }
        // Dust settling over the bowl.
        for k in 0..<22 {
            let x = f.cx - f.rx + Int(noise(k * 4 + 900) * Double(f.rx * 2)) + Int(sin(t * 0.4 + Double(k)) * Double(3 * s))
            let top = f.horizon - (isTall(c) ? 30 : 6) * s
            let y = top + Int(frac(noise(k * 4 + 901) + t * 0.012 * (0.6 + noise(k * 4 + 902))) * Double(f.cy - top + f.ry / 2))
            c.px(x, y, C(0xF0D8B0, 0.5))
        }
        c.ellipse(f.cx, f.cy + f.ry / 2, f.rx * 3 / 4, f.ry / 4, C(0xF0D8B0, 0.05 + 0.03 * sin(t * 0.3)))
    }
}

// MARK: - The dream desert

extension Scenes {
    /// Where things stand in the dream desert: the horizon, the campfire, the painted rock, the sun.
    static func slayerDreamDesertFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, fire: Int, rock: Int, sun: (x: Int, y: Int, r: Int)) {
        let s = unit(g), tall = isTall(c)
        let horizon = tall ? g - 80 * s : g - 28 * s
        let sun = tall ? (x: c.w * 70 / 100, y: horizon * 30 / 100, r: 20 * s) : (x: c.w * 46 / 100, y: 11 * s, r: 6 * s)
        return (horizon, c.w * 22 / 100, c.w * 80 / 100, sun)
    }

    /// The desert of Buffy's dreams ("Restless", "Intervention"), by day: a bleached sky going faintly lilac overhead,
    /// a white sun, red mesas fading into the haze, red sand rippled by the wind, a campfire in a ring of stones on the
    /// left and on the right a tall red rock painted with the First Slayer's handprints and spiral. On the screen saver
    /// the mesas stand huge, a natural arch on the far left, and the sun burns big in a sky streaked with wisps.
    static func slayerDreamDesert(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerDreamDesertFrame(c, g), hz = f.horizon
        c.gradient(0, hz + 4 * s, C(0xB8A8C8), C(0xFFE4B8), bands: tall ? 9 : 6)
        // The sun: a white disc in rings of glare.
        let sun = f.sun
        for k in (1...3).reversed() { c.circle(sun.x, sun.y, sun.r + k * sun.r * 2 / 3, C(0xFFFFF0, 0.08)) }
        c.circle(sun.x, sun.y, sun.r, C(0xFFFFF4))
        if tall {
            for k in 0..<6 {
                wisp(c, c.w * (6 + k * 17) / 100, hz * (18 + (k * 37) % 50) / 100, (60 + k * 12) * s, C(0xFFF4E8, 0.5), s: s)
            }
            // Huge buttes and a natural arch, far off in the haze.
            slayerButte4(c, x: c.w * 26 / 100, w: 120 * s, h: 66 * s, base: hz + 2 * s, C(0xD89A80), C(0xC08470), seed: 3, s)
            slayerButte4(c, x: c.w * 56 / 100, w: 170 * s, h: 110 * s, base: hz + 2 * s, C(0xC8826A), C(0xAE6C58), seed: 5, s)
            let ax = c.w * 9 / 100, ay = hz - 40 * s, arc = C(0xB86A50)
            for k in 0...40 {   // the arch's span, thick at its feet
                let a = Double.pi * Double(k) / 40
                let r = Int((5 + 3 * abs(cos(a))) * Double(s))
                c.circle(ax + Int(cos(a) * Double(30 * s)), ay - Int(sin(a) * Double(26 * s)), r, arc)
            }
            c.rect(ax - 37 * s, ay, 14 * s, hz + 2 * s - ay, arc); c.rect(ax + 23 * s, ay, 14 * s, hz + 2 * s - ay, arc)
            c.rect(ax + 30 * s, ay - 10 * s, 6 * s, hz + 12 * s - ay, C(0x9A5440))
        }
        // Far mesas, nearer buttes.
        mesa(c, x: c.w * 4 / 100, width: 60 * s, h: (tall ? 16 : 8) * s, base: hz + 2 * s, C(0xD8A088), seed: 11)
        mesa(c, x: c.w * 46 / 100, width: 80 * s, h: (tall ? 14 : 7) * s, base: hz + 2 * s, C(0xD8A088), seed: 13)
        slayerButte4(c, x: c.w * 24 / 100, w: 54 * s, h: (tall ? 36 : 16) * s, base: hz + 3 * s, C(0xB05A40), C(0x8A4430), seed: 17, s)
        slayerButte4(c, x: c.w * 62 / 100, w: 34 * s, h: (tall ? 28 : 13) * s, base: hz + 3 * s, C(0xA44E36), C(0x7E3A28), seed: 19, s)
        // The sand: low swells, and wind ripples here and there.
        c.gradient(hz + 2 * s, g, C(0xD88458), C(0xB85A36), bands: 5)
        let swell = max(4 * s, (g - hz) / 4)
        c.dunes(base: hz + swell + 2 * s, amp: Double(2 * s), freq: 0.013, phase: 0.4, bottom: g, C(0xCC7A50), shade: C(0xE8A070))
        c.dunes(base: hz + swell * 5 / 2, amp: Double(3 * s), freq: 0.009, phase: 2.6, bottom: g, C(0xC06A42), shade: C(0xE0946A))
        for k in 0..<(c.w * (g - hz) / (420 * s * s)) {
            let x = Int(noise(k * 3 + 600) * Double(c.w)), y = hz + 6 * s + Int(noise(k * 3 + 601) * Double(g - hz - 9 * s))
            let len = (5 + Int(noise(k * 3 + 602) * 10)) * s
            for i in 0..<3 {
                let yy = y + i * 2 * s
                c.rect(x + i * s, yy, len - 2 * i * s, max(1, s / 2), C(0xF0A878, 0.55))
                c.rect(x + i * s + s, yy + s, len - 2 * i * s - 2 * s, max(1, s / 2), C(0x8A3E22, 0.3))
            }
        }
        // The painted rock on the right: a big red outcrop with a ledge, handprints and a spiral in pale ochre.
        let rx = f.rock, rh = tall ? 58 * s : 30 * s, rw = tall ? 120 * s : 70 * s
        for i in 0..<rw {
            let u = Double(i) / Double(rw)
            let prof = sin(u * .pi) * 0.75 + 0.25 * sin(u * .pi * 3 + 0.6) * (1 - u)
            let top = g - Int(Double(rh) * max(0.15, prof)) - Int(noise(i / max(1, s) + 650) * 2) * s
            let x = rx - rw / 3 + i
            c.rect(x, top, 1, g - top, C(0x9A3E28))
            c.rect(x, top, 1, s, C(0xD06A44))
            if u > 0.72 { c.rect(x, top + s, 1, g - top - s, C(0x6A2818, 0.6)) }
        }
        for k in 0..<3 {   // cracks and a ledge
            let x = rx - rw / 3 + rw * (25 + k * 22) / 100
            slayerLine(c, Double(x), Double(g - rh * 2 / 3), Double(x + 3 * s), Double(g - 2 * s), C(0x6A2818), Double(s) * 0.5)
        }
        c.rect(rx - rw / 4, g - rh / 3, rw / 2, s, C(0xC85A3A)); c.rect(rx - rw / 4, g - rh / 3 + s, rw / 2, s, C(0x6A2818))
        let paint = C(0xF4E2B8)
        let hp = tall ? 2 * s : s
        func hand(_ x: Int, _ y: Int) {   // fingers spread, thumb out
            let rows = ["0101010", "0101010", "0111111", "1111110", "0111100", "0011100"]
            for (r, row) in rows.enumerated() {
                for (q, ch) in row.enumerated() where ch == "1" { c.rect(x + q * hp, y + r * hp, hp, hp, paint) }
            }
        }
        hand(rx - rw / 5, g - rh * 7 / 10); hand(rx - rw / 5 + 8 * hp, g - rh * 7 / 10 + 2 * hp)
        let sp = (x: rx + rw / 6, y: g - rh * 6 / 10)
        for i in 0..<30 {
            let a = Double(i) * 0.5, r = Double(hp) * (0.6 + Double(i) * 0.17)
            c.rect(sp.x + Int(cos(a) * r), sp.y + Int(sin(a) * r), hp, hp, paint.alpha(0.9))
        }
        for k in 0..<4 { c.rect(rx - rw / 6 + k * 3 * hp, g - rh * 7 / 10 + 9 * hp, 2 * hp, hp, paint.alpha(0.8)) }   // tally marks
        // The campfire: a ring of stones, crossed sticks, embers.
        let q = isTall(c) ? 2 * s : s, fx = f.fire, fb = g - s
        c.ellipse(fx, fb, 12 * q, 3 * q, C(0x6A2A18, 0.5))
        for k in 0..<7 {
            let a = Double(k) / 7 * 2 * .pi
            let x = fx + Int(cos(a) * Double(8 * q)), y = fb + Int(sin(a) * Double(2 * q))
            c.ellipse(x, y, 2 * q, s + s / 2, C(0x5A4A40)); c.px(x - s, y - s, C(0x8A786A))
        }
        slayerLine(c, Double(fx - 6 * q), Double(fb), Double(fx + 4 * q), Double(fb - 5 * q), C(0x4A2A18), Double(q) * 0.9)
        slayerLine(c, Double(fx + 6 * q), Double(fb), Double(fx - 4 * q), Double(fb - 5 * q), C(0x5A3420), Double(q) * 0.9)
        c.rect(fx - 3 * q, fb - 2 * q, 6 * q, 2 * q, C(0xD84A1A))
        // Sand at the crew's feet.
        c.ground(g, C(0xA44E30), edge: C(0xD07A50), speck: C(0x8A3E24), seed: 47)
    }

    /// The desert's life: heat shimmer wobbling over the horizon, sand blowing low across the ground, the campfire's
    /// flames and sparks, and on the screen saver a hawk wheeling high up.
    static func slayerDreamDesertLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerDreamDesertFrame(c, g), hz = f.horizon
        for k in 0..<4 {
            let y0 = hz - k * 3 * s
            for x in stride(from: 0, to: c.w, by: 3 * s) {
                let dy = Int((sin(Double(x) * 0.09 + t * 3.1 + Double(k)) * 1.3).rounded()) * s
                c.rect(x, y0 + dy, 2 * s, max(1, s / 2), C(0xFFF0D8, 0.22 - Double(k) * 0.04))
            }
        }
        // Blowing sand.
        for k in 0..<14 {
            let len = (8 + Int(noise(k * 5 + 1) * 16)) * s
            let x = c.w - Int(frac(noise(k * 5) + t * (0.06 + noise(k * 5 + 2) * 0.05)) * Double(c.w + len * 2)) + len
            let y = g - (1 + Int(noise(k * 5 + 3) * 14)) * s + Int(sin(t * 2 + Double(k)) * Double(s))
            c.rect(x, y, len, max(1, s / 2), C(0xF0B080, 0.35)); c.rect(x + len / 3, y - s, len / 3, max(1, s / 2), C(0xF0B080, 0.2))
        }
        // The fire.
        let q = isTall(c) ? 2 * s : s, fx = f.fire, fb = g - 3 * q
        let fl = noise(Int(t * 10) * 7)
        let h = (8 + Int(fl * 4)) * q
        c.circle(fx, fb - 4 * q, 10 * q, C(0xFFB050, 0.10))
        slayerWedge4(c, fx + Int((fl - 0.5) * 2) * q, fb - h, fb, 0, 4 * q, C(0xE8501A))
        slayerWedge4(c, fx, fb - h * 2 / 3, fb, 0, 3 * q, C(0xFF9A2A))
        slayerWedge4(c, fx, fb - h / 3, fb, 0, 2 * q, C(0xFFE08A))
        for k in 0..<4 {
            let u = frac(t * 0.7 + Double(k) * 0.25)
            c.px(fx + Int(sin(t * 3 + Double(k) * 2) * Double(3 * q)), fb - h - Int(u * Double(14 * q)), C(0xFFC060, 1 - u))
        }
        if isTall(c) {   // a hawk circling
            let a = t * 0.35, x = f.sun.x - 90 * s + Int(cos(a) * Double(50 * s)), y = hz / 2 + Int(sin(a) * Double(16 * s))
            let up = Int(t * 3) % 3 == 0
            c.rect(x - s, y, 3 * s, 2 * s, C(0x3A2018))
            c.rect(x - 6 * s, y + (up ? -s : 0), 5 * s, s, C(0x3A2018)); c.rect(x + 2 * s, y + (up ? -s : 0), 5 * s, s, C(0x3A2018))
        }
    }
}

// MARK: - The Hyperion Hotel

extension Scenes {
    /// Where things stand in the Hyperion's lobby: the lift, the round desk, the stairs, the fan, and (on the screen
    /// saver) the galleries above.
    static func slayerHyperionFrame(_ c: PixelCanvas, _ g: Int) -> (lift: (x: Int, w: Int, h: Int), desk: (x: Int, w: Int),
                                                                     stairs: Int, landing: Int, fan: (x: Int, y: Int),
                                                                     galleries: [Int]) {
        let s = unit(g), tall = isTall(c)
        let landing = tall ? g - 70 * s : g - 40 * s
        let galleries = tall ? [g - 132 * s, g - 194 * s] : []
        let fan = (x: c.w * 56 / 100, y: tall ? landing - 30 * s : 14 * s)
        return ((c.w * 6 / 100, 26 * s, 38 * s), (c.w * 34 / 100, 76 * s), c.w * 76 / 100, landing, fan, galleries)
    }

    /// One of the Hyperion's room doors on a gallery: an arched wooden door with a brass number plate.
    static func slayerHotelDoor(_ c: PixelCanvas, _ x: Int, _ base: Int, _ s: Int) {
        c.rect(x - s, base - 22 * s, 14 * s, 22 * s, C(0x2A5A50))
        c.rect(x, base - 20 * s, 12 * s, 20 * s, C(0x5A341E)); c.ellipse(x + 6 * s, base - 20 * s, 6 * s, 3 * s, C(0x5A341E))
        c.rect(x + s, base - 18 * s, 4 * s, 7 * s, C(0x4A2A16)); c.rect(x + 7 * s, base - 18 * s, 4 * s, 7 * s, C(0x4A2A16))
        c.rect(x + s, base - 9 * s, 4 * s, 7 * s, C(0x4A2A16)); c.rect(x + 7 * s, base - 9 * s, 4 * s, 7 * s, C(0x4A2A16))
        c.rect(x + 4 * s, base - 23 * s, 4 * s, 2 * s, C(0xC8A04A)); c.rect(x + 10 * s, base - 10 * s, s, s, C(0xE8C86A))
    }

    /// The Hyperion's art deco lobby, sunny Los Angeles through tall windows: cream walls with jade pilasters
    /// stepped and capped in brass, a chevron frieze, the brass-gated lift on the left with its floor dial, the big
    /// round reception desk with the key cubbies behind it, a potted palm, the staircase sweeping up on the right
    /// with its red runner, and a dark jade floor. On the screen saver the lobby opens into an atrium: two galleries of
    /// room doors behind brass railings, sconces, and a round deco skylight at the top.
    static func slayerHyperion(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerHyperionFrame(c, g)
        let cream = C(0xE2CFA0), creamD = C(0xC4AE7C), jade = C(0x2A6A5C), jadeD = C(0x1A4038), jadeL = C(0x3E8A78)
        let brass = C(0xD0A848), brassD = C(0x8A6A28)
        c.gradient(0, g, C(0xEAD8AA), creamD, bands: 5)
        let roof = tall ? (f.galleries.last ?? f.landing) - 40 * s : 0
        if tall {
            // The ceiling: a deep coffered band and the round deco skylight in it, pale sky through radiating panes,
            // a brass chandelier hanging from its centre.
            c.rect(0, 0, c.w, roof + 6 * s, C(0xC8B486))
            for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, 0, 2 * s, roof, creamD); c.rect(x + 2 * s, 0, s, roof, cream) }
            let sx = c.w / 2, sy = roof / 2, ry = max(6 * s, roof / 2 - 6 * s), sr = min(ry * 3, c.w / 3)
            c.ellipse(sx, sy, sr + 6 * s, ry + 4 * s, brassD); c.ellipse(sx, sy, sr + 4 * s, ry + 2 * s, jadeD)
            c.ellipse(sx, sy, sr, ry, C(0xCDE8EC))
            c.ellipse(sx, sy - ry / 3, sr * 2 / 3, ry / 3, C(0xE4F4F4))
            for k in 0..<16 {
                let a = Double(k) / 16 * 2 * .pi
                slayerLine(c, Double(sx), Double(sy), Double(sx) + cos(a) * Double(sr), Double(sy) + sin(a) * Double(ry),
                           brassD, Double(s) * 0.6)
            }
            c.ellipse(sx, sy, sr / 2, ry / 2, brassD.alpha(0.0)); c.ellipse(sx, sy, sr / 5, ry / 5, brass)
            for k in 0..<3 {   // the panes' rings
                let rr = sr * (k + 1) / 4, rv = ry * (k + 1) / 4
                for i in 0..<64 {
                    let a = Double(i) / 64 * 2 * .pi
                    c.rect(sx + Int(cos(a) * Double(rr)), sy + Int(sin(a) * Double(rv)), s, s, brassD)
                }
            }
            c.rect(0, roof, c.w, 6 * s, jadeD); c.rect(0, roof, c.w, s, brass)
            for x in stride(from: 0, to: c.w, by: 6 * s) { c.rect(x + 2 * s, roof + 2 * s, 2 * s, 2 * s, brass) }
            let ch = roof + 26 * s   // the chandelier
            c.rect(sx, sy, max(1, s), ch - sy - 6 * s, brassD)
            c.ellipse(sx, ch - 4 * s, 10 * s, 2 * s, brass); c.ellipse(sx, ch, 14 * s, 2 * s, brassD)
            c.rect(sx - 2 * s, ch - 8 * s, 5 * s, 10 * s, brass); c.ellipse(sx, ch + 3 * s, 3 * s, 2 * s, brass)
            for k in -3...3 {
                c.rect(sx + k * 4 * s, ch - 3 * s, s, 2 * s, C(0xFFF4C8)); c.circle(sx + k * 4 * s, ch - 3 * s, 2 * s, C(0xFFE8A0, 0.3))
            }
            // Tall arched windows between the galleries, LA sunshine and palm tops through them.
            for (i, gy) in f.galleries.enumerated() {
                let wy = gy - 34 * s
                for k in 0..<4 {
                    let wx = c.w * (12 + k * 24) / 100 + (i == 0 ? 0 : 6 * s)
                    if k % 2 == i % 2 {
                        c.rect(wx - 2 * s, wy - 2 * s, 18 * s, 32 * s, jadeD)
                        c.rect(wx, wy + 6 * s, 14 * s, 22 * s, C(0xA8D8E8)); c.ellipse(wx + 7 * s, wy + 6 * s, 7 * s, 7 * s, C(0xA8D8E8))
                        c.rect(wx, wy + 22 * s, 14 * s, 6 * s, C(0xC8E8EC))
                        slayerLine(c, Double(wx + 10 * s), Double(wy + 28 * s), Double(wx + 9 * s), Double(wy + 14 * s), C(0x5A4A2A), Double(s) * 0.6)
                        for d in [-1.0, 1.0] { slayerLine(c, Double(wx + 9 * s), Double(wy + 14 * s), Double(wx + 9 * s) + d * Double(6 * s), Double(wy + 17 * s), C(0x3A6A3A), Double(s) * 0.6) }
                        c.rect(wx + 7 * s - s / 2, wy, max(1, s), 28 * s, jadeD); c.rect(wx, wy + 16 * s, 14 * s, max(1, s), jadeD)
                    } else {
                        slayerHotelDoor(c, wx + s, gy, s)
                        c.rect(wx + 18 * s, gy - 18 * s, 2 * s, 4 * s, brass); c.circle(wx + 19 * s, gy - 19 * s, 3 * s, C(0xFFE8A0, 0.25))
                    }
                }
                // The gallery's floor and its brass railing.
                c.rect(0, gy, c.w, 5 * s, jadeD); c.rect(0, gy, c.w, s, jadeL); c.rect(0, gy + 4 * s, c.w, s, C(0x10261F))
                c.rect(0, gy - 9 * s, c.w, s, brass); c.rect(0, gy - 8 * s, c.w, max(1, s / 2), brassD)
                for x in stride(from: 2 * s, to: c.w, by: 4 * s) { c.rect(x, gy - 8 * s, max(1, s), 8 * s, brassD) }
                for x in stride(from: 0, to: c.w, by: 40 * s) { c.rect(x, gy - 10 * s, 3 * s, 10 * s, brass) }
            }
        }
        // Jade pilasters: with stepped brass caps under a chevron frieze on the screen saver, running up out of sight
        // in the window, a fan-shaped deco sconce on each.
        let top = tall ? f.landing - 50 * s : 0
        if tall {
            let fz = top - 6 * s
            c.rect(0, fz, c.w, 6 * s, jadeD); c.rect(0, fz, c.w, s, brass); c.rect(0, fz + 5 * s, c.w, s, brass)
            for x in stride(from: 0, to: c.w, by: 6 * s) {
                c.rect(x, fz + 2 * s, 2 * s, s, brass); c.rect(x + 2 * s, fz + 3 * s, 2 * s, s, brass); c.rect(x + 4 * s, fz + 2 * s, 2 * s, s, brass)
            }
        }
        let sconce = tall ? f.landing - 26 * s : g - 46 * s
        // Tall arched windows in the bays that are free, LA sunshine and a palm outside.
        let busy = [(f.lift.x - 6 * s, f.lift.x + f.lift.w + 6 * s), (f.desk.x, f.desk.x + f.desk.w), (f.stairs - 8 * s, c.w)]
        for x0 in stride(from: 26 * s, to: c.w, by: 64 * s) {
            let wx = x0 + 10 * s, ww = 36 * s
            guard !busy.contains(where: { wx < $0.1 && wx + ww > $0.0 }) else { continue }
            let wt = top + (tall ? 16 : 10) * s, wb = g - 22 * s, r = ww / 2
            guard wb - wt > r + 6 * s else { continue }
            c.rect(wx - 2 * s, wt + r - 2 * s, ww + 4 * s, wb - wt - r + 4 * s, jadeD); c.circle(wx + r, wt + r, r + 2 * s, jadeD)
            c.rect(wx, wt + r, ww, wb - wt - r, C(0xA8D8E8)); c.circle(wx + r, wt + r, r, C(0xA8D8E8))
            c.rect(wx, wt + r, ww, (wb - wt - r) / 2, C(0x98CCE0))
            c.rect(wx, wb - 6 * s, ww, 6 * s, C(0xC8E4DC))
            let px0 = Double(wx + ww * 2 / 3), pb = Double(wb - 4 * s), ph = Double(wb - wt - r / 2) * 0.8
            slayerLine(c, px0, pb, px0 - Double(2 * s), pb - ph, C(0x5A4A2A), Double(s) * 0.8)
            for a in [-2.8, -2.2, -1.6, -1.0, -0.4] {
                let ex = px0 - Double(2 * s) + cos(a) * Double(9 * s), ey = pb - ph + sin(a) * Double(4 * s) + Double(3 * s)
                slayerLine(c, px0 - Double(2 * s), pb - ph, ex, ey, C(0x3A7A44), Double(s) * 0.7)
            }
            c.rect(wx + r - s / 2, wt, max(1, s), wb - wt, jadeD)
            for y in stride(from: wt + r, to: wb, by: 9 * s) { c.rect(wx, y, ww, max(1, s), jadeD) }
            c.rect(wx - 3 * s, wb, ww + 6 * s, 2 * s, brass)
        }
        for x in stride(from: 18 * s, to: c.w, by: 64 * s) {
            c.rect(x, top, 8 * s, g - top, jade); c.rect(x, top, s, g - top, jadeL); c.rect(x + 7 * s, top, s, g - top, jadeD)
            if tall { for k in 0..<3 { c.rect(x - k * s, top + k * 2 * s, 8 * s + 2 * k * s, 2 * s, k == 2 ? brass : jade) } }
            for k in 0..<3 { c.rect(x + 4 * s - (k + 1) * s, sconce - k * 2 * s, 2 * (k + 1) * s, 2 * s, k == 0 ? brassD : brass) }
            c.rect(x + 2 * s, sconce - 7 * s, 4 * s, s, C(0xFFF0C0))
            c.ellipse(x + 4 * s, sconce - 9 * s, 8 * s, 5 * s, C(0xFFE8A0, 0.18))
            c.rect(x + 3 * s, sconce + 2 * s, 2 * s, g - sconce - 14 * s, jadeL.alpha(0.5))
        }
        // The lift: a brass frame, the dark shaft, and the floor dial above it.
        let l = f.lift, lt = g - l.h
        c.rect(l.x - 3 * s, lt - 3 * s, l.w + 6 * s, l.h + 3 * s, brassD); c.rect(l.x - 3 * s, lt - 3 * s, l.w + 6 * s, s, brass)
        c.rect(l.x, lt, l.w, l.h, C(0x1E1610))
        c.rect(l.x + 2 * s, lt + 2 * s, l.w - 4 * s, l.h - 2 * s, C(0x5A3A22)); c.rect(l.x + 2 * s, lt + 2 * s, l.w - 4 * s, 2 * s, C(0xFFE0A0, 0.6))
        c.rect(l.x + 4 * s, lt + 8 * s, l.w - 8 * s, l.h - 14 * s, C(0x4A2E1A))
        let dy = lt - 6 * s
        slayerDiscAbove4(c, l.x + l.w / 2, dy + 2 * s, 8 * s, dy + 3 * s, brassD)
        slayerDiscAbove4(c, l.x + l.w / 2, dy + 2 * s, 6 * s, dy + 2 * s, C(0xF0E2C0))
        for k in 0..<5 {
            let a = Double.pi * Double(k) / 4
            c.px(l.x + l.w / 2 + Int(cos(a) * Double(5 * s)), dy + 2 * s - Int(sin(a) * Double(5 * s)), C(0x5A4A2A))
        }
        // The key cubbies behind the desk.
        let d = f.desk, kx = d.x + 10 * s, ky = g - 38 * s, kw = d.w - 20 * s
        c.rect(kx - s, ky - s, kw + 2 * s, 18 * s, C(0x3A2214))
        for r in 0..<4 { for q in 0..<(kw / (5 * s)) {
            let x = kx + q * 5 * s, y = ky + r * 4 * s
            c.rect(x, y, 4 * s, 3 * s, C(0x24140A))
            if noise(q * 7 + r * 13) > 0.4 { c.rect(x + s, y + s, s, 2 * s, brass) }
            if noise(q * 7 + r * 13 + 1) > 0.8 { c.rect(x + 2 * s, y + s, 2 * s, s, C(0xF0E8D8)) }
        } }
        // The round desk: a curved, fluted front with a brass top edge, a bell and a lamp on it.
        let dh = 15 * s, dtop = g - dh, dcx = d.x + d.w / 2, half = d.w / 2
        // The front curves round: each column of it shorter and darker towards the sides.
        for i in 0..<d.w {
            let u = Double(i - half) / Double(half)
            let drop = Int((1 - (1 - u * u).squareRoot()) * Double(5 * s))
            let col = abs(u) > 0.8 ? C(0x3A2010) : abs(u) > 0.5 ? C(0x4A2A16) : C(0x5A321C)
            c.rect(d.x + i, dtop + drop, 1, dh - drop - 2 * s, col)
            if (i / max(1, s)) % 5 == 2 { c.rect(d.x + i, dtop + drop + 3 * s, 1, dh - drop - 6 * s, abs(u) > 0.6 ? C(0x2A1608) : C(0x7A4A2A)) }
            c.px(d.x + i, dtop + drop + 2 * s, brassD)
        }
        c.ellipse(dcx, dtop + s, half + s, 4 * s, C(0x7A4A2A)); c.ellipse(dcx, dtop + s, half - 2 * s, 2 * s, C(0x8A5A34))
        c.ellipse(dcx, dtop - 3 * s + 4 * s, half + s, s, brass)
        c.rect(d.x + 3 * s, g - 2 * s, d.w - 6 * s, 2 * s, C(0x2A1608))
        c.rect(d.x + d.w / 2 - 20 * s, dtop - 3 * s, 4 * s, 2 * s, brass); c.rect(d.x + d.w / 2 - 19 * s, dtop - 4 * s, 2 * s, s, brass)
        c.rect(d.x + d.w - 16 * s, dtop - 8 * s, s, 7 * s, brassD)
        slayerWedge4(c, d.x + d.w - 16 * s, dtop - 11 * s, dtop - 7 * s, s, 4 * s, C(0x3E8A78))
        c.rect(d.x + d.w - 14 * s, dtop - 3 * s, 7 * s, 2 * s, C(0xE8DCC0))
        // A potted palm between the lift and the desk.
        let px = (l.x + l.w + d.x) / 2 + 2 * s, pb = g - 7 * s
        for (a, len) in [(-2.4, 14.0), (-1.9, 16.0), (-1.3, 15.0), (-0.7, 14.0), (-1.6, 12.0)] {
            let ex = Double(px) + cos(a) * len * Double(s), ey = Double(pb - 14 * s) + sin(a) * len * Double(s) * 0.7
            slayerLine(c, Double(px), Double(pb - 14 * s), ex, ey, C(0x2E6A34), Double(s) * 1.1)
            slayerLine(c, ex, ey, ex + cos(a) * 3 * Double(s), ey + 4 * Double(s), C(0x2E6A34), Double(s) * 0.8)
        }
        c.rect(px - s, pb - 14 * s, 2 * s, 14 * s, C(0x6A5030))
        c.rect(px - 5 * s, pb, 10 * s, 7 * s, C(0x2A5A50)); c.rect(px - 6 * s, pb, 12 * s, 2 * s, brass)
        // The staircase on the right, up to the landing, red runner and brass rods, a banister.
        let sx = f.stairs, rise = g - f.landing, steps = max(5, rise / (4 * s))
        for k in 0..<steps {
            let y = g - (k + 1) * rise / steps, x = sx + k * 5 * s
            guard x < c.w else { break }
            c.rect(x, y, c.w - x, rise / steps, C(0x6A4428)); c.rect(x, y, c.w - x, s, C(0x8A6038))
            c.rect(x + 3 * s, y, 12 * s, rise / steps, C(0x8A2A2A)); c.rect(x + 3 * s, y + rise / steps - s, 12 * s, s, brass)
        }
        c.rect(sx + steps * 5 * s, f.landing, c.w, 3 * s, jadeD)
        slayerLine(c, Double(sx - 2 * s), Double(g - 12 * s), Double(sx + steps * 5 * s), Double(f.landing - 10 * s), C(0x4A2A16), Double(s))
        for k in stride(from: 0, to: steps, by: 2) {
            let x = sx + k * 5 * s, y = g - (k + 1) * rise / steps
            c.rect(x, y - 10 * s + 2 * s, max(1, s), 10 * s - 2 * s, brassD)
        }
        c.rect(sx - 4 * s, g - 14 * s, 4 * s, 14 * s, C(0x4A2A16)); c.rect(sx - 5 * s, g - 16 * s, 6 * s, 3 * s, brass)
        // Wainscot along the bottom, then the floor.
        c.ground(g, C(0x1E3A34), edge: C(0x3E6A5E), speck: C(0x18302A), seed: 59)
        for x in stride(from: 0, to: c.w, by: 16 * s) { c.rect(x, g + s, max(1, s / 2), c.h - g, C(0x16302A)) }
        c.rect(0, g + (c.h - g) / 2, c.w, max(1, s / 2), C(0xC8A04A, 0.35))
    }

    /// The Hyperion's life: the ceiling fan turning, the lift's brass gate folding open and shut while the floor dial's
    /// needle swings, and dust turning in the sunlight.
    static func slayerHyperionLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerHyperionFrame(c, g)
        let brass = C(0xD0A848), brassD = C(0x8A6A28)
        // The fan: a rod from above, a hub, four blades seen edge-on as they come round.
        let fx = f.fan.x, fy = f.fan.y
        let rod = isTall(c) ? 14 * s : fy
        c.rect(fx, fy - rod, max(1, s), rod, brassD)
        for k in 0..<4 {
            let a = t * 4 + Double(k) * .pi / 2
            let len = 16 * Double(s)
            slayerLine(c, Double(fx), Double(fy + s), Double(fx) + cos(a) * len, Double(fy + s) + sin(a) * len * 0.12,
                       C(0x5A3A22), Double(s) * 0.8)
        }
        c.rect(fx - 2 * s, fy - s, 5 * s, 3 * s, brass); c.rect(fx - s, fy + 2 * s, 3 * s, 2 * s, C(0xF0E2C0))
        // The lift's gate.
        let k = frac(t / 14)
        let open = k < 0.2 ? 0 : k < 0.3 ? (k - 0.2) / 0.1 : k < 0.6 ? 1 : k < 0.7 ? 1 - (k - 0.6) / 0.1 : 0
        let l = f.lift, lt = g - l.h
        let gw = Int(Double(l.w) * (1 - open * 0.8))
        if gw > 2 * s {
            c.rect(l.x, lt, gw, s, brass); c.rect(l.x, g - 2 * s, gw, s, brass)
            let step = 4 * s
            for x in stride(from: l.x, to: l.x + gw, by: step) {
                slayerLine(c, Double(x), Double(lt), Double(min(x + step, l.x + gw)), Double(g - 2 * s), brassD, Double(s) * 0.5)
                slayerLine(c, Double(min(x + step, l.x + gw)), Double(lt), Double(x), Double(g - 2 * s), brassD, Double(s) * 0.5)
            }
            c.rect(l.x + gw - s, lt, s, l.h - s, brass)
        }
        // The dial's needle: the car comes down, waits, and goes back up.
        let lev = k < 0.2 ? 1 - k / 0.2 : k < 0.7 ? 0 : (k - 0.7) / 0.3
        let a = .pi * (1 - lev)
        let dx = l.x + l.w / 2, dy = lt - 6 * s + 2 * s
        slayerLine(c, Double(dx), Double(dy), Double(dx) + cos(a) * Double(5 * s), Double(dy) - sin(a) * Double(4 * s), C(0x2A1A10), Double(s) * 0.5)
        // Sunlit dust.
        for m in 0..<10 {
            let x = c.w * 20 / 100 + Int(noise(m * 3 + 400) * Double(c.w * 60 / 100)) + Int(sin(t * 0.3 + Double(m)) * Double(4 * s))
            let y = Int(Double(g) * (0.1 + 0.6 * frac(noise(m * 3 + 401) + t * 0.01)))
            c.px(x, y, C(0xFFF8E0, 0.5))
        }
    }
}

// MARK: - Caritas

extension Scenes {
    /// Where things stand in Caritas: the stage, the mic, the disco ball, the lyrics monitor, and the rafters.
    static func slayerCaritasFrame(_ c: PixelCanvas, _ g: Int) -> (stage: (x: Int, w: Int, top: Int), ball: (x: Int, y: Int, r: Int),
                                                                    monitor: (x: Int, y: Int, w: Int, h: Int), rafters: Int?) {
        let s = unit(g), tall = isTall(c)
        let stage = (x: c.w * 62 / 100, w: c.w * 34 / 100, top: g - 6 * s)
        let rafters: Int? = tall ? 40 * s : nil
        let ball = tall ? (x: c.w * 48 / 100, y: g - 104 * s, r: 10 * s) : (x: c.w * 49 / 100, y: 13 * s, r: 6 * s)
        let mw = tall ? 30 * s : 22 * s, mh = tall ? 20 * s : 14 * s
        let monitor = (x: stage.x - mw - 6 * s, y: tall ? g - 52 * s : g - 40 * s, w: mw, h: mh)
        return (stage, ball, monitor, rafters)
    }

    /// Caritas, the karaoke bar for demons: teal velvet walls with gold trim, a coral neon "CARITAS" sign, round tables
    /// with little red lamps where horned and finned demon patrons sit in silhouette, the small stage with its silver
    /// tinsel curtain and the chrome mic stand in a coral spotlight, and a monitor for the lyrics. On the screen saver
    /// the rafters carry a rig of coloured lights throwing soft beams down.
    static func slayerCaritas(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerCaritasFrame(c, g), st = f.stage
        let gold = C(0xD8B050), goldD = C(0x8A6A2A)
        c.gradient(0, g, C(0x062020), C(0x0E3A38), bands: 6)
        // Velvet: soft vertical folds.
        for x in stride(from: 0, to: c.w, by: 7 * s) {
            c.rect(x, 0, 2 * s, g, C(0x041818, 0.5)); c.rect(x + 3 * s, 0, s, g, C(0x1E5450, 0.35))
        }
        if let r = f.rafters {
            // The rafters and the light rig.
            c.rect(0, 0, c.w, r + 6 * s, C(0x040C0E))
            for x in stride(from: 0, to: c.w, by: 50 * s) { c.rect(x, 0, 6 * s, r, C(0x0C1A1C)); c.rect(x, 0, s, r, C(0x1A2E30)) }
            c.rect(0, r / 2, c.w, 4 * s, C(0x0C1A1C)); c.rect(0, r / 2, c.w, s, C(0x1A2E30))
            c.rect(0, r, c.w, 3 * s, C(0x3A4448)); c.rect(0, r + 5 * s, c.w, 2 * s, C(0x3A4448))
            for x in stride(from: 0, to: c.w, by: 6 * s) { slayerLine(c, Double(x), Double(r + 2 * s), Double(x + 3 * s), Double(r + 5 * s), C(0x3A4448), Double(s) * 0.4) }
            let cols: [UInt32] = [0xFF5A5A, 0x5AE0A0, 0x6A8AFF, 0xFFC04A, 0xFF6AC8, 0x5AE0E0]
            for k in 0..<9 {
                let x = c.w * (6 + k * 11) / 100, col = C(cols[k % cols.count])
                let lean = (Double(k) - 4) * -0.12
                slayerWedge4(c, x, r + 12 * s, g - 40 * s, 2 * s, 20 * s, col.alpha(0.05), lean: lean)
                c.rect(x - 3 * s, r + 7 * s, 6 * s, 6 * s, C(0x1A1E20)); c.rect(x - 3 * s, r + 7 * s, 6 * s, s, C(0x4A5458))
                c.rect(x - 2 * s, r + 12 * s, 4 * s, 2 * s, col); c.circle(x, r + 13 * s, 5 * s, col.alpha(0.18))
            }
        }
        if tall {
            // Gold starbursts up the velvet, Vegas lounge style, and red velvet swags framing the stage.
            let bursts: [(x: Int, y: Int)] = [(8, 50), (30, 34), (70, 30), (90, 52), (40, 74), (58, 60)]
            for (i, b) in bursts.enumerated() {
                let bx = c.w * b.x / 100, by = (f.rafters ?? 0) + (g - (f.rafters ?? 0)) * b.y / 100
                let rr = (i % 2 == 0 ? 12 : 9) * s
                c.circle(bx, by, rr + 4 * s, C(0xFFD870, 0.06))
                for k in 0..<12 {
                    let a = Double(k) / 12 * 2 * .pi, len = Double(k % 2 == 0 ? rr : rr * 2 / 3)
                    slayerLine(c, Double(bx), Double(by), Double(bx) + cos(a) * len, Double(by) + sin(a) * len, gold, Double(s) * 0.5)
                    c.rect(bx + Int(cos(a) * len) - s / 2, by + Int(sin(a) * len) - s / 2, s, s, C(0xFFF0B0))
                }
                c.circle(bx, by, 2 * s, C(0xFFF0B0))
            }
        }
        // Gold trim: a dado rail and a cornice.
        let rail = g - 18 * s
        c.rect(0, rail, c.w, 2 * s, goldD); c.rect(0, rail, c.w, s, gold)
        c.gradient(rail + 2 * s, g, C(0x3A1418), C(0x2A0E12), bands: 3)   // the red panelling under it
        for x in stride(from: 6 * s, to: c.w, by: 24 * s) { c.rect(x, rail + 4 * s, 18 * s, g - rail - 6 * s, C(0x4A1E22)) }
        // The neon sign.
        let word = "CARITAS", p = tall ? 3 * s : 2 * s
        let nx = c.w * 22 / 100 - slayerTextWidth4(word, p) / 2, ny = tall ? g - 78 * s : g - 46 * s
        c.ellipse(nx + slayerTextWidth4(word, p) / 2, ny + 5 * p / 2, slayerTextWidth4(word, p) * 2 / 3, 6 * p, C(0xFF7A5A, 0.10))
        slayerText4(c, nx + s, ny + s, word, C(0x2A0E0A, 0.6), p)
        slayerText4(c, nx, ny, word, C(0xFF8A6A), p)
        // Round tables with lamps, demon patrons sat at them.
        func patron(_ x: Int, _ base: Int, kind: Int, rim: Px) {
            let ink = C(0x061010)
            c.rect(x - 4 * s, base - 12 * s, 8 * s, 12 * s, ink); c.circle(x, base - 15 * s, 4 * s, ink)
            c.rect(x - 4 * s, base - 12 * s, s, 11 * s, rim); c.rect(x - 3 * s, base - 18 * s, s, 3 * s, rim)
            switch kind {
            case 0:   // horns
                c.rect(x - 4 * s, base - 21 * s, s, 3 * s, ink); c.rect(x - 5 * s, base - 23 * s, s, 2 * s, ink)
                c.rect(x + 3 * s, base - 21 * s, s, 3 * s, ink); c.rect(x + 4 * s, base - 23 * s, s, 2 * s, ink)
                c.rect(x - 5 * s, base - 23 * s, s, 2 * s, rim)
            case 1:   // a fin
                for k in 0..<5 { c.rect(x - s + k * s / 2, base - 20 * s - k * s, 2 * s, s, ink) }
                c.rect(x - s, base - 20 * s, s, s, rim)
            default:  // big pointed ears
                c.rect(x - 7 * s, base - 17 * s, 3 * s, s, ink); c.rect(x - 8 * s, base - 18 * s, 2 * s, s, ink)
                c.rect(x + 4 * s, base - 17 * s, 3 * s, s, ink); c.rect(x + 6 * s, base - 18 * s, 2 * s, s, ink)
                c.rect(x - 8 * s, base - 18 * s, 2 * s, s, rim)
            }
            c.rect(x - 2 * s, base - 16 * s, s, s, C(0xF0E040)); c.rect(x + s, base - 16 * s, s, s, C(0xF0E040))
        }
        func table(_ x: Int) {
            let top = g - 10 * s
            c.ellipse(x, top, 9 * s, 2 * s, C(0x2A1A10)); c.rect(x - 9 * s, top, 18 * s, s, gold)
            c.rect(x - s, top + s, 2 * s, g - top - s, C(0x1A100A)); c.rect(x - 4 * s, g - s, 8 * s, s, C(0x1A100A))
            c.rect(x - s, top - 5 * s, 2 * s, 4 * s, goldD); c.rect(x - 3 * s, top - 7 * s, 6 * s, 3 * s, C(0xC83A2A))
            c.circle(x, top - 4 * s, 6 * s, C(0xFF6A3A, 0.15))
            c.rect(x + 4 * s, top - 3 * s, 2 * s, 3 * s, C(0x8AD8C8, 0.7))   // a drink
        }
        patron(c.w * 6 / 100, g - 8 * s, kind: 0, rim: C(0x6AE08A))
        table(c.w * 12 / 100)
        patron(c.w * 18 / 100, g - 8 * s, kind: 2, rim: C(0x6A9AFF))
        patron(c.w * 32 / 100, g - 8 * s, kind: 1, rim: C(0xFF7A5A))
        table(c.w * 38 / 100)
        patron(c.w * 44 / 100, g - 8 * s, kind: 0, rim: C(0xE07AFF))
        // The stage: tinsel curtain, a gold-edged platform, the mic in its spotlight.
        let ct = tall ? g - 76 * s : 10 * s
        c.rect(st.x - 3 * s, ct - 3 * s, st.w + 6 * s, 4 * s, goldD); c.rect(st.x - 3 * s, ct - 3 * s, st.w + 6 * s, s, gold)
        for x in stride(from: st.x, to: st.x + st.w, by: s) {
            let i = (x - st.x) / max(1, s)
            let col = i % 3 == 0 ? C(0xC8D8E0) : i % 3 == 1 ? C(0x7A8A98) : C(0x2A3640)
            let ragged = Int(noise(i + 800) * 3) * s
            c.rect(x, ct + s, s, st.top - ct - s - ragged, col.alpha(0.85))
        }
        if tall {
            let red = C(0x8A1A22), redL = C(0xB83A3A)
            for side in [0, 1] {
                for i in 0..<28 {
                    let y = ct + i * 2 * s, w = max(2 * s, (28 - i) * s * 3 / 4)
                    let x = side == 0 ? st.x - 3 * s : st.x + st.w + 3 * s - w
                    c.rect(x, y, w, 2 * s, red); c.rect(side == 0 ? x + w - s : x, y, s, 2 * s, redL)
                }
            }
            for k in 0..<5 { c.ellipse(st.x + st.w * (2 * k + 1) / 10, ct + 2 * s, st.w / 10 + s, 4 * s, k % 2 == 0 ? red : C(0x7A1620)) }
        }
        c.ellipse(st.x + st.w / 2, st.top - 20 * s, st.w / 3, 22 * s, C(0xFF8A6A, 0.10))
        c.rect(st.x - 2 * s, st.top, st.w + 4 * s, g - st.top, C(0x2A1A10)); c.rect(st.x - 2 * s, st.top, st.w + 4 * s, s, gold)
        c.ellipse(st.x + st.w / 2, st.top + s, 16 * s, 2 * s, C(0xFFB09A, 0.35))
        let mx = st.x + st.w / 2
        c.rect(mx - 5 * s, st.top - 2 * s, 10 * s, 2 * s, C(0x1A1A20)); c.rect(mx - s, st.top - 22 * s, 2 * s, 21 * s, C(0x1A1A20))
        c.rect(mx, st.top - 22 * s, max(1, s / 2 + s % 2), 21 * s, C(0x8A949C))
        slayerLine(c, Double(mx), Double(st.top - 22 * s), Double(mx - 4 * s), Double(st.top - 26 * s), C(0x1A1A20), Double(s) * 0.8)
        c.rect(mx - 7 * s, st.top - 29 * s, 4 * s, 4 * s, C(0x1A1A20)); c.rect(mx - 7 * s, st.top - 29 * s, 4 * s, s, C(0x9AA4AC))
        // The lyrics monitor on its pole.
        let m = f.monitor
        c.rect(m.x + m.w / 2 - s, m.y + m.h, 2 * s, g - m.y - m.h, C(0x1A1E20))
        c.rect(m.x - 2 * s, m.y - 2 * s, m.w + 4 * s, m.h + 4 * s, C(0x1A1E20)); c.rect(m.x, m.y, m.w, m.h, C(0x0A1A3A))
        // The disco ball's cord.
        let b = f.ball
        let cordTop = f.rafters.map { $0 + 3 * s } ?? 0
        c.rect(b.x, cordTop, max(1, s), b.y - b.r - cordTop, C(0x2A3436))
        // The floor.
        c.ground(g, C(0x1A1416), edge: C(0x3A2A2C), speck: C(0x120E10), seed: 71)
    }

    /// Caritas's life: the disco ball turning, its facets glinting, specks of light gliding round the walls, and lyrics
    /// scrolling up the monitor with the line being sung picked out.
    static func slayerCaritasLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerCaritasFrame(c, g), b = f.ball
        // The ball: grey facets in a grid, a few catching the light as it turns.
        c.circle(b.x, b.y, b.r, C(0x6A747C))
        let step = max(2, b.r / 3)
        let turn = Int(t * 3)
        for dy in stride(from: -b.r, through: b.r, by: step) {
            let half = Int((Double(b.r * b.r - dy * dy)).squareRoot())
            for dx in stride(from: -half, to: half, by: step) {
                let i = (dx + b.r) / step + (dy + b.r) / step * 13 + turn
                let lit = noise(i * 7) > 0.72
                c.rect(b.x + dx, b.y + dy, step - 1, step - 1, lit ? C(0xF8FCFF) : (noise(i * 3) > 0.5 ? C(0xA8B4BC) : C(0x5A646C)))
            }
        }
        c.circle(b.x, b.y, b.r * 2, C(0xE8F0FF, 0.06))
        // Specks of light round the walls, kept above the crew.
        let cols: [UInt32] = [0xFFFFFF, 0xFF9A7A, 0x8AF0E0, 0xFFE08A]
        let span = c.w + 40 * s
        for k in 0..<18 {
            let x = (Int(noise(k * 5 + 1) * Double(span)) + Int(t * Double(14 * s) * (0.8 + noise(k * 5 + 2) * 0.4))) % span - 20 * s
            let hi = isTall(c) ? (f.rafters ?? 0) + 20 * s : 2 * s
            let y = hi + Int(noise(k * 5 + 3) * Double(max(1, g - 26 * s - hi)))
            c.rect(x, y, 2 * s, s, C(cols[k % cols.count], 0.35)); c.px(x, y + s, C(cols[k % cols.count], 0.2))
        }
        // Lyrics: lines of text-blocks scrolling up, the current one filling in coral as it's sung.
        let m = f.monitor
        let lineH = 4 * s, scroll = t * 0.8
        let first = Int(scroll), off = Int(frac(scroll) * Double(lineH))
        for r in 0..<(m.h / lineH + 1) {
            let y = m.y + 2 * s + r * lineH - off
            guard y >= m.y + s, y + s <= m.y + m.h - s else { continue }
            let n = first + r
            var x = m.x + 2 * s
            var w = 0
            let current = r == 1
            for word in 0..<4 {
                let ww = (2 + Int(noise(n * 11 + word) * 4)) * s
                guard x + ww <= m.x + m.w - 2 * s else { break }
                let sung = current && Double(w + ww) < frac(scroll) * Double(m.w) * 1.4
                c.rect(x, y, ww, s, sung ? C(0xFF8A6A) : C(0xE0F0FF, current ? 0.95 : 0.55))
                x += ww + s; w += ww + s
            }
        }
        // Glints running down the tinsel.
        let ct = isTall(c) ? g - 76 * s : 10 * s
        for k in 0..<7 {
            let x = f.stage.x + Int(noise(k * 7 + 40) * Double(f.stage.w))
            let y = ct + Int(frac(noise(k * 7 + 41) + t * 0.15) * Double(f.stage.top - ct))
            c.rect(x, y, s, 2 * s, C(0xFFFFFF, 0.8))
        }
        // The spotlight breathing on the mic.
        let st = f.stage
        c.ellipse(st.x + st.w / 2, st.top + s, 12 * s, 2 * s, C(0xFFB09A, 0.12 + 0.08 * sin(t * 1.5)))
    }
}

// MARK: - Wolfram & Hart

extension Scenes {
    /// Where things stand in Wolfram & Hart's lobby: the logo wall, the glass wall, the lifts, and (on the screen
    /// saver) the mezzanine.
    static func slayerWolframHartFrame(_ c: PixelCanvas, _ g: Int) -> (wall: (x: Int, w: Int, top: Int), glass: (x0: Int, x1: Int, top: Int),
                                                                       lifts: [Int], liftH: Int, mezz: Int?) {
        let s = unit(g), tall = isTall(c)
        let ceiling = tall ? 14 * s : 5 * s
        let lifts = [c.w * 84 / 100, c.w * 92 / 100]
        return ((c.w * 3 / 100, c.w * 26 / 100, tall ? g - 110 * s : g - 46 * s), (c.w * 33 / 100, c.w * 80 / 100, ceiling),
                lifts, tall ? 46 * s : 36 * s, tall ? g - 150 * s : nil)
    }

    /// Wolfram & Hart's Los Angeles lobby at night: pale stone and steel under a row of recessed lights, the great
    /// logo wall on the left in dark granite left blank, the sleek white reception desk in front of it with a cyan
    /// strip of light, a glass curtain wall showing the city's towers lit gold and white with palms and a freeway far
    /// below, two steel lifts on the right, and polished dark stone underfoot. On the screen saver the glass climbs the
    /// tower's full height past a mezzanine with a glass balustrade, and the skyline rises with it to a crowned tower.
    static func slayerWolframHart(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerWolframHartFrame(c, g)
        let stone = C(0xC8CCD0), stoneD = C(0x9AA0A8), steel = C(0x7A848E), steelL = C(0xB8C4CC)
        c.gradient(0, g, C(0xDDE2E6), stone, bands: 4)
        // The glass wall: the night sky and the city through it.
        let gl = f.glass, gw = gl.x1 - gl.x0
        let sky = PixelCanvas(gw, g - gl.top)
        let hz = sky.h - (tall ? 20 : 10) * s
        sky.gradient(0, sky.h, C(0x10183A), C(0x5A3A6A), bands: tall ? 10 : 5)
        sky.stars(0, hz / 2, density: 90, seed: 3)
        // Towers, far and near, windows lit.
        func tower(_ x: Int, _ w: Int, _ h: Int, _ col: Px, lit: Double, seed: Int, crown: Bool = false) {
            let top = hz - h
            sky.rect(x, top, w, sky.h - top, col)
            sky.rect(x, top, max(1, s), sky.h - top, col.alpha(0.6))
            for y in stride(from: top + 2 * s, to: sky.h, by: 3 * s) {
                for xx in stride(from: x + s, to: x + w - s, by: 2 * s) where noise(xx * 7 + y * 13 + seed) < lit {
                    sky.px(xx, y, noise(xx + y + seed) > 0.4 ? C(0xFFD890) : C(0xE8F4FF))
                }
            }
            if crown {   // a lit crown, like the Library Tower's
                for k in 0..<4 { sky.rect(x + k * 2 * s, top - (4 - k) * 2 * s, w - k * 4 * s, 2 * s, k % 2 == 0 ? C(0xE8F4FF) : col) }
                sky.rect(x + w / 2, top - 14 * s, max(1, s), 6 * s, C(0x8A9AAA))
            }
        }
        let scale = tall ? 5 : 1
        for k in 0..<10 {
            let w = (8 + Int(noise(k + 1100) * 10)) * s, h = (6 + Int(noise(k + 1101) * 14)) * s * scale
            tower(Int(noise(k + 1102) * Double(gw)), w, h, C(0x1E2440), lit: 0.25, seed: k)
        }
        // The nearer towers: (x %, width, height in the window, height on the screen saver).
        let near: [(x: Int, w: Int, h: Int, th: Int)] = [(4, 16, 26, 150), (24, 12, 20, 112), (44, 20, 34, 236), (70, 14, 22, 176),
                                                         (86, 18, 28, 128), (58, 10, 0, 90), (14, 9, 0, 70)]
        for (k, n) in near.enumerated() {
            let h = tall ? n.th : n.h
            guard h > 0 else { continue }
            tower(gw * n.x / 100, n.w * s, h * s, k > 4 ? C(0x1A1E38) : C(0x161A30), lit: 0.4, seed: 50 + k, crown: tall && k == 2)
        }
        // Palms and the freeway far below.
        sky.rect(0, hz + 2 * s, gw, sky.h - hz, C(0x0C0E1C))
        sky.rect(0, hz + 4 * s, gw, s, C(0x3A3A50))
        for k in 0..<5 {
            let x = gw * (8 + k * 21) / 100, h = (tall ? 16 : 9) * s
            slayerLine(sky, Double(x), Double(hz + 3 * s), Double(x + s), Double(hz + 3 * s - h), C(0x0A0A14), Double(s) * 0.5)
            for d in [-1.0, -0.4, 0.4, 1.0] {
                slayerLine(sky, Double(x + s), Double(hz + 3 * s - h), Double(x + s) + d * Double(4 * s), Double(hz + 4 * s - h) + abs(d) * Double(2 * s),
                           C(0x0A0A14), Double(s) * 0.5)
            }
        }
        c.paste(sky, x: gl.x0, y: gl.top)
        // Glass: a cool sheen, then steel mullions and transoms.
        c.rect(gl.x0, gl.top, gw, g - gl.top, C(0x8AD8E8, 0.08))
        for x in stride(from: gl.x0, through: gl.x1, by: max(24 * s, gw / 8)) { c.rect(x, gl.top, 2 * s, g - gl.top, steel); c.rect(x, gl.top, max(1, s / 2), g - gl.top, steelL) }
        c.rect(gl.x1 - 2 * s, gl.top, 2 * s, g - gl.top, steel)
        for y in stride(from: gl.top + 26 * s, to: g - 4 * s, by: 34 * s) { c.rect(gl.x0, y, gw, s, steel.alpha(0.8)) }
        c.rect(gl.x0, g - 3 * s, gw, 3 * s, stoneD)
        // Big stone panels on the walls either side of the glass.
        for y in stride(from: gl.top + 30 * s, to: g, by: 30 * s) {
            c.rect(0, y, gl.x0, max(1, s / 2), stoneD.alpha(0.6)); c.rect(gl.x1, y, c.w - gl.x1, max(1, s / 2), stoneD.alpha(0.6))
        }
        for x in stride(from: 20 * s, to: c.w, by: 40 * s) where x < gl.x0 || x > gl.x1 { c.rect(x, gl.top, max(1, s / 2), g - gl.top, stoneD.alpha(0.5)) }
        // The mezzanine on the screen saver: a floor slab and a glass balustrade across the whole lobby, glass-fronted
        // offices behind it, lit late.
        if let mz = f.mezz {
            let ot = mz - 64 * s
            for (x0, x1) in [(0, gl.x0), (gl.x1, c.w)] {
                c.rect(x0, ot, x1 - x0, mz - ot, C(0x5A646E)); c.rect(x0, ot, x1 - x0, s, steelL)
                for x in stride(from: x0 + 3 * s, to: x1 - 20 * s, by: 26 * s) {
                    c.rect(x, ot + 4 * s, 22 * s, mz - ot - 4 * s, C(0xD8F0F4))
                    c.rect(x, ot + 4 * s, 22 * s, 2 * s, C(0xFFFFFF)); c.rect(x + 3 * s, mz - 14 * s, 12 * s, 2 * s, C(0x8A949C))
                    c.rect(x + 7 * s, mz - 20 * s, 6 * s, 5 * s, C(0x2A2E34)); c.rect(x + 8 * s, mz - 19 * s, 4 * s, 3 * s, C(0x6AD0F0))
                    c.rect(x + 21 * s, ot + 4 * s, s, mz - ot - 4 * s, steel)
                }
            }
            c.rect(0, mz, c.w, 6 * s, stoneD); c.rect(0, mz, c.w, s, C(0xF0F4F6)); c.rect(0, mz + 5 * s, c.w, s, C(0x6A7078))
            c.rect(0, mz - 12 * s, c.w, 12 * s, C(0x9AE0F0, 0.12)); c.rect(0, mz - 12 * s, c.w, s, steelL)
            for x in stride(from: 0, to: c.w, by: 30 * s) { c.rect(x, mz - 12 * s, max(1, s), 12 * s, steel) }
            for k in 0..<10 { c.rect(c.w * (5 + k * 10) / 100, mz + 6 * s, 6 * s, s, C(0xF8FCFF)) }
        }
        // The ceiling and its row of recessed lights.
        c.rect(0, 0, c.w, gl.top, C(0xE8ECEE)); c.rect(0, gl.top - s, c.w, s, stoneD)
        for x in stride(from: 10 * s, to: c.w, by: 30 * s) {
            c.rect(x, gl.top - 2 * s, 6 * s, s, C(0xFFFFFF))
            if x + 10 * s < gl.x0 || x > gl.x1 { slayerWedge4(c, x + 3 * s, gl.top, gl.top + 10 * s, 3 * s, 8 * s, C(0xFFFFFF, 0.08)) }
        }
        // The logo wall: a dark granite panel framed in steel, washed with light from above, and blank.
        let w = f.wall
        c.rect(w.x - 3 * s, w.top - 3 * s, w.w + 6 * s, g - w.top + 3 * s, steel); c.rect(w.x - 3 * s, w.top - 3 * s, w.w + 6 * s, s, steelL)
        c.rect(w.x, w.top, w.w, g - w.top, C(0x26282E))
        for k in 0..<2 {   // a soft sheen across the polished granite
            let x0 = w.x + w.w * (20 + k * 40) / 100
            slayerLine(c, Double(x0), Double(g), Double(x0 + w.w / 4), Double(w.top), C(0xE8F4FF, 0.035), Double((6 - k * 3) * s))
        }
        c.rect(w.x, w.top, w.w, 3 * s, C(0xE8F4FF, 0.08)); c.rect(w.x, w.top + 3 * s, w.w, 4 * s, C(0xE8F4FF, 0.04))
        for k in 0..<4 { c.rect(w.x + w.w * (1 + k * 2) / 8 - s, w.top, 2 * s, s, C(0xFFFFFF)) }
        // The reception desk: long, white, a cyan strip of light at its foot, a monitor glowing on it.
        let dx = w.x + 6 * s, dw = w.w - 12 * s, dt = g - 13 * s
        c.rect(dx, dt, dw, 13 * s, C(0xEEF2F4)); c.rect(dx, dt, dw, 2 * s, C(0xFFFFFF)); c.rect(dx + dw - 3 * s, dt, 3 * s, 13 * s, C(0xC0C8CE))
        c.rect(dx, dt + 2 * s, dw, s, C(0x9AA4AC))
        c.rect(dx, g - 2 * s, dw, s, C(0x5AF0FF)); c.rect(dx - 2 * s, g - s, dw + 4 * s, s, C(0x5AF0FF, 0.35))
        c.rect(dx + dw / 3, dt - 6 * s, 9 * s, 6 * s, C(0x2A2E34)); c.rect(dx + dw / 3 + s, dt - 5 * s, 7 * s, 4 * s, C(0x6AD0F0))
        c.rect(dx + dw * 2 / 3, dt - 3 * s, 2 * s, 3 * s, C(0x3A6A3A)); c.rect(dx + dw * 2 / 3 - s, dt - 6 * s, 4 * s, 3 * s, C(0x5A9A4A))
        // The lifts: brushed steel doors in stone surrounds, an indicator strip over each.
        for lx in f.lifts {
            let lw = 18 * s, lh = f.liftH, lt = g - lh
            c.rect(lx - lw / 2 - 3 * s, lt - 8 * s, lw + 6 * s, lh + 8 * s, stoneD)
            c.rect(lx - lw / 2, lt, lw, lh, C(0x9AA4AE)); c.rect(lx - lw / 2, lt, lw, s, steelL)
            for x in stride(from: lx - lw / 2 + s, to: lx + lw / 2, by: 3 * s) { c.rect(x, lt + s, max(1, s / 2), lh - s, C(0xB0BAC2)) }
            c.rect(lx - s / 2, lt, max(1, s), lh, C(0x5A646E))
            c.rect(lx - 8 * s, lt - 6 * s, 16 * s, 3 * s, C(0x1A1E24))
            c.rect(lx + lw / 2 + s, lt + lh / 2, 2 * s, 3 * s, C(0x2A2E34)); c.px(lx + lw / 2 + s, lt + lh / 2 + s, C(0xFFE08A))
        }
        // Polished stone underfoot, the glass and the lights faintly mirrored in it.
        c.ground(g, C(0x2A2E36), edge: C(0x5A626E), speck: C(0x242830), seed: 83)
        c.rect(gl.x0, g + s, gw, c.h - g - s, C(0x8AD8E8, 0.05))
        for x in stride(from: gl.x0, through: gl.x1, by: max(24 * s, gw / 8)) { c.rect(x, g + s, 2 * s, (c.h - g) / 2, C(0xB8C4CC, 0.12)) }
        c.rect(f.wall.x + 6 * s, g + s, f.wall.w - 12 * s, s, C(0x5AF0FF, 0.25))
    }

    /// Wolfram & Hart's life: each lift's floor lights stepping up and down, windows in the city lighting and going
    /// dark, a plane's light blinking across the sky, and cars streaming on the freeway far below.
    static func slayerWolframHartLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerWolframHartFrame(c, g), gl = f.glass, gw = gl.x1 - gl.x0
        for (i, lx) in f.lifts.enumerated() {
            let lt = g - f.liftH, n = 6
            let ph = frac(t / (9 + Double(i) * 3) + Double(i) * 0.4)
            let at = Int((ph < 0.5 ? ph * 2 : 2 - ph * 2) * Double(n - 1) + 0.5)
            for k in 0..<n {
                let x = lx - 7 * s + k * 14 * s / n
                c.rect(x, lt - 5 * s, s, s, k == at ? C(0xFFE08A) : C(0x4A4E56))
            }
            if at == 0 { c.rect(lx - 9 * s, lt, 18 * s, s, C(0xFFF0C0, 0.4)) }
        }
        // The city: some windows switching on and off.
        let hz = g - (isTall(c) ? 20 : 10) * s
        for k in 0..<14 {
            let x = gl.x0 + 4 * s + Int(noise(k * 3 + 1300) * Double(gw - 8 * s))
            let y = gl.top + Int(Double(hz - gl.top) * (0.55 + 0.4 * noise(k * 3 + 1301)))
            if noise(k * 3 + 1302 + Int(t / 3) * 17) > 0.5 { c.px(x, y, C(0xFFE8A0)) }
        }
        // A plane crossing high up, blinking.
        let k = frac(t / 30)
        let px = gl.x0 + Int(k * Double(gw)), py = gl.top + 6 * s + Int(k * Double(4 * s))
        c.px(px, py, C(0xF0F4FF, 0.7))
        if Int(t * 1.5) % 2 == 0 { c.px(px + s, py, C(0xFF4A3A)) }
        // The freeway: headlights one way, tail lights the other.
        let fy = hz + 4 * s
        for m in 0..<8 {
            let u = frac(noise(m) + t * 0.05 * (0.8 + noise(m + 5) * 0.4))
            let east = m % 2 == 0
            let x = gl.x0 + Int((east ? u : 1 - u) * Double(gw))
            c.px(x, fy + (east ? -s : s), east ? C(0xFFF4D8) : C(0xFF3A2A))
        }
    }
}
