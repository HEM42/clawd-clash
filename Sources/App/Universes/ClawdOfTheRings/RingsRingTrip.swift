import CoreGraphics
import Foundation

// The Ring going on between Clawd of the Rings places (`RingsWipe.ring`).

extension RingsTrip {
    /// A frame `k` (0…1) of the Ring going on and coming off, over the whole of `r`. A gold ring spins down out of the
    /// top into the middle of the frame and settles, face on (0–0.24); the world drains to a cold wraith-world grey-blue,
    /// coarse, smeared and wavering (0.12–0.35); ring-shaped ripples spread from the Ring (0.3–0.94) while, far off, a
    /// fiery Eye glimmers and is gone (0.4–0.74, at its brightest about 0.57), and the grey world under it drifts from
    /// the old place to the new (0.42–0.62); the Ring spins up and away out of the top (0.66–0.84) and the colour floods
    /// back from the middle, a warm edge running out past the corners, as the new place (0.78–1). The places are drawn
    /// as they are; the wraith-world is the place itself, drawn down onto a grid twice as coarse as the art's and
    /// scaled back up unsmoothed; everything of the trip's own (the Ring, its glow, the ripples, the Eye, the dark at
    /// the edges and the flood's rim) is pixel art, drawn into a bitmap about 180 pixels tall and
    /// scaled up without smoothing. The flood is cut on that same grid.
    func drawRing(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.drawShot(old, in: r); return }
        guard k < 1 else { ctx.drawShot(new, in: r); return }
        let s = r.height / 800
        let px: CGFloat = max(1, (r.height / 180).rounded())      // screen pixels per pixel of the trip's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = ringCanvas(width: w, height: h, px: px, in: r) else { ctx.drawShot(k < 0.5 ? old : new, in: r); return }
        let centre = CGPoint(x: r.midX, y: r.midY)
        let radius = min(r.height * 0.11, r.width * 0.08)          // the Ring, settled
        let drain = CGFloat(ringEase(ringSpan(k, 0.12, 0.35)))
        let mix = CGFloat(ringEase(ringSpan(k, 0.42, 0.62)))
        let flood = CGFloat(ringEase(ringSpan(k, 0.78, 1)))
        let grey = drain * (1 - flood)                              // how much of the wraith-world's own art shows

