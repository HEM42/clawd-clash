import Foundation

// Hook: Neverland, Pirate Town and the Jolly Roger.

let clawdbergScenes10: [Location: Place] = [
    .neverland: Place(name: "Neverland", panel: 0x16261A, still: Scenes.neverland, moving: Scenes.neverlandLife),
    .pirateTown: Place(name: "Pirate Town", panel: 0x2A1E14, still: Scenes.pirateTown, moving: Scenes.pirateTownLife),
    .jollyRoger: Place(name: "The Jolly Roger", panel: 0x221424, still: Scenes.jollyRoger, moving: Scenes.jollyRogerLife),
]

// MARK: - Shared bits for Neverland

/// A hard pixel line with no glow (ropes, rigging, masts).
private func hkLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px,
                    _ r: Double = 0.5) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.01)
}

/// A rope slung between two points, sagging by `sag` in the middle, drawn in `n` straight pieces; returns the
/// points along it (for hanging lights on).
@discardableResult
private func hkRope(_ c: PixelCanvas, _ a: (Int, Int), _ b: (Int, Int), sag: Int, _ col: Px, n: Int = 16,
                    draw: Bool = true) -> [(Double, Double)] {
    var pts: [(Double, Double)] = []
    for i in 0...n {
        let q = Double(i) / Double(n)
        let x = Double(a.0) + Double(b.0 - a.0) * q
        let y = Double(a.1) + Double(b.1 - a.1) * q + sin(q * .pi) * Double(sag)
        pts.append((x, y))
    }
    if draw {
        for (p, q) in zip(pts, pts.dropFirst()) { hkLine(c, p.0, p.1, q.0, q.1, col) }
    }
    return pts
}

/// The fairy lights' colours, in the order they hang.
private let hkFairy: [UInt32] = [0xFFD84A, 0xFF7AB8, 0x7AE8FF, 0xFFFFFF, 0xB8FF6A]

// MARK: - Neverland

extension Scenes {
    /// Where Neverland's things are: the giant tree's middle and trunk half-width, the cliff's lip and the
    /// waterfall's left edge and width, the treehouse platforms (x, y, width), and the zip line's two ends.
    private static func hkNeverFrame(_ c: PixelCanvas, _ g: Int) -> (tree: Int, trunk: Int, cliff: Int, fall: (x: Int, w: Int),
                                                                       decks: [(x: Int, y: Int, w: Int)],
                                                                       zip: ((Int, Int), (Int, Int)),
                                                                       lights: [((Int, Int), (Int, Int), Int)]) {
        let s = unit(g), tall = isTall(c)
        let tree = c.w * 74 / 100
        if tall {
            let trunk = 34 * s
            let decks = [(tree - trunk - 40 * s, g - 70 * s, 50 * s), (tree + trunk - 6 * s, g - 120 * s, 56 * s),
                         (tree - trunk - 34 * s, g - 170 * s, 46 * s), (tree + trunk - 10 * s, g - 214 * s, 44 * s)]
            let zip = ((tree - trunk - 30 * s, g - 168 * s), (c.w * 14 / 100, g - 216 * s))
            let lights = [((tree - trunk - 40 * s, g - 70 * s), (c.w * 40 / 100, g - 60 * s), 16 * s),
                          ((tree + trunk + 46 * s, g - 120 * s), (c.w - 2 * s, g - 96 * s), 14 * s),
                          ((c.w * 40 / 100, g - 60 * s), (c.w * 24 / 100, g - 120 * s), 12 * s)]
            return (tree, trunk, g - 226 * s, (c.w * 10 / 100, 18 * s), decks, zip, lights)
        }
        let trunk = 15 * s
        let decks = [(tree - trunk - 26 * s, 17 * s, 30 * s), (tree + trunk - 4 * s, 12 * s, 32 * s)]
        let zip = ((tree - trunk - 24 * s, 16 * s), (c.w * 18 / 100, 7 * s))
        let lights = [((tree - trunk - 26 * s, 18 * s), (c.w * 44 / 100, 14 * s), 6 * s),
                      ((tree + trunk + 28 * s, 13 * s), (c.w - 2 * s, 9 * s), 5 * s)]
        return (tree, trunk, 4 * s, (c.w * 9 / 100, 10 * s), decks, zip, lights)
    }

    /// A Lost Boys' hut on a platform: a patchwork box of planks in a bright colour, a little window and a pointed
    /// roof, with the platform's plank edge under it.
    private static func hkHut(_ c: PixelCanvas, x: Int, y: Int, w: Int, s: Int, col: Px, roof: Px) {
        c.rect(x, y, w, 2 * s, C(0x7A5232)); c.rect(x, y, w, s, C(0xA8784A))
        for px in stride(from: x + 2 * s, to: x + w, by: 8 * s) { c.rect(px, y + 2 * s, s, 3 * s, C(0x5A3A22)) }
        let hw = w * 3 / 5, hx = x + (w - hw) / 2, hh = max(5 * s, w / 3)
        c.rect(hx, y - hh, hw, hh, col)
        c.rect(hx + hw / 2, y - hh, hw / 2, hh / 2, col.alpha(0.75))
        c.rect(hx + 2 * s, y - hh + 2 * s, 3 * s, 3 * s, C(0x2A1A10)); c.rect(hx + 2 * s, y - hh + 2 * s, 3 * s, s, C(0xFFD87A))
        for i in 0..<(hw / 2 + 2 * s) {
            let rw = max(s, hw + 4 * s - 2 * i)
            c.rect(hx - 2 * s + i, y - hh - i / 2 - s, rw, 1, roof)
            if rw <= s { break }
        }
    }

