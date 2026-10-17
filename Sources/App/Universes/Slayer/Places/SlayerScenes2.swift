import Foundation

// Sunnydale by night: the Bronze, Restfield Cemetery, the Summers house, the Magic Box, Spyke's crypt, the Old Master's
// sunken church and the Hellmouth itself. Each night place has its own key colour so they don't all sink into the same
// navy: the Bronze's purple stage light, the cemetery's cold green moonlight, Revello Drive's rose dusk, the Magic
// Box's warm amber, the crypt's grey stone lit by a blue TV, the church's olive gloom and gold candles, and the
// Hellmouth's red.
let slayerScenes2: [Location: Place] = [
    .slayerBronze: Place(name: "The Bronze", panel: 0x170D1E, still: Scenes.slayerBronze, moving: Scenes.slayerBronzeLife),
    .slayerCemetery: Place(name: "Restfield Cemetery", panel: 0x0C1614, still: Scenes.slayerCemetery,
                           moving: Scenes.slayerCemeteryLife),
    .slayerRevello: Place(name: "1630 Revello Drive", panel: 0x1C1424, still: Scenes.slayerRevello,
                          moving: Scenes.slayerRevelloLife),
    .slayerMagicBox: Place(name: "The Magic Box", panel: 0x22140C, still: Scenes.slayerMagicBox,
                           moving: Scenes.slayerMagicBoxLife),
    .slayerCrypt: Place(name: "Spyke's Crypt", panel: 0x121412, still: Scenes.slayerCrypt, moving: Scenes.slayerCryptLife),
    .slayerSunkenChurch: Place(name: "The Sunken Church", panel: 0x12140C, still: Scenes.slayerSunkenChurch,
                               moving: Scenes.slayerSunkenChurchLife),
    .slayerHellmouth: Place(name: "The Hellmouth", panel: 0x1A0606, still: Scenes.slayerHellmouth,
                            moving: Scenes.slayerHellmouthLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 3×5 alphabet, only the letters the signs here need.
private let slayerGlyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011", "E": "111100110100111",
    "G": "011100101101011", "H": "101101111101101", "I": "111010010010111", "M": "101111111101101",
    "N": "110101101101101", "O": "010101101101010", "R": "110101110101101", "T": "111010010010010",
    "X": "101101010101101", "Z": "111001010100111",
]

/// How wide `text` comes out at `p` pixels a dot.
private func slayerSignWidth(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + ($1 == " " ? 3 : 4) * p } - p
}

/// Lettering in the blocky alphabet, `p` pixels a dot, from its top-left corner.
private func slayerSign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    var cx = x
    for ch in text {
        guard let bits = slayerGlyphs[ch] else { cx += 3 * p; continue }
        for (i, b) in bits.enumerated() where b == "1" { c.rect(cx + (i % 3) * p, y + (i / 3) * p, p, p, col) }
        cx += 4 * p
    }
}

/// A candle: wax standing on `base`, `h` tall; its wick is at (x, base - h - s), where `slayerFlame` lights it.
private func slayerCandle(_ c: PixelCanvas, _ x: Int, _ base: Int, _ h: Int, _ s: Int, wide: Bool = false) {
    let w = wide ? 2 * s : s
    c.rect(x, base - h, w, h, C(0xE8DCC0)); c.rect(x + w - s, base - h, s, h, wide ? C(0xC0B49A) : C(0xE8DCC0))
    c.rect(x, base - h + s, s, s, C(0xF8F0DC))
    c.rect(x, base - h - s, s, s, C(0x2A2018))
}

/// A candle flame flickering on the wick at (x, y): taller and shorter, now and then guttering sideways, with a
/// soft halo.
private func slayerFlame(_ c: PixelCanvas, _ x: Int, _ y: Int, _ t: Double, _ k: Int, _ s: Int, halo: Double = 0.12) {
    let f = noise(Int(t * 9) * 7 + k * 131)
    let h = (2 + Int(f * 1.99)) * s
    let lean = noise(Int(t * 4) * 3 + k * 17) > 0.8 ? s : 0
    if halo > 0 { c.circle(x, y - h / 2, 4 * s, C(0xFFB048, halo * (0.8 + 0.4 * f))) }
    c.rect(x + lean, y - h, s, h - s, C(0xFF9A2A))
    c.rect(x, y - s, s, s, C(0xFFE8A0))
}

/// A wall of rough stone blocks between rows `y0` and `y1`, in a handful of tones.
private func slayerBlocks(_ c: PixelCanvas, _ y0: Int, _ y1: Int, _ s: Int, tones: [Px], mortar: Px, light: Px, seed: Int) {
    let rowH = 7 * s
    var y = y0, row = 0
    while y < y1 {
        let h = min(rowH, y1 - y)
        var x = -Int(noise(row * 7 + seed) * Double(20 * s)), i = 0
        while x < c.w {
            let w = (14 + Int(noise(seed + row * 31 + i * 3) * 12)) * s
            let col = tones[Int(noise(seed + row * 31 + i * 3 + 1) * Double(tones.count)) % tones.count]
            c.rect(x, y, w, h, col)
            c.rect(x, y, w, s, light); c.rect(x, y, s, h, light)
            c.rect(x + w - s, y, s, h, mortar)
            x += w; i += 1
        }
        c.rect(0, y + h - s, c.w, s, mortar)
        y += rowH; row += 1
    }
}

// MARK: - The Bronze

extension Scenes {
    /// Where things stand in the Bronze: the stage on the right, the bar on the left, the sofa, the pool table, the
    /// lighting rig over the stage, and (on the screen saver) the upstairs gallery.
    static func slayerBronzeFrame(_ c: PixelCanvas, _ g: Int) -> (stage: (x: Int, w: Int, top: Int), bar: (x: Int, w: Int),
                                                                sofa: Int, pool: Int, rig: Int, loft: Int?) {
        let s = unit(g), tall = isTall(c)
        let sx = c.w * 60 / 100
        return ((sx, c.w - sx - c.w * 3 / 100, g - 8 * s), (c.w * 2 / 100, c.w * 22 / 100), c.w * 26 / 100,
                c.w * 38 / 100, tall ? g - 118 * s : 2 * s, tall ? g - 78 * s : nil)
    }

    /// Where the neon sign hangs, and its dot size.
    static func slayerBronzeSign(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, p: Int) {
        let s = unit(g), f = slayerBronzeFrame(c, g), p = 2 * s
        let w = slayerSignWidth("THE BRONZE", p)
        if let loft = f.loft { return (c.w * 26 / 100 - w / 2, loft - 28 * s, p) }
        return (f.bar.x + (f.bar.w - w) / 2, 6 * s, p)
    }

    /// The Bronze, Sunnydale's only club: a brick warehouse washed in purple light, the band's stage on the right with
    /// its speaker stacks, drum kit and a dark curtain, the bar on the left with bottles lit from behind under a pink
    /// neon sign, a plum velvet sofa, and the pool table under its hanging lamp. On the screen saver the steel roof
    /// trusses, a duct, the high warehouse windows, the upstairs gallery and the lighting rig hung on chains.
    static func slayerBronze(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerBronzeFrame(c, g), st = f.stage
        let mortar = C(0x120A16)
        c.gradient(0, g, C(0x0C0612), C(0x281A30), bands: 6)
        // Brick courses, staggered.
        for (row, y) in stride(from: 0, to: g, by: 5 * s).enumerated() {
            c.rect(0, y, c.w, s, mortar.alpha(0.55))
            for x in stride(from: row % 2 == 0 ? 0 : 5 * s, to: c.w, by: 10 * s) { c.rect(x, y, s, 5 * s, mortar.alpha(0.45)) }
        }
        // The purple wash over the stage end of the room.
        for k in 0..<4 {
            let rx = st.w * (9 - k * 2) / 10, ry = (tall ? 130 - k * 24 : 56 - k * 10) * s
            c.ellipse(st.x + st.w / 2, st.top - 8 * s, rx, ry, C(0x8A2AC8, 0.06))
        }

        if tall, let loft = f.loft {
            // The roof: steel trusses, a duct under them.
            let r0 = 4 * s, r1 = 28 * s
            c.rect(0, 0, c.w, r1 + 2 * s, C(0x08040C))
            var x = 0, up = true
            while x < c.w {
                slayerLine(c, Double(x), Double(up ? r1 : r0 + 2 * s), Double(x + 14 * s), Double(up ? r0 + 2 * s : r1),
                           C(0x2E2636), Double(s) * 0.6)
                x += 14 * s; up.toggle()
            }
            c.rect(0, r0, c.w, 2 * s, C(0x3E3446)); c.rect(0, r1, c.w, 2 * s, C(0x3E3446))
            let duct = r1 + 9 * s
            c.rect(0, duct, c.w, 7 * s, C(0x2A2430)); c.rect(0, duct, c.w, s, C(0x4A4056)); c.rect(0, duct + 6 * s, c.w, s, C(0x16101C))
            for x in stride(from: 6 * s, to: c.w, by: 38 * s) { c.rect(x, duct, s, 7 * s, C(0x1A1420)); c.rect(x + 6 * s, duct + 7 * s, s, 4 * s, C(0x2A2430)) }
            // High warehouse windows, the night outside them.
            for k in 0..<5 {
                let wx = c.w * (6 + k * 19) / 100, wy = duct + 22 * s, ww = 30 * s, wh = min(loft - wy - 44 * s, f.rig - wy - 14 * s)
                guard wh > 16 * s else { continue }
                c.rect(wx - 2 * s, wy - 2 * s, ww + 4 * s, wh + 4 * s, C(0x0A060E))
                c.rect(wx, wy, ww, wh, C(0x1A2244))
                c.rect(wx, wy + wh / 2, ww, wh - wh / 2, C(0x222A50))
                for (i, py) in stride(from: wy, to: wy + wh, by: 6 * s).enumerated() {
                    for (j, pxx) in stride(from: wx, to: wx + ww, by: 6 * s).enumerated() where noise(k * 97 + i * 13 + j) > 0.9 {
                        c.rect(pxx, py, 6 * s, 6 * s, C(0x0C1024))   // a broken pane
                    }
                }
                for px in stride(from: wx, through: wx + ww, by: 6 * s) { c.rect(px, wy, s, wh, C(0x0A060E)) }
                for py in stride(from: wy, through: wy + wh, by: 6 * s) { c.rect(wx, py, ww, s, C(0x0A060E)) }
            }
            // The upstairs gallery: its floor, its railing, and the posts holding it up.
            let lw = st.x - 8 * s
            for px in [c.w * 23 / 100, c.w * 53 / 100] where px < lw { c.rect(px, loft, 3 * s, g - loft, C(0x1A1220)); c.rect(px, loft, s, g - loft, C(0x3A2E44)) }
            c.rect(0, loft, lw, 5 * s, C(0x241A2C)); c.rect(0, loft, lw, s, C(0x4A3C56)); c.rect(0, loft + 4 * s, lw, s, C(0x100A14))
            c.rect(0, loft - 9 * s, lw, s, C(0x5A4A66))
            for x in stride(from: 2 * s, to: lw, by: 4 * s) { c.rect(x, loft - 8 * s, s, 8 * s, C(0x2E2438)) }
            for x in stride(from: 10 * s, to: lw, by: 50 * s) { c.rect(x, loft - 11 * s, 2 * s, 11 * s, C(0x3A2E44)) }
            // The lighting rig over the stage, hung on chains from the roof.
            for cx in [st.x + 6 * s, st.x + st.w - 8 * s] {
                for y in stride(from: r1 + 2 * s, to: f.rig, by: 2 * s) { c.rect(cx + (y / (2 * s)) % 2 * s, y, s, s, C(0x4A4054)) }
            }
        }
        // The rig's truss and its lamps (along the top edge in the window).
        let rig = f.rig
        c.rect(st.x - 4 * s, rig, st.w + 8 * s, 4 * s, C(0x1A1420))
        c.rect(st.x - 4 * s, rig, st.w + 8 * s, s, C(0x5A5066)); c.rect(st.x - 4 * s, rig + 3 * s, st.w + 8 * s, s, C(0x3A3044))
        for x in stride(from: st.x - 4 * s, to: st.x + st.w + 4 * s, by: 4 * s) { c.rect(x, rig + s, s, 2 * s, C(0x3A3044)) }
        let lens = [C(0xC070FF), C(0xFF60C8), C(0x60A0FF)]
        for (i, x) in stride(from: st.x + 4 * s, to: st.x + st.w - 2 * s, by: 18 * s).enumerated() {
            c.rect(x, rig + 4 * s, 4 * s, 4 * s, C(0x100C14)); c.rect(x, rig + 8 * s, 4 * s, s, lens[i % 3])
        }
        // The stage curtain, then the stage.
        let ct = rig + 9 * s
        c.rect(st.x, ct, st.w, st.top - ct, C(0x24102E))
        for x in stride(from: st.x, to: st.x + st.w, by: 7 * s) {
            c.rect(x + 2 * s, ct, 2 * s, st.top - ct, C(0x36164A)); c.rect(x + 5 * s, ct, s, st.top - ct, C(0x16081E))
        }
        for k in 0..<3 { c.ellipse(st.x + st.w / 2, st.top, st.w * (5 - k) / 10, (12 + k * 6) * s, C(0xC060F0, 0.07)) }
        c.rect(st.x, st.top, st.w, g - st.top, C(0x140C18))
        c.rect(st.x, st.top, st.w, 2 * s, C(0x4A3A52)); c.rect(st.x, st.top, st.w, s, C(0x6E5A7C))
        for x in stride(from: st.x + 8 * s, to: st.x + st.w - 4 * s, by: 16 * s) { c.rect(x, st.top + 4 * s, 6 * s, 2 * s, C(0x221828)) }
        // Speaker stacks at both ends of the stage.
        for sx in [st.x + 2 * s, st.x + st.w - 16 * s] {
            let sy = st.top - 26 * s
            c.rect(sx, sy, 14 * s, 26 * s, C(0x0C080E)); c.rect(sx, sy, 14 * s, s, C(0x3A3044))
            c.rect(sx, sy + 13 * s, 14 * s, s, C(0x2A2230))
            for cy in [sy + 6 * s, sy + 19 * s] { c.circle(sx + 7 * s, cy, 4 * s, C(0x2A2432)); c.circle(sx + 7 * s, cy, 2 * s, C(0x050306)) }
        }
        // An amp and the mic stand.
        let amp = st.x + st.w * 22 / 100
        c.rect(amp, st.top - 10 * s, 12 * s, 10 * s, C(0x1A1418)); c.rect(amp + s, st.top - 7 * s, 10 * s, 6 * s, C(0x2E2632))
        c.rect(amp + s, st.top - 9 * s, 10 * s, s, C(0x6A6070))
        let mic = st.x + st.w * 36 / 100
        c.rect(mic, st.top - 20 * s, s, 20 * s, C(0x4A4252)); c.rect(mic - 2 * s, st.top - s, 5 * s, s, C(0x4A4252))
        c.rect(mic - s, st.top - 21 * s, 2 * s, 2 * s, C(0x8A8494))
        // The drum kit: bass drum facing us, toms, cymbals on stands.
        let dk = st.x + st.w * 60 / 100
        for (cx, cy) in [(dk - 14 * s, st.top - 18 * s), (dk + 14 * s, st.top - 20 * s)] {
            c.rect(cx, cy, s, st.top - cy, C(0x5A5266)); c.rect(cx - 5 * s, cy, 11 * s, s, C(0xC8A848))
        }
        c.ellipse(dk - 7 * s, st.top - 12 * s, 3 * s, 2 * s, C(0x7A3A8A)); c.ellipse(dk + 7 * s, st.top - 12 * s, 3 * s, 2 * s, C(0x7A3A8A))
        c.circle(dk, st.top - 6 * s, 6 * s, C(0x3A2A44)); c.circle(dk, st.top - 6 * s, 5 * s, C(0xB8A8C8))
        c.rect(dk - 4 * s, st.top - 6 * s, 9 * s, s, C(0x7A3A9A))

        // The bar: bottles on lit shelves under a mirror, the counter, the stools.
        let b = f.bar, bt = g - 42 * s
        c.rect(b.x, bt, b.w, 26 * s, C(0x241C30))
        for (i, x) in stride(from: b.x, to: b.x + b.w, by: 9 * s).enumerated() { c.rect(x + i % 3 * s, bt, s, 26 * s, C(0x32283E)) }
        for (k, sy) in [bt + 9 * s, bt + 19 * s].enumerated() {
            c.rect(b.x, sy - 2 * s, b.w, 2 * s, C(0xFF4AB8, 0.18))
            var x = b.x + 2 * s, i = 0
            while x < b.x + b.w - 3 * s {
                let h = (4 + Int(noise(k * 50 + i) * 3)) * s
                let col = [C(0x3A7A4A), C(0xA86A2A), C(0xC8C0B0), C(0x6A2A3A), C(0x2A4A7A)][Int(noise(k * 50 + i + 7) * 5) % 5]
                c.rect(x, sy - h, 2 * s, h, col); c.rect(x, sy - h - s, s, s, col); c.px(x, sy - h + s, C(0xFFFFFF, 0.6))
                x += 3 * s + (noise(k * 50 + i + 3) > 0.7 ? s : 0); i += 1
            }
            c.rect(b.x, sy, b.w, 2 * s, C(0x3A2418)); c.rect(b.x, sy, b.w, s, C(0x6A4430))
        }
        let ctop = g - 16 * s
        c.rect(b.x - 2 * s, ctop, b.w + 4 * s, 3 * s, C(0x5A3A2A)); c.rect(b.x - 2 * s, ctop, b.w + 4 * s, s, C(0x8A5E3E))
        c.rect(b.x, ctop + 3 * s, b.w, g - ctop - 3 * s, C(0x2A1A1E))
        for x in stride(from: b.x + 3 * s, to: b.x + b.w - 6 * s, by: 14 * s) { c.rect(x, ctop + 5 * s, 10 * s, 6 * s, C(0x22141A)); c.rect(x, ctop + 5 * s, 10 * s, s, C(0x3A262A)) }
        c.rect(b.x, g - 3 * s, b.w, s, C(0xB89040))
        for x in stride(from: b.x + 8 * s, to: b.x + b.w - 4 * s, by: 26 * s) {
            c.rect(x, g - 11 * s, 7 * s, 2 * s, C(0x8A2A44)); c.rect(x, g - 11 * s, 7 * s, s, C(0xB04A64))
            c.rect(x + 3 * s, g - 9 * s, s, 8 * s, C(0x6A6070)); c.rect(x + s, g - s, 5 * s, s, C(0x6A6070))
        }
        // The neon sign over the bar, with its glow.
        let sg = slayerBronzeSign(c, g), sw = slayerSignWidth("THE BRONZE", sg.p)
        c.rect(sg.x - 3 * s, sg.y - 3 * s, sw + 6 * s, 5 * sg.p + 6 * s, C(0x12081A))
        c.rect(sg.x - 2 * s, sg.y - 2 * s, sw + 4 * s, 5 * sg.p + 4 * s, C(0xFF4AC0, 0.12))
        slayerSign(c, sg.x, sg.y, "THE BRONZE", C(0xFF7AD8), sg.p)

        // The sofa: plum velvet.
        let sx = f.sofa, sw2 = 34 * s
        c.rect(sx + 2 * s, g - 16 * s, sw2 - 4 * s, 9 * s, C(0x4A1434)); c.rect(sx + 2 * s, g - 16 * s, sw2 - 4 * s, s, C(0x7A2A5A))
        c.rect(sx + 3 * s, g - 8 * s, sw2 - 6 * s, 3 * s, C(0x6A1E4A)); c.rect(sx + sw2 / 2, g - 8 * s, s, 3 * s, C(0x3A0E2A))
        for ax in [sx, sx + sw2 - 4 * s] { c.rect(ax, g - 12 * s, 4 * s, 9 * s, C(0x5A1A40)); c.rect(ax, g - 12 * s, 4 * s, s, C(0x8A3A6A)) }
        c.rect(sx + s, g - 5 * s, sw2 - 2 * s, 3 * s, C(0x3A0E2A))
        for lx in [sx + s, sx + sw2 - 2 * s] { c.rect(lx, g - 2 * s, s, 2 * s, C(0x1A0A12)) }

        // The pool table under its lamp.
        let px0 = f.pool, pw = 48 * s, lampY = g - 34 * s
        let cordTop = f.loft.map { $0 + 5 * s } ?? 0
        c.rect(px0 + pw / 2, cordTop, s, lampY - cordTop, C(0x0A060C))
        for y in (lampY + 5 * s)..<(g - 15 * s) {
            let half = 5 * s + (y - lampY - 5 * s) * (pw / 2 - 5 * s) / max(1, g - 20 * s - lampY)
            c.rect(px0 + pw / 2 - half, y, 2 * half + s, 1, C(0xF8E8A8, 0.07))
        }
        for k in 0..<5 { c.rect(px0 + pw / 2 - (4 + k) * s, lampY + k * s, (9 + 2 * k) * s, s, k == 4 ? C(0xE8D890) : C(0x24543A)) }
        c.rect(px0, g - 15 * s, pw, 3 * s, C(0x1E7044)); c.rect(px0, g - 15 * s, pw, s, C(0x4A2A1A))
        c.rect(px0 - s, g - 12 * s, pw + 2 * s, 4 * s, C(0x3A2014)); c.rect(px0 - s, g - 12 * s, pw + 2 * s, s, C(0x5A3420))
        for kx in [px0 - s, px0 + pw / 2 - s, px0 + pw - s] { c.rect(kx, g - 12 * s, 2 * s, 2 * s, C(0x0A0606)) }
        for lx in [px0 + s, px0 + pw - 4 * s] { c.rect(lx, g - 8 * s, 3 * s, 8 * s, C(0x2E1810)) }
        for (i, bc) in [C(0xE8E0D0), C(0xD02A2A), C(0xE8C030), C(0x2A4AC0)].enumerated() { c.rect(px0 + (8 + i * 9) * s, g - 16 * s, s, s, bc) }
        slayerLine(c, Double(px0 + pw + 2 * s), Double(g - s), Double(px0 + pw + 7 * s), Double(g - 32 * s), C(0xC8A070), Double(s) * 0.5)

        // A dark concrete floor, the stage's light pooling in front of it.
        c.ground(g, C(0x1C1420), edge: C(0x3A2C44), speck: C(0x271C2C), seed: 71)
        c.ellipse(st.x + st.w / 2, g + 3 * s, st.w / 2, 3 * s, C(0x9A40D0, 0.10))
    }

