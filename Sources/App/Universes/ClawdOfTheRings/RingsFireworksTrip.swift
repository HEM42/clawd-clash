import CoreGraphics
import Foundation

// The trip between Clawd of the Rings places with Gandclawd's dragon rocket (`RingsWipe.fireworks`).

extension RingsTrip {
    /// One of Gandclawd's rockets, at Bilbo's party. The old place dims to night and the rocket shoots up from the
    /// bottom of the frame, trailing sparks (0.04–0.29); it bursts with a bang of light (0.27–0.42) into a fiery dragon
    /// of sparks, red-gold, wings spread, that grows out of the burst and swoops across the frame and out to the right
    /// (0.3–0.8). The burst blows the old place away around it and the dragon's wings sweep the rest of it away behind
    /// a white-hot edge; where it's gone, sparks and smoke are left that fall and fade like glitter, the new place
    /// showing through them, until it's clear (to 1). The places are drawn as they are; everything of the rocket's
    /// own is pixel art, into a bitmap about a sixth of `r` in each direction, scaled up without smoothing: the
    /// night, smoke and glitter set pixel by pixel, and the rocket, burst, flash and dragon drawn over them.
    func drawFireworks(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k < 1 else { ctx.draw(new, in: r); return }
        let s = r.height / 800
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the rocket's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.fwCanvas(width: w, height: h, px: px, in: r) else { return }

        // The burst, and the dragon's flight out of it: across to past the right of the frame, dipping on the way.
        let bang = 0.3, out = 0.76
        let burst = CGPoint(x: r.minX + r.width * 0.24, y: r.minY + r.height * 0.6)
        let size = min(r.width * 0.45, r.height * 0.85)        // the dragon's length, nose to tail
        let lead = size * 0.3                                // how far ahead of its middle its wings sweep
        let endX = r.maxX + r.height * 0.35 + size * 0.3
        let speed = (endX - burst.x) / CGFloat(out - bang)    // across the frame, per unit of k
        let dip = r.height * 0.22
        let p = (k - bang) / (out - bang)
        let dragon = CGPoint(x: burst.x + speed * CGFloat(k - bang), y: burst.y - dip * CGFloat(sin(.pi * p)))
        let heading = atan2(Double(-dip) * .pi * cos(.pi * p) / (out - bang), Double(speed))
        let blast = r.height * 0.42 * CGFloat(Self.fwEase(Self.fwSpan(k, 0.29, 0.4)))  // the burst's reach

        // Pixel by pixel: the night falling on the old place; where it's been swept away (by the burst, or behind the
        // dragon's wings), a white-hot edge, then smoke that thins to show the new place, and sparks that fall, cool and
        // wink out. The rows of what's left of the old place are gathered on the way.
        var keep: [CGRect] = []
        if let data = art.data {
            let bytes = data.bindMemory(to: UInt8.self, capacity: art.bytesPerRow * h)
            let stride = art.bytesPerRow
            let frame = Int(k * 60)
            let night = 0.32 * Self.fwSpan(k, 0.02, 0.22)
            let end = 1 - Self.fwSpan(k, 0.84, 1)
            func put(_ o: Int, _ hex: UInt32, _ a: Double) {
                let alpha = max(0, min(1, a))
                bytes[o] = UInt8(Double(hex >> 16 & 0xFF) * alpha)
                bytes[o + 1] = UInt8(Double(hex >> 8 & 0xFF) * alpha)
                bytes[o + 2] = UInt8(Double(hex & 0xFF) * alpha)
                bytes[o + 3] = UInt8(255 * alpha)
            }
            for j in 0..<h {
                let y = r.minY + (CGFloat(h - 1 - j) + 0.5) * px
                let front = k >= bang ? dragon.x + lead - 0.5 * abs(y - dragon.y) : -.greatestFiniteMagnitude
                var from = -1
                for i in 0..<w {
                    let x = r.minX + (CGFloat(i) + 0.5) * px
                    var d = front - x
                    if blast > 0 {
                        let dx = x - burst.x, dy = y - burst.y
                        d = max(d, blast - (dx * dx + dy * dy).squareRoot())
                    }
                    let o = j * stride + i * 4
                    guard d > 0 else {
                        if from < 0 { from = i }
                        put(o, 0x0A0820, night)
                        continue
                    }
                    if from >= 0 {
                        keep.append(CGRect(x: r.minX + CGFloat(from) * px, y: r.minY + CGFloat(h - 1 - j) * px,
                                           width: CGFloat(i - from) * px, height: px))
                        from = -1
                    }
                    let age = min(Double(d / speed), k - bang)
                    let twinkle = Self.fwHash(i, j, frame)
                    if d < px * 1.5 {
                        put(o, twinkle < 0.5 ? 0xFFFFFF : 0xFFE08A, end)
                    } else if d < px * 4 && twinkle < 0.4 {
                        put(o, 0xFFB040, end)
                    } else {
                        let fall = j - Int(age * 90)
                        let n = Self.fwHash(i, fall, 7)
                        let density = 0.07 * (1 - Self.fwSpan(age, 0.1, 0.45))
                        if n < density && Self.fwHash(i, fall, frame / 2) > 0.25 {
                            let heat = age + n * 0.4
                            let hex: UInt32 = heat < 0.05 ? 0xFFF8E0 : heat < 0.14 ? 0xFFD050 : heat < 0.28 ? 0xFF8A1E : 0xD03018
                            put(o, hex, end)
                        } else {
                            put(o, 0x2A0E16, 0.9 * (1 - Self.fwEase(Self.fwSpan(age, 0.03, 0.32))) * end)
                        }
                    }
                }
                if from >= 0 {
                    keep.append(CGRect(x: r.minX + CGFloat(from) * px, y: r.minY + CGFloat(h - 1 - j) * px,
                                       width: CGFloat(w - from) * px, height: px))
                }
            }
        }

        // The rocket and its trail, the bang's flash, the burst's sparks and the dragon.
        Self.fwRocket(art, burst: burst, k: k, in: r, s: s, px: px)
        let flash = Self.fwSpan(k, 0.27, 0.3) * (1 - Self.fwEase(Self.fwSpan(k, 0.3, 0.42)))
        if flash > 0 {
            art.saveGState()
            art.setAlpha(CGFloat(flash))
            let light: [FwStop] = [FwStop(0, 0xFFFFFF, 1), FwStop(0.3, 0xFFF0B8, 0.85), FwStop(1, 0xFFD070, 0.5)]
            Self.fwBands(art, centre: burst, radius: max(r.width, r.height) * 0.75, stops: light, count: 6, beyond: r)
            art.restoreGState()
        }
        Self.fwBurstSparks(art, burst: burst, reach: blast, k: k, px: px)
        if k >= bang && k < 0.95 {
            let grow = 0.25 + 0.75 * CGFloat(Self.fwEase(Self.fwSpan(k, bang, 0.42)))
            Self.fwDragon(art, at: dragon, heading: heading, length: size * grow, k: k, px: px)
        }

        // The places: the new one where the old has gone, what's left of the old one, and the art over them.
        if k >= bang - 0.02 { ctx.draw(new, in: r) }
        ctx.saveGState()
        if k >= bang { ctx.clip(to: keep) }
        if k < bang || !keep.isEmpty { ctx.draw(old, in: r) }
        ctx.restoreGState()
        Self.fwBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// The rocket, rising from below the frame to `burst` (0.04–0.29): a red tube with a gold band and a white cone,
    /// on its stick, a flame flickering under it; and the sparks it sheds, falling and cooling behind it, until 0.4.
    private static func fwRocket(_ ctx: CGContext, burst: CGPoint, k: Double, in r: CGRect, s: CGFloat, px: CGFloat) {
        guard k > 0.04, k < 0.4 else { return }
        let start = CGPoint(x: burst.x - r.width * 0.03, y: r.minY - 40 * s)
        func at(_ t: Double) -> CGPoint {
            let q = 1 - pow(1 - fwSpan(t, 0.04, 0.29), 2)
            return CGPoint(x: start.x + (burst.x - start.x) * CGFloat(q * q), y: start.y + (burst.y - start.y) * CGFloat(q))
        }
        func dot(_ x: CGFloat, _ y: CGFloat, _ hex: UInt32, _ a: CGFloat = 1, _ wide: CGFloat = 1, _ tall: CGFloat = 1) {
            ctx.setFillColor(fwRGB(hex, a))
            ctx.fill(CGRect(x: (x / px).rounded() * px, y: (y / px).rounded() * px, width: px * wide, height: px * tall))
        }
        // The trail: sparks let go along the way, dropping and cooling.
        let frame = Int(k * 60)
        for i in 0..<40 {
            let t = k - Double(i) * 0.006
            guard t > 0.05, t < 0.29 else { continue }
            let age = k - t
            let p = at(t)
            let x = p.x + CGFloat(fwHash(i, 3, 0) - 0.5) * 30 * s * CGFloat(age * 6)
            let y = p.y - CGFloat(age * age) * r.height * 2.5 - 6 * px
            let fade = CGFloat(1 - age / 0.24)
            guard fade > 0, fwHash(i, frame, 1) > 0.2 else { continue }
            dot(x, y, age < 0.03 ? 0xFFF4C0 : age < 0.08 ? 0xFFC040 : age < 0.15 ? 0xFF8A1E : 0xC8301A, fade)
        }
        guard k < 0.29 else { return }
        let c = at(k)
        let cx = (c.x / px).rounded() * px
        dot(cx - px, c.y - px * 14, 0xFFE070, 1, 3, 3 + CGFloat(frame % 2))   // the flame
        dot(cx, c.y - px * 15, 0xFF8A1E, 1, 1, 2)
        dot(cx, c.y - px * 20, 0x7A5030, 1, 1, 9)                              // the stick
        dot(cx - px, c.y - px * 11, 0xC0281E, 1, 3, 8)                         // the tube
        dot(cx - px, c.y - px * 8, 0xF0C040, 1, 3, 1)                          // its gold band
        dot(cx - px, c.y - px * 3, 0xE8E0D0, 1, 3, 1)                          // the cone
        dot(cx, c.y - px * 2, 0xFFFFFF, 1, 1, 1)
    }

    /// The burst's sparks: rays of gold flying out from `burst` to its `reach`, fading (0.29–0.45).
    private static func fwBurstSparks(_ ctx: CGContext, burst: CGPoint, reach: CGFloat, k: Double, px: CGFloat) {
        let life = fwSpan(k, 0.29, 0.46)
        guard life > 0, life < 1, reach > 0 else { return }
        let frame = Int(k * 60)
        for i in 0..<28 {
            let angle = 2 * Double.pi * (Double(i) + fwHash(i, 1, 0) * 0.6) / 28
            let far = reach * CGFloat(0.75 + 0.35 * fwHash(i, 2, 0))
            for n in 0..<4 {
                guard fwHash(i, n, frame) > 0.25 else { continue }
                let d = far - CGFloat(n) * px * 3
                let x = burst.x + d * CGFloat(cos(angle)), y = burst.y + d * CGFloat(sin(angle)) - CGFloat(life * life) * reach * 0.3
                let hex: UInt32 = n == 0 ? 0xFFFFFF : n == 1 ? 0xFFE08A : n == 2 ? 0xFFB040 : 0xFF6A1E
                ctx.setFillColor(fwRGB(hex, CGFloat(1 - life)))
                ctx.fill(CGRect(x: (x / px).rounded() * px, y: (y / px).rounded() * px, width: px, height: px))
            }
        }
    }

    /// The dragon of sparks, `length` nose to tail, its middle at `at`, flying towards `heading` (radians), seen from
    /// below with its wings spread either side: a sinuous body of fire, thick at the shoulders and thin to the spade of
    /// its tail, a horned head with white eyes spitting a little fire, four clawed legs, and two great bat's wings,
    /// flapping, a glowing red-gold membrane between gold bones, its edge scalloped in orange. Sparks twinkle over all
    /// of it from frame to frame.
    private static func fwDragon(_ ctx: CGContext, at centre: CGPoint, heading: Double, length L: CGFloat, k: Double, px: CGFloat) {
        let frame = Int(k * 60)
        let cosH = CGFloat(cos(heading)), sinH = CGFloat(sin(heading))
        func world(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
            CGPoint(x: centre.x + (u * cosH - v * sinH) * L, y: centre.y + (u * sinH + v * cosH) * L)
        }
        func pt(_ u: CGFloat, _ v: CGFloat) -> CGPoint { CGPoint(x: u, y: v) }
        func fill(_ shape: [CGPoint], _ hex: UInt32, _ alpha: CGFloat) {
            guard let first = shape.first else { return }
            ctx.move(to: world(first.x, first.y))
            for p in shape.dropFirst() { ctx.addLine(to: world(p.x, p.y)) }
            ctx.closePath()
            ctx.setFillColor(fwRGB(hex, alpha)); ctx.fillPath()
        }
        var sparks: [UInt32: [CGRect]] = [:]
        let bold: Set<UInt32> = [0xFFF4C8, 0xFFE08A, 0xFFC040]   // the spine and bones: two pixels a spark
        var seed = 0
        func spark(_ u: CGFloat, _ v: CGFloat, _ hex: UInt32, _ chance: Double = 0.9) {
            seed += 1
            guard fwHash(seed, frame, 3) < chance else { return }
            let p = world(u, v), size = bold.contains(hex) ? px * 2 : px
            sparks[hex, default: []].append(CGRect(x: (p.x / px).rounded() * px, y: (p.y / px).rounded() * px, width: size, height: size))
        }
        func line(_ a: CGPoint, _ b: CGPoint, _ hex: UInt32, _ chance: Double = 0.9) {
            let n = max(1, Int(((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)).squareRoot() * L / px))
            for t in 0...n {
                let f = CGFloat(t) / CGFloat(n)
                spark(a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f, hex, chance)
            }
        }

        // The wings, one either side, their span foreshortened as they beat.
        let flap = CGFloat(0.72 + 0.28 * sin(k * 28))
        for side in [CGFloat(1), CGFloat(-1)] {
            func wing(_ u: CGFloat, _ v: CGFloat) -> CGPoint { pt(u, side * v * flap) }
            let root = pt(0.16, side * 0.04), back = pt(-0.12, side * 0.035)
            let wrist = wing(0.1, 0.24)
            let tips = [wing(0.22, 0.52), wing(-0.02, 0.54), wing(-0.17, 0.45), wing(-0.27, 0.27)]
            // The trailing edge: a scallop between each pair of fingers, sagging towards the wrist.
            var edge: [CGPoint] = []
            for (a, b) in zip(tips, Array(tips.dropFirst()) + [back]) {
                edge += [a, pt((a.x + b.x) / 2 * 0.88 + wrist.x * 0.12, (a.y + b.y) / 2 * 0.88 + wrist.y * 0.12)]
            }
            let membrane = [root, wrist] + edge + [back]
            fill(membrane, 0xB82818, 0.55)
            fill(membrane.map { pt(wrist.x + ($0.x - wrist.x) * 0.6, wrist.y + ($0.y - wrist.y) * 0.6) }, 0xFF6A1A, 0.45)
            for (a, b) in zip(edge, Array(edge.dropFirst()) + [back]) { line(a, b, 0xFF8A1E, 0.85) }
            line(root, wrist, 0xFFE08A, 1); line(wrist, tips[0], 0xFFE08A, 1)
            for tip in tips.dropFirst() { line(wrist, tip, 0xFFC040, 0.95) }
            for i in 0..<30 {                        // glitter on the membrane
                let a = membrane[Int(fwHash(i, 1, 13) * Double(membrane.count))], f = CGFloat(fwHash(i, frame / 3, 14))
                spark(wrist.x + (a.x - wrist.x) * f, wrist.y + (a.y - wrist.y) * f, 0xFFD060, 0.8)
            }
            // The legs, claws spread.
            for hip in [CGFloat(0.22), CGFloat(-0.13)] {
                let knee = pt(hip + 0.03, side * 0.1), foot = pt(hip + 0.07, side * 0.115)
                line(pt(hip, side * 0.04), knee, 0xFFC040); line(knee, foot, 0xFFC040)
                spark(foot.x + 0.012, foot.y + side * 0.01, 0xFFF4C8); spark(foot.x + 0.015, foot.y - side * 0.004, 0xFFF4C8)
            }
        }

        // The body: wide at the shoulders, a neck to the head, a tail swaying away to nothing, filled with fire and
        // run through with a white-hot spine.
        func sway(_ u: CGFloat) -> CGFloat { 0.04 * max(0, 0.3 - u) * CGFloat(sin(Double(u) * 11 + k * 26)) }
        func girth(_ u: CGFloat) -> CGFloat {
            if u > 0.5 { return 0.05 * max(0, (0.64 - u) / 0.14) + 0.012 }   // the head, to its snout
            if u > 0.38 { return 0.03 + 0.03 * (u - 0.38) / 0.12 }           // the neck, widening into the head
            if u > 0.1 { return 0.03 + 0.03 * (0.38 - u) / 0.28 }           // the shoulders
            return max(0.006, 0.06 * (u + 0.58) / 0.68)                    // the belly and tail
        }
        let steps = 40
        let us = (0...steps).map { 0.64 - 1.22 * CGFloat($0) / CGFloat(steps) }
        fill(us.map { pt($0, sway($0) + girth($0)) } + us.reversed().map { pt($0, sway($0) - girth($0)) }, 0xFF8A1E, 0.85)
        fill(us.map { pt($0, sway($0) + girth($0) * 0.45) } + us.reversed().map { pt($0, sway($0) - girth($0) * 0.45) }, 0xFFC860, 0.7)
        for (a, b) in zip(us, us.dropFirst()) {
            line(pt(a, sway(a)), pt(b, sway(b)), 0xFFF4C8, 0.95)
            line(pt(a, sway(a) + girth(a)), pt(b, sway(b) + girth(b)), 0xFFC040, 0.5)
            line(pt(a, sway(a) - girth(a)), pt(b, sway(b) - girth(b)), 0xFFC040, 0.5)
        }
        // The spade at the tail's end.
        let end = pt(-0.58, sway(-0.58))
        fill([end, pt(end.x - 0.04, end.y + 0.035), pt(end.x - 0.09, end.y), pt(end.x - 0.04, end.y - 0.035)], 0xFF8A1E, 0.9)
        line(end, pt(end.x - 0.09, end.y), 0xFFE08A)

        // The head: horns swept back, white eyes, and a lick of fire out of its jaws.
        for side in [CGFloat(1), CGFloat(-1)] {
            line(pt(0.5, side * 0.045), pt(0.4, side * 0.11), 0xFFE08A, 1)
            line(pt(0.46, side * 0.05), pt(0.38, side * 0.09), 0xFFC040, 1)
            spark(0.55, side * 0.028, 0xFFFFFF, 1)
        }
        for i in 0..<22 {
            let f = CGFloat(fwHash(i, frame / 2, 9)), spread = CGFloat(fwHash(i, frame / 2, 10) - 0.5)
            spark(0.65 + f * 0.18, spread * (0.02 + f * 0.14), f < 0.35 ? 0xFFF4C0 : f < 0.7 ? 0xFF8A1E : 0xD03018, 0.9)
        }

        // A glow round the brightest sparks, then the sparks, colour by colour.
        ctx.setFillColor(fwRGB(0xFF6A1A, 0.3))
        ctx.fill(bold.flatMap { (sparks[$0] ?? []).map { $0.insetBy(dx: -px, dy: -px) } })
        for (hex, rects) in sparks.sorted(by: { $0.key < $1.key }) {
            ctx.setFillColor(fwRGB(hex)); ctx.fill(rects)
        }
    }

    // MARK: The rocket's pixel art (copies of the Eye's helpers in RingsTrips.swift)

    private static func fwEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func fwSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

    /// Deterministic noise in 0..<1 for a pixel or spark `x`, `y` and a `z` (a frame, or which use it's for): cheap
    /// enough to call for every pixel of the art.
    private static func fwHash(_ x: Int, _ y: Int, _ z: Int) -> Double {
        var n = UInt32(truncatingIfNeeded: x &* 374_761_393 &+ y &* 668_265_263 &+ z &* 1_274_126_177)
        n = (n ^ (n >> 13)) &* 1_274_126_177
        n ^= n >> 16
        return Double(n) / 4_294_967_296
    }

    /// A colour from 0xRRGGBB.
    private static func fwRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
    }