    /// The Lost Boys' Neverland in full colour: a teal-to-gold sky, soft island hills, a mossy cliff on the left with
    /// its waterfall pouring into a pool, and on the right the giant tree, its huge trunk and roots, its canopy
    /// overhead, and the boys' patchwork huts on plank platforms. Rope zip lines run off it and strings of fairy
    /// lights hang in loops. On the screen saver the giant tree climbs the whole height with more huts and ladders.
    static func neverland(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hkNeverFrame(c, g)
        c.gradient(0, g, C(0x5ABED0), C(0xF6DC96), bands: 7)
        for i in 0..<(tall ? 8 : 4) {
            cloud(c, Int(noise(i + 3000) * Double(c.w)), Int(noise(i + 3010) * Double(tall ? g / 2 : 14 * s)), 4 * s,
                  seed: i + 30, top: C(0xFFF6E0), base: C(0xF0D8B0))
        }
        // The island's hills and forest.
        c.dunes(base: g - (tall ? 70 : 26) * s, amp: Double((tall ? 18 : 6) * s), freq: 0.02, phase: 1.1, bottom: g, C(0x7AB89A))
        c.dunes(base: g - (tall ? 40 : 16) * s, amp: Double((tall ? 10 : 4) * s), freq: 0.045, phase: 3.0, bottom: g, C(0x4E9A5E))
        // The cliff and its waterfall.
        let cw = f.fall.x + f.fall.w + (tall ? 40 : 26) * s
        for x in 0..<cw {
            let lip = f.cliff + Int(noise(x / max(1, 3 * s) + 3100) * 3) * s
            let edge = x > cw - 14 * s ? (x - (cw - 14 * s)) * (g - f.cliff) / max(1, 14 * s) : 0
            let top = lip + edge
            if top < g {
                c.rect(x, top, 1, g - top, (x / max(1, 4 * s)) % 3 == 0 ? C(0x5A6A66) : C(0x6A7C74))
                c.rect(x, top, 1, 2 * s, C(0x5AA84A))
            }
        }
        for i in 0..<(tall ? 26 : 10) {
            let mx = Int(noise(i + 3200) * Double(cw)), my = f.cliff + Int(noise(i + 3210) * Double(g - f.cliff))
            c.ellipse(mx, my, 3 * s, s, C(0x4A8A3E))
        }
        c.rect(f.fall.x, f.cliff, f.fall.w, g - f.cliff, C(0x9ADCE4))
        for x in stride(from: f.fall.x, to: f.fall.x + f.fall.w, by: 2 * s) { c.rect(x, f.cliff, s, g - f.cliff, C(0xD4F4F4)) }
        c.ellipse(f.fall.x + f.fall.w / 2, g - s, f.fall.w + 10 * s, 3 * s, C(0x6AC8D4))
        c.ellipse(f.fall.x + f.fall.w / 2, g - 2 * s, f.fall.w, 2 * s, C(0xF0FFFF, 0.8))
        // The giant tree: roots, the trunk and its grooves, the canopy.
        let t = f.tree, tw = f.trunk
        for i in 0..<5 {
            let dir = i < 2 ? -1.0 : (i > 2 ? 1.0 : 0.3)
            let len = Double((tall ? 50 : 26) * s) * (0.6 + noise(i + 3300) * 0.6)
            let rx = Double(t + (i - 2) * tw / 2)
            hkLine(c, rx, Double(g - (tall ? 30 : 12) * s), rx + dir * len, Double(g), C(0x5A3C24), Double((tall ? 4 : 2) * s))
        }
        c.rect(t - tw, 0, tw * 2, g, C(0x6A4A2E))
        c.rect(t - tw, 0, 3 * s, g, C(0x8A6440)); c.rect(t + tw - 4 * s, 0, 4 * s, g, C(0x4A3220))
        for i in 0..<(tall ? 14 : 6) {
            let gx = t - tw + 5 * s + Int(noise(i + 3400) * Double(tw * 2 - 10 * s))
            var y = 0
            while y < g {
                c.rect(gx + Int(sin(Double(y) * 0.08 + Double(i)) * 1.5), y, s, 1, C(0x523822))
                y += 1
            }
        }
        // Ladders up the trunk and the canopy.
        c.rect(t - 4 * s, f.decks[0].y, s, g - f.decks[0].y, C(0xA8784A)); c.rect(t + 2 * s, f.decks[0].y, s, g - f.decks[0].y, C(0xA8784A))
        for y in stride(from: f.decks[0].y + 2 * s, to: g, by: 4 * s) { c.rect(t - 4 * s, y, 7 * s, s, C(0xA8784A)) }
        let crown = tall ? -14 * s : -6 * s
        for i in 0..<(tall ? 34 : 9) {
            let lx = t + Int((noise(i + 3500) - 0.5) * Double((tall ? 300 : 170) * s))
            let ly = crown + Int(noise(i + 3510) * Double((tall ? 100 : 10) * s))
            let r = (tall ? 30 : 16) * s + Int(noise(i + 3520) * 10) * s
            c.ellipse(lx, ly, r, r * 2 / 3, i % 2 == 0 ? C(0x3E8A3A) : C(0x5AA848))
            c.ellipse(lx - r / 4, ly - r / 4, r / 2, r / 4, C(0x7AC85A))
        }
        if tall {
            // Branches reaching out to the higher huts.
            for d in f.decks {
                let from = Double(d.x < t ? t - tw : t + tw), to = Double(d.x < t ? d.x : d.x + d.w)
                hkLine(c, from, Double(d.y + 8 * s), to, Double(d.y + 2 * s), C(0x5A3C24), Double(3 * s))
            }
        }
        // The huts.
        let cols: [(UInt32, UInt32)] = [(0xC84A2A, 0x3A6AB8), (0xE8B83A, 0xC84A2A), (0x3A6AB8, 0xE8B83A), (0x8A4AB8, 0x5AA848)]
        for (i, d) in f.decks.enumerated() {
            hkHut(c, x: d.x, y: d.y, w: d.w, s: s, col: C(cols[i % 4].0), roof: C(cols[i % 4].1))
        }
        // The zip line, and the fairy lights on their strings.
        hkRope(c, f.zip.0, f.zip.1, sag: (tall ? 10 : 4) * s, C(0x3A2818))
        for l in f.lights {
            let pts = hkRope(c, l.0, l.1, sag: l.2, C(0x3A2818, 0.8), n: 20)
            for (i, p) in pts.enumerated() where i % 2 == 0 {
                c.rect(Int(p.0), Int(p.1) + s, s, s, C(hkFairy[(i / 2) % hkFairy.count]))
            }
        }
        for l in f.lights where l.1.0 < c.w - 4 * s && l.1.1 > (tall ? g - 80 * s : 12 * s) {
            c.rect(l.1.0, l.1.1, s * 2, g - l.1.1, C(0x7A5232))   // a pole holding the far end
        }
        // The grass, with flowers.
        c.ground(g, C(0x4A8A3A), edge: C(0x7AC858), speck: C(0x3E7A30), seed: 91)
        for i in 0..<24 {
            let fx = Int(noise(i + 3600) * Double(c.w)), fy = g + 2 + Int(noise(i + 3610) * Double(max(1, c.h - g - 3)))
            c.rect(fx, fy, s, s, C(hkFairy[i % 3]))
        }
    }

