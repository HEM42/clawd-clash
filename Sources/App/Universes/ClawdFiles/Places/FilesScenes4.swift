import Foundation

// Where the aliens are: the Antarctic ice field, the mothership, Ruskin Dam and the cornfield with the bee domes.

let filesScenes4: [Location: Place] = [
    .antarctic: Place(name: "The Antarctic Ice Field", panel: 0x0C1620, still: Scenes.antarctic, moving: Scenes.antarcticLife),
    .mothership: Place(name: "The Mothership", panel: 0x0A100E, still: Scenes.mothership, moving: Scenes.mothershipLife),
    .ruskinDam: Place(name: "Ruskin Dam", panel: 0x0E0E14, still: Scenes.ruskinDam, moving: Scenes.ruskinDamLife),
    .beeDomes: Place(name: "The Cornfield and the Bee Domes", panel: 0x0C120C, still: Scenes.beeDomes, moving: Scenes.beeDomesLife),
]

// MARK: - Shared bits

extension Scenes {
    /// A saucer seen from the side: the dark hull widest at `cy`, `r` across from the middle, its dome on top.
    static func s4Saucer(_ c: PixelCanvas, cx: Int, cy: Int, r: Int, hull: Px, rim: Px, dome: Px) {
        let h = max(2, r / 4)
        for dy in -h...h {
            let k = 1 - Double(dy * dy) / Double(h * h)
            let half = Int(Double(r) * k.squareRoot())
            c.rect(cx - half, cy + dy, half * 2 + 1, 1, dy < 0 ? hull : hull.alpha(0.85))
        }
        c.rect(cx - r, cy, r * 2 + 1, max(1, r / 24), rim)
        c.ellipse(cx, cy - h, r / 3, max(2, r / 6), dome)
    }
}

// MARK: - The Antarctic ice field

