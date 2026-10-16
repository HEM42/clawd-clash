import Foundation

// Indiana Jones: the idol temple, the Well of Souls, the Temple of Doom and the Grail temple. Four distinct palettes:
// mossy grey stone and gold for the jungle temple, ochre and black for the well, crimson and lava for the cavern, and
// rose-red sandstone in daylight for the canyon.

let clawdbergScenes7: [Location: Place] = [
    .idolTemple: Place(name: "The Idol Temple", panel: 0x16160E, still: Scenes.idolTemple, moving: Scenes.idolTempleLife),
    .wellOfSouls: Place(name: "The Well of Souls", panel: 0x1E140A, still: Scenes.wellOfSouls, moving: Scenes.wellOfSoulsLife),
    .templeOfDoom: Place(name: "The Temple of Doom", panel: 0x1E0806, still: Scenes.templeOfDoom,
                         moving: Scenes.templeOfDoomLife),
    .grailTemple: Place(name: "The Grail Temple", panel: 0x2A1610, still: Scenes.grailTemple, moving: Scenes.grailTempleLife),
]

// MARK: - Shared bits for the temples

extension Scenes {
    /// A wall of big dressed blocks between rows `top` and `bottom`: staggered courses with dark joints, a lit top
    /// edge on each block, and a little colour wander from block to block.
    private static func ijBlocks(_ c: PixelCanvas, top: Int, bottom: Int, course: Int, base: Px, joint: Px, lit: Px,
                                 seed: Int) {
        guard bottom > top else { return }
        c.rect(0, top, c.w, bottom - top, base)
        var row = 0
        for y in stride(from: top, to: bottom, by: course) {
            let len = course * 2 + course / 2
            let off = (row % 2) * len / 2
            var k = 0
            for x in stride(from: -off, to: c.w, by: len) {
                if noise(row * 53 + k + seed) > 0.6 { c.rect(x, y, len, course, joint.alpha(0.25)) }
                c.rect(x, y, 1, course, joint); c.rect(x + 1, y + 1, len - 2, 1, lit)
                k += 1
            }
            c.rect(0, y, c.w, 1, joint)
            row += 1
        }
    }

    /// A torch flame at (`x`, `y`), flickering with `t`: an orange tongue, a yellow core, a spark, and a soft glow.
    private static func ijFlame(_ c: PixelCanvas, _ x: Int, _ y: Int, _ s: Int, _ t: Double, _ i: Int) {
        let fl = sin(t * 12 + Double(i) * 1.9), fl2 = sin(t * 19 + Double(i) * 0.7)
        c.circle(x, y - 2 * s, (9 + Int(fl * 1.5)) * s, C(0xF09A40, 0.08))
        c.ellipse(x, y - 2 * s, 2 * s, (3 + Int(fl2 + 1)) * s, C(0xE8621A))
        c.ellipse(x + Int(fl) * s / 2, y - 2 * s, s, 2 * s, C(0xFFD870))
        c.rect(x + Int(fl2 * 2) * s / 2, y - (7 + Int(fl + 1)) * s, s, s, C(0xFFA040, 0.7))
    }

    /// A wall torch's bracket and wrapped head (the flame is drawn by the moving layer).
    private static func ijSconce(_ c: PixelCanvas, _ x: Int, _ y: Int, _ s: Int) {
        c.circle(x, y - 2 * s, 14 * s, C(0xF0A040, 0.06))
        c.rect(x - s, y, 2 * s, 6 * s, C(0x3A2A1A)); c.rect(x - 2 * s, y + 5 * s, 4 * s, s, C(0x2A2420))
        c.rect(x - 2 * s, y - s, 4 * s, 2 * s, C(0x5A3A1A))
    }
}

// MARK: - The idol temple

extension Scenes {
    /// Where things stand in the jungle temple: the tunnel mouth the boulder waits in (its middle and radius), the
    /// idol on its pedestal, the doorway with the spears across it, and the ceiling's height.
    private static func ijIdolFrame(_ c: PixelCanvas, _ g: Int) -> (tunnel: (x: Int, r: Int), idol: (x: Int, y: Int),
                                                                     door: (x: Int, w: Int, top: Int), ceiling: Int) {
        let s = unit(g), tall = isTall(c)
        let r = (tall ? 22 : 17) * s
        let idol = (x: c.w * 70 / 100, y: g - 31 * s)
        let door = (x: c.w * 36 / 100, w: 22 * s, top: g - 40 * s)
        return ((c.w * 9 / 100, r), idol, door, tall ? g * 42 / 100 : 0)
    }

    /// The golden idol, its base at (`x`, `y`): a squat seated figure with a big head, bulging eyes, hands on its
    /// knees, gold with a bright edge.
    private static func ijIdol(_ c: PixelCanvas, _ x: Int, _ y: Int, _ g: Int) {
        let p = Pen(c, x - 4 * unit(g), y - 9 * unit(g), g)
        let gold = C(0xE8B830), hi = C(0xFFE890), dk = C(0x9A6A10)
        p.rect(1, 5, 6, 4, gold); p.rect(0, 7, 8, 2, gold)      // body and knees
        p.rect(1, 0, 6, 5, gold); p.rect(2, -1, 4, 1, gold)    // the big head
        p.rect(1, 0, 1, 4, hi); p.rect(2, 1, 1, 1, dk); p.rect(5, 1, 1, 1, dk)
        p.rect(3, 3, 2, 1, dk); p.rect(0, 6, 1, 1, dk); p.rect(7, 6, 1, 1, dk)
        p.rect(0, 9, 8, 1, dk)
    }