    /// One stop of a stepped gradient: at `at` (0…1 of the radius), colour `hex` at `alpha`.
    private struct FwStop {
        let at: CGFloat, hex: UInt32, alpha: CGFloat
        init(_ at: CGFloat, _ hex: UInt32, _ alpha: CGFloat) { self.at = at; self.hex = hex; self.alpha = alpha }
    }

    /// The colour `u` (0…1) of the way along `stops`.
    private static func fwColour(at u: CGFloat, _ stops: [FwStop]) -> CGColor {
        guard let last = stops.last else { return fwRGB(0x000000, 0) }
        var i = 0
        while i + 1 < stops.count && stops[i + 1].at < u { i += 1 }
        guard i + 1 < stops.count, u > stops[i].at else {
            return u <= stops[0].at ? fwRGB(stops[0].hex, stops[0].alpha) : fwRGB(last.hex, last.alpha)
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
    private static func fwBands(_ ctx: CGContext, centre: CGPoint, radius: CGFloat, stops: [FwStop], count n: Int, beyond: CGRect?) {
        func circle(_ rr: CGFloat) -> CGRect { CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2) }
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.beginTransparencyLayer(auxiliaryInfo: nil)
        ctx.setBlendMode(.copy)
        if let out = beyond { ctx.setFillColor(fwColour(at: 1, stops)); ctx.fill(out) }
        for i in stride(from: n - 1, through: 0, by: -1) {
            ctx.setFillColor(fwColour(at: CGFloat(i) / CGFloat(n), stops))
            ctx.fillEllipse(in: circle(radius * CGFloat(i + 1) / CGFloat(n)))
        }
        ctx.endTransparencyLayer()
    }

    /// A clear bitmap `width`×`height`, set up so that drawing into it in `r`'s units lands on its grid, unsmoothed.
    private static func fwCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: 1 / px, y: 1 / px)
        c.translateBy(x: -r.minX, y: -r.minY)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    private static func fwBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }
}
