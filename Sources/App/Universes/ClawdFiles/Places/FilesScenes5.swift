import Foundation

// In the city: the quarantine railcar, Tooms's apartment block, the autopsy bay and the Reflecting Pool.

let filesScenes5: [Location: Place] = [
    .quarantineCar: Place(name: "The Quarantine Railcar", panel: 0x141810, still: Scenes.quarantineCar, moving: Scenes.quarantineCarLife),
    .toomsBlock: Place(name: "Tooms's Apartment Block", panel: 0x10121A, still: Scenes.toomsBlock, moving: Scenes.toomsBlockLife),
    .autopsyBay: Place(name: "The Autopsy Bay", panel: 0x18201E, still: Scenes.autopsyBay, moving: Scenes.autopsyBayLife),
    .reflectingPool: Place(name: "The Reflecting Pool", panel: 0x0C1018, still: Scenes.reflectingPool, moving: Scenes.reflectingPoolLife),
]

// MARK: - Digits

/// Digits and a colon in a 3×5 pixel font, each pixel `s` square, from the left at `x`.
private func drawDigits(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, col: Px) {
    let glyphs: [Character: [String]] = [
        "0": ["###", "#.#", "#.#", "#.#", "###"], "1": [".#.", "##.", ".#.", ".#.", "###"],
        "2": ["###", "..#", "###", "#..", "###"], "3": ["###", "..#", ".##", "..#", "###"],
        "4": ["#.#", "#.#", "###", "..#", "..#"], "5": ["###", "#..", "###", "..#", "###"],
        "6": ["###", "#..", "###", "#.#", "###"], "7": ["###", "..#", ".#.", ".#.", ".#."],
        "8": ["###", "#.#", "###", "#.#", "###"], "9": ["###", "#.#", "###", "..#", "###"],
        ":": [".", "#", ".", "#", "."],
    ]
    var cx = x
    for ch in text {
        guard let rows = glyphs[ch] else { cx += 4 * s; continue }
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" { c.rect(cx + dx * s, y + dy * s, s, s, col) }
        }
        cx += (rows[0].count + 1) * s
    }
}

// MARK: - The quarantine railcar ("731")

extension Scenes {
    /// The railcar's frame: the window band, the bomb's box and the bulkhead door.
    static func s5CarFrame(_ c: PixelCanvas, _ g: Int) -> (winTop: Int, winH: Int, bomb: (x: Int, y: Int, w: Int, h: Int), door: Int, ceiling: Int) {
        let s = unit(g), tall = isTall(c)
        let ceiling = tall ? g - 70 * s : max(0, g - 60 * s)
        let winTop = g - 42 * s, winH = 16 * s
        let bomb = (x: c.w * 14 / 100, y: g - 14 * s, w: 24 * s, h: 14 * s)
        return (winTop, winH, bomb, c.w * 86 / 100, ceiling)
    }

