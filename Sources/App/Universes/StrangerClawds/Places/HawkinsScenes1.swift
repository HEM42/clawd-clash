import Foundation

// Places: the Wheelers' house. Drawn in the same pixel art as the crew, at the same pixel size: flat colours, two or
// three tones a material, the light from the front left. The floor and the band above it stay plain and mid-dark so
// the crew's outlines and names read; the busy things go higher up and at the sides. Props keep their size in
// `Scenes.unit(g)` steps, and the screen saver's taller canvas gets more of the room above.

let hawkinsScenes1: [Location: Place] = [
    .hawkinsBasement: Place(name: "The Wheelers' Basement", panel: 0x1E1612, still: Scenes.hawkinsBasement,
                            moving: Scenes.hawkinsBasementLife),
]

// MARK: - The Wheelers' basement

extension Scenes {
    /// Where things stand in the basement, shared by the still picture and the moving layer so they line up: the top
    /// of the wood panelling, the stairs' foot, the D&D table's middle and top, the couch, the standing lamp's shade,
    /// the blanket fort and the high windows.
    static func hawkinsBasementFrame(_ c: PixelCanvas, _ g: Int) -> (panel: Int, stairs: Int, table: (x: Int, top: Int),
                                                                    couch: Int, lamp: (x: Int, y: Int), fort: Int, windows: [Int]) {
        let s = unit(g)
        return (g - 44 * s, 6 * s + 95 * s, (x: c.w * 38 / 100, top: g - 12 * s), c.w * 61 / 100,
                (x: c.w * 72 / 100, y: g - 27 * s), c.w * 86 / 100, [c.w * 34 / 100, c.w * 66 / 100])
    }