    /// What moves in Neverland: the waterfall pouring, the fairy lights twinkling, a Lost Boy whizzing down the zip
    /// line now and then, and a fairy's spark darting about the tree.
    static func neverlandLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = hkNeverFrame(c, g)
        // The water.
        let h = Double(g - f.cliff)
        for i in 0..<(f.fall.w / s * 3) {
            let x = f.fall.x + Int(noise(i + 3700) * Double(f.fall.w))
            let y = (noise(i + 3710) * h + t * (40 + noise(i + 3720) * 30)).truncatingRemainder(dividingBy: h)
            c.rect(x, f.cliff + Int(y), s, 4 * s, C(0xFFFFFF, 0.7))
        }
        for i in 0..<5 {
            let k = (t * 0.8 + Double(i) / 5).truncatingRemainder(dividingBy: 1)
            let x = f.fall.x + f.fall.w / 2 + Int((noise(i + 3730) - 0.5) * Double(f.fall.w * 2))
            c.rect(x, g - 2 * s - Int(k * Double(5 * s)), s, s, C(0xFFFFFF, 1 - k))
        }
        // The fairy lights twinkling.
        for (li, l) in f.lights.enumerated() {
            let pts = hkRope(c, l.0, l.1, sag: l.2, C(0, 0), n: 20, draw: false)
            for (i, p) in pts.enumerated() where i % 2 == 0 && noise(i + li * 50 + Int(t * 3)) > 0.7 {
                let col = C(hkFairy[(i / 2) % hkFairy.count])
                c.glowLine(p.0, p.1 + Double(s), p.0 + 0.1, p.1 + Double(s), core: col, glow: col.alpha(0.5),
                           coreR: Double(s) * 0.7, glowR: Double(s) * 2.2)
            }
        }
        // A Lost Boy down the zip line: a little figure hanging from a handle, every 7 seconds.
        let ride = t.truncatingRemainder(dividingBy: 7)
        if ride < 2.2 {
            let k = ride / 2.2
            let pts = hkRope(c, f.zip.0, f.zip.1, sag: (tall ? 10 : 4) * s, C(0, 0), draw: false)
            let fi = min(Double(pts.count - 1), k * Double(pts.count - 1))
            let p = pts[Int(fi)]
            let x = Int(p.0), y = Int(p.1)
            c.rect(x - s, y, 3 * s, s, C(0x2A1A10))                         // the handle
            c.rect(x - s, y + s, s, 3 * s, C(0xE8A86A)); c.rect(x + s, y + s, s, 3 * s, C(0xE8A86A))
            c.rect(x - s, y + 3 * s, 3 * s, 4 * s, C(0x5AA848))             // the tunic
            c.rect(x - s, y + 2 * s, 3 * s, 2 * s, C(0xE8A86A))             // the face
            c.rect(x - s, y + s, 3 * s, s, C(0xC84A2A))                     // the cap
            c.rect(x - s, y + 7 * s, s, 2 * s, C(0x5A3A22)); c.rect(x + s, y + 7 * s, s, 2 * s, C(0x5A3A22))
        }
        // A fairy's spark round the tree.
        let fx = Double(f.tree) + sin(t * 1.3) * Double((tall ? 90 : 60) * s) + sin(t * 3.1) * Double(8 * s)
        let fy = Double(tall ? g / 2 : 20 * s) + sin(t * 2.1) * Double((tall ? 60 : 10) * s)
        for k in 1...5 {
            let back = Double(k) * 0.06
            let tx = Double(f.tree) + sin((t - back) * 1.3) * Double((tall ? 90 : 60) * s) + sin((t - back) * 3.1) * Double(8 * s)
            let ty = Double(tall ? g / 2 : 20 * s) + sin((t - back) * 2.1) * Double((tall ? 60 : 10) * s)
            c.rect(Int(tx), Int(ty), s, s, C(0xFFE88A, 0.6 - Double(k) * 0.1))
        }
        c.glowLine(fx, fy, fx + 0.1, fy, core: C(0xFFFFF0), glow: C(0xFFD84A), coreR: Double(s) * 0.9, glowR: Double(s) * 3)
    }
}

// MARK: - Pirate Town