    /// The quarantine railcar from "731": a sealed sleeper car, its riveted green-grey walls, a row of windows black
    /// with night, strip lights along the curved ceiling, a bulkhead door with a little round window, and on the floor
    /// the bomb: a steel case with its red counter, wires running off it. On the screen saver the car's curved roof
    /// rises over it, ribbed, with vents and a sealed hatch.
    static func quarantineCar(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s5CarFrame(c, g)
        // Above the car (the screen saver): the roof's ribs curving over, a hatch and vents.
        if tall {
            c.gradient(0, f.ceiling, C(0x0E120C), C(0x22281E), bands: 6)
            // The ribs, curving in towards the middle as they rise, like the inside of a barrel.
            for x0 in stride(from: 6 * s, to: c.w, by: 22 * s) {
                for y in 0..<f.ceiling {
                    let k = 1 - Double(y) / Double(max(1, f.ceiling))
                    let x = x0 + Int(Double(c.w / 2 - x0) * k * k * 0.25)
                    c.rect(x, y, 3 * s, 1, C(0x2E3628)); c.rect(x, y, s, 1, C(0x44503A))
                }
            }
            // Two pipes along the vault, with valve wheels.
            for (i, py) in [f.ceiling / 4, f.ceiling * 3 / 5].enumerated() {
                c.rect(0, py, c.w, 4 * s, C(0x4E5A44)); c.rect(0, py, c.w, s, C(0x6E7A5E))
                for x in stride(from: c.w / 6 + i * 30 * s, to: c.w, by: c.w / 3) {
                    c.circle(x, py + 2 * s, 4 * s, C(0x8A3A2A)); c.circle(x, py + 2 * s, 2 * s, C(0x4E5A44))
                }
            }
            // Riveted plates bolted over the ribs here and there, so the vault isn't all ribs.
            for i in 0..<5 {
                let px: Int = Int(noise(i + 950) * Double(c.w - 40 * s)), py: Int = f.ceiling / 10 + Int(noise(i + 960) * Double(f.ceiling * 6 / 10))
                let pw: Int = (26 + Int(noise(i + 970) * 20)) * s, ph: Int = (14 + Int(noise(i + 980) * 10)) * s
                c.rect(px, py, pw, ph, C(0x2E3628)); c.rect(px, py, pw, s, C(0x4A5640)); c.rect(px, py + ph - s, pw, s, C(0x1E2418))
                for rx in stride(from: px + 2 * s, to: px + pw - s, by: 5 * s) { c.px(rx, py + 2 * s, C(0x5E6A50)); c.px(rx, py + ph - 3 * s, C(0x5E6A50)) }
            }
            // The sealed hatch in the crown: a heavy wheel, hazard stripes round it.
            let hx = c.w / 2 - 18 * s, hy = f.ceiling / 2 - 4 * s
            c.rect(hx - 2 * s, hy - 2 * s, 40 * s, 28 * s, C(0x1A2016))
            for k in 0..<10 { c.rect(hx + k * 4 * s, hy - 2 * s, 2 * s, 2 * s, C(0xC8A83A)); c.rect(hx + k * 4 * s, hy + 24 * s, 2 * s, 2 * s, C(0xC8A83A)) }
            c.rect(hx, hy, 36 * s, 24 * s, C(0x3A4432)); c.rect(hx + 2 * s, hy + 2 * s, 32 * s, 20 * s, C(0x2A3224))
            c.circle(hx + 18 * s, hy + 12 * s, 8 * s, C(0x8A3A2A)); c.circle(hx + 18 * s, hy + 12 * s, 6 * s, C(0x2A3224))
            c.rect(hx + 10 * s, hy + 12 * s, 17 * s, s, C(0x8A3A2A)); c.rect(hx + 18 * s, hy + 4 * s, s, 17 * s, C(0x8A3A2A))
            c.circle(hx + 18 * s, hy + 12 * s, 2 * s, C(0xB84A3A))
            // The big vent fans either side (their blades turn with the moving layer).
            for vx in [c.w * 16 / 100, c.w * 84 / 100] {
                c.circle(vx, f.ceiling * 3 / 8, 16 * s, C(0x4A5640)); c.circle(vx, f.ceiling * 3 / 8, 14 * s, C(0x1A2016))
                c.circle(vx, f.ceiling * 3 / 8, 12 * s, C(0x0C100A))
            }
            // Cables hanging in loops between the pipes.
            for i in 0..<6 {
                let x0: Int = c.w * (5 + i * 17) / 100, x1: Int = x0 + c.w / 9, sag: Int = (6 + i % 3 * 5) * s
                let y0: Int = f.ceiling / 4 + 4 * s
                for x in stride(from: x0, to: x1, by: s) {
                    let k: Double = Double(x - x0) / Double(max(1, x1 - x0))
                    let y: Int = y0 + Int(sin(k * .pi) * Double(sag))
                    c.rect(x, y, s, s, i % 2 == 0 ? C(0x14180F) : C(0x3A2A1A))
                }
            }
            // Caged work lamps hanging off the lower pipe.
            for (i, lx) in [c.w * 30 / 100, c.w * 70 / 100].enumerated() {
                let ly: Int = f.ceiling * 3 / 5 + 4 * s
                c.rect(lx, ly, s, 10 * s, C(0x1A2016))
                c.rect(lx - 3 * s, ly + 10 * s, 7 * s, 5 * s, C(0x2A3224)); c.rect(lx - 2 * s, ly + 11 * s, 5 * s, 3 * s, i == 0 ? C(0xF0E8B0) : C(0xB8F0A8))
                for k in 0..<5 { c.ellipse(lx, ly + 22 * s + k * 4 * s, (10 + k * 5) * s, (5 + k) * s, C(i == 0 ? 0xF0E8B0 : 0xB8F0A8, 0.03)) }
            }
            for i in 0..<4 { c.rect(c.w / 5 + i * c.w / 5, f.ceiling - 10 * s, 10 * s, 4 * s, C(0x1A2016)) }
        } else {
            c.rect(0, 0, c.w, max(0, f.ceiling), C(0x161A12))
        }
        // The walls.
        c.gradient(f.ceiling, g, C(0x3A4434), C(0x4E5A44), bands: 5)
        c.rect(0, f.ceiling, c.w, 4 * s, C(0x2A3224))
        for x in stride(from: 4 * s, to: c.w, by: 10 * s) { c.px(x, f.ceiling + 6 * s, C(0x6E7A5E)); c.px(x, g - 4 * s, C(0x6E7A5E)) }
        c.rect(0, g - 6 * s, c.w, s, C(0x2A3224))
        // The windows, black with night.
        for x in stride(from: c.w * 26 / 100, to: c.w * 80 / 100, by: 24 * s) {
            c.rect(x - s, f.winTop - s, 18 * s, f.winH + 2 * s, C(0x6A765C))
            c.rect(x, f.winTop, 16 * s, f.winH, C(0x0A0E12))
            c.rect(x, f.winTop + f.winH / 2, 16 * s, s, C(0x6A765C))
        }
        // The bulkhead door.
        let dx = f.door, dh = min(40 * s, g - f.ceiling - 6 * s)
        c.rect(dx - s, g - dh - s, 20 * s, dh + s, C(0x2A3224))
        c.rect(dx, g - dh, 18 * s, dh, C(0x5E6A50)); c.rect(dx + 17 * s, g - dh, s, dh, C(0x3A4432))
        c.circle(dx + 9 * s, g - dh + 9 * s, 4 * s, C(0x2A3224)); c.circle(dx + 9 * s, g - dh + 9 * s, 3 * s, C(0x0E1418))
        c.rect(dx + 2 * s, g - dh / 2, 3 * s, 2 * s, C(0x9AA48A))   // the handle
        c.rect(dx + 2 * s, g - dh + 2 * s, 14 * s, s, C(0xB8A23A))   // a hazard band
        // The bomb: a steel case, its counter's window, and wires off to the wall.
        let b = f.bomb
        c.rect(b.x - s, b.y - s, b.w + 2 * s, b.h + s, C(0x1E2218))
        c.rect(b.x, b.y, b.w, b.h, C(0x7A8088)); c.rect(b.x, b.y, b.w, s, C(0xA8AEB6))
        c.rect(b.x + 2 * s, b.y + 3 * s, b.w - 4 * s, 7 * s, C(0x140A0A))
        for (i, col) in [C(0xC8282E), C(0x2E6AC8), C(0xE8C04A)].enumerated() {
            let wy = b.y + 4 * s + i * 3 * s
            c.rect(b.x + b.w, wy, 4 * s + i * 2 * s, s, col)
            c.rect(b.x + b.w + 4 * s + i * 2 * s, wy - (6 + i * 4) * s, s, (6 + i * 4) * s, col)
        }
        // The floor: worn plating.
        c.ground(g, C(0x34382E), edge: C(0x5E6650), speck: C(0x2A2E24), seed: 51)
        for x in stride(from: 0, to: c.w, by: 16 * s) { c.rect(x, g + 1, s, c.h - g - 1, C(0x2A2E24)) }
    }

