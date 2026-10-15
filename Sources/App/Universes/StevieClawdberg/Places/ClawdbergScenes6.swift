import Foundation

// The Goonies: the Goondocks and the Inferno. The Goondocks are the Oregon coast at Astoria, grey sky, the big sea
// stack and the lighthouse; the Inferno is One-Eyed Willy's ship in its hidden cove under the rocks.

let clawdbergScenes6: [Location: Place] = [
    .goondocks: Place(name: "The Goondocks", panel: 0x16202A, still: Scenes.goondocks, moving: Scenes.goondocksLife),
    .inferno: Place(name: "The Inferno", panel: 0x1A120C, still: Scenes.inferno, moving: Scenes.infernoLife),
]

// MARK: - The Goondocks

extension Scenes {
    /// Where things stand on the coast: the sea's horizon, the headland's top and right edge, the lighthouse's foot
    /// and lantern, and the big sea stack (middle, half width, height).
    private static func gnDocksFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, cliff: (top: Int, right: Int),
                                                                      light: (x: Int, base: Int, lamp: Int),
                                                                      stack: (x: Int, hw: Int, h: Int)) {
        let s = unit(g), tall = isTall(c)
        let horizon = g - (tall ? 46 : 26) * s
        let cliffTop = g - (tall ? 40 : 22) * s, cliffRight = c.w * (tall ? 30 : 22) / 100
        let lx = c.w * (tall ? 18 : 11) / 100
        let lamp = cliffTop - (tall ? 40 : 28) * s
        let stack = (x: c.w * 72 / 100, hw: (tall ? 48 : 30) * s, h: (tall ? 84 : 52) * s)
        return (horizon, (cliffTop, cliffRight), (lx, cliffTop, lamp), stack)
    }

    /// A clapboard house on the hill: a painted front, a steep gable, a white-trimmed window or two, lit or not.
    private static func gnHouse(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, s: Int, k: Int) {
        let paints = [C(0x7A8C9A), C(0xB8A47A), C(0x8A5A4A), C(0x6A7A5A), C(0xC8C0B0), C(0x5A6A82)]
        let col = paints[k % paints.count]
        c.rect(x, base - h, w, h, col)
        c.rect(x, base - h, s, h, C(0xFFFFFF, 0.12))
        let peak = w / 2 + s
        for i in 0..<peak {
            c.rect(x + w / 2 - i, base - h - peak + i, 2 * i + s, 1, C(0x3A3A40))
        }
        for wy in stride(from: base - h + 3 * s, to: base - 4 * s, by: 7 * s) {
            for wx in stride(from: x + 2 * s, to: x + w - 4 * s, by: 6 * s) {
                c.rect(wx - s / 2, wy - s / 2, 3 * s + s / 2 + 1, 4 * s + 1, C(0xE8E4DC))
                let lit = noise(wx * 3 + wy + k) > 0.6
                c.rect(wx, wy, 3 * s, 4 * s, lit ? C(0xF0D49A) : C(0x2A323C))
            }
        }
    }

    /// The Goondocks: the Oregon coast under a low grey sky, the Pacific grey-green to the horizon, the great sea
    /// stack standing in the surf with gulls' white streaking its face and the little needles beside it, a grassy
    /// headland on the left with the white lighthouse and its black lantern, dark rocks along the tide line and wet
    /// sand underfoot. On the screen saver the hill climbs behind with the town's clapboard houses stacked up it, the
    /// old restaurant out on the point under the lighthouse, and the long bridge on the horizon.
    static func goondocks(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = gnDocksFrame(c, g)
        c.gradient(0, f.horizon, C(0x5C6C7C), C(0xB8C2C4), bands: tall ? 10 : 6)
        // Low cloud in long grey bands.
        for i in 0..<(tall ? 22 : 8) {
            let x = Int(noise(i * 4 + 1101) * Double(c.w)), y = Int(noise(i * 4 + 1102) * Double(f.horizon * 2 / 3))
            c.ellipse(x, y, (40 + Int(noise(i * 4 + 1103) * 60)) * s, (2 + Int(noise(i * 4 + 1104) * 4)) * s,
                      C(0x8A96A2, 0.45))
        }
        if tall { gnTown(c, g, s, f.horizon) }
        // The sea, banded darker towards the shore.
        c.gradient(f.horizon, g, C(0x6A8A8C), C(0x2E5258), bands: tall ? 8 : 5)
        c.rect(0, f.horizon, c.w, s, C(0xC8D2D0, 0.6))
        for i in 0..<(tall ? 40 : 18) {
            let x = Int(noise(i * 3 + 1201) * Double(c.w))
            let y = f.horizon + 2 * s + Int(noise(i * 3 + 1202) * Double(g - f.horizon - 4 * s))
            c.rect(x, y, (6 + Int(noise(i * 3 + 1203) * 12)) * s, s, C(0xDDE6E2, 0.25))
        }
        // The sea stack and the needles beside it.
        gnStack(c, x: f.stack.x, hw: f.stack.hw, h: f.stack.h, base: g - 3 * s, s: s)
        gnStack(c, x: f.stack.x + f.stack.hw + 12 * s, hw: f.stack.hw / 5, h: f.stack.h * 2 / 5, base: g - 2 * s, s: s)
        gnStack(c, x: f.stack.x + f.stack.hw + 24 * s, hw: f.stack.hw / 7, h: f.stack.h / 4, base: g - 2 * s, s: s)
        // The headland: dark basalt with a grassy top, and the lighthouse on it.
        for x in 0..<f.cliff.right {
            let edge = max(0, x - (f.cliff.right - 18 * s))
            let top = f.cliff.top + edge * edge / max(1, 6 * s) + Int(noise(x / max(1, s) + 1300) * 2) * s
            if top < g {
                c.rect(x, top, 1, g - top, x % (3 * s) == 0 ? C(0x2A2C2A) : C(0x34363A))
                c.rect(x, top, 1, 2 * s, C(0x5A7040))
            }
        }
        let lt = f.light
        let tw = (isTall(c) ? 9 : 7) * s
        for y in lt.lamp..<lt.base {
            let k = Double(y - lt.lamp) / Double(max(1, lt.base - lt.lamp))
            let hw = Int(Double(tw) / 2 * (0.75 + 0.35 * k))
            c.rect(lt.x - hw, y, hw * 2 + s, 1, C(0xECEAE2))
            c.rect(lt.x + hw - s, y, 2 * s, 1, C(0xB8B6AE))
        }
        c.rect(lt.x - tw / 2 - s, lt.lamp, tw + 3 * s, s, C(0x1E2024))
        c.rect(lt.x - tw / 3, lt.lamp - 4 * s, tw * 2 / 3 + s, 4 * s, C(0xF6E8A8))
        for wx in stride(from: lt.x - tw / 3, through: lt.x + tw / 3, by: 2 * s) { c.rect(wx, lt.lamp - 4 * s, s / 2 + 1, 4 * s, C(0x1E2024)) }
        c.rect(lt.x - tw / 2, lt.lamp - 6 * s, tw + s, 2 * s, C(0x1E2024))
        c.rect(lt.x, lt.lamp - 8 * s, s, 2 * s, C(0x1E2024))
        c.rect(lt.x - s, lt.base - 4 * s, 2 * s, 4 * s, C(0x3A2A20))
        // Rocks along the tide line, low, and the wet sand.
        c.ground(g, C(0x6A6452), edge: C(0xD8DCD0), speck: C(0x7A7462), seed: 61)
        for i in 0..<(c.w / (26 * s)) {
            let x = Int(noise(i + 1400) * Double(c.w)), r = (3 + Int(noise(i + 1410) * 4)) * s
            c.ellipse(x, g - s, r, r / 2 + s, C(0x2A2C2E)); c.rect(x - r / 2, g - r / 2 - s, r, s, C(0x4A4C4E))
        }
        if g + 3 * s < c.h { c.rect(0, g + 2 * s, c.w, s, C(0x5A5444)) }
    }

    /// A sea stack: a rugged dome of dark basalt, steep on the seaward side, a cap of green on top and white streaks
    /// from the birds down its face.
    private static func gnStack(_ c: PixelCanvas, x: Int, hw: Int, h: Int, base: Int, s: Int) {
        for dx in -hw...hw {
            let u = Double(dx) / Double(hw)
            let lean = u < 0 ? pow(-u, 2.2) : pow(u, 3.2)
            let rug = Int(noise(dx / max(1, s) + x + 1500) * 3) * s
            let top = base - Int(Double(h) * (1 - lean)) + rug
            guard top < base else { continue }
            let shade = dx < -hw / 3 ? C(0x2E3032) : (dx > hw / 2 ? C(0x1E2022) : C(0x262829))
            c.rect(x + dx, top, 1, base - top, shade)
            if abs(dx) < hw * 2 / 3 { c.rect(x + dx, top, 1, 2 * s, C(0x4E6234)) }
            if (dx / max(1, s)) % 7 == 0 && abs(dx) < hw * 3 / 4 {
                let len = Int(noise(dx + 1520) * Double(h) * 0.4)
                c.rect(x + dx, top + 3 * s, 1, len, C(0xE8E8E0, 0.35))
            }
        }
        c.rect(x - hw, base - s, 2 * hw, s, C(0xE8F0EC, 0.6))
    }

    /// The town on the screen saver: the hill on the left with clapboard houses stacked up it among dark firs, the
    /// old restaurant out on the point (where the counterfeiters hide), and the long bridge across the river mouth on
    /// the horizon.
    private static func gnTown(_ c: PixelCanvas, _ g: Int, _ s: Int, _ horizon: Int) {
        // The bridge, far away: a long low deck with the high truss over the shipping channel.
        let by = horizon - 3 * s, bx0 = c.w * 40 / 100, bx1 = c.w * 98 / 100
        c.rect(bx0, by, bx1 - bx0, s, C(0x6A7680))
        for x in stride(from: bx0, to: bx1, by: 8 * s) { c.rect(x, by, s, 3 * s, C(0x6A7680)) }
        let tx = c.w * 82 / 100
        for i in 0..<(14 * s) {
            let up = i < 7 * s ? i : 14 * s - i
            c.rect(tx + i * 2, by - up, 2, up, C(0x6A7680, 0.8))
        }
        // The hill, rising from the right down to the headland on the left.
        let hillRight = c.w * 46 / 100
        for x in 0..<hillRight {
            let k = Double(x) / Double(hillRight)
            let top = g / 6 + Int(pow(k, 1.6) * Double(horizon - g / 6)) + Int(sin(Double(x) / Double(17 * s)) * Double(3 * s))
            c.rect(x, top, 1, horizon + 6 * s - top, C(0x3A4A3C))
            c.rect(x, top, 1, s, C(0x5A6A50))
        }
        // Houses up the hill, firs among them.
        var k = 0
        for row in 0..<6 {
            let y = g / 6 + 20 * s + row * (horizon - g / 6 - 20 * s) / 6
            var x = 4 * s + row * 5 * s
            while x < hillRight - 20 * s {
                let k1 = Double(x) / Double(hillRight)
                let top = g / 6 + Int(pow(k1, 1.6) * Double(horizon - g / 6))
                if y > top + 10 * s {
                    if noise(k + 1600) < 0.3 {
                        c.ellipse(x + 3 * s, y - 6 * s, 3 * s, 7 * s, C(0x22322A))
                    } else {
                        gnHouse(c, x: x, base: y, w: (12 + Int(noise(k + 1610) * 6)) * s, h: (9 + Int(noise(k + 1620) * 5)) * s,
                                s: s, k: k)
                    }
                }
                x += (18 + Int(noise(k + 1630) * 10)) * s; k += 1
            }
        }
        // The old restaurant on the point: weathered boards, a long porch, a sign board and boarded windows.
        let rx = c.w * 27 / 100, rb = g - 40 * s
        c.rect(rx, rb - 18 * s, 44 * s, 18 * s, C(0x6A5444)); c.rect(rx, rb - 18 * s, 44 * s, s, C(0x8A7060))
        for i in 0..<(8 * s) { c.rect(rx - 2 * s + i, rb - 26 * s + i, 48 * s - 2 * i, 1, C(0x3A3230)) }
        for wx in stride(from: rx + 4 * s, to: rx + 40 * s, by: 9 * s) {
            c.rect(wx, rb - 13 * s, 5 * s, 6 * s, C(0x2A2420))
            c.rect(wx - s, rb - 11 * s, 7 * s, s, C(0x9A8466))
        }
        c.rect(rx + 10 * s, rb - 32 * s, 24 * s, 5 * s, C(0xD8CCB0)); c.rect(rx + 12 * s, rb - 30 * s, 20 * s, s, C(0x8A3A2A))
        c.rect(rx + 14 * s, rb - 27 * s, s, 2 * s, C(0x3A3230)); c.rect(rx + 29 * s, rb - 27 * s, s, 2 * s, C(0x3A3230))
        c.rect(rx - 4 * s, rb - 2 * s, 52 * s, 2 * s, C(0x4A3A30))
    }

    /// What moves at the Goondocks: the swell rolling in as lines of foam, spray thrown up against the sea stack, the
    /// lighthouse's beam sweeping round (a flash when it turns towards you), and gulls wheeling.
    static func goondocksLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = gnDocksFrame(c, g)
        // Foam lines rolling in towards the beach.
        for i in 0..<5 {
            let k = (t / 6 + Double(i) / 5).truncatingRemainder(dividingBy: 1)
            let y = f.horizon + Int(Double(g - f.horizon) * (0.25 + 0.75 * k))
            let a = sin(k * .pi) * 0.5
            for j in 0..<6 {
                let x = Int(noise(i * 9 + j + 1700) * Double(c.w))
                c.rect(x, y, (10 + Int(noise(i * 9 + j + 1720) * 20)) * s, s, C(0xF0F6F2, a))
            }
        }
        // Spray against the stack, every few seconds.
        let burst = (t / 3.5).truncatingRemainder(dividingBy: 1)
        if burst < 0.5 {
            let up = burst / 0.5
            for i in 0..<10 {
                let dx = (noise(i + 1750) - 0.5) * Double(f.stack.hw) * 1.6
                let dy = up * Double(8 + Int(noise(i + 1760) * 14)) * Double(s)
                c.rect(f.stack.x + Int(dx), g - 3 * s - Int(dy), s, s, C(0xF4F8F6, 0.8 * (1 - up)))
            }
        }
        // The lighthouse beam: a long pale wedge swinging round.
        let a = t * 0.9
        let reach = cos(a) * Double(c.w) * 0.55, depth = sin(a)
        let lx = Double(f.light.x), ly = Double(f.light.lamp - 2 * s)
        if abs(reach) > Double(10 * s) {
            let n = 6
            for i in 0..<n {
                let spread = (Double(i) / Double(n - 1) - 0.5) * 0.16 * abs(reach)
                c.glowLine(lx, ly, lx + reach, ly + spread + depth * Double(6 * s), core: C(0xFFF6D0, 0.1),
                           glow: C(0xFFF6D0, 0.06), coreR: Double(s), glowR: Double(3 * s))
            }
        }
        if depth > 0.85 {
            c.circle(Int(lx), Int(ly), 8 * s, C(0xFFF6D0, 0.35)); c.circle(Int(lx), Int(ly), 3 * s, C(0xFFFFF0, 0.9))
        }
        // Gulls wheeling over the stack.
        for i in 0..<4 {
            let a2 = t * (0.4 + Double(i) * 0.07) + Double(i) * 1.7
            let gx = f.stack.x + Int(cos(a2) * Double((40 + i * 12) * s))
            let gy = g - f.stack.h - 8 * s + Int(sin(a2 * 1.3) * Double(6 * s)) - i * 3 * s
            let up = sin(t * 8 + Double(i)) > 0
            c.rect(gx - 2 * s, gy + (up ? -s : 0), 2 * s, s, C(0xF4F4EE))
            c.rect(gx, gy, s, s, C(0xF4F4EE))
            c.rect(gx + s, gy + (up ? -s : 0), 2 * s, s, C(0xF4F4EE))
        }
    }
}

