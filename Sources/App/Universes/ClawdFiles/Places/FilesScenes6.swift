import Foundation

// Small towns: Gibsonton, Lake Okobogee, the Mutato's farm and the motel in Chaney, Texas.

let filesScenes6: [Location: Place] = [
    .gibsonton: Place(name: "Gibsonton, Florida", panel: 0x1A1428, still: Scenes.gibsonton, moving: Scenes.gibsontonLife),
    .lakeOkobogee: Place(name: "Lake Okobogee", panel: 0x101A26, still: Scenes.lakeOkobogee, moving: Scenes.lakeOkobogeeLife),
    .mutatoFarm: Place(name: "The Mutato's Farm", panel: 0x1C1C1C, still: Scenes.mutatoFarm, moving: Scenes.mutatoFarmLife),
    .chaneyMotel: Place(name: "Chaney, Texas", panel: 0x0E1020, still: Scenes.chaneyMotel, moving: Scenes.chaneyMotelLife),
]

// MARK: - Shared bits

/// Capital letters in a 3×5 pixel font (5 wide for M and W), for the signs in these towns.
private let s6Glyphs: [Character: [String]] = [
    "A": [".#.", "#.#", "###", "#.#", "#.#"], "B": ["##.", "#.#", "##.", "#.#", "##."],
    "C": [".##", "#..", "#..", "#..", ".##"], "D": ["##.", "#.#", "#.#", "#.#", "##."],
    "E": ["###", "#..", "##.", "#..", "###"], "G": [".##", "#..", "#.#", "#.#", ".##"],
    "H": ["#.#", "#.#", "###", "#.#", "#.#"], "I": ["###", ".#.", ".#.", ".#.", "###"],
    "L": ["#..", "#..", "#..", "#..", "###"], "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"],
    "N": ["#.#", "###", "###", "#.#", "#.#"], "O": [".#.", "#.#", "#.#", "#.#", ".#."],
    "P": ["##.", "#.#", "##.", "#..", "#.."], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
    "S": [".##", "#..", ".#.", "..#", "##."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "U": ["#.#", "#.#", "#.#", "#.#", "###"], "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"],
    "Y": ["#.#", "#.#", ".#.", ".#.", ".#."], "Z": ["###", "..#", ".#.", "#..", "###"],
    "!": ["#", "#", "#", ".", "#"], " ": [".", ".", ".", ".", "."],
]

/// How wide `text` comes out at pixel size `s`.
private func s6TextWidth(_ text: String, s: Int) -> Int {
    (text.reduce(0) { $0 + (s6Glyphs[$1]?[0].count ?? 3) + 1 } - 1) * s
}

/// `text` in the town font, its left edge at `x`.
private func s6Text(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, _ col: Px) {
    var x = x
    for ch in text {
        let rows = s6Glyphs[ch] ?? s6Glyphs[" "]!
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" { c.rect(x + dx * s, y + dy * s, s, s, col) }
        }
        x += (rows[0].count + 1) * s
    }
}

/// A sagging wire from (x0, y0) to (x1, y1), `sag` lower in the middle; calls `dot` for each column.
private func s6Wire(x0: Int, y0: Int, x1: Int, y1: Int, sag: Int, _ dot: (Int, Int, Double) -> Void) {
    guard x1 > x0 else { return }
    for x in x0...x1 {
        let k = Double(x - x0) / Double(x1 - x0)
        dot(x, y0 + Int(Double(y1 - y0) * k + sin(k * .pi) * Double(sag)), k)
    }
}

// MARK: - Gibsonton, Florida

extension Scenes {
    /// Where things stand in Gibsonton: the palms (x, height), the Ferris wheel, the banner and its poles.
    static func s6GibsontonFrame(_ c: PixelCanvas, _ g: Int) -> (palms: [(x: Int, h: Int)], wheel: (x: Int, y: Int, r: Int),
                                                                 banner: (x: Int, y: Int, w: Int, h: Int)) {
        let s = unit(g), tall = isTall(c)
        let ph = tall ? min(110 * s, g * 6 / 10) : min(58 * s, g - 6 * s)
        let palms = [(c.w * 6 / 100, ph), (c.w * 49 / 100, ph * 85 / 100), (c.w * 93 / 100, ph * 95 / 100)]
        let r = tall ? min(70 * s, g / 3) : min(26 * s, (g - 8 * s) / 2)
        let wheel = (x: c.w * 30 / 100, y: g - r - 8 * s, r: r)
        let bw = 54 * s, bh = 20 * s
        let banner = (x: c.w * 60 / 100, y: g - bh - 22 * s, w: bw, h: bh)
        return (palms, wheel, banner)
    }

