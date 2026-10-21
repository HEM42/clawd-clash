import CoreGraphics
import Foundation

extension BurtonTrip {
    /// It's Alive! A storm rolls over the old place: the sky darkens, rain slants down, and a patched kite climbs into
    /// the top right on its long string (0–0.26). Lightning strikes it: a jagged bolt with forks, the kite lit white,
    /// sparks running down the string (0.26–0.4), and the whole scene flashes in black and white, the old place
    /// strobing as a negative and a hard grey print, a white blink, and the new place comes through, the same way,
    /// then settles in greys with a flicker of film grain (0.28–0.55). The kite is blown away up off the top. Colour
    /// seeps back in from under the strike, spreading out in a ragged edge that crackles with violet sparks
    /// (0.55–0.95). Going to a Frankenweenie place (Victor's attic, the windmill mini-golf), the new place stays in
    /// its greys: no colour comes back, only the grain and a last flicker fade.
    func drawItsAlive(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let tick = Int(k * 2.2 * 30)
        let greyPlace = [Location.newHollandAttic, .windmillMiniGolf].contains(to)
        let strike = 0.26
        let kite = (x: W * 0.74 + sin(k * 11) * W * 0.015,
                    y: H * (0.24 + 0.9 * pow(1 - Self.ease(Self.span(k, 0, 0.24)), 2))
                        - H * 0.7 * Self.ease(Self.span(k, 0.5, 0.82)) + cos(k * 13) * H * 0.02)

        // The picture: old, then strobing in black and white, then new in greys.
        enum Look { case colour, grey, negative, white }
        let flashes: [(Double, Look, Bool)] = [
            (0.28, .white, false), (0.3, .negative, false), (0.33, .grey, false), (0.36, .negative, false),
            (0.385, .white, true), (0.405, .negative, true), (0.43, .grey, true),
        ]
        var look = Look.colour, showNew = false
        for (at, l, n) in flashes where k >= at { look = l; showNew = n }
        ctx.draw(showNew ? new : old, in: r)
        switch look {
        case .white:
            ctx.setFillColor(rgb(0xF2EEE3)); ctx.fill(r)
        case .negative:
            ctx.setBlendMode(.difference); ctx.setFillColor(rgb(0xFFFFFF)); ctx.fill(r)
            ctx.setBlendMode(.saturation); ctx.setFillColor(rgb(0x808080)); ctx.fill(r)
            ctx.setBlendMode(.normal)
        case .grey:
            Self.aliveGrey(ctx, r: r, px: px, cols: c.w, rows: c.h, k: k, greyPlace: greyPlace)
            // A hard print for a beat after each flash, then the flicker of old film.
            let hard = 1 - Self.span(k, 0.43, 0.5)
            let flicker = (noise(tick * 13) - 0.5) * 0.12 * (1 - Self.span(k, 0.6, 0.95))
            if hard > 0 {
                ctx.setBlendMode(.overlay); ctx.setFillColor(rgb(0x000000, CGFloat(0.35 * hard))); ctx.fill(r)
            }
            ctx.setBlendMode(.normal)
            if flicker > 0 { ctx.setFillColor(rgb(0xF2EEE3, CGFloat(flicker))); ctx.fill(r) }
            if flicker < 0 { ctx.setFillColor(rgb(0x16161B, CGFloat(-flicker))); ctx.fill(r) }
            // Going somewhere already grey, a last flicker of sheet lightning instead of the colour coming back.
            if greyPlace && ((k > 0.78 && k < 0.8) || (k > 0.83 && k < 0.845)) {
                ctx.setFillColor(rgb(0xF2EEE3, 0.28)); ctx.fill(r)
            }
        case .colour:
            // The storm darkening the old place.
            let dark = Self.ease(Self.span(k, 0, 0.22))
            if dark > 0 { ctx.setFillColor(rgb(0x14142A, CGFloat(0.5 * dark))); ctx.fill(r) }
        }

        // Rain, slanting, through the storm and thinning away after the strike.
        let rain = Self.span(k, 0.02, 0.15) * (1 - Self.span(k, 0.4, 0.75))
        if rain > 0 && look != .white {
            for n in 0..<Int(W * H / 260) {
                let x0 = noise(n * 3) * (W + H * 0.3), fallY = (noise(n * 3 + 1) * H + k * 2.2 * H * 5.5)
                let y = fallY.truncatingRemainder(dividingBy: H + 8) - 4, x = x0 - y * 0.3
                c.glowLine(x, y, x - 1.2, y + 4, core: C(0xA8B4D8, 0.5 * rain), glow: C(0, 0), coreR: 0.45, glowR: 0.5)
            }
        }

        // The kite and its string, down to someone holding it off the bottom left.
        if kite.y > -H * 0.3 && k < 0.85 {
            let lit = k > strike && k < strike + 0.12 && tick % 2 == 0
            let hand = (x: W * 0.3, y: H + 2)
            let sag = (x: (kite.x + hand.x) / 2 + W * 0.04, y: (kite.y + hand.y) / 2 + H * 0.08)
            var last = (x: kite.x, y: kite.y + H * 0.07)
            let charge = Self.span(k, strike + 0.01, strike + 0.14), held = 1 - Self.span(k, 0.6, 0.72)
            for q in 1...16 {
                let t = Double(q) / 16, a = 1 - t
                let p = (x: a * a * last.x + 2 * a * t * sag.x + t * t * hand.x,
                         y: a * a * (kite.y + H * 0.07) + 2 * a * t * sag.y + t * t * hand.y)
                let hot = charge > 0 && charge < 1 && abs(t - charge) < 0.12
                c.glowLine(q == 1 ? kite.x : last.x, q == 1 ? kite.y + H * 0.07 : last.y, p.x, p.y,
                           core: hot ? C(0xF2EEE3) : C(0x2A2A30, 0.8 * held), glow: hot ? C(0x6B5BD6) : C(0, 0),
                           coreR: 0.45, glowR: hot ? 2 : 0.5)
                last = p
            }
            Self.aliveKite(c, x: kite.x, y: kite.y, size: max(10, H * 0.18), lit: lit, k: k)
        }

        // The bolt: down from the clouds onto the kite, forking, flickering.
        if k > strike && k < strike + 0.11 && tick % 3 != 1 {
            var rng = 4100 + tick / 2
            func jag(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ steps: Int,
                     _ wide: Double) -> [(Double, Double)] {
                var pts = [(x0, y0)]
                for q in 1..<steps {
                    let t = Double(q) / Double(steps)
                    rng += 1
                    pts.append((x0 + (x1 - x0) * t + (noise(rng) - 0.5) * wide, y0 + (y1 - y0) * t))
                }
                pts.append((x1, y1))
                return pts
            }
            let main = jag(kite.x - W * 0.06, -2, kite.x, kite.y - H * 0.06, 9, H * 0.12)
            var forks: [[(Double, Double)]] = []
            for f in [2, 5] where f < main.count {
                let p = main[f]
                forks.append(jag(p.0, p.1, p.0 + (noise(rng + f) - 0.3) * W * 0.12, p.1 + H * 0.16, 4, H * 0.06))
            }
            for line in [main] + forks {
                let thick = line.count > 5 ? 1.0 : 0.6
                for (a, b) in zip(line, line.dropFirst()) {
                    c.glowLine(a.0, a.1, b.0, b.1, core: C(0xFFFFFF), glow: C(0x6B5BD6), coreR: 1.1 * thick,
                               glowR: 3.6 * thick)
                }
            }
        }

        // Violet sparks along the edge where colour is coming back, and film grain over the greys.
        if look == .grey {
            let grain = Self.span(k, 0.43, 0.5) * (1 - Self.span(k, greyPlace ? 0.85 : 0.75, 0.98))
            if grain > 0 {
                for n in 0..<min(700, Int(W * H / 120)) {
                    let s = tick * 7919 + n * 3
                    let speck = n % 3 == 0 ? C(0xF2EEE3, 0.3 * grain) : C(0x000000, 0.35 * grain)
                    c.px(Int(noise(s) * W), Int(noise(s + 1) * H), speck)
                }
            }
            if !greyPlace {
                let front = Self.aliveFront(k), reach = hypot(max(kite.x, W - kite.x), H)
                if front > 0 && front < 1 {
                    for n in 0..<60 {
                        let a = noise(n * 5 + tick) * .pi
                        let d = front * reach * 1.15 + (noise(n * 5 + 1 + tick) - 0.5) * H * 0.06
                        let x = Self.aliveSeat.x * W + cos(a) * d, y = -H * 0.05 + sin(a) * d
                        c.px(Int(x), Int(y), n % 3 == 0 ? C(0xFFFFFF) : C(0x8A7BF0))
                    }
                }
            }
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// Where the colour starts seeping back in, across the top (a fraction of the width).
    private static let aliveSeat = (x: 0.74, y: 0.0)

    /// How far the colour has seeped back out from under the strike at `k` (0 none yet, 1 everywhere).
    private static func aliveFront(_ k: Double) -> Double { ease(span(k, 0.55, 0.93)) }

    /// The greys over the picture in `r`: all of it at first, then (unless the new place is grey itself) only what
    /// the colour seeping out from the top right hasn't reached, its edge ragged on the art's grid.
    private static func aliveGrey(_ ctx: CGContext, r: CGRect, px: CGFloat, cols: Int, rows: Int, k: Double,
                                  greyPlace: Bool) {
        let front = greyPlace ? 0 : aliveFront(k)
        ctx.saveGState()
        ctx.setBlendMode(.saturation)
        ctx.setFillColor(rgb(0x808080, greyPlace ? CGFloat(1 - span(k, 0.9, 1)) : 1))
        if front <= 0 {
            ctx.fill(r)
        } else if front < 1 {
            // Per block, how far the colour has come back: none, a third, two thirds or all.
            let cell = max(2, Int((Double(cols * rows) / 900).squareRoot().rounded()))
            let bc = (cols + cell - 1) / cell, br = (rows + cell - 1) / cell
            let W = Double(cols), H = Double(rows), sx = aliveSeat.x * W
            let reach = hypot(max(sx, W - sx), H)
            var levels: [[CGRect]] = [[], [], []]
            for j in 0..<br {
                for i in 0..<bc {
                    let cx = (Double(i) + 0.5) * Double(cell), cy = (Double(j) + 0.5) * Double(cell)
                    let d = hypot(cx - sx, cy + H * 0.05) / reach
                    let ragged = d + (noise(j * 131 + i * 17) - 0.5) * 0.08
                    let back = (front * 1.15 - ragged) / 0.1
                    guard back < 1 else { continue }
                    let level = back <= 0 ? 0 : back < 0.5 ? 1 : 2
                    levels[level].append(CGRect(x: r.minX + CGFloat(i * cell) * px,
                                                y: r.maxY - CGFloat((j + 1) * cell) * px,
                                                width: CGFloat(cell) * px, height: CGFloat(cell) * px))
                }
            }
            for (n, rects) in levels.enumerated() where !rects.isEmpty {
                ctx.setFillColor(rgb(0x808080, [1, 0.66, 0.33][n]))
                ctx.fill(rects)
            }
        }
        ctx.restoreGState()
    }

    /// The patched diamond kite at (`x`, `y`) (its top point), `size` tall: grey and bone panels, a dark cross of
    /// spars, a tail of bows below; lit white when the bolt hits.
    private static func aliveKite(_ c: PixelCanvas, x: Double, y: Double, size: Double, lit: Bool, k: Double) {
        let hw = size * 0.38, mid = y + size * 0.36, bottom = y + size
        let ink = C(0x16161B)
        let panels: [(UInt32, (Double, Double), (Double, Double))] = [
            (0xD8D2C4, (x - hw, mid), (x, y)), (0x9A968E, (x, y), (x + hw, mid)),
            (0x6E6A66, (x - hw, mid), (x, bottom)), (0xC8C2B4, (x + hw, mid), (x, bottom)),
        ]
        for (hex, a, b) in panels {
            // A triangle from the spine to the corner, filled a row at a time.
            let top = min(a.1, b.1), low = max(a.1, b.1)
            for yy in Int(top)...Int(low) {
                let t = (Double(yy) - top) / max(1, low - top)
                let edgeX = a.1 < b.1 ? a.0 + (b.0 - a.0) * t : b.0 + (a.0 - b.0) * t
                let x0 = min(x, edgeX), x1 = max(x, edgeX)
                c.rect(Int(x0), yy, max(1, Int(x1 - x0)), 1, lit ? C(0xFFFFFF) : C(hex))
            }
        }
        for (a, b) in [((x, y), (x - hw, mid)), ((x - hw, mid), (x, bottom)), ((x, bottom), (x + hw, mid)),
                       ((x + hw, mid), (x, y)), ((x, y), (x, bottom)), ((x - hw, mid), (x + hw, mid))] {
            c.glowLine(a.0, a.1, b.0, b.1, core: lit ? C(0x6B5BD6) : ink, glow: C(0, 0), coreR: 0.5, glowR: 0.55)
        }
        // A stitched patch.
        c.rect(Int(x + hw * 0.2), Int(mid + size * 0.12), max(2, Int(size * 0.12)), max(2, Int(size * 0.1)),
               C(0x4E4A48))
        // The tail, swinging.
        var tx = x, ty = bottom
        for q in 0..<5 {
            let nx = x + sin(k * 14 + Double(q) * 0.9) * size * 0.12 - Double(q) * size * 0.05, ny = ty + size * 0.18
            c.glowLine(tx, ty, nx, ny, core: ink, glow: C(0, 0), coreR: 0.45, glowR: 0.5)
            c.rect(Int(nx) - 1, Int(ny), 3, 1, q % 2 == 0 ? C(0xF2EEE3) : C(0x16161B))
            tx = nx; ty = ny
        }
    }
}
