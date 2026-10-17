import CoreGraphics
import Foundation

// Restless (`SlayerWipe.restless`): sand blows across the picture, the First Slayer's painted face looms out of it and
// fades, and the sand clears on the new place.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Streaks of sand blow in from the right
    /// and thicken into a haze in stepped bands, pale at the top and dune-brown below (0–0.3); the First Slayer's
    /// face looms out of it, growing toward us and filling the frame: Clawd's orange head, rounded, framed by wild
    /// beaded dreadlocks, white clay across the brow and eyes, black paint round the eyes and streaks down from them.
    /// She comes out of the sand in streaky blocks (0.24–0.42) and goes back into it (0.6–0.8), the sand still
    /// blowing across her; under the haze the old place gives way to the new (0.42–0.55); then the haze and the
    /// streaks thin out and leave the new place (0.6–0.95). The sand and the face are pixel art.
    func drawRestless(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard let canvas = Self.slayerDustCanvas(in: r) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let (art, w, h, px) = canvas
        let W = Double(w), H = Double(h)

        // The places, the old giving way to the new while the sand is thickest.
        ctx.draw(new, in: r)
        let swap = Self.ease(Self.span(k, 0.42, 0.55))
        if swap < 1 { ctx.setAlpha(CGFloat(1 - swap)); ctx.draw(old, in: r); ctx.setAlpha(1) }

        // The haze, in bands down the frame.
        let haze = 0.93 * Self.ease(Self.span(k, 0, 0.3)) * (1 - Self.ease(Self.span(k, 0.62, 0.95)))
        if haze > 0 {
            let bands: [UInt32] = [0xE8D4A4, 0xE0C890, 0xD6BA80, 0xCAA870, 0xBC9860, 0xAE8852]
            let band = (H / Double(bands.count)).rounded(.up)
            for (i, hex) in bands.enumerated() {
                art.setFillColor(sandRGB(hex, CGFloat(haze)))
                art.fill(CGRect(x: 0, y: H - Double(i + 1) * band, width: W, height: band))
            }
        }

        // Her face, looming out of the sand and fading back into it: it grows toward us, sized so that at its
        // biggest it fits inside the frame, strip or full screen.
        let face = Self.ease(Self.span(k, 0.24, 0.42)) * (1 - Self.ease(Self.span(k, 0.6, 0.8)))
        if face > 0 {
            let loom = 0.82 + 0.18 * Self.ease(Self.span(k, 0.22, 0.8))
            let fit = min(H * 0.94 / Self.slayerFaceSize.h, W * 0.92 / Self.slayerFaceSize.w)
            art.saveGState()
            art.setAlpha(CGFloat(min(1, face * 1.3) * 0.94))
            art.beginTransparencyLayer(auxiliaryInfo: nil)
            Self.slayerFirstSlayerFace(art, cx: W / 2, cy: H / 2, scale: fit * loom, reveal: face)
            art.endTransparencyLayer()
            art.restoreGState()
        }

        // The streaks blowing across from the right, and loose grains faster still.
        let blow = Self.span(k, 0, 0.18) * (1 - Self.ease(Self.span(k, 0.6, 0.9)))
        if blow > 0 {
            let tones: [UInt32] = [0xF4E2B4, 0xD8B880, 0xA07C4A]
            let count = min(900, Int(W * H / 160)), span = W + 40
            for i in 0..<count {
                let s = i * 7
                let len = (3 + noise(s + 1) * 13).rounded()
                let speed = span * (2.2 + 1.8 * noise(s + 2))
                let x = W + 20 - ((noise(s + 3) * span + k * speed).truncatingRemainder(dividingBy: span))
                let y = (noise(s) * H + sin(k * 9 + noise(s + 4) * 6) * 2).rounded()
                let grain = i % 3 == 0
                art.setFillColor(sandRGB(tones[i % 3], CGFloat(blow * (grain ? 0.9 : 0.75))))
                art.fill(CGRect(x: x.rounded(), y: y, width: grain ? 1 : len, height: 1))
            }
        }
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// The First Slayer's face, in units (its size here, in units across and down).
    static let slayerFaceSize = (w: 48.0, h: 46.0)

    /// The First Slayer's face, big, `scale` art pixels to a unit and centred on (`cx`, `cy`): Clawd's orange head,
    /// rounded, framed by a mass of wild dreadlocks with beads and bone in them; a band of white clay paint across the
    /// brow and eyes, its lower edge dripping; black paint round the eyes and black streaks running down from them.
    /// `reveal` (0…1) is how far it has come out of the sand: below 1 it is tinted with sand and broken up by it, in
    /// streaky blocks.
    private static func slayerFirstSlayerFace(_ art: CGContext, cx: Double, cy: Double, scale s: Double, reveal: Double) {
        let fw = slayerFaceSize.w, fh = slayerFaceSize.h
        let ox = cx - fw * s / 2, oy = cy - fh * s / 2
        let dread: UInt32 = 0x2C1E16, dreadL: UInt32 = 0x54402E
        /// A block `w`×`h` units with its top left at (`x`, `y`), counted down from the top.
        func put(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ hex: UInt32) {
            let x0 = (ox + x * s).rounded(), x1 = (ox + (x + w) * s).rounded()
            let y0 = (oy + (fh - y - h) * s).rounded(), y1 = (oy + (fh - y) * s).rounded()
            guard x1 > x0, y1 > y0 else { return }
            art.setFillColor(sandRGB(hex)); art.fill(CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0))
        }
        /// An ellipse at (`ex`, `ey`), `rx`×`ry` units, a row of units at a time; `edge`, if given, shades the last
        /// unit on the right of each row.
        func oval(_ ex: Double, _ ey: Double, _ rx: Double, _ ry: Double, _ hex: UInt32, edge: UInt32? = nil) {
            for y in Int((ey - ry).rounded(.down))...Int((ey + ry).rounded(.up)) {
                let t = (Double(y) + 0.5 - ey) / ry
                guard abs(t) < 1 else { continue }
                let half = (rx * (1 - t * t).squareRoot() * 2).rounded() / 2
                guard half > 0 else { continue }
                put(ex - half, Double(y), half * 2, 1, hex)
                if let e = edge { put(ex + half - 1, Double(y), 1, 1, e) }
            }
        }
        /// A rope of hair along `pts`: a 2-unit square at each step, a paler strand down one side every other step,
        /// and a bead near the end if `bead` is given.
        func rope(_ pts: [(Double, Double)], bead: UInt32?) {
            for (n, p) in pts.enumerated() {
                let x = min(fw - 2, max(0, p.0)), y = min(fh - 2, max(0, p.1))
                let x0 = (ox + x * s).rounded(), y0 = (oy + (fh - y - 2) * s).rounded(), size = (2 * s).rounded()
                art.setFillColor(sandRGB(dread)); art.fill(CGRect(x: x0, y: y0, width: size, height: size))
                if n % 4 < 2 {
                    art.setFillColor(sandRGB(dreadL))
                    art.fill(CGRect(x: x0, y: y0, width: max(1, (s * 0.6).rounded()), height: size))
                }
            }
            if let b = bead, pts.count > 5 {
                let p = pts[pts.count - 4]
                put(min(fw - 2, max(0, p.0)), min(fh - 2, max(0, p.1)), 2, 2, b)
            }
        }

        let hx = 24.0, hy = 25.0, rx = 12.5, ry = 14.0
        // The dreadlocks behind: a mass about the crown, then ropes standing out from the top of the head and
        // falling back under their own weight, and more hanging down the sides past the jaw.
        oval(hx, hy - 7, 15.5, 10, dread)
        for i in 0..<15 {
            let phi = -.pi + 0.15 + (.pi - 0.3) * (Double(i) + 0.5) / 15 + (noise(i + 300) - 0.5) * 0.15
            let side = abs(cos(phi))
            let len = (side > 0.6 ? 9 : 6) + (noise(i + 320) * 4).rounded()
            let x0 = hx + cos(phi) * rx * 0.9, y0 = hy + sin(phi) * ry * 0.9
            let pts = stride(from: 0.0, to: len, by: 0.5).map { t -> (Double, Double) in
                let wave = sin(t * 0.8 + Double(i) * 1.9) * 0.6
                return (x0 + cos(phi) * t * 1.1 - sin(phi) * wave - 1, y0 + sin(phi) * t + 0.05 * t * t - 1)
            }
            let bead: UInt32? = noise(i + 340) < 0.35 ? (i % 2 == 0 ? 0xC8783A : 0xE6DEC8) : nil
            rope(pts, bead: bead)
        }
        for n in 0..<8 {
            let left = n < 4, m = Double(n % 4)
            let x0 = left ? hx - rx - 1 + m * 1.2 : hx + rx - 1 - m * 1.2
            let y0 = hy - 8 + m * 3
            let len = 13 + (noise(n + 360) * 5).rounded()
            let pts = stride(from: 0.0, to: len, by: 0.5).map { t -> (Double, Double) in
                (x0 + (left ? -1 : 1) * (t * 0.35 + sin(t * 0.5 + Double(n)) * 0.8), y0 + t)
            }
            let bead: UInt32? = noise(n + 380) < 0.5 ? (n % 2 == 0 ? 0xE6DEC8 : 0xC8783A) : nil
            rope(pts, bead: bead)
        }

        // The head: round, shaded down the right and along the jaw.
        oval(hx, hy, rx, ry, 0xD97757, edge: 0xB85F40)
        // The white clay across the brow and the eyes, inside the head, its lower edge dripping.
        let paint: UInt32 = 0xEEE8DC, paintD: UInt32 = 0xC8C0B0, soot: UInt32 = 0x141012
        for x in Int(hx - rx + 1)..<Int(hx + rx) {
            let u = (Double(x) + 0.5 - hx) / rx
            let reach = ry * (1 - u * u).squareRoot()
            let top = max(hy - 10 + (noise(x + 420) < 0.3 ? 1 : 0), (hy - reach).rounded(.up) + 1)
            let bottom = hy - 1 + (noise(x + 440) * 2.4).rounded()
            guard bottom > top else { continue }
            put(Double(x), top, 1, bottom - top, paint)
            put(Double(x), bottom - 1, 1, 1, paintD)
        }
        // Black paint round the eyes, the eyes in it with a glint, and the streaks running down.
        for ex in [hx - 5.5, hx + 5.5] {
            oval(ex, hy - 4.5, 3.6, 3.2, soot)
            put(ex - 1, hy - 6, 2, 3, 0x000000); put(ex - 1, hy - 6, 1, 1, 0xF4E8D0)
            put(ex - 1, hy - 1.5, 2, 8, soot); put(ex - 0.5, hy + 6.5, 1, 2, soot)
        }
        put(hx - 2, hy - 1, 1, 6, soot); put(hx + 1, hy - 1, 1, 6, soot)
        // A fringe of locks falling over the top of the clay.
        for n in 0..<8 {
            let x = hx - 10 + Double(n) * 2.8 + (noise(n + 400) - 0.5)
            put(x.rounded(), hy - ry + 1, 2, 3 + (noise(n + 410) * 3).rounded(), n % 3 == 1 ? dreadL : dread)
        }

        // Out of the sand: sand-tinted while she is faint, and broken up by streaky blocks of it.
        guard reveal < 1 else { return }
        art.setBlendMode(.sourceAtop)
        art.setFillColor(sandRGB(0xD8BC88, CGFloat(0.55 * (1 - reveal))))
        art.fill(CGRect(x: ox, y: oy, width: fw * s, height: fh * s))
        art.setBlendMode(.clear)
        for y in 0..<Int(fh) {
            for x in 0..<Int(fw) where 0.6 * noise(y * 61 + x * 7 + 500) + 0.4 * noise(y * 13 + x / 5 + 900) > reveal {
                put(Double(x), Double(y), 1, 1, 0x000000)
            }
        }
        art.setBlendMode(.normal)
    }
}

/// A colour from 0xRRGGBB.
private func sandRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
