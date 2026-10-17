import Foundation

// The Nightmare Before Christmas's other places: Spiral Hill and its graveyard under the moon, Oogie Boogie's lair, and
// Christmas Town in the snow.

let burtonScenes2: [Location: Place] = [
    .spiralHill: Place(name: "Spiral Hill", panel: 0x0C0E16, still: Scenes.spiralHill, moving: Scenes.spiralHillLife),
    .oogiesLair: Place(name: "Oogie Boogie's Lair", panel: 0x0C0A14, still: Scenes.oogiesLair, moving: Scenes.oogiesLairLife),
    .christmasTown: Place(name: "Christmas Town", panel: 0x142036, still: Scenes.christmasTown, moving: Scenes.christmasTownLife),
]

// MARK: - Spiral Hill

extension Scenes {
    private static let shStone = C(0x5A6476), shStoneLit = C(0x9AA6BA)

    /// Where Spiral Hill stands: the moon, and the hill's foot, width and height (sized so its curl sits on the moon).
    static func shFrame(_ c: PixelCanvas, _ g: Int) -> (moon: (x: Int, y: Int, r: Int), hill: (x: Int, base: Int, w: Int, h: Int)) {
        let s = unit(g), tall = isTall(c)
        let moon = tall ? (c.w * 30 / 100, g * 40 / 100, 44 * s) : (c.w * 24 / 100, g * 38 / 100, 18 * s)
        let base = g - (tall ? 80 : 2) * s, h = (base - moon.1) * 100 / 71, w = h * 8 / 5
        return (moon, (moon.0 - w * 3 / 5, base, w, h))
    }

    /// A stone gargoyle on its pedestal, crouched, head thrown up and jaws open, its moonlit side picked out.
    private static func shGargoyle(_ c: PixelCanvas, x: Int, base: Int, s: Int) {
        let stone = C(0x4A5262), lit = C(0x8A96AA)
        c.rect(x - 7 * s, base - 8 * s, 14 * s, 8 * s, stone); c.rect(x - 8 * s, base - 9 * s, 16 * s, 2 * s, lit)
        let rows = [
            "......SSS.....",
            ".....SSSSS....",
            "....SSSKSSS...",
            "...SSSSSSSKK..",
            "...SSSSSKK....",
            "..SSSSSSSKK...",
            "..SSSSSSSS....",
            ".SSSSSSSSS....",
            ".SSSSSSSSSS...",
            "SSSSSSSSSSSS..",
            "SSSSSSSSSSSSS.",
            "SSS.SSSSSS.SS.",
            "SS..SSSSS..SS.",
        ]
        for (r, row) in rows.enumerated() {
            for (k, ch) in row.enumerated() where ch != "." {
                c.rect(x - 7 * s + k * s, base - 9 * s - (rows.count - r) * 2 * s, s, 2 * s, ch == "K" ? C(0x14161E) : (k < 4 ? lit : stone))
            }
        }
    }

