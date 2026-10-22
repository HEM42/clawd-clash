import CoreGraphics
import Foundation

// The Storm (`HawkinsWipe.storm`): the Upside Down's red storm. A cloud the colour of a bruise rolls in over the old
// place, the Mind Flayer's spider shape looms in it, lightning cracks through, and the clouds part onto the new place.

extension HawkinsTrip {
    /// A frame `k` (0…1) of the Storm, over the whole of `r`. The cloud rolls in from the top and the sides, churning,
    /// the old place going dark and red under it (0–0.35); the Mind Flayer looms out of it, a black shape of smoke
    /// with legs reaching down through the cloud, and two strokes of lightning light it red from inside (0.3–0.68); the
    /// clouds part down the middle, ragged at the edges, taking it with them, onto the new place (0.66–1). All of it
    /// pixel art: the cloud in four stepped tones, worked out pixel by pixel from a drifting value noise.
    func drawStorm(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let roll = Self.ease(Self.span(k, 0, 0.35))
        let loom = Self.ease(Self.span(k, 0.3, 0.5)) * (1 - Self.ease(Self.span(k, 0.7, 0.9)))
        let part = Self.ease(Self.span(k, 0.66, 1))
        // Two strikes of lightning, each a fifth of a second of the trip or so.
        let strikes: [(at: Double, x: Double)] = [(0.44, 0.3), (0.58, 0.72)]
        var flash = 0.0, bolt: (at: Double, x: Double)?
        for s in strikes where k >= s.at && k < s.at + 0.07 {
            flash = 1 - (k - s.at) / 0.07; bolt = s
        }

        // Underneath: the old place darkening red as the cloud comes over, the new place once it's hidden.
        ctx.drawShot(k < 0.5 ? old : new, in: r)
        if k < 0.5 { Self.wash(ctx, 0x1A0408, 0.65 * roll, in: r) }

        // The Mind Flayer, on a canvas of its own, so the clouds can carry it off when they part.
        let flayer = PixelCanvas(w, h)
        if loom > 0 { hawkinsStormFlayer(flayer, loom: loom, flash: flash, k: k) }

        // The cloud: drifting value noise, thicker at the top, in four tones from near-black to a lit red, coming in
        // as `roll` grows and split down the middle as it parts.
        let cx = Double(w) / 2, gap = part * Double(w) * 0.62
        let tones = [C(0x0C0407), C(0x1C080C), C(0x341018), C(0x5A1A26)]
        let lit = [C(0x2A0C14), C(0x5A1A24), C(0x8A2A36), C(0xC84452)]
        let unit = Double(h) / 4.5
        for y in 0..<h {
            let jag = (noise(y / 3 * 17 + 5) - 0.5) * 8 + sin(Double(y) * 0.11) * 5
            let fy = Double(y) / Double(h)
            for x in 0..<w {
                let fx = Double(x)
                var sx = fx
                if gap > 0 {
                    if fx < cx - gap / 2 + jag { sx = fx + gap / 2 }
                    else if fx > cx + gap / 2 + jag { sx = fx - gap / 2 }
                    else { continue }
                }
                // How dense the cloud is here: two octaves, drifting, and more of it towards the top.
                let v = hawkinsValueNoise(sx / unit + k * 1.3, fy * 4.5, 11) * 0.65
                    + hawkinsValueNoise(sx / unit * 2.6 - k * 2, fy * 11.7, 29) * 0.35
                let edge = min(fx, Double(w) - fx) / Double(w)
                let come = roll * 1.5 - fy * 0.55 - edge * 0.5 + 0.2   // in from the top and the sides first
                let d = v + come - 0.9
                if d > 0 {
                    // Its tone from how dense it is here, so the billows show; darkest along its ragged edge.
                    // Lit from behind where the Mind Flayer stands, so its shape shows black against it.
                    let bx = (fx - cx) / Double(h), by = fy - 0.36
                    let back = loom * max(0, 0.32 - (bx * bx * 0.5 + by * by) * 0.9)
                    let band = d < 0.05 ? 0 : max(0, min(3, Int((v + back - 0.36) * 7)))
                    c.px(x, y, (flash > 0.4 ? lit : tones)[band].alpha(d < 0.04 ? 0.6 : 1))
                }
                // The Mind Flayer over the cloud, carried with it.
                let si = Int(sx.rounded())
                if si >= 0 && si < w {
                    let i = (y * w + si) * 4
                    if flayer.buf[i + 3] > 0 { c.px(x, y, unpremultiplied(flayer, i)) }
                }
            }
        }

        // The lightning: a forking bolt from the top, the whole sky lit for a moment.
        if let b = bolt {
            var x = Double(w) * b.x, y = 0.0
            let end = Double(h) * 0.75
            var n = 0
            while y < end {
                let nx = x + (noise(Int(b.at * 1000) + n * 7) - 0.5) * 9, ny = y + 3 + noise(n * 13) * 4
                hawkinsLine(c, x, y, nx, ny, C(0xFFE8EE, flash), 0.8)
                c.glowLine(x, y, nx, ny, core: C(0xFFE8EE, 0), glow: C(0xFF4A5A), coreR: 0.8, glowR: 3, strength: flash * 0.6)
                if n % 4 == 2 {
                    let fx2 = nx + (noise(n * 31) > 0.5 ? 1 : -1) * (6 + noise(n * 5) * 8)
                    hawkinsLine(c, nx, ny, fx2, ny + 7, C(0xFFB0C0, flash * 0.8), 0.5)
                }
                x = nx; y = ny; n += 1
            }
            c.rect(0, 0, w, h, C(0xFF6A7A, 0.07 * flash))
        }
        art.show(ctx)
    }

