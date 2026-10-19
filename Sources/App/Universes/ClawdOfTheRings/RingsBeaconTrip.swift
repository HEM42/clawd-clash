import CoreGraphics
import Foundation

// The trip between Clawd of the Rings places with the beacons of Gondor lighting (`RingsWipe.beacons`): fire runs from
// peak to peak into the distance, and the last one's light opens on the new place.

extension RingsTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. The old place darkens to night and the
    /// stars come out (0–0.22) while a range of dark peaks rises across the frame, the White Mountains pale behind
    /// them (0.08–0.41); the beacons light one after another, from the nearest peak on the left to the farthest and
    /// smallest on the right, each a flare and then a steady blaze with its glow (0.32, 0.385… 0.71: seven, a beat
    /// apart); the last one swells (0.74–0.86) and its light opens out into a ring of fire with the new place inside,
    /// growing past the frame and fading (0.8–1). The places are drawn as they are; the night, the mountains, the fires
    /// and the ring are pixel art: drawn into a bitmap a few screen pixels to each of its own (about 180 of them from
    /// top to bottom), in stepped bands of colour, then scaled up without smoothing. The opening is cut on that same grid.
    func drawBeacons(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the trip's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.beaconCanvas(width: w, height: h) else { ctx.drawShot(k < 0.5 ? old : new, in: r); return }
        let W = Double(w), H = Double(h)
        let flick = Int(k * 2.4 * 12)                            // the flames change a dozen times a second

        // Night falls on the old place, and the stars come out.
        ctx.drawShot(old, in: r)
        let night = Self.beaconEase(Self.beaconSpan(k, 0, 0.22))
        art.setFillColor(beaconRGB(0x060818, CGFloat(0.86 * night))); art.fill(CGRect(x: 0, y: 0, width: W, height: H))
        for i in 0..<36 {
            let twinkle = 0.6 + 0.4 * noise(i * 17 + flick / 3)
            art.setFillColor(beaconRGB(i % 5 == 0 ? 0xFFF0C0 : 0xC8D4FF, CGFloat(night * twinkle * 0.9)))
            art.fill(CGRect(x: (noise(i * 17 + 1) * W).rounded(), y: (H * (0.45 + 0.55 * noise(i * 17 + 2))).rounded(),
                            width: 1, height: 1))
        }

        // The White Mountains behind, snow pale on their tops, then the beacon hills in front, farthest first.
        Self.beaconRange(art, rise: Self.beaconEase(Self.beaconSpan(k, 0.08, 0.28)), W: W, H: H)
        let hills = (0..<7).map { Self.beaconHill($0, W: W, H: H) }
        for i in stride(from: 6, through: 0, by: -1) {
            let rise = Self.beaconEase(Self.beaconSpan(k, 0.1 + 0.025 * Double(i), 0.26 + 0.025 * Double(i)))
            Self.beaconPeak(art, hills[i], index: i, drop: (1 - rise) * (hills[i].top + 4), W: W)
        }

        // The fires, one after another along the chain, each flaring as it catches; the last one swells.
        let swell = Self.beaconEase(Self.beaconSpan(k, 0.74, 0.86))
        for i in 0..<7 {
            let lit = k - (0.32 + 0.065 * Double(i))
            guard lit > 0 else { continue }
            let catching = Self.beaconEase(min(1, lit / 0.025))
            let flare = lit < 0.09 ? sin(.pi * lit / 0.09) * 0.7 : 0
            let grow = i == 6 ? 1 + 2.2 * swell : 1
            let size = hills[i].fire * catching * (1 + flare) * grow
            Self.beaconFire(art, x: hills[i].x, y: hills[i].top, size: size, flare: flare + (i == 6 ? swell : 0),
                            index: i, flick: flick, k: k)
        }

        // The last fire's light opens out into a ring of fire with the new place inside it.
        let opening = pow(Self.beaconSpan(k, 0.8, 0.97), 1.5)
        if opening > 0 {
            let cx = hills[6].x, cy = hills[6].top + hills[6].fire * 0.5
            let far = max(hypot(cx, cy), hypot(W - cx, cy), hypot(cx, H - cy), hypot(W - cx, H - cy))
            let radius = opening * (far + 16)
            let hole = Self.beaconRows(cx: cx, cy: cy, radius: radius, width: w, height: h)
            if !hole.isEmpty {
                ctx.saveGState()
                ctx.clip(to: hole.map { CGRect(x: r.minX + $0.minX * px, y: r.minY + $0.minY * px,
                                               width: $0.width * px, height: $0.height * px) })
                ctx.setFillColor(beaconRGB(0x000000)); ctx.fill(r); ctx.drawShot(new, in: r)
                ctx.setFillColor(beaconRGB(0xFF8A1E, CGFloat(0.4 * (1 - Self.beaconSpan(k, 0.82, 0.98))))); ctx.fill(r)
                ctx.restoreGState()
                for row in hole { art.clear(row) }
            }
            let fade = CGFloat(1 - Self.beaconSpan(k, 0.9, 1))
            let ring = CGRect(x: cx - radius, y: cy - radius, width: radius * 2, height: radius * 2)
            for (width, hex, alpha) in [(14.0, 0xFF8A1E as UInt32, 0.25), (7.0, 0xFF8A1E, 0.55), (3.0, 0xFFC040, 0.9),
                                        (1.0, 0xFFF0B0, 0.9)] {
                art.setStrokeColor(beaconRGB(hex, CGFloat(alpha) * fade)); art.setLineWidth(width)
                art.strokeEllipse(in: ring)
            }
        }
        Self.beaconBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// One beacon hill, `i` from the nearest (0, on the left, big) to the farthest (6, on the right, small and low):
    /// its summit at (`x`, `top`) in the art's pixels from the bottom left, `half` its half-width at the bottom of the
    /// frame, `fire` the height of its fire, and its colour, paler with distance.
    private static func beaconHill(_ i: Int, W: Double, H: Double) -> (x: Double, top: Double, half: Double, fire: Double, hex: UInt32) {
        let d = Double(i) / 6
        let x = W * (0.1 + 0.82 * d + 0.03 * (noise(i * 13 + 70) - 0.5))
        let shades: [UInt32] = [0x08090F, 0x0C0E17, 0x10131E, 0x141826, 0x181C2D, 0x1B2034, 0x1E243A]
        return (x, H * (0.74 - 0.38 * d), H * (0.55 - 0.3 * d), max(4, H * (0.11 - 0.065 * d)), shades[i])
    }

    /// A beacon hill, `drop` pixels below where it stands as it rises: a rocky peak with a flat top for the fire,
    /// its slopes jagged.
    private static func beaconPeak(_ art: CGContext, _ hill: (x: Double, top: Double, half: Double, fire: Double, hex: UInt32),
                                   index i: Int, drop: Double, W: Double) {
        let top = hill.top - drop, base = -2 - drop, cap = max(2, (hill.fire * 0.45).rounded())
        /// A point `t` (0 at the bottom, 1 at the summit) up the slope on `side`, knocked about a little.
        func slope(_ side: Double, _ t: Double, _ s: Int) -> CGPoint {
            let jag = t > 0 && t < 1 ? (noise(i * 29 + s * 2 + (side < 0 ? 0 : 1)) - 0.5) * hill.half * 0.2 : 0
            return CGPoint(x: (hill.x + side * (cap + (hill.half - cap) * (1 - t)) + jag).rounded(),
                           y: (base + (top - base) * t).rounded())
        }
        let path = CGMutablePath()
        path.move(to: slope(-1, 0, 0))
        for s in 1...5 { path.addLine(to: slope(-1, Double(s) / 5, s)) }
        for s in 1...5 { path.addLine(to: slope(1, 1 - Double(s) / 5, s)) }
        path.closeSubpath()
        art.setFillColor(beaconRGB(hill.hex)); art.addPath(path); art.fillPath()
        // A paler rim along the ridge, as the night sky catches it.
        art.setStrokeColor(beaconRGB(0x2A3150, 0.6)); art.setLineWidth(1); art.addPath(path); art.strokePath()
    }

    /// The White Mountains, far behind the beacon hills: a jagged range across the frame with snow on its tops,
    /// risen `rise` (0…1) of the way from below the frame.
    private static func beaconRange(_ art: CGContext, rise: Double, W: Double, H: Double) {
        guard rise > 0 else { return }
        let drop = (1 - rise) * H * 0.7
        let peaks = Int(W / (H * 0.22)) + 2
        var tops: [CGPoint] = []
        for i in 0...peaks {
            let x = W * Double(i) / Double(peaks)
            let high = i % 2 == 0
            let y = H * (high ? 0.5 + 0.14 * noise(i * 7 + 80) : 0.36 + 0.08 * noise(i * 7 + 81)) - drop
            tops.append(CGPoint(x: x.rounded(), y: y.rounded()))
        }
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -1, y: -1))
        for p in tops { path.addLine(to: p) }
        path.addLine(to: CGPoint(x: W + 1, y: -1))
        path.closeSubpath()
        art.setFillColor(beaconRGB(0x232A46)); art.addPath(path); art.fillPath()
        // Snow on the high tops: a pale cap down each slope.
        art.setFillColor(beaconRGB(0x4A5478))
        for (i, p) in tops.enumerated() where i % 2 == 0 {
            let depth = H * 0.06
            let left = i > 0 ? tops[i - 1] : CGPoint(x: p.x - 20, y: p.y - 20)
            let right = i + 1 < tops.count ? tops[i + 1] : CGPoint(x: p.x + 20, y: p.y - 20)
            func along(_ q: CGPoint) -> CGPoint {
                let t = min(1, depth / max(1, Double(p.y - q.y)))
                return CGPoint(x: (p.x + (q.x - p.x) * t).rounded(), y: (p.y + (q.y - p.y) * t).rounded())
            }
            let cap = CGMutablePath()
            cap.move(to: along(left)); cap.addLine(to: p); cap.addLine(to: along(right))
            cap.addLine(to: CGPoint(x: p.x, y: (p.y - depth * 0.55).rounded()))
            cap.closeSubpath()
            art.addPath(cap); art.fillPath()
        }
    }

    /// A beacon fire `size` pixels tall on the summit at (`x`, `y`): a glow in stepped rings (brighter while it
    /// `flare`s), a pile of logs with embers, the flames in bands from red outside to a yellow-white heart, each
    /// column flickering, and sparks rising off it.
    private static func beaconFire(_ art: CGContext, x: Double, y: Double, size: Double, flare: Double, index i: Int,
                                   flick: Int, k: Double) {
        guard size > 0.5 else { return }
        let bx = x.rounded(), by = y.rounded()
        // The glow.
        let glow = size * (1.7 + 0.9 * flare)
        let rings: [(Double, UInt32, Double)] = [(1, 0xFF8A1E, 0.07), (0.72, 0xFF8A1E, 0.12), (0.48, 0xFFA040, 0.2)]
        art.saveGState()
        art.beginTransparencyLayer(auxiliaryInfo: nil)
        art.setBlendMode(.copy)
        for (f, hex, a) in rings {
            let rr = (glow * f).rounded()
            art.setFillColor(beaconRGB(hex, CGFloat(min(0.6, a * (1 + flare)))))
            art.fillEllipse(in: CGRect(x: bx - rr, y: by + size * 0.4 - rr, width: rr * 2, height: rr * 2))
        }
        art.endTransparencyLayer()
        art.restoreGState()
        // The logs, glowing at the cracks.
        let half = max(1, (size * 0.36).rounded())
        let logs = max(1, (size * 0.14).rounded())
        art.setFillColor(beaconRGB(0x3A2414)); art.fill(CGRect(x: bx - half - 1, y: by, width: half * 2 + 3, height: logs))
        art.setFillColor(beaconRGB(0xFF5A14))
        for c in stride(from: -half, through: half, by: 3) { art.fill(CGRect(x: bx + c, y: by, width: 1, height: 1)) }
        // The flames: a column per pixel across, red, orange, yellow and a white heart, flickering.
        let bands: [(Double, Double, UInt32)] = [(1, 1, 0xD8401A), (0.72, 0.68, 0xFF8A1E), (0.48, 0.42, 0xFFE08A),
                                                 (0.24, 0.2, 0xFFF6D6)]
        for (wide, tall, hex) in bands {
            art.setFillColor(beaconRGB(hex))
            let reach = Int((Double(half) * wide).rounded())
            for c in -reach...reach {
                let u = Double(c) / (Double(reach) + 0.5)
                let lick = 0.75 + 0.4 * noise(i * 31 + c * 7 + flick * 13)
                let height = (size * tall * (1 - u * u) * lick).rounded()
                guard height >= 1 else { continue }
                art.fill(CGRect(x: bx + Double(c), y: by + logs, width: 1, height: height))
            }
        }
        // Sparks, drifting up off the top.
        art.setFillColor(beaconRGB(0xFFC040))
        for s in 0..<3 {
            let up = (noise(i * 5 + s) + k * 6).truncatingRemainder(dividingBy: 1)
            let sx = bx + ((noise(i * 5 + s + 9) - 0.5) * Double(half) * 2 + sin(k * 30 + Double(s)) * 1.5).rounded()
            art.fill(CGRect(x: sx, y: (by + size * (0.8 + 1.4 * up)).rounded(), width: 1, height: 1))
        }
    }

    /// The rows of the art's grid inside the circle at (`cx`, `cy`), `radius` across: one rectangle per row, in the
    /// art's pixels.
    private static func beaconRows(cx: Double, cy: Double, radius: Double, width w: Int, height h: Int) -> [CGRect] {
        guard radius > 0 else { return [] }
        var out: [CGRect] = []
        for j in 0..<h {
            let d = (Double(j) + 0.5 - cy) / radius
            guard abs(d) < 1 else { continue }
            let half = radius * (1 - d * d).squareRoot()
            let x0 = max(0, (cx - half).rounded()), x1 = min(Double(w), (cx + half).rounded())
            if x1 > x0 { out.append(CGRect(x: x0, y: Double(j), width: x1 - x0, height: 1)) }
        }
        return out
    }

    // MARK: Helpers

    private static func beaconEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func beaconSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

    /// A clear bitmap `width`×`height`, drawn into in its own pixels (y up), unsmoothed.
    private static func beaconCanvas(width w: Int, height h: Int) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    private static func beaconBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }
}

/// A colour from 0xRRGGBB.
private func beaconRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
