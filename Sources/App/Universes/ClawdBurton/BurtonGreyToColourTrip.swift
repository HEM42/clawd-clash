import CoreGraphics
import Foundation

// Grey to Colour (`BurtonWipe.greyToColour`): the old place drains to the grey-blue of Corpse Bride's living world, a
// flurry of blue butterflies sweeps across, and behind them the new place blooms into colour.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. The colour drains out of the old
    /// place from the top down, a ragged edge running down the picture with drips ahead of it, and leaves it the cold
    /// grey-blue of the land of the living (0.02–0.32); a flurry of blue butterflies sweeps across from left to
    /// right, wings flickering, the near ones bigger (0.26–0.8); where they have passed the new place is there, still
    /// grey-blue, and colour blooms out over it in round patches that open one after another behind the flurry until
    /// they join (0.36–0.95). The butterflies are pixel art; the old and new places are greyed on the art's grid.
    func drawGreyToColour(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h), rows = c.h
        let drain = Self.ease(Self.span(k, 0.02, 0.32))
        let sweep = Self.span(k, 0.26, 0.8)
        let front = -W * 0.36 + W * 1.72 * sweep
        let flick = Int(k * 2.0 * 15)
        /// Where the flurry's edge is along row `j` (from the top): the new place to its left, the old to its right.
        func edge(_ j: Int) -> Double {
            front + (noise(j / 2 * 13 + flick * 3 + 77) - 0.5) * W * 0.03 + sin(Double(j) / H * 7 + k * 9) * W * 0.03
        }
        /// A row `j` (from the top) on screen, from art column `x0` to `x1`.
        func strip(_ j: Int, _ x0: Double, _ x1: Double) -> CGRect {
            CGRect(x: r.minX + CGFloat(x0.rounded()) * px, y: r.maxY - CGFloat(j + 1) * px,
                   width: CGFloat((x1 - x0).rounded()) * px, height: px)
        }

        // The old place, drained from the top down to the drips' ends, ahead of the flurry.
        ctx.draw(old, in: r)
        if drain > 0 {
            // How far down each column has drained: the edge a little uneven, some columns dripping on ahead.
            let col = max(1, Int((W / 90).rounded()))
            let depths: [Int] = stride(from: 0, to: c.w, by: col).map { x in
                let i = x / col
                let drip = noise(i * 7 + 11) < 0.35 ? noise(i * 7 + 12) * H * 0.18 : noise(i * 7 + 13) * H * 0.04
                let reach = (H * 1.25 + H * 0.2) * drain - H * 0.2 + drip * min(1, drain * 3)
                return Int(min(H, max(0, reach)).rounded())
            }
            var drained: [CGRect] = []
            for j in 0..<rows {
                let e = max(0, edge(j))
                var start: Int?
                for (i, d) in depths.enumerated() {
                    let on = d > j && Double((i + 1) * col) > e
                    if on && start == nil { start = i }
                    if !on, let s = start {
                        drained.append(strip(j, max(e, Double(s * col)), Double(i * col))); start = nil
                    }
                }
                if let s = start { drained.append(strip(j, max(e, Double(s * col)), W)) }
            }
            greyToColourGrey(ctx, drained, amount: 1)
        }

        // Behind the flurry, the new place: grey-blue until the colour blooms over it.
        if front > -W * 0.1 {
            var behind: [CGRect] = []
            for j in 0..<rows where edge(j) > 0 { behind.append(strip(j, 0, min(W, edge(j)))) }
            if !behind.isEmpty {
                ctx.saveGState(); ctx.clip(to: behind); ctx.draw(new, in: r); ctx.restoreGState()
            }
            // The blooms: a patch a seed, opening once the flurry has gone by, its edge a little ragged.
            let n = max(6, Int((W / H * 5).rounded()))
            let blooms: [(x: Double, y: Double, rad: Double)] = (0..<n).map { i in
                let sx = (Double(i) + 0.15 + noise(i * 5 + 1) * 0.7) / Double(n) * W
                let sy = (0.15 + 0.7 * noise(i * 5 + 2)) * H
                let passes = 0.26 + 0.54 * (sx + W * 0.36) / (W * 1.72)
                let open = Self.ease(Self.span(k, passes + 0.06 + noise(i * 5 + 3) * 0.06, passes + 0.36))
                return (sx, sy, open * max(W / Double(n) * 1.3, H * 0.9))
            }
            let fade = 1 - Self.ease(Self.span(k, 0.84, 0.96))
            var grey: [CGRect] = []
            for j in 0..<rows {
                let right = min(W, edge(j))
                guard right > 0 else { continue }
                let y = Double(j) + 0.5
                var spans: [(Double, Double)] = []
                for (b, bl) in blooms.enumerated() where bl.rad > 0 {
                    let d = y - bl.y, rr = bl.rad * (1 + 0.06 * sin(Double(j) * 0.9 + Double(b)))
                    guard abs(d) < rr else { continue }
                    let half = (rr * rr - d * d).squareRoot()
                    spans.append(((bl.x - half).rounded(), (bl.x + half).rounded()))
                }
                spans.sort { $0.0 < $1.0 }
                var x = 0.0
                for s in spans where s.1 > x {
                    if s.0 > x { grey.append(strip(j, x, min(right, s.0))) }
                    x = max(x, s.1)
                    if x >= right { break }
                }
                if x < right { grey.append(strip(j, x, right)) }
            }
            greyToColourGrey(ctx, grey.filter { $0.width > 0 }, amount: fade)
        }

        // The flurry: blue butterflies thick round the edge, a few straggling ahead and behind.
        if sweep > 0 && sweep < 1 {
            let count = max(26, Int(H * 0.55))
            let big = H > 120 ? 2 : 1
            for i in 0..<count {
                let spread = (noise(i * 9 + 1) + noise(i * 9 + 2) - 1) * W * 0.3
                let y0 = noise(i * 9 + 3) * H
                let bob = sin(k * (18 + noise(i * 9 + 4) * 10) + Double(i)) * H * 0.04
                let drift = (noise(i * 9 + 5) - 0.5) * H * 0.3 * sweep
                let x = front + spread + sin(k * 7 + Double(i) * 1.7) * W * 0.01
                let y = y0 + bob + drift
                let near = noise(i * 9 + 6) < 0.18
                let wing = (Int(k * 2.0 * 30) + i) % 4
                greyToColourButterfly(c, x: Int(x), y: Int(y), wing: wing, scale: near ? big + 1 : big,
                                      pale: noise(i * 9 + 7) < 0.4)
            }
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// The grey-blue of the land of the living laid over `rects`: the colour taken out and a cold blue-grey put in,
    /// `amount` of the way.
    private func greyToColourGrey(_ ctx: CGContext, _ rects: [CGRect], amount: Double) {
        guard amount > 0.01, !rects.isEmpty else { return }
        ctx.saveGState()
        ctx.clip(to: rects)
        ctx.setBlendMode(.color)
        ctx.setFillColor(rgb(0x7C8CA4, CGFloat(0.92 * amount)))
        ctx.fill(rects.reduce(CGRect.null) { $0.union($1) })
        ctx.setBlendMode(.multiply)
        ctx.setFillColor(rgb(0xC4CCDA, CGFloat(amount)))
        ctx.fill(rects.reduce(CGRect.null) { $0.union($1) })
        ctx.restoreGState()
    }

    /// One blue butterfly at (`x`, `y`), `scale` art pixels a pixel, its wings at one of four beats (`wing` 0 open
    /// wide, 1 half up, 2 shut, 3 half up): Corpse Bride's, pale-edged and dark-veined.
    private func greyToColourButterfly(_ c: PixelCanvas, x: Int, y: Int, wing: Int, scale s: Int, pale: Bool) {
        let shapes: [[String]] = [
            ["BB...BB", "BLB.BLB", "BBBKBBB", ".BBKBB.", ".B.K.B."],
            [".B...B.", ".LB.BL.", ".BBKBB.", "..BKB..", "..BKB.."],
            ["...K...", "..LKL..", "..BKB..", "...K...", "......."],
            [".B...B.", ".LB.BL.", ".BBKBB.", "..BKB..", "..BKB.."],
        ]
        let blue = pale ? C(0x8FC4FF) : C(0x3E78E0), light = pale ? C(0xDCEEFF) : C(0x8FC4FF)
        let pal: [Character: Px] = ["B": blue, "L": light, "K": C(0x1C2440)]
        for (j, row) in shapes[wing].enumerated() {
            for (i, ch) in row.enumerated() {
                guard let col = pal[ch] else { continue }
                c.rect(x + (i - 3) * s, y + (j - 2) * s, s, s, col)
            }
        }
    }
}