// MARK: - The Inferno

extension Scenes {
    /// Where things stand in the cove: the water line, the ship (bow, stern, deck line, gun-deck row), the torches,
    /// and the masts.
    private static func gnCoveFrame(_ c: PixelCanvas, _ g: Int) -> (water: Int, bow: Int, stern: Int, deck: Int, guns: Int,
                                                                     torches: [(x: Int, y: Int)], masts: [Int]) {
        let s = unit(g), tall = isTall(c)
        let water = g - 12 * s
        let bow = c.w * 24 / 100, stern = c.w * 90 / 100
        let deck = g - (tall ? 46 : 38) * s
        let guns = water - (tall ? 14 : 11) * s
        let torches = [(x: c.w * 7 / 100, y: g - 36 * s), (x: c.w * 97 / 100, y: g - 40 * s), (x: c.w * 18 / 100, y: g - 30 * s)]
        let masts = [bow + (stern - bow) * 28 / 100, bow + (stern - bow) * 56 / 100, bow + (stern - bow) * 82 / 100]
        return (water, bow, stern, deck, guns, torches, masts)
    }

    /// A wall torch: an iron bracket, a wrapped head, and its warm light on the rock (the flame is in the moving
    /// layer).
    private static func gnTorch(_ c: PixelCanvas, _ x: Int, _ y: Int, _ s: Int) {
        c.circle(x, y - 3 * s, 16 * s, C(0xF0A040, 0.06)); c.circle(x, y - 3 * s, 9 * s, C(0xF0A040, 0.08))
        c.rect(x - s, y, 2 * s, 7 * s, C(0x3A2A1A)); c.rect(x - 2 * s, y + 6 * s, 4 * s, s, C(0x2A2420))
        c.rect(x - 2 * s, y - s, 4 * s, 2 * s, C(0x5A3A1A))
    }