    /// What moves in the railcar: the strip lights flickering, lights from outside sliding past the windows as the car
    /// rocks along, and the bomb's counter running down.
    static func quarantineCarLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s5CarFrame(c, g)
        // The strip lights under the ceiling.
        for (i, x) in stride(from: c.w / 8, to: c.w, by: c.w / 4).enumerated() {
            let off = noise(i * 31 + Int(t * 11)) > 0.9
            c.rect(x - 12 * s, f.ceiling + 4 * s, 24 * s, 2 * s, off ? C(0x6A7462) : C(0xEEF6DC, 0.95))
            if !off { c.rect(x - 18 * s, f.ceiling + 6 * s, 36 * s, 5 * s, C(0xEEF6DC, 0.06)) }
        }
        // Lights passing outside, and the car's sway (a pixel up and down on the window glare).
        let sway = sin(t * 2.2) > 0.6 ? s : 0
        for x in stride(from: c.w * 26 / 100, to: c.w * 80 / 100, by: 24 * s) {
            let k = (t * 0.7 + Double(x) / Double(c.w)).truncatingRemainder(dividingBy: 1)
            let lx = x + Int(k * Double(16 * s))
            if noise(Int(t * 0.7 + Double(x)) % 97) > 0.4 { c.rect(lx, f.winTop + 3 * s + sway, 2 * s, 2 * s, C(0xFFE8A0, 0.8)) }
            c.rect(x + 2 * s, f.winTop + 2 * s + sway, 3 * s, s, C(0x8AA0B0, 0.25))
        }
        // The vault's fans turning (the screen saver).
        if isTall(c) {
            for (k, vx) in [c.w * 16 / 100, c.w * 84 / 100].enumerated() {
                let vy: Int = f.ceiling * 3 / 8
                for blade in 0..<4 {
                    let a: Double = t * (2.5 + Double(k)) + Double(blade) * .pi / 2
                    for r in stride(from: 2 * s, to: 11 * s, by: s) {
                        c.rect(vx + Int(cos(a) * Double(r)), vy + Int(sin(a) * Double(r)), 2 * s, 2 * s, C(0x3A4632))
                    }
                }
                c.circle(vx, vy, 2 * s, C(0x5E6A50))
            }
        }
        // The counter: minutes and seconds running down, the colon blinking, its red cast on the wall behind.
        let b = f.bomb
        let beat: Double = Int(t * 2) % 2 == 0 ? 1 : 0.6
        c.ellipse(b.x + b.w / 2, b.y + b.h / 3, b.w, b.h, C(0xFF3A2A, 0.07 * beat))
        let left = max(0, 59 * 60 - Int(t)) % 3600
        let text = String(format: "%02d", left / 60) + (Int(t * 2) % 2 == 0 ? ":" : " ") + String(format: "%02d", left % 60)
        drawDigits(c, text, x: b.x + 3 * s, y: b.y + 4 * s, s: s, col: C(0xFF3A2A))
    }
}

// MARK: - Tooms's apartment block

extension Scenes {
    /// The block's frame: its left and right edges, the floors' height and the vent at the bottom.
    static func s5BlockFrame(_ c: PixelCanvas, _ g: Int) -> (left: Int, right: Int, floor: Int, vent: (x: Int, y: Int, w: Int, h: Int)) {
        let s = unit(g)
        return (c.w * 18 / 100, c.w * 74 / 100, 26 * s, (x: c.w * 40 / 100, y: g - 12 * s, w: 22 * s, h: 10 * s))
    }

