import CoreGraphics
import Foundation

// The Jack-o'-Lantern (`BurtonWipe.jackOLantern`): a huge carved pumpkin swings in on its vine, and its grin opens
// wider and wider, the new place glowing inside, until the mouth fills the screen.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Night falls a little over the old
    /// place as a huge carved pumpkin swings in from the top left on its vine, overshoots and settles in the middle,
    /// its triangle eyes and zigzag grin flickering with candlelight; through the grin, warm with the candle's glow,
    /// the new place shows (0–0.34). Then the grin opens wider and wider, the teeth shrinking away, as the camera
    /// pushes in on the mouth, the glow inside fading, until the mouth is all there is (0.3–0.95). The pumpkin is pixel
    /// art drawn on the art's own grid at every size, the carved edges lit.
    func drawJackOLantern(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let rx = min(W * 0.3, H * 0.55), ry = rx * 0.82, mc = 0.3
        // The swing in on the vine, the grin opening, and the push in on the mouth.
        let swing = Self.span(k, 0, 0.34), open = Self.ease(Self.span(k, 0.3, 0.95))
        let L = max(H * 1.3, W * 0.6), pivot = (x: W / 2, y: H * 0.53 - L)
        var turn = -1.4 * pow(1 - swing, 2.2) * cos(swing * 2.5 * .pi)
        turn += 0.035 * sin(k * 19) * swing * (1 - open)
        let Z = max(W / 2 / (0.4 * rx), H / 2 / (0.42 * ry)) * 1.15
        let z = exp(log(Z) * pow(open, 1.7))
        let down = (x: sin(turn), y: cos(turn)), right = (x: cos(turn), y: -sin(turn))
        let hung = (x: pivot.x + L * down.x, y: pivot.y + L * down.y)
        let mouthAt = (x: hung.x + mc * ry * down.x, y: hung.y + mc * ry * down.y)
        let g = Self.ease(Self.span(k, 0.34, 0.9))
        let anchor = (x: mouthAt.x + (W / 2 - mouthAt.x) * g, y: mouthAt.y + (H / 2 - mouthAt.y) * g)
        let centre = (x: anchor.x - z * mc * ry * down.x, y: anchor.y - z * mc * ry * down.y)
        let pose = JackPose(centre: centre, right: right, down: down, z: z, rx: rx, ry: ry, mc: mc, open: open)

        // Night falling a little over the old place.
        ctx.draw(old, in: r)
        ctx.setFillColor(rgb(0x140E2C, 0.4 * Self.ease(Self.span(k, 0, 0.3)))); ctx.fill(r)

        // The vine it swings on, while it is still in sight.
        if open < 0.5 {
            let vine = C(0x2E3A12), stem = (x: centre.x - 1.0 * ry * z * down.x, y: centre.y - 1.0 * ry * z * down.y)
            var prev = (x: pivot.x, y: pivot.y)
            for i in 1...16 {
                let f = Double(i) / 16
                let wig = sin(f * 9) * rx * 0.05 * (1 - f)
                let q = (x: pivot.x + (stem.x - pivot.x) * f + wig * right.x,
                         y: pivot.y + (stem.y - pivot.y) * f + wig * right.y)
                burtonLine(c, prev.x, prev.y, q.x, q.y, vine, max(0.8, rx * 0.025))
                prev = q
            }
        }
        // The pumpkin, and the mouth's opening, row by row.
        let flicker = 0.85 + 0.15 * noise(Int(k * 40) + 5300)
        let glowA = (0.6 - 0.45 * open) * (1 - Self.span(k, 0.78, 0.97)) * flicker
        let mouth = jackDraw(c, pose, flicker: flicker, glow: glowA)
        let rects = mouth.map { run in
            CGRect(x: r.minX + CGFloat(run.x0) * px, y: r.maxY - CGFloat(run.y + 1) * px,
                   width: CGFloat(run.x1 - run.x0) * px, height: px)
        }
        if !rects.isEmpty {
            ctx.saveGState(); ctx.clip(to: rects); ctx.draw(new, in: r); ctx.restoreGState()
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// Where the pumpkin is: its middle on the art grid, which way its right and its down point as it swings, how much
    /// it is blown up, its size, how far down its mouth sits, and how wide the grin is open.
    private struct JackPose {
        let centre: (x: Double, y: Double), right: (x: Double, y: Double), down: (x: Double, y: Double)
        let z: Double, rx: Double, ry: Double, mc: Double, open: Double
    }

    /// Which part of the carved face a point (`u` across, `v` down, the pumpkin's half-sizes 1) is in: 0 rind, 1 the
    /// mouth's opening, 2 a carved edge round it, 3 an eye or the nose full of flame, 5 the flame's edge there, 4 their
    /// carved edges. `eu` and `ev` are an art pixel in these units, for the edges.
    private static func jackFace(_ u: Double, _ v: Double, mc: Double, open: Double, eu: Double, ev: Double) -> Int {
        // The grin: a smile, its top and bottom edges zigzagging into teeth that shrink as it opens.
        let mw = 0.5 + 0.3 * open, au = abs(u)
        if au < mw + eu {
            let line = mc - 0.28 * u * u * (1 - 0.5 * open)
            let o = 0.07 + 0.55 * open
            let hh = o * pow(max(0, 1 - (u / mw) * (u / mw)), 0.6)
            let tooth = min(o * 0.8, 0.11) * (1 - open)
            let zig = (abs((u * 10).truncatingRemainder(dividingBy: 2)) - 1) * 0.025 * (1 - open)
            var top = line - hh + zig, bottom = line + hh + zig
            if abs(au - 0.3 * mw) < 0.07 { top += tooth }          // two teeth hanging down
            if au < 0.08 { bottom -= tooth }                        // one pushing up
            if v > top && v < bottom && au < mw { return 1 }
            if v > top - ev && v < bottom + ev && hh > 0.001 { return 2 }
        }
        // The eyes, triangles with their points up, and a small nose.
        for (ex, ey, s) in [(-0.38, -0.22, 1.0), (0.38, -0.22, 1.0), (0.0, 0.02, 0.45)] {
            let h = 0.3 * s, w = 0.2 * s
            let dy = v - (ey - h / 2), f = dy / h
            guard f > -ev / h, f < 1 + ev / h else { continue }
            let half = w * Self.clamp(f)
            if abs(u - ex) < half && f > 0 && f < 1 {
                return abs(u - ex) > half - eu * 2.5 || f > 1 - ev * 2.5 / h ? 5 : 3
            }
            if abs(u - ex) < half + eu * 1.2 { return 4 }
        }
        return 0
    }

    /// The pumpkin drawn on the art grid over its pose: ribbed orange rind lit from the top left with a dark edge, a
    /// green stem, the eyes and nose full of candle flame, the carved edges lit; over the mouth's opening a warm glow
    /// `glow` strong. Gives back the opening, as runs of art pixels along each row.
    private func jackDraw(_ c: PixelCanvas, _ p: JackPose, flicker: Double,
                          glow: Double) -> [(y: Int, x0: Int, x1: Int)] {
        let reach = p.z * max(p.rx, p.ry) * 1.2
        let x0 = max(0, Int(p.centre.x - reach)), x1 = min(c.w, Int(p.centre.x + reach) + 1)
        let y0 = max(0, Int(p.centre.y - reach)), y1 = min(c.h, Int(p.centre.y + reach) + 1)
        guard x0 < x1, y0 < y1 else { return [] }
        let eu = 1.3 / (p.z * p.rx), ev = 1.3 / (p.z * p.ry), edge = 1.2 / (p.z * min(p.rx, p.ry))
        let rind: [Px] = [C(0x8A3A08), C(0xC85A12), C(0xE0701A), C(0xF08A2A)]
        let rim = C(0x5A2408), flesh = C(0xFFD27A), flameEdge = C(0xF0A030)
        let flame = lerp(C(0xFFC850), C(0xFFE890), (flicker - 0.85) / 0.15)
        let warm = C(0xFF9A30, glow), stem = C(0x4A5A1A), stemLit = C(0x6A7A2A)
        var runs: [(y: Int, x0: Int, x1: Int)] = []
        for y in y0..<y1 {
            var start = -1
            for x in x0..<x1 {
                let dx = (Double(x) + 0.5 - p.centre.x) / p.z, dy = (Double(y) + 0.5 - p.centre.y) / p.z
                let u = (dx * p.right.x + dy * p.right.y) / p.rx, v = (dx * p.down.x + dy * p.down.y) / p.ry
                var inMouth = false
                defer {
                    if inMouth {
                        if start < 0 { start = x }
                    } else if start >= 0 { runs.append((y, start, x)); start = -1 }
                }
                // The stem, curving off to the right.
                if v < -0.86 && v > -1.14 {
                    let su = u - 0.12 * pow(-0.86 - v, 1.3) * 4
                    if abs(su) < 0.07 { c.px(x, y, su < 0 ? stemLit : stem); continue }
                }
                let d2 = u * u + v * v
                guard d2 <= 1 else { continue }
                switch Self.jackFace(u, v, mc: p.mc, open: p.open, eu: eu, ev: ev) {
                case 1:
                    inMouth = true
                    if glow > 0.01 { c.px(x, y, warm) }
                case 2, 4: c.px(x, y, flesh)
                case 3: c.px(x, y, flame)
                case 5: c.px(x, y, flameEdge)
                default:
                    if 1 - d2.squareRoot() < edge { c.px(x, y, rim); continue }
                    // Ribs: five lobes curving round, their grooves dark; lit from the top left.
                    let w = u / max(0.25, (1 - v * v)).squareRoot()
                    let lobe = (w + 1) * 2.5, e = abs(lobe - lobe.rounded(.down) - 0.5) * 2
                    let shade = -0.55 * u - 0.45 * v + (1 - e) * 0.45 - (e > 0.86 ? 0.5 : 0)
                    c.px(x, y, rind[shade > 0.5 ? 3 : shade > 0 ? 2 : shade > -0.5 ? 1 : 0])
                }
            }
            if start >= 0 { runs.append((y, start, x1)) }
        }
        return runs
    }
}
