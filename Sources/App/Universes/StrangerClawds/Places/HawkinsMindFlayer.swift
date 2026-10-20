import Foundation

// The Mind Flayer, as scenery: not a character but the thing that looms over the Upside Down, a towering spider of
// black smoke standing in the storm over the town, in the window's strip and on the screen saver alike. It's drawn
// in the place's moving layer, so its legs can shift slowly and the storm's red lightning can light it from inside,
// and only where the sky shows: behind the trees, the houses and the pole (`hawkinsUpsideDownOpen`), and never on
// the floor. Its body stands right of the middle, clear of the top-left corner where the window puts the place's
// name. A spider reads either way up, so it holds up when the scene turns over too.

/// Where the sky shows through in front of it, by canvas size: true where nothing of the street is drawn.
private var hawkinsOpenSky: [String: [Bool]] = [:]

extension Scenes {
    /// Which pixels of a `w`×`h` Upside Down with its floor at `g` are open sky (the street drawn on its own and
    /// nothing there), worked out once per size.
    static func hawkinsUpsideDownOpen(_ w: Int, _ h: Int, _ g: Int) -> [Bool] {
        let key = "\(w)x\(h)/\(g)"
        if let hit = hawkinsOpenSky[key] { return hit }
        let m = PixelCanvas(w, h)
        hawkinsUpsideDownStreet(m, g)
        var open = [Bool](repeating: false, count: w * h)
        for i in 0..<(w * h) { open[i] = m.buf[i * 4 + 3] < 90 && i / w < g }
        if hawkinsOpenSky.count > 8 { hawkinsOpenSky.removeAll() }
        hawkinsOpenSky[key] = open
        return open
    }

