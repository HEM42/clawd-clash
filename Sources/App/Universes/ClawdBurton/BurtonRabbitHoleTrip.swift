import CoreGraphics
import Foundation

extension BurtonTrip {
    /// Down the Rabbit Hole. The ground gives way: the old place slides up and away above us, slowly and then faster,
    /// roots dangling from its underside (0–0.3), and we drop down a long earthy hole, its walls in bands of soil and
    /// stone, with roots reaching in and dust streaking past. Things fall with us, slower or faster, turning as they
    /// go: clocks and pocket watches, teacups on saucers, a teapot, books, and a grand piano drifting by in the middle
    /// (0.25–0.8). The fall slows, the hole opens out at the bottom and we float down into the new place, which rises
    /// to fill the frame and settles (0.7–1).
    func drawRabbitHole(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let shaft = H * 5, end = H + shaft
        let cam = end * Self.ease(k)
        let speed = end * 6 * k * (1 - k)            // how fast we fall, art pixels per whole trip
        let u = H >= 120 ? 2 : 1

        // The two places: the old one above us, the new one below.
        if cam < H { ctx.draw(old, in: r.offsetBy(dx: 0, dy: CGFloat(cam) * px)) }
        if end - cam < H { ctx.draw(new, in: r.offsetBy(dx: 0, dy: -CGFloat(end - cam) * px)) }

        // The hole, row by row: soil walls in bands, the dark back of the hole between them.
        let bands: [UInt32] = [0x5A3A24, 0x4A3020, 0x63432A, 0x3E2A1C, 0x54402E]
        for y in 0..<c.h {
            let d = Double(y) + cam
            guard d >= H, d < end else { continue }
            let band = Int(d / (H * 0.17)), soil = C(bands[(band * 7 + band / 3) % bands.count])
            let lip = Self.span(d, H, H + H * 0.25), open = 1 - Self.span(d, end - H * 0.4, end)
            let waver = sin(d * 0.045) * W * 0.025 + (noise(Int(d / 3)) - 0.5) * 2
            let left = (W * (0.16 + 0.1 * (1 - lip)) + waver) * open
            let right = W - (W * (0.16 + 0.1 * (1 - lip)) - waver * 0.7 + sin(d * 0.03 + 2) * W * 0.02) * open
            c.rect(0, y, Int(left), 1, soil)
            // The back of the hole, a little lighter down the middle where the light from above still falls.
            let ring = Int(d * 0.5 / (H * 0.23)) % 2 == 0
            let span = right - left
            c.rect(Int(left), y, max(0, Int(right) - Int(left)), 1, ring ? C(0x2A1E26) : C(0x241A22))
            c.rect(Int(left + span * 0.22), y, Int(span * 0.56), 1, ring ? C(0x34262E) : C(0x2E222A))
            c.rect(Int(left + span * 0.36), y, Int(span * 0.28), 1, ring ? C(0x3E2E34) : C(0x382A30))
            c.rect(Int(right), y, c.w - Int(right), 1, soil)
            c.px(Int(left) - 1, y, C(0x7A5A3A)); c.px(Int(right), y, C(0x2E1E14))
        }
        // Stones in the walls and roots reaching in, every few yards of the fall.
        let slot = max(10, H * 0.22)
        let first = Int(max(H, cam) / slot), last = Int(min(end, cam + H) / slot)
        if first <= last {
            for n in first...last {
                let d = Double(n) * slot + noise(n * 17) * slot, y = d - cam
                guard d > H, d < end - H * 0.4 else { continue }
                let onLeft = n % 2 == 0
                let wall = onLeft ? W * (0.16 + noise(n * 5) * 0.08) : W * (0.84 - noise(n * 5) * 0.08)
                let sx = onLeft ? wall - W * 0.07 * noise(n * 3) - 4 : wall + W * 0.07 * noise(n * 3) + 4
                c.ellipse(Int(sx), Int(y), 3 * u, 2 * u, C(0x8A8070))
                c.ellipse(Int(sx), Int(y) - u / 2, 2 * u, u, C(0xA89E8C))
                let reach = Double(u) * (6 + 10 * noise(n * 11)), dir = onLeft ? 1.0 : -1.0
                let mx = wall + dir * reach * 0.6, my = y + reach * 0.3
                let col = C(0x8A6A44)
                c.glowLine(wall - dir, y, mx, my, core: col, glow: C(0, 0), coreR: 0.5 * Double(u),
                           glowR: 0.55 * Double(u))
                c.glowLine(mx, my, mx + dir * reach * 0.4, my + reach * 0.6, core: col, glow: C(0, 0),
                           coreR: 0.4 * Double(u), glowR: 0.45 * Double(u))
            }
        }
        // Roots dangling from under the old place.
        if cam < H * 1.6 {
            for n in 0..<Int(W / 6) {
                let x = Double(n) * 6 + noise(n * 13) * 4, len = H * (0.04 + 0.12 * noise(n * 7))
                let y0 = H - cam
                c.glowLine(x, y0, x + (noise(n * 9) - 0.5) * 6, y0 + len, core: C(0x6A4A2E), glow: C(0, 0),
                           coreR: 0.5 * Double(u), glowR: 0.55 * Double(u))
            }
        }
        // Dust streaking up past us as we fall.
        let streak = min(H * 0.5, speed / 60)
        if streak > 1 {
            for n in 0..<40 {
                let x = W * (0.25 + 0.5 * noise(n * 3)), d = noise(n * 3 + 1) * H * 3
                let y = (d - cam * 1.4).truncatingRemainder(dividingBy: H * 3) + H * 3
                let sy = y.truncatingRemainder(dividingBy: H * 3) - H
                c.rect(Int(x), Int(sy), 1, Int(streak * (0.5 + noise(n * 3 + 2))), C(0xB8A890, 0.35))
            }
        }

        // The things falling with us: each crosses the frame at its own moment, the far ones slower and dimmer.
        let things: [(kind: Int, at: Double, x: Double, depth: Double, spin: Double)] = [
            (0, 0.28, 0.4, 0.5, 40), (2, 0.32, 0.64, 0.9, -30), (3, 0.35, 0.28, 0.3, 15), (4, 0.39, 0.34, 0.7, 25),
            (1, 0.43, 0.7, 0.6, 60), (2, 0.46, 0.3, 0.4, -40), (5, 0.52, 0.54, 0.45, 0), (0, 0.55, 0.26, 0.75, 30),
            (3, 0.58, 0.68, 0.8, -20), (1, 0.61, 0.4, 0.35, 50), (0, 0.64, 0.66, 0.95, -50), (2, 0.68, 0.42, 0.65, 35),
            (4, 0.71, 0.7, 0.4, -25), (1, 0.74, 0.56, 0.85, 45),
        ]
        for (i, th) in things.enumerated().sorted(by: { $0.element.depth < $1.element.depth }) {
            // Mid-frame at its moment; it rises past us at its own pace (the near ones faster and bigger).
            let rate = H * (2.6 + 5 * th.depth)
            let bob: Double = sin(k * 9 + Double(i)) * H * 0.02
            let y: Double = H * 0.55 - (k - th.at) * rate + bob
            let sway: Double = sin(k * 5 + Double(i) * 2) * W * 0.03
            let x: Double = W * th.x + sway
            guard y > -H * 0.4, y < H * 1.4 else { continue }
            let dim = 0.55 + 0.45 * th.depth
            if th.kind == 5 {
                Self.holePiano(c, x: Int(x), y: Int(y), s: max(2, Int((H / 70).rounded())), dim: dim)
            } else {
                let s = min(4, max(1, Int((H / 45 * (0.6 + 0.6 * th.depth)).rounded())))
                let o = 10 * s + 2, n = 2 * o + 1
                let art = PixelCanvas(n, n)
                Self.holeThing(art, kind: th.kind, o: o, s: s, dim: dim)
                let turn = th.spin * (k - th.at) * 6
                let mid = Double(o) + 0.5
                c.paste(art.rotated(turn, about: (mid, mid), into: n, n, at: (mid, mid)), x: Int(x) - o, y: Int(y) - o)
            }
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// A colour darkened to `dim` of itself, for the things further off.
    private static func holeDim(_ hex: UInt32, _ dim: Double) -> Px {
        let p = C(hex)
        return Px(r: UInt8(Double(p.r) * dim), g: UInt8(Double(p.g) * dim), b: UInt8(Double(p.b) * dim), a: 255)
    }

    /// One small falling thing, centred on (`o`, `o`) of `p`, `s` pixels to its pixel: a clock with two bells (0), a
    /// pocket watch (1), a teacup on its saucer (2), a book (3) or a teapot (4), each with an ink edge.
    private static func holeThing(_ p: PixelCanvas, kind: Int, o: Int, s: Int, dim: Double) {
        func d(_ hex: UInt32) -> Px { holeDim(hex, dim) }
        let ink = d(0x16161B), m = Double(o) + 0.5, line = max(0.5, Double(s) * 0.45)
        /// A box with an ink edge round it.
        func box(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ col: Px) {
            p.rect(x - 1, y - 1, w + 2, h + 2, ink); p.rect(x, y, w, h, col)
        }
        switch kind {
        case 0, 1:
            // A clock face in a brass rim with bells on top (or a watch on its ring), its hands at odd hours.
            let rr = kind == 0 ? 6 * s : 5 * s
            if kind == 0 {
                for dx in [-1, 1] {
                    p.circle(o + dx * (rr - s), o - rr + s, 2 * s + 1, ink)
                    p.circle(o + dx * (rr - s), o - rr + s, 2 * s, d(0xC89A3A))
                }
            } else {
                p.circle(o, o - rr - s, s + 2, ink); p.circle(o, o - rr - s, s + 1, d(0xC89A3A))
                p.circle(o, o - rr - s, max(0, s - 1), ink)
            }
            p.circle(o, o, rr + 1, ink); p.circle(o, o, rr, d(0xC89A3A)); p.circle(o, o, rr - s, d(0xF2EEE3))
            for q in 0..<12 {
                let a = Double(q) * .pi / 6, at = Double(rr - s) - 1.5
                p.px(o + Int((cos(a) * at).rounded()), o + Int((sin(a) * at).rounded()), q % 3 == 0 ? ink : d(0x8A8478))
            }
            p.glowLine(m, m, m + Double(rr) * 0.5, m - Double(rr) * 0.2, core: ink, glow: C(0, 0), coreR: line,
                       glowR: line + 0.05)
            p.glowLine(m, m, m - Double(rr) * 0.12, m - Double(rr) * 0.68, core: d(0xA8302A), glow: C(0, 0),
                       coreR: line * 0.8, glowR: line * 0.8 + 0.05)
        case 2:
            // A white cup with a violet band, tea in it, on a saucer.
            box(o - 9 * s, o + 3 * s, 18 * s, s, d(0xD8D2C4)); p.rect(o - 7 * s, o + 4 * s, 14 * s, s, d(0xA8A294))
            box(o + 5 * s, o - 2 * s, 3 * s, 3 * s, d(0xF2EEE3))
            box(o - 5 * s, o - 3 * s, 10 * s, 6 * s, d(0xF2EEE3))
            p.rect(o - 5 * s, o - s, 10 * s, s, d(0x6B5BD6)); p.rect(o - 5 * s, o + 2 * s, 10 * s, s, d(0xD8D2C4))
            p.rect(o - 4 * s, o - 3 * s, 8 * s, s, d(0x8A5A30))
        case 3:
            // A red book, its pages showing, a gold title on the cover.
            box(o - 6 * s, o - 4 * s, 12 * s, 8 * s, d(0x8A2A2A)); p.rect(o - 5 * s, o + 3 * s, 11 * s, s, d(0xF2EEE3))
            p.rect(o - 6 * s, o - 4 * s, 2 * s, 8 * s, d(0x5A1A1A)); p.rect(o - 2 * s, o - 2 * s, 6 * s, s, d(0xC8A04A))
            p.rect(o - s, o, 4 * s, s, d(0xC8A04A))
        default:
            // A round teal teapot with a spout, a handle and a lid knob.
            p.glowLine(m + 5 * Double(s), m, m + 9.5 * Double(s), m - 3.5 * Double(s), core: ink, glow: C(0, 0),
                       coreR: Double(s) * 0.9 + 1, glowR: Double(s) * 0.9 + 1.05)
            p.glowLine(m + 5 * Double(s), m, m + 9.5 * Double(s), m - 3.5 * Double(s), core: d(0x3A9A8A), glow: C(0, 0),
                       coreR: Double(s) * 0.9, glowR: Double(s) * 0.95)
            p.ellipse(o - 6 * s, o, 2 * s + 1, 3 * s + 1, ink); p.ellipse(o - 6 * s, o, 2 * s, 3 * s, d(0x2A7A6C))
            p.ellipse(o, o, 6 * s + 1, 5 * s + 1, ink); p.ellipse(o, o, 6 * s, 5 * s, d(0x3A9A8A))
            p.rect(o - 6 * s, o - s, 12 * s + 1, s, d(0xF2EEE3)); p.rect(o - 3 * s, o - 3 * s, 2 * s, s, d(0x6ACABA))
            p.ellipse(o, o - 5 * s, 2 * s + 1, s + 1, ink); p.ellipse(o, o - 5 * s, 2 * s, s, d(0x2A7A6C))
            p.rect(o - s / 2, o - 7 * s, max(1, s), s, d(0xF2EEE3))
        }
    }

    /// A black grand piano drifting by, centred on (`x`, `y`): the curved case with its lid propped open, the keys,
    /// three legs.
    private static func holePiano(_ c: PixelCanvas, x: Int, y: Int, s: Int, dim: Double) {
        func d(_ hex: UInt32) -> Px { holeDim(hex, dim) }
        let ink = C(0x0E0E12), body = d(0x3A3A46), shine = d(0x8A8A9C)
        // The case: a long body, the curved tail at the right.
        c.rect(x - 16 * s - 1, y - 3 * s - 1, 26 * s + 2, 6 * s + 2, ink)
        c.ellipse(x + 10 * s, y, 7 * s + 1, 3 * s + 1, ink)
        c.rect(x - 16 * s, y - 3 * s, 26 * s, 6 * s, body); c.ellipse(x + 10 * s, y, 7 * s, 3 * s, body)
        c.rect(x - 16 * s, y - 3 * s, 33 * s, s, shine)
        // The lid, propped up on its stick.
        for q in 0..<(9 * s) {
            let w = 30 * s - q * 3
            if w > 0 { c.rect(x - 13 * s + q * 2, y - 4 * s - q, w, 1, q == 0 ? shine : body) }
        }
        c.rect(x + 6 * s, y - 9 * s, max(1, s / 2), 6 * s, d(0x8A8070))
        // The keys at the front.
        c.rect(x - 19 * s, y - 2 * s, 4 * s, 3 * s, d(0xF2EEE3))
        for q in 0..<3 { c.rect(x - 19 * s, y - 2 * s + q * s, 2 * s, max(1, s / 2), ink) }
        // Three legs.
        for lx in [x - 14 * s, x + 2 * s, x + 14 * s] {
            c.rect(lx, y + 3 * s, 2 * s, 5 * s, body); c.rect(lx, y + 8 * s, 2 * s, s, ink)
        }
    }
}