    /// The idol temple: a dim corridor of mossy grey-green stone, light falling in long shafts from holes in the
    /// roof, the dark tunnel mouth on the left where the boulder waits, a doorway with spears jutting across it from
    /// the jambs and cobwebs in its corners, and on the right the stepped altar with the golden idol on its pedestal,
    /// caught in a shaft of light. The floor is laid in square slabs (some of them pressure plates). On the screen
    /// saver the roof has fallen in and the jungle canopy hangs over it, vines trailing down, sun breaking through.
    static func idolTemple(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ijIdolFrame(c, g)
        if tall { ijCanopy(c, g, s, f.ceiling) }
        ijBlocks(c, top: f.ceiling, bottom: g, course: 7 * s, base: C(0x4A4A38), joint: C(0x2A2A20), lit: C(0x5E5E48), seed: 3100)
        c.gradient(f.ceiling, f.ceiling + 22 * s, C(0x0E0E08, 0.85), C(0x0E0E08, 0), bands: 5)
        if tall { ijRelief(c, c.w * 52 / 100, f.ceiling + (g - f.ceiling) * 38 / 100, s) }
        // Moss and roots creeping down the wall.
        for i in 0..<(c.w / (14 * s)) {
            let x = Int(noise(i + 3200) * Double(c.w)), len = (4 + Int(noise(i + 3210) * 16)) * s
            c.rect(x, f.ceiling, 2 * s, len, C(0x4A6A2A, 0.6)); c.rect(x + s, f.ceiling + len, s, 2 * s, C(0x5A7A30, 0.5))
        }
        // Light shafts from holes in the roof.
        for (i, sx) in [c.w * 24 / 100, c.w * 52 / 100, f.idol.x].enumerated() {
            let top = f.ceiling, h = g - top
            c.rect(sx - 3 * s, top, 6 * s, 2 * s, C(0xFFF4C0, 0.6))
            for y in 0..<h {
                let hw = 3 * s + y / 9
                let x = sx - hw + y * (i == 2 ? 0 : 1) / 4
                c.rect(x, top + y, hw * 2, 1, C(0xF8E8A8, 0.07))
            }
        }
        // The tunnel mouth: an arch of big stones, black inside.
        let tn = f.tunnel
        let ar = tn.r + 4 * s
        c.rect(tn.x - ar, g - 2 * tn.r - 4 * s, 2 * ar, 2 * tn.r + 4 * s, C(0x3A3A2C))
        c.circle(tn.x, g - 2 * tn.r - 4 * s, ar, C(0x3A3A2C))
        c.rect(tn.x - tn.r - s, g - tn.r * 2 - 2 * s, 2 * tn.r + 2 * s, tn.r * 2 + 2 * s, C(0x080806))
        c.circle(tn.x, g - tn.r * 2 - 2 * s, tn.r + s, C(0x080806))
        for k in 0..<9 {
            let a = Double(k) / 8 * .pi
            let bx = tn.x - Int(cos(a) * Double(tn.r + 3 * s)), by = g - 2 * tn.r - 2 * s - Int(sin(a) * Double(tn.r + 3 * s))
            c.rect(bx - s, by - s, 2 * s, 2 * s, C(0x5A5A44))
        }
        // The doorway with spears across it.
        let d = f.door
        c.rect(d.x - 3 * s, d.top - 3 * s, d.w + 6 * s, 3 * s, C(0x5E5E48))
        c.rect(d.x - 3 * s, d.top, 3 * s, g - d.top, C(0x3A3A2C)); c.rect(d.x + d.w, d.top, 3 * s, g - d.top, C(0x3A3A2C))
        c.rect(d.x, d.top, d.w, g - d.top, C(0x14140E))
        for (j, sy) in [d.top + 8 * s, d.top + 15 * s].enumerated() {
            let from = j == 0 ? d.x : d.x + d.w
            let dir = j == 0 ? 1 : -1
            let len = d.w * 2 / 3
            c.rect(min(from, from + dir * len), sy, len, s, C(0x6A4A2A))
            c.rect(from + dir * len - (dir < 0 ? 3 * s : 0), sy - s / 2, 3 * s, s + 1, C(0xB8B0A0))
        }
        c.glowLine(Double(d.x), Double(d.top), Double(d.x + 6 * s), Double(d.top + 6 * s), core: C(0xE8E8E0, 0.35), glow: C(0, 0), coreR: 0.4)
        c.glowLine(Double(d.x + 6 * s), Double(d.top), Double(d.x), Double(d.top + 6 * s), core: C(0xE8E8E0, 0.25), glow: C(0, 0), coreR: 0.4)
        // Spear holes in the wall either side of the door.
        for hx in [d.x - 12 * s, d.x + d.w + 9 * s] {
            for hy in stride(from: d.top, to: g - 20 * s, by: 6 * s) { c.rect(hx, hy, 2 * s, 2 * s, C(0x101008)) }
        }
        // The altar: three steps, the pedestal, the idol in its light.
        let ix = f.idol.x
        for i in 0..<3 {
            let w = (40 - i * 10) * s
            c.rect(ix - w / 2, g - (i + 1) * 4 * s, w, 4 * s, C(0x6A6450)); c.rect(ix - w / 2, g - (i + 1) * 4 * s, w, s, C(0x8A8468))
        }
        c.rect(ix - 4 * s, f.idol.y, 8 * s, g - 12 * s - f.idol.y, C(0x5A5644))
        c.rect(ix - 6 * s, f.idol.y, 12 * s, 2 * s, C(0x7A7460)); c.rect(ix - 3 * s, f.idol.y + 2 * s, s, g - 14 * s - f.idol.y, C(0x6E6A56))
        c.circle(ix, f.idol.y - 5 * s, 10 * s, C(0xFFD860, 0.12))
        ijIdol(c, ix, f.idol.y, g)
        // A skull on the altar step.
        c.rect(ix + 12 * s, g - 7 * s, 3 * s, 3 * s, C(0xD8D0B8)); c.rect(ix + 12 * s, g - 6 * s, s, s, C(0x2A2418))
        // The floor: square slabs.
        c.ground(g, C(0x4E4A38), edge: C(0x7A745A), speck: C(0x5A5642), seed: 31)
        for x in stride(from: 0, to: c.w, by: 12 * s) { c.rect(x, g + s, s, c.h - g - s, C(0x3A3628)) }
        for x in stride(from: 6 * s, to: c.w, by: 36 * s) where g + 4 * s < c.h {
            c.rect(x, g + 2 * s, 5 * s, 2 * s, C(0x5E5A44))
        }
    }

    /// A great carved face in the temple wall on the screen saver: a slab of stone with a heavy brow, deep-set eyes,
    /// a block of a nose and a grimace of square teeth, moss in its cracks.
    private static func ijRelief(_ c: PixelCanvas, _ x: Int, _ y: Int, _ s: Int) {
        func R(_ u: Int, _ v: Int, _ w: Int, _ h: Int, _ col: Px) { c.rect(x - 25 * s + u * s, y - 20 * s + v * s, w * s, h * s, col) }
        let face = C(0x5E5E48), dark = C(0x24241A), lit = C(0x7A7A5E)
        R(-2, -2, 54, 44, dark); R(0, 0, 50, 40, face); R(0, 0, 50, 2, lit)
        R(4, 6, 42, 4, lit); R(4, 10, 42, 1, dark)                 // the brow
        R(9, 12, 10, 7, dark); R(31, 12, 10, 7, dark)              // eyes
        R(12, 14, 4, 3, C(0x0E0E08)); R(34, 14, 4, 3, C(0x0E0E08))
        R(21, 11, 8, 14, lit); R(21, 24, 8, 2, dark)               // nose
        R(10, 29, 30, 8, dark)                                     // the grimace
        for k in 0..<7 { R(11 + k * 4, 30, 3, 3, C(0xA8A488)); R(11 + k * 4, 34, 3, 2, C(0xA8A488)) }
        R(2, 20, 4, 1, C(0x4A6A2A)); R(44, 6, 2, 9, C(0x4A6A2A)); R(30, 38, 6, 2, C(0x4A6A2A))
    }