    /// The Wheelers' basement at night: wood panelling halfway up the walls and the painted block wall above it, two
    /// little windows high up at ground level with the grass outside against the night; the wooden stairs coming
    /// down on the left with their railing, boxes in the dark under them; the card table set for D&D with Mike's
    /// screen, the rulebooks and the minis; the old plaid couch with a crocheted blanket over its back and board games
    /// on a shelf above it; the standing lamp; and Eleven's blanket fort in the corner, made of sheets and blankets
    /// over two chairs, pillows inside. A rust carpet along the front where the crew stands. On the screen saver the
    /// room goes higher: the stairs climb on to a landing and the door upstairs with light under it, shelves of
    /// cardboard boxes line the wall, a BMX hangs up for the winter under a pegboard of tools, and the joists and a bare bulb hang overhead.
    static func hawkinsBasement(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsBasementFrame(c, g), tall = isTall(c)
        // The block wall: painted blocks in courses, each offset half a block from the one below, a shade under each.
        let block = C(0x8C8478), blockD = C(0x767064), mortar = C(0x5E5A50)
        c.rect(0, 0, c.w, f.panel, block)
        var row = 0
        for y in stride(from: f.panel - 5 * s, to: -5 * s, by: -5 * s) {
            c.rect(0, y + 4 * s, c.w, s, mortar)
            let off = row % 2 == 0 ? 0 : 6 * s
            for x in stride(from: -off, to: c.w, by: 12 * s) {
                c.rect(x, y, s, 4 * s, mortar)
                c.rect(x + s, y + 3 * s, 11 * s, s, blockD)
                if noise(x / max(1, s) * 13 + row * 7) > 0.8 { c.rect(x + 3 * s, y + s, 2 * s, s, blockD) }   // a chip
            }
            row += 1
        }
        // The copper pipe along the top of the panelling, on its brackets.
        let pipeY = f.panel - 9 * s
        c.rect(0, pipeY, c.w, 2 * s, C(0xB06A3E)); c.rect(0, pipeY, c.w, s, C(0xD48A56)); c.rect(0, pipeY + 2 * s, c.w, s, C(0x5E4A3C))
        for x in stride(from: 20 * s, to: c.w, by: 48 * s) { c.rect(x, pipeY - s, 2 * s, 4 * s, C(0x5A5A60)) }

        // The high windows, at ground level outside: a white frame, the night, blades of grass up against the glass and
        // a little moonlight on the pane.
        for wx in f.windows {
            let wy = g - 60 * s, ww = 24 * s, wh = 9 * s
            c.rect(wx - ww / 2 - s, wy - s, ww + 2 * s, wh + 2 * s, C(0xC8C0B0))
            c.rect(wx - ww / 2 - s, wy + wh, ww + 2 * s, s, C(0x8E887C))
            c.rect(wx - ww / 2, wy, ww, wh, C(0x1A2440))
            c.rect(wx - ww / 2, wy, ww, 2 * s, C(0x22305A))
            for k in 0..<(ww / s) where k % 2 == 0 {
                let h = (2 + Int(noise(k * 3 + wx) * 4)) * s
                c.rect(wx - ww / 2 + k * s, wy + wh - h, s, h, C(0x1E3A22))
            }
            c.rect(wx - s / 2, wy, max(1, s), wh, C(0xC8C0B0))
            c.rect(wx - ww / 2 + 2 * s, wy + s, 3 * s, s, C(0x5A6A90)); c.rect(wx + 3 * s, wy + s, 2 * s, s, C(0x5A6A90))
        }

        // The panelling: dark wood boards with grooves between them, grain in short strokes, a lit cap rail on top and
        // the skirting board along the bottom.
        let wood = C(0x6A4630), woodD = C(0x543622), groove = C(0x3A2416), grain = C(0x7A5438)
        c.rect(0, f.panel, c.w, g - f.panel, wood)
        for (i, x) in stride(from: 0, to: c.w, by: 7 * s).enumerated() {
            if i % 3 == 1 { c.rect(x, f.panel, 7 * s, g - f.panel, woodD) }
            c.rect(x, f.panel, s, g - f.panel, groove)
            for k in 0..<3 {
                let gy = f.panel + 3 * s + Int(noise(i * 9 + k) * Double(g - f.panel - 12 * s))
                c.rect(x + (2 + k) * s, gy, s, (3 + k) * s, grain)
            }
        }
        c.rect(0, f.panel - s, c.w, 2 * s, C(0x8A603E)); c.rect(0, f.panel + s, c.w, s, groove)
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0x3E2A1C)); c.rect(0, g - 3 * s, c.w, s, C(0x5A3E28))

        // The shelf above the couch: board games stacked on it, a trophy and a pile of comics.
        let sh = (x: f.couch - 20 * s, y: g - 31 * s)
        c.rect(sh.x, sh.y, 40 * s, 2 * s, C(0x8A603E)); c.rect(sh.x, sh.y + 2 * s, 40 * s, s, C(0x2E1E14))
        for bx in [sh.x + 3 * s, sh.x + 33 * s] { c.rect(bx, sh.y + 2 * s, s, 3 * s, C(0x5A5A60)) }
        let games: [(UInt32, UInt32, Int, Int)] = [(0xC0402E, 0xF0D060, 12, 3), (0x2E5AA0, 0xF0F0E0, 11, 3), (0x2E8A4A, 0xF0C040, 13, 2), (0xE0B030, 0x8A2A1E, 10, 3)]
        var gy = sh.y
        for (col, band, w, h) in games {
            gy -= h * s
            c.rect(sh.x + 2 * s, gy, w * s, h * s, C(col)); c.rect(sh.x + 2 * s, gy, w * s, s, C(band))
            c.rect(sh.x + 2 * s + w * s - s, gy, s, h * s, lerp(C(col), C(0x000000), 0.3))
        }
        c.rect(sh.x + 20 * s, sh.y - 6 * s, 3 * s, 5 * s, C(0xD8B040)); c.rect(sh.x + 19 * s, sh.y - s, 5 * s, s, C(0x6A4A2A))
        c.rect(sh.x + 19 * s, sh.y - 7 * s, 5 * s, 2 * s, C(0xE8C850)); c.rect(sh.x + 22 * s, sh.y - 6 * s, s, 5 * s, C(0xA88428))
        for k in 0..<4 { c.rect(sh.x + 27 * s, sh.y - (k + 1) * s, 9 * s, s, [C(0xE04A3A), C(0xF0E0C0), C(0x3A7AC0), C(0xF0C040)][k]) }

        // The stairs: wooden treads lit along their noses, the risers in shade, closed in underneath with boxes in
        // the dark there; the railing's balusters and handrail, and the newel post at the foot.
        let run = 5 * s, rise = 4 * s
        let landing = tall ? 19 : 1000
        var steps = 0
        while true {
            let k = steps + 1
            let x = f.stairs - k * run, y = g - k * rise
            if x + run <= 0 || y + rise <= 0 || k > landing { break }
            c.rect(x, y, run, rise, C(0x7A5232))
            c.rect(x, y, run, s, C(0xA87A4A)); c.rect(x, y + s, run, s, C(0x4E321E))
            c.rect(x + run - s, y + s, s, rise - s, C(0x5E3E24))
            c.rect(x, y + rise, run, g - y - rise, C(0x3E2A1A))
            if k % 2 == 0 { c.rect(x, y + rise + 3 * s, s, g - y - rise - 3 * s, C(0x2E1E12)) }   // the boards under them
            steps = k
        }
        // The stringer down the open side, and boxes stacked under the stairs.
        for k in 1...max(1, steps) {
            let x = f.stairs - k * run, y = g - k * rise
            c.rect(x, y + rise, run, 2 * s, C(0x5E3E24)); c.rect(x, y + rise + 2 * s, run, s, C(0x3E2A1A))
        }
        for (bx, bw, bh) in [(f.stairs - 22 * s, 9 * s, 7 * s), (f.stairs - 32 * s, 10 * s, 9 * s), (f.stairs - 30 * s, 7 * s, 5 * s)] {
            let by = bh == 5 * s ? g - 9 * s - bh : g - bh
            guard bx > 0 else { continue }
            c.rect(bx, by, bw, bh, C(0x6E5236)); c.rect(bx, by, bw, s, C(0x8A6A44)); c.rect(bx + bw - s, by, s, bh, C(0x4E3A26))
            c.rect(bx + bw / 2, by, s, 2 * s, C(0x9A8A6A))
        }
        // The railing, balusters every other step, the handrail parallel to the treads.
        for k in stride(from: 1, through: steps, by: 2) {
            let x = f.stairs - k * run + 2 * s, y = g - k * rise
            c.rect(x, y - 12 * s, s, 12 * s, C(0x8A6038))
        }
        for k in 0...(steps * run / s) {
            let x = f.stairs - k * s, y = g - 13 * s - k * rise / run
            if x < 0 { break }
            c.rect(x, y, s, 2 * s, C(0x9A6E42)); c.px(x, y, C(0xC0905A))
        }
        c.rect(f.stairs - 2 * s, g - 17 * s, 4 * s, 17 * s, C(0x8A6038)); c.rect(f.stairs - 2 * s, g - 17 * s, s, 17 * s, C(0xB08050))
        c.rect(f.stairs - 3 * s, g - 19 * s, 6 * s, 2 * s, C(0x9A6E42)); c.rect(f.stairs + s, g - 17 * s, s, 17 * s, C(0x5E3E24))
        if tall {
            // The landing at the top, and the door upstairs, its light spilling out underneath and round its edges.
            let ly = g - landing * rise - rise, lx = f.stairs - landing * run - run
            c.rect(0, ly, max(lx + run, 0), 2 * s, C(0xA87A4A)); c.rect(0, ly + 2 * s, max(lx + run, 0), 3 * s, C(0x4E321E))
            let dx = max(2 * s, lx - 14 * s), dh = 24 * s
            c.rect(dx - s, ly - dh - s, 14 * s, dh + s, C(0xC8B89A))
            c.rect(dx, ly - dh, 12 * s, dh, C(0x7A5A3C)); c.rect(dx, ly - dh, s, dh, C(0x9A7650))
            c.rect(dx + 2 * s, ly - dh + 3 * s, 8 * s, 7 * s, C(0x6A4C32)); c.rect(dx + 2 * s, ly - dh + 13 * s, 8 * s, 8 * s, C(0x6A4C32))
            c.rect(dx + 9 * s, ly - dh + 12 * s, 2 * s, s, C(0xD8B048))
            c.rect(dx, ly - s, 12 * s, s, C(0xF8D88A))
        }

        // The D&D table, a card table: its top lit along the edge, the folding legs, a chair either side with its back up.
        let t = f.table
        for (cx, dir) in [(t.x - 26 * s, 1), (t.x + 22 * s, -1)] {
            c.rect(cx, t.top - 6 * s, 4 * s, 2 * s, C(0x5A6A5A)); c.rect(cx + (dir > 0 ? 0 : 3 * s), t.top - 4 * s, s, 16 * s, C(0x3E4A3E))
            c.rect(cx, t.top + 4 * s, 4 * s, s, C(0x4A584A)); c.rect(cx + (dir > 0 ? 3 * s : 0), t.top + 4 * s, s, 8 * s, C(0x3E4A3E))
        }
        c.rect(t.x - 22 * s, t.top, 44 * s, 2 * s, C(0x2E3A2E)); c.rect(t.x - 22 * s, t.top, 44 * s, s, C(0x4E5E4A))
        c.rect(t.x - 22 * s, t.top + 2 * s, 44 * s, s, C(0x1E241E))
        for lx in [t.x - 20 * s, t.x + 18 * s] { c.rect(lx, t.top + 3 * s, 2 * s, 9 * s, C(0x6A6E72)); c.rect(lx, t.top + 3 * s, s, 9 * s, C(0x8A8E94)) }
        // On it: Mike's screen, three panels with their painted art; the rulebooks; a sheet of graph paper; the minis.
        let sx = t.x + 4 * s
        c.rect(sx, t.top - 7 * s, 15 * s, 7 * s, C(0x8A2A2E))
        c.rect(sx, t.top - 7 * s, 15 * s, s, C(0xC04A3E))
        c.rect(sx + 5 * s, t.top - 7 * s, s, 7 * s, C(0x5A1A1E)); c.rect(sx + 10 * s, t.top - 7 * s, s, 7 * s, C(0x5A1A1E))
        c.rect(sx + s, t.top - 5 * s, 3 * s, 3 * s, C(0xE0B040)); c.rect(sx + 6 * s, t.top - 5 * s, 3 * s, 3 * s, C(0x3A7A4A))
        c.rect(sx + 11 * s, t.top - 5 * s, 3 * s, 3 * s, C(0x4A6AB0))
        c.rect(t.x - 18 * s, t.top - 3 * s, 7 * s, 3 * s, C(0x2E4A8A)); c.rect(t.x - 18 * s, t.top - 3 * s, 7 * s, s, C(0x6A8ACA))
        c.rect(t.x - 17 * s, t.top - 5 * s, 6 * s, 2 * s, C(0xA83A2A)); c.rect(t.x - 17 * s, t.top - 5 * s, 6 * s, s, C(0xD86A4A))
        c.rect(t.x - 9 * s, t.top - s, 10 * s, s, C(0xE8E4D4))
        for (k, col) in [C(0xC8C8D0), C(0xD8B040), C(0x8AB0D8)].enumerated() {
            let mx = t.x - 7 * s + k * 3 * s
            c.rect(mx, t.top - 3 * s, s, 2 * s, col); c.px(mx, t.top - 3 * s, lerp(col, C(0xFFFFFF), 0.4))
        }
        // The dice tray, its dice drawn in the moving layer.
        c.rect(t.x + 22 * s - 4 * s, t.top - 2 * s, 6 * s, 2 * s, C(0x3A2216)); c.rect(t.x + 22 * s - 4 * s, t.top - 2 * s, 6 * s, s, C(0x5A3A26))

        // The old couch: rust tweed, three puffy back cushions and three seat cushions, each lit
        // along its top and shaded underneath, rolled arms, short dark feet, and a crocheted blanket in zigzags over
        // the back.
        let cw = 48 * s, cx = f.couch - cw / 2
        let fab = C(0x9A5634), fabD = C(0x743E24), fabL = C(0xB86E44), line = C(0xA86A42)
        c.rect(cx - 2 * s, g - 9 * s, cw + 4 * s, 7 * s, fabD)                       // the frame behind the seat
        for k in 0..<3 {
            let bx = cx + k * cw / 3
            c.rect(bx + s, g - 17 * s, cw / 3 - 2 * s, 9 * s, fab)                    // a back cushion
            c.rect(bx + 2 * s, g - 18 * s, cw / 3 - 4 * s, s, fab)
            c.rect(bx + 2 * s, g - 17 * s, cw / 3 - 4 * s, s, fabL)
            c.rect(bx + cw / 3 - 2 * s, g - 16 * s, s, 8 * s, fabD)
            c.rect(bx + s, g - 8 * s, cw / 3 - 2 * s, 4 * s, fab)                     // a seat cushion
            c.rect(bx + s, g - 8 * s, cw / 3 - 2 * s, s, fabL)
            c.rect(bx + s, g - 5 * s, cw / 3 - 2 * s, s, fabD)
            for d in 0..<3 { c.rect(bx + (3 + d * 4) * s, g - (14 - d * 2) * s, s, s, line) }   // flecks in the tweed
        }
        for (ax, lit) in [(cx - 6 * s, true), (cx + cw, false)] {                      // the rolled arms
            c.rect(ax, g - 11 * s, 6 * s, 9 * s, fab)
            c.rect(ax + s, g - 12 * s, 4 * s, s, fab)
            c.rect(ax + s, g - 11 * s, 4 * s, s, fabL)
            c.rect(lit ? ax : ax + 5 * s, g - 10 * s, s, 8 * s, lit ? fabL : fabD)
            c.rect(ax, g - 3 * s, 6 * s, s, fabD)
        }
        c.rect(cx - 6 * s, g - 2 * s, cw + 12 * s, s, C(0x3A2416))
        for fx in [cx - 5 * s, cx + cw + 3 * s] { c.rect(fx, g - s, 2 * s, s, C(0x2A1A10)) }
        let zig = [C(0xD87A30), C(0xE8C050), C(0x6A8A3A), C(0xA03A2A)]
        for x in stride(from: cx + 18 * s, to: cx + cw - s, by: s) {
            let k = (x - cx) / s
            let y = g - 19 * s + (k % 4 < 2 ? k % 2 : 1 - k % 2) * s
            c.rect(x, y, s, 2 * s, zig[(k / 4) % zig.count])
        }
        for k in 0..<5 { c.rect(cx + cw - 3 * s, g - 17 * s + k * 2 * s, 2 * s, 2 * s, zig[k % zig.count]) }   // its end hanging down

        // The standing lamp: a brass pole on a round foot, the cream shade (lit by the moving layer).
        let l = f.lamp
        c.rect(l.x, l.y + 5 * s, s, g - l.y - 6 * s, C(0xB08A40)); c.rect(l.x + s, l.y + 5 * s, s, g - l.y - 6 * s, C(0x7A5E2A))
        c.rect(l.x - 3 * s, g - 2 * s, 7 * s, 2 * s, C(0x7A5E2A)); c.rect(l.x - 3 * s, g - 2 * s, 7 * s, s, C(0xB08A40))

        // Eleven's blanket fort: sheets and blankets thrown over a line between two chairs, a blue blanket, a red plaid
        // and a yellow sheet, peaked in the middle where the line holds them up and sagging out to the floor, their
        // folds in shade and their hems in points, a dark way in, and pillows in there.
        let fw = 48 * s, fx = f.fort - fw / 2, fh = 22 * s
        let blue = C(0x3A5A8A), blueD = C(0x2A4068), red = C(0x9A3A30), redL = C(0xC8705A), yellow = C(0xD8B850), yellowD = C(0xB0922E)
        for y in (g - fh)..<g {
            let k = Double(y - (g - fh)) / Double(fh)
            let half = Int(Double(fw / 2) * (0.18 + 0.82 * min(1, k * 1.3)))
            for x in (f.fort - half)..<(f.fort + half) {
                let u = x - fx
                var col: Px
                if u < fw * 35 / 100 { col = (u / (3 * s)) % 3 == 2 ? blueD : blue }
                else if u < fw * 65 / 100 { col = (u / s) % 6 == 2 ? redL : ((g - y) / s) % 7 == 3 ? C(0x6E2620) : red }
                else { col = (u / (3 * s)) % 4 == 3 ? yellowD : yellow }
                c.px(x, y, col)
            }
        }
        c.rect(f.fort - 9 * s, g - fh - s, 18 * s, s, C(0xE8E0C8))                      // the line along the top
        for cxp in [f.fort - 10 * s, f.fort + 9 * s] {                                   // the chairs' backs poking up
            c.rect(cxp, g - fh - 4 * s, s, 4 * s, C(0x5A3E28)); c.rect(cxp - s, g - fh - 5 * s, 3 * s, s, C(0x7A5A3A))
        }
        for k in 0..<(fw / (4 * s)) { c.rect(fx + k * 4 * s + 2 * s, g - 2 * s, s, 2 * s, C(0x2A1C16)) }   // folds at the hem
        // The way in, dark, and the pillows inside it.
        for k in 0..<(12 * s) {
            let half = k / 2
            c.rect(f.fort - half, g - 12 * s + k, half * 2 + s, 1, C(0x1A1210))
        }
        c.rect(f.fort - 4 * s, g - 3 * s, 3 * s, 2 * s, C(0xE8E4DA)); c.rect(f.fort + s, g - 3 * s, 3 * s, 2 * s, C(0xC8D8E8))

        if tall {
            // Shelves of cardboard boxes up the wall on brackets, paint tins among them, and the joists
            // and their bare bulb up at the top.
            var shelf = g - 84 * s, n = 0
            while shelf > 22 * s {
                for (a, b) in [(c.w * 24 / 100, c.w * 48 / 100), (c.w * 56 / 100, c.w * 92 / 100)] {
                    c.rect(a, shelf, b - a, 2 * s, C(0x8A8E94)); c.rect(a, shelf, b - a, s, C(0xB8BCC4)); c.rect(a, shelf + 2 * s, b - a, s, C(0x3E3A34))
                    for bx in [a + 2 * s, b - 4 * s] { c.rect(bx, shelf + 2 * s, 2 * s, 5 * s, C(0x6A6E74)) }
                    var x = a + 2 * s, i = 0
                    while x < b - 10 * s {
                        let r = noise(n * 31 + i * 7 + a)
                        let bw = (9 + Int(r * 8)) * s, bh = (7 + Int(noise(n * 31 + i * 7 + 1 + a) * 7)) * s
                        if x + bw > b - 2 * s { break }
                        if r > 0.86 {
                            // A paint tin or two.
                            c.rect(x, shelf - 6 * s, 5 * s, 6 * s, C(0x9AA0A8)); c.rect(x, shelf - 6 * s, 5 * s, s, C(0xC8CCD2))
                            c.rect(x, shelf - 3 * s, 5 * s, s, [C(0xC04A3A), C(0x3A6AB0)][i % 2])
                            x += 7 * s
                        } else {
                            let tone = [C(0xA07A4E), C(0x8E6A42), C(0xB08A5A)][i % 3]
                            c.rect(x, shelf - bh, bw, bh, tone); c.rect(x, shelf - bh, bw, s, lerp(tone, C(0xFFFFFF), 0.2))
                            c.rect(x + bw - s, shelf - bh, s, bh, lerp(tone, C(0x000000), 0.3))
                            c.rect(x + bw / 2, shelf - bh, s, 2 * s, C(0xC8B88A))                 // the tape
                            c.rect(x + 2 * s, shelf - bh + 3 * s, min(bw - 4 * s, 5 * s), s, C(0x2A2A2A))   // marker writing
                            x += bw + s
                        }
                        i += 1
                    }
                }
                shelf -= 34 * s; n += 1
            }
            // Up on the left, a BMX hung on its hooks for the winter, and a pegboard of tools above it.
            let bx = c.w * 10 / 100, by = g - 112 * s
            if by > 40 * s {
                c.rect(bx - s, by - 9 * s, s, 3 * s, C(0x5A5A60)); c.rect(bx + 15 * s, by - 9 * s, s, 3 * s, C(0x5A5A60))
                for wx in [bx, bx + 16 * s] {
                    c.circle(wx, by, 6 * s, C(0x1E1E22)); c.circle(wx, by, 5 * s, C(0x8C8478)); c.circle(wx, by, s, C(0xA8ACB4))
                    for a in 0..<6 { let r = Double(a) * .pi / 3; c.px(wx + Int(cos(r) * Double(3 * s)), by + Int(sin(r) * Double(3 * s)), C(0xA8ACB4)) }
                }
                for k in 0...(8 * s) {   // the frame: down tube, top tube and the forks, red
                    c.rect(bx + k, by - k / 2, s, s, C(0xC8302A)); c.rect(bx + 8 * s + k, by - 4 * s, s, s, C(0xC8302A))
                    c.rect(bx + 16 * s - k / 3, by - k, s, s, C(0xC8302A))
                }
                c.rect(bx + 6 * s, by - 6 * s, 4 * s, s, C(0x1E1E22)); c.rect(bx + 12 * s, by - 9 * s, 6 * s, s, C(0x6A6A72))
            }
            let py = g - 170 * s
            if py > 30 * s {
                let pw = 34 * s, px0 = c.w * 4 / 100
                c.rect(px0, py, pw, 20 * s, C(0xB89A6A)); c.rect(px0, py, pw, s, C(0xD0B484)); c.rect(px0 + pw - s, py, s, 20 * s, C(0x8A7048))
                for yy in stride(from: py + 2 * s, to: py + 20 * s, by: 3 * s) { for xx in stride(from: px0 + 2 * s, to: px0 + pw, by: 3 * s) { c.rect(xx, yy, s, s, C(0x8A7048)) } }
                c.rect(px0 + 4 * s, py + 4 * s, 2 * s, 9 * s, C(0x5A5A62)); c.rect(px0 + 2 * s, py + 4 * s, 6 * s, 2 * s, C(0x6A6A72))   // a hammer
                c.rect(px0 + 12 * s, py + 3 * s, s, 11 * s, C(0xB8BCC4)); c.rect(px0 + 11 * s, py + 12 * s, 3 * s, 4 * s, C(0xC8302A))   // a screwdriver
                c.rect(px0 + 18 * s, py + 4 * s, 8 * s, 2 * s, C(0x7A5232)); c.rect(px0 + 24 * s, py + 3 * s, 3 * s, 4 * s, C(0x8A8E94))   // a saw
                c.rect(px0 + 18 * s, py + 9 * s, 9 * s, 6 * s, C(0x8A8E94)); c.rect(px0 + 19 * s, py + 10 * s, 7 * s, 4 * s, C(0x5A5E64))
            }
            // The joists and the bulb on its cord.
            c.rect(0, 0, c.w, 6 * s, C(0x4E3A28)); c.rect(0, 6 * s, c.w, s, C(0x2A1E14))
            for x in stride(from: 0, to: c.w, by: 16 * s) { c.rect(x, 0, 4 * s, 9 * s, C(0x6A5038)); c.rect(x, 0, s, 9 * s, C(0x8A6A48)) }
            let bulbX = c.w * 52 / 100
            c.rect(bulbX, 7 * s, s, 10 * s, C(0x2A2A2A)); c.rect(bulbX - s, 17 * s, 3 * s, 2 * s, C(0x8A8A90))
        }

        // The carpet: rust and plain, a lit edge where it meets the skirting, a few flecks.
        c.ground(g, C(0x5E4234), edge: C(0x7A5644), speck: C(0x523A2E), seed: 9)
    }

    /// The basement's life: the standing lamp flickering now and then, its glow soft round the shade; and the dice in
    /// their tray rattling every few seconds, as if somebody just shook the table. On the screen saver the bare bulb
    /// glows up by the joists.
    static func hawkinsBasementLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsBasementFrame(c, g)
        let flick = noise(Int(t * 14)) < 0.1 || (noise(Int(t * 3) + 500) < 0.08 && Int(t * 20) % 2 == 0)
        let l = f.lamp
        let lit = flick ? C(0xB8A880) : C(0xF6E6B8), litD = flick ? C(0x988A68) : C(0xE0C890)
        // The glow round the shade: faint rings, nothing that washes over the crew.
        if !flick {
            for (r, a) in [(16, 0.05), (11, 0.07), (7, 0.08)] { c.circle(l.x, l.y + 2 * s, r * s, C(0xFFD890, a)) }
        }
        for k in 0..<5 {
            let half = 3 * s + k * s / 2 + k / 2
            c.rect(l.x - half, l.y + k * s, 2 * half + s, s, k == 4 ? litD : lit)
        }
        c.rect(l.x - 2 * s, l.y - s, 5 * s, s, litD)
        // The dice in the tray: a red twenty-sider, a blue six and a green four, hopping when the table's knocked.
        let t0 = f.table, tx = t0.x + 18 * s, ty = t0.top - 2 * s
        let shaking = t.truncatingRemainder(dividingBy: 4.5) < 0.6
        let dice: [(dx: Int, col: Px, lite: Px)] = [(0, C(0xC8302A), C(0xF06A5A)), (2, C(0x3A6AC0), C(0x8AB0F0)), (4, C(0x3A9A4A), C(0x8AD08A))]
        for (k, d) in dice.enumerated() {
            let hop = shaking && Int(t * 16 + Double(k) * 1.7) % 2 == 0 ? s : 0
            c.rect(tx + d.dx * s, ty - s - hop, s * 2 - (k == 2 ? s : 0), s, d.col); c.px(tx + d.dx * s, ty - s - hop, d.lite)
        }
        if isTall(c) {
            let bulbX = c.w * 52 / 100
            for (r, a) in [(10, 0.05), (6, 0.08)] { c.circle(bulbX, 20 * s, r * s, C(0xFFE8A8, a)) }
            c.rect(bulbX - s, 19 * s, 3 * s, 3 * s, flick ? C(0xC8B888) : C(0xFFF4C8))
        }
    }
}
