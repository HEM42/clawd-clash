import CoreGraphics
import Foundation

// Willow's Spell (`SlayerWipe.spell`): a circle of candles; Willow's green ribbon of sparkles spirals in, the old
// place twists through it and untwists as the new one.

extension SlayerTrip {
    /// A ring of candles fades in around the middle of the old place and lights one after another, the rest of the
    /// picture dimming (0–0.2); a ribbon of leaf-green and emerald sparkles spirals in from outside the circle to its
    /// middle (0.12–0.5), and the picture inside the circle twists after it, tighter towards the middle; at the
    /// tightest twist a green flare hides the swap (0.44–0.56); the ribbon unwinds back out and the new place untwists,
    /// still turning the same way (0.5–0.86); the sparkles drift and fade, the flames gutter out in wisps of smoke and
    /// the candles go (0.82–1). The twist is the picture drawn at the art's resolution in rings of the circle, each
    /// turned by its own angle; the candles, ribbon and sparkles are pixel art about 180 pixels tall, scaled up
    /// without smoothing, with a little grain.
    func drawSpell(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())    // screen pixels per pixel of the spell's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let centre = CGPoint(x: r.midX, y: r.midY)
        let s = r.height / 200
        let swap = k >= 0.5

        // How far the middle of the circle is turned: winding up to the swap, then unwinding the same way round.
        let maxTwist = 2.6 * Double.pi
        let twist = swap ? -maxTwist * (1 - Self.ease(Self.span(k, 0.5, 0.86))) : maxTwist * pow(Self.span(k, 0.16, 0.5), 1.6)

        // The picture, twisted inside the circle (at the art's resolution while it turns), the old place and the new
        // crossfading through the flare.
        let blend = Self.ease(Self.span(k, 0.45, 0.55))
        if abs(twist) > 0.001 {
            art.interpolationQuality = .none
            Self.spellTwist(art, swap ? new : old, twist: twist, centre: centre, in: r)
            if blend > 0 && blend < 1 {
                art.saveGState(); art.setAlpha(CGFloat(swap ? 1 - blend : blend))
                Self.spellTwist(art, swap ? old : new, twist: twist, centre: centre, in: r)
                art.restoreGState()
            }
        } else {
            ctx.draw(swap ? new : old, in: r)
        }

        // The dim: night drawn in around the circle while the spell is cast.
        let candles = Self.span(k, 0, 0.08) * (1 - Self.span(k, 0.9, 1))
        let dim = CGFloat(0.5 * Self.ease(Self.span(k, 0, 0.2)) * (1 - Self.ease(Self.span(k, 0.8, 1))))
        if dim > 0 { Self.spellDim(art, centre: centre, strength: dim, px: px, in: r) }

        // The flare at the swap: stepped rings of green light in the middle.
        let flare = CGFloat(sin(Self.span(k, 0.38, 0.62) * .pi))
        if flare > 0 {
            let radius = min(r.width, r.height * 1.6) * 0.3 * (0.3 + 0.7 * flare)
            for i in 0..<6 {
                let rr = radius * CGFloat(6 - i) / 6
                art.setFillColor(rgb(i < 4 ? 0x3FD07A : 0xD8FFC8, (i < 4 ? 0.12 : 0.3) * flare))
                art.fillEllipse(in: CGRect(x: centre.x - rr * 1.3, y: centre.y - rr * 0.8, width: rr * 2.6, height: rr * 1.6))
            }
        }

        // The candles in their ring, the back half first, then the ribbon, then the front half.
        let ring = CGSize(width: min(r.width * 0.4, r.height * 1.6), height: r.height * 0.36)
        let count = 9
        var spots: [(Int, CGPoint)] = (0..<count).map { i in
            let a = Double.pi / 2 + 2 * .pi * Double(i) / Double(count)
            return (i, CGPoint(x: centre.x + ring.width * CGFloat(cos(a)), y: centre.y + ring.height * CGFloat(sin(a))))
        }
        spots.sort { $0.1.y > $1.1.y }
        let back = spots.filter { $0.1.y >= centre.y }, front = spots.filter { $0.1.y < centre.y }
        for (i, p) in back { Self.spellCandle(art, at: p, index: i, k: k, shown: candles, s: s, px: px, in: r) }
        Self.spellRibbon(art, centre: centre, k: k, s: s, px: px, in: r)
        for (i, p) in front { Self.spellCandle(art, at: p, index: i, k: k, shown: candles, s: s, px: px, in: r) }

