import Foundation

// E.T.: Elliott's street and the moonlit hill. The street is a California cul-de-sac at night, the house sealed in
// plastic for the quarantine; the hill is the one under the big moon, where the bike flies across it.

let clawdbergScenes5: [Location: Place] = [
    .elliottStreet: Place(name: "Elliott’s Street", panel: 0x0E1226, still: Scenes.elliottStreet,
                          moving: Scenes.elliottStreetLife),
    .moonHill: Place(name: "The Moonlit Hill", panel: 0x0A1024, still: Scenes.moonHill, moving: Scenes.moonHillLife),
]

// MARK: - Elliott's street

extension Scenes {
    /// Where things stand on the street: Elliott's house (middle, half width, wall top, roof peak), the quarantine
    /// tunnel's far end and height, the two fans, and the porch lights.
    private static func etStreetFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, hw: Int, wallTop: Int, roofTop: Int,
                                                                       tunnelEnd: Int, tunnelH: Int,
                                                                       fans: [(x: Int, y: Int)], porches: [(x: Int, y: Int)]) {
        let s = unit(g)
        let cx = c.w * 54 / 100, hw = 36 * s
        let wallTop = g - 24 * s, roofTop = g - 37 * s
        let tunnelEnd = cx - hw - 46 * s
        let fans = [(x: tunnelEnd - 6 * s, y: g - 8 * s), (x: cx + hw + 9 * s, y: g - 9 * s)]
        let porches = [(x: c.w * 13 / 100, y: g - 15 * s), (x: c.w * 84 / 100, y: g - 15 * s), (x: cx + 10 * s, y: g - 17 * s)]
        return (cx, hw, wallTop, roofTop, tunnelEnd, 11 * s, fans, porches)
    }

    /// A low-pitched roof as a stepped triangle from `top` down to `base`, `halfW` wide at the eaves.
    private static func etRoof(_ c: PixelCanvas, cx: Int, top: Int, base: Int, halfW: Int, _ col: Px, _ edge: Px) {
        let rows = max(1, base - top)
        for i in 0..<rows {
            let hw = halfW * (i + 1) / rows
            c.rect(cx - hw, top + i, hw * 2, 1, col)
        }
        c.rect(cx - halfW - 1, base - 1, halfW * 2 + 2, 1, edge)
    }

    /// A ranch house on the cul-de-sac: stucco walls, a shingled roof, a garage door, warm windows and a porch light.
    private static func etHouse(_ c: PixelCanvas, x: Int, w: Int, g: Int, s: Int, k: Int) {
        let wallTop = g - 18 * s, roofTop = wallTop - 9 * s
        let walls = [C(0x3A3A52), C(0x40384A), C(0x343C4E)][k % 3]
        c.rect(x, wallTop, w, g - wallTop, walls)
        c.rect(x, wallTop, s, g - wallTop, C(0x4A4A62))
        etRoof(c, cx: x + w / 2, top: roofTop, base: wallTop + s, halfW: w / 2 + 3 * s, C(0x1E2030), C(0x2A2C40))
        // The garage door, panelled.
        let gw = w * 2 / 5, gx = k % 2 == 0 ? x + w - gw - 3 * s : x + 3 * s
        c.rect(gx, g - 11 * s, gw, 11 * s, C(0x2C2C3C))
        for gy in stride(from: g - 9 * s, to: g, by: 3 * s) { c.rect(gx, gy, gw, s, C(0x24242F)) }
        // Windows lit amber behind the curtains.
        let wx = k % 2 == 0 ? x + 5 * s : x + w - 17 * s
        c.rect(wx, g - 13 * s, 12 * s, 6 * s, C(0x1A1A22))
        c.rect(wx + s, g - 12 * s, 10 * s, 4 * s, C(0xF2C26A, 0.85))
        c.rect(wx + 5 * s, g - 12 * s, s, 4 * s, C(0x8A6A3A))
    }

    /// A pine for the hills behind: a stack of widening tiers on a short trunk, `h` rows tall, standing on `base`.
    private static func etPine(_ c: PixelCanvas, x: Int, base: Int, h: Int, _ col: Px) {
        let tiers = max(1, h)
        for i in 0..<tiers {
            let hw = (i % 4 + 1) * max(1, h / 7) / 2 + i / 3
            c.rect(x - hw, base - h + i, hw * 2 + 1, 1, col)
        }
    }

    /// Elliott's street, the night the government comes: a navy sky over a ridge of pines, the ranch houses round the
    /// cul-de-sac with their garage doors and amber windows, and Elliott's house in the middle sealed in plastic
    /// sheeting, lit cold white from inside, with the ribbed quarantine tunnel running out from the front door to a
    /// big extractor fan, and another fan humming at the side. Street lamps throw cones of light on the road. On the
    /// screen saver the forest rises behind, ridge after ridge, with the government van parked on the fire road, its
    /// headlights on.
    static func elliottStreet(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = etStreetFrame(c, g)
        c.gradient(0, g, C(0x070B22), C(0x22305A), bands: 8)
        // Stars.
        for i in 0..<(c.w * g / 900) {
            let x = Int(noise(i * 3 + 501) * Double(c.w)), y = Int(noise(i * 3 + 502) * Double(g * 2 / 3))
            c.rect(x, y, 1, 1, C(0xDDE4FF, 0.35 + noise(i * 3 + 503) * 0.5))
        }
        if tall { etForest(c, g, s) }
        // The ridge of pines behind the houses.
        let ridge = g - 30 * s
        for x in stride(from: 0, to: c.w, by: s) {
            let bump = Int((sin(Double(x) / Double(40 * s)) + 1) * Double(3 * s))
            c.rect(x, ridge - bump, s, g - ridge + bump, C(0x0E1630))
        }
        var px = 0, pk = 0
        while px < c.w {
            let h = (10 + Int(noise(pk + 530) * 9)) * s
            let base = ridge - Int((sin(Double(px) / Double(40 * s)) + 1) * Double(3 * s)) + 2 * s
            etPine(c, x: px, base: base, h: h, C(0x0B1228))
            px += (5 + Int(noise(pk + 540) * 6)) * s; pk += 1
        }
        // The neighbours' houses either side.
        let houses = [(x: c.w * 2 / 100, w: 54 * s), (x: c.w * 2 / 100 + 60 * s, w: 46 * s),
                      (x: f.cx + f.hw + 22 * s, w: 50 * s), (x: f.cx + f.hw + 78 * s, w: 56 * s),
                      (x: f.cx + f.hw + 140 * s, w: 50 * s)]
        for (k, h) in houses.enumerated() {
            if h.x > c.w { continue }
            etHouse(c, x: h.x, w: h.w, g: g, s: s, k: k)
        }
        // Elliott's house: split-level, wrapped in plastic, lit from inside by the scientists' lamps.
        let left = f.cx - f.hw, w = f.hw * 2
        c.rect(left, f.wallTop, w, g - f.wallTop, C(0x46465E))
        etRoof(c, cx: f.cx - 6 * s, top: f.roofTop, base: f.wallTop + s, halfW: f.hw - 2 * s, C(0x22243A), C(0x30324A))
        for (wx, wy) in [(left + 5 * s, f.wallTop + 4 * s), (left + w - 19 * s, f.wallTop + 4 * s),
                         (f.cx - 12 * s, f.wallTop - 7 * s)] {
            c.rect(wx, wy, 14 * s, 7 * s, C(0x1A1C26))
            c.rect(wx + s, wy + s, 12 * s, 5 * s, C(0xD8ECFF, 0.9))
            c.rect(wx + 7 * s, wy + s, s, 5 * s, C(0x8AA0C0))
        }
        c.rect(f.cx + 4 * s, g - 12 * s, 9 * s, 12 * s, C(0x2A2A36))   // the front door, open to the light
        c.rect(f.cx + 5 * s, g - 11 * s, 7 * s, 11 * s, C(0xE8F4FF, 0.75))
        // The plastic over it all: a pale sheen, slack seams, and a hem flapping at the ground.
        let sheetTop = f.roofTop - 2 * s
        c.rect(left - 3 * s, sheetTop + 6 * s, w + 6 * s, g - sheetTop - 6 * s, C(0xC8DCF0, 0.16))
        etRoof(c, cx: f.cx - 6 * s, top: sheetTop, base: f.wallTop + 2 * s, halfW: f.hw + 2 * s, C(0xC8DCF0, 0.14), C(0xE0EEFF, 0.35))
        for sx in stride(from: left, to: left + w, by: 9 * s) {
            c.rect(sx, f.wallTop + s, s, g - f.wallTop - s, C(0xE0EEFF, 0.3))
        }
        // The quarantine tunnel: a ribbed, see-through tube from the front door down the drive to the extractor.
        let ty = g - f.tunnelH
        c.rect(f.tunnelEnd, ty, f.cx + 4 * s - f.tunnelEnd, f.tunnelH, C(0xD0E2F4, 0.32))
        c.rect(f.tunnelEnd, ty, f.cx + 4 * s - f.tunnelEnd, s, C(0xF0F8FF, 0.7))
        c.rect(f.tunnelEnd, ty + 3 * s, f.cx + 4 * s - f.tunnelEnd, 3 * s, C(0xF4FAFF, 0.2))
        for rx in stride(from: f.tunnelEnd, to: f.cx + 4 * s, by: 5 * s) {
            c.rect(rx, ty, s, f.tunnelH, C(0xE8F2FF, 0.55))
        }
        // The fans: square housings with a round grille (the blades turn in the moving layer).
        for fan in f.fans {
            let r = 7 * s
            c.rect(fan.x - r - s, fan.y - r - s, 2 * r + 2 * s, 2 * r + 2 * s, C(0x3A4048))
            c.rect(fan.x - r - s, fan.y - r - s, 2 * r + 2 * s, s, C(0x5A6270))
            c.circle(fan.x, fan.y, r, C(0x161A20))
            c.rect(fan.x - r - s, g - 2 * s, 2 * r + 2 * s, 2 * s, C(0x2A2E36))
        }
        // Street lamps, each with its cone of light on the road.
        for lx in [c.w * 30 / 100, c.w * 95 / 100] {
            let top = g - 34 * s
            c.rect(lx, top, s, g - top, C(0x2A2E3A))
            c.rect(lx, top, 5 * s, s, C(0x2A2E3A)); c.rect(lx + 3 * s, top + s, 3 * s, s, C(0xF8E8B0))
            for i in 0..<(g - top - 2 * s) {
                let hw = i / 4
                c.rect(lx + 4 * s - hw, top + 2 * s + i, hw * 2 + 1, 1, C(0xF8E8B0, 0.05))
            }
        }
        // The porch lights.
        for p in f.porches {
            c.circle(p.x, p.y, 3 * s, C(0xF6D88A, 0.2)); c.rect(p.x, p.y, s, s, C(0xFFF0C0))
        }
        // The road: asphalt, the kerb, a drain, the dashes down the middle.
        c.ground(g, C(0x1A1C2A), edge: C(0x4A4E62), speck: C(0x242838), seed: 81)
        for x in stride(from: 4 * s, to: c.w, by: 22 * s) where g + 5 * s < c.h {
            c.rect(x, g + 5 * s, 9 * s, s, C(0xB8AA70, 0.45))
        }
    }

    /// The forest above the town on the screen saver: three ridges of pines, nearer ones darker, a crescent of moon,
    /// mist lying in the valleys, and the fire road cut across the slope with the government van on it, headlights on.
    private static func etForest(_ c: PixelCanvas, _ g: Int, _ s: Int) {
        let moonX = c.w * 82 / 100, moonY = g / 8
        c.circle(moonX, moonY, 9 * s, C(0xE8E6D0, 0.15)); c.circle(moonX, moonY, 6 * s, C(0xF2EEDA))
        c.circle(moonX - 2 * s, moonY - s, 5 * s, C(0x0C1230))
        let ridges = [(base: g * 36 / 100, col: C(0x26345E), seed: 600), (base: g * 50 / 100, col: C(0x1C2850), seed: 620),
                      (base: g * 63 / 100, col: C(0x141E40), seed: 640), (base: g * 76 / 100, col: C(0x0F1834), seed: 680)]
        for (i, r) in ridges.enumerated() {
            for x in stride(from: 0, to: c.w, by: s) {
                let wave = sin(Double(x) / Double((70 + i * 25) * s) + Double(i))
                let top = r.base - Int((wave + 1) * Double(9 * s))
                c.rect(x, top, s, g - top, r.col)
            }
            var x = 0, k = 0
            while x < c.w {
                let wave = sin(Double(x) / Double((70 + i * 25) * s) + Double(i))
                let base = r.base - Int((wave + 1) * Double(9 * s)) + 2 * s
                etPine(c, x: x, base: base, h: (12 + Int(noise(k + r.seed) * 12) + i * 4) * s, r.col)
                x += (4 + Int(noise(k + r.seed + 20) * 6)) * s; k += 1
            }
            // Mist lying in front of each ridge.
            c.rect(0, r.base + 4 * s, c.w, 3 * s, C(0x8A9AC8, 0.1)); c.rect(0, r.base + 7 * s, c.w, 3 * s, C(0x8A9AC8, 0.06))
        }
        // The fire road across the nearest slope, and the van on it with its headlights cutting the mist.
        let roadY = g * 76 / 100 + 10 * s
        c.rect(0, roadY, c.w, 3 * s, C(0x2A3048))
        let vx = c.w * 20 / 100, vy = roadY + s, v = 2 * s
        c.rect(vx, vy - 9 * v, 24 * v, 8 * v, C(0xC8CCD4)); c.rect(vx, vy - 9 * v, 24 * v, s, C(0xE8ECF0))
        c.rect(vx + 17 * v, vy - 8 * v, 6 * v, 3 * v, C(0x2A3448))
        c.rect(vx + 2 * v, vy - 7 * v, 12 * v, 3 * v, C(0x9AA0AC))
        c.circle(vx + 5 * v, vy - s, 2 * v, C(0x101218)); c.circle(vx + 19 * v, vy - s, 2 * v, C(0x101218))
        c.rect(vx + 23 * v, vy - 4 * v, v, v, C(0xFFF6D0))
        for i in 0..<(40 * v) {
            let hw = i / 5
            c.rect(vx + 24 * v + i, vy - 4 * v - hw / 2, 1, hw + 1, C(0xF8F0C8, 0.07))
        }
    }

    /// What moves on Elliott's street: the fans' blades turning, the porch lights flickering with a moth at each,
    /// fog drifting low along the road, and a flashlight beam (an agent with keys on his belt) sweeping the houses.
    static func elliottStreetLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = etStreetFrame(c, g)
        // The fan blades: four, turning fast.
        for (i, fan) in f.fans.enumerated() {
            let r = Double(6 * s)
            for b in 0..<4 {
                let a = t * (9 + Double(i) * 2) + Double(b) * .pi / 2
                let ex = Double(fan.x) + cos(a) * r, ey = Double(fan.y) + sin(a) * r
                c.glowLine(Double(fan.x), Double(fan.y), ex, ey, core: C(0x8A94A4), glow: C(0, 0), coreR: Double(s) * 0.9)
            }
            c.rect(fan.x - s / 2, fan.y - s / 2, s, s, C(0xC8D0DC))
        }
        // Porch lights flickering, a moth circling each.
        for (i, p) in f.porches.enumerated() {
            let fl = 0.12 + 0.08 * sin(t * 13 + Double(i) * 2)
            c.circle(p.x, p.y, 5 * s, C(0xF6D88A, fl))
            let a = t * 5 + Double(i)
            let mx = p.x + Int(cos(a) * Double(3 * s)), my = p.y + Int(sin(a * 1.3) * Double(2 * s))
            c.rect(mx, my, s, s, C(0xE8E0C8, 0.8))
        }
        // Fog rolling along the road.
        for i in 0..<9 {
            let speed = 4 + noise(i + 700) * 5
            let span = Double(c.w + 120 * s)
            let x = (noise(i + 710) * span + t * speed).truncatingRemainder(dividingBy: span) - Double(60 * s)
            let y = g - (2 + Int(noise(i + 720) * 8)) * s
            c.ellipse(Int(x), y, (30 + Int(noise(i + 730) * 25)) * s, (3 + Int(noise(i + 740) * 2)) * s, C(0xA8B8D8, 0.1))
        }
        // An agent's flashlight sweeping across the houses.
        let sweep = sin(t * 0.6)
        let fx = Double(c.w) * 0.72, fy = Double(g - 14 * s)
        let tx = fx + sweep * Double(90 * s), ty = Double(g - 24 * s)
        c.glowLine(fx, fy, tx, ty, core: C(0xFFF8E0, 0.06), glow: C(0xFFF8E0, 0.05), coreR: Double(2 * s), glowR: Double(5 * s))
        c.circle(Int(tx), Int(ty), 5 * s, C(0xFFF8E0, 0.12))
    }
}

