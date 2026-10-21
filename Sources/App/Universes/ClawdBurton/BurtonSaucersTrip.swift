import CoreGraphics
import Foundation

extension BurtonTrip {
    /// Saucer Swarm. Five Martian saucers swoop in from the top right in a tight V, dip low over the old place and
    /// spread out into a line across its sky, bobbing, their rim lights chasing (0–0.24). They open fire: green rays
    /// with a yellow core flicker down from their bellies in bursts, each hit a green-and-yellow spark (0.18–0.58).
    /// Out from every hit the picture breaks into pixels: it goes to flat squares that flash green, then they come
    /// loose and tumble away, scattering from the hit, until only the new place is left (by 0.72). Then the saucers
    /// peel off one by one, dipping and climbing away off the right edge (0.55–0.97), and the middle one leaves a tiny
    /// "ACK ACK" hanging in the air behind it.
    func drawSaucers(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let s = max(1, Int((H / 90).rounded())), S = Double(s)
        let tick = Int(k * 2.0 * 30)

        // Where each saucer is: swooping in on a curve to its spot in the line, bobbing, then peeling off.
        let count = 5
        func saucer(_ i: Int) -> (x: Double, y: Double) {
            let spot = (x: W * (0.3 + 0.15 * Double(i)), y: H * 0.2 + S * Double(i % 2 == 0 ? 0 : 8))
            let start = (x: W + S * Double(28 + i * 18), y: -S * Double(14 + i * 7))
            let bend = (x: W * (0.55 + 0.06 * Double(i)), y: H * 0.62)
            let t = Self.ease(Self.span(k, 0.02 * Double(i), 0.2 + 0.02 * Double(i)))
            let u = 1 - t
            var x = u * u * start.x + 2 * u * t * bend.x + t * t * spot.x
            var y = u * u * start.y + 2 * u * t * bend.y + t * t * spot.y
            y += sin(k * 26 + Double(i) * 1.9) * S * t
            let leave = Self.span(k, 0.55 + 0.06 * Double(i), 0.73 + 0.06 * Double(i))
            if leave > 0 {
                x += (W * 0.95 + S * 40) * leave * leave
                y += H * 0.1 * sin(leave * .pi) - (H * 0.45 + S * 10) * leave * leave
            }
            return (x, y)
        }
        let places = (0..<count).map(saucer)

        // The shots: three bursts from each saucer, each at a spot on the picture below it.
        var hits: [(t: Double, x: Double, y: Double, from: Int)] = []
        for b in 0..<3 {
            for i in 0..<count {
                let seed = b * 41 + i * 7
                let t = 0.2 + 0.11 * Double(b) + 0.025 * Double((i * 3 + b) % count)
                let x = W * (0.3 + 0.15 * Double(i)) + (noise(seed + 900) - 0.5) * W * 0.3
                hits.append((t, min(W - 2, max(2, x)), H * (0.4 + 0.5 * noise(seed + 901)), i))
            }
        }

        // The old place in squares: each goes to a flat pixel once a hit's blast reaches it, then tumbles away.
        let cell = max(2, Int((W * H / 1200).squareRoot().rounded()))
        let cols = (c.w + cell - 1) / cell, rows = (c.h + cell - 1) / cell
        let colours = Self.saucerSample(old, cols: cols, rows: rows)
        let reach = max(W, H) * 0.9
        ctx.draw(new, in: r)
        var keep: [CGRect] = []
        let flat = 0.06, fall = 0.16
        for j in 0..<rows {
            var run = -1
            for i in 0...cols {
                var standing = false
                if i < cols {
                    let cx = (Double(i) + 0.5) * Double(cell), cy = (Double(j) + 0.5) * Double(cell)
                    var at = 0.64 + 0.08 * noise(j * 313 + i * 17), near = 0
                    for (n, h) in hits.enumerated() {
                        let when = h.t + 0.02 + hypot(cx - h.x, cy - h.y) / reach * 0.32
                        if when < at { at = when; near = n }
                    }
                    at += 0.025 * noise(j * 97 + i * 31)
                    if k < at - flat {
                        standing = true
                    } else if k < at + fall {
                        let col = colours.isEmpty ? C(0x16161B) : colours[j * cols + i]
                        if k < at {
                            // Gone to one flat pixel, flashing green as the blast hits it.
                            let f = (k - (at - flat)) / flat
                            c.rect(i * cell, j * cell, cell, cell, Px(r: col.r / 2, g: col.g / 2, b: col.b / 2, a: 255))
                            c.rect(i * cell, j * cell, cell - 1, cell - 1, col)
                            if f < 0.55 {
                                c.rect(i * cell, j * cell, cell - 1, cell - 1, C(0x3AE05A, 0.55 * (1 - f / 0.55)))
                            }
                        } else {
                            // Come loose: thrown out from the hit, falling, shrinking, fading.
                            let f = (k - at) / fall, h = hits[near]
                            let d = max(1, hypot(cx - h.x, cy - h.y))
                            let push = Double(cell) * (2 + 2 * noise(i * 7 + j * 3)) * f
                            let x = cx + (cx - h.x) / d * push, y = cy + (cy - h.y) / d * push + H * 0.3 * f * f
                            let size = max(1, Int((Double(cell - 1) * (1 - 0.5 * f)).rounded()))
                            c.rect(Int(x) - size / 2, Int(y) - size / 2, size, size, col.alpha(1 - f * f))
                        }
                    }
                }
                if standing && run < 0 { run = i }
                if !standing && run >= 0 {
                    keep.append(CGRect(x: r.minX + CGFloat(run * cell) * px, y: r.maxY - CGFloat((j + 1) * cell) * px,
                                       width: CGFloat((i - run) * cell) * px, height: CGFloat(cell) * px))
                    run = -1
                }
            }
        }
        if !keep.isEmpty { ctx.saveGState(); ctx.clip(to: keep); ctx.draw(old, in: r); ctx.restoreGState() }

        // The rays, flickering, from a saucer's belly to its hit, and the spark where each lands.
        for h in hits where k > h.t && k < h.t + 0.07 && (tick + h.from) % 3 != 2 {
            let p = places[h.from]
            c.glowLine(p.x, p.y + 3 * S, h.x, h.y, core: C(0xFFF07A), glow: C(0x3AE05A), coreR: 0.6 * S, glowR: 2.2 * S)
            Self.saucerSpark(c, x: h.x, y: h.y, s: S, seed: tick + h.from * 5)
        }

        // The saucers, the speeding ones trailing a few streaks.
        for (i, p) in places.enumerated() where p.x > -S * 20 && p.x < W + S * 20 && p.y > -S * 10 {
            let leave = Self.span(k, 0.55 + 0.06 * Double(i), 0.73 + 0.06 * Double(i))
            if leave > 0.15 {
                for q in 0..<4 {
                    let len = Int(S * (6 + 10 * leave)), y = Int(p.y) + (q - 2) * s
                    c.rect(Int(p.x) - 18 * s - len - q * 3 * s, y, len, 1, C(0xB8BCC8, 0.5))
                }
            }
            Self.saucerDraw(c, x: Int(p.x.rounded()), y: Int(p.y.rounded()), s: s, t: k * 2.0 + Double(i) * 0.4)
        }

        // "ACK ACK", popping up where the middle saucer was as it leaves, drifting up and fading.
        let said = Self.span(k, 0.68, 0.93)
        if said > 0 && said < 1 {
            let words = said < 0.25 ? "ACK" : "ACK ACK"
            let spot = (x: W * 0.6, y: H * 0.2 + 5 * S)
            let tx = Int(spot.x) - Scenes.bjTextWidth("ACK ACK", s: s) / 2
            let ty = Int(spot.y + S * 8 - H * 0.05 * said)
            let a = 1 - Self.span(said, 0.7, 1)
            for (dx, dy) in [(1, 1), (0, 1), (1, 0)] {
                Scenes.bjText(c, words, x: tx + dx, y: ty + dy, s: s, C(0x16161B, a))
            }
            Scenes.bjText(c, words, x: tx, y: ty, s: s, C(0x8AF0A0, a))
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// The colour of each square of `img` on a `cols` × `rows` grid (rows from the top), one sample each.
    private static func saucerSample(_ img: CGImage, cols: Int, rows: Int) -> [Px] {
        guard cols > 0, rows > 0, let g = CGContext(data: nil, width: cols, height: rows, bitsPerComponent: 8,
                                                    bytesPerRow: cols * 4, space: CGColorSpaceCreateDeviceRGB(),
                                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue),
              let data = g.data else { return [] }
        g.interpolationQuality = .low
        g.draw(img, in: CGRect(x: 0, y: 0, width: cols, height: rows))
        let bytes = data.bindMemory(to: UInt8.self, capacity: cols * rows * 4)
        return (0..<(cols * rows)).map { n in Px(r: bytes[n * 4], g: bytes[n * 4 + 1], b: bytes[n * 4 + 2], a: 255) }
    }

    /// A Martian saucer centred on (`x`, `y`), `s` art pixels to its pixel: a silver disc with an ink edge and a
    /// darker belly, its rim lights chasing round, a green glass dome over a pink brain.
    private static func saucerDraw(_ c: PixelCanvas, x: Int, y: Int, s: Int, t: Double) {
        let ink = C(0x16161B)
        c.ellipse(x, y - 4 * s, 6 * s + 1, 5 * s + 1, ink)
        c.ellipse(x, y - 4 * s, 6 * s, 5 * s, C(0x5AC07A))
        c.ellipse(x, y - 4 * s, 6 * s - 1, 5 * s - 1, C(0x8AF0A0))
        c.ellipse(x, y - 5 * s, 3 * s, 2 * s, C(0xE88AB0))
        c.rect(x - 2 * s, y - 6 * s, s, s, C(0xB85A84)); c.rect(x + s, y - 5 * s, s, s, C(0xB85A84))
        c.rect(x - 3 * s, y - 8 * s, s, s, C(0xFFFFFF, 0.8))
        c.ellipse(x, y, 16 * s + 1, 4 * s + 1, ink)
        c.ellipse(x, y, 16 * s, 4 * s, C(0xB8BCC8))
        c.ellipse(x, y + 2 * s, 13 * s, 2 * s, C(0x6A6E7A))
        c.rect(x - 16 * s, y - s, 32 * s, s, C(0xE4E8F0))
        for n in 0..<7 {
            let on = (n + Int(t * 8)) % 3 == 0
            c.rect(x - 12 * s + n * 4 * s, y + s, s, s, on ? C(0xFFF07A) : C(0x8A8040))
        }
    }

    /// A ray's hit: a yellow-white core with green specks thrown out round it.
    private static func saucerSpark(_ c: PixelCanvas, x: Double, y: Double, s: Double, seed: Int) {
        let n = max(1, Int(s))
        c.rect(Int(x) - n, Int(y) - n, 2 * n + 1, 2 * n + 1, C(0xFFFBD0))
        for q in 0..<8 {
            let a = Double(q) / 8 * 2 * .pi + noise(seed + q) * 0.6, d = s * (2 + 3 * noise(seed * 3 + q))
            c.rect(Int(x + cos(a) * d), Int(y + sin(a) * d), n, n, q % 3 == 0 ? C(0xFFF07A) : C(0x3AE05A))
        }
    }
}