    /// Tooms's apartment block in Baltimore at night: an old brick block, its windows in rows (most dark, a few
    /// lit), a fire escape zigzagging down the front, the street lamp at the corner, trash cans, and at the foot of the
    /// wall the vent grate, bars bent, newspaper stuffed behind it. On the screen saver the block climbs on up to its
    /// cornice and a water tower against the night.
    static func toomsBlock(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s5BlockFrame(c, g)
        c.gradient(0, g, C(0x080A14), C(0x1A1E2E), bands: 6)
        for i in 0..<30 { c.px(Int(noise(i + 500) * Double(c.w)), Int(noise(i + 540) * Double(g / 2)), C(0xB8C0D0, 0.6)) }
        // Neighbouring buildings, dark, either side.
        c.rect(0, g - 70 * s, f.left - 4 * s, 70 * s, C(0x14161E))
        c.rect(f.right + 4 * s, g - 56 * s, c.w - f.right, 56 * s, C(0x161820))
        for i in 0..<6 {
            c.rect(Int(noise(i + 600) * Double(f.left - 10 * s)), g - 60 * s + i * 9 * s, 4 * s, 4 * s, C(0x3A3420))
        }
        // The block: brick, its top at the canvas top (or a cornice on the screen saver).
        let top = tall ? max(10 * s, g * 2 / 5) : 0
        c.rect(f.left, top, f.right - f.left, g - top, C(0x5A3226))
        for y in stride(from: top, to: g, by: 3 * s) {
            c.rect(f.left, y, f.right - f.left, max(1, s / 2), C(0x46261C))
            let off = (y / (3 * s)) % 2 == 0 ? 0 : 4 * s
            for x in stride(from: f.left + off, to: f.right, by: 8 * s) { c.rect(x, y, max(1, s / 2), 3 * s, C(0x46261C)) }
        }
        if tall {
            c.rect(f.left - 3 * s, top - 4 * s, f.right - f.left + 6 * s, 4 * s, C(0x3A2018))
            // The water tower on the roof.
            let wx = f.right - 30 * s, wy = top - 30 * s
            c.rect(wx, wy, 18 * s, 18 * s, C(0x3A2A1E)); c.rect(wx, wy + 5 * s, 18 * s, s, C(0x22180E)); c.rect(wx, wy + 12 * s, 18 * s, s, C(0x22180E))
            for k in 0..<6 { c.rect(wx - s + k * s * 2, wy - 6 * s + (6 - k) * s, 20 * s - k * 4 * s, s, C(0x2A2018)) }
            c.rect(wx + 2 * s, wy + 18 * s, s, 8 * s, C(0x22180E)); c.rect(wx + 15 * s, wy + 18 * s, s, 8 * s, C(0x22180E))
        }
        // The windows, floor by floor.
        let cols = 5, colW = (f.right - f.left) / cols
        var floorY = g - 20 * s - f.floor
        var n = 0
        while floorY > top + 2 * s {
            for k in 0..<cols {
                let x = f.left + k * colW + colW / 2 - 5 * s
                c.rect(x - s, floorY - s, 12 * s, 15 * s, C(0x3A2018))
                c.rect(x, floorY, 10 * s, 13 * s, C(0x101420))
                c.rect(x + 5 * s, floorY, s, 13 * s, C(0x3A2018)); c.rect(x, floorY + 6 * s, 10 * s, s, C(0x3A2018))
                if noise(n * 7 + k) > 0.82 { c.rect(x, floorY, 10 * s, 13 * s, C(0xC8A858, 0.55)) }
            }
            // The fire escape: a landing under each floor's middle windows, ladders between.
            let fx = f.left + colW + 2 * s
            c.rect(fx, floorY + 14 * s, colW * 2, s, C(0x18181C)); c.rect(fx, floorY + 11 * s, colW * 2, s, C(0x18181C))
            for x in stride(from: fx, to: fx + colW * 2, by: 3 * s) { c.rect(x, floorY + 11 * s, max(1, s / 2), 3 * s, C(0x18181C)) }
            for i in 0..<(f.floor / (2 * s)) { c.px(fx + colW + (i % 2) * 2 * s + i * s / 2, floorY + 14 * s + i * 2 * s, C(0x22222A)) }
            floorY -= f.floor
            n += 1
        }
        // The ground floor: the door and its step.
        let doorX = f.left + colW * 3 + colW / 2 - 6 * s
        c.rect(doorX, g - 20 * s, 12 * s, 20 * s, C(0x241612)); c.rect(doorX + 2 * s, g - 18 * s, 8 * s, 6 * s, C(0x6A5A3A, 0.6))
        // The vent grate at the foot of the wall: bent bars, newspaper behind.
        let v = f.vent
        c.rect(v.x - s, v.y - s, v.w + 2 * s, v.h + 2 * s, C(0x22201E))
        c.rect(v.x, v.y, v.w, v.h, C(0x050505))
        c.rect(v.x + 2 * s, v.y + v.h - 4 * s, 8 * s, 3 * s, C(0xC8C0A8)); c.rect(v.x + 9 * s, v.y + v.h - 3 * s, 7 * s, 2 * s, C(0xA8A090))
        for i in 0..<5 {
            let bx = v.x + 2 * s + i * 4 * s
            c.rect(bx, v.y, s, v.h, C(0x6A6E74))
            if i == 2 { c.rect(bx + s, v.y + 3 * s, s, 4 * s, C(0x6A6E74)) }   // a bent bar
        }
        // The street lamp at the corner, and the trash cans.
        let lx = c.w * 86 / 100
        c.rect(lx, g - 46 * s, 2 * s, 46 * s, C(0x26282E)); c.rect(lx - 4 * s, g - 48 * s, 10 * s, 3 * s, C(0x26282E))
        c.rect(lx - 2 * s, g - 45 * s, 6 * s, 2 * s, C(0xFFD070))
        // Sodium light: a warm halo round the head, a cone down the post and a pool on the pavement.
        for k in 0..<4 { c.ellipse(lx + s, g - 43 * s, (14 - k * 3) * s, (9 - k * 2) * s, C(0xFFA840, 0.07)) }
        for y in stride(from: g - 43 * s, to: g, by: 1) {
            let hw: Int = 3 * s + (y - (g - 43 * s)) * 12 / 43
            c.rect(lx + s - hw, y, hw * 2, 1, C(0xFFB050, 0.06))
        }
        c.ellipse(lx + s, g + 2 * s, 16 * s, 3 * s, C(0xFFB050, 0.18))
        for k in 0..<2 {
            let tx = f.right + 8 * s + k * 14 * s
            c.rect(tx, g - 15 * s, 12 * s, 15 * s, C(0x4A4E54)); c.rect(tx - s, g - 17 * s, 14 * s, 3 * s, C(0x5E6268))
            for rx in [3, 6, 9] { c.rect(tx + rx * s, g - 12 * s, s, 10 * s, C(0x3A3E44)) }
        }
        // The pavement.
        c.ground(g, C(0x3A3C42), edge: C(0x5E6068), speck: C(0x2E3036), seed: 57)
        c.rect(0, g + 6 * s, c.w, s, C(0x2E3036))
    }