    /// The jungle canopy over the fallen roof on the screen saver: the wall's broken top, layered greens of the
    /// canopy above with gaps of hazy sunlight, and vines trailing down over the stones.
    private static func ijCanopy(_ c: PixelCanvas, _ g: Int, _ s: Int, _ ceiling: Int) {
        c.gradient(0, ceiling + 10 * s, C(0xC8D890), C(0x6A8A40), bands: 6)
        let greens = [C(0x1E3A18), C(0x2A4A1E), C(0x3A5E24), C(0x4A7028)]
        for layer in 0..<4 {
            for i in 0..<(c.w / (10 * s)) {
                let x = Int(noise(i * 5 + layer * 400 + 3300) * Double(c.w))
                let y = Int(noise(i * 5 + layer * 400 + 3301) * Double(ceiling)) * (4 - layer) / 4 + layer * ceiling / 6
                let r = (8 + Int(noise(i * 5 + layer * 400 + 3302) * 14)) * s
                c.ellipse(x, y, r, r * 2 / 3, greens[layer])
                c.ellipse(x - r / 4, y - r / 4, r / 2, r / 3, greens[min(3, layer + 1)].alpha(0.7))
            }
        }
        // The broken top of the wall, ragged against the leaves.
        for x in stride(from: 0, to: c.w, by: s) {
            let rag = Int(noise(x / max(1, s) / 3 + 3400) * Double(14 * s))
            c.rect(x, ceiling - rag, s, rag, C(0x4A4A38))
        }
        // Vines hanging down over the stone.
        for i in 0..<(c.w / (20 * s)) {
            let x = Int(noise(i + 3500) * Double(c.w)), len = (20 + Int(noise(i + 3510) * 50)) * s
            for y in stride(from: ceiling - 10 * s, to: ceiling + len, by: s) {
                let sway = Int(sin(Double(y) / Double(9 * s) + Double(i)) * Double(2 * s))
                c.rect(x + sway, y, s, s, C(0x2E5A1E))
                if (y / max(1, s)) % 5 == 0 { c.rect(x + sway + s, y, 2 * s, s, C(0x4A8A2A)) }
            }
        }
    }

    /// What moves in the idol temple: dust motes turning in the light shafts, a glint running over the idol, and the
    /// boulder: it waits in the tunnel mouth rocking on its seat, and every half minute rolls out and thunders across
    /// the back of the corridor, dust kicking up behind it.
    static func idolTempleLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = ijIdolFrame(c, g)
        // Dust in the shafts.
        for (i, sx) in [c.w * 24 / 100, c.w * 52 / 100, f.idol.x].enumerated() {
            for j in 0..<8 {
                let h = Double(g - f.ceiling)
                let y = (noise(i * 20 + j + 3600) * h + t * (2 + Double(j % 3))).truncatingRemainder(dividingBy: h)
                let x = sx + Int(sin(t * 0.7 + Double(j)) * Double(3 * s)) + Int(y) * (i == 2 ? 0 : 1) / 4
                c.rect(x, f.ceiling + Int(y), 1, 1, C(0xFFF4C8, 0.4 + 0.3 * sin(t + Double(j))))
            }
        }
        // The idol's glint.
        let gk = (t / 3).truncatingRemainder(dividingBy: 1)
        if gk < 0.3 {
            let gy = f.idol.y - 9 * s + Int(gk / 0.3 * Double(9 * s))
            c.rect(f.idol.x - 2 * s, gy, s, s, C(0xFFFFF0, 0.9)); c.rect(f.idol.x - 3 * s, gy, 3 * s, s, C(0xFFFFE0, 0.35))
        }
        // The boulder.
        let r = f.tunnel.r, cycle = t.truncatingRemainder(dividingBy: 30)
        var bx = Double(f.tunnel.x), roll = sin(t * 1.3) * 0.08
        if cycle > 24 {
            let k = (cycle - 24) / 6
            bx += k * k * Double(c.w + 2 * r)
            roll = (bx - Double(f.tunnel.x)) / Double(r)
            for p in 0..<5 {
                let px = Int(bx) - r - p * 4 * s, py = g - Int(noise(p + Int(t * 4)) * Double(6 * s))
                c.circle(px, py, (3 + p) * s, C(0xB8A880, 0.25))
            }
        }
        let by = g - r
        let cx = Int(bx)
        c.circle(cx, by, r, C(0x5E5440))
        c.circle(cx + r / 6, by - r / 6, r * 4 / 5, C(0x6E6450))
        c.circle(cx + r / 3, by - r / 3, r / 2, C(0x7E7460))
        for k in 0..<4 {
            let a = roll + Double(k) * .pi / 2
            let x0 = Double(cx) + cos(a) * Double(r) * 0.2, y0 = Double(by) + sin(a) * Double(r) * 0.2
            let x1 = Double(cx) + cos(a + 0.4) * Double(r) * 0.9, y1 = Double(by) + sin(a + 0.4) * Double(r) * 0.9
            c.glowLine(x0, y0, x1, y1, core: C(0x3A3426), glow: C(0, 0), coreR: Double(s) * 0.5)
        }
        c.rect(cx - r + 2 * s, by + r - s, 2 * r - 4 * s, s, C(0x2A2418))
    }
}

// MARK: - The Well of Souls

extension Scenes {
    /// Where things stand in the Well of Souls: the great statue (middle, height), the alcove with the Ark, the
    /// sand falls, the wall torches, and the opening high above.
    private static func ijWellFrame(_ c: PixelCanvas, _ g: Int) -> (statue: (x: Int, h: Int), ark: (x: Int, y: Int),
                                                                     sand: [Int], torches: [(x: Int, y: Int)], hole: (x: Int, w: Int)) {
        let s = unit(g), tall = isTall(c)
        let h = tall ? g * 78 / 100 : g - 2 * s
        let torches = [(x: c.w * 14 / 100, y: g - 32 * s), (x: c.w * 56 / 100, y: g - 32 * s), (x: c.w * 95 / 100, y: g - 30 * s)]
        return ((c.w * 78 / 100, h), (c.w * 36 / 100, g - 46 * s), [c.w * 26 / 100, c.w * 47 / 100, c.w * 66 / 100],
                torches, (c.w * 40 / 100, 46 * s))
    }

