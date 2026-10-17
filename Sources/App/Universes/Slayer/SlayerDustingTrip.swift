import CoreGraphics
import Foundation

// Dusting (`SlayerWipe.dusting`): a stake strikes and the old place bursts into grey-gold dust that swirls and blows
// away to show the new place. The most common trip, so it is quick and punchy.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. A wooden stake thrusts in from the lower
    /// left and strikes (0–0.09) with a white-gold flash (0.085–0.17), then pulls back out (0.17–0.3). The old
    /// place, cut into blocks on the art's grid, crumbles from the strike outward: each block glows dust-gold for a
    /// moment, then goes, and its dust bursts away from the strike, swirls, and is blown off up and to the right
    /// (0.11–0.97, the last block going at 0.67). The new place waits behind it, in a night-blue shade that lifts as
    /// the dust clears. The stake, the dust and the flash are pixel art, with a little film grain over the night.
    func drawDusting(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard let canvas = Self.slayerDustCanvas(in: r) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let (art, w, h, px) = canvas
        let W = Double(w), H = Double(h)

        // The new place behind, in the night's shade until the dust has gone.
        ctx.draw(new, in: r)
        let shade = 0.42 * (1 - Self.ease(Self.span(k, 0.3, 0.95)))
        if shade > 0 { ctx.setFillColor(dustRGB(0x0A0E22, CGFloat(shade))); ctx.fill(r) }

        // The old place in blocks, each going when the crumbling reaches it: nearer the strike first, a little
        // ragged. A block's dust lives for `life` after it goes.
        let block = max(2, Int((H / 40).rounded()))
        let cols = (w + block - 1) / block, rows = (h + block - 1) / block
        let ix = W * 0.55, iy = H * 0.5
        let far = max(hypot(ix, iy), hypot(W - ix, iy), hypot(ix, H - iy), hypot(W - ix, H - iy))
        let life = 0.3
        let B = Double(block)
        let dust: [UInt32] = [0x8C877C, 0xB3A383, 0xD8B25C, 0xF4E2A4]
        var keep: [CGRect] = []
        for j in 0..<rows {
            var runStart = -1
            for i in 0...cols {
                var standing = false
                if i < cols {
                    let seed = j * 977 + i * 131
                    let cx = (Double(i) + 0.5) * B, cy = (Double(j) + 0.5) * B
                    let d = hypot(cx - ix, cy - iy) / far
                    let goes = 0.11 + 0.42 * d + 0.14 * noise(seed)
                    if k < goes {
                        standing = true
                        // Just before it goes, the block glows the colour of dust.
                        let glow = 1 - (goes - k) / 0.05
                        if glow > 0 {
                            art.setFillColor(dustRGB(glow > 0.6 ? 0xE8CC84 : 0xA89C84, CGFloat(0.7 * glow)))
                            art.fill(CGRect(x: Double(i) * B, y: Double(j) * B, width: B, height: B))
                        }
                    } else if k < goes + life {
                        // Its dust: a burst away from the strike, then swirled and blown off up and to the right.
                        let a = (k - goes) / life
                        let burst = 1 - (1 - a) * (1 - a)
                        let ux = (cx - ix) / max(1, d * far), uy = (cy - iy) / max(1, d * far)
                        for m in 0..<(noise(seed + 5) < 0.45 ? 2 : 1) {
                            let s = seed + m * 17
                            let reach = B * 3 * (0.5 + noise(s + 1)) * burst
                            let spin = a * 7 + noise(s + 2) * 6.28
                            let x = cx + (noise(s + 3) - 0.5) * B + ux * reach + W * 0.55 * (0.4 + noise(s + 4)) * pow(a, 1.6)
                                + cos(spin) * B * 1.4 * a
                            let y = cy + (noise(s + 6) - 0.5) * B + uy * reach + H * 0.28 * (noise(s + 7) - 0.1) * a * a
                                + sin(spin) * B * 1.4 * a
                            let size: Double = a < 0.35 && m == 0 ? 2 : 1
                            let tone = noise(s + 8)
                            art.setFillColor(dustRGB(dust[min(3, Int(tone * 4))], CGFloat(pow(1 - a, 1.2))))
                            art.fill(CGRect(x: x.rounded(), y: y.rounded(), width: size, height: size))
                        }
                    }
                }
                if standing && runStart < 0 { runStart = i }
                if !standing && runStart >= 0 {
                    keep.append(CGRect(x: r.minX + CGFloat(runStart * block) * px, y: r.minY + CGFloat(j * block) * px,
                                       width: CGFloat((i - runStart) * block) * px, height: CGFloat(block) * px))
                    runStart = -1
                }
            }
        }
        if !keep.isEmpty {
            ctx.saveGState(); ctx.clip(to: keep); ctx.draw(old, in: r); ctx.restoreGState()
        }

        // A thin haze of dust over everything while it flies.
        let haze = Self.span(k, 0.12, 0.3) * (1 - Self.span(k, 0.55, 0.95))
        if haze > 0 { art.setFillColor(dustRGB(0xB8A78A, CGFloat(0.13 * haze))); art.fill(CGRect(x: 0, y: 0, width: W, height: H)) }

        // The strike's flash: a white-gold star and a ring, gone in a blink.
        let flash = Self.span(k, 0.085, 0.17)
        if flash > 0 && flash < 1 {
            let fx = ix.rounded(), fy = iy.rounded(), arm = (B * (3 + 9 * flash)).rounded(), t = max(2, B.rounded())
            let fade = CGFloat(1 - flash)
            art.setFillColor(dustRGB(0xFFF4D0, fade))
            art.fill(CGRect(x: fx - arm, y: fy - t / 2, width: arm * 2, height: t))
            art.fill(CGRect(x: fx - t / 2, y: fy - arm, width: t, height: arm * 2))
            art.setFillColor(dustRGB(0xF0C860, fade))
            for q in 0..<4 {
                let ang = Double(q) * .pi / 2 + .pi / 4, out = arm * 0.8
                for step in 0..<Int(max(1, out * 0.5)) {
                    let rr = out * 0.35 + Double(step)
                    art.fill(CGRect(x: (fx + cos(ang) * rr).rounded(), y: (fy + sin(ang) * rr).rounded(), width: 1, height: 1))
                }
            }
            let core = (B * 1.6 * (1 - flash)).rounded()
            art.setFillColor(dustRGB(0xFFFFF4, fade)); art.fill(CGRect(x: fx - core, y: fy - core, width: core * 2, height: core * 2))
            let ring = arm * 1.3
            art.setStrokeColor(dustRGB(0xF4E2A4, fade * 0.7)); art.setLineWidth(1)
            art.strokeEllipse(in: CGRect(x: fx - ring, y: fy - ring, width: ring * 2, height: ring * 2))
        }

        // The stake: thrust in from the lower left, a beat on the strike, pulled back out.
        let thrust = 1 - pow(1 - Self.span(k, 0, 0.09), 3)
        let pull = Self.ease(Self.span(k, 0.17, 0.3))
        if pull < 1 {
            let ang = Double.pi * 0.24
            let len = H * 0.5, back = len * 1.1 * ((1 - thrust) + pull)
            Self.slayerStake(art, tipX: ix - cos(ang) * back, tipY: iy - sin(ang) * back, angle: ang, length: len,
                             width: max(4, (H * 0.07).rounded()))
        }

        Self.slayerDustGrain(art, W: W, H: H, seed: Int(k * 1.6 * 15), amount: 1 - 0.8 * k)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// A wooden stake pointing along `angle` with its tip at (`tipX`, `tipY`): a dark shaft with a pale top edge and
    /// grain, whittled to a paler point.
    private static func slayerStake(_ art: CGContext, tipX: Double, tipY: Double, angle: Double, length: Double, width: Double) {
        art.saveGState()
        art.translateBy(x: tipX.rounded(), y: tipY.rounded())
        art.rotate(by: angle)
        let tip = width * 1.6, half = (width / 2).rounded()
        art.setFillColor(dustRGB(0x5E3C20)); art.fill(CGRect(x: -length, y: -half, width: length - tip, height: half * 2))
        art.setFillColor(dustRGB(0x8A6038)); art.fill(CGRect(x: -length, y: half - 1, width: length - tip, height: 1))
        art.setFillColor(dustRGB(0x442C18)); art.fill(CGRect(x: -length, y: -half, width: length - tip, height: 1))
        art.setFillColor(dustRGB(0x46301A))
        for g in 0..<4 { art.fill(CGRect(x: -length + 6 + Double(g) * length * 0.2, y: Double(g % 2) - 1, width: length * 0.1, height: 1)) }
        let point = CGMutablePath()
        point.move(to: CGPoint(x: -tip, y: -half)); point.addLine(to: CGPoint(x: 0, y: 0))
        point.addLine(to: CGPoint(x: -tip, y: half)); point.closeSubpath()
        art.setFillColor(dustRGB(0x9A6E40)); art.addPath(point); art.fillPath()
        art.setFillColor(dustRGB(0xBC8E58)); art.fill(CGRect(x: -tip, y: half - 1, width: tip * 0.6, height: 1))
        art.setFillColor(dustRGB(0x5A3A20)); art.fill(CGRect(x: -tip, y: -half, width: tip * 0.5, height: 1))
        // The butt, rough-cut.
        art.setFillColor(dustRGB(0x442C18)); art.fill(CGRect(x: -length, y: -half, width: 2, height: half * 2))
        art.restoreGState()
    }

    // MARK: Shared by Dusting, Sunrise and Restless

    /// The trip's art canvas over `r`, about 180 art pixels tall, drawn into in its own pixels from the bottom left.
    static func slayerDustCanvas(in r: CGRect) -> (CGContext, Int, Int, CGFloat)? {
        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = artCanvas(width: w, height: h, px: px, in: r) else { return nil }
        art.translateBy(x: r.minX, y: r.minY)
        art.scaleBy(x: px, y: px)
        return (art, w, h, px)
    }

    /// Film grain over the night: specks, pale and dark, that move every frame (`seed`), `amount` 0…1 strong.
    static func slayerDustGrain(_ art: CGContext, W: Double, H: Double, seed: Int, amount: Double) {
        guard amount > 0 else { return }
        let count = Int(W * H / 170)
        for i in 0..<count {
            let s = seed * 7919 + i * 3
            art.setFillColor(dustRGB(i % 3 == 0 ? 0xC8D0E8 : 0x000000, CGFloat(amount * (i % 3 == 0 ? 0.22 : 0.3))))
            art.fill(CGRect(x: (noise(s) * W).rounded(.down), y: (noise(s + 1) * H).rounded(.down), width: 1, height: 1))
        }
    }
}

/// A colour from 0xRRGGBB.
private func dustRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
