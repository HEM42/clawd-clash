import Foundation

let slayerScenes1: [Location: Place] = [
    .slayerLibrary: Place(name: "Sunnydale High Library", panel: 0x1C130C, still: Scenes.slayerLibrary,
                          moving: Scenes.slayerLibraryLife),
]

// MARK: - Sunnydale High library

extension Scenes {
    /// Where things stand in the library: the balcony's walkway, the book cage, the study table, the stairs, and (on
    /// the screen saver) the tall arched windows.
    static func slayerLibraryFrame(_ c: PixelCanvas, _ g: Int) -> (walk: Int, cage: (x: Int, w: Int, h: Int),
                                                                 table: (x: Int, w: Int), stairs: Int,
                                                                 windows: [(x: Int, y: Int, w: Int, h: Int)]) {
        let s = unit(g), tall = isTall(c)
        let walk = tall ? g - 70 * s : g - 36 * s
        let cage = (x: c.w * 64 / 100, w: 34 * s, h: min(30 * s, g - walk - 4 * s))
        var windows: [(x: Int, y: Int, w: Int, h: Int)] = []
        if tall {
            let h = min(80 * s, walk - 34 * s), w = 22 * s
            for k in 0..<3 where h > 20 * s { windows.append((x: c.w * (18 + k * 28) / 100, y: walk - h - 16 * s, w: w, h: h)) }
        }
        return (walk, cage, (x: c.w * 30 / 100, w: 70 * s), c.w * 86 / 100, windows)
    }