    /// Spiral Hill at night: a near-black sky, a huge yellow moon with the hill curling up in front of it, its slope
    /// covered in graves; tombstones, crosses and an obelisk all over the ground, red berry bushes, a crooked iron
    /// fence and a stone gargoyle with its jaws open. The ground is grooved like clay.
    static func spiralHill(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = shFrame(c, g)
        c.gradient(0, g, C(0x05060A), C(0x1E2434), bands: 6)
        c.stars(0, g / 2, density: 160, seed: 71)
        let m = f.moon
        c.circle(m.x, m.y, m.r + 6 * s, C(0xF8D060, 0.08)); c.circle(m.x, m.y, m.r + 3 * s, C(0xF8D060, 0.16))
        c.circle(m.x, m.y, m.r, C(0xE8A828)); c.circle(m.x - 1, m.y - 1, m.r - max(1, m.r / 12), C(0xF8D848))
        c.circle(m.x - m.r / 3, m.y - m.r / 4, max(1, m.r / 5), C(0xE8B838, 0.6))
        // A far ridge, the hill, its moonlit rim and graves up its slope.
        c.dunes(base: g - (tall ? 84 : 14) * s, amp: (tall ? 8 : 4) * Double(s), freq: 0.015, phase: 0.6, bottom: g, C(0x1A1E28))
        let h = f.hill
        burtonSpiralHill(c, x: h.x, base: h.base, w: h.w, h: h.h, C(0x2A3140))
        func top(_ x: Int) -> Int { burtonSpiralHillTop(x: h.x, base: h.base, w: h.w, h: h.h, at: x) }
        for x in h.x..<(h.x + h.w) where top(x) < h.base { c.rect(x, top(x), 1, s, C(0x4A5468)) }
        let curlX = h.x + h.w * 3 / 5
        for i in 0..<12 {
            let gx = h.x + h.w * (6 + i * 88 / 11) / 100
            guard abs(gx - curlX) > h.h / 9, top(gx) < h.base - 4 * s else { continue }
            htGrave(c, gx, top(gx) + 2 * s, kind: [0, 1, 0, 1, 2, 1, 0, 1, 0, 1, 0, 1][i], s: s,
                    tilt: (noise(i + 1700) - 0.5) * 0.5, stone: shStone, lit: shStoneLit)
        }
        // The ground: dark earth, grooved like clay in wavy rows.
        c.ground(g, C(0x262A34), edge: C(0x4A5262), speck: C(0x1C1F28), seed: 91)
        for row in 0..<((c.h - g) / (2 * s)) {
            let y = g + 2 * s + row * 2 * s
            for x in stride(from: Int(noise(row + 1800) * 6), to: c.w, by: 6) {
                c.rect(x, y + Int(sin(Double(x) * 0.15 + Double(row)) * 1.0), 3 * s, 1, C(0x323846))
            }
        }
        // Red berry bushes on the left.
        for i in 0..<5 {
            let bx = Int(noise(i + 1820) * Double(c.w / 4)), by = g - Int(noise(i + 1830) * Double(3 * s))
            c.ellipse(bx, by - 3 * s, 5 * s, 3 * s, C(0x1C2420))
            for k in 0..<5 { c.rect(bx - 4 * s + k * 2 * s, by - 5 * s + (k % 2) * s, s, s, C(0xC8202A)) }
        }
        if tall {   // a middle distance of graves between the ridge and the yard
            for i in 0..<14 {
                let gx = Int(noise(i + 1870) * Double(c.w)), gy = g - (26 + Int(noise(i + 1880) * 30)) * s
                htGrave(c, gx, gy, kind: i % 3, s: s, tilt: (noise(i + 1890) - 0.5) * 0.6, stone: C(0x3E4656), lit: C(0x6A7488))
            }
        }
        // Graves across the yard, a crooked fence and the gargoyle on the right.
        for i in 0..<10 {
            let gx = c.w * 35 / 100 + Int(noise(i + 1840) * Double(c.w * 50 / 100))
            htGrave(c, gx, g + 2 * s, kind: [2, 0, 1, 0, 1, 1, 0, 2, 1, 0][i], s: tall ? 2 * s : s,
                    tilt: (noise(i + 1850) - 0.5) * 0.6, stone: shStone, lit: shStoneLit)
        }
        for fx in stride(from: c.w * 62 / 100, to: c.w * 88 / 100, by: 4 * s) {
            let lean = Int((noise(fx + 1860) - 0.5) * Double(3 * s))
            c.rect(fx + lean, g - 8 * s, s, 8 * s, C(0x14161E)); c.px(fx + lean, g - 9 * s, C(0x14161E))
        }
        c.rect(c.w * 62 / 100, g - 6 * s, c.w * 26 / 100, s, C(0x14161E))
        shGargoyle(c, x: c.w * 92 / 100, base: g + s, s: tall ? 2 * s : s)
    }