// MARK: - The moonlit hill

extension Scenes {
    /// Where things stand on the hill: the moon (centre and radius), the ridge line's height, and the communicator
    /// (its foot and the umbrella's centre).
    private static func etHillFrame(_ c: PixelCanvas, _ g: Int) -> (moon: (x: Int, y: Int, r: Int), ridge: Int,
                                                                     comm: (x: Int, base: Int, top: Int)) {
        let s = unit(g), tall = isTall(c)
        let r = tall ? g * 30 / 100 : 30 * s
        let my = tall ? g * 40 / 100 : g * 47 / 100
        let ridge = g - (tall ? 22 : 9) * s
        let cx = c.w * 17 / 100
        let base = g - (tall ? 32 : 17) * s
        return ((c.w * 60 / 100, my, r), ridge, (cx, base, base - 16 * etCommUnit(c, g)))
    }

    /// The communicator's own unit: twice the size on the screen saver, so it still reads under the big moon.
    private static func etCommUnit(_ c: PixelCanvas, _ g: Int) -> Int { isTall(c) ? 2 * unit(g) : unit(g) }

    /// The height of the hill's skyline at column `x`: a long rolling ridge with a knoll on the left for the
    /// communicator.
    private static func etHillTop(_ c: PixelCanvas, _ g: Int, _ x: Int) -> Int {
        let f = etHillFrame(c, g), s = unit(g)
        let roll = sin(Double(x) / Double(55 * s)) * Double(2 * s)
        let d = Double(x - f.comm.x) / Double(34 * s)
        let knoll = Double(f.ridge - f.comm.base) * exp(-d * d)
        return f.ridge - Int(roll + knoll)
    }