    /// The statue of the jackal-headed god, standing, `h` rows tall on `base` with its middle at `x`: black stone,
    /// tall ears, the long muzzle in profile, a gold eye, gold collar, belt and kilt, a staff in its hand.
    private static func ijAnubis(_ c: PixelCanvas, x: Int, base: Int, h: Int) {
        func R(_ u: Int, _ v: Int, _ w: Int, _ hh: Int, _ col: Px) {
            let x0 = x + u * h / 60, y0 = base - h + v * h / 60
            let x1 = x + (u + w) * h / 60, y1 = base - h + (v + hh) * h / 60
            c.rect(x0, y0, max(1, x1 - x0), max(1, y1 - y0), col)
        }
        let stone = C(0x1C1A20), lit = C(0x3A3844), gold = C(0xD8A840), blue = C(0x2A4A8A)
        // The staff, behind.
        R(12, 3, 1, 57, C(0x2A2830)); R(11, 2, 3, 1, gold); R(11, 0, 1, 2, C(0x2A2830)); R(13, 0, 1, 2, C(0x2A2830))
        // Legs and feet, the kilt, the torso, arms.
        R(-6, 40, 4, 18, stone); R(2, 40, 4, 18, stone); R(-6, 40, 1, 18, lit)
        R(-7, 58, 6, 2, stone); R(1, 58, 6, 2, stone)
        R(-8, 18, 16, 13, stone); R(-8, 18, 2, 13, lit)
        R(-11, 17, 3, 16, stone); R(8, 17, 3, 16, stone); R(-11, 17, 1, 16, lit)
        R(-11, 33, 3, 2, gold); R(8, 33, 3, 2, gold)
        R(-8, 30, 16, 2, gold)
        R(-8, 32, 16, 8, C(0xE8DCC0)); R(-3, 32, 6, 9, gold)
        for u in stride(from: -8, to: 8, by: 2) { R(u, 33, 1, 7, C(0xB8A88A)) }
        // The collar, gold and blue.
        R(-9, 15, 18, 4, gold); R(-8, 16, 16, 1, blue); R(-7, 18, 14, 1, blue)
        // The head: neck, lappets, the jackal's skull and muzzle, ears up.
        R(-3, 12, 6, 3, stone)
        R(-6, 9, 3, 8, gold); R(-6, 11, 3, 1, blue); R(-6, 13, 3, 1, blue)
        R(-5, 5, 9, 7, stone); R(-5, 5, 2, 7, lit)
        R(4, 7, 7, 3, stone); R(10, 8, 2, 2, stone); R(4, 10, 6, 1, C(0x141218))
        R(1, 7, 2, 1, gold)
        R(-4, -1, 2, 7, stone); R(1, -1, 2, 7, stone); R(-3, 0, 1, 4, C(0x4A3A3A)); R(2, 0, 1, 4, C(0x4A3A3A))
    }

    /// The Well of Souls: a chamber cut in ochre sandstone, columns of hieroglyphs in the walls, the great black
    /// statue of the jackal-headed god towering on the right with its gold collar and kilt, an alcove up high where
    /// the gold Ark sits with its winged figures, torches in brackets, heaps of sand where it has poured in, and the
    /// floor (the snakes are in the moving layer). On the screen saver the walls rise to the opening high above,
    /// daylight falling in a broad shaft and a rope hanging down, the statue at its full height.
    static func wellOfSouls(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ijWellFrame(c, g)
        ijBlocks(c, top: 0, bottom: g, course: 9 * s, base: C(0x8A6A3A), joint: C(0x4A3418), lit: C(0xA07E48), seed: 4100)
        // Hieroglyph columns.
        for col in 0..<(c.w / (30 * s)) {
            let x = col * 30 * s + 8 * s
            if abs(x - f.statue.x) < 24 * s { continue }
            for y in stride(from: max(4 * s, g / 3), to: g - 10 * s, by: 5 * s) {
                let k = Int(noise(col * 41 + y + 4200) * 4)
                switch k {
                case 0: c.rect(x, y, 3 * s, s, C(0x3A2410)); c.rect(x + s, y + s, s, 2 * s, C(0x3A2410))
                case 1: c.circle(x + s, y + s, s, C(0x3A2410))
                case 2: c.rect(x, y, s, 3 * s, C(0x3A2410)); c.rect(x + s, y + 2 * s, 2 * s, s, C(0x3A2410))
                default: c.rect(x, y + s, 3 * s, s, C(0x3A2410)); c.rect(x + 2 * s, y, s, s, C(0x3A2410))
                }
            }
            c.rect(x - 2 * s, g / 3 - 2 * s, s, g - g / 3 - 8 * s, C(0x5A4220, 0.5))
        }
        if tall { ijWellTop(c, g, s, f.hole) }
        // Darkness gathering at the top of the strip, warmth at the bottom.
        c.gradient(0, g / 2, C(0x140C04, tall ? 0.3 : 0.75), C(0x140C04, 0), bands: 5)
        // The alcove and the Ark.
        let ark = f.ark
        c.rect(ark.x - 14 * s, ark.y - 12 * s, 28 * s, 14 * s, C(0x2A1A0C)); c.rect(ark.x - 15 * s, ark.y + 2 * s, 30 * s, 2 * s, C(0xA07E48))
        c.circle(ark.x, ark.y - 4 * s, 12 * s, C(0xFFD060, 0.08))
        c.rect(ark.x - 8 * s, ark.y - 4 * s, 16 * s, 6 * s, C(0xD8A840)); c.rect(ark.x - 8 * s, ark.y - 4 * s, 16 * s, s, C(0xFFE080))
        c.rect(ark.x - 9 * s, ark.y - 5 * s, 18 * s, s, C(0xB8882A))
        c.rect(ark.x - 6 * s, ark.y - 8 * s, 2 * s, 3 * s, C(0xD8A840)); c.rect(ark.x + 4 * s, ark.y - 8 * s, 2 * s, 3 * s, C(0xD8A840))
        c.rect(ark.x - 5 * s, ark.y - 9 * s, 4 * s, s, C(0xE8C050)); c.rect(ark.x + s, ark.y - 9 * s, 4 * s, s, C(0xE8C050))
        c.rect(ark.x - 11 * s, ark.y, 22 * s, s, C(0x8A6A2A))
        // The statue.
        ijAnubis(c, x: f.statue.x, base: g, h: f.statue.h)
        // Wall torches.
        for tch in f.torches { ijSconce(c, tch.x, tch.y, s) }
        // Heaps of sand under the falls.
        for sx in f.sand {
            for i in 0..<(6 * s) { c.rect(sx - 10 * s + i * 2, g - i, 20 * s - i * 4, 1, C(0xC8A060)) }
        }
        // The floor, sandy stone.
        c.ground(g, C(0x6A4E28), edge: C(0xA07E48), speck: C(0x7A5E34), seed: 41)
    }

    /// The top of the well on the screen saver: the walls going up into shadow, the square opening cut in the roof
    /// with a hazy sky in it, daylight falling in a shaft to the floor, and a rope hanging down from the edge.
    private static func ijWellTop(_ c: PixelCanvas, _ g: Int, _ s: Int, _ hole: (x: Int, w: Int)) {
        let roof = g / 8
        c.rect(0, 0, c.w, roof, C(0x2A1A0C))
        c.gradient(roof, g / 2, C(0x1A1006, 0.7), C(0x1A1006, 0), bands: 6)
        c.rect(hole.x - hole.w / 2, 0, hole.w, roof, C(0xD8E4E8)); c.rect(hole.x - hole.w / 2, roof - 2 * s, hole.w, 2 * s, C(0x6A5030))
        c.rect(hole.x - hole.w / 2, 0, hole.w, roof / 3, C(0xA8C4D8))
        for y in roof..<g {
            let hw = hole.w / 2 + (y - roof) / 10
            c.rect(hole.x - hw + (y - roof) / 6, y, hw * 2, 1, C(0xFFF0C8, 0.06))
        }
        let rx = hole.x + hole.w / 2 - 6 * s
        for y in stride(from: roof - 2 * s, to: g * 62 / 100, by: s) {
            let sway = Int(sin(Double(y) / Double(30 * s)) * Double(2 * s))
            c.rect(rx + sway, y, s, s, C(0x8A7448))
        }
    }