    /// The Bronze's life: two stage lights sweeping the stage, the band playing in silhouette (the singer at the mic,
    /// the guitarist strumming, the drummer's sticks), and a letter of the neon sign buzzing off now and then.
    static func slayerBronzeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerBronzeFrame(c, g), st = f.stage
        // The beams.
        for (k, col) in [C(0xC070FF, 0.15), C(0xFF60C8, 0.13)].enumerated() {
            let x0 = Double(st.x + st.w * (k == 0 ? 30 : 74) / 100), y0 = f.rig + 9 * s
            let a = 0.38 * sin(t * 0.55 + Double(k) * 2.2)
            for y in y0..<st.top {
                let d = Double(y - y0), half = Int(Double(s) + d * 0.17)
                c.rect(Int(x0 + tan(a) * d) - half, y, 2 * half + 1, 1, col)
            }
            let ex = Int(x0 + tan(a) * Double(st.top - y0))
            c.rect(ex - 10 * s, st.top, 20 * s, s, col.alpha(2.5))
        }
        // The band.
        let ink = C(0x0E0814), rim = C(0xD890FF)
        func player(_ x: Int, bob: Int) {
            let foot = st.top, top = foot - 24 * s + bob
            c.rect(x - 3 * s, foot - 10 * s, 2 * s, 10 * s, ink); c.rect(x + s, foot - 10 * s, 2 * s, 10 * s, ink)
            c.rect(x - 4 * s, top + 4 * s, 8 * s, 11 * s - bob, ink)
            c.circle(x, top + s, 3 * s, ink)
            c.rect(x - 4 * s, top + 4 * s, s, 10 * s, rim); c.rect(x - 3 * s, top - s, s, 3 * s, rim)
            c.rect(x + 3 * s, top + 4 * s, s, 10 * s, C(0xFF70C8, 0.6)); c.rect(x - 3 * s, foot - 10 * s, s, 10 * s, rim.alpha(0.5))
        }
        let beat = Int(t * 4.4)
        let mic = st.x + st.w * 36 / 100
        player(mic + 3 * s, bob: beat % 4 == 0 ? s : 0)                    // the singer, at the mic
        slayerLine(c, Double(mic + 2 * s), Double(st.top - 18 * s), Double(mic), Double(st.top - 20 * s), ink, Double(s) * 0.7)
        let gx = st.x + st.w * 84 / 100, gb = beat % 2 == 0 ? s : 0          // the guitarist
        player(gx, bob: gb)
        c.ellipse(gx - s, st.top - 11 * s + gb, 4 * s, 3 * s, C(0x9A2A3A)); c.ellipse(gx - s, st.top - 11 * s + gb, s, s, C(0x1A0A10))
        slayerLine(c, Double(gx - 2 * s), Double(st.top - 12 * s + gb), Double(gx - 13 * s), Double(st.top - 18 * s + gb), C(0x6A4A3A), Double(s) * 0.6)
        let strum = (beat % 2 == 0 ? -2 : 1) * s
        slayerLine(c, Double(gx + 3 * s), Double(st.top - 18 * s + gb), Double(gx + s), Double(st.top - 11 * s + gb + strum), ink, Double(s) * 0.8)
        let dk = st.x + st.w * 60 / 100                                       // the drummer, behind the kit
        c.rect(dk - 4 * s, st.top - 22 * s, 8 * s, 8 * s, ink); c.circle(dk, st.top - 25 * s, 3 * s, ink)
        c.rect(dk - 4 * s, st.top - 22 * s, s, 8 * s, rim); c.rect(dk - 3 * s, st.top - 27 * s, s, 3 * s, rim)
        for (k, side) in [-1, 1].enumerated() {
            let hit = (beat + k) % 2 == 0
            slayerLine(c, Double(dk + side * 3 * s), Double(st.top - 18 * s), Double(dk + side * (hit ? 9 : 7) * s),
                       Double(st.top - (hit ? 13 : 22) * s), C(0xE0D0B8), Double(s) * 0.5)
        }
        // The sign buzzes: one letter drops out for a moment every few seconds.
        let fl = Int(t * 7)
        if noise(fl * 13 + 11) > 0.92 {
            let sg = slayerBronzeSign(c, g), i = 4 + Int(noise(fl / 20) * 6) % 6   // a letter of BRONZE
            c.rect(sg.x + (i * 4 - 1) * sg.p, sg.y, 3 * sg.p, 5 * sg.p, C(0x12081A))
        }
    }
}

// MARK: - Restfield Cemetery