    /// What moves at the block: a window light going on and off, yellow eyes blinking in the vent's dark now and then,
    /// and moths round the street lamp.
    static func toomsBlockLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s5BlockFrame(c, g)
        let colW = (f.right - f.left) / 5
        if Int(t / 7) % 2 == 0 {
            let x = f.left + colW + colW / 2 - 5 * s, y = g - 20 * s - f.floor
            c.rect(x, y, 10 * s, 13 * s, C(0xE8C870, 0.5)); c.rect(x + 5 * s, y, s, 13 * s, C(0x3A2018))
        }
        // The eyes in the vent: there for a few seconds out of every ten, blinking.
        let v = f.vent
        let cycle = t.truncatingRemainder(dividingBy: 10)
        if cycle > 6, cycle < 9.4, Int(t * 3) % 7 != 0 {
            for ex in [v.x + 7 * s, v.x + 12 * s] { c.rect(ex, v.y + 3 * s, 2 * s, s, C(0xF2D040)) }
        }
        // Moths round the lamp.
        let lx = c.w * 86 / 100, ly = g - 44 * s
        for i in 0..<4 {
            let a = t * (2.4 + Double(i) * 0.6) + Double(i) * 1.7
            c.px(lx + Int(cos(a) * Double((4 + i) * s)), ly + Int(sin(a * 1.3) * Double(3 * s)), C(0xE8E0D0, 0.8))
        }
    }
}

// MARK: - The autopsy bay

extension Scenes {
    /// The bay's frame: the operating light's centre, the two tables and the mic's drop.
    static func s5BayFrame(_ c: PixelCanvas, _ g: Int) -> (light: (x: Int, y: Int), tables: [Int], ceiling: Int) {
        let s = unit(g), tall = isTall(c)
        let ceiling = tall ? g - 80 * s : 0
        return ((c.w * 38 / 100, ceiling + (tall ? 22 * s : 8 * s)), [c.w * 30 / 100, c.w * 62 / 100], ceiling)
    }

    /// The autopsy bay: pale green tiles to the ceiling, the big round operating light hanging over the first steel
    /// table, a microphone on its cord over the other, both tables covered with sheets, a hanging scale, the steel sink,
    /// cabinets of jars and the X-ray light box on the wall. On the screen saver, ducts and the viewing window high up,
    /// dark behind the glass.
    static func autopsyBay(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s5BayFrame(c, g)
        c.rect(0, 0, c.w, g, C(0xB8CCC4))
        for y in stride(from: 0, to: g, by: 6 * s) { c.rect(0, y, c.w, max(1, s / 2), C(0x9AB0A8)) }
        for x in stride(from: 0, to: c.w, by: 6 * s) { c.rect(x, 0, max(1, s / 2), g, C(0x9AB0A8)) }
        c.rect(0, g - 12 * s, c.w, 12 * s, C(0x7E9A90)); c.rect(0, g - 12 * s, c.w, s, C(0x5E7A70))
        if tall {
            // Ducts along the ceiling and the viewing window, dark.
            c.rect(0, f.ceiling - 8 * s, c.w, 6 * s, C(0x8A9894)); c.rect(0, f.ceiling - 8 * s, c.w, s, C(0xB8C4C0))
            for x in stride(from: 20 * s, to: c.w, by: 40 * s) { c.rect(x, f.ceiling - 9 * s, 2 * s, 8 * s, C(0x6A7874)) }
            let wx = c.w * 55 / 100, wy = f.ceiling - 50 * s
            c.rect(wx - 2 * s, wy - 2 * s, 60 * s, 30 * s, C(0x6A7874)); c.rect(wx, wy, 56 * s, 26 * s, C(0x1A2426))
            c.rect(wx + 4 * s, wy + 4 * s, 10 * s, 2 * s, C(0xFFFFFF, 0.15))
            // The cold-storage drawers, three by three in the wall.
            let mx = c.w * 8 / 100, my = f.ceiling - 58 * s
            c.rect(mx - 2 * s, my - 2 * s, 64 * s, 46 * s, C(0x6A7874))
            for r in 0..<3 { for k in 0..<3 {
                let dx = mx + k * 20 * s, dy = my + r * 14 * s
                c.rect(dx, dy, 18 * s, 12 * s, C(0xC0C8CC)); c.rect(dx, dy, 18 * s, s, C(0xE0E6E8)); c.rect(dx + 17 * s, dy, s, 12 * s, C(0x8A9498))
                c.rect(dx + 6 * s, dy + 5 * s, 6 * s, 2 * s, C(0x6A7478)); c.rect(dx + 2 * s, dy + 2 * s, 4 * s, 2 * s, C(0xF4F0E0))
            } }
        }
        // The X-ray light box (its glow comes with the moving layer) and the cabinet of jars.
        let xb = c.w * 6 / 100
        c.rect(xb, g - 46 * s, 26 * s, 18 * s, C(0x5A6664)); c.rect(xb + 2 * s, g - 44 * s, 22 * s, 14 * s, C(0x2A3436))
        let cab = c.w * 80 / 100
        c.rect(cab, g - 40 * s, 30 * s, 40 * s, C(0x8A9894)); c.rect(cab + 2 * s, g - 38 * s, 26 * s, 20 * s, C(0xC8DCD8, 0.6))
        for (i, col) in [C(0xC8B85A), C(0x8AB87A), C(0xC8B85A), C(0xA8C8D0), C(0x8AB87A)].enumerated() {
            c.rect(cab + 4 * s + i * 5 * s, g - 34 * s, 3 * s, 6 * s, col); c.rect(cab + 4 * s + i * 5 * s, g - 35 * s, 3 * s, s, C(0x5A5A5A))
        }
        c.rect(cab + 2 * s, g - 16 * s, 26 * s, s, C(0x6A7874)); c.rect(cab + 14 * s, g - 12 * s, 2 * s, 2 * s, C(0x4A5450))
        // The sink.
        let sk = c.w * 46 / 100
        c.rect(sk - 22 * s, g - 22 * s, 16 * s, 8 * s, C(0xA8B4B8)); c.rect(sk - 21 * s, g - 21 * s, 14 * s, 4 * s, C(0x6A7478))
        c.rect(sk - 15 * s, g - 28 * s, 2 * s, 6 * s, C(0xC8D0D4)); c.rect(sk - 15 * s, g - 28 * s, 5 * s, 2 * s, C(0xC8D0D4))
        // The hanging scale.
        let hs = c.w * 48 / 100
        c.rect(hs, f.ceiling, s, g - f.ceiling - 34 * s, C(0x4A5450))
        c.circle(hs, g - 32 * s, 4 * s, C(0xD8DCD8)); c.circle(hs, g - 32 * s, 3 * s, C(0xF4F4EE)); c.rect(hs, g - 34 * s, s, 3 * s, C(0xC82E2E))
        c.rect(hs - 6 * s, g - 24 * s, 13 * s, 2 * s, C(0xB8C0C4))
        for d in [-5, 5] { c.rect(hs + d * s, g - 28 * s, s, 4 * s, C(0x8A9498)) }
        // The tables: steel, a sheet over each.
        for tx in f.tables {
            c.rect(tx - 18 * s, g - 14 * s, 36 * s, 3 * s, C(0xA8B4B8)); c.rect(tx - 18 * s, g - 14 * s, 36 * s, s, C(0xD8E0E4))
            c.rect(tx - 2 * s, g - 11 * s, 4 * s, 11 * s, C(0x7A868A)); c.rect(tx - 8 * s, g - 2 * s, 16 * s, 2 * s, C(0x6A7478))
            c.rect(tx - 16 * s, g - 18 * s, 32 * s, 4 * s, C(0xEEF2EE)); c.rect(tx - 13 * s, g - 20 * s, 10 * s, 2 * s, C(0xEEF2EE))
            c.rect(tx - 16 * s, g - 15 * s, 32 * s, s, C(0xC8D0CC))
        }
        // The operating light's arm (the light itself comes with the moving layer).
        c.rect(f.light.x - s, f.ceiling, 2 * s, max(0, f.light.y - f.ceiling - 4 * s), C(0x6A7874))
        // The mic's cord over the second table (the mic sways with the moving layer).
        c.ground(g, C(0x8A9894), edge: C(0xB8C4C0), speck: C(0x7A8884), seed: 63)
        c.rect(c.w / 2 - 3 * s, g + 2 * s, 6 * s, 2 * s, C(0x4A5450))   // the drain
    }