    /// What moves in the Well of Souls: snakes writhing across the floor (dozens, banded and olive, heads up), sand
    /// pouring in thin streams from the cracks above, and the torches' flames.
    static func wellOfSoulsLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = ijWellFrame(c, g)
        for (i, tch) in f.torches.enumerated() { ijFlame(c, tch.x, tch.y, s, t, i) }
        // Sand pouring.
        let roof = isTall(c) ? g / 8 : 0
        for (i, sx) in f.sand.enumerated() {
            let fall = Double(g - roof)
            for j in 0..<((g - roof) / (3 * s)) {
                let y = (Double(j * 3 * s) + t * 30).truncatingRemainder(dividingBy: fall)
                let jitter = Int(noise(j + i * 50 + 4300) * 2) * s / 2
                c.rect(sx + jitter, roof + Int(y), s, 2 * s, C(0xE0C080, 0.75))
            }
            c.rect(sx - s, roof, 3 * s, s, C(0xE0C080, 0.6))
        }
        // Snakes on the floor.
        let floor = max(1, c.h - g)
        for i in 0..<(c.w / (11 * s)) {
            let len = 14 + Int(noise(i + 4400) * 10)
            let speed = (noise(i + 4410) - 0.5) * 10
            let span = Double(c.w + 40 * s)
            let hx = (noise(i + 4420) * span + t * speed).truncatingRemainder(dividingBy: span)
            let headX = (hx < 0 ? hx + span : hx) - Double(20 * s)
            let y0 = g + Int(noise(i + 4430) * Double(max(1, min(floor - 3 * s, 7 * s))))
            let dir = speed >= 0 ? -1.0 : 1.0
            let dark = noise(i + 4440) > 0.5
            let body = dark ? C(0x1E1A10) : C(0x3A3418)
            let band = dark ? C(0xB8A050) : C(0x8A9A3A)
            for k in 0..<len {
                let x = Int(headX + dir * Double(k * s))
                let wave = sin(Double(k) * 0.55 - t * 5 + Double(i)) * Double(2 * s)
                let taper = k > len - 4 ? 1 : 2
                let y = y0 + Int(wave.rounded())
                c.rect(x, y, s, taper * s, k % 4 == 0 ? band : body)
            }
            // The head raised, and the tongue flicking.
            let wave0 = Int((sin(-t * 5 + Double(i)) * Double(2 * s)).rounded())
            let hxI = Int(headX) - Int(dir) * s
            c.rect(hxI - s, y0 + wave0 - s, 3 * s, 2 * s, body)
            c.rect(hxI - Int(dir) * s, y0 + wave0 - s, s, s, C(0xE8D060))
            if sin(t * 5 + Double(i)) > 0.5 { c.rect(hxI - Int(dir) * 3 * s, y0 + wave0, 2 * s, s / 2 + 1, C(0xD83A2A)) }
        }
    }
}

// MARK: - The Temple of Doom

extension Scenes {
    /// Where things stand in the cavern: the lava's line, the two mine-cart tracks (height and run), the far ledge
    /// the chanters stand on, and the idol's middle.
    private static func ijDoomFrame(_ c: PixelCanvas, _ g: Int) -> (lava: Int, high: Int, low: (y: Int, x0: Int),
                                                                     ledge: (x0: Int, x1: Int, y: Int), idol: Int) {
        let s = unit(g)
        return (g - 15 * s, g - 47 * s, (g - 26 * s, c.w * 55 / 100), (c.w * 4 / 100, c.w * 30 / 100, g - 30 * s), c.w / 2)
    }

    /// The height of the high track at column `x`: it dips and climbs along the cavern.
    private static func ijTrackY(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let f = ijDoomFrame(c, g), s = unit(g)
        return f.high + Int(sin(Double(x) / Double(c.w) * 2 * .pi + 0.6) * Double(5 * s))
    }

    /// A mine cart on rails: a riveted iron tub on little wheels, its bottom at (`x`, `y`).
    private static func ijCart(_ c: PixelCanvas, _ x: Int, _ y: Int, _ s: Int, _ body: Px) {
        c.rect(x - 7 * s, y - 7 * s, 14 * s, 5 * s, body); c.rect(x - 8 * s, y - 8 * s, 16 * s, s, C(0x6A6A70))
        c.rect(x - 6 * s, y - 6 * s, s, 3 * s, C(0x2A2A2E)); c.rect(x + 5 * s, y - 6 * s, s, 3 * s, C(0x2A2A2E))
        c.circle(x - 4 * s, y - s, s, C(0x1A1A1E)); c.circle(x + 4 * s, y - s, s, C(0x1A1A1E))
    }

