import CoreGraphics
import Foundation

// Dusting (`SlayerWipe.dusting`): a stake strikes and the old place bursts into grey-gold dust that swirls and blows
// away to show the new place. The most common trip, so it is quick and punchy, and its work per frame is capped.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. A rough wooden stake thrusts in from
    /// the lower left and strikes (0–0.09) with a white-gold flash that lights the whole frame for a blink (0.085–0.18),
    /// then pulls back out (0.17–0.3). The old place, cut into about a thousand square blocks whatever the size,
    /// crumbles from the strike outward (0.1–0.63), each block breaking into smaller bits along the crumbling edge:
    /// each glows dust-gold for a moment, then goes in a puff.
    /// Its dust (a fixed pool of specks, at most `slayerDustSpecks` a frame) bursts out, is caught by a gust and
    /// carried along four sinuous ribbons that sweep up and to the right, thinning as they go, with a few bright
    /// glints (gone by 0.95). The new place waits behind in a night-blue shade that lifts as the dust clears. The
    /// stake, the dust and the flash are pixel art, with a little film grain over the night.
    func drawDusting(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard let canvas = Self.slayerDustCanvas(in: r) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let (art, w, h, px) = canvas
        let W = Double(w), H = Double(h)

        // The new place behind, in the night's shade until the dust has gone.
        ctx.draw(new, in: r)
        let shade = 0.42 * (1 - Self.ease(Self.span(k, 0.3, 0.95)))
        if shade > 0 { ctx.setFillColor(dustRGB(0x0A0E22, CGFloat(shade))); ctx.fill(r) }

        // The old place in square blocks, about a thousand of them at any size, each going when the crumbling
        // reaches it: nearer the strike first, a little ragged.
        let grid = Self.slayerDustGrid(in: r, px: px)
        let cell = grid.cell, cols = grid.cols, rows = grid.rows, C = Double(cell)
        let ix = W * 0.55, iy = H * 0.5
        let far = max(hypot(ix, iy), hypot(W - ix, iy), hypot(ix, H - iy), hypot(W - ix, H - iy))
        /// When block (`i`, `j`) goes.
        func goes(_ i: Int, _ j: Int) -> Double {
            let d = hypot((Double(i) + 0.5) * C - ix, (Double(j) + 0.5) * C - iy) / far
            return 0.1 + 0.38 * d + 0.1 * noise(j * 977 + i * 131)
        }
        // Along the crumbling edge itself a block breaks up into smaller bits (2 to 4 art pixels), each going at its
        // own moment, so the edge reads as crumbling grit rather than big squares. Only the blocks on the edge are
        // split, so the work stays about the same.
        let sub = cell % 4 == 0 && cell >= 8 ? 4 : (cell % 3 == 0 && cell >= 6 ? 3 : (cell >= 4 ? 2 : 1))
        let bit = cell / sub
        var keep: [CGRect] = []
        for j in 0..<rows {
            var runStart = -1
            for i in 0...cols {
                var standing = false
                if i < cols {
                    let at = goes(i, j)
                    let crumbling = sub > 1 && abs(k - at) < 0.035
                    if crumbling {
                        for q in 0..<(sub * sub) {
                            let si = q % sub, sj = q / sub
                            let bx = i * cell + si * bit, by = j * cell + sj * bit
                            let bw = si == sub - 1 ? cell - bit * (sub - 1) : bit, bh = sj == sub - 1 ? cell - bit * (sub - 1) : bit
                            let atBit = at + (noise(j * 4093 + i * 263 + q * 17) - 0.5) * 0.06
                            guard k < atBit else { continue }
                            keep.append(CGRect(x: r.minX + CGFloat(bx) * px, y: r.minY + CGFloat(by) * px,
                                               width: CGFloat(bw) * px, height: CGFloat(bh) * px))
                            let glow = 1 - (atBit - k) / 0.035
                            if glow > 0 {
                                art.setFillColor(dustRGB(glow > 0.6 ? 0xE8CC84 : 0xA89C84, CGFloat(0.45 * glow)))
                                art.fill(CGRect(x: bx, y: by, width: bw, height: bh))
                            }
                        }
                    }
                    if k < at && !crumbling {
                        standing = true
                        // Just before it goes, the block glows the colour of dust.
                        let glow = 1 - (at - k) / 0.035
                        if glow > 0 {
                            art.setFillColor(dustRGB(glow > 0.6 ? 0xE8CC84 : 0xA89C84, CGFloat(0.45 * glow)))
                            art.fill(CGRect(x: Double(i) * C, y: Double(j) * C, width: C, height: C))
                        }
                    } else if k >= at && k < at + 0.1 {
                        // Just after, a puff of dust where it stood: a few clumps spreading as the gust takes them.
                        let t = (k - at) / 0.1, clump = max(1, (C / 4 * (1 - t * 0.5)).rounded())
                        for q in 0..<4 {
                            let seed = j * 31 + i * 7 + q * 3
                            art.setFillColor(dustRGB(noise(seed) < 0.5 ? 0xB8A27A : 0x9A9080, CGFloat(0.7 * (1 - t))))
                            let cx = Double(i) * C + noise(seed + 1) * (C - clump) + C * (1.5 + noise(seed + 2) * 2) * t
                            let cy = Double(j) * C + noise(seed + 3) * (C - clump) + C * (0.4 + noise(seed + 4)) * t
                            art.fill(CGRect(x: cx.rounded(), y: cy.rounded(), width: clump, height: clump))
                        }
                    }
                }
                if standing && runStart < 0 { runStart = i }
                if !standing && runStart >= 0 {
                    keep.append(CGRect(x: r.minX + CGFloat(runStart * cell) * px, y: r.minY + CGFloat(j * cell) * px,
                                       width: CGFloat((i - runStart) * cell) * px, height: CGFloat(cell) * px))
                    runStart = -1
                }
            }
        }
        if !keep.isEmpty {
            ctx.saveGState(); ctx.clip(to: keep); ctx.draw(old, in: r); ctx.restoreGState()
        }

        // The dust: each speck from a block, born as it goes, bursts out from the strike, then rides its ribbon on
        // the gust, up and to the right, spreading thin.
        let life = 0.32, blocks = cols * rows
        let tones: [UInt32] = [0x7E7A72, 0x9C9482, 0xB8A47E, 0xD4B266]
        for n in 0..<Self.slayerDustSpecks {
            let s = n * 7
            let b = min(blocks - 1, Int(noise(s + 1) * Double(blocks)))
            let bi = b % cols, bj = b / cols
            let a = (k - goes(bi, bj) - noise(s + 2) * 0.05) / life
            guard a > 0 && a < 1 else { continue }
            let sx = (Double(bi) + noise(s + 3)) * C, sy = (Double(bj) + noise(s + 4)) * C
            // Its stream, the nearest of four sinuous ribbons that sweep across and up to the right.
            let stream = min(3, max(0, Int(sy / H * 4)))
            let u = (sx - ix + W * 0.4) / (W * 1.05) + 0.04 * noise(s + 5) + a * 0.75
            let px0 = ix - W * 0.4 + u * W * 1.05
            let py0 = H * (0.18 + 0.2 * Double(stream)) + u * u * H * 0.3 + sin(u * 6 + Double(stream) * 1.7) * H * 0.07
            // A puff out from the strike, then the pull into the stream; the ribbon spreads thin as it goes.
            let d = max(1, hypot(sx - ix, sy - iy))
            let puff = C * 1.2 * (1 - pow(1 - min(1, a * 3), 3))
            let pull = Self.ease(min(1, a * 5))          // into its ribbon soon, so the ribbons read from the start
            let spread = (noise(s + 6) - 0.5) * C * (0.25 + 1.3 * a)
            let x = (sx + (sx - ix) / d * puff) * (1 - pull) + px0 * pull
            let y = (sy + (sy - iy) / d * puff) * (1 - pull) + (py0 + spread) * pull
            let glint = noise(s + 8) > 0.92
            let fade = pow(1 - a, 1.3)
            art.setFillColor(glint ? dustRGB(0xFFF4C8, CGFloat(min(1, fade * 1.3)))
                                    : dustRGB(tones[min(3, Int(noise(s + 9) * 4))], CGFloat(fade)))
            // Early on a speck is a clump; on the gust, a short streak along the stream.
            let streak: Double = pull > 0.5 ? 4 : 2, tall: Double = a < 0.4 && !glint ? 2 : 1
            art.fill(CGRect(x: x.rounded(), y: y.rounded(), width: max(streak, tall), height: tall))
        }

        // The strike's flash: the whole frame lit for a blink, then a white-gold star with long spokes and a ring.
        let flash = Self.span(k, 0.085, 0.18)
        if flash > 0 && flash < 1 {
            let fade = CGFloat(1 - flash)
            if flash < 0.4 {
                art.setFillColor(dustRGB(0xFFF4D8, CGFloat(0.35 * (1 - flash / 0.4))))
                art.fill(CGRect(x: 0, y: 0, width: W, height: H))
            }
            let unit = max(2, (H / 40).rounded())
            let fx = ix.rounded(), fy = iy.rounded(), arm = (unit * (4 + 9 * flash)).rounded(), t = unit
            art.setFillColor(dustRGB(0xFFF4D0, fade))
            art.fill(CGRect(x: fx - arm, y: fy - t / 2, width: arm * 2, height: t))
            art.fill(CGRect(x: fx - t / 2, y: fy - arm, width: t, height: arm * 2))
            let core = (unit * 2 * (1 - flash * 0.6)).rounded()
            art.setFillColor(dustRGB(0xFFFFF6, fade)); art.fill(CGRect(x: fx - core, y: fy - core, width: core * 2, height: core * 2))
            art.setFillColor(dustRGB(0xF0C860, fade))
            for q in 0..<8 {
                let ang = Double(q) * .pi / 4 + .pi / 8, out = arm * (q % 2 == 0 ? 1.1 : 0.75)
                for step in stride(from: out * 0.35, to: out, by: 1) {
                    art.fill(CGRect(x: (fx + cos(ang) * step).rounded(), y: (fy + sin(ang) * step).rounded(), width: 1, height: 1))
                }
            }
            let ring = arm * 1.35
            art.setStrokeColor(dustRGB(0xF4E2A4, fade * 0.8)); art.setLineWidth(max(1, (unit / 2).rounded()))
            art.strokeEllipse(in: CGRect(x: fx - ring, y: fy - ring, width: ring * 2, height: ring * 2))
        }

        // The stake: thrust in from the lower left, a beat on the strike, pulled back out.
        let thrust = 1 - pow(1 - Self.span(k, 0, 0.09), 3)
        let pull = Self.ease(Self.span(k, 0.17, 0.3))
        if pull < 1 {
            let ang = Double.pi * 0.24
            let len = H * 0.5, back = len * 1.1 * ((1 - thrust) + pull)
            Self.slayerStake(art, tipX: ix - cos(ang) * back, tipY: iy - sin(ang) * back, angle: ang, length: len,
                             width: max(5, (H * 0.075).rounded()))
        }

        Self.slayerDustGrain(art, W: W, H: H, seed: Int(k * 1.6 * 15), amount: 1 - 0.8 * k)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// The most dust specks drawn in a frame.
    static let slayerDustSpecks = 1500

    /// Dusting's grid of blocks over `r`: square cells `cell` art pixels across, about a thousand of them at any size.
    static func slayerDustGrid(in r: CGRect, px: CGFloat) -> (cell: Int, cols: Int, rows: Int) {
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        let cell = max(2, Int((Double(r.width * r.height).squareRoot() / 31.6 / Double(px)).rounded()))
        return (cell, (w + cell - 1) / cell, (h + cell - 1) / cell)
    }

    /// A rough wooden stake pointing along `angle` with its tip at (`tipX`, `tipY`): a split-wood shaft with uneven
    /// edges and dark grain, a cloth wrap for the grip, and a crude whittled point in pale fresh-cut facets.
    private static func slayerStake(_ art: CGContext, tipX: Double, tipY: Double, angle: Double, length: Double, width: Double) {
        art.saveGState()
        art.translateBy(x: tipX.rounded(), y: tipY.rounded())
        art.rotate(by: angle)
        let tip = (width * 1.9).rounded(), half = (width / 2).rounded()
        // The shaft, a column of wood at a time, its edges split and uneven.
        var x = -length
        var c = 0
        while x < -tip + 1 {
            let top = half - (noise(c * 3 + 900) < 0.3 ? 1 : 0), bottom = -half + (noise(c * 3 + 901) < 0.3 ? 1 : 0)
            art.setFillColor(dustRGB(0x5C3A1E)); art.fill(CGRect(x: x, y: bottom, width: 2, height: top - bottom))
            art.setFillColor(dustRGB(0x8A6236)); art.fill(CGRect(x: x, y: top - 1, width: 2, height: 1))
            art.setFillColor(dustRGB(0x3A2412)); art.fill(CGRect(x: x, y: bottom, width: 2, height: 1))
            x += 2; c += 1
        }
        // Dark grain running along it, broken.
        art.setFillColor(dustRGB(0x3E2814))
        for g in 0..<Int(half * 2 - 2) where g % 2 == 0 {
            let y = -half + 1 + Double(g)
            var gx = -length + 2 + noise(g + 950) * 8
            while gx < -tip - 2 {
                let run = 4 + noise(Int(gx) + g * 37) * length * 0.18
                art.fill(CGRect(x: gx.rounded(), y: y, width: min(run, -tip - 2 - gx).rounded(), height: 1))
                gx += run + 3 + noise(Int(gx) * 3 + g) * 6
            }
        }
        // The cloth wrap round the grip, bound in diagonal turns.
        let wrap = (width * 1.3).rounded(), wx = (-length * 0.86).rounded()
        art.setFillColor(dustRGB(0xA89C84)); art.fill(CGRect(x: wx, y: -half - 1, width: wrap, height: half * 2 + 2))
        art.setFillColor(dustRGB(0x74695A))
        for t in stride(from: 0.0, to: wrap, by: 3) {
            for y in 0..<Int(half * 2 + 2) {
                let cx = wx + t + Double(y) * 0.5
                if cx < wx + wrap { art.fill(CGRect(x: cx.rounded(), y: -half - 1 + Double(y), width: 1, height: 1)) }
            }
        }
        art.setFillColor(dustRGB(0xD0C4A8)); art.fill(CGRect(x: wx, y: half, width: wrap, height: 1))
        // The point: whittled in crude facets, not a neat cone.
        let facets: [([CGPoint], UInt32)] = [
            ([CGPoint(x: -tip, y: half), CGPoint(x: -tip * 0.55, y: half * 0.55), CGPoint(x: 0, y: 0),
              CGPoint(x: -tip * 0.3, y: 1), CGPoint(x: -tip * 0.7, y: 0)], 0xC8A070),
            ([CGPoint(x: -tip, y: 0), CGPoint(x: -tip * 0.7, y: 0), CGPoint(x: -tip * 0.3, y: 1), CGPoint(x: 0, y: 0),
              CGPoint(x: -tip * 0.35, y: -half * 0.6), CGPoint(x: -tip * 0.8, y: -half)], 0xA07448),
            ([CGPoint(x: -tip, y: -half), CGPoint(x: -tip * 0.8, y: -half), CGPoint(x: -tip * 0.35, y: -half * 0.6),
              CGPoint(x: -tip * 0.62, y: -half * 0.3), CGPoint(x: -tip, y: -half * 0.2)], 0x7E5630),
        ]
        for (points, hex) in facets {
            let p = CGMutablePath(); p.addLines(between: points); p.closeSubpath()
            art.setFillColor(dustRGB(hex)); art.addPath(p); art.fillPath()
        }
        // Knife nicks where the point meets the shaft.
        art.setFillColor(dustRGB(0x3A2412))
        art.fill(CGRect(x: -tip - 1, y: half * 0.2, width: 2, height: 1)); art.fill(CGRect(x: -tip + 1, y: -half * 0.6, width: 1, height: 1))
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

    /// Film grain over the night: up to 600 specks, pale and dark, that move every frame (`seed`), `amount` 0…1 strong.
    static func slayerDustGrain(_ art: CGContext, W: Double, H: Double, seed: Int, amount: Double) {
        guard amount > 0 else { return }
        let count = min(600, Int(W * H / 170))
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