        // The old place, fading under the wraith-world; then the grey world, wavering; then the new place, flooding
        // back in colour from the middle.
        if drain < 1 { ctx.drawShot(old, in: r) }
        let coarse = px * 2
        let cw = Int((r.width / coarse).rounded(.up)), ch = Int((r.height / coarse).rounded(.up))
        if drain > 0, let wraith = ringWraith(old: old, new: new, mix: mix, waver: 2.5 * drain, k: k, width: cw, height: ch) {
            ctx.saveGState()
            ctx.clip(to: r)
            ctx.interpolationQuality = .none
            ctx.setAlpha(drain)
            ctx.draw(wraith, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(cw) * coarse, height: CGFloat(ch) * coarse))
            ctx.restoreGState()
        }
        let reach = (r.width * r.width + r.height * r.height).squareRoot() / 2 + 4 * px
        let floodRadius = reach * flood
        let hole: [CGRect] = flood > 0
            ? ringRows(of: CGRect(x: centre.x - floodRadius, y: centre.y - floodRadius, width: floodRadius * 2, height: floodRadius * 2),
                       px: px, height: h, in: r)
            : []
        if !hole.isEmpty {
            ctx.saveGState()
            ctx.clip(to: hole)
            ctx.drawShot(new, in: r)
            ctx.restoreGState()
        }

        if grey > 0 {
            // The dark closing in at the edges of the wraith-world.
            let dusk: [RingStop] = [RingStop(0, 0x0A1220, 0), RingStop(0.55, 0x0A1220, 0.12), RingStop(1, 0x0A1220, 0.5)]
            art.saveGState()
            art.setAlpha(grey)
            ringBands(art, centre: centre, radius: reach, stops: dusk, count: 6, beyond: r)
            art.restoreGState()

            // Ring-shaped ripples spreading from the Ring, pale with a dark trough inside.
            for i in 0..<3 {
                let start = 0.3 + 0.13 * Double(i)
                let p = CGFloat(ringSpan(k, start, start + 0.38))
                guard p > 0, p < 1 else { continue }
                let rr = radius * 1.3 + p * reach * 0.9
                let a = (1 - p) * grey
                let ripple = CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2)
                art.setLineWidth(max(px * 2, 6 * s))
                art.setStrokeColor(ringRGB(0x1A2436, 0.35 * a))
                art.strokeEllipse(in: ripple.insetBy(dx: 4 * s + px, dy: 4 * s + px))
                art.setLineWidth(max(px, 3 * s))
                art.setStrokeColor(ringRGB(0xD8E6F6, 0.55 * a))
                art.strokeEllipse(in: ripple)
            }

            // Far off, the Eye: a glimmer of fire over the horizon, its slit black, there and gone.
            let eye = CGFloat(sin(Double.pi * ringSpan(k, 0.4, 0.74))) * (0.8 + 0.2 * CGFloat(noise(Int(k * 40) + 7)))
            if eye > 0.01 {
                let at = CGPoint(x: r.midX + r.width * 0.3, y: r.minY + r.height * 0.79)
                let hw = r.height * 0.065, hh = r.height * 0.024
                art.saveGState()
                art.setAlpha(eye * 0.85)
                let haze: [RingStop] = [RingStop(0, 0xFF6A1A, 0.5), RingStop(0.5, 0x8A1E0A, 0.25), RingStop(1, 0x8A1E0A, 0)]
                ringBands(art, centre: at, radius: hw * 2.4, stops: haze, count: 5, beyond: nil)
                art.addPath(ringAlmond(at, halfWidth: hw, halfHeight: hh)); art.clip()
                let fire: [RingStop] = [RingStop(0, 0xFFE08A, 1), RingStop(0.45, 0xFF8A1E, 1), RingStop(1, 0x8A1E0A, 1)]
                ringBands(art, centre: at, radius: hw, stops: fire, count: 4, beyond: nil)
                art.setFillColor(ringRGB(0x000000))
                art.fillEllipse(in: CGRect(x: at.x - max(px, hw * 0.08), y: at.y - hh, width: max(px * 2, hw * 0.16), height: hh * 2))
                art.restoreGState()
            }
        }

        if !hole.isEmpty {
            // The colour flooding back: the new place, clear of the art, inside a warm running edge.
            art.saveGState()
            art.setBlendMode(.clear); art.fill(hole)
            art.restoreGState()
            let edge = CGRect(x: centre.x - floodRadius, y: centre.y - floodRadius, width: floodRadius * 2, height: floodRadius * 2)
            art.setLineWidth(max(px * 3, 16 * s)); art.setStrokeColor(ringRGB(0xFFC04A, 0.22 * (1 - flood))); art.strokeEllipse(in: edge)
            art.setLineWidth(max(px, 4 * s)); art.setStrokeColor(ringRGB(0xFFE08A, 0.6 * (1 - flood))); art.strokeEllipse(in: edge)
        }

        // The Ring: spinning down to settle in the middle, then spinning up and away.
        let fall = ringSpan(k, 0, 0.24), lift = ringSpan(k, 0.66, 0.84)
        if lift < 1 {
            let top = r.maxY + radius * 1.6
            let drop = CGFloat(1 - pow(1 - fall, 3)), rise = CGFloat(lift * lift)
            let y = top + (centre.y - top) * drop + (top - centre.y) * rise
            let spin = 13 * pow(1 - fall, 2) + 11 * lift * lift
            let face = max(0.1, CGFloat(abs(cos(spin))))
            ringDrawRing(art, at: CGPoint(x: centre.x, y: y), radius: radius, face: face, glow: drain * CGFloat(1 - lift),
                         k: k, s: s, px: px)
        }
        ringBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// The world as the Ring-bearer sees it: `old`, with `new` over it `mix` of the way, drained to a wraith grey-blue,