extension Scenes {
    /// Where things stand in the cemetery: the horizon, the moon, the fresh grave, the bare tree.
    static func slayerCemeteryFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, moon: (x: Int, y: Int, r: Int), grave: Int, tree: Int) {
        let s = unit(g), tall = isTall(c)
        let moon = tall ? (x: c.w * 30 / 100, y: (g - 50 * s) * 36 / 100, r: 46 * s) : (x: c.w * 47 / 100, y: 12 * s, r: 7 * s)
        return (tall ? g - 50 * s : g - 26 * s, moon, c.w * 57 / 100, c.w * 86 / 100)
    }

    /// A bare tree: a trunk forking into crooked branches, `depth` times.
    static func slayerBranch(_ c: PixelCanvas, _ x: Double, _ y: Double, _ angle: Double, _ len: Double, _ r: Double,
                             _ depth: Int, _ seed: Int, _ col: Px) {
        let rad = angle * .pi / 180
        let x1 = x + cos(rad) * len, y1 = y - sin(rad) * len
        slayerLine(c, x, y, x1, y1, col, max(0.5, r))
        guard depth > 0 else { return }
        let spread = 18 + noise(seed) * 22
        slayerBranch(c, x1, y1, angle + spread, len * (0.62 + noise(seed + 1) * 0.15), r * 0.68, depth - 1, seed * 3 + 1, col)
        slayerBranch(c, x1, y1, angle - spread * 0.9, len * (0.58 + noise(seed + 2) * 0.18), r * 0.66, depth - 1, seed * 3 + 2, col)
    }

    /// A headstone `w` by `h` standing on `base` at x: rounded (0), a cross (1) or peaked (2), leaning `lean` units
    /// over its height.
    static func slayerHeadstone(_ c: PixelCanvas, _ x: Int, _ base: Int, _ w: Int, _ h: Int, kind: Int, lean: Int, _ s: Int,
                                far: Bool) {
        let body = far ? C(0x3A4644) : C(0x56625E), lit = far ? C(0x4A5652) : C(0x7A8882), shade = far ? C(0x2A3432) : C(0x3A4642)
        for r in 0..<h {
            let y = base - (r + 1) * s, dx = lean * r / max(1, h) * s
            var inset = 0, ww = w
            switch kind {
            case 0:
                let k = r - (h - w / 2)
                if k > 0 { let rr = Double(w) / 2; inset = Int(rr - (rr * rr - Double(k * k)).squareRoot().rounded()) }
            case 1:
                inset = (w - 2) / 2
                if r >= h * 6 / 10 && r < h * 6 / 10 + 2 { inset = 0 }
            default:
                if r >= h - w / 2 { inset = r - (h - w / 2) }
            }
            ww = w - 2 * inset
            guard ww > 0 else { continue }
            c.rect(x + inset * s + dx, y, ww * s, s, body)
            c.rect(x + inset * s + dx, y, s, s, lit)
            c.rect(x + (inset + ww - 1) * s + dx, y, s, s, shade)
        }
        if kind == 0 && !far && h > 8 { c.rect(x + 2 * s + lean * 4 / h * s, base - h * s * 6 / 10, (w - 4) * s, s, shade) }
    }

    /// Restfield Cemetery at night: a dark teal sky with stars and the moon, low hills and a tree line, an iron fence
    /// across the back, a columned mausoleum on the left and a flat-roofed crypt with an urn on the right, leaning
    /// headstones and crosses between them, a fresh grave with its mound of dirt, and a bare tree. On the screen saver
    /// the moon is huge and the tree reaches right up the sky.
    static func slayerCemetery(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerCemeteryFrame(c, g), hz = f.horizon
        c.gradient(0, hz + 6 * s, C(0x050A12), C(0x183836), bands: tall ? 10 : 6)
        c.stars(0, hz - 10 * s, density: tall ? 110 : 70, seed: 5)
        // The moon, with a cold halo and a few seas.
        let m = f.moon
        c.circle(m.x, m.y, m.r * 17 / 10, C(0xC8F0E0, 0.05)); c.circle(m.x, m.y, m.r * 13 / 10, C(0xC8F0E0, 0.07))
        c.circle(m.x, m.y, m.r, C(0xE6F0DA))
        for (dx, dy, rr) in [(-3, -2, 2), (2, 2, 3), (3, -4, 1), (-1, 4, 1)] where m.r > 10 * s {
            c.circle(m.x + dx * m.r / 8, m.y + dy * m.r / 8, rr * m.r / 9, C(0xC8D6C0))
        }
        if m.r <= 10 * s { c.rect(m.x - 2 * s, m.y - s, 2 * s, 2 * s, C(0xC8D6C0)) }
        // Hills and a tree line on the horizon, then the graveyard's grass.
        c.dunes(base: hz + 2 * s, amp: Double(3 * s), freq: 0.02, phase: 1, bottom: g, C(0x0C1C1C))
        for x in stride(from: 0, to: c.w, by: 3 * s) {
            let h = (2 + Int(noise(x / (3 * s) + 300) * 6)) * s
            c.rect(x, hz - h + s, 3 * s, h, C(0x081414))
        }
        c.gradient(hz + 5 * s, g, C(0x0E1E1A), C(0x1A3028), bands: 4)
        // The bare tree, behind the crypts.
        let trunk = tall ? 120.0 : 24.0
        slayerBranch(c, Double(f.tree), Double(hz + 8 * s), 92, trunk * Double(s) * 0.55, Double(s) * (tall ? 4.5 : 2.2),
                     tall ? 6 : 4, 7, C(0x0A1210))
        // The iron fence.
        let fb = hz + 8 * s
        c.rect(0, fb - 9 * s, c.w, s, C(0x0A0E10)); c.rect(0, fb - 3 * s, c.w, s, C(0x0A0E10))
        for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, fb - 11 * s, s, 11 * s, C(0x0A0E10)); c.px(x, fb - 12 * s, C(0x0A0E10)) }
        if tall {   // a middle row of stones on the screen saver's deeper ground
            for k in 0..<9 {
                let x = c.w * (3 + k * 11) / 100 + Int(noise(k + 60) * 20) * s
                slayerHeadstone(c, x, hz + 28 * s, 7, 11, kind: k % 3, lean: Int((noise(k + 61) - 0.5) * 5), s, far: true)
            }
        }
        // The mausoleum on the left: a pediment on two columns, an iron door, steps.
        let mx = c.w * 5 / 100, mw = 56 * s, mb = g - 3 * s, mh = 32 * s
        let stone = C(0x5E6A66), lit = C(0x84928A), shade = C(0x38423F)
        c.rect(mx, mb - mh, mw, mh, stone); c.rect(mx, mb - mh, s, mh, lit); c.rect(mx + mw - 3 * s, mb - mh, 3 * s, mh, shade)
        for k in 0..<(10 * s) {
            let inset = k * (mw / 2 + 4 * s) / (10 * s)
            c.rect(mx - 4 * s + inset, mb - mh - k - s, mw + 8 * s - 2 * inset, s, k == 0 ? lit : stone)
        }
        c.rect(mx - 4 * s, mb - mh - s, mw + 8 * s, 2 * s, shade)
        c.rect(mx + mw / 2 - s, mb - mh - 6 * s, 2 * s, 2 * s, shade)
        for cx in [mx + 6 * s, mx + mw - 12 * s] { c.rect(cx, mb - mh + s, 6 * s, mh - s, C(0x6E7A74)); c.rect(cx, mb - mh + s, s, mh - s, lit); c.rect(cx + 5 * s, mb - mh + s, s, mh - s, shade) }
        let dx = mx + mw / 2 - 8 * s, dy = mb - 24 * s
        c.rect(dx - s, dy - s, 18 * s, 25 * s, shade)
        c.rect(dx, dy, 16 * s, 24 * s, C(0x141A1C))
        for x in stride(from: dx + 2 * s, to: dx + 16 * s, by: 3 * s) { c.rect(x, dy, s, 24 * s, C(0x2A3436)) }
        c.rect(dx, dy + 8 * s, 16 * s, s, C(0x2A3436)); c.rect(dx + 8 * s, dy, s, 24 * s, C(0x0A0E10))
        c.rect(mx + 10 * s, mb - mh + 4 * s, mw - 20 * s, 2 * s, shade)
        c.rect(mx - 2 * s, mb, mw + 4 * s, 3 * s, C(0x4A5652)); c.rect(mx - 2 * s, mb, mw + 4 * s, s, lit)
        // The crypt on the right: flat-roofed, an urn on top, a dark doorway.
        let rx = c.w * 70 / 100, rw = 42 * s, rb = g - 5 * s, rh = 26 * s
        c.rect(rx, rb - rh, rw, rh, C(0x52605A)); c.rect(rx, rb - rh, s, rh, lit); c.rect(rx + rw - 3 * s, rb - rh, 3 * s, rh, shade)
        c.rect(rx - 3 * s, rb - rh - 3 * s, rw + 6 * s, 3 * s, stone); c.rect(rx - 3 * s, rb - rh - 3 * s, rw + 6 * s, s, lit)
        c.rect(rx + rw / 2 - 2 * s, rb - rh - 6 * s, 4 * s, 3 * s, stone); c.ellipse(rx + rw / 2, rb - rh - 9 * s, 4 * s, 3 * s, C(0x6A7670))
        c.rect(rx + rw / 2 - s, rb - rh - 13 * s, 2 * s, 2 * s, C(0x6A7670))
        c.rect(rx + rw / 2 - 7 * s, rb - 18 * s, 14 * s, 18 * s, C(0x0C1012)); c.ellipse(rx + rw / 2, rb - 18 * s, 7 * s, 4 * s, C(0x0C1012))
        c.rect(rx - s, rb, rw + 2 * s, 5 * s, C(0x44504C)); c.rect(rx - s, rb, rw + 2 * s, s, lit)
        // Headstones between them, near and far, some leaning.
        let stones: [(x: Int, w: Int, h: Int, kind: Int, lean: Int, far: Bool)] = [
            (23, 7, 9, 0, 2, true), (31, 5, 8, 1, 0, true), (40, 6, 7, 2, -1, true), (64, 6, 8, 0, 1, true), (93, 6, 8, 2, 0, true),
            (27, 9, 15, 0, -3, false), (36, 7, 16, 1, 2, false), (45, 10, 13, 2, 0, false), (66, 8, 14, 0, 3, false),
            (91, 9, 16, 1, -2, false),
        ]
        for st in stones {
            slayerHeadstone(c, c.w * st.x / 100, st.far ? hz + 12 * s : g - (st.x % 3) * s, st.w, st.h, kind: st.kind,
                            lean: st.lean, s, far: st.far)
        }
        // The fresh grave: a new headstone and a mound of turned earth.
        slayerHeadstone(c, f.grave - 4 * s, g - 2 * s, 9, 14, kind: 0, lean: 0, s, far: false)
        c.ground(g, C(0x16261E), edge: C(0x2C4234), speck: C(0x0E1C16), seed: 83)
        for x in stride(from: 0, to: c.w, by: 5 * s) where noise(x + 9) > 0.5 { c.rect(x, g - s, s, s, C(0x2C4234)) }
        c.ellipse(f.grave + 2 * s, g + s, 16 * s, 3 * s, C(0x2E2016)); c.rect(f.grave - 10 * s, g - 2 * s, 24 * s, s, C(0x4A3624))
        for k in 0..<6 { c.rect(f.grave - 12 * s + Int(noise(k + 40) * 28) * s, g + Int(noise(k + 50) * 3) * s, s, s, C(0x4A3624)) }
    }

    /// The cemetery's life: mist rolling low over the grass, and every so often a pale hand pushing up out of the
    /// fresh grave, clawing at the air, and sinking back. On the screen saver a bat flits across the moon.
    static func slayerCemeteryLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerCemeteryFrame(c, g)
        // Mist.
        let span = Double(c.w + 240 * s)
        for k in 0..<6 {
            let x = Int(frac(noise(k * 5) + t * 0.006 * (0.6 + noise(k * 5 + 1)))  * span) - 120 * s
            let y = g - (2 + Int(noise(k * 5 + 2) * 10)) * s
            let rx = (40 + Int(noise(k * 5 + 3) * 40)) * s, ry = (2 + Int(noise(k * 5 + 4) * 2)) * s
            c.ellipse(x, y, rx, ry, C(0xB8E0D0, 0.07)); c.ellipse(x + rx / 3, y - s, rx / 2, max(s, ry - s), C(0xD0F0E4, 0.06))
        }
        if isTall(c) {
            for k in 0..<3 {
                let x = Int(frac(noise(k * 9 + 70) + t * 0.004) * span) - 120 * s
                c.ellipse(x, f.horizon + (8 + k * 6) * s, (70 + k * 20) * s, 3 * s, C(0xB8E0D0, 0.06))
            }
            // A bat crossing the moon.
            let m = f.moon, k = frac(t / 19)
            if k < 0.5 {
                let bx = m.x - m.r * 2 + Int(k / 0.5 * Double(m.r * 4)), by = m.y + Int(sin(t * 3) * Double(4 * s))
                let up = Int(t * 8) % 2 == 0
                c.rect(bx - s, by - s, 3 * s, 3 * s, C(0x060808)); c.rect(bx - s, by - 2 * s, s, s, C(0x060808)); c.rect(bx + s, by - 2 * s, s, s, C(0x060808))
                c.rect(bx - 5 * s, by + (up ? -2 : 0) * s, 4 * s, s, C(0x060808)); c.rect(bx + 2 * s, by + (up ? -2 : 0) * s, 4 * s, s, C(0x060808))
                c.rect(bx - 3 * s, by - (up ? 1 : 0) * s, 2 * s, s, C(0x060808)); c.rect(bx + 2 * s, by - (up ? 1 : 0) * s, 2 * s, s, C(0x060808))
            }
        }
        // The hand from the grave.
        let k = frac((t + 4) / 23)
        guard k < 0.4 else { return }
        let rise = min(1, k / 0.1, (0.4 - k) / 0.06)
        let h = Int(rise * 9) * s, x = f.grave + 2 * s, base = g + s
        guard h > 0 else { return }
        let skin = C(0x9AAA94), dark = C(0x6A7A66)
        c.rect(x, base - h, 3 * s, h, skin); c.rect(x + 2 * s, base - h, s, h, dark)
        c.rect(x - s, base - 2 * s, 5 * s, 2 * s, C(0x3A2A1A))
        if h >= 6 * s {
            let grip = Int(t * 2.5) % 2 == 0, top = base - h
            c.rect(x - s, top - 2 * s, 5 * s, 3 * s, skin)
            for i in 0..<4 { c.rect(x - s + i * (grip ? s : (i < 2 ? s : 2 * s)) + (grip ? 0 : (i - 1) * s / 2), top - (grip ? 3 : 5) * s, s, (grip ? 1 : 3) * s, skin) }
            c.rect(x - 2 * s, top, s, 2 * s, skin)   // the thumb
            for d in 0..<3 { c.px(x - 3 * s + Int(noise(Int(t * 6) + d) * Double(9 * s)), base - Int(noise(Int(t * 6) + d + 9) * Double(5 * s)), C(0x4A3624)) }
        }
    }
}

// MARK: - 1630 Revello Drive

