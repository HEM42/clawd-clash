import CoreGraphics
import Foundation

// Bored Now (`SlayerWipe.boredNow`): Dark Willow's black veins crawl in over the old place from its edges until it's
// dark, then draw back and leave the new place.

extension SlayerTrip {
    /// Black veins, rimmed in crimson, creep in from all four edges of the old place, branching as they go and
    /// leaving a stain of darkness round them, the picture going dark between them (0–0.46); they meet in the middle
    /// and the frame is black, the veins' crimson pulsing once like a heartbeat (0.44–0.56); then they draw back to
    /// the edges the way they came, the dark lifting off the new place after them (0.56–1). The places are drawn as
    /// they are; the veins and the dark are pixel art about 180 pixels tall, scaled up without smoothing, with grain.
    func drawBoredNow(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.drawShot(old, in: r); return }
        guard k < 1 else { ctx.drawShot(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())    // screen pixels per pixel of the veins' art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r),
              let stain = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let swap = k >= 0.5
        ctx.drawShot(swap ? new : old, in: r)
        // A web of its own each time, from where it leaves and where it goes.
        let trip = (from.rawValue + ">" + to.rawValue).unicodeScalars.reduce(7) { ($0 &* 31 &+ Int($1.value)) % 100_003 }

        // How far the veins have reached: creeping in, a held beat of dark, then drawing back.
        let g = swap ? 1 - Self.ease(Self.span(k, 0.56, 1)) : pow(Self.span(k, 0, 0.46), 1.3)
        let pulse = CGFloat(sin(Self.span(k, 0.43, 0.6) * .pi))

        // The dark between them: a pall over the whole picture, deeper at the edges, then black.
        let pall = CGFloat(pow(Self.span(g, 0.45, 0.97), 1.3))
        if pall > 0 {
            art.setFillColor(rgb(0x07030A, 0.55 * pall)); art.fill(r)
            for i in 0..<6 {
                let f = CGFloat(i) / 6
                let inset = CGRect(x: r.minX + r.width * 0.5 * f * CGFloat(g), y: r.minY + r.height * 0.5 * f * CGFloat(g),
                                   width: r.width * (1 - f * CGFloat(g)), height: r.height * (1 - f * CGFloat(g)))
                art.saveGState()
                art.addRect(r); art.addRect(Self.boredGrid(inset, px: px, in: r)); art.clip(using: .evenOdd)
                art.setFillColor(rgb(0x07030A, 0.16 * pall)); art.fill(r)
                art.restoreGState()
            }
        }
        let black = CGFloat(Self.span(g, 0.88, 0.99))
        if black > 0 { art.setFillColor(rgb(0x07030A, black)); art.fill(r) }

        Self.boredVeins(art, stainOn: stain, reach: g, dark: pall, pulse: pulse, trip: trip, px: px, in: r)
        ctx.saveGState(); ctx.setBlendMode(.multiply)
        Self.blit(stain, onto: ctx, width: w, height: h, px: px, in: r)
        ctx.restoreGState()
        Self.boredGrain(art, k: k, strength: CGFloat(0.4 + 0.6 * g) * CGFloat(1 - Self.span(k, 0.9, 1)), px: px, in: r)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// One stretch of a vein: from `a` to `b`, drawn once the veins' reach passes `t0` and finished at `t1`.
    private struct BoredSeg { let a: CGPoint, b: CGPoint, t0: Double, t1: Double, width: CGFloat, depth: Int }

    /// The veins at `reach` (0 none … 1 met in the middle): roots spaced round the edges, each a wandering trunk
    /// heading for the middle and forking as it goes. Under each, a wide stain of dark; then a crimson rim; then the
    /// black vein; and down the trunks a thin crimson thread that brightens with `pulse`.
    private static func boredVeins(_ c: CGContext, stainOn sc: CGContext, reach: Double, dark: CGFloat, pulse: CGFloat,
                                   trip: Int, px: CGFloat, in r: CGRect) {
        guard reach > 0 else { return }
        let segs = boredGrow(in: r, px: px, trip: trip)
        let s = r.height / 200
        var stain: [(CGPoint, CGPoint, CGFloat)] = [], rim: [(CGPoint, CGPoint, CGFloat)] = []
        var vein: [(CGPoint, CGPoint, CGFloat)] = [], thread: [(CGPoint, CGPoint, CGFloat)] = []
        for seg in segs where reach > seg.t0 {
            let f = CGFloat(min(1, (reach - seg.t0) / max(0.0001, seg.t1 - seg.t0)))
            let end = CGPoint(x: seg.a.x + (seg.b.x - seg.a.x) * f, y: seg.a.y + (seg.b.y - seg.a.y) * f)
            let wd = max(px, seg.width)
            stain.append((seg.a, end, wd * 3 + s * 5))
            rim.append((seg.a, end, wd + px * 2))
            vein.append((seg.a, end, wd))
            let heart = dark > 0.3 && wd > px * 2 ? max(px, (wd * 0.34 / px).rounded() * px) : px
            if wd >= px * 3 || dark > 0.3 { thread.append((seg.a, end, heart)) }
        }
        func stroke(_ list: [(CGPoint, CGPoint, CGFloat)], _ hex: UInt32, _ alpha: CGFloat, on layer: CGContext? = nil, widen: CGFloat = 1) {
            let c = layer ?? c
            c.setStrokeColor(rgb(hex, alpha)); c.setLineCap(.square)
            for (a, b, wd) in list {
                c.setLineWidth(((wd * widen) / px).rounded() * px); c.move(to: a); c.addLine(to: b); c.strokePath()
            }
        }
        // The stain, in two steps, goes on its own layer, which darkens the picture under it (multiplied) rather than
        // laying grey over it: a bright window goes a deep wine colour, not a dull grey.
        stroke(stain, 0x3A0614, 0.35, on: sc)
        stroke(stain, 0x3A0614, 0.35, on: sc, widen: 0.6)
        stroke(rim, 0x5A0612, 0.25 + 0.45 * dark + 0.3 * pulse)
        stroke(vein, 0x0A0306, 1)
        stroke(thread, 0xB00E28, 0.2 + 0.5 * dark + 0.3 * pulse)
    }

    /// The veins' shape, the same every frame of a trip but different from one trip to the next (`trip`): in `r`'s
    /// units, on the art's grid. Roots are spaced along all four edges about two fifths of the frame's height apart;
    /// each trunk wanders towards the middle (reaching it at 1), thinning, and forks now and then into branches that
    /// stop short of it.
    private static func boredGrow(in r: CGRect, px: CGFloat, trip: Int) -> [BoredSeg] {
        func n(_ i: Int) -> Double { noise(i + trip * 7919) }
        let s = r.height / 200
        let centre = CGPoint(x: r.midX, y: r.midY)
        let gap = r.height * 0.32
        var roots: [CGPoint] = []
        let across = max(2, min(8, Int(r.width / gap))), down = max(1, min(4, Int(r.height / gap)))
        for i in 0..<across {
            let x = r.minX + r.width * (CGFloat(i) + 0.5 + CGFloat(n(i * 3 + 1) - 0.5) * 0.6) / CGFloat(across)
            roots.append(CGPoint(x: x, y: r.maxY)); roots.append(CGPoint(x: x + gap * 0.3, y: r.minY))
        }
        for i in 0..<down {
            let y = r.minY + r.height * (CGFloat(i) + 0.5 + CGFloat(n(i * 3 + 50) - 0.5) * 0.5) / CGFloat(down)
            roots.append(CGPoint(x: r.minX, y: y)); roots.append(CGPoint(x: r.maxX, y: y - gap * 0.2))
        }
        // Roots far from the middle (along a wide frame) start sooner, so all of them meet it together.
        let far = roots.map { hypot($0.x - centre.x, $0.y - centre.y) }.max() ?? 1
        var segs: [BoredSeg] = []
        func snap(_ p: CGPoint) -> CGPoint {
            CGPoint(x: ((p.x - r.minX) / px).rounded() * px + r.minX, y: ((p.y - r.minY) / px).rounded() * px + r.minY)
        }
        func branch(from p: CGPoint, towards target: CGPoint, length: CGFloat, step: CGFloat, width: CGFloat, t0: Double,
                    t1: Double, depth: Int, seed: Int) {
            let steps = max(2, Int(length / step))
            var at = p
            var angle = Double(atan2(target.y - p.y, target.x - p.x))
            for j in 0..<steps {
                let toward = Double(atan2(target.y - at.y, target.x - at.x))
                var turn = toward - angle
                while turn > .pi { turn -= 2 * .pi }
                while turn < -.pi { turn += 2 * .pi }
                angle += turn * (depth == 0 ? 0.3 : 0.08) + (n(seed * 97 + j * 7) - 0.5) * 1.3
                let len = length / CGFloat(steps)
                let next = CGPoint(x: at.x + len * CGFloat(cos(angle)), y: at.y + len * CGFloat(sin(angle)))
                let ta = t0 + (t1 - t0) * Double(j) / Double(steps), tb = t0 + (t1 - t0) * Double(j + 1) / Double(steps)
                let wd = width * (1 - 0.8 * CGFloat(j) / CGFloat(steps))
                segs.append(BoredSeg(a: snap(at), b: snap(next), t0: ta, t1: tb, width: (wd / px).rounded() * px, depth: depth))
                if depth < 3 && j > 0 && j < steps - 2 && n(seed * 31 + j * 13) < (depth == 0 ? 0.3 : depth == 1 ? 0.22 : 0.12) {
                    let side = n(seed * 31 + j * 13 + 5) < 0.5 ? -1.0 : 1.0
                    let fork = angle + side * (0.6 + 0.6 * n(seed * 31 + j * 13 + 6))
                    let reachLeft = length * CGFloat(steps - j) / CGFloat(steps)
                    let blen = reachLeft * CGFloat(0.35 + 0.35 * n(seed * 31 + j * 13 + 7))
                    let aim = CGPoint(x: next.x + blen * 2 * CGFloat(cos(fork)), y: next.y + blen * 2 * CGFloat(sin(fork)))
                    branch(from: next, towards: aim, length: blen, step: step, width: wd * 0.6, t0: tb, t1: min(1, tb + (t1 - tb) * 0.8),
                           depth: depth + 1, seed: seed * 7 + j + 1)
                }
                at = next
            }
        }
        for (i, root) in roots.enumerated() {
            let dist = hypot(root.x - centre.x, root.y - centre.y)
            let start = 0.25 * Double(1 - dist / far) + 0.06 * n(i * 17 + 9)
            let aim = CGPoint(x: centre.x + (CGFloat(n(i * 17 + 2)) - 0.5) * r.height * 0.3,
                              y: centre.y + (CGFloat(n(i * 17 + 3)) - 0.5) * r.height * 0.3)
            branch(from: root, towards: aim, length: dist * 1.05, step: max(px * 3, s * 4, dist / 22), width: max(px * 3, s * 4.5), t0: start, t1: 1,
                   depth: 0, seed: i + 1)
        }
        return segs
    }

    /// `rect` with its edges on the art's grid.
    private static func boredGrid(_ rect: CGRect, px: CGFloat, in r: CGRect) -> CGRect {
        let x0 = ((rect.minX - r.minX) / px).rounded() * px + r.minX, y0 = ((rect.minY - r.minY) / px).rounded() * px + r.minY
        let x1 = ((rect.maxX - r.minX) / px).rounded() * px + r.minX, y1 = ((rect.maxY - r.minY) / px).rounded() * px + r.minY
        return CGRect(x: x0, y: y0, width: max(0, x1 - x0), height: max(0, y1 - y0))
    }

    /// Film grain, tinted crimson in the dark: scattered pixels of the art, different every frame.
    private static func boredGrain(_ c: CGContext, k: Double, strength: CGFloat, px: CGFloat, in r: CGRect) {
        guard strength > 0 else { return }
        let w = Int(r.width / px), h = Int(r.height / px)
        let n = w * h / 60, frame = Int(k * 30) * 7919
        var light: [CGRect] = [], dark: [CGRect] = []
        light.reserveCapacity(n / 2); dark.reserveCapacity(n / 2)
        for i in 0..<n {
            let x = Int(noise(i * 3 + frame) * Double(w)), y = Int(noise(i * 3 + 1 + frame) * Double(h))
            let rect = CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(y) * px, width: px, height: px)
            if i % 2 == 0 { light.append(rect) } else { dark.append(rect) }
        }
        c.setFillColor(rgb(0x8A1A2A, 0.12 * strength)); c.fill(light)
        c.setFillColor(rgb(0x000000, 0.14 * strength)); c.fill(dark)
    }
}
