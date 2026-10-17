import CoreGraphics
import Foundation

// Sunrise (`SlayerWipe.sunrise`): the sky blushes, a line of dawn light sweeps across and burns the old place off into
// brightness, and the new place settles in.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. The night sky over the old place
    /// blushes in four soft bands, violet at the top to rose and amber at the horizon (0–0.3); a slanted line of
    /// white-gold dawn light sweeps from left to right (0.26–0.76), a glow running ahead of it and embers lifting off the old place
    /// along its ragged edge; behind it the old place is gone and the new place lies under a glare that fades back
    /// from the line; then the glare and the blush ebb and the new place settles in as it is (0.6–1). The light, the
    /// blush and the embers are pixel art, and the old place is cut on the art's grid, with grain over the night.
    func drawSunrise(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard let canvas = Self.slayerDustCanvas(in: r) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let (art, w, h, px) = canvas
        let W = Double(w), H = Double(h)
        let flick = Int(k * 2.0 * 15)
        let blush = Self.ease(Self.span(k, 0, 0.3)), settle = Self.ease(Self.span(k, 0.6, 1))
        let sweep = Self.span(k, 0.26, 0.76)
        let sweepE = sweep * (0.6 + 0.4 * sweep)            // a touch slower at first, quickening
        let slant = W * 0.1, trail = max(W * 0.45, H * 0.9)
        /// The line's place along the row at `y`, before its edge is roughened.
        func line(_ y: Double) -> Double { -slant - 6 + (W + 2 * slant + 12) * sweepE + (y / H - 0.5) * slant * 2 }

        // The new place behind; the old one ahead of the line, its edge ragged as it burns.
        ctx.draw(new, in: r)
        let edge: [Double] = (0..<h).map { j in
            (line(Double(j)) + ((noise(j / 2 * 31 + flick * 7) - 0.5) * 3).rounded()).rounded()
        }
        var rows: [CGRect] = []
        for j in 0..<h where edge[j] < W {
            let x = max(0, edge[j])
            rows.append(CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(j) * px,
                               width: CGFloat(W - x) * px, height: px))
        }
        if !rows.isEmpty { ctx.saveGState(); ctx.clip(to: rows); ctx.draw(old, in: r); ctx.restoreGState() }

        // The blush: four soft bands down the sky, close in colour, deepening toward the horizon, a warm wash below.
        let ebb = blush * (1 - settle)
        if ebb > 0 {
            let sky: [(UInt32, Double)] = [(0x4A3068, 0.12), (0x7A3C6A, 0.15), (0xB45A64, 0.18), (0xE8905E, 0.21)]
            let horizon = (H * 0.4).rounded(), band = ((H - horizon) / Double(sky.count)).rounded(.up)
            for (i, (hex, alpha)) in sky.enumerated() {
                art.setFillColor(sunRGB(hex, CGFloat(ebb * alpha)))
                art.fill(CGRect(x: 0, y: H - Double(i + 1) * band, width: W, height: band))
            }
            art.setFillColor(sunRGB(0xF0A060, CGFloat(ebb * 0.1)))
            art.fill(CGRect(x: 0, y: 0, width: W, height: H - Double(sky.count) * band))
        }

        // Row by row along the line: behind it the glare, brightest at the line and stepping down to a warm wash
        // that ebbs as the new place settles; ahead of it a glow over the old place; and the line itself.
        if sweep > 0 {
            let fade = 1 - settle
            let steps = 10, step = (trail / Double(steps)).rounded()
            let glare: [UInt32] = [0xFFF6DC, 0xFFF6DC, 0xFFEEC4, 0xFFE6B0, 0xFFDCA0, 0xFFD494, 0xFFCC8C, 0xFFC888, 0xFFC888, 0xFFC888]
            for j in 0..<h {
                let x = edge[j], y = Double(j)
                guard x > -2 else { continue }
                let back = x - Double(steps) * step
                if back > 0 {
                    art.setFillColor(sunRGB(0xFFD8A0, CGFloat(0.28 * fade))); art.fill(CGRect(x: 0, y: y, width: back, height: 1))
                }
                for b in 0..<steps {
                    let t = Double(b) / Double(steps)
                    art.setFillColor(sunRGB(glare[b], CGFloat((0.28 + 0.66 * pow(1 - t, 1.7)) * fade)))
                    art.fill(CGRect(x: x - Double(b + 1) * step, y: y, width: step, height: 1))
                }
                if sweep < 1 {
                    for g in 0..<4 {
                        art.setFillColor(sunRGB(g < 2 ? 0xFFD27A : 0xF0A050, CGFloat(0.42 * (1 - Double(g) / 4))))
                        art.fill(CGRect(x: x + Double(g) * 3, y: y, width: 3, height: 1))
                    }
                    art.setFillColor(sunRGB(0xFFFFF4)); art.fill(CGRect(x: x - 2, y: y, width: 3, height: 1))
                }
            }
        }

        // Embers lifting off the old place along the burning edge.
        if sweep > 0 && sweep < 1 {
            for i in 0..<Int(H * 0.35) {
                let age = (noise(i * 13) + k * 9).truncatingRemainder(dividingBy: 1)
                let y = noise(i * 13 + 1) * H + age * H * 0.12
                let x = line(y) + 1 + noise(i * 13 + 2) * 8 - age * 10
                art.setFillColor(sunRGB(noise(i * 13 + 3) < 0.5 ? 0xFF8A3A : 0xFFD060, CGFloat(1 - age)))
                art.fill(CGRect(x: x.rounded(), y: y.rounded(), width: 1, height: 1))
            }
        }

        Self.slayerDustGrain(art, W: W, H: H, seed: flick, amount: 0.9 * (1 - Self.span(k, 0.3, 0.7)))
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// A colour from 0xRRGGBB.
private func sunRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
