import CoreGraphics
import Foundation

// Hush (`SlayerWipe.hush`): the colour drains to grey and the Gentlemen float across in silhouette. Little glowing
// voices drift out of the scene into a wooden box, which snaps shut; silence; it opens on the new place.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. The colour drains out of the old place
    /// to a cold grey (0–0.2) and a small wooden box fades in on the floor, its lid open (0.1–0.2); three Gentlemen
    /// float across from left to right in black silhouette, their pale heads and grins just showing, bobbing politely
    /// (0.08–0.8); little glowing voices rise out of the scene and drift in arcs down into the box (0.18–0.58); the lid
    /// snaps shut with a jolt (0.6–0.63) and everything goes dark and still round it: silence (0.63–0.78); then the lid
    /// lifts, light spills out (0.78–0.84) and the new place opens out of the box to fill the frame in full colour, the
    /// voices flying free again (0.82–0.98). The old place is greyed with a saturation blend, not pixel by pixel; the
    /// box, the voices and the Gentlemen (their own sprite, as silhouettes) are pixel art, drawn into a bitmap about 180
    /// pixels tall and scaled up without smoothing, with a little grain.
    func drawHush(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else {
            Self.crossfade(ctx, old: old, new: new, k: k, in: r); return
        }
        art.translateBy(x: r.minX, y: r.minY); art.scaleBy(x: px, y: px)  // the art's own pixels, from the bottom left
        art.interpolationQuality = .none
        let W = r.width / px, H = r.height / px
        let drain = CGFloat(Self.ease(Self.span(k, 0, 0.2)))
        let shut = k >= 0.6 && k < 0.8
        let lid: CGFloat = k < 0.6 ? 1 : (k < 0.63 ? 1 - CGFloat(Self.span(k, 0.6, 0.63)) : CGFloat(Self.ease(Self.span(k, 0.78, 0.84))))
        let silence = CGFloat(Self.ease(Self.span(k, 0.6, 0.68))) * (1 - CGFloat(Self.span(k, 0.8, 0.9)))
        let bloom = CGFloat(Self.ease(Self.span(k, 0.82, 0.98)))     // the new place opening out of the box

        // The box: small and square on the floor in the middle, in wood and brass.
        let u = max(1, (H / 64).rounded())
        let bw = 16 * u, bh = 9 * u
        let jolt: CGFloat = k >= 0.62 && k < 0.66 ? u : 0
        let box = CGRect(x: (W / 2 - bw / 2).rounded(), y: (H * 0.06).rounded() + jolt, width: bw, height: bh)
        let mouth = CGRect(x: box.minX + u, y: box.maxY - u, width: bw - 2 * u, height: u)

        // The old place, its colour draining to a cold grey and going dark in the silence; then the new one opening
        // out of the box's mouth.
        ctx.draw(old, in: r)
        ctx.saveGState()
        ctx.setBlendMode(.saturation); ctx.setFillColor(rgb(0x808080, drain)); ctx.fill(r)
        ctx.setBlendMode(.normal)
        ctx.setFillColor(rgb(0x0C1220, 0.3 * drain + 0.55 * silence)); ctx.fill(r)
        ctx.restoreGState()
        if bloom > 0 {
            let full = CGRect(x: 0, y: 0, width: W, height: H)
            let o = CGRect(x: mouth.minX + (full.minX - mouth.minX) * bloom, y: mouth.maxY + (full.minY - mouth.maxY) * bloom,
                           width: mouth.width + (full.width - mouth.width) * bloom, height: (full.height) * bloom)
            ctx.saveGState()
            ctx.clip(to: CGRect(x: r.minX + o.minX.rounded() * px, y: r.minY + o.minY.rounded() * px,
                                width: o.width.rounded() * px, height: o.height.rounded() * px))
            ctx.draw(new, in: r)
            ctx.restoreGState()
        }

        // The Gentlemen, floating across in silhouette, one after another.
        if let sprites = hushGentlemen, k > 0.06, k < 0.86 {
            let sc = max(1, (H * (W > 2.5 * H ? 0.95 : 0.7) / CGFloat(Sprite.height)).rounded())
            let sw = CGFloat(Sprite.width) * sc, sh = CGFloat(Sprite.height) * sc
            for i in 0..<3 {
                let a = 0.07 + 0.08 * Double(i)
                let t = CGFloat(Self.span(k, a, a + 0.62))
                guard t > 0, t < 1 else { continue }
                let x = -sw + (W + sw * 1.2) * t - CGFloat(i) * sw * 0.15
                let y = H * 0.02 + u + (CGFloat(sin(k * 18 + Double(i) * 2)) * u).rounded() + CGFloat(i % 2) * u
                let rect = CGRect(x: x.rounded(), y: y.rounded(), width: sw, height: sh)
                art.draw(sprites.shadow, in: rect)
                art.setAlpha(0.5); art.draw(sprites.real, in: rect); art.setAlpha(1)
            }
        }

        // The box, fading in, its lid open, snapping shut, lifting again; gone as the new place opens out of it.
        let boxIn = CGFloat(Self.span(k, 0.1, 0.2)) * (1 - CGFloat(Self.span(k, 0.86, 0.96)))
        if boxIn > 0 {
            art.saveGState()
            art.setAlpha(boxIn)
            art.beginTransparencyLayer(auxiliaryInfo: nil)
            hushBox(art, box, u: u, lid: lid, glow: shut ? 0.5 + 0.5 * CGFloat(noise(Int(k * 12))) : 0,
                    light: CGFloat(Self.span(k, 0.78, 0.84)))
            art.endTransparencyLayer()
            art.restoreGState()
        }

        // The voices: rising from the scene and drifting into the box; flying free as it opens on the new place.
        let target = CGPoint(x: mouth.midX, y: mouth.midY)
        for i in 0..<11 {
            let start = 0.18 + 0.025 * Double(i)
            let appear = CGFloat(Self.span(k, start - 0.05, start))
            let go = CGFloat(Self.ease(Self.span(k, start, start + 0.15)))
            guard appear > 0, go < 1 else { continue }
            let from = CGPoint(x: W * (0.06 + 0.88 * CGFloat(noise(i * 7 + 3))), y: H * (0.3 + 0.45 * CGFloat(noise(i * 7 + 4))))
            let x = from.x + (target.x - from.x) * go + CGFloat(sin(Double(go) * 9 + Double(i))) * 2 * u * (1 - go)
            let y = from.y + (target.y - from.y) * go + CGFloat(sin(Double(go) * .pi)) * H * 0.12
            hushVoice(art, x: x, y: y, u: u, warm: i % 2 == 0, alpha: appear * (go > 0.85 ? (1 - go) / 0.15 : 1))
        }
        let free = CGFloat(Self.span(k, 0.82, 0.98))
        if free > 0 && free < 1 {
            for i in 0..<9 {
                let a = 0.4 + 2.3 * Double(i) / 8
                let dist = (H * 0.15 + H * 0.7 * CGFloat(noise(i * 5 + 60))) * free
                hushVoice(art, x: target.x + CGFloat(cos(a)) * dist * 1.4, y: target.y + CGFloat(sin(a)) * dist,
                          u: u, warm: i % 2 == 1, alpha: 1 - free)
            }
        }
        hushGrain(art, k: k, W: W, H: H, amount: 1 - bloom)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// The Gentlemen's own sprite, standing: as it is, and all one black, for drawing them in silhouette.
private let hushGentlemen: (real: CGImage, shadow: CGImage)? = {
    let c = PixelCanvas(Sprite.width, Sprite.height)
    Cast.villain(.gentlemen).draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: false)
    guard let real = c.makeImage(),
          let lo = CGContext(data: nil, width: Sprite.width, height: Sprite.height, bitsPerComponent: 8, bytesPerRow: 0,
                             space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return nil }
    let all = CGRect(x: 0, y: 0, width: Sprite.width, height: Sprite.height)
    lo.draw(real, in: all)
    lo.setBlendMode(.sourceIn)
    lo.setFillColor(rgb(0x0A0A10)); lo.fill(all)
    guard let shadow = lo.makeImage() else { return nil }
    return (real, shadow)
}()