    /// The Temple of Doom: a crimson cavern lit from below by the lava glowing in the pit, a high mine-cart track
    /// snaking along on spindly wooden trestles with a cart standing on it, a lower track running off to the right,
    /// a far ledge on the left where the cult's chanters stand (they sway in the moving layer), and the hot rock
    /// floor in front. On the screen saver the cavern opens up: the great many-armed idol of the goddess carved into
    /// the rock above the pit, eyes glowing, a necklace of skulls, the sacrifice cage hanging on its chain.
    static func templeOfDoom(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ijDoomFrame(c, g)
        c.gradient(0, g, C(0x0E0406), C(0x6A1A0E), bands: tall ? 12 : 7)
        for i in 0..<(c.w * g / (tall ? 800 : 240)) {
            let x = Int(noise(i * 4 + 5001) * Double(c.w)), y = Int(noise(i * 4 + 5002) * Double(g))
            let r = (2 + Int(noise(i * 4 + 5003) * 6)) * s
            c.ellipse(x, y, r * 2, r, C(0x1A0606, 0.3)); c.rect(x - r, y + r - s, r * 2, s, C(0xC84A1A, 0.1))
        }
        if tall { ijKali(c, g, s, f.idol) }
        // The pit: lava glowing between the rocks at the back.
        c.rect(0, f.lava - 10 * s, c.w, 10 * s, C(0xF05A1A, 0.12))
        c.rect(0, f.lava - 4 * s, c.w, 4 * s, C(0xF05A1A, 0.15))
        c.rect(0, f.lava, c.w, 3 * s, C(0xE8501A))
        c.rect(0, f.lava, c.w, s, C(0xFFC050))
        // The near lip of the pit: black rock, lit red along its edge, with lumps breaking the lava line.
        c.rect(0, f.lava + 3 * s, c.w, g - f.lava - 3 * s, C(0x1A0806))
        c.rect(0, f.lava + 3 * s, c.w, s, C(0xC84A1A, 0.7))
        for i in 0..<(c.w / (24 * s)) {
            let x = Int(noise(i + 5100) * Double(c.w)), r = (4 + Int(noise(i + 5110) * 8)) * s
            c.ellipse(x, f.lava + 4 * s, r, r / 3 + s, C(0x1A0806)); c.rect(x - r / 2, f.lava + 3 * s - r / 3, r, s, C(0xE8641A, 0.5))
        }
        for i in 0..<(c.w / (50 * s)) {
            let x = Int(noise(i + 5150) * Double(c.w))
            for j in 0..<(5 * s) { c.rect(x + j, f.lava + 5 * s + j, s, s, C(0xE8501A, 0.45)) }
        }
        // The far ledge for the chanters.
        let l = f.ledge
        c.rect(l.x0, l.y, l.x1 - l.x0, 3 * s, C(0x2A0E0A)); c.rect(l.x0, l.y, l.x1 - l.x0, s, C(0xC84A1A, 0.6))
        for x in stride(from: l.x0 + 4 * s, to: l.x1, by: 18 * s) {
            c.rect(x, l.y + 3 * s, 2 * s, f.lava - l.y - 3 * s, C(0x2A0E0A))
        }
        // The high track on its trestles.
        for x in stride(from: 0, to: c.w, by: 22 * s) {
            let ty = ijTrackY(c, g, x)
            c.glowLine(Double(x), Double(ty + 2 * s), Double(x - 6 * s), Double(f.lava), core: C(0x3A1E10), glow: C(0, 0), coreR: Double(s) * 0.6)
            c.glowLine(Double(x), Double(ty + 2 * s), Double(x + 6 * s), Double(f.lava), core: C(0x3A1E10), glow: C(0, 0), coreR: Double(s) * 0.6)
            c.glowLine(Double(x - 4 * s), Double(ty + 12 * s), Double(x + 4 * s), Double(ty + 12 * s), core: C(0x2A1408),
                       glow: C(0, 0), coreR: Double(s) * 0.5)
        }
        for x in stride(from: 0, to: c.w, by: s) {
            let ty = ijTrackY(c, g, x)
            c.rect(x, ty, s, s, C(0x8A8A90)); c.rect(x, ty + s, s, s, C(0x4A2414))
            if (x / max(1, s)) % 4 == 0 { c.rect(x, ty + s, s, 2 * s, C(0x5A3018)) }
        }
        let parked = c.w * 18 / 100
        ijCart(c, parked, ijTrackY(c, g, parked), s, C(0x4A4A50))
        // The low track, coming in from the middle and running off to the right.
        let lo = f.low
        for x in stride(from: lo.x0, to: c.w, by: s) {
            let y = lo.y + (x - lo.x0) / 12
            c.rect(x, y, s, s, C(0x8A8A90)); c.rect(x, y + s, s, s, C(0x4A2414))
        }
        for x in stride(from: lo.x0 + 6 * s, to: c.w, by: 26 * s) {
            let y = lo.y + (x - lo.x0) / 12
            c.rect(x, y + 2 * s, 2 * s, g - y, C(0x3A1E10))
        }
        // The floor: hot black rock with glowing cracks.
        c.ground(g, C(0x1E0C08), edge: C(0xC84A1A), speck: C(0x3A1408), seed: 51)
        for i in 0..<(c.w / (40 * s)) {
            let x = Int(noise(i + 5200) * Double(c.w))
            for j in 0..<(6 * s) where g + 2 * s + j / 2 < c.h { c.rect(x + j, g + 2 * s + j / 2, s, s, C(0xF06A1A, 0.6)) }
        }
    }

    /// The cavern's upper reaches on the screen saver: the huge idol of the goddess carved into the rock, her many
    /// arms fanning out, a crown, glowing eyes and a red tongue, a necklace of skulls; pillars of rock to either
    /// side; and the cage hanging on its chain over the pit.
    private static func ijKali(_ c: PixelCanvas, _ g: Int, _ s: Int, _ x: Int) {
        let h = g * 52 / 100, top = g * 14 / 100
        let u = max(1, h / 60)
        func R(_ a: Int, _ b: Int, _ w: Int, _ hh: Int, _ col: Px) { c.rect(x + a * u, top + b * u, w * u, hh * u, col) }
        let stone = C(0x3A1E1E), dark = C(0x220E0E), lit = C(0x6A3A2A)
        c.circle(x, top + 20 * u, 34 * u, C(0xE8501A, 0.08))
        // The ring of flames behind her, carved.
        for k in 0..<36 {
            let a = Double(k) / 36 * 2 * .pi
            let rx = Double(x) + cos(a) * Double(30 * u), ry = Double(top + 22 * u) + sin(a) * Double(30 * u)
            if ry < Double(top + 46 * u) {
                c.rect(Int(rx) - u, Int(ry) - u, 2 * u, 2 * u, C(0x8A4A1A))
                c.rect(Int(rx), Int(ry) - 2 * u, u, u, C(0xE8801A, 0.7))
            }
        }
        // Arms fanning out, four each side, thick at the shoulder, each hand holding something.
        for i in 0..<4 {
            let a = -0.9 + Double(i) * 0.45
            let len = Double(26 * u)
            let sx = Double(x), sy = Double(top + 22 * u)
            for side in [-1.0, 1.0] {
                let ex = sx + side * cos(a) * len, ey = sy + sin(a) * len
                let mx = sx + side * cos(a) * len * 0.5, my = sy + sin(a) * len * 0.5
                c.glowLine(sx, sy, mx, my, core: stone, glow: C(0, 0), coreR: Double(u) * 2.2)
                c.glowLine(mx, my, ex, ey, core: stone, glow: C(0, 0), coreR: Double(u) * 1.4)
                c.glowLine(sx, sy - Double(u), ex, ey - Double(u), core: lit, glow: C(0, 0), coreR: Double(u) * 0.4)
                c.circle(Int(ex), Int(ey), 2 * u, lit)
                if i == 0 {
                    c.glowLine(ex, ey, ex + side * Double(3 * u), ey - Double(10 * u), core: C(0xC8C0B0), glow: C(0, 0), coreR: Double(u) * 0.6)
                } else if i == 3 {
                    c.circle(Int(ex), Int(ey) + 2 * u, u + u / 2, C(0xE8DCC0))
                }
            }
        }
        // Body, skirt and the crossed legs on the base.
        R(-9, 18, 18, 22, stone); R(-9, 18, 2, 22, lit)
        R(-14, 40, 28, 10, dark); R(-16, 50, 32, 6, stone); R(-20, 56, 40, 4, dark)
        // The necklace of skulls.
        for k in 0..<7 { R(-9 + k * 3, 22 + abs(k - 3), 2, 2, C(0xE8DCC0)) }
        // Head: crown, face, glowing eyes, tongue.
        R(-6, 6, 12, 12, stone); R(-6, 6, 2, 12, lit)
        R(-7, 0, 14, 6, C(0xC8962A)); for k in 0..<4 { R(-7 + k * 4, -3, 2, 3, C(0xC8962A)) }
        R(-4, 10, 2, 2, C(0xFFD040)); R(2, 10, 2, 2, C(0xFFD040))
        R(-1, 15, 2, 4, C(0xC8281A))
        // Rock pillars either side.
        for px in [c.w * 12 / 100, c.w * 88 / 100] {
            c.rect(px - 10 * s, 0, 20 * s, g, C(0x1A0808)); c.rect(px - 10 * s, 0, 2 * s, g, C(0x5A1A10, 0.6))
        }
        // The cage on its chain.
        let cx = c.w * 70 / 100, cy = g * 46 / 100
        for y in stride(from: 0, to: cy, by: 2 * s) { c.rect(cx, y, s, s, C(0x6A6A70)) }
        c.rect(cx - 8 * s, cy, 17 * s, 2 * s, C(0x4A4A50)); c.rect(cx - 8 * s, cy + 18 * s, 17 * s, 2 * s, C(0x4A4A50))
        for bx in stride(from: cx - 8 * s, through: cx + 8 * s, by: 4 * s) { c.rect(bx, cy, s, 20 * s, C(0x4A4A50)) }
    }