        Self.spellGrain(art, k: k, strength: CGFloat(1 - Self.span(k, 0.85, 1)), px: px, in: r)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// `image` over `r`, turned inside the oval inscribed in `r` in rings, each by `twist` times (1 − its distance out)²:
    /// the middle turns most, the rim not at all, and anything outside the oval stays put. The turn is made in the
    /// oval's own shape, so each ring keeps to itself and nothing outside the picture comes into view.
    private static func spellTwist(_ c: CGContext, _ image: CGImage, twist: Double, centre: CGPoint, in r: CGRect) {
        let a = r.width / 2, b = r.height / 2
        let n = 26
        c.draw(image, in: r)
        for i in 0..<n {
            let outer = CGFloat(n - i) / CGFloat(n), inner = CGFloat(n - i - 1) / CGFloat(n)
            let mid = Double(outer + inner) / 2
            let angle = twist * pow(1 - mid, 2)
            guard abs(angle) > 0.002 else { continue }
            c.saveGState()
            c.addEllipse(in: CGRect(x: centre.x - a * outer, y: centre.y - b * outer, width: a * outer * 2, height: b * outer * 2))
            if inner > 0 {
                c.addEllipse(in: CGRect(x: centre.x - a * inner, y: centre.y - b * inner, width: a * inner * 2, height: b * inner * 2))
            }
            c.clip(using: .evenOdd)
            c.translateBy(x: centre.x, y: centre.y)
            c.scaleBy(x: a, y: b)
            c.rotate(by: CGFloat(angle))
            c.scaleBy(x: 1 / a, y: 1 / b)
            c.translateBy(x: -centre.x, y: -centre.y)
            c.draw(image, in: r)
            c.restoreGState()
        }
    }

    /// Night drawn in from the corners: stepped ovals, darker further out.
    private static func spellDim(_ c: CGContext, centre: CGPoint, strength: CGFloat, px: CGFloat, in r: CGRect) {
        c.setFillColor(rgb(0x060A18, 0.35 * strength)); c.fill(r)
        for i in 0..<4 {
            let f = 1.0 - CGFloat(i) * 0.12
            let oval = CGRect(x: centre.x - r.width * 0.5 * f, y: centre.y - r.height * 0.5 * f, width: r.width * f, height: r.height * f)
            c.saveGState()
            c.addRect(r); c.addEllipse(in: oval); c.clip(using: .evenOdd)
            c.setFillColor(rgb(0x060A18, 0.18 * strength)); c.fill(r)
            c.restoreGState()
        }
    }