extension Scenes {
    /// Where things stand in Pirate Town: the horizon, the crocodile tower's middle, its plinth top, its body's top,
    /// half-width and head size, and the clock's centre and radius.
    private static func hkTownFrame(_ c: PixelCanvas, _ g: Int) -> (sea: Int, cx: Int, plinth: Int, top: Int, hw: Int,
                                                                     head: Int, clock: (x: Int, y: Int, r: Int)) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w * 44 / 100
        if tall { return (g - 70 * s, cx, g - 26 * s, g - 206 * s, 32 * s, 32 * s, (cx, g - 150 * s, 20 * s)) }
        return (g - 28 * s, cx, g - 8 * s, 13 * s, 13 * s, 8 * s, (cx, 21 * s, 6 * s))
    }

    /// A ship riding at anchor: a dark hull with a gold stripe, two masts with square cream sails, all leaning by
    /// `tilt` (pixels across per pixel up) as it rocks, its waterline on `base`; `k` is its size.
    private static func hkShip(_ c: PixelCanvas, x: Int, base: Int, k: Int, tilt: Double, hull: Px) {
        let hullH = 4 * k, len = 26 * k
        for r in 0..<hullH {
            let y = base - r
            let inset = (hullH - r) * k / 2
            let lean = Int(tilt * Double(r))
            c.rect(x + inset + lean - (r > hullH - 2 ? 2 * k : 0), y, len - inset * 2 + (r > hullH - 2 ? 4 * k : 0), 1, hull)
        }
        c.rect(x + Int(tilt * Double(hullH)), base - hullH + k, len, max(1, k / 2), C(0xD8A83A))
        for (m, h) in [(x + 8 * k, 18 * k), (x + 18 * k, 14 * k)] {
            let foot = Double(base - hullH)
            let topX = Double(m) + tilt * Double(h), topY = foot - Double(h)
            hkLine(c, Double(m), foot, topX, topY, C(0x3A2818), Double(k) * 0.5)
            for sail in 0..<2 {
                let sy = Int(topY) + 2 * k + sail * (h / 2 - k)
                let sh = h / 2 - 3 * k
                for r in 0..<sh {
                    let lean = Int(tilt * Double(base - hullH - (sy + r)))
                    let w = 8 * k + (sail == 1 ? 2 * k : 0)
                    c.rect(m + lean - w / 2, sy + r, w, 1, r == 0 ? C(0xC8B890) : C(0xF0E6CC))
                }
            }
        }
    }

    /// A row of crooked Pirate Town houses from `x0` to `x1`: painted timber fronts in faded bright colours, each one
    /// a different height, with an overhanging upper storey, shuttered windows and a roof.
    private static func hkHouses(_ c: PixelCanvas, x0: Int, x1: Int, g: Int, maxH: Int, s: Int, seed: Int) {
        let fronts: [UInt32] = [0xC88A3A, 0x3A7A7A, 0xA83A2A, 0xD8C49A, 0x5A6A9A]
        var x = x0
        var k = 0
        while x < x1 {
            let w = min(x1 - x, (26 + Int(noise(seed + k * 3) * 16)) * s)
            let h = maxH * 3 / 5 + Int(noise(seed + k * 3 + 1) * Double(maxH * 2 / 5))
            let col = C(fronts[(k + seed) % fronts.count])
            let top = g - h
            c.rect(x, top, w, h, col)
            c.rect(x, top, s, h, col.alpha(0.6))
            for pl in stride(from: top + 3 * s, to: g, by: 3 * s) { c.rect(x, pl, w, 1, C(0x2A1A10, 0.18)) }
            let over = top + h / 2
            c.rect(x - s, over, w + 2 * s, 2 * s, C(0x4A3020))
            for wy in [top + 4 * s, over + 5 * s] where wy + 5 * s < g - 8 * s {
                for wx in stride(from: x + 4 * s, to: x + w - 6 * s, by: 10 * s) {
                    c.rect(wx, wy, 4 * s, 5 * s, C(0x2A1A10)); c.rect(wx + s, wy + s, 2 * s, 3 * s, C(0xF4C860, 0.7))
                    c.rect(wx - 2 * s, wy, 2 * s, 5 * s, C(0x4A6A3A)); c.rect(wx + 4 * s, wy, 2 * s, 5 * s, C(0x4A6A3A))
                }
            }
            // The roof: a dark peak or a slant.
            let roof = C(0x5A3A2A)
            for i in 0..<(w / 2 + s) {
                let lean = k % 2 == 0 ? i / 2 : i / 3
                c.rect(x - s + i, top - lean - s, max(1, w + 2 * s - 2 * i), 1, roof)
                if w + 2 * s - 2 * i <= 1 { break }
            }
            c.rect(x + w / 2 - 2 * s, g - 9 * s, 5 * s, 9 * s, C(0x3A2416))   // the door
            x += w + s; k += 1
        }
    }

    /// Pirate Town on the waterfront: a warm afternoon sky over the harbour, crooked painted houses crowding both
    /// sides of the quay, and in the square the stuffed crocodile stood on its tail as the clock tower, jaws gaping
    /// at the sky and the clock set in its belly. Barrels, rope and a lamp post on the planks. Ships and gulls are in
    /// the moving layer. On the screen saver the crocodile towers over the dock, the town stacked up behind.
    static func pirateTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hkTownFrame(c, g)
        c.gradient(0, f.sea, C(0x7AB8DA), C(0xF6DCA8), bands: 6)
        c.circle(c.w * 80 / 100, f.sea - (tall ? 50 : 12) * s, (tall ? 14 : 6) * s, C(0xFFF0C0, 0.8))
        // The sea.
        c.gradient(f.sea, g, C(0x4A9AA8), C(0x2A6A7A), bands: 4)
        c.rect(0, f.sea, c.w, s, C(0xC8E4E0))
        for i in 0..<(tall ? 60 : 24) {
            let wx = Int(noise(i + 4000) * Double(c.w)), wy = f.sea + 2 * s + Int(noise(i + 4010) * Double(g - f.sea - 2 * s))
            c.rect(wx, wy, (3 + Int(noise(i + 4020) * 4)) * s, s, C(0xA8E0E0, 0.6))
        }
        if tall {
            // The town climbing the hill behind the harbour.
            c.dunes(base: f.sea - 30 * s, amp: Double(14 * s), freq: 0.02, phase: 0.4, bottom: f.sea, C(0x8AA86A))
            for i in 0..<24 {
                let hx = Int(noise(i + 4100) * Double(c.w)), hy = f.sea - Int(noise(i + 4110) * 34) * s
                let col = [C(0xC88A3A), C(0xD8C49A), C(0xA83A2A), C(0x5A6A9A)][i % 4]
                c.rect(hx, hy - 6 * s, 9 * s, 7 * s, col); c.rect(hx - s, hy - 8 * s, 11 * s, 2 * s, C(0x5A3A2A))
                c.rect(hx + 3 * s, hy - 4 * s, 2 * s, 2 * s, C(0x2A1A10))
            }
        }
        // The houses either side.
        let maxH = (tall ? 150 : 50) * s
        hkHouses(c, x0: 0, x1: c.w * 24 / 100, g: g, maxH: maxH, s: s, seed: 1)
        hkHouses(c, x0: c.w * 70 / 100, x1: c.w, g: g, maxH: maxH, s: s, seed: 4)
        // The crocodile clock tower: the plinth, the tail curled round it, the body, belly scutes, arms, head.
        let plinthW = f.hw * 2 + 10 * s
        c.rect(f.cx - plinthW / 2, f.plinth, plinthW, g - f.plinth, C(0x6A4A30))
        c.rect(f.cx - plinthW / 2, f.plinth, plinthW, s, C(0xA8784A))
        let green = C(0x4A7A3A), dark = C(0x2E5A2A), belly = C(0xB8C07A)
        for i in 0..<(f.hw * 3) {   // the tail along the plinth
            let tx = f.cx + f.hw / 2 + i
            let th = max(s, (f.hw * 3 - i) / 6)
            c.rect(tx, f.plinth - th, 1, th, green)
            if i % (3 * s) == 0 { c.rect(tx, f.plinth - th - s, s, s, dark) }
        }
        let bodyH = f.plinth - f.top
        for y in f.top..<f.plinth {
            let k = Double(y - f.top) / Double(max(1, bodyH))
            let hw = Int(Double(f.hw) * (0.7 + 0.3 * sin(k * .pi * 0.9 + 0.2)))
            c.rect(f.cx - hw, y, hw * 2, 1, green)
            c.rect(f.cx - hw, y, s, 1, dark); c.rect(f.cx + hw - s, y, s, 1, dark)
            let bw = hw * 3 / 5
            c.rect(f.cx - bw, y, bw * 2, 1, (y - f.top) % (3 * s) == 0 ? C(0x8A9A5A) : belly)
            if (y / s) % 4 == 0 {   // the ridged back showing at the edges
                c.rect(f.cx - hw - s, y, s, s, dark); c.rect(f.cx + hw, y, s, s, dark)
            }
        }
        // The hind feet on the plinth and the little arms either side of the clock.
        c.rect(f.cx - f.hw - 2 * s, f.plinth - 3 * s, 6 * s, 3 * s, green); c.rect(f.cx + f.hw - 4 * s, f.plinth - 3 * s, 6 * s, 3 * s, green)
        let ck = f.clock
        for side in [-1, 1] {
            let ax = Double(f.cx + side * (f.hw - s)), ay = Double(ck.y - ck.r / 2)
            hkLine(c, ax, ay, ax + Double(side * 4 * s), ay + Double(ck.r), green, Double(s) * 1.2)
            c.rect(Int(ax) + side * 4 * s - s, Int(ay) + ck.r, 3 * s, s, C(0xF0EAD0))
        }
        // The head: thrown back, the long jaws gaping at the sky with the pink mouth between them, teeth along
        // both, nostrils on the snout's tip and an eye bulging either side.
        let hx = f.cx, hy = f.top
        let jawLen = f.head * 3 / 2
        let white = C(0xF4F0E0)
        c.ellipse(hx - f.hw / 6, hy - jawLen / 3, f.hw / 2, jawLen / 3, C(0xC85A64))
        for i in 0..<jawLen {   // the upper jaw, up and to the right
            let k = Double(i) / Double(jawLen)
            let w = max(2 * s, Int(Double(f.hw) * (0.95 - 0.5 * k)))
            let x = hx - f.hw / 5 + Int(Double(i) * 0.45)
            c.rect(x, hy - i, w, 1, green); c.rect(x + w - s, hy - i, s, 1, dark)
            if i % (2 * s) == 0 && i > s { c.rect(x - s, hy - i, s, s, white) }
        }
        let tip = (x: hx - f.hw / 5 + Int(Double(jawLen) * 0.45), y: hy - jawLen)
        c.rect(tip.x + s, tip.y - s, 2 * s, s, green); c.rect(tip.x + s, tip.y, s, s, C(0x1A2A14))
        let lowLen = jawLen * 2 / 3
        for i in 0..<lowLen {   // the lower jaw, dropped back up and to the left
            let k = Double(i) / Double(lowLen)
            let w = max(2 * s, Int(Double(f.hw) * (0.75 - 0.4 * k)))
            let x = hx - f.hw / 5 - w - Int(Double(i) * 0.9)
            c.rect(x, hy - i, w, 1, green); c.rect(x, hy - i, s, 1, dark)
            if i % (2 * s) == 0 && i > s { c.rect(x + w, hy - i, s, s, white) }
        }
        for side in [-1, 1] {   // the eyes
            let ex = hx + side * (f.hw * 3 / 4)
            c.ellipse(ex, hy + s, max(2 * s, f.hw / 4), max(s, f.hw / 6), green)
            c.rect(ex - s, hy, 2 * s, max(s, f.hw / 8), C(0xF0D04A)); c.rect(ex, hy, s, max(s, f.hw / 8), C(0x1A1A10))
        }
        // The clock in its belly: brass rim, cream face, hour ticks (the hands are in the moving layer).
        c.circle(ck.x, ck.y, ck.r + 2 * s, C(0x8A6A2A)); c.circle(ck.x, ck.y, ck.r + s, C(0xD8A83A))
        c.circle(ck.x, ck.y, ck.r, C(0xF4ECD0))
        for h in 0..<12 {
            let a = Double(h) / 12 * 2 * .pi
            let rr = Double(ck.r - s)
            c.rect(ck.x + Int(sin(a) * rr), ck.y - Int(cos(a) * rr), s, s, C(0x2A2018))
        }
        // The quay: planks, barrels, a coil of rope, a lamp post.
        c.ground(g, C(0x7A5A3A), edge: C(0xB08A5A), speck: C(0x6A4A2E), seed: 41)
        for y in stride(from: g + 3, to: c.h, by: 3) { c.rect(0, y, c.w, 1, C(0x5A402A)) }
        for bx in [c.w * 26 / 100, c.w * 28 / 100, c.w * 66 / 100] {
            c.rect(bx, g - 8 * s, 7 * s, 8 * s, C(0x8A5A2E)); c.rect(bx, g - 7 * s, 7 * s, s, C(0x3A3A3A))
            c.rect(bx, g - 2 * s, 7 * s, s, C(0x3A3A3A)); c.rect(bx + s, g - 8 * s, 5 * s, s, C(0xA87A44))
        }
        c.ellipse(c.w * 63 / 100, g - s, 5 * s, 2 * s, C(0xC8A870)); c.ellipse(c.w * 63 / 100, g - s, 2 * s, s, C(0x7A5A3A))
        let lp = c.w * 58 / 100, lpTop = g - (tall ? 70 : 34) * s
        c.rect(lp, lpTop, 2 * s, g - lpTop, C(0x2A2420)); c.rect(lp - 2 * s, lpTop - 5 * s, 6 * s, 5 * s, C(0x2A2420))
        c.rect(lp - s, lpTop - 4 * s, 4 * s, 3 * s, C(0xF8D878))
    }

    /// What moves in Pirate Town: the clock's hands ticking round (the second hand jumping once a second), two ships
    /// rocking at anchor in the harbour, gulls wheeling over the roofs, and the sun glinting off the water.
    static func pirateTownLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = hkTownFrame(c, g)
        // The ships, out in the harbour behind the quay.
        let k = tall ? 3 * s : s
        let ships: [(x: Int, ph: Double, hull: UInt32)] = [(c.w * 27 / 100, 0, 0x3A2418), (c.w * 55 / 100, 1.7, 0x4A1A1A)]
        for sh in ships {
            let tilt = sin(t * 1.1 + sh.ph) * 0.12
            let bob = Int((sin(t * 1.4 + sh.ph) * Double(s)).rounded())
            hkShip(c, x: sh.x, base: g - (tall ? 6 : 3) * s + bob, k: k, tilt: tilt, hull: C(sh.hull))
        }
        // The water glinting.
        for i in 0..<(tall ? 12 : 6) {
            let on = noise(i * 13 + Int(t * 2)) > 0.5
            if on {
                let wx = Int(noise(i + 4200) * Double(c.w)), wy = f.sea + 2 * s + Int(noise(i + 4210) * Double(g - f.sea - 4 * s))
                c.rect(wx, wy, 2 * s, s, C(0xFFFFF0, 0.9))
            }
        }
        // The clock's hands.
        let ck = f.clock
        let sec = floor(t).truncatingRemainder(dividingBy: 60)
        let minute = (t / 60 + 22).truncatingRemainder(dividingBy: 60)
        let hour = 10 + minute / 60
        let hands: [(Double, Double, Double, Px)] = [
            (hour / 12, 0.5, 0.8, C(0x1A1410)), (minute / 60, 0.8, 0.6, C(0x1A1410)), (sec / 60, 0.9, 0.4, C(0xB02A1A)),
        ]
        for h in hands {
            let a = h.0 * 2 * .pi
            let len = Double(ck.r) * h.1
            let ex = Double(ck.x) + 0.5 + sin(a) * len, ey = Double(ck.y) + 0.5 - cos(a) * len
            c.glowLine(Double(ck.x) + 0.5, Double(ck.y) + 0.5, ex, ey, core: h.3, glow: C(0, 0),
                       coreR: Double(s) * h.2, glowR: Double(s) * h.2 + 0.01)
        }
        c.rect(ck.x, ck.y, s, s, C(0xD8A83A))
        // The gulls.
        for i in 0..<(tall ? 6 : 4) {
            let span = Double(c.w + 60)
            let speed = 14 + noise(i + 4300) * 12
            let x = Int((noise(i + 4310) * span + t * speed).truncatingRemainder(dividingBy: span)) - 30
            let y = Int(noise(i + 4320) * Double(tall ? g / 2 : 14 * s)) + 2 * s + Int(sin(t * 0.9 + Double(i)) * Double(2 * s))
            let flap = Int(t * 6 + Double(i)) % 2 == 0
            let wy = flap ? -s : s
            c.rect(x, y, s, s, C(0xF8F8F4))
            c.rect(x - s, y + (flap ? -s : 0), s, s, C(0xF8F8F4)); c.rect(x + s, y + (flap ? -s : 0), s, s, C(0xF8F8F4))
            c.rect(x - 2 * s, y + wy, s, s, C(0x3A3A3A)); c.rect(x + 2 * s, y + wy, s, s, C(0x3A3A3A))
        }
    }
}