    /// Gibsonton, Florida, where the sideshow folk winter ("Humbug"): a dusky sky over the Ferris wheel standing idle,
    /// silver trailers with warm windows and a striped awning, palms with string lights slung between them, and the
    /// sideshow banner on its poles (it flaps with the moving layer). On the screen saver, the sky climbs to stars and a
    /// big Florida moon, and the palms and the wheel stand taller.
    static func gibsonton(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s6GibsontonFrame(c, g)
        // Dusk: deep violet overhead, warm orange low down.
        c.gradient(0, g, C(0x1A1430), C(0xC8664A), bands: tall ? 14 : 8)
        c.stars(0, g / 3, density: tall ? 70 : 120, seed: 61)
        if tall { c.circle(c.w * 80 / 100, g / 6, 16 * s, C(0xF2E2B0)); c.circle(c.w * 80 / 100, g / 6, 22 * s, C(0xF2E2B0, 0.08)) }
        // The Ferris wheel, standing idle against the sky.
        let wl = f.wheel, frame = C(0x4A2C52), frameL = C(0x7A5A82)
        for side in [-1, 1] {   // the A-frame legs, behind the wheel
            for k in 0...(g - wl.y) {
                c.rect(wl.x + side * k * wl.r * 3 / max(1, (g - wl.y) * 4), wl.y + k, 2 * s, 1, frame)
            }
        }
        // The rim doubled and lit along its top, an inner ring, spokes, and a hub.
        drawRing(c, wl.x, wl.y, wl.r, s, frame)
        drawRing(c, wl.x, wl.y, wl.r - s, s, frame)
        drawRing(c, wl.x, wl.y - s, wl.r, s, frameL.alpha(0.5))
        drawRing(c, wl.x, wl.y, wl.r * 2 / 3, s, frame)
        for i in 0..<12 {
            let a = Double(i) * .pi / 6
            for k in 0...wl.r { c.rect(wl.x + Int(cos(a) * Double(k)), wl.y + Int(sin(a) * Double(k)), s, s, frame) }
        }
        c.circle(wl.x, wl.y, max(2 * s, wl.r / 8), frame); c.circle(wl.x, wl.y, max(s, wl.r / 16), frameL)
        let cars = [C(0xB83A3A), C(0xE8B84A), C(0x3A7AB8), C(0x5AA85A)]
        for i in 0..<12 {   // the gondolas, hanging below the rim, painted
            let a = Double(i) * .pi / 6
            let gx = wl.x + Int(cos(a) * Double(wl.r)), gy = wl.y + Int(sin(a) * Double(wl.r))
            let gw: Int = max(4 * s, wl.r / 5), gh: Int = max(3 * s, wl.r / 7)
            c.rect(gx, gy, s, 2 * s, frame)
            c.rect(gx - gw / 2, gy + 2 * s, gw, gh, cars[i % 4].alpha(0.85)); c.rect(gx - gw / 2, gy + 2 * s, gw, s, C(0x2A1A30))
        }
        // The trailers: rounded silver, warm windows, one with a striped awning.
        for (i, x) in [c.w * 10 / 100, c.w * 72 / 100].enumerated() {
            let tw = 44 * s, th = 18 * s, ty = g - th - 2 * s
            c.rect(x + 2 * s, ty, tw - 4 * s, th, C(0xA8ACB4)); c.rect(x, ty + 2 * s, tw, th - 4 * s, C(0xA8ACB4))
            c.rect(x + 2 * s, ty, tw - 4 * s, s, C(0xD8DCE4)); c.rect(x, ty + th - 3 * s, tw, s, C(0x6E727A))
            for wx in stride(from: x + 6 * s, to: x + tw - 8 * s, by: 12 * s) {
                c.rect(wx, ty + 4 * s, 6 * s, 5 * s, C(0xFFD48A)); c.rect(wx, ty + 4 * s, 6 * s, s, C(0x8A6A3A))
            }
            c.rect(x + tw - 9 * s, ty + 4 * s, 5 * s, th - 6 * s, C(0x5A5E66))   // the door
            c.rect(x + 6 * s, g - 2 * s, 3 * s, 2 * s, C(0x2A2A30)); c.rect(x + tw - 14 * s, g - 2 * s, 3 * s, 2 * s, C(0x2A2A30))
            if i == 0 {   // the awning
                for k in 0..<8 { c.rect(x + tw + k * 3 * s, ty + 2 * s, 3 * s, 4 * s, k % 2 == 0 ? C(0xC83A3A) : C(0xF0E6D8)) }
                c.rect(x + tw + 23 * s, ty + 6 * s, s, th - 6 * s, C(0x6E727A))
            }
        }
        // The banner's poles (the banner itself flaps in the moving layer).
        let b = f.banner
        c.rect(b.x - 2 * s, b.y - 3 * s, 2 * s, g - b.y + 3 * s, C(0x5A3A24)); c.rect(b.x + b.w, b.y - 3 * s, 2 * s, g - b.y + 3 * s, C(0x5A3A24))
        // The palms.
        for p in f.palms { s6FilesPalm(c, x: p.x, base: g, h: p.h, s: s) }
        // Sandy ground with tufts.
        c.ground(g, C(0x6A5A3C), edge: C(0x8A9A4A), speck: C(0x4E4A2C), seed: 63)
    }

    private static func drawRing(_ c: PixelCanvas, _ cx: Int, _ cy: Int, _ r: Int, _ s: Int, _ col: Px) {
        let n = max(24, r * 7)
        for i in 0..<n {
            let a = Double(i) / Double(n) * 2 * .pi
            c.rect(cx + Int(cos(a) * Double(r)), cy + Int(sin(a) * Double(r)), s, s, col)
        }
    }

    /// A palm: a leaning trunk in rings and a burst of drooping fronds.
    static func s6FilesPalm(_ c: PixelCanvas, x: Int, base: Int, h: Int, s: Int) {
        let trunk = C(0x4A3424), ring = C(0x2E2016), frond = C(0x1E3A22), frondL = C(0x2E5230)
        var tx = x, ty = base
        for k in 0..<h {
            let lean = Int(Double(k * k) / Double(max(1, h * h)) * Double(h) * 0.18)
            tx = x + lean; ty = base - k
            c.rect(tx - 2 * s, ty, 4 * s, 1, k % (4 * s) == 0 ? ring : trunk)
        }
        for i in 0..<9 {
            let a = -.pi + Double(i) / 8 * .pi
            let len = Double(h) * (0.32 + 0.08 * noise(i + x))
            for k in 0..<Int(len) {
                let d = Double(k)
                let fx = tx + Int(cos(a) * d), fy = ty + Int(sin(a) * d * 0.55 + d * d / len * 0.45)
                c.rect(fx, fy, 2 * s, s, k % 3 == 0 ? frondL : frond)
                if k % 2 == 0 { c.rect(fx, fy + s, s, 2 * s, frond) }   // the leaflets hanging off
            }
        }
        c.circle(tx, ty, 2 * s, C(0x5A3A20))   // coconuts
    }