    /// What moves in the Temple of Doom: the lava's surface heaving with bubbles and embers drifting up, a mine cart
    /// racing along the high track, and the chanters on the far ledge swaying, arms rising and falling together, a
    /// torch between them.
    static func templeOfDoomLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = ijDoomFrame(c, g)
        // Lava bubbles and the glow breathing.
        c.rect(0, f.lava - 14 * s, c.w, 14 * s, C(0xF05A1A, 0.05 + 0.04 * sin(t * 1.7)))
        for i in 0..<12 {
            let x = Int(noise(i + 5300) * Double(c.w))
            let k = (t / (1.5 + noise(i + 5310)) + noise(i + 5320)).truncatingRemainder(dividingBy: 1)
            if k < 0.6 { c.circle(x, f.lava + s, Int(k * 3) * s / 2 + s / 2, C(0xFFD060, 0.8)) }
        }
        // Embers rising.
        for i in 0..<16 {
            let h = Double(f.lava)
            let y = h - (noise(i + 5400) * h + t * (6 + noise(i + 5410) * 8)).truncatingRemainder(dividingBy: h)
            let x = Int(noise(i + 5420) * Double(c.w)) + Int(sin(t + Double(i)) * Double(3 * s))
            c.rect(x, Int(y), s, s, C(0xFFA040, 0.3 + 0.4 * (y / h)))
        }
        // The chanters: robed shapes swaying, arms up and down in time.
        let l = f.ledge
        let n = (l.x1 - l.x0) / (9 * s)
        for i in 0..<n {
            let x = l.x0 + 4 * s + i * 9 * s
            let beat = sin(t * 2.4 + Double(i % 2) * .pi)
            let lean = Int(beat * Double(s))
            c.rect(x - s + lean, l.y - 7 * s, 3 * s, 7 * s, C(0x140404))
            c.rect(x + lean, l.y - 9 * s, s, 2 * s, C(0x140404))
            c.rect(x + lean, l.y - 8 * s, s, s, C(0xC8962A, 0.6))
            let armY = beat > 0 ? l.y - 11 * s : l.y - 6 * s
            c.rect(x - 2 * s + lean, armY, s, 3 * s, C(0x140404)); c.rect(x + 2 * s + lean, armY, s, 3 * s, C(0x140404))
            if i == n / 2 { ijFlame(c, x + 5 * s, l.y - 9 * s, s, t, i) }
        }
        // A cart racing along the high track.
        let span = Double(c.w + 40 * s)
        let cx = Int((t * 70).truncatingRemainder(dividingBy: span)) - 20 * s
        ijCart(c, cx, ijTrackY(c, g, cx), s, C(0x5A5A60))
        c.rect(cx - 5 * s, ijTrackY(c, g, cx) - 10 * s, 3 * s, 3 * s, C(0xF08A2A))
        for p in 0..<3 { c.rect(cx - (10 + p * 4) * s, ijTrackY(c, g, cx) - (1 + p) * s, s, s, C(0xFFD060, 0.8 - Double(p) * 0.25)) }
    }
}

// MARK: - The Grail temple