extension Scenes {
    /// Where the ship sits in the ice: its middle, its half-width and the hull's line at rest.
    static func s4ShipFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, cy: Int, r: Int) {
        let s = unit(g), tall = isTall(c)
        let r = tall ? min(c.w / 3, g / 3) : min(c.w / 7, 46 * s)
        return (c.w * 62 / 100, g - (tall ? g / 6 : 24 * s), r)
    }

    /// The Antarctic: a night of deep blue over a long white ice field, the aurora hanging in green curtains, pressure
    /// ridges and ice cliffs along the horizon, and, half out of a broken crater in the ice, the great dark saucer.
    static func antarctic(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = s4ShipFrame(c, g)
        c.gradient(0, g, C(0x060A18), C(0x24425A), bands: 9)
        c.stars(0, g * 2 / 3, density: tall ? 220 : 110, seed: 71)
        // The aurora: soft green curtains, folds hanging down.
        let top = tall ? g / 8 : 2 * s, depth = tall ? g / 4 : g / 3
        for x in stride(from: 0, to: c.w, by: s) {
            let wave = sin(Double(x) / Double(40 * s)) * Double(depth) / 4 + sin(Double(x) / Double(13 * s)) * Double(3 * s)
            let y0 = top + Int(wave) + depth / 4
            let len = depth / 2 + Int(noise(x / s + 400) * Double(depth / 3))
            for k in 0..<len where k % s == 0 {
                let a = 0.16 * (1 - Double(k) / Double(len))
                c.rect(x, y0 + k, s, s, C(0x6AF0A0, a))
            }
        }
        // Ice cliffs and pressure ridges along the horizon.
        let horizon = g - (tall ? g / 5 : 22 * s)
        for i in 0..<9 {
            let x = Int(noise(i + 300) * Double(c.w)), w = (24 + Int(noise(i + 310) * 40)) * s, h = (6 + Int(noise(i + 320) * 12)) * s
            for dy in 0..<h {
                let half = w / 2 - dy * w / 2 / max(1, h) / 2
                c.rect(x - half, horizon - h + dy + h / 3, half * 2, 1, dy < 2 * s ? C(0xD8ECF4) : C(0x9AB8CC))
            }
        }
        c.rect(0, horizon, c.w, g - horizon, C(0xB8D0DC))
        for i in 0..<(c.w / (18 * s)) {   // drifts and long blue shadows across the field
            let x = Int(noise(i + 340) * Double(c.w)), y = horizon + Int(noise(i + 350) * Double(g - horizon))
            c.rect(x, y, (10 + Int(noise(i + 360) * 22)) * s, s, C(0x86A4B8))
        }
        // The crater the ship broke out of: a dark bowl, ice slabs tipped up round its lip.
        c.ellipse(f.cx, f.cy + f.r / 6, f.r + 6 * s, max(3 * s, f.r / 5), C(0x2A3E4E))
        for i in 0..<7 {
            let a = Double(i) / 6 * .pi
            let x = f.cx - Int(cos(a) * Double(f.r + 4 * s)), w = (6 + i % 3 * 3) * s
            c.rect(x - w / 2, f.cy + f.r / 8 - (i % 2 + 2) * s, w, (i % 2 + 3) * s, C(0xE4F2F8))
            c.rect(x - w / 2, f.cy + f.r / 8 - (i % 2 + 2) * s, w, s, C(0xFFFFFF))
        }
        // The ice floor the crew stands on.
        c.ground(g, C(0xC8DCE6), edge: C(0xF2FAFF), speck: C(0xA4BCCC), seed: 73)
        if tall {   // a research hut and its antenna, far off on the left
            let hx = c.w / 10, hy = horizon - 2 * s
            c.rect(hx, hy - 8 * s, 18 * s, 8 * s, C(0xB8402E)); c.rect(hx, hy - 9 * s, 18 * s, s, C(0xE4F2F8))
            c.rect(hx + 3 * s, hy - 5 * s, 3 * s, 3 * s, C(0xFFE08A)); c.rect(hx + 22 * s, hy - 24 * s, s, 24 * s, C(0x4A5662))
        }
    }

    /// What moves on the ice: the ship heaving up out of its crater and settling, its rim lights running, a glow under
    /// it, and snow blowing sideways across the field.
    static func antarcticLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = s4ShipFrame(c, g)
        let rise = Int((0.5 - 0.5 * cos(t * 2 * .pi / 9)) * Double(max(4 * s, f.r / 5)))
        let cy = f.cy - rise
        c.ellipse(f.cx, f.cy + f.r / 6, f.r, max(2 * s, f.r / 6), C(0x8AFFC8, 0.1 + 0.08 * Double(rise) / Double(max(1, f.r / 5))))
        s4Saucer(c, cx: f.cx, cy: cy, r: f.r, hull: C(0x1E262E), rim: C(0x4A5A66), dome: C(0x2E3A44))
        // The lights round the rim, chasing.
        let n = 14
        for i in 0..<n {
            let a = Double(i) / Double(n - 1)
            let x = f.cx - f.r + Int(a * Double(f.r * 2))
            let on = (i + Int(t * 6)) % 4 == 0
            c.rect(x - s / 2, cy, max(1, s), max(1, s), on ? C(0x8AFFB4) : C(0x2E6A4A))
        }
        // Snow, blowing left to right.
        for i in 0..<(c.w * g / (220 * s * s)) {
            let speed = 30 + noise(i * 3 + 1) * 40
            let x = Int((noise(i * 3) * Double(c.w) + t * speed * Double(s))) % c.w
            let y = Int(noise(i * 3 + 2) * Double(g)) + Int(sin(t * 2 + Double(i)) * Double(2 * s))
            c.rect(x, y, s, s, C(0xF2F8FF, 0.6))
        }
    }
}

// MARK: - The mothership