    /// What moves in Gibsonton: the string lights twinkling between the palms, the wheel's rim lights chasing round,
    /// and the sideshow banner (HUMBUG! and a strongman) rippling in the breeze.
    static func gibsontonLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s6GibsontonFrame(c, g)
        // The string lights, palm top to palm top.
        let colors = [C(0xFFE08A), C(0xFF7A6A), C(0x8AE0FF), C(0xB8FF8A)]
        for (a, b) in zip(f.palms, f.palms.dropFirst()) {
            let y0 = g - a.h * 3 / 4, y1 = g - b.h * 3 / 4
            var n = 0
            s6Wire(x0: a.x + 3 * s, y0: y0, x1: b.x - 3 * s, y1: y1, sag: 10 * s) { x, y, _ in
                c.px(x, y, C(0x2A2028))
                if (x - a.x) % (7 * s) == 0 {
                    n += 1
                    let on = noise(n * 7 + Int(t * 3) + a.x) > 0.18
                    c.rect(x, y + s, s, s, colors[n % 4].alpha(on ? 1 : 0.3))
                    if on { c.rect(x - s, y, 3 * s, 3 * s, colors[n % 4].alpha(0.2)) }
                }
            }
        }
        // The wheel's rim lights, chasing.
        let wl = f.wheel
        for i in 0..<24 {
            let a = Double(i) / 24 * 2 * .pi
            let lit = (i + Int(t * 6)) % 4 == 0
            c.rect(wl.x + Int(cos(a) * Double(wl.r)), wl.y + Int(sin(a) * Double(wl.r)), s, s,
                   lit ? C(0xFFF0A0) : C(0xC88A4A, 0.6))
        }
        // The banner, its columns rippling.
        let b = f.banner
        let banner = PixelCanvas(b.w, b.h)
        banner.rect(0, 0, b.w, b.h, C(0xE8D2A0)); banner.rect(0, 0, b.w, 2 * s, C(0xA8302A)); banner.rect(0, b.h - 2 * s, b.w, 2 * s, C(0xA8302A))
        let word = "HUMBUG!", ws = s6TextWidth(word, s: s)
        s6Text(banner, word, x: (b.w - ws) / 2 + 6 * s, y: 4 * s, s: s, C(0xA8302A))
        // A painted strongman on the left: a barbell over his head, handlebar moustache, leopard-skin leotard.
        let man = [
            "PP........PP",
            "PPBBBBBBBBPP",
            "PP.k....k.PP",
            "...k.hh.k...",
            "...k.ff.k...",
            "...kkmmkk...",
            "...kkkkkk...",
            "....kkkk....",
            "....LLlL....",
            "....lLLL....",
            "....LLLl....",
            "....k..k....",
            "....k..k....",
            "...dd..dd...",
        ]
        let paint: [Character: Px] = ["P": C(0x2A2A30), "B": C(0x4A4A52), "k": C(0xD08A5A), "h": C(0x2A2A30), "f": C(0xE0A070),
                                       "m": C(0x2A2A30), "L": C(0xE8A040), "l": C(0x6A3A1A), "d": C(0x2A2A30)]
        for (row, line) in man.enumerated() {
            for (col, ch) in line.enumerated() {
                guard let p = paint[ch] else { continue }
                banner.rect(s + col * s, 3 * s + row * s, s, s, p)
            }
        }
        s6Text(banner, "SIDESHOW", x: (b.w - s6TextWidth("SIDESHOW", s: s)) / 2 + 6 * s, y: 11 * s, s: s, C(0x2A2A30))
        for x in 0..<b.w {
            let wave = Int((sin(Double(x) / Double(8 * s) - t * 2.4) * 1.5 * Double(s)).rounded())
            for y in 0..<b.h {
                guard banner.isDrawn(x, y) else { continue }
                let shade = 0.82 + 0.18 * sin(Double(x) / Double(8 * s) - t * 2.4 + 1)
                c.px(b.x + x, b.y + y + wave, s6Shade(s6Pixel(banner, x, y), shade))
            }
        }
    }
}

// MARK: - Lake Okobogee