extension Scenes {
    /// Where things stand in the canyon: the façade's middle, its base and scale (pixels to a unit, a hundred units
    /// tall in all), the door, and the inner edges of the canyon walls.
    private static func ijGrailFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, base: Int, u: Double, siq: (l: Int, r: Int)) {
        let s = unit(g), tall = isTall(c)
        let u = tall ? Double(g) * 0.78 / 100 : Double(g - 4 * s) / 56
        return (c.w / 2, g, u, (c.w * (tall ? 16 : 20) / 100, c.w * (tall ? 84 : 80) / 100))
    }

    /// The treasury façade carved into the cliff, its middle at `cx` and its foot on `base`, `u` pixels to a unit
    /// (fifty units for each storey): steps, six columns with the doorway between the middle pair, weathered riders
    /// between the outer ones, the entablature and pediment; above, the round pavilion with its cone and urn between
    /// two half-pavilions with broken pediments.
    private static func ijFacade(_ c: PixelCanvas, cx: Int, base: Int, u: Double) {
        func R(_ a: Double, _ b: Double, _ w: Double, _ h: Double, _ col: Px) {
            let x0 = cx + Int((a * u).rounded()), y0 = base + Int((b * u).rounded())
            let x1 = cx + Int(((a + w) * u).rounded()), y1 = base + Int(((b + h) * u).rounded())
            c.rect(x0, y0, max(1, x1 - x0), max(1, y1 - y0), col)
        }
        let lit = C(0xE09A78), face = C(0xC87A5A), shade = C(0xA05A44), deep = C(0x6A3428), recess = C(0x4A2018)
        // The cut in the cliff the façade stands in.
        R(-52, -104, 104, 104, shade)
        // Lower storey: the recess, columns, door, riders.
        R(-48, -42, 96, 36, deep)
        R(-7, -32, 14, 26, C(0x1A0A06)); R(-8, -33, 16, 1, lit); R(-8, -33, 1, 27, face); R(7, -33, 1, 27, face)
        for (i, colX) in [-42.0, -30.0, -12.0, 12.0, 30.0, 42.0].enumerated() {
            R(colX - 2.5, -38, 5, 32, face); R(colX - 2.5, -38, 1.5, 32, lit); R(colX + 1.5, -38, 1, 32, shade)
            R(colX - 3.5, -41, 7, 3, lit); R(colX - 3.5, -7, 7, 1.5, shade)
            if i == 0 || i == 4 {
                R(colX + 4, -26, 7, 8, shade); R(colX + 6, -30, 3, 4, shade); R(colX + 4, -18, 2, 6, shade)
            }
        }
        // Steps.
        R(-50, -6, 100, 2, face); R(-50, -6, 100, 0.6, lit); R(-52, -4, 104, 2, lit); R(-54, -2, 108, 2, face)
        // Entablature and pediment.
        R(-50, -47, 100, 6, face); R(-50, -47, 100, 1, lit); R(-50, -42, 100, 1, deep)
        for k in 0..<12 { R(-46 + Double(k) * 8, -45.5, 2, 2, shade) }
        for i in 0..<9 {
            let w = 52 - Double(i) * 6
            R(-w / 2, -48 - Double(i), w, 1, i == 8 ? lit : face)
        }
        R(-24, -48, 48, 0.6, lit)
        // Upper storey.
        R(-50, -59, 100, 3, face); R(-50, -59, 100, 0.8, lit)
        R(-48, -92, 96, 33, deep)
        for side in [-1.0, 1.0] {
            let mid = side * 37
            for colX in [mid - 9, mid + 9] {
                R(colX - 2, -86, 4, 27, face); R(colX - 2, -86, 1, 27, lit); R(colX - 3, -88, 6, 2, lit)
            }
            R(mid - 12, -92, 24, 4, face); R(mid - 12, -92, 24, 1, lit)
            // The broken half-pediment, rising towards the outside.
            for i in 0..<6 {
                let w = 9 - Double(i) * 1.5
                let x0 = side < 0 ? mid - 12 : mid + 12 - w
                R(x0, -93 - Double(i), w, 1, face)
            }
        }
        // The round pavilion: drum and columns, the cone, the urn on top.
        R(-14, -86, 28, 27, shade)
        for colX in [-12.0, -4.0, 4.0, 12.0] {
            R(colX - 1.5, -84, 3, 25, face); R(colX - 1.5, -84, 1, 25, lit)
        }
        R(-15, -88, 30, 4, face); R(-15, -88, 30, 1, lit)
        for i in 0..<8 {
            let w = 24 - Double(i) * 3
            R(-w / 2, -89 - Double(i), w, 1, i % 2 == 0 ? face : shade)
        }
        R(-2, -100, 4, 4, face); R(-3, -101, 6, 1.5, lit); R(-1, -103, 2, 2, face)
        R(-48, -102, 96, 1, recess)
    }

    /// A wall of the canyon in shadow, from the screen's edge to `edge` (rough), with the sandstone's swirled bands.
    private static func ijSiq(_ c: PixelCanvas, _ g: Int, left: Bool, edge: Int, s: Int, narrowing: Bool) {
        let bands = [C(0x7A3A2C), C(0x8A4632), C(0x6A3226), C(0x94503A), C(0x7E4030)]
        let seed = left ? 6000 : 6100
        for y in 0..<g {
            let k = 1 - Double(y) / Double(g)
            let pinch = narrowing ? Int(pow(k, 1.6) * Double(c.w) * 0.2) : 0
            let lump = Int(sin(Double(y) / Double(23 * s) + Double(seed)) * Double(6 * s))
            let rough = Int(noise(y / max(1, 2 * s) + seed) * Double(4 * s))
            let e = left ? edge + pinch + rough + lump : edge - pinch - rough - lump
            let x0 = left ? 0 : max(0, e), x1 = left ? min(c.w, e) : c.w
            guard x1 > x0 else { continue }
            for x in stride(from: x0, to: x1, by: s) {
                let swirl = sin(Double(x) / Double(21 * s) + Double(y) / Double(53 * s)) * Double(5 * s)
                let b = (y + Int(swirl)) / max(1, 3 * s)
                c.rect(x, y, s, 1, bands[((b % 5) + 5) % 5])
            }
            if left { c.rect(e - s, y, s, 1, C(0xC87A5A, 0.6)) } else { c.rect(e, y, s, 1, C(0x5A2A20)) }
        }
    }

    /// The Grail temple: the rose-red treasury façade cut into the canyon's cliff in sunlight, six columns and the
    /// dark doorway with torches either side, the pediment over them, glimpsed between the shadowed walls of the
    /// narrow canyon in banded sandstone, a pale sandy floor. On the screen saver the whole façade stands up, the
    /// round pavilion and its urn on top, and the canyon walls lean in until only a sliver of blue sky is left.
    static func grailTemple(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ijGrailFrame(c, g)
        c.gradient(0, g, C(0xC88468), C(0xD8967A), bands: 5)
        if tall {
            c.gradient(0, g / 5, C(0x5A8AC8), C(0xB8D0E0), bands: 5)
        }
        // The cliff face: banded sandstone, lit.
        for y in stride(from: tall ? g / 6 : 0, to: g, by: s) {
            let w = sin(Double(y) / Double(11 * s)) * 0.5 + 0.5
            c.rect(0, y, c.w, s, C(0xB86E52, 0.25 + w * 0.2))
        }
        ijFacade(c, cx: f.cx, base: f.base, u: f.u)
        // Torches either side of the door.
        let tx = Int(12 * f.u) + 4 * s
        for d in [-1, 1] { ijSconce(c, f.cx + d * tx, g - Int(20 * f.u), s) }
        // The canyon walls in shadow.
        ijSiq(c, g, left: true, edge: f.siq.l, s: s, narrowing: tall)
        ijSiq(c, g, left: false, edge: f.siq.r, s: s, narrowing: tall)
        // The sandy floor.
        c.ground(g, C(0xC8987A), edge: C(0xE8B898), speck: C(0xB08468), seed: 21)
        for i in 0..<(c.w / (30 * s)) {
            let x = Int(noise(i + 6200) * Double(c.w))
            c.rect(x, g - s, (6 + Int(noise(i + 6210) * 8)) * s, s, C(0xD8A888))
        }
    }

    /// What moves in the canyon: dust drifting through the light in a slow haze and in motes, the torches by the
    /// door flickering, and the doorway's dark breathing with the firelight inside.
    static func grailTempleLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = ijGrailFrame(c, g)
        let tx = Int(12 * f.u) + 4 * s
        for (i, d) in [-1, 1].enumerated() { ijFlame(c, f.cx + d * tx, g - Int(20 * f.u), s, t, i) }
        let glow = 0.12 + 0.06 * sin(t * 7)
        let dw = Int(14 * f.u), dh = Int(20 * f.u)
        c.rect(f.cx - dw / 2, g - Int(6 * f.u) - dh, dw, dh, C(0xF08A3A, glow))
        // Dust: a slow band of haze and motes drifting across.
        for i in 0..<5 {
            let span = Double(c.w + 160 * s)
            let x = (noise(i + 6300) * span + t * (5 + Double(i))).truncatingRemainder(dividingBy: span) - Double(80 * s)
            let y = g - (6 + Int(noise(i + 6310) * 30)) * s
            c.ellipse(Int(x), y, (50 + i * 10) * s, (3 + i % 2) * s, C(0xF0C8A8, 0.07))
        }
        for i in 0..<24 {
            let span = Double(c.w)
            let x = (noise(i + 6400) * span + t * (8 + noise(i + 6410) * 10)).truncatingRemainder(dividingBy: span)
            let y = Double(g) * noise(i + 6420) + sin(t * 0.8 + Double(i)) * Double(4 * s)
            c.rect(Int(x), Int(y), s, s, C(0xFFE8D0, 0.35 + 0.25 * sin(t * 2 + Double(i))))
        }
    }
}
