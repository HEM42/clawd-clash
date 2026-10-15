import Foundation

let filesScenes1: [Location: Place] = [
    .xFilesOffice: Place(name: "The X-Files Office", panel: 0x16180F, still: Scenes.xFilesOffice, moving: Scenes.xFilesOfficeLife),
]

// MARK: - The X-Files office, FBI basement

extension Scenes {
    /// Where things stand in the office: the slide screen, the poster, the projector's lens, the ceiling's depth and
    /// the strip light.
    static func officeFrame(_ c: PixelCanvas, _ g: Int) -> (screen: (x: Int, y: Int, w: Int, h: Int),
                                                             poster: (x: Int, y: Int, w: Int, h: Int),
                                                             lens: (x: Int, y: Int), ceiling: Int, light: (x: Int, w: Int)) {
        let s = unit(g)
        let ceiling = g > 60 ? 6 * s : 0
        let panelTop = g - 14 * s
        let ph = min(48 * s, panelTop - ceiling - 4 * s), pw = 37 * s   // wide enough for the slogan
        let poster = (x: c.w * 60 / 100, y: panelTop - ph - 2 * s, w: pw, h: ph)
        let sh = min(24 * s, panelTop - ceiling - 6 * s), sw = sh * 4 / 3
        let screen = (x: c.w * 30 / 100, y: max(ceiling + 3 * s, panelTop - sh - 10 * s), w: sw, h: sh)
        return (screen, poster, (x: c.w * 82 / 100, y: g - 20 * s), ceiling, (x: c.w / 2 - 15 * s, w: 30 * s))
    }