    /// The moon: a faint halo, a cream disc brightening to the middle, the grey seas and a few craters.
    private static func etMoon(_ c: PixelCanvas, _ m: (x: Int, y: Int, r: Int)) {
        let r = m.r
        c.circle(m.x, m.y, r + r / 4, C(0xC8D4F0, 0.05))
        c.circle(m.x, m.y, r + r / 8, C(0xD8E0F4, 0.08))
        c.circle(m.x, m.y, r + max(1, r / 20), C(0xE8ECF4, 0.25))
        c.circle(m.x, m.y, r, C(0xE6E2CE))
        c.circle(m.x + r / 14, m.y - r / 14, r * 92 / 100, C(0xEEEAD6))
        c.circle(m.x + r / 10, m.y - r / 10, r * 78 / 100, C(0xF6F2E2))
        // The seas, in fractions of the radius.
        let seas: [(dx: Int, dy: Int, rx: Int, ry: Int)] = [(-30, -28, 26, 18), (8, -38, 22, 14), (-42, 10, 18, 22),
                                                            (22, -6, 20, 16), (-8, 30, 16, 10), (36, 24, 12, 10)]
        for sea in seas {
            c.ellipse(m.x + r * sea.dx / 100, m.y + r * sea.dy / 100, max(1, r * sea.rx / 100), max(1, r * sea.ry / 100),
                      C(0xC8C6B8, 0.75))
        }
        let craters: [(dx: Int, dy: Int, rr: Int)] = [(10, 52, 7), (-56, -40, 5), (48, -44, 4), (60, 30, 5), (-20, 60, 4)]
        for k in craters {
            let x = m.x + r * k.dx / 100, y = m.y + r * k.dy / 100, cr = max(1, r * k.rr / 100)
            c.circle(x, y, cr, C(0xD6D2C2)); c.circle(x + max(1, cr / 3), y + max(1, cr / 3), max(1, cr * 2 / 3), C(0xF8F6EA))
        }
    }

