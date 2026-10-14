import Foundation

// The Mines of Mori-ah and Mount Doomscroll.
let ringsScenes2: [Location: Place] = [
    .moria: Place(name: "The Mines of Mori-ah", panel: 0x101216, still: Scenes.moria, moving: Scenes.moriaLife),
    .mountDoom: Place(name: "Mount Doomscroll", panel: 0x1E0E0A, still: Scenes.mountDoom, moving: Scenes.mountDoomLife),
]

// MARK: - Shared bits for these scenes

extension Scenes {
    /// Where a repeating motion of `period` seconds is, from 0 up to 1.
    static func rings2Phase(_ t: Double, _ period: Double, offset: Double = 0) -> Double {
        let v = (t + offset).truncatingRemainder(dividingBy: period) / period
        return v < 0 ? v + 1 : v
    }

    /// `v` clamped into 0...1.
    static func rings2Clamp(_ v: Double) -> Double { max(0, min(1, v)) }
}

// MARK: - The Mines of Mori-ah

extension Scenes {
    /// The bridge: the inner faces of the two abutments and the deck's thickness. Its top row is the ground row `g`.
    static func moriaBridge(_ c: PixelCanvas, _ g: Int) -> (left: Int, right: Int, deck: Int) {
        let s = unit(g)
        return (24 * s, c.w - 24 * s, 3 * s)
    }

    /// The chasm's far rim, where the pillars stand.
    static func moriaRim(_ c: PixelCanvas, _ g: Int) -> Int {
        isTall(c) ? Int(Double(g) * 0.58) : g - 15 * unit(g)
    }

