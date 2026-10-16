import CoreGraphics
import Foundation

// The trip between Clawd of the Rings places with Gladriel's Mirror (`RingsWipe.mirror`).

extension RingsTrip {
    /// We look down into Gladriel's Mirror: the old place is the reflection in its water. A wide silver basin closes in
    /// from past the frame, a moonlit garden around it, and the water darkens and silvers the reflection (0–0.2); a
    /// drop falls into the middle (0.2–0.3) and splashes; rings of ripples spread to the rim and break the reflection
    /// into wobbling bands, and the new place surfaces under them as they settle (0.3–0.8); then the basin's rim
    /// widens past the frame and the water clears on the new place (0.8–1). The places are drawn as they are (in
    /// bands, shifted, while the water wobbles); everything of the Mirror's own (the garden, rim, water's tint, the
    /// moon's reflection, the drop and the ripples) is drawn as pixel art: into a bitmap about a sixth of `r` in each
    /// direction, in stepped bands of colour, then scaled up without smoothing. The water is cut on that same grid.
    func drawMirror(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the Mirror's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.mirrorCanvas(width: w, height: h, px: px, in: r) else { return }
        let centre = CGPoint(x: r.midX, y: r.midY)
        let close = Self.mirrorEase(Self.mirrorSpan(k, 0, 0.2)), widen = Self.mirrorEase(Self.mirrorSpan(k, 0.8, 1))
        let grow = 1 + 0.9 * CGFloat(1 - close) + 0.9 * CGFloat(widen)
        let a = r.width * 0.47 * grow, b = r.height * 0.43 * grow    // the water's half-width and half-height
        let water = CGRect(x: centre.x - a, y: centre.y - b, width: a * 2, height: b * 2)
        let rimWidth = max(px * 2, min(r.height, r.width * 0.6) * 0.035) * grow
        let tint = CGFloat(close * (1 - widen))

        // The ripples' wobble: none before the drop, strongest just after, settled by 0.8; it reaches a band of the
        // water once the rings have spread that far.
        let wobble = CGFloat(Self.mirrorSpan(k, 0.3, 0.35) * (1 - Self.mirrorEase(Self.mirrorSpan(k, 0.42, 0.8))))
        let spread = CGFloat(max(0, k - 0.3) / 0.25)
        func shift(_ y: CGFloat) -> CGFloat {
            guard wobble > 0 else { return 0 }
            let d = abs(y - centre.y) / b
            let reach: CGFloat = d < spread ? 1 : 0.15
            let wave = sin(Double(abs(y - centre.y) / (r.height * 0.016)) - k * 60)
            return (CGFloat(wave) * r.height * 0.03 * wobble * reach / px).rounded() * px
        }

        // The water: the reflection, in bands two pixels of the art tall, each shifted by the wobble; the new place
        // surfacing over the old one.
        ctx.setFillColor(Self.mirrorRGB(0x05080E)); ctx.fill(r)
        ctx.saveGState()
        ctx.clip(to: Self.mirrorRows(of: water, px: px, height: h, in: r))
        let surface = CGFloat(Self.mirrorEase(Self.mirrorSpan(k, 0.45, 0.75)))
        if surface < 1 { Self.mirrorReflect(ctx, old, alpha: 1, band: px * 2, shift: shift, in: r) }
        if surface > 0 { Self.mirrorReflect(ctx, new, alpha: surface, band: px * 2, shift: shift, in: r) }
        ctx.restoreGState()

        // The garden around the basin, moonlit: grass in stepped rings, darker away from the Mirror, strewn with fallen
        // gold leaves and white and gold flowers; then the water cut out of it.
        if grow < 1.85 {
            let lawn: [MirrorStop] = [MirrorStop(0, 0x3E6066, 1), MirrorStop(0.45, 0x284448, 1), MirrorStop(0.75, 0x16282E, 1),
                                      MirrorStop(1, 0x0B151B, 1)]
            Self.mirrorBands(art, centre: centre, radius: max(r.width, r.height) * 0.62 * grow, stops: lawn, count: 7, beyond: r)
            for i in 0..<70 {
                let x = r.minX + CGFloat(noise(i * 11 + 3)) * r.width, y = r.minY + CGFloat(noise(i * 11 + 4)) * r.height
                let dx = (x - centre.x) / a, dy = (y - centre.y) / b
                guard dx * dx + dy * dy > 1.15 else { continue }
                let gx = (x / px).rounded() * px, gy = (y / px).rounded() * px
                switch i % 3 {
                case 0:  // a white niphredil or a gold elanor: a cross of petals round a gold eye
                    art.setFillColor(Self.mirrorRGB(i % 2 == 0 ? 0xE6ECF4 : 0xF0C850))
                    art.fill([CGRect(x: gx - px, y: gy, width: px * 3, height: px), CGRect(x: gx, y: gy - px, width: px, height: px * 3)])
                    art.setFillColor(Self.mirrorRGB(0xF8E088)); art.fill(CGRect(x: gx, y: gy, width: px, height: px))
                case 1:  // a fallen mallorn leaf
                    art.setFillColor(Self.mirrorRGB(0xC8A848, 0.85)); art.fill(CGRect(x: gx, y: gy, width: px * 2, height: px))
                default:  // a tuft of grass
                    art.setFillColor(Self.mirrorRGB(0x5E8A7E, 0.7))
                    art.fill([CGRect(x: gx, y: gy, width: px, height: px * 2), CGRect(x: gx + px * 2, y: gy, width: px, height: px * 2)])
                }
            }
            art.saveGState()
            art.setBlendMode(.clear); art.fill(Self.mirrorRows(of: water, px: px, height: h, in: r))
            art.restoreGState()
        }

        // In the water: its dark, silvering tint, the moon's reflection (wobbling with the ripples), the ripples and the
        // drop, all kept inside the basin.
        art.saveGState()
        art.addEllipse(in: water); art.clip()
        art.setFillColor(Self.mirrorRGB(0x0A1A30, 0.42 * tint)); art.fill(r)
        art.setFillColor(Self.mirrorRGB(0xA8C0D8, 0.08 * tint)); art.fill(r)
        let moon = CGPoint(x: centre.x - a * 0.42, y: centre.y + b * 0.42), moonRadius = b * 0.13
        var y = (moon.y - moonRadius) / px
        while y * px < moon.y + moonRadius {
            let row = (y.rounded(.down) + 0.5) * px, d = (row - moon.y) / moonRadius
            if abs(d) < 1 {
                let half = moonRadius * (1 - d * d).squareRoot() * 1.15, x = moon.x + shift(row)
                art.setFillColor(Self.mirrorRGB(0xD8E4F0, 0.4 * tint))
                art.fill(CGRect(x: ((x - half) / px).rounded() * px, y: y.rounded(.down) * px, width: (half * 2 / px).rounded() * px, height: px))
            }
            y += 1
        }
        Self.mirrorRipples(art, centre: centre, a: a, b: b, k: k, px: px)
        Self.mirrorDrop(art, centre: centre, top: water.maxY + r.height * 0.1, k: k, s: r.height / 800, px: px)
        art.restoreGState()

        // The basin's silver rim, with its shadow on the grass, a bright inner edge and the dark lip of the water.
        let rim = CGPath(ellipseIn: water, transform: nil)
        let lip = CGPath(ellipseIn: water.insetBy(dx: rimWidth * 0.45, dy: rimWidth * 0.45), transform: nil)
        for (path, width, hex, alpha) in [(rim, rimWidth * 1.9, 0x04070B as UInt32, 0.5 as CGFloat), (rim, rimWidth, 0x7E8A9C, 1),
                                          (rim, rimWidth * 0.6, 0xB4C0CE, 1), (rim, max(px, rimWidth * 0.15), 0xF2F6FA, 1),
                                          (lip, px, 0x1C2632, 1)] {
            art.addPath(path); art.setStrokeColor(Self.mirrorRGB(hex, alpha)); art.setLineWidth(width); art.strokePath()
        }
        // The moon's gleam on the rim, top left.
        art.saveGState()
        art.translateBy(x: centre.x, y: centre.y); art.scaleBy(x: a, y: b)
        art.addArc(center: .zero, radius: 1 - rimWidth * 0.1 / b, startAngle: .pi * 0.58, endAngle: .pi * 0.86, clockwise: false)
        art.restoreGState()
        art.setStrokeColor(Self.mirrorRGB(0xFFFFFF, 0.9)); art.setLineWidth(max(px, rimWidth * 0.3)); art.strokePath()

        Self.mirrorBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// `image` over `r` at `alpha`, in horizontal bands `band` tall, each shifted sideways by `shift` of its middle.
    private static func mirrorReflect(_ ctx: CGContext, _ image: CGImage, alpha: CGFloat, band: CGFloat,
                                      shift: (CGFloat) -> CGFloat, in r: CGRect) {
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.setAlpha(alpha)
        let sy = CGFloat(image.height) / r.height
        var y = r.minY
        while y < r.maxY {
            let top = min(r.maxY, y + band)
            let crop = CGRect(x: 0, y: ((r.maxY - top) * sy).rounded(), width: CGFloat(image.width),
                              height: ((top - y) * sy).rounded())
            if let piece = image.cropping(to: crop) {
                ctx.draw(piece, in: CGRect(x: r.minX + shift((y + top) / 2), y: y, width: r.width, height: top - y))
            }
            y = top
        }
    }

    /// Rings of ripple spreading from the middle of the water, `a`×`b` across: a bright crest with a dark trough
    /// inside it, each fading as it nears the rim; five of them, a little apart, after the drop at 0.3.
    private static func mirrorRipples(_ ctx: CGContext, centre: CGPoint, a: CGFloat, b: CGFloat, k: Double, px: CGFloat) {
        for i in 0..<5 {
            let start = 0.3 + Double(i) * 0.07
            let reach = CGFloat((k - start) / 0.42)
            guard reach > 0.02, reach < 1 else { continue }
            let fade = (1 - reach) * CGFloat(1 - mirrorSpan(k, 0.65, 0.85))
            func ring(_ f: CGFloat) -> CGRect {
                CGRect(x: centre.x - a * f, y: centre.y - b * f, width: a * f * 2, height: b * f * 2)
            }
            ctx.setStrokeColor(mirrorRGB(0x03060C, 0.35 * fade)); ctx.setLineWidth(px * 2)
            ctx.strokeEllipse(in: ring(max(0.01, reach - 0.035)))
            ctx.setStrokeColor(mirrorRGB(0xE6EEF8, 0.7 * fade)); ctx.setLineWidth(px)
            ctx.strokeEllipse(in: ring(reach))
        }
    }

    /// The drop: falls from `top` to the middle of the water (0.2–0.3), glinting, its reflection brightening under it as
    /// it nears; then it splashes, a few beads leaping out and falling back (0.3–0.38).
    private static func mirrorDrop(_ ctx: CGContext, centre: CGPoint, top: CGFloat, k: Double, s: CGFloat, px: CGFloat) {
        func dot(_ x: CGFloat, _ y: CGFloat, _ hex: UInt32, _ alpha: CGFloat, _ wide: CGFloat = 1, _ tall: CGFloat? = nil) {
            ctx.setFillColor(mirrorRGB(hex, alpha))
            ctx.fill(CGRect(x: (x / px).rounded() * px, y: (y / px).rounded() * px, width: px * wide, height: px * (tall ?? wide)))
        }
        if k >= 0.2 && k < 0.3 {
            let f = CGFloat(pow(mirrorSpan(k, 0.2, 0.3), 2))
            let y = top + (centre.y - top) * f
            dot(centre.x - px * 2, centre.y - px * 2, 0xA8C0D8, 0.4 * f, 5, 5)    // its reflection, brightening
            dot(centre.x - px, centre.y - px, 0xE6EEF8, 0.5 * f, 3, 3)
            dot(centre.x, y + px * 4, 0xA8C0D8, 0.5, 1, 2)                 // its glint trailing above
            dot(centre.x, y + px * 2, 0xE6EEF8, 0.9, 1, 2)
            dot(centre.x - px, y - px * 2, 0xE6EEF8, 0.6, 3, 4)            // the drop, round at its foot
            dot(centre.x, y - px * 2, 0xFFFFFF, 1, 1, 4)
        }
        let splash = mirrorSpan(k, 0.3, 0.38)
        guard splash > 0, splash < 1 else { return }
        let fade = CGFloat(1 - splash)
        dot(centre.x - px, centre.y - px, 0xFFFFFF, fade, 3)
        for i in 0..<10 {
            let angle = 2 * Double.pi * (Double(i) + noise(i * 3 + 7) * 0.5) / 10
            let out = CGFloat(splash) * 70 * s * CGFloat(0.6 + 0.4 * noise(i * 3 + 8))
            let up = CGFloat(sin(splash * .pi)) * 26 * s
            dot(centre.x + out * CGFloat(cos(angle)), centre.y + out * CGFloat(sin(angle)) * 0.6 + up,
                i % 2 == 0 ? 0xFFFFFF : 0xC8D8EA, fade)
        }
    }

    // MARK: The Mirror's pixel art (copies of the Eye's helpers in RingsTrips.swift)

    private static func mirrorEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func mirrorSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

    /// A colour from 0xRRGGBB.
    private static func mirrorRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
    }

