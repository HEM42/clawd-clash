import Foundation

// Halloween Town square: the crooked houses pulling faces round the green-slime fountain, the town hall, pumpkins
// everywhere, and on the screen saver Spiral Hill and its graveyard against the moon.

let burtonScenes1: [Location: Place] = [
    .halloweenTown: Place(name: "Halloween Town", panel: 0x140E2C, still: Scenes.halloweenTown,
                          moving: Scenes.halloweenTownLife),
]

// MARK: - Halloween Town

extension Scenes {
    /// Where things stand on the square: the town hall's middle and width, its roof line and spire top, the
    /// fountain's middle and basin radius, and the moon's middle and radius.
    static func htFrame(_ c: PixelCanvas, _ g: Int) -> (hall: (cx: Int, hw: Int, roof: Int, spire: Int),
                                                         fountain: (cx: Int, r: Int), moon: (x: Int, y: Int, r: Int)) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w * 58 / 100, hw = (tall ? 34 : 26) * s
        let roof = g - (tall ? 46 : 32) * s, spire = roof - (tall ? 44 : 26) * s
        let moon = tall ? (c.w * 30 / 100, g * 42 / 100, 40 * s) : (c.w * 86 / 100, 13 * s, 10 * s)
        return ((cx, hw, roof, max(3 * s, spire)), (c.w * 30 / 100, (tall ? 22 : 16) * s), moon)
    }

    private static let htGlow = C(0xFFD84A), htStone = C(0x4A3E80), htStoneLit = C(0x8A7AC8)

    /// A big moon with a soft halo, its two craters in `rim`.
    private static func htMoon(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, s: Int) {
        let core = C(0xFFD266), rim = C(0xF0A030), halo = C(0xFFB040)
        c.circle(x, y, r + 6 * s, halo.alpha(0.08)); c.circle(x, y, r + 3 * s, halo.alpha(0.16))
        c.circle(x, y, r, rim); c.circle(x - max(1, r / 14), y - max(1, r / 14), r - max(1, r / 12), core)
        c.circle(x - r / 3, y - r / 4, max(1, r / 5), rim.alpha(0.45)); c.circle(x + r / 3, y + r / 3, max(1, r / 6), rim.alpha(0.45))
    }

    /// A crooked, scary house: walls that bulge and bend as they rise, a witch-hat roof whose tip curls over, and
    /// either a jack-o'-lantern face for windows (`face`) or a few crooked lit windows.
    private static func htHouse(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, bend: Int, s: Int, wall: Px,
                                edge: Px, roof: Px, face: Bool, seed: Int) {
        let bulge = Double(w) * 0.14 * noise(seed + 1)
        func centre(_ r: Int) -> Double { Double(x) + Double(w) / 2 + Double(bend) * pow(Double(r) / Double(max(1, h)), 2) }
        for r in 0..<h {
            let k = Double(r) / Double(h)
            let half = Double(w) / 2 + bulge * sin(k * .pi) - Double(w) * 0.1 * k
            let x0 = Int((centre(r) - half).rounded()), x1 = Int((centre(r) + half).rounded())
            c.rect(x0, base - r - 1, x1 - x0, 1, wall)
            c.rect(x1 - s, base - r - 1, s, 1, edge)
        }
        // The witch-hat roof, its tip swept over and curled.
        let top = base - h, half0 = Double(w) / 2 + Double(2 * s)
        let roofH = Int(Double(w) * (1.0 + noise(seed + 2) * 1.0))
        let sweep = Double(bend) * 1.2 + (noise(seed + 3) - 0.5) * Double(w) * 1.2
        var tip = (x: centre(h), y: Double(top))
        for r in 0..<roofH {
            let k = Double(r) / Double(roofH)
            let half = half0 * pow(1 - k, 1.3)
            let cx = centre(h) + sweep * k * k
            c.rect(Int((cx - half).rounded()), top - r - 1, max(s, Int((half * 2).rounded())), 1, roof)
            tip = (cx, Double(top - r - 1))
        }
        let dir = sweep >= 0 ? 1 : -1
        for (dx, dy) in [(1, 0), (2, 1), (2, 2), (1, 3)] { c.rect(Int(tip.x) + dir * dx * s, Int(tip.y) + dy * s, s, s, roof) }
        // Windows: a face (angry slanted eyes and a zigzag grin), or two or three crooked lit panes.
        if face {
            let e = max(2 * s, w / 5), ey = top + h / 5, mid = centre(h * 3 / 4)
            for dy in 0..<e {
                for dx in 0..<e where dx <= dy {
                    c.px(Int(mid) - e - s + (e - 1 - dx), ey + dy, htGlow)   // the left eye, low at the nose
                    c.px(Int(mid) + s + dx, ey + dy, htGlow)                  // the right eye
                }
            }
            let mw = w * 3 / 5, mx = Int(centre(h / 3)) - mw / 2, my = base - h / 3 - 2 * s
            for i in 0..<mw { c.rect(mx + i, my + ((i / (2 * s)) % 2) * s, 1, 2 * s, htGlow) }
        } else {
            for i in 0..<(2 + Int(noise(seed + 4) * 2)) {
                let r = h * (i + 1) / 4, wx = Int(centre(r)) + (i % 2 == 0 ? -w / 4 : w / 8)
                c.rect(wx, base - r - 3 * s, 3 * s, 4 * s, htGlow)
                c.rect(wx + s, base - r - 3 * s, s, 4 * s, wall)
                c.rect(wx - s, base - r - 4 * s, 4 * s, s, wall)   // a crooked lintel
            }
        }
    }

    /// A grave on row `base`: a round-topped tombstone (0), a cross (1) or an obelisk (2), leaning by `tilt`, its
    /// moonlit side picked out.
    private static func htGrave(_ c: PixelCanvas, _ x: Int, _ base: Int, kind: Int, s: Int, tilt: Double) {
        switch kind {
        case 0:
            let w = 6 * s, h = 8 * s
            for r in 0..<h {
                let off = Int(tilt * Double(r)), round = r > h - 3 * s ? (r - (h - 3 * s)) : 0
                c.rect(x + off + round, base - r - 1, w - round * 2, 1, htStone); c.px(x + off + round, base - r - 1, htStoneLit)
            }
        case 1:
            let a = -90 + tilt * 40, foot = (x: Double(x), y: Double(base))
            let top = burtonReach(foot, a, Double(10 * s)), arm = burtonReach(foot, a, Double(7 * s))
            burtonLine(c, foot.x, foot.y, top.x, top.y, htStone, Double(s))
            let p = burtonReach(arm, a + 90, Double(3 * s)), q = burtonReach(arm, a - 90, Double(3 * s))
            burtonLine(c, p.x, p.y, q.x, q.y, htStone, Double(s))
        default:
            let h = 16 * s
            for r in 0..<h {
                let w = max(s, 5 * s - r * 2 * s / h), off = Int(tilt * Double(r))
                c.rect(x + off - w / 2, base - r - 1, w, 1, htStone); c.px(x + off - w / 2, base - r - 1, htStoneLit)
            }
            c.rect(x - 4 * s, base - 2 * s, 8 * s, 2 * s, htStone)
        }
    }

    /// A pumpkin sitting on row `base`, `r` across; `face`: carved, its eyes and grin glowing at `glow`.
    static func htPumpkin(_ c: PixelCanvas, _ x: Int, _ base: Int, r: Int, s: Int, face: Bool, glow: Double = 1) {
        c.ellipse(x, base - r * 2 / 3, r, r * 2 / 3, C(0xE0701A))
        c.ellipse(x - r / 3, base - r * 2 / 3, max(1, r / 3), r * 2 / 3, C(0xC85A12))
        c.rect(x, base - r * 4 / 3 - s, s, 2 * s, C(0x3A5A1A))
        guard face else { return }
        let lamp = C(0xFFD24A, glow)
        c.rect(x - r / 2, base - r, 2 * s, 2 * s, lamp); c.rect(x + r / 2 - 2 * s, base - r, 2 * s, 2 * s, lamp)
        c.rect(x - r / 2, base - r / 3, r, s, lamp)
    }

    /// Small pumpkins scattered along a skyline (`top(x)` gives the ground there), every `gap` pixels or so; some
    /// carved and glowing.
    private static func htPumpkinRow(_ c: PixelCanvas, from x0: Int, to x1: Int, gap: Int, s: Int, seed: Int,
                                     top: (Int) -> Int) {
        var x = x0, i = 0
        while x < x1 {
            let r = (2 + Int(noise(seed + i * 3) * 3)) * s
            htPumpkin(c, x, top(x) + s, r: r, s: s, face: noise(seed + i * 3 + 1) > 0.55)
            x += gap + Int(noise(seed + i * 3 + 2) * Double(gap)); i += 1
        }
    }

    /// Spiral Hill on the screen saver, its curl in front of the moon, its rim catching the moonlight, and a
    /// graveyard all over it: graves along both slopes and further down its sides, a crooked fence, pumpkins.
    private static func htSpiralHill(_ c: PixelCanvas, _ g: Int, moon m: (x: Int, y: Int, r: Int), base: Int) {
        let s = unit(g)
        let hh = (base - m.y) * 100 / 71, hw = hh * 8 / 5, hx = m.x - hw * 3 / 5, curlX = hx + hw * 3 / 5
        burtonSpiralHill(c, x: hx, base: base, w: hw, h: hh, C(0x221848))
        func top(_ x: Int) -> Int { burtonSpiralHillTop(x: hx, base: base, w: hw, h: hh, at: x) }
        for x in hx..<(hx + hw) where top(x) < base { c.rect(x, top(x), 1, s, C(0x3A2C70)) }
        // Graves along the whole ridge, both sides of the curl's foot, leaning every way.
        for i in 0..<18 {
            let gx = hx + hw * (3 + i * 94 / 17) / 100
            guard abs(gx - curlX) > hh / 9, top(gx) < base - 4 * s else { continue }
            htGrave(c, gx, top(gx) + 2 * s, kind: [0, 1, 1, 0, 2, 1, 0, 1, 0][i % 9], s: s, tilt: (noise(i + 1300) - 0.5) * 0.5)
        }
        // More, further down the hill's sides: the graveyard covers it.
        for i in 0..<16 {
            let gx = hx + Int(noise(i + 1320) * Double(hw))
            let t = top(gx), depth = Double(base - t) * (0.3 + noise(i + 1330) * 0.45)
            guard base - t > 12 * s, abs(gx - curlX) > hh / 12 else { continue }
            htGrave(c, gx, t + Int(depth), kind: i % 3, s: s, tilt: (noise(i + 1340) - 0.5) * 0.6)
        }
        // A crooked picket fence down the right-hand slope.
        for k in 0..<10 {
            let fx = curlX + hh / 4 + k * 4 * s
            guard fx < hx + hw - 4 * s else { break }
            let ft = top(fx) + 6 * s, lean = Int((noise(k + 1360) - 0.5) * Double(3 * s))
            c.rect(fx + lean, ft - 5 * s, s, 6 * s, C(0x161034)); c.px(fx + lean, ft - 6 * s, C(0x161034))
            if k > 0 { burtonLine(c, Double(fx - 4 * s), Double(top(fx - 4 * s) + 3 * s), Double(fx), Double(ft - 3 * s), C(0x161034), 0.5) }
        }
        // Pumpkins on both slopes and among the graves.
        htPumpkinRow(c, from: hx + hw / 20, to: curlX - hh / 8, gap: 12 * s, s: s, seed: 1400) { top($0) }
        htPumpkinRow(c, from: curlX + hh / 8, to: hx + hw - 6 * s, gap: 14 * s, s: s, seed: 1450) { top($0) }
        for i in 0..<8 {
            let px = hx + Int(noise(i + 1500) * Double(hw)), t = top(px)
            guard base - t > 10 * s else { continue }
            htPumpkin(c, px, t + Int(Double(base - t) * (0.25 + noise(i + 1510) * 0.5)), r: 3 * s, s: s, face: i % 2 == 0)
        }
    }

    /// The town hall: a crooked block under a big triangular gable with a spider-web rose window glowing in it and
    /// orange-and-black bunting strung under it, two crooked turrets at its corners, the spire bent over with a bat
    /// for a weathervane, tall arched windows, and the arched door between two lanterns.
    private static func htTownHall(_ c: PixelCanvas, _ g: Int, _ f: (cx: Int, hw: Int, roof: Int, spire: Int)) {
        let s = unit(g), tall = isTall(c)
        let wall = C(0x3A2C78), dark = C(0x281E5A), trim = C(0x6A5AA8), lamp = C(0xFFB040)
        let left = f.cx - f.hw
        // The turrets, behind the block's corners.
        let th = g - f.roof + (tall ? 18 : 10) * s
        htHouse(c, x: left - 10 * s, base: g, w: 12 * s, h: th, bend: -4 * s, s: s, wall: wall, edge: trim, roof: C(0x4A3A90),
                face: false, seed: 1601)
        htHouse(c, x: left + f.hw * 2 - 2 * s, base: g, w: 12 * s, h: th, bend: 4 * s, s: s, wall: wall, edge: trim,
                roof: C(0x4A3A90), face: false, seed: 1607)
        // The block, leaning a little as it rises.
        for r in 0..<(g - f.roof) {
            let off = Int(Double(3 * s) * pow(Double(r) / Double(max(1, g - f.roof)), 2))
            c.rect(left + off, g - r - 1, f.hw * 2, 1, wall); c.rect(left + off + f.hw * 2 - s, g - r - 1, s, 1, trim)
        }
        // The gable, its trim, and the rose window with a spider's web across it.
        let gh = (f.roof - f.spire) / 2, apex = (x: f.cx + 3 * s, y: f.roof - gh)
        for r in 0..<gh {
            let half = (f.hw + 3 * s) * (gh - r) / gh, x0 = apex.x - half
            c.rect(x0, f.roof - r - 1, half * 2, 1, wall)
            c.rect(x0, f.roof - r - 1, s, 1, trim); c.rect(x0 + half * 2 - s, f.roof - r - 1, s, 1, trim)
        }
        c.rect(apex.x - f.hw - 4 * s, f.roof - s, (f.hw + 4 * s) * 2, 2 * s, dark)
        let rw = (x: apex.x, y: f.roof - gh * 2 / 5), rr = max(3 * s, gh * 2 / 5)
        c.circle(rw.x, rw.y, rr + s, dark); c.circle(rw.x, rw.y, rr, lamp)
        for k in 0..<8 {
            let a = Double(k) / 8 * 2 * .pi
            burtonLine(c, Double(rw.x), Double(rw.y), Double(rw.x) + cos(a) * Double(rr), Double(rw.y) + sin(a) * Double(rr), dark, 0.45)
        }
        for ring in [rr * 2 / 5, rr * 3 / 4] {
            for k in 0..<(ring * 6) {
                let a = Double(k) / Double(ring * 6) * 2 * .pi
                c.px(rw.x + Int((cos(a) * Double(ring)).rounded()), rw.y + Int((sin(a) * Double(ring)).rounded()), dark)
            }
        }
        // The bunting, sagging under the gable: orange and black pennants.
        let bx0 = left - 2 * s, bx1 = left + f.hw * 2 + 4 * s, step = 4 * s
        for (i, bx) in stride(from: bx0, to: bx1, by: step).enumerated() {
            let k = Double(bx - bx0) / Double(bx1 - bx0), by = f.roof + 2 * s + Int(sin(k * .pi) * Double(3 * s))
            let col = i % 2 == 0 ? C(0xE0701A) : C(0x120E1C)
            for r in 0..<(3 * s) { c.rect(bx + r / 2, by + r, max(s, 3 * s - r), 1, col) }
        }
        // The spire off the gable's top, bent over, and the bat on its tip.
        let sh = apex.y - f.spire
        var tip = (x: apex.x, y: apex.y)
        for r in 0..<sh {
            let k = Double(r) / Double(sh)
            let half = Int(Double(5 * s) * (1 - k)), off = Int(k * k * Double(9 * s)), w = max(s, half * 2)
            c.rect(apex.x - half + off, apex.y - r, w, 1, C(0x4A3A90)); c.rect(apex.x - half + off + w - s, apex.y - r, s, 1, trim)
            tip = (apex.x + off, apex.y - r)
        }
        c.rect(tip.x, tip.y - 3 * s, s, 3 * s, trim)
        c.pattern(tip.x - 3 * s, tip.y - 5 * s, ["K.....K", "KK.K.KK", ".KKKKK."].flatMap { row in
            Array(repeating: String(row.flatMap { Array(repeating: $0, count: s) }), count: s) }, ["K": C(0x120E1C)])
        // Tall arched windows, the door and its lanterns, and the steps.
        let wh = (g - f.roof) / 2
        for wx in [left + 4 * s, left + 12 * s, left + f.hw * 2 - 17 * s, left + f.hw * 2 - 9 * s] {
            c.rect(wx, f.roof + 9 * s, 4 * s, wh - 2 * s, lamp); c.rect(wx + s, f.roof + 8 * s, 2 * s, s, lamp)
            c.rect(wx, f.roof + 9 * s + wh / 2, 4 * s, s, wall)
        }
        let dw = 12 * s, dh = (tall ? 20 : 14) * s, dx = f.cx - dw / 2
        c.rect(dx, g - dh, dw, dh, C(0x0C0A14)); c.ellipse(f.cx, g - dh, dw / 2, 3 * s, C(0x0C0A14))
        c.rect(f.cx, g - dh, s, dh, wall)
        for lx in [dx - 4 * s, dx + dw + 2 * s] { c.rect(lx, g - dh + 2 * s, 2 * s, 3 * s, htGlow); c.rect(lx, g - dh + s, 2 * s, s, dark) }
        for i in 0..<2 { c.rect(dx - (2 + i * 2) * s, g - (2 - i) * s, dw + (4 + i * 4) * s, s, trim) }
    }

    /// Halloween Town at night, in its purples: a big orange-yellow moon, a ridge of pumpkins behind the town, and
    /// two rows of crooked houses bending and bulging, most of them pulling jack-o'-lantern faces with their windows;
    /// the town hall in the middle, the green-slime fountain in the square, pumpkins on the cobbles. On the screen
    /// saver Spiral Hill curls up in front of the moon, its graveyard all over it.
    static func halloweenTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = htFrame(c, g)
        c.gradient(0, g, C(0x1C1440), C(0x5A3E9A), bands: 7)
        c.stars(0, g / 2, density: 120, seed: 41)
        htMoon(c, f.moon.x, f.moon.y, f.moon.r, s: s)
        if tall {
            c.dunes(base: g - 84 * s, amp: 8 * Double(s), freq: 0.018, phase: 2.1, bottom: g, C(0x3A2A70))
            htSpiralHill(c, g, moon: f.moon, base: g - 78 * s)
        }
        // A far ridge behind the town with its pumpkins.
        let ridge = g - (tall ? 70 : 34) * s
        c.dunes(base: ridge, amp: 3 * Double(s), freq: 0.05, phase: 0.4, bottom: g, C(0x2E2262))
        htPumpkinRow(c, from: 4 * s, to: c.w, gap: 16 * s, s: s, seed: 300) { x in
            ridge - Int((sin(Double(x) * 0.05 + 0.4) * 0.6 + sin(Double(x) * 0.115 + 0.68) * 0.4) * 3 * Double(s))
        }
        // Two rows of crooked houses: a far row, darker and smaller, then the near row.
        let rows = [(C(0x2A1F58), C(0x3E3080), C(0x201848)), (C(0x372A72), C(0x5A48A8), C(0x281E5A))]
        for (row, colours) in rows.enumerated() {
            var x = -6 * s + row * 9 * s, k = 0
            while x < c.w {
                let seed = k * 5 + row * 77
                let w = (12 + Int(noise(seed) * 12)) * s
                let h = ((tall ? 26 : 16) - row * 4) * s + Int(noise(seed + 1) * Double((tall ? 20 : 12) * s))
                let bend = Int((noise(seed + 2) - 0.5) * Double(14 * s))
                if row == 0 || abs(x + w / 2 - f.hall.cx) > f.hall.hw + 12 * s + w / 2 {
                    htHouse(c, x: x, base: g - (row == 0 ? 6 : 0) * s, w: w, h: h, bend: bend, s: s, wall: colours.0,
                            edge: colours.1, roof: colours.2, face: noise(seed + 3) > 0.45, seed: k * 11 + row)
                }
                x += w + (row == 0 ? 2 : 4 + Int(noise(k * 5 + 4) * 8)) * s; k += 1
            }
        }
        htTownHall(c, g, f.hall)
        // The fountain: a stone basin brimming with green slime, the pillar in the middle and the slime spouting.
        let fc = f.fountain, stone = C(0x5A4E8A)
        c.rect(fc.cx - 2 * s, g - (tall ? 26 : 18) * s, 4 * s, (tall ? 22 : 14) * s, stone)
        c.ellipse(fc.cx, g - (tall ? 28 : 19) * s, 4 * s, 2 * s, stone)
        c.rect(fc.cx - fc.r, g - 6 * s, fc.r * 2, 6 * s, stone); c.rect(fc.cx - fc.r, g - 6 * s, fc.r * 2, s, C(0x8076AA))
        c.ellipse(fc.cx, g - 6 * s, fc.r - s, 2 * s, C(0x5ACB3A))
        c.ellipse(fc.cx, g - 6 * s, fc.r - 4 * s, s, C(0x8AF060))
        // The cobbles, and pumpkins along them.
        c.ground(g, C(0x3A2E6A), edge: C(0x6A5AA8), speck: C(0x2A204E), seed: 77)
        for i in 0..<10 {
            let px = Int(noise(i + 410) * Double(c.w)), r = (3 + Int(noise(i + 420) * 4)) * s
            guard abs(px - fc.cx) > fc.r + r, abs(px - f.hall.cx) > f.hall.hw + 8 * s else { continue }
            htPumpkin(c, px, g + 2 * s, r: r, s: s, face: i % 2 == 0)
        }
    }

    /// What moves in the square: the fountain's slime spouting and bubbling, the carved pumpkins' candles and the
    /// town hall's rose window flickering, and a bat flitting across now and then.
    static func halloweenTownLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = htFrame(c, g), fc = f.fountain
        // The slime spout arcing down from the pillar's top into the basin, both ways.
        let topY = Double(g - (tall ? 29 : 20) * s)
        for side in [-1.0, 1.0] {
            for i in 0..<10 {
                let k = (Double(i) / 10 + t * 0.9).truncatingRemainder(dividingBy: 1)
                let x = Double(fc.cx) + side * k * Double(fc.r - 3 * s), y = topY - sin(k * .pi) * Double(4 * s) + k * k * Double(14 * s)
                c.rect(Int(x.rounded()), Int(y.rounded()), s, s, C(0x8AF060, 0.85))
            }
        }
        // Bubbles rising and popping in the basin.
        for i in 0..<5 {
            let k = (t * 0.6 + noise(i + 600)).truncatingRemainder(dividingBy: 1)
            let bx = fc.cx + Int((noise(i + 610) - 0.5) * Double(fc.r * 2 - 6 * s))
            let r = k < 0.85 ? max(s, Int(k * Double(2 * s) + 0.5)) : 0
            if r > 0 { c.circle(bx, g - 7 * s - Int(k * Double(2 * s)), r, C(0xB0FF80, 0.8)) }
        }
        // The carved pumpkins' candles flicker over their faces.
        for i in 0..<10 where i % 2 == 0 {
            let px = Int(noise(i + 410) * Double(c.w)), r = (3 + Int(noise(i + 420) * 4)) * s
            guard abs(px - fc.cx) > fc.r + r, abs(px - f.hall.cx) > f.hall.hw + 8 * s else { continue }
            c.rect(px - r / 2, g + 2 * s - r, r, s, C(0xFFF0A0, 0.2 + 0.35 * noise(Int(t * 9) + i * 13)))
        }
        // The rose window's glow breathing.
        let gh = (f.hall.roof - f.hall.spire) / 2, rr = max(3 * s, gh * 2 / 5)
        c.circle(f.hall.cx + 3 * s, f.hall.roof - gh * 2 / 5, rr, C(0xFFE08A, 0.12 + 0.12 * sin(t * 2.3)))
        // A bat, crossing every 9 seconds, its wings flapping.
        let cycle = t.truncatingRemainder(dividingBy: 9) / 9
        guard cycle < 0.5 else { return }
        let bx = Int(Double(c.w + 40) * cycle * 2) - 20, by = g / 3 + Int(sin(t * 3) * Double(6 * s))
        let up = Int(t * 10) % 2 == 0
        c.pattern(bx, by, up ? ["K.....K", "KK.K.KK", ".KKKKK.", "...K..."] : ["...K...", ".KKKKK.", "KK...KK", "K.....K"],
                  ["K": C(0x0A0810)])
    }
}