    /// The Inferno in its cove: a cavern of brown rock lit by torches, dark green water lapping in the middle, and
    /// One-Eyed Willy's galleon moored across it, its black hull trimmed in faded gold, a row of gunports with the
    /// cannons run out, the high stern with its lit windows, the bowsprit and the masts going up into the dark. The
    /// rock ledge in front is scattered with gold. On the screen saver the masts climb with their rigging and
    /// tattered black sails, the skull flag at the top, and the cave roof hangs over all of it in stalactites, a
    /// shaft of daylight falling through a crack.
    static func inferno(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = gnCoveFrame(c, g)
        c.gradient(0, g, C(0x120C08), C(0x3A2818), bands: tall ? 10 : 6)
        // Rock texture: dark lumps and lit edges.
        for i in 0..<(c.w * g / (tall ? 700 : 260)) {
            let x = Int(noise(i * 4 + 2001) * Double(c.w)), y = Int(noise(i * 4 + 2002) * Double(g))
            let r = (2 + Int(noise(i * 4 + 2003) * 6)) * s
            c.ellipse(x, y, r * 2, r, C(0x1A120A, 0.35)); c.rect(x - r, y - r, r * 2, s, C(0x6A4A2A, 0.2))
        }
        if tall { gnCaveRoof(c, g, s, f.masts) }
        // The masts (lower parts; the screen saver draws the rest).
        for (i, mx) in f.masts.enumerated() {
            let top = 0
            c.rect(mx - s, top, 3 * s, f.deck - top, C(0x2A1A10)); c.rect(mx - s, top, s, f.deck - top, C(0x4A3220))
            if !tall {
                let yy = f.deck - (14 + i * 4) * s
                c.rect(mx - 16 * s, yy, 33 * s, 2 * s, C(0x2A1A10))
                c.rect(mx - 14 * s, yy + 2 * s, 29 * s, 3 * s, C(0x1A1614))
                for fx in stride(from: mx - 14 * s, to: mx + 15 * s, by: 4 * s) { c.rect(fx, yy + 5 * s, 2 * s, s, C(0x1A1614)) }
            }
        }
        // Rigging down to the rails.
        for mx in f.masts {
            for d in [-1, 1] {
                c.glowLine(Double(mx), Double(f.deck - 26 * s), Double(mx + d * 18 * s), Double(f.deck), core: C(0x5A4A3A, 0.7),
                           glow: C(0, 0), coreR: 0.5)
            }
        }
        // The hull: tumblehome sides, gold-trimmed wales, the gunports with cannons run out.
        for x in f.bow..<f.stern {
            let k = Double(x - f.bow) / Double(f.stern - f.bow)
            let rise = (1 - k) * (1 - k) * (1 - k) * Double(10 * s)
            let top = f.deck - Int(rise) + 2 * s
            c.rect(x, top, 1, f.water - top, C(0x24180F))
            for py in stride(from: top + 3 * s, to: f.water, by: 3 * s) { c.rect(x, py, 1, 1, C(0x1A1009)) }
            c.rect(x, top, 1, s, C(0xA88A3A)); c.rect(x, top + s, 1, s, C(0x3A2818))
            c.rect(x, f.guns - 4 * s, 1, s, C(0x8A6A2A))
            c.rect(x, f.guns + 5 * s, 1, s, C(0x6A5020))
        }
        // The stern castle: higher, with windows glowing.
        let sx = f.stern - 30 * s
        c.rect(sx, f.deck - 12 * s, 30 * s, 12 * s, C(0x2A1C12)); c.rect(sx, f.deck - 12 * s, 30 * s, s, C(0xA88A3A))
        for wx in stride(from: sx + 3 * s, to: f.stern - 3 * s, by: 6 * s) {
            c.rect(wx, f.deck - 9 * s, 4 * s, 5 * s, C(0xF0B048, 0.85)); c.rect(wx + s, f.deck - 9 * s, s, 5 * s, C(0x5A3A18))
        }
        c.rect(f.stern - 2 * s, f.deck - 14 * s, 4 * s, f.water - f.deck + 14 * s, C(0x1E140C))
        c.rect(f.stern, f.deck - 16 * s, 2 * s, 3 * s, C(0xF0B048))
        // The bow and bowsprit with its figurehead.
        for i in 0..<(12 * s) {
            let top = f.deck - 8 * s + i
            c.rect(f.bow - i, top + i, 1, max(0, f.water - top - i * 2), C(0x24180F))
            c.rect(f.bow - i, top + i, 1, s, C(0xA88A3A))
        }
        c.glowLine(Double(f.bow), Double(f.deck - 6 * s), Double(f.bow - 36 * s), Double(f.deck - 20 * s),
                   core: C(0x3A2818), glow: C(0, 0), coreR: Double(s) * 1.3)
        c.circle(f.bow - 10 * s, f.deck + 2 * s, 2 * s, C(0xC8A04A))
        // Gunports and cannons.
        for gx in stride(from: f.bow + 10 * s, to: f.stern - 8 * s, by: 14 * s) {
            c.rect(gx, f.guns - 2 * s, 6 * s, 5 * s, C(0x0E0806)); c.rect(gx, f.guns - 3 * s, 6 * s, s, C(0x8A2A1A))
            c.rect(gx + s, f.guns, 4 * s, 2 * s, C(0x2A2A2E)); c.rect(gx + s, f.guns, 4 * s, s, C(0x5A5A60))
            c.rect(gx + 4 * s, f.guns - s, s, 4 * s, C(0x1A1A1E))
        }
        // The water: dark green, lighter bands, torchlight on it in the moving layer.
        c.gradient(f.water, g, C(0x1E4A42), C(0x10302C), bands: 3)
        c.rect(0, f.water, c.w, s, C(0x4A8A7A, 0.6))
        // The torches on the walls.
        for tch in f.torches { gnTorch(c, tch.x, tch.y, s) }
        // The ledge: wet rock, with gold coins and a chest's corner.
        c.ground(g, C(0x2E2218), edge: C(0x5A4430), speck: C(0x3A2C20), seed: 71)
        for i in 0..<(c.w / (18 * s)) {
            let x = Int(noise(i + 2100) * Double(c.w))
            let y = g + s + Int(noise(i + 2110) * Double(max(1, c.h - g - 2 * s)))
            c.rect(x, y, s, s, C(0xF0C850)); c.rect(x + s, y, s, s, C(0xB89030))
        }
        let cx = c.w * 82 / 100
        c.rect(cx, g - 6 * s, 14 * s, 6 * s, C(0x5A3A1E)); c.rect(cx, g - 6 * s, 14 * s, s, C(0x7A5228))
        c.rect(cx + 6 * s, g - 5 * s, 2 * s, 3 * s, C(0xC8A04A))
        for i in 0..<6 { c.rect(cx + 2 * s + i * 2 * s, g - 7 * s - (i % 2) * s, 2 * s, s, C(0xF0C850)) }
    }

