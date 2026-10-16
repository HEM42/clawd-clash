import Foundation

// Close Encounters: Devils Tower.

let clawdbergScenes9: [Location: Place] = [
    .devilsTower: Place(name: "Devils Tower", panel: 0x120E22, still: Scenes.devilsTower, moving: Scenes.devilsTowerLife),
]

/// The five notes, as the colours the landing site's light board and the mothership flash them in.
private let ceNotes: [UInt32] = [0xF2643A, 0xF2D23A, 0x3AD2F2, 0xD23AF2, 0xF2F2F2]

// MARK: - Devils Tower

extension Scenes {
    /// Where things stand at the tower: its middle, its flat top's row and half-width, its foot's half-width, and the
    /// mothership's middle and radii.
    private static func ceFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, top: Int, topHW: Int, footHW: Int,
                                                                 ship: (x: Int, y: Int, rx: Int, ry: Int)) {
        let s = unit(g), tall = isTall(c)
        let cx = c.w * 60 / 100
        if tall {
            return (cx, g - 170 * s, 40 * s, 112 * s, (cx - 30 * s, g - 232 * s, 150 * s, 30 * s))
        }
        return (cx, 15 * s, 22 * s, 62 * s, (cx - 40 * s, -3 * s, 120 * s, 12 * s))
    }

    /// The tower's left and right edge on row `y`: straight fluted sides that flare out into the talus at the foot.
    private static func ceEdges(_ f: (cx: Int, top: Int, topHW: Int, footHW: Int, ship: (x: Int, y: Int, rx: Int, ry: Int)),
                                y: Int, g: Int) -> (Int, Int) {
        let k = Double(y - f.top) / Double(max(1, g - f.top))
        let body = Double(f.topHW) * (1 + 0.35 * k)
        let apron = max(0, k - 0.78) / 0.22
        let hw = body + (Double(f.footHW) - body) * apron * apron
        return (f.cx - Int(hw), f.cx + Int(hw))
    }

    /// Devils Tower on the night of the landing: a deep violet sky full of stars, the low Wyoming hills, and the
    /// flat-topped tower of grey-violet fluted columns rising over its scree. At its foot the landing site: the
    /// scaffold with the big light board, floodlights on stands and a row of runway lamps. Above, the mothership
    /// fills the sky, a dark dome bristling with lights. On the screen saver the whole tower stands up out of the
    /// hills, the mothership hanging huge over it with its spires and its glowing underside.
    static func devilsTower(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = ceFrame(c, g)
        c.gradient(0, g, C(0x0A0820), C(0x2E2450), bands: 7)
        c.stars(0, g * 2 / 3, density: tall ? 160 : 110, seed: 9)
        // The hills.
        c.dunes(base: g - (tall ? 40 : 14) * s, amp: Double((tall ? 10 : 4) * s), freq: 0.018, phase: 0.6, bottom: g, C(0x1C1834))
        c.dunes(base: g - (tall ? 20 : 8) * s, amp: Double((tall ? 6 : 3) * s), freq: 0.04, phase: 2.2, bottom: g, C(0x16122A))
        // The glow of the landing site lighting the tower's foot.
        c.ellipse(f.cx, g, f.footHW + 60 * s, (tall ? 36 : 12) * s, C(0x8AA8F0, 0.08))
        // The tower.
        let colW = (tall ? 4 : 3) * s
        for y in f.top..<g {
            let e = ceEdges(f, y: y, g: g)
            let width = e.1 - e.0
            c.rect(e.0, y, width, 1, C(0x463C5A))
            // The fluting: light and dark columns that draw together towards the top; the scree at the foot is
            // broken rubble instead.
            let k = Double(y - f.top) / Double(max(1, g - f.top))
            let half = Double(max(1, width)) / 2
            let n = Double(f.topHW * 2 / colW)
            for x in e.0..<e.1 {
                let u = (Double(x - f.cx) / half + 1) / 2
                let rubble = k > 0.86 && noise(x * 7 + y * 131) < (k - 0.86) * 7
                if rubble {
                    c.px(x, y, noise(x * 3 + y * 17) > 0.5 ? C(0x3A3252) : C(0x2E2844))
                } else if Int(u * n) % 2 == 0 {
                    c.px(x, y, C(0x54486A))
                } else if Int(u * n * 2) % 4 == 3 {
                    c.px(x, y, C(0x342C4A))
                }
            }
            c.rect(e.0, y, 2 * s, 1, C(0x6A5E82)); c.rect(e.1 - 2 * s, y, 2 * s, 1, C(0x2A2240))
            let lift = Double(y - f.top) / Double(max(1, g - f.top))
            if lift > 0.6 { c.rect(e.0, y, width, 1, C(0x9AB0F0, (lift - 0.6) * 0.3)) }
        }
        // The flat top and its broken rim.
        c.rect(f.cx - f.topHW, f.top - s, f.topHW * 2, 2 * s, C(0x5E5276))
        for i in 0..<8 {
            let bx = f.cx - f.topHW + Int(noise(i + 2000) * Double(f.topHW * 2)), h = (1 + Int(noise(i + 2010) * 3)) * s
            c.rect(bx, f.top - h, 2 * s, h, C(0x5E5276))
        }
        // The scree: boulders round the foot.
        for i in 0..<(tall ? 22 : 10) {
            let bx = f.cx + Int((noise(i + 2100) - 0.5) * Double(f.footHW * 2))
            let by = g - Int(noise(i + 2110) * Double((tall ? 18 : 5) * s))
            c.ellipse(bx, by, (2 + Int(noise(i + 2120) * 3)) * s, s, C(0x3A3252))
        }
        // The landing site: the scaffold and its light board, off to the left of the foot.
        let site = f.cx - f.footHW - (tall ? 40 : 30) * s
        let bw = (tall ? 40 : 24) * s, bh = (tall ? 26 : 12) * s
        let boardTop = g - bh - (tall ? 22 : 8) * s
        for px in stride(from: site - bw / 2, through: site + bw / 2, by: bw / 4) { c.rect(px, boardTop, s, g - boardTop, C(0x5A5A6A)) }
        for y in stride(from: boardTop + bh, to: g, by: 4 * s) { c.rect(site - bw / 2, y, bw + s, s, C(0x5A5A6A)) }
        c.rect(site - bw / 2, boardTop, bw + s, bh, C(0x1A1824))
        let cell = (tall ? 4 : 2) * s
        for gy in stride(from: boardTop + s, to: boardTop + bh - cell, by: cell + s) {
            for gx in stride(from: site - bw / 2 + s, to: site + bw / 2 - cell + s, by: cell + s) {
                c.rect(gx, gy, cell, cell, C(0x3A3850))
            }
        }
        // Floodlights on stands either side, pointing up.
        for fx in [site - bw / 2 - 14 * s, f.cx + f.footHW + 24 * s, c.w * 8 / 100] {
            let stand = (tall ? 18 : 9) * s
            c.rect(fx, g - stand, s, stand, C(0x4A4A5A))
            c.rect(fx - 2 * s, g - stand - 3 * s, 5 * s, 3 * s, C(0x2A2A36))
            c.rect(fx - s, g - stand - 3 * s, 3 * s, s, C(0xF8F8FF))
            c.ellipse(fx, g - stand - 3 * s, 6 * s, 3 * s, C(0xE8F0FF, 0.18))
        }
        // The runway lamps along the ground.
        for lx in stride(from: 6 * s, to: c.w, by: 18 * s) {
            c.rect(lx, g - s, 2 * s, s, C(0xF8E8A0))
            c.rect(lx - s, g - 2 * s, 4 * s, 2 * s, C(0xF8E8A0, 0.2))
        }
        // The mothership: a dark dome with a glowing rim and its lights (lit by the moving layer).
        let m = f.ship
        if tall {
            // Spires on its back, like an upside-down city.
            for i in 0..<15 {
                let sx = m.x + Int((Double(i) / 14 - 0.5) * Double(m.rx) * 1.4)
                let h = (14 + Int(noise(i + 2200) * 40)) * s
                c.rect(sx, m.y - m.ry / 2 - h, 2 * s, h, C(0x1A1830))
                c.rect(sx, m.y - m.ry / 2 - h, 2 * s, s, C(0xF8E0B0))
            }
            c.ellipse(m.x, m.y - m.ry / 3, m.rx * 2 / 3, m.ry, C(0x16142A))
        }
        c.ellipse(m.x, m.y, m.rx + 4 * s, m.ry + 2 * s, C(0xC8D8FF, 0.12))
        c.ellipse(m.x, m.y, m.rx, m.ry, C(0x1A1830))
        c.ellipse(m.x, m.y + m.ry / 3, m.rx - 6 * s, m.ry * 2 / 3, C(0x24223E))
        c.ellipse(m.x, m.y + m.ry / 2, m.rx / 3, m.ry / 3, C(0xF0F4FF, 0.55))
        // The ground: dark prairie scrub.
        c.ground(g, C(0x16122A), edge: C(0x3A3260), speck: C(0x221C3A), seed: 77)
    }

    /// The lights of the mothership for its pulsing: positions in rings round the underside, with each one's ring.
    private static func ceLights(_ m: (x: Int, y: Int, rx: Int, ry: Int), s: Int) -> [(x: Int, y: Int, ring: Int)] {
        var out: [(x: Int, y: Int, ring: Int)] = []
        for ring in 0..<3 {
            let k = 0.92 - Double(ring) * 0.26
            let n = 26 - ring * 7
            for i in 0..<n {
                let a = Double(i) / Double(n) * .pi
                let x = m.x + Int(cos(a) * Double(m.rx) * k)
                let y = m.y + Int(sin(a) * Double(m.ry) * k)
                out.append((x, y, ring))
            }
        }
        return out
    }

    /// What moves at the tower: the mothership's lights pulsing round it in the five notes' colours, its belly
    /// glowing brighter and dimmer, the light board at the landing site flashing in answer, the floodlight beams
    /// sweeping the sky, and one small scout ship zipping across.
    static func devilsTowerLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = ceFrame(c, g)
        let m = f.ship
        // The beams, faint, crossing.
        let site = f.cx - f.footHW - (tall ? 40 : 30) * s
        for (i, fx) in [site - (tall ? 34 : 26) * s, f.cx + f.footHW + 24 * s].enumerated() {
            let a = sin(t * 0.4 + Double(i) * 2) * 0.35 + (i == 0 ? 0.2 : -0.2)
            let base = Double(g - (tall ? 21 : 12) * s)
            let len = Double(g) * 1.1
            c.glowLine(Double(fx), base, Double(fx) + sin(a) * len, base - cos(a) * len, core: C(0xE8F0FF, 0.1),
                       glow: C(0xC8D8FF, 0.06), coreR: Double(s) * 1.5, glowR: Double(s) * 5)
        }
        // The belly glow.
        let pulse = sin(t * 2.2) * 0.5 + 0.5
        c.ellipse(m.x, m.y + m.ry / 2, m.rx / 3 + 4 * s, m.ry / 3 + s, C(0xF8FAFF, 0.15 + pulse * 0.3))
        // The lights: a chase running round the rings in the notes' colours.
        let note = Int(t * 2.5)
        for (i, l) in ceLights(m, s: s).enumerated() {
            let phase = (Double(i) * 0.37 + t * 3 + Double(l.ring)).truncatingRemainder(dividingBy: 5)
            let col = C(ceNotes[(note + l.ring + i / 6) % 5])
            let on = phase < 2.5
            let r = Double(s) * (on ? 1.0 : 0.6)
            c.glowLine(Double(l.x), Double(l.y), Double(l.x) + 0.1, Double(l.y), core: on ? col : col.alpha(0.5),
                       glow: col.alpha(on ? 0.6 : 0.2), coreR: r, glowR: r * 2.6)
        }
        // The light board answering, one note at a time.
        let bw = (tall ? 40 : 24) * s, bh = (tall ? 26 : 12) * s
        let boardTop = g - bh - (tall ? 22 : 8) * s
        let cell = (tall ? 4 : 2) * s
        let lit = note % 5
        var col = 0
        for gx in stride(from: site - bw / 2 + s, to: site + bw / 2 - cell + s, by: cell + s) {
            if col % 5 == lit {
                for gy in stride(from: boardTop + s, to: boardTop + bh - cell, by: cell + s) {
                    c.rect(gx, gy, cell, cell, C(ceNotes[lit]))
                }
            }
            col += 1
        }
        // A scout ship streaking across, every 11 seconds.
        let run = t.truncatingRemainder(dividingBy: 11)
        if run < 2.4 {
            let x = Double(c.w) * (run / 2.4) * 1.2 - Double(c.w) * 0.1
            let y = Double(tall ? g / 2 : g / 3) + sin(run * 4) * Double(3 * s)
            c.glowLine(x - Double(14 * s), y + Double(2 * s), x, y, core: C(0xFFD8A0, 0.4), glow: C(0xFF8A3A, 0.15),
                       coreR: Double(s) * 0.6, glowR: Double(s) * 2)
            c.glowLine(x, y, x + 0.1, y, core: C(0xFFF4E0), glow: C(0xFF6A3A), coreR: Double(s) * 1.2, glowR: Double(s) * 3.5)
        }
    }
}