    /// The moonlit hill above the town: a deep blue night going pale at the horizon, a huge full moon low over the
    /// forest with its seas and craters, the pines along the ridge black against it, and on the knoll to the left the
    /// home-made communicator (a foil-lined umbrella on a stand, a saw blade, the talking spelling toy wired to it).
    /// On the screen saver the moon is enormous and the sky full of stars.
    static func moonHill(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = etHillFrame(c, g)
        c.gradient(0, g, C(0x050A20), C(0x1E3266), bands: tall ? 12 : 8)
        // Stars, thinning near the moon.
        let count = tall ? c.w * g / 220 : c.w * g / 500
        for i in 0..<count {
            let x = Int(noise(i * 3 + 801) * Double(c.w)), y = Int(noise(i * 3 + 802) * Double(g * 3 / 4))
            let dx = Double(x - f.moon.x), dy = Double(y - f.moon.y)
            if (dx * dx + dy * dy).squareRoot() < Double(f.moon.r) * 1.5 { continue }
            let b = 0.3 + noise(i * 3 + 803) * 0.6
            c.rect(x, y, 1, 1, C(0xE8ECFF, b))
            if tall && b > 0.85 {
                c.rect(x - 1, y, 3, 1, C(0xE8ECFF, 0.3)); c.rect(x, y - 1, 1, 3, C(0xE8ECFF, 0.3))
            }
        }
        if tall {
            // A wash of the Milky Way across the top.
            for i in 0..<60 {
                let k = noise(i + 900)
                let x = Int(k * Double(c.w)), y = Int(Double(g) * (0.08 + k * 0.22) + (noise(i + 910) - 0.5) * Double(30 * s))
                c.ellipse(x, y, (8 + Int(noise(i + 920) * 14)) * s, (2 + Int(noise(i + 930) * 3)) * s, C(0x8CA0D8, 0.05))
            }
        }
        etMoon(c, f.moon)
        // Far hills, a little lighter, then the ridge of pines.
        for x in stride(from: 0, to: c.w, by: s) {
            let far = f.ridge - (tall ? 22 : 8) * s - Int((sin(Double(x) / Double(31 * s) + 2) + 1) * Double(3 * s))
            c.rect(x, far, s, g - far, C(0x142048))
        }
        var px = 0, k = 0
        while px < c.w {
            let base = etHillTop(c, g, px) + 2 * s
            let h = (tall ? 16 + Int(noise(k + 950) * 20) : 8 + Int(noise(k + 950) * 11)) * s
            if abs(px - f.comm.x) > 26 * s { etPine(c, x: px, base: base, h: h, C(0x060A18)) }
            px += (4 + Int(noise(k + 960) * 7)) * s; k += 1
        }
        for x in stride(from: 0, to: c.w, by: s) {
            let top = etHillTop(c, g, x)
            c.rect(x, top, s, g - top, C(0x080C1C))
            c.rect(x, top, s, s, C(0x2A3A6A, 0.6))   // moonlight on the crest
        }
        // The communicator on the knoll: a stand, the saw blade, the umbrella (its ribs turn in the moving layer),
        // the spelling toy on the ground with its wires.
        let cm = f.comm, cs = etCommUnit(c, g)
        c.rect(cm.x, cm.top, s, cm.base - cm.top, C(0x5A6070))
        c.glowLine(Double(cm.x), Double(cm.top + 8 * cs), Double(cm.x - 5 * cs), Double(cm.base), core: C(0x4A5060),
                   glow: C(0, 0), coreR: Double(cs) * 0.5)
        c.glowLine(Double(cm.x), Double(cm.top + 8 * cs), Double(cm.x + 5 * cs), Double(cm.base), core: C(0x4A5060),
                   glow: C(0, 0), coreR: Double(cs) * 0.5)
        c.circle(cm.x + 3 * cs, cm.top + 9 * cs, 3 * cs, C(0x9AA4B4)); c.circle(cm.x + 3 * cs, cm.top + 9 * cs, s, C(0x3A404C))
        c.ellipse(cm.x, cm.top, 9 * cs, 3 * cs, C(0x8A96AE))
        c.ellipse(cm.x, cm.top - s, 8 * cs, 2 * cs, C(0xC8D2E4))
        c.rect(cm.x - 9 * cs, cm.base - 3 * cs, 7 * cs, 3 * cs, C(0xC84A2A)); c.rect(cm.x - 8 * cs, cm.base - 3 * cs, 5 * cs, s, C(0x2A2A30))
        c.rect(cm.x - 2 * cs, cm.base - 2 * cs, 2 * cs, s, C(0x3A3A44))
        // The hillside in front: grass under moonlight, where the crew stands.
        c.ground(g, C(0x0C1428), edge: C(0x2C3C6A), speck: C(0x18244A), seed: 91)
    }