    /// The cave roof on the screen saver: the masts going all the way up with their crow's nests, yards and tattered
    /// black sails, rigging fanning out, the skull-and-crossbones at the top, and the roof of rock closing in with
    /// stalactites, a crack of daylight letting a shaft down onto the water.
    private static func gnCaveRoof(_ c: PixelCanvas, _ g: Int, _ s: Int, _ masts: [Int]) {
        // The daylight shaft.
        let lx = c.w * 40 / 100
        for i in 0..<g {
            let hw = 6 * s + i / 14
            c.rect(lx + i / 3 - hw, i, hw * 2, 1, C(0xE8E0B0, 0.05))
        }
        for (i, mx) in masts.enumerated() {
            let top = g * (12 + i % 2 * 8) / 100
            c.rect(mx - s, top, 3 * s, g - top, C(0x2A1A10)); c.rect(mx - s, top, s, g - top, C(0x4A3220))
            // Yards and sails, each sail torn along its foot.
            for (j, yy) in [top + 18 * s, top + (g - top) * 45 / 100].enumerated() {
                let half = (24 - j * 2) * s
                c.rect(mx - half - 2 * s, yy, half * 2 + 5 * s, 2 * s, C(0x2A1A10))
                let sh = (g - top) * 28 / 100
                for x in (mx - half)..<(mx + half + s) {
                    let tear = Int(noise(x + j * 31 + i * 97 + 2200) * Double(sh) * 0.45)
                    let billow = Int(sin(Double(x - mx + half) / Double(2 * half) * .pi) * Double(3 * s))
                    c.rect(x, yy + 2 * s, 1, sh - tear + billow, C(0x3A302A))
                    c.rect(x, yy + 2 * s + sh - tear + billow - s, 1, s, C(0x4E4238))
                    if (x - mx) % (9 * s) == 0 { c.rect(x, yy + 2 * s, 1, sh - tear + billow, C(0x2A221E)) }
                }
            }
            // The crow's nest.
            c.rect(mx - 5 * s, top + 8 * s, 11 * s, 4 * s, C(0x3A2818)); c.rect(mx - 5 * s, top + 8 * s, 11 * s, s, C(0x5A4228))
            // Rigging fanning down.
            for d in [-1, 1] {
                for r in 0..<3 {
                    let ex = Double(mx + d * (16 + r * 10) * s)
                    c.glowLine(Double(mx), Double(top + 10 * s), ex, Double(g - 40 * s), core: C(0x5A4A3A, 0.35),
                               glow: C(0, 0), coreR: 0.5)
                }
            }
        }
        // The flag on the mainmast: black, the skull and crossed bones.
        let fx = masts[1] + 2 * s, fy = g * 20 / 100 - 16 * s
        c.rect(masts[1], fy - 2 * s, s, 18 * s, C(0x2A1A10))
        c.rect(fx, fy, 20 * s, 13 * s, C(0x0E0C0C))
        let skull = Pen(c, fx + 6 * s, fy + 2 * s, g)
        skull.rect(1, 0, 6, 5, C(0xE8E4D8)); skull.rect(2, 5, 4, 2, C(0xE8E4D8))
        skull.rect(2, 2, 1, 2, C(0x0E0C0C)); skull.rect(5, 2, 1, 2, C(0x0E0C0C))
        skull.rect(-3, 8, 2, 1, C(0xE8E4D8)); skull.rect(-1, 9, 10, 1, C(0xE8E4D8)); skull.rect(9, 8, 2, 1, C(0xE8E4D8))
        skull.rect(-3, 10, 2, 1, C(0xE8E4D8)); skull.rect(9, 10, 2, 1, C(0xE8E4D8))
        // The roof of rock and its stalactites.
        for x in stride(from: 0, to: c.w, by: s) {
            let rough = Int(noise(x / max(1, s) + 2300) * Double(8 * s))
            let dome = Int(pow(abs(Double(x - c.w / 2)) / Double(c.w / 2), 2) * Double(g / 4))
            let bottom = g / 16 + dome + rough
            let gap = abs(x - lx) < 3 * s
            if !gap { c.rect(x, 0, s, bottom, C(0x0C0805)); c.rect(x, bottom - s, s, s, C(0x5A4028)) }
        }
        for i in 0..<(c.w / (9 * s)) {
            let x = Int(noise(i + 2400) * Double(c.w))
            let dome = Int(pow(abs(Double(x - c.w / 2)) / Double(c.w / 2), 2) * Double(g / 4))
            let root = g / 16 + dome
            let len = (6 + Int(noise(i + 2410) * 22)) * s
            for j in 0..<len {
                let hw = max(0, (len - j) * 5 * s / len)
                c.rect(x - hw, root + j, hw * 2 + 1, 1, C(0x0C0805)); c.rect(x + hw, root + j, 1, 1, C(0x5A4028, 0.35))
            }
        }
    }