extension Scenes {
    /// Where things stand at the Summers house: the house's span, the porch floor and roof, the two lit windows
    /// downstairs and the upstairs windows.
    static func slayerRevelloFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, w: Int, eave: Int, tv: (x: Int, y: Int, w: Int, h: Int),
                                                                 lamp: (x: Int, y: Int, w: Int, h: Int), upper: Int, upperH: Int) {
        let s = unit(g), tall = isTall(c)
        let w = min(c.w * 64 / 100, 250 * s), x = (c.w - w) / 2 + c.w * 5 / 100
        let ww = 30 * s, wy = g - 31 * s, wh = 18 * s
        return (x, w, g - 38 * s, (x + w * 12 / 100, wy, ww, wh), (x + w - w * 12 / 100 - ww, wy, ww, wh),
                tall ? g - 80 * s : g - 62 * s, tall ? 24 * s : 16 * s)
    }

    /// A sash window: trim, glass lit `glass` (or dark), mullions, and rose curtains drawn to the sides.
    static func slayerWindow(_ c: PixelCanvas, _ x: Int, _ y: Int, _ w: Int, _ h: Int, lit: Bool, _ s: Int) {
        let trim = C(0xC8C0A8)
        c.rect(x - 2 * s, y - 2 * s, w + 4 * s, h + 4 * s, trim); c.rect(x - 3 * s, y + h + s, w + 6 * s, 2 * s, trim)
        if lit {
            c.rect(x, y, w, h, C(0xF0B460)); c.rect(x, y, w, h / 3, C(0xF8CC80))
            c.rect(x, y, 4 * s, h, C(0xB85C58)); c.rect(x + w - 4 * s, y, 4 * s, h, C(0xB85C58))
            c.rect(x + 3 * s, y, s, h, C(0x8A3C3C)); c.rect(x + w - 4 * s, y, s, h, C(0x8A3C3C))
        } else {
            c.rect(x, y, w, h, C(0x2A2E44)); c.rect(x + s, y + s, w / 3, s, C(0x5A6084))
        }
        c.rect(x, y + h / 2, w, s, trim); c.rect(x + w / 2, y, s, h, trim)
    }

    /// 1630 Revello Drive at dusk: the Summers house, sage clapboard with cream trim, its porch with columns on brick
    /// piers, a railing and a swing, steps down to the lawn, the front door under a porch light, warm windows either
    /// side, the upstairs windows above. A rose and orange dusk behind dark trees, a street lamp on the corner. On the
    /// screen saver the gabled roof, the chimney, a lit attic window, Buffy's tree reaching up to her window, and the
    /// first stars.
    static func slayerRevello(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerRevelloFrame(c, g)
        // Dusk.
        if tall {
            let mid = g * 45 / 100
            c.gradient(0, mid, C(0x0E0C2A), C(0x3A2456), bands: 8)
            c.gradient(mid, g, C(0x3A2456), C(0xD8805A), bands: 8)
            c.stars(0, mid, density: 90, seed: 3)
            let mx = c.w * 82 / 100, my = g * 16 / 100, mr = 11 * s   // a crescent moon
            for y in (my - mr)...(my + mr) {
                for x in (mx - mr)...(mx + mr) {
                    let (dx, dy) = (x - mx, y - my), (ex, ey) = (x - mx - mr / 2, y - my + mr / 4)
                    if dx * dx + dy * dy <= mr * mr && ex * ex + ey * ey > mr * mr { c.px(x, y, C(0xF0E8D0)) }
                }
            }
        } else {
            c.gradient(0, g, C(0x3A2456), C(0xD07A58), bands: 6)
        }
        // Far rooftops and trees along the street.
        for x in stride(from: 0, to: c.w, by: 4 * s) {
            let h = (8 + Int(noise(x / (4 * s) + 500) * 6) + (noise(x / (24 * s) + 520) > 0.5 ? 4 : 0)) * s
            c.rect(x, g - h, 4 * s, h, C(0x2A1E30))
        }
        // The tree on the left, by Buffy's window.
        let hx = f.x, hw = f.w, trim = C(0xC8C0A8)
        let tx = hx - 22 * s, treeTop = tall ? f.upper - 40 * s : -10 * s
        c.rect(tx - 3 * s, treeTop + 20 * s, 7 * s, g - treeTop - 20 * s, C(0x241820))
        for k in 0..<7 {
            let cx = tx + Int((noise(k * 3 + 80) - 0.5) * 56) * s, cy = treeTop + Int(noise(k * 3 + 81) * 40) * s + 14 * s
            c.ellipse(cx, cy, (14 + Int(noise(k * 3 + 82) * 8)) * s, (11 + Int(noise(k * 3 + 83) * 6)) * s, k % 2 == 0 ? C(0x1C1A28) : C(0x221E2E))
        }
        // The house: upstairs wall (and on the screen saver the gable roof and chimney), then the porch.
        let siding = C(0x667270), line = C(0x525E5C)
        let wallTop = tall ? f.upper - 14 * s : 0
        c.rect(hx, wallTop, hw, g - wallTop, siding)
        for y in stride(from: wallTop + 3 * s, to: g, by: 3 * s) { c.rect(hx, y, hw, s, line) }
        c.rect(hx, wallTop, 2 * s, g - wallTop, trim); c.rect(hx + hw - 2 * s, wallTop, 2 * s, g - wallTop, trim)
        if tall {
            let apex = wallTop - hw * 30 / 100, ov = 8 * s
            for y in apex..<wallTop {
                let k = Double(y - apex) / Double(wallTop - apex), half = Int(k * Double(hw / 2 + ov))
                c.rect(hx + hw / 2 - half, y, 2 * half, 1, (y - apex) % (3 * s) == 0 ? C(0x2A2434) : C(0x3A3244))
            }
            c.ellipse(hx + hw / 2, wallTop - (wallTop - apex) / 3, 9 * s, 6 * s, trim)   // the attic window
            c.ellipse(hx + hw / 2, wallTop - (wallTop - apex) / 3, 7 * s, 4 * s, C(0xD8985A))
            c.rect(hx + hw / 2 - s / 2, wallTop - (wallTop - apex) / 3 - 4 * s, s, 8 * s, trim)
            slayerLine(c, Double(hx - ov), Double(wallTop + s), Double(hx + hw / 2), Double(apex), trim, Double(s) * 0.9)
            slayerLine(c, Double(hx + hw / 2), Double(apex), Double(hx + hw + ov), Double(wallTop + s), trim, Double(s) * 0.9)
            let chx = hx + hw * 78 / 100, chTop = apex + (wallTop - apex) * 30 / 100
            c.rect(chx, chTop, 10 * s, wallTop - chTop - (wallTop - apex) * 30 / 100, C(0x6A3A2E))
            for y in stride(from: chTop, to: wallTop - (wallTop - apex) * 30 / 100, by: 3 * s) { c.rect(chx, y, 10 * s, s, C(0x4A2820)) }
            c.rect(chx - s, chTop - 2 * s, 12 * s, 2 * s, C(0x3A2420))
        }
        // The upstairs windows: Buffy's lit, the other dark.
        slayerWindow(c, hx + hw * 16 / 100, f.upper, 26 * s, f.upperH, lit: true, s)
        slayerWindow(c, hx + hw * 50 / 100 - 13 * s, f.upper, 26 * s, f.upperH, lit: false, s)
        slayerWindow(c, hx + hw - hw * 16 / 100 - 26 * s, f.upper, 26 * s, f.upperH, lit: false, s)
        // The branch Buffy climbs in and out by, reaching to her sill.
        slayerLine(c, Double(tx), Double(f.upper + f.upperH + 12 * s), Double(hx + hw * 16 / 100 - 4 * s), Double(f.upper + f.upperH + 3 * s), C(0x241820), Double(s) * 1.4)
        for k in 0..<3 { c.ellipse(hx + (2 + k * 5) * s, f.upper + f.upperH + (4 - k) * s, 4 * s, 3 * s, C(0x1C1A28)) }
        // The porch: shaded wall behind, roof, the two windows and the door, the columns and railing, the steps.
        let eave = f.eave, floorY = g - 5 * s
        c.rect(hx + 2 * s, eave, hw - 4 * s, floorY - eave, C(0x4A5452))
        for y in stride(from: eave + 3 * s, to: floorY, by: 3 * s) { c.rect(hx + 2 * s, y, hw - 4 * s, s, C(0x3E4846)) }
        c.rect(hx - 6 * s, eave - 5 * s, hw + 12 * s, 3 * s, C(0x3A3244)); c.rect(hx - 6 * s, eave - 2 * s, hw + 12 * s, 2 * s, trim)
        c.rect(hx - 6 * s, eave - 6 * s, hw + 12 * s, s, C(0x5A5066))
        for w in [f.tv, f.lamp] { slayerWindow(c, w.x, w.y, w.w, w.h, lit: true, s) }
        let doorX = hx + hw / 2 - 8 * s
        c.rect(doorX - 2 * s, g - 32 * s, 20 * s, 27 * s, trim)
        c.rect(doorX, g - 30 * s, 16 * s, 25 * s, C(0x4A2A20)); c.rect(doorX + 3 * s, g - 28 * s, 10 * s, 8 * s, C(0xE8A860))
        c.rect(doorX + 8 * s, g - 28 * s, s, 8 * s, C(0x4A2A20)); c.rect(doorX + 12 * s, g - 17 * s, s, s, C(0xC8A048))
        c.rect(doorX + 19 * s, g - 26 * s, 2 * s, 3 * s, C(0xF8D890))
        c.circle(doorX + 19 * s, g - 25 * s, 5 * s, C(0xF8D890, 0.10))
        // The porch swing on its chains.
        let swx = hx + 10 * s
        c.rect(swx, eave, s, 21 * s, C(0x8A8070)); c.rect(swx + 22 * s, eave, s, 21 * s, C(0x8A8070))
        c.rect(swx - s, g - 17 * s, 25 * s, 2 * s, C(0xB8AE96)); c.rect(swx - s, g - 21 * s, 25 * s, s, C(0xB8AE96))
        // Porch floor, piers, columns, railing.
        c.rect(hx - 4 * s, floorY, hw + 8 * s, 5 * s, C(0x5A4E48)); c.rect(hx - 4 * s, floorY, hw + 8 * s, s, trim)
        let stepW = 26 * s, stepX = hx + hw / 2 - stepW / 2
        let piers = [hx - 3 * s, stepX - 7 * s, stepX + stepW + s, hx + hw - 4 * s]
        for (i, px) in piers.enumerated() {
            if i < 3 {
                let nx = piers[i + 1]
                if i != 1 {
                    c.rect(px + 7 * s, g - 13 * s, nx - px - 7 * s, s, trim); c.rect(px + 7 * s, floorY - s, nx - px - 7 * s, s, trim)
                    for bx in stride(from: px + 9 * s, to: nx, by: 3 * s) { c.rect(bx, g - 12 * s, s, 6 * s, trim) }
                }
            }
            c.rect(px, g - 14 * s, 7 * s, 14 * s, C(0x7A3E32))
            for y in stride(from: g - 12 * s, to: g, by: 3 * s) { c.rect(px, y, 7 * s, s, C(0x5A2C24)) }
            c.rect(px - s, g - 15 * s, 9 * s, 2 * s, trim)
            c.rect(px + s, eave, 5 * s, g - 15 * s - eave, trim); c.rect(px + 4 * s, eave, 2 * s, g - 15 * s - eave, C(0xA8A090))
        }
        for k in 0..<2 {
            c.rect(stepX - k * 2 * s, floorY + (k + 1) * 2 * s - s, stepW + k * 4 * s, 2 * s, C(0x6A5E56))
            c.rect(stepX - k * 2 * s, floorY + (k + 1) * 2 * s - s, stepW + k * 4 * s, s, C(0x8A7E72))
        }
        // The street lamp on the corner, and a hedge.
        let lx = c.w * 95 / 100
        c.rect(lx, g - 46 * s, 2 * s, 46 * s, C(0x1A1420)); c.rect(lx - 2 * s, g - 50 * s, 6 * s, 4 * s, C(0xF8E0A0))
        c.rect(lx - 3 * s, g - 51 * s, 8 * s, s, C(0x1A1420)); c.circle(lx + s, g - 48 * s, 9 * s, C(0xF8E0A0, 0.10))
        for k in 0..<6 { c.ellipse(hx + hw + (6 + k * 6) * s, g - 4 * s, 6 * s, 5 * s, C(0x1E2A22)) }
        for k in 0..<4 { c.ellipse(hx - (34 + k * 7) * s, g - 3 * s, 6 * s, 4 * s, C(0x1E2A22)) }
        // The lawn, a path to the steps.
        c.ground(g, C(0x24302A), edge: C(0x3A4C3E), speck: C(0x1C2622), seed: 91)
        c.rect(stepX - 2 * s, g, stepW + 4 * s, c.h - g, C(0x3A3A38)); c.rect(stepX - 2 * s, g, stepW + 4 * s, s, C(0x4E4C48))
    }

    /// Revello Drive's life: the TV's blue flicker in the living-room window, the curtain stirring in the other, and
    /// a moth circling the porch light.
    static func slayerRevelloLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerRevelloFrame(c, g)
        let tv = f.tv, n = noise(Int(t * 5) + 3)
        c.rect(tv.x + 4 * s, tv.y, tv.w - 8 * s, tv.h, C(0x7AA0F0, 0.25 + 0.35 * n))
        c.rect(tv.x + 4 * s, tv.y + tv.h - 3 * s, tv.w - 8 * s, 3 * s, C(0x3A4A80, 0.4))
        let l = f.lamp, sway = Int(((sin(t * 1.1) + 1) * 1.5 + (sin(t * 2.7) + 1) * 0.6).rounded())
        for y in 0..<(l.h / s) {
            let bulge = sway * y / max(1, l.h / s)
            c.rect(l.x + l.w - (4 + bulge) * s, l.y + y * s, (bulge + 1) * s, s, C(0xB85C58))
            c.rect(l.x + l.w - (4 + bulge) * s, l.y + y * s, s, s, C(0x8A3C3C))
        }
        let doorX = f.x + f.w / 2 - 8 * s, a = t * 3.1
        c.px(doorX + 20 * s + Int(cos(a) * Double(4 * s)), g - 25 * s + Int(sin(a * 1.3) * Double(3 * s)), C(0xF8F0D8))
    }
}

// MARK: - The Magic Box

extension Scenes {
    /// Where things stand in the Magic Box: the counter, the round table, the hanging crystal, and (on the screen
    /// saver) the loft and the back door to the training room.
    static func slayerMagicBoxFrame(_ c: PixelCanvas, _ g: Int) -> (counter: (x: Int, w: Int), table: Int, crystal: (x: Int, y: Int),
                                                                  loft: Int?, door: (x: Int, w: Int, top: Int)?) {
        let s = unit(g), tall = isTall(c)
        let table = c.w * 43 / 100
        return ((c.w * 68 / 100, c.w * 26 / 100), table, (table, g - 34 * s), tall ? g - 86 * s : nil,
                tall ? (c.w * 50 / 100, 30 * s, g - 48 * s) : nil)
    }