    /// What moves in the bay: the operating light, humming and now and then flickering, its cone over the first
    /// table; the microphone swaying on its cord; the X-ray box's glow; a drip from the tap.
    static func autopsyBayLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s5BayFrame(c, g)
        let lit = noise(Int(t * 13)) > 0.06 ? 1.0 : 0.4
        let lx = f.light.x, ly = f.light.y
        c.ellipse(lx, ly - s, 13 * s, 5 * s, C(0x6A7874)); c.ellipse(lx, ly, 12 * s, 4 * s, C(0x8A9894))
        c.ellipse(lx, ly + s, 10 * s, 3 * s, C(0xFFFFF4).alpha(lit))
        c.ellipse(lx, ly + 2 * s, 18 * s, 6 * s, C(0xFFFFE8, 0.18 * lit))
        let tx = f.tables[0]
        for y in (ly + 4 * s)..<(g - 18 * s) {
            let k = Double(y - ly) / Double(max(1, g - 18 * s - ly))
            let hw = Int(Double(9 * s) + k * Double(14 * s))
            let cx: Int = lx + (tx - lx) * Int(k * 100) / 100
            c.rect(cx - hw, y, hw * 2, 1, C(0xFFFFE8, 0.2 * lit))
            c.rect(cx - hw / 2, y, hw, 1, C(0xFFFFF4, 0.12 * lit))   // the brighter core
        }
        c.ellipse(tx, g - 17 * s, 22 * s, 3 * s, C(0xFFFFF4, 0.35 * lit))   // the pool of light on the sheet
        // The mic.
        let mx = f.tables[1] + Int(sin(t * 0.9) * Double(2 * s)), my = g - 34 * s
        let topY = f.ceiling
        for y in stride(from: topY, to: my, by: max(1, s)) {
            let k = Double(y - topY) / Double(max(1, my - topY))
            c.rect(f.tables[1] + Int(Double(mx - f.tables[1]) * k), y, max(1, s / 2), max(1, s), C(0x2A3032))
        }
        c.rect(mx - s, my, 3 * s, 5 * s, C(0x2A3032)); c.rect(mx - s, my + 5 * s, 3 * s, s, C(0x5A6264))
        // The light box's glow, flickering a little.
        let xb = c.w * 6 / 100
        c.rect(xb + 2 * s, g - 44 * s, 22 * s, 14 * s, C(0xD8F0F4, 0.55 + 0.08 * sin(t * 17)))
        c.rect(xb + 6 * s, g - 42 * s, 3 * s, 10 * s, C(0x2A3436, 0.5)); c.rect(xb + 11 * s, g - 42 * s, 8 * s, 2 * s, C(0x2A3436, 0.5))
        c.rect(xb + 11 * s, g - 38 * s, 8 * s, 2 * s, C(0x2A3436, 0.5)); c.rect(xb + 11 * s, g - 34 * s, 8 * s, 2 * s, C(0x2A3436, 0.5))
        // A drip from the tap into the sink.
        let sk = c.w * 46 / 100, k = (t * 0.8).truncatingRemainder(dividingBy: 1)
        c.rect(sk - 11 * s, g - 26 * s + Int(k * Double(6 * s)), s, s, C(0xA8D8E8, 0.9))
    }
}

// MARK: - The Reflecting Pool

