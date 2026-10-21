import CoreGraphics
import Foundation

// The Horseman's Ride (`BurtonWipe.horseman`): mist rolls in, the Headless Horseman gallops across, his sword drawing a
// clean line through the picture, and the two halves slide apart on the new place.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Mist rolls in over the old place
    /// from both sides, low wavy banks of it drifting, and the night closes in blue (0–0.3); the Headless Horseman
    /// gallops in from the left, a black silhouette, nothing above his collar, his cloak streaming, his horse at full
    /// stretch, his sword raised and held out level ahead of him, and where its point has been a clean white line
    /// runs through the picture (0.2–0.58); the line flashes, then the top part of the picture slides off to the left
    /// and the bottom part off to the right, gathering speed, and the new place is behind them (0.6–0.86); the mist
    /// thins away (0.78–0.97).
    func drawHorseman(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let s = H * 0.0136                                   // art pixels per unit of the Horseman's drawing
        let ground = (H * 0.94).rounded(), cutY = (ground - 43 * s).rounded()
        let ride = Self.span(k, 0.2, 0.58)
        let hx = -36 * s + (W + 72 * s) * ride               // where the horse's middle is
        let tip = hx + 31 * s                                // the point of his sword
        let slide = pow(Self.span(k, 0.6, 0.86), 2.2)
        let mist = Self.ease(Self.span(k, 0, 0.28)) * (1 - Self.ease(Self.span(k, 0.78, 0.97)))

        // The picture: the old place whole, then its two halves sliding apart over the new one.
        let cut = r.maxY - CGFloat(cutY) * px                // the line on screen
        ctx.saveGState(); ctx.clip(to: r)
        if k < 0.6 {
            ctx.draw(old, in: r)
        } else {
            ctx.draw(new, in: r)
            let shift = CGFloat((W * 1.08 * slide).rounded()) * px
            ctx.saveGState(); ctx.clip(to: CGRect(x: r.minX, y: cut, width: r.width, height: r.maxY - cut))
            ctx.draw(old, in: r.offsetBy(dx: -shift, dy: 0)); ctx.restoreGState()
            ctx.saveGState(); ctx.clip(to: CGRect(x: r.minX, y: r.minY, width: r.width, height: cut - r.minY))
            ctx.draw(old, in: r.offsetBy(dx: shift, dy: 0)); ctx.restoreGState()
        }
        // The night closing in, blue.
        if mist > 0.01 { ctx.setFillColor(rgb(0x141C30, CGFloat(0.35 * mist))); ctx.fill(r) }
        ctx.restoreGState()

        // The mist, in low banks drifting in from both sides.
        if mist > 0.01 {
            horsemanMist(ctx, in: r, px: px, k: k, amount: mist, W: W, H: H, ground: ground, layers: [0, 1])
        }

        // The line his sword draws: behind its point while he rides; along both cut edges as they part.
        let bright = Self.span(k, 0.58, 0.6) * (1 - Self.span(k, 0.6, 0.8))
        if ride > 0 && k < 0.6 {
            let end = min(W, tip)
            if end > 0 {
                c.rect(0, Int(cutY) - 1, Int(end), 3, C(0xBFD8FF, 0.35 + 0.5 * bright))
                c.rect(0, Int(cutY), Int(end), 1, C(0xFFFFFF))
            }
        } else if k >= 0.6 && bright > 0.01 {
            let shift = Int((W * 1.08 * slide).rounded())
            c.rect(-shift, Int(cutY) - 1, Int(W), 1, C(0xE8F2FF, bright))
            c.rect(shift, Int(cutY), Int(W), 1, C(0xE8F2FF, bright))
        }

        // The Horseman, galloping.
        if ride > 0 && ride < 1 {
            let stride = frac(k * 2.2 * 3.2)
            horsemanRider(c, x: hx, ground: ground, s: s, stride: stride, flap: k * 2.2 * 9)
            // Clods and mist kicked up behind the hooves.
            for i in 0..<12 {
                let age = frac(noise(i * 3 + 40) + k * 6)
                let x = hx - 12 * s - age * 18 * s, y = ground - 2 * s - sin(age * .pi) * 7 * s * noise(i * 3 + 41)
                c.rect(Int(x), Int(y), max(1, Int(s)), max(1, Int(s)), C(0xB8C2D2, 0.6 * (1 - age)))
            }
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
        // The nearest bank of mist, over his hooves.
        if mist > 0.01 {
            horsemanMist(ctx, in: r, px: px, k: k, amount: mist, W: W, H: H, ground: ground, layers: [2])
        }
    }

    /// Banks of mist along the ground, three layers of it rolling in from the sides as `amount` grows and drifting with
    /// `k`, each a wavy-topped band of pale blue-grey, the nearest the palest, in the art's own columns and in four
    /// steps of thickness at its leading end. Filled straight onto the screen, a step at a time.
    private func horsemanMist(_ ctx: CGContext, in r: CGRect, px: CGFloat, k: Double, amount: Double, W: Double,
                              H: Double, ground: Double, layers which: [Int]) {
        let layers: [(top: Double, amp: Double, tone: UInt32, alpha: Double, fromLeft: Bool, drift: Double)] = [
            (0.44, 0.05, 0x8E9AB2, 0.26, true, 0.5), (0.3, 0.045, 0xAEB8CC, 0.3, false, -0.8),
            (0.16, 0.035, 0xD6DEEA, 0.34, true, 1.1)]
        let col = max(1, Int((H / 110).rounded())), bottom = ground + H * 0.08
        ctx.saveGState(); ctx.clip(to: r)
        for (i, l) in layers.enumerated() where which.contains(i) {
            let lead = -0.3 * W + 1.7 * W * amount
            var bands: [[CGRect]] = Array(repeating: [], count: 5), tops: [[CGRect]] = Array(repeating: [], count: 5)
            for x in stride(from: 0, to: Int(W.rounded(.up)), by: col) {
                let xd = Double(x), inFrom = lead - (l.fromLeft ? xd : W - xd)
                guard inFrom > 0 else { continue }
                let step = Int((min(1, inFrom / (W * 0.2)) * 4).rounded(.up)), soft = Double(step) / 4
                let a = xd / W * 2 * .pi + k * l.drift * 3
                let top = (ground - H * l.top * (0.6 + 0.4 * soft) + sin(a * 2 + Double(i) * 2) * H * l.amp
                    + sin(a * 5.3 + Double(i)) * H * l.amp * 0.4).rounded()
                let sx = r.minX + CGFloat(x) * px, sw = CGFloat(col) * px
                bands[step].append(CGRect(x: sx, y: r.maxY - CGFloat(bottom) * px, width: sw,
                                          height: CGFloat(bottom - top) * px))
                tops[step].append(CGRect(x: sx, y: r.maxY - CGFloat(top + Double(col * 2)) * px, width: sw,
                                         height: CGFloat(col * 2) * px))
            }
            for step in 1...4 where !bands[step].isEmpty {
                let alpha = l.alpha * amount * Double(step) / 4
                ctx.setFillColor(rgb(l.tone, CGFloat(alpha))); ctx.fill(bands[step])
                ctx.setFillColor(rgb(l.tone, CGFloat(alpha * 0.8))); ctx.fill(tops[step])
            }
        }
        ctx.restoreGState()
    }

    /// The Headless Horseman on his black horse, facing right, the horse's middle at `x` and its hooves on `ground`,
    /// `s` art pixels a unit, at `stride` (0…1) through a gallop; `flap` ripples his cloak. A silhouette in ink
    /// black, the cloak a shade off it, the horse's one eye glinting red, the blade's edge catching the light.
    private func horsemanRider(_ c: PixelCanvas, x: Double, ground: Double, s: Double, stride: Double, flap: Double) {
        let ink = C(0x08080C), steel = C(0xD8E2F0), cloak = C(0x221C30)
        let bob = sin(stride * 4 * .pi) * 0.8
        func p(_ u: Double, _ v: Double) -> (Double, Double) { (x + u * s, ground + (v + bob) * s) }
        func line(_ a: (Double, Double), _ b: (Double, Double), _ w: Double, _ col: Px = C(0x08080C)) {
            burtonLine(c, a.0, a.1, b.0, b.1, col, max(0.6, w * s))
        }
        func tri(_ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double), _ col: Px = C(0x08080C)) {
            burtonTriangle(c, a, b, d, col)
        }
        // The legs: a gallop, the front pair reaching and the back pair driving, each leg in two bends.
        let a = stride * 2 * .pi
        for (hip, phase, front) in [((-9.0, -19.0), 0.0, false), ((-8.0, -19.0), 0.35, false),
                                    ((9.0, -19.0), 2.6, true), ((10.0, -19.0), 3.0, true)] {
            let swing = sin(a + phase), lift = max(0, cos(a + phase))
            let thigh = (front ? 100.0 : 80.0) + swing * 36
            let knee = (hip.0 + cos(thigh * .pi / 180) * 9, hip.1 + sin(thigh * .pi / 180) * 9)
            let bend = front ? -lift * 75 : lift * 60
            let shin = thigh + bend
            let hoof = (knee.0 + cos(shin * .pi / 180) * 9, knee.1 + sin(shin * .pi / 180) * 9)
            line(p(hip.0, hip.1), p(knee.0, knee.1), 1.5)
            line(p(knee.0, knee.1), p(hoof.0, hoof.1), 0.9)
        }
        // The body, the neck and the head stretched out level, the mane and the tail streaming back.
        let body = p(0, -23)
        c.ellipse(Int(body.0.rounded()), Int(body.1.rounded()), Int(12.5 * s), max(1, Int(5.2 * s)), ink)
        line(p(9, -24), p(15, -32), 3.2)
        line(p(15, -32), p(23, -29.5), 2.1)
        line(p(21, -30.5), p(24, -28.5), 1.6)                                 // the muzzle
        tri(p(13.5, -36), p(15.5, -33), p(12, -33))                          // the ears
        let mane = sin(flap) * 1.5
        tri(p(15, -34), p(8, -26), p(5, -32 + mane))
        let tail = sin(flap * 1.3) * 2
        line(p(-12, -25), p(-19, -27 + tail), 1.6)
        line(p(-19, -27 + tail), p(-26, -24 + tail), 1.1)
        // The cloak, streaming out behind him from his shoulders, rippling, its trailing edge torn into tails, a shade
        // off black so he stands out in front of it.
        var upper: [(Double, Double)] = [], lower: [(Double, Double)] = []
        for i in 0...8 {
            let u = Double(i) / 8
            let cx = -2 - 29 * u, cy = -37 + 4 * u + sin(flap - u * 5) * 2.6 * u
            let th = 2 + 8 * u, tear = i > 2 && i % 2 == 0 ? 3.5 * u : 0
            upper.append(p(cx, cy - th * 0.3)); lower.append(p(cx + 2 * u, cy + th * 0.7 + tear))
        }
        for i in 0..<8 {
            tri(upper[i], upper[i + 1], lower[i], cloak); tri(upper[i + 1], lower[i + 1], lower[i], cloak)
        }
        // The rider in front of it: his leg down the horse's side, his body upright and broad in the shoulders, and
        // above them nothing but the stump of a high collar, its two points standing up.
        line(p(-2, -27), p(2, -21), 1.6)
        line(p(2, -21), p(1, -17), 1.2)
        line(p(-2, -27), p(0, -35), 2.6)
        line(p(-3, -36), p(3, -36.5), 1.6)
        c.rect(Int(p(-1.8, -38.5).0), Int(p(-1.8, -38.5).1), max(1, Int(3.6 * s)), max(1, Int(2.5 * s)), ink)
        tri(p(-2.4, -38), p(-0.8, -38), p(-2.8, -41))
        tri(p(0.8, -38), p(2.4, -38), p(2.8, -41))
        // The sword arm out ahead, the blade raised level over his collar along the line it cuts.
        line(p(2, -36), p(6, -41), 1.2)
        line(p(6, -41), p(9, -43), 1.0)
        // The blade, level with the line on the picture whether he bobs or not.
        line((x + 9 * s, ground - 43 * s), (x + 31 * s, ground - 43 * s), 0.45, steel)
        c.rect(Int(p(9, -44.5).0), Int(p(9, -44.5).1), max(1, Int(s)), max(2, Int(3 * s)), ink)   // the hilt's guard
        let eye = p(18.5, -31.5)
        c.rect(Int(eye.0), Int(eye.1), max(1, Int(s * 0.9)), max(1, Int(s * 0.9)), C(0xD8281E))
    }
}