extension Scenes {
    /// The mothership: a vast round hall inside the saucer. Ribbed metal walls curving up into the dark, panels of
    /// alien glyphs glowing green, pods of pale silhouettes along the wall, and a ring of light in the floor, where the
    /// beam comes up from below. On the screen saver the ribs arch up into the dome, rings of lights round its crown.
    static func mothership(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x060A08), C(0x18241E), bands: 8)
        // The ribs, curving in towards the top.
        let ribs = max(6, c.w / (40 * s))
        for i in 0...ribs where abs(i * c.w / ribs - c.w / 2) > 8 * s {   // none up the middle, where the beam is
            let baseX = i * c.w / ribs
            for y in 0..<g {
                let k = Double(g - y) / Double(g)
                let x = baseX + Int(Double(c.w / 2 - baseX) * k * k * (tall ? 0.9 : 0.35))
                c.rect(x - s, y, 3 * s, 1, C(0x26322C)); c.rect(x - s, y, s, 1, C(0x3E5046))
            }
        }
        if tall {   // the dome's crown: rings of lights
            for (k, y) in [g / 10, g / 6, g / 4].enumerated() {
                let half = c.w / 8 + k * c.w / 9
                for x in stride(from: c.w / 2 - half, to: c.w / 2 + half, by: 6 * s) { c.rect(x, y, s, s, C(0x6AE8A0, 0.6)) }
            }
        }
        // Glyph panels and the pods along the wall.
        let wallY = g - 30 * s
        for i in 0..<6 {
            let x = c.w * (5 + i * 16) / 100
            if i % 2 == 0 {
                c.rect(x, wallY, 16 * s, 18 * s, C(0x101814)); c.rect(x, wallY, 16 * s, s, C(0x3E5046))
                for r in 0..<4 {
                    for k in 0..<5 where noise(i * 40 + r * 7 + k) > 0.35 {
                        c.rect(x + 2 * s + k * 3 * s, wallY + 3 * s + r * 4 * s, 2 * s, s, C(0x4AD87A))
                    }
                }
            } else {
                // A pod: a tall glass capsule, a pale shape asleep inside.
                c.rect(x, wallY - 6 * s, 12 * s, 26 * s, C(0x1E2E26)); c.rect(x + s, wallY - 5 * s, 10 * s, 24 * s, C(0x5AB88A, 0.25))
                c.ellipse(x + 6 * s, wallY + s, 3 * s, 3 * s, C(0xC8D8CC, 0.55)); c.rect(x + 4 * s, wallY + 4 * s, 4 * s, 10 * s, C(0xC8D8CC, 0.45))
                c.rect(x, wallY - 6 * s, 12 * s, s, C(0x6A8A7A)); c.rect(x, wallY + 19 * s, 12 * s, s, C(0x6A8A7A))
            }
        }
        // The floor: plates round the ring in the middle.
        c.ground(g, C(0x1A221E), edge: C(0x4A6A5A), speck: C(0x121814), seed: 77)
        for x in stride(from: 0, to: c.w, by: 12 * s) { c.rect(x, g + 1, s, c.h - g - 1, C(0x121814)) }
        c.ellipse(c.w / 2, g + 2 * s, 34 * s, 3 * s, C(0x2E4A3A)); c.ellipse(c.w / 2, g + 2 * s, 30 * s, 2 * s, C(0x0A100C))
    }

    /// What moves in the mothership: the beam coming up through the floor ring and breathing, the glyph panels and the
    /// rings flickering, and motes rising in the light.
    static func mothershipLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g)
        let pulse = 0.5 + 0.5 * sin(t * 2 * .pi / 3.2)
        let half = 26 * s
        for y in 0..<(g + 2 * s) {
            let k = Double(y) / Double(g)
            let w = Int(Double(half) * (0.55 + 0.45 * k))
            c.rect(c.w / 2 - w, y, w * 2, 1, C(0xC8FFE0, (0.05 + 0.08 * pulse) * k))
        }
        c.ellipse(c.w / 2, g + 2 * s, 30 * s, 2 * s, C(0xC8FFE0, 0.35 + 0.35 * pulse))
        for i in 0..<14 {   // motes, rising in the beam
            let y = g - Int((noise(i * 5) * Double(g) + t * (10 + noise(i * 5 + 1) * 14) * Double(s))) % g
            let x = c.w / 2 + Int((noise(i * 5 + 2) - 0.5) * Double(half))
            c.rect(x, y, s, s, C(0xE8FFF0, 0.6))
        }
        // A glyph panel's row lighting up and going out.
        let wallY = g - 30 * s
        for i in stride(from: 0, to: 6, by: 2) {
            let x = c.w * (5 + i * 16) / 100, row = Int(t * 1.5 + Double(i)) % 4
            c.rect(x + 2 * s, wallY + 3 * s + row * 4 * s, 14 * s, s, C(0xA8FFC8, 0.5))
        }
    }
}

// MARK: - Ruskin Dam

