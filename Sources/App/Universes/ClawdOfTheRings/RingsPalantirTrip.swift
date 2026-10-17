import CoreGraphics
import Foundation

// The palantír between Clawd of the Rings places (`RingsWipe.palantir`).

extension RingsTrip {
    /// A frame `k` (0…1) of the view clouding into a seeing-stone and clearing on the new place, over the whole of `r`.
    /// A dark, glassy stone grows in the middle of the frame (0–0.3) while the old place outside it dims and the old
    /// place inside it shrinks, turning, into its depths (0.05–0.5); smoke and fire swirl up inside, round a fiery core
    /// (0.25–0.78), and for an instant the Eye's slit burns in the fire (0.46–0.58); the stone clears, the swirl
    /// settling into the new place as it rises out of the depths and turns upright (0.58–0.82); then the stone's rim
    /// widens past the frame, its highlight and dark edge fading, and leaves the new place (0.8–1). The places are
    /// drawn as they are, but inside the stone, while they turn, they're drawn onto the art's grid; everything of the
    /// stone's own (its glass, rim, highlight, glow, smoke, fire and the Eye) is pixel art, drawn into a bitmap about
    /// 180 pixels tall and scaled up without smoothing. The stone is cut on that same grid.
    func drawPalantir(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let s = r.height / 800
        let px: CGFloat = max(1, (r.height / 180).rounded())      // screen pixels per pixel of the stone's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = palantirCanvas(width: w, height: h, px: px, in: r) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let centre = CGPoint(x: r.midX, y: r.midY)
        let settled = min(r.height, r.width) * 0.42
        let reach = (r.width * r.width + r.height * r.height).squareRoot() / 2 + 6 * px
        let grow = CGFloat(palantirEase(palantirSpan(k, 0, 0.3)))
        let widen = CGFloat(palantirEase(palantirSpan(k, 0.8, 1)))
        let radius = max(px, settled * grow + (reach * 1.15 - settled) * widen)
        let ball = CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)
        let sink = palantirEase(palantirSpan(k, 0.05, 0.5))        // the old place going down into the depths
        let rise = palantirEase(palantirSpan(k, 0.58, 0.82))       // the new place coming up out of them
        let swirl = CGFloat(palantirSpan(k, 0.25, 0.4) * (1 - palantirEase(palantirSpan(k, 0.62, 0.78))))
        let crisp = rise >= 1                                       // the new place, upright, drawn as it is

        // The old place outside the stone, dimming.
        ctx.draw(old, in: r)
        let inside = palantirRows(of: ball, px: px, height: h, in: r)
        if crisp {
            ctx.saveGState(); ctx.clip(to: inside); ctx.draw(new, in: r); ctx.restoreGState()
        }
        art.setFillColor(palantirRGB(0x05060A, 0.72 * grow))
        art.fill(r)
        art.saveGState()
        art.setBlendMode(.clear); art.fill(inside)
        art.restoreGState()

        art.saveGState()
        art.clip(to: inside)
        if !crisp {
            // The depths: the old place shrinking and turning away into the dark, the new one turning up out of it.
            art.setFillColor(palantirRGB(0x07080E)); art.fill(ball)
            art.interpolationQuality = .none
            if sink < 1 { palantirSunk(art, old, scale: CGFloat(1 - 0.75 * sink), angle: CGFloat(3 * sink * sink), alpha: CGFloat((1 - sink) * (1 - sink)), in: r) }
            if rise > 0 { palantirSunk(art, new, scale: CGFloat(0.5 + 0.5 * rise), angle: CGFloat(-2.4 * (1 - rise) * (1 - rise)), alpha: CGFloat(rise), in: r) }
        }

        // The fiery core and the smoke and fire swirling round it.
        if swirl > 0 {
            let core: [PalantirStop] = [PalantirStop(0, 0xFFB040, 0.75), PalantirStop(0.45, 0xB8300E, 0.4), PalantirStop(1, 0x3A0A06, 0)]
            art.saveGState()
            art.setAlpha(swirl)
            palantirBands(art, centre: centre, radius: radius * 0.6, stops: core, count: 6)
            art.restoreGState()
            palantirSwirl(art, centre: centre, radius: radius, k: k, strength: swirl, px: px)

            // The Eye, for an instant: an almond of fire, its slit black.
            let glimpse = CGFloat(sin(Double.pi * palantirSpan(k, 0.46, 0.58)))
            if glimpse > 0.01 {
                let hw = radius * 0.5, hh = radius * 0.17
                art.saveGState()
                art.setAlpha(glimpse)
                art.addPath(palantirAlmond(centre, halfWidth: hw, halfHeight: hh)); art.clip()
                let fire: [PalantirStop] = [PalantirStop(0, 0xFFE08A, 1), PalantirStop(0.4, 0xFF8A1E, 1), PalantirStop(1, 0x8A1E0A, 1)]
                palantirBands(art, centre: centre, radius: hw, stops: fire, count: 6)
                art.setFillColor(palantirRGB(0x000000))
                let slit = max(px * 2, hw * 0.1) * (0.6 + 0.4 * glimpse)
                art.fillEllipse(in: CGRect(x: centre.x - slit / 2, y: centre.y - hh * 0.92, width: slit, height: hh * 1.84))
                art.restoreGState()
            }
        }