    /// What moves on Spiral Hill: mist drifting low between the graves, and now and then a little ghost wisp rising
    /// and fading.
    static func spiralHillLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g)
        for i in 0..<8 {
            let x = (noise(i + 1900) * Double(c.w + 200) + t * (6 + noise(i + 1910) * 6)).truncatingRemainder(dividingBy: Double(c.w + 200)) - 100
            c.ellipse(Int(x), g - 2 * s - Int(noise(i + 1920) * Double(6 * s)), (30 + Int(noise(i + 1930) * 30)) * s, 2 * s,
                      C(0xA8B4C8, 0.12))
        }
        for i in 0..<3 {
            let k = (t / 5 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            let n = Int(t / 5 + Double(i) / 3) * 3 + i
            let x = Int(noise(n + 1940) * Double(c.w)) + Int(sin(k * 9) * Double(3 * s)), y = g - Int(k * Double(g) * 0.5)
            let a = (k < 0.2 ? k / 0.2 : 1 - (k - 0.2) / 0.8) * 0.7
            c.pattern(x, y, [".WW.", "WWWW", "WKWK", "WWWW", "W.W."], ["W": C(0xF0F4F8, a), "K": C(0x14161E, a)])
        }
    }
}

// MARK: - Oogie Boogie's lair

extension Scenes {
    /// Where the lair's wheel hangs on the back wall: its middle and radius.
    static func olWheel(_ c: PixelCanvas, _ g: Int) -> (x: Int, y: Int, r: Int) {
        let s = unit(g), tall = isTall(c)
        return tall ? (c.w * 50 / 100, g * 46 / 100, 62 * s) : (c.w * 50 / 100, g * 44 / 100, 22 * s)
    }

    /// A neon arch: an outline glowing green, `w` wide and `h` tall, standing on row `base`.
    private static func olArch(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, s: Int) {
        let uv = C(0x3AFF6A), r = w / 2
        for k in 0...40 {
            let a = Double(k) / 40 * .pi
            let px = x + r - Int((cos(a) * Double(r)).rounded()), py = base - h + r - Int((sin(a) * Double(r)).rounded())
            c.rect(px, py, s, s, uv); c.rect(px, py + s, s, s, uv.alpha(0.3))
        }
        c.rect(x, base - h + r, s, h - r, uv); c.rect(x + w - s, base - h + r, s, h - r, uv)
        c.rect(x + s, base - h + r, s, h - r, uv.alpha(0.3)); c.rect(x + w - 2 * s, base - h + r, s, h - r, uv.alpha(0.3))
    }