    /// One stop of a stepped gradient: at `at` (0…1 of the radius), colour `hex` at `alpha`.
    private struct MirrorStop {
        let at: CGFloat, hex: UInt32, alpha: CGFloat
        init(_ at: CGFloat, _ hex: UInt32, _ alpha: CGFloat) { self.at = at; self.hex = hex; self.alpha = alpha }
    }

    /// The colour `u` (0…1) of the way along `stops`.
    private static func mirrorColour(at u: CGFloat, _ stops: [MirrorStop]) -> CGColor {
        guard let last = stops.last else { return mirrorRGB(0x000000, 0) }
        var i = 0
        while i + 1 < stops.count && stops[i + 1].at < u { i += 1 }
        guard i + 1 < stops.count, u > stops[i].at else {
            return u <= stops[0].at ? mirrorRGB(stops[0].hex, stops[0].alpha) : mirrorRGB(last.hex, last.alpha)
        }
        let a = stops[i], b = stops[i + 1]
        let f: CGFloat = (u - a.at) / max(0.0001, b.at - a.at)
        func mix(_ shift: UInt32) -> CGFloat {
            let x = CGFloat(a.hex >> shift & 0xFF), y = CGFloat(b.hex >> shift & 0xFF)
            return (x + (y - x) * f) / 255
        }
        return CGColor(red: mix(16), green: mix(8), blue: mix(0), alpha: a.alpha + (b.alpha - a.alpha) * f)
    }

