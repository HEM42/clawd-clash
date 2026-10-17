import CoreGraphics
import Foundation

// Restless (`SlayerWipe.restless`): sand blows across the picture, the First Slayer's painted face looms out of it and
// fades, and the sand clears on the new place.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Streaks of sand blow in from the right
    /// and thicken into a haze in stepped bands, pale at the top and dune-brown below (0–0.3); the First Slayer's
    /// face looms out of it, growing toward us: Clawd's orange head under a mass of wild dreadlocks, chalk-white paint
    /// across the eyes under black brows, black streaks running down from them (in 0.26–0.42, gone by 0.78), the
    /// sand still blowing across her; under the haze the old place gives way to the new (0.42–0.55); then the haze and the streaks thin
    /// out and leave the new place (0.6–0.95). The sand and the face are pixel art.
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

        // Her face, looming out of the sand and fading back into it.
        let face = Self.span(k, 0.26, 0.42) * (1 - Self.ease(Self.span(k, 0.6, 0.78)))
        if face > 0 {
            let loom = 0.86 + 0.24 * Self.ease(Self.span(k, 0.24, 0.8))
            art.saveGState()
            art.setAlpha(CGFloat(0.94 * face))
            art.beginTransparencyLayer(auxiliaryInfo: nil)
            Self.slayerFirstSlayerFace(art, cx: W / 2, cy: H * 0.47, scale: H * 0.8 / 36 * loom)
            art.endTransparencyLayer()
            art.restoreGState()
        }

        // The streaks blowing across from the right, and loose grains faster still.
        let blow = Self.span(k, 0, 0.18) * (1 - Self.ease(Self.span(k, 0.6, 0.9)))
        if blow > 0 {
            let tones: [UInt32] = [0xF4E2B4, 0xD8B880, 0xA07C4A]
            let count = Int(W * H / 160), span = W + 40
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

    /// The First Slayer's face, big: Clawd's orange head under a mass of wild dreadlocks with beads in them, chalk
    /// paint across the eyes and black streaks down from them, centred on (`cx`, `cy`), `scale` art pixels to each of
    /// its 44×36 units.
    private static func slayerFirstSlayerFace(_ art: CGContext, cx: Double, cy: Double, scale s: Double) {
        let fw = 44.0, fh = 36.0
        let ox = cx - fw * s / 2, oy = cy - fh * s / 2
        let dread: UInt32 = 0x2C1E16, dreadL: UInt32 = 0x54402E, bead: UInt32 = 0xC8783A
        /// A block `w`×`h` units with its top left at (`x`, `y`), counted down from the top.
        func put(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ hex: UInt32) {
            let x0 = (ox + x * s).rounded(), x1 = (ox + (x + w) * s).rounded()
            let y0 = (oy + (fh - y - h) * s).rounded(), y1 = (oy + (fh - y) * s).rounded()
            guard x1 > x0, y1 > y0 else { return }
            art.setFillColor(sandRGB(hex)); art.fill(CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0))
        }

        /// A rope of hair: a 2-unit square at each half-unit step along it, a paler strand down one side every
        /// other step, and a bead near the end of some.
        func rope(_ pts: [(Double, Double)], beadAt: Int?) {
            for (n, p) in pts.enumerated() {
                let x0 = (ox + p.0 * s).rounded(), y0 = (oy + (fh - p.1 - 2) * s).rounded(), size = (2 * s).rounded()
                art.setFillColor(sandRGB(dread)); art.fill(CGRect(x: x0, y: y0, width: size, height: size))
                if n % 4 < 2 {
                    art.setFillColor(sandRGB(dreadL))
                    art.fill(CGRect(x: x0, y: y0, width: max(1, (s * 0.6).rounded()), height: size))
                }
            }
            if let b = beadAt, b < pts.count { put(pts[b].0, pts[b].1, 2, 2, bead) }
        }
        // The dreadlocks behind: a mass over the crown, ropes standing out all round it, more hanging at the sides.
        put(8, 6, 28, 8, dread)
        for i in 0..<17 {
            let phi = -.pi * 1.04 + .pi * 1.08 * (Double(i) + 0.5) / 17 + (noise(i + 300) - 0.5) * 0.1
            let len = 9 + (noise(i + 320) * 6).rounded()
            let pts = stride(from: 0.0, to: len, by: 0.5).map { step -> (Double, Double) in
                let rad = 7 + step, wave = sin(rad * 0.6 + Double(i) * 1.7) * 0.9
                return (21 + cos(phi) * rad * 1.2 - sin(phi) * wave, 12 + sin(phi) * rad + cos(phi) * wave)
            }
            rope(pts, beadAt: noise(i + 340) < 0.4 ? pts.count - 4 : nil)
        }
        for (n, x0) in [1.0, 4, 6.5, 35.5, 38, 41].enumerated() {
            let bottom = 26 + (noise(n + 360) * 7).rounded()
            let pts = stride(from: 9.0, to: bottom, by: 0.5).map { y in (x0 + sin(y * 0.4 + Double(n)) * 0.9, y) }
            rope(pts, beadAt: noise(n + 380) < 0.6 ? pts.count - 6 : nil)
        }

        // The head, shaded on the right and along the bottom.
        put(8, 12, 28, 22, 0xD97757); put(35, 12, 1, 22, 0xB85F40); put(8, 33, 28, 1, 0xB85F40)
        // The fringe of locks over the brow.
        put(8, 11, 28, 2, dread)
        for (n, x) in [9.0, 12, 15, 18, 21, 24, 27, 30, 33].enumerated() {
            put(x, 13, 2, 1 + (noise(n + 400) * 2.5).rounded(), n % 3 == 1 ? dreadL : dread)
        }
        // The chalk paint across the eyes, its edges rough.
        let paint: UInt32 = 0xEEE8DC, soot: UInt32 = 0x141012
        put(9, 16, 26, 6, paint); put(12, 15, 3, 1, paint); put(27, 15, 4, 1, paint)
        put(10, 22, 4, 1, paint); put(30, 22, 4, 1, paint); put(11, 23, 2, 1, paint); put(31, 23, 2, 1, paint)
        // The eyes, black in the paint, a glint in each, and the black streaks running down from them.
        put(13, 17, 4, 6, soot); put(27, 17, 4, 6, soot)
        put(14, 18, 1, 1, 0xF4E8D0); put(28, 18, 1, 1, 0xF4E8D0)
        // Black brows over the paint, slanting down to the nose: a hard stare.
        put(11, 14, 3, 1, soot); put(13, 15, 3, 1, soot); put(15, 16, 3, 1, soot)
        put(30, 14, 3, 1, soot); put(28, 15, 3, 1, soot); put(26, 16, 3, 1, soot)
        put(14, 23, 2, 6, soot); put(28, 23, 2, 6, soot); put(14, 29, 1, 2, soot); put(29, 29, 1, 2, soot)
        put(19, 22, 1, 5, soot); put(24, 22, 1, 5, soot)
    }
}

/// A colour from 0xRRGGBB.
private func sandRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