    /// The Magic Box: Giles's magic shop, warm and amber. The front window on the left with herbs hung in it, shelving
    /// units packed with jars, bottles, crystal clusters, candles, books and the odd skull, plaster between them hung
    /// with a dreamcatcher and a mask, a wainscot below, the round research table with its chairs and open books, the
    /// counter with a glass display case and a brass till, an incense burner, cubbyholes and the shop's sign behind it,
    /// and a crystal hung over the table. On the screen saver the loft with its railing, low bookcases and crates and
    /// a ladder up, a brick wall above with a zodiac wheel and a high window, brass lanterns on chains, beams hung with
    /// dried herbs, and the back door open on the training room.
    static func slayerMagicBox(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = slayerMagicBoxFrame(c, g)
        let wood = C(0x6A4428), woodL = C(0x9A6438), woodD = C(0x3A2214)
        c.gradient(0, g, C(0x3A2216), C(0x5E3A24), bands: 5)
        let shelfTop = f.loft.map { $0 + 10 * s } ?? 4 * s, shelfBottom = g - 20 * s
        if let loft = f.loft {
            // Brick above the loft, the beams and their herbs, lanterns, a zodiac wheel and a high window.
            for (row, y) in stride(from: 10 * s, to: loft, by: 4 * s).enumerated() {
                c.rect(0, y, c.w, s, C(0x3A1E12, 0.6))
                for x in stride(from: row % 2 * 5 * s, to: c.w, by: 10 * s) { c.rect(x, y, s, 4 * s, C(0x3A1E12, 0.5)) }
            }
            c.rect(0, 0, c.w, 8 * s, woodD); c.rect(0, 7 * s, c.w, s, wood)
            for x in stride(from: 0, to: c.w, by: 44 * s) {
                c.rect(x, 0, 6 * s, 12 * s, C(0x4A2C18)); c.rect(x, 0, s, 12 * s, wood)
                for k in 0..<3 {
                    let hx = x + (14 + k * 8) * s
                    c.rect(hx, 8 * s, s, 5 * s, C(0x8A7A5A))
                    c.rect(hx - s, 13 * s, 3 * s, 7 * s, [C(0x4A6A3A), C(0x7A6A34), C(0x5A7A44)][k]); c.rect(hx - s, 13 * s, 3 * s, s, C(0x8A3A2A))
                }
            }
            let wx = c.w * 72 / 100, ww = 34 * s, wt = 30 * s, wb = loft - 40 * s
            if wb - wt > 30 * s {
                c.rect(wx - 3 * s, wt + ww / 2, ww + 6 * s, wb - wt - ww / 2 + 3 * s, woodD); c.ellipse(wx + ww / 2, wt + ww / 2, ww / 2 + 3 * s, ww / 2 + 3 * s, woodD)
                c.rect(wx, wt + ww / 2, ww, wb - wt - ww / 2, C(0x1A2440)); c.ellipse(wx + ww / 2, wt + ww / 2, ww / 2, ww / 2, C(0x1A2440))
                c.rect(wx, wt + ww / 2, ww, ww / 2, C(0x1A2440))
                c.stars(wt, wb, density: 30, seed: 11, x0: wx, x1: wx + ww)
                c.rect(wx + ww / 2, wt, s, wb - wt, woodD)
                for y in stride(from: wt + ww / 2, to: wb, by: 10 * s) { c.rect(wx, y, ww, s, woodD) }
            }
            let zx = c.w * 30 / 100, zy = (loft + 10 * s) / 2, zr = min(34 * s, (loft - 30 * s) / 2)
            if zr > 14 * s {
                c.circle(zx, zy, zr + 2 * s, C(0x5A3A1A)); c.circle(zx, zy, zr, C(0x1E2A3A)); c.circle(zx, zy, zr * 7 / 10, C(0x2A3A4E))
                c.circle(zx, zy, zr * 7 / 10 - s, C(0x1E2A3A)); c.circle(zx, zy, zr / 4, C(0xC89A3A)); c.circle(zx, zy, zr / 4 - 2 * s, C(0xE8C860))
                for k in 0..<12 {
                    let a = Double(k) / 12 * 2 * .pi
                    slayerLine(c, Double(zx) + cos(a) * Double(zr / 4), Double(zy) + sin(a) * Double(zr / 4),
                               Double(zx) + cos(a) * Double(zr), Double(zy) + sin(a) * Double(zr), C(0xC89A3A), Double(s) * 0.5)
                    let m = a + .pi / 12
                    c.rect(zx + Int(cos(m) * Double(zr * 85 / 100)) - s, zy + Int(sin(m) * Double(zr * 85 / 100)) - s, 2 * s, 2 * s, C(0xE8C860))
                }
            }
            for (k, lx) in [c.w * 12 / 100, c.w * 52 / 100, c.w * 90 / 100].enumerated() {
                let ly = 40 * s + k % 2 * 24 * s
                c.rect(lx, 8 * s, s, ly - 8 * s, C(0x2A1A10))
                c.circle(lx, ly + 5 * s, 12 * s, C(0xFFC060, 0.12)); c.circle(lx, ly + 5 * s, 7 * s, C(0xFFC060, 0.10))
                c.rect(lx - 3 * s, ly, 7 * s, 2 * s, C(0xA8802A)); c.rect(lx - 3 * s, ly + 2 * s, 7 * s, 6 * s, C(0xF0B050))
                for x in [lx - 3 * s, lx, lx + 3 * s] { c.rect(x, ly + 2 * s, s, 6 * s, C(0x8A6420)) }
                c.rect(lx - 2 * s, ly + 8 * s, 5 * s, 2 * s, C(0xA8802A)); c.rect(lx, ly + 10 * s, s, 2 * s, C(0xA8802A))
            }
            // The loft: low bookcases and crates behind its railing.
            for (k, bx) in [c.w * 4 / 100, c.w * 40 / 100, c.w * 60 / 100].enumerated() {
                let bw = 46 * s, bt = loft - 24 * s
                c.rect(bx, bt, bw, 24 * s, woodD); c.rect(bx, bt, bw, s, woodL)
                for sy in [bt + 11 * s, bt + 22 * s] {
                    var x = bx + 2 * s, i = k * 30 + sy
                    while x < bx + bw - 4 * s {
                        let bh = (6 + Int(noise(i) * 3)) * s, bw2 = (2 + Int(noise(i + 1) * 2)) * s
                        c.rect(x, sy - bh, bw2, bh, [C(0x7A2A1E), C(0x2E5A3A), C(0x8A6A2E), C(0x4A2A5A)][Int(noise(i + 2) * 4) % 4])
                        x += bw2 + (noise(i + 3) > 0.8 ? 3 * s : 0); i += 4
                    }
                    c.rect(bx, sy, bw, s, wood)
                }
            }
            for bx in [c.w * 24 / 100, c.w * 82 / 100] {
                c.rect(bx, loft - 12 * s, 16 * s, 12 * s, C(0x7A5A34)); c.rect(bx, loft - 12 * s, 16 * s, s, C(0xA07A48))
                c.rect(bx + 4 * s, loft - 20 * s, 12 * s, 8 * s, C(0x6A4A2A)); c.rect(bx + 4 * s, loft - 20 * s, 12 * s, s, C(0x9A7040))
            }
            c.rect(0, loft, c.w, 6 * s, wood); c.rect(0, loft, c.w, s, woodL); c.rect(0, loft + 5 * s, c.w, s, woodD)
            c.rect(0, loft - 10 * s, c.w, 2 * s, woodL)
            for x in stride(from: 3 * s, to: c.w, by: 6 * s) { c.rect(x, loft - 8 * s, s, 8 * s, wood) }
            let lx = c.w * 3 / 100   // the ladder up to it
            c.rect(lx, loft - 10 * s, 2 * s, g - loft + 10 * s, C(0x7A5232)); c.rect(lx + 12 * s, loft - 10 * s, 2 * s, g - loft + 10 * s, C(0x7A5232))
            for y in stride(from: loft - 6 * s, to: g, by: 6 * s) { c.rect(lx, y, 14 * s, 2 * s, C(0x8A5E3A)) }
        }
        // The front window on the left: the night street, herbs hung across its top.
        let fw = (x: c.w * 4 / 100 + (f.loft == nil ? 0 : 18 * s), w: c.w * 11 / 100)
        let fy = shelfTop + 2 * s
        c.rect(fw.x - 3 * s, fy - 3 * s, fw.w + 6 * s, shelfBottom - fy + 3 * s, woodD)
        c.rect(fw.x, fy, fw.w, shelfBottom - fy, C(0x1C2A44)); c.rect(fw.x, shelfBottom - 8 * s, fw.w, 8 * s, C(0x24304A))
        c.rect(fw.x, shelfBottom - 3 * s, fw.w, 3 * s, woodL)
        for x in stride(from: fw.x, to: fw.x + fw.w, by: 3 * s) { c.rect(x, shelfBottom - 7 * s - Int(noise(x) * 6) * s, 2 * s, Int(noise(x) * 6) * s + 4 * s, C(0x101828)) }
        c.rect(fw.x + fw.w / 2, fy, s, shelfBottom - fy, woodD); c.rect(fw.x, fy + (shelfBottom - fy) / 2, fw.w, s, woodD)
        c.rect(fw.x, fy + 2 * s, fw.w, s, C(0x8A7A5A))
        for k in 0..<4 { c.rect(fw.x + (3 + k * 7) * s, fy + 3 * s, 3 * s, 6 * s, [C(0x4A6A3A), C(0x7A6A34), C(0x5A7A44), C(0x6A3A2A)][k]) }
        // The shelving units, plaster between them.
        let jar = [C(0x4A9A5A), C(0x4A72B8), C(0xD09A3A), C(0xB04040), C(0x7A52A0), C(0x9AB84A)]
        let units = f.loft == nil ? [(17, 31), (38, 52), (55, 66)] : [(19, 31), (38, 48)]
        for (u, unit) in units.enumerated() {
            let ux = c.w * unit.0 / 100, uw = c.w * unit.1 / 100 - ux
            guard uw > 10 * s else { continue }
            c.rect(ux, shelfTop, uw, shelfBottom - shelfTop, C(0x2E1A0E))
            for (row, y) in stride(from: shelfTop, to: shelfBottom - 8 * s, by: 12 * s).enumerated() {
                let sy = y + 10 * s
                var x = ux + 3 * s, i = u * 100 + row * 20
                while x < ux + uw - 6 * s {
                    let col = jar[Int(noise(i * 3 + 901) * 6) % 6]
                    switch Int(noise(i * 3 + 900) * 6) {
                    case 0, 1:
                        let h = (5 + Int(noise(i + 950) * 3)) * s
                        c.rect(x, sy - h, 5 * s, h, col); c.rect(x, sy - h - s, 5 * s, s, C(0x5A4430))
                        c.rect(x + s, sy - h + s, s, h - 2 * s, C(0xFFFFFF, 0.35)); x += 7 * s
                    case 2:
                        c.rect(x, sy - 6 * s, 3 * s, 6 * s, col); c.rect(x + s, sy - 8 * s, s, 2 * s, col); c.px(x, sy - 5 * s, C(0xFFFFFF, 0.5)); x += 5 * s
                    case 3:
                        c.rect(x, sy - 2 * s, 6 * s, 2 * s, C(0x8A6ACA)); c.rect(x + s, sy - 6 * s, 2 * s, 4 * s, C(0xB89AF0))
                        c.rect(x + 4 * s, sy - 4 * s, s, 2 * s, C(0x9ADCE8)); c.px(x + s, sy - 6 * s, C(0xFFFFFF, 0.8)); x += 8 * s
                    case 4:
                        for b in 0..<3 { c.rect(x + b * 2 * s, sy - (6 + b % 2) * s, 2 * s, (6 + b % 2) * s, [C(0x7A2A1E), C(0x2E5A3A), C(0x8A6A2E)][b]) }
                        x += 8 * s
                    default:
                        if noise(i + 960) > 0.5 {
                            c.rect(x, sy - 5 * s, 5 * s, 4 * s, C(0xE0D4B8)); c.rect(x + s, sy - s, 3 * s, s, C(0xC0B496))
                            c.rect(x + s, sy - 4 * s, s, s, C(0x2A1A10)); c.rect(x + 3 * s, sy - 4 * s, s, s, C(0x2A1A10))
                        } else {
                            c.rect(x + s, sy - 6 * s, 2 * s, 6 * s, C(0xE8D8B8)); c.rect(x, sy - s, 4 * s, s, C(0xC89A48))
                        }
                        x += 7 * s
                    }
                    i += 1
                }
                c.rect(ux, sy, uw, 2 * s, wood); c.rect(ux, sy, uw, s, woodL)
            }
            c.rect(ux - 2 * s, shelfTop - 2 * s, uw + 4 * s, 3 * s, wood); c.rect(ux - 2 * s, shelfTop - 2 * s, uw + 4 * s, s, woodL)
            c.rect(ux - 2 * s, shelfTop, 2 * s, shelfBottom - shelfTop, wood); c.rect(ux + uw, shelfTop, 2 * s, shelfBottom - shelfTop, woodD)
        }
        // Hung on the plaster between the units: a dreamcatcher and a mask.
        let dcx = c.w * 345 / 1000, dcy = shelfTop + 14 * s
        c.rect(dcx, shelfTop, s, 6 * s, C(0x8A7A5A))
        c.circle(dcx, dcy, 7 * s, C(0xC8A870)); c.circle(dcx, dcy, 6 * s, C(0x4A2C1C))
        for k in 0..<6 { let a = Double(k) / 6 * 2 * .pi; slayerLine(c, Double(dcx), Double(dcy), Double(dcx) + cos(a) * Double(6 * s), Double(dcy) + sin(a) * Double(6 * s), C(0xC8A870, 0.7), Double(s) * 0.3) }
        for k in 0..<3 { c.rect(dcx - 4 * s + k * 4 * s, dcy + 7 * s, s, 6 * s, C(0xC8A870)); c.rect(dcx - 4 * s + k * 4 * s, dcy + 12 * s, s, 3 * s, C(0xE8E0D0)) }
        let mx = c.w * 535 / 1000, my = shelfTop + 8 * s
        c.ellipse(mx, my + 6 * s, 5 * s, 7 * s, C(0x8A4A2A)); c.rect(mx - 3 * s, my + 3 * s, 2 * s, s, C(0x1A0A06)); c.rect(mx + 2 * s, my + 3 * s, 2 * s, s, C(0x1A0A06))
        c.rect(mx - 2 * s, my + 9 * s, 5 * s, s, C(0x1A0A06)); c.rect(mx - 5 * s, my - s, 11 * s, 2 * s, C(0xB84A2A))
        // Cubbyholes behind the counter.
        let ct = f.counter, cbt = f.loft.map { $0 + 30 * s } ?? 22 * s
        if shelfBottom - cbt > 14 * s {
            c.rect(ct.x + 4 * s, cbt, ct.w - 8 * s, shelfBottom - cbt, woodD)
            for (r, y) in stride(from: cbt, to: shelfBottom - 6 * s, by: 10 * s).enumerated() {
                for (k, x) in stride(from: ct.x + 4 * s, to: ct.x + ct.w - 12 * s, by: 12 * s).enumerated() {
                    c.rect(x + 2 * s, y + 2 * s, 10 * s, 8 * s, C(0x24140A))
                    let col = jar[(r * 3 + k) % 6]
                    if noise(r * 17 + k) > 0.3 { c.rect(x + 4 * s, y + 5 * s, 5 * s, 5 * s, col); c.rect(x + 5 * s, y + 6 * s, s, 3 * s, C(0xFFFFFF, 0.3)) }
                    c.rect(x, y, 12 * s, 2 * s, wood); c.rect(x, y, 2 * s, 10 * s, wood)
                }
            }
        }
        // The wainscot.
        c.rect(0, shelfBottom, c.w, g - shelfBottom, C(0x3A2216)); c.rect(0, shelfBottom, c.w, 2 * s, C(0x7A4A2C))
        for x in stride(from: 6 * s, to: c.w, by: 24 * s) { c.rect(x, shelfBottom + 5 * s, 18 * s, g - shelfBottom - 9 * s, C(0x2E1A10)); c.rect(x, shelfBottom + 5 * s, 18 * s, s, C(0x4A2C1C)) }
        // The back door, open on the training room (screen saver only). The punch bag swings in the moving layer.
        if let d = f.door {
            c.rect(d.x - 3 * s, d.top - 3 * s, d.w + 6 * s, g - d.top + 3 * s, C(0x6A4428))
            c.rect(d.x, d.top, d.w, g - d.top, C(0x3A4250)); c.rect(d.x, g - 8 * s, d.w, 8 * s, C(0x2A4A7A))
            c.rect(d.x, g - 8 * s, d.w, s, C(0x4A6A9A)); c.rect(d.x + 2 * s, d.top + 6 * s, 8 * s, 18 * s, C(0x5A6A7A))
            c.rect(d.x, d.top, d.w, 2 * s, C(0x2A303A))
            c.rect(d.x + d.w + 3 * s, d.top, 4 * s, g - d.top, C(0x4A2C1A))   // the door itself, swung back
        }
        // The sign.
        let sp = 2 * s, sw = slayerSignWidth("MAGIC BOX", sp)
        let sx = f.counter.x + (f.counter.w - sw) / 2, sy = f.loft.map { $0 + 10 * s } ?? 3 * s
        c.rect(sx - 4 * s, sy - 3 * s, sw + 8 * s, 5 * sp + 6 * s, C(0x16301E)); c.rect(sx - 4 * s, sy - 3 * s, sw + 8 * s, s, C(0x3A5A3A))
        c.rect(sx - 4 * s, sy + 5 * sp + 2 * s, sw + 8 * s, s, C(0x0C1A10))
        slayerSign(c, sx, sy, "MAGIC BOX", C(0xE8C058), sp)
        // The counter: a glass case, the brass till, the incense burner.
        let top = g - 16 * s
        c.rect(ct.x, top, ct.w, 3 * s, C(0x7A4A2A)); c.rect(ct.x, top, ct.w, s, C(0xA06A3E))
        c.rect(ct.x + s, top + 3 * s, ct.w - 2 * s, g - top - 3 * s, C(0x4A2C1A))
        c.rect(ct.x + 4 * s, top + 4 * s, ct.w - 8 * s, 8 * s, C(0x24302E)); c.rect(ct.x + 4 * s, top + 4 * s, ct.w - 8 * s, s, C(0x5A706A))
        for k in 0..<6 {
            let ix = ct.x + (8 + k * (ct.w / s - 16) / 6) * s
            c.rect(ix, top + 9 * s, 3 * s, 2 * s, jar[k % 6]); c.px(ix + s, top + 8 * s, C(0xB89AF0))
        }
        let tillX = ct.x + ct.w * 58 / 100
        c.rect(tillX, top - 9 * s, 16 * s, 9 * s, C(0xB8902A)); c.rect(tillX, top - 9 * s, 16 * s, s, C(0xE8C860))
        c.rect(tillX + 2 * s, top - 7 * s, 12 * s, 4 * s, C(0x8A6A1E))
        for kx in stride(from: tillX + 3 * s, to: tillX + 14 * s, by: 3 * s) { c.rect(kx, top - 6 * s, 2 * s, s, C(0xF0E0B0)); c.rect(kx, top - 4 * s, 2 * s, s, C(0xF0E0B0)) }
        c.rect(tillX + 4 * s, top - 13 * s, 8 * s, 4 * s, C(0xB8902A)); c.rect(tillX + 5 * s, top - 12 * s, 6 * s, 2 * s, C(0xF0E8D0))
        c.rect(tillX + 16 * s, top - 6 * s, 2 * s, 2 * s, C(0x8A6A1E))
        let ix = ct.x + 8 * s
        c.rect(ix - 2 * s, top - 2 * s, 5 * s, 2 * s, C(0xA8822A)); c.rect(ix - s, top - 3 * s, 3 * s, s, C(0xC8A048))
        slayerLine(c, Double(ix), Double(top - 3 * s), Double(ix + 2 * s), Double(top - 9 * s), C(0x5A3A2A), Double(s) * 0.4)
        // The round table: chairs behind it, books and a candle on it.
        let tx = f.table, tw = 30 * s, ty = g - 14 * s
        for cx in [tx - 18 * s, tx + 12 * s] {
            c.rect(cx, ty - 13 * s, 2 * s, 13 * s, C(0x8A5A34)); c.rect(cx + 6 * s, ty - 13 * s, 2 * s, 13 * s, C(0x8A5A34))
            for ry in [ty - 12 * s, ty - 8 * s, ty - 4 * s] { c.rect(cx, ry, 8 * s, s, C(0xA06A3E)) }
        }
        c.ellipse(tx, ty, tw, 3 * s, C(0xC8864A)); c.ellipse(tx, ty - s, tw - 2 * s, 2 * s, C(0xA86A3C))
        c.rect(tx - tw, ty, 2 * tw + 1, 2 * s, C(0x5A3620))
        c.rect(tx - 2 * s, ty + 2 * s, 4 * s, g - ty - 4 * s, C(0x4A2C1A)); c.rect(tx - 8 * s, g - 2 * s, 16 * s, 2 * s, C(0x4A2C1A))
        c.rect(tx - 16 * s, ty - 2 * s, 9 * s, 2 * s, C(0xE8DCC0)); c.rect(tx - 12 * s, ty - 2 * s, s, 2 * s, C(0xA89878))
        c.rect(tx + 6 * s, ty - 4 * s, 7 * s, 2 * s, C(0x6A2A1E)); c.rect(tx + 7 * s, ty - 6 * s, 6 * s, 2 * s, C(0x2E4A3A))
        slayerCandle(c, tx - s, ty - 2 * s, 4 * s, s, wide: true)
        // The crystal's string.
        let cr = f.crystal, stringTop = f.loft.map { $0 + 6 * s } ?? 0
        c.rect(cr.x, stringTop, s, cr.y - stringTop - 3 * s, C(0xA89878, 0.7))
        // Warm boards.
        c.ground(g, C(0x3E2618), edge: C(0x6A4428), speck: C(0x32200F), seed: 97)
        for x in stride(from: 0, to: c.w, by: 18 * s) { c.rect(x, g + s, s, c.h - g, C(0x2A180E)) }
    }

    /// The Magic Box's life: incense smoke curling up from the counter, the hanging crystal turning and catching the
    /// light, a glint running over the crystals on the shelves, the candle on the table, and (on the screen saver) the
    /// punch bag still swinging in the training room.
    static func slayerMagicBoxLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerMagicBoxFrame(c, g)
        // Incense.
        let ix = f.counter.x + 10 * s, iy = g - 25 * s
        for k in 0..<18 {
            let p = frac(t * 0.12 + Double(k) / 18)
            let y = iy - Int(p * Double(34 * s)), x = ix + Int(sin(p * 9 + t * 0.8) * Double(2 + Int(p * 5)) * Double(s))
            c.rect(x, y, s, s, C(0xD8D0E0, 0.45 * (1 - p)))
        }
        // The hanging crystal: a turning prism, a sparkle as a face catches the light.
        let cr = f.crystal, turn = Int(t * 1.5) % 4
        let widths = [3, 2, 1, 2]
        let w = widths[turn] * s
        c.rect(cr.x - w / 2, cr.y - 3 * s, max(s, w), 6 * s, C(0x9ADCE8)); c.rect(cr.x - s / 2, cr.y - 4 * s, s, 8 * s, C(0xC8F0F8))
        c.px(cr.x, cr.y + 4 * s, C(0x9ADCE8))
        let tw = frac(t * 0.4)
        if tw < 0.25 {
            let a = sin(tw / 0.25 * .pi)
            c.rect(cr.x - 3 * s, cr.y - s, 7 * s, s, C(0xFFFFFF, a)); c.rect(cr.x, cr.y - 4 * s, s, 7 * s, C(0xFFFFFF, a))
        }
        let gl = Int(t * 0.7)
        let gx = Int(noise(gl * 3 + 1) * Double(c.w)), gy = Int(noise(gl * 3 + 2) * Double(g - 30 * s)) + (f.loft.map { $0 } ?? 4 * s) / 2
        c.px(gx, gy, C(0xFFFFFF, 0.8 * sin(frac(t * 0.7) * .pi)))
        // The candle.
        slayerFlame(c, f.table - s, g - 21 * s, t, 1, s)
        // The punch bag.
        if let d = f.door {
            let sw = sin(t * 1.4) * 2.5
            let top = d.top + 2 * s, bx = d.x + d.w / 2 + Int(sw * Double(s))
            slayerLine(c, Double(d.x + d.w / 2), Double(top), Double(bx), Double(top + 8 * s), C(0x8A8E94), Double(s) * 0.5)
            c.rect(bx - 4 * s, top + 8 * s, 8 * s, 22 * s, C(0xA0282A)); c.rect(bx - 4 * s, top + 8 * s, 2 * s, 22 * s, C(0xC84A44))
            c.rect(bx - 4 * s, top + 8 * s, 8 * s, s, C(0x5A1418)); c.rect(bx - 4 * s, top + 29 * s, 8 * s, s, C(0x5A1418))
            c.rect(bx - 4 * s, top + 18 * s, 8 * s, s, C(0x6A1A1E))
        }
    }
}