extension Scenes {
    /// Ruskin Dam at night: the road along the top of the dam, its concrete parapet behind the crew and lamp posts
    /// along it; beyond, the valley in darkness, a ridge of pines and the reservoir catching the light. Something
    /// burns further along the dam, and a white light hangs in the sky. On the screen saver the dam's face drops away
    /// below the parapet's line, sky above.
    static func ruskinDam(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x05060C), C(0x1C1E2C), bands: 8)
        c.stars(0, g / 2, density: tall ? 240 : 130, seed: 81)
        // The far ridge and its pines, and the reservoir below them.
        let ridge = g - (tall ? g / 3 : 26 * s)
        for x in stride(from: 0, to: c.w, by: s) {
            let h = Int((sin(Double(x) / Double(70 * s)) * 0.5 + 0.5) * Double(10 * s))
            c.rect(x, ridge - h, s, h + 6 * s, C(0x0C1014))
        }
        for i in 0..<(c.w / (9 * s)) {
            let x = i * 9 * s + Int(noise(i + 500) * Double(6 * s))
            filesPine(c, cx: x, base: ridge + 4 * s, h: (8 + Int(noise(i + 510) * 8)) * s, s: s, C(0x080A0E))
        }
        // The reservoir below the ridge, down to the dam's top: dark water and streaks of light on it.
        let parTop = g - 9 * s
        c.gradient(ridge + 6 * s, parTop, C(0x161E2C), C(0x0C1018), bands: 4)
        let streaks = max(20, (parTop - ridge) * c.w / (90 * s * s))
        for i in 0..<streaks {
            let y = ridge + 7 * s + Int(noise(i + 530) * Double(max(1, parTop - ridge - 8 * s)))
            c.rect(Int(noise(i + 520) * Double(c.w)), y, (4 + i % 5) * s, max(1, s / 2), C(0x6A7890, 0.45))
        }
        // The parapet along the dam's top, its posts, and the lamp posts.
        let parY = g - 9 * s
        c.rect(0, parY, c.w, 9 * s, C(0x5A5C62)); c.rect(0, parY, c.w, s, C(0x8A8C92)); c.rect(0, g - s, c.w, s, C(0x3A3C42))
        for x in stride(from: 0, to: c.w, by: 22 * s) { c.rect(x, parY + s, s, 8 * s, C(0x46484E)) }
        for x in stride(from: c.w / 7, to: c.w, by: c.w * 2 / 7) {
            c.rect(x, parY - 30 * s, 2 * s, 30 * s, C(0x2E3036)); c.rect(x - 4 * s, parY - 31 * s, 8 * s, 2 * s, C(0x2E3036))
            c.rect(x - 3 * s, parY - 29 * s, 6 * s, s, C(0xFFE8A0, 0.8))
        }
        // The road.
        c.ground(g, C(0x2C2E34), edge: C(0x5A5C62), speck: C(0x22242A), seed: 83)
        for x in stride(from: 0, to: c.w, by: 16 * s) { c.rect(x, g + 3 * s, 8 * s, s, C(0xC8B060, 0.6)) }
    }

    /// What moves on the dam: the fire further along, flickering and throwing its light on the parapet, sparks going
    /// up, and the white light in the sky swelling and fading.
    static func ruskinDamLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), fx = c.w * 80 / 100, parY = g - 9 * s
        // The light in the sky.
        let lx = c.w * 30 / 100, ly = isTall(c) ? g / 5 : 10 * s
        let swell = 0.5 + 0.5 * sin(t * 2 * .pi / 6)
        for r in stride(from: 12 * s, to: 0, by: -2 * s) { c.circle(lx, ly, r, C(0xF4FAFF, 0.05 + 0.05 * swell)) }
        c.circle(lx, ly, 2 * s, C(0xFFFFFF, 0.8 + 0.2 * swell))
        // The fire: tongues licking up from a heap on the dam's top, behind the parapet line.
        c.ellipse(fx, parY, 28 * s, 10 * s, C(0xFF7A2A, 0.08 + 0.04 * sin(t * 9)))
        for i in 0..<7 {
            let x = fx - 9 * s + i * 3 * s
            let h = (8 + Int(noise(i + Int(t * 10) * 13) * 10)) * s
            for y in 0..<h {   // a tongue: wide at the base, narrowing to a point, yellow at its heart
                let w = max(s, (h - y) * 4 * s / max(1, h))
                let lean = Int(sin(t * 7 + Double(i)) * Double(y) / Double(max(1, h)) * Double(2 * s))
                c.rect(x - w / 2 + lean, parY - y, w, 1, y < h / 2 ? C(0xFFD24A, 0.9) : C(0xFF7A2A, 0.85))
            }
        }
        for i in 0..<6 {   // sparks
            let k = (t * 0.8 + noise(i + 600)).truncatingRemainder(dividingBy: 1)
            c.rect(fx - 8 * s + Int(noise(i + 610) * Double(16 * s)) + Int(sin(t * 3 + Double(i)) * Double(2 * s)),
                   parY - 18 * s - Int(k * Double(20 * s)), s, s, C(0xFFC85A, 1 - k))
        }
    }
}

// MARK: - The bee domes

extension Scenes {
    /// Where the domes stand: their middles and radii, on the field's line.
    static func s4Domes(_ c: PixelCanvas, _ g: Int) -> [(x: Int, r: Int)] {
        let s = unit(g), tall = isTall(c)
        let r = tall ? min(g / 6, c.w / 8) : min(34 * s, g * 2 / 5)
        return [(c.w * 30 / 100, r), (c.w * 66 / 100, r * 4 / 5)]
    }