    /// The Sunnydale High library, above the Hellmouth: dark wood everywhere, shelves of old books up to a balcony that
    /// runs across the back with its railing, more shelves above it, the stairs climbing up to it on the right, the book
    /// cage with its wire-mesh door, the card catalogue, and the long study table with books left open on it. On the
    /// screen saver, the stacks rise higher and three tall arched windows let the daylight in.
    static func slayerLibrary(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = slayerLibraryFrame(c, g)
        let wall = C(0x3A2416), wood = C(0x5C3A22), woodL = C(0x7A5232), woodD = C(0x2A1A0E)
        c.gradient(0, g, C(0x24160C), wall, bands: 6)
        // Shelves of books: above the balcony and below it, row after row.
        func shelves(_ y0: Int, _ y1: Int, seed: Int) {
            guard y1 - y0 > 6 * s else { return }
            for y in stride(from: y0, to: y1 - 6 * s, by: 9 * s) {
                c.rect(0, y + 7 * s, c.w, s, woodL); c.rect(0, y + 8 * s, c.w, s, woodD)
                var x = 0, i = seed + y
                while x < c.w {
                    let bw = (2 + Int(noise(i) * 3)) * s, bh = (5 + Int(noise(i + 1) * 2)) * s
                    let tones = [C(0x6A2A1E), C(0x2E3E2A), C(0x5A4A2A), C(0x3A2A40), C(0x7A5A2E), C(0x4A1E1A), C(0x2A3446)]
                    let col = tones[Int(noise(i + 2) * Double(tones.count)) % tones.count]
                    if noise(i + 3) > 0.08 { c.rect(x, y + 7 * s - bh, bw, bh, col); c.rect(x, y + 7 * s - bh, max(1, s), bh, col.alpha(0.7)) }
                    x += bw + (noise(i + 4) > 0.85 ? s : 0)
                    i += 5
                }
            }
            for x in stride(from: 0, to: c.w, by: 46 * s) { c.rect(x, y0, 2 * s, y1 - y0, wood) }   // the uprights
        }
        // On the screen saver, a coffered ceiling of dark beams over the stacks.
        let ceiling = isTall(c) ? 10 * s : 0
        if ceiling > 0 {
            c.rect(0, 0, c.w, ceiling, woodD); c.rect(0, ceiling - s, c.w, s, woodL)
            for x in stride(from: 0, to: c.w, by: 30 * s) { c.rect(x, 0, 3 * s, ceiling, wood) }
        }
        shelves(ceiling, f.walk - 2 * s, seed: 11)
        // The windows, high up on the screen saver: arched, mullioned, pale daylight.
        for w in f.windows {
            c.rect(w.x - 2 * s, w.y - 2 * s, w.w + 4 * s, w.h + 4 * s, woodD)
            c.rect(w.x, w.y + w.w / 2, w.w, w.h - w.w / 2, C(0xC8D8E0))
            c.ellipse(w.x + w.w / 2, w.y + w.w / 2, w.w / 2, w.w / 2, C(0xC8D8E0))
            c.rect(w.x, w.y + w.w / 2, w.w, w.w / 2, C(0xC8D8E0))
            c.rect(w.x + w.w / 2 - s / 2, w.y, max(1, s), w.h, woodD)
            for y in stride(from: w.y + w.w / 2, to: w.y + w.h, by: 9 * s) { c.rect(w.x, y, w.w, max(1, s), woodD) }
        }
        shelves(f.walk + 4 * s, g - 12 * s, seed: 57)
        // The balcony's walkway and its railing.
        c.rect(0, f.walk, c.w, 4 * s, wood); c.rect(0, f.walk, c.w, s, woodL); c.rect(0, f.walk + 3 * s, c.w, s, woodD)
        c.rect(0, f.walk - 7 * s, c.w, s, woodL)
        for x in stride(from: 2 * s, to: c.w, by: 5 * s) { c.rect(x, f.walk - 6 * s, s, 6 * s, wood) }
        // The panelling along the bottom.
        let panel = g - 12 * s
        c.rect(0, panel, c.w, 12 * s, wood); c.rect(0, panel, c.w, s, woodL)
        for x in stride(from: 10 * s, to: c.w, by: 22 * s) { c.rect(x, panel + 2 * s, 18 * s, 8 * s, woodD.alpha(0.5)) }
        // The stairs up to the balcony, on the right, with their banister.
        let sx = f.stairs, rise = g - f.walk, steps = max(4, rise / (4 * s))
        for k in 0..<steps {
            let y = g - (k + 1) * rise / steps, x = sx + k * 4 * s
            guard x < c.w else { break }
            c.rect(x, y, c.w - x, rise / steps, wood); c.rect(x, y, c.w - x, s, woodL)
        }
        slLine(c, Double(sx), Double(g - 10 * s), Double(sx + steps * 4 * s), Double(f.walk - 6 * s), woodD, Double(s) * 0.7)
        // The book cage: a wire-mesh wall and door, books stacked inside.
        let cg = f.cage, cy = g - cg.h
        if cg.h > 10 * s {
            c.rect(cg.x, cy, cg.w, cg.h, C(0x1A120A))
            for k in 0..<3 { c.rect(cg.x + 2 * s, cy + cg.h - (k + 1) * 6 * s, 14 * s, 5 * s, [C(0x6A2A1E), C(0x2E3E2A), C(0x5A4A2A)][k]) }
            c.rect(cg.x + 18 * s, cy + 4 * s, 3 * s, cg.h - 4 * s, C(0x5A4A2A))
            let wire = C(0x8A8E94, 0.75)
            for x in stride(from: cg.x, through: cg.x + cg.w, by: 3 * s) { c.rect(x, cy, max(1, s / 2), cg.h, wire) }
            for y in stride(from: cy, through: g, by: 3 * s) { c.rect(cg.x, y, cg.w, max(1, s / 2), wire) }
            c.rect(cg.x - s, cy - s, cg.w + 2 * s, s, C(0x4A4E54)); c.rect(cg.x - s, cy, s, cg.h, C(0x4A4E54))
            c.rect(cg.x + cg.w, cy, s, cg.h, C(0x4A4E54))
        }
        // The card catalogue, on the left: little drawers with brass pulls.
        let kx = c.w * 6 / 100, kh = 18 * s, ky = g - kh
        c.rect(kx, ky, 20 * s, kh, wood); c.rect(kx, ky, 20 * s, s, woodL); c.rect(kx + 19 * s, ky, s, kh, woodD)
        for r in 0..<4 { for q in 0..<4 {
            let dx = kx + s + q * 5 * s, dy = ky + 2 * s + r * 4 * s
            c.rect(dx, dy, 4 * s, 3 * s, woodD.alpha(0.6)); c.rect(dx + s + s / 2, dy + s, s, s, C(0xC8A04A))
        } }
        // The long study table, books left open on it and a green banker's lamp.
        let tx = f.table.x, tw = f.table.w, ty = g - 15 * s
        c.rect(tx, ty, tw, 2 * s, woodL); c.rect(tx, ty + 2 * s, tw, s, woodD)
        for lx in [tx + 2 * s, tx + tw - 5 * s] { c.rect(lx, ty + 3 * s, 3 * s, 12 * s, wood) }
        c.rect(tx + 8 * s, ty - 2 * s, 12 * s, 2 * s, C(0xE8DCC0)); c.rect(tx + 14 * s, ty - 2 * s, s, 2 * s, C(0xA89878))
        c.rect(tx + 26 * s, ty - 4 * s, 8 * s, 4 * s, C(0x5A2A1E)); c.rect(tx + 26 * s, ty - 4 * s, 8 * s, s, C(0x7A3A2A))
        c.rect(tx + 46 * s, ty - 7 * s, s, 7 * s, C(0xC8A04A)); c.rect(tx + 43 * s, ty - 9 * s, 7 * s, 3 * s, C(0x2E6A3A))
        c.rect(tx + 44 * s, ty - 1 * s, 5 * s, s, C(0xC8A04A))
        // Floorboards.
        c.ground(g, C(0x4A3020), edge: C(0x6A4630), speck: C(0x3A2416), seed: 61)
        for x in stride(from: 0, to: c.w, by: 14 * s) { c.rect(x, g, max(1, s / 2), c.h - g, C(0x2E1C10)) }
    }