extension Scenes {
    /// The pool's frame: the water's top and bottom, and the Monument's centre and height.
    static func s5PoolFrame(_ c: PixelCanvas, _ g: Int) -> (water: Int, edge: Int, mx: Int, mh: Int) {
        let s = unit(g), tall = isTall(c)
        let edge = g - 8 * s, water = g - 20 * s
        return (water, edge, c.w * 58 / 100, tall ? min(water - 30 * s, 150 * s) : max(16 * s, water * 55 / 100))
    }

    /// The Reflecting Pool at night: the Washington Monument lit white from below at the far end, the ring of flags at
    /// its foot and the Capitol's dome low beyond it, its reflection laid down the long dark water, rows of elms in
    /// silhouette either side and big near elms framing the walk, lamp posts along it, their lights on the water, and
    /// the park benches where informants meet. On the screen saver the obelisk rises tall into a deep sky with stars, a
    /// moon and the city's glow along the horizon.
    static func reflectingPool(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s5PoolFrame(c, g)
        c.gradient(0, f.water, C(0x060A16), C(0x1E2840), bands: 7)
        for i in 0..<40 { c.px(Int(noise(i + 700) * Double(c.w)), Int(noise(i + 760) * Double(f.water * 2 / 3)), C(0xD0D8E8, 0.6)) }
        if tall {
            c.stars(0, f.water / 2, density: 260, seed: 74)
            s46Moon(c, x: c.w * 84 / 100, y: f.water / 6, r: 9 * s, sky: C(0x060A16))
            for k in 0..<5 { c.ellipse(c.w / 2, f.water - 3 * s, c.w * (6 - k) / 10, (14 - 2 * k) * s, C(0xE8A860, 0.025)) }
        }
        // The Capitol far beyond, its dome lit, low behind the far trees.
        s5Capitol(c, x: f.mx + 46 * s, base: f.water - 3 * s, s: s)
        // The far bank and the trees.
        c.rect(0, f.water - 3 * s, c.w, 3 * s, C(0x0E1418))
        for i in 0..<14 {
            let tx = Int(noise(i + 800) * Double(c.w)), r = (6 + Int(noise(i + 820) * 6)) * s
            guard abs(tx - f.mx) > 14 * s else { continue }
            c.ellipse(tx, f.water - 3 * s - r / 2, r, r * 2 / 3, C(0x0A1210))
        }
        // The Monument: a white obelisk, lit from below, its pyramid tip.
        let mw = max(2 * s, f.mh / 22), base = f.water - 3 * s
        for y in (base - f.mh)..<base {
            let k = Double(y - (base - f.mh)) / Double(f.mh)
            let hw = mw
            c.rect(f.mx - hw, y, hw * 2, 1, C(0xD8DCE4).alpha(0.75 + 0.25 * k))
            c.rect(f.mx + hw - max(1, hw / 3), y, max(1, hw / 3), 1, C(0xA8ACB8))
        }
        for i in 0..<(mw) { c.rect(f.mx - i, base - f.mh - (mw - i), i * 2, 1, C(0xE8ECF2)) }
        c.px(f.mx, base - f.mh - mw - s, C(0xFF4040))   // the aircraft light on top
        // The floodlights' glow at its foot, and the ring of flags round it.
        c.ellipse(f.mx, base - s, 16 * s, 3 * s, C(0xF4F0E0, 0.12))
        for i in 0..<14 {
            let a = Double(i) / 14 * 2 * .pi
            let x = f.mx + Int(cos(a) * Double(13 * s)), y = base - s + Int(sin(a) * Double(2 * s))
            guard abs(x - f.mx) > mw + s || sin(a) > 0 else { continue }   // the ones behind the obelisk are hidden
            c.rect(x, y - 6 * s, max(1, s / 2), 6 * s, C(0x8A8E96))
            c.rect(x + max(1, s / 2), y - 6 * s, 2 * s, s, i % 3 == 0 ? C(0x3A4A8A) : C(0xC8303A))
            c.rect(x + max(1, s / 2), y - 5 * s, 2 * s, max(1, s / 2), C(0xE8E8EC))
        }
        // The water: dark, the Monument's reflection laid down it.
        c.rect(0, f.water, c.w, f.edge - f.water, C(0x0A1222))
        let refl = min(f.mh, f.edge - f.water)
        for y in 0..<refl {
            let hw = Int(Double(mw) * (1 - 0.3 * Double(y) / Double(max(1, f.mh))))
            c.rect(f.mx - hw, f.water + y, hw * 2, 1, C(0xC8D0E0, 0.45 * (1 - Double(y) / Double(max(1, refl)))))
        }
        // The near elms framing the walk, broad dark crowns lit a little on their undersides by the lamps: on the right,
        // and on the screen saver on the left too (in the window that corner stays calm under the title).
        for (k, x) in [-4 * s, c.w + 4 * s].enumerated() where tall || k == 1 { s5Elm(c, x: x, foot: f.edge, s: s, seed: k) }
        // The walk's edge, lamp posts and benches.
        c.rect(0, f.edge, c.w, 2 * s, C(0x8A8E94)); c.rect(0, f.edge, c.w, s, C(0xB8BCC2))
        for x in stride(from: c.w / 10, to: c.w, by: c.w / 4) where abs(x - f.mx) > 12 * s {
            c.rect(x, g - 30 * s, s, 30 * s, C(0x1E2228)); c.rect(x - 2 * s, g - 33 * s, 5 * s, 3 * s, C(0x1E2228))
            c.rect(x - s, g - 32 * s, 3 * s, 2 * s, C(0xFFE8B0)); c.ellipse(x, g - 28 * s, 8 * s, 6 * s, C(0xFFE8B0, 0.06))
            for k in 0..<3 { c.rect(x - (2 - k) * s, f.water + 2 * s + k * 3 * s, (5 - 2 * k) * s, max(1, s / 2), C(0xFFE8B0, 0.3 - 0.08 * Double(k))) }
        }
        for bx in [c.w * 22 / 100, c.w * 80 / 100] {
            c.rect(bx, g - 8 * s, 22 * s, 2 * s, C(0x5A4430)); c.rect(bx, g - 12 * s, 22 * s, 2 * s, C(0x5A4430))
            c.rect(bx + 2 * s, g - 6 * s, s, 6 * s, C(0x1E2228)); c.rect(bx + 19 * s, g - 6 * s, s, 6 * s, C(0x1E2228))
            c.rect(bx + 2 * s, g - 12 * s, s, 4 * s, C(0x1E2228)); c.rect(bx + 19 * s, g - 12 * s, s, 4 * s, C(0x1E2228))
        }
        c.ground(g, C(0x4A4C50), edge: C(0x6A6C72), speck: C(0x3A3C40), seed: 69)
    }