    /// The pillars of the hall beyond the chasm: left edge, width, and whether it's in the far rank.
    static func moriaPillars(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int, far: Bool)] {
        let s = unit(g), tall = isTall(c)
        var out: [(x: Int, w: Int, far: Bool)] = []
        if tall {
            var x = 30 * s, i = 0
            while x < c.w {
                out.append((x + Int(noise(i * 5 + 610) * Double(10 * s)), (8 + Int(noise(i * 5 + 611) * 3.0)) * s, true))
                x += 46 * s; i += 1
            }
        }
        var x = -6 * s, i = 0
        while x < c.w {
            let w = (17 + Int(noise(i * 5 + 600) * 6.0)) * s
            out.append((x, w, false))
            x += w + (52 + Int(noise(i * 5 + 601) * 22.0)) * s
            i += 1
        }
        return out
    }

    /// The Mines of Mori-ah: the crew is out on the narrow stone bridge that crosses the strip, with nothing either
    /// side of it. Beyond and below is the chasm, lit a faint orange from the depths, and past it the huge carved
    /// pillars of the hall rise from the far rim and fade into the dark. On tall screens the hall opens up: a second
    /// rank of pillars, their capitals and vaults, and the chasm gaping under the far rim with rock spires and a far
    /// bridge down in its glow.
    static func moria(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), rim = moriaRim(c, g), b = moriaBridge(c, g)
        let dark = C(0x0C0D10), glow = C(0x3A1A0A)
        c.rect(0, 0, c.w, g, dark)
        // the far wall, barely there
        for i in 0..<max(0, c.w * rim / 260) {
            let x = Int(noise(i * 4 + 640) * Double(c.w)), y = Int(noise(i * 4 + 641) * Double(rim))
            let len = (3 + Int(noise(i * 4 + 642) * 10.0)) * s
            c.rect(x, y, len, s, C(0x15161B, 0.4 + 0.5 * Double(y) / Double(max(1, rim))))
        }
        if tall { moriaVaults(c, g) }
        for p in moriaPillars(c, g) where p.far { moriaPillar(c, g, p.x, p.w, far: true) }
        for p in moriaPillars(c, g) where !p.far { moriaPillar(c, g, p.x, p.w, far: false) }
        // the far rim and the chasm below it, brightening towards the depths
        c.rect(0, rim, c.w, 2 * s, C(0x1A1B20)); c.rect(0, rim, c.w, s, C(0x2C2A2C))
        let chasmTop = rim + 2 * s
        c.gradient(chasmTop, g, C(0x0E0C0D), glow, bands: tall ? 10 : 5)
        if tall { moriaDeep(c, g) }
        // the far rim's ragged lip, hanging over the chasm, and a few cracks running down from it into the glow
        for x in 0..<c.w {
            c.rect(x, chasmTop, 1, s + Int(noise(x / (3 * s) + 650) * Double(3 * s)), C(0x111115))
        }
        for i in 0..<(c.w / (20 * s)) {
            let x = Int(noise(i * 3 + 660) * Double(c.w))
            let len = Int((0.2 + noise(i * 3 + 661) * 0.4) * Double(g - chasmTop))
            for y in chasmTop..<(chasmTop + len) {
                let k = Double(y - chasmTop) / Double(max(1, len))
                c.px(x + Int(sin(Double(y) * 0.3 + Double(i)) * 1.2), y, C(0x08080A, 0.5 * (1 - k)))
            }
        }
        moriaBridgeDraw(c, g, b)
    }

    /// One great pillar standing on the far rim: fluted, banded with carved diamonds, lit orange low down where the
    /// glow reaches and fading into the dark above. The far rank is slimmer and dimmer.
    static func moriaPillar(_ c: PixelCanvas, _ g: Int, _ x: Int, _ w: Int, far: Bool) {
        let s = unit(g), tall = isTall(c), rim = moriaRim(c, g)
        let dark = C(0x0C0D10), lit = C(0x6A3418)
        let body = far ? C(0x1C1D22) : C(0x2A2C32), shade = far ? C(0x141519) : C(0x1E2025)
        let edge = far ? C(0x24252B) : C(0x3A3C44), groove = far ? C(0x17181C) : C(0x222429)
        let capital = tall ? Int(Double(g) * (far ? 0.2 : 0.1)) : -1
        let y0: Double = tall ? Double(g) * 0.04 : -Double(g) / 3
        let y1: Double = tall ? Double(g) * 0.5 : Double(g) * 0.85
        let glowLen = Double((tall ? 70 : 24) * s)
        // the colour of `p` at row `y`: faded into the dark above, warmed by the glow below
        func tone(_ p: Px, _ y: Int) -> Px {
            let k = (rings2Clamp((Double(y) - y0) / (y1 - y0)) * 8).rounded(.down) / 8
            let gk = rings2Clamp(1 - Double(rim - y) / glowLen) * (far ? 0.25 : 0.4)
            return lerp(lerp(dark, p, k), lit, gk)
        }
        let top = max(0, capital)
        for y in top..<max(top, rim) {
            c.rect(x, y, w, 1, tone(body, y))
            c.rect(x + w - 3 * s, y, 3 * s, 1, tone(shade, y))
            c.rect(x, y, s, 1, tone(edge, y))
            for fx in stride(from: x + 3 * s, to: x + w - 4 * s, by: 4 * s) { c.rect(fx, y, s, 1, tone(groove, y)) }
        }
        // the carved bands
        let bandGap = (far ? 26 : 34) * s
        for by in stride(from: rim - (far ? 16 : 20) * s, to: top + 6 * s, by: -bandGap) {
            c.rect(x - s, by, w + 2 * s, 4 * s, tone(body, by))
            c.rect(x - s, by, w + 2 * s, s, tone(edge, by))
            c.rect(x - s, by + 3 * s, w + 2 * s, s, tone(shade, by))
            for dx in stride(from: 2 * s, to: w - 2 * s, by: 4 * s) {
                c.rect(x + dx, by + s, s, s, tone(groove, by)); c.rect(x + dx + s, by + 2 * s, s, s, tone(groove, by))
                c.rect(x + dx - s, by + 2 * s, s, s, tone(groove, by))
            }
        }
        // the plinth on the rim
        let py = rim - 4 * s
        c.rect(x - 2 * s, py, w + 4 * s, 4 * s, tone(body, py + 2 * s))
        c.rect(x - 2 * s, py, w + 4 * s, s, tone(edge, py + 2 * s))
        c.rect(x + w - s, py + s, 3 * s, 3 * s, tone(shade, py + 2 * s))
        // the capital, flaring into the vault (tall screens only)
        if capital >= 0 {
            for k in 0..<(6 * s) {
                let flare = (6 * s - k) / 2
                c.rect(x - flare, capital - k, w + flare * 2, 1, tone(k == 0 ? edge : body, capital))
            }
        }
    }

    /// The chasm's colour at row `y`, as its gradient paints it.
    static func moriaChasmTone(_ c: PixelCanvas, _ g: Int, _ y: Int) -> Px {
        let top = moriaRim(c, g) + 2 * unit(g)
        return lerp(C(0x0E0C0D), C(0x3A1A0A), Double(y - top) / Double(max(1, g - top)))
    }

    /// Down in the chasm on tall screens: rock spires standing up out of the glow, hazier the further off they are,
    /// with their flanks lit from beneath, and a far bridge spanning between two of them.
    static func moriaDeep(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), top = moriaRim(c, g) + 2 * s, depth = g - top
        let dark = C(0x07070A), lit = C(0x6A3418)
        // x (share of the width), height (share of the depth), half-width at the foot, haze (0 near, 1 far)
        let spires: [(x: Double, h: Double, half: Int, haze: Double)] = [
            (0.06, 0.55, 16, 0.6), (0.3, 0.62, 12, 0.75), (0.66, 0.5, 14, 0.7), (0.93, 0.68, 20, 0.55),
            (0.47, 0.44, 15, 0.35), (0.18, 0.36, 17, 0.2), (0.8, 0.4, 19, 0.15),
        ]
        func spire(_ sp: (x: Double, h: Double, half: Int, haze: Double)) {
            let x0 = Int(Double(c.w) * sp.x), sTop = g - Int(Double(depth) * sp.h)
            let lean: Double = (noise(Int(sp.x * 100) + 690) - 0.5) * Double(14 * s)
            for y in sTop..<g {
                let k = Double(y - sTop) / Double(max(1, g - sTop)), bg = moriaChasmTone(c, g, y)
                // ragged flanks: each side steps in and out in little ledges of rock
                let l = Int(noise((y - sTop) / (3 * s) * 2 + x0) * 3.0) * s, r = Int(noise((y - sTop) / (4 * s) * 2 + x0 + 1) * 3.0) * s
                let hw = max(s, Int(Double(sp.half * s) * pow(k, 1.15)))
                let x = x0 + Int((1 - k) * lean)
                let body = lerp(dark, bg, sp.haze)
                c.rect(x - hw - l, y, hw * 2 + l + r, 1, body)
                c.px(x + hw + r - 1, y, lerp(body, lit, 0.6 * Double(y - top) / Double(depth)))
                c.px(x - hw - l, y, lerp(body, lit, 0.3 * Double(y - top) / Double(depth)))
            }
        }
        for sp in spires where sp.haze > 0.5 { spire(sp) }
        // the far bridge, from the second spire to the third
        let by = g - Int(Double(depth) * 0.45), bx0 = Int(Double(c.w) * 0.3), bx1 = Int(Double(c.w) * 0.66)
        let span = lerp(dark, moriaChasmTone(c, g, by), 0.62)
        c.rect(bx0, by, bx1 - bx0, s, span)
        for x in bx0..<bx1 {
            let u = Double(min(x - bx0, bx1 - x)) / Double(max(1, (bx1 - bx0) / 2))
            c.rect(x, by + s, 1, Int(pow(1 - u, 3) * Double(6 * s)), span)
        }
        c.rect(bx0, by - s, bx1 - bx0, s, lerp(span, lit, 0.15))
        for sp in spires where sp.haze <= 0.5 { spire(sp) }
    }

    /// High up on tall screens: the vaults springing from capital to capital, lost in the dark.
    static func moriaVaults(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), dark = C(0x0C0D10)
        let near = moriaPillars(c, g).filter { !$0.far }
        let spring = Int(Double(g) * 0.1) - 6 * s
        for (a, b) in zip(near, near.dropFirst()) {
            let x0 = a.x + a.w / 2, x1 = b.x + b.w / 2, cx = (x0 + x1) / 2, half = (x1 - x0) / 2
            let rise = Int(Double(half) * 0.7)
            for dx in -half...half {
                let k = Double(dx) / Double(max(1, half))
                let y = spring - Int(Double(rise) * (1 - k * k).squareRoot())
                for j in 0..<(5 * s) {
                    let fade = rings2Clamp(Double(y + j) / Double(spring)) * 0.55
                    c.px(cx + dx, y + j, lerp(dark, j < s ? C(0x2E3036) : C(0x24262C), fade))
                }
            }
        }
    }

    /// How far the bridge's arch hangs below the deck at column `x`: deep at the abutments, a pixel or two mid-span.
    static func moriaArch(_ c: PixelCanvas, _ g: Int, _ b: (left: Int, right: Int, deck: Int), _ x: Int) -> Int {
        let s = unit(g), u = Double(min(x - b.left, b.right - x)) / (Double(b.right - b.left) / 2)
        return Int(pow(1 - u, 4) * Double(c.h - g)) + (u > 0.15 ? s : 2 * s)
    }

    /// The bridge: a slender span of pale stone from abutment to abutment, its top row on the ground row, no rails.
    /// Its top edge catches the light, its side face and the thin arch under it are darker, and the arch has a dark
    /// underside. Below it the chasm drops away, black under the span and glowing orange in the depths.
    static func moriaBridgeDraw(_ c: PixelCanvas, _ g: Int, _ b: (left: Int, right: Int, deck: Int)) {
        let s = unit(g)
        let top = C(0xD8CBB4), stone = C(0x9A8E80), face = C(0x655B52), arch = C(0x6A6056)
        let lip = C(0x2E2620), joint = C(0x51483F), glow = C(0x8A3A12)
        let rock = C(0x5A5148), rockLit = C(0x7E7266), rockFace = C(0x3A332D)
        // the chasm under the bridge: black just under the span, glowing in the depths
        for y in g..<c.h {
            let k = Double(y - g + 1) / Double(max(1, c.h - g))
            c.rect(0, y, c.w, 1, lerp(C(0x060506), glow, pow(k, 2.5)))
        }
        // the abutments: dressed stone from the bridge down out of sight, their chasm-side faces shelving away
        for side in [-1, 1] {
            for y in g..<c.h {
                let shelf = (y - g) * (y - g) / max(1, 16 * s)
                let x0 = side < 0 ? 0 : b.right + shelf, x1 = side < 0 ? b.left - shelf : c.w
                c.rect(x0, y, x1 - x0, 1, rock)
                // the face towards the chasm, lit at its edge by the glow
                let fx = side < 0 ? x1 - 2 * s : x0
                c.rect(fx, y, 2 * s, 1, rockFace)
                c.px(side < 0 ? x1 - 1 : x0, y, lerp(rockFace, glow, pow(Double(y - g + 1) / Double(max(1, c.h - g)), 2)))
            }
            // courses of masonry on the abutment
            for y in stride(from: g + b.deck + 2 * s, to: c.h, by: 3 * s) {
                let x0 = side < 0 ? 0 : b.right, x1 = side < 0 ? b.left : c.w
                c.rect(x0, y, x1 - x0, 1, rockFace)
                for x in stride(from: x0 + ((y / (3 * s)) % 2) * 4 * s, to: x1, by: 8 * s) { c.rect(x, y - 2 * s, s, 2 * s, rockFace) }
            }
        }
        // the thin arch under the deck, springing from the abutments
        for x in b.left..<max(b.left, b.right) {
            let extra = moriaArch(c, g, b, x)
            c.rect(x, g + b.deck, 1, extra, arch)
            c.px(x, g + b.deck + extra - 1, lip)
        }
        // the deck, the whole way across: a lit top edge, the stone, then the darker side face with its joints
        c.rect(0, g, c.w, b.deck, stone)
        c.rect(0, g + b.deck - s, c.w, s, face)
        for i in 0..<(c.w / 4) {
            let x = Int(noise(i * 3 + 720) * Double(c.w))
            c.px(x, g + s + Int(noise(i * 3 + 721) * Double(max(1, b.deck - 2 * s))), C(0x887C70))
        }
        for x in stride(from: 9 * s, to: c.w, by: 14 * s) { c.rect(x, g + s, s, b.deck - s, joint) }
        c.rect(0, g, c.w, s, top)
        // the abutments' top faces, a shade lighter where they meet the deck
        c.rect(0, g + b.deck, b.left, s, rockLit); c.rect(b.right, g + b.deck, c.w - b.right, s, rockLit)
    }

    /// The glow from the depths swelling and ebbing, and now and then a mote of dust falling from the dark.
    static func moriaLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), rim = moriaRim(c, g), b = moriaBridge(c, g)
        let twoPi: Double = 2 * Double.pi
        let pulse: Double = 0.5 + 0.5 * sin(t * twoPi / 5)
        let top = rim + 2 * s
        for y in top..<max(top, g) {
            let k = Double(y - top) / Double(max(1, g - top))
            c.rect(0, y, c.w, 1, C(0xC85A1E, k * k * (0.03 + 0.09 * pulse)))
        }
        // under the bridge: only where the chasm shows, below the arch, and strongest deep down
        for x in b.left..<max(b.left, b.right) {
            let y0 = g + b.deck + moriaArch(c, g, b, x)
            for y in y0..<max(y0, c.h) {
                let k: Double = pow(Double(y - g + 1) / Double(max(1, c.h - g)), 2.5)
                c.px(x, y, C(0xC85A1E, k * (0.05 + 0.12 * pulse)))
            }
        }
        // glints of the glow on the pillars' feet
        for p in moriaPillars(c, g) where !p.far {
            c.rect(p.x, rim - 10 * s, s, 6 * s, C(0xE8701E, 0.05 + 0.12 * pulse))
        }
        // dust
        for i in 0..<(tall ? 7 : 4) {
            let period = 6.0 + noise(i * 3 + 740) * 6
            let ph = rings2Phase(t, period, offset: noise(i * 3 + 741) * period)
            guard ph < 0.3 else { continue }
            let fall = ph / 0.3, end = Double(tall ? g - s : rim)
            let x = Int(noise(i * 3 + 742) * Double(c.w)) + Int(sin(t * 2 + Double(i)) * Double(s))
            let y = Int(fall * end)
            let a: Double = fall < 0.8 ? 0.75 : (1 - fall) * 3.75
            c.rect(x, y, s, s, C(0xA89880, a * 0.7))
            c.rect(x, y - 2 * s, s, s, C(0xA89880, a * 0.25))
        }
    }
}