// MARK: - Spyke's crypt

extension Scenes {
    /// Where things stand in the crypt: the doorway, the sarcophagus, the TV, the armchair, the candelabra, every
    /// candle's wick, and (on the screen saver) the hole with the ladder down.
    static func slayerCryptFrame(_ c: PixelCanvas, _ g: Int) -> (door: Int, sarc: Int, tv: Int, chair: Int, stand: Int,
                                                               wicks: [(x: Int, y: Int)], hole: Int?) {
        let s = unit(g), tall = isTall(c)
        let sarc = c.w * 24 / 100, stand = c.w * 84 / 100
        var wicks: [(x: Int, y: Int)] = []
        let st = g - 14 * s
        for (dx, h) in [(4, 4), (8, 6), (11, 3)] { wicks.append((sarc + dx * s, st - h * s - s)) }
        for dx in [-6, 0, 6] { wicks.append((stand + dx * s, g - (dx == 0 ? 37 : 33) * s)) }
        for nx in [c.w * 40 / 100, c.w * 74 / 100, c.w * 94 / 100] { wicks.append((nx + 3 * s, g - 32 * s)) }
        if tall { for nx in [c.w * 18 / 100, c.w * 50 / 100, c.w * 82 / 100] { wicks.append((nx + 3 * s, g - 74 * s)) } }
        return (c.w * 6 / 100, sarc, c.w * 49 / 100, c.w * 62 / 100, stand, wicks, tall ? c.w * 91 / 100 : nil)
    }

    /// Spyke's crypt: rough grey stone, a pointed doorway with its iron gate swung open on the moonlit graves outside,
    /// a stone sarcophagus he uses as a table with candles and a bottle on it, a little TV with rabbit ears on a crate,
    /// his worn red armchair, candles in wall niches and an iron candelabra. On the screen saver the stone vault
    /// overhead, more niches, cobwebs, and the hole in the floor with the ladder down to the lower level.
    static func slayerCrypt(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerCryptFrame(c, g)
        let tones = [C(0x343840), C(0x2E323A), C(0x3A3E46), C(0x2A2E34)]
        let wallTop = tall ? g - 112 * s : 0
        slayerBlocks(c, wallTop, g, s, tones: tones, mortar: C(0x16181E), light: C(0x464A54), seed: 210)
        for w in f.wicks { c.circle(w.x, w.y, 16 * s, C(0xFF9A40, 0.05)); c.circle(w.x, w.y, 9 * s, C(0xFF9A40, 0.06)) }
        if tall {
            // The vault: in each bay a lunette of wall under a pointed arch, a slit window in some, ribs springing
            // from pilasters that run down the wall.
            let bay = 120 * s, rise = wallTop * 80 / 100
            slayerBlocks(c, 0, wallTop, s, tones: [C(0x2A2E36), C(0x262A30), C(0x2E323A)], mortar: C(0x121418), light: C(0x363A44), seed: 260)
            c.rect(0, 0, c.w, wallTop - rise, C(0x000000, 0.55))
            for (i, bx) in stride(from: -bay / 2, to: c.w + bay, by: bay).enumerated() {
                func arc(_ k: Double, _ inset: Int) -> (x: Double, y: Double) {
                    let half = Double(bay / 2 - inset), a = k * .pi
                    // A pointed arch: two quarter-ellipses meeting at the apex.
                    let x = Double(bx) - cos(a) * half
                    let y = Double(wallTop) - pow(sin(a), 0.6) * Double(rise - inset)
                    return (x, y)
                }
                for y in (wallTop - rise)..<wallTop {
                    let k = Double(wallTop - y) / Double(rise), half = Int(Double(bay / 2 - 2 * s) * max(0, 1 - pow(k, 1 / 0.3)).squareRoot())
                    c.rect(bx - bay / 2, y, bay / 2 - half, 1, C(0x000000, 0.45)); c.rect(bx + half, y, bay / 2 - half, 1, C(0x000000, 0.45))
                }
                if i % 2 == 1 {
                    let sw = 6 * s, st = wallTop - rise / 2, sb = wallTop - 12 * s
                    c.rect(bx - sw / 2, st, sw, sb - st, C(0x18243A)); c.ellipse(bx, st, sw / 2, sw / 2, C(0x18243A))
                    c.rect(bx - sw / 2, st + (sb - st) / 3, sw, s, C(0x0A0C10))
                }
                for k in 0..<30 {
                    let p = arc(Double(k) / 30, 0), q = arc(Double(k + 1) / 30, 0)
                    slayerLine(c, p.x, p.y, q.x, q.y, C(0x4E5260), Double(s) * 1.4)
                    slayerLine(c, p.x, p.y + Double(s), q.x, q.y + Double(s), C(0x1A1C22), Double(s) * 0.5)
                }
                let px0 = bx - bay / 2
                c.rect(px0 - 5 * s, wallTop, 10 * s, g - wallTop, C(0x3A3E48)); c.rect(px0 - 5 * s, wallTop, 2 * s, g - wallTop, C(0x4E5260))
                c.rect(px0 + 3 * s, wallTop, 2 * s, g - wallTop, C(0x22262E))
                c.rect(px0 - 7 * s, wallTop - 4 * s, 14 * s, 5 * s, C(0x4E5260)); c.rect(px0 - 7 * s, wallTop + s, 14 * s, s, C(0x22262E))
            }
            c.rect(0, wallTop - rise - 2 * s, c.w, 3 * s, C(0x3A3E48))
            // Cobwebs in the corners.
            for (cx, dir) in [(0, 1), (c.w - 1, -1)] {
                for k in 0..<4 { slayerLine(c, Double(cx), Double(wallTop + k * 8 * s), Double(cx + dir * (32 - k * 6) * s), Double(wallTop), C(0xC8C8C0, 0.25), Double(s) * 0.4) }
            }
        }
        // Wall niches with candles in them.
        for w in f.wicks[6...] {
            let nx = w.x - 3 * s, ny = w.y - 6 * s
            c.rect(nx, ny + 3 * s, 8 * s, 10 * s, C(0x121410)); c.ellipse(nx + 4 * s, ny + 3 * s, 4 * s, 3 * s, C(0x121410))
            c.rect(nx - s, ny + 13 * s, 10 * s, 2 * s, C(0x4A4E44))
            slayerCandle(c, w.x, ny + 13 * s, 5 * s, s)
            c.rect(w.x + s, ny + 10 * s, s, 3 * s, C(0xE8DCC0))   // a wax drip
        }
        // The doorway: a pointed arch, the gate open, the graveyard outside under the moon.
        let dx = f.door, dw = 26 * s, dt = g - 42 * s
        for y in (dt - 3 * s)..<g {
            let k = Double(y - dt + 3 * s) / Double(16 * s)
            let half = k < 1 ? Int(Double(dw / 2 + 3 * s) * (1 - (1 - k) * (1 - k)).squareRoot()) : dw / 2 + 3 * s
            c.rect(dx + dw / 2 - half, y, 2 * half, 1, C(0x52564C))
        }
        for y in dt..<g {
            let k = Double(y - dt) / Double(14 * s)
            let half = k < 1 ? Int(Double(dw / 2) * (1 - (1 - k) * (1 - k)).squareRoot()) : dw / 2
            c.rect(dx + dw / 2 - half, y, 2 * half, 1, y < g - 14 * s ? C(0x101C2E) : C(0x0C1418))
        }
        c.circle(dx + dw / 2 + 5 * s, dt + 9 * s, 3 * s, C(0xD8E4D0))
        c.stars(dt + 4 * s, g - 16 * s, density: 30, seed: 9, x0: dx + 2 * s, x1: dx + dw - 2 * s)
        for (hx, hh) in [(4, 6), (11, 8), (19, 5)] {
            c.rect(dx + hx * s, g - 14 * s - hh * s, 4 * s, hh * s, C(0x2A3436)); c.rect(dx + hx * s, g - 14 * s - hh * s, 4 * s, s, C(0x3E4A4A))
        }
        c.rect(dx, g - 14 * s, dw, 14 * s, C(0x161A16))
        for k in 0..<3 { c.rect(dx - k * s, g - 14 * s + k * 5 * s, dw + 2 * k * s, s, C(0x3A3E36)) }
        for x in stride(from: dx + dw + 4 * s, to: dx + dw + 13 * s, by: 3 * s) { c.rect(x, dt + 6 * s, s, g - dt - 6 * s, C(0x1A1A1A)) }
        c.rect(dx + dw + 3 * s, dt + 6 * s, 11 * s, s, C(0x1A1A1A)); c.rect(dx + dw + 3 * s, g - 12 * s, 11 * s, s, C(0x1A1A1A))
        // The sarcophagus, with candles and a bottle on its lid.
        let sx = f.sarc, sw = 40 * s, st = g - 14 * s
        c.rect(sx, st + 3 * s, sw, g - st - 3 * s, C(0x4E5248)); c.rect(sx, st + 3 * s, s, g - st - 3 * s, C(0x6A6E62))
        c.rect(sx - 2 * s, st, sw + 4 * s, 3 * s, C(0x5E6256)); c.rect(sx - 2 * s, st, sw + 4 * s, s, C(0x7A7E70))
        c.rect(sx + 4 * s, st + 5 * s, sw - 8 * s, 6 * s, C(0x42463E))
        c.rect(sx + sw / 2 - s, st + 6 * s, 2 * s, 4 * s, C(0x6A6E62)); c.rect(sx + sw / 2 - 3 * s, st + 7 * s, 6 * s, s, C(0x6A6E62))
        for (i, h) in [4, 6, 3].enumerated() { slayerCandle(c, f.wicks[i].x, st, h * s, s) }
        c.rect(sx + 26 * s, st - 7 * s, 3 * s, 7 * s, C(0x6A3A12)); c.rect(sx + 27 * s, st - 9 * s, s, 2 * s, C(0x6A3A12))
        c.rect(sx + 26 * s, st - 5 * s, 3 * s, 2 * s, C(0xE8DCC0))
        c.rect(sx + 32 * s, st - 3 * s, 3 * s, 3 * s, C(0x9AA4A8, 0.8))   // a glass
        // The TV on its crate, rabbit ears up.
        let tx = f.tv
        c.rect(tx, g - 9 * s, 18 * s, 9 * s, C(0x5A4228))
        for y in [g - 9 * s, g - 5 * s] { c.rect(tx, y, 18 * s, s, C(0x7A5A36)) }
        c.rect(tx + s, g - 23 * s, 16 * s, 14 * s, C(0x2A2622)); c.rect(tx + s, g - 23 * s, 16 * s, s, C(0x4A443C))
        c.rect(tx + 2 * s, g - 21 * s, 11 * s, 10 * s, C(0x101818))
        c.rect(tx + 14 * s, g - 20 * s, 2 * s, 2 * s, C(0x8A8070)); c.rect(tx + 14 * s, g - 16 * s, 2 * s, 2 * s, C(0x8A8070))
        slayerLine(c, Double(tx + 8 * s), Double(g - 23 * s), Double(tx + 3 * s), Double(g - 33 * s), C(0x9A9A9A), Double(s) * 0.4)
        slayerLine(c, Double(tx + 9 * s), Double(g - 23 * s), Double(tx + 15 * s), Double(g - 32 * s), C(0x9A9A9A), Double(s) * 0.4)
        // The armchair: worn red, facing out.
        let ax = f.chair, aw = 26 * s, red = C(0x6A2620), redL = C(0x8A3A2E), redD = C(0x4A1A16)
        c.rect(ax + 4 * s, g - 28 * s, aw - 8 * s, 16 * s, red); c.ellipse(ax + aw / 2, g - 28 * s, aw / 2 - 4 * s, 3 * s, red)
        c.rect(ax + 5 * s, g - 30 * s, aw - 10 * s, s, redL)
        for x in [ax, ax + aw - 5 * s] { c.rect(x, g - 18 * s, 5 * s, 15 * s, red); c.rect(x, g - 18 * s, 5 * s, s, redL); c.rect(x + 4 * s, g - 17 * s, s, 14 * s, redD) }
        c.rect(ax + 5 * s, g - 12 * s, aw - 10 * s, 4 * s, redL); c.rect(ax + 5 * s, g - 8 * s, aw - 10 * s, 5 * s, redD)
        c.rect(ax + 9 * s, g - 22 * s, 4 * s, 3 * s, C(0x9A5A44))   // a worn patch
        c.rect(ax + 14 * s, g - 12 * s, 6 * s, 6 * s, C(0x3A4A3A)); c.rect(ax + 14 * s, g - 10 * s, 6 * s, s, C(0x6A2A1E))  // a tartan blanket
        for x in [ax + s, ax + aw - 3 * s] { c.rect(x, g - 3 * s, 2 * s, 3 * s, C(0x1A100C)) }
        // The candelabra.
        let cx = f.stand
        c.rect(cx, g - 33 * s, s, 33 * s, C(0x1A1A18)); c.rect(cx - 4 * s, g - s, 9 * s, s, C(0x1A1A18))
        c.rect(cx - 6 * s, g - 28 * s, 13 * s, s, C(0x1A1A18))
        for w in f.wicks[3...5] { c.rect(w.x - s, w.y + 4 * s, 3 * s, s, C(0x2A2A26)); slayerCandle(c, w.x, w.y + 4 * s + s, 3 * s, s) }
        for w in f.wicks[3...5] { c.rect(w.x, w.y + 5 * s, s, (g - 28 * s) - (w.y + 5 * s), C(0x1A1A18)) }
        // Flagstones, and the hole with the ladder down.
        c.ground(g, C(0x262822), edge: C(0x40443A), speck: C(0x1E201A), seed: 113)
        for x in stride(from: 0, to: c.w, by: 22 * s) { c.rect(x + (x / (22 * s)) % 2 * 5 * s, g + s, s, c.h - g, C(0x1A1C16)) }
        if let hx = f.hole {
            c.ellipse(hx + 8 * s, g + 4 * s, 12 * s, 3 * s, C(0x060604)); c.rect(hx - 4 * s, g + s, 24 * s, s, C(0x40443A))
            c.rect(hx + 2 * s, g - 14 * s, s, 20 * s, C(0x6A5232)); c.rect(hx + 13 * s, g - 14 * s, s, 20 * s, C(0x6A5232))
            for y in stride(from: g - 12 * s, to: g + 6 * s, by: 4 * s) { c.rect(hx + 2 * s, y, 12 * s, s, C(0x8A6A42)) }
        }
    }