    /// The Mind Flayer at `t`: a hunched body of smoke high in the storm with a ridge of spines, two arms a side
    /// reaching up and out into the cloud and curling, and three long legs a side arching out at the knee and down to
    /// the horizon behind the town. The legs shift slowly, the arms curl and uncurl, the body sways; dull red embers
    /// glow inside it, and when the storm's lightning strikes it lights up red from within.
    static func hawkinsMindFlayer(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = hawkinsUpsideDownFrame(c, g)
        // Its size: on the screen saver it fills the storm; in the strip as much of the sky as there is.
        let big = tall ? Double(s) : 0.6
        let W = Double(c.w)
        let X = W * (tall ? 0.56 : 0.62) + sin(t * 0.21) * 3 * big
        let Y = tall ? Double(max(f.cloud * 42 / 100, 44 * s)) : 23.0
        let Y0 = Y + sin(t * 0.5) * 2 * big
        let foot = Double(g) - (tall ? 6 : 2) * Double(s)
        let H = foot - Y0
        // The lightning (`hawkinsUpsideDownLife`'s, every 6.3 s for a fifth of a second), and a slower ember pulse.
        let phase = t.truncatingRemainder(dividingBy: 6.3)
        let flash = phase < 0.22 ? 1 - phase / 0.22 : 0
        let ember = 0.5 + 0.5 * sin(t * 1.7)

        let fx = PixelCanvas(c.w, c.h)
        let body = C(0x08070A), smoke = C(0x0C0A10, 0.4), rim = C(0x5A1A24), hot = C(0xE0303C)
        let px = max(1.0, Double(s))
        func blob(_ x: Double, _ y: Double, _ th: Double) {
            let r = Int(max(px, th)), x0 = Int(x - th / 2), y0 = Int(y - th / 2)
            fx.rect(x0 - Int(px), y0 - Int(px), r + 2 * Int(px), r + 2 * Int(px), smoke)
            fx.rect(x0, y0, r, r, body)
            fx.rect(x0, y0 + r, r, Int(px), rim)                       // lit from below by the storm
        }
        func limb(_ pts: [(Double, Double)], _ th0: Double) {
            var prev = pts[0]
            let total = Double(pts.count - 1)
            for (i, q) in pts.dropFirst().enumerated() {
                let n = max(1, Int(max(abs(q.0 - prev.0), abs(q.1 - prev.1)) / px))
                for st in 0...n {
                    let u = Double(st) / Double(n)
                    blob(prev.0 + (q.0 - prev.0) * u, prev.1 + (q.1 - prev.1) * u, max(px, th0 * (1 - (Double(i) + u) / total * 0.8)))
                }
                prev = q
            }
        }
        func curve(_ a: (Double, Double), _ b: (Double, Double), _ e: (Double, Double)) -> [(Double, Double)] {
            (0...14).map { i in
                let u = Double(i) / 14, v = 1 - u
                return (v * v * a.0 + 2 * v * u * b.0 + u * u * e.0, v * v * a.1 + 2 * v * u * b.1 + u * u * e.1)
            }
        }
        for side in [-1.0, 1.0] {
            // Three legs a side, out and up to the knee, then down to the horizon; each shifting on its own slow beat.
            for j in 0..<3 {
                let beat = t * (0.23 + Double(j) * 0.05) + Double(j) * 1.9 + (side > 0 ? 0.7 : 0)
                let out = (0.15 + Double(j) * 0.09 + 0.012 * sin(beat)) * W * side
                let lift = (14 + Double(j) * 7) * big + 4 * big * sin(beat * 1.3)
                let knee = (X + out * 0.72, Y0 - lift)
                let toe = (X + out * 1.18 + 0.02 * W * side * sin(beat * 0.7), foot + Double(j) * 2 * big)
                limb(curve((X, Y0), (X + out * 0.3, Y0 - lift * 1.5), knee) +
                     curve(knee, (X + out * 1.08, Y0 + H * 0.15), toe).dropFirst(), (7 - Double(j)) * big)
            }
            // Two arms a side, reaching up and out into the cloud, curling and uncurling at the ends.
            for j in 0..<2 {
                let curl = sin(t * 0.4 + Double(j) * 2 + (side > 0 ? 1 : 0))
                let reach = (0.11 + Double(j) * 0.09) * W * side
                limb(curve((X, Y0 - 8 * big), (X + reach * 0.4, Y0 - (32 + Double(j) * 10) * big),
                           (X + reach, Y0 - (16 + Double(j) * 12 + curl * 5) * big)), 5 * big)
            }
        }
        // The body: hunched, taller than wide, a ridge of spines along its top.
        let bx = Int(X), by = Int(Y0)
        fx.ellipse(bx, by - Int(6 * big), Int(17 * big), Int(26 * big), smoke)
        fx.ellipse(bx, by - Int(6 * big), Int(15 * big), Int(24 * big), body)
        fx.ellipse(bx + Int(2 * big), by + Int(10 * big), Int(18 * big), Int(10 * big), body)
        for k in 0..<7 {
            fx.rect(bx + Int((-12 + Double(k) * 4) * big), by + Int((-34 + Double(abs(k - 3)) * 3) * big),
                    Int(max(px, 2 * big)), Int(8 * big), body)
        }
        fx.ellipse(bx + Int(2 * big), by + Int(19 * big), Int(14 * big), Int(max(1, big)), rim)
        // Inside: embers that glow and fade, and the lightning lighting it up red from within, in forking veins.
        for k in 0..<9 {
            let a = 0.25 + 0.35 * ember * noise(k * 7 + Int(t * 3))
            fx.rect(bx + Int((noise(k * 13 + 1) - 0.5) * 22 * big), by + Int((noise(k * 13 + 2) - 0.6) * 36 * big),
                    Int(px), Int(px), hot.alpha(a + 0.6 * flash))
        }
        if flash > 0 {
            fx.ellipse(bx, by - Int(4 * big), Int(12 * big), Int(20 * big), hot.alpha(0.22 * flash))
            var vx = Double(bx), vy = Double(by) - 26 * big
            while vy < Double(by) + 14 * big {
                let nx = vx + (noise(Int(vy) * 7 + Int(t / 6.3)) - 0.5) * 6 * big
                fx.rect(Int(min(vx, nx)), Int(vy), Int(abs(nx - vx) + px), Int(px), C(0xFF6A60, 0.85 * flash))
                vx = nx; vy += 2 * big
            }
        }

        // Onto the place, only where the sky shows.
        let open = hawkinsUpsideDownOpen(c.w, c.h, g)
        let buf = fx.buf
        for y in 0..<min(g, c.h) {
            for x in 0..<c.w where open[y * c.w + x] {
                let i = (y * c.w + x) * 4, a = buf[i + 3]
                guard a > 0 else { continue }
                let m = 255 / Double(a)
                c.px(x, y, Px(r: UInt8(min(255, Double(buf[i]) * m)), g: UInt8(min(255, Double(buf[i + 1]) * m)),
                              b: UInt8(min(255, Double(buf[i + 2]) * m)), a: a))
            }
        }
    }
}