// MARK: - Mount Doomscroll

extension Scenes {
    /// The volcano: its peak's x, the crater's row, the half-width of its foot at the ground row, and the crater's half.
    static func mountDoomVolcano(_ c: PixelCanvas, _ g: Int) -> (x: Int, top: Int, half: Int, crater: Int) {
        let s = unit(g), tall = isTall(c)
        let top = tall ? Int(Double(g) * 0.32) : 14 * s
        return (Int(Double(c.w) * 0.2), top, max(0, Int(Double(g - top) * (tall ? 1.15 : 1.9))), (tall ? 12 : 7) * s)
    }

    /// The volcano's half-width at row `y`: steep near the crater, spreading out at the foot.
    static func mountDoomHalf(_ v: (x: Int, top: Int, half: Int, crater: Int), _ g: Int, _ y: Int) -> Int {
        let f = rings2Clamp(Double(y - v.top) / Double(max(1, g - v.top)))
        let k: Double = 1 - (1 - f).squareRoot()
        return v.crater + Int(k * Double(v.half - v.crater))
    }

    /// One lava streak down the volcano's face: its pixels and how far down each one is (0 at the crater).
    static func mountDoomStreak(_ c: PixelCanvas, _ g: Int, _ i: Int) -> [(x: Int, y: Int, k: Double)] {
        let v = mountDoomVolcano(c, g), s = unit(g)
        let a: Double = (noise(i * 5 + 800) * 2 - 1) * 0.8
        let len: Double = 0.3 + noise(i * 5 + 801) * 0.55
        let end = v.top + Int(len * Double(g - v.top))
        var out: [(x: Int, y: Int, k: Double)] = []
        for y in (v.top + s)..<max(v.top + s, end) {
            let wob = Int(sin(Double(y) * 0.18 + Double(i) * 2.1) * 1.4 * Double(s))
            out.append((v.x + Int(a * Double(mountDoomHalf(v, g, y)) * 0.9) + wob, y, Double(y - v.top) / Double(g - v.top)))
        }
        return out
    }