    /// Oogie Boogie's lair: his casino in the dark under ultraviolet light. A giant roulette wheel on the back wall
    /// (it spins in the moving layer), neon-green arches either side, a stack of giant dice, a slot machine framed in
    /// bulbs, playing cards on the walls and a chequered floor glowing green at its edge; on the screen saver, the
    /// rope bridge sagging across and a cage hanging from it.
    static func oogiesLair(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), uv = C(0x3AFF6A)
        c.gradient(0, g, C(0x08040E), C(0x2A1046), bands: 6)
        // The back wall: dark stone, a glow behind the wheel.
        for y in stride(from: 0, to: g, by: 8 * s) {
            for x in stride(from: ((y / (8 * s)) % 2) * 6 * s, to: c.w, by: 12 * s) {
                c.rect(x, y, s, 8 * s, C(0x1E1030)); c.rect(x, y, 12 * s, s, C(0x1E1030))
            }
        }
        let w = olWheel(c, g)
        c.circle(w.x, w.y, w.r + 10 * s, uv.alpha(0.05)); c.circle(w.x, w.y, w.r + 5 * s, uv.alpha(0.08))
        c.rect(w.x - 2 * s, w.y, 4 * s, g - w.y, C(0x2A1A3A))   // the wheel's stand
        // Neon arches either side, and playing cards fanned on the walls.
        let aw = (tall ? 70 : 34) * s, ah = (tall ? 150 : 50) * s
        olArch(c, x: c.w * 6 / 100, base: g, w: aw, h: ah, s: s)
        olArch(c, x: c.w * 94 / 100 - aw, base: g, w: aw, h: ah, s: s)
        for (i, (fx, fy)) in [(0.30, 0.18), (0.70, 0.16), (0.16, 0.42), (0.86, 0.40)].enumerated() {
            let cx = Int(Double(c.w) * fx), cy = Int(Double(g) * fy)
            for k in 0..<3 {
                let x = cx + (k - 1) * 4 * s, y = cy + abs(k - 1) * 2 * s
                c.rect(x, y, 5 * s, 7 * s, C(0xE8E4D8)); c.rect(x, y, 5 * s, s, uv.alpha(0.6))
                c.rect(x + 2 * s, y + 3 * s, s, s, (k + i) % 2 == 0 ? C(0xC8202A) : C(0x1A1A22))
            }
        }
        if tall {
            // The rope bridge sagging across, and the cage hanging from it.
            let by = g * 16 / 100
            for x in 0..<c.w {
                let y = by + Int(sin(Double(x) / Double(c.w) * .pi) * Double(14 * s))
                c.px(x, y, C(0x8A6A3A)); if x % (5 * s) == 0 { c.rect(x, y, s, 4 * s, C(0x6A4E2A)) }
                c.px(x, y + 4 * s, C(0x8A6A3A))
            }
            let cx = c.w * 78 / 100, cy = by + 34 * s
            c.rect(cx, by + 12 * s, s, 22 * s, C(0x5A5A64))
            for k in 0..<5 { c.rect(cx - 8 * s + k * 4 * s, cy, s, 18 * s, C(0x5A5A64)) }
            c.rect(cx - 9 * s, cy, 18 * s, s, C(0x6A6A74)); c.rect(cx - 9 * s, cy + 18 * s, 18 * s, s, C(0x6A6A74))
        }
        // The chequered floor, glowing green where the light catches its edge.
        c.rect(0, g, c.w, c.h - g, C(0x0C0814))
        let tile = 6 * s
        for y in stride(from: g, to: c.h, by: tile) {
            for x in stride(from: ((y - g) / tile % 2) * tile, to: c.w, by: tile * 2) { c.rect(x, y, tile, tile, C(0x143A20)) }
        }
        c.rect(0, g, c.w, s, uv)
        // A stack of giant dice on the left.
        let dz = (tall ? 26 : 13) * s, dx = c.w * 22 / 100
        for (i, (ox, oy)) in [(0, 0), (dz + 2 * s, 0), (dz / 2 + s, dz)].enumerated() {
            let x = dx + ox, y = g - dz - oy
            c.rect(x, y, dz, dz, C(0xF0ECE0)); c.rect(x, y, dz, s, uv.alpha(0.7)); c.rect(x + dz - s, y, s, dz, C(0xC8C4B8))
            let pips: [(Int, Int)] = [[(2, 2)], [(1, 1), (3, 3)], [(1, 1), (2, 2), (3, 3)]][i]
            for (u, v) in pips { c.rect(x + dz * u / 4 - s, y + dz * v / 4 - s, 2 * s, 2 * s, C(0x1A1A22)) }
        }
        // The slot machine on the right, framed in bulbs, its reels (the moving layer spins them) and its handle.
        let sx = c.w * 70 / 100, sw = (tall ? 40 : 22) * s, sh = (tall ? 70 : 34) * s
        c.rect(sx, g - sh, sw, sh, C(0x5A1A6A)); c.rect(sx + sw - s, g - sh, s, sh, C(0x3A0E48))
        for k in stride(from: 0, to: sw, by: 3 * s) { c.rect(sx + k, g - sh, s, s, C(0xF8D848)); c.rect(sx + k, g - sh + 2 * s, s, s, C(0xF8D848, 0.6)) }
        c.rect(sx + 2 * s, g - sh + 6 * s, sw - 4 * s, sh / 4, C(0x0C0A10))
        c.rect(sx + 3 * s, g - sh / 2, sw - 6 * s, 3 * s, C(0x2A0A34))
        c.rect(sx + sw, g - sh + 6 * s, 2 * s, sh / 3, C(0x9A9AA8)); c.circle(sx + sw + s, g - sh + 5 * s, 3 * s, C(0xC8202A))
    }

    /// What moves in the lair: the giant wheel spinning, the slot machine's reels flickering, the bulbs chasing, the
    /// ultraviolet light throbbing, and bugs scuttling across the floor.
    static func oogiesLairLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), uv = C(0x3AFF6A), w = olWheel(c, g)
        // The wheel: pockets of red and black (and a green one now and then) round a glowing rim, spinning.
        let n = 18, spin = t * 1.4
        for y in (w.y - w.r)...(w.y + w.r) {
            for x in (w.x - w.r)...(w.x + w.r) {
                let dx = Double(x - w.x), dy = Double(y - w.y), d = (dx * dx + dy * dy).squareRoot()
                guard d <= Double(w.r) else { continue }
                if d > Double(w.r - 2 * s) { c.px(x, y, uv); continue }
                if d < Double(w.r) * 0.28 { c.px(x, y, d < Double(w.r) * 0.2 ? C(0xF0ECE0) : C(0x8A6A3A)); continue }
                let a = (atan2(dy, dx) + spin) / (2 * .pi) * Double(n)
                let k = (Int(floor(a)) % n + n) % n
                let col = k % 9 == 0 ? C(0x1E8A3A) : (k % 2 == 0 ? C(0xC8202A) : C(0x14141A))
                c.px(x, y, d > Double(w.r) * 0.8 && Int(d) % 3 == 0 ? lerp(col, C(0xFFFFFF), 0.15) : col)
            }
        }
        c.pattern(w.x - 2 * s, w.y - w.r - 4 * s, ["PPPPP", ".PPP.", "..P.."].map { r in
            String(r.flatMap { Array(repeating: $0, count: s) }) }, ["P": C(0xF8D848)])
        for (u, v) in [(-1, -1), (1, 1), (0, 0)] { c.rect(w.x + u * w.r / 10 - s / 2, w.y + v * w.r / 10 - s / 2, max(1, s), max(1, s), C(0x1A1A22)) }
        // The slot machine's reels: skull, bug, die, flickering through; its bulbs chasing.
        let sx = c.w * 70 / 100, sw = (tall ? 40 : 22) * s, sh = (tall ? 70 : 34) * s
        let icons: [[String]] = [[".WWW.", "WKWKW", "WWWWW", ".W.W."], ["..G..", ".GGG.", "GGGGG", ".G.G."], ["WWWWW", "WKWWW", "WWWKW", "WWWWW"]]
        for r in 0..<3 {
            let icon = icons[(Int(t * 6) + r * 2) % 3]
            c.pattern(sx + 3 * s + r * (sw - 6 * s) / 3, g - sh + 8 * s, icon, ["W": C(0xF0ECE0), "K": C(0x1A1A22), "G": C(0x6ADB2E)])
        }
        let chase = Int(t * 8)
        for (i, k) in stride(from: 0, to: sw, by: 3 * s).enumerated() where (i + chase) % 3 == 0 {
            c.rect(sx + k, g - sh, s, s, C(0xFFFFFF))
        }
        // The UV light throbbing over everything.
        c.rect(0, 0, c.w, g, uv.alpha(0.03 + 0.03 * sin(t * 2.5)))
        // Bugs on the floor.
        for i in 0..<3 {
            let k = (t / 6 + Double(i) / 3).truncatingRemainder(dividingBy: 1), left = i % 2 == 0
            let x = left ? c.w - Int(k * Double(c.w + 20)) : Int(k * Double(c.w + 20)) - 10
            burtonBeetle(c, x: x, y: g + 3 * s, step: Int(t * 16) % 2 == 0, left: left,
                         shell: [C(0x3A8A1A), C(0x7A3AB0), C(0xC8581A)][i], shine: [C(0xB8F060), C(0xD8A8FF), C(0xFFB060)][i])
        }
    }
}