    /// The Mind Flayer in the storm, `loom` (0…1) of the way out of it: a hunched body of black smoke in the upper
    /// middle with a ridge of spines, two arms a side reaching up and out, three long legs a side arching out and down
    /// through the cloud, lit red along their undersides; lit red from within when the lightning strikes.
    private func hawkinsStormFlayer(_ c: PixelCanvas, loom: Double, flash: Double, k: Double) {
        let w = Double(c.w), h = Double(c.h)
        let big = h / 112
        let X = w / 2 + sin(k * 5) * 2, Y = h * 0.34 + (1 - loom) * h * 0.08
        let smoke = C(0x1E0A10, (loom * 4).rounded() / 4)
        let body = C(0x08060A, (loom * 4).rounded() / 4), rim = C(flash > 0.4 ? 0xFF4A5A : 0x6A1A26, (loom * 4).rounded() / 4)
        // Every limb as short straight pieces, gathered first so the smoke round all of them goes down before any of
        // the black on top (a piece's smoke would otherwise cover the one before it).
        var pieces: [(x0: Double, y0: Double, x1: Double, y1: Double, t: Double)] = []
        func curve(_ a: (Double, Double), _ b: (Double, Double), _ e: (Double, Double), _ th: Double) {
            var prev = a
            for i in 1...16 {
                let u = Double(i) / 16, v = 1 - u
                let q = (v * v * a.0 + 2 * v * u * b.0 + u * u * e.0, v * v * a.1 + 2 * v * u * b.1 + u * u * e.1)
                pieces.append((prev.0, prev.1, q.0, q.1, max(0.6, th * (1 - u * 0.7))))
                prev = q
            }
        }
        for side in [-1.0, 1.0] {
            for j in 0..<3 {
                let out = (0.16 + Double(j) * 0.1) * w * side * min(1, h * 2.6 / w)
                let knee = (X + out * 0.75, Y - (10 + Double(j) * 5) * big)
                curve((X, Y), (X + out * 0.3, Y - (16 + Double(j) * 6) * big), knee, (4.4 - Double(j) * 0.7) * big)
                curve(knee, (X + out * 1.1, Y + h * 0.1), (X + out * 1.25, h + 2), (3.4 - Double(j) * 0.5) * big)
            }
            for j in 0..<2 {
                let reach = (0.12 + Double(j) * 0.08) * w * side * min(1, h * 2.6 / w)
                curve((X, Y - 6 * big), (X + reach * 0.4, Y - (26 + Double(j) * 8) * big),
                      (X + reach, Y - (14 + Double(j) * 9 + sin(k * 7 + Double(j)) * 3) * big), 3 * big)
            }
        }
        for p in pieces { hawkinsLine(c, p.x0, p.y0, p.x1, p.y1, smoke, p.t + 2 * big) }
        if flash > 0.4 { for p in pieces { hawkinsLine(c, p.x0, p.y0 + p.t * 0.7, p.x1, p.y1 + p.t * 0.7, rim, p.t) } }
        for p in pieces { hawkinsLine(c, p.x0, p.y0, p.x1, p.y1, body, p.t) }
        let bx = Int(X), by = Int(Y)
        // Hunched: broad at the shoulders, narrowing below, smoke curling off its outline.
        c.ellipse(bx, by, Int(15 * big), Int(19 * big), smoke)
        c.ellipse(bx, by + Int(2 * big), Int(12 * big), Int(17 * big), rim)
        c.ellipse(bx, by, Int(12 * big), Int(17 * big), body)
        c.ellipse(bx, by - Int(7 * big), Int(15 * big), Int(9 * big), body)
        for s in 0..<10 {
            let a = Double(s) / 10 * 2 * .pi + k * 3
            let px = Double(bx) + cos(a) * 14 * big, py = Double(by) + sin(a) * 18 * big - abs(k * 9).truncatingRemainder(dividingBy: 4) * big
            c.rect(Int(px), Int(py), Int(max(1, 2 * big)), Int(max(1, 2 * big)), smoke)
        }
        for s in 0..<7 {
            let sx = bx + Int((Double(s) - 3) * 3.4 * big), top = by - Int((22 - Double(abs(s - 3)) * 2.5) * big)
            c.rect(sx, top, max(1, Int(2 * big)), Int(7 * big), body)
        }
        if flash > 0.3 {
            c.ellipse(bx, by, Int(8 * big), Int(12 * big), C(0xE0303C, 0.3 * flash))
            var vx = Double(bx), vy = Double(by) - 14 * big
            while vy < Double(by) + 12 * big {
                let nx = vx + (noise(Int(vy) * 7) - 0.5) * 5 * big
                hawkinsLine(c, vx, vy, nx, vy + 2 * big, C(0xFF7A70, 0.9 * flash), 0.5)
                vx = nx; vy += 2 * big
            }
        }
    }
}

/// Smooth value noise in 0…1: random values on a unit grid, eased between (for clouds and smoke).
func hawkinsValueNoise(_ x: Double, _ y: Double, _ seed: Int) -> Double {
    let x0 = floor(x), y0 = floor(y)
    let fx = x - x0, fy = y - y0
    let ux = fx * fx * (3 - 2 * fx), uy = fy * fy * (3 - 2 * fy)
    func at(_ i: Double, _ j: Double) -> Double { noise((Int(i) &* 7919 &+ Int(j) &* 104_729 &+ seed &* 31) & 0xFFFFF) }
    let a = at(x0, y0), b = at(x0 + 1, y0), c = at(x0, y0 + 1), d = at(x0 + 1, y0 + 1)
    return (a + (b - a) * ux) * (1 - uy) + (c + (d - c) * ux) * uy
}