    /// The cornfield at night: rows of tall corn under a starry sky, and in the middle of it two great white domes,
    /// glowing from inside, where the bees are kept. On the screen saver the field runs back to a line of trees and a
    /// farm silo under the stars.
    static func beeDomes(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x05080A), C(0x1A2420), bands: 8)
        c.stars(0, g * 2 / 3, density: tall ? 220 : 120, seed: 91)
        let field = g - (tall ? g / 4 : 22 * s)
        if tall {
            for i in 0..<(c.w / (10 * s)) {
                filesPine(c, cx: i * 10 * s + Int(noise(i + 700) * Double(5 * s)), base: field, h: (14 + Int(noise(i + 710) * 10)) * s, s: s, C(0x0A0E0C))
            }
            let sx = c.w * 86 / 100   // the silo
            c.rect(sx, field - 40 * s, 12 * s, 40 * s, C(0x2A2E30)); c.ellipse(sx + 6 * s, field - 40 * s, 6 * s, 3 * s, C(0x3A4044))
        }
        c.rect(0, field, c.w, g - field, C(0x16200E))
        // The domes, behind the front rows: a white shell, a brighter rim, the seams of their panels.
        for d in s4Domes(c, g) {
            for dy in 0...d.r {
                let half = Int(Double(d.r) * (1 - Double(dy * dy) / Double(d.r * d.r)).squareRoot())
                c.rect(d.x - half, field + 4 * s - dy, half * 2 + 1, 1, dy > d.r - 2 * s ? C(0xF4F8F0) : C(0xD8E4D4))
            }
            for k in 1..<4 { c.rect(d.x - d.r + k * d.r / 2, field + 4 * s - d.r * 3 / 4, s, d.r * 3 / 4, C(0xB8C8B4)) }
            c.rect(d.x - 3 * s, field - 4 * s, 6 * s, 8 * s, C(0x4A5A44))   // the hatch
        }
        // The corn: stalks with leaves, darker and denser at the front.
        for row in 0..<3 {
            let y = field + row * (g - field) / 3, h = (tall ? 14 + row * 6 : 6 + row * 3) * s
            for i in 0..<(c.w / ((5 - row) * s)) {
                let x = i * (5 - row) * s + Int(noise(i * 3 + row * 100) * Double(2 * s))
                let col = [C(0x2E4220), C(0x24341A), C(0x1A2612)][row]
                c.rect(x, y + (g - field) / 3 - h, s, h, col)
                c.rect(x - 2 * s, y + (g - field) / 3 - h * 2 / 3, 2 * s, s, col); c.rect(x + s, y + (g - field) / 3 - h / 3, 2 * s, s, col)
                c.rect(x, y + (g - field) / 3 - h - s, s, s, C(0x8A7A3A))   // the tassel
            }
        }
        c.ground(g, C(0x2A2216), edge: C(0x4A3E2A), speck: C(0x1E1810), seed: 93)
    }

    /// What moves in the cornfield: the domes' glow breathing, bees swarming round them, and the corn tops nodding.
    static func beeDomesLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c)
        let field = g - (tall ? g / 4 : 22 * s)
        let glow = 0.5 + 0.5 * sin(t * 2 * .pi / 4)
        for (i, d) in s4Domes(c, g).enumerated() {
            c.ellipse(d.x, field + 4 * s - d.r / 2, d.r + 6 * s, d.r * 3 / 4, C(0xE8FFE0, 0.05 + 0.06 * glow))
            // The swarm: each bee on its own loop round the dome.
            for b in 0..<18 {
                let a = t * (1.2 + noise(b + i * 50) * 1.5) + Double(b)
                let rx = Double(d.r) * (0.7 + noise(b + i * 50 + 1) * 0.6), ry = Double(d.r) * (0.3 + noise(b + i * 50 + 2) * 0.4)
                let x = d.x + Int(cos(a) * rx), y = field - d.r / 2 + Int(sin(a * 1.3) * ry)
                c.rect(x, y, s, s, Int(t * 8 + Double(b)) % 2 == 0 ? C(0xF2C83A) : C(0x2A2216))
            }
        }
        // The front row's tops nodding in the wind.
        for i in stride(from: 0, to: c.w / (3 * s), by: 4) {
            let x = i * 3 * s, h = (tall ? 26 : 12) * s, sway = Int((sin(t * 1.4 + Double(i) * 0.3) * 1.5).rounded()) * s
            c.rect(x + sway, g - h - s, s, 2 * s, C(0x8A7A3A, 0.9))
        }
    }
}