        // The glass: dark towards its edge, as deep as a sphere, fading as the rim widens away.
        let glass = 1 - widen
        let edge: [PalantirStop] = [PalantirStop(0, 0x05060A, 0), PalantirStop(0.6, 0x05060A, 0.12), PalantirStop(0.85, 0x05060A, 0.45),
                                    PalantirStop(1, 0x05060A, 0.8)]
        art.saveGState()
        art.setAlpha(glass)
        palantirBands(art, centre: centre, radius: radius, stops: edge, count: 7)
        art.restoreGState()
        art.restoreGState()                                         // the clip to the stone

        // The rim, and the window's light caught on the glass: a pale curve upper left, a cold glint lower right.
        if glass > 0, grow > 0 {
            art.setLineWidth(max(px * 2, 7 * s)); art.setStrokeColor(palantirRGB(0x0C0E16, glass)); art.strokeEllipse(in: ball)
            art.setLineWidth(max(px, 2 * s)); art.setStrokeColor(palantirRGB(0x4A5468, 0.8 * glass))
            art.strokeEllipse(in: ball.insetBy(dx: -max(px, 4 * s), dy: -max(px, 4 * s)))
            let shine = CGRect(x: centre.x - radius * 0.62, y: centre.y + radius * 0.38, width: radius * 0.46, height: radius * 0.24)
            art.setFillColor(palantirRGB(0xDCE6F4, 0.35 * glass)); art.fillEllipse(in: shine)
            art.setFillColor(palantirRGB(0xFFFFFF, 0.7 * glass))
            art.fillEllipse(in: CGRect(x: shine.minX + shine.width * 0.2, y: shine.midY, width: shine.width * 0.3, height: shine.height * 0.35))
            art.saveGState()
            art.addArc(center: centre, radius: radius * 0.86, startAngle: -1.25, endAngle: -0.3, clockwise: false)
            art.setLineWidth(max(px, 5 * s)); art.setStrokeColor(palantirRGB(0x6A7A98, 0.4 * glass)); art.strokePath()
            art.restoreGState()
        }
        palantirBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// A place drawn into the stone's art, `scale` of its size about the middle of `r`, turned by `angle`, at `alpha`.
private func palantirSunk(_ art: CGContext, _ place: CGImage, scale: CGFloat, angle: CGFloat, alpha: CGFloat, in r: CGRect) {
    guard alpha > 0 else { return }
    art.saveGState()
    art.setAlpha(alpha)
    art.translateBy(x: r.midX, y: r.midY)
    art.rotate(by: angle)
    art.scaleBy(x: scale, y: scale)
    art.draw(place, in: CGRect(x: -r.width / 2, y: -r.height / 2, width: r.width, height: r.height))
    art.restoreGState()
}

/// Three arms of smoke curling round the stone's core, fire towards the middle, turning with `k`; blobs on the art's
/// grid, `strength` strong.
private func palantirSwirl(_ art: CGContext, centre: CGPoint, radius: CGFloat, k: Double, strength: CGFloat, px: CGFloat) {
    let fire: [UInt32] = [0xFFE08A, 0xFF8A1E, 0xFF5A14]
    let smoke: [UInt32] = [0x3A3448, 0x5A5068, 0x2A2436, 0x6A6078]
    let steps = 40
    for arm in 0..<3 {
        for i in 0..<steps {
            let t = Double(i) / Double(steps - 1)
            let seed = arm * 101 + i * 7
            let a = Double(arm) * 2 * .pi / 3 + t * 3.4 + k * 9 + noise(seed) * 0.3
            let d = radius * CGFloat(0.06 + 0.86 * t)
            let size = radius * CGFloat(0.05 + 0.11 * t) * CGFloat(0.7 + 0.6 * noise(seed + 1))
            let x = centre.x + d * CGFloat(cos(a)), y = centre.y + d * CGFloat(sin(a))
            let hex = t < 0.32 ? fire[(i + arm) % fire.count] : smoke[(i + arm) % smoke.count]
            let flicker = 0.75 + 0.25 * noise(seed + Int(k * 30))
            let alpha = strength * CGFloat((t < 0.32 ? 0.8 : 0.65) * flicker * (1 - 0.35 * t))
            art.setFillColor(palantirRGB(hex, alpha))
            art.fillEllipse(in: CGRect(x: ((x - size) / px).rounded() * px, y: ((y - size) / px).rounded() * px,
                                       width: max(px, (size * 2 / px).rounded() * px), height: max(px, (size * 2 / px).rounded() * px)))
        }
    }
}

/// One stop of a stepped gradient: at `at` (0…1 of the radius), colour `hex` at `alpha`.
private struct PalantirStop {
    let at: CGFloat, hex: UInt32, alpha: CGFloat
    init(_ at: CGFloat, _ hex: UInt32, _ alpha: CGFloat) { self.at = at; self.hex = hex; self.alpha = alpha }
}

/// The colour `u` (0…1) of the way along `stops`.
private func palantirColour(at u: CGFloat, _ stops: [PalantirStop]) -> CGColor {
    guard let last = stops.last else { return palantirRGB(0x000000, 0) }
    var i = 0
    while i + 1 < stops.count && stops[i + 1].at < u { i += 1 }
    guard i + 1 < stops.count, u > stops[i].at else {
        return u <= stops[0].at ? palantirRGB(stops[0].hex, stops[0].alpha) : palantirRGB(last.hex, last.alpha)
    }
    let a = stops[i], b = stops[i + 1]
    let f: CGFloat = (u - a.at) / max(0.0001, b.at - a.at)
    func mix(_ shift: UInt32) -> CGFloat {
        let x = CGFloat(a.hex >> shift & 0xFF), y = CGFloat(b.hex >> shift & 0xFF)
        return (x + (y - x) * f) / 255
    }
    return CGColor(red: mix(16), green: mix(8), blue: mix(0), alpha: a.alpha + (b.alpha - a.alpha) * f)
}

/// A radial gradient in `count` solid rings. Drawn as discs, outermost first, each replacing what's under it in a
/// layer of its own, so no pixel is painted twice.
private func palantirBands(_ ctx: CGContext, centre: CGPoint, radius: CGFloat, stops: [PalantirStop], count n: Int) {
    func circle(_ rr: CGFloat) -> CGRect { CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2) }
    ctx.saveGState(); defer { ctx.restoreGState() }
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    ctx.setBlendMode(.copy)
    for i in stride(from: n - 1, through: 0, by: -1) {
        ctx.setFillColor(palantirColour(at: CGFloat(i) / CGFloat(n), stops))
        ctx.fillEllipse(in: circle(radius * CGFloat(i + 1) / CGFloat(n)))
    }
    ctx.endTransparencyLayer()
}

