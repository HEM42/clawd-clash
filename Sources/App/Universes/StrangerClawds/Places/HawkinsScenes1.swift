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
        return (g - 44 * s, 6 * s + 95 * s, (x: c.w * 38 / 100, top: g - 14 * s), c.w * 61 / 100,
                (x: c.w * 72 / 100, y: g - 27 * s), c.w * 86 / 100, [c.w * 34 / 100, c.w * 66 / 100])
    }

    /// The Wheelers' basement at night: wood panelling halfway up the walls and the painted block wall above it, two
    /// little windows high up at ground level with the grass outside against the night; the wooden stairs coming
    /// down on the left with their railing, boxes in the dark under them; the D&D game in full swing on a
    /// big folding table: Mike's screen standing up, maps and character sheets, the minis, snacks and soda, chairs
    /// pulled up round it; the old plaid couch with a crocheted blanket over its back and board games
    /// on a shelf above it; the standing lamp; and Eleven's blanket fort in the corner, made of sheets and blankets
    /// over two chairs, pillows inside. A rust carpet along the front where the crew stands. On the screen saver the
    /// room goes higher: the stairs climb to a landing and the door upstairs, and the rest of the basement shows (see
    /// `hawkinsBasementHigh`).
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
        let landing = tall ? 12 : 1000
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
            // The landing at the top, boarded in underneath like the stairs, and the door upstairs standing back from
            // the corner, its light spilling out underneath; the light switch beside it.
            let ly = g - landing * rise - rise, lx = f.stairs - landing * run - run
            c.rect(0, ly + 5 * s, lx + run, g - ly - 5 * s, C(0x3E2A1A))
            for x in stride(from: 4 * s, to: lx + run, by: 10 * s) { c.rect(x, ly + 8 * s, s, g - ly - 8 * s, C(0x2E1E12)) }
            c.rect(0, ly, lx + run, 2 * s, C(0xA87A4A)); c.rect(0, ly + 2 * s, lx + run, 3 * s, C(0x4E321E))
            let dx = max(6 * s, lx - 18 * s), dh = 24 * s
            c.rect(dx - s, ly - dh - s, 14 * s, dh + s, C(0xC8B89A))
            c.rect(dx, ly - dh, 12 * s, dh, C(0x7A5A3C)); c.rect(dx, ly - dh, s, dh, C(0x9A7650))
            c.rect(dx + 2 * s, ly - dh + 3 * s, 8 * s, 7 * s, C(0x6A4C32)); c.rect(dx + 2 * s, ly - dh + 13 * s, 8 * s, 8 * s, C(0x6A4C32))
            c.rect(dx + 9 * s, ly - dh + 12 * s, 2 * s, s, C(0xD8B048))
            c.rect(dx, ly - s, 12 * s, s, C(0xF8D88A))
            c.rect(dx + 15 * s, ly - 14 * s, 2 * s, 3 * s, C(0xE8E0CC)); c.px(dx + 15 * s, ly - 13 * s, C(0x5A5A60))
        }

        hawkinsDnD(c, f.table, s, g)

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

        if tall { hawkinsBasementHigh(c, g, s) }

        // The carpet: rust and plain, a lit edge where it meets the skirting, a few flecks.
        c.ground(g, C(0x5E4234), edge: C(0x7A5644), speck: C(0x523A2E), seed: 9)
    }

    /// The D&D game in full swing, the middle of the basement: a big folding table seen a little from above so the game
    /// on it shows, chairs pulled up at both ends and two more behind. On it, left to right: the rulebooks stacked
    /// up, a bowl of chips, a character sheet with its pencil, the graph-paper map with the painted minis on it and a
    /// tiny Demogorgon among them, soda cans, the dice tray (its dice in the moving layer), another sheet, and Mike's
    /// screen standing up at the far end. `t.top` is the table's front edge.
    private static func hawkinsDnD(_ c: PixelCanvas, _ t: (x: Int, top: Int), _ s: Int, _ g: Int) {
        let p = Pen(c, t.x, t.top, g)
        let chair = C(0x5A6A5A), chairD = C(0x3E4A3E), chairL = C(0x7A8A78)
        // The two chairs behind, only their backs showing over the table.
        for bx in [-20, 6] {
            p.rect(bx, -14, 7, 4, chair); p.rect(bx, -14, 7, 1, chairL); p.rect(bx + 6, -13, 1, 3, chairD)
            p.rect(bx + 1, -10, 1, 3, chairD); p.rect(bx + 5, -10, 1, 3, chairD)
        }
        // The top, its far edge in shade, wood grain in short strokes; the front edge lit, the legs, the underside dark.
        let top = C(0xA88052), topD = C(0x8E6A42), topL = C(0xC49A66)
        p.rect(-34, -7, 68, 7, top); p.rect(-33, -8, 66, 1, topD)
        for (k, gx) in [-30, -19, -6, 7, 18, 28].enumerated() { p.rect(gx, -6 + k % 3 * 2, 4 + k % 2 * 2, 1, topD) }
        p.rect(-34, 0, 68, 1, topL); p.rect(-34, 1, 68, 1, C(0x7A5A38)); p.rect(-34, 2, 68, 1, C(0x2E1E12))
        for lx in [-31, 29] { p.rect(lx, 3, 2, 11, C(0x6A6E72)); p.rect(lx, 3, 1, 11, C(0x8A8E94)) }
        for lx in [-26, 24] { p.rect(lx, 3, 1, 10, C(0x4A4E52)) }
        // The chairs at the ends, side on, turned to the table.
        for (cx, dir) in [(-43, 1), (36, -1)] {
            let back = dir > 0 ? cx : cx + 6
            p.rect(back, -9, 1, 23, chairD); p.rect(back - (dir > 0 ? 0 : 1), -10, 2, 6, chair); p.rect(back - (dir > 0 ? 0 : 1), -10, 2, 1, chairL)
            p.rect(cx, 3, 7, 2, chair); p.rect(cx, 3, 7, 1, chairL)
            p.rect(cx + (dir > 0 ? 6 : 0), 5, 1, 9, chairD)
        }

        // The graph-paper map, its pale blue squares, the dungeon's walls pencilled in.
        let paper = C(0xEDE8D6), grid = C(0xA8C0D8), pencil = C(0x4A4A52)
        p.rect(-12, -7, 21, 6, paper); p.rect(-12, -2, 21, 1, C(0xC8C2B0))
        for gx in stride(from: -11, to: 9, by: 2) { p.rect(gx, -7, 1, 5, grid) }
        p.rect(-12, -5, 21, 1, grid)
        p.rect(-10, -6, 6, 1, pencil); p.rect(-10, -6, 1, 3, pencil); p.rect(1, -4, 6, 1, pencil); p.rect(6, -6, 1, 3, pencil)
        // A second sheet, half under it, with another level drawn on.
        p.rect(-17, -6, 6, 4, paper); p.rect(-16, -5, 3, 1, pencil); p.rect(-16, -5, 1, 2, grid)
        // The painted minis on the map: a knight, a wizard in blue, a cleric in gold, an elf in green; and facing them a
        // tiny Demogorgon, its head open like a flower.
        for (mx, my, col) in [(-9, -3, C(0xC8C8D0)), (-7, -4, C(0x3A5AC0)), (-4, -3, C(0xD8B040)), (-2, -5, C(0x3A8A4A))] {
            p.rect(mx, my - 4, 1, 1, C(0xE8C0A0)); p.rect(mx, my - 3, 1, 3, col); p.rect(mx - 1, my - 2, 1, 1, col)
            p.rect(mx - 1, my, 3, 1, C(0x3A3A40))
        }
        p.rect(3, -8, 1, 1, C(0xD83A3A)); p.rect(5, -8, 1, 1, C(0xD83A3A)); p.rect(3, -7, 3, 1, C(0xA83A3A))
        p.rect(4, -6, 1, 2, C(0x6A5A58)); p.rect(3, -5, 1, 2, C(0x5A4A48)); p.rect(5, -5, 1, 2, C(0x5A4A48))
        p.rect(3, -3, 3, 1, C(0x3A3A40))
        // The rulebooks stacked at the end: the red one, the blue, the orange, each lit along its top and its pages
        // showing at the side.
        for (k, col) in [C(0x2E4A8A), C(0xA83A2A), C(0xD87A30)].enumerated() {
            let y = -3 - k * 2, bx = -32 + (k == 1 ? 1 : 0)
            p.rect(bx, y, 9, 2, col); p.rect(bx, y, 9, 1, lerp(col, C(0xFFFFFF), 0.3))
            p.rect(bx + 7, y + 1, 1, 1, C(0xE8E0C8))
        }
        // The bowl of chips, the soda cans: a red one, a green one and an orange one by the screen.
        p.rect(-22, -9, 7, 1, C(0xE8B840)); p.rect(-21, -10, 2, 1, C(0xD8902A)); p.rect(-18, -10, 2, 1, C(0xF0D060))
        p.rect(-22, -8, 7, 2, C(0x3A6A9A)); p.rect(-21, -6, 5, 1, C(0x2A4A70)); p.rect(-22, -8, 7, 1, C(0x5A8ABA))
        for (cx, cy, col) in [(-14, -2, C(0xC8302A)), (11, -5, C(0x2E8A4A)), (29, -2, C(0xE07A20))] {
            p.rect(cx, cy - 4, 2, 4, col); p.rect(cx, cy - 3, 2, 1, C(0xE8E4D8)); p.rect(cx, cy - 4, 2, 1, C(0xB8BCC4))
        }
        // The character sheets, lined, each with a pencil; a d20 and a d6 left out by them.
        for hx in [-23, 13] {
            p.rect(hx, -3, 8, 3, C(0xF4F0E4)); p.rect(hx + 1, -2, 6, 1, C(0xA8A49A)); p.rect(hx + 1, -3, 3, 1, C(0x5A5A60))
        }
        p.rect(-22, -1, 5, 1, C(0xE8C040)); p.rect(-17, -1, 1, 1, C(0xE8A0A0))
        p.rect(17, -1, 4, 1, C(0xE8C040))
        p.rect(-11, -2, 2, 2, C(0x7A3AB0)); p.rect(-11, -2, 1, 1, C(0xB07AE0))
        // The dice tray, its dice drawn in the moving layer.
        p.rect(19, -3, 7, 3, C(0x3A2216)); p.rect(19, -3, 7, 1, C(0x5A3A26)); p.rect(20, -2, 5, 1, C(0x2A160E))
        // Mike's screen: three panels standing up, each with its painting (a red dragon, a castle, a wizard), the
        // folds between them in shade.
        let sx = 13
        p.rect(sx, -14, 17, 10, C(0x8A2A2E)); p.rect(sx, -14, 17, 1, C(0xC04A3E)); p.rect(sx, -5, 17, 1, C(0x5A1A1E))
        p.rect(sx + 5, -14, 1, 10, C(0x5A1A1E)); p.rect(sx + 11, -14, 1, 10, C(0x5A1A1E))
        p.rect(sx + 1, -12, 4, 5, C(0x2A1A2A)); p.rect(sx + 1, -10, 3, 2, C(0xD83A2A)); p.rect(sx + 3, -11, 2, 1, C(0xF0A040))
        p.rect(sx + 6, -12, 5, 5, C(0x5A7AB0)); p.rect(sx + 7, -10, 3, 3, C(0x9A9AA0)); p.rect(sx + 7, -11, 1, 1, C(0x9A9AA0)); p.rect(sx + 9, -11, 1, 1, C(0x9A9AA0))
        p.rect(sx + 12, -12, 4, 5, C(0x2A3A2A)); p.rect(sx + 13, -11, 2, 4, C(0x4A3AA0)); p.rect(sx + 13, -12, 2, 1, C(0xE8E0C8))
    }

    /// The rest of the basement, high up the wall on the screen saver, as it would be in 1983: a few short shelves of
    /// odds and ends (paint tins, a box of Christmas things spilling tinsel and lights, a box of old toys, a fan, the
    /// old TV and a suitcase, boxes of every size); the BMX hung up for the winter under a pegboard of tools, the sled
    /// on its hooks, a coil of Christmas lights on a nail; and on the raised concrete at the back, the laundry corner
    /// with its washer, basket and line of washing, the water heater and the furnace, a light-up Santa waiting for
    /// December, with the Christmas things and the camping gear on shelves above. The fuse box by the door; ducts and pipes along under the joists, old boards and fishing rods
    /// put away up there, the shop light and the bare bulb hanging from them.
    private static func hawkinsBasementHigh(_ c: PixelCanvas, _ g: Int, _ s: Int) {
        let w = c.w, f = hawkinsBasementFrame(c, g)
        let tape = C(0xC8B88A), marker = C(0x2A2A2A)
        /// A cardboard box standing on `y`: lit along its top, shaded down its right side, taped, written on.
        func box(_ x: Int, _ y: Int, _ bw: Int, _ bh: Int, _ tone: Px, label: Bool = true) {
            c.rect(x, y - bh * s, bw * s, bh * s, tone); c.rect(x, y - bh * s, bw * s, s, lerp(tone, C(0xFFFFFF), 0.2))
            c.rect(x + (bw - 1) * s, y - bh * s, s, bh * s, lerp(tone, C(0x000000), 0.3))
            c.rect(x + bw / 2 * s, y - bh * s, s, 2 * s, tape)
            if label && bh >= 5 { c.rect(x + 2 * s, y - (bh - 3) * s, min(bw - 4, 5) * s, s, marker) }
        }
        /// A shelf board on its two brackets, `bw` units long.
        func board(_ x: Int, _ y: Int, _ bw: Int) {
            c.rect(x, y, bw * s, 2 * s, C(0x9A7A52)); c.rect(x, y, bw * s, s, C(0xB89668)); c.rect(x, y + 2 * s, bw * s, s, C(0x3E3A34))
            for bx in [x + 3 * s, x + (bw - 5) * s] { c.rect(bx, y + 2 * s, 2 * s, 4 * s, C(0x5A5E64)); c.rect(bx, y + 2 * s, s, 4 * s, C(0x7A7E84)) }
        }
        /// A paint tin with its coloured label and a drip down the side.
        func tin(_ x: Int, _ y: Int, _ col: Px) {
            c.rect(x, y - 6 * s, 5 * s, 6 * s, C(0x9AA0A8)); c.rect(x, y - 6 * s, 5 * s, s, C(0xC8CCD2)); c.rect(x + 4 * s, y - 5 * s, s, 5 * s, C(0x6A7078))
            c.rect(x, y - 4 * s, 5 * s, 2 * s, col); c.rect(x + s, y - 5 * s, s, s, col)
        }

        // Under the joists: the copper water pipe and the black gas pipe on their straps, and the furnace's big duct.
        let duct = C(0x9AA0A6), ductD = C(0x6E747A), ductL = C(0xC0C6CC)
        c.rect(0, 10 * s, w, 2 * s, C(0xB06A3E)); c.rect(0, 10 * s, w, s, C(0xD48A56))
        c.rect(0, 14 * s, w * 60 / 100, 2 * s, C(0x2A2A2E)); c.rect(0, 14 * s, w * 60 / 100, s, C(0x4A4A50))
        for x in stride(from: 12 * s, to: w, by: 40 * s) { c.rect(x, 7 * s, s, 9 * s, C(0x5A5A60)) }
        let trunk = w * 58 / 100
        c.rect(trunk, 9 * s, w - trunk, 10 * s, duct); c.rect(trunk, 9 * s, w - trunk, s, ductL); c.rect(trunk, 18 * s, w - trunk, s, ductD)
        for x in stride(from: trunk + 14 * s, to: w, by: 18 * s) { c.rect(x, 9 * s, s, 10 * s, ductD) }   // the seams
        c.rect(trunk, 9 * s, s, 10 * s, ductD)

        // The fuse box just past the door's light switch (the door stands 18 units back from the landing's top step,
        // which is 52 units up), its conduit running up the wall.
        let fb = max(6 * s, f.stairs - 83 * s) + 20 * s, fby = g - 75 * s
        c.rect(fb + 4 * s, 19 * s, s, fby - 19 * s, C(0x7A7E84))
        c.rect(fb, fby, 10 * s, 12 * s, C(0x8A8E94)); c.rect(fb, fby, 10 * s, s, C(0xB8BCC4)); c.rect(fb + 9 * s, fby, s, 12 * s, C(0x5A5E64))
        c.rect(fb + 2 * s, fby + 3 * s, 6 * s, 6 * s, C(0x6A6E74)); c.rect(fb + 7 * s, fby + 5 * s, s, 2 * s, C(0x2A2A2E))

        // The raised concrete at the back, along the right: its top lit, its face cracked.
        let ledge = g - 96 * s, lx = w * 50 / 100
        c.rect(lx, ledge, w - lx, 9 * s, C(0x8A867C)); c.rect(lx, ledge, w - lx, 2 * s, C(0xA8A49A))
        c.rect(lx, ledge + 9 * s, w - lx, s, C(0x4E4A44)); c.rect(lx, ledge, s, 9 * s, C(0xA8A49A))
        for (k, x) in stride(from: lx + 9 * s, to: w, by: 31 * s).enumerated() {
            c.rect(x, ledge + 3 * s, s, 2 * s, C(0x6A665E)); c.rect(x + s, ledge + (5 + k % 2) * s, s, 2 * s, C(0x6A665E))
        }

        // The laundry corner: the washer with its knobs on the back panel and a box of soap powder on the lid, the
        // basket of washing beside it, and the line strung above with the washing pegged out.
        let wx = w * 52 / 100
        let enamel = C(0xE4E0D4), enamelD = C(0xB4B0A4)
        c.rect(wx, ledge - 18 * s, 16 * s, 18 * s, enamel); c.rect(wx + 15 * s, ledge - 18 * s, s, 18 * s, enamelD)
        c.rect(wx, ledge - 22 * s, 16 * s, 4 * s, C(0xC8C4B8)); c.rect(wx, ledge - 22 * s, 16 * s, s, C(0xF0ECE0))
        c.rect(wx + 3 * s, ledge - 20 * s, 2 * s, s, C(0x3A3A40)); c.rect(wx + 11 * s, ledge - 20 * s, 2 * s, s, C(0x3A3A40)); c.rect(wx + 7 * s, ledge - 21 * s, 2 * s, 2 * s, C(0xC8302A))
        c.rect(wx + s, ledge - 15 * s, 14 * s, s, enamelD); c.rect(wx + 6 * s, ledge - 14 * s, 4 * s, s, C(0x8A8A90))
        c.rect(wx, ledge - s, 16 * s, s, C(0x5A5A60))
        c.rect(wx + 2 * s, ledge - 23 * s, 4 * s, 5 * s, C(0xE07A20)); c.rect(wx + 2 * s, ledge - 21 * s, 4 * s, s, C(0x2E5AA0))
        let bkx = wx + 18 * s
        c.rect(bkx, ledge - 6 * s, 10 * s, 6 * s, C(0xC8A870)); c.rect(bkx, ledge - 6 * s, 10 * s, s, C(0xE0C890))
        for k in stride(from: 1, to: 10, by: 2) { c.rect(bkx + k * s, ledge - 5 * s, s, 5 * s, C(0xA88A54)) }
        c.rect(bkx + s, ledge - 8 * s, 4 * s, 2 * s, C(0x5A8AC8)); c.rect(bkx + 5 * s, ledge - 7 * s, 4 * s, s, C(0xE8A0B0))
        // The line, sagging a little between its hooks, and the washing on it: a striped shirt, a towel, socks.
        let hx = w * 64 / 100
        let lineY = ledge - 36 * s, la = lx + 2 * s, lb = hx - 3 * s
        for x in la..<lb {
            let k = Double(x - la) / Double(max(1, lb - la))
            c.px(x, lineY + Int((sin(k * .pi) * Double(2 * s)).rounded()), C(0xD8D4C8))
        }
        c.rect(la - s, lineY - s, s, 3 * s, C(0x5A5A60)); c.rect(lb, lineY - s, s, 3 * s, C(0x5A5A60))
        func sag(_ x: Int) -> Int { lineY + Int((sin(Double(x - la) / Double(max(1, lb - la)) * .pi) * Double(2 * s)).rounded()) }
        let shirt = la + 4 * s, sy = sag(shirt + 4 * s) + s
        c.rect(shirt, sy, 9 * s, 3 * s, C(0xE8E4DA)); c.rect(shirt + 2 * s, sy + 3 * s, 5 * s, 5 * s, C(0xE8E4DA))
        for k in [1, 4, 7] { c.rect(shirt + 2 * s, sy + k * s, 5 * s, s, C(0x2E5AA0)) }
        c.rect(shirt, sy + s, 9 * s, s, C(0xC8302A))
        let towel = shirt + 12 * s, ty = sag(towel + 3 * s) + s
        c.rect(towel, ty, 7 * s, 10 * s, C(0xD8B040)); c.rect(towel, ty + 7 * s, 7 * s, s, C(0xE8E0C0)); c.rect(towel + 6 * s, ty, s, 10 * s, C(0xB08A2A))
        for k in 0..<2 { let kx = towel + (10 + k * 3) * s; c.rect(kx, sag(kx) + s, s, 5 * s, C(0xF0F0EC)); c.rect(kx, sag(kx) + 2 * s, s, s, C(0xC8302A)); c.rect(kx + s, sag(kx) + 5 * s, s, s, C(0xF0F0EC)) }

        // The water heater: a cream drum, lit on the left, its domed top, the burner's little door at the foot and the
        // pipes and flue going up to the joists.
        c.rect(hx + 5 * s, 19 * s, 2 * s, ledge - 32 * s - 19 * s, C(0x7A7E84))
        c.rect(hx + 2 * s, 12 * s, s, ledge - 30 * s - 12 * s, C(0xB06A3E)); c.rect(hx + 9 * s, 12 * s, s, ledge - 30 * s - 12 * s, C(0xB06A3E))
        c.rect(hx, ledge - 30 * s, 12 * s, 30 * s, C(0xD8D0B8)); c.rect(hx + s, ledge - 31 * s, 10 * s, s, C(0xD8D0B8))
        c.rect(hx, ledge - 30 * s, 2 * s, 30 * s, C(0xEEE8D4)); c.rect(hx + 10 * s, ledge - 30 * s, 2 * s, 30 * s, C(0xA8A08A))
        c.rect(hx + 3 * s, ledge - 22 * s, 5 * s, 3 * s, C(0xC8302A)); c.rect(hx + 4 * s, ledge - 21 * s, 3 * s, s, C(0xF0E0C0))
        c.rect(hx + 4 * s, ledge - 5 * s, 4 * s, 3 * s, C(0x2A2A2E)); c.rect(hx, ledge - s, 12 * s, s, C(0x5A5A60))

        // The furnace: a big brown cabinet with its panels, the grille at the foot, a little window on the flame, and
        // the duct off its top up to the trunk under the joists.
        let fx = w * 78 / 100
        let fur = C(0x8A7A5A), furD = C(0x5E5240), furL = C(0xA8987A)
        c.rect(fx + 8 * s, 19 * s, 10 * s, ledge - 46 * s - 19 * s, duct); c.rect(fx + 8 * s, 19 * s, 2 * s, ledge - 46 * s - 19 * s, ductL)
        c.rect(fx + 16 * s, 19 * s, 2 * s, ledge - 46 * s - 19 * s, ductD)
        c.rect(fx - s, ledge - 46 * s, 28 * s, 10 * s, duct); c.rect(fx - s, ledge - 46 * s, 28 * s, s, ductL); c.rect(fx + 25 * s, ledge - 46 * s, 2 * s, 10 * s, ductD)
        c.rect(fx, ledge - 36 * s, 26 * s, 36 * s, fur); c.rect(fx, ledge - 36 * s, 2 * s, 36 * s, furL); c.rect(fx + 24 * s, ledge - 36 * s, 2 * s, 36 * s, furD)
        c.rect(fx + 2 * s, ledge - 20 * s, 22 * s, s, furD); c.rect(fx + 12 * s, ledge - 36 * s, s, 16 * s, furD)
        for k in 0..<4 { c.rect(fx + 5 * s, ledge - (16 - k * 3) * s, 16 * s, s, C(0x2E2620)) }
        c.rect(fx + 15 * s, ledge - 28 * s, 5 * s, 3 * s, C(0x1A1410))   // the flame's window, lit in the moving layer
        c.rect(fx + 4 * s, ledge - 30 * s, 5 * s, 2 * s, C(0xC8B888))
        c.rect(fx, ledge - s, 26 * s, s, C(0x3A3228))
        // A light-up Santa waiting for December, at the end.
        let sx = w * 92 / 100
        c.rect(sx + s, ledge - 14 * s, 6 * s, 11 * s, C(0xC8302A)); c.rect(sx, ledge - 9 * s, 8 * s, 6 * s, C(0xC8302A))
        c.rect(sx + 2 * s, ledge - 13 * s, 4 * s, 3 * s, C(0xF0C8A8)); c.rect(sx + 2 * s, ledge - 11 * s, 4 * s, 2 * s, C(0xF4F4F0))
        c.rect(sx + 2 * s, ledge - 16 * s, 4 * s, 2 * s, C(0xC8302A)); c.rect(sx + 5 * s, ledge - 17 * s, 2 * s, 2 * s, C(0xF4F4F0))
        c.rect(sx, ledge - 7 * s, 8 * s, s, C(0x2A2A2E)); c.rect(sx + 3 * s, ledge - 7 * s, 2 * s, s, C(0xE8C040))
        c.rect(sx + s, ledge - 3 * s, 2 * s, 3 * s, C(0x2A2A2E)); c.rect(sx + 5 * s, ledge - 3 * s, 2 * s, 3 * s, C(0x2A2A2E))
        c.rect(sx + 6 * s, ledge - 14 * s, s, 11 * s, C(0x8A1E1A))

        // The low shelves: paint tins, the Christmas box spilling tinsel and a string of lights, a small box; above,
        // the box fan, the box of old toys (a teddy, a ball, a toy truck) and two boxes.
        let ax = w * 25 / 100, a1 = g - 84 * s, a2 = g - 118 * s
        board(ax, a1, 54); board(ax, a2, 54)
        tin(ax + 2 * s, a1, C(0xC04A3A)); tin(ax + 8 * s, a1, C(0x3A6AB0)); tin(ax + 14 * s, a1, C(0xE8E0C8))
        box(ax + 21 * s, a1, 16, 10, C(0xB08A5A), label: false)
        c.rect(ax + 23 * s, a1 - 8 * s, 6 * s, 2 * s, C(0xC8302A)); c.rect(ax + 30 * s, a1 - 8 * s, 5 * s, 2 * s, C(0x2E8A4A))   // XMAS, in red and green
        for k in 0..<7 { c.rect(ax + (22 + k * 2) * s, a1 - (11 + k % 2) * s, s, 2 * s, [C(0xD8C040), C(0xC8D0D8)][k % 2]) }   // the tinsel
        for k in 0..<6 {   // the lights hanging over the front
            let lxp = ax + (36 + k * 2) * s, ly = a1 + (1 + (k % 3 == 1 ? 1 : 0) + k / 2) * s
            c.px(lxp, ly, C(0x2E4A2E)); c.rect(lxp, ly + s, s, s, [C(0xE83A3A), C(0x3AC85A), C(0x4A7AE8), C(0xF0C040)][k % 4])
        }
        box(ax + 41 * s, a1, 10, 6, C(0xA07A4E))
        // The box fan: a grey frame, the dark grille and its blades.
        c.rect(ax + 2 * s, a2 - 13 * s, 13 * s, 13 * s, C(0x8A8E94)); c.rect(ax + 3 * s, a2 - 12 * s, 11 * s, 11 * s, C(0x2E3034))
        for k in 0..<5 { c.px(ax + (5 + k) * s, a2 - (10 - k) * s, C(0x9AA0A8)); c.px(ax + (5 + k) * s, a2 - (3 + k) * s, C(0x9AA0A8)) }
        c.rect(ax + 8 * s, a2 - 7 * s, s, s, C(0xC8CCD2)); c.rect(ax + 2 * s, a2 - 13 * s, 13 * s, s, C(0xB8BCC4))
        // The toys box, open: a teddy's head and ears, a red ball, the yellow truck's cab.
        let tb = ax + 17 * s
        c.rect(tb + 2 * s, a2 - 12 * s, 5 * s, 4 * s, C(0x9A6A3A)); c.rect(tb + 2 * s, a2 - 13 * s, s, s, C(0x9A6A3A)); c.rect(tb + 6 * s, a2 - 13 * s, s, s, C(0x9A6A3A))
        c.px(tb + 3 * s, a2 - 11 * s, C(0x1A1A1A)); c.px(tb + 5 * s, a2 - 11 * s, C(0x1A1A1A)); c.rect(tb + 4 * s, a2 - 10 * s, s, s, C(0x3A2A1A))
        c.rect(tb + 9 * s, a2 - 11 * s, 3 * s, 3 * s, C(0xD83A3A)); c.px(tb + 9 * s, a2 - 11 * s, C(0xF08A7A))
        c.rect(tb + 13 * s, a2 - 10 * s, 3 * s, 2 * s, C(0xE8C030))
        box(tb, a2, 17, 8, C(0x9A7448), label: false)
        c.rect(tb + 3 * s, a2 - 5 * s, 6 * s, s, marker)
        box(ax + 36 * s, a2, 9, 7, C(0xB08A5A)); box(ax + 45 * s, a2, 7, 5, C(0x8E6A42)); box(ax + 37 * s, a2 - 7 * s, 7, 4, C(0xA07A4E), label: false)

        // The high shelves: the old TV in its wood cabinet with its rabbit ears, a suitcase, boxes; and above, more
        // boxes of every size.
        let bx = w * 33 / 100, b1 = g - 152 * s, b2 = g - 186 * s
        if b1 > 30 * s {
            board(bx, b1, 50)
            c.rect(bx + 2 * s, b1 - 13 * s, 18 * s, 13 * s, C(0x6A4428)); c.rect(bx + 2 * s, b1 - 13 * s, 18 * s, s, C(0x8A603E))
            c.rect(bx + 4 * s, b1 - 11 * s, 11 * s, 9 * s, C(0x3A4440)); c.rect(bx + 5 * s, b1 - 10 * s, 3 * s, s, C(0x7A8A84))
            c.rect(bx + 16 * s, b1 - 11 * s, 2 * s, 2 * s, C(0xC8C0A8)); c.rect(bx + 16 * s, b1 - 7 * s, 2 * s, 2 * s, C(0xC8C0A8))
            for k in 0..<6 { c.px(bx + (9 - k) * s, b1 - (14 + k) * s, C(0xB8BCC4)); c.px(bx + (13 + k) * s, b1 - (14 + k) * s, C(0xB8BCC4)) }
            c.rect(bx + 22 * s, b1 - 9 * s, 14 * s, 9 * s, C(0x7A4A2A)); c.rect(bx + 22 * s, b1 - 9 * s, 14 * s, s, C(0x9A6A42))
            c.rect(bx + 27 * s, b1 - 11 * s, 4 * s, 2 * s, C(0x3A2416)); c.rect(bx + 24 * s, b1 - 6 * s, 2 * s, 2 * s, C(0xD8B040)); c.rect(bx + 32 * s, b1 - 6 * s, 2 * s, 2 * s, C(0xD8B040))
            box(bx + 38 * s, b1, 10, 12, C(0xA07A4E))
        }
        if b2 > 26 * s {
            board(bx, b2, 50)
            box(bx + 2 * s, b2, 14, 10, C(0xB08A5A)); box(bx + 17 * s, b2, 9, 6, C(0x8E6A42)); box(bx + 27 * s, b2, 12, 8, C(0xA07A4E))
            c.rect(bx + 29 * s, b2 - 6 * s, 6 * s, 3 * s, C(0xF0ECE0))   // a white label
            box(bx + 40 * s, b2, 8, 11, C(0x9A7448))
        }

        // Over the laundry, a long shelf of Christmas things: the artificial tree in its long box, a box of baubles
        // with one on top, a wreath; and over the end of the concrete, a shelf of camping gear: the cooler, a lantern,
        // sleeping bags rolled up.
        let cx0 = w * 50 / 100, c1 = ledge - 62 * s
        if c1 > 30 * s {
            board(cx0, c1, 56)
            box(cx0 + 2 * s, c1, 26, 6, C(0xC8C0B0), label: false)
            c.rect(cx0 + 4 * s, c1 - 4 * s, 6 * s, 2 * s, C(0x2E7A3A)); c.rect(cx0 + 5 * s, c1 - 5 * s, 4 * s, s, C(0x2E7A3A)); c.rect(cx0 + 6 * s, c1 - 2 * s, s, s, C(0x6A4428))
            c.rect(cx0 + 12 * s, c1 - 4 * s, 12 * s, 2 * s, C(0xC8302A))
            box(cx0 + 30 * s, c1, 12, 7, C(0xB08A5A), label: false)
            for (k, col) in [C(0xE83A3A), C(0x3AC85A), C(0xF0C040), C(0x4A7AE8)].enumerated() { c.rect(cx0 + (31 + k * 3) * s, c1 - 9 * s, 2 * s, 2 * s, col) }
            c.circle(cx0 + 49 * s, c1 - 7 * s, 5 * s, C(0x2E6A34)); c.circle(cx0 + 49 * s, c1 - 7 * s, 2 * s, C(0x8C8478))
            c.rect(cx0 + 48 * s, c1 - 12 * s, 3 * s, 2 * s, C(0xC8302A)); c.px(cx0 + 46 * s, c1 - 8 * s, C(0xC8302A)); c.px(cx0 + 52 * s, c1 - 6 * s, C(0xC8302A))
        }
        let ex = w * 86 / 100, e1 = ledge - 58 * s
        if e1 > 30 * s && ex + 40 * s <= w {
            board(ex, e1, 40)
            c.rect(ex + 2 * s, e1 - 9 * s, 14 * s, 9 * s, C(0x2E7A4A)); c.rect(ex + 2 * s, e1 - 9 * s, 14 * s, 2 * s, C(0xE8E4D8)); c.rect(ex + 15 * s, e1 - 7 * s, s, 7 * s, C(0x1E5A34))
            c.rect(ex + 6 * s, e1 - 11 * s, 6 * s, s, C(0x3A3A40))
            c.rect(ex + 19 * s, e1 - 8 * s, 5 * s, 8 * s, C(0x2E5A3A)); c.rect(ex + 20 * s, e1 - 6 * s, 3 * s, 3 * s, C(0xF0E0A0)); c.rect(ex + 20 * s, e1 - 10 * s, 3 * s, 2 * s, C(0x5A5A60))
            for (k, col) in [C(0xD87A30), C(0x3A5A8A)].enumerated() {
                let rx = ex + (26 + k * 6) * s
                c.rect(rx, e1 - 6 * s, 6 * s, 6 * s, col); c.rect(rx + 2 * s, e1 - 4 * s, 2 * s, 2 * s, lerp(col, C(0x000000), 0.35)); c.rect(rx, e1 - 6 * s, 6 * s, s, lerp(col, C(0xFFFFFF), 0.25))
            }
        }
        // High on the left, over the pegboard: an old suitcase and a box of Mike's baby things, and a pennant.
        let hy = g - 192 * s
        if hy > 26 * s {
            let hx0 = w * 4 / 100
            board(hx0, hy, 40)
            c.rect(hx0 + 2 * s, hy - 10 * s, 16 * s, 10 * s, C(0x3A5A7A)); c.rect(hx0 + 2 * s, hy - 10 * s, 16 * s, s, C(0x5A7A9A)); c.rect(hx0 + 8 * s, hy - 12 * s, 4 * s, 2 * s, C(0x2A2A2E))
            c.rect(hx0 + 2 * s, hy - 6 * s, 16 * s, s, C(0x2A3A4A))
            box(hx0 + 20 * s, hy, 16, 9, C(0xA07A4E))
        }

        // On the left, above the landing: the sled on its hooks, the BMX hung up for the winter, the pegboard of tools
        // and a coil of Christmas lights on a nail.
        let sl = w * 15 / 100, sly = g - 72 * s
        if sly > 30 * s {
            c.rect(sl + 2 * s, sly - 4 * s, s, 2 * s, C(0x5A5A60)); c.rect(sl + 26 * s, sly - 4 * s, s, 2 * s, C(0x5A5A60))
            c.rect(sl, sly - 2 * s, 30 * s, 3 * s, C(0xB08A5A)); c.rect(sl, sly - 2 * s, 30 * s, s, C(0xD0A874))
            for k in stride(from: 4, to: 30, by: 6) { c.rect(sl + k * s, sly - 2 * s, s, 3 * s, C(0x8A6A42)) }
            c.rect(sl + 2 * s, sly + 2 * s, 28 * s, s, C(0xC8302A)); c.rect(sl + 30 * s, sly - s, s, 3 * s, C(0xC8302A)); c.px(sl + 31 * s, sly - 2 * s, C(0xC8302A))
            c.rect(sl + 22 * s, sly - 4 * s, 7 * s, s, C(0x3A2A1A))
            c.rect(sl + 6 * s, sly - s, 14 * s, s, C(0xC8302A))   // the name painted on the deck
        }
        let bmx = w * 10 / 100, by = g - 112 * s
        if by > 40 * s {
            c.rect(bmx - s, by - 9 * s, s, 3 * s, C(0x5A5A60)); c.rect(bmx + 15 * s, by - 9 * s, s, 3 * s, C(0x5A5A60))
            for wxp in [bmx, bmx + 16 * s] {
                c.circle(wxp, by, 6 * s, C(0x1E1E22)); c.circle(wxp, by, 5 * s, C(0x8C8478)); c.circle(wxp, by, s, C(0xA8ACB4))
                for a in 0..<6 { let r = Double(a) * .pi / 3; c.px(wxp + Int(cos(r) * Double(3 * s)), by + Int(sin(r) * Double(3 * s)), C(0xA8ACB4)) }
            }
            for k in 0...(8 * s) {   // the frame: down tube, top tube and the forks, red
                c.rect(bmx + k, by - k / 2, s, s, C(0xC8302A)); c.rect(bmx + 8 * s + k, by - 4 * s, s, s, C(0xC8302A))
                c.rect(bmx + 16 * s - k / 3, by - k, s, s, C(0xC8302A))
            }
            c.rect(bmx + 6 * s, by - 6 * s, 4 * s, s, C(0x1E1E22)); c.rect(bmx + 12 * s, by - 9 * s, 6 * s, s, C(0x6A6A72))
        }
        let py = g - 150 * s
        if py > 30 * s {
            let pw = 34 * s, px0 = w * 4 / 100
            c.rect(px0, py, pw, 20 * s, C(0xB89A6A)); c.rect(px0, py, pw, s, C(0xD0B484)); c.rect(px0 + pw - s, py, s, 20 * s, C(0x8A7048))
            for yy in stride(from: py + 2 * s, to: py + 20 * s, by: 3 * s) { for xx in stride(from: px0 + 2 * s, to: px0 + pw, by: 3 * s) { c.rect(xx, yy, s, s, C(0x8A7048)) } }
            c.rect(px0 + 4 * s, py + 4 * s, 2 * s, 9 * s, C(0x5A5A62)); c.rect(px0 + 2 * s, py + 4 * s, 6 * s, 2 * s, C(0x6A6A72))   // a hammer
            c.rect(px0 + 12 * s, py + 3 * s, s, 11 * s, C(0xB8BCC4)); c.rect(px0 + 11 * s, py + 12 * s, 3 * s, 4 * s, C(0xC8302A))   // a screwdriver
            c.rect(px0 + 18 * s, py + 4 * s, 8 * s, 2 * s, C(0x7A5232)); c.rect(px0 + 24 * s, py + 3 * s, 3 * s, 4 * s, C(0x8A8E94))   // a saw
            c.rect(px0 + 18 * s, py + 9 * s, 9 * s, 6 * s, C(0x8A8E94)); c.rect(px0 + 19 * s, py + 10 * s, 7 * s, 4 * s, C(0x5A5E64))
            // The coil of Christmas lights beside it, hung on a nail.
            let cx = px0 + pw + 10 * s, cy = py + 9 * s
            c.rect(cx, cy - 8 * s, s, s, C(0x5A5A60))
            for k in 0..<20 {
                let a = Double(k) / 20 * 2 * .pi
                let x = cx + Int((sin(a) * Double(6 * s)).rounded()), y = cy + Int((-cos(a) * Double(7 * s)).rounded())
                c.rect(x, y, s, s, C(0x2E4A2E))
                if k % 3 == 0 { c.rect(x, y + s, s, s, [C(0xE83A3A), C(0x3AC85A), C(0x4A7AE8), C(0xF0C040)][k / 3 % 4]) }
            }
        }

        // Things put away up in the joists: old boards and fishing rods laid across the straps over the left, and the
        // shop light hanging on its chains, switched off.
        c.rect(w * 3 / 100, 17 * s, w * 40 / 100, 2 * s, C(0x9A7A52)); c.rect(w * 3 / 100, 17 * s, w * 40 / 100, s, C(0xB89668))
        c.rect(w * 6 / 100, 19 * s, w * 30 / 100, 2 * s, C(0x7A5A3A))
        for k in 0..<2 { c.rect(w * 8 / 100, (22 + k * 2) * s, w * 26 / 100, s, C(0x3A3A40)) }
        c.rect(w * 34 / 100 - 2 * s, 21 * s, 3 * s, 4 * s, C(0xC8C0A8))   // a reel
        for k in stride(from: 4 * s, through: w * 40 / 100 - 4 * s, by: w * 18 / 100) { c.rect(w * 3 / 100 + k, 16 * s, s, 9 * s, C(0x5A5A60)) }
        let sl0 = w * 38 / 100
        if g - 200 * s > 40 * s {   // only where there's room over the high shelves
            c.rect(sl0 + 2 * s, 19 * s, s, 12 * s, C(0x5A5A60)); c.rect(sl0 + 22 * s, 19 * s, s, 12 * s, C(0x5A5A60))
            c.rect(sl0, 31 * s, 25 * s, 3 * s, C(0x8A8E94)); c.rect(sl0 + s, 34 * s, 23 * s, s, C(0xE0E4E0)); c.rect(sl0, 31 * s, 25 * s, s, C(0xB8BCC4))
        }
        // The joists and the bulb on its cord.
        c.rect(0, 0, w, 6 * s, C(0x4E3A28)); c.rect(0, 6 * s, w, s, C(0x2A1E14))
        for x in stride(from: 0, to: w, by: 16 * s) { c.rect(x, 0, 4 * s, 9 * s, C(0x6A5038)); c.rect(x, 0, s, 9 * s, C(0x8A6A48)) }
        let bulbX = w * 52 / 100
        c.rect(bulbX, 7 * s, s, 10 * s, C(0x2A2A2A)); c.rect(bulbX - s, 17 * s, 3 * s, 2 * s, C(0x8A8A90))
    }

    /// The basement's life: the standing lamp flickering now and then, its glow soft round the shade; and the dice in
    /// their tray rattling every few seconds, as if somebody just shook the table, and a die thrown across the map now and
    /// then. On the screen saver the bare bulb glows up by the joists and the furnace's flame flickers.
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
        let t0 = f.table, tx = t0.x + 20 * s, ty = t0.top - 2 * s
        let shaking = t.truncatingRemainder(dividingBy: 4.5) < 0.6
        let dice: [(dx: Int, col: Px, lite: Px)] = [(0, C(0xC8302A), C(0xF06A5A)), (2, C(0x3A6AC0), C(0x8AB0F0)), (4, C(0x3A9A4A), C(0x8AD08A))]
        for (k, d) in dice.enumerated() {
            let hop = shaking && Int(t * 16 + Double(k) * 1.7) % 2 == 0 ? s : 0
            c.rect(tx + d.dx * s, ty - s - hop, s * 2 - (k == 2 ? s : 0), s, d.col); c.px(tx + d.dx * s, ty - s - hop, d.lite)
        }
        // A white d20 thrown across the map every few seconds, tumbling (its lit face moving round) and hopping, then
        // lying where it stopped until the next throw sends it back the other way.
        let throwN = Int(t / 6), k = min(1, t.truncatingRemainder(dividingBy: 6) / 0.9)
        let (from, to) = throwN % 2 == 0 ? (-6, 7) : (7, -6)
        let rx = t0.x + Int((Double(from) + Double(to - from) * (1 - (1 - k) * (1 - k))) * Double(s))
        let ry = t0.top - 3 * s - Int((abs(sin(k * .pi * 3)) * (1 - k) * 3).rounded()) * s
        c.rect(rx, ry - s, 2 * s, 2 * s, C(0xE8E8F0)); c.rect(rx + (Int(k * 9) % 2) * s, ry - s + (Int(k * 7) % 2) * s, s, s, C(0x7A7A90))
        if isTall(c) {
            let bulbX = c.w * 52 / 100
            for (r, a) in [(10, 0.05), (6, 0.08)] { c.circle(bulbX, 20 * s, r * s, C(0xFFE8A8, a)) }
            c.rect(bulbX - s, 19 * s, 3 * s, 3 * s, flick ? C(0xC8B888) : C(0xFFF4C8))
            // The furnace's flame through its little window.
            let fx = c.w * 78 / 100, fy = g - 96 * s - 27 * s
            c.rect(fx + 16 * s, fy, 3 * s, s, noise(Int(t * 8)) < 0.5 ? C(0xF0902A) : C(0x4A7AE8))
            c.px(fx + 17 * s, fy - s, C(0xF8C050))
        }
    }
}
