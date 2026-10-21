import CoreGraphics
import Foundation

// Ice Dance (`BurtonWipe.iceDance`): ice shavings fly up as if from Edward's blades and come down as snow, thicker and
// thicker until the screen is white; it thins on the new place, Kim twirling in it in silhouette.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Along the bottom of the old place
    /// Edward's blades flash, snip-snip, and a fountain of ice shavings sprays up from them, then another and
    /// another, the chips glinting as they rise and turning to snowflakes as they drift down (0.02–0.4); the snow
    /// falls thicker and thicker and the picture whitens behind it until the screen is white (0.12–0.5); then it
    /// thins, and in the thinning snow a small dark silhouette of Kim twirls on one toe with her arms up, her skirt
    /// and hair flying out as she turns, fading as the snow clears on the new place (0.5–0.95). All of it pixel art
    /// on the art's own grid.
    func drawIceDance(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let white = Self.ease(Self.span(k, 0.14, 0.5)) * (1 - Self.ease(Self.span(k, 0.52, 0.9)))
        let fall = Self.span(k, 0.06, 0.42) * (1 - Self.span(k, 0.6, 0.95))
        let ice = C(0xC8E4FF), iceD = C(0x9EC4E8), glint = C(0xFFFFFF), flake = C(0xDCEAF8)

        // The picture whitening behind the snow.
        ctx.saveGState(); ctx.clip(to: r)
        ctx.draw(k < 0.5 ? old : new, in: r)
        if white > 0.003 { ctx.setFillColor(rgb(0xF2F5FA, CGFloat(min(1, white * 1.02)))); ctx.fill(r) }
        ctx.restoreGState()

        // The snow: steady flakes coming down everywhere, thicker and thicker, then thinning.
        if fall > 0.01 {
            let n = Int(W * H / 26 * fall)
            for i in 0..<n {
                let speed = 0.5 + noise(i * 4 + 2) * 0.7
                let y = frac(noise(i * 4 + 1) + k * 2.2 * speed * 0.55) * (H + 4) - 2
                let x = noise(i * 4) * W + sin(k * 8 * speed + Double(i)) * 2
                let big = noise(i * 4 + 3) < 0.15
                let tone = white > 0.7 ? (big ? iceD : C(0xB8D2EC)) : (big ? glint : flake)
                c.rect(Int(x), Int(y), big ? 2 : 1, big ? 2 : 1, tone)
            }
        }

        // The shavings: fountains sprayed up from where the blades flash, rising fast, drifting down as snow.
        let bursts: [(at: Double, x: Double)] = [(0.02, 0.5), (0.09, 0.24), (0.15, 0.76), (0.21, 0.38), (0.27, 0.64)]
        for (b, burst) in bursts.enumerated() {
            let t = (k - burst.at) * 2.2                     // seconds since this one
            guard t > 0, t < 2.4, k < 0.62 else { continue }
            let ex = W * burst.x, ey = H * 0.97
            if t < 0.4 { iceDanceBlades(c, x: ex, y: ey, open: frac(t / 0.2), size: max(7, H * 0.13)) }
            let chips = max(40, Int(H * 0.9)), chunk = H > 120 ? 2 : 1
            for i in 0..<chips {
                let s = b * 1000 + i * 6
                let vx = (noise(s) - 0.5) * H * 1.2, vy = H * (1.6 + 1.1 * noise(s + 1)), g = H * 2.2
                let tApex = vy / (2 * g)
                var x: Double, y: Double
                let fade = 1 - Self.span(k, 0.5, 0.62)
                if t < tApex {
                    x = ex + vx * t; y = ey - vy * t + g * t * t
                    let tumble = (Int(t * 30) + i) % 3
                    let tone = i % 4 == 0 ? glint : (i % 3 == 0 ? iceD : ice)
                    let w = chunk * (tumble == 0 ? 2 : 1), h = chunk * (tumble == 1 ? 2 : 1)
                    c.rect(Int(x), Int(y), w, h, tone.alpha(fade))
                } else {
                    let after = t - tApex
                    x = ex + vx * tApex + sin(after * 4 + Double(i)) * H * 0.02
                    y = ey - vy * vy / (4 * g) + after * H * (0.18 + 0.12 * noise(s + 2))
                    c.rect(Int(x), Int(y), chunk, chunk, (white > 0.7 || i % 3 == 0 ? iceD : flake).alpha(fade))
                }
            }
        }

        // Kim, twirling in the thinning snow: a dark silhouette, drawn whole and then faded, going as the snow does.
        let kim = Self.span(k, 0.46, 0.54) * (1 - Self.span(k, 0.74, 0.92))
        if kim > 0.01 {
            let turn = (k - 0.46) * 2.2 * 2.6 * 2 * .pi
            let tall = max(16, H * 0.36)
            let her = PixelCanvas(c.w, c.h)
            iceDanceKim(her, x: W * 0.5, feet: H * 0.9, tall: tall, turn: turn, col: C(0x2A3350))
            c.paste(her, alpha: kim)
        }
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// Edward's blades flashing up out of the floor at (`x`, `y`): two pairs of long silver points snipping open and
    /// shut, `open` (0…1) through a snip, a glint over them.
    private func iceDanceBlades(_ c: PixelCanvas, x: Double, y: Double, open: Double, size: Double) {
        let spread = sin(open * .pi) * 0.45, w = max(0.6, size * 0.05)
        for (side, lean) in [(-1.0, -0.12), (1.0, 0.12), (-1.0, 0.5), (1.0, 0.74)] {
            let a = -.pi / 2 + lean + side * spread, len = lean > 0.3 ? size * 0.7 : size
            let b = (x - cos(a) * size * 0.25, y - sin(a) * size * 0.25), e = (x + cos(a) * len, y + sin(a) * len)
            burtonLine(c, b.0, b.1, e.0, e.1, C(0x4A5468), w + 0.7)
            burtonLine(c, b.0, b.1, e.0, e.1, C(0xD8E2EE), w)
        }
        let g = Int((y - size * 0.75).rounded()), gx = Int(x.rounded()), arm = max(1, Int(size * 0.12))
        c.rect(gx - arm, g, arm * 2 + 1, 1, C(0xFFFFFF)); c.rect(gx, g - arm, 1, arm * 2 + 1, C(0xFFFFFF))
    }

    /// Kim as a small silhouette standing `tall` art pixels high on `feet`, centred on `x`, twirling on one toe, the
    /// other foot drawn up to her knee, her arms raised over her head, her long hair and her skirt flying out as she
    /// turns (`turn` in radians; the turn shows as her body narrowing side-on and her hair swinging round).
    private func iceDanceKim(_ c: PixelCanvas, x: Double, feet: Double, tall: Double, turn: Double, col: Px) {
        let u = tall / 30                                      // her drawing is 30 units tall
        let face = cos(turn), side = sin(turn)
        let wide = 0.35 + 0.65 * abs(face)                     // how broad she looks, side-on to square-on
        func p(_ a: Double, _ b: Double) -> (Double, Double) { (x + a * u, feet - b * u) }
        func line(_ a: (Double, Double), _ b: (Double, Double), _ w: Double) {
            burtonLine(c, a.0, a.1, b.0, b.1, col, max(0.5, w * u))
        }
        // The leg she turns on, and the other drawn up to its knee.
        line(p(0, 0.5), p(0, 10), 0.8)
        line(p(0.3, 10), p(2.8 * side + 0.6, 7.5), 0.75); line(p(2.8 * side + 0.6, 7.5), p(0.4, 5), 0.65)
        // The skirt, flaring out as she spins.
        let flare = (4.2 + 1.6 * abs(sin(turn * 2))) * wide + 1.2
        burtonTriangle(c, p(-1.3 * wide, 16.5), p(1.3 * wide, 16.5), p(flare, 9.5), col)
        burtonTriangle(c, p(-1.3 * wide, 16.5), p(flare, 9.5), p(-flare, 9.5), col)
        // Her body, nipped in at the waist; her head; her hair down past her shoulders, swinging out as she turns.
        line(p(0, 15.5), p(0, 18), 0.8 * wide + 0.3)
        line(p(0, 18), p(0, 21), 1.25 * wide + 0.35)
        let head = p(0.4 * side, 24.2)
        c.ellipse(Int(head.0.rounded()), Int(head.1.rounded()), max(1, Int(2.1 * u)), max(1, Int(2.4 * u)), col)
        line(p(0, 21), p(0.2 * side, 22.5), 0.9)                              // her neck
        burtonTriangle(c, p(-2 - side, 25.5), p(2 - side, 25.5), p(-side * 5 - 1.5, 18.5), col)
        burtonTriangle(c, p(-2 - side, 25.5), p(2 - side, 25.5), p(-side * 5 + 1.5, 18.5), col)
        // Her arms up and out over her head, softly bent, the hands apart.
        for s in [-1.0, 1.0] {
            let sh = p(s * 1.5 * wide, 20.8), el = p(s * 4.2 * wide, 24.5), hand = p(s * 2.6 * wide + 0.3 * side, 29)
            line(sh, el, 0.6); line(el, hand, 0.5)
        }
    }
}
