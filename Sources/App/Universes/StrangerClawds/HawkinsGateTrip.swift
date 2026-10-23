import CoreGraphics
import Foundation

// The Gate (`HawkinsWipe.gate`): the crack in the wall at Hawkins Lab, torn across the whole picture. A red, glowing
// crack runs down it from top to bottom, pulses like something breathing behind it, and opens wide, its fleshy edges
// burning, on the new place.

extension HawkinsTrip {
    /// A frame `k` (0…1) of the Gate, over the whole of `r`. The crack runs down from the top, jagged, branching as it
    /// goes, and the old place takes a red cast (0–0.3); it pulses, the glow swelling and shrinking, motes drifting off
    /// it (0.3–0.55); it tears open, wider in the middle than at the ends, the edges a raw red rim lit orange, with the
    /// new place through it in a red flash that fades (0.55–1). Pixel art, the opening cut on the art's own grid.
    func drawGate(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let grow = Self.ease(Self.span(k, 0, 0.3))
        let pulse = Self.span(k, 0.3, 0.55) > 0 && k < 0.6 ? 0.5 + 0.5 * sin(Self.span(k, 0.3, 0.6) * .pi * 4 - .pi / 2) : 0
        let open = pow(Self.span(k, 0.55, 1), 2.2)

        // The crack's line: a jagged walk down the middle, the same every frame of this trip.
        let seed = (from.rawValue + to.rawValue).unicodeScalars.reduce(7) { $0 &* 31 &+ Int($1.value) } & 0xFFF
        var line = [Double](repeating: 0, count: h)
        var x = Double(w) / 2 + (noise(seed) - 0.5) * Double(w) * 0.1
        for y in 0..<h {
            if y % 3 == 0 { x += (noise(seed + y * 7) - 0.5) * 5 }
            x += (Double(w) / 2 - x) * 0.04
            line[y] = x
        }
        // How far either side of the line the opening reaches on each row: wider in the middle, ragged at the edge.
        let reach = Double(w) * 1.8 * open
        func half(_ y: Int) -> Double {
            guard open > 0 else { return 0 }
            let u = sin(Double(y) / Double(max(1, h - 1)) * .pi)
            return reach * (0.3 + 0.7 * pow(u, 0.7)) + (noise(seed + y * 13) - 0.5) * 3 * min(1, open * 8)
        }

        // The old place, reddening, and through the opening the new one in a fading red flash.
        ctx.drawShot(old, in: r)
        Self.wash(ctx, 0x3A040A, 0.32 * grow + 0.12 * pulse, in: r)
        if open > 0 {
            let hole = art.runs { x, y in abs(Double(x) - line[y]) < half(y) }
            if !hole.isEmpty {
                ctx.saveGState()
                ctx.clip(to: hole)
                ctx.drawShot(new, in: r)
                Self.wash(ctx, 0x8A1012, 0.6 * (1 - Self.span(k, 0.55, 0.85)), in: r)
                ctx.restoreGState()
            }
        }

        // The crack itself, while it's still a crack: a white-hot core in layers of red glow, and short branches.
        let deep = C(0x6A0A12), red = C(0xE0281E), orange = C(0xFF7A3A), hot = C(0xFFE0B0)
        if open < 0.02 {
            let reached = Int(grow * Double(h))
            let glowR = 2 + Int((2 * pulse).rounded())
            for y in 0..<min(h, reached) {
                let lx = Int(line[y].rounded())
                c.rect(lx - glowR - 2, y, 2 * glowR + 5, 1, deep.alpha(0.35))
                c.rect(lx - glowR, y, 2 * glowR + 1, 1, red.alpha(0.55 + 0.2 * pulse))
                c.rect(lx - 1, y, 3, 1, orange)
                c.px(lx, y, hot)
                // A branch now and then, running off to one side and down.
                if y % 11 == 5, noise(seed + y) > 0.35 {
                    let dir = noise(seed + y * 3) > 0.5 ? 1 : -1, len = 3 + Int(noise(seed + y * 5) * 6)
                    for i in 1...len where y + i / 2 < reached { c.px(lx + dir * (i + 1), y + i / 2, i < len / 2 ? orange : red) }
                }
            }
        } else {
            // The opening's rim: raw red at its very edge, lit orange inside it, with a dim glow round the outside.
            for y in 0..<h {
                let hw = half(y), lx = line[y]
                for side in [-1.0, 1.0] {
                    let e = Int((lx + side * hw).rounded())
                    let d = Int(side)
                    c.rect(min(e, e + d * 4), y, 5, 1, deep.alpha(0.4))
                    c.px(e + d, y, deep); c.px(e + d * 2, y, deep.alpha(0.6))
                    c.px(e, y, red); c.px(e - d, y, red); c.px(e - d * 2, y, orange); c.px(e - d * 3, y, orange.alpha(0.5))
                }
            }
        }

        // Motes drifting off it while it pulses and opens: small embers rising.
        if k > 0.25 && k < 0.9 {
            let strength = Self.span(k, 0.25, 0.4) * (1 - Self.span(k, 0.75, 0.9))
            for i in 0..<36 {
                let rise = (noise(i * 5 + 1) + k * (1 + noise(i * 5 + 2))).truncatingRemainder(dividingBy: 1)
                let y = h - Int(rise * Double(h + 6))
                guard y >= 0, y < h else { continue }
                let x = Int(line[y]) + Int((noise(i * 5 + 3) - 0.5) * (Double(w) * 0.12 + half(y) * 2.2))
                c.px(x, y, (i % 3 == 0 ? hot : orange).alpha(strength * (0.5 + 0.5 * noise(i * 9 + Int(k * 40)))))
            }
        }
        art.show(ctx)
    }
}