    static func mountDoomStreakCount(_ c: PixelCanvas) -> Int { isTall(c) ? 9 : 6 }

    /// Barad-dûr: its x, the tips of its horns, its foot, the Eye's centre row and the Eye's radii.
    static func mountDoomTower(_ c: PixelCanvas, _ g: Int) -> (x: Int, top: Int, base: Int, eyeY: Int, rx: Int, ry: Int) {
        let s = unit(g), tall = isTall(c)
        let top = tall ? Int(Double(g) * 0.1) : 3 * s
        let rx = (tall ? 9 : 6) * s, ry = (tall ? 4 : 3) * s
        return (Int(Double(c.w) * 0.84), top, g - (tall ? 6 : 4) * s, top + ry + (tall ? 11 : 8) * s, rx, ry)
    }

    /// The tower's half-width at its neck, under the Eye.
    static func mountDoomNeck(_ c: PixelCanvas, _ g: Int) -> Int { (isTall(c) ? 8 : 4) * unit(g) }

    /// The lava cracks in the basalt floor.
    static func mountDoomCracks(_ c: PixelCanvas, _ g: Int) -> [[(x: Int, y: Int)]] {
        let s = unit(g)
        var out: [[(x: Int, y: Int)]] = []
        for i in 0..<max(1, c.w / (44 * s)) {
            var x = Int(noise(i * 7 + 820) * Double(c.w)), y = g + 2 * s + Int(noise(i * 7 + 821) * Double(max(1, c.h - g - 4 * s)))
            var crack: [(x: Int, y: Int)] = []
            for k in 0..<(10 + Int(noise(i * 7 + 822) * 22.0)) * s {
                crack.append((x, y))
                x += 1
                let n = noise(i * 131 + k)
                if n < 0.25 { y -= 1 } else if n > 0.75 { y += 1 }
                y = max(g + 2, min(c.h - 1, y))
            }
            out.append(crack)
        }
        return out
    }