    /// What moves in the cove: the torches' flames licking and flickering, their light dancing on the water in
    /// broken orange streaks, ripples lapping at the hull, a drip now and then from the roof, and every so often a
    /// cannon firing (a flash at a gunport and a puff of smoke rolling away).
    static func infernoLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = gnCoveFrame(c, g)
        // Flames.
        for (i, tch) in f.torches.enumerated() {
            let fl = sin(t * 11 + Double(i) * 2.1), fl2 = sin(t * 17 + Double(i))
            c.circle(tch.x, tch.y - 4 * s, (10 + Int(fl * 2)) * s, C(0xF0A040, 0.07))
            c.ellipse(tch.x, tch.y - 3 * s, 2 * s, (3 + Int(fl2 + 1)) * s, C(0xE8641A))
            c.ellipse(tch.x + Int(fl) * s / 2, tch.y - 4 * s, s, 2 * s, C(0xFFD86A))
            c.rect(tch.x + Int(fl2 * 2) * s / 2, tch.y - (8 + Int(fl + 1)) * s, s, s, C(0xFFA040, 0.7))
        }
        // Torchlight on the water, and ripples.
        for (i, tch) in f.torches.enumerated() {
            for j in 0..<4 {
                let y = f.water + (2 + j * 2) * s
                guard y < g else { continue }
                let wob = Int(sin(t * 3 + Double(j) + Double(i)) * Double(2 * s))
                c.rect(tch.x - 2 * s + wob, y, (4 - j / 2) * s, s, C(0xF0A040, 0.5 - Double(j) * 0.1))
            }
        }
        for i in 0..<10 {
            let x = Int((noise(i + 2500) * Double(c.w) + t * 6).truncatingRemainder(dividingBy: Double(c.w)))
            let y = f.water + s + Int(noise(i + 2510) * Double(max(1, g - f.water - 2 * s)))
            c.rect(x, y, (5 + Int(noise(i + 2520) * 6)) * s, s, C(0x6AAA9A, 0.3 + 0.2 * sin(t * 2 + Double(i))))
        }
        // A drip falling into the cove.
        let dk = (t / 2.7).truncatingRemainder(dividingBy: 1)
        let dx = c.w * 62 / 100
        if dk < 0.8 {
            c.rect(dx, Int(dk / 0.8 * Double(f.water)), s, 2 * s, C(0x8AC8B8, 0.7))
        } else {
            let r = Int((dk - 0.8) / 0.2 * 6) * s
            c.ellipse(dx, f.water + s, r + s, max(1, r / 3), C(0x8AC8B8, 0.5))
        }
        // A cannon firing every ten seconds or so.
        let ck = (t / 10).truncatingRemainder(dividingBy: 1) * 10
        if ck < 2.5 {
            let gx = f.bow + 10 * s + 14 * s * (1 + Int(t / 10) % 4) + 3 * s
            if ck < 0.15 { c.circle(gx, f.guns + s, 5 * s, C(0xFFE08A, 0.85)) }
            for p in 0..<4 {
                let k = ck / 2.5
                let px = gx + Int(k * Double((10 + p * 4) * s)) - p * 2 * s
                let py = f.guns - Int(k * Double((6 + p * 3) * s))
                c.circle(px, py, (2 + p + Int(k * 4)) * s, C(0xC8C0B0, 0.4 * (1 - k)))
            }
        }
    }
}