extension Scenes {
    /// The lake: where the water meets the far shore, and where the dock's deck is.
    static func s6LakeFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, moonX: Int, moonY: Int) {
        let s = unit(g), tall = isTall(c)
        let horizon = tall ? g * 55 / 100 : g - 26 * s
        return (horizon, c.w * 70 / 100, tall ? g / 5 : max(8 * s, horizon - 30 * s))
    }

    /// Lake Okobogee at dusk: a cooling sky, a low moon, the far shore black with pines, still dark water, and the
    /// wooden dock underfoot with its posts, a rowboat tied up and a lamp on a pole. Something big lives out there
    /// (the moving layer). On the screen saver, more sky and a wider lake.
    static func lakeOkobogee(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s6LakeFrame(c, g)
        c.gradient(0, f.horizon, C(0x0E1630), C(0x8A6A7A), bands: tall ? 12 : 7)
        c.stars(0, f.horizon / 2, density: tall ? 60 : 110, seed: 71)
        c.circle(f.moonX, f.moonY, (tall ? 12 : 6) * s, C(0xF2ECD8))
        // The far shore: a dark hill line and pines.
        c.dunes(base: f.horizon - 4 * s, amp: Double(3 * s), freq: 0.02 / Double(s), phase: 1.3, bottom: f.horizon, C(0x0E1418))
        for i in 0..<(c.w / (9 * s) + 1) {
            let x = i * 9 * s + Int(noise(i + 700) * Double(5 * s))
            let h = (tall ? 26 : 12) * s + Int(noise(i + 720) * Double((tall ? 18 : 8) * s))
            Scenes.filesPine(c, cx: x, base: f.horizon + s, h: h, s: s, C(0x0A1014))
        }
        // The water, dark, lighter towards the far shore.
        c.gradient(f.horizon, g, C(0x3A4258), C(0x0E141E), bands: 6)
        // The moon's path on the water.
        for (i, y) in stride(from: f.horizon + s, to: g - 2 * s, by: 2 * s).enumerated() {
            let half = (1 + (y - f.horizon) / (14 * s)) * s, jog = (Int(noise(i + 860) * 3) - 1) * s
            c.rect(f.moonX - half + jog, y, half * 2, s, C(0xF2ECD8, 0.14 - 0.08 * Double(y - f.horizon) / Double(max(1, g - f.horizon))))
        }
        if tall {
            // The far shore's pines reflected in the water, a band of mist lying over it, a lit cabin and its jetty
            // across the lake, lily pads, and reeds standing in the shallows either side.
            for i in 0..<(c.w / (9 * s) + 1) {
                let x = i * 9 * s + Int(noise(i + 700) * Double(5 * s))
                let h = 26 * s + Int(noise(i + 720) * Double(18 * s))
                for k in stride(from: 0, to: h / 2, by: s) { c.rect(x - (h / 2 - k) / 8, f.horizon + s + k, (h / 2 - k) / 4 + s, s, C(0x0A1014, 0.5)) }
            }
            c.rect(0, f.horizon + 2 * s, c.w, 5 * s, C(0xB8B0C0, 0.08)); c.rect(0, f.horizon + 4 * s, c.w, 2 * s, C(0xC8C0D0, 0.07))
            let cx = c.w * 22 / 100
            c.rect(cx, f.horizon - 10 * s, 14 * s, 9 * s, C(0x1A1418)); c.rect(cx + 3 * s, f.horizon - 7 * s, 3 * s, 3 * s, C(0xFFC870))
            for k in 0..<3 { c.ellipse(cx + 4 * s, f.horizon - 5 * s, (6 + k * 4) * s, (3 + k * 2) * s, C(0xFFC870, 0.05)) }
            c.rect(cx + 14 * s, f.horizon - s, 20 * s, s, C(0x2A1E14))
            for k in 0..<6 { c.rect(cx + 4 * s, f.horizon + 2 * s + k * 4 * s, 2 * s, s, C(0xFFC870, 0.3 - Double(k) * 0.04)) }   // its light on the water
            for i in 0..<12 {
                let px = Int(noise(i + 880) * Double(c.w)), py = f.horizon + (g - f.horizon) / 2 + Int(noise(i + 890) * Double((g - f.horizon) / 2 - 8 * s))
                c.ellipse(px, py, 3 * s, s, C(0x2A4A2E)); c.px(px + s, py, C(0x0E141E))
            }
            for i in 0..<38 {
                let side = i % 2 == 0
                let rx = side ? Int(noise(i + 900) * Double(c.w / 8)) : c.w - Int(noise(i + 900) * Double(c.w / 10))
                let rh = (10 + Int(noise(i + 910) * 16)) * s
                c.rect(rx, g - rh, s, rh, C(0x1A2416))
                if i % 3 == 0 { c.rect(rx, g - rh - 4 * s, s, 4 * s, C(0x3A2A18)) }   // a cattail
                if i % 4 == 1 { c.rect(rx + s, g - rh / 2, 2 * s, s, C(0x1A2416)) }
            }
        }
        // The rowboat, tied up on the left.
        let bx = c.w * 12 / 100, by = g - 6 * s
        c.rect(bx, by, 30 * s, 4 * s, C(0x6A3E24)); c.rect(bx + 2 * s, by + 4 * s, 26 * s, 2 * s, C(0x4A2A16))
        c.rect(bx, by, 30 * s, s, C(0x9A6A42)); c.rect(bx + 13 * s, by - s, 4 * s, s, C(0x4A2A16))
        // The dock: posts down into the water, the deck the crew stands on, the lamp at the end.
        let deckX = c.w * 35 / 100
        for x in stride(from: deckX, to: c.w, by: 22 * s) { c.rect(x, g - 6 * s, 3 * s, 6 * s, C(0x3A2A1C)) }
        c.rect(0, g, c.w, c.h - g, C(0x5A4430))
        for y in stride(from: g + 3 * s, to: c.h, by: 4 * s) { c.rect(0, y, c.w, s, C(0x3E2E1E)) }
        for x in stride(from: 0, to: c.w, by: 31 * s) { c.rect(x, g, s, c.h - g, C(0x3E2E1E)) }
        c.rect(0, g, c.w, s, C(0x8A6E4E))
        let lx = c.w * 88 / 100
        c.rect(lx, g - 40 * s, 2 * s, 40 * s, C(0x2A2A2E)); c.rect(lx - 3 * s, g - 42 * s, 8 * s, 2 * s, C(0x2A2A2E))
        c.rect(lx - 2 * s, g - 40 * s, 6 * s, 3 * s, C(0xFFE0A0))
    }

    /// What moves on the lake: ripples catching the light, the lamp's glow, and now and then Big Blue: a wake opens
    /// across the water and a long neck and hump break the surface, then sink again.
    static func lakeOkobogeeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s6LakeFrame(c, g)
        // Ripples: short glints drifting along.
        for i in 0..<26 {
            let y = f.horizon + 2 * s + Int(noise(i + 800) * Double(max(1, g - f.horizon - 6 * s)))
            let x = Int((noise(i + 830) * Double(c.w) + t * Double(3 + i % 4) * Double(s))) % max(1, c.w)
            let len = (2 + (y - f.horizon) / (8 * s)) * s
            c.rect(x, y, len, s, C(0xC8D4E8, 0.18 + 0.15 * sin(t * 1.5 + Double(i))))
        }
        // The lamp's glow on the deck.
        let lx = c.w * 88 / 100
        c.ellipse(lx + s, g - 37 * s, 5 * s, 3 * s, C(0xFFE0A0, 0.1))
        c.ellipse(lx + s, g + s, 18 * s, 2 * s, C(0xFFE0A0, 0.12))
        // Big Blue: every 20 seconds, for 7 of them, he crosses the lake.
        let k = (t.truncatingRemainder(dividingBy: 20)) / 7
        guard k < 1 else { return }
        let wy = f.horizon + (g - f.horizon) * 2 / 5
        let hx = Int(Double(c.w) * (0.1 + 0.6 * k))
        let rise = sin(k * .pi)                                // up in the middle of the crossing, under at the ends
        // The wake: a V spreading behind him.
        for d in stride(from: 0, to: 40 * s, by: s) {
            let spread = d / 3
            c.rect(hx - d, wy - spread, s, s, C(0xC8D4E8, 0.4 * (1 - Double(d) / Double(40 * s))))
            c.rect(hx - d, wy + spread, s, s, C(0xC8D4E8, 0.4 * (1 - Double(d) / Double(40 * s))))
        }
        guard rise > 0.25 else { return }
        let big = isTall(c) ? 2 : 1
        let up = Int(rise * Double(12 * s * big)), body = C(0x1E3438), bodyL = C(0x2E4A4E)
        c.ellipse(hx - 11 * s * big, wy, 9 * s * big, max(1, up / 3), body)                // the hump
        c.ellipse(hx - 11 * s * big, wy - up / 3 + s, 6 * s * big, s, bodyL)              // the light on its back
        c.ellipse(hx - 24 * s * big, wy, 4 * s * big, max(1, up / 6), body)                 // a second, smaller hump
        for k in 0..<up { c.rect(hx + k / 4, wy - k, 2 * s, s, k % 3 == 0 ? bodyL : body) }   // the neck
        c.rect(hx + up / 4, wy - up - s, 4 * s * big, 2 * s * big, body); c.px(hx + up / 4 + 3 * s * big, wy - up - s, C(0xC8E0D0))   // head, eye
        c.rect(hx - 30 * s * big, wy, 40 * s * big, s, C(0xC8D4E8, 0.35))              // the water line round him
    }
}