    /// Mount Doomscroll: an ash-red sky, the volcano at the left with lava streaking down its face and smoke pouring
    /// from its crater, and on the right horizon Barad-dûr's black tower with the Eye burning between its horns. The
    /// crew stands on cracked basalt with lava glowing in the cracks. Down the right edge runs a faint scrollbar of ash.
    /// On tall screens the tower stands at its full height.
    static func mountDoom(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x3A1A12), C(0x8A3A1E), bands: tall ? 10 : 7)
        // ash clouds
        for i in 0..<(tall ? 14 : 6) {
            let x = Int(noise(i * 5 + 840) * Double(c.w))
            let y = Int(noise(i * 5 + 841) * Double(g) * (tall ? 0.55 : 0.5))
            let len = (30 + Int(noise(i * 5 + 842) * 70.0)) * s
            wisp(c, x, y, len, C(0x2A1410, 0.45), s: s)
        }
        // the far mountains of the Ash range
        c.dunes(base: g - (tall ? 20 : 8) * s, amp: Double((tall ? 8 : 3) * s), freq: 0.035, phase: 1.3, bottom: g,
                C(0x3A1A14), shade: C(0x5A2818))
        mountDoomTowerDraw(c, g)
        // the plain
        c.dunes(base: g - (tall ? 5 : 3) * s, amp: Double(s), freq: 0.08, phase: 0.4, bottom: g, C(0x2A1814))
        mountDoomVolcanoDraw(c, g)
        // basalt crags at either end
        for (x0, w) in [(0, 20 * s), (c.w - 22 * s, 22 * s)] {
            for k in 0..<w {
                let hgt = Int((sin(Double(k) * 0.4 + Double(x0)) * 0.5 + 0.8) * Double((tall ? 9 : 5) * s))
                c.rect(x0 + k, g - hgt, 1, hgt, C(0x1A1210))
                c.px(x0 + k, g - hgt, C(0x4A2A20))
            }
        }
        // the floor and its cracks
        c.ground(g, C(0x1E1614), edge: C(0x3E2C24), speck: C(0x2A201C), seed: 21)
        for crack in mountDoomCracks(c, g) {
            for p in crack {
                c.px(p.x, p.y - 1, C(0xE8501E, 0.25)); c.px(p.x, p.y + 1, C(0xE8501E, 0.25))
                c.px(p.x, p.y, C(0xE8501E))
            }
        }
        // the scrollbar of ash, one pixel wide, with its thumb near the top
        let sx = c.w - 2
        for y in (2 * s)..<max(2 * s, g - 2 * s) {
            let thumb = y > g / 9 && y < g / 9 + g / 5
            c.px(sx, y, C(0xC8B4A4, (thumb ? 0.22 : 0.09) + noise(y + 860) * 0.05))
        }
    }

    /// The volcano: dark slopes lit from the left (the shading follows the cone), gullies, lava streaks, the crater's
    /// glow and its smoke.
    static func mountDoomVolcanoDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), v = mountDoomVolcano(c, g)
        // the smoke, drifting right as it rises
        for k in 0..<(tall ? 10 : 5) {
            let r = (3 + k * 2) * s
            let px = v.x + k * k * (tall ? 3 : 2) * s / 2, py = v.top - 2 * s - k * (tall ? 9 : 6) * s
            c.ellipse(px, py, r * 3 / 2, r, C(0x241210, 0.6 - Double(k) * 0.04))
            c.ellipse(px - s, py + r / 2, r, max(1, r / 3), C(0xE8501E, 0.08 * Double(max(0, 4 - k))))
        }
        c.circle(v.x, v.top, (tall ? 26 : 14) * s, C(0xE8501E, 0.12))
        let lit = C(0x2E1C18), mid = C(0x271814), shade = C(0x201310)
        for x in (v.x - v.half)...(v.x + v.half) {
            let d = abs(x - v.x)
            var ty = v.top
            if d > v.crater {
                // invert the half-width: the row where the slope reaches this column
                let k = Double(d - v.crater) / Double(max(1, v.half - v.crater))
                ty = v.top + Int((1 - (1 - k) * (1 - k)) * Double(g - v.top))
            }
            ty += Int(noise(x + 880) * 1.6)
            guard ty < g else { continue }
            c.rect(x, ty, 1, g - ty, shade)
            // the light falls from the left: lit and half-lit wedges fanning out from the crater
            let dx = Double(x - v.x)
            let yMid = dx <= 0 ? ty : max(ty, v.top + Int(dx / 0.75))
            let yLit = dx <= 0 ? ty : max(ty, v.top + Int(dx / 0.3))
            if yMid < g { c.rect(x, yMid, 1, g - yMid, mid) }
            if yLit < g { c.rect(x, yLit, 1, g - yLit, lit) }
            c.px(x, ty, x < v.x ? C(0x6A2E1C) : C(0x3A1E16))
        }
        // gullies
        for i in 0..<(tall ? 8 : 5) {
            let a: Double = (noise(i * 3 + 890) * 2 - 1) * 0.9
            for y in stride(from: v.top + 3 * s, to: g - 2 * s, by: 1) where noise(i * 61 + y) > 0.2 {
                c.px(v.x + Int(a * Double(mountDoomHalf(v, g, y)) * 0.95), y, C(0x180E0C))
            }
        }
        // the lava streaks, bright at the top and cooling as they run down
        for i in 0..<mountDoomStreakCount(c) {
            for p in mountDoomStreak(c, g, i) {
                let col: Px = p.k < 0.15 ? C(0xFFB03A) : p.k < 0.5 ? C(0xE8501E) : C(0xA8341A)
                c.rect(p.x, p.y, s, 1, col)
                if tall, p.k < 0.4 { c.px(p.x + s, p.y, C(0xE8501E, 0.6)) }
            }
        }
        // the crater
        c.ellipse(v.x, v.top + s, v.crater, max(1, 2 * s), C(0xE8501E))
        c.ellipse(v.x, v.top + s, max(1, v.crater - 3 * s), max(1, s), C(0xFFB03A))
    }

    /// Barad-dûr: stepped black tiers with spiked corners and buttresses, red slits, and the Eye held between two
    /// clawed horns.
    static func mountDoomTowerDraw(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = mountDoomTower(c, g)
        let black = C(0x0A0707), rimLit = C(0x4A2016)
        let neck = f.eyeY + f.ry + s
        let topHalf = mountDoomNeck(c, g), baseHalf = (tall ? 26 : 12) * s, tier = (tall ? 16 : 7) * s
        c.ellipse(f.x, f.eyeY, f.rx * 3, f.ry * 5, C(0xE8501E, 0.06))
        c.ellipse(f.x, f.eyeY, f.rx * 2, f.ry * 3, C(0xE8501E, 0.07))
        for y in neck..<max(neck, f.base) {
            let k = Double(y - neck) / Double(max(1, f.base - neck))
            let step = (y - neck) / tier
            let tk = Double(step * tier) / Double(max(1, f.base - neck))
            var hw = topHalf + Int(pow(tk, 1.5) * Double(baseHalf - topHalf))
            if (y - neck) % tier < s, step > 0 {
                hw += 2 * s
                // a spike at each corner of the tier
                for side in [-1, 1] { c.rect(side < 0 ? f.x - hw : f.x + hw - s, y - 3 * s, s, 3 * s, black) }
            }
            if tall, k > 0.8 { hw += Int((k - 0.8) * 5 * Double(baseHalf)) }
            c.rect(f.x - hw, y, hw * 2, 1, black)
            c.px(f.x - hw, y, rimLit)
        }
        // red slit windows
        for i in 0..<(tall ? 14 : 5) {
            let y = neck + 6 * s + Int(noise(i * 3 + 900) * Double(f.base - neck - 12 * s))
            let x = f.x + Int((noise(i * 3 + 901) - 0.5) * Double(topHalf * 2))
            c.rect(x, y, s, 2 * s, C(0xC8401A, 0.8))
        }
        mountDoomEye(c, g, look: 0, flick: -1)
        mountDoomHorns(c, g)
    }

    /// The two horns of the tower's crown, bowing out round the Eye and hooking in above it like claws.
    static func mountDoomHorns(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = mountDoomTower(c, g)
        let black = C(0x0A0707), rimLit = C(0x4A2016)
        let foot = f.eyeY + f.ry + 3 * s
        let p0 = Double(mountDoomNeck(c, g) - 2 * s), p1 = Double(f.rx + 6 * s), p2 = Double(f.rx - 2 * s)
        for y in f.top..<foot {
            let k = Double(foot - y) / Double(max(1, foot - f.top))
            let inner = Int((1 - k) * (1 - k) * p0 + 2 * k * (1 - k) * p1 + k * k * p2)
            let w = 2 * s + Int((1 - k) * Double(2 * s))
            for side in [-1, 1] {
                let x0 = side < 0 ? f.x - inner - w : f.x + inner
                c.rect(x0, y, w, 1, black)
                if side < 0 { c.px(x0, y, rimLit) }
            }
        }
    }

    /// The Eye: a flaming oval, gold at the heart, with its black slit `look` pixels off centre. `flick` >= 0 adds
    /// that frame's licking flames.
    static func mountDoomEye(_ c: PixelCanvas, _ g: Int, look: Int, flick: Int) {
        let s = unit(g), tall = isTall(c), f = mountDoomTower(c, g)
        let fire = C(0xE8501E), gold = C(0xFFB03A)
        if flick >= 0 {
            for k in 0..<(f.rx * 2 / s) {
                let x = f.x - f.rx + k * s, n = noise(flick * 37 + k)
                let middle = 1 - abs(Double(x - f.x)) / Double(f.rx)
                let lick = Int(n * middle * Double(tall ? 5 : 3)) * s
                c.rect(x, f.eyeY - f.ry - lick + s, s, lick, fire.alpha(0.8))
                if n > 0.75, lick > s { c.rect(x, f.eyeY - f.ry - lick + s, s, s, gold.alpha(0.7)) }
            }
        }
        c.ellipse(f.x, f.eyeY, f.rx + s, f.ry, fire)
        c.ellipse(f.x, f.eyeY, f.rx - s, max(1, f.ry - s), gold)
        c.ellipse(f.x + look, f.eyeY, max(1, f.rx / 4), max(1, f.ry - s), C(0xFFE08A))
        // the slit
        let sw = tall ? 2 * s : s
        c.rect(f.x + look - sw / 2, f.eyeY - f.ry + s, sw, f.ry * 2 - s, C(0x000000))
        if tall { c.rect(f.x + look - sw / 2 - s, f.eyeY - s, sw + 2 * s, 3 * s, C(0x000000)) }
    }

    /// The Eye's slit looking left and right, the lava glowing, the floor's cracks pulsing, and ash falling.
    static func mountDoomLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = mountDoomTower(c, g), v = mountDoomVolcano(c, g)
        let twoPi: Double = 2 * Double.pi
        let look = Int((sin(t * twoPi / 6) * Double(f.rx - 3 * s)).rounded())
        mountDoomEye(c, g, look: look, flick: Int(t * 9))
        mountDoomHorns(c, g)
        // lava glow: each streak breathing, with a bright bead running down it
        for i in 0..<mountDoomStreakCount(c) {
            let pts = mountDoomStreak(c, g, i)
            guard !pts.isEmpty else { continue }
            let a: Double = 0.15 + 0.25 * (0.5 + 0.5 * sin(t * 1.4 + Double(i) * 1.7))
            for p in pts { c.rect(p.x, p.y, s, 1, C(0xFFB03A, a * (1 - p.k))) }
            let bead = pts[Int(rings2Phase(t, 4 + Double(i % 3), offset: Double(i)) * Double(pts.count)) % pts.count]
            c.rect(bead.x, bead.y, s, 2 * s, C(0xFFE08A, 0.8))
        }
        let crater: Double = 0.5 + 0.5 * sin(t * twoPi / 3)
        c.ellipse(v.x, v.top, v.crater + 2 * s, 3 * s, C(0xFFB03A, 0.15 + 0.2 * crater))
        for (j, crack) in mountDoomCracks(c, g).enumerated() {
            let a: Double = 0.2 + 0.4 * (0.5 + 0.5 * sin(t * 1.1 + Double(j) * 2.3))
            for p in crack { c.px(p.x, p.y, C(0xFFB03A, a)) }
        }
        // ash
        for i in 0..<(tall ? 70 : 28) {
            let fall: Double = 5 + noise(i * 4 + 920) * 7, drift: Double = 3 + noise(i * 4 + 921) * 5
            let x = Int((noise(i * 4 + 922) * Double(c.w) + t * drift).truncatingRemainder(dividingBy: Double(c.w)))
            let y = Int((noise(i * 4 + 923) * Double(g) + t * fall).truncatingRemainder(dividingBy: Double(g)))
            c.rect(x, y, s, s, C(noise(i * 4 + 924) > 0.7 ? 0xC8B4A4 : 0x6A5A54, 0.55))
        }
    }
}