/// The wooden box at `box` (its body; the lid sits on top), `u` art pixels to a unit: planks, brass corners and a
/// clasp; the lid open (`lid` 1, its inside showing, tipped up behind) or shut (0); the voices' `glow` leaking from the
/// seam while it's shut, and `light` pouring from its mouth as it opens on the new place.
private func hushBox(_ art: CGContext, _ box: CGRect, u: CGFloat, lid: CGFloat, glow: CGFloat, light: CGFloat) {
    let wood = rgb(0x6A4428), woodD = rgb(0x4A2C18), woodL = rgb(0x8A5C34), brass = rgb(0xC8A04A), brassD = rgb(0x8A6A2A)
    let ink = rgb(0x1A0E08)
    // The lid, tipped open behind the box: its inside showing, taller the wider it's open.
    let open = (8 * u * lid).rounded()
    if open > 0 {
        let inside = CGRect(x: box.minX + u, y: box.maxY, width: box.width - 2 * u, height: open + u)
        art.setFillColor(ink); art.fill(inside.insetBy(dx: -u, dy: 0))
        art.setFillColor(woodD); art.fill(inside.insetBy(dx: 0, dy: u / 2).offsetBy(dx: 0, dy: u / 2))
        art.setFillColor(rgb(0x3A1A26)); art.fill(CGRect(x: inside.minX + u, y: inside.minY + u, width: inside.width - 2 * u, height: max(0, inside.height - 2 * u)))
    }
    // The body.
    art.setFillColor(ink); art.fill(box.insetBy(dx: -u, dy: -u))
    art.setFillColor(wood); art.fill(box)
    art.setFillColor(woodL); art.fill(CGRect(x: box.minX, y: box.maxY - u, width: box.width, height: u))
    art.setFillColor(woodD)
    for j in 1..<3 { art.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j) * box.height / 3, width: box.width, height: max(1, u / 2))) }
    art.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: u))
    // Brass corners and the clasp.
    art.setFillColor(brass)
    for (x, y) in [(box.minX, box.minY), (box.maxX - 2 * u, box.minY), (box.minX, box.maxY - 2 * u), (box.maxX - 2 * u, box.maxY - 2 * u)] {
        art.fill(CGRect(x: x, y: y, width: 2 * u, height: 2 * u))
    }
    art.fill(CGRect(x: box.midX - u, y: box.maxY - 4 * u, width: 2 * u, height: 3 * u))
    art.setFillColor(brassD); art.fill(CGRect(x: box.midX - u / 2, y: box.maxY - 3 * u, width: max(1, u / 2), height: u))
    if open > 0 {
        // The mouth: dark inside, or full of light as it opens on the new place.
        art.setFillColor(light > 0 ? rgb(0xFFF4D0, 0.4 + 0.6 * light) : ink)
        art.fill(CGRect(x: box.minX + u, y: box.maxY - u, width: box.width - 2 * u, height: u))
        if light > 0 {
            let rays = CGMutablePath()
            rays.addLines(between: [CGPoint(x: box.minX + u, y: box.maxY), CGPoint(x: box.maxX - u, y: box.maxY),
                                    CGPoint(x: box.maxX + 6 * u, y: box.maxY + 22 * u), CGPoint(x: box.minX - 6 * u, y: box.maxY + 22 * u)])
            art.addPath(rays); art.setFillColor(rgb(0xFFF0C0, 0.35 * light)); art.fillPath()
        }
    } else {
        // Shut: the lid's front edge on top, the voices' glow leaking from the seam.
        art.setFillColor(ink); art.fill(CGRect(x: box.minX - u, y: box.maxY, width: box.width + 2 * u, height: 3 * u + u))
        art.setFillColor(woodL); art.fill(CGRect(x: box.minX, y: box.maxY + u, width: box.width, height: 2 * u))
        art.setFillColor(brass)
        art.fill(CGRect(x: box.minX, y: box.maxY + u, width: 2 * u, height: 2 * u))
        art.fill(CGRect(x: box.maxX - 2 * u, y: box.maxY + u, width: 2 * u, height: 2 * u))
        if glow > 0 {
            art.setFillColor(rgb(0xFFE6A0, 0.7 * glow))
            art.fill(CGRect(x: box.minX + 3 * u, y: box.maxY, width: box.width - 6 * u, height: max(1, u / 2)))
        }
    }
}