    /// The crypt's life: the TV flickering through a soap opera (two heads, a cut, a close-up), its blue light
    /// washing the floor, and every candle guttering.
    static func slayerCryptLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerCryptFrame(c, g)
        let tx = f.tv + 2 * s, ty = g - 21 * s
        let shot = Int(t / 2.3) % 3, n = noise(Int(t * 8) + 7)
        let bgs = [C(0x6A4A6A), C(0x4A6A8A), C(0x8A5A4A)]
        c.rect(tx, ty, 11 * s, 10 * s, bgs[shot])
        let skin = C(0xE0B090)
        switch shot {
        case 0:   // two heads, facing
            c.rect(tx + 2 * s, ty + 3 * s, 3 * s, 4 * s, skin); c.rect(tx + 2 * s, ty + 2 * s, 3 * s, 2 * s, C(0xE8C860))
            c.rect(tx + 7 * s, ty + 3 * s, 3 * s, 4 * s, skin); c.rect(tx + 7 * s, ty + 2 * s, 3 * s, 2 * s, C(0x3A2018))
            c.rect(tx + s, ty + 7 * s, 9 * s, 3 * s, C(0x2A2A4A))
        case 1:   // a close-up
            c.rect(tx + 3 * s, ty + 2 * s, 5 * s, 7 * s, skin); c.rect(tx + 3 * s, ty + s, 5 * s, 2 * s, C(0xE8C860))
            c.px(tx + 4 * s, ty + 4 * s, C(0x2A1A10)); c.px(tx + 6 * s, ty + 4 * s, C(0x2A1A10))
        default:  // a dramatic look
            c.rect(tx + 4 * s, ty + 2 * s, 4 * s, 6 * s, skin); c.rect(tx + 4 * s, ty + s, 4 * s, 2 * s, C(0x3A2018))
            c.rect(tx + 2 * s, ty + 8 * s, 8 * s, 2 * s, C(0x6A1A2A))
        }
        c.rect(tx, ty, 11 * s, 10 * s, C(0xFFFFFF, 0.08 + 0.12 * n))
        c.rect(tx, ty + Int(frac(t * 0.7) * 10) * s, 11 * s, s, C(0xFFFFFF, 0.15))
        c.ellipse(tx + 5 * s, g + 4 * s, 26 * s, 4 * s, C(0x8AB0E8, 0.05 + 0.06 * n))
        c.ellipse(tx + 5 * s, ty + 5 * s, 14 * s, 12 * s, C(0x8AB0E8, 0.04 + 0.05 * n))
        for (k, w) in f.wicks.enumerated() { slayerFlame(c, w.x, w.y, t, k, s) }
    }
}

// MARK: - The sunken church

extension Scenes {
    /// Where things stand in the sunken church: the pool, the window behind it, the pillars, every candle's wick,
    /// the drips' sources, and (on the screen saver) the vault's springing line and the bell tower.
    static func slayerChurchFrame(_ c: PixelCanvas, _ g: Int) -> (pool: (x: Int, w: Int), pillars: [Int], wicks: [(x: Int, y: Int)],
                                                                ceiling: Int, tower: (x: Int, w: Int)?) {
        let s = unit(g), tall = isTall(c)
        let pw = 76 * s, px = c.w / 2 - pw / 2
        var wicks: [(x: Int, y: Int)] = []
        for dx in stride(from: 4, to: 76, by: 9) where dx < 30 || dx > 46 { wicks.append((px + dx * s, g - 12 * s - Int(noise(dx) * 3) * s)) }
        for sx in [px - 12 * s, px + pw + 10 * s] { for dx in [-5, 0, 5] { wicks.append((sx + dx * s, g - (dx == 0 ? 37 : 33) * s)) } }
        let pillars = [c.w * 8 / 100, c.w * 27 / 100, c.w * 71 / 100, c.w * 90 / 100]
        return ((px, pw), pillars, wicks, tall ? g - 126 * s : 7 * s, tall ? (c.w / 2 - 26 * s, 52 * s) : nil)
    }

    /// How far right the sunken church has tilted at row `y`.
    static func slayerChurchTilt(_ g: Int, _ y: Int) -> Int { (g - y) / 13 }

    /// The Old Master's sunken church: a church swallowed by an earthquake, everything leaning. Olive stone gloom,
    /// tilted gothic pillars (one snapped off), a pointed window whose stained glass is mostly gone and packed with
    /// earth behind, broken pews, two iron candelabras and a row of candles along the rim of the Master's pool, its
    /// surface dark crimson. Earth and roots hang from the broken roof. On the screen saver the ribbed vault, and
    /// above it, buried in the earth, the church's bell tower with the bell still hanging in it.
    static func slayerSunkenChurch(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerChurchFrame(c, g)
        let stone = C(0x3A3E2C), stoneL = C(0x565A40), stoneD = C(0x24281A)
        c.gradient(0, g, C(0x0E1008), C(0x2A2C1C), bands: 6)
        // Big faint courses on the back wall, leaning with everything else.
        for y in stride(from: f.ceiling, to: g, by: 10 * s) {
            c.rect(0, y, c.w, s, C(0x1A1C10, 0.6))
            for x in stride(from: (y / (10 * s)) % 2 * 18 * s, to: c.w, by: 36 * s) { c.rect(x + slayerChurchTilt(g, y), y, s, 10 * s, C(0x1A1C10, 0.5)) }
        }
        // The window behind the pool: pointed, glass mostly gone, earth packed behind.
        let wx = c.w / 2, ww = (tall ? 46 : 36) * s, wb = g - 22 * s, wt = tall ? g - 104 * s : max(f.ceiling + 2 * s, g - 60 * s)
        let archH = ww * 7 / 10
        for y in (wt - 3 * s)..<(wb + 3 * s) {
            let k = Double(y - wt + 3 * s) / Double(archH + 3 * s)
            let half = k < 1 ? Int(Double(ww / 2 + 3 * s) * (1 - (1 - k) * (1 - k)).squareRoot()) : ww / 2 + 3 * s
            c.rect(wx - half + slayerChurchTilt(g, y), y, 2 * half, 1, stoneL)
        }
        for y in wt..<wb {
            let k = Double(y - wt) / Double(archH)
            let half = k < 1 ? Int(Double(ww / 2) * (1 - (1 - k) * (1 - k)).squareRoot()) : ww / 2
            let tl = slayerChurchTilt(g, y)
            c.rect(wx - half + tl, y, 2 * half, 1, C(0x3A2A18))
            for x in (wx - half)..<(wx + half) where noise(x * 7 + y * 131) > 0.93 { c.px(x + tl, y, C(0x5A4428)) }
            if half > 3 * s {
                let glass = [C(0x7A2A2A), C(0x2A4A7A), C(0xA8802A)]
                if (y / (3 * s)) % 3 != 1 { c.rect(wx - half + tl, y, 2 * s, 1, glass[(y / (4 * s)) % 3].alpha(0.8)) }
                if (y / (3 * s)) % 4 == 0 { c.rect(wx + half - 2 * s + tl, y, 2 * s, 1, glass[(y / (5 * s) + 1) % 3].alpha(0.8)) }
            }
            c.px(wx + tl, y, stoneL); c.px(wx + tl + s - 1, y, stoneL)
        }
        let rose = wt + archH / 2
        c.circle(wx + slayerChurchTilt(g, rose), rose, ww / 5, stoneL); c.circle(wx + slayerChurchTilt(g, rose), rose, ww / 5 - s, C(0x7A2A2A, 0.85))
        c.circle(wx + slayerChurchTilt(g, rose), rose, ww / 10, C(0xA8802A, 0.85))
        // The pillars, leaning; the third one snapped off.
        let capital = tall ? f.ceiling + 8 * s : -1
        for (i, px) in f.pillars.enumerated() {
            let top = i == 2 ? g - 44 * s : (tall ? capital : 0)
            for y in top..<g {
                let x = px + slayerChurchTilt(g, y)
                c.rect(x, y, 12 * s, 1, stone); c.rect(x, y, 2 * s, 1, stoneL); c.rect(x + 9 * s, y, 3 * s, 1, stoneD)
                c.rect(x + 5 * s, y, s, 1, stoneD)
            }
            if i == 2 {   // the jagged break
                for k in 0..<6 { c.rect(px + slayerChurchTilt(g, top) + k * 2 * s, top - Int(noise(k + 77) * 4) * s, 2 * s, 4 * s, stone) }
            }
            if tall && i != 2 {
                let x = px + slayerChurchTilt(g, capital)
                c.rect(x - 3 * s, capital - 4 * s, 18 * s, 4 * s, stoneL); c.rect(x - 2 * s, capital, 16 * s, 3 * s, stone)
            }
            c.rect(px - 2 * s, g - 4 * s, 16 * s, 4 * s, stone); c.rect(px - 2 * s, g - 4 * s, 16 * s, s, stoneL)
            for k in 0..<3 { c.px(px + (3 + k * 2) * s + slayerChurchTilt(g, g - 20 * s - k * 9 * s), g - 20 * s - k * 9 * s, stoneD) }
        }
        // The vault (screen saver), the buried tower above it, or in the window the broken roof with earth and roots.
        if tall, let tw = f.tower {
            let cl = f.ceiling
            c.gradient(0, cl, C(0x1E160C), C(0x2A2014), bands: 5)
            // Packed earth: wavy strata, buried stones, roots.
            for (j, y) in stride(from: 4 * s, to: cl, by: 7 * s).enumerated() {
                for x in stride(from: 0, to: c.w, by: 2 * s) {
                    let yy = y + Int(sin(Double(x) * 0.025 / Double(s) + Double(j) * 1.7) * Double(2 * s))
                    c.rect(x, yy, 2 * s, s, j % 2 == 0 ? C(0x3A2C1A) : C(0x1A120A))
                }
            }
            for i in 0..<(c.w * cl / (700 * s * s)) {
                let x = Int(noise(i * 3 + 400) * Double(c.w)), y = Int(noise(i * 3 + 401) * Double(cl))
                let r = (2 + Int(noise(i * 3 + 402) * 4)) * s
                c.ellipse(x, y, r, r * 2 / 3, C(0x4A4636)); c.ellipse(x - r / 3, y - r / 3, r / 2, r / 3, C(0x5E5A46))
            }
            for k in 0..<10 {
                var x = Double(noise(k + 430) * Double(c.w)), y = 0.0
                let len = Double(cl) * (0.4 + noise(k + 440) * 0.6)
                while y < len {
                    let nx = x + (noise(Int(y) + k * 77) - 0.5) * Double(6 * s)
                    slayerLine(c, x, y, nx, y + Double(6 * s), C(0x4A3622), Double(s) * (1.2 - y / len * 0.7))
                    x = nx; y += Double(6 * s)
                }
            }
            // The tower's shaft, the bell hanging in it.
            c.rect(tw.x - 6 * s, 0, tw.w + 12 * s, cl, stoneD)
            c.rect(tw.x, 0, tw.w, cl, C(0x0C0C08))
            for y in stride(from: 0, to: cl, by: 8 * s) {
                c.rect(tw.x - 6 * s, y, 6 * s, s, C(0x14160C)); c.rect(tw.x + tw.w, y, 6 * s, s, C(0x14160C))
            }
            c.rect(tw.x - 6 * s, 0, 2 * s, cl, stone); c.rect(tw.x + tw.w + 4 * s, 0, 2 * s, cl, stone)
            let beam = cl * 25 / 100, bx = tw.x + tw.w / 2
            c.rect(tw.x, beam, tw.w, 4 * s, C(0x3A2416)); c.rect(tw.x, beam, tw.w, s, C(0x5A3A22))
            c.rect(bx - s, beam + 4 * s, 2 * s, 4 * s, C(0x2A2A20))
            let bt = beam + 8 * s, bh = 28 * s
            for y in bt..<(bt + bh) {
                let k = Double(y - bt) / Double(bh)
                let half = Int((5 + 9 * k * k + (k > 0.85 ? 3 : 0)) * Double(s))
                c.rect(bx - half, y, 2 * half, 1, C(0x6A5A2A)); c.rect(bx - half, y, max(1, half / 3), 1, C(0x9A8040))
                c.rect(bx + half - s, y, s, 1, C(0x3A3014))
            }
            c.rect(bx - s, bt + bh, 2 * s, 3 * s, C(0x3A3014))
            slayerLine(c, Double(bx + 2 * s), Double(bt + bh), Double(bx + 5 * s), Double(cl + 6 * s), C(0x8A7A5A), Double(s) * 0.5)
            // The vault's broken ribs, leaning, the wall closing up under each one (but not where the tower broke in).
            let span = f.pillars[1] - f.pillars[0]
            let posts = [f.pillars[0] - span] + f.pillars + [f.pillars[3] + span]
            for (i, px) in posts.enumerated() where i < posts.count - 1 {
                let nx = posts[i + 1], mid = i == 2
                let x0 = px + 6 * s, x1 = nx + 6 * s
                func rib(_ k: Int) -> (x: Double, y: Double) {
                    let a = Double(k) / 24 * .pi
                    let y = Double(capital - 4 * s) - sin(a) * Double(30 * s)
                    return (Double(x0 + x1) / 2 - cos(a) * Double(x1 - x0) / 2 + Double(slayerChurchTilt(g, Int(y))), y)
                }
                for k in 0..<24 {
                    let p = rib(k), q = rib(k + 1)
                    let open = mid && Int(p.x) > tw.x - 8 * s && Int(p.x) < tw.x + tw.w + 8 * s
                    if !open { c.rect(Int(min(p.x, q.x)), Int(min(p.y, q.y)), Int(abs(q.x - p.x)) + s, cl - Int(min(p.y, q.y)), C(0x16180E)) }
                }
                for k in 0..<24 where !(mid && k > 8 && k < 15) {   // the middle rib broken where the tower came through
                    let p = rib(k), q = rib(k + 1)
                    slayerLine(c, p.x, p.y, q.x, q.y, stoneL, Double(s) * 1.5)
                    slayerLine(c, p.x, p.y + Double(2 * s), q.x, q.y + Double(2 * s), stoneD, Double(s) * 0.5)
                }
            }
            c.rect(0, cl - 2 * s, c.w, 2 * s, C(0x14100A))
        } else {
            for x in 0..<c.w {
                let h = f.ceiling + Int((sin(Double(x) * 0.05) + noise(x / (3 * s) + 444)) * Double(3 * s))
                c.rect(x, 0, 1, max(0, h), C(0x2A2014))
            }
        }
        // Roots hanging down through the roof.
        for k in 0..<9 {
            let rx = Int(noise(k * 3 + 470) * Double(c.w)), len = (6 + Int(noise(k * 3 + 471) * 12)) * s
            let ry = f.ceiling - s
            for y in 0..<len { c.px(rx + Int(sin(Double(y) / Double(3 * s) + Double(k)) * Double(s)), ry + y, C(0x4A3622)) }
        }
        // Broken pews.
        let wood = C(0x3A2416), woodL = C(0x5A3A22)
        for (x0, x1, broken) in [(c.w * 12 / 100, c.w * 25 / 100, false), (c.w * 75 / 100, c.w * 88 / 100, true)] {
            for (d, dy) in [(0, 0), (6 * s, 3 * s)] {
                let a = x0 + d, b = x1 + d
                c.rect(a, g - 17 * s + dy, b - a, 3 * s, wood); c.rect(a, g - 17 * s + dy, b - a, s, woodL)
                c.rect(a, g - 9 * s + dy, b - a, 2 * s, wood)
                for lx in [a, b - 2 * s] { c.rect(lx, g - 18 * s + dy, 2 * s, 18 * s - dy, C(0x2A180E)) }
            }
            if broken {
                c.rect(x0 + (x1 - x0) / 2, g - 17 * s, 10 * s, 3 * s, C(0x22241A))
                slayerLine(c, Double(x0 + (x1 - x0) / 2), Double(g - 15 * s), Double(x0 + (x1 - x0) / 2 + 12 * s), Double(g - 2 * s), woodL, Double(s) * 0.9)
            }
        }
        for w in f.wicks { c.circle(w.x, w.y, 14 * s, C(0xFFB040, 0.04)) }
        // The candelabras either side of the pool.
        for i in 0..<2 {
            let cx = f.wicks[f.wicks.count - 6 + i * 3 + 1].x
            c.rect(cx, g - 32 * s, s, 32 * s, C(0x14140E)); c.rect(cx - 4 * s, g - s, 9 * s, s, C(0x14140E))
            c.rect(cx - 5 * s, g - 28 * s, 11 * s, s, C(0x14140E))
            for k in 0..<3 {
                let w = f.wicks[f.wicks.count - 6 + i * 3 + k]
                c.rect(w.x, w.y + 5 * s, s, (g - 28 * s) - (w.y + 5 * s), C(0x14140E)); slayerCandle(c, w.x, w.y + 5 * s, 4 * s, s)
            }
        }
        // The Master's pool: a stone rim, the dark crimson surface, candles on the back rim.
        let p = f.pool
        c.rect(p.x - 4 * s, g - 10 * s, p.w + 8 * s, 3 * s, stone); c.rect(p.x - 4 * s, g - 10 * s, p.w + 8 * s, s, stoneL)
        c.rect(p.x, g - 7 * s, p.w, 5 * s, C(0x2E060A)); c.rect(p.x, g - 7 * s, p.w, s, C(0x14040A))
        for k in 0..<5 { c.rect(p.x + (6 + k * 14) * s, g - 5 * s + (k % 2) * s, 8 * s, s, C(0x5A1420)) }
        c.rect(p.x - 4 * s, g - 2 * s, p.w + 8 * s, 2 * s, stoneL)
        for w in f.wicks.prefix(f.wicks.count - 6) { slayerCandle(c, w.x, g - 10 * s, (g - 10 * s) - w.y - s, s) }
        // Rubble at the pillars' feet, then the flagstones.
        c.ground(g, C(0x24261A), edge: C(0x3E4230), speck: C(0x1A1C12), seed: 127)
        for x in stride(from: 0, to: c.w, by: 26 * s) { c.rect(x, g + s, s, c.h - g, C(0x181A10)) }
        for k in 0..<10 {
            let rx = f.pillars[k % 4] + Int((noise(k + 500) - 0.3) * 30) * s
            c.rect(rx, g - 2 * s, (2 + Int(noise(k + 510) * 3)) * s, 2 * s, k % 2 == 0 ? stoneL : stone)
        }
    }