    /// One candle standing at `p`: cream wax with a drip, a wick, and (once lit, each a moment after the last) a
    /// flickering flame in a warm pool of light; at the end the flame gutters out into a wisp of smoke.
    private static func spellCandle(_ c: CGContext, at p: CGPoint, index i: Int, k: Double, shown: Double, s: CGFloat,
                                    px: CGFloat, in r: CGRect) {
        guard shown > 0 else { return }
        func snap(_ v: CGFloat, _ o: CGFloat) -> CGFloat { ((v - o) / px).rounded() * px + o }
        let tall = max(px * 8, snap(s * 20, 0)), wide = max(px * 4, snap(s * 6, 0))
        let x = snap(p.x - wide / 2, r.minX), y = snap(p.y - tall / 2, r.minY)
        let a = CGFloat(shown)
        let lit = span(k, 0.05 + Double(i) * 0.013, 0.07 + Double(i) * 0.013) * (1 - span(k, 0.84 + Double(i % 3) * 0.02, 0.88 + Double(i % 3) * 0.02))
        let frame = Int(k * 40)
        // The light it throws.
        if lit > 0 {
            for j in 0..<3 {
                let rr = tall * CGFloat(1.6 - Double(j) * 0.4)
                c.setFillColor(rgb(0xFFA040, CGFloat(0.07 * lit) * a))
                c.fillEllipse(in: CGRect(x: p.x - rr, y: y + tall - rr * 0.7, width: rr * 2, height: rr * 1.4))
            }
        }
        // Its shadow, the wax, the shaded side, a drip and the wick.
        c.setFillColor(rgb(0x000000, 0.35 * a)); c.fill(CGRect(x: x - px, y: y - px, width: wide + px * 3, height: px * 2))
        c.setFillColor(rgb(0xE6D4A8, a)); c.fill(CGRect(x: x, y: y, width: wide, height: tall))
        c.setFillColor(rgb(0xB89C70, a)); c.fill(CGRect(x: x + wide - px, y: y, width: px, height: tall))
        c.setFillColor(rgb(0xF4E8C8, a)); c.fill(CGRect(x: x, y: y + tall - px, width: wide, height: px))
        c.setFillColor(rgb(0xD8CCAA, a))
        c.fill(CGRect(x: x + px, y: y + tall - px * CGFloat(2 + i % 3), width: px, height: px * CGFloat(2 + i % 3)))
        c.setFillColor(rgb(0x2A2018, a)); c.fill(CGRect(x: x + snap(wide / 2, 0) - px, y: y + tall, width: px, height: px * 2))
        let wick = CGPoint(x: x + snap(wide / 2, 0) - px, y: y + tall + px * 2)
        if lit > 0 {
            // The flame: an orange teardrop round a yellow heart, its height flickering.
            let flick = CGFloat(noise(i * 31 + frame)) * 2
            let fh = (max(px * 5, s * 10) + flick * px) * CGFloat(lit)
            let fw = max(px * 3, snap(s * 4, 0))
            c.setFillColor(rgb(0xFF8A20, a)); c.fill(CGRect(x: wick.x - fw / 2 + px / 2, y: wick.y, width: fw, height: snap(fh * 0.7, 0)))
            c.fill(CGRect(x: wick.x, y: wick.y, width: px, height: snap(fh, 0)))
            c.setFillColor(rgb(0xFFE890, a)); c.fill(CGRect(x: wick.x, y: wick.y, width: px, height: snap(fh * 0.55, 0)))
        } else if k > 0.84 {
            // Smoke, curling up from the snuffed wick.
            let t = span(k, 0.86 + Double(i % 3) * 0.02, 1)
            for j in 0..<6 {
                let up = CGFloat(j) * px * 2 + CGFloat(t) * s * 18
                let sway = CGFloat(sin(Double(j) * 0.9 + k * 12 + Double(i))) * s * 3
                c.setFillColor(rgb(0xA8B0C0, CGFloat(0.5 * (1 - t)) * (1 - CGFloat(j) / 6) * a))
                c.fill(CGRect(x: snap(wick.x + sway, r.minX), y: snap(wick.y + up, r.minY), width: px, height: px * 2))
            }
        }
    }