    /// The X-Files office in the basement of FBI headquarters: dingy green-grey walls over brown panelling, a ceiling of
    /// stained tiles with pencils stuck in them, a strip light, filing cabinets stuffed full, the I WANT TO BELIEVE
    /// poster (a saucer over the pines), a pull-down screen and a cluttered desk with the slide projector on it. On the
    /// screen saver, pipes run up the wall into the dark.
    static func xFilesOffice(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = officeFrame(c, g)
        c.gradient(0, g, C(0x1C1F18), C(0x3A3D30), bands: 7)
        if tall {
            // Pipes and conduit running up the wall.
            for (i, x) in [c.w / 12, c.w / 12 + 5 * s, c.w * 9 / 10].enumerated() {
                c.rect(x, 0, 3 * s, g - 14 * s, C(0x4A4E44)); c.rect(x, 0, s, g - 14 * s, C(0x6A6E62))
                for y in stride(from: g / 5 + i * 9 * s, to: g - 16 * s, by: g / 4) { c.rect(x - s, y, 5 * s, 2 * s, C(0x3A3D34)) }
            }
        }
        // The ceiling tiles, and the pencils thrown up into them.
        if f.ceiling > 0 {
            c.rect(0, 0, c.w, f.ceiling, C(0x8A8A7A))
            for x in stride(from: 0, to: c.w, by: 18 * s) { c.rect(x, 0, s, f.ceiling, C(0x5E5E52)) }
            c.rect(0, f.ceiling - s, c.w, s, C(0x5E5E52))
            for i in 0..<9 {
                let x = Int(noise(i * 7 + 3) * Double(c.w)), len = (3 + Int(noise(i * 7 + 4) * 3)) * s
                c.rect(x, f.ceiling, s, len, C(0xE8C04A)); c.rect(x, f.ceiling + len, s, s, C(0xE89AA0))
            }
            c.rect(f.light.x - s, f.ceiling, f.light.w + 2 * s, s, C(0x6A6A5E))
        }
        // The panelling along the bottom of the wall.
        let panelTop = g - 14 * s
        c.rect(0, panelTop, c.w, 14 * s, C(0x4A3826)); c.rect(0, panelTop, c.w, s, C(0x6A5038))
        for x in stride(from: 9 * s, to: c.w, by: 16 * s) { c.rect(x, panelTop + s, s, 13 * s, C(0x36281A)) }
        // Filing cabinets, drawers bulging with files.
        for k in 0..<2 {
            let x = c.w * 6 / 100 + k * 17 * s, h = min(32 * s, g - f.ceiling - 4 * s), top = g - h
            c.rect(x, top, 16 * s, h, C(0x5A665A)); c.rect(x + 15 * s, top, s, h, C(0x3E4A3E)); c.rect(x, top, 16 * s, s, C(0x7A8A7A))
            for d in 0..<3 {
                let y = top + 2 * s + d * h / 3
                c.rect(x + s, y, 14 * s, h / 3 - 3 * s, C(0x4E5A4E))
                c.rect(x + 6 * s, y + 2 * s, 4 * s, s, C(0xB8BCB0))
                c.rect(x + 2 * s, y - s, 12 * s, s, C(0xE8DCB8))   // paper sticking out
            }
        }
        // The pull-down screen (the slides come with the moving layer).
        let sc = f.screen
        c.rect(sc.x - 2 * s, sc.y - 2 * s, sc.w + 4 * s, 2 * s, C(0x2A2A26))
        c.rect(sc.x, sc.y, sc.w, sc.h, C(0xD8D6CC)); c.rect(sc.x, sc.y + sc.h, sc.w, s, C(0x8A887E))
        // The poster, and the corkboard of clippings joined up with red string.
        drawBelievePoster(c, f.poster, s: s)
        drawCorkboard(c, x: c.w * 44 / 100, bottom: panelTop - 6 * s, s: s, room: panelTop - f.ceiling - 10 * s)
        // The desk, at a Clawd's chest: drawers, a stack of files, papers, a mug and the slide projector; his chair beside it.
        let dw = 64 * s, dh = 16 * s, dx = f.lens.x - 48 * s, dtop = g - dh
        let chx = dx + dw + 4 * s
        if chx + 12 * s < c.w {
            c.rect(chx, g - 24 * s, 3 * s, 15 * s, C(0x2A2A2E)); c.rect(chx, g - 24 * s, 3 * s, s, C(0x44444A))
            c.rect(chx, g - 10 * s, 12 * s, 3 * s, C(0x34343A)); c.rect(chx + 5 * s, g - 7 * s, 2 * s, 5 * s, C(0x1E1E22))
            c.rect(chx + s, g - 2 * s, 10 * s, s, C(0x1E1E22))
        }
        c.rect(dx, dtop, dw, dh, C(0x5A4430)); c.rect(dx - s, dtop, dw + 2 * s, 2 * s, C(0x7A5E40))
        c.rect(dx + dw - 3 * s, dtop + 2 * s, s, dh - 2 * s, C(0x4A3826))
        for d in 0..<2 {   // the drawers
            let y = dtop + 3 * s + d * 6 * s
            c.rect(dx + 3 * s, y, 16 * s, 5 * s, C(0x4A3826)); c.rect(dx + 9 * s, y + 2 * s, 4 * s, s, C(0xB89A6A))
        }
        c.rect(dx + 3 * s, dtop - 2 * s, 12 * s, 2 * s, C(0xE8DCB8)); c.rect(dx + 4 * s, dtop - 3 * s, 10 * s, s, C(0xD8CCA8))
        for k in 0..<3 {   // case files, piled
            c.rect(dx + 17 * s + k * s / 2, dtop - (k + 1) * 2 * s, 11 * s, 2 * s, [C(0xC8A870), C(0xB89858), C(0xD8B880)][k])
        }
        c.rect(dx + 31 * s, dtop - 5 * s, 4 * s, 5 * s, C(0xF2F0EA)); c.rect(dx + 35 * s, dtop - 4 * s, s, 3 * s, C(0xF2F0EA))
        c.rect(dx + 31 * s, dtop - 5 * s, 4 * s, s, C(0x3A2A1A))   // coffee
        // The slide projector, sitting on the desk, a carousel of slides on top, its lens facing the screen.
        c.rect(f.lens.x - 8 * s, f.lens.y - 2 * s, 11 * s, 6 * s, C(0x4A4C52)); c.rect(f.lens.x - 8 * s, f.lens.y - 2 * s, 11 * s, s, C(0x6A6E76))
        c.ellipse(f.lens.x - 3 * s, f.lens.y - 3 * s, 4 * s, s, C(0x2E3036))
        c.rect(f.lens.x - 11 * s, f.lens.y, 3 * s, 2 * s, C(0x2A2A2E))
        // The floor: old lino.
        c.ground(g, C(0x3A3A32), edge: C(0x5E5E52), speck: C(0x2C2C26), seed: 41)
    }

