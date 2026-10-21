import CoreGraphics
import Foundation

// Spiral Hill Unfurls (`BurtonWipe.spiralHill`): the hill rises in silhouette against the moon, and its curl unrolls
// across the screen like a tongue, laying out the new place as it goes.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Night falls over the old place, then
    /// a big moon rises behind as Spiral Hill comes up out of the ground on the left in black silhouette, its rim
    /// moonlit violet, its curl standing against the moon (0–0.28). Then the curl rolls off along the hilltop and
    /// out across the screen like a tongue unfurling, winding tighter as it goes, the ridge it leaves behind sloping
    /// up toward the right; under the ridge, close behind the curl, the hill fills with the new place (0.26–0.82).
    /// Last the whole ridge lifts up and away off the top, taking the night with it (0.62–0.96). Pixel art on the
    /// art's own grid; the places are cut along it.
    func drawSpiralHill(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (hill, px) = Self.pixelCanvas(in: r)
        let sky = PixelCanvas(hill.w, hill.h)
        let W = Double(hill.w), H = Double(hill.h)
        let night = Self.ease(Self.span(k, 0, 0.16)), rise = Self.ease(Self.span(k, 0.03, 0.28))
        let moon = Self.ease(Self.span(k, 0.12, 0.3))   // once the dark is down: never a moon over daylight
        let roll = Self.ease(Self.span(k, 0.26, 0.82)), fill = Self.ease(Self.span(k, 0.26, 0.42))
        let lift = Self.ease(Self.span(k, 0.62, 0.96))
        // The hill's shape, as `burtonSpiralHill` draws it, coming up out of the ground.
        let h = H * 0.82, w = min(h * 1.6, W * 0.55), x0 = (W * 0.04).rounded()
        let rad = h * 0.29, cx = x0 + w * 0.6
        let base = H + (1 - rise) * h * 1.1, rampTop = base - h + 2 * rad
        let up = lift * (H + 4)
        // The curl rolling off to the right, and the ridge it leaves, sloping up toward the right edge.
        let front = cx + (W + rad * 2.5 - cx) * roll, rho = rad * (1 - 0.55 * roll)
        func ridge(_ x: Double) -> Double { rampTop - (x - cx) / max(1, W - cx) * (rampTop - H * 0.42) * roll }
        func top(_ x: Double) -> Double {
            let t: Double
            if x <= cx {
                t = base - (base - rampTop) * pow(Self.clamp((x - x0) / (cx - x0)), 1.7)
            } else if x <= front {
                t = ridge(x)
            } else {
                let edge = ridge(front)
                t = edge + (base - edge) * pow(Self.clamp((x - front) / (w * 0.4)), 1.4)
            }
            return t - up
        }
        let reveal = x0 + (front - x0) * fill

        // Night over the old place, the moon coming up behind the curl.
        ctx.draw(old, in: r)
        ctx.setFillColor(rgb(0x140E2C, 0.72 * night)); ctx.fill(r)
        let mr = max(4, Int(H * 0.2)), cyTop = H - h + rad
        Scenes.htMoon(sky, Int(cx + rad * 0.35), Int(cyTop - rad * 0.15 + (1 - moon) * H * 0.4 - up), mr, s: 1)
        Self.blitCanvas(sky, onto: ctx, px: px, in: r, alpha: CGFloat(moon))

        // The new place, under the ridge behind the curl; the hill still black ahead of it.
        let ink = burtonInk, violet = burtonViolet, glow = C(0x9A8AF0)
        var rects: [CGRect] = []
        for col in 0..<hill.w {
            let t = top(Double(col) + 0.5)
            guard t < H else { continue }
            let y = max(0, Int(t.rounded()))
            if Double(col) < reveal {
                rects.append(CGRect(x: r.minX + CGFloat(col) * px, y: r.minY, width: px,
                                    height: CGFloat(hill.h - y) * px))
            } else {
                hill.rect(col, y, 1, hill.h - y, ink)
            }
            hill.px(col, y, ink); hill.px(col, y - 1, violet); hill.px(col, y - 2, glow.alpha(0.35))
        }
        if !rects.isEmpty { ctx.saveGState(); ctx.clip(to: rects); ctx.draw(new, in: r); ctx.restoreGState() }

        // The curl: one and a third turns at first, winding tighter as it unrolls, its inner coils spinning.
        if front - rho < W + 2 {
            let turns = 2.6 * Double.pi * (1 - 0.45 * roll), spin = (front - cx) / max(2, rho) * 0.35
            let thick = max(1.2, h * 0.11), contact = (x: front, y: ridge(front) - up)
            let centre = (x: contact.x, y: contact.y - rho)
            let n = max(24, Int(rho * 10))
            var prev = contact
            var points: [((x: Double, y: Double), (x: Double, y: Double), Double)] = []
            for i in 1...n {
                let f = Double(i) / Double(n), phi = -Double.pi / 2 + f * turns - spin * f * f
                let rr = rho * (1 - 0.78 * f)
                let q = (x: centre.x + rr * cos(phi), y: centre.y - rr * sin(phi))
                points.append((prev, q, max(0.6, thick * (1 - 0.7 * f) / 2)))
                prev = q
            }
            for (a, b, t) in points { burtonLine(hill, a.x, a.y - 1, b.x, b.y - 1, violet, t) }
            for (a, b, t) in points { burtonLine(hill, a.x, a.y, b.x, b.y, ink, t) }
        }
        Self.blitCanvas(hill, onto: ctx, px: px, in: r)
    }
}