// MARK: - The Mutato's farm

extension Scenes {
    /// The farm: the moon and the windmill's hub.
    static func s6FarmFrame(_ c: PixelCanvas, _ g: Int) -> (moon: (x: Int, y: Int, r: Int), mill: (x: Int, y: Int, r: Int)) {
        let s = unit(g), tall = isTall(c)
        let mr = tall ? min(40 * s, g / 6) : min(18 * s, g / 3)
        let moon = (x: c.w * 50 / 100, y: tall ? g / 4 : mr + 4 * s, r: mr)
        let mh = tall ? min(90 * s, g / 2) : min(46 * s, g - 10 * s)
        return (moon, (x: c.w * 66 / 100, y: g - mh, r: min(12 * s, mh / 3)))
    }

    /// The Mutato's farm ("The Post-Modern Prometheus"), in black and white like the episode: a pale, comic-book moon
    /// with its craters inked in, the white farmhouse with its porch and lit windows, the big barn, a water-pumping
    /// windmill on its lattice tower, fence posts along the field. On the screen saver, the sky rises to a huge moon.
    static func mutatoFarm(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s6FarmFrame(c, g)
        c.gradient(0, g, C(0x1A1A1A), C(0x6A6A6A), bands: tall ? 12 : 7)
        c.stars(0, g / 2, density: tall ? 90 : 160, seed: 81)
        // The comic-book moon: a heavy black outline, crisp craters.
        let m = f.moon
        c.circle(m.x, m.y, m.r + 2 * s, C(0x0A0A0A)); c.circle(m.x, m.y, m.r, C(0xF0F0EA))
        for (u, v, k) in [(-0.4, -0.3, 0.2), (0.35, -0.35, 0.13), (0.15, 0.3, 0.24), (-0.3, 0.45, 0.1), (0.55, 0.15, 0.09)] {
            let x = m.x + Int(u * Double(m.r)), y = m.y + Int(v * Double(m.r)), cr = max(s, Int(k * Double(m.r)))
            c.circle(x, y, cr + s, C(0x2A2A2A)); c.circle(x, y, cr, C(0xB8B8B4)); c.circle(x - cr / 3, y - cr / 3, max(1, cr / 3), C(0xD8D8D4))
        }
        // Far fields: a low ridge.
        c.dunes(base: g - 10 * s, amp: Double(3 * s), freq: 0.015 / Double(s), phase: 0.4, bottom: g, C(0x2E2E2E))
        // The farmhouse: white clapboard, a gable, a porch, warm (here: bright) windows.
        let hx = c.w * 10 / 100, hw = 50 * s, hh = tall ? 34 * s : min(30 * s, g - 14 * s), hy = g - hh
        c.rect(hx, hy + 8 * s, hw, hh - 8 * s, C(0xD8D8D4))
        for y in stride(from: hy + 10 * s, to: g, by: 3 * s) { c.rect(hx, y, hw, s, C(0xB0B0AC)) }
        // The roof: a steep gable, shingle lines across it, a chimney and an attic window in the end.
        let rise: Int = hw / 2 + 2 * s
        c.rect(hx + hw - 14 * s, hy + 8 * s - rise * 3 / 4, 5 * s, rise * 3 / 4, C(0x3A3A3A)); c.rect(hx + hw - 15 * s, hy + 8 * s - rise * 3 / 4, 7 * s, s, C(0x1A1A1A))
        for k in 0..<rise {
            let inset: Int = k
            c.rect(hx - 2 * s + inset, hy + 8 * s - k, hw + 4 * s - inset * 2, 1, k % (3 * s) == 0 ? C(0x1A1A1A) : C(0x2E2E2E))
        }
        c.rect(hx + hw / 2 - 3 * s, hy + 8 * s - rise / 2, 6 * s, 6 * s, C(0xD8D8D4)); c.rect(hx + hw / 2 - 2 * s, hy + 9 * s - rise / 2, 4 * s, 4 * s, C(0xF6F6EE))
        c.rect(hx - 2 * s, hy + 8 * s, hw + 4 * s, s, C(0x0A0A0A))
        for wx in [hx + 6 * s, hx + 34 * s] { c.rect(wx, hy + 12 * s, 9 * s, 7 * s, C(0xF6F6EE)); c.rect(wx + 4 * s, hy + 12 * s, s, 7 * s, C(0x3A3A3A)) }
        c.rect(hx + 21 * s, g - 12 * s, 8 * s, 12 * s, C(0x3A3A3A))                   // the door
        c.rect(hx - 4 * s, g - 14 * s, hw + 8 * s, 2 * s, C(0x4A4A4A))                 // the porch roof
        for px in stride(from: hx - 4 * s, through: hx + hw + 3 * s, by: 12 * s) { c.rect(px, g - 12 * s, s, 12 * s, C(0xC8C8C4)) }
        // The barn: a gambrel roof, big doors with their X braces.
        let bx = c.w * 78 / 100, bw = 48 * s, bh = tall ? 40 * s : min(36 * s, g - 10 * s), by = g - bh
        c.rect(bx, by + 12 * s, bw, bh - 12 * s, C(0x5A5A5A))
        for x in stride(from: bx, to: bx + bw, by: 4 * s) { c.rect(x, by + 12 * s, s, bh - 12 * s, C(0x464646)) }
        for k in 0..<(12 * s) {
            let inset = k < 6 * s ? k / 2 : 3 * s + (k - 6 * s) * 2
            c.rect(bx - 2 * s + inset, by + 12 * s - k, bw + 4 * s - inset * 2, 1, C(0x2A2A2A))
        }
        let dx = bx + 14 * s, dw = 20 * s, dh = min(20 * s, bh - 14 * s)
        c.rect(dx, g - dh, dw, dh, C(0x3A3A3A)); c.rect(dx, g - dh, dw, s, C(0xC8C8C4))
        for k in 0..<dh { c.px(dx + k * dw / max(1, dh), g - dh + k, C(0xC8C8C4)); c.px(dx + dw - 1 - k * dw / max(1, dh), g - dh + k, C(0xC8C8C4)) }
        c.rect(bx + 20 * s, by + 4 * s, 8 * s, 6 * s, C(0x1A1A1A))                    // the hayloft door
        // The windmill's lattice tower (the wheel turns in the moving layer).
        let ml = f.mill
        for y in ml.y..<g {
            let spread = (y - ml.y) * 7 * s / max(1, g - ml.y) + s
            c.rect(ml.x - spread, y, s, 1, C(0x1A1A1A)); c.rect(ml.x + spread, y, s, 1, C(0x1A1A1A))
            if (y - ml.y) % (8 * s) == 0 { c.rect(ml.x - spread, y, spread * 2 + s, s, C(0x1A1A1A)) }
        }
        c.rect(ml.x - 2 * s, ml.y - 2 * s, 5 * s, 4 * s, C(0x1A1A1A))
        c.rect(ml.x + 3 * s, ml.y - s, 10 * s, s, C(0x1A1A1A)); c.rect(ml.x + 11 * s, ml.y - 4 * s, 2 * s, 7 * s, C(0x1A1A1A))   // the tail vane
        // Fence posts and rails across the field.
        for x in stride(from: 0, to: c.w, by: 16 * s) where !(x > hx - 6 * s && x < hx + hw + 6 * s) && !(x > bx - 4 * s && x < bx + bw + 4 * s) {
            c.rect(x, g - 9 * s, 2 * s, 9 * s, C(0x2A2A2A))
        }
        c.ground(g, C(0x3E3E3E), edge: C(0x8A8A8A), speck: C(0x2A2A2A), seed: 83)
    }