    /// Willow's ribbon: a spiral of sparkles in the circle's shape. Its head winds in from outside to the middle
    /// (0.12–0.5) and back out again (0.5–0.86), trailing a tapering band that twists like a ribbon (pale leaf green
    /// edged with emerald, a bright core) with sparkles winking round it; then what's left drifts and fades.
    private static func spellRibbon(_ c: CGContext, centre: CGPoint, k: Double, s: CGFloat, px: CGFloat, in r: CGRect) {
        let inward = span(k, 0.12, 0.5), outward = span(k, 0.5, 0.86)
        guard k > 0.12 else { return }
        let fade = CGFloat(1 - span(k, 0.74, 0.94))
        guard fade > 0 else { return }
        let a = r.width * 0.5, b = r.height * 0.5
        // The head's distance out (0 middle, 1 the rim) and how long the band behind it is, in the same units.
        let head = k < 0.5 ? 1.35 - 1.35 * ease(inward) : 1.45 * ease(outward)
        let length = k < 0.5 ? 0.9 : 0.9 - 0.4 * outward
        let spin = k * 9
        func point(_ rho: Double) -> CGPoint {
            // Two and a half turns from the rim to the middle; inward it trails outside the head, outward inside it.
            let phi = spin + 5 * .pi * rho
            return CGPoint(x: centre.x + a * CGFloat(rho * cos(phi)), y: centre.y + b * CGFloat(rho * sin(phi)))
        }
        let frame = Int(k * 30)
        // The band, as a chain of short strokes (so its width can change along it), and the sparkles round it.
        let samples = Int(max(160, length * 5 * .pi * Double(a + b) / 2 / Double(px) * 0.25))
        var points: [(CGPoint, CGFloat)] = []
        var spark: [CGRect] = []
        for j in 0...samples {
            let d = Double(j) / Double(samples)                     // 0 at the head, 1 at the tail
            let rho = k < 0.5 ? head + d * length : head - d * length
            guard rho >= 0, rho < 1.4 else { points.append((.zero, -1)); continue }
            let p = point(rho)
            let taper = CGFloat(1 - d * 0.85)
            let turning = CGFloat(abs(sin(d * 16 + k * 26)))        // the ribbon turning edge-on and back
            let half = (s * 1.2 + s * 2.6 * turning) * taper
            points.append((p, half))
            // Sparkles winking around it, scattered a little wider.
            if noise(j * 7 + frame * 131) > 0.62 - 0.25 * d {
                let off = CGFloat(noise(j * 7 + 3 + frame * 17) - 0.5) * (half + s * 5) * 4
                let c0 = CGRect(x: ((p.x - r.minX) / px).rounded() * px + r.minX,
                                y: ((p.y + off - r.minY) / px).rounded() * px + r.minY, width: px, height: px)
                spark.append(c0)
                if noise(j * 7 + 5 + frame) > 0.55 {
                    spark.append(c0.offsetBy(dx: px, dy: 0)); spark.append(c0.offsetBy(dx: -px, dy: 0))
                    spark.append(c0.offsetBy(dx: 0, dy: px)); spark.append(c0.offsetBy(dx: 0, dy: -px))
                }
            }
        }
        c.setLineCap(.round)
        for (hex, scale, add, alpha) in [(0x0E6A3A as UInt32, 1.0 as CGFloat, px * 2, 0.3 as CGFloat), (0x1FA05A, 1, 0, 0.9),
                                         (0x9CE88A, 0.55, 0, 0.95), (0xE6FFD8, 0, px, 0.9)] {
            for j in 0..<(points.count - 1) {
                let (p0, h0) = points[j], (p1, h1) = points[j + 1]
                guard h0 >= 0, h1 >= 0 else { continue }
                // Fainter towards the tail, and glittering: some stretches brighter than others.
                let along = CGFloat(j) / CGFloat(points.count)
                let glitter: CGFloat = noise(j / 3 * 11 + frame * 7) > 0.75 ? 1 : 0.7
                c.setStrokeColor(rgb(hex, alpha * fade * (1 - along * 0.8) * glitter))
                c.setLineWidth(max(px, (h0 + h1) * scale + add))
                c.move(to: p0); c.addLine(to: p1); c.strokePath()
            }
        }
        c.setFillColor(rgb(0xF4FFF0, fade)); c.fill(spark)

        // The sparkles it leaves behind as it unwinds, drifting outward and winking out.
        if k > 0.5 {
            var dust: [CGRect] = []
            for i in 0..<60 {
                let born = 0.5 + 0.36 * noise(i * 5 + 1)
                let t = (k - born) / 0.25
                guard t > 0, t < 1 else { continue }
                let rho = 1.45 * ease(span(born, 0.5, 0.86)) * (1 + 0.25 * t)
                let p = point(rho)
                let drift = CGFloat(t) * s * 14
                guard noise(i * 5 + frame) > 0.3 else { continue }
                dust.append(CGRect(x: ((p.x - r.minX) / px).rounded() * px + r.minX,
                                   y: ((p.y + drift - r.minY) / px).rounded() * px + r.minY, width: px, height: px))
            }
            c.setFillColor(rgb(0xC8F8B0, 0.85 * fade)); c.fill(dust)
        }
    }

    /// Film grain: scattered pixels of the art, a little lighter or darker, different every frame.
    private static func spellGrain(_ c: CGContext, k: Double, strength: CGFloat, px: CGFloat, in r: CGRect) {
        guard strength > 0 else { return }
        let w = Int(r.width / px), h = Int(r.height / px)
        let n = w * h / 70, frame = Int(k * 30) * 7919
        var light: [CGRect] = [], dark: [CGRect] = []
        light.reserveCapacity(n / 2); dark.reserveCapacity(n / 2)
        for i in 0..<n {
            let x = Int(noise(i * 3 + frame) * Double(w)), y = Int(noise(i * 3 + 1 + frame) * Double(h))
            let rect = CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(y) * px, width: px, height: px)
            if i % 2 == 0 { light.append(rect) } else { dark.append(rect) }
        }
        c.setFillColor(rgb(0xE8F4FF, 0.07 * strength)); c.fill(light)
        c.setFillColor(rgb(0x000000, 0.12 * strength)); c.fill(dark)
    }
}
