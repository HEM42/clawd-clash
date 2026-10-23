import CoreGraphics
import Foundation

// Fireworks (`HawkinsWipe.fireworks`): the Fourth of July over Starcourt, the night of the battle. The old place
// goes dark, rockets climb and burst, and the new place lights up in their glow.

extension HawkinsTrip {
    /// A frame `k` (0…1) of Fireworks, over the whole of `r`. Night falls over the old place (0–0.2); five rockets
    /// climb on sparking trails and burst one after another into rings of sparks, red, green, blue, gold and pink, that
    /// slow, droop and fade (0.06–0.9); round each burst the new place shows, dimly lit by it, brighter close in, the glow
    /// widening, until the whole of it is there (0.72–0.95). Sparks and trails are pixel art; the glow is cut on the art's grid.
    func drawFireworks(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let night = Self.ease(Self.span(k, 0, 0.2))
        let whole = Self.span(k, 0.72, 0.95)

        // The rockets: when each goes up, from where, how high it bursts and in what colour.
        let rockets: [(at: Double, x: Double, top: Double, col: UInt32)] = [
            (0.06, 0.3, 0.3, 0xFF4A4A), (0.16, 0.68, 0.22, 0x6AF07A), (0.27, 0.5, 0.36, 0x6A9AFF),
            (0.36, 0.16, 0.24, 0xFFD24A), (0.45, 0.84, 0.32, 0xFF80C8),
        ]
        let climb = 0.14, life = 0.42
        let R = Double(min(h, w / 2)) * 0.36

        ctx.drawShot(old, in: r)
        Self.wash(ctx, 0x060A1E, 0.72 * night, in: r)
        // The new place, where the bursts light it.
        var lit: [(x: Double, y: Double, r: Double)] = []
        for rk in rockets where k > rk.at + climb {
            let u = Self.span(k, rk.at + climb, rk.at + climb + 0.3)
            lit.append((rk.x * Double(w), rk.top * Double(h), R * (0.3 + 1.0 * Self.ease(u))))
        }
        if whole > 0 {
            ctx.saveGState()
            ctx.setAlpha(CGFloat((Self.ease(whole) * 5).rounded() / 5))
            ctx.drawShot(new, in: r)
            ctx.restoreGState()
        }
        if !lit.isEmpty && whole < 1 {
            // In two steps out from each burst: dimly lit at the edge of its glow, brighter close in, still night-blue
            // enough for the sparks to show against it.
            for (reach, dim) in [(1.0, 0.6), (0.6, 0.38)] {
                let glow = art.runs { x, y in
                    lit.contains { (Double(x) - $0.x) * (Double(x) - $0.x) + (Double(y) - $0.y) * (Double(y) - $0.y) * 1.6 < $0.r * $0.r * reach * reach }
                }
                guard !glow.isEmpty else { continue }
                ctx.saveGState()
                ctx.clip(to: glow)
                ctx.drawShot(new, in: r)
                Self.wash(ctx, 0x060A1E, dim * (1 - whole), in: r)
                ctx.restoreGState()
            }
        }

        for (i, rk) in rockets.enumerated() {
            let x0 = rk.x * Double(w), y0 = Double(h) + 2, y1 = rk.top * Double(h)
            if k >= rk.at && k < rk.at + climb {
                // Climbing: a bright head, a sparking trail behind it, curving a touch.
                let u = Self.ease((k - rk.at) / climb)
                let y = y0 + (y1 - y0) * u, x = x0 + sin(u * 2) * 3
                for t in 0..<14 {
                    let ty = y + Double(t) * 2.5
                    guard ty < y0 else { break }
                    if noise(i * 97 + t + Int(k * 60)) > 0.35 {
                        c.px(Int(x - sin(Double(t) * 0.3)), Int(ty), C(0xFFD8A0, 0.9 - Double(t) * 0.06))
                    }
                }
                c.rect(Int(x), Int(y), 2, 2, C(0xFFF4D8))
            } else if k >= rk.at + climb && k < rk.at + climb + life {
                // The burst: sparks flying out in a ring, slowing, drooping, flickering out, each with a short tail.
                let u = (k - rk.at - climb) / life
                let spread = 1 - pow(1 - min(1, u * 1.6), 2.5)
                let count = 28
                for s in 0..<count {
                    let a = Double(s) / Double(count) * 2 * .pi + Double(i)
                    let reach = R * (0.85 + noise(i * 31 + s) * 0.3)
                    let d = reach * spread, droop = u * u * R * 0.5
                    let x = x0 + cos(a) * d, y = y1 + sin(a) * d * 0.9 + droop
                    let fade = 1 - u
                    guard fade > 0.05, noise(s * 13 + Int(k * 70)) > u * 0.6 else { continue }
                    let tail = max(0.0, d - reach * 0.18)
                    hawkinsLine(c, x0 + cos(a) * tail, y1 + sin(a) * tail * 0.9 + droop * 0.8, x, y, C(rk.col, 0.55 * fade), 0.5)
                    c.rect(Int(x), Int(y), 2, 2, C(0xFFFFFF, fade))
                    c.px(Int(x) - 1, Int(y), C(rk.col, fade)); c.px(Int(x), Int(y) - 1, C(rk.col, fade))
                }
                // The flash of the burst itself, for a moment.
                if u < 0.12 { c.circle(Int(x0), Int(y1), Int(R * 0.25 * (1 - u / 0.12) + 2), C(0xFFF4D8, 0.8 * (1 - u / 0.12))) }
            }
        }
        art.show(ctx)
    }
}