    /// What moves at the farm: clouds sliding across the moon, the windmill's wheel turning, and the whole picture
    /// flickering like an old film, with the odd scratch and speck of dust.
    static func mutatoFarmLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s6FarmFrame(c, g)
        // Clouds.
        for i in 0..<3 {
            let w = (40 + i * 14) * s, y = f.moon.y - f.moon.r / 2 + i * f.moon.r / 2
            let x = Int((Double(i) * 0.37 * Double(c.w) + t * Double(4 + i * 2) * Double(s))
                .truncatingRemainder(dividingBy: Double(c.w + w))) - w
            c.ellipse(x + w / 2, y, w / 2, 4 * s, C(0x8A8A86, 0.75)); c.ellipse(x + w / 3, y - 3 * s, w / 4, 4 * s, C(0xA8A8A4, 0.7))
        }
        // The windmill's wheel.
        let ml = f.mill
        let spin = t * 1.6
        for i in 0..<12 {
            let a = spin + Double(i) * .pi / 6
            for k in (ml.r / 3)...ml.r {
                c.rect(ml.x + Int(cos(a) * Double(k)), ml.y + Int(sin(a) * Double(k)), s, s, C(0x0E0E0E))
            }
            c.rect(ml.x + Int(cos(a) * Double(ml.r)) - s, ml.y + Int(sin(a) * Double(ml.r)) - s, 2 * s, 2 * s, C(0x2A2A2A))
        }
        c.rect(ml.x - s, ml.y - s, 2 * s, 2 * s, C(0x4A4A4A))
        // The film: a flicker over everything, a scratch now and then, specks.
        let frame = Int(t * 12)
        let flick = noise(frame) * 0.07
        c.rect(0, 0, c.w, c.h, (noise(frame + 5) > 0.5 ? C(0xFFFFFF) : C(0x000000)).alpha(flick))
        if noise(frame / 3 + 40) > 0.6 {
            let x = Int(noise(frame / 3 + 41) * Double(c.w))
            c.rect(x, 0, s, c.h, C(0xE8E8E4, 0.35))
        }
        for i in 0..<4 where noise(frame * 4 + i) > 0.5 {
            c.rect(Int(noise(frame * 4 + i + 100) * Double(c.w)), Int(noise(frame * 4 + i + 200) * Double(c.h)), s, s, C(0x0A0A0A, 0.7))
        }
    }
}