/// averaged down onto a `w`×`h` grid (the blur), ghosted sideways (the smear), and its rows shifted sideways by up to
/// about `waver` of its own pixels, flowing with `k` (the wavering).
private func ringWraith(old: CGImage, new: CGImage, mix: CGFloat, waver: CGFloat, k: Double, width w: Int, height h: Int) -> CGImage? {
    let space = CGColorSpaceCreateDeviceRGB(), info = CGImageAlphaInfo.premultipliedLast.rawValue
    guard w > 0, h > 0,
          let flat = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: info),
          let out = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: info)
    else { return nil }
    let all = CGRect(x: 0, y: 0, width: w, height: h)
    flat.interpolationQuality = .medium
    flat.drawShot(old, in: all)
    if mix > 0 { flat.setAlpha(mix); flat.drawShot(new, in: all); flat.setAlpha(1) }
    if let sharp = flat.makeImage() {
        flat.setAlpha(0.3)
        flat.draw(sharp, in: all.offsetBy(dx: 2, dy: 0))
        flat.draw(sharp, in: all.offsetBy(dx: -1, dy: 1))
        flat.setAlpha(1)
    }
    flat.setBlendMode(.color); flat.setFillColor(ringRGB(0x7C8FAE)); flat.fill(all)
    flat.setBlendMode(.normal); flat.setFillColor(ringRGB(0xC4D2E6, 0.22)); flat.fill(all)
    guard let drained = flat.makeImage() else { return nil }
    out.interpolationQuality = .none
    out.draw(drained, in: all)                                  // under the shifted rows, so their ends aren't bare
    for j in 0..<h {
        let y = Double(j)
        let dx = (sin(y * 0.42 + k * 26) + 0.5 * sin(y * 0.11 - k * 9)) * Double(waver)
        out.saveGState()
        out.clip(to: CGRect(x: 0, y: j, width: w, height: 1))
        out.draw(drained, in: all.offsetBy(dx: CGFloat(dx.rounded()), dy: 0))
        out.restoreGState()
    }
    return out.makeImage()
}

/// The Ring at `c`, `radius` tall, `face` (0…1) of the way from edge on to face on: a dark outline, a gold band lit
/// along its upper half, a pale shine down its middle and a twinkle, over a warm glow `glow` strong.
private func ringDrawRing(_ art: CGContext, at c: CGPoint, radius: CGFloat, face: CGFloat, glow: CGFloat, k: Double, s: CGFloat, px: CGFloat) {
    if glow > 0 {
        art.saveGState()
        art.setAlpha(glow)
        let warm: [RingStop] = [RingStop(0, 0xFFC04A, 0.35), RingStop(0.6, 0xFF9A2A, 0.12), RingStop(1, 0xFF9A2A, 0)]
        ringBands(art, centre: c, radius: radius * 2.4, stops: warm, count: 5, beyond: nil)
        art.restoreGState()
    }
    let band = max(px * 2, radius * 0.26)
    let oval = CGRect(x: c.x - radius * face, y: c.y - radius, width: radius * face * 2, height: radius * 2)
    art.setLineWidth(band + px * 2); art.setStrokeColor(ringRGB(0x4A2C06)); art.strokeEllipse(in: oval)
    art.setLineWidth(band); art.setStrokeColor(ringRGB(0xB87A14)); art.strokeEllipse(in: oval)
    art.saveGState()
    art.clip(to: CGRect(x: c.x - radius * 2, y: c.y - radius * 0.2, width: radius * 4, height: radius * 3))
    art.setLineWidth(band * 0.6); art.setStrokeColor(ringRGB(0xE8B235)); art.strokeEllipse(in: oval)
    art.restoreGState()
    art.setLineWidth(max(px, band * 0.2)); art.setStrokeColor(ringRGB(0xFFE9A0, 0.8)); art.strokeEllipse(in: oval)

    // A twinkle on the upper left of the band, a cross of the art's pixels.
    let twinkle = CGFloat(0.5 + 0.5 * sin(k * 38))
    guard twinkle > 0.2 else { return }
    let g = CGPoint(x: ((c.x - radius * face * 0.7) / px).rounded() * px, y: ((c.y + radius * 0.7) / px).rounded() * px)
    let arm = max(px, (radius * 0.18 * twinkle / px).rounded() * px)
    art.setFillColor(ringRGB(0xFFFBE6, twinkle))
    art.fill(CGRect(x: g.x - arm, y: g.y, width: arm * 2 + px, height: px))
    art.fill(CGRect(x: g.x, y: g.y - arm, width: px, height: arm * 2 + px))
}