    /// I WANT TO BELIEVE: a saucer under a night sky over a line of pines, the slogan along the bottom.
    private static func drawBelievePoster(_ c: PixelCanvas, _ r: (x: Int, y: Int, w: Int, h: Int), s: Int) {
        guard r.h > 30 * s else { return }
        c.rect(r.x - s, r.y - s, r.w + 2 * s, r.h + 2 * s, C(0x1A1A16))
        let sky = r.h - 14 * s   // the slogan's band below
        for y in r.y..<(r.y + sky) {
            let k = Double(y - r.y) / Double(max(1, sky))
            c.rect(r.x, y, r.w, 1, k < 0.5 ? C(0x0E1630) : C(0x1E2A44))
        }
        for i in 0..<6 { c.px(r.x + Int(noise(i + 90) * Double(r.w)), r.y + Int(noise(i + 97) * Double(sky / 2)), C(0xE8ECF4)) }
        // The saucer, centred, and a faint glow under it.
        let ux = r.x + r.w / 2, uy = r.y + sky / 3
        c.ellipse(ux, uy, r.w / 5, max(1, r.w / 14), C(0xB8C0C8)); c.rect(ux - r.w / 12, uy - r.w / 12, r.w / 6, r.w / 12, C(0x8A949E))
        c.rect(ux - r.w / 6, uy + r.w / 14, r.w / 3, sky - sky / 3 - r.w / 14, C(0xC8FFE0, 0.18))
        // Pines along the bottom of the sky.
        for i in 0..<5 {
            let tx = r.x + i * r.w / 5 + r.w / 10, th = sky / 4 + Int(noise(i + 80) * Double(sky / 6))
            for dy in 0..<th { let hw = dy * r.w / 18 / max(1, th) + 1; c.rect(tx - hw, r.y + sky - th + dy, hw * 2, 1, C(0x0A100C)) }
        }
        // The slogan on black.
        c.rect(r.x, r.y + sky, r.w, r.h - sky, C(0x0C0C0A))
        drawTinyText(c, "I WANT TO", cx: r.x + r.w / 2, y: r.y + sky + s, s: s, col: C(0xF0F0EA))
        drawTinyText(c, "BELIEVE", cx: r.x + r.w / 2, y: r.y + sky + 7 * s, s: s, col: C(0xF0F0EA))
    }

    /// A corkboard: newspaper clippings and blurry photos pinned up, red string running from pin to pin.
    private static func drawCorkboard(_ c: PixelCanvas, x: Int, bottom: Int, s: Int, room: Int) {
        let h = min(20 * s, room), w = 30 * s, y = bottom - h
        guard h > 10 * s else { return }
        c.rect(x - s, y - s, w + 2 * s, h + 2 * s, C(0x5A4028)); c.rect(x, y, w, h, C(0x9A7448))
        for i in 0..<14 { c.px(x + Int(noise(i + 200) * Double(w)), y + Int(noise(i + 230) * Double(h)), C(0x7E5C36)) }
        // Clippings (text lines) and photos (a dark smudge in a white border), each with its pin.
        var pins: [(Int, Int)] = []
        for i in 0..<5 {
            let px = x + 2 * s + i * (w - 9 * s) / 4, py = y + 2 * s + (i % 2 == 0 ? 0 : h / 2 - s)
            let cw = 7 * s, ch = min(8 * s, h / 2 - 2 * s)
            if i % 2 == 0 {
                c.rect(px, py, cw, ch, C(0xE8E2CC))
                for ly in stride(from: py + 2 * s, to: py + ch - s, by: 2 * s) { c.rect(px + s, ly, cw - 2 * s, max(1, s / 2), C(0x8A8676)) }
            } else {
                c.rect(px, py, cw, ch, C(0xF2F0EA)); c.rect(px + s, py + s, cw - 2 * s, ch - 3 * s, C(0x3A4238))
            }
            pins.append((px + cw / 2, py + s / 2))
        }
        // The red string, pin to pin.
        for (a, b) in zip(pins, pins.dropFirst()) {
            let n = max(abs(b.0 - a.0), abs(b.1 - a.1), 1)
            for k in 0...n { c.rect(a.0 + (b.0 - a.0) * k / n, a.1 + (b.1 - a.1) * k / n, max(1, s / 2), max(1, s / 2), C(0xC8202A)) }
        }
        for p in pins { c.rect(p.0 - s / 2, p.1 - s / 2, s, s, C(0xE8E8F0)) }
    }