    /// The bike, in silhouette, `k` pixels to a unit, its middle at (`x`, `y`): a BMX with the pedals turning, the
    /// boy in his hood bent over the bars, and the basket on the front with the little alien wrapped in a blanket.
    private static func etBike(_ c: PixelCanvas, x: Double, y: Double, k: Double, t: Double, _ col: Px) {
        func P(_ u: Double, _ v: Double) -> (Double, Double) { (x + u * k, y + v * k) }
        func line(_ a: (Double, Double), _ b: (Double, Double), _ w: Double = 0.75) {
            c.glowLine(a.0, a.1, b.0, b.1, core: col, glow: C(0, 0), coreR: w * k)
        }
        // Wheels: rims and turning spokes.
        let spin = t * 6
        for hub in [P(-8, 3), P(8, 3)] {
            let r = 4.4 * k
            let n = 20
            for i in 0..<n {
                let a0 = Double(i) / Double(n) * 2 * .pi, a1 = Double(i + 1) / Double(n) * 2 * .pi
                c.glowLine(hub.0 + cos(a0) * r, hub.1 + sin(a0) * r, hub.0 + cos(a1) * r, hub.1 + sin(a1) * r,
                           core: col, glow: C(0, 0), coreR: 0.7 * k)
            }
            for i in 0..<3 {
                let a = spin + Double(i) * .pi / 3
                let dx = cos(a) * r, dy = sin(a) * r
                c.glowLine(hub.0 - dx, hub.1 - dy, hub.0 + dx, hub.1 + dy, core: col.alpha(0.8), glow: C(0, 0), coreR: 0.3 * k)
            }
        }
        // The frame.
        let rear = P(-8, 3), crank = P(-1, 3), seat = P(-3, -3), head = P(5.5, -4), front = P(8, 3)
        line(rear, crank); line(rear, seat); line(crank, seat); line(crank, head); line(seat, P(5, -3)); line(head, front)
        line(head, P(5, -7)); line(P(4, -7), P(7, -7))
        // The basket and its passenger: a blanket-wrapped hump and the round head peeping out over the rim.
        c.rect(Int(x + 6.5 * k), Int(y - 7.5 * k), Int(5 * k), Int(4 * k), col)
        c.ellipse(Int(x + 9 * k), Int(y - 9 * k), Int(2.6 * k), Int(2.4 * k), col)
        c.ellipse(Int(x + 10.2 * k), Int(y - 12 * k), Int(2.2 * k), Int(1.8 * k), col)
        c.ellipse(Int(x + 8.4 * k), Int(y - 11 * k), Int(1.4 * k), Int(2 * k), col)
        // The boy: hood up, leaning over the bars, legs on the turning pedals.
        let pa = t * 7
        let hip = P(-3, -4.5), shoulder = P(1.5, -10.5)
        line(hip, shoulder, 1.6)
        c.ellipse(Int(x + 0.2 * k), Int(y - 8 * k), Int(2.6 * k), Int(3 * k), col)
        c.circle(Int(x + 3 * k), Int(y - 13 * k), Int(2.2 * k), col)
        c.circle(Int(x + 1.6 * k), Int(y - 12.4 * k), Int(2 * k), col)   // the hood bunched behind
        line(shoulder, P(5, -7), 0.8)
        for side in [0.0, Double.pi] {
            let ped = (crank.0 + cos(pa + side) * 2.6 * k, crank.1 + sin(pa + side) * 2.6 * k)
            let knee = ((hip.0 + ped.0) / 2 + 2.2 * k, (hip.1 + ped.1) / 2 - 1.6 * k)
            line(hip, knee, 0.9); line(knee, ped, 0.8)
        }
    }