/// An almond (two circular arcs meeting at points left and right of `c`), `halfHeight` above and below it.
private func palantirAlmond(_ c: CGPoint, halfWidth a: CGFloat, halfHeight hh: CGFloat) -> CGPath {
    let path = CGMutablePath()
    let radius = (a * a + hh * hh) / (2 * hh)
    let theta = CGFloat(atan2(Double(radius - hh), Double(a)))
    let half: CGFloat = .pi
    path.addArc(center: CGPoint(x: c.x, y: c.y + hh - radius), radius: radius, startAngle: theta, endAngle: half - theta, clockwise: false)
    path.addArc(center: CGPoint(x: c.x, y: c.y - hh + radius), radius: radius,
                startAngle: half + theta, endAngle: 2 * half - theta, clockwise: false)
    path.closeSubpath()
    return path
}

/// The rows of the art's grid that fall inside `oval`: one rectangle per row, its ends on the grid, in `r`'s units.
private func palantirRows(of oval: CGRect, px: CGFloat, height h: Int, in r: CGRect) -> [CGRect] {
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
private func palantirCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
    guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    c.setShouldAntialias(false)
    c.scaleBy(x: 1 / px, y: 1 / px)
    c.translateBy(x: -r.minX, y: -r.minY)
    return c
}

/// The art, scaled up onto `r` without smoothing.
private func palantirBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
    guard let img = art.makeImage() else { return }
    ctx.saveGState()
    ctx.clip(to: r)
    ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
    ctx.restoreGState()
}

private func palantirEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
/// How far `k` is through `a…b`: 0 before, 1 after.
private func palantirSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

/// A colour from 0xRRGGBB.
private func palantirRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