// MARK: - Chaney, Texas

extension Scenes {
    /// The motel's row of rooms, the MOTEL sign, the pizza place, the lamp post and the car.
    static func s6ChaneyFrame(_ c: PixelCanvas, _ g: Int) -> (motel: (x: Int, w: Int, h: Int), sign: (x: Int, y: Int),
                                                              pizza: (x: Int, w: Int, h: Int), lamp: (x: Int, y: Int)) {
        let s = unit(g), tall = isTall(c)
        let mh = min(26 * s, g - 22 * s)
        let motel = (x: c.w * 4 / 100, w: c.w * 50 / 100, h: max(16 * s, mh))
        let signH = tall ? 70 * s : min(44 * s, g - 8 * s)
        let ph = min(28 * s, g - 20 * s)
        return (motel, (x: c.w * 58 / 100, y: g - signH), (x: c.w * 70 / 100, w: c.w * 26 / 100, h: max(18 * s, ph)),
                (x: c.w * 64 / 100, y: g - 34 * s))
    }

    /// Chaney, Texas ("Bad Blood"): a flat night sky, a one-storey motel with its row of numbered doors and a walkway
    /// light over each, the tall MOTEL sign on its pole, the pizza place next door, a lamp post and a parked car. On the
    /// screen saver, the town's water tower stands over it all with CHANEY on its tank.
    static func chaneyMotel(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s6ChaneyFrame(c, g)
        c.gradient(0, g, C(0x070A18), C(0x1E2440), bands: tall ? 12 : 7)
        c.stars(0, g * 2 / 3, density: tall ? 60 : 110, seed: 91)
        if tall {   // the water tower
            let tx = c.w * 22 / 100, ty = g / 4, tw = 44 * s
            for side in [-1, 1] { for y in (ty + 20 * s)..<g { c.rect(tx + tw / 2 + side * (tw / 3 + (y - ty) * s / 12), y, 2 * s, 1, C(0x1A1E2C)) } }
            c.rect(tx, ty, tw, 22 * s, C(0x2A3046)); c.ellipse(tx + tw / 2, ty, tw / 2, 5 * s, C(0x2A3046))
            c.rect(tx, ty + 20 * s, tw, 2 * s, C(0x1A1E2C))
            let word = "CHANEY"
            s6Text(c, word, x: tx + (tw - s6TextWidth(word, s: s)) / 2, y: ty + 8 * s, s: s, C(0xA8B0C8))
        }
        // Low scrub on the horizon.
        c.dunes(base: g - 6 * s, amp: Double(2 * s), freq: 0.02 / Double(s), phase: 2.1, bottom: g, C(0x12141E))
        // The motel: a flat roof, the row of doors and windows, a light over each door.
        let m = f.motel, top = g - m.h
        c.rect(m.x, top, m.w, m.h, C(0x8A7A62)); c.rect(m.x - 2 * s, top - 3 * s, m.w + 4 * s, 3 * s, C(0x4A3A2A))
        c.rect(m.x, g - 3 * s, m.w, 3 * s, C(0x6A5E4E))
        var n = 1
        for x in stride(from: m.x + 4 * s, to: m.x + m.w - 18 * s, by: 22 * s) {
            c.rect(x, g - 15 * s, 7 * s, 12 * s, C(0x6A3A2A)); c.rect(x + 5 * s, g - 9 * s, s, s, C(0xD8B44A))
            c.rect(x + 10 * s, g - 13 * s, 8 * s, 6 * s, noise(n + 940) > 0.4 ? C(0xE8C47A) : C(0x2A2E3E))
            c.rect(x + 2 * s, top + s, 3 * s, 2 * s, C(0xFFE8A8))
            n += 1
        }
        // The MOTEL sign's pole and frame (its letters glow in the moving layer).
        let sg = f.sign
        c.rect(sg.x + 10 * s, sg.y + 10 * s, 3 * s, g - sg.y - 10 * s, C(0x3A3A44))
        c.rect(sg.x, sg.y, 24 * s, 34 * s, C(0x14182A)); c.rect(sg.x, sg.y, 24 * s, s, C(0x5A6078))
        // The pizza place: a flat-fronted shop with a big lit window and a sign board (lit in the moving layer).
        let p = f.pizza, ptop = g - p.h
        c.rect(p.x, ptop, p.w, p.h, C(0x5A4A3E)); c.rect(p.x, ptop, p.w, 7 * s, C(0x2A2420))
        c.rect(p.x + 4 * s, g - 14 * s, p.w - 22 * s, 11 * s, C(0xE8C47A, 0.85)); c.rect(p.x + p.w - 14 * s, g - 15 * s, 8 * s, 15 * s, C(0x3A2A20))
        // The lamp post.
        let lp = f.lamp
        c.rect(lp.x, lp.y, 2 * s, g - lp.y, C(0x2A2A32)); c.rect(lp.x - 4 * s, lp.y, 8 * s, 2 * s, C(0x2A2A32))
        c.rect(lp.x - 3 * s, lp.y + 2 * s, 6 * s, 2 * s, C(0xFFF0C0))
        // The parked car: a 90s sedan, nose right.
        let cx = c.w * 40 / 100 + 6 * s, cy = g - 10 * s
        c.rect(cx, cy + 3 * s, 36 * s, 6 * s, C(0x6A2E2E)); c.rect(cx + 8 * s, cy - s, 18 * s, 5 * s, C(0x6A2E2E))
        c.rect(cx + 10 * s, cy, 6 * s, 3 * s, C(0x8AA0B8, 0.7)); c.rect(cx + 18 * s, cy, 6 * s, 3 * s, C(0x8AA0B8, 0.7))
        c.rect(cx + 34 * s, cy + 4 * s, 2 * s, 2 * s, C(0xFFF0C0)); c.rect(cx, cy + 4 * s, s, 2 * s, C(0xC8302A))
        for wx in [cx + 6 * s, cx + 28 * s] { c.circle(wx, g - s, 3 * s, C(0x101014)); c.circle(wx, g - s, s, C(0x8A8A90)) }
        // Asphalt.
        c.ground(g, C(0x26262C), edge: C(0x4A4A54), speck: C(0x1A1A20), seed: 93)
    }