// MARK: - The Jolly Roger

extension Scenes {
    private typealias HkDeck = (sea: Int, rail: Int, masts: [Int], mw: Int, yards: [Int], quarter: (x: Int, top: Int),
                                wheel: (x: Int, y: Int, r: Int), lanterns: [(Int, Int)])

    /// Where things are on Captain Clawk's deck: the horizon, the bulwark's top, the masts' x and width, the yards'
    /// rows, the quarterdeck's left edge and top, the wheel, and where the lanterns hang.
    private static func hkDeckFrame(_ c: PixelCanvas, _ g: Int) -> HkDeck {
        let s = unit(g), tall = isTall(c)
        let masts = [c.w * 16 / 100, c.w * 52 / 100]
        let qx = c.w * (tall ? 80 : 82) / 100, wx = qx + (c.w - qx) / 2
        if tall {
            let yards = [g - 218 * s, g - 162 * s, g - 106 * s], qt = g - 30 * s
            return (g - 52 * s, g - 22 * s, masts, 8 * s, yards, (qx, qt), (wx, qt - 34 * s, 14 * s),
                    [(masts[0] + 30 * s, g - 104 * s), (masts[1] - 34 * s, g - 104 * s), (masts[1] + 40 * s, g - 104 * s),
                     (c.w * 96 / 100 - 8 * s, g - 76 * s)])
        }
        let qt = g - 20 * s
        return (g - 27 * s, g - 16 * s, masts, 5 * s, [-8 * s, 10 * s], (qx, qt), (wx, qt - 19 * s, 9 * s),
                [(masts[0] + 24 * s, 12 * s), (masts[1] - 26 * s, 12 * s), (masts[1] + 26 * s, 12 * s)])
    }