    /// The sunken church's life: candle flames, and water dripping from the roots into the pool, each drop landing in
    /// a little ring of ripples.
    static func slayerSunkenChurchLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerChurchFrame(c, g)
        for (k, w) in f.wicks.enumerated() { slayerFlame(c, w.x, w.y, t, k + 40, s, halo: 0.1) }
        let surface = g - 6 * s, top = f.ceiling
        for k in 0..<3 {
            let period = 2.6 + Double(k) * 0.7, p = frac(t / period + noise(k + 600))
            let x = f.pool.x + f.pool.w * (22 + k * 27) / 100
            if p < 0.6 {
                let q = p / 0.6, y = top + Int(q * q * Double(surface - top))
                c.rect(x, y, s, 2 * s, C(0x9AB0B0, 0.75))
            } else {
                let r = Int((p - 0.6) / 0.4 * 6) * s + s, a = 0.6 * (1 - (p - 0.6) / 0.4)
                c.rect(x - r, surface, s, s, C(0xC85A6A, a)); c.rect(x + r, surface, s, s, C(0xC85A6A, a))
                c.rect(x - r / 2, surface - s, r, s, C(0xC85A6A, a * 0.5))
            }
        }
    }
}

// MARK: - The Hellmouth

extension Scenes {
    /// Where things stand at the Hellmouth: the cracks in the cavern wall (as runs of points), the seal, the stairs up
    /// to the school, and (on the screen saver) the rim of the drop.
    static func slayerHellmouthFrame(_ c: PixelCanvas, _ g: Int) -> (cracks: [[(x: Int, y: Int)]], seal: Int, stairs: Int, rim: Int?) {
        let s = unit(g), tall = isTall(c)
        let rim: Int? = tall ? g - 96 * s : nil
        var cracks: [[(x: Int, y: Int)]] = []
        let bottom = rim ?? g, n = max(3, c.w / (110 * s))
        for k in 0..<n {
            var x = Int((Double(k) + 0.15 + noise(k + 700) * 0.7) / Double(n) * Double(c.w))
            var y = bottom - Int(noise(k + 710) * 3) * s
            var dir = (noise(k + 715) - 0.5) * 1.4                          // radians off straight up
            let len = tall ? 14 + Int(noise(k + 720) * 10) : 7 + Int(noise(k + 720) * 5)
            var run: [(x: Int, y: Int)] = [(x, y)]
            for i in 0..<len {
                dir = max(-1.2, min(1.2, dir + (noise(k * 40 + i + 730) - 0.5) * 1.6))
                let step = Double((4 + Int(noise(k * 40 + i + 760) * 4)) * s)
                x += Int(sin(dir) * step); y -= Int(cos(dir) * step)
                run.append((x, y))
                if i > 1, i < len - 2, noise(k * 40 + i + 790) > 0.78 {        // a branch splitting off
                    var bx = x, by = y, bd = dir + (noise(k * 40 + i + 800) > 0.5 ? 1 : -1) * (0.7 + noise(k * 40 + i + 810) * 0.6)
                    var branch: [(x: Int, y: Int)] = [(x, y)]
                    for j in 0..<(3 + Int(noise(k * 40 + i + 820) * 3)) {
                        bd += (noise(k * 50 + i * 7 + j + 830) - 0.5) * 0.8
                        bx += Int(sin(bd) * Double(4 * s)); by -= Int(cos(bd) * Double(4 * s))
                        branch.append((bx, by))
                    }
                    cracks.append(branch)
                }
            }
            cracks.append(run)
        }
        return (cracks, c.w / 2, c.w * 16 / 100, rim)
    }

    /// The Hellmouth: the cavern under Sunnydale High. Black-red rock with stalactites, cracks in the walls glowing
    /// from below, boulders, a stone stair climbing up to a door into the school's basement, and the Seal of Danthazar
    /// set in the floor. On the screen saver the school's foundations and pipes in the roof, and the floor breaks off
    /// into a long drop, the red light coming up out of it.
    static func slayerHellmouth(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerHellmouthFrame(c, g)
        let rock = C(0x2A0E0A), rockL = C(0x4A1A12), rockD = C(0x140606)
        c.gradient(0, g, C(0x0A0404), C(0x2E0C08), bands: tall ? 8 : 5)
        // Strata and lumps in the rock.
        let wallBottom = f.rim ?? g
        for i in 0..<(c.w * wallBottom / (120 * s)) {
            let x = Int(noise(i * 4 + 800) * Double(c.w)), y = Int(noise(i * 4 + 801) * Double(wallBottom))
            let len = (4 + Int(noise(i * 4 + 802) * 14)) * s
            c.rect(x, y, len, s, noise(i * 4 + 803) > 0.5 ? rockL.alpha(0.5) : rockD.alpha(0.7))
        }
        var top = 0
        if tall {
            // The school's foundations: concrete and brick, pipes along them, a broken hole into the basement.
            top = 30 * s
            c.rect(0, 0, c.w, top, C(0x3A3230))
            for y in stride(from: 0, to: top - 8 * s, by: 4 * s) {
                c.rect(0, y, c.w, s, C(0x2A2220))
                for x in stride(from: (y / (4 * s)) % 2 * 6 * s, to: c.w, by: 12 * s) { c.rect(x, y, s, 4 * s, C(0x2A2220)) }
            }
            c.rect(0, top - 8 * s, c.w, 8 * s, C(0x4A4440)); c.rect(0, top - 8 * s, c.w, s, C(0x6A625C))
            for (py, col) in [(top - 14 * s, C(0x6A5A4A)), (top - 20 * s, C(0x5A6066))] {
                c.rect(0, py, c.w, 4 * s, col); c.rect(0, py, c.w, s, col.alpha(0.6))
                for x in stride(from: 30 * s, to: c.w, by: 90 * s) { c.rect(x, py - s, 3 * s, 6 * s, C(0x3A3430)) }
            }
            for x in 0..<c.w {
                let h = Int((noise(x / (4 * s) + 850) * 6 + 2) * Double(s))
                c.rect(x, top, 1, h, C(0x2A2220))
            }
            top += 6 * s
        }
        if let rim = f.rim {   // two great columns where stalactite and stalagmite have grown together
            for cx in [c.w * 41 / 100, c.w * 93 / 100] {
                for y in top..<rim {
                    let k = Double(y - top) / Double(rim - top), waist = abs(k - 0.55)
                    let half = Int((3 + waist * waist * 60) * Double(s))
                    c.rect(cx - half, y, 2 * half, 1, rock); c.rect(cx - half, y, s, 1, rockL); c.rect(cx + half - 2 * s, y, 2 * s, 1, rockD)
                    if (y / (5 * s)) % 3 == 0 { c.rect(cx - half + 2 * s, y, half, 1, rockD.alpha(0.5)) }
                }
            }
        }
        // Stalactites.
        for k in 0..<(c.w / (18 * s)) {
            let x = Int(noise(k * 3 + 870) * Double(c.w)), w = (4 + Int(noise(k * 3 + 871) * 8)) * s
            let len = (tall ? 14 + Int(noise(k * 3 + 872) * 30) : 6 + Int(noise(k * 3 + 872) * 14)) * s
            for y in 0..<len {
                let half = max(0, w / 2 - w / 2 * y / len)
                c.rect(x - half, top + y, 2 * half + 1, 1, rock); c.px(x - half, top + y, rockL)
            }
        }
        // The cracks, dark with a dull red edge (the moving layer makes them glow).
        for run in f.cracks {
            for (i, (a, b)) in zip(run, run.dropFirst()).enumerated() {
                let w = Double(s) * (1.3 - 0.7 * Double(i) / Double(run.count))
                slayerLine(c, Double(a.x), Double(a.y), Double(b.x), Double(b.y), C(0x6A1408), w)
                slayerLine(c, Double(a.x), Double(a.y), Double(b.x), Double(b.y), C(0x0A0000), w * 0.45)
            }
        }
        if let rim = f.rim {
            // The drop: the far wall falling away, redder and redder with depth.
            c.gradient(rim, g, C(0x1A0606), C(0x6A1408), bands: 8)
            for i in 0..<(c.w / (6 * s)) {
                let x = Int(noise(i * 2 + 900) * Double(c.w)), y = rim + Int(noise(i * 2 + 901) * Double(g - rim))
                c.rect(x, y, s, (6 + Int(noise(i + 902) * 14)) * s, C(0x140404, 0.6))
            }
            for k in 0..<(c.w / (34 * s)) {                                  // rock spires rising out of the depths
                let x = Int(noise(k * 3 + 930) * Double(c.w)), w = (8 + Int(noise(k * 3 + 931) * 14)) * s
                let top = rim + Int((0.2 + noise(k * 3 + 932) * 0.6) * Double(g - rim))
                for y in top..<g {
                    let half = w / 2 * (y - top) / max(1, g - top) + s
                    c.rect(x - half, y, 2 * half, 1, C(0x160404)); c.px(x - half, y, C(0x8A2010))
                }
            }
            for x in 0..<c.w {                                                  // the far rim's ragged lip
                let h = Int((noise(x / (3 * s) + 920) * 5 + 1) * Double(s))
                c.rect(x, rim, 1, h, rockD); c.px(x, rim, rockL)
            }
            // The rock shelf on the left where the stairs come down.
            let shelf = c.w * 24 / 100
            for y in rim..<g {
                let edge = shelf + Int(sin(Double(y) * 0.11) * Double(4 * s)) + Int(noise(y / (2 * s) + 940) * Double(3 * s))
                c.rect(0, y, edge, 1, rock); c.rect(edge - s, y, s, 1, rockL)
            }
        } else {
            for y in (g - 22 * s)..<g { c.rect(0, y, c.w, 1, C(0xFF2A10, 0.10 * Double(y - g + 22 * s) / Double(22 * s))) }
        }
        // Boulders on the right.
        for (bx, br) in [(c.w * 86 / 100, 9), (c.w * 93 / 100, 6), (c.w * 79 / 100, 5)] {
            c.ellipse(bx, g - br * s / 2, br * s, br * s * 2 / 3, rock); c.ellipse(bx - br * s / 3, g - br * s * 3 / 4, br * s / 2, br * s / 4, rockL)
        }
        // The stairs up to the school's basement door.
        let sx = f.stairs
        let steps = 7
        for k in 0..<steps {
            let x = sx - (k + 1) * 6 * s, y = g - (k + 1) * 5 * s
            c.rect(x, y, sx - x, 5 * s, C(0x4A3A34)); c.rect(x, y, sx - x, s, C(0x6A5A50)); c.rect(sx - 2 * s, y, 2 * s, 5 * s, C(0x2A201C))
        }
        let dy = g - steps * 5 * s, dxx = sx - steps * 6 * s - 4 * s
        c.rect(dxx - 2 * s, dy - 22 * s, 18 * s, 22 * s, C(0x3A3230))
        c.rect(dxx, dy - 20 * s, 14 * s, 20 * s, C(0xC8A860)); c.rect(dxx, dy - 20 * s, 14 * s, 8 * s, C(0xE0C880))
        c.rect(dxx + 10 * s, dy - 20 * s, 4 * s, 20 * s, C(0x5A4A30))
        c.ellipse(dxx + 7 * s, dy - 4 * s, 12 * s, 4 * s, C(0xE0C880, 0.08))
        // The floor, and the Seal of Danthazar set in it.
        c.ground(g, C(0x24100C), edge: C(0x4A2016), speck: C(0x1A0806), seed: 131)
        let sl = f.seal
        c.ellipse(sl, g + 5 * s, 46 * s, 5 * s, C(0x3A2A24)); c.ellipse(sl, g + 5 * s, 44 * s, 4 * s, C(0x4A3830))
        c.ellipse(sl, g + 5 * s, 34 * s, 3 * s, C(0x2A1C18)); c.ellipse(sl, g + 5 * s, 32 * s, 2 * s, C(0x4A3830))
        c.ellipse(sl, g + 5 * s, 10 * s, 2 * s, C(0x2A1C18)); c.ellipse(sl, g + 5 * s, 6 * s, s, C(0x5A1A10))
        for k in 0..<8 {
            let a = Double(k) / 8 * 2 * .pi
            c.rect(sl + Int(cos(a) * Double(39 * s)), g + 5 * s + Int(sin(a) * Double(4 * s)), 2 * s, s, C(0x2A1C18))
        }
    }

    /// The Hellmouth's life: the cracks pulsing red, the seal's carvings answering, embers drifting up, and (on the
    /// screen saver) eyes opening and closing far down the drop.
    static func slayerHellmouthLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerHellmouthFrame(c, g)
        for (k, run) in f.cracks.enumerated() {
            let a = 0.35 + 0.45 * (0.5 + 0.5 * sin(t * 1.6 + Double(k) * 1.3))
            for (i, (p, q)) in zip(run, run.dropFirst()).enumerated() {
                let fade = a * (1 - Double(i) / Double(run.count))
                slayerLine(c, Double(p.x), Double(p.y), Double(q.x), Double(q.y), C(0xFF5A1A, fade), Double(s) * 0.45)
            }
            if let first = run.first { c.circle(first.x, first.y, 3 * s, C(0xFF3A10, a * 0.25)) }
        }
        let pulse = 0.5 + 0.5 * sin(t * 1.1)
        c.ellipse(f.seal, g + 5 * s, 6 * s, s, C(0xFF4A1A, 0.3 + 0.5 * pulse))
        for k in 0..<8 {
            let ang = Double(k) / 8 * 2 * .pi
            c.rect(f.seal + Int(cos(ang) * Double(39 * s)), g + 5 * s + Int(sin(ang) * Double(4 * s)), 2 * s, s, C(0xFF4A1A, 0.2 + 0.4 * pulse))
        }
        for k in 0..<10 {
            let p = frac(t * 0.08 * (0.7 + noise(k + 980)) + noise(k + 990))
            let x = Int(noise(k + 970) * Double(c.w)) + Int(sin(t + Double(k)) * Double(3 * s)), y = g - Int(p * Double(g * 7 / 10))
            c.rect(x, y, s, s, C(0xFF8A3A, 0.8 * (1 - p)))
        }
        if let rim = f.rim {
            for k in 0..<7 {
                let x = c.w * 28 / 100 + Int(noise(k + 1000) * Double(c.w * 68 / 100)), y = g - (8 + Int(noise(k + 1010) * 40)) * s
                let open = frac(t / (5 + noise(k + 1020) * 4) + noise(k + 1030))
                guard open < 0.7, y > rim + 6 * s else { continue }
                let lid = open < 0.05 || open > 0.65 ? 0.4 : 1.0
                let col = k % 3 == 0 ? C(0xF0E040, lid) : C(0xFF6A2A, lid)
                c.rect(x, y, 2 * s, s, col); c.rect(x + 4 * s, y, 2 * s, s, col)
            }
        }
    }
}
