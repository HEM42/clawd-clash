import CoreGraphics
import Foundation

// Black-and-White Stripes (`BurtonWipe.stripes`): Beetlejooce's suit slides in from both sides, twists into a spinning
// spiral and unwinds on the new place.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Crooked upright stripes slide in over
    /// the old place, the black ones from the left and the white ones from the right, each at its own pace, until they
    /// lock together like the suit's (0–0.25); the stripes twist about the middle into a hypnotic spiral that spins
    /// faster and faster (0.25–0.5); then, from the top-left corner outward, the white arms give way to the new place
    /// and the black ones thin to threads and are gone as the spiral untwists (0.5–0.95). The stripes are pixel art on
    /// the art's own grid.
    func drawStripes(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let sw = max(4, (min(W, H * 1.6) / 12).rounded())
        let twist = Self.ease(Self.span(k, 0.25, 0.5)), unwind = Self.ease(Self.span(k, 0.5, 0.95))
        ctx.draw(k < 0.5 ? old : new, in: r)
        if k < 0.25 {
            stripesSlide(c, k: k, sw: sw)
        } else {
            stripesSpiral(c, k: k, sw: sw, twist: twist, unwind: unwind)
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// The suit's stripes wobble a little as they run down, hand-drawn: how far a stripe's edge is pushed at row `y`.
    private static func stripesWobble(_ x: Double, _ y: Double, sw: Double) -> Double {
        sin(y * 0.11 + x * 0.04) * sw * 0.12
    }

    /// The stripes sliding in: the black ones in from the left, the white ones in from the right, each its own pace,
    /// a dark edge on each white one's leading side so they read over a pale place.
    private func stripesSlide(_ c: PixelCanvas, k: Double, sw: Double) {
        let W = Double(c.w), n = Int((W / sw).rounded(.up)) + 1
        let ink = burtonInk, bone = burtonBone, edge = C(0x6B5BD6)
        for i in 0..<n {
            let start = 0.13 * noise(i * 17 + 5100)
            let s = Self.ease(Self.span(k, start, start + 0.12))
            guard s > 0 else { continue }
            let dark = i % 2 == 0
            let shift = (1 - s) * (W + sw * 2) * (dark ? -1 : 1)
            let x0 = Double(i) * sw + shift
            for y in 0..<c.h {
                let wob = Self.stripesWobble(Double(i) * sw, Double(y), sw: sw)
                let a = Int((x0 + wob).rounded()), b = Int((x0 + sw + wob).rounded())
                c.rect(a, y, b - a, 1, dark ? ink : bone)
                if !dark && s < 1 { c.px(a, y, edge) }
            }
        }
    }

    /// The stripes twisted about the middle into a spinning spiral, then eaten from the top-left corner outward: the
    /// white arms first, the black ones thinning after them, until only the new place is left.
    private func stripesSpiral(_ c: PixelCanvas, k: Double, sw: Double, twist: Double, unwind: Double) {
        let W = Double(c.w), H = Double(c.h), cx = W / 2, cy = H / 2
        let R0 = min(W, H) * 0.3, diag = (W * W + H * H).squareRoot()
        let spin = twist * pow(Self.span(k, 0.25, 1), 1.6) * 16   // radians, quickening
        // How hard the stripes are wound: turning more the further out, but easing off so the outer arms stay broad.
        let coil = twist * (1 - 0.75 * unwind) * 3.6
        let ink = burtonInk, bone = burtonBone, violet = burtonViolet.alpha(0.55)
        for y in 0..<c.h {
            let dy = Double(y) + 0.5 - cy
            for x in 0..<c.w {
                let dx = Double(x) + 0.5 - cx
                let d = (dx * dx + dy * dy).squareRoot()
                // Reveal: from the top-left corner outward, white first.
                let q = unwind * 1.7 - 0.7 * (Double(x * x + y * y)).squareRoot() / diag
                let qWhite = Self.clamp(q / 0.55), qBlack = Self.clamp((q - 0.3) / 0.7)
                if qBlack >= 1 { continue }
                let a = coil * log(1 + d / R0) + spin
                let ca = cos(a), sa = sin(a)
                let ux = dx * ca - dy * sa + cx, uy = dx * sa + dy * ca + cy
                let p = (ux + Self.stripesWobble(ux, uy, sw: sw)) / sw
                let f = p - p.rounded(.down), even = Int(p.rounded(.down)) & 1 == 0
                // Within a pair of stripes: the black one first, then the white.
                let t = even ? f * 0.5 : 0.5 + f * 0.5
                if t < 0.5 {
                    if t < 0.5 * (1 - qBlack) { c.px(x, y, ink) }
                } else if t - 0.5 < 0.5 * (1 - qWhite) {
                    c.px(x, y, qWhite > 0 && t - 0.5 > 0.5 * (1 - qWhite) - 0.6 / sw ? violet : bone)
                }
            }
        }
    }
}