    /// The shrouds: rope ladders from each mast down to the bulwark either side, four lines a side with the ratlines
    /// across them and a deadeye at each foot.
    private static func hkShrouds(_ c: PixelCanvas, _ g: Int, f: HkDeck, s: Int) {
        let rope = C(0x2A1A14), top = max(0, f.yards[f.yards.count - 1] + 2 * s)
        let spread = (f.rail - top) * 3 / 10
        for m in f.masts {
            for side in [-1, 1] {
                let feet = (0..<4).map { m + side * (spread + $0 * 4 * s) }
                for x in feet {
                    hkLine(c, Double(m), Double(top), Double(x), Double(f.rail), rope, 0.5)
                    c.rect(x - s, f.rail - 2 * s, 2 * s + 1, 2 * s, C(0x1A100C))
                }
                for y in stride(from: top + 6 * s, to: f.rail - 2 * s, by: 3 * s) {
                    let k = Double(y - top) / Double(f.rail - top)
                    let a = m + Int(Double(feet[0] - m) * k), b = m + Int(Double(feet[3] - m) * k)
                    c.rect(min(a, b), y, abs(b - a) + 1, 1, C(0x3A2A1E, 0.9))
                }
            }
        }
    }

    /// A sail set and drawing: cream canvas bellied out by the wind, its sides bowed and its foot curved, the cloth
    /// panels running down it, warm sunset light on it and shadow in the belly, the bolt rope round the edge and a
    /// patch or two sewn on.
    private static func hkSail(_ c: PixelCanvas, m: Int, y: Int, half: Int, h: Int, s: Int, seed: Int) {
        let bow = Double(3 * s), sag = Double(4 * s)
        for r in 0..<(h + Int(sag)) {
            let q = Double(r) / Double(h)
            let hw = half - s + Int(sin(min(1, q) * .pi) * bow)
            for dx in -hw...hw {
                let u = Double(dx + hw) / Double(2 * hw)
                let foot = h + Int(sin(u * .pi) * sag)
                guard r < foot else { continue }
                let rim = abs(dx) == hw || r >= foot - s
                var col = q < 0.35 ? C(0xF6E8CC) : (q < 0.75 ? C(0xEAD4AC) : C(0xD8B88C))
                if (dx + hw) % (6 * s) == 0 { col = C(0xD0B48A) }
                c.rect(m + dx, y + r, 1, 1, rim ? C(0xA8845A) : col)
                if u > 0.6 && !rim { c.rect(m + dx, y + r, 1, 1, C(0xB8805A, (u - 0.6) * 0.8)) }
            }
        }
        for p in 0..<2 {
            let px = m - half / 2 + Int(noise(seed + p) * Double(half)), py = y + h / 4 + p * h / 3
            c.rect(px, py, 6 * s, 4 * s, C(0xC8A87A))
            for k in 0..<3 { c.rect(px + k * 2 * s, py, s, s, C(0x8A6A48)); c.rect(px + k * 2 * s + s, py + 3 * s, s, s, C(0x8A6A48)) }
        }
        // The yard it hangs from: tapered to the yardarms.
        c.rect(m - half - 3 * s, y - 2 * s, 2 * half + 6 * s, 2 * s, C(0x4A3020))
        c.rect(m - half + 4 * s, y - 2 * s, 2 * half - 8 * s, s, C(0x7A5232))
    }