    /// A radial gradient in `count` solid rings, and `beyond` (if given) filled with its last colour.
    private static func mirrorBands(_ ctx: CGContext, centre: CGPoint, radius: CGFloat, stops: [MirrorStop], count n: Int, beyond: CGRect?) {
        func circle(_ rr: CGFloat) -> CGRect { CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2) }
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.beginTransparencyLayer(auxiliaryInfo: nil)
        ctx.setBlendMode(.copy)
        if let out = beyond { ctx.setFillColor(mirrorColour(at: 1, stops)); ctx.fill(out) }
        for i in stride(from: n - 1, through: 0, by: -1) {
            ctx.setFillColor(mirrorColour(at: CGFloat(i) / CGFloat(n), stops))
            ctx.fillEllipse(in: circle(radius * CGFloat(i + 1) / CGFloat(n)))
        }
        ctx.endTransparencyLayer()
    }

    /// The rows of the art's grid that fall inside `oval`: one rectangle per row, its ends on the grid, in `r`'s units.
    private static func mirrorRows(of oval: CGRect, px: CGFloat, height h: Int, in r: CGRect) -> [CGRect] {
        let cx = oval.midX, cy = oval.midY, a = oval.width / 2, b = oval.height / 2
        guard a > 0, b > 0 else { return [] }
        var out: [CGRect] = []
        for j in 0..<h {
            let y: CGFloat = r.minY + (CGFloat(j) + 0.5) * px
            let d: CGFloat = (y - cy) / b
            guard abs(d) < 1 else { continue }
            let half: CGFloat = a * (1 - d * d).squareRoot()
            let x0: CGFloat = max(0, ((cx - half - r.minX) / px).rounded())
            let x1: CGFloat = min((r.width / px).rounded(.up), ((cx + half - r.minX) / px).rounded())
            if x1 > x0 { out.append(CGRect(x: r.minX + x0 * px, y: r.minY + CGFloat(j) * px, width: (x1 - x0) * px, height: px)) }
        }
        return out
    }

    /// A clear bitmap `width`×`height`, set up so that drawing into it in `r`'s units lands on its grid, unsmoothed.
    private static func mirrorCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: 1 / px, y: 1 / px)
        c.translateBy(x: -r.minX, y: -r.minY)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    private static func mirrorBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }
}
