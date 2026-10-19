import Foundation

// Hill Valley, 1955: the courthouse square on the night of the storm.

let clawdbergScenes1: [Location: Place] = [
    .hillValley1955: Place(name: "Hill Valley, 1955", panel: 0x14121E, still: Scenes.hillValley1955,
                           moving: Scenes.hillValley1955Life),
]

// MARK: - Hill Valley, 1955

extension Scenes {
    /// Where things stand on the square: the courthouse's middle and width, its roof line, the clock's centre and
    /// radius, the tower's top, and the lamp post the cable runs down to.
    static func hv55Frame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, hw: Int, roof: Int, clock: (x: Int, y: Int, r: Int),
                                                           towerTop: Int, lamp: (x: Int, top: Int)) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w * 56 / 100, hw = 62 * s
        let roof = g - (tall ? 44 : 30) * s
        let r = (tall ? 12 : 7) * s
        let clockY = roof - (tall ? 22 : 13) * s
        let towerTop = clockY - r - (tall ? 22 : 6) * s
        return (cx, hw, roof, (cx, clockY, r), max(0, towerTop), (c.w * 18 / 100, g - (tall ? 54 : 40) * s))
    }

    /// The courthouse square in Hill Valley on the night of the storm: a purple-black sky, the brick courthouse with
    /// its white columns and steps, the clock tower on top stopped at 10:04, the shops round the square with their
    /// windows lit, and the lamp post with the cable strung from the tower. On the screen saver the tower climbs up
    /// into the storm clouds, the clock big.
    static func hillValley1955(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hv55Frame(c, g)
        c.gradient(0, g, C(0x120E22), C(0x34284A), bands: 7)
        if tall {
            // Heavy storm clouds rolling over the top.
            for i in 0..<14 {
                let x = Int(noise(i * 5 + 1) * Double(c.w)), y = Int(noise(i * 5 + 2) * Double(g / 3))
                c.ellipse(x, y, (30 + Int(noise(i * 5 + 3) * 40)) * s, (8 + Int(noise(i * 5 + 4) * 8)) * s,
                          C(0x221A34, 0.85))
            }
        }
        hv55Behind(c, g)
        // The shops round the square: flat fronts, awnings, lit windows, one with a sign.
        let shopTop = g - (tall ? 34 : 24) * s
        var x = 0
        var k = 0
        while x < c.w {
            let w = (34 + Int(noise(k * 3 + 7) * 20)) * s, h = (g - shopTop) - Int(noise(k * 3 + 8) * 6) * s
            if abs(x + w / 2 - f.cx) > f.hw + w / 2 {
                let col = [C(0x3A2C30), C(0x2E2A38), C(0x40302A)][k % 3]
                c.rect(x, g - h, w, h, col); c.rect(x, g - h, w, s, C(0x4E3E44))
                for wx in stride(from: x + 4 * s, to: x + w - 8 * s, by: 10 * s) {
                    c.rect(wx, g - h + 4 * s, 6 * s, 5 * s, C(0xF2C86A, 0.85))
                    c.rect(wx, g - h + 4 * s, 6 * s, s, C(0xC8984A))
                }
                let awning = [C(0x8A2A2A), C(0x2A5A3A), C(0x2A3A6A)][k % 3]
                for ax in stride(from: x + 2 * s, to: x + w - 2 * s, by: 2 * s) {
                    c.rect(ax, g - 11 * s, s, 3 * s, (ax / s) % 4 < 2 ? awning : C(0xE8E0D0))
                }
                c.rect(x + 3 * s, g - 8 * s, w - 6 * s, 8 * s, C(0x2A2018))
                c.rect(x + 5 * s, g - 7 * s, w - 10 * s, 5 * s, C(0xF2D898, 0.6))
            }
            x += w + 2 * s; k += 1
        }
        // The clock tower, behind the courthouse: brick, white trim, the dome and its spike.
        let tw = (tall ? 34 : 22) * s
        let towerX = f.cx - tw / 2
        c.rect(towerX, f.towerTop + 4 * s, tw, f.roof - f.towerTop - 4 * s, C(0x7A3A2A))
        c.rect(towerX, f.towerTop + 4 * s, s, f.roof - f.towerTop - 4 * s, C(0x9A4E3A))
        c.rect(towerX + tw - s, f.towerTop + 4 * s, s, f.roof - f.towerTop - 4 * s, C(0x5A2A1E))
        c.rect(towerX - s, f.towerTop + 4 * s, tw + 2 * s, 2 * s, C(0xE8E2D4))
        c.ellipse(f.cx, f.towerTop + 4 * s, tw / 2 - s, 4 * s, C(0x5A6A6A))
        c.rect(f.cx, max(0, f.towerTop - 4 * s), s, 5 * s, C(0x3A3A3E))
        // The clock: a white face, Roman ticks, the hands stopped at 10:04.
        let ck = f.clock
        c.circle(ck.x, ck.y, ck.r + s, C(0xE8E2D4)); c.circle(ck.x, ck.y, ck.r, C(0xF4EEDA))
        for h in 0..<12 {
            let a = Double(h) / 12 * 2 * .pi
            c.rect(ck.x + Int(sin(a) * Double(ck.r - s)), ck.y - Int(cos(a) * Double(ck.r - s)), s, s, C(0x2A2420))
        }
        let hour = (10 + 4.0 / 60) / 12 * 2 * .pi, minute = 4.0 / 60 * 2 * .pi
        c.glowLine(Double(ck.x), Double(ck.y), Double(ck.x) + sin(hour) * Double(ck.r) * 0.55,
                   Double(ck.y) - cos(hour) * Double(ck.r) * 0.55, core: C(0x1A1614), glow: C(0, 0), coreR: Double(s) * 0.6)
        c.glowLine(Double(ck.x), Double(ck.y), Double(ck.x) + sin(minute) * Double(ck.r) * 0.85,
                   Double(ck.y) - cos(minute) * Double(ck.r) * 0.85, core: C(0x1A1614), glow: C(0, 0), coreR: Double(s) * 0.5)
        // The courthouse: red brick, a pediment, white columns and the steps up to the doors.
        let left = f.cx - f.hw, w = f.hw * 2
        c.rect(left, f.roof, w, g - f.roof, C(0x8A4030)); c.rect(left, f.roof, w, s, C(0xA4523E))
        for by in stride(from: f.roof + 3 * s, to: g, by: 3 * s) {
            for bx in stride(from: left + ((by / s) % 2) * 2 * s, to: left + w, by: 4 * s) { c.rect(bx, by, s, s, C(0x7A3628)) }
        }
        for i in 0..<(tall ? 8 : 6) {   // the pediment, a stepped triangle
            c.rect(f.cx - f.hw / 2 + i * 3 * s, f.roof - (i + 1) * s, f.hw - i * 6 * s, s, C(0xE8E2D4))
        }
        c.rect(left - 2 * s, f.roof, w + 4 * s, 2 * s, C(0xE8E2D4))
        let colTop = f.roof + 2 * s
        for i in 0..<6 {
            let colX = f.cx - f.hw / 2 + i * (f.hw / 5)
            c.rect(colX, colTop, 2 * s, g - colTop - 4 * s, C(0xEDE8DC)); c.rect(colX + s, colTop, s, g - colTop - 4 * s, C(0xC8C2B4))
        }
        c.rect(f.cx - 6 * s, g - 12 * s, 12 * s, 8 * s, C(0x3A1E14)); c.rect(f.cx - 6 * s, g - 12 * s, 12 * s, s, C(0xE8E2D4))
        for i in 0..<3 { c.rect(f.cx - f.hw / 2 - 2 * s + i * s, g - (3 - i) * s - s, f.hw + 4 * s - 2 * i * s, s, C(0xB8B2A4)) }
        for wx in [left + 6 * s, left + w - 14 * s] {   // the tall side windows
            c.rect(wx, f.roof + 6 * s, 8 * s, g - f.roof - 12 * s, C(0x2A1A16)); c.rect(wx + s, f.roof + 7 * s, 6 * s, g - f.roof - 14 * s, C(0xE8B85A, 0.55))
        }
        // The lamp post, and the cable strung down to it from the tower.
        let lp = f.lamp
        c.rect(lp.x, lp.top, 2 * s, g - lp.top, C(0x2A2A30)); c.rect(lp.x - s, g - 2 * s, 4 * s, 2 * s, C(0x2A2A30))
        c.rect(lp.x - 2 * s, lp.top - 3 * s, 6 * s, 3 * s, C(0x3A3A40)); c.rect(lp.x - s, lp.top - 2 * s, 4 * s, s, C(0xF6E8A8))
        let ax = Double(towerX), ay = Double(ck.y + ck.r + 2 * s), bx = Double(lp.x + s), by = Double(lp.top - 3 * s)
        let n = 40
        for i in 0..<n {
            let t0 = Double(i) / Double(n), t1 = Double(i + 1) / Double(n)
            let sag = Double(6 * s)
            c.glowLine(ax + (bx - ax) * t0, ay + (by - ay) * t0 + sin(t0 * .pi) * sag, ax + (bx - ax) * t1,
                       ay + (by - ay) * t1 + sin(t1 * .pi) * sag, core: C(0x1A1A1E), glow: C(0, 0), coreR: 0.5)
        }
        // The street: wet asphalt with the kerb's line and puddles catching the light.
        c.ground(g, C(0x22202A), edge: C(0x4A4656), speck: C(0x2E2C38), seed: 55)
        for i in 0..<6 {
            let px = Int(noise(i + 300) * Double(c.w)), py = g + 2 + Int(noise(i + 310) * Double(max(1, c.h - g - 3)))
            c.rect(px, py, (8 + Int(noise(i + 320) * 10)) * s, s, C(0x6A6A8A, 0.5))
        }
    }

    /// Behind the square: the dark hills with porch lights dotted over them, the radio mast on the right with its
    /// red light, and a back row of taller blocks over the shops, a few upper windows lit. On the screen saver a
    /// lower bank of storm cloud, the town's water tower on its legs, and the Essex's blade sign standing up over the
    /// roofs with its lights round the edge.
    private static func hv55Behind(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        if tall {
            // The storm's lower decks under the heavy stuff, rolling in from the right, their bellies lit a dull
            // amber by the town below.
            for i in 0..<16 {
                let x = c.w * 25 / 100 + Int(noise(i * 5 + 61) * Double(c.w * 85 / 100))
                let y = g * 30 / 100 + Int(noise(i * 5 + 62) * Double(g * 40 / 100)) / s * s
                let rx = (40 + Int(noise(i * 5 + 63) * 60)) * s, ry = (6 + Int(noise(i * 5 + 64) * 7)) * s
                c.ellipse(x, y, rx, ry, C(0x2E2446, 0.8))
                c.ellipse(x - 4 * s, y - 2 * s, rx * 3 / 4, ry * 2 / 3, C(0x3A2E52, 0.6))
                c.rect(x - rx / 2, y + ry - s, rx, s, C(0x6A4A4A, 0.35))
                c.ellipse(x - 6 * s, y + ry, rx * 2 / 3, 2 * s, C(0x1C1630, 0.6))
            }
        }
        // The hills, low and dark, with house lights scattered over them.
        let hillBase = g - (tall ? 30 : 20) * s, hillH = Double((tall ? 46 : 12) * s)
        func hill(_ x: Int) -> Int {
            let k = Double(x / s)
            return Int((0.55 + 0.25 * sin(k * 0.013 + 1.2) + 0.2 * sin(k * 0.041 + 0.4)) * hillH) / s * s
        }
        for x in stride(from: 0, to: c.w, by: s) {
            let h = hill(x)
            c.rect(x, hillBase - h, s, g - hillBase + h, C(0x1E1832))
        }
        for i in 0..<(c.w / (tall ? 14 : 30) / s) {
            let x = Int(noise(i * 3 + 71) * Double(c.w)) / s * s, h = hill(x)
            guard h > 3 * s, x > c.w * 20 / 100 || !tall else { continue }
            let y = hillBase - h + 2 * s + Int(noise(i * 3 + 72) * Double(h - 2 * s)) / s * s
            c.rect(x, y, s, s, C(0xF2C86A, noise(i * 3 + 73) > 0.5 ? 0.85 : 0.5))
        }
        // The radio mast on the hill: a lattice tapering up, guy wires, the red light on top.
        let mx = c.w * 90 / 100, mBase = hillBase - hill(mx), mh = (tall ? 120 : 26) * s
        for y in stride(from: mBase - mh, to: mBase, by: s) {
            let half = (y - (mBase - mh)) * (tall ? 4 : 2) * s / mh / s * s + s
            c.rect(mx - half, y, s, s, C(0x3A3446)); c.rect(mx + half, y, s, s, C(0x3A3446))
            if ((y - mBase) / s) % (tall ? 6 : 4) == 0 { c.rect(mx - half, y, 2 * half + s, s, C(0x2E2A3A)) }
        }
        for gx in [mx - mh / 3, mx + mh / 3] {
            let n = max(1, abs(gx - mx) / s)
            for k in stride(from: 0, through: n, by: 2) {
                c.rect(mx + (gx - mx) * k / n, mBase - mh * 2 / 3 + (mh * 2 / 3) * k / n, s, s, C(0x2A2636, 0.8))
            }
        }
        c.rect(mx - s, mBase - mh - 2 * s, 3 * s, 2 * s, C(0xE03A3A)); c.circle(mx, mBase - mh - s, 4 * s, C(0xFF4A4A, 0.15))
        if tall {
            // The water tower on its legs, up on the hill.
            let wx = c.w * 30 / 100, wBase = hillBase - hill(wx), top = wBase - 62 * s
            for (lx, lean) in [(wx - 9 * s, -1), (wx + 8 * s, 1), (wx - 3 * s, 0), (wx + 2 * s, 0)] {
                for y in stride(from: top + 14 * s, to: wBase, by: s) {
                    c.rect(lx + lean * (y - top - 14 * s) / (12 * s) * s, y, s, s, C(0x2E2838))
                }
            }
            for y in stride(from: top + 22 * s, to: wBase, by: 12 * s) { c.rect(wx - 10 * s, y, 21 * s, s, C(0x2A2434)) }
            c.rect(wx - 12 * s, top + 2 * s, 24 * s, 12 * s, C(0x3A3246)); c.rect(wx - 12 * s, top + 2 * s, 2 * s, 12 * s, C(0x4A4258))
            c.rect(wx - 12 * s, top + 13 * s, 24 * s, s, C(0x2A2434))
            for k in 0..<7 { c.rect(wx - 10 * s + k * 2 * s, top - k / 2 * s + 2 * s, 20 * s - k * 4 * s, s, C(0x34303F)) }
            c.rect(wx - s, top - 4 * s, s, 3 * s, C(0x2A2434))
        }
        // The back row: taller blocks behind the shops, some upper windows lit.
        var x = -6 * s, k = 0
        while x < c.w {
            let w = (26 + Int(noise(k * 3 + 91) * 20)) * s
            let h = (tall ? 44 + Int(noise(k * 3 + 92) * 22) : 28 + Int(noise(k * 3 + 92) * 6)) * s
            let col = [C(0x261E30), C(0x2C2236), C(0x221C2C)][k % 3]
            c.rect(x, g - h, w, h, col); c.rect(x, g - h, w, s, C(0x3A2E44))
            if noise(k * 3 + 93) > 0.5 { c.rect(x + w / 2 - 3 * s, g - h - 3 * s, 6 * s, 3 * s, col) }   // a roof box
            for wy in stride(from: g - h + 4 * s, to: g - (tall ? 36 : 25) * s, by: 7 * s) {
                for wx in stride(from: x + 3 * s, to: x + w - 5 * s, by: 7 * s) {
                    let lit = noise(wx / s * 7 + wy / s * 13 + 5) > 0.62
                    c.rect(wx, wy, 3 * s, 4 * s, lit ? C(0xF2C86A, 0.7) : C(0x16121E))
                }
            }
            x += w + s; k += 1
        }
        guard tall else { return }
        // The Essex's blade sign up over the roofs, its letters stacked, lights round the edge.
        let ex = c.w * 78 / 100, eTop = g - 84 * s, eh = 36 * s
        c.rect(ex - s, eTop + eh, 2 * s, 8 * s, C(0x2A2434))
        c.rect(ex - 6 * s, eTop, 12 * s, eh, C(0x8A1E22)); c.rect(ex - 5 * s, eTop + s, 10 * s, eh - 2 * s, C(0x1E1420))
        for (i, rows) in hv55Essex.enumerated() {
            for (dy, row) in rows.enumerated() {
                for (dx, p) in row.enumerated() where p == "#" {
                    c.rect(ex - 2 * s + dx * s, eTop + 3 * s + (i * 6 + dy) * s, s, s, C(0xFFD86A))
                }
            }
        }
        for y in stride(from: eTop + s, to: eTop + eh, by: 3 * s) {
            c.rect(ex - 6 * s, y, s, s, C(0xFFF0B0)); c.rect(ex + 5 * s, y, s, s, C(0xFFF0B0))
        }
        c.circle(ex, eTop + eh / 2, 20 * s, C(0xF2A040, 0.06))
    }

    /// The Essex's letters, 3×5, stacked down its blade sign.
    private static let hv55Essex: [[String]] = [
        ["###", "#..", "##.", "#..", "###"], [".##", "#..", ".#.", "..#", "##."], [".##", "#..", ".#.", "..#", "##."],
        ["###", "#..", "##.", "#..", "###"], ["#.#", "#.#", ".#.", "#.#", "#.#"],
    ]

    /// What moves on the square: rain slanting down, and now and then the lightning strike, a jagged bolt into the
    /// tower's spike while the sky flashes white and sparks run down the cable.
    static func hillValley1955Life(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hv55Frame(c, g)
        // Rain.
        for i in 0..<(c.w * g / 160) {
            let x0 = noise(i * 7 + 11) * Double(c.w + 40), speed = 70 + noise(i * 7 + 12) * 30
            let y = (noise(i * 7 + 13) * Double(g) + t * speed).truncatingRemainder(dividingBy: Double(g))
            let x = Int(x0 - y * 0.3) - 10
            c.rect(x, Int(y), 1, 2 * s, C(0xB8C4E8, 0.35))
        }
        // The lightning: every 7 seconds a strike, a flash and a flicker after.
        let cycle = t.truncatingRemainder(dividingBy: 7)
        guard cycle < 0.55 else { return }
        let flash = cycle < 0.12 ? 0.35 : (cycle > 0.25 && cycle < 0.32 ? 0.2 : 0)
        if flash > 0 { c.rect(0, 0, c.w, g, C(0xE8E8FF, flash)) }
        let topX = Double(f.cx) - 40 + noise(Int(t / 7)) * 80
        var prev = (x: topX, y: 0.0)
        let target = (x: Double(f.cx), y: Double(max(0, f.towerTop - 4 * s)))
        for i in 1...8 {
            let k = Double(i) / 8
            let jitter = i == 8 ? 0 : (noise(i * 13 + Int(t / 7) * 31) - 0.5) * 14
            let q = (x: topX + (target.x - topX) * k + jitter, y: target.y * k)
            c.glowLine(prev.x, prev.y, q.x, q.y, core: C(0xFFFFFF), glow: C(0xA8B8FF), coreR: 0.7, glowR: 2.6)
            prev = q
        }
        // Sparks running down the cable.
        let lp = f.lamp, k = min(1, cycle / 0.5)
        let ax = Double(f.cx - (isTall(c) ? 17 : 11) * s), ay = Double(f.clock.y + f.clock.r + 2 * s)
        let bx = Double(lp.x + s), by = Double(lp.top - 3 * s)
        let sx = ax + (bx - ax) * k, sy = ay + (by - ay) * k + sin(k * .pi) * Double(6 * s)
        c.glowLine(sx - 1, sy, sx + 1, sy, core: C(0xFFFFFF), glow: C(0x9AC8FF), coreR: 1, glowR: 3)
    }
}