    /// The library's life: dust motes turning in the light, the book cage's door swinging a little on its hinge, and
    /// now and then the Hellmouth's red glow seeping up between the floorboards.
    static func slayerLibraryLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerLibraryFrame(c, g)
        // A shaft of light from the high windows (or from off to the left in the window), dust drifting in it.
        let x0 = f.windows.first.map { $0.x } ?? c.w / 8
        for k in 0..<14 {
            let ph = frac(t * 0.05 + noise(k * 3) )
            let x = x0 + Int((noise(k * 3 + 1) * 40 + ph * 30) * Double(s)), y = Int(Double(g) * (0.15 + 0.7 * frac(noise(k * 3 + 2) + t * 0.02 * (1 + noise(k)))))
            c.px(x, y, C(0xF8E8C0, 0.25 + 0.35 * (0.5 + 0.5 * sin(t * 2 + Double(k)))))
        }
        // The cage door: hinged on its left post, swinging out and back a few pixels.
        let cg = f.cage, cy = g - cg.h
        if cg.h > 10 * s {
            let open = Int(((sin(t * 0.7) + 1) * 2.5).rounded()) * s
            let dx = cg.x + cg.w - 12 * s
            c.rect(dx + open, cy + 2 * s, 11 * s, cg.h - 2 * s, C(0x8A8E94, 0.35))
            c.rect(dx + open, cy + 2 * s, s, cg.h - 2 * s, C(0x5A5E64)); c.rect(dx + open + 10 * s, cy + 2 * s, s, cg.h - 2 * s, C(0x5A5E64))
            c.rect(dx + open + 8 * s, cy + cg.h / 2, 2 * s, 2 * s, C(0xC8A04A))
        }
        // The seal under the floor: a red glow pulses up through the cracks every half minute or so.
        let k = frac(t / 31)
        if k < 0.18 {
            let a = sin(k / 0.18 * .pi) * 0.7
            let cx = c.w / 2, step = 14 * s
            for x in stride(from: (cx - 28 * s) / step * step, to: cx + 28 * s, by: step) {   // along the board joins
                c.rect(x, g, max(1, s), c.h - g, C(0xFF3A1A, a))
            }
            c.rect(cx - 20 * s, g, 40 * s, max(1, s / 2), C(0xFF6A3A, a * 0.6))
        }
    }
}