/// A little glowing voice: a soft halo round a bright core, warm or pale blue.
private func hushVoice(_ art: CGContext, x: CGFloat, y: CGFloat, u: CGFloat, warm: Bool, alpha: CGFloat) {
    guard alpha > 0 else { return }
    let core = warm ? rgb(0xFFF0C0, alpha) : rgb(0xE0F0FF, alpha)
    let halo = warm ? rgb(0xFFC860, 0.35 * alpha) : rgb(0x8AC0FF, 0.35 * alpha)
    let cx = x.rounded(), cy = y.rounded()
    art.setFillColor(halo)
    art.fill(CGRect(x: cx - 2 * u, y: cy - u, width: 4 * u, height: 2 * u))
    art.fill(CGRect(x: cx - u, y: cy - 2 * u, width: 2 * u, height: 4 * u))
    art.setFillColor(core); art.fill(CGRect(x: cx - u, y: cy - u, width: 2 * u, height: 2 * u))
}

/// A little film grain over the night, changing every frame or two.
private func hushGrain(_ art: CGContext, k: Double, W: CGFloat, H: CGFloat, amount: CGFloat) {
    guard amount > 0 else { return }
    let seed = Int(k * 40) * 977
    let count = Int(W * H / 110)
    var light: [CGRect] = [], dark: [CGRect] = []
    for i in 0..<count {
        let rect = CGRect(x: (CGFloat(noise(seed + i * 3)) * W).rounded(.down), y: (CGFloat(noise(seed + i * 3 + 1)) * H).rounded(.down),
                          width: 1, height: 1)
        if i % 2 == 0 { light.append(rect) } else { dark.append(rect) }
    }
    art.setFillColor(rgb(0xFFFFFF, 0.07 * amount)); art.fill(light)
    art.setFillColor(rgb(0x000000, 0.12 * amount)); art.fill(dark)
}