/// One stop of a stepped gradient: at `at` (0…1 of the radius), colour `hex` at `alpha`.
private struct RingStop {
    let at: CGFloat, hex: UInt32, alpha: CGFloat
    init(_ at: CGFloat, _ hex: UInt32, _ alpha: CGFloat) { self.at = at; self.hex = hex; self.alpha = alpha }
}

/// The colour `u` (0…1) of the way along `stops`.
private func ringColour(at u: CGFloat, _ stops: [RingStop]) -> CGColor {
    guard let last = stops.last else { return ringRGB(0x000000, 0) }
    var i = 0
    while i + 1 < stops.count && stops[i + 1].at < u { i += 1 }
    guard i + 1 < stops.count, u > stops[i].at else { return u <= stops[0].at ? ringRGB(stops[0].hex, stops[0].alpha) : ringRGB(last.hex, last.alpha) }
    let a = stops[i], b = stops[i + 1]
    let f: CGFloat = (u - a.at) / max(0.0001, b.at - a.at)
    func mix(_ shift: UInt32) -> CGFloat {
        let x = CGFloat(a.hex >> shift & 0xFF), y = CGFloat(b.hex >> shift & 0xFF)
        return (x + (y - x) * f) / 255
    }
    return CGColor(red: mix(16), green: mix(8), blue: mix(0), alpha: a.alpha + (b.alpha - a.alpha) * f)
}

/// A radial gradient in `count` solid rings, and `beyond` (if given) filled with its last colour. Drawn as discs,
/// outermost first, each replacing what's under it in a layer of its own, so no pixel is painted twice.
private func ringBands(_ ctx: CGContext, centre: CGPoint, radius: CGFloat, stops: [RingStop], count n: Int, beyond: CGRect?) {
    func circle(_ rr: CGFloat) -> CGRect { CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2) }
    ctx.saveGState(); defer { ctx.restoreGState() }
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    ctx.setBlendMode(.copy)
    if let out = beyond { ctx.setFillColor(ringColour(at: 1, stops)); ctx.fill(out) }
    for i in stride(from: n - 1, through: 0, by: -1) {
        ctx.setFillColor(ringColour(at: CGFloat(i) / CGFloat(n), stops))
        ctx.fillEllipse(in: circle(radius * CGFloat(i + 1) / CGFloat(n)))
    }
    ctx.endTransparencyLayer()
}

/// An almond (two circular arcs meeting at points left and right of `c`), `halfHeight` above and below it.
private func ringAlmond(_ c: CGPoint, halfWidth a: CGFloat, halfHeight hh: CGFloat) -> CGPath {
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
private func ringRows(of oval: CGRect, px: CGFloat, height h: Int, in r: CGRect) -> [CGRect] {
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
private func ringCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
    guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    c.setShouldAntialias(false)
    c.scaleBy(x: 1 / px, y: 1 / px)
    c.translateBy(x: -r.minX, y: -r.minY)
    return c
}

/// The art, scaled up onto `r` without smoothing.
private func ringBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
    guard let img = art.makeImage() else { return }
    ctx.saveGState()
    ctx.clip(to: r)
    ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
    ctx.restoreGState()
}

private func ringEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
/// How far `k` is through `a…b`: 0 before, 1 after.
private func ringSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

/// A colour from 0xRRGGBB.
private func ringRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