// MARK: - Christmas Town

extension Scenes {
    /// Christmas Town: everything Halloween Town isn't. A deep blue night, snow on the ground, toy-town houses in candy
    /// colours with snow on their roofs and warm windows, candy-cane lamp posts, and a giant decorated tree with a star.
    /// On the screen saver, the northern lights ripple across the sky.
    static func christmasTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), snow = C(0xEEF4FA), snowD = C(0xC8D8E8)
        c.gradient(0, g, C(0x0E1A34), C(0x3A5A8A), bands: 7)
        c.stars(0, g * 2 / 3, density: 110, seed: 81)
        if tall {
            // Far snowy hills.
            c.dunes(base: g - 70 * s, amp: 10 * Double(s), freq: 0.012, phase: 1.1, bottom: g, C(0xB8CCE0))
            c.dunes(base: g - 50 * s, amp: 8 * Double(s), freq: 0.02, phase: 2.3, bottom: g, C(0xD0E0EE))
            // A far row of little houses along the hills, their windows lit.
            for i in 0..<18 {
                let hx = Int(noise(i + 2120) * Double(c.w)), hw = (6 + Int(noise(i + 2121) * 5)) * s, hh = (5 + Int(noise(i + 2122) * 6)) * s
                let hy = g - 62 * s + Int(sin(Double(hx) * 0.012 + 1.1) * 6 * Double(s))
                c.rect(hx, hy - hh, hw, hh, [C(0xA85A6A), C(0x5A8A7A), C(0xC8A86A), C(0x7A6AA8)][i % 4])
                for r in 0..<(hw / 2) { c.rect(hx + r, hy - hh - r, hw - r * 2, 1, C(0xEEF4FA)) }
                c.rect(hx + hw / 3, hy - hh + 2 * s, s, s, C(0xFFE08A))
            }
        }
        // The houses: candy colours, steep snowy roofs, warm windows, a chimney or two.
        let walls = [C(0xC8303A), C(0x2E8A4A), C(0xE88AB0), C(0xE8C040), C(0x6ACBB0), C(0x8A5AC8)]
        var x = -4 * s, k = 0
        let tree = c.w * 54 / 100
        while x < c.w {
            let tower = k % 4 == 2
            let w = (14 + Int(noise(k * 3 + 2100) * 10)) * s - (tower ? 4 * s : 0)
            let h = (tall ? 22 : 14) * s + Int(noise(k * 3 + 2101) * Double(10 * s)) + (tower ? (tall ? 16 : 8) * s : 0)
            if abs(x + w / 2 - tree) > (tall ? 50 : 22) * s + w / 2 {
                let wall = walls[k % walls.count]
                c.rect(x, g - h, w, h, wall); c.rect(x + w - s, g - h, s, h, lerp(wall, C(0x000000), 0.25))
                let roofH = w * 2 / 3
                for r in 0..<roofH {
                    let half = (w / 2 + 2 * s) * (roofH - r) / roofH
                    c.rect(x + w / 2 - half, g - h - r, half * 2, 1, r > roofH / 3 ? snow : C(0x8A3A2A))
                }
                c.rect(x - 2 * s, g - h, w + 4 * s, 2 * s, snow)
                for i in 0..<2 {
                    let wx = x + w / 4 + i * w / 2 - 2 * s
                    c.rect(wx, g - h + 4 * s, 4 * s, 4 * s, C(0xFFE08A)); c.rect(wx + 2 * s - 1, g - h + 4 * s, s, 4 * s, wall)
                }
                c.rect(x + w / 2 - 2 * s, g - 6 * s, 4 * s, 6 * s, C(0x5A3A22))
            }
            x += w + (3 + Int(noise(k * 3 + 2102) * 5)) * s; k += 1
        }
        // The giant tree: tiers of green, a gold star on top, ornaments.
        let th = (tall ? 90 : 46) * s, tiers = 4
        for i in 0..<tiers {
            let ty = g - th + i * th / (tiers + 1), tw = (12 + i * 8) * s * (tall ? 2 : 1)
            for r in 0..<(th / tiers + 4 * s) {
                let half = tw * r / (th / tiers + 4 * s)
                c.rect(tree - half, ty + r, half * 2, 1, r % 3 == 0 ? C(0x1E6A32) : C(0x2A8A42))
            }
        }
        c.rect(tree - 2 * s, g - 6 * s, 4 * s, 6 * s, C(0x5A3A22))
        c.pattern(tree - 3 * s, g - th - 6 * s, ["...Y...", "..YYY..", "YYYYYYY", ".YYYYY.", ".YY.YY.", "Y.....Y"], ["Y": C(0xF8D848)])
        // Candy-cane lamp posts along the street.
        for lx in stride(from: c.w / 10, to: c.w, by: c.w / 5) {
            for y in stride(from: g - 18 * s, to: g, by: s) { c.rect(lx, y, s, s, ((y - g) / (2 * s)) % 2 == 0 ? C(0xE8E8E8) : C(0xC8202A)) }
            c.rect(lx - s, g - 20 * s, 3 * s, 2 * s, C(0xFFF0B0))
        }
        // The snowy street.
        c.ground(g, snow, edge: C(0xFFFFFF), speck: snowD, seed: 51)
    }

    /// What moves in Christmas Town: snow falling, the tree's lights twinkling, the lamps glowing; on the screen saver
    /// the northern lights rippling, and a sleigh crossing far off now and then.
    static func christmasTownLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), tree = c.w * 54 / 100, th = (tall ? 90 : 46) * s
        if tall {
            for band in 0..<3 {
                let col = [C(0x3AF0A0), C(0x5AC8F0), C(0xE07AD0)][band]
                for x in stride(from: 0, to: c.w, by: 2) {
                    let y = g / 6 + band * 14 * s + Int(sin(Double(x) * 0.02 + t * 0.6 + Double(band)) * Double(10 * s))
                    c.rect(x, y, 2, 10 * s, col.alpha(0.06 + 0.05 * sin(Double(x) * 0.05 + t)))
                }
            }
            let k = (t / 20).truncatingRemainder(dividingBy: 1)
            let sx = Int(k * Double(c.w + 80)) - 40, sy = g / 4
            c.pattern(sx, sy, ["R.R.R.....", "RRRRRR.SSS", ".R.R...SSS"], ["R": C(0x2A1A10, 0.7), "S": C(0x8A1A1A, 0.7)])
        }
        // Snow.
        for i in 0..<(c.w * g / 250) {
            let x0 = noise(i * 3 + 2200) * Double(c.w), speed = 8 + noise(i * 3 + 2201) * 10
            let y = (noise(i * 3 + 2202) * Double(g) + t * speed).truncatingRemainder(dividingBy: Double(g))
            c.rect(Int(x0 + sin(t + Double(i)) * 3), Int(y), s, s, C(0xFFFFFF, 0.8))
        }
        // The tree's lights.
        for i in 0..<16 {
            let y = g - th + Int(noise(i + 2300) * Double(th - 8 * s)), spread = Double(y - (g - th)) / Double(th) * 0.9
            let x = tree + Int((noise(i + 2310) - 0.5) * Double(36 * s) * spread * (tall ? 2 : 1))
            let on = noise(Int(t * 3) + i * 7) > 0.35
            c.rect(x, y, s, s, ([C(0xFF3A3A), C(0xF8D848), C(0x5AC8F0), C(0xE07AD0)][i % 4]).alpha(on ? 1 : 0.3))
        }
    }
}