    /// The Jolly Roger at sunset: a violet-to-orange sky with the sun going down into a purple sea, two masts with
    /// their yards and patched sails billowing, the shrouds and ratlines running down to the bulwark, lantern hooks on
    /// the yards, the bulwark of planks under a scarlet strake with its gun ports open on the sea and the cannons on
    /// their carriages, and Captain Clawk's raised quarterdeck with its gilded balustrade and the big ship's wheel.
    /// The deck's planks underfoot. On the screen saver the masts climb high, sail over sail, with the crow's nest
    /// on the mainmast (the flag flies in the moving layer).
    static func jollyRoger(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = hkDeckFrame(c, g)
        c.gradient(0, f.sea, C(0x2E1C4A), C(0xF29A4A), bands: 8)
        let sunY = f.sea - (tall ? 30 : 9) * s
        c.circle(c.w * 34 / 100, sunY, (tall ? 26 : 12) * s, C(0xFFC87A, 0.25))
        c.circle(c.w * 34 / 100, sunY, (tall ? 18 : 7) * s, C(0xFFD27A))
        for i in 0..<(tall ? 6 : 3) {
            let wx = Int(noise(i + 5000) * Double(c.w)), wy = sunY - Int(noise(i + 5010) * Double((tall ? 120 : 20) * s))
            wisp(c, wx, wy, (40 + Int(noise(i + 5020) * 50)) * s, C(0xF8B8A0, 0.5), s: s)
        }
        // The sea down to the rail.
        c.gradient(f.sea, f.rail, C(0x5A3A6A), C(0x2A1E4A), bands: 3)
        c.rect(c.w * 34 / 100 - (tall ? 22 : 8) * s, f.sea, (tall ? 44 : 16) * s, s, C(0xFFC87A, 0.8))
        for i in 0..<(tall ? 20 : 8) {
            let wx = c.w * 34 / 100 + Int((noise(i + 5100) - 0.5) * Double((tall ? 60 : 30) * s))
            let wy = f.sea + 2 * s + Int(noise(i + 5110) * Double(f.rail - f.sea - 2 * s))
            c.rect(wx, wy, (2 + Int(noise(i + 5120) * 4)) * s, s, C(0xF8A85A, 0.6))
        }
        // The masts, yards and sails, the sheets from the sails' corners down to the rail.
        for (mi, m) in f.masts.enumerated() {
            c.rect(m - f.mw / 2, 0, f.mw, f.rail, C(0x5A3A22))
            c.rect(m - f.mw / 2 + s, 0, s, f.rail, C(0x8A5E36)); c.rect(m + f.mw / 2 - s, 0, s, f.rail, C(0x3A2416))
            for by in stride(from: 6 * s, to: f.rail, by: (tall ? 24 : 12) * s) { c.rect(m - f.mw / 2, by, f.mw, s, C(0x2A1A10)) }
            for (yi, y) in f.yards.enumerated() {
                let half = (tall ? 54 - yi * 6 : 34 - yi * 4) * s
                let last = yi == f.yards.count - 1
                let sh = (last ? (tall ? 40 : 18) : (tall ? 50 : 12)) * s
                hkSail(c, m: m, y: y + 2 * s, half: half, h: sh, s: s, seed: mi * 10 + yi + 5200)
                guard last else { continue }
                for d in [-1, 1] {
                    let cx = Double(m + d * (half - s)), cy = Double(y + 2 * s + sh)
                    hkLine(c, cx, cy, cx + Double(d * 10 * s), Double(f.rail), C(0x3A2A1E), 0.5)
                }
            }
            if tall && mi == 1 {
                // The crow's nest.
                c.rect(m - 12 * s, f.yards[0] - 30 * s, 24 * s, 10 * s, C(0x6A4428))
                c.rect(m - 12 * s, f.yards[0] - 30 * s, 24 * s, 2 * s, C(0xD8A83A))
            }
        }
        hkShrouds(c, g, f: f, s: s)
        for l in f.lanterns { c.rect(l.0, l.1, s, 3 * s, C(0x2A1A14)) }
        hkBulwark(c, g, f)
        hkQuarterdeck(c, g, f)
        // The deck: planks running along, their butts staggered, tar in the seams.
        c.ground(g, C(0x7A5434), edge: C(0x3A2416), speck: C(0x6A4628), seed: 71)
        for (i, y) in stride(from: g + 2 * s, to: c.h, by: 3 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x4A3020))
            for x in stride(from: (i * 23 % 47) * s, to: c.w, by: 47 * s) { c.rect(x, y - 2 * s, s, 2 * s, C(0x4A3020)) }
        }
    }

    /// The bulwark from the deck: the cap rail with its gold trim over a scarlet strake, planks below with the frames
    /// standing up through them, and the gun ports open on the sea with a cannon run out through each on its carriage.
    private static func hkBulwark(_ c: PixelCanvas, _ g: Int, _ f: HkDeck) {
        let s = unit(g), tall = isTall(c), r = f.rail, end = f.quarter.x
        c.rect(0, r, end, g - r, C(0x6A4428))
        for y in stride(from: r + 6 * s, to: g, by: 3 * s) { c.rect(0, y, end, s, C(0x4A2E1A)) }
        c.rect(0, r + 2 * s, end, 4 * s, C(0x9A2A22)); c.rect(0, r + 5 * s, end, s, C(0x5A1A14))
        c.rect(0, r, end, 2 * s, C(0x8A5A30)); c.rect(0, r, end, s, C(0xD8A83A))
        for x in stride(from: 10 * s, to: end, by: 30 * s) { c.rect(x, r + 2 * s, 2 * s, g - r - 2 * s, C(0x4A2E1A)) }
        let ph = (tall ? 9 : 6) * s, pw = (tall ? 12 : 9) * s, py = r + 7 * s
        for gx in stride(from: 22 * s, to: end - pw, by: 46 * s) {
            c.rect(gx - s, py - s, pw + 2 * s, ph + 2 * s, C(0xD8A83A))
            c.rect(gx, py, pw, ph, C(0x3A2A5A)); c.rect(gx, py, pw, s, C(0x6A4A7A))
            // The cannon: the barrel out through the port, the carriage and its little wheels on the deck.
            let by = py + ph / 2
            c.rect(gx + s, by - s, pw - 2 * s, 3 * s, C(0x1E1E22)); c.rect(gx + s, by - s, pw - 2 * s, s, C(0x5A5A62))
            c.rect(gx - s, by + 2 * s, pw + 2 * s, g - by - 3 * s, C(0x5A3A22))
            c.rect(gx - s, by + 2 * s, pw + 2 * s, s, C(0x8A5E36))
            c.circle(gx + s, g - 2 * s, 2 * s, C(0x2A1A10)); c.circle(gx + pw - s, g - 2 * s, 2 * s, C(0x2A1A10))
        }
    }

    /// The quarterdeck: its front bulkhead with panelled doors, the steps up, the gilded balustrade, and the wheel
    /// on its pedestal standing up against the sky, spokes and handles round the rim and a brass hub.
    private static func hkQuarterdeck(_ c: PixelCanvas, _ g: Int, _ f: HkDeck) {
        let s = unit(g), tall = isTall(c), q = f.quarter, gold = C(0xD8A83A)
        c.rect(q.x, q.top, c.w - q.x, g - q.top, C(0x6A4428))
        for y in stride(from: q.top + 4 * s, to: g, by: 3 * s) { c.rect(q.x, y, c.w - q.x, s, C(0x4A2E1A)) }
        c.rect(q.x, q.top, c.w - q.x, 2 * s, gold)
        let dw = (tall ? 14 : 8) * s
        c.rect(q.x + 10 * s, q.top + 4 * s, dw, g - q.top - 4 * s, C(0x4A2E1A))
        c.rect(q.x + 11 * s, q.top + 5 * s, dw - 2 * s, g - q.top - 6 * s, C(0x7A5232))
        c.rect(q.x + 9 * s + dw, q.top + (g - q.top) / 2, s, s, gold)
        for i in 0..<4 {
            let sw = 4 * s, sy = q.top + i * (g - q.top) / 4
            c.rect(q.x - (i + 1) * sw, sy, sw, g - sy, C(0x5A3A22)); c.rect(q.x - (i + 1) * sw, sy, sw, s, C(0x9A6A3A))
        }
        // The wheel, behind the balustrade.
        let w = f.wheel, wc = C(0x7A4A26)
        c.rect(w.x - s, w.y, 3 * s, q.top - w.y, C(0x4A3020))
        c.rect(w.x - 3 * s, w.y + w.r + 2 * s, 7 * s, q.top - w.y - w.r - 2 * s, C(0x5A3A22))
        for k in 0..<8 {
            let a = Double(k) / 8 * .pi * 2
            let ex = Double(w.x) + cos(a) * Double(w.r + 3 * s), ey = Double(w.y) + sin(a) * Double(w.r + 3 * s)
            hkLine(c, Double(w.x), Double(w.y), ex, ey, wc, Double(s) * 0.6)
            c.rect(Int(ex) - s / 2, Int(ey) - s / 2, s + s / 2 + 1, s + s / 2 + 1, C(0xA86E3A))
        }
        for rr in [w.r, w.r - s] {
            for k in 0..<64 {
                let a = Double(k) / 64 * 2 * .pi
                c.rect(w.x + Int(cos(a) * Double(rr)), w.y + Int(sin(a) * Double(rr)), s, s, rr == w.r ? C(0x9A6236) : wc)
            }
        }
        c.circle(w.x, w.y, 2 * s, gold); c.rect(w.x, w.y, s, s, C(0xFFF0A0))
        let balTop = q.top - (tall ? 14 : 8) * s
        c.rect(q.x, balTop, c.w - q.x, 2 * s, gold)
        for bx in stride(from: q.x, to: c.w, by: 4 * s) {
            c.rect(bx, balTop + 2 * s, 2 * s, q.top - balTop - 2 * s, C(0xB8862A))
            c.rect(bx, balTop + 2 * s + (q.top - balTop) / 2 - s, 2 * s, s, C(0x8A5A1A))
        }
        if tall, let stern = f.lanterns.last {
            // The stern lantern's post with its arm.
            c.rect(stern.0 + 8 * s, stern.1, 2 * s, q.top - stern.1, C(0x4A3020))
            c.rect(stern.0, stern.1, 10 * s, 2 * s, C(0x4A3020))
        }
    }

    /// What moves on the Jolly Roger: the ship rolling (the horizon tilting and rising against the rail, the
    /// lanterns swinging on their hooks), gulls of spray glinting on the sea, and on the screen saver the black
    /// skull-and-crossbones flag streaming from the mainmast.
    static func jollyRogerLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = hkDeckFrame(c, g)
        // The roll: the sea's edge tilting, painted over a band either side of the still horizon.
        let roll = sin(t * 0.9)
        let amp = Double((tall ? 5 : 2) * s)
        let mid = Double(c.w / 2)
        for x in 0..<(f.quarter.x - 16 * s) {
            if f.masts.contains(where: { abs($0 - x) <= f.mw / 2 }) { continue }
            let tilt = (Double(x) - mid) / mid
            let off = Int((roll * amp * 0.6 + tilt * roll * amp).rounded())
            if off < 0 {
                c.rect(x, f.sea + off, 1, -off, C(0x5A3A6A))
            } else if off > 0 {
                c.rect(x, f.sea, 1, off, C(0xF29A4A))
            }
        }
        hkShrouds(c, g, f: f, s: s)
        // The lanterns, swinging against the roll.
        for (i, l) in f.lanterns.enumerated() {
            let a = -roll * 0.35 + sin(t * 2.3 + Double(i)) * 0.06
            let len = Double((tall ? 14 : 7) * s)
            let lx = Double(l.0) + sin(a) * len, ly = Double(l.1 + 3 * s) + cos(a) * len
            hkLine(c, Double(l.0), Double(l.1 + 3 * s), lx, ly, C(0x2A1A14), 0.5)
            let w = (tall ? 6 : 3) * s, h = (tall ? 8 : 4) * s
            c.rect(Int(lx) - w / 2, Int(ly), w, h, C(0x3A2A1A))
            c.rect(Int(lx) - w / 2 + s, Int(ly) + s, w - 2 * s, h - 2 * s, C(0xFFD27A))
            c.glowLine(lx, ly + Double(h / 2), lx + 0.1, ly + Double(h / 2), core: C(0xFFE8A0, 0.3), glow: C(0xFFB84A, 0.25),
                       coreR: Double(s), glowR: Double(h + 2 * s))
        }
        // Glints on the sea.
        for i in 0..<5 where noise(i * 7 + Int(t * 3)) > 0.5 {
            let wx = Int(noise(i + 5300) * Double(c.w)), wy = f.sea + 2 * s + Int(noise(i + 5310) * Double(f.rail - f.sea - 3 * s))
            c.rect(wx, wy, 2 * s, s, C(0xFFD8A0, 0.8))
        }
        guard tall else { return }
        // The flag on the mainmast's top, streaming and rippling.
        let m = f.masts[1], fy = f.yards[0] - 66 * s
        c.rect(m - s, fy, 2 * s, f.yards[0] - 30 * s - fy, C(0x5A3A22))
        let fw = 50 * s, fh = 32 * s
        let flag = PixelCanvas(fw, fh)
        flag.rect(0, 0, fw, fh, C(0x141014))
        let sk: [String] = [
            "...#####...",
            "..#######..",
            "..#.###.#..",
            "..#######..",
            "...##.##...",
            "...#####...",
            "....#.#....",
            "#.........#",
            ".##.....##.",
            "...##.##...",
            ".....#.....",
            "...##.##...",
            ".##.....##.",
            "#.........#",
        ]
        for (ry, row) in sk.enumerated() {
            for (rx, p) in row.enumerated() where p == "#" {
                flag.rect(fw / 2 - 11 * s + rx * 2 * s, 2 * s + ry * 2 * s, 2 * s, 2 * s, C(0xF0ECE0))
            }
        }
        for x in 0..<fw {
            let wave = sin(Double(x) * 0.18 - t * 5) * Double(2 * s) * Double(x) / Double(fw)
            for y in 0..<fh {
                let i = (y * fw + x) * 4
                let a = flag.buf[i + 3]
                guard a > 0 else { continue }
                let col = Px(r: flag.buf[i], g: flag.buf[i + 1], b: flag.buf[i + 2], a: a)
                let shade = sin(Double(x) * 0.18 - t * 5) > 0.6 ? 0.85 : 1.0
                c.px(m + s + x, fy + y + Int(wave), Px(r: UInt8(Double(col.r) * shade), g: UInt8(Double(col.g) * shade),
                                                         b: UInt8(Double(col.b) * shade), a: 255))
            }
        }
    }
}