    /// What moves in Chaney: the MOTEL sign's neon (and its VACANCY), the pizza sign flickering and buzzing, the
    /// lamp's glow and the moths round it.
    static func chaneyMotelLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s6ChaneyFrame(c, g)
        let sg = f.sign
        // MOTEL, top to bottom, letter by letter lit, then all.
        let cycle = Int(t * 3) % 10
        for (i, ch) in "MOTEL".enumerated() {
            let lit = cycle >= 5 || i <= cycle
            let col = C(0xFF4A6A).alpha(lit ? 1 : 0.18)
            let wch = s6TextWidth(String(ch), s: s)
            s6Text(c, String(ch), x: sg.x + (24 * s - wch) / 2, y: sg.y + 3 * s + i * 6 * s, s: s, col)
            if lit { c.rect(sg.x + 7 * s, sg.y + 3 * s + i * 6 * s, 10 * s, 5 * s, C(0xFF4A6A, 0.08)) }
        }
        // The pizza sign: buzzes, and drops out for a beat now and then.
        let p = f.pizza, ptop = g - p.h
        let dead = noise(Int(t * 7)) > 0.88
        let word = "PIZZA", ws = s6TextWidth(word, s: s)
        let col = C(0x7AFFB0).alpha(dead ? 0.15 : 0.95)
        s6Text(c, word, x: p.x + (p.w - ws) / 2, y: ptop + s, s: s, col)
        if !dead { c.rect(p.x + (p.w - ws) / 2 - s, ptop, ws + 2 * s, 7 * s, C(0x7AFFB0, 0.08)) }
        // The lamp's glow, and the moths.
        let lp = f.lamp
        c.ellipse(lp.x + s, lp.y + 4 * s, 5 * s, 3 * s, C(0xFFF0C0, 0.1))
        c.ellipse(lp.x + s, g + s, 14 * s, 2 * s, C(0xFFF0C0, 0.12))
        for i in 0..<5 {
            let a = t * (2.4 + Double(i) * 0.6) + Double(i) * 1.7
            let r = Double((4 + i) * s)
            c.rect(lp.x + Int(cos(a) * r), lp.y + 3 * s + Int(sin(a * 1.3) * r * 0.6), s, s, C(0xE8E0D0, 0.85))
        }
    }
}

// MARK: - Small helpers

/// The colour at (x, y) of a canvas this file drew (back from premultiplied).
private func s6Pixel(_ c: PixelCanvas, _ x: Int, _ y: Int) -> Px {
    let i = (y * c.w + x) * 4, a = c.buf[i + 3]
    guard a > 0 else { return Px(r: 0, g: 0, b: 0, a: 0) }
    let m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(c.buf[i]) * m)), g: UInt8(min(255, Double(c.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(c.buf[i + 2]) * m)), a: a)
}

/// `p` darkened to `k` (1 = as is).
private func s6Shade(_ p: Px, _ k: Double) -> Px {
    Px(r: UInt8(Double(p.r) * k), g: UInt8(Double(p.g) * k), b: UInt8(Double(p.b) * k), a: p.a)
}