    /// Text in a 3×5 pixel font (only the letters this universe's signs need), centred on `cx`.
    static func drawTinyText(_ c: PixelCanvas, _ text: String, cx: Int, y: Int, s: Int, col: Px) {
        let glyphs: [Character: [String]] = [
            "A": [".#.", "#.#", "###", "#.#", "#.#"], "B": ["##.", "#.#", "##.", "#.#", "##."],
            "E": ["###", "#..", "##.", "#..", "###"], "I": ["###", ".#.", ".#.", ".#.", "###"],
            "L": ["#..", "#..", "#..", "#..", "###"], "N": ["#.#", "###", "###", "#.#", "#.#"],
            "O": [".#.", "#.#", "#.#", "#.#", ".#."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
            "V": ["#.#", "#.#", "#.#", "#.#", ".#."], "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"],
            " ": [".", ".", ".", ".", "."],
        ]
        let width = text.reduce(0) { $0 + (glyphs[$1]?[0].count ?? 3) + 1 } - 1
        var x = cx - width * s / 2
        for ch in text {
            let rows = glyphs[ch] ?? glyphs[" "]!
            for (dy, row) in rows.enumerated() {
                for (dx, p) in row.enumerated() where p == "#" { c.rect(x + dx * s, y + dy * s, s, s, col) }
            }
            x += (rows[0].count + 1) * s
        }
    }

    /// What moves in the office: the strip light flickering now and then, and the projector's beam with the slides
    /// changing on the screen (a saucer photo, a blurry figure in the woods, a crop circle).
    static func xFilesOfficeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = officeFrame(c, g)
        if f.ceiling > 0 {
            let flicker = noise(Int(t * 9)) > 0.93 ? 0.25 : 1.0
            c.rect(f.light.x, f.ceiling, f.light.w, 2 * s, C(0xEEF4E2, 0.9 * flicker))
            c.rect(f.light.x - 6 * s, f.ceiling + 2 * s, f.light.w + 12 * s, 6 * s, C(0xEEF4E2, 0.05 * flicker))
        }
        // The beam: from the lens across to the screen, faint and dusty.
        let sc = f.screen, lx = f.lens.x - 11 * s, ly = f.lens.y + s
        let span = max(1, lx - (sc.x + sc.w))
        for x in (sc.x + sc.w)..<lx {
            let k = Double(lx - x) / Double(span)
            let top = ly + Int(Double(sc.y - ly) * k), bottom = ly + Int(Double(sc.y + sc.h - ly) * k)
            c.rect(x, top, 1, max(1, bottom - top), C(0xFFF6DA, 0.06))
        }
        // The slide on the screen.
        let slide = Int(t / 4.5) % 3
        c.rect(sc.x + s, sc.y + s, sc.w - 2 * s, sc.h - 2 * s, C(0xFFF6DA, 0.35))
        let mx = sc.x + sc.w / 2, my = sc.y + sc.h / 2
        switch slide {
        case 0:   // a saucer, grainy
            c.ellipse(mx, my - sc.h / 8, sc.w / 6, max(1, sc.h / 12), C(0x3A3A36, 0.8))
            c.rect(mx - sc.w / 14, my - sc.h / 8 - sc.h / 10, sc.w / 7, sc.h / 10, C(0x3A3A36, 0.8))
        case 1:   // something tall and dark among the trees
            for i in 0..<4 { c.rect(sc.x + (i + 1) * sc.w / 5, sc.y + sc.h / 4, s, sc.h * 3 / 4 - s, C(0x2E3A2A, 0.7)) }
            c.rect(mx + sc.w / 10, my - sc.h / 6, 3 * s, sc.h / 2, C(0x2A1E14, 0.8)); c.rect(mx + sc.w / 10, my - sc.h / 4, 3 * s, 2 * s, C(0x2A1E14, 0.8))
        default:  // a crop circle from above
            c.rect(sc.x + s, sc.y + s, sc.w - 2 * s, sc.h - 2 * s, C(0xC8A84A, 0.35))
            c.ellipse(mx, my, sc.h / 3, sc.h / 3, C(0x8A6E2A, 0.55)); c.ellipse(mx, my, sc.h / 5, sc.h / 5, C(0xC8A84A, 0.5))
            c.ellipse(mx + sc.h / 2, my - sc.h / 5, sc.h / 9, sc.h / 9, C(0x8A6E2A, 0.55))
        }
    }
}