    /// What moves on the hill: stars twinkling, the communicator's umbrella turning with a red light blinking on
    /// it, and the bike flying across the face of the moon, a black silhouette, pedals going round. It drifts across
    /// slowly over half a minute, so most of the time it is somewhere on the moon.
    static func moonHillLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = etHillFrame(c, g)
        // Twinkling stars.
        for i in 0..<(tall ? 40 : 14) {
            let x = Int(noise(i * 5 + 1001) * Double(c.w)), y = Int(noise(i * 5 + 1002) * Double(g * 2 / 3))
            let b = max(0, sin(t * (1.5 + noise(i * 5 + 1003) * 2) + Double(i)))
            if b > 0.6 {
                c.rect(x, y, 1, 1, C(0xFFFFFF, b))
                c.rect(x - 1, y, 3, 1, C(0xE8ECFF, b * 0.35)); c.rect(x, y - 1, 1, 3, C(0xE8ECFF, b * 0.35))
            }
        }
        // The umbrella's ribs turning, and the blinking light.
        let cm = f.comm, cs = etCommUnit(c, g)
        for i in 0..<8 {
            let a = t * 0.9 + Double(i) * .pi / 4
            let ex = Double(cm.x) + cos(a) * Double(8 * cs), ey = Double(cm.top - s) + sin(a) * Double(2 * cs)
            c.glowLine(Double(cm.x), Double(cm.top - 2 * cs), ex, ey, core: C(0x5A6478, 0.8), glow: C(0, 0),
                       coreR: Double(cs) * 0.4)
        }
        if sin(t * 4) > 0.3 {
            c.rect(cm.x, cm.top - 3 * cs, s, s, C(0xFF5A3A))
            c.circle(cm.x, cm.top - 3 * cs, 2 * cs, C(0xFF5A3A, 0.25))
        }
        // The bike crossing the moon.
        let m = f.moon
        let k = tall ? Double(max(2, m.r / 26)) : Double(s) * 1.3
        let span = Double(2 * m.r) + 80 * k
        let phase = (t / 30 + 0.5).truncatingRemainder(dividingBy: 1) - 0.5
        let bx = Double(m.x) + phase * span
        let by = Double(m.y) + Double(m.r) * (tall ? 0.22 : 0.04) - phase * 14 * k + sin(t * 1.4) * 0.6 * k
        etBike(c, x: bx, y: by, k: k, t: t, C(0x05060E))
    }
}