    /// The Capitol, far off: a long low front with its colonnade picked out, the drum, the lit dome and its statue.
    private static func s5Capitol(_ c: PixelCanvas, x: Int, base: Int, s: Int) {
        let stone = C(0x8A90A0), lit = C(0xC8CCD8)
        c.rect(x - 22 * s, base - 4 * s, 44 * s, 4 * s, stone); c.rect(x - 22 * s, base - 4 * s, 44 * s, max(1, s / 2), lit)
        for u in stride(from: -20, to: 21, by: 3) { c.rect(x + u * s, base - 3 * s, max(1, s / 2), 3 * s, C(0x5A6070)) }
        c.rect(x - 8 * s, base - 7 * s, 16 * s, 3 * s, stone)
        c.rect(x - 6 * s, base - 11 * s, 12 * s, 4 * s, lit)
        for u in stride(from: -5, to: 6, by: 2) { c.rect(x + u * s, base - 10 * s, max(1, s / 2), 3 * s, C(0x8A90A0)) }
        c.ellipse(x, base - 11 * s, 6 * s, 5 * s, C(0xE0E4EC)); c.rect(x - 6 * s, base - 11 * s, 12 * s, 5 * s, lit)
        c.rect(x - s, base - 18 * s, 2 * s, 2 * s, lit); c.rect(x - max(1, s / 2), base - 20 * s, max(1, s), 2 * s, C(0xA8ACB8))
        c.ellipse(x, base - 10 * s, 14 * s, 8 * s, C(0xF4F0E0, 0.05))   // its floodlit glow
    }

    /// A near elm at the side of the walk: a trunk standing on `foot`, a broad crown of overlapping clumps, the lamps'
    /// light catching their undersides.
    private static func s5Elm(_ c: PixelCanvas, x: Int, foot: Int, s: Int, seed: Int) {
        let top = foot - 44 * s, dir = x < c.w / 2 ? 1 : -1
        c.rect(x - 2 * s, top + 20 * s, 5 * s, foot - top - 20 * s, C(0x0A0E10))
        c.rect(dir > 0 ? x + 2 * s : x - 9 * s, top + 22 * s, 7 * s, 2 * s, C(0x0A0E10))   // a bough reaching in
        for k in 0..<9 {
            let u = x + dir * Int(noise(seed * 31 + k) * Double(30 * s)) - dir * 4 * s
            let v = top + 4 * s + Int(noise(seed * 31 + k + 10) * Double(18 * s)), r = (8 + Int(noise(seed * 31 + k + 20) * 7)) * s
            c.ellipse(u, v + 2 * s, r + s, r * 2 / 3, C(0x16221E))   // the lit underside
            c.ellipse(u, v, r + s, r * 2 / 3, C(0x070C0C))
        }
    }

    /// What moves at the pool: ripples breaking up the reflection, clouds sliding over the stars, and far down the
    /// water on the left, someone on a bench, the glow of his cigarette brightening as he draws on it.
    static func reflectingPoolLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s5PoolFrame(c, g)
        // Clouds.
        for i in 0..<3 {
            let w = (50 + i * 20) * s
            let x = Int((t * Double(3 + i) * Double(s) + Double(i * c.w / 3)).truncatingRemainder(dividingBy: Double(c.w + w))) - w
            let tip = f.water - 3 * s - f.mh - 6 * s
            let y = max(3 * s, tip / 4 + i * tip / 4)
            guard y < tip - 2 * s else { continue }   // only in the sky above the Monument's tip
            c.ellipse(x + w / 2, y, w / 2, 3 * s, C(0x2A3450, 0.5))
        }
        // Ripples across the reflection.
        for i in 0..<6 {
            let y = f.water + 2 * s + i * max(s, (f.edge - f.water) / 7)
            let x = f.mx - 8 * s + Int(sin(t * 1.4 + Double(i) * 1.9) * Double(5 * s))
            c.rect(x, y, 16 * s, max(1, s / 2), C(0xE8F0FF, 0.35))
            c.rect(x - 20 * s + Int(sin(t + Double(i)) * Double(8 * s)), y + s, 10 * s, max(1, s / 2), C(0x6A7A9A, 0.3))
        }
        // The far figure on the bank, and the ember of his cigarette.
        let fx = c.w * 8 / 100, fy = f.water - 3 * s
        c.rect(fx, fy - 7 * s, 3 * s, 7 * s, C(0x05080C)); c.rect(fx, fy - 9 * s, 3 * s, 2 * s, C(0x05080C))
        let glow = 0.4 + 0.6 * max(0, sin(t * 0.8))
        c.px(fx + 3 * s, fy - 7 * s, C(0xFF6A2A).alpha(glow))
    }
}
